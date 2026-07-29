"""P1-EEG CHB-MIT protocol tests (synthetic; no PhysioNet download)."""

from __future__ import annotations

from pathlib import Path

import numpy as np
import pytest

from core.chbmit_io import (
    SeizureAnnotation,
    epoch_rms,
    filter_eeg_channels,
    is_eeg_channel,
    parse_chbmit_summary,
    seconds_to_epoch,
)
from core.p1_eeg import (
    FROZEN_PARAMS,
    PROTOCOL_VERSION,
    build_candidates_document,
    hash_endpoints_document,
    make_protocol_lock,
    score_c1_interictal_synthetic,
    score_endpoints_eeg,
    score_seizure_matrix,
    scan_c1_interictal_file,
    verify_lock,
)
from core.synthetic import independent_noise, synchronized_seasonal

FIXTURE_SUMMARY = (
    Path(__file__).resolve().parents[2]
    / "data"
    / "chbmit"
    / "fixtures"
    / "sample_summary.txt"
)


def test_is_eeg_channel_filters_dummy_and_ecg():
    assert is_eeg_channel("FP1-F7")
    assert is_eeg_channel("FZ-CZ")
    assert not is_eeg_channel("-")
    assert not is_eeg_channel("ECG")
    assert not is_eeg_channel("VNS")


def test_epoch_rms_shape_and_nonneg():
    rng = np.random.default_rng(0)
    fs = 256.0
    data = rng.normal(size=(10, int(fs * 5)))  # 5 s, 10 ch
    X = epoch_rms(data, fs_hz=fs, epoch_s=1.0)
    assert X.shape == (5, 10)
    assert np.all(X >= 0)


def test_filter_eeg_channels():
    data = np.ones((5, 100))
    names = ["FP1-F7", "-", "ECG", "F7-T7", "CZ-PZ"]
    out, kept = filter_eeg_channels(data, names)
    assert kept == ["FP1-F7", "F7-T7", "CZ-PZ"]
    assert out.shape[0] == 3


def test_parse_sample_summary():
    assert FIXTURE_SUMMARY.is_file()
    ann = parse_chbmit_summary(FIXTURE_SUMMARY, case="chb01")
    assert len(ann) == 3
    assert ann[0].record == "chb01_03"
    assert ann[0].t_start_s == 2996.0
    assert ann[1].record == "chb01_15"
    assert ann[1].t_start_s == 1732.0
    # short preictal seizure still parsed
    assert ann[2].t_start_s == 101.0
    assert ann[0].edf_relpath.endswith("chb01_03.edf")


def test_candidates_eligibility_min_preictal():
    ann = parse_chbmit_summary(FIXTURE_SUMMARY, case="chb01")
    doc = build_candidates_document(ann, pre_registered=False)
    by_rec = {s["record"]: s for s in doc["series"]}
    assert by_rec["chb01_03"]["eligible_for_score"] is True
    assert by_rec["chb01_16"]["eligible_for_score"] is False  # 101 < 300
    assert doc["protocol_version"] == PROTOCOL_VERSION


def test_lock_detects_tamper():
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
    lock = make_protocol_lock(doc)
    ok, _ = verify_lock(doc, lock)
    assert ok
    doc2 = dict(doc)
    doc2 = __import__("json").loads(__import__("json").dumps(doc))
    doc2["series"][0]["t_obs_s"] = 501.0
    ok2, msg = verify_lock(doc2, lock)
    assert not ok2
    assert "sha256" in msg.lower() or "mismatch" in msg.lower()


def test_refuse_score_without_pre_registered():
    ann = [
        SeizureAnnotation(
            case="x",
            record="r",
            edf_relpath="x/r.edf",
            seizure_index=0,
            t_start_s=400.0,
            t_end_s=420.0,
        )
    ]
    doc = build_candidates_document(ann, pre_registered=False)
    for s in doc["series"]:
        s["pre_registered"] = False
        s["eligible_for_score"] = True
    lock = make_protocol_lock(doc)
    # make_protocol_lock allows empty pre_reg; score must refuse rows
    from core.chbmit_io import AggregatedEEG

    X = independent_noise(T=500, N=12, seed=0)

    def load_fn(_):
        return AggregatedEEG(
            X=X,
            channel_names=[f"c{i}" for i in range(12)],
            epoch_s=1.0,
            fs_hz=256.0,
            feature="rms",
            n_raw_samples=500 * 256,
            record="r",
        )

    # Force lock to match (0 pre_registered)
    lock = make_protocol_lock(doc)
    out = score_endpoints_eeg(doc, lock, Path("."), load_fn=load_fn)
    assert out["rows"][0]["scored"] is False
    assert "pre_registered" in out["rows"][0]["reason"]


