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

from core import (  # noqa: E402
    THETA_CHAOS,
    THETA_STABLE,
    add_column_noise,
    compute_taus,
    independent_noise,
    synchronized_seasonal,
)

RHOS = (0.0, 0.05, 0.10, 0.20)


def regime_fracs(tg: np.ndarray) -> dict:
    valid = tg[~np.isnan(tg)]
    return {
        "mean_tau": float(valid.mean()),
        "stable": float(np.mean(valid >= THETA_STABLE)),
        "chaos": float(np.mean(np.abs(valid) < THETA_CHAOS)),
        "anti": float(np.mean(valid <= -THETA_CHAOS)),
    }


def agreement(tg0: np.ndarray, tgn: np.ndarray) -> float:
    def lab(t):
        if t >= THETA_STABLE:
            return 0
        if abs(t) < THETA_CHAOS:
            return 1
        if t <= -THETA_CHAOS:
            return 2
        return 3

    m = ~np.isnan(tg0) & ~np.isnan(tgn)
    if not np.any(m):
        return 0.0
    a = np.array([lab(x) for x in tg0[m]])
    b = np.array([lab(x) for x in tgn[m]])
    return float(np.mean(a == b))


def scan(name: str, X0: np.ndarray) -> None:
    tg0, _ = compute_taus(X0, window_size=13)
    print(f"\n--- {name} shape={X0.shape} ---")
    for rho in RHOS:
        Xn = add_column_noise(X0, rho=rho, seed=42)
        tgn, _ = compute_taus(Xn, window_size=13)
        fr = regime_fracs(tgn)
        agr = agreement(tg0, tgn) if rho > 0 else 1.0
        print(
            f"  ρ={rho:.2f}  meanτ={fr['mean_tau']:+.3f}  "
            f"stable={fr['stable']:.2%} chaos={fr['chaos']:.2%} "
            f"anti={fr['anti']:.2%}  agree@ρ0={agr:.2%}"
        )


def main():
    print("=== 04_p3_noise_robustness ===")
    print("[OPERACIONAL] Synthetic only — not dengue field validation.\n")
    scan("synchronized_seasonal", synchronized_seasonal(T=260, N=4, seed=0))
    scan("independent_noise", independent_noise(T=260, N=4, seed=2))
    print("\nP3 failure mode: systematic regime flips at ≤20% noise.")
    print("Report format: docs/EXPERIMENTAL_PROTOCOL.md §7")


if __name__ == "__main__":
    main()
