"""Operational regime labels from τₛ (not Lean theorems)."""

from __future__ import annotations

from typing import Dict

import numpy as np

from .constants import THETA_CHAOS, THETA_STABLE

# 0 stable, 1 chaos, 2 anti, 3 intermediate, -1 invalid/NaN
REGIME_STABLE = 0
REGIME_CHAOS = 1
REGIME_ANTI = 2
REGIME_INTERMEDIATE = 3
REGIME_INVALID = -1


def regime_vector(tg: np.ndarray) -> np.ndarray:
    """Map τₛ series to discrete regime codes."""
    out = np.full(tg.shape, REGIME_INVALID, dtype=int)
    m = ~np.isnan(tg)
    t = tg[m]
    labels = np.full(t.shape, REGIME_INTERMEDIATE, dtype=int)
    labels[t >= THETA_STABLE] = REGIME_STABLE
    labels[t <= -THETA_CHAOS] = REGIME_ANTI
    labels[np.abs(t) < THETA_CHAOS] = REGIME_CHAOS
    # edges take precedence over chaos band when |τ| is large
    labels[t >= THETA_STABLE] = REGIME_STABLE
    labels[t <= -THETA_CHAOS] = REGIME_ANTI
    out[m] = labels
    return out


def regime_agreement(a: np.ndarray, b: np.ndarray) -> float:
    """Fraction of time both labels valid and equal."""
    m = (a >= 0) & (b >= 0)
    if not np.any(m):
        return 0.0
    return float(np.mean(a[m] == b[m]))


def regime_fracs(tg: np.ndarray) -> Dict[str, float]:
    valid = tg[~np.isnan(tg)]
    if valid.size == 0:
        return {"mean_tau": float("nan"), "stable": 0.0, "chaos": 0.0, "anti": 0.0}
    return {
        "mean_tau": float(valid.mean()),
        "stable": float(np.mean(valid >= THETA_STABLE)),
        "chaos": float(np.mean(np.abs(valid) < THETA_CHAOS)),
        "anti": float(np.mean(valid <= -THETA_CHAOS)),
    }


def p3_noise_scan(
    X0: np.ndarray,
    *,
    rhos: tuple[float, ...] = (0.0, 0.05, 0.10, 0.20),
    window_size: int = 13,
    seed: int = 42,
) -> list[dict]:
    """
    Protocol P3 scan: add column noise at each ρ, no threshold re-fit.

    Returns one dict per ρ with fracs + agreement vs ρ=0.
    """
    from .synthetic import add_column_noise
    from .tau import compute_taus

    X0 = np.asarray(X0, dtype=float)
    tg0, _ = compute_taus(X0, window_size=window_size)
    r0 = regime_vector(tg0)
    rows: list[dict] = []
    for rho in rhos:
        Xn = add_column_noise(X0, rho=float(rho), seed=seed)
        # counts stay non-negative when field-like
        Xn = np.maximum(Xn, 0.0)
        tgn, _ = compute_taus(Xn, window_size=window_size)
        rn = regime_vector(tgn)
        fr = regime_fracs(tgn)
        agr = 1.0 if rho == 0.0 else regime_agreement(r0, rn)
        rows.append(
            {
                "rho": float(rho),
                "mean_tau": fr["mean_tau"],
                "frac_stable": fr["stable"],
                "frac_chaos": fr["chaos"],
                "frac_anti": fr["anti"],
                "agree_vs_rho0": agr,
            }
        )
    return rows
