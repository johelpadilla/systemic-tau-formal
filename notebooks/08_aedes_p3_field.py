"""
08 — P3 noise robustness on field Aedes matrices (data/aedes/raw/).

Same protocol as notebook 04 (ρ ∈ {0, 0.05, 0.10, 0.20}, no threshold re-fit),
but on **committed field series** → outcomes labeled [EMPÍRICO] for the series,
protocol noise is [OPERACIONAL] perturbation.

Does **not** claim clinical decision-system validation.

Usage (repo root):
  python notebooks/08_aedes_p3_field.py
  python notebooks/08_aedes_p3_field.py --json data/aedes/raw/last_p3_field.json
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "python"))

from core import load_aedes_sites, p3_noise_scan  # noqa: E402

RHOS = (0.0, 0.05, 0.10, 0.20)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--json", type=Path, default=None)
    ap.add_argument("--window", type=int, default=13)
    ap.add_argument("--seed", type=int, default=42)
    args = ap.parse_args()

    result = load_aedes_sites(root=ROOT, prefer_raw=True)
    print("=== 08_aedes_p3_field ===")
    print(f"{result.label} · source={result.source} · window={args.window}\n")
    if result.source != "raw":
        print("No raw CSVs — run import or drop matrices under data/aedes/raw/.")
        return 1

    all_rows = []
    for name, X in result.sites.items():
        print(f"--- {name} shape={X.shape} ---")
        rows = p3_noise_scan(X, rhos=RHOS, window_size=args.window, seed=args.seed)
        for r in rows:
            print(
                f"  ρ={r['rho']:.2f}  meanτ={r['mean_tau']:+.3f}  "
                f"stable={r['frac_stable']:.1%} chaos={r['frac_chaos']:.1%} "
                f"anti={r['frac_anti']:.1%}  agree@ρ0={r['agree_vs_rho0']:.1%}"
            )
            all_rows.append({"series": name, **r})
        # simple pass/fail hint at ρ=0.20 (not a formal gate)
        r20 = next(x for x in rows if x["rho"] == 0.20)
        status = "OK-ish" if r20["agree_vs_rho0"] >= 0.55 else "WATCH"
        print(
            f"  @ρ=0.20 agreement={r20['agree_vs_rho0']:.1%} → {status} "
            f"(P3 qualitative; short T is noisier)\n"
        )

    payload = {
        "label_series": result.label,
        "noise_protocol": "[OPERACIONAL] additive Gaussian column noise",
        "prediction": "P3",
        "window_size": args.window,
        "seed": args.seed,
        "rhos": list(RHOS),
        "rows": all_rows,
        "honesty": (
            "Field provenance is EMPÍRICO; noise is synthetic protocol. "
            "Not a claim that dengue programs can skip domain validation."
        ),
    }
    if args.json is not None:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
        print(f"wrote {args.json}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
