"""P1-Aedes external t_obs: calendar map, propose honesty, lock/score integrity."""

from __future__ import annotations

import json
from pathlib import Path

import numpy as np
import pytest

from core.p1_aedes import (
    FROZEN_PARAMS,
    PROTOCOL_VERSION,
    choose_external_week,
    epiweek_to_row,
    load_calendar_map,
    make_protocol_lock,
    propose_endpoints_from_incidence,
    score_locked_endpoints,
    verify_lock,
)
from core.synthetic import independent_noise, synchronized_seasonal


ROOT = Path(__file__).resolve().parents[2]
CAL = ROOT / "data" / "aedes" / "raw" / "calendar_map.json"


def test_calendar_map_committed():
    assert CAL.is_file()
    cal = load_calendar_map(CAL)
    assert cal["protocol_version"] == PROTOCOL_VERSION
    assert "San_Juan_SJU1_Repto_Metropolitano_2018" in cal["series"]
    assert "San_Juan_SJU2_2018_epiweeks" in cal["series"]
    assert "San_Juan_SJU3_2018_12traps" in cal["series"]


def test_epiweek_to_row_sju1_sju2():
    cal = load_calendar_map(CAL)
    assert epiweek_to_row("San_Juan_SJU1_Repto_Metropolitano_2018", 4, cal) == 0
    assert epiweek_to_row("San_Juan_SJU1_Repto_Metropolitano_2018", 52, cal) == 48
    assert epiweek_to_row("San_Juan_SJU1_Repto_Metropolitano_2018", 3, cal) is None
    assert epiweek_to_row("San_Juan_SJU2_2018_epiweeks", 7, cal) == 0
    assert epiweek_to_row("San_Juan_SJU2_2018_epiweeks", 52, cal) == 45


def test_epiweek_to_row_sju3_exact_and_nearest():
    cal = load_calendar_map(CAL)
    assert epiweek_to_row("San_Juan_SJU3_2018_12traps", 9, cal) == 0
    assert epiweek_to_row("San_Juan_SJU3_2018_12traps", 45, cal) == 29
    # gap week 10 → nearest (9 or 11); abs distance equal picks min by sorted? 
    # our code uses min(rows, key=abs) — first min if tie depends on order
    r = epiweek_to_row("San_Juan_SJU3_2018_12traps", 10, cal, nearest=True)
    assert r in (0, 1)


def test_choose_external_week_peak_and_p75():
    inc = [
        {"year": 2018, "weekofyear": 20, "total_cases": 10},
        {"year": 2018, "weekofyear": 21, "total_cases": 50},
        {"year": 2018, "weekofyear": 22, "total_cases": 12},
        {"year": 2018, "weekofyear": 23, "total_cases": 11},
    ]
    peak = choose_external_week(inc, year=2018, method="peak_week")
    assert peak["ok"] and peak["weekofyear"] == 21
    p75 = choose_external_week(inc, year=2018, method="first_exceed_year_p75")
    assert p75["ok"]
    assert p75["weekofyear"] in (20, 21, 22, 23)


def test_choose_external_week_rejects_all_zero_year():
    """2018-like post-Zika low transmission: do not invent peak at week 1 of span."""
    inc = [{"year": 2018, "weekofyear": w, "total_cases": 0} for w in range(4, 53)]
    peak = choose_external_week(inc, year=2018, method="peak_week", week_min=4, week_max=52)
    assert peak["ok"] is False
    assert "no clinical event" in peak["reason"]
    p75 = choose_external_week(
        inc, year=2018, method="first_exceed_year_p75", week_min=4, week_max=52
    )
    assert p75["ok"] is False


def test_propose_sets_pre_registered_false(tmp_path: Path):
    csv_path = tmp_path / "inc.csv"
    csv_path.write_text(
        "year,weekofyear,total_cases\n"
        "2018,24,10\n2018,25,80\n2018,26,20\n",
        encoding="utf-8",
    )
    doc = propose_endpoints_from_incidence(
        csv_path, method="peak_week", root=ROOT, year=2018
    )
    assert doc["status"] == "candidates_not_pre_registered"
    assert all(s["pre_registered"] is False for s in doc["series"])
    # peak week 25 should map for SJU1 (row 25-4=21) and SJU2 (25-7=18)
    by_file = {s["file"]: s for s in doc["series"]}
    assert by_file["San_Juan_SJU1_Repto_Metropolitano_2018.csv"]["t_obs"] == 21
    assert by_file["San_Juan_SJU2_2018_epiweeks.csv"]["t_obs"] == 18


def test_lock_score_hit_synthetic():
    # Build synthetic multi-trap with early chaos so t* early, set t_obs = t*+5
    rng = np.random.default_rng(0)
    # synchronized early then noise chaos-like: use independent_noise (low tau)
    X = independent_noise(T=60, N=6, seed=1)
    # force score path: compute t* then set t_obs
    from core.p1_endpoints import score_p1_for_series

    probe = score_p1_for_series(X, t_obs=40, window_size=13)
    if probe.get("t_star") is None:
        pytest.skip("no chaos run in this seed")
    t_star = int(probe["t_star"])
    t_obs = t_star + 5  # inside 4–6 window

    endpoints = {
        "schema": "systemic-tau-formal/aedes-endpoints/v1",
        "protocol_version": PROTOCOL_VERSION,
        "series": [
            {
                "file": "demo_site.csv",
                "t_obs": t_obs,
                "pre_registered": True,
            }
        ],
    }
    lock = make_protocol_lock(endpoints, root=ROOT)
    ok, _ = verify_lock(endpoints, lock)
    assert ok
    result = score_locked_endpoints(
        endpoints, lock, root=ROOT, sites={"demo_site": X}
    )
    assert result["scored"] is True
    assert result["rows"][0]["verdict"] == "hit"
    assert result["n_hit"] == 1


def test_score_refuses_without_pre_registered():
    X = synchronized_seasonal(T=50, N=4, seed=2)
    endpoints = {
        "series": [{"file": "demo.csv", "t_obs": 30, "pre_registered": False}]
    }
    lock = make_protocol_lock(endpoints, root=ROOT)
    result = score_locked_endpoints(
        endpoints, lock, root=ROOT, sites={"demo": X}
    )
    assert result["scored"] is True  # lock ok
    assert result["rows"][0]["scored"] is False
    assert result["rows"][0]["verdict"] == "not_scored"


def test_score_refuses_tampered_endpoints():
    endpoints = {
        "series": [{"file": "demo.csv", "t_obs": 30, "pre_registered": True}]
    }
    lock = make_protocol_lock(endpoints, root=ROOT)
    endpoints["series"][0]["t_obs"] = 31  # tamper after lock
    result = score_locked_endpoints(
        endpoints, lock, root=ROOT, sites={"demo": independent_noise(T=40, N=3, seed=3)}
    )
    assert result["scored"] is False
    assert "mismatch" in result["reason"].lower() or "sha" in result["reason"].lower()


def test_frozen_params_stable():
    assert FROZEN_PARAMS["window_size"] == 13
    assert FROZEN_PARAMS["lead_lo"] == 4
    assert FROZEN_PARAMS["lead_hi"] == 6
    assert FROZEN_PARAMS["theta_chaos"] == 0.41
