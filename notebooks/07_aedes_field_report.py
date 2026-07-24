"""
07 — Empirical report on data/aedes/raw/ field matrices.

Runs τₛ + RECD pipeline_report on every raw CSV.
Documents chaos-band runs (RECD depth) honestly.

Does **not** claim P1 (4–6 week lead) without a pre-registered observable
transition endpoint. Labels all outcomes [EMPÍRICO] for series provenance only.

Usage (repo root):
  python notebooks/07_aedes_field_report.py
  python notebooks/07_aedes_field_report.py --json data/aedes/raw/last_field_report.json
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "python"))

from core import (  # noqa: E402
    THETA_CHAOS,
    accumulate_time,
    compute_taus,
    format_report,
    load_aedes_sites,
    pipeline_report,
)
from core.constants import THETA_STABLE  # noqa: E402


def chaos_runs(tau: np.ndarray, theta: float = THETA_CHAOS) -> list[tuple[int, int]]:
    """Maximal index runs where |τ| < theta (NaNs break runs)."""
    below = np.abs(tau) < theta
    below = np.asarray(below, dtype=bool)
    # treat nan as not-below
    below = below & np.isfinite(tau)
    runs: list[tuple[int, int]] = []
    i = 0
    n = len(below)
    while i < n:
        if below[i]:
            j = i
            while j < n and below[j]:
                j += 1
            runs.append((i, j))
            i = j
        else:
            i += 1
    return runs


def series_extras(X: np.ndarray, window_size: int = 13) -> dict:
    tg, _ = compute_taus(X, window_size=window_size)
    T, dtk, g, depth = accumulate_time(tg, window_size=window_size)
    runs = chaos_runs(tg)
    lengths = [e - s for s, e in runs]
    long_runs = [L for L in lengths if L >= 4]
    return {
        "n_chaos_runs": len(runs),
        "n_chaos_runs_len_ge_4": len(long_runs),
        "max_chaos_run_len": int(max(lengths) if lengths else 0),
        "mean_chaos_run_len": float(np.mean(lengths)) if lengths else 0.0,
        "frac_time_chaos_band": float(np.mean(np.abs(tg[np.isfinite(tg)]) < THETA_CHAOS))
        if np.any(np.isfinite(tg))
        else 0.0,
        "frac_time_stable_band": float(np.mean(tg[np.isfinite(tg)] >= THETA_STABLE))
        if np.any(np.isfinite(tg))
        else 0.0,
        "max_depth_k": int(np.nanmax(depth)),
        "T_RECD_end": float(T[-1]),
        "p1_note": (
            "P1 not evaluated: no pre-registered domain endpoint t_obs on this series. "
            "Report chaos-run / RECD structure only."
        ),
    }


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--json",
        type=Path,
        default=None,
        help="Optional path to write JSON report",
    )
    ap.add_argument("--window", type=int, default=13)
    args = ap.parse_args()

    result = load_aedes_sites(root=ROOT, prefer_raw=True)
    print(f"=== 07_aedes_field_report ({result.label} · source={result.source}) ===\n")
    if result.source != "raw":
        print("No raw CSVs — nothing empirical to report. Drop matrices under data/aedes/raw/.")
        return 1

    reports = []
    for name, X in result.sites.items():
        X = np.asarray(X, dtype=float)
        rep = pipeline_report(X, window_size=args.window, name=name, meta={"label": result.label})
        extra = series_extras(X, window_size=args.window)
        rep["empirical"] = extra
        reports.append(rep)
        print(format_report(rep))
        print(
            f"  chaos_runs={extra['n_chaos_runs']} "
            f"(len≥4: {extra['n_chaos_runs_len_ge_4']}) "
            f"max_run={extra['max_chaos_run_len']} "
            f"frac_chaos={extra['frac_time_chaos_band']:.1%}"
        )
        print(f"  {extra['p1_note']}\n")

    payload = {
        "label": result.label,
        "source": result.source,
        "window_size": args.window,
        "n_series": len(reports),
        "series": reports,
        "honesty": {
            "p1": "not scored without labeled transition endpoints",
            "p3": "use notebooks/04 on synthetic; field noise study is separate",
            "epistemic": result.label,
        },
    }
    if args.json is not None:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
        print(f"wrote {args.json}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
