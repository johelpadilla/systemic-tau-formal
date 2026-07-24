"""Field Aedes intake under data/aedes/raw/ ([EMPÍRICO] when present)."""

from __future__ import annotations

from pathlib import Path

import numpy as np
import pytest

from core import accumulate_time, compute_taus, load_aedes_sites, load_matrix_csv
from core.aedes_io import discover_matrix_csvs

REPO = Path(__file__).resolve().parents[2]
RAW = REPO / "data" / "aedes" / "raw"
SJU3 = RAW / "San_Juan_SJU3_2018_12traps.csv"


def test_sju3_matrix_shape_and_pipeline():
    if not SJU3.is_file():
        pytest.skip("SJU3 raw series not present")
    X = load_matrix_csv(SJU3)
    assert X.ndim == 2
    assert X.shape[0] >= 10
    assert X.shape[1] >= 2
    assert np.all(np.isfinite(X))
    assert np.all(X >= 0)
    tg, _ = compute_taus(X, window_size=13)
    T, _, _, depth = accumulate_time(tg, window_size=13)
    assert T.shape == (X.shape[0],)
    assert np.isfinite(T[-1])
    assert depth.shape == (X.shape[0],)


def test_load_aedes_sites_prefers_raw():
    result = load_aedes_sites(root=REPO, prefer_raw=True)
    assert result.sites
    if discover_matrix_csvs(RAW):
        assert result.source == "raw"
        assert result.label == "[EMPÍRICO]"
        assert "San_Juan_SJU3_2018_12traps" in result.sites or any(
            "SJU" in k.upper() or "sju" in k for k in result.sites
        )
    else:
        assert result.source in ("proxy", "generated")
        assert result.label == "[OPERACIONAL]"


def test_discover_raw_csvs_nonempty_when_committed():
    found = discover_matrix_csvs(RAW)
    if not SJU3.is_file():
        pytest.skip("no raw CSVs")
    assert "San_Juan_SJU3_2018_12traps" in found


@pytest.mark.parametrize(
    "name,min_t,min_n",
    [
        ("San_Juan_SJU3_2018_12traps.csv", 20, 10),
        ("San_Juan_SJU1_Repto_Metropolitano_2018.csv", 40, 15),
        ("San_Juan_SJU2_2018_epiweeks.csv", 40, 15),
    ],
)
def test_all_committed_raw_series_pipeline(name, min_t, min_n):
    path = RAW / name
    if not path.is_file():
        pytest.skip(f"missing {name}")
    X = load_matrix_csv(path)
    assert X.shape[0] >= min_t and X.shape[1] >= min_n
    assert np.all(np.isfinite(X))
    assert np.all(X >= 0)
    tg, _ = compute_taus(X, window_size=13)
    T, _, _, _ = accumulate_time(tg, window_size=13)
    assert np.isfinite(T[-1])


def test_load_aedes_sites_finds_three_clusters_when_present():
    result = load_aedes_sites(root=REPO, prefer_raw=True)
    if result.source != "raw":
        pytest.skip("raw empty")
    # Starter pack: SJU1 + SJU2 + SJU3
    stems = set(result.sites)
    if len(stems) >= 3:
        assert any("SJU1" in s or "SJU1" in s.upper() or "Repto" in s for s in stems)
        assert any("SJU2" in s for s in stems)
        assert any("SJU3" in s for s in stems)
