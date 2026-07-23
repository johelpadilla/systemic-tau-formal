"""RECD gate g(τₛ) and discrete extramental time accumulation."""

from __future__ import annotations

from typing import Tuple

import numpy as np

from .constants import DELTA, THETA_CHAOS, THETA_STABLE


def gate_function(
    tau_s,
    threshold_chaos: float = THETA_CHAOS,
    threshold_stable: float = THETA_STABLE,
):
    """
    Gate g(τₛ) — [OPERACIONAL] reference law.

    +1 if τ ≥ 0.50
    ((δ-1)/δ) * (0.41 - |τ|) / 0.41 if |τ| < 0.41
    -1 if τ ≤ -0.41
    0 otherwise
    """
    tau_s = np.asarray(tau_s, dtype=float)
    g_val = np.zeros_like(tau_s, dtype=float)

    mask_stable = tau_s >= threshold_stable
    g_val[mask_stable] = 1.0

    mask_chaos = np.abs(tau_s) < threshold_chaos
    prefactor = (DELTA - 1.0) / DELTA
    g_val[mask_chaos] = (
        prefactor * (threshold_chaos - np.abs(tau_s[mask_chaos])) / threshold_chaos
    )

    mask_anti = tau_s <= -threshold_chaos
    g_val[mask_anti] = -1.0

    if g_val.ndim == 0:
        return float(g_val)
    return g_val


def compute_recd_increments(
    taus_series: np.ndarray, window_size: int = 13, dt0: float = 1.0
) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Δt_k, gate series, renormalization depths k on chaotic runs."""
    taus_series = np.asarray(taus_series, dtype=float)
    T = len(taus_series)
    dtk_series = np.zeros(T)
    gate_series = np.zeros(T)
    depth_series = np.zeros(T, dtype=int)

    chaotic_count = 0
    in_run = False

    for i in range(T):
        tau = taus_series[i]
        if np.isnan(tau):
            continue
        g = gate_function(tau)
        gate_series[i] = g
        if np.abs(tau) < THETA_CHAOS:
            if not in_run:
                in_run = True
            chaotic_count += 1
            k = chaotic_count
            dtk = (DELTA ** (-k)) * np.abs(tau) * (dt0 / window_size)
            dtk_series[i] = dtk
            depth_series[i] = k
        else:
            in_run = False
            chaotic_count = 0
            dtk_series[i] = 0.0
            depth_series[i] = 0

    return dtk_series, gate_series, depth_series


def accumulate_time(
    taus_series: np.ndarray, window_size: int = 13, dt0: float = 1.0
) -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    """
    T_n = sum g(τ) Δt_k

    Returns
    -------
    T_series, dtk_series, gate_series, depth_series
    """
    dtk_series, gate_series, depth_series = compute_recd_increments(
        taus_series, window_size=window_size, dt0=dt0
    )
    increments = gate_series * dtk_series
    # NaN-safe cumsum
    increments = np.nan_to_num(increments, nan=0.0)
    T_series = np.cumsum(increments)
    return T_series, dtk_series, gate_series, depth_series
