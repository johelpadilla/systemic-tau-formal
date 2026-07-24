"""
Unified empirical board for Aedes field series (P1 / P3 / P4 status).

Does not invent endpoints or claim anti-regime discharge. Aggregates operational
metrics already implemented in p1_endpoints / regimes / p4_sync.
"""

from __future__ import annotations

from pathlib import Path
from typing import Any, Dict, List, Optional

import numpy as np

from .aedes_io import AedesLoadResult, load_aedes_sites
from .field_return import multi_site_field_return
from .p1_endpoints import exploratory_lead_scan, load_endpoints, score_endpoints_file
from .p4_sync import p4_series_report
from .regimes import p3_noise_scan, regime_fracs
from .tau import compute_taus


def _p1_board_status(
    root: Path,
    sites: Dict[str, np.ndarray],
    *,
    window_size: int,
) -> Dict[str, Any]:
    ep_path = root / "data" / "aedes" / "raw" / "endpoints.json"
    example = root / "data" / "aedes" / "raw" / "endpoints.example.json"
    if not ep_path.is_file():
        return {
            "status": "scaffold_only",
            "scored": False,
            "path": str(ep_path),
            "example": str(example) if example.is_file() else None,
            "note": (
                "No endpoints.json — P1 not scored. Copy endpoints.example.json, "
                "set t_obs + pre_registered:true for each series."
            ),
            "rows": [],
        }
    endpoints = load_endpoints(ep_path)
    if endpoints is None:
        return {
            "status": "unreadable",
            "scored": False,
            "path": str(ep_path),
            "rows": [],
            "note": "endpoints.json present but unreadable",
        }
    rows = score_endpoints_file(endpoints, sites, window_size=window_size)
    any_scored = any(r.get("scored") for r in rows)
    any_pass = any(r.get("pass") for r in rows if r.get("scored"))
    if not any_scored:
        status = "present_not_scored"
    elif any_pass:
        status = "scored_some_pass"
    else:
        status = "scored_no_pass"
    return {
        "status": status,
        "scored": any_scored,
        "path": str(ep_path),
        "pre_registered_claim": bool(endpoints.get("pre_registered", False)),
        "rows": rows,
        "note": "P1 only with non-null t_obs and pre_registered true per series.",
    }


def _series_board_row(
    name: str,
    X: np.ndarray,
    *,
    window_size: int,
    p3_seed: int,
    p4_seed: int,
) -> Dict[str, Any]:
    X = np.asarray(X, dtype=float)
    T, N = X.shape
    tg, _ = compute_taus(X, window_size=window_size)
    fr = regime_fracs(tg)
    # P3: only ρ=0 and ρ=0.20 for board speed
    p3_rows = p3_noise_scan(
        X, rhos=(0.0, 0.20), window_size=window_size, seed=p3_seed
    )
    p3_20 = next(r for r in p3_rows if r["rho"] == 0.20)
    p4 = p4_series_report(X, name=name, window_size=window_size, seed=p4_seed)
    m = p4["metrics"]
    return {
        "name": name,
        "shape": [int(T), int(N)],
        "mean_tau": fr["mean_tau"],
        "frac_stable": fr["stable"],
        "frac_chaos": fr["chaos"],
        "frac_anti": fr["anti"],
        "p3": {
            "rho": 0.20,
            "agree_vs_rho0": p3_20["agree_vs_rho0"],
            "frac_chaos_at_rho": p3_20["frac_chaos"],
            "status": "ok" if p3_20["agree_vs_rho0"] >= 0.45 else "watch",
        },
        "p4": {
            "mean_pair_corr": m["mean_pair_corr"],
            "frac_strong_anti": m["frac_strong_anti"],
            "nearest_baseline": p4["nearest_baseline"],
            "p4_status": p4["p4_status"],
            "premise_anti": p4["premise_anti"],
        },
    }


