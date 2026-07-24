"""
10 — Unified empirical board (P1 / P3 / P4) for data/aedes/raw/.

One pass over all field matrices (including multi-year subfolders):

  P1  endpoints.json present? scored? (never invents t_obs)
  P3  regime agreement @ ρ=0.20 (protocol noise, no re-fit)
  P4  structure vs baselines; strong-anti premise check

Usage (repo root):
  python notebooks/10_aedes_empirical_board.py
  python notebooks/10_aedes_empirical_board.py --json data/aedes/raw/last_empirical_board.json
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "python"))

from core import build_empirical_board  # noqa: E402


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--json", type=Path, default=None)
    ap.add_argument("--window", type=int, default=13)
    args = ap.parse_args()

    board = build_empirical_board(root=ROOT, window_size=args.window)
    print("=== 10_aedes_empirical_board ===")
    print(f"{board['label_series']} · source={board['source']}")
    print(f"headline: {board['summary']['headline']}\n")

    if board["source"] != "raw":
        print("No raw field CSVs. Drop matrices under data/aedes/raw/ (or year subdirs).")
        return 1

    p1 = board["p1"]
    print(f"--- P1 ---")
    print(f"  status={p1['status']}  scored={p1['scored']}")
    print(f"  {p1['note']}")
    if p1.get("rows"):
        for r in p1["rows"]:
            print(f"  · {r.get('file')}: scored={r.get('scored')} {r.get('reason', r.get('pass'))}")

    print(f"\n--- series (P3 @ρ=0.20 · P4 structure) ---")
    for s in board["series"]:
        print(
            f"  {s['name']}  {s['shape']}  meanτ={s['mean_tau']:+.3f}  "
            f"chaos={s['frac_chaos']:.0%}"
        )
        print(
            f"    P3 agree@0.20={s['p3']['agree_vs_rho0']:.1%} → {s['p3']['status']}  |  "
            f"P4 {s['p4']['p4_status']}  pair_r={s['p4']['mean_pair_corr']:+.3f}  "
            f"nearest={s['p4']['nearest_baseline']}"
        )
    for sk in board["skipped"]:
        print(f"  SKIP {sk['name']}: {sk['reason']}")

    print(f"\n{board['honesty']}")

    if args.json is not None:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(board, indent=2) + "\n", encoding="utf-8")
        print(f"\nwrote {args.json}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
