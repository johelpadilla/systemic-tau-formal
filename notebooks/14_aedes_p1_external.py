#!/usr/bin/env python3
"""
14 — P1-Aedes external t_obs (protocol v1.0.0)

Multi-trap field τₛ scored only against pre-registered external endpoints
(clinical dengue / intervention). Never invents dates from trap totals.

Usage (repo root):
  python notebooks/14_aedes_p1_external.py calendar
  python notebooks/14_aedes_p1_external.py scaffold
  python notebooks/14_aedes_p1_external.py propose \\
      --incidence data/aedes/external/YOUR_2018_cases.csv --method peak_week
  # human review → endpoints.json with pre_registered:true
  python notebooks/14_aedes_p1_external.py lock --endpoints data/aedes/raw/endpoints.json
  python notebooks/14_aedes_p1_external.py score --endpoints data/aedes/raw/endpoints.json
  python notebooks/14_aedes_p1_external.py status
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "python"))

from core.p1_aedes import (  # noqa: E402
    PROTOCOL_ID,
    PROTOCOL_VERSION,
    default_paths,
    load_calendar_map,
    make_protocol_lock,
    propose_endpoints_from_incidence,
    scaffold_endpoints_null,
    score_locked_endpoints,
    write_json,
)


def cmd_calendar(_: argparse.Namespace) -> int:
    paths = default_paths(ROOT)
    cal = load_calendar_map(paths["calendar"])
    print(f"=== calendar_map · protocol {cal.get('protocol_version')} ===")
    for key, meta in cal.get("series", {}).items():
        print(f"  {key}")
        print(f"    file={meta.get('file')}  kind={meta.get('calendar_kind')}  T={meta.get('T')}")
        if meta.get("calendar_kind") == "thesis_epiweek":
            print(
                f"    epi weeks {meta.get('epiweek_start')}–{meta.get('epiweek_end')} "
                f"→ row = epiweek - {meta.get('epiweek_start')}"
            )
        else:
            rows = meta.get("rows") or []
            print(f"    ISO weeks {[r['iso_week'] for r in rows[:5]]}… (+{max(0,len(rows)-5)} more)")
    print(f"\npath: {paths['calendar']}")
    return 0


def cmd_scaffold(args: argparse.Namespace) -> int:
    paths = default_paths(ROOT)
    doc = scaffold_endpoints_null(ROOT)
    out = args.out or paths["endpoints_example"]
    write_json(out, doc)
    print(f"wrote scaffold → {out}")
    print("Fill t_obs from data/aedes/external/ incidence; set pre_registered true; then lock.")
    return 0


def cmd_propose(args: argparse.Namespace) -> int:
    paths = default_paths(ROOT)
    inc = Path(args.incidence)
    if not inc.is_file():
        print(f"incidence file not found: {inc}", file=sys.stderr)
        print(
            "Drop a weekly clinical CSV under data/aedes/external/ "
            "(see incidence.example.csv). 2018 San Juan cases are the known gap.",
            file=sys.stderr,
        )
        return 1
    doc = propose_endpoints_from_incidence(
        inc,
        method=args.method,
        root=ROOT,
        year=args.year,
        source_note=args.source_note or "",
    )
    out = args.out or paths["endpoints_candidates"]
    write_json(out, doc)
    print(f"=== propose · {PROTOCOL_ID} v{PROTOCOL_VERSION} · method={args.method} ===")
    for s in doc["series"]:
        print(
            f"  {s['file']}: t_obs={s.get('t_obs')} week={s.get('external_weekofyear')} "
            f"pre_reg={s.get('pre_registered')} · {s.get('reason')}"
        )
    print(f"\nwrote CANDIDATES → {out}")
    print("Review, promote to endpoints.json with pre_registered:true, then lock.")
    return 0


def cmd_lock(args: argparse.Namespace) -> int:
    paths = default_paths(ROOT)
    ep_path = Path(args.endpoints or paths["endpoints"])
    if not ep_path.is_file():
        print(f"endpoints not found: {ep_path}", file=sys.stderr)
        return 1
    endpoints = json.loads(ep_path.read_text(encoding="utf-8"))
    n_ready = sum(
        1
        for s in endpoints.get("series", [])
        if s.get("pre_registered") and s.get("t_obs") is not None
    )
    if n_ready == 0:
        print(
            "WARNING: no series with pre_registered:true and non-null t_obs. "
            "Lock will still freeze hash, but score will yield no hits.",
            file=sys.stderr,
        )
    lock = make_protocol_lock(endpoints, root=ROOT)
    out = args.out or paths["lock"]
    write_json(out, lock)
    print(f"=== lock · {PROTOCOL_ID} v{PROTOCOL_VERSION} ===")
    print(f"  endpoints_sha256={lock['endpoints_sha256']}")
    print(f"  git_commit={lock.get('git_commit')}")
    print(f"  n_pre_registered={lock['n_pre_registered']}")
    print(f"wrote {out}")
    return 0


def cmd_score(args: argparse.Namespace) -> int:
    paths = default_paths(ROOT)
    ep_path = Path(args.endpoints or paths["endpoints"])
    lock_path = Path(args.lock or paths["lock"])
    if not ep_path.is_file():
        print(f"endpoints not found: {ep_path}", file=sys.stderr)
        return 1
    if not lock_path.is_file():
        print(f"lock not found: {lock_path} — run lock first", file=sys.stderr)
        return 1
    endpoints = json.loads(ep_path.read_text(encoding="utf-8"))
    lock = json.loads(lock_path.read_text(encoding="utf-8"))
    result = score_locked_endpoints(endpoints, lock, root=ROOT)
    out = args.out or paths["last_score"]
    write_json(out, result)
    print(f"=== score · {PROTOCOL_ID} v{PROTOCOL_VERSION} ===")
    if not result.get("scored"):
        print(f"  REFUSED: {result.get('reason')}")
        return 2
    print(f"  n_scored={result['n_scored']}  n_hit={result['n_hit']}  hit_rate={result['hit_rate']}")
    for r in result["rows"]:
        print(
            f"  · {r.get('file')}: verdict={r.get('verdict')} "
            f"t_obs={r.get('t_obs')} t*={r.get('t_star')} lead={r.get('lead')} "
            f"{r.get('reason', '')}"
        )
    print(f"\n{result.get('honesty')}")
    print(f"wrote {out}")
    return 0


def cmd_status(_: argparse.Namespace) -> int:
    paths = default_paths(ROOT)
    print(f"=== P1-Aedes status · {PROTOCOL_ID} v{PROTOCOL_VERSION} ===")
    for name in ("calendar", "endpoints_example", "endpoints", "lock", "last_score", "external"):
        p = paths[name]
        flag = "yes" if p.exists() else "no"
        print(f"  {name:18} [{flag}] {p.relative_to(ROOT)}")
    ext = paths["external"]
    if ext.is_dir():
        csvs = sorted(ext.glob("*.csv"))
        real = [c for c in csvs if "example" not in c.name.lower()]
        print(f"  external CSVs: {len(csvs)} total, {len(real)} non-example")
        if not real:
            print(
                "  BLOCKER: no non-example incidence under data/aedes/external/ "
                "(2018 San Juan clinical weekly still missing)."
            )
    if paths["endpoints"].is_file():
        ep = json.loads(paths["endpoints"].read_text(encoding="utf-8"))
        n = sum(
            1
            for s in ep.get("series", [])
            if s.get("pre_registered") and s.get("t_obs") is not None
        )
        print(f"  endpoints pre_registered ready: {n}")
    else:
        print("  endpoints.json: absent (scaffold only)")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)

    sub.add_parser("calendar", help="print calendar_map summary")
    p_sc = sub.add_parser("scaffold", help="write null endpoints scaffold")
    p_sc.add_argument("--out", type=Path, default=None)

    p_pr = sub.add_parser("propose", help="map external incidence → endpoint candidates")
    p_pr.add_argument("--incidence", type=Path, required=True)
    p_pr.add_argument("--method", choices=("peak_week", "first_exceed_year_p75"), default="peak_week")
    p_pr.add_argument("--year", type=int, default=2018)
    p_pr.add_argument("--source-note", default="")
    p_pr.add_argument("--out", type=Path, default=None)

    p_lk = sub.add_parser("lock", help="freeze SHA-256 of endpoints + params")
    p_lk.add_argument("--endpoints", type=Path, default=None)
    p_lk.add_argument("--out", type=Path, default=None)

    p_sc = sub.add_parser("score", help="score if lock matches endpoints")
    p_sc.add_argument("--endpoints", type=Path, default=None)
    p_sc.add_argument("--lock", type=Path, default=None)
    p_sc.add_argument("--out", type=Path, default=None)

    sub.add_parser("status", help="paths + blocker summary")

    args = ap.parse_args()
    if args.cmd == "calendar":
        return cmd_calendar(args)
    if args.cmd == "scaffold":
        return cmd_scaffold(args)
    if args.cmd == "propose":
        return cmd_propose(args)
    if args.cmd == "lock":
        return cmd_lock(args)
    if args.cmd == "score":
        return cmd_score(args)
    if args.cmd == "status":
        return cmd_status(args)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
