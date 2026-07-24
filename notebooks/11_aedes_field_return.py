"""
11 — Field-derived first-return + exploratory multi-site leads (critical path).

Runs on all ``data/aedes/raw/**/*.csv`` matrices:

  · chaos-band runs of τₛ
  · coherence-run return map (phase proxy)
  · local-max first-return on τₛ
  · exploratory trap-surge lead times (NOT pre-registered P1)

Usage (repo root):
  python notebooks/11_aedes_field_return.py
  python notebooks/11_aedes_field_return.py --json data/aedes/raw/last_field_return.json
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "python"))

from core import load_aedes_sites  # noqa: E402
from core.field_return import multi_site_field_return  # noqa: E402
from core.p1_endpoints import exploratory_lead_scan  # noqa: E402


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--json", type=Path, default=None)
    ap.add_argument("--window", type=int, default=13)
    ap.add_argument("--min-run", type=int, default=4)
    args = ap.parse_args()

    loaded = load_aedes_sites(root=ROOT, prefer_raw=True)
    print("=== 11_aedes_field_return ===")
    print(f"{loaded.label} · source={loaded.source} · n={len(loaded.sites)}")

    if loaded.source != "raw":
        print("No raw field CSVs under data/aedes/raw/.")
        return 1

    fr = multi_site_field_return(
        loaded.sites, window_size=args.window, min_run=args.min_run
    )
    expl = exploratory_lead_scan(loaded.sites, window_size=args.window)

    print(f"\n--- field return ---\n  {fr['headline']}")
    for s in fr["sites"]:
        if not s.get("ok"):
            print(f"  · {s.get('name')}: FAIL {s.get('reason')}")
            continue
        cr = s["chaos_runs"]
        rp = s["coherence_run_return"]
        loc = s["local_max_return"]
        zc = s.get("zero_cross_return") or {}
        peak = loc["binned"].get("single_peak_like") or rp["binned"].get(
            "single_peak_like"
        )
        print(
            f"  · {s['name']}  shape={s['shape']}  primary={s.get('primary_section')}  "
            f"runs={cr['n']}  run_pairs={rp['n_pairs']}  "
            f"loc_pairs={loc['n_pairs']}  zc_pairs={zc.get('n_pairs', 0)}  "
            f"peak_like={peak}  "
            f"δ_proxy={s['length_ratio_proxy'].get('median_ratio')}"
        )
        if cr.get("note"):
            print(f"      note: {cr['note']}")
    pb = fr.get("pooled_binned") or {}
    print(
        f"  pooled pairs={fr['pooled_coherence_pairs']}  "
        f"pooled_peak_like={pb.get('single_peak_like')}"
    )

    print(f"\n--- exploratory leads (NOT P1 discharge) ---")
    print(f"  status={expl['status']}  scored={expl.get('n_scored')}")
    print(
        f"  lead median={expl.get('lead_median')}  "
        f"mean={expl.get('lead_mean')}  "
        f"range=[{expl.get('lead_min')},{expl.get('lead_max')}]  "
        f"in_4–6w={expl.get('n_in_protocol_window_4_6')}"
    )
    for r in expl.get("rows") or []:
        print(
            f"  · {r['series']} / {r['endpoint_method']}: "
            f"t_obs={r.get('endpoint', {}).get('t_obs')}  "
            f"t*={r.get('t_star')}  lead={r.get('lead')}  "
            f"in_window={r.get('pass_protocol_window')}"
        )

    print(f"\n{fr.get('honesty')}")
    print(expl.get("note"))

    if args.json is not None:
        payload = {
            "field_return": fr,
            "p1_exploratory": expl,
            "source": loaded.source,
            "label": loaded.label,
        }
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
        print(f"\nwrote {args.json}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
