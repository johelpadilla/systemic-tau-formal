"""Minimal protocol-style summary of a multivariate series through τₛ + RECD."""

from __future__ import annotations

from typing import Any, Dict, Optional

import numpy as np

from .constants import THETA_CHAOS, THETA_STABLE
from .recd import accumulate_time
from .tau import compute_taus


def pipeline_report(
    X: np.ndarray,
    *,
    window_size: int = 13,
    name: str = "series",
    meta: Optional[Dict[str, Any]] = None,
) -> Dict[str, Any]:
    """
    Run τₛ + RECD and return a JSON-serializable summary.

    Outcomes are **not** automatically [EMPÍRICO]; caller must label domain.
    """
    X = np.asarray(X, dtype=float)
    tg, _ = compute_taus(X, window_size=window_size)
    T, dtk, g, depth = accumulate_time(tg, window_size=window_size)
    valid = tg[~np.isnan(tg)]
    if valid.size == 0:
        raise ValueError("no valid τₛ windows — increase T or decrease window")

    out: Dict[str, Any] = {
        "name": name,
        "shape": [int(X.shape[0]), int(X.shape[1])],
        "window_size": window_size,
        "mean_tau": float(valid.mean()),
        "std_tau": float(valid.std()),
        "frac_stable": float(np.mean(valid >= THETA_STABLE)),
        "frac_chaos": float(np.mean(np.abs(valid) < THETA_CHAOS)),
        "frac_anti": float(np.mean(valid <= -THETA_CHAOS)),
        "T_RECD_end": float(T[-1]),
        "max_depth_k": int(depth.max()),
        "mean_gate": float(np.nanmean(g)),
    }
    if meta:
        out["meta"] = {k: (float(v) if isinstance(v, (int, float, np.floating)) else v) for k, v in meta.items()}
    return out


def format_report(rep: Dict[str, Any]) -> str:
    lines = [
        f"{rep['name']}  shape={tuple(rep['shape'])}  w={rep['window_size']}",
        f"  mean τₛ={rep['mean_tau']:+.4f}  std={rep['std_tau']:.4f}",
        f"  regimes: stable={rep['frac_stable']:.1%} chaos={rep['frac_chaos']:.1%} "
        f"anti={rep['frac_anti']:.1%}",
        f"  T_RECD={rep['T_RECD_end']:.6f}  max_k={rep['max_depth_k']}  "
        f"mean g={rep['mean_gate']:+.4f}",
    ]
    if "meta" in rep:
        lines.append(f"  meta={rep['meta']}")
    return "\n".join(lines)