def test_score_seizure_matrix_precondition_channels():
    X = independent_noise(T=400, N=3, seed=0)
    r = score_seizure_matrix(X, t_obs_epoch=350)
    assert r["verdict"] == "precondition_fail"
    assert r["scored"] is False


def test_score_seizure_matrix_structure():
    N = 12
    X = np.vstack(
        [
            synchronized_seasonal(T=350, N=N, seed=3),
            independent_noise(T=150, N=N, seed=4),
        ]
    )
    t_obs = 480
    r = score_seizure_matrix(X, t_obs)
    assert r["scored"] is True
    assert r["verdict"] in {
        "hit",
        "miss_lead",
        "no_signal",
        "post_onset_only",
    }
    assert "lead_window_s" in r
    assert r["lead_window_s"] == [
        FROZEN_PARAMS["lead_lo_s"],
        FROZEN_PARAMS["lead_hi_s"],
    ]


def test_end_to_end_with_injected_loader():
    N, T = 12, 600
    X = np.vstack(
        [
            synchronized_seasonal(T=400, N=N, seed=5),
            independent_noise(T=200, N=N, seed=6),
        ]
    )
    ann = [
        SeizureAnnotation(
            case="synth",
            record="synth_01",
            edf_relpath="synth/synth_01.edf",
            seizure_index=0,
            t_start_s=550.0,
            t_end_s=580.0,
        )
    ]
    doc = build_candidates_document(ann, pre_registered=True)
    for s in doc["series"]:
        s["pre_registered"] = True
    lock = make_protocol_lock(doc)
    from core.chbmit_io import AggregatedEEG

    def load_fn(_):
        return AggregatedEEG(
            X=X,
            channel_names=[f"c{i}" for i in range(N)],
            epoch_s=1.0,
            fs_hz=256.0,
            feature="rms",
            n_raw_samples=T * 256,
            record="synth_01",
        )

    out = score_endpoints_eeg(doc, lock, Path("."), load_fn=load_fn)
    assert out["lock_ok"] is True
    assert out["not_dengue_p1"] is True
    assert out["n_rows"] == 1
    assert out["rows"][0]["scored"] is True


def test_lock_fail_on_param_mismatch():
    ann = [
        SeizureAnnotation(
            case="x",
            record="r",
            edf_relpath="x.edf",
            seizure_index=0,
            t_start_s=400.0,
            t_end_s=410.0,
        )
    ]
    doc = build_candidates_document(ann, pre_registered=True)
    for s in doc["series"]:
        s["pre_registered"] = True
    lock = make_protocol_lock(doc)
    lock["frozen_params"] = dict(lock["frozen_params"])
    lock["frozen_params"]["lead_lo_s"] = 1.0  # tamper lock
    out = score_endpoints_eeg(doc, lock, Path("."), require_lock=True)
    assert out.get("verdict") == "lock_fail" or out.get("scored") is False


def test_c1_interictal_scan_runs():
    # Unit path with shortened gap/window (protocol defaults need multi-hour files)
    short = independent_noise(T=900, N=12, seed=8)
    panel = scan_c1_interictal_file(
        short,
        [(450, 470)],
        window_len_s=100.0,
        gap_s=50.0,
        horizon_s=80.0,
        stride_s=50.0,
    )
    assert panel["n_windows"] >= 1
    assert "n_false_positive" in panel


def test_seconds_to_epoch():
    assert seconds_to_epoch(2996.0, 1.0) == 2996
    assert seconds_to_epoch(2996.9, 1.0) == 2996
    assert seconds_to_epoch(10.0, 2.0) == 5


def test_hash_stable():
    a = {"b": 1, "a": [2, 3]}
    assert hash_endpoints_document(a) == hash_endpoints_document({"a": [2, 3], "b": 1})
