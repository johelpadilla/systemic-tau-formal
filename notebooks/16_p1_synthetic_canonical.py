#!/usr/bin/env python3
"""
16 — P1-Synthetic Canonical instrument validation (protocol v1.0.0)

Lab plant (order → chaos-like) + null controls scored with the same frozen
P1 detector as empirical tracks. Does not discharge field P1.

Usage (repo root):
  python notebooks/16_p1_synthetic_canonical.py generate
  python notebooks/16_p1_synthetic_canonical.py lock
  python notebooks/16_p1_synthetic_canonical.py score
  python notebooks/16_p1_synthetic_canonical.py run
  python notebooks/16_p1_synthetic_canonical.py status
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "python"))

from core.p1_synthetic import (  # noqa: E402
    PROTOCOL_ID,
    PROTOCOL_VERSION,
    default_syn_paths,
    evaluate_c1_gates,
    evaluate_gates,
    format_report,
    generate_suite,
    load_suite_sites,
    make_protocol_lock,
    run_full_pipeline,
    score_c1_panel,
    score_locked_endpoints,
    write_json,
)


def cmd_generate(args: argparse.Namespace) -> int:
    gen = generate_suite(root=ROOT, write=True)
    ep = gen["endpoints"]
    print(f"=== generate · {PROTOCOL_ID} v{PROTOCOL_VERSION} ===")
    print(f"series: {len(ep['series'])}")
    print(f"endpoints → {gen['paths']['endpoints']}")
    print(f"matrices → {gen['paths']['matrices']}")
    return 0


def cmd_lock(args: argparse.Namespace) -> int:
    paths = default_syn_paths(ROOT)
    if not paths["endpoints"].is_file():
        print("missing endpoints; run generate first", file=sys.stderr)
        return 1
    endpoints = json.loads(paths["endpoints"].read_text(encoding="utf-8"))
    lock = make_protocol_lock(endpoints, root=ROOT)
    write_json(paths["lock"], lock)
    print(f"=== lock · {PROTOCOL_ID} v{PROTOCOL_VERSION} ===")
    print(f"endpoints_sha256: {lock['endpoints_sha256'][:16]}…")
    print(f"lock_sha256:      {lock['lock_sha256'][:16]}…")
    print(f"→ {paths['lock']}")
    return 0


def cmd_score(args: argparse.Namespace) -> int:
    paths = default_syn_paths(ROOT)
    if not paths["endpoints"].is_file() or not paths["lock"].is_file():
        print("need endpoints + lock; run generate && lock (or run)", file=sys.stderr)
        return 1
    endpoints = json.loads(paths["endpoints"].read_text(encoding="utf-8"))
    lock = json.loads(paths["lock"].read_text(encoding="utf-8"))
    score = score_locked_endpoints(endpoints, lock, root=ROOT)
    gates = evaluate_gates(score)
    sites = load_suite_sites(ROOT)
    c1 = score_c1_panel(endpoints, sites)
    c1_gates = evaluate_c1_gates(c1)
    c1_out = {**c1, "gates": c1_gates}
    write_json(paths["score"], score)
    write_json(paths["gates"], gates)
    write_json(paths["c1"], c1_out)
    print(format_report(score, gates, c1_out, c1_gates))
    print(f"score → {paths['score']}")
    print(f"gates → {paths['gates']}")
    print(f"c1    → {paths['c1']}")
    # exit 0 if P1 instrument pass; C1 stress fail is reported but not exit 2
    # unless --strict-c1
    if args.strict_c1 and not c1_gates.get("c1_pass"):
        return 3
    return 0 if gates.get("gates_pass") else 2


def cmd_c1(args: argparse.Namespace) -> int:
    paths = default_syn_paths(ROOT)
    if not paths["endpoints"].is_file():
        print("missing endpoints; run generate first", file=sys.stderr)
        return 1
    endpoints = json.loads(paths["endpoints"].read_text(encoding="utf-8"))
    sites = load_suite_sites(ROOT)
    if not sites:
        gen = generate_suite(root=ROOT, write=False)
        sites = gen["sites"]
    c1 = score_c1_panel(endpoints, sites)
    c1_gates = evaluate_c1_gates(c1)
    c1_out = {**c1, "gates": c1_gates}
    write_json(paths["c1"], c1_out)
    print(f"=== C1 · {PROTOCOL_ID} v{PROTOCOL_VERSION} ===")
    for name, s in (c1.get("panel_summary") or {}).items():
        print(
            f"  {name}: n={s.get('n')} alert={s.get('n_alert')} fp={s.get('n_fp')} "
            f"alert_rate={s.get('alert_rate')} fp_rate={s.get('fp_rate')}"
        )
    print(f"C1: {c1_gates.get('verdict')} (c1_pass={c1_gates.get('c1_pass')})")
    for gid, g in (c1_gates.get("gates") or {}).items():
        print(f"  {gid}: {'PASS' if g.get('pass') else 'FAIL'} {g.get('detail')}")
    print(f"→ {paths['c1']}")
    return 0 if c1_gates.get("c1_pass") else 3


def cmd_run(args: argparse.Namespace) -> int:
    out = run_full_pipeline(root=ROOT, write=True)
    print(format_report(out["score"], out["gates"], out["c1"], out["c1_gates"]))
    print(f"lock  → {out['paths']['lock']}")
    print(f"score → {out['paths']['score']}")
    print(f"gates → {out['paths']['gates']}")
    print(f"c1    → {out['paths']['c1']}")
    if args.strict_c1 and not out["c1_gates"].get("c1_pass"):
        return 3
    return 0 if out["gates"].get("gates_pass") else 2


def cmd_status(args: argparse.Namespace) -> int:
    paths = default_syn_paths(ROOT)
    print(f"=== status · {PROTOCOL_ID} v{PROTOCOL_VERSION} ===")
    for k in ("endpoints", "lock", "score", "gates", "c1", "manifest"):
        p = paths[k]
        print(f"  {k}: {'OK' if p.is_file() else 'missing'}  {p}")
    if paths["gates"].is_file():
        g = json.loads(paths["gates"].read_text(encoding="utf-8"))
        print(f"  P1 verdict: {g.get('verdict')}  gates_pass={g.get('gates_pass')}")
    if paths["c1"].is_file():
        c = json.loads(paths["c1"].read_text(encoding="utf-8"))
        cg = c.get("gates") or {}
        print(f"  C1 verdict: {cg.get('verdict')}  c1_pass={cg.get('c1_pass')}")
        for name, st in (c.get("panel_summary") or {}).items():
            print(
                f"    {name}: alert_rate={st.get('alert_rate')} fp_rate={st.get('fp_rate')}"
            )
    if paths["score"].is_file():
        s = json.loads(paths["score"].read_text(encoding="utf-8"))
        ps = s.get("panel_summary") or {}
        for name, st in ps.items():
            print(
                f"  P1 {name}: hit_rate={st.get('hit_rate')} "
                f"n={st.get('n_scored')} lag_med={st.get('lag_median')}"
            )
    return 0


def main() -> int:
    p = argparse.ArgumentParser(description="P1-Synthetic Canonical v1.0.0")
    sub = p.add_subparsers(dest="cmd", required=True)
    sub.add_parser("generate", help="Generate plant + null matrices and endpoints")
    sub.add_parser("lock", help="Lock endpoints SHA + frozen params")
    ps = sub.add_parser("score", help="Score locked suite: P1 G1–G4 + C1")
    ps.add_argument(
        "--strict-c1",
        action="store_true",
        help="Exit 3 if C1 gates fail (default: only P1 instrument gates affect exit)",
    )
    sub.add_parser("c1", help="C1 false-early-warning panel only")
    pr = sub.add_parser("run", help="generate + lock + P1 score + C1")
    pr.add_argument("--strict-c1", action="store_true")
    sub.add_parser("status", help="Show artifact paths and last verdict")
    args = p.parse_args()
    return {
        "generate": cmd_generate,
        "lock": cmd_lock,
        "score": cmd_score,
        "c1": cmd_c1,
        "run": cmd_run,
        "status": cmd_status,
    }[args.cmd](args)


if __name__ == "__main__":
    raise SystemExit(main())
