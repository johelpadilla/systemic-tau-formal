#!/usr/bin/env python3
"""
15 — P1-ILI external t_obs (protocol v1.0.0)

HHS1–10 ILINet %wILI scored only against pre-registered FluSurv
hospitalization peaks. National ILI is never used as t_obs.

Usage (repo root):
  python notebooks/15_ili_p1_external.py intake
  python notebooks/15_ili_p1_external.py propose [--method peak_week]
  python notebooks/15_ili_p1_external.py lock
  python notebooks/15_ili_p1_external.py score
  python notebooks/15_ili_p1_external.py status
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "python"))

from core.ili_io import (  # noqa: E402
    default_ili_paths,
    intake_seasons,
)
from core.p1_ili import (  # noqa: E402
    PROTOCOL_ID,
    PROTOCOL_VERSION,
    default_season_start_years_v1,
    load_calendar_map,
    make_protocol_lock,
    propose_endpoints_from_flusurv,
    score_locked_endpoints,
    write_json,
)


def cmd_intake(args: argparse.Namespace) -> int:
    years = default_season_start_years_v1()
    if args.years:
        years = [int(y) for y in args.years.split(",")]
    summary = intake_seasons(years, root=ROOT, download=not args.offline)
    print(f"=== intake · {PROTOCOL_ID} v{PROTOCOL_VERSION} ===")
    for lab, meta in summary.get("seasons", {}).items():
        print(f"  {lab}: ok={meta.get('ok')} shape={meta.get('shape')}")
    print(f"flusurv → {summary.get('flusurv_csv')}")
    print(f"calendar → {summary.get('calendar')}")
    return 0


def cmd_propose(args: argparse.Namespace) -> int:
    paths = default_ili_paths(ROOT)
    if not paths["flusurv_csv"].is_file():
        print(f"missing {paths['flusurv_csv']}; run intake first", file=sys.stderr)
        return 1
    if not paths["calendar"].is_file():
        print(f"missing {paths['calendar']}; run intake first", file=sys.stderr)
        return 1
    doc = propose_endpoints_from_flusurv(
        paths["flusurv_csv"],
        method=args.method,
        root=ROOT,
        source_note=args.source_note or "",
        pre_register=args.pre_register,
    )
    out = Path(args.out) if args.out else (
        paths["endpoints_p75"]
        if args.method == "first_exceed_season_p75"
        else paths["endpoints"]
    )
    write_json(out, doc)
    print(f"=== propose · method={args.method} · pre_reg={args.pre_register} ===")
    for s in doc["series"]:
        print(
            f"  {s.get('season')}: t_obs={s.get('t_obs')} "
            f"ew={s.get('external_epiweek')} pre_reg={s.get('pre_registered')} · {s.get('reason')}"
        )
    print(f"\nwrote → {out}")
    return 0


def cmd_lock(args: argparse.Namespace) -> int:
    paths = default_ili_paths(ROOT)
    ep_path = Path(args.endpoints) if args.endpoints else paths["endpoints"]
    if not ep_path.is_file():
        print(f"endpoints not found: {ep_path}", file=sys.stderr)
        return 1
    endpoints = json.loads(ep_path.read_text(encoding="utf-8"))
    lock = make_protocol_lock(
        endpoints,
        root=ROOT,
        extra={"design": endpoints.get("design"), "source_endpoints": str(ep_path)},
    )
    out = Path(args.out) if args.out else (
        paths["lock_p75"] if "p75" in ep_path.name else paths["lock"]
    )
    write_json(out, lock)
    print(f"=== lock · n_pre_registered={lock['n_pre_registered']} ===")
    print(f"endpoints_sha256={lock['endpoints_sha256'][:16]}…")
    print(f"wrote → {out}")
    return 0


def cmd_score(args: argparse.Namespace) -> int:
    paths = default_ili_paths(ROOT)
    if args.method == "first_exceed_season_p75":
        ep_path = Path(args.endpoints) if args.endpoints else paths["endpoints_p75"]
        lock_path = Path(args.lock) if args.lock else paths["lock_p75"]
        score_path = paths["last_score_p75"]
    else:
        ep_path = Path(args.endpoints) if args.endpoints else paths["endpoints"]
        lock_path = Path(args.lock) if args.lock else paths["lock"]
        score_path = paths["last_score"]
    if not ep_path.is_file() or not lock_path.is_file():
        print(f"need endpoints+lock: {ep_path} {lock_path}", file=sys.stderr)
        return 1
    endpoints = json.loads(ep_path.read_text(encoding="utf-8"))
    lock = json.loads(lock_path.read_text(encoding="utf-8"))
    result = score_locked_endpoints(endpoints, lock, root=ROOT)
    write_json(score_path, result)
    print(f"=== score · {PROTOCOL_ID} v{PROTOCOL_VERSION} ===")
    if not result.get("scored"):
        print(f"REFUSED: {result.get('reason')}")
        return 1
    print(f"n_scored={result['n_scored']} n_hit={result['n_hit']} hit_rate={result['hit_rate']}")
    for r in result["rows"]:
        print(
            f"  {r.get('season')}: {r.get('verdict')} "
            f"t*={r.get('t_star')} t_obs={r.get('t_obs')} lead={r.get('lead')}"
        )
    print(f"\nwrote → {score_path}")
    return 0


def cmd_status(_: argparse.Namespace) -> int:
    paths = default_ili_paths(ROOT)
    print(f"=== status · {PROTOCOL_ID} v{PROTOCOL_VERSION} ===")
    for key in (
        "calendar",
        "flusurv_csv",
        "endpoints",
        "lock",
        "last_score",
        "endpoints_p75",
        "lock_p75",
        "last_score_p75",
    ):
        p = paths[key]
        print(f"  {'OK' if p.is_file() else '--'} {p.relative_to(ROOT)}")
    if paths["calendar"].is_file():
        cal = load_calendar_map(paths["calendar"])
        print(f"  calendar series: {len(cal.get('series', {}))}")
    if paths["last_score"].is_file():
        sc = json.loads(paths["last_score"].read_text(encoding="utf-8"))
        print(
            f"  last peak_week: n_hit={sc.get('n_hit')}/{sc.get('n_scored')} "
            f"rate={sc.get('hit_rate')}"
        )
    if paths["last_score_p75"].is_file():
        sc = json.loads(paths["last_score_p75"].read_text(encoding="utf-8"))
        print(
            f"  last p75: n_hit={sc.get('n_hit')}/{sc.get('n_scored')} "
            f"rate={sc.get('hit_rate')}"
        )
    return 0


def main() -> int:
    p = argparse.ArgumentParser(description="P1-ILI external FluSurv protocol CLI")
    sub = p.add_subparsers(dest="cmd", required=True)

    s = sub.add_parser("intake", help="Download HHS + FluSurv and write field CSVs")
    s.add_argument("--years", help="comma-separated season start years (default 2010-2019)")
    s.add_argument("--offline", action="store_true", help="skip network; use existing files")
    s.set_defaults(func=cmd_intake)

    s = sub.add_parser("propose", help="Build endpoints from FluSurv + calendar")
    s.add_argument(
        "--method",
        default="peak_week",
        choices=["peak_week", "first_exceed_season_p75"],
    )
    s.add_argument("--pre-register", action="store_true", help="set pre_registered true")
    s.add_argument("--out", help="output endpoints path")
    s.add_argument("--source-note", default="")
    s.set_defaults(func=cmd_propose)

    s = sub.add_parser("lock", help="SHA-256 lock endpoints")
    s.add_argument("--endpoints", help="endpoints JSON path")
    s.add_argument("--out", help="lock output path")
    s.set_defaults(func=cmd_lock)

    s = sub.add_parser("score", help="Score locked endpoints")
    s.add_argument(
        "--method",
        default="peak_week",
        choices=["peak_week", "first_exceed_season_p75"],
    )
    s.add_argument("--endpoints")
    s.add_argument("--lock")
    s.set_defaults(func=cmd_score)

    s = sub.add_parser("status", help="Show field file presence + last scores")
    s.set_defaults(func=cmd_status)

    args = p.parse_args()
    return int(args.func(args))


if __name__ == "__main__":
    raise SystemExit(main())
