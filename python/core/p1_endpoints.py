"""Optional P1 scoring when pre-registered endpoints exist (no invented dates).

Also: *exploratory* trap-surge endpoint proposals for multi-site lead-time
characterization — always ``pre_registered=false`` and never counted as P1 discharge.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict, List, Optional

import numpy as np

from .constants import THETA_CHAOS
from .recd import accumulate_time
from .tau import compute_taus


def load_endpoints(path: Path) -> Optional[dict]:
    if not path.is_file():
        return None
    return json.loads(path.read_text(encoding="utf-8"))


def first_sustained_chaos_ascent(
    tg: np.ndarray,
    depth: np.ndarray,
    *,
    min_run: int = 4,
    theta: float = THETA_CHAOS,
) -> Optional[int]:
    """
    Operational proxy for t*: first index where a chaos-band run of length
    ≥ min_run begins and RECD depth will grow — **not** the published P1 claim
    without a domain endpoint.
    """
    below = (np.abs(tg) < theta) & np.isfinite(tg)
    i = 0
    n = len(below)
    while i < n:
        if below[i]:
            j = i
            while j < n and below[j]:
                j += 1
            if j - i >= min_run:
                return int(i)
            i = j
        else:
            i += 1
    return None


def first_sustained_order_ascent(
    tg: np.ndarray,
    depth: np.ndarray,
    *,
    min_run: int = 4,
    theta_stable: float = 0.50,
) -> Optional[int]:
    """
    P1-EEG v1.1 polarity: first index where an *order-band* run of length
    ≥ min_run begins (|τ| ≥ θ_stable). Hypersync / ordered co-movement proxy.

    ``depth`` is accepted for API symmetry with chaos ascent; unused.
    """
    _ = depth  # API symmetry with first_sustained_chaos_ascent
    order = (np.abs(tg) >= float(theta_stable)) & np.isfinite(tg)
    i = 0
    n = len(order)
    while i < n:
        if order[i]:
            j = i
            while j < n and order[j]:
                j += 1
            if j - i >= min_run:
                return int(i)
            i = j
        else:
            i += 1
    return None


def score_p1_for_series(
    X: np.ndarray,
    t_obs: int,
    *,
    window_size: int = 13,
    lead_lo: int = 4,
    lead_hi: int = 6,
) -> Dict[str, Any]:
    """
    Score P1 given a pre-registered observable index t_obs.

    lead = t_obs - t_star (weeks/rows). Pass if lead in [lead_lo, lead_hi].
    """
    X = np.asarray(X, dtype=float)
    tg, _ = compute_taus(X, window_size=window_size)
    _, _, _, depth = accumulate_time(tg, window_size=window_size)
    t_star = first_sustained_chaos_ascent(tg, depth)
    if t_star is None:
        return {
            "scored": True,
            "pass": False,
            "reason": "no sustained chaos-band run found for t*",
            "t_obs": int(t_obs),
            "t_star": None,
            "lead": None,
        }
    lead = int(t_obs) - int(t_star)
    ok = lead_lo <= lead <= lead_hi
    return {
        "scored": True,
        "pass": ok,
        "t_obs": int(t_obs),
        "t_star": int(t_star),
        "lead": lead,
        "lead_window": [lead_lo, lead_hi],
        "reason": "lead in window" if ok else "lead outside 4–6 (or chosen window)",
    }


def score_endpoints_file(
    endpoints: dict,
    sites: Dict[str, np.ndarray],
    *,
    window_size: int = 13,
) -> List[dict]:
    """Score each series entry that has a non-null t_obs and matching file stem."""
    out: List[dict] = []
    for entry in endpoints.get("series", []):
        fname = entry.get("file") or entry.get("path")
        t_obs = entry.get("t_obs")
        stem = Path(str(fname)).stem if fname else None
        row: dict = {
            "file": fname,
            "pre_registered": bool(entry.get("pre_registered", False)),
            "scored": False,
        }
        if t_obs is None:
            row["reason"] = "t_obs is null — P1 not scored (fill endpoints.json)"
            out.append(row)
            continue
        if stem not in sites:
            row["reason"] = f"series stem {stem!r} not loaded"
            out.append(row)
            continue
        if not entry.get("pre_registered", False):
            row["reason"] = "pre_registered is false — refuse to score (honesty)"
            out.append(row)
            continue
        scored = score_p1_for_series(sites[stem], int(t_obs), window_size=window_size)
        row.update(scored)
        out.append(row)
    return out


def trap_surge_t_obs(
    X: np.ndarray,
    *,
    method: str = "max_total",
) -> Dict[str, Any]:
    """
    Domain-style *observational* endpoint from the trap matrix itself.

    Methods
    -------
    max_total
        Row index of maximum total catch (sum over traps).
    first_q90
        First row whose total catch reaches the 90th percentile of row totals
        (falls back to max_total if none).

    Always exploratory: not a clinical outbreak date and not pre-registered.
    """
    X = np.asarray(X, dtype=float)
    if X.ndim != 2 or X.shape[0] < 2:
        return {"t_obs": None, "method": method, "reason": "invalid_matrix"}
    totals = np.nansum(X, axis=1)
    if method == "max_total":
        t = int(np.nanargmax(totals))
        return {
            "t_obs": t,
            "method": method,
            "total_at_t": float(totals[t]),
            "reason": "ok",
        }
    if method == "first_q90":
        thr = float(np.nanpercentile(totals, 90))
        hits = np.where(totals >= thr)[0]
        if len(hits) == 0:
            t = int(np.nanargmax(totals))
            return {
                "t_obs": t,
                "method": method,
                "threshold": thr,
                "total_at_t": float(totals[t]),
                "reason": "fallback_max_total",
            }
        t = int(hits[0])
        return {
            "t_obs": t,
            "method": method,
            "threshold": thr,
            "total_at_t": float(totals[t]),
            "reason": "ok",
        }
    return {"t_obs": None, "method": method, "reason": f"unknown method {method!r}"}


def exploratory_lead_scan(
    sites: Dict[str, np.ndarray],
    *,
    window_size: int = 13,
    methods: Optional[List[str]] = None,
    lead_lo: int = 4,
    lead_hi: int = 6,
) -> Dict[str, Any]:
    """
    Multi-site lead-time scan using trap-surge endpoints.

    **Honesty:** ``status=exploratory_not_pre_registered``. Never sets
    ``pre_registered=true``. Does not claim P1 pass/fail for the paradigm;
    only reports empirical lead distributions under explicit matrix-derived
    endpoints.
    """
    methods = methods or ["max_total", "first_q90"]
    rows: List[dict] = []
    for name in sorted(sites.keys()):
        X = np.asarray(sites[name], dtype=float)
        for method in methods:
            prop = trap_surge_t_obs(X, method=method)
            t_obs = prop.get("t_obs")
            row: dict = {
                "series": name,
                "endpoint_method": method,
                "endpoint": prop,
                "pre_registered": False,
                "p1_discharge": False,
            }
            if t_obs is None:
                row["scored"] = False
                row["reason"] = prop.get("reason", "no t_obs")
                rows.append(row)
                continue
            scored = score_p1_for_series(
                X,
                int(t_obs),
                window_size=window_size,
                lead_lo=lead_lo,
                lead_hi=lead_hi,
            )
            row.update(scored)
            row["in_protocol_window"] = bool(scored.get("pass"))
            # rename so nobody confuses with pre-registered P1
            row["pass_protocol_window"] = row.pop("pass", False)
            rows.append(row)
    leads = [r["lead"] for r in rows if r.get("lead") is not None]
    in_win = sum(1 for r in rows if r.get("pass_protocol_window"))
    return {
        "status": "exploratory_not_pre_registered",
        "p1_discharge": False,
        "n_scored": sum(1 for r in rows if r.get("scored")),
        "n_in_protocol_window_4_6": in_win,
        "lead_mean": float(np.mean(leads)) if leads else None,
        "lead_median": float(np.median(leads)) if leads else None,
        "lead_min": int(min(leads)) if leads else None,
        "lead_max": int(max(leads)) if leads else None,
        "rows": rows,
        "note": (
            "Trap-surge t_obs from the same matrix that yields τₛ — useful for "
            "multi-site lead characterization, NOT pre-registered outbreak P1. "
            "Fill endpoints.json with external domain dates + pre_registered:true "
            "for true P1 scoring."
        ),
    }
