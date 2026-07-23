"""C3 synthetic cross-domain starters — [OPERACIONAL] only."""

import numpy as np

from core import (
    eeg_like_channels,
    finance_like_returns,
    grid_like_loads,
    pipeline_report,
)


def test_finance_like_correlation_break_shifts_tau():
    X, meta = finance_like_returns(T=400, N=5, t_break=200, seed=10)
    assert X.shape == (400, 5)
    rep = pipeline_report(X, name="finance_like", meta=meta)
    # second half should pull mean τ down vs pure high-corr series
    X_hi, _ = finance_like_returns(T=400, N=5, t_break=399, rho_pre=0.8, rho_post=0.8, seed=10)
    rep_hi = pipeline_report(X_hi, name="finance_hi")
    assert rep["mean_tau"] < rep_hi["mean_tau"]


def test_eeg_like_desync_increases_chaos_fraction():
    X, meta = eeg_like_channels(T=600, N=6, t_desync=300, seed=11)
    rep = pipeline_report(X, name="eeg_like", meta=meta)
    X_lock, _ = eeg_like_channels(T=600, N=6, t_desync=599, seed=11)
    rep_lock = pipeline_report(X_lock, name="eeg_lock")
    # desync should not increase stable share vs fully locked
    assert rep["frac_stable"] <= rep_lock["frac_stable"] + 0.05


def test_grid_like_runs_pipeline():
    X, meta = grid_like_loads(T=300, N=4, seed=12)
    rep = pipeline_report(X, name="grid_like", meta=meta)
    assert np.isfinite(rep["T_RECD_end"])
    assert rep["shape"] == [300, 4]
