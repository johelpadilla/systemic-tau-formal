"""
04 — P3 noise robustness harness ([OPERACIONAL] on synthetic).

Runs protocol noise levels ρ ∈ {0, 0.05, 0.10, 0.20} without re-fitting thresholds.
See docs/FALSIFIABLE_PREDICTIONS.md (P3) and EXPERIMENTAL_PROTOCOL.md § Noise.
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "python"))

from core import independent_noise, p3_noise_scan, synchronized_seasonal  # noqa: E402

RHOS = (0.0, 0.05, 0.10, 0.20)


def scan(name: str, X0: np.ndarray) -> None:
    print(f"\n--- {name} shape={X0.shape} ---")
    for r in p3_noise_scan(X0, rhos=RHOS, window_size=13, seed=42):
        print(
            f"  ρ={r['rho']:.2f}  meanτ={r['mean_tau']:+.3f}  "
            f"stable={r['frac_stable']:.2%} chaos={r['frac_chaos']:.2%} "
            f"anti={r['frac_anti']:.2%}  agree@ρ0={r['agree_vs_rho0']:.2%}"
        )


def main():
    print("=== 04_p3_noise_robustness ===")
    print("[OPERACIONAL] Synthetic only — field scan: notebooks/08_aedes_p3_field.py\n")
    scan("synchronized_seasonal", synchronized_seasonal(T=260, N=4, seed=0))
    scan("independent_noise", independent_noise(T=260, N=4, seed=2))
    print("\nP3 failure mode: systematic regime flips at ≤20% noise.")
    print("Report format: docs/EXPERIMENTAL_PROTOCOL.md §7")


if __name__ == "__main__":
    main()
