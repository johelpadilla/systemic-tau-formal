"""
01 — Synthetic chaos: logistic maps + RECD appearance.

Runnable as a script (and convertible to .ipynb).
Labels: [OPERACIONAL] demo on synthetic dynamics; not a field claim.
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "python"))

from core import accumulate_time, compute_taus, gate_function  # noqa: E402


def coupled_logistic(T=800, N=4, r=3.85, eps=0.05, seed=0):
    rng = np.random.default_rng(seed)
    X = rng.uniform(0.1, 0.9, size=(T, N))
    for t in range(1, T):
        mean = X[t - 1].mean()
        for i in range(N):
            x = (1 - eps) * X[t - 1, i] + eps * mean
            X[t, i] = r * x * (1 - x)
    return X


def main():
    print("=== 01_synthetic_chaos ===")
    print("[OPERACIONAL] Coupled logistic maps; window=13\n")

    for r, name in [(3.30, "pre-chaos"), (3.85, "chaos")]:
        X = coupled_logistic(r=r, seed=42)
        tg, _ = compute_taus(X, window_size=13)
        valid = tg[~np.isnan(tg)]
        T, dtk, g, depth = accumulate_time(tg, window_size=13)
        frac_chaos = np.mean(np.abs(valid) < 0.41)
        print(f"r={r:.2f} ({name})")
        print(f"  mean τₛ     = {valid.mean():.4f}")
        print(f"  frac |τ|<0.41 = {frac_chaos:.3f}")
        print(f"  T_RECD end  = {T[-1]:.6f}")
        print(f"  max depth k = {int(depth.max())}")
        print(f"  mean g      = {np.nanmean(g):.4f}")
        print()

    # gate sanity
    assert gate_function(0.8) == 1.0
    print("Gate sanity OK. Run pytest in python/ for full tests.")


if __name__ == "__main__":
    main()
