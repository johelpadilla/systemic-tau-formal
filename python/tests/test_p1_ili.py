"""P1-ILI: FluSurv season chooser, lock integrity, score honesty."""

from __future__ import annotations

import json
from pathlib import Path

import numpy as np
import pytest

from core.ili_io import (
    build_hhs_season_matrix,
    candidate_season_epiweeks,
    season_label,
    season_of_epiweek,
)
from core.p1_ili import (
    EXCLUDED_SEASON_START_YEARS,
    FROZEN_PARAMS,
    PROTOCOL_VERSION,
    choose_external_season_week,
    make_protocol_lock,
    score_locked_endpoints,
    verify_lock,
)
from core.synthetic import independent_noise


ROOT = Path(__file__).resolve().parents[2]
FIELD = ROOT / "data" / "ili" / "field_hhs"
FLUSURV = ROOT / "data" / "ili" / "external" / "flusurv_network_all.csv"


def test_season_helpers():
    assert season_label(2017) == "2017-18"
    assert season_of_epiweek(201740) == "2017-18"
    assert season_of_epiweek(201805) == "2017-18"
    assert season_of_epiweek(201739) == "2016-17"
    ews = candidate_season_epiweeks(2017)
    assert ews[0] == 201740
    assert ews[-1] == 201820


def test_choose_external_season_peak_and_p75():
    inc = [
        {"season": "2017-18", "epiweek": 201750, "total_cases": 2.0},
        {"season": "2017-18", "epiweek": 201801, "total_cases": 10.2},
        {"season": "2017-18", "epiweek": 201805, "total_cases": 4.0},
        {"season": "2016-17", "epiweek": 201708, "total_cases": 5.4},
    ]
    peak = choose_external_season_week(inc, season="2017-18", method="peak_week")
    assert peak["ok"] and peak["epiweek"] == 201801
    p75 = choose_external_season_week(
        inc, season="2017-18", method="first_exceed_season_p75"
    )
    assert p75["ok"]
    assert p75["epiweek"] in (201750, 201801, 201805)


def test_choose_rejects_all_zero_season():
    inc = [
        {"season": "2018-19", "epiweek": 201840 + i, "total_cases": 0.0}
        for i in range(10)
    ]
    peak = choose_external_season_week(inc, season="2018-19", method="peak_week")
    assert peak["ok"] is False


def test_covid_seasons_excluded_a_priori():
    assert 2020 in EXCLUDED_SEASON_START_YEARS
    assert 2019 not in EXCLUDED_SEASON_START_YEARS


def test_build_hhs_matrix_complete_weeks():
    # synthetic fluview-like rows for one short season
    rows = []
    weeks = [201740, 201741, 201742] + [2017 * 100 + w for w in range(43, 53)] + [
        2018 * 100 + w for w in range(1, 21)
    ]
    for ew in weeks:
        for i in range(1, 11):
            rows.append({"region": f"hhs{i}", "epiweek": ew, "wili": 1.0 + 0.01 * i})
    X, ews, regs = build_hhs_season_matrix(rows, 2017)
    assert X.shape[1] == 10
    assert len(ews) == X.shape[0] >= 20
    assert regs[0] == "hhs1"


def test_lock_score_hit_synthetic():
    from core.p1_endpoints import score_p1_for_series

    X = independent_noise(T=60, N=10, seed=7)
    probe = score_p1_for_series(X, t_obs=40, window_size=13)
    if probe.get("t_star") is None:
        pytest.skip("no chaos run in this seed")
    t_obs = int(probe["t_star"]) + 5
    endpoints = {
        "schema": "systemic-tau-formal/ili-endpoints/v1",
        "protocol_version": PROTOCOL_VERSION,
        "series": [
            {
                "file": "demo_hhs.csv",
                "season": "demo",
                "t_obs": t_obs,
                "pre_registered": True,
            }
        ],
    }
    lock = make_protocol_lock(endpoints, root=ROOT)
    ok, _ = verify_lock(endpoints, lock)
    assert ok
    result = score_locked_endpoints(
        endpoints, lock, root=ROOT, sites={"demo_hhs": X}
    )
    assert result["scored"] is True
    assert result["rows"][0]["verdict"] == "hit"


def test_score_refuses_without_pre_registered():
    X = independent_noise(T=40, N=6, seed=2)
    endpoints = {
        "series": [{"file": "demo.csv", "t_obs": 30, "pre_registered": False}]
    }
    lock = make_protocol_lock(endpoints, root=ROOT)
    result = score_locked_endpoints(endpoints, lock, root=ROOT, sites={"demo": X})
    assert result["scored"] is True
    assert result["rows"][0]["verdict"] == "not_scored"


def test_score_refuses_tampered_endpoints():
    endpoints = {
        "series": [{"file": "demo.csv", "t_obs": 30, "pre_registered": True}]
    }
    lock = make_protocol_lock(endpoints, root=ROOT)
    endpoints["series"][0]["t_obs"] = 31
    result = score_locked_endpoints(
        endpoints, lock, root=ROOT, sites={"demo": independent_noise(T=40, N=3, seed=3)}
    )
    assert result["scored"] is False


def test_frozen_params_stable():
    assert FROZEN_PARAMS["window_size"] == 13
    assert FROZEN_PARAMS["lead_lo"] == 4
    assert FROZEN_PARAMS["lead_hi"] == 6
    assert FROZEN_PARAMS["theta_chaos"] == 0.41


def test_field_intake_present_and_score_reproducible():
    """If field data committed, peak_week lock must score 0 hits under v1.0.0."""
    ep = FIELD / "endpoints_hhs_yearly.json"
    lock = FIELD / "protocol_lock_hhs_yearly.json"
    if not ep.is_file() or not lock.is_file():
        pytest.skip("field ILI intake not present")
    endpoints = json.loads(ep.read_text(encoding="utf-8"))
    lock_doc = json.loads(lock.read_text(encoding="utf-8"))
    result = score_locked_endpoints(endpoints, lock_doc, root=ROOT)
    assert result["scored"] is True
    assert result["n_scored"] == 10
    assert result["n_hit"] == 0
    assert FLUSURV.is_file()
