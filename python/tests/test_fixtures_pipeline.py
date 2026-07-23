"""End-to-end pipeline on committed CSV fixtures ([OPERACIONAL])."""

from __future__ import annotations

from pathlib import Path

import numpy as np
import pytest

from core import (
    THETA_CHAOS,
    THETA_STABLE,
    accumulate_time,
    compute_taus,
    load_matrix_csv,
)

REPO = Path(__file__).resolve().parents[2]
SYN = REPO / "data" / "synthetic"
AEDES = REPO / "data" / "aedes" / "proxy"


def _require_fixture(path: Path) -> Path:
    if not path.is_file():
        pytest.skip(f"missing fixture {path} — run python/scripts/export_fixtures.py")
    return path


def test_sync_fixture_high_tau():
    path = _require_fixture(SYN / "sync_seasonal.csv")
    X = load_matrix_csv(path)
    assert X.shape[1] >= 2
    tg, _ = compute_taus(X, window_size=13)
    valid = tg[~np.isnan(tg)]
    assert valid.mean() > 0.5
    assert np.mean(valid >= THETA_STABLE) > 0.5


def test_anti_fixture_not_stable():
    path = _require_fixture(SYN / "anti_sync.csv")
    X = load_matrix_csv(path)
    tg, _ = compute_taus(X, window_size=13)
    valid = tg[~np.isnan(tg)]
    # Anti construction should suppress stable band dominance
    assert valid.mean() < 0.2
    assert np.mean(valid >= THETA_STABLE) < 0.2


def test_independent_fixture_mostly_chaos_band():
    path = _require_fixture(SYN / "independent_noise.csv")
    X = load_matrix_csv(path)
    tg, _ = compute_taus(X, window_size=13)
    valid = tg[~np.isnan(tg)]
    assert np.mean(np.abs(valid) < THETA_CHAOS) > 0.5


def test_regime_switch_fixture_runs_pipeline():
    path = _require_fixture(SYN / "regime_switch.csv")
    X = load_matrix_csv(path)
    tg, _ = compute_taus(X, window_size=13)
    T, dtk, g, depth = accumulate_time(tg, window_size=13)
    assert T.shape == (X.shape[0],)
    assert np.any(depth > 0)  # second half noise → chaotic runs


def test_aedes_proxy_fixtures():
    for name in ("Cano_Martin_Pena_proxy.csv", "Candelaria_proxy.csv"):
        path = _require_fixture(AEDES / name)
        X = load_matrix_csv(path)
        assert X.shape == (200, 3)
        assert np.all(X >= 0)
        tg, _ = compute_taus(X, window_size=13)
        T, _, _, _ = accumulate_time(tg, window_size=13)
        assert np.isfinite(T[-1])
