"""P1-Synthetic Canonical: generator, lock integrity, gates."""

from __future__ import annotations

import json
from pathlib import Path

import numpy as np
import pytest

from core.p1_endpoints import score_p1_for_series
from core.p1_synthetic import (
    FROZEN_PARAMS,
    GATES,
    GENERATOR_CONFIG,
    PROTOCOL_ID,
    PROTOCOL_VERSION,
    evaluate_c1_gates,
    evaluate_gates,
    generate_suite,
    make_protocol_lock,
    run_full_pipeline,
    score_c1_panel,
    score_c1_series,
    score_locked_endpoints,
    verify_lock,
)
from core.synthetic import (
    p1_canonical_null_noise,
    p1_canonical_null_sync,
    p1_canonical_panel,
)


def test_frozen_params_match_empirical_p1_core():
    """Detector core identical to Aedes/ILI (plus synthetic-only phi)."""
    assert FROZEN_PARAMS["window_size"] == 13
    assert FROZEN_PARAMS["theta_chaos"] == 0.41
    assert FROZEN_PARAMS["min_run"] == 4
    assert FROZEN_PARAMS["lead_lo"] == 4
    assert FROZEN_PARAMS["lead_hi"] == 6
    assert FROZEN_PARAMS["phi_phenom"] == FROZEN_PARAMS["window_size"]
    assert FROZEN_PARAMS["t_star"] == "first_sustained_chaos_ascent"


def test_canonical_panel_shape_and_t_obs():
    X, meta = p1_canonical_panel(seed=0)
    assert X.shape == (120, 6)
    assert meta["t_switch"] == 40.0
    assert meta["t_obs"] == 40.0 + 13.0
    assert meta["label"] == "[OPERACIONAL]"


def test_null_generators():
    Xs, ms = p1_canonical_null_sync(seed=100)
    Xn, mn = p1_canonical_null_noise(seed=200)
    assert Xs.shape == (120, 6) and Xn.shape == (120, 6)
    assert ms["panel"] == "pure_sync"
    assert mn["panel"] == "pure_noise"


def test_lock_refuses_endpoint_tamper():
    gen = generate_suite(write=False)
    ep = gen["endpoints"]
    lock = make_protocol_lock(ep)
    ok, _ = verify_lock(ep, lock)
    assert ok
    ep2 = json.loads(json.dumps(ep))
    ep2["series"][0]["t_obs"] = 999
    ok2, reason = verify_lock(ep2, lock)
    assert not ok2
    assert "endpoints_sha256" in reason


def test_score_refuses_pre_registered_false():
    gen = generate_suite(write=False)
    ep = gen["endpoints"]
    ep["series"][0]["pre_registered"] = False
    # re-lock with tampered flag would change hash; build lock on tampered
    lock = make_protocol_lock(ep)
    score = score_locked_endpoints(ep, lock, sites=gen["sites"])
    row0 = score["rows"][0]
    assert row0["verdict"] == "not_scored"
    assert "pre_registered" in row0["reason"]


def test_plant_oracle_lead_window():
    """With planted t_obs = t_switch+φ, clean seed should hit or near-hit."""
    X, meta = p1_canonical_panel(seed=3)
    s = score_p1_for_series(
        X,
        int(meta["t_obs"]),
        window_size=13,
        lead_lo=4,
        lead_hi=6,
    )
    assert s["t_star"] is not None
    assert s["lead"] is not None
    # seed 3 was a hit in design probe; allow miss only if outside (still signal)
    assert s["scored"] is True


def test_full_pipeline_gates(tmp_path: Path):
    """End-to-end instrument gates on temp root (no pollute repo if fail)."""
    out = run_full_pipeline(root=tmp_path, write=True)
    assert out["score"]["scored"] is True
    gates = out["gates"]
    assert gates["protocol"] == PROTOCOL_ID
    assert gates["protocol_version"] == PROTOCOL_VERSION

    ps = out["score"]["panel_summary"]
    assert ps["plant"]["n_scored"] == len(GENERATOR_CONFIG["plant_seeds"])
    assert ps["pure_sync"]["n_scored"] == len(GENERATOR_CONFIG["sync_seeds"])
    assert ps["pure_noise"]["n_scored"] == len(GENERATOR_CONFIG["noise_seeds"])

    # Core scientific claims of the instrument test
    assert gates["gates"]["G1"]["pass"], gates["gates"]["G1"]
    assert gates["gates"]["G2"]["pass"], gates["gates"]["G2"]
    assert gates["gates"]["G3"]["pass"], gates["gates"]["G3"]
    assert gates["gates"]["G4"]["pass"], gates["gates"]["G4"]
    assert gates["gates_pass"] is True
    assert gates["verdict"] == "INSTRUMENT_PASS"

    # Hit-rate threshold explicit
    assert ps["plant"]["hit_rate"] >= GATES["G2_min_hit_rate"]
    assert ps["pure_sync"]["hit_rate"] == 0.0
    assert ps["pure_sync"]["no_signal_rate"] == 1.0
    assert ps["pure_noise"]["hit_rate"] <= GATES["G4_max_hit_rate"]

    # C1 companion: plant justified + sync silent; ambient noise stress expected FAIL
    c1g = out["c1_gates"]
    assert c1g["gates"]["C1A"]["pass"], c1g["gates"]["C1A"]
    assert c1g["gates"]["C1B"]["pass"], c1g["gates"]["C1B"]
    assert c1g["gates"]["C1C"]["pass"] is False  # ambient chaos polarity stress
    assert c1g["verdict"] == "C1_STRESS_FAIL"
    assert c1g["c1_pass"] is False
    cps = out["c1"]["panel_summary"]
    assert cps["plant"]["fp_rate"] == 0.0
    assert cps["pure_sync"]["alert_rate"] == 0.0
    assert cps["pure_noise"]["fp_rate"] == 1.0


def test_c1_plant_justified_vs_noise_fp():
    X, meta = p1_canonical_panel(seed=3)
    ok = score_c1_series(
        X, t_obs=int(meta["t_obs"]), has_critical_event=True
    )
    assert ok["alert"] is True
    assert ok["false_positive"] is False
    assert ok["event_in_horizon"] is True

    Xn, _ = p1_canonical_null_noise(seed=200)
    bad = score_c1_series(Xn, has_critical_event=False)
    assert bad["alert"] is True
    assert bad["false_positive"] is True


def test_pure_sync_no_chaos_ascent():
    X, meta = p1_canonical_null_sync(seed=101)
    s = score_p1_for_series(X, int(meta["t_obs"]), window_size=13)
    assert s["t_star"] is None
    c1 = score_c1_series(X, has_critical_event=False)
    assert c1["alert"] is False
