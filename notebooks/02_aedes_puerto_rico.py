"""
02 — Aedes Puerto Rico trap pipeline.

Prefers field matrices under data/aedes/raw/ ([EMPÍRICO]).
Falls back to committed proxy CSVs or in-memory generators ([OPERACIONAL]).
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "python"))

from core import accumulate_time, compute_taus, load_aedes_sites  # noqa: E402


def summarize(name, X):
    tg, _ = compute_taus(X, window_size=13)
    T, _, g, depth = accumulate_time(tg, window_size=13)
    valid = tg[~np.isnan(tg)]
    print(f"{name}")
    print(
        f"  shape={X.shape}  mean τₛ={valid.mean():.3f}  "
        f"T_RECD={T[-1]:.5f}  max_k={int(depth.max())}"
    )


def main():
    result = load_aedes_sites(root=ROOT, prefer_raw=True)
    tag = f"{result.label} · source={result.source}"
    if result.directory is not None:
        try:
            rel = result.directory.relative_to(ROOT)
        except ValueError:
            rel = result.directory
        print(f"=== 02_aedes_puerto_rico ({tag}) ===")
        print(f"Loaded from {rel}\n")
    else:
        print(f"=== 02_aedes_puerto_rico ({tag}) ===")
        print("No CSV fixtures — in-memory proxy generator.\n")

    for name, X in result.sites.items():
        summarize(name, np.asarray(X, dtype=float))


if __name__ == "__main__":
    main()
