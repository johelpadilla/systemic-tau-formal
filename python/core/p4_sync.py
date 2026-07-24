"""
P4 — anti-synchronization clock structure ([CONJETURA] operationalized).

Synthetic path (CI): anti vs sync series differ in gate polarity and increments.
Field path: same metrics on multi-trap matrices + distance to synthetic baselines
at matched (T, N). Does **not** invent anti-regimes when field data are co-moving.
"""

from __future__ import annotations

from typing import Dict, List, Optional, Sequence, Tuple

import numpy as np

from .constants import THETA_CHAOS, THETA_STABLE
from .recd import accumulate_time
from .regimes import regime_fracs
from .synthetic import anti_synchronized, independent_noise, synchronized_seasonal
from .tau import compute_taus


def pairwise_corr_stats(X: np.ndarray) -> Dict[str, float]:
    """Upper-triangle Pearson correlations across columns (traps / channels)."""
    X = np.asarray(X, dtype=float)
    T, N = X.shape
    if N < 2:
        return {
            "mean_pair_corr": float("nan"),
            "median_pair_corr": float("nan"),
            "frac_neg_pair_corr": float("nan"),
            "n_pairs": 0.0,
        }
    # drop columns that are constant (corr undefined)
    std = np.nanstd(X, axis=0)
    good = std > 1e-12
    if int(good.sum()) < 2:
        return {
            "mean_pair_corr": float("nan"),
            "median_pair_corr": float("nan"),
            "frac_neg_pair_corr": float("nan"),
            "n_pairs": 0.0,
        }
    C = np.corrcoef(X[:, good].T)
    iu = np.triu_indices(C.shape[0], k=1)
    pc = C[iu]
    pc = pc[np.isfinite(pc)]
    if pc.size == 0:
        return {
            "mean_pair_corr": float("nan"),
            "median_pair_corr": float("nan"),
            "frac_neg_pair_corr": float("nan"),
            "n_pairs": 0.0,
        }
    return {
        "mean_pair_corr": float(np.mean(pc)),
        "median_pair_corr": float(np.median(pc)),
        "frac_neg_pair_corr": float(np.mean(pc < 0.0)),
        "n_pairs": float(pc.size),
    }


def p4_clock_metrics(X: np.ndarray, *, window_size: int = 13) -> Dict[str, float]:
    """
    Operational P4 feature vector for one multivariate series.

    Combines ordinal τₛ / gate structure with raw pairwise co-movement.
    """
    X = np.asarray(X, dtype=float)
    if X.ndim != 2:
        raise ValueError("X must be 2-D (T, N)")
    T, N = X.shape
    pc = pairwise_corr_stats(X)
    tg, _ = compute_taus(X, window_size=window_size)
    fr = regime_fracs(tg)
    _, dtk, g, _ = accumulate_time(tg, window_size=window_size)
    m = np.isfinite(g) & np.isfinite(dtk)
    g_v = g[m]
    dtk_v = dtk[m]
    inc = g_v * dtk_v
    if g_v.size:
        frac_plus = float(np.mean(g_v == 1.0))
        frac_minus = float(np.mean(g_v == -1.0))
        mean_g = float(np.mean(g_v))
        mean_inc = float(np.mean(inc))
        std_inc = float(np.std(inc))
    else:
        frac_plus = frac_minus = mean_g = mean_inc = std_inc = float("nan")
    valid = tg[~np.isnan(tg)]
    frac_strong_anti = float(np.mean(valid <= -THETA_CHAOS)) if valid.size else 0.0
    frac_strong_stable = float(np.mean(valid >= THETA_STABLE)) if valid.size else 0.0
    return {
        "T": float(T),
        "N": float(N),
        "n_valid_tau": float(valid.size),
        "mean_tau": fr["mean_tau"],
        "frac_stable": fr["stable"],
        "frac_chaos": fr["chaos"],
        "frac_anti": fr["anti"],
        "frac_strong_anti": frac_strong_anti,
        "frac_strong_stable": frac_strong_stable,
        "frac_gate_plus": frac_plus,
        "frac_gate_minus": frac_minus,
        "mean_gate": mean_g,
        "mean_inc": mean_inc,
        "std_inc": std_inc,
        **pc,
    }


# Features used for nearest-baseline distance (scale-robust enough for short T)
_FEATURE_KEYS: Tuple[str, ...] = (
    "mean_tau",
    "mean_pair_corr",
    "frac_gate_plus",
    "frac_neg_pair_corr",
)


def _feature_vec(m: Dict[str, float]) -> np.ndarray:
    return np.array([float(m[k]) for k in _FEATURE_KEYS], dtype=float)


