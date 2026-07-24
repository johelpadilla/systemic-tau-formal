"""Optional P1 scoring when pre-registered endpoints exist (no invented dates)."""

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
