#!/usr/bin/env python3
"""CLI for P1-EEG CHB-MIT protocol v1.0.0 (clinical seizure onset).

Subcommands: parse | lock | score | c1 | report | selftest

See docs/P1_EEG_CHBMIT.md. Does not invent endpoints. Does not discharge dengue P1.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "python"))


def _cmd_parse(args: argparse.Namespace) -> int:
    from core.chbmit_io import parse_all_summaries, parse_chbmit_summary
    from core.p1_eeg import build_candidates_document, write_json

    raw = Path(args.raw)
    cases = [args.case] if args.case else None
    if args.summary:
        ann = parse_chbmit_summary(Path(args.summary), case=args.case)
    else:
        ann = parse_all_summaries(raw, cases=cases)
    doc = build_candidates_document(ann, pre_registered=False)
    out = Path(args.out)
    write_json(out, doc)
    n_el = sum(1 for s in doc["series"] if s.get("eligible_for_score"))
    print(f"Wrote {out}  seizures={len(doc['series'])}  eligible>={doc['min_preictal_s']}s: {n_el}")
    print("Next: review → copy to endpoints.json → set pre_registered true → lock")
    return 0


def _cmd_lock(args: argparse.Namespace) -> int:
    from core.p1_eeg import make_protocol_lock, read_json, write_json

    ep = read_json(Path(args.endpoints))
    # Promote: if user forgot, require at least one pre_registered
    n_pr = sum(1 for s in ep.get("series") or [] if s.get("pre_registered"))
    if n_pr == 0 and not args.allow_empty:
        print(
            "ERROR: no series with pre_registered:true. "
            "Set flags after human review of clinical t_obs_s.",
            file=sys.stderr,
        )
        return 2
    lock = make_protocol_lock(ep, repo_root=ROOT)
    out = Path(args.lock)
    write_json(out, lock)
    print(f"Locked {out}")
    print(f"  endpoints_sha256={lock['endpoints_sha256']}")
    print(f"  git_commit={lock.get('git_commit')}")
    print(f"  n_pre_registered={lock['n_pre_registered']}")
    print("Do not edit endpoints.json after this point.")
    return 0


def _cmd_score(args: argparse.Namespace) -> int:
    from core.p1_eeg import format_score_report, read_json, score_endpoints_eeg, write_json

    ep = read_json(Path(args.endpoints))
    lock = read_json(Path(args.lock))
    raw = Path(args.raw)
    result = score_endpoints_eeg(ep, lock, raw, require_lock=not args.skip_lock)
    out = Path(args.out)
    write_json(out, result)
    print(format_score_report(result))
    print(f"\nJSON → {out}")
    if result.get("verdict") == "lock_fail":
        return 3
    return 0


def _cmd_c1(args: argparse.Namespace) -> int:
    from core.chbmit_io import load_and_aggregate, parse_all_summaries, resolve_edf, seconds_to_epoch
    from core.p1_eeg import FROZEN_PARAMS, scan_c1_interictal_file, write_json

    raw = Path(args.raw)
    cases = [args.case] if args.case else None
    ann = parse_all_summaries(raw, cases=cases)
    if not ann:
        print("No seizures parsed; need summaries under --raw", file=sys.stderr)
        return 1
    # Group by edf
    by_edf: dict = {}
    for a in ann:
        by_edf.setdefault(a.edf_relpath, []).append(a)

    all_panels = []
    for edf_rel, seizures in sorted(by_edf.items()):
        try:
            path = resolve_edf(raw, edf_rel)
            agg = load_and_aggregate(path, epoch_s=FROZEN_PARAMS["epoch_s"])
        except Exception as e:
            all_panels.append({"edf": edf_rel, "error": str(e)})
            continue
        epoch_s = FROZEN_PARAMS["epoch_s"]
        se_epochs = [
            (
                seconds_to_epoch(s.t_start_s, epoch_s),
                seconds_to_epoch(s.t_end_s, epoch_s),
            )
            for s in seizures
        ]
        panel = scan_c1_interictal_file(agg.X, se_epochs)
        panel["edf"] = edf_rel
        panel["record"] = seizures[0].record
        all_panels.append(panel)

    n_fp = sum(p.get("n_false_positive") or 0 for p in all_panels if "n_false_positive" in p)
    n_win = sum(p.get("n_windows") or 0 for p in all_panels if "n_windows" in p)
    out_obj = {
        "track": "C1_interictal_CHB-MIT",
        "protocol_version": FROZEN_PARAMS["protocol_version"],
        "n_files": len(all_panels),
        "n_windows_total": n_win,
        "n_false_positive_total": n_fp,
        "panels": all_panels,
        "note": "C1 stress only; not P1 discharge.",
    }
    out = Path(args.out)
    write_json(out, out_obj)
    print(json.dumps({k: out_obj[k] for k in out_obj if k != "panels"}, indent=2))
    print(f"JSON → {out}")
    return 0


def _cmd_report(args: argparse.Namespace) -> int:
    from core.p1_eeg import format_score_report, read_json

    score = read_json(Path(args.score))
    print(format_score_report(score))
    if args.c1 and Path(args.c1).is_file():
        c1 = read_json(Path(args.c1))
        print("\n## C1 summary")
        print(
            f"windows={c1.get('n_windows_total')}  "
            f"FP={c1.get('n_false_positive_total')}"
        )
    return 0


def _cmd_selftest(args: argparse.Namespace) -> int:
    """Run synthetic integrity path without PhysioNet download."""
    from core.p1_eeg import (
        FROZEN_PARAMS,
        build_candidates_document,
        format_score_report,
        hash_endpoints_document,
        make_protocol_lock,
        score_endpoints_eeg,
        score_seizure_matrix,
        verify_lock,
    )
    from core.chbmit_io import SeizureAnnotation, epoch_rms
    from core.synthetic import independent_noise, synchronized_seasonal
    import numpy as np

    # Synthetic pre-ictal: mostly sync then chaos-like noise before onset
    rng = np.random.default_rng(0)
    T, N = 600, 12
    X_sync = synchronized_seasonal(T=400, N=N, seed=1)
    X_chaos = independent_noise(T=200, N=N, seed=2)
    X = np.vstack([X_sync, X_chaos])
    t_obs = 550
    r = score_seizure_matrix(X, t_obs)
    print("synthetic score_seizure_matrix:", json.dumps({k: r[k] for k in r if k != "channel_names"}, default=str))

    # Lock integrity
    ann = [
        SeizureAnnotation(
            case="synth",
            record="synth_01",
            edf_relpath="synth/synth_01.edf",
            seizure_index=0,
            t_start_s=550.0,
            t_end_s=580.0,
            file_duration_s=600.0,
        )
    ]
    doc = build_candidates_document(ann, pre_registered=True)
    # force pre_registered on eligible
    for s in doc["series"]:
        s["pre_registered"] = True
    lock = make_protocol_lock(doc, repo_root=ROOT)
    ok, msg = verify_lock(doc, lock)
    assert ok, msg
    doc_tamper = json.loads(json.dumps(doc))
    doc_tamper["series"][0]["t_obs_s"] = 999.0
    ok2, msg2 = verify_lock(doc_tamper, lock)
    assert not ok2, "tamper should fail"
    print("lock integrity: OK (tamper detected:", msg2, ")")

    def load_fn(_rel):
        from core.chbmit_io import AggregatedEEG

        return AggregatedEEG(
            X=X,
            channel_names=[f"ch{i}" for i in range(N)],
            epoch_s=1.0,
            fs_hz=256.0,
            feature="rms",
            n_raw_samples=T * 256,
            record="synth_01",
        )

    result = score_endpoints_eeg(doc, lock, Path("."), load_fn=load_fn)
    print(format_score_report(result))
    print("selftest done. frozen:", FROZEN_PARAMS["protocol_version"])
    return 0


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description="P1-EEG CHB-MIT protocol CLI")
    sub = p.add_subparsers(dest="cmd", required=True)

    sp = sub.add_parser("parse", help="Parse summaries → candidate endpoints JSON")
    sp.add_argument("--raw", default=str(ROOT / "data/chbmit/raw"))
    sp.add_argument("--case", default=None, help="e.g. chb01")
    sp.add_argument("--summary", default=None, help="Single summary file path")
    sp.add_argument("--out", default=str(ROOT / "data/chbmit/endpoints_candidates.json"))
    sp.set_defaults(func=_cmd_parse)

    sl = sub.add_parser("lock", help="Hash endpoints + freeze protocol lock")
    sl.add_argument("--endpoints", required=True)
    sl.add_argument("--lock", default=str(ROOT / "data/chbmit/protocol_lock.json"))
    sl.add_argument("--allow-empty", action="store_true")
    sl.set_defaults(func=_cmd_lock)

    ss = sub.add_parser("score", help="Score under lock (requires EDFs unless injected)")
    ss.add_argument("--endpoints", required=True)
    ss.add_argument("--lock", required=True)
    ss.add_argument("--raw", default=str(ROOT / "data/chbmit/raw"))
    ss.add_argument("--out", default=str(ROOT / "data/chbmit/last_p1_eeg_score.json"))
    ss.add_argument("--skip-lock", action="store_true", help="Dangerous; tests only")
    ss.set_defaults(func=_cmd_score)

    sc = sub.add_parser("c1", help="Interictal false-alarm panel")
    sc.add_argument("--raw", default=str(ROOT / "data/chbmit/raw"))
    sc.add_argument("--case", default=None)
    sc.add_argument("--out", default=str(ROOT / "data/chbmit/last_c1_eeg.json"))
    sc.set_defaults(func=_cmd_c1)

    sr = sub.add_parser("report", help="Pretty-print score JSON")
    sr.add_argument("--score", required=True)
    sr.add_argument("--c1", default=None)
    sr.set_defaults(func=_cmd_report)

    st = sub.add_parser("selftest", help="Synthetic lock+score path (no download)")
    st.set_defaults(func=_cmd_selftest)

    args = p.parse_args(argv)
    return int(args.func(args))


if __name__ == "__main__":
    raise SystemExit(main())
