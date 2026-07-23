"""
03 — Falsifiability harness: load user CSV and run protocol defaults.

Usage:
  python notebooks/03_falsifiability_test.py path/to/data.csv

CSV: rows = time, columns = variables (N>=2). Optional header row allowed.

Labels outcomes as [EMPÍRICO] only when data are real; else [OPERACIONAL].
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
    accumulate_time,
    compute_taus,
    load_matrix_csv,
)


def report(X: np.ndarray, label: str):
    tg, _ = compute_taus(X, window_size=13)
    T, dtk, g, depth = accumulate_time(tg, window_size=13)
    valid = tg[~np.isnan(tg)]
    frac_stable = np.mean(valid >= THETA_STABLE)
    frac_chaos = np.mean(np.abs(valid) < THETA_CHAOS)
    frac_anti = np.mean(valid <= -THETA_CHAOS)
    print(f"Dataset: {label}  shape={X.shape}")
    print(f"  mean τₛ={valid.mean():.4f}  std={valid.std():.4f}")
    print(f"  regimes: stable={frac_stable:.2%} chaos={frac_chaos:.2%} anti={frac_anti:.2%}")
    print(f"  T_RECD end={T[-1]:.6f}  max depth k={int(depth.max())}")
    print("  Predictions P1–P4: see docs/FALSIFIABLE_PREDICTIONS.md")
    print("  Report format: docs/EXPERIMENTAL_PROTOCOL.md §7")


def main(argv=None):
    argv = argv or sys.argv[1:]
    if not argv:
        demo = ROOT / "data" / "synthetic" / "regime_switch.csv"
        if demo.is_file():
            X = load_matrix_csv(demo)
            print("=== 03_falsifiability_test (demo fixture) ===")
            print(f"Default: {demo.relative_to(ROOT)}\n")
            report(X, str(demo.relative_to(ROOT)))
            return
        rng = np.random.default_rng(0)
        X = np.cumsum(rng.normal(size=(300, 4)), axis=0)
        print("=== 03_falsifiability_test (demo random walk) ===")
        print("Pass a CSV path to test your own data.\n")
        report(X, "demo_random_walk")
        return
    path = Path(argv[0])
    X = load_matrix_csv(path)
    print("=== 03_falsifiability_test ===\n")
    report(X, str(path))


if __name__ == "__main__":
    main()
