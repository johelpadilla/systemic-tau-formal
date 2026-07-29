"""P1-EEG scorer for CHB-MIT: clinical t_obs, lock integrity, lead in seconds.

Protocol: docs/P1_EEG_CHBMIT.md v1.0.0
"""

from __future__ import annotations

import hashlib
import json
import subprocess
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional, Sequence, Tuple

import numpy as np

from .chbmit_io import (
    AggregatedEEG,
    SeizureAnnotation,
    epoch_to_seconds,
    load_and_aggregate,
    parse_all_summaries,
    resolve_edf,
    seconds_to_epoch,
)
from .constants import THETA_CHAOS, THETA_STABLE
from .p1_endpoints import first_sustained_chaos_ascent
from .recd import accumulate_time
from .tau import compute_taus

PROTOCOL_ID = "P1_EEG_CHBMIT"
PROTOCOL_VERSION = "1.0.0"

# Frozen operational parameters — must match docs/P1_EEG_CHBMIT.md §2
FROZEN_PARAMS: Dict[str, Any] = {
    "protocol_id": PROTOCOL_ID,
    "protocol_version": PROTOCOL_VERSION,
    "fs_hz_expected": 256,
    "epoch_s": 1.0,
    "feature": "rms",
    "min_channels": 8,
    "window_size": 13,
    "stride": 1,
    "min_run": 4,
    "theta_chaos": THETA_CHAOS,
    "theta_stable": THETA_STABLE,
    "min_preictal_s": 300.0,
    "lead_lo_s": 30.0,
    "lead_hi_s": 300.0,
    "c1_horizon_s": 600.0,
    "c1_gap_from_seizure_s": 1800.0,
    "eval_crop": "preictal_to_onset",
    "t_star": "first_sustained_chaos_band_run",
}


def canonical_json_bytes(obj: Any) -> bytes:
    """Stable UTF-8 JSON for hashing (sorted keys, no insignificant whitespace)."""
    return json.dumps(obj, sort_keys=True, separators=(",", ":"), ensure_ascii=False).encode(
        "utf-8"
    )


