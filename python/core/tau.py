"""Systemic Tau: mean pairwise Kendall-τ on sliding windows."""

from __future__ import annotations

import itertools
from typing import Tuple

import numpy as np
from scipy import stats


def kendall_tau(x: np.ndarray, y: np.ndarray) -> float:
    """Kendall-τ between two 1-D arrays; NaN → 0.0."""
    tau, _ = stats.kendalltau(x, y)
    return 0.0 if tau is None or np.isnan(tau) else float(tau)


def compute_taus(
    X: np.ndarray, window_size: int = 13, stride: int = 1
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Compute global and per-module Systemic Tau.

    Parameters
    ----------
    X : array, shape (T, N), N >= 2
    window_size : int
    stride : int

    Returns
    -------
    taus_global : shape (T,)
    taus_per_module : shape (T, N)
    """
    X = np.asarray(X, dtype=float)
    if X.ndim != 2:
        raise ValueError("X must be 2-D (T, N)")
    T, N = X.shape
    if N < 2:
        raise ValueError("At least 2 components are required.")
    if window_size < 2:
        raise ValueError("window_size must be >= 2")

    taus_global = np.full(T, np.nan)
    taus_per_module = np.full((T, N), np.nan)

    for t in range(window_size - 1, T, stride):
        window = X[t - window_size + 1 : t + 1, :]
        tau_matrix = np.zeros((N, N))
        for i, j in itertools.combinations(range(N), 2):
            tau = kendall_tau(window[:, i], window[:, j])
            tau_matrix[i, j] = tau
            tau_matrix[j, i] = tau
        iu = np.triu_indices(N, k=1)
        taus_global[t] = float(np.mean(tau_matrix[iu]))
        for i in range(N):
            mask = np.ones(N, dtype=bool)
            mask[i] = False
            taus_per_module[t, i] = float(np.mean(tau_matrix[i, mask]))

    return taus_global, taus_per_module
