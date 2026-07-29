"""P1-ILI: multi-region HHS %wILI vs external FluSurv t_obs (protocol v1.0.0).

Honesty
-------
* ``t_obs`` from FluSurv hospitalization rates only (not national ILI peak).
* Score refuses null t_obs, false pre_registered, or endpoints hash ≠ lock.
* Seasons 2020–21+ excluded a priori (COVID surveillance disruption).
"""

from __future__ import annotations

import hashlib
import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional, Sequence, Tuple

import numpy as np

from .ili_io import (
    default_ili_paths,
    load_flusurv_csv,
    load_ili_sites,
    parse_season_label,
    season_label,
)
from .p1_endpoints import first_sustained_chaos_ascent, score_p1_for_series

PROTOCOL_ID = "P1_ILI_EXTERNAL_TOBS"
PROTOCOL_VERSION = "1.0.0"
SCHEMA_ENDPOINTS = "systemic-tau-formal/ili-endpoints/v1"
SCHEMA_LOCK = "systemic-tau-formal/ili-protocol-lock/v1"

FROZEN_PARAMS: Dict[str, Any] = {
    "window_size": 13,
    "theta_chaos": 0.41,
    "theta_stable": 0.50,
    "min_run": 4,
    "t_star": "first_sustained_chaos_ascent",
    "lead_lo": 4,
    "lead_hi": 6,
    "lead_unit": "weeks_approx_row_index",
}

# A priori exclusion — do not score COVID-disrupted seasons under v1.0.0.
EXCLUDED_SEASON_START_YEARS = frozenset({2020, 2021, 2022, 2023, 2024, 2025})


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def git_commit(root: Optional[Path] = None) -> Optional[str]:
    root = Path(root) if root is not None else _repo_root()
    try:
        out = subprocess.check_output(
            ["git", "rev-parse", "HEAD"],
            cwd=str(root),
            stderr=subprocess.DEVNULL,
            text=True,
        ).strip()
        return out or None
    except (subprocess.CalledProcessError, FileNotFoundError, OSError):
        return None


def canonical_json_bytes(obj: Any) -> bytes:
    return json.dumps(obj, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode(
        "utf-8"
    )


def sha256_obj(obj: Any) -> str:
    return hashlib.sha256(canonical_json_bytes(obj)).hexdigest()


def write_json(path: Path, obj: Any) -> Path:
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2) + "\n", encoding="utf-8")
    return path


def load_calendar_map(path: Optional[Path] = None) -> dict:
    path = path or default_ili_paths()["calendar"]
    return json.loads(Path(path).read_text(encoding="utf-8"))


def choose_external_season_week(
    incidence: Sequence[dict],
    *,
    season: str,
    method: str = "peak_week",
) -> Dict[str, Any]:
    """
    Pick FluSurv event week from external rates for one flu season only.

    ``incidence`` rows need: season, epiweek, total_cases (or rate_overall).
    """
    rows = [r for r in incidence if str(r.get("season")) == str(season)]
    if not rows:
        return {
            "ok": False,
            "reason": f"no FluSurv rows for season={season}",
            "method": method,
            "season": season,
        }
    rates = np.array(
        [
            float(r.get("total_cases", r.get("rate_overall", np.nan)))
            for r in rows
        ],
        dtype=float,
    )
    ews = np.array([int(r["epiweek"]) for r in rows], dtype=int)
    max_rate = float(np.nanmax(rates)) if rates.size else 0.0
    if not np.isfinite(max_rate) or max_rate <= 0.0:
        return {
            "ok": False,
            "reason": "no clinical event: max(rate_overall) <= 0",
            "method": method,
            "season": season,
            "max_rate": max_rate,
        }
    if method == "peak_week":
        i = int(np.nanargmax(rates))
        return {
            "ok": True,
            "method": method,
            "season": season,
            "epiweek": int(ews[i]),
            "year": int(ews[i]) // 100,
            "weekofyear": int(ews[i]) % 100,
            "rate_overall": float(rates[i]),
            "total_cases": float(rates[i]),
            "reason": "argmax FluSurv rate_overall in season",
        }
    if method == "first_exceed_season_p75":
        thr = float(np.nanpercentile(rates, 75))
        if thr <= 0.0:
            return {
                "ok": False,
                "reason": "season p75 of rates <= 0",
                "method": method,
                "threshold_p75": thr,
            }
        hits = np.where(rates >= thr)[0]
        if len(hits) == 0:
            return {"ok": False, "reason": "no week exceeds season p75", "method": method}
        i = int(hits[0])
        return {
            "ok": True,
            "method": method,
            "season": season,
            "epiweek": int(ews[i]),
            "year": int(ews[i]) // 100,
            "weekofyear": int(ews[i]) % 100,
            "rate_overall": float(rates[i]),
            "total_cases": float(rates[i]),
            "threshold_p75": thr,
            "reason": "first week >= season p75 of FluSurv rate_overall",
        }
    return {"ok": False, "reason": f"unknown method {method!r}", "method": method}


