"""P1-Synthetic Canonical: instrument validation of chaos-band EWS (v1.0.0).

Honesty
-------
* Lab generators only — never counted as field P1 discharge.
* Same FROZEN_PARAMS as P1-Aedes / P1-ILI (w=13, θ=0.41, lead 4–6).
* φ_phenom = w = 13 a priori (t_obs = t_switch + φ).
* Lock SHA before score; refuse drift.
"""

from __future__ import annotations

import hashlib
import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional, Sequence, Tuple

import numpy as np

from .io_data import load_matrix_csv, save_matrix_csv
from .p1_endpoints import first_sustained_chaos_ascent, score_p1_for_series
from .recd import accumulate_time
from .synthetic import (
    p1_canonical_null_noise,
    p1_canonical_null_sync,
    p1_canonical_panel,
)
from .tau import compute_taus

PROTOCOL_ID = "P1_SYNTHETIC_CANONICAL"
PROTOCOL_VERSION = "1.0.0"
SCHEMA_ENDPOINTS = "systemic-tau-formal/p1-syn-endpoints/v1"
SCHEMA_LOCK = "systemic-tau-formal/p1-syn-protocol-lock/v1"
SCHEMA_SCORE = "systemic-tau-formal/p1-syn-score/v1"

# Same operational detector as empirical P1 tracks.
FROZEN_PARAMS: Dict[str, Any] = {
    "window_size": 13,
    "theta_chaos": 0.41,
    "theta_stable": 0.50,
    "min_run": 4,
    "t_star": "first_sustained_chaos_ascent",
    "lead_lo": 4,
    "lead_hi": 6,
    "lead_unit": "row_index",
    "phi_phenom": 13,  # a priori = window_size; synthetic event lag after break
    # C1 companion (false early warnings): max rows after t* for a justified event
    "c1_horizon": 13,  # = w; plant leads 4–6 must fall inside
}

# Generator config frozen with protocol (not free parameters at score time).
GENERATOR_CONFIG: Dict[str, Any] = {
    "T": 120,
    "N": 6,
    "t_switch": 40,
    "noise_pre": 0.02,
    "period": 52.0,
    "plant_seeds": list(range(0, 20)),
    "sync_seeds": list(range(100, 110)),
    "noise_seeds": list(range(200, 210)),
}

# Acceptance gates (docs/P1_SYNTHETIC_CANONICAL.md §4)
GATES: Dict[str, Any] = {
    "G1_lag_lo": 0,
    "G1_lag_hi": 13,  # = w
    "G2_min_hit_rate": 0.80,
    "G3_max_hit_rate": 0.0,  # pure_sync: no hits
    "G3_require_all_no_signal": True,
    "G4_max_hit_rate": 0.10,  # pure_noise P1-hit with mid t_obs
}

# C1 companion gates (challenge C1 — false early warnings). Separate from G1–G4.
C1_GATES: Dict[str, Any] = {
    "C1A_plant_max_fp_rate": 0.10,  # alerts must be justified by planted t_obs
    "C1B_sync_max_alert_rate": 0.0,  # order-only: no alerts
    # C1C ambient chaos: pure_noise alert/FP rate is *reported*; chaos polarity is
    # expected to FAIL specificity here (honest C1 stress). Pass if FP ≤ threshold.
    "C1C_noise_max_fp_rate": 0.20,
    "C1C_required_for_c1_pass": True,
}


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def default_syn_paths(root: Optional[Path] = None) -> Dict[str, Path]:
    root = Path(root) if root is not None else _repo_root()
    base = root / "data" / "synthetic" / "p1_canonical"
    return {
        "root": root,
        "base": base,
        "matrices": base / "matrices",
        "endpoints": base / "endpoints.json",
        "lock": base / "protocol_lock.json",
        "score": base / "last_score.json",
        "gates": base / "last_gates.json",
        "c1": base / "last_c1.json",
        "manifest": base / "manifest.json",
    }


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


def series_stem(panel: str, seed: int) -> str:
    return f"{panel}_seed{int(seed):03d}"