def sha256_hex(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def hash_endpoints_document(endpoints: dict) -> str:
    """Hash endpoints without volatile fields if present."""
    # Hash full document as written — user must not edit after lock.
    return sha256_hex(canonical_json_bytes(endpoints))


def git_commit(repo_root: Optional[Path] = None) -> Optional[str]:
    try:
        cwd = str(repo_root) if repo_root else None
        out = subprocess.check_output(
            ["git", "rev-parse", "HEAD"],
            cwd=cwd,
            stderr=subprocess.DEVNULL,
            text=True,
        ).strip()
        return out or None
    except (subprocess.CalledProcessError, FileNotFoundError, OSError):
        return None


def build_candidates_document(
    annotations: Sequence[SeizureAnnotation],
    *,
    min_preictal_s: float = FROZEN_PARAMS["min_preictal_s"],
    pre_registered: bool = False,
) -> dict:
    """
    Build endpoints-shaped document from parsed summaries.

    Candidates with t_start_s < min_preictal_s are included but flagged
    ``eligible_for_score: false`` so the human can still audit them.
    """
    series = []
    for a in annotations:
        eligible = float(a.t_start_s) >= float(min_preictal_s)
        series.append(
            {
                "case": a.case,
                "record": a.record,
                "edf": a.edf_relpath,
                "seizure_index": a.seizure_index,
                "t_obs_s": float(a.t_start_s),
                "t_end_s": float(a.t_end_s),
                "t_obs_unit": "seconds_from_edf_start",
                "endpoint_definition": (
                    "CHB-MIT annotated seizure start (clinical) from chbNN-summary.txt"
                ),
                "source": "chbmit-summary",
                "pre_registered": bool(pre_registered) and eligible,
                "eligible_for_score": eligible,
                "ineligible_reason": None
                if eligible
                else f"t_obs_s={a.t_start_s} < min_preictal_s={min_preictal_s}",
                "file_duration_s": a.file_duration_s,
            }
        )
    return {
        "schema": "systemic-tau-formal/chbmit-endpoints/v1",
        "protocol_id": PROTOCOL_ID,
        "protocol_version": PROTOCOL_VERSION,
        "domain": "EEG_seizure_onset",
        "label": "[EMPÍRICO]",
        "dataset": {
            "name": "CHB-MIT Scalp EEG Database",
            "version": "1.0.0",
            "doi": "10.13026/C2K01R",
            "url": "https://physionet.org/content/chbmit/1.0.0/",
            "license": "ODC-By-1.0",
        },
        "aggregation": {
            "epoch_s": FROZEN_PARAMS["epoch_s"],
            "feature": FROZEN_PARAMS["feature"],
            "fs_hz_expected": FROZEN_PARAMS["fs_hz_expected"],
        },
        "lead_window_s": [FROZEN_PARAMS["lead_lo_s"], FROZEN_PARAMS["lead_hi_s"]],
        "min_preictal_s": FROZEN_PARAMS["min_preictal_s"],
        "note": (
            "Set pre_registered:true only after human review and BEFORE scoring. "
            "Then run lock. Not dengue P1 (weeks); lead horizon is seconds."
        ),
        "series": series,
        "frozen_params": dict(FROZEN_PARAMS),
    }


def make_protocol_lock(
    endpoints: dict,
    *,
    repo_root: Optional[Path] = None,
    extra: Optional[dict] = None,
) -> dict:
    """Create integrity lock for pre-registered endpoints + frozen params."""
    # Ensure frozen params in endpoints match library freeze
    doc_params = endpoints.get("frozen_params") or {}
    for k, v in FROZEN_PARAMS.items():
        if k in doc_params and doc_params[k] != v:
            raise ValueError(
                f"endpoints frozen_params[{k!r}]={doc_params[k]!r} != protocol {v!r}"
            )
    h = hash_endpoints_document(endpoints)
    lock = {
        "schema": "systemic-tau-formal/p1-eeg-protocol-lock/v1",
        "protocol_id": PROTOCOL_ID,
        "protocol_version": PROTOCOL_VERSION,
        "created_utc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "endpoints_sha256": h,
        "frozen_params": dict(FROZEN_PARAMS),
        "git_commit": git_commit(repo_root),
        "n_series": len(endpoints.get("series") or []),
        "n_pre_registered": sum(
            1 for s in endpoints.get("series") or [] if s.get("pre_registered")
        ),
        "note": "Score refuses if endpoints_sha256 mismatches. Do not edit endpoints after lock.",
    }
    if extra:
        lock["extra"] = extra
    return lock


def verify_lock(endpoints: dict, lock: dict) -> Tuple[bool, str]:
    if lock.get("protocol_version") != PROTOCOL_VERSION:
        return False, (
            f"lock protocol_version {lock.get('protocol_version')!r} != "
            f"code {PROTOCOL_VERSION!r}"
        )
    for k, v in FROZEN_PARAMS.items():
        if lock.get("frozen_params", {}).get(k) != v:
            return False, f"lock frozen_params mismatch at {k!r}"
    h = hash_endpoints_document(endpoints)
    if h != lock.get("endpoints_sha256"):
        return False, "endpoints_sha256 mismatch (file edited after lock?)"
    return True, "ok"


def _verdict_from_lead(
    t_star: Optional[int],
    t_obs_epoch: int,
    *,
    epoch_s: float,
    lead_lo_s: float,
    lead_hi_s: float,
) -> Dict[str, Any]:
    if t_star is None:
        return {
            "verdict": "no_signal",
            "pass": False,
            "lead_s": None,
            "t_star_epoch": None,
            "t_star_s": None,
            "reason": "no sustained chaos-band run in pre-ictal crop",
        }
    if t_star >= t_obs_epoch:
        return {
            "verdict": "post_onset_only",
            "pass": False,
            "lead_s": epoch_to_seconds(t_star - t_obs_epoch, epoch_s),
            "t_star_epoch": int(t_star),
            "t_star_s": epoch_to_seconds(t_star, epoch_s),
            "reason": "t* at/after clinical onset (detection, not early-warning)",
        }
    lead_epochs = t_obs_epoch - t_star
    lead_s = epoch_to_seconds(lead_epochs, epoch_s)
    ok = lead_lo_s <= lead_s <= lead_hi_s
    return {
        "verdict": "hit" if ok else "miss_lead",
        "pass": bool(ok),
        "lead_s": float(lead_s),
        "t_star_epoch": int(t_star),
        "t_star_s": epoch_to_seconds(t_star, epoch_s),
        "reason": "lead in window" if ok else "lead outside pre-registered window",
    }


def score_seizure_matrix(
    X: np.ndarray,
    t_obs_epoch: int,
    *,
    epoch_s: float = FROZEN_PARAMS["epoch_s"],
    window_size: int = FROZEN_PARAMS["window_size"],
    min_run: int = FROZEN_PARAMS["min_run"],
    lead_lo_s: float = FROZEN_PARAMS["lead_lo_s"],
    lead_hi_s: float = FROZEN_PARAMS["lead_hi_s"],
    min_channels: int = FROZEN_PARAMS["min_channels"],
    min_preictal_epochs: Optional[int] = None,
) -> Dict[str, Any]:
    """
    Score one pre-ictal matrix (rows 0..t_obs_epoch inclusive recommended).

    ``t_obs_epoch`` is the clinical onset index on the **same** epoch grid as X.
    """
    X = np.asarray(X, dtype=float)
    if X.ndim != 2:
        return {
            "scored": False,
            "verdict": "precondition_fail",
            "pass": False,
            "reason": "X must be 2-D",
        }
    T, N = X.shape
    if N < min_channels:
        return {
            "scored": False,
            "verdict": "precondition_fail",
            "pass": False,
            "reason": f"n_channels={N} < min_channels={min_channels}",
            "n_channels": N,
        }
    min_pe = min_preictal_epochs
    if min_pe is None:
        min_pe = int(np.ceil(FROZEN_PARAMS["min_preictal_s"] / epoch_s))
    if t_obs_epoch < min_pe:
        return {
            "scored": False,
            "verdict": "precondition_fail",
            "pass": False,
            "reason": f"t_obs_epoch={t_obs_epoch} < min_preictal_epochs={min_pe}",
            "t_obs_epoch": int(t_obs_epoch),
        }
    if t_obs_epoch >= T:
        return {
            "scored": False,
            "verdict": "precondition_fail",
            "pass": False,
            "reason": f"t_obs_epoch={t_obs_epoch} >= T={T}",
        }
    # Crop to pre-ictal inclusive (no ictal look-ahead for t*)
    Xc = X[: t_obs_epoch + 1, :]
    tg, _ = compute_taus(Xc, window_size=window_size)
    _, _, _, depth = accumulate_time(tg, window_size=window_size)
    t_star = first_sustained_chaos_ascent(tg, depth, min_run=min_run)
    base = _verdict_from_lead(
        t_star,
        t_obs_epoch,
        epoch_s=epoch_s,
        lead_lo_s=lead_lo_s,
        lead_hi_s=lead_hi_s,
    )
    base.update(
        {
            "scored": True,
            "t_obs_epoch": int(t_obs_epoch),
            "t_obs_s": epoch_to_seconds(t_obs_epoch, epoch_s),
            "lead_window_s": [lead_lo_s, lead_hi_s],
            "window_size": window_size,
            "n_channels": N,
            "n_epochs_preictal": int(Xc.shape[0]),
            "tau_finite_frac": float(np.mean(np.isfinite(tg))),
        }
    )
    return base


def score_endpoints_eeg(
    endpoints: dict,
    lock: dict,
    raw_root: Path,
    *,
    require_lock: bool = True,
    load_fn=None,
) -> Dict[str, Any]:
    """
    Score all pre-registered eligible seizures under lock.

    ``load_fn(edf_path) -> AggregatedEEG`` injectable for tests.
    """
    raw_root = Path(raw_root)
    if require_lock:
        ok, msg = verify_lock(endpoints, lock)
        if not ok:
            return {
                "protocol_id": PROTOCOL_ID,
                "protocol_version": PROTOCOL_VERSION,
                "scored": False,
                "verdict": "lock_fail",
                "reason": msg,
                "rows": [],
            }

    epoch_s = float(FROZEN_PARAMS["epoch_s"])
    rows: List[dict] = []
    for entry in endpoints.get("series") or []:
        row: Dict[str, Any] = {
            "case": entry.get("case"),
            "record": entry.get("record"),
            "edf": entry.get("edf"),
            "seizure_index": entry.get("seizure_index"),
            "pre_registered": bool(entry.get("pre_registered", False)),
            "eligible_for_score": bool(entry.get("eligible_for_score", True)),
        }
        if not entry.get("pre_registered", False):
            row.update(
                {
                    "scored": False,
                    "verdict": "lock_fail",
                    "reason": "pre_registered is false — refuse to score",
                }
            )
            rows.append(row)
            continue
        if entry.get("eligible_for_score") is False:
            row.update(
                {
                    "scored": False,
                    "verdict": "precondition_fail",
                    "reason": entry.get("ineligible_reason") or "not eligible",
                }
            )
            rows.append(row)
            continue
        t_obs_s = entry.get("t_obs_s")
        if t_obs_s is None:
            row.update(
                {
                    "scored": False,
                    "verdict": "precondition_fail",
                    "reason": "t_obs_s is null",
                }
            )
            rows.append(row)
            continue
        edf_rel = entry.get("edf")
        try:
            if load_fn is not None:
                agg: AggregatedEEG = load_fn(edf_rel)
            else:
                edf_path = resolve_edf(raw_root, str(edf_rel))
                agg = load_and_aggregate(
                    edf_path,
                    epoch_s=epoch_s,
                    feature=str(FROZEN_PARAMS["feature"]),
                    record=str(entry.get("record") or ""),
                )
        except Exception as e:
            row.update(
                {
                    "scored": False,
                    "verdict": "precondition_fail",
                    "reason": f"load error: {e}",
                }
            )
            rows.append(row)
            continue

        t_obs_epoch = seconds_to_epoch(float(t_obs_s), epoch_s)
        scored = score_seizure_matrix(
            agg.X,
            t_obs_epoch,
            epoch_s=epoch_s,
            window_size=int(FROZEN_PARAMS["window_size"]),
            min_run=int(FROZEN_PARAMS["min_run"]),
            lead_lo_s=float(FROZEN_PARAMS["lead_lo_s"]),
            lead_hi_s=float(FROZEN_PARAMS["lead_hi_s"]),
            min_channels=int(FROZEN_PARAMS["min_channels"]),
        )
        row.update(scored)
        row["channel_names"] = list(agg.channel_names)
        row["fs_hz"] = agg.fs_hz
        row["n_epochs_file"] = agg.n_epochs
        rows.append(row)

    n_scored = sum(1 for r in rows if r.get("scored"))
    n_hit = sum(1 for r in rows if r.get("verdict") == "hit")
    n_miss = sum(1 for r in rows if r.get("verdict") == "miss_lead")
    n_ns = sum(1 for r in rows if r.get("verdict") == "no_signal")
    n_pf = sum(1 for r in rows if r.get("verdict") == "precondition_fail")
    return {
        "protocol_id": PROTOCOL_ID,
        "protocol_version": PROTOCOL_VERSION,
        "label": "[EMPÍRICO]",
        "domain": "EEG_seizure_onset",
        "not_dengue_p1": True,
        "lock_ok": True,
        "endpoints_sha256": lock.get("endpoints_sha256"),
        "git_commit_lock": lock.get("git_commit"),
        "frozen_params": dict(FROZEN_PARAMS),
        "n_rows": len(rows),
        "n_scored": n_scored,
        "n_hit": n_hit,
        "n_miss_lead": n_miss,
        "n_no_signal": n_ns,
        "n_precondition_fail": n_pf,
        "hit_rate_among_scored": (n_hit / n_scored) if n_scored else None,
        "rows": rows,
        "note": (
            "P1-EEG clinical onset protocol. Lead horizon in seconds. "
            "Does not discharge Aedes/dengue P1 (4–6 weeks)."
        ),
    }


def score_c1_interictal_synthetic(
    X: np.ndarray,
    *,
    epoch_s: float = FROZEN_PARAMS["epoch_s"],
    window_size: int = FROZEN_PARAMS["window_size"],
    min_run: int = FROZEN_PARAMS["min_run"],
    min_channels: int = FROZEN_PARAMS["min_channels"],
) -> Dict[str, Any]:
    """
    C1 probe on a single interictal matrix: does t* fire at all?

    Full file-based C1 panel is ``scan_c1_interictal_file``.
    """
    X = np.asarray(X, dtype=float)
    if X.ndim != 2 or X.shape[1] < min_channels:
        return {
            "alert": False,
            "reason": "precondition_fail",
            "t_star_epoch": None,
        }
    tg, _ = compute_taus(X, window_size=window_size)
    _, _, _, depth = accumulate_time(tg, window_size=window_size)
    t_star = first_sustained_chaos_ascent(tg, depth, min_run=min_run)
    if t_star is None:
        return {
            "alert": False,
            "reason": "no_chaos_run",
            "t_star_epoch": None,
            "t_star_s": None,
        }
    return {
        "alert": True,
        "reason": "sustained_chaos_run",
        "t_star_epoch": int(t_star),
        "t_star_s": epoch_to_seconds(t_star, epoch_s),
    }


def scan_c1_interictal_file(
    X: np.ndarray,
    seizure_epochs: Sequence[Tuple[int, int]],
    *,
    epoch_s: float = FROZEN_PARAMS["epoch_s"],
    window_len_s: float = FROZEN_PARAMS["min_preictal_s"],
    gap_s: float = FROZEN_PARAMS["c1_gap_from_seizure_s"],
    horizon_s: float = FROZEN_PARAMS["c1_horizon_s"],
    stride_s: float = 60.0,
) -> Dict[str, Any]:
    """
    Slide interictal windows far from seizures; count alerts without seizure in horizon.

    ``seizure_epochs``: list of (start_epoch, end_epoch) inclusive ranges.
    """
    X = np.asarray(X, dtype=float)
    T = X.shape[0]
    w = int(round(window_len_s / epoch_s))
    gap = int(round(gap_s / epoch_s))
    hor = int(round(horizon_s / epoch_s))
    stride = max(1, int(round(stride_s / epoch_s)))

    def near_seizure(a: int, b: int) -> bool:
        for s0, s1 in seizure_epochs:
            # expand by gap
            lo, hi = s0 - gap, s1 + gap
            if not (b < lo or a > hi):
                return True
        return False

    def seizure_in_horizon(t_alert: int) -> bool:
        a, b = t_alert, t_alert + hor
        for s0, s1 in seizure_epochs:
            if s0 <= b and s1 >= a:
                return True
        return False

    windows = []
    t = 0
    while t + w <= T:
        if not near_seizure(t, t + w - 1):
            sub = X[t : t + w]
            probe = score_c1_interictal_synthetic(sub, epoch_s=epoch_s)
            alert = bool(probe.get("alert"))
            fp = False
            if alert:
                # map alert time into file coords
                local = probe.get("t_star_epoch")
                t_alert = t + int(local) if local is not None else t
                fp = not seizure_in_horizon(t_alert)
            windows.append(
                {
                    "start_epoch": t,
                    "end_epoch": t + w - 1,
                    "alert": alert,
                    "false_positive": fp if alert else False,
                    "probe": probe,
                }
            )
        t += stride

    n_alert = sum(1 for w_ in windows if w_["alert"])
    n_fp = sum(1 for w_ in windows if w_["false_positive"])
    hours = (len(windows) * window_len_s) / 3600.0 if windows else 0.0
    return {
        "protocol_id": PROTOCOL_ID,
        "protocol_version": PROTOCOL_VERSION,
        "track": "C1_interictal",
        "n_windows": len(windows),
        "n_alert": n_alert,
        "n_false_positive": n_fp,
        "fp_rate_per_window": (n_fp / len(windows)) if windows else None,
        "approx_window_hours": hours,
        "windows": windows,
        "note": "Interictal C1 stress; not P1 discharge.",
    }


def format_score_report(score: dict) -> str:
    lines = [
        f"# P1-EEG report ({score.get('protocol_id')} v{score.get('protocol_version')})",
        "",
        f"Domain: {score.get('domain')}  |  Label: {score.get('label')}",
        f"NOT dengue P1: {score.get('not_dengue_p1', True)}",
        f"Scored: {score.get('n_scored')}  hits: {score.get('n_hit')}  "
        f"miss_lead: {score.get('n_miss_lead')}  no_signal: {score.get('n_no_signal')}  "
        f"precondition_fail: {score.get('n_precondition_fail')}",
        f"Hit rate (among scored): {score.get('hit_rate_among_scored')}",
        f"Lock sha: {score.get('endpoints_sha256')}",
        "",
        "| record | seiz | t_obs_s | t_star_s | lead_s | verdict |",
        "|--------|------|---------|----------|--------|---------|",
    ]
    for r in score.get("rows") or []:
        lines.append(
            f"| {r.get('record')} | {r.get('seizure_index')} | {r.get('t_obs_s')} | "
            f"{r.get('t_star_s')} | {r.get('lead_s')} | {r.get('verdict')} |"
        )
    lines.append("")
    lines.append(score.get("note") or "")
    return "\n".join(lines)


def write_json(path: Path, obj: dict) -> None:
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def read_json(path: Path) -> dict:
    return json.loads(Path(path).read_text(encoding="utf-8"))
