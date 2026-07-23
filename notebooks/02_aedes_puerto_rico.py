"""
02 — Aedes Puerto Rico schema demo (synthetic stand-in until public data lands).

[OPERACIONAL] Not an empirical claim about Caño Martín Peña / Candelaria.
When real trap CSVs are licensed into data/aedes/, swap the loader only.
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "python"))

from core import accumulate_time, compute_taus  # noqa: E402


def synthetic_two_sites(T=200, seed=1):
    """Two sites × 3 traps each, weakly coupled seasonal drivers."""
    rng = np.random.default_rng(seed)
    t = np.arange(T)
    seasonal = 1.2 + np.sin(2 * np.pi * t / 52)
    site_a = np.column_stack(
        [seasonal + 0.3 * rng.normal(size=T) for _ in range(3)]
    )
    # site B: later onset of volatility (proxy "transition")
    vol = np.where(t > 120, 1.5, 0.3)
    site_b = np.column_stack(
        [seasonal * 0.8 + vol * rng.normal(size=T) for _ in range(3)]
    )
    return {"Cano_Martin_Pena_proxy": site_a, "Candelaria_proxy": site_b}


def summarize(name, X):
    tg, _ = compute_taus(X, window_size=13)
    T, _, g, depth = accumulate_time(tg, window_size=13)
    valid = tg[~np.isnan(tg)]
    print(f"{name}")
    print(f"  mean τₛ={valid.mean():.3f}  T_RECD={T[-1]:.5f}  max_k={int(depth.max())}")


def main():
    print("=== 02_aedes_puerto_rico (SYNTHETIC PROXY) ===")
    print("Replace with data/aedes/*.csv when license permits.\n")
    sites = synthetic_two_sites()
    for name, X in sites.items():
        summarize(name, np.maximum(X, 0.0))


if __name__ == "__main__":
    main()
