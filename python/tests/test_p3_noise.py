"""
P3 — Threshold robustness under noise ([EMPÍRICO] protocol on synthetic).

See docs/FALSIFIABLE_PREDICTIONS.md and EXPERIMENTAL_PROTOCOL.md § Noise.

We do **not** claim dengue field robustness here. We check that on controlled
synthetic systems, qualitative regime labels stay usable at ρ ≤ 0.20 without
re-fitting thresholds.
"""

from __future__ import annotations

import numpy as np
import pytest

from core import (
    THETA_CHAOS,
    THETA_STABLE,
    add_column_noise,
    compute_taus,
    synchronized_seasonal,
    independent_noise,
)


def _regime_vector(tg: np.ndarray) -> np.ndarray:
    """Map τₛ to {0 stable, 1 chaos, 2 anti, 3 intermediate}; NaN → -1."""
    out = np.full(tg.shape, -1, dtype=int)
    m = ~np.isnan(tg)
    t = tg[m]
    labels = np.full(t.shape, 3, dtype=int)  # intermediate default
    labels[t >= THETA_STABLE] = 0
    labels[np.abs(t) < THETA_CHAOS] = 1
    labels[t <= -THETA_CHAOS] = 2
    # chaos overrides intermediate; stable/anti take precedence at edges
    labels[t >= THETA_STABLE] = 0
    labels[t <= -THETA_CHAOS] = 2
    labels[(np.abs(t) < THETA_CHAOS)] = 1
    out[m] = labels
    return out


def _agreement(a: np.ndarray, b: np.ndarray) -> float:
    m = (a >= 0) & (b >= 0)
    if not np.any(m):
        return 0.0
    return float(np.mean(a[m] == b[m]))


@pytest.mark.parametrize("rho", [0.05, 0.10, 0.20])
def test_p3_sync_remains_mostly_stable_under_noise(rho):
    X0 = synchronized_seasonal(T=260, N=4, seed=0)
    tg0, _ = compute_taus(X0, window_size=13)
    r0 = _regime_vector(tg0)

    Xn = add_column_noise(X0, rho=rho, seed=99)
    tgn, _ = compute_taus(Xn, window_size=13)
    rn = _regime_vector(tgn)

    agree = _agreement(r0, rn)
    # Qualitative usability (P3): majority regime agreement; slightly looser at 20%
    min_agree = 0.70 if rho < 0.20 else 0.60
    assert agree >= min_agree, f"P3 fail sync: agreement={agree:.3f} at rho={rho}"

    valid = tgn[~np.isnan(tgn)]
    assert valid.mean() > 0.35  # still sync-leaning


@pytest.mark.parametrize("rho", [0.05, 0.10, 0.20])
def test_p3_iid_remains_mostly_chaos_band_under_noise(rho):
    X0 = independent_noise(T=260, N=4, seed=2)
    tg0, _ = compute_taus(X0, window_size=13)
    r0 = _regime_vector(tg0)

    Xn = add_column_noise(X0, rho=rho, seed=77)
    tgn, _ = compute_taus(Xn, window_size=13)
    rn = _regime_vector(tgn)

    agree = _agreement(r0, rn)
    assert agree >= 0.55, f"P3 fail iid: agreement={agree:.3f} at rho={rho}"

    valid = tgn[~np.isnan(tgn)]
    assert np.mean(np.abs(valid) < THETA_CHAOS) > 0.45


def test_p3_zero_noise_identity():
    X = synchronized_seasonal(T=100, N=3, seed=5)
    Y = add_column_noise(X, rho=0.0)
    assert np.allclose(X, Y)