def build_empirical_board(
    *,
    root: Optional[Path] = None,
    window_size: int = 13,
    p3_seed: int = 42,
    p4_seed: int = 0,
    min_T: int = 20,
    min_N: int = 2,
) -> Dict[str, Any]:
    """
    One JSON-serializable board: load status + per-series P3/P4 + global P1.

    Field series → EMPÍRICO provenance; protocol noise / baselines → OPERACIONAL.
    """
    root = Path(root) if root is not None else Path(__file__).resolve().parents[2]
    loaded: AedesLoadResult = load_aedes_sites(root=root, prefer_raw=True)
    series_rows: List[Dict[str, Any]] = []
    skipped: List[Dict[str, str]] = []
    if loaded.source == "raw":
        for name, X in loaded.sites.items():
            X = np.asarray(X, dtype=float)
            if X.ndim != 2 or X.shape[0] < min_T or X.shape[1] < min_N:
                skipped.append(
                    {
                        "name": name,
                        "reason": f"shape {X.shape} below min_T={min_T} min_N={min_N}",
                    }
                )
                continue
            series_rows.append(
                _series_board_row(
                    name,
                    X,
                    window_size=window_size,
                    p3_seed=p3_seed,
                    p4_seed=p4_seed,
                )
            )
    p1 = _p1_board_status(root, loaded.sites, window_size=window_size)

    # Critical-path diagnostics (never invent pre-registered P1)
    if loaded.source == "raw" and loaded.sites:
        field_ret = multi_site_field_return(
            loaded.sites, window_size=window_size
        )
        p1_expl = exploratory_lead_scan(loaded.sites, window_size=window_size)
    else:
        field_ret = {
            "schema": "systemic-tau-formal/field-return/v1",
            "n_sites": 0,
            "headline": "no raw sites",
            "sites": [],
        }
        p1_expl = {
            "status": "no_raw",
            "p1_discharge": False,
            "rows": [],
            "note": "exploratory lead scan needs EMPÍRICO raw matrices",
        }

    n = len(series_rows)
    p3_ok = sum(1 for r in series_rows if r["p3"]["status"] == "ok")
    p4_anti = sum(1 for r in series_rows if r["p4"]["premise_anti"])
    fr_pairs = int(field_ret.get("n_with_run_pairs") or 0)
    summary = {
        "n_series": n,
        "n_skipped": len(skipped),
        "p1_status": p1["status"],
        "p1_exploratory_status": p1_expl.get("status"),
        "p1_discharge": False,  # never auto-claim from exploratory
        "field_return_sites_with_pairs": fr_pairs,
        "p3_ok_at_rho020": p3_ok,
        "p3_all_ok": n > 0 and p3_ok == n,
        "p4_with_anti_premise": p4_anti,
        "p4_field_discharge": False,  # never auto-claim
        "headline": _headline(loaded, p1, p1_expl, field_ret, n, p3_ok, p4_anti),
    }
    return {
        "schema": "systemic-tau-formal/empirical-board/v2",
        "label_series": loaded.label,
        "source": loaded.source,
        "window_size": window_size,
        "summary": summary,
        "p1": p1,
        "p1_exploratory": p1_expl,
        "field_return": field_ret,
        "series": series_rows,
        "skipped": skipped,
        "honesty": (
            "P1 discharge requires pre-registered t_obs in endpoints.json. "
            "p1_exploratory uses trap-surge endpoints from the same matrix "
            "(not outbreak dates; not pre-registered). "
            "field_return is observational Poincaré on τₛ / chaos runs — not "
            "lab logistic unimodality. P3 noise is OPERACIONAL on EMPÍRICO series. "
            "P4 field discharge requires strong-anti premise (τₛ ≤ −0.41 mass); "
            "2018 SJU multi-trap matrices are co-moving → no_strong_anti_regime is expected."
        ),
    }


def _headline(
    loaded: AedesLoadResult,
    p1: dict,
    p1_expl: dict,
    field_ret: dict,
    n: int,
    p3_ok: int,
    p4_anti: int,
) -> str:
    if loaded.source != "raw":
        return "No field raw series — board is empty of EMPÍRICO rows."
    fr_pairs = field_ret.get("n_with_run_pairs", 0)
    expl_n = p1_expl.get("n_scored", 0)
    parts = [
        f"{n} field series",
        f"P1={p1['status']}",
        f"P1-expl scored={expl_n}",
        f"field-return pairs@sites={fr_pairs}",
        f"P3@0.20 ok={p3_ok}/{n}",
        f"P4 anti-premise={p4_anti}/{n}",
    ]
    return " · ".join(parts)
