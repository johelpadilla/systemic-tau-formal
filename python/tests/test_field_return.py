"""Field-return diagnostics + exploratory multi-site leads."""

from __future__ import annotations

from pathlib import Path

import numpy as np
import pytest

from core.field_return import (
    binned_return_curve,
    chaos_band_runs,
    coherence_run_return_pairs,
    field_return_report,
    multi_site_field_return,
)
from core.p1_endpoints import exploratory_lead_scan, trap_surge_t_obs
from core.synthetic import independent_noise, synchronized_seasonal

REPO = Path(__file__).resolve().parents[2]


def test_chaos_band_runs_min_length():
    # indices 1–3: three chaos samples; 5–7 also |τ|<0.41 for three samples
    tau = np.array([0.6, 0.1, 0.0, -0.2, 0.7, 0.05, 0.1, 0.2, 0.8])
    runs = chaos_band_runs(tau, theta=0.41, min_run=3)
    assert runs == [(1, 4), (5, 8)]
    runs_strict = chaos_band_runs(tau, theta=0.41, min_run=4)
    assert runs_strict == []
    # shorter min_run keeps both
    runs2 = chaos_band_runs(tau, theta=0.41, min_run=2)
    assert (1, 4) in runs2 and (5, 8) in runs2


def test_coherence_run_return_pairs_shapes():
    runs = [(0, 10), (15, 20), (30, 50)]
    ex, nx = coherence_run_return_pairs(runs, soften=5.0)
    assert len(ex) == 2 and len(nx) == 2
    assert np.all(ex >= 0) and np.all(ex < 1)
    assert np.all(nx >= 0) and np.all(nx < 1)


def test_binned_single_peak_like():
    # inverted-U shape
    x = np.linspace(0, 1, 40)
    y = 1.0 - (x - 0.5) ** 2
    out = binned_return_curve(x, y, n_bins=6)
    assert out["n"] == 40
    assert out["single_peak_like"] is True


def test_field_return_report_on_synthetic():
    X = synchronized_seasonal(T=80, N=5, seed=3)
    rep = field_return_report(X, name="syn", window_size=13, min_run=3)
    assert rep["ok"] is True
    assert rep["shape"] == [80, 5]
    assert "coherence_run_return" in rep
    assert "local_max_return" in rep
    assert "not classical" in rep["honesty"].lower() or "Not a proof" in rep["honesty"]


def test_trap_surge_methods():
    X = np.array(
        [
            [1, 1],
            [2, 2],
            [10, 10],  # max
            [3, 3],
            [4, 4],
        ],
        dtype=float,
    )
    m = trap_surge_t_obs(X, method="max_total")
    assert m["t_obs"] == 2
    q = trap_surge_t_obs(X, method="first_q90")
    assert q["t_obs"] is not None
    assert q["t_obs"] <= 2


def test_exploratory_never_pre_registered():
    sites = {
        "A": independent_noise(T=60, N=3, seed=1),
        "B": synchronized_seasonal(T=60, N=4, seed=2),
    }
    out = exploratory_lead_scan(sites, window_size=13)
    assert out["status"] == "exploratory_not_pre_registered"
    assert out["p1_discharge"] is False
    assert out["n_scored"] >= 1
    for r in out["rows"]:
        assert r["pre_registered"] is False
        assert r["p1_discharge"] is False


def test_multi_site_on_committed_raw():
    from core import load_aedes_sites

    loaded = load_aedes_sites(root=REPO, prefer_raw=True)
    if loaded.source != "raw":
        pytest.skip("no raw")
    board = multi_site_field_return(loaded.sites, window_size=13, min_run=4)
    assert board["n_sites"] >= 3
    assert board["n_ok"] >= 3
    # short series may yield few run pairs — still must report
    assert "pooled_coherence_pairs" in board
    for s in board["sites"]:
        assert s.get("ok")
        assert "honesty" in s
