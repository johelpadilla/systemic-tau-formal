"""
Field-derived first-return diagnostics from multi-trap matrices.

[EMPÍRICO] when run on ``data/aedes/raw/`` series; the *map construction*
itself is [OPERACIONAL]. Does **not** prove continuum unimodality, C² renorm,
or classical Feigenbaum universality. Complements the lab logistic return
in Lean (`tauReturnFour`) with an observational Poincaré package.
"""

from __future__ import annotations

from typing import Any, Dict, List, Optional, Sequence, Tuple

import numpy as np

from .constants import THETA_CHAOS
from .first_return import (
    first_return_crossing,
    first_return_from_local_maxima,
    return_pairs,
)
from .tau import compute_taus


def chaos_band_runs(
    tau: Sequence[float],
    *,
    theta: float = THETA_CHAOS,
    min_run: int = 4,
) -> List[Tuple[int, int]]:
    """
    Maximal index intervals ``[start, end)`` where ``|τ| < theta`` and
    length ≥ ``min_run``.
    """
    tg = np.asarray(tau, dtype=float)
    below = (np.abs(tg) < theta) & np.isfinite(tg)
    runs: List[Tuple[int, int]] = []
    i = 0
    n = len(below)
    while i < n:
        if below[i]:
            j = i
            while j < n and below[j]:
                j += 1
            if j - i >= min_run:
                runs.append((i, j))
            i = j
        else:
            i += 1
    return runs


