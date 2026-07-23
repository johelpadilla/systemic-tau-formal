"""
03 — Falsifiability harness: load user CSV and run protocol defaults.

Usage:
  python notebooks/03_falsifiability_test.py path/to/data.csv

CSV: rows = time, columns = variables (N>=2). No header required;
if header present, numeric columns only are used.

Labels outcomes as [EMPÍRICO] only when data are real; else [OPERACIONAL].
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "python"))

from core import THETA_CHAOS, THETA_STABLE, accumulate_time, compute_taus  # noqa: E402


def load_csv(path: Path) -> np.ndarray:
    try:
        data = np.genfromtxt(path, delimiter=",", names=None)
    except Exception as exc:
        raise SystemExit(f"Failed to read {path}: {exc}") from exc
    X = np.asarray(data, dtype=float)
    if X.ndim == 1:
        raise SystemExit("Need at least 2 columns")
    # drop non-finite columns
    mask = np.isfinite(X).all(axis=0)
    X = X[:, mask]
    if X.shape[1] < 2:
        raise SystemExit("Need ≥2 finite numeric columns")
    return X


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
        # self-demo with random walk multivariate
        rng = np.random.default_rng(0)
        X = np.cumsum(rng.normal(size=(300, 4)), axis=0)
        print("=== 03_falsifiability_test (demo random walk) ===")
        print("Pass a CSV path to test your own data.\n")
        report(X, "demo_random_walk")
        return
    path = Path(argv[0])
    X = load_csv(path)
    print("=== 03_falsifiability_test ===\n")
    report(X, str(path))


if __name__ == "__main__":
    main()
