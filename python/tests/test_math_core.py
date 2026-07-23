"""Mathematical smoke tests for τₛ + RECD reference core."""

import numpy as np
import pytest

from core import (
    DELTA,
    THETA_CHAOS,
    THETA_STABLE,
    accumulate_time,
    compute_taus,
    gate_function,
    kendall_tau,
)


def test_constants():
    assert DELTA == pytest.approx(4.6692016091)
    assert THETA_CHAOS == 0.41
    assert THETA_STABLE == 0.50


def test_kendall_perfect_sync():
    x = np.arange(20, dtype=float)
    y = x + 3.0
    assert kendall_tau(x, y) == pytest.approx(1.0)


def test_kendall_perfect_anti():
    x = np.arange(20, dtype=float)
    y = -x
    assert kendall_tau(x, y) == pytest.approx(-1.0)


def test_gate_regimes():
    assert gate_function(0.75) == 1.0
    assert gate_function(-0.75) == -1.0
    assert gate_function(0.45) == 0.0  # intermediate
    g_chaos = gate_function(0.0)
    expected = (DELTA - 1.0) / DELTA  # |τ|=0 → full chaotic prefactor
    assert g_chaos == pytest.approx(expected)


def test_compute_taus_shape():
    rng = np.random.default_rng(0)
    X = rng.normal(size=(100, 3))
    tg, tm = compute_taus(X, window_size=13)
    assert tg.shape == (100,)
    assert tm.shape == (100, 3)
    # first window_size-1 entries are nan
    assert np.all(np.isnan(tg[:12]))
    assert np.any(~np.isnan(tg[12:]))


def test_synchronized_system_high_tau():
    t = np.linspace(0, 10, 200)
    base = np.sin(t)
    X = np.column_stack([base, base + 0.01 * np.sin(3 * t), base + 0.01])
    tg, _ = compute_taus(X, window_size=13)
    valid = tg[~np.isnan(tg)]
    assert valid.mean() > 0.5


def test_accumulate_time_monotone_on_chaos_run():
    # sustained chaotic |τ|<0.41 with positive gate contribution
    taus = np.full(50, 0.1)
    T, dtk, g, depth = accumulate_time(taus, window_size=13)
    assert T.shape == (50,)
    assert np.all(g > 0)
    assert depth[-1] == 50
    assert T[-1] > 0