def coherence_run_return_pairs(
    runs: Sequence[Tuple[int, int]],
    *,
    soften: float = 5.0,
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Phase-proxy return map from successive chaos-band runs.

    For each run ``k`` with length L and gap G to the next run:
      s_exit = (L-1) / (L + soften)
      s_next = G / (G + soften)

    Same construction as the thesis return-map script (operational phase
    coordinates on run length / inter-run gap — not a Poincaré section of
    a continuous vector field).
    """
    if soften <= 0:
        raise ValueError("soften must be positive")
    exits: List[float] = []
    nexts: List[float] = []
    for idx in range(len(runs) - 1):
        start, end = runs[idx]
        length = end - start
        next_start = runs[idx + 1][0]
        gap = next_start - end
        if length < 1 or gap < 0:
            continue
        s_exit = (length - 1) / (length + soften)
        s_next = gap / (gap + soften)
        exits.append(float(s_exit))
        nexts.append(float(s_next))
    return np.asarray(exits, dtype=float), np.asarray(nexts, dtype=float)


def binned_return_curve(
    x: np.ndarray,
    y: np.ndarray,
    *,
    n_bins: int = 8,
) -> Dict[str, Any]:
    """
    Sort-x bin means of y — exploratory shape diagnostic.

    Returns midpoints, mean y per non-empty bin, and a coarse
    ``single_peak_like`` flag (exactly one interior local max in bin means).
    """
    x = np.asarray(x, dtype=float)
    y = np.asarray(y, dtype=float)
    mask = np.isfinite(x) & np.isfinite(y)
    x, y = x[mask], y[mask]
    if len(x) < 3:
        return {
            "n": int(len(x)),
            "bin_mid": [],
            "bin_mean_y": [],
            "single_peak_like": False,
            "reason": "too_few_points",
        }
    lo, hi = float(np.min(x)), float(np.max(x))
    if hi <= lo:
        return {
            "n": int(len(x)),
            "bin_mid": [],
            "bin_mean_y": [],
            "single_peak_like": False,
            "reason": "degenerate_x_range",
        }
    edges = np.linspace(lo, hi, n_bins + 1)
    mids: List[float] = []
    means: List[float] = []
    for i in range(n_bins):
        if i < n_bins - 1:
            sel = (x >= edges[i]) & (x < edges[i + 1])
        else:
            sel = (x >= edges[i]) & (x <= edges[i + 1])
        if not np.any(sel):
            continue
        mids.append(float(0.5 * (edges[i] + edges[i + 1])))
        means.append(float(np.mean(y[sel])))
    peak_like = _single_peak_like(means)
    return {
        "n": int(len(x)),
        "bin_mid": mids,
        "bin_mean_y": means,
        "single_peak_like": peak_like,
        "reason": "ok" if mids else "empty_bins",
    }


def _single_peak_like(means: Sequence[float]) -> bool:
    """True if the discrete sequence has exactly one strict interior local max."""
    m = list(means)
    if len(m) < 3:
        return False
    peaks = 0
    for i in range(1, len(m) - 1):
        if m[i] > m[i - 1] and m[i] > m[i + 1]:
            peaks += 1
    return peaks == 1


def length_ratio_proxy(
    runs: Sequence[Tuple[int, int]],
    *,
    min_length: int = 4,
    max_ratios: int = 6,
) -> Dict[str, Any]:
    """
    Median length-ratio of sorted chaos-run lengths (exploratory δ proxy).

    **Not** classical Feigenbaum δ from superstable R_n.
    """
    lengths = np.array([e - s for s, e in runs if e - s >= min_length], dtype=float)
    if len(lengths) < 2:
        return {
            "n_lengths": int(len(lengths)),
            "median_ratio": None,
            "ratios": [],
            "note": "need ≥2 runs for ratios",
        }
    lengths = np.sort(lengths)[::-1]
    ratios = (lengths[:-1] / lengths[1:]).tolist()
    take = ratios[: min(max_ratios, len(ratios))]
    return {
        "n_lengths": int(len(lengths)),
        "median_ratio": float(np.median(take)) if take else None,
        "ratios": [float(r) for r in take],
        "note": "run-length hierarchy proxy — not classical Feigenbaum δ",
    }


def field_return_report(
    X: np.ndarray,
    *,
    name: str = "series",
    window_size: int = 13,
    theta: float = THETA_CHAOS,
    min_run: int = 4,
    soften: float = 5.0,
    n_bins: int = 8,
) -> Dict[str, Any]:
    """
    Full field-return package for one multi-trap matrix (T × N).

    Layers
    ------
    1. τₛ global series from Kendall windows
    2. Chaos-band runs + coherence-run return pairs
    3. Local-maxima first-return on τₛ (combinatorial skeleton)
    4. Binned shape diagnostics (exploratory single-peak flag)
    5. Run-length ratio proxy (not classical δ)
    """
    X = np.asarray(X, dtype=float)
    if X.ndim != 2 or X.shape[1] < 2:
        return {
            "name": name,
            "ok": False,
            "reason": f"need 2-D matrix with N≥2, got shape {getattr(X, 'shape', None)}",
        }
    T, N = X.shape
    tg, _ = compute_taus(X, window_size=window_size)
    finite = tg[np.isfinite(tg)]
    runs = chaos_band_runs(tg, theta=theta, min_run=min_run)
    ex, nx = coherence_run_return_pairs(runs, soften=soften)
    run_curve = binned_return_curve(ex, nx, n_bins=n_bins) if len(ex) else {
        "n": 0,
        "bin_mid": [],
        "bin_mean_y": [],
        "single_peak_like": False,
        "reason": "no_run_pairs",
    }
    sec, pairs = first_return_from_local_maxima(tg)
    pair_x = np.array([p[0] for p in pairs], dtype=float) if pairs else np.array([])
    pair_y = np.array([p[1] for p in pairs], dtype=float) if pairs else np.array([])
    loc_curve = binned_return_curve(pair_x, pair_y, n_bins=n_bins) if len(pair_x) else {
        "n": 0,
        "bin_mid": [],
        "bin_mean_y": [],
        "single_peak_like": False,
        "reason": "no_local_max_pairs",
    }
    sec_z, pairs_z = first_return_crossing(tg, level=0.0, direction="up")
    zx = np.array([p[0] for p in pairs_z], dtype=float) if pairs_z else np.array([])
    zy = np.array([p[1] for p in pairs_z], dtype=float) if pairs_z else np.array([])
    z_curve = binned_return_curve(zx, zy, n_bins=n_bins) if len(zx) else {
        "n": 0,
        "bin_mid": [],
        "bin_mean_y": [],
        "single_peak_like": False,
        "reason": "no_zero_cross_pairs",
    }
    ratios = length_ratio_proxy(runs, min_length=min_run)
    run_lengths = [e - s for s, e in runs]
    # Prefer local-max when a single long chaos band yields no run-pairs (common on short T)
    primary = "local_max" if len(pairs) > 0 else (
        "coherence_run" if len(ex) > 0 else "none"
    )
    return {
        "name": name,
        "ok": True,
        "label": "[EMPÍRICO · field return diagnostic]",
        "shape": [int(T), int(N)],
        "window_size": int(window_size),
        "theta": float(theta),
        "min_run": int(min_run),
        "primary_section": primary,
        "tau": {
            "n_finite": int(len(finite)),
            "mean": float(np.mean(finite)) if len(finite) else None,
            "frac_chaos_band": float(np.mean(np.abs(finite) < theta)) if len(finite) else None,
            "frac_stable_band": float(np.mean(finite >= 0.50)) if len(finite) else None,
        },
        "chaos_runs": {
            "n": len(runs),
            "runs": [{"start": int(s), "end": int(e), "length": int(e - s)} for s, e in runs],
            "mean_length": float(np.mean(run_lengths)) if run_lengths else None,
            "max_length": int(max(run_lengths)) if run_lengths else None,
            "note": (
                "single long chaos-band → no inter-run pairs; use local_max / zero-cross"
                if len(runs) <= 1
                else "multiple chaos-band runs"
            ),
        },
        "coherence_run_return": {
            "n_pairs": int(len(ex)),
            "s_exit": ex.tolist(),
            "s_next": nx.tolist(),
            "binned": run_curve,
        },
        "local_max_return": {
            "n_section": int(len(sec)),
            "n_pairs": int(len(pairs)),
            "binned": loc_curve,
        },
        "zero_cross_return": {
            "n_section": int(len(sec_z)),
            "n_pairs": int(len(pairs_z)),
            "binned": z_curve,
        },
        "length_ratio_proxy": ratios,
        "honesty": (
            "Field return is observational: coherence-run phase proxies, "
            "local-max pairs, and zero-cross pairs on τₛ. Not a proof of strong "
            "unimodality or lab-map identification with logistic/tent. Length "
            "ratios are not classical Feigenbaum δ from superstable R_n. Short "
            "T with |τ| always in the chaos band yields one run → inter-run map empty."
        ),
    }


def multi_site_field_return(
    sites: Dict[str, np.ndarray],
    *,
    window_size: int = 13,
    theta: float = THETA_CHAOS,
    min_run: int = 4,
) -> Dict[str, Any]:
    """Per-site reports + pooled coherence-run pairs across sites."""
    reports: List[Dict[str, Any]] = []
    pool_x: List[float] = []
    pool_y: List[float] = []
    for name in sorted(sites.keys()):
        rep = field_return_report(
            sites[name],
            name=name,
            window_size=window_size,
            theta=theta,
            min_run=min_run,
        )
        reports.append(rep)
        if rep.get("ok"):
            cr = rep["coherence_run_return"]
            pool_x.extend(cr.get("s_exit") or [])
            pool_y.extend(cr.get("s_next") or [])
    pool_curve = binned_return_curve(
        np.asarray(pool_x, dtype=float),
        np.asarray(pool_y, dtype=float),
    )
    n_ok = sum(1 for r in reports if r.get("ok"))
    n_with_pairs = sum(
        1 for r in reports if r.get("ok") and r["coherence_run_return"]["n_pairs"] > 0
    )
    n_loc = sum(
        1 for r in reports if r.get("ok") and r["local_max_return"]["n_pairs"] > 0
    )
    n_peak = sum(
        1
        for r in reports
        if r.get("ok")
        and (
            r["local_max_return"]["binned"].get("single_peak_like")
            or r["coherence_run_return"]["binned"].get("single_peak_like")
        )
    )
    return {
        "schema": "systemic-tau-formal/field-return/v1",
        "n_sites": len(reports),
        "n_ok": n_ok,
        "n_with_run_pairs": n_with_pairs,
        "n_with_local_max_pairs": n_loc,
        "n_single_peak_like": n_peak,
        "pooled_coherence_pairs": int(len(pool_x)),
        "pooled_binned": pool_curve,
        "sites": reports,
        "headline": (
            f"{n_ok} sites · run-pairs={n_with_pairs} · "
            f"local-max pairs={n_loc} · peak_like={n_peak}/{n_ok} · "
            f"pooled_run_pairs={len(pool_x)}"
        ),
        "honesty": (
            "Multi-site field return is a diagnostic board, not classical "
            "unimodality discharge. Short T (≈30–50 weeks) and sustained chaos "
            "band often yield a single run → rely on local-max / zero-cross pairs."
        ),
    }