def epiweek_to_row_from_calendar(
    series_key: str,
    epiweek: int,
    calendar: dict,
) -> Optional[int]:
    """Map FluSurv peak epiweek → matrix row using calendar_map series.epiweeks."""
    series = calendar.get("series", {}).get(series_key)
    if series is None:
        return None
    ews = series.get("epiweeks") or []
    ew = int(epiweek)
    for i, w in enumerate(ews):
        if int(w) == ew:
            return int(i)
    return None


def propose_endpoints_from_flusurv(
    flusurv_path: Path,
    *,
    method: str = "peak_week",
    root: Optional[Path] = None,
    calendar: Optional[dict] = None,
    source_note: str = "",
    pre_register: bool = False,
) -> dict:
    """
    Build endpoints from FluSurv + calendar.

    By default ``pre_registered: false`` (candidates). Set ``pre_register=True``
    only when applying the frozen a-priori rule after human review of mapping.
    """
    paths = default_ili_paths(root)
    calendar = calendar or load_calendar_map(paths["calendar"])
    incidence = load_flusurv_csv(Path(flusurv_path))
    series_out: List[dict] = []

    for key, meta in calendar.get("series", {}).items():
        season = meta.get("season") or key.replace("HHS_wILI_", "")
        sy = int(meta.get("start_year") or parse_season_label(str(season)))
        excluded = sy in EXCLUDED_SEASON_START_YEARS
        choice = choose_external_season_week(incidence, season=str(season), method=method)
        row: Dict[str, Any] = {
            "file": meta["file"],
            "series_key": key,
            "season": season,
            "t_obs": None,
            "t_obs_unit": "row_index_0_based_within_season",
            "endpoint_definition": (
                f"External FluSurv network_all rate_overall via method={method} "
                f"(protocol {PROTOCOL_VERSION}) — not national ILI peak."
            ),
            "pre_registered": False,
            "excluded_a_priori": excluded,
            "external": choice,
            "source_incidence": str(flusurv_path),
        }
        if excluded:
            row["reason"] = f"season start_year={sy} excluded a priori (COVID-era)"
            series_out.append(row)
            continue
        if choice.get("ok"):
            t_row = epiweek_to_row_from_calendar(key, int(choice["epiweek"]), calendar)
            row["t_obs"] = t_row
            row["external_epiweek"] = int(choice["epiweek"])
            if t_row is None:
                row["reason"] = (
                    f"FluSurv peak epiweek {choice['epiweek']} not in HHS season matrix rows"
                )
            else:
                row["reason"] = "mapped from FluSurv; set pre_registered true after review"
                if pre_register:
                    row["pre_registered"] = True
                    row["reason"] = "a priori FluSurv peak_week mapped; pre_registered"
        else:
            row["reason"] = choice.get("reason", "external week selection failed")
        series_out.append(row)

    return {
        "schema": SCHEMA_ENDPOINTS,
        "protocol": PROTOCOL_ID,
        "protocol_version": PROTOCOL_VERSION,
        "status": "pre_registered" if pre_register else "candidates_not_pre_registered",
        "label": "[EMPÍRICO]",
        "geo": "USA_HHS_regions",
        "design": {
            "channels": "HHS1-10 ILINet wILI a_priori",
            "t_obs_rule": f"FluSurv network_all rate_overall {method} within season",
            "note": "t_obs from FluSurv only; τ* not inspected before lock",
            "exclude_seasons": "2020+ a priori (COVID surveillance disruption)",
            "sources": {
                "channels": "Delphi Epidata fluview (CDC ILINet)",
                "t_obs": "Delphi Epidata flusurv location=network_all",
            },
        },
        "source_note": source_note,
        "frozen_params": dict(FROZEN_PARAMS),
        "method": method,
        "series": series_out,
    }


def make_protocol_lock(
    endpoints: dict,
    *,
    root: Optional[Path] = None,
    extra: Optional[dict] = None,
) -> dict:
    commit = git_commit(root)
    endpoints_sha = sha256_obj(endpoints)
    lock = {
        "schema": SCHEMA_LOCK,
        "protocol": PROTOCOL_ID,
        "protocol_version": PROTOCOL_VERSION,
        "frozen_params": dict(FROZEN_PARAMS),
        "endpoints_sha256": endpoints_sha,
        "git_commit": commit,
        "locked_at_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "n_series": len(endpoints.get("series", [])),
        "n_pre_registered": sum(
            1
            for s in endpoints.get("series", [])
            if s.get("pre_registered") and s.get("t_obs") is not None
        ),
    }
    if extra:
        lock["extra"] = extra
    lock["lock_sha256"] = sha256_obj(lock)
    return lock