def generate_suite(
    *,
    root: Optional[Path] = None,
    write: bool = True,
) -> Dict[str, Any]:
    """
    Generate plant + null matrices and endpoints document.

    Returns dict with sites, endpoints, meta rows (and writes if *write*).
    """
    paths = default_syn_paths(root)
    cfg = GENERATOR_CONFIG
    phi = int(FROZEN_PARAMS["phi_phenom"])
    T = int(cfg["T"])
    N = int(cfg["N"])
    t_switch = int(cfg["t_switch"])
    noise_pre = float(cfg["noise_pre"])
    period = float(cfg["period"])

    sites: Dict[str, np.ndarray] = {}
    series: List[dict] = []
    matrix_meta: List[dict] = []

    def _add(
        panel: str,
        seed: int,
        X: np.ndarray,
        meta: dict,
        *,
        t_obs: int,
        pre_registered: bool = True,
    ) -> None:
        stem = series_stem(panel, seed)
        fname = f"{stem}.csv"
        sites[stem] = np.asarray(X, dtype=float)
        entry = {
            "file": fname,
            "series_key": stem,
            "panel": panel,
            "seed": int(seed),
            "t_obs": int(t_obs),
            "t_switch": (
                None
                if panel != "plant"
                else int(meta.get("t_switch", t_switch))
            ),
            "phi_phenom": int(phi) if panel == "plant" else None,
            "pre_registered": bool(pre_registered),
            "generator": meta.get("generator"),
            "shape": [int(X.shape[0]), int(X.shape[1])],
        }
        series.append(entry)
        matrix_meta.append({**entry, "meta": {k: meta[k] for k in meta}})
        if write:
            mat_dir = paths["matrices"]
            mat_dir.mkdir(parents=True, exist_ok=True)
            save_matrix_csv(mat_dir / fname, sites[stem])

    for seed in cfg["plant_seeds"]:
        X, meta = p1_canonical_panel(
            T=T,
            N=N,
            t_switch=t_switch,
            noise_pre=noise_pre,
            period=period,
            seed=int(seed),
            phi_phenom=phi,
        )
        _add("plant", int(seed), X, meta, t_obs=int(meta["t_obs"]))

    for seed in cfg["sync_seeds"]:
        X, meta = p1_canonical_null_sync(
            T=T, N=N, noise_pre=noise_pre, period=period, seed=int(seed)
        )
        _add("pure_sync", int(seed), X, meta, t_obs=int(meta["t_obs"]))

    for seed in cfg["noise_seeds"]:
        X, meta = p1_canonical_null_noise(T=T, N=N, seed=int(seed))
        _add("pure_noise", int(seed), X, meta, t_obs=int(meta["t_obs"]))

    endpoints = {
        "schema": SCHEMA_ENDPOINTS,
        "protocol": PROTOCOL_ID,
        "protocol_version": PROTOCOL_VERSION,
        "label": "[OPERACIONAL]",
        "design": {
            "generator_config": dict(cfg),
            "frozen_params": dict(FROZEN_PARAMS),
            "t_obs_rule_plant": "t_switch + phi_phenom (phi = window_size = 13)",
            "t_obs_rule_null": "T // 2",
            "note": "Lab instrument test; not field epidemiology",
        },
        "series": series,
    }

    manifest = {
        "schema": "systemic-tau-formal/p1-syn-manifest/v1",
        "protocol": PROTOCOL_ID,
        "protocol_version": PROTOCOL_VERSION,
        "n_series": len(series),
        "matrices": matrix_meta,
        "generated_at_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    }

    if write:
        write_json(paths["endpoints"], endpoints)
        write_json(paths["manifest"], manifest)

    return {
        "paths": paths,
        "sites": sites,
        "endpoints": endpoints,
        "manifest": manifest,
    }


def load_suite_sites(root: Optional[Path] = None) -> Dict[str, np.ndarray]:
    paths = default_syn_paths(root)
    mat_dir = paths["matrices"]
    if not mat_dir.is_dir():
        return {}
    sites: Dict[str, np.ndarray] = {}
    for p in sorted(mat_dir.glob("*.csv")):
        sites[p.stem] = load_matrix_csv(p)
    return sites


def make_protocol_lock(
    endpoints: dict,
    *,
    root: Optional[Path] = None,
    extra: Optional[dict] = None,
) -> dict:
    commit = git_commit(root)
    lock = {
        "schema": SCHEMA_LOCK,
        "protocol": PROTOCOL_ID,
        "protocol_version": PROTOCOL_VERSION,
        "frozen_params": dict(FROZEN_PARAMS),
        "generator_config": dict(GENERATOR_CONFIG),
        "gates": dict(GATES),
        "c1_gates": dict(C1_GATES),
        "endpoints_sha256": sha256_obj(endpoints),
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
    if lock.get("generator_config") != GENERATOR_CONFIG:
        return False, "generator_config drift vs GENERATOR_CONFIG"
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
            "schema": SCHEMA_SCORE,
            "scored": False,
            "protocol": PROTOCOL_ID,
            "protocol_version": PROTOCOL_VERSION,
            "reason": reason,
            "rows": [],
        }
    root = Path(root) if root is not None else _repo_root()
    if sites is None:
        sites = load_suite_sites(root)
        if not sites:
            gen = generate_suite(root=root, write=False)
            sites = gen["sites"]
        source = "disk_or_regen"
    else:
        source = "provided"

    w = int(FROZEN_PARAMS["window_size"])
    lead_lo = int(FROZEN_PARAMS["lead_lo"])
    lead_hi = int(FROZEN_PARAMS["lead_hi"])
    rows: List[dict] = []

    for entry in endpoints.get("series", []):
        fname = entry.get("file") or entry.get("path")
        stem = Path(str(fname)).stem if fname else None
        t_obs = entry.get("t_obs")
        panel = entry.get("panel")
        row: Dict[str, Any] = {
            "file": fname,
            "series_key": entry.get("series_key") or stem,
            "panel": panel,
            "seed": entry.get("seed"),
            "t_switch": entry.get("t_switch"),
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

        X = sites[stem]
        scored = score_p1_for_series(
            X,
            int(t_obs),
            window_size=w,
            lead_lo=lead_lo,
            lead_hi=lead_hi,
        )
        row.update(scored)
        t_star = scored.get("t_star")
        t_sw = entry.get("t_switch")
        if t_star is not None and t_sw is not None:
            row["detection_lag"] = int(t_star) - int(t_sw)
        else:
            row["detection_lag"] = None

        if not scored.get("scored"):
            row["verdict"] = "not_scored"
        elif scored.get("t_star") is None:
            row["verdict"] = "no_signal"
        elif scored.get("pass"):
            row["verdict"] = "hit"
        else:
            row["verdict"] = "miss_lead"
        rows.append(row)

    by_panel: Dict[str, List[dict]] = {}
    for r in rows:
        by_panel.setdefault(str(r.get("panel")), []).append(r)

    def _panel_stats(panel_rows: Sequence[dict]) -> dict:
        scored_rows = [r for r in panel_rows if r.get("scored")]
        n_scored = len(scored_rows)
        n_hit = sum(1 for r in scored_rows if r.get("verdict") == "hit")
        n_ns = sum(1 for r in scored_rows if r.get("verdict") == "no_signal")
        n_miss = sum(1 for r in scored_rows if r.get("verdict") == "miss_lead")
        leads = [r["lead"] for r in scored_rows if r.get("lead") is not None]
        lags = [r["detection_lag"] for r in scored_rows if r.get("detection_lag") is not None]
        return {
            "n_scored": n_scored,
            "n_hit": n_hit,
            "n_no_signal": n_ns,
            "n_miss_lead": n_miss,
            "hit_rate": (n_hit / n_scored) if n_scored else None,
            "no_signal_rate": (n_ns / n_scored) if n_scored else None,
            "lead_median": float(np.median(leads)) if leads else None,
            "lag_median": float(np.median(lags)) if lags else None,
            "lag_min": int(min(lags)) if lags else None,
            "lag_max": int(max(lags)) if lags else None,
        }

    panel_summary = {p: _panel_stats(rs) for p, rs in sorted(by_panel.items())}

    return {
        "schema": SCHEMA_SCORE,
        "scored": True,
        "protocol": PROTOCOL_ID,
        "protocol_version": PROTOCOL_VERSION,
        "label": "[OPERACIONAL]",
        "source": source,
        "endpoints_sha256": lock.get("endpoints_sha256"),
        "git_commit": lock.get("git_commit"),
        "frozen_params": dict(FROZEN_PARAMS),
        "generator_config": dict(GENERATOR_CONFIG),
        "n_scored": sum(1 for r in rows if r.get("scored")),
        "panel_summary": panel_summary,
        "rows": rows,
        "honesty": (
            "P1-Synthetic Canonical v1.0.0: lab plant + nulls only. "
            "Does not discharge empirical P1 (Aedes/ILI/EEG)."
        ),
    }


def score_c1_series(
    X: np.ndarray,
    *,
    t_obs: Optional[int] = None,
    has_critical_event: bool = False,
    window_size: Optional[int] = None,
    min_run: Optional[int] = None,
    horizon: Optional[int] = None,
) -> Dict[str, Any]:
    """
    C1 probe on one series (challenge: false early warnings).

    *alert* if first sustained chaos-band run exists.
    *false_positive* if alert and no critical event in (t*, t* + horizon].

    For plant panels set has_critical_event=True and t_obs=planted endpoint.
    For pure_sync / pure_noise set has_critical_event=False (no transition).
    """
    w = int(window_size if window_size is not None else FROZEN_PARAMS["window_size"])
    mr = int(min_run if min_run is not None else FROZEN_PARAMS["min_run"])
    H = int(horizon if horizon is not None else FROZEN_PARAMS["c1_horizon"])
    X = np.asarray(X, dtype=float)
    tg, _ = compute_taus(X, window_size=w)
    _, _, _, depth = accumulate_time(tg, window_size=w)
    t_star = first_sustained_chaos_ascent(tg, depth, min_run=mr)
    if t_star is None:
        return {
            "alert": False,
            "false_positive": False,
            "t_star": None,
            "t_obs": t_obs,
            "horizon": H,
            "event_in_horizon": False,
            "reason": "no_chaos_run",
        }
    event_in_horizon = False
    if has_critical_event and t_obs is not None:
        # justified iff event strictly after alert and within horizon (EWS story)
        event_in_horizon = int(t_star) < int(t_obs) <= int(t_star) + H
    fp = not event_in_horizon
    return {
        "alert": True,
        "false_positive": bool(fp),
        "t_star": int(t_star),
        "t_obs": int(t_obs) if t_obs is not None else None,
        "horizon": H,
        "event_in_horizon": bool(event_in_horizon),
        "reason": "justified_alert" if event_in_horizon else "alert_without_event_in_horizon",
    }


def score_c1_panel(
    endpoints: dict,
    sites: Dict[str, np.ndarray],
    *,
    horizon: Optional[int] = None,
) -> dict:
    """
    Series-level C1 panel on the canonical suite.

    plant  → has_critical_event=True (planted t_obs)
    pure_* → has_critical_event=False (no transition by construction)
    """
    H = int(horizon if horizon is not None else FROZEN_PARAMS["c1_horizon"])
    rows: List[dict] = []
    for entry in endpoints.get("series", []):
        fname = entry.get("file") or entry.get("path")
        stem = Path(str(fname)).stem if fname else None
        panel = str(entry.get("panel") or "")
        row: Dict[str, Any] = {
            "file": fname,
            "series_key": entry.get("series_key") or stem,
            "panel": panel,
            "seed": entry.get("seed"),
            "scored": False,
        }
        if stem is None or stem not in sites:
            row["reason"] = f"series stem {stem!r} not loaded"
            rows.append(row)
            continue
        has_event = panel == "plant"
        t_obs = entry.get("t_obs") if has_event else None
        probe = score_c1_series(
            sites[stem],
            t_obs=int(t_obs) if t_obs is not None else None,
            has_critical_event=has_event,
            horizon=H,
        )
        row.update(probe)
        row["scored"] = True
        rows.append(row)

    def _stats(panel_name: str) -> dict:
        pr = [r for r in rows if r.get("panel") == panel_name and r.get("scored")]
        n = len(pr)
        n_alert = sum(1 for r in pr if r.get("alert"))
        n_fp = sum(1 for r in pr if r.get("false_positive"))
        return {
            "n": n,
            "n_alert": n_alert,
            "n_fp": n_fp,
            "alert_rate": (n_alert / n) if n else None,
            "fp_rate": (n_fp / n) if n else None,
            # among alerts only
            "fp_rate_given_alert": (n_fp / n_alert) if n_alert else None,
        }

    panel_summary = {
        name: _stats(name) for name in ("plant", "pure_sync", "pure_noise")
    }
    return {
        "schema": "systemic-tau-formal/p1-syn-c1/v1",
        "protocol": PROTOCOL_ID,
        "protocol_version": PROTOCOL_VERSION,
        "track": "C1_false_early_warnings",
        "label": "[OPERACIONAL]",
        "horizon": H,
        "frozen_params": dict(FROZEN_PARAMS),
        "panel_summary": panel_summary,
        "rows": rows,
        "honesty": (
            "C1 companion: alert = first_sustained_chaos_ascent; "
            "FP = alert without critical event in (t*, t*+H]. "
            "pure_noise ambient chaos is the classic C1 stress for chaos polarity. "
            "Not field C1; not P1 discharge."
        ),
    }


def evaluate_c1_gates(c1: dict) -> dict:
    """C1A/B/C gates — separate verdict from P1 G1–G4."""
    ps = c1.get("panel_summary") or {}
    plant = ps.get("plant") or {}
    sync = ps.get("pure_sync") or {}
    noise = ps.get("pure_noise") or {}

    plant_fp = plant.get("fp_rate")
    c1a = {
        "id": "C1A",
        "name": "plant_justified_alerts",
        "pass": (
            plant.get("n", 0) > 0
            and plant_fp is not None
            and float(plant_fp) <= float(C1_GATES["C1A_plant_max_fp_rate"])
        ),
        "detail": {
            "fp_rate": plant_fp,
            "alert_rate": plant.get("alert_rate"),
            "n": plant.get("n"),
            "threshold": C1_GATES["C1A_plant_max_fp_rate"],
        },
    }

    sync_ar = sync.get("alert_rate")
    c1b = {
        "id": "C1B",
        "name": "pure_sync_no_alert",
        "pass": (
            sync.get("n", 0) > 0
            and sync_ar is not None
            and float(sync_ar) <= float(C1_GATES["C1B_sync_max_alert_rate"])
        ),
        "detail": {
            "alert_rate": sync_ar,
            "fp_rate": sync.get("fp_rate"),
            "n": sync.get("n"),
            "threshold": C1_GATES["C1B_sync_max_alert_rate"],
        },
    }

    noise_fp = noise.get("fp_rate")
    c1c_pass = (
        noise.get("n", 0) > 0
        and noise_fp is not None
        and float(noise_fp) <= float(C1_GATES["C1C_noise_max_fp_rate"])
    )
    c1c = {
        "id": "C1C",
        "name": "pure_noise_ambient_chaos",
        "pass": bool(c1c_pass),
        "detail": {
            "fp_rate": noise_fp,
            "alert_rate": noise.get("alert_rate"),
            "n": noise.get("n"),
            "threshold": C1_GATES["C1C_noise_max_fp_rate"],
            "note": (
                "Chaos-band t* on IID noise is ambient ordinal chaos — "
                "expected hard for this polarity (EEG v1.0 C1 FP≈1.0)."
            ),
        },
    }

    gates = {"C1A": c1a, "C1B": c1b, "C1C": c1c}
    required = ["C1A", "C1B"]
    if C1_GATES.get("C1C_required_for_c1_pass"):
        required.append("C1C")
    all_pass = all(gates[g]["pass"] for g in required)
    return {
        "schema": "systemic-tau-formal/p1-syn-c1-gates/v1",
        "protocol": PROTOCOL_ID,
        "protocol_version": PROTOCOL_VERSION,
        "c1_pass": all_pass,
        "verdict": "C1_PASS" if all_pass else "C1_STRESS_FAIL",
        "gates": gates,
        "required_for_pass": required,
        "honesty": (
            "C1_PASS requires justified plant alerts, silent pure_sync, and "
            "low ambient FP on pure_noise. Chaos polarity often fails C1C."
        ),
    }


def evaluate_gates(score: dict) -> dict:
    """Apply a priori G1–G4 from protocol freeze."""
    if not score.get("scored"):
        return {
            "protocol": PROTOCOL_ID,
            "protocol_version": PROTOCOL_VERSION,
            "gates_pass": False,
            "reason": score.get("reason", "score not available"),
            "gates": {},
        }

    ps = score.get("panel_summary") or {}
    plant = ps.get("plant") or {}
    sync = ps.get("pure_sync") or {}
    noise = ps.get("pure_noise") or {}
    plant_rows = [r for r in score.get("rows", []) if r.get("panel") == "plant" and r.get("scored")]

    # G1: detection lag in [0, w] for every plant series with t*
    lag_ok = True
    lag_failures: List[dict] = []
    for r in plant_rows:
        lag = r.get("detection_lag")
        if lag is None:
            lag_ok = False
            lag_failures.append({"series": r.get("series_key"), "reason": "no t* / lag"})
            continue
        if not (GATES["G1_lag_lo"] <= int(lag) <= GATES["G1_lag_hi"]):
            lag_ok = False
            lag_failures.append(
                {
                    "series": r.get("series_key"),
                    "lag": lag,
                    "reason": "lag outside [0, w]",
                }
            )

    g1 = {
        "id": "G1",
        "name": "detection_lag_in_window",
        "pass": bool(lag_ok and plant_rows),
        "detail": {
            "lag_median": plant.get("lag_median"),
            "lag_min": plant.get("lag_min"),
            "lag_max": plant.get("lag_max"),
            "failures": lag_failures,
        },
    }

    hr = plant.get("hit_rate")
    g2 = {
        "id": "G2",
        "name": "plant_hit_rate",
        "pass": hr is not None and float(hr) >= float(GATES["G2_min_hit_rate"]),
        "detail": {
            "hit_rate": hr,
            "n_hit": plant.get("n_hit"),
            "n_scored": plant.get("n_scored"),
            "threshold": GATES["G2_min_hit_rate"],
            "lead_median": plant.get("lead_median"),
        },
    }

    sync_hr = sync.get("hit_rate")
    sync_ns = sync.get("no_signal_rate")
    g3_pass = (
        sync.get("n_scored", 0) > 0
        and (sync_hr is not None and float(sync_hr) <= float(GATES["G3_max_hit_rate"]))
        and (
            not GATES["G3_require_all_no_signal"]
            or (sync_ns is not None and float(sync_ns) >= 1.0 - 1e-12)
        )
    )
    g3 = {
        "id": "G3",
        "name": "pure_sync_null",
        "pass": bool(g3_pass),
        "detail": {
            "hit_rate": sync_hr,
            "no_signal_rate": sync_ns,
            "n_scored": sync.get("n_scored"),
        },
    }

    noise_hr = noise.get("hit_rate")
    g4 = {
        "id": "G4",
        "name": "pure_noise_false_ews",
        "pass": (
            noise.get("n_scored", 0) > 0
            and noise_hr is not None
            and float(noise_hr) <= float(GATES["G4_max_hit_rate"])
        ),
        "detail": {
            "hit_rate": noise_hr,
            "n_hit": noise.get("n_hit"),
            "n_scored": noise.get("n_scored"),
            "threshold": GATES["G4_max_hit_rate"],
        },
    }

    gates = {"G1": g1, "G2": g2, "G3": g3, "G4": g4}
    all_pass = all(g["pass"] for g in gates.values())
    return {
        "schema": "systemic-tau-formal/p1-syn-gates/v1",
        "protocol": PROTOCOL_ID,
        "protocol_version": PROTOCOL_VERSION,
        "gates_pass": all_pass,
        "verdict": "INSTRUMENT_PASS" if all_pass else "INSTRUMENT_FAIL",
        "gates": gates,
        "honesty": (
            "Instrument PASS does not discharge empirical P1. "
            "Instrument FAIL means rethink t*/lead/window before more field domains."
        ),
    }


def run_full_pipeline(
    *,
    root: Optional[Path] = None,
    write: bool = True,
) -> Dict[str, Any]:
    """Generate → lock → P1 score → G1–G4 → C1 panel → C1 gates."""
    root = Path(root) if root is not None else _repo_root()
    gen = generate_suite(root=root, write=write)
    endpoints = gen["endpoints"]
    lock = make_protocol_lock(endpoints, root=root)
    score = score_locked_endpoints(
        endpoints, lock, root=root, sites=gen["sites"]
    )
    gates = evaluate_gates(score)
    c1 = score_c1_panel(endpoints, gen["sites"])
    c1_gates = evaluate_c1_gates(c1)
    # Nest C1 gate results into c1 artifact for a single write
    c1_out = {**c1, "gates": c1_gates}
    if write:
        paths = default_syn_paths(root)
        write_json(paths["lock"], lock)
        write_json(paths["score"], score)
        write_json(paths["gates"], gates)
        write_json(paths["c1"], c1_out)
    return {
        "endpoints": endpoints,
        "lock": lock,
        "score": score,
        "gates": gates,
        "c1": c1_out,
        "c1_gates": c1_gates,
        "paths": default_syn_paths(root),
    }


def format_report(
    score: dict,
    gates: dict,
    c1: Optional[dict] = None,
    c1_gates: Optional[dict] = None,
) -> str:
    lines = [
        f"=== {PROTOCOL_ID} v{PROTOCOL_VERSION} ===",
        f"Label: [OPERACIONAL]  scored={score.get('scored')}",
    ]
    if not score.get("scored"):
        lines.append(f"Reason: {score.get('reason')}")
        return "\n".join(lines)

    ps = score.get("panel_summary") or {}
    lines.append("--- P1 lead score ---")
    for name in ("plant", "pure_sync", "pure_noise"):
        s = ps.get(name) or {}
        lines.append(
            f"  {name}: n={s.get('n_scored')} hit={s.get('n_hit')} "
            f"no_signal={s.get('n_no_signal')} miss={s.get('n_miss_lead')} "
            f"hit_rate={s.get('hit_rate')} lag_med={s.get('lag_median')} "
            f"lead_med={s.get('lead_median')}"
        )
    lines.append(f"P1 gates: {gates.get('verdict')} (all_pass={gates.get('gates_pass')})")
    for gid, g in (gates.get("gates") or {}).items():
        lines.append(
            f"  {gid} {g.get('name')}: {'PASS' if g.get('pass') else 'FAIL'} {g.get('detail')}"
        )

    if c1 is not None:
        lines.append("--- C1 false early warnings ---")
        cps = c1.get("panel_summary") or {}
        for name in ("plant", "pure_sync", "pure_noise"):
            s = cps.get(name) or {}
            lines.append(
                f"  {name}: n={s.get('n')} alert={s.get('n_alert')} fp={s.get('n_fp')} "
                f"alert_rate={s.get('alert_rate')} fp_rate={s.get('fp_rate')}"
            )
        cg = c1_gates or c1.get("gates") or {}
        lines.append(f"C1 gates: {cg.get('verdict')} (c1_pass={cg.get('c1_pass')})")
        for gid, g in (cg.get("gates") or {}).items():
            lines.append(
                f"  {gid} {g.get('name')}: {'PASS' if g.get('pass') else 'FAIL'} {g.get('detail')}"
            )
        lines.append(c1.get("honesty", ""))

    lines.append(score.get("honesty", ""))
    return "\n".join(lines)


def probe_series_tau(X: np.ndarray, *, window_size: int = 13) -> Dict[str, Any]:
    """Diagnostic: t* and lag helpers (not a scored claim)."""
    tg, _ = compute_taus(X, window_size=window_size)
    _, _, _, depth = accumulate_time(tg, window_size=window_size)
    t_star = first_sustained_chaos_ascent(tg, depth)
    return {
        "t_star": t_star,
        "n_finite_tau": int(np.sum(np.isfinite(tg))),
        "frac_chaos_band": float(
            np.mean(np.abs(tg[np.isfinite(tg)]) < FROZEN_PARAMS["theta_chaos"])
        )
        if np.any(np.isfinite(tg))
        else None,
    }
