"""P1-Aedes: multi-trap field τₛ vs external domain t_obs (protocol v1.0.0).

Honesty
-------
* ``t_obs`` must come from an **external** clinical / intervention series.
* Trap-surge / max_total are never written with ``pre_registered: true``.
* Score refuses null t_obs, false pre_registered, or endpoints hash ≠ lock.
"""

from __future__ import annotations

import hashlib
import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional, Sequence, Tuple

import numpy as np

from .aedes_io import load_aedes_sites
from .p1_endpoints import first_sustained_chaos_ascent, score_p1_for_series

PROTOCOL_ID = "P1_AEDES_EXTERNAL_TOBS"
PROTOCOL_VERSION = "1.0.0"
SCHEMA_ENDPOINTS = "systemic-tau-formal/aedes-endpoints/v1"
SCHEMA_LOCK = "systemic-tau-formal/aedes-protocol-lock/v1"

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


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def default_paths(root: Optional[Path] = None) -> Dict[str, Path]:
    root = Path(root) if root is not None else _repo_root()
    raw = root / "data" / "aedes" / "raw"
    return {
        "root": root,
        "raw": raw,
        "calendar": raw / "calendar_map.json",
        "endpoints_example": raw / "endpoints.example.json",
        "endpoints": raw / "endpoints.json",
        "endpoints_candidates": raw / "endpoints_candidates.json",
        "lock": raw / "protocol_lock.json",
        "last_score": raw / "last_p1_aedes_score.json",
        "external": root / "data" / "aedes" / "external",
    }


def load_calendar_map(path: Optional[Path] = None) -> dict:
    path = path or default_paths()["calendar"]
    return json.loads(Path(path).read_text(encoding="utf-8"))


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


def epiweek_to_row(
    series_key: str,
    epiweek: int,
    calendar: Optional[dict] = None,
    *,
    nearest: bool = True,
) -> Optional[int]:
    """
    Map calendar week → matrix row index using calendar_map.json.

    For thesis_epiweek series: exact arithmetic.
    For date_iso_week (SJU3): exact iso_week match, else nearest row by |Δweek|.
    """
    calendar = calendar or load_calendar_map()
    series = calendar.get("series", {}).get(series_key)
    if series is None:
        # allow file stem aliases
        for k, v in calendar.get("series", {}).items():
            if Path(v.get("file", "")).stem == series_key or k == series_key:
                series = v
                series_key = k
                break
    if series is None:
        return None
    kind = series.get("calendar_kind")
    w = int(epiweek)
    if kind == "thesis_epiweek":
        start = int(series["epiweek_start"])
        end = int(series["epiweek_end"])
        if w < start or w > end:
            return None
        return int(w - start)
    if kind == "date_iso_week":
        rows = series.get("rows") or []
        exact = [r for r in rows if int(r["iso_week"]) == w]
        if exact:
            return int(exact[0]["row"])
        if not nearest or not rows:
            return None
        best = min(rows, key=lambda r: abs(int(r["iso_week"]) - w))
        return int(best["row"])
    return None


def series_key_for_file(fname: str, calendar: Optional[dict] = None) -> str:
    stem = Path(fname).stem
    calendar = calendar or load_calendar_map()
    for k, v in calendar.get("series", {}).items():
        if Path(v.get("file", "")).stem == stem or k == stem:
            return k
    return stem