def verify_lock(endpoints: dict, lock: dict) -> Tuple[bool, str]:
    if lock.get("protocol") != PROTOCOL_ID:
        return False, f"protocol mismatch: {lock.get('protocol')}"
    if lock.get("protocol_version") != PROTOCOL_VERSION:
        return False, f"version mismatch: {lock.get('protocol_version')}"
    if lock.get("frozen_params") != FROZEN_PARAMS:
        return False, "frozen_params drift vs FROZEN_PARAMS"
    expect = sha256_obj(endpoints)
    if lock.get("endpoints_sha256") != expect:
        return False, "endpoints_sha256 mismatch (endpoints changed after lock)"
    return True, "ok"


def score_locked_endpoints(
    endpoints: dict,
    lock: dict,
    *,
    root: Optional[Path] = None,
    sites: Optional[Dict[str, np.ndarray]] = None,
) -> dict:
    ok, reason = verify_lock(endpoints, lock)
    if not ok:
        return {
            "scored": False,
            "protocol": PROTOCOL_ID,
            "protocol_version": PROTOCOL_VERSION,
            "reason": reason,
            "rows": [],
        }
    root = Path(root) if root is not None else _repo_root()
    if sites is None:
        loaded = load_ili_sites(root=root)
        sites = loaded.sites
        source = loaded.source
        label = loaded.label
    else:
        source = "provided"
        label = "[EMPÍRICO]"

    w = int(FROZEN_PARAMS["window_size"])
    lead_lo = int(FROZEN_PARAMS["lead_lo"])
    lead_hi = int(FROZEN_PARAMS["lead_hi"])
    rows: List[dict] = []
    for entry in endpoints.get("series", []):
        fname = entry.get("file") or entry.get("path")
        stem = Path(str(fname)).stem if fname else None
        t_obs = entry.get("t_obs")
        row: Dict[str, Any] = {
            "file": fname,
            "series_key": entry.get("series_key") or stem,
            "season": entry.get("season"),
            "pre_registered": bool(entry.get("pre_registered", False)),
            "scored": False,
        }
        if entry.get("excluded_a_priori"):
            row["reason"] = "excluded a priori"
            row["verdict"] = "not_scored"
            rows.append(row)
            continue
        if t_obs is None:
            row["reason"] = "t_obs is null — P1 not scored"
            row["verdict"] = "not_scored"
            rows.append(row)
            continue
        if not entry.get("pre_registered", False):
            row["reason"] = "pre_registered is false — refuse to score (honesty)"
            row["verdict"] = "not_scored"
            rows.append(row)
            continue
        if stem not in sites:
            row["reason"] = f"series stem {stem!r} not loaded"
            row["verdict"] = "not_scored"
            rows.append(row)
            continue
        scored = score_p1_for_series(
            sites[stem],
            int(t_obs),
            window_size=w,
            lead_lo=lead_lo,
            lead_hi=lead_hi,
        )
        row.update(scored)
        if not scored.get("scored"):
            row["verdict"] = "not_scored"
        elif scored.get("t_star") is None:
            row["verdict"] = "no_signal"
        elif scored.get("pass"):
            row["verdict"] = "hit"
        else:
            row["verdict"] = "miss_lead"
        rows.append(row)

    n_scored = sum(1 for r in rows if r.get("scored"))
    n_hit = sum(1 for r in rows if r.get("verdict") == "hit")
    return {
        "scored": True,
        "protocol": PROTOCOL_ID,
        "protocol_version": PROTOCOL_VERSION,
        "label": label,
        "source": source,
        "endpoints_sha256": lock.get("endpoints_sha256"),
        "git_commit": lock.get("git_commit"),
        "frozen_params": dict(FROZEN_PARAMS),
        "n_scored": n_scored,
        "n_hit": n_hit,
        "hit_rate": (n_hit / n_scored) if n_scored else None,
        "rows": rows,
        "honesty": (
            "P1-ILI v1.0.0: HHS1–10 wILI τₛ vs FluSurv network_all peak only. "
            "Does not use national ILI as t_obs. COVID seasons 2020+ excluded a priori."
        ),
    }


def default_season_start_years_v1() -> List[int]:
    """Protocol v1.0.0 default panel: 2010–11 … 2019–20."""
    return list(range(2010, 2020))
