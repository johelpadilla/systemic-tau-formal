"""
Discrete first-return (Poincaré) skeleton matching Lean FeigenbaumReduction.

[OPERACIONAL] Combinatorial extraction from a 1-D coherence series (e.g. τₛ).
Does **not** prove continuum unimodality or Feigenbaum universality.
"""

from __future__ import annotations

from typing import Callable, List, Sequence, Tuple

import numpy as np


def section_values(
    series: Sequence[float],
    pred: Callable[[float], bool],
) -> np.ndarray:
    """Keep samples where *pred* is true (finite values only)."""
    out: List[float] = []
    for x in series:
        if x is None or (isinstance(x, float) and np.isnan(x)):
            continue
        xf = float(x)
        if not np.isfinite(xf):
            continue
        if pred(xf):
            out.append(xf)
    return np.asarray(out, dtype=float)


def return_pairs(section: Sequence[float]) -> List[Tuple[float, float]]:
    """Successive pairs (xᵢ, xᵢ₊₁) — Lean `returnPairs`."""
    xs = [float(x) for x in section if np.isfinite(float(x))]
    return [(xs[i], xs[i + 1]) for i in range(len(xs) - 1)]


def local_max_mask(series: np.ndarray) -> np.ndarray:
    """Boolean mask: strict local maxima in the interior."""
    s = np.asarray(series, dtype=float)
    n = len(s)
    m = np.zeros(n, dtype=bool)
    for i in range(1, n - 1):
        if np.isnan(s[i]) or np.isnan(s[i - 1]) or np.isnan(s[i + 1]):
            continue
        if s[i] > s[i - 1] and s[i] > s[i + 1]:
            m[i] = True
    return m


def first_return_from_local_maxima(
    series: Sequence[float],
) -> Tuple[np.ndarray, List[Tuple[float, float]]]:
    """Poincaré section ≈ local maxima of the coherence series."""
    s = np.asarray(series, dtype=float)
    mask = local_max_mask(s)
    sec = s[mask]
    return sec, return_pairs(sec)


def first_return_crossing(
    series: Sequence[float],
    level: float = 0.0,
    direction: str = "up",
) -> Tuple[np.ndarray, List[Tuple[float, float]]]:
    """
    Section at upward (or downward) crossings of *level*.

    Records the value *after* the crossing (series[i+1]).
    """
    s = np.asarray(series, dtype=float)
    sec: List[float] = []
    for i in range(len(s) - 1):
        a, b = s[i], s[i + 1]
        if not (np.isfinite(a) and np.isfinite(b)):
            continue
        if direction == "up" and a < level <= b:
            sec.append(float(b))
        elif direction == "down" and a > level >= b:
            sec.append(float(b))
    arr = np.asarray(sec, dtype=float)
    return arr, return_pairs(arr)


def nonneg_pred(x: float) -> bool:
    """Lean-style `nonnegPred`."""
    return x >= 0.0
