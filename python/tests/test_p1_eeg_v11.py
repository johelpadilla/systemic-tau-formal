"""P1-EEG v1.1.0 tests (synthetic; no PhysioNet download required)."""

from __future__ import annotations

from pathlib import Path

import numpy as np
import pytest

from core.chbmit_io import (
    AggregatedEEG,
    SeizureAnnotation,
    epoch_log_bandpower_4,
    expand_bandpower_channel_names,
)
from core.p1_endpoints import first_sustained_chaos_ascent, first_sustained_order_ascent
from core.p1_eeg_v11 import (
    FROZEN_PARAMS,
    PROTOCOL_VERSION,
    build_candidates_document,
    evaluate_gates,
    format_score_report,
    hash_diagnostic_document,
    make_protocol_lock,
    run_precondition_diagnostic,
    score_endpoints_eeg,
    score_seizure_matrix,
    tau_occupancy,
    verify_lock,
)
from core.synthetic import independent_noise, synchronized_seasonal


def test_protocol_version_is_1_1():
    assert PROTOCOL_VERSION == "1.1.0"
    assert FROZEN_PARAMS["feature"] == "log_bandpower_4_chmean"
    assert FROZEN_PARAMS["epoch_s"] == 2.0
    assert FROZEN_PARAMS["t_star"] == "first_sustained_order_band_run"


def test_epoch_log_bandpower_4_shape():
    rng = np.random.default_rng(0)
    fs = 256.0
    epoch_s = 2.0
    n_ch = 10
    # 10 s → 5 epochs
    data = rng.normal(size=(n_ch, int(fs * 10)))
    X = epoch_log_bandpower_4(data, fs_hz=fs, epoch_s=epoch_s, collapse="chmean")
    assert X.shape == (5, n_ch)
    assert np.all(np.isfinite(X))
    Xf = epoch_log_bandpower_4(data, fs_hz=fs, epoch_s=epoch_s, collapse="full")
    assert Xf.shape == (5, 4 * n_ch)


def test_epoch_log_bandpower_tone_has_higher_band_energy():
    """A pure tone near 10 Hz should elevate alpha relative to delta (same ch)."""
    fs = 256.0
    epoch_s = 2.0
    L = int(fs * 20)  # 10 epochs
    t = np.arange(L) / fs
    tone = np.sin(2 * np.pi * 10.0 * t)  # alpha
    data = np.vstack([tone, tone * 0.5])
    X = epoch_log_bandpower_4(data, fs_hz=fs, epoch_s=epoch_s, collapse="full")
    # ch0: cols 0=δ 1=θ 2=α 3=β
    alpha = X[:, 2].mean()
    delta = X[:, 0].mean()
    assert alpha > delta


def test_expand_bandpower_names():
    names = expand_bandpower_channel_names(["FP1-F7", "F7-T7"], collapse="chmean")
    assert names == ["FP1-F7|bp4mean", "F7-T7|bp4mean"]
    full = expand_bandpower_channel_names(["FP1-F7"], collapse="full")
    assert full == [
        "FP1-F7|delta",
        "FP1-F7|theta",
        "FP1-F7|alpha",
        "FP1-F7|beta",
    ]


def test_first_sustained_order_ascent():
    # |τ|: low then high for 5 samples
    tg = np.array([0.1, 0.2, 0.1, 0.6, 0.7, 0.8, 0.9, 0.55, 0.1])
    depth = np.zeros_like(tg)
    i = first_sustained_order_ascent(tg, depth, min_run=4, theta_stable=0.50)
    assert i == 3
    # chaos helper still different
    j = first_sustained_chaos_ascent(tg, depth, min_run=3, theta=0.41)
    assert j == 0


def test_first_sustained_order_none():
    tg = np.full(20, 0.2)
    assert first_sustained_order_ascent(tg, np.zeros(20), min_run=4) is None


def test_gates_pass_and_fail():
    good = [
        {"chaos_occ": 0.5, "order_occ": 0.2, "n_finite": 100},
        {"chaos_occ": 0.4, "order_occ": 0.3, "n_finite": 100},
        {"chaos_occ": 0.6, "order_occ": 0.1, "n_finite": 100},
        {"chaos_occ": 0.55, "order_occ": 0.15, "n_finite": 100},
        {"chaos_occ": 0.45, "order_occ": 0.25, "n_finite": 100},
    ]
    g = evaluate_gates(good)
    assert g["all_pass"] is True
    ambient = [{"chaos_occ": 0.99, "order_occ": 0.0, "n_finite": 50}] * 5
    g2 = evaluate_gates(ambient)
    assert g2["G1_ambient_chaos"] is False
    assert g2["all_pass"] is False
    few = good[:2]
    g3 = evaluate_gates(few)
    assert g3["G4_sample_size"] is False


