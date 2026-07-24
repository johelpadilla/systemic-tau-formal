"""P4 structure scan on committed field Aedes series ([EMPÍRICO] provenance)."""

from __future__ import annotations

from pathlib import Path

import numpy as np
import pytest

from core import (
    anti_synchronized,
    load_aedes_sites,
    p4_field_scan,
    p4_series_report,
    synchronized_seasonal,
)

REPO = Path(__file__).resolve().parents[2]


@pytest.fixture(scope="module")
def raw_sites():
    result = load_aedes_sites(root=REPO, prefer_raw=True)
    if result.source != "raw":
        pytest.skip("no field CSVs in data/aedes/raw/")
    return result.sites


def test_p4_synthetic_anti_nearest_is_anti():
    """Sanity: pure anti generator should not map nearest to sync."""
    X = anti_synchronized(T=260, N=6, seed=7)
    rep = p4_series_report(X, name="anti_lab", window_size=13, seed=0)
    assert rep["nearest_baseline"] in ("anti", "independent")
    assert rep["nearest_baseline"] != "sync"
    assert rep["metrics"]["mean_pair_corr"] < rep["baselines"]["sync"]["mean_pair_corr"]


def test_p4_synthetic_sync_nearest_is_sync():
    X = synchronized_seasonal(T=260, N=6, seed=0)
    rep = p4_series_report(X, name="sync_lab", window_size=13, seed=0)
    assert rep["nearest_baseline"] == "sync"
    assert rep["metrics"]["mean_pair_corr"] > 0.5


def test_p4_field_scan_runs(raw_sites):
    rows = p4_field_scan(raw_sites, window_size=13, seed=0)
    scored = [r for r in rows if not r.get("skipped")]
    assert scored, "expected at least one scorable field series"
    for r in scored:
        m = r["metrics"]
        assert m["N"] >= 2
        assert np.isfinite(m["mean_tau"])
        assert np.isfinite(m["mean_pair_corr"])
        assert r["nearest_baseline"] in ("sync", "anti", "independent")
        assert r["p4_status"] in (
            "no_strong_anti_regime",
            "anti_structure_present",
            "anti_mass_but_inc_like_sync",
        )


def test_p4_field_sju_co_moving_not_anti_premise(raw_sites):
    """
    Honest field expectation for 2018 San Juan multi-trap matrices:

    traps co-move (positive mean pairwise corr); strong-anti premise for P4
    is not satisfied → status no_strong_anti_regime.
    """
    rows = p4_field_scan(raw_sites, window_size=13, seed=0)
    for r in rows:
        if r.get("skipped"):
            continue
        m = r["metrics"]
        assert m["mean_pair_corr"] > 0.10, (
            f"{r['name']}: expected co-moving traps, got pair_r={m['mean_pair_corr']}"
        )
        assert m["mean_tau"] > -0.05, (
            f"{r['name']}: mean τ unexpectedly anti-like: {m['mean_tau']}"
        )
        # P4 premise (strong anti mass) should not fire on these series
        assert r["p4_status"] == "no_strong_anti_regime", (
            f"{r['name']}: unexpected p4_status={r['p4_status']}"
        )
        # nearest baseline should not be pure anti
        assert r["nearest_baseline"] != "anti", (
            f"{r['name']}: nearest=anti despite co-moving traps"
        )