def load_incidence_csv(path: Path) -> List[dict]:
    """
    Load external weekly incidence.

    Required columns (case-insensitive): year, weekofyear, total_cases.
    Optional: week_start_date, geo.
    """
    import csv

    path = Path(path)
    with path.open(newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        if reader.fieldnames is None:
            raise ValueError(f"empty incidence CSV: {path}")
        fields = {h.lower().strip(): h for h in reader.fieldnames}
        for req in ("year", "weekofyear", "total_cases"):
            if req not in fields:
                raise ValueError(
                    f"incidence CSV missing column {req!r} (have {list(reader.fieldnames)})"
                )
        rows: List[dict] = []
        for raw in reader:
            try:
                year = int(float(raw[fields["year"]]))
                week = int(float(raw[fields["weekofyear"]]))
                cases = float(raw[fields["total_cases"]])
            except (TypeError, ValueError):
                continue
            item = {
                "year": year,
                "weekofyear": week,
                "total_cases": cases,
            }
            if "week_start_date" in fields and raw.get(fields["week_start_date"]):
                item["week_start_date"] = raw[fields["week_start_date"]]
            if "geo" in fields and raw.get(fields["geo"]):
                item["geo"] = raw[fields["geo"]]
            rows.append(item)
    return rows


def choose_external_week(
    incidence: Sequence[dict],
    *,
    year: int,
    method: str = "peak_week",
    week_min: Optional[int] = None,
    week_max: Optional[int] = None,
) -> Dict[str, Any]:
    """Pick an external outbreak week from incidence only (no trap data)."""
    rows = [
        r
        for r in incidence
        if int(r["year"]) == int(year)
        and (week_min is None or int(r["weekofyear"]) >= week_min)
        and (week_max is None or int(r["weekofyear"]) <= week_max)
    ]
    if not rows:
        return {
            "ok": False,
            "reason": f"no incidence rows for year={year} in week span",
            "method": method,
        }
    cases = np.array([float(r["total_cases"]) for r in rows], dtype=float)
    weeks = np.array([int(r["weekofyear"]) for r in rows], dtype=int)
    # Honest: a flat-zero clinical year has no domain transition to forecast.
    # argmax/p75 on all zeros would invent a fake t_obs at the first week of span.
    max_cases = float(np.nanmax(cases)) if cases.size else 0.0
    if not np.isfinite(max_cases) or max_cases <= 0.0:
        return {
            "ok": False,
            "reason": (
                "no clinical event in span: max(total_cases) <= 0 "
                "(cannot define peak_week / first_exceed_year_p75)"
            ),
            "method": method,
            "year": int(year),
            "max_total_cases": max_cases,
            "n_weeks": int(len(rows)),
        }
    if method == "peak_week":
        i = int(np.nanargmax(cases))
        return {
            "ok": True,
            "method": method,
            "year": int(year),
            "weekofyear": int(weeks[i]),
            "total_cases": float(cases[i]),
            "reason": "argmax total_cases in span",
        }
    if method == "first_exceed_year_p75":
        thr = float(np.nanpercentile(cases, 75))
        if thr <= 0.0:
            return {
                "ok": False,
                "reason": "year p75 of weekly cases is <= 0 (no positive exceedance event)",
                "method": method,
                "threshold_p75": thr,
            }
        hits = np.where(cases >= thr)[0]
        if len(hits) == 0:
            return {"ok": False, "reason": "no week exceeds year p75", "method": method}
        i = int(hits[0])
        return {
            "ok": True,
            "method": method,
            "year": int(year),
            "weekofyear": int(weeks[i]),
            "total_cases": float(cases[i]),
            "threshold_p75": thr,
            "reason": "first week >= year p75 of weekly cases",
        }
    return {"ok": False, "reason": f"unknown method {method!r}", "method": method}


def propose_endpoints_from_incidence(
    incidence_path: Path,
    *,
    method: str = "peak_week",
    root: Optional[Path] = None,
    calendar: Optional[dict] = None,
    year: int = 2018,
    source_note: str = "",
) -> dict:
    """
    Build endpoints **candidates** from external incidence + calendar map.

    Always sets ``pre_registered: false``. Human must review and promote.
    """
    calendar = calendar or load_calendar_map(default_paths(root)["calendar"])
    incidence = load_incidence_csv(Path(incidence_path))
    series_out: List[dict] = []
    for key, meta in calendar.get("series", {}).items():
        fname = meta["file"]
        if meta.get("calendar_kind") == "thesis_epiweek":
            wmin, wmax = int(meta["epiweek_start"]), int(meta["epiweek_end"])
        else:
            weeks = [int(r["iso_week"]) for r in meta.get("rows", [])]
            wmin, wmax = (min(weeks), max(weeks)) if weeks else (None, None)
        choice = choose_external_week(
            incidence, year=year, method=method, week_min=wmin, week_max=wmax
        )
        row: Dict[str, Any] = {
            "file": fname,
            "series_key": key,
            "t_obs": None,
            "t_obs_unit": "row_index_0_based",
            "endpoint_definition": (
                f"External clinical/intervention week via method={method} "
                f"(protocol {PROTOCOL_VERSION}) — not trap-surge."
            ),
            "pre_registered": False,
            "external": choice,
            "source_incidence": str(incidence_path),
        }
        if choice.get("ok"):
            t_row = epiweek_to_row(key, int(choice["weekofyear"]), calendar)
            row["t_obs"] = t_row
            row["external_weekofyear"] = int(choice["weekofyear"])
            if t_row is None:
                row["reason"] = "week not mappable to trap rows"
            else:
                row["reason"] = "mapped; set pre_registered true after human review"
        else:
            row["reason"] = choice.get("reason", "external week selection failed")
        series_out.append(row)

    return {
        "schema": SCHEMA_ENDPOINTS,
        "protocol": PROTOCOL_ID,
        "protocol_version": PROTOCOL_VERSION,
        "status": "candidates_not_pre_registered",
        "label": "[EMPÍRICO]",
        "note": (
            "CANDIDATES only. Review mapping, set pre_registered:true per series "
            "you trust, then lock. Never score with pre_registered false."
        ),
        "source_note": source_note,
        "frozen_params": dict(FROZEN_PARAMS),
        "method": method,
        "year": year,
        "series": series_out,
    }


def scaffold_endpoints_null(root: Optional[Path] = None) -> dict:
    """Null-endpoint scaffold aligned to calendar_map (no invented dates)."""
    calendar = load_calendar_map(default_paths(root)["calendar"])
    series = []
    for key, meta in calendar.get("series", {}).items():
        series.append(
            {
                "file": meta["file"],
                "series_key": key,
                "t_obs": None,
                "t_obs_unit": "row_index_0_based",
                "endpoint_definition": (
                    "External domain transition (outbreak week / intervention) — "
                    "not trap-surge max."
                ),
                "pre_registered": False,
            }
        )
    return {
        "schema": SCHEMA_ENDPOINTS,
        "protocol": PROTOCOL_ID,
        "protocol_version": PROTOCOL_VERSION,
        "label": "[EMPÍRICO]",
        "note": (
            "Copy to endpoints.json (gitignored). Fill t_obs from external incidence "
            "under data/aedes/external/ + pre_registered:true before scoring."
        ),
        "frozen_params": dict(FROZEN_PARAMS),
        "series": series,
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
            1 for s in endpoints.get("series", []) if s.get("pre_registered") and s.get("t_obs") is not None
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
        loaded = load_aedes_sites(root=root, prefer_raw=True)
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
            "pre_registered": bool(entry.get("pre_registered", False)),
            "scored": False,
        }
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
            "P1-Aedes v1.0.0: multi-trap τₛ vs external t_obs only. "
            "Does not promote trap-surge exploratory leads. "
            "Spatial scale: neighborhood traps vs municipal/island clinical if used."
        ),
    }


def write_json(path: Path, obj: Any) -> Path:
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2) + "\n", encoding="utf-8")
    return path