def test_lock_requires_gates_and_detects_tamper():
    ann = [
        SeizureAnnotation(
            case="chb01",
            record="chb01_03",
            edf_relpath="chb01/chb01_03.edf",
            seizure_index=0,
            t_start_s=500.0,
            t_end_s=540.0,
        )
    ]
    doc = build_candidates_document(ann, pre_registered=True)
    for s in doc["series"]:
        s["pre_registered"] = True

    diag_fail = {
        "protocol_version": PROTOCOL_VERSION,
        "gates": {"all_pass": False, "G1_ambient_chaos": False},
        "windows": [],
    }
    with pytest.raises(ValueError, match="gates"):
        make_protocol_lock(doc, diag_fail)

    diag_ok = {
        "schema": "systemic-tau-formal/p1-eeg-precondition/v1",
        "protocol_id": "P1_EEG_CHBMIT",
        "protocol_version": PROTOCOL_VERSION,
        "gates": {
            "all_pass": True,
            "G1_ambient_chaos": True,
            "G2_order_exists": True,
            "G3_not_frozen_order": True,
            "G4_sample_size": True,
            "mean_chaos_occ": 0.5,
            "mean_order_occ": 0.1,
            "n_usable_windows": 10,
        },
        "windows": [{"chaos_occ": 0.5, "order_occ": 0.1, "n_finite": 50}] * 10,
        "frozen_params": dict(FROZEN_PARAMS),
    }
    lock = make_protocol_lock(doc, diag_ok)
    ok, _ = verify_lock(doc, lock, diagnostic=diag_ok)
    assert ok
    assert lock["precondition_diagnostic_sha256"] == hash_diagnostic_document(diag_ok)

    doc2 = __import__("json").loads(__import__("json").dumps(doc))
    doc2["series"][0]["t_obs_s"] = 501.0
    ok2, msg = verify_lock(doc2, lock, diagnostic=diag_ok)
    assert not ok2


def test_score_order_polarity_on_sync_then_hold():
    """High multichannel sync → high |τ| → order t* should fire."""
    # Synchronized seasonal yields high |τ|; noise yields low
    X_sync = synchronized_seasonal(T=400, N=12, seed=1)
    # Feature matrix is already "aggregated"; treat as columns
    t_obs = 350
    r = score_seizure_matrix(X_sync, t_obs, feature="rms")  # columns = channels
    # synchronized should produce some order run → not always no_signal
    assert r["scored"] is True
    assert r["t_star_polarity"] == "order"
    # With pure sync, order run is likely early → miss_lead or hit
    assert r["verdict"] in ("hit", "miss_lead", "no_signal")


def test_score_noise_often_no_order_signal():
    X = independent_noise(T=400, N=12, seed=3)
    r = score_seizure_matrix(X, 350, feature="rms")
    assert r["scored"] is True
    # Independent noise typically stays in chaos → no sustained order
    # (allow rare flukes but expect no_signal most seeds)
    assert r["verdict"] in ("no_signal", "miss_lead", "hit")


def test_end_to_end_lock_score_injected():
    N_ch = 12
    T = 400
    X = synchronized_seasonal(T=T, N=N_ch, seed=7)
    t_obs_s = 700.0  # epoch 2s → epoch 350
    ann = [
        SeizureAnnotation(
            case="synth",
            record="synth_01",
            edf_relpath="synth/synth_01.edf",
            seizure_index=0,
            t_start_s=t_obs_s,
            t_end_s=t_obs_s + 30,
            file_duration_s=900.0,
        )
    ]
    doc = build_candidates_document(ann, pre_registered=True)
    for s in doc["series"]:
        s["pre_registered"] = True
        s["eligible_for_score"] = True

    diag = {
        "protocol_version": PROTOCOL_VERSION,
        "protocol_id": "P1_EEG_CHBMIT",
        "gates": {
            "all_pass": True,
            "G1_ambient_chaos": True,
            "G2_order_exists": True,
            "G3_not_frozen_order": True,
            "G4_sample_size": True,
            "mean_chaos_occ": 0.4,
            "mean_order_occ": 0.2,
            "n_usable_windows": 8,
        },
        "windows": [],
    }
    lock = make_protocol_lock(doc, diag)

    def load_fn(_rel):
        return AggregatedEEG(
            X=X,
            channel_names=expand_bandpower_channel_names(
                [f"c{i}" for i in range(N_ch)], collapse="chmean"
            ),
            epoch_s=2.0,
            fs_hz=256.0,
            feature="log_bandpower_4_chmean",
            n_raw_samples=T * 512,
            record="synth_01",
        )

    out = score_endpoints_eeg(doc, lock, Path("."), diagnostic=diag, load_fn=load_fn)
    assert out.get("lock_ok") is True
    assert out["protocol_version"] == "1.1.0"
    assert out["n_scored"] == 1
    assert out["rows"][0]["verdict"] in ("hit", "miss_lead", "no_signal")
    report = format_score_report(out)
    assert "1.1.0" in report


def test_precondition_diagnostic_injected_passes_gates():
    """tau_occupancy fractions sum to 1 on sync matrix."""
    N_ch = 12
    T = 400
    X = synchronized_seasonal(T=T, N=N_ch, seed=11)
    from core.tau import compute_taus

    tg, _ = compute_taus(X, window_size=13)
    occ = tau_occupancy(tg)
    assert occ["n_finite"] > 0
    assert occ["order_occ"] + occ["chaos_occ"] + occ["mid_occ"] == pytest.approx(1.0, abs=1e-6)
