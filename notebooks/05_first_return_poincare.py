"""
05 — First-return Poincaré skeleton on τₛ ([OPERACIONAL]).

Links Python extraction to Lean `FeigenbaumReduction` combinatorial types.
Does **not** claim continuum unimodality or Feigenbaum universality.
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "python"))

from core import accumulate_time, compute_taus, coupled_logistic  # noqa: E402
from core.first_return import (  # noqa: E402
    first_return_crossing,
    first_return_from_local_maxima,
)


def main():
    print("=== 05_first_return_poincare ===")
    print("[OPERACIONAL] Discrete section only — see docs/FEIGENBAUM_STATUS.md\n")

    X = coupled_logistic(T=600, N=4, r=3.85, seed=0)
    tg, _ = compute_taus(X, window_size=13)
    valid_idx = ~np.isnan(tg)
    series = tg[valid_idx]

    T_recd, _, g, depth = accumulate_time(tg, window_size=13)
    print(f"τₛ series length (valid) = {len(series)}")
    print(f"T_RECD end = {T_recd[-1]:.6f}  max_k = {int(depth.max())}")

    sec_max, pairs_max = first_return_from_local_maxima(series)
    sec_up, pairs_up = first_return_crossing(series, level=0.0, direction="up")

    print(f"\nLocal-max section: n={len(sec_max)}  return_pairs={len(pairs_max)}")
    if len(sec_max):
        print(f"  mean section τ = {sec_max.mean():.4f}  std = {sec_max.std():.4f}")
    if pairs_max:
        dx = np.array([b - a for a, b in pairs_max])
        print(f"  mean Δ return  = {dx.mean():.4f}")

    print(f"\nUp-crossing 0 section: n={len(sec_up)}  return_pairs={len(pairs_up)}")
    print("\nLean twins: sectionValues / returnPairs / FirstReturnData")
    print("Open: continuum extension + strong unimodality (named sorry goals).")


if __name__ == "__main__":
    main()
