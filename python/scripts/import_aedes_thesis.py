#!/usr/bin/env python3
"""
Convert thesis Excel trap books into matrix CSVs under data/aedes/raw/.

Default source (sibling research tree):
  ~/grok-work/tau-sistemic/Investigaciones/tau-sistemic/
    feigenbaum_reduction_theorem/data/aedes_tesis/

Writes:
  San_Juan_SJU1_Repto_Metropolitano_2018.csv
  San_Juan_SJU2_2018_epiweeks.csv

Does **not** overwrite San_Juan_SJU3_2018_12traps.csv (already standardized).

Usage (from repo root or python/):
  python scripts/import_aedes_thesis.py
  python scripts/import_aedes_thesis.py --source /path/to/aedes_tesis
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import numpy as np
import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_SOURCE = (
    Path.home()
    / "grok-work"
    / "tau-sistemic"
    / "Investigaciones"
    / "tau-sistemic"
    / "feigenbaum_reduction_theorem"
    / "data"
    / "aedes_tesis"
)
RAW = ROOT / "data" / "aedes" / "raw"


def _normalize_columns(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df.columns = [str(c).strip().lower() for c in df.columns]
    rename = {}
    for c in df.columns:
        cl = c.lower()
        if "trap" in cl:
            rename[c] = "trapid"
        elif "epi" in cl or "week" in cl:
            rename[c] = "epiweek"
        elif "count" in cl or "mosq" in cl:
            rename[c] = "count"
    return df.rename(columns=rename)


def load_epi_workbook(path: Path) -> pd.DataFrame:
    """Long → wide matrix: index=epiweek, columns=trapid, values=count."""
    xl = pd.ExcelFile(path)
    frames: list[pd.DataFrame] = []
    for sh in xl.sheet_names:
        if not str(sh).lower().startswith("epi"):
            continue
        df = pd.read_excel(path, sheet_name=sh)
        df = _normalize_columns(df)
        if "trapid" not in df.columns or "count" not in df.columns:
            continue
        if "epiweek" not in df.columns:
            try:
                df["epiweek"] = int(str(sh).split()[-1])
            except ValueError:
                continue
        frames.append(df[["trapid", "epiweek", "count"]])
    if not frames:
        raise ValueError(f"no epi sheets with trap/count in {path}")
    long = pd.concat(frames, ignore_index=True)
    wide = (
        long.pivot_table(index="epiweek", columns="trapid", values="count", aggfunc="sum")
        .sort_index()
    )
    # Missing trap-weeks → 0 (documented; not “imputed biology”)
    return wide.fillna(0.0)


def write_matrix_csv(path: Path, wide: pd.DataFrame) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    # Index as first column EPIWEEK for human inspection; loader drops non-numeric? 
    # EPIWEEK is numeric so it would be kept as a column — use DATE-like non-numeric
    # header row only + pure numeric body (trap columns only).
    header = ",".join(str(c) for c in wide.columns)
    body = wide.to_numpy(dtype=float)
    with path.open("w", encoding="utf-8") as f:
        f.write(header + "\n")
        np.savetxt(f, body, delimiter=",")
    return path


def update_manifest(entries: list[dict]) -> None:
    man_path = RAW / "manifest.json"
    if man_path.is_file():
        man = json.loads(man_path.read_text(encoding="utf-8"))
    else:
        man = {
            "schema": "systemic-tau-formal/aedes-raw/v1",
            "label": "[EMPÍRICO]",
            "note": "Field / thesis-derived trap matrices. Not synthetic proxy.",
            "files": [],
        }
    by_path = {f.get("path"): f for f in man.get("files", [])}
    for e in entries:
        by_path[e["path"]] = e
    # Keep SJU3 first if present
    order = [
        "San_Juan_SJU3_2018_12traps.csv",
        "San_Juan_SJU1_Repto_Metropolitano_2018.csv",
        "San_Juan_SJU2_2018_epiweeks.csv",
    ]
    files = []
    for p in order:
        if p in by_path:
            files.append(by_path.pop(p))
    files.extend(by_path.values())
    man["files"] = files
    man_path.write_text(json.dumps(man, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    ap.add_argument("--out", type=Path, default=RAW)
    args = ap.parse_args()
    src: Path = args.source
    out: Path = args.out
    if not src.is_dir():
        print(f"Source not found: {src}", file=sys.stderr)
        return 1

    entries: list[dict] = []

    # SJU-1 — Repto Metropolitano workbook
    sju1 = src / "Mosquitos Aedes en Repto Metropolitano.xlsx"
    if sju1.is_file():
        wide = load_epi_workbook(sju1)
        path = out / "San_Juan_SJU1_Repto_Metropolitano_2018.csv"
        write_matrix_csv(path, wide)
        print(f"wrote {path.relative_to(ROOT)} shape={wide.shape}")
        entries.append(
            {
                "path": path.name,
                "site_id": "San_Juan_SJU1_Repto_2018",
                "T": int(wide.shape[0]),
                "N": int(wide.shape[1]),
                "sampling": "epi weeks 4–52; missing trap-weeks filled with 0",
                "year": 2018,
                "region": "San Juan Repto Metropolitano (SJU-1 cluster)",
                "provenance": "Thesis aedes_tesis / Mosquitos Aedes en Repto Metropolitano.xlsx",
            }
        )
    else:
        print(f"skip missing {sju1.name}")

    # SJU-2 — SUMMER and WINTER books are identical matrices (verified)
    sju2 = src / "SanJuan Mosquito Data epi weeks_2018 SUMMER.xls"
    if sju2.is_file():
        wide = load_epi_workbook(sju2)
        path = out / "San_Juan_SJU2_2018_epiweeks.csv"
        write_matrix_csv(path, wide)
        print(f"wrote {path.relative_to(ROOT)} shape={wide.shape}")
        entries.append(
            {
                "path": path.name,
                "site_id": "San_Juan_SJU2_2018",
                "T": int(wide.shape[0]),
                "N": int(wide.shape[1]),
                "sampling": "epi weeks 7–52; missing trap-weeks filled with 0",
                "year": 2018,
                "region": "San Juan (SJU-2 cluster)",
                "provenance": "Thesis aedes_tesis / SanJuan Mosquito Data epi weeks_2018 SUMMER.xls "
                "(identical to WINTER book)",
            }
        )
    else:
        print(f"skip missing {sju2.name}")

    if entries:
        update_manifest(entries)
        print(f"updated { (out / 'manifest.json').relative_to(ROOT) }")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
