"""
02 — Aedes Puerto Rico schema demo.

Loads committed proxy CSVs under data/aedes/proxy/ when present;
otherwise generates the same series in-memory.

[OPERACIONAL] Not an empirical claim about Caño Martín Peña / Candelaria.
When real trap CSVs are licensed into data/aedes/raw/, swap the loader only.
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "python"))

from core import (  # noqa: E402
    accumulate_time,
    aedes_proxy_two_sites,
    compute_taus,
    load_matrix_csv,
)

PROXY_DIR = ROOT / "data" / "aedes" / "proxy"


def load_sites() -> dict:
    sites = {}
    for name in ("Cano_Martin_Pena_proxy", "Candelaria_proxy"):
        path = PROXY_DIR / f"{name}.csv"
        if path.is_file():
            sites[name] = load_matrix_csv(path)
        else:
            break
    if len(sites) == 2:
        print(f"Loaded proxy CSVs from {PROXY_DIR.relative_to(ROOT)}")
        return sites
    print("Proxy CSVs missing — generating in-memory (run scripts/export_fixtures.py).")
    return aedes_proxy_two_sites()


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
    print("=== 02_aedes_puerto_rico (SYNTHETIC PROXY) ===")
    print("Replace with data/aedes/raw/* when license permits.\n")
    sites = load_sites()
    for name, X in sites.items():
        summarize(name, np.maximum(np.asarray(X, dtype=float), 0.0))


if __name__ == "__main__":
    main()