def p4_baseline_metrics(
    T: int,
    N: int,
    *,
    window_size: int = 13,
    seed: int = 0,
) -> Dict[str, Dict[str, float]]:
    """Matched-(T,N) synthetic baselines: sync / anti / independent."""
    # anti_synchronized needs N>=2; for odd N, generators still work (unbalanced)
    n_use = max(int(N), 2)
    X_s = synchronized_seasonal(T=T, N=n_use, seed=seed)
    X_a = anti_synchronized(T=T, N=n_use if n_use % 2 == 0 else n_use + 1, seed=seed + 1)
    if X_a.shape[1] != n_use:
        X_a = X_a[:, :n_use]
    X_i = independent_noise(T=T, N=n_use, seed=seed + 2)
    # match amplitude loosely to counts when N was 1 (rare)
    out = {
        "sync": p4_clock_metrics(X_s, window_size=window_size),
        "anti": p4_clock_metrics(X_a, window_size=window_size),
        "independent": p4_clock_metrics(X_i, window_size=window_size),
    }
    return out


def p4_nearest_baseline(
    metrics: Dict[str, float],
    baselines: Dict[str, Dict[str, float]],
) -> Tuple[str, float, Dict[str, float]]:
    """
    L1 distance on the feature vector → nearest baseline name.

    Returns (name, distance, all_distances).
    """
    v = _feature_vec(metrics)
    dists: Dict[str, float] = {}
    for name, bm in baselines.items():
        bv = _feature_vec(bm)
        if not np.all(np.isfinite(v)) or not np.all(np.isfinite(bv)):
            dists[name] = float("inf")
        else:
            dists[name] = float(np.sum(np.abs(v - bv)))
    best = min(dists, key=dists.get)
    return best, dists[best], dists


def p4_series_report(
    X: np.ndarray,
    *,
    name: str = "series",
    window_size: int = 13,
    seed: int = 0,
) -> Dict:
    """Full P4 operational report for one matrix."""
    X = np.asarray(X, dtype=float)
    T, N = X.shape
    m = p4_clock_metrics(X, window_size=window_size)
    bases = p4_baseline_metrics(T, N, window_size=window_size, seed=seed)
    nearest, dist, all_d = p4_nearest_baseline(m, bases)
    # Can we even *instantiate* the P4 anti-regime premise on this series?
    premise_anti = bool(m["frac_strong_anti"] >= 0.15 and m["mean_tau"] < 0.0)
    premise_stable = bool(m["frac_strong_stable"] >= 0.15 and m["mean_tau"] > 0.0)
    if not premise_anti:
        p4_status = "no_strong_anti_regime"
        p4_note = (
            "Series does not sit in the P4 premise (τₛ ≤ −0.41 mass). "
            "Cannot confirm or falsify anti-sync clock structure on this matrix; "
            "structure is reported vs synthetic baselines only."
        )
    else:
        # With anti mass, compare increment structure to sync baseline
        sync_std = bases["sync"]["std_inc"]
        anti_std = bases["anti"]["std_inc"]
        field_std = m["std_inc"]
        # distinct if field closer to anti baseline on std_inc than to sync
        closer_anti = abs(field_std - anti_std) < abs(field_std - sync_std)
        p4_status = "anti_structure_present" if closer_anti else "anti_mass_but_inc_like_sync"
        p4_note = (
            "Strong anti mass present; increment std compared to baselines."
            if closer_anti
            else "Anti τ mass present but increment spread nearer sync baseline."
        )
    return {
        "name": name,
        "metrics": m,
        "baselines": {k: bases[k] for k in bases},
        "nearest_baseline": nearest,
        "nearest_distance": dist,
        "distances": all_d,
        "premise_anti": premise_anti,
        "premise_stable": premise_stable,
        "p4_status": p4_status,
        "p4_note": p4_note,
        "label": "[CONJETURA] operationalized; field rows tagged separately by caller",
    }


def p4_field_scan(
    sites: Dict[str, np.ndarray],
    *,
    window_size: int = 13,
    seed: int = 0,
    min_T: int = 20,
    min_N: int = 2,
) -> List[Dict]:
    """Run ``p4_series_report`` on each site matrix that is long/wide enough."""
    rows: List[Dict] = []
    for name, X in sites.items():
        X = np.asarray(X, dtype=float)
        if X.ndim != 2 or X.shape[0] < min_T or X.shape[1] < min_N:
            rows.append(
                {
                    "name": name,
                    "skipped": True,
                    "reason": f"shape {getattr(X, 'shape', None)} below min_T={min_T} min_N={min_N}",
                }
            )
            continue
        rep = p4_series_report(X, name=name, window_size=window_size, seed=seed)
        rep["skipped"] = False
        rows.append(rep)
    return rows
