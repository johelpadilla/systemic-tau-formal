#!/usr/bin/env python3
"""CLI for P1-EEG CHB-MIT protocol v1.1.0 (order polarity + log bandpower).

Subcommands: precondition | parse | lock | score | c1 | report | selftest

Design freeze: docs/P1_EEG_CHBMIT_v1.1.md
Does not touch v1.0.0 artifacts under data/chbmit/ (root).
Does not invent endpoints. Does not discharge dengue P1.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "python"))

V11 = ROOT / "data" / "chbmit" / "v1.1"


def _cmd_precondition(args: argparse.Namespace) -> int:
    from core.p1_eeg_v11 import run_precondition_diagnostic, write_json

    raw = Path(args.raw)
    cases = [args.case] if args.case else None
    diag = run_precondition_diagnostic(
        raw,
        cases=cases,
        max_windows=int(args.max_windows),
    )
    out = Path(args.out)
    write_json(out, diag)
    gates = diag.get("gates") or {}
    print(json.dumps({k: gates[k] for k in gates if k != "thresholds"}, indent=2))
    print(f"n_windows={diag.get('n_windows')}  file_errors={len(diag.get('file_errors') or [])}")
    print(f"JSON → {out}")
    if gates.get("all_pass"):
        print("PRECONDITION: PASS (G1–G4) — may proceed to parse/lock.")
        return 0
    print("PRECONDITION: FAIL — do NOT lock or score under v1.1.0.", file=sys.stderr)
    return 2


def _cmd_parse(args: argparse.Namespace) -> int:
    from core.chbmit_io import parse_all_summaries, parse_chbmit_summary
    from core.p1_eeg_v11 import build_candidates_document, write_json

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
    print("Next: review → endpoints.json with pre_registered true → lock (after precondition PASS)")
    return 0


def _cmd_lock(args: argparse.Namespace) -> int:
    from core.p1_eeg_v11 import make_protocol_lock, read_json, write_json

    ep = read_json(Path(args.endpoints))
    diag = read_json(Path(args.diagnostic))
    n_pr = sum(1 for s in ep.get("series") or [] if s.get("pre_registered"))
    if n_pr == 0 and not args.allow_empty:
        print(
            "ERROR: no series with pre_registered:true.",
            file=sys.stderr,
        )
        return 2
    try:
        lock = make_protocol_lock(ep, diag, repo_root=ROOT)
    except ValueError as e:
        print(f"ERROR: lock refused: {e}", file=sys.stderr)
        return 2
    out = Path(args.lock)
    write_json(out, lock)
    print(f"Locked {out}")
    print(f"  endpoints_sha256={lock['endpoints_sha256']}")
    print(f"  precondition_diagnostic_sha256={lock['precondition_diagnostic_sha256']}")
    print(f"  git_commit={lock.get('git_commit')}")
    print(f"  n_pre_registered={lock['n_pre_registered']}")
    print("Do not edit endpoints.json or diagnostic after this point.")
    return 0


def _cmd_score(args: argparse.Namespace) -> int:
    from core.p1_eeg_v11 import format_score_report, read_json, score_endpoints_eeg, write_json

    ep = read_json(Path(args.endpoints))
    lock = read_json(Path(args.lock))
    diag = None
    if args.diagnostic:
        diag = read_json(Path(args.diagnostic))
    raw = Path(args.raw)
    result = score_endpoints_eeg(
        ep,
        lock,
        raw,
        diagnostic=diag,
        require_lock=not args.skip_lock,
    )
    out = Path(args.out)
    write_json(out, result)
    print(format_score_report(result))
    print(f"\nJSON → {out}")
    if result.get("verdict") == "lock_fail":
        return 3
    return 0


def _cmd_c1(args: argparse.Namespace) -> int:
    from core.chbmit_io import load_and_aggregate, parse_all_summaries, resolve_edf, seconds_to_epoch
    from core.p1_eeg_v11 import FROZEN_PARAMS, scan_c1_interictal_file, write_json

    raw = Path(args.raw)
    cases = [args.case] if args.case else None
    ann = parse_all_summaries(raw, cases=cases)
    if not ann:
        print("No seizures parsed; need summaries under --raw", file=sys.stderr)
        return 1
    by_edf: dict = {}
    for a in ann:
        by_edf.setdefault(a.edf_relpath, []).append(a)

    epoch_s = float(FROZEN_PARAMS["epoch_s"])
    feature = str(FROZEN_PARAMS["feature"])
    all_panels = []
    for edf_rel, seizures in sorted(by_edf.items()):
        try:
            path = resolve_edf(raw, edf_rel)
            agg = load_and_aggregate(
                path,
                epoch_s=epoch_s,
                feature=feature,
                bandpower_eps=float(FROZEN_PARAMS["bandpower_eps"]),
            )
        except Exception as e:
            all_panels.append({"edf": edf_rel, "error": str(e)})
            continue
        se_epochs = [
            (
                seconds_to_epoch(s.t_start_s, epoch_s),
                seconds_to_epoch(s.t_end_s, epoch_s),
            )
            for s in seizures
        ]
        panel = scan_c1_interictal_file(agg.X, se_epochs, feature=feature)
        panel["edf"] = edf_rel
        panel["record"] = seizures[0].record
        all_panels.append(panel)

    n_fp = sum(p.get("n_false_positive") or 0 for p in all_panels if "n_false_positive" in p)
    n_win = sum(p.get("n_windows") or 0 for p in all_panels if "n_windows" in p)
    n_alert = sum(p.get("n_alert") or 0 for p in all_panels if "n_alert" in p)
    out_obj = {
        "track": "C1_interictal_CHB-MIT",
        "protocol_version": FROZEN_PARAMS["protocol_version"],
        "t_star_polarity": "order",
        "n_files": len(all_panels),
        "n_windows_total": n_win,
        "n_alert_total": n_alert,
        "n_false_positive_total": n_fp,
        "fp_rate_per_window": (n_fp / n_win) if n_win else None,
        "panels": all_panels,
        "note": "C1 stress order polarity; not P1 discharge.",
    }
    out = Path(args.out)
    write_json(out, out_obj)
    print(json.dumps({k: out_obj[k] for k in out_obj if k != "panels"}, indent=2))
    print(f"JSON → {out}")
    return 0


def _cmd_report(args: argparse.Namespace) -> int:
    from core.p1_eeg_v11 import format_score_report, read_json

    score = read_json(Path(args.score))
    print(format_score_report(score))
    if args.c1 and Path(args.c1).is_file():
        c1 = read_json(Path(args.c1))
        print("\n## C1 summary")
        print(
            f"windows={c1.get('n_windows_total')}  "
            f"alerts={c1.get('n_alert_total')}  "
            f"FP={c1.get('n_false_positive_total')}  "
            f"fp_rate={c1.get('fp_rate_per_window')}"
        )
    return 0


def _cmd_selftest(args: argparse.Namespace) -> int:
    from core.chbmit_io import AggregatedEEG, SeizureAnnotation, expand_bandpower_channel_names
    from core.p1_eeg_v11 import (
        FROZEN_PARAMS,
        build_candidates_document,
        format_score_report,
        make_protocol_lock,
        score_endpoints_eeg,
        verify_lock,
    )
    from core.synthetic import synchronized_seasonal
    import numpy as np

    N, T = 12, 400
    X = synchronized_seasonal(T=T, N=N, seed=0)
    ann = [
        SeizureAnnotation(
            case="synth",
            record="synth_01",
            edf_relpath="synth/synth_01.edf",
            seizure_index=0,
            t_start_s=700.0,
            t_end_s=730.0,
            file_duration_s=900.0,
        )
    ]
    doc = build_candidates_document(ann, pre_registered=True)
    for s in doc["series"]:
        s["pre_registered"] = True
    diag = {
        "protocol_version": FROZEN_PARAMS["protocol_version"],
        "protocol_id": FROZEN_PARAMS["protocol_id"],
        "gates": {
            "all_pass": True,
            "G1_ambient_chaos": True,
            "G2_order_exists": True,
            "G3_not_frozen_order": True,
            "G4_sample_size": True,
            "mean_chaos_occ": 0.4,
            "mean_order_occ": 0.2,
            "n_usable_windows": 10,
        },
        "windows": [],
    }
    lock = make_protocol_lock(doc, diag, repo_root=ROOT)
    ok, msg = verify_lock(doc, lock, diagnostic=diag)
    assert ok, msg

    def load_fn(_):
        return AggregatedEEG(
            X=X,
            channel_names=expand_bandpower_channel_names(
                [f"c{i}" for i in range(N)], collapse="chmean"
            ),
            epoch_s=2.0,
            fs_hz=256.0,
            feature="log_bandpower_4_chmean",
            n_raw_samples=T * 512,
            record="synth_01",
        )

    result = score_endpoints_eeg(doc, lock, Path("."), diagnostic=diag, load_fn=load_fn)
    print(format_score_report(result))
    print("selftest OK v", FROZEN_PARAMS["protocol_version"])
    return 0


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description="P1-EEG CHB-MIT protocol v1.1.0 CLI")
    sub = p.add_subparsers(dest="cmd", required=True)

    spc = sub.add_parser("precondition", help="Interictal occupancy gates G1–G4 (before lock)")
    spc.add_argument("--raw", default=str(ROOT / "data/chbmit/raw"))
    spc.add_argument("--case", default="chb01")
    spc.add_argument("--max-windows", type=int, default=42)
    spc.add_argument("--out", default=str(V11 / "precondition_diagnostic.json"))
    spc.set_defaults(func=_cmd_precondition)

    sp = sub.add_parser("parse", help="Parse summaries → candidate endpoints JSON")
    sp.add_argument("--raw", default=str(ROOT / "data/chbmit/raw"))
    sp.add_argument("--case", default="chb01")
    sp.add_argument("--summary", default=None)
    sp.add_argument("--out", default=str(V11 / "endpoints_candidates.json"))
    sp.set_defaults(func=_cmd_parse)

    sl = sub.add_parser("lock", help="Lock endpoints + diagnostic (gates must pass)")
    sl.add_argument("--endpoints", default=str(V11 / "endpoints.json"))
    sl.add_argument("--diagnostic", default=str(V11 / "precondition_diagnostic.json"))
    sl.add_argument("--lock", default=str(V11 / "protocol_lock.json"))
    sl.add_argument("--allow-empty", action="store_true")
    sl.set_defaults(func=_cmd_lock)

    ss = sub.add_parser("score", help="Score under lock")
    ss.add_argument("--endpoints", default=str(V11 / "endpoints.json"))
    ss.add_argument("--lock", default=str(V11 / "protocol_lock.json"))
    ss.add_argument("--diagnostic", default=str(V11 / "precondition_diagnostic.json"))
    ss.add_argument("--raw", default=str(ROOT / "data/chbmit/raw"))
    ss.add_argument("--out", default=str(V11 / "last_p1_eeg_score.json"))
    ss.add_argument("--skip-lock", action="store_true")
    ss.set_defaults(func=_cmd_score)

    sc = sub.add_parser("c1", help="Interictal false-alarm panel (order polarity)")
    sc.add_argument("--raw", default=str(ROOT / "data/chbmit/raw"))
    sc.add_argument("--case", default="chb01")
    sc.add_argument("--out", default=str(V11 / "last_c1_eeg.json"))
    sc.set_defaults(func=_cmd_c1)

    sr = sub.add_parser("report", help="Pretty-print score JSON")
    sr.add_argument("--score", default=str(V11 / "last_p1_eeg_score.json"))
    sr.add_argument("--c1", default=None)
    sr.set_defaults(func=_cmd_report)

    st = sub.add_parser("selftest", help="Synthetic lock+score path")
    st.set_defaults(func=_cmd_selftest)

    args = p.parse_args(argv)
    return int(args.func(args))


if __name__ == "__main__":
    raise SystemExit(main())
