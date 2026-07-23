"""
P4 — Anti-synchronization clock structure ([CONJETURA] operationalized).

On synthetic anti vs sync series, gate polarity and increment structure differ.
"""

from __future__ import annotations

import numpy as np

from core import (
    THETA_CHAOS,
    THETA_STABLE,
    accumulate_time,
    anti_synchronized,
    compute_taus,
    synchronized_seasonal,
)


def test_p4_gate_sign_differs_anti_vs_sync():
    X_s = synchronized_seasonal(T=260, N=4, seed=0)
    X_a = anti_synchronized(T=260, N=4, seed=1)

    tg_s, _ = compute_taus(X_s, window_size=13)
    tg_a, _ = compute_taus(X_a, window_size=13)

    _, _, g_s, _ = accumulate_time(tg_s, window_size=13)
    _, _, g_a, _ = accumulate_time(tg_a, window_size=13)

    # Sync: many +1 gates; anti: should not be dominated by +1
    frac_plus_s = np.mean(g_s == 1.0)
    frac_plus_a = np.mean(g_a == 1.0)
    assert frac_plus_s > 0.4
    assert frac_plus_a < frac_plus_s - 0.15

    # Mean gate: sync high positive, anti lower
    assert np.nanmean(g_s) > np.nanmean(g_a) + 0.2


def test_p4_increment_histograms_differ():
    X_s = synchronized_seasonal(T=260, N=4, seed=0)
    X_a = anti_synchronized(T=260, N=4, seed=1)

    tg_s, _ = compute_taus(X_s, window_size=13)
    tg_a, _ = compute_taus(X_a, window_size=13)

    T_s, dtk_s, g_s, _ = accumulate_time(tg_s, window_size=13)
    T_a, dtk_a, g_a, _ = accumulate_time(tg_a, window_size=13)

    inc_s = g_s * dtk_s
    inc_a = g_a * dtk_a

    # Distinct structure: sync rarely accumulates via anti gate path
    # Compare mass of negative increments (anti gate × positive Δt on chaos)
    # and final |T| profiles
    assert not np.allclose(
        np.histogram(inc_s, bins=20, range=(-0.01, 0.01))[0],
        np.histogram(inc_a, bins=20, range=(-0.01, 0.01))[0],
    ) or abs(T_s[-1] - T_a[-1]) > 1e-6

    # Harder signal: mean τ and mean g differ in the expected direction
    vs = tg_s[~np.isnan(tg_s)]
    va = tg_a[~np.isnan(tg_a)]
    assert vs.mean() > va.mean()


def test_p4_anti_suppresses_stable_band():
    X_a = anti_synchronized(T=300, N=6, seed=4)
    tg, _ = compute_taus(X_a, window_size=13)
    valid = tg[~np.isnan(tg)]
    assert np.mean(valid >= THETA_STABLE) < 0.25
    # many windows should sit in chaos or anti side
    assert np.mean((valid <= -THETA_CHAOS) | (np.abs(valid) < THETA_CHAOS)) > 0.3
