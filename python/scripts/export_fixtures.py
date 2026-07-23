#!/usr/bin/env python3
"""
Regenerate committed synthetic / Aedes-proxy CSV fixtures (deterministic seeds).

Run from repo root or python/:
  python scripts/export_fixtures.py
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "python"))

from core.io_data import save_matrix_csv  # noqa: E402
from core.synthetic import (  # noqa: E402
    aedes_proxy_two_sites,
    anti_synchronized,
    independent_noise,
    regime_switch,
    synchronized_seasonal,
)


def main() -> None:
    syn = ROOT / "data" / "synthetic"
    aedes = ROOT / "data" / "aedes" / "proxy"
    syn.mkdir(parents=True, exist_ok=True)
    aedes.mkdir(parents=True, exist_ok=True)

    X_sync = synchronized_seasonal(T=260, N=4, seed=0)
    save_matrix_csv(syn / "sync_seasonal.csv", X_sync, header="v0,v1,v2,v3")

    X_anti = anti_synchronized(T=260, N=4, seed=1)
    save_matrix_csv(syn / "anti_sync.csv", X_anti, header="v0,v1,v2,v3")

    X_iid = independent_noise(T=260, N=4, seed=2)
    save_matrix_csv(syn / "independent_noise.csv", X_iid, header="v0,v1,v2,v3")

    X_sw, meta = regime_switch(T=400, N=4, seed=3)
    save_matrix_csv(syn / "regime_switch.csv", X_sw, header="v0,v1,v2,v3")
    (syn / "regime_switch_meta.json").write_text(
        json.dumps(
            {
                "schema": "systemic-tau-formal/synthetic/v1",
                "label": "[OPERACIONAL]",
                "description": "Sync seasonal then independent noise",
                **meta,
            },
            indent=2,
        )
        + "\n"
    )

    sites = aedes_proxy_two_sites(T=200, traps_per_site=3, seed=1)
    for name, X in sites.items():
        header = ",".join(f"trap_{i}" for i in range(X.shape[1]))
        save_matrix_csv(aedes / f"{name}.csv", X, header=header)

    manifest = {
        "schema": "systemic-tau-formal/aedes-proxy/v1",
        "label": "[OPERACIONAL]",
        "note": "Synthetic stand-in only. Not field entomology.",
        "sites": list(sites.keys()),
        "T": 200,
        "traps_per_site": 3,
        "seed": 1,
        "sampling": "index as week-like unit (not calendar-stamped)",
    }
    (aedes / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")

    # Sanity sizes
    for p in syn.glob("*.csv"):
        print(f"wrote {p.relative_to(ROOT)}  shape={np.loadtxt(p, delimiter=',', skiprows=1).shape}")
    for p in aedes.glob("*.csv"):
        print(f"wrote {p.relative_to(ROOT)}  shape={np.loadtxt(p, delimiter=',', skiprows=1).shape}")
    print("OK")


if __name__ == "__main__":
    main()
