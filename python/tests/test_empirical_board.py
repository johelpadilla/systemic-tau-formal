"""Unified empirical board + multi-year raw discovery."""

from __future__ import annotations

from pathlib import Path

import numpy as np
import pytest

from core import build_empirical_board, load_aedes_sites
from core.aedes_io import discover_matrix_csvs
from core.io_data import save_matrix_csv

REPO = Path(__file__).resolve().parents[2]
RAW = REPO / "data" / "aedes" / "raw"


def test_discover_recursive_includes_year_subdir(tmp_path: Path):
    year = tmp_path / "2019"
    year.mkdir()
    # tiny valid matrix
    X = np.arange(40, dtype=float).reshape(20, 2)
    save_matrix_csv(year / "Demo_Site.csv", X)
    # top-level also
    save_matrix_csv(tmp_path / "Top.csv", X + 1)
    found = discover_matrix_csvs(tmp_path, recursive=True)
    assert "Top" in found
    assert "2019_Demo_Site" in found
    flat_only = discover_matrix_csvs(tmp_path, recursive=False)
    assert "Top" in flat_only
    assert "2019_Demo_Site" not in flat_only


def test_load_aedes_sites_recursive_raw(tmp_path: Path):
    """Isolated fake repo tree with nested raw only."""
    raw = tmp_path / "data" / "aedes" / "raw" / "2020"
    raw.mkdir(parents=True)
    X = np.random.default_rng(0).normal(size=(30, 4))
    X = np.maximum(X, 0.0)
    save_matrix_csv(raw / "Nested.csv", X)
    result = load_aedes_sites(root=tmp_path, prefer_raw=True)
    assert result.source == "raw"
    assert "2020_Nested" in result.sites
    assert result.sites["2020_Nested"].shape == (30, 4)


def test_empirical_board_on_committed_raw():
    board = build_empirical_board(root=REPO, window_size=13)
    if board["source"] != "raw":
        pytest.skip("no raw field CSVs")
    assert board["summary"]["n_series"] >= 3
    assert board["p1"]["status"] == "scaffold_only"
    assert board["p1"]["scored"] is False
    assert board["summary"]["p4_field_discharge"] is False
    for s in board["series"]:
        assert s["p3"]["rho"] == 0.20
        assert 0.0 <= s["p3"]["agree_vs_rho0"] <= 1.0
        assert s["p4"]["p4_status"] == "no_strong_anti_regime"
    # P3 usable on all three SJU series at protocol noise
    assert board["summary"]["p3_all_ok"] is True


def test_discover_committed_raw_still_finds_flat():
    found = discover_matrix_csvs(RAW, recursive=True)
    if not found:
        pytest.skip("no raw")
    assert any("SJU3" in k for k in found)
