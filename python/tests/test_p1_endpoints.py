"""P1 endpoint scorer refuses to invent dates; only scores pre_registered t_obs."""

from __future__ import annotations

import numpy as np

from core.p1_endpoints import score_endpoints_file, score_p1_for_series
from core.synthetic import independent_noise


def test_score_p1_returns_lead_structure():
    X = independent_noise(T=80, N=4, seed=0)
    # pick a late t_obs so lead is defined if t* early
    out = score_p1_for_series(X, t_obs=40, window_size=13)
    assert out["scored"] is True
    assert "t_star" in out
    assert "lead" in out


def test_endpoints_null_not_scored():
    sites = {"San_Juan_SJU3_2018_12traps": independent_noise(T=40, N=4, seed=1)}
    ep = {
        "series": [
            {
                "file": "San_Juan_SJU3_2018_12traps.csv",
                "t_obs": None,
                "pre_registered": False,
            }
        ]
    }
    rows = score_endpoints_file(ep, sites)
    assert rows[0]["scored"] is False
    assert "null" in rows[0]["reason"].lower() or "t_obs" in rows[0]["reason"]


def test_endpoints_require_pre_registered_flag():
    sites = {"demo": independent_noise(T=50, N=3, seed=2)}
    ep = {
        "series": [
            {"file": "demo.csv", "t_obs": 30, "pre_registered": False},
        ]
    }
    rows = score_endpoints_file(ep, sites)
    assert rows[0]["scored"] is False
    assert "pre_registered" in rows[0]["reason"]
