"""
09 — P4 anti-sync clock structure on field Aedes matrices (data/aedes/raw/).

Operationalizes docs/FALSIFIABLE_PREDICTIONS.md §P4:

  - Feature vector: mean τₛ, pairwise trap corr, gate +1 fraction, …
  - Compare each field series to matched-(T,N) synthetic baselines
    (sync / anti / independent).
  - If the series never enters the strong anti premise (τₛ ≤ −0.41 mass),
    report ``no_strong_anti_regime`` — does **not** invent a P4 discharge.

Synthetic P4 still lives in ``python/tests/test_p4_anti_sync.py``.

Usage (repo root):
  python notebooks/09_aedes_p4_field.py
  python notebooks/09_aedes_p4_field.py --json data/aedes/raw/last_p4_field.json
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "python"))

from core import load_aedes_sites, p4_field_scan  # noqa: E402


def _slim(rep: dict) -> dict:
    """JSON-friendly subset (drop full baseline metric dumps unless useful)."""
    if rep.get("skipped"):
        return {"name": rep["name"], "skipped": True, "reason": rep.get("reason")}
    m = rep["metrics"]
    bsum = {
        k: {
            "mean_tau": v["mean_tau"],
            "mean_pair_corr": v["mean_pair_corr"],
            "frac_gate_plus": v["frac_gate_plus"],
        }
        for k, v in rep["baselines"].items()
    }
    return {
        "name": rep["name"],
        "skipped": False,
        "shape": [int(m["T"]), int(m["N"])],
        "mean_tau": m["mean_tau"],
        "mean_pair_corr": m["mean_pair_corr"],
        "frac_neg_pair_corr": m["frac_neg_pair_corr"],
        "frac_gate_plus": m["frac_gate_plus"],
        "frac_gate_minus": m["frac_gate_minus"],
        "frac_strong_anti": m["frac_strong_anti"],
        "frac_strong_stable": m["frac_strong_stable"],
        "std_inc": m["std_inc"],
        "nearest_baseline": rep["nearest_baseline"],
        "distances": rep["distances"],
        "premise_anti": rep["premise_anti"],
        "premise_stable": rep["premise_stable"],
        "p4_status": rep["p4_status"],
        "p4_note": rep["p4_note"],
        "baseline_summary": bsum,
    }


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--json", type=Path, default=None)
    ap.add_argument("--window", type=int, default=13)
    ap.add_argument("--seed", type=int, default=0)
    args = ap.parse_args()

    result = load_aedes_sites(root=ROOT, prefer_raw=True)
    print("=== 09_aedes_p4_field ===")
    print(f"{result.label} · source={result.source} · window={args.window}\n")
    if result.source != "raw":
        print("No raw CSVs — drop matrices under data/aedes/raw/ first.")
        return 1

    rows = p4_field_scan(
        result.sites, window_size=args.window, seed=args.seed
    )
    slim_rows = []
    for rep in rows:
        s = _slim(rep)
        slim_rows.append(s)
        if s.get("skipped"):
            print(f"--- {s['name']} SKIP {s.get('reason')} ---\n")
            continue
        print(f"--- {s['name']} shape={s['shape']} ---")
        print(
            f"  meanτ={s['mean_tau']:+.3f}  pair_r={s['mean_pair_corr']:+.3f}  "
            f"frac_neg_r={s['frac_neg_pair_corr']:.1%}  "
            f"g+={s['frac_gate_plus']:.1%} g−={s['frac_gate_minus']:.1%}"
        )
        print(
            f"  strong_anti={s['frac_strong_anti']:.1%}  "
            f"strong_stable={s['frac_strong_stable']:.1%}  "
            f"std_inc={s['std_inc']:.4g}"
        )
        print(
            f"  nearest_baseline={s['nearest_baseline']}  "
            f"distances={{{', '.join(f'{k}={v:.3f}' for k, v in s['distances'].items())}}}"
        )
        print(f"  P4 status: {s['p4_status']}")
        print(f"  note: {s['p4_note']}\n")

    n_anti = sum(1 for s in slim_rows if s.get("premise_anti"))
    n_ok = sum(1 for s in slim_rows if not s.get("skipped"))
    print(
        f"Summary: {n_ok} series scored; {n_anti} meet strong-anti premise. "
        "No premise → no field discharge of P4 (honest)."
    )

    payload = {
        "label_series": result.label,
        "prediction": "P4",
        "epistemic": (
            "[CONJETURA] operationalized. Field co-movement is EMPÍRICO; "
            "baselines are OPERACIONAL synthetic matched-(T,N)."
        ),
        "window_size": args.window,
        "seed": args.seed,
        "rows": slim_rows,
        "honesty": (
            "P4 requires a strong anti-sync regime (τₛ ≤ −0.41) to compare "
            "RECD interval structure vs stable sync. San Juan multi-trap matrices "
            "that are co-moving do not satisfy that premise; report structure "
            "vs baselines only. Synthetic anti vs sync remains in test_p4_anti_sync."
        ),
    }
    if args.json is not None:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
        print(f"wrote {args.json}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
