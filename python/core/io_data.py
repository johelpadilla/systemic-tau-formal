"""Small CSV loaders for fixtures and protocol reports."""

from __future__ import annotations

from pathlib import Path
from typing import Union

import numpy as np


def load_matrix_csv(path: Union[str, Path]) -> np.ndarray:
    """
    Load a dense numeric matrix from CSV.

    - Optional header row (skipped if any non-numeric token appears).
    - Rows = time, columns = variables (N >= 2).
    """
    path = Path(path)
    if not path.is_file():
        raise FileNotFoundError(path)

    # Try with header detection via genfromtxt
    try:
        data = np.genfromtxt(path, delimiter=",", names=None, dtype=float)
    except Exception as exc:
        raise ValueError(f"Failed to parse {path}: {exc}") from exc

    X = np.asarray(data, dtype=float)
    if X.ndim == 1:
        # single column or failed header → re-read skipping first row
        data2 = np.genfromtxt(path, delimiter=",", skip_header=1, dtype=float)
        X = np.asarray(data2, dtype=float)
        if X.ndim == 1:
            raise ValueError(f"{path}: need at least 2 columns")

    # Drop columns that are entirely NaN (header bleed)
    col_ok = np.isfinite(X).any(axis=0)
    X = X[:, col_ok]
    # Drop rows that are entirely NaN
    row_ok = np.isfinite(X).any(axis=1)
    X = X[row_ok]

    if X.ndim != 2 or X.shape[1] < 2:
        raise ValueError(f"{path}: need shape (T, N) with N>=2, got {X.shape}")
    return X


def save_matrix_csv(
    path: Union[str, Path],
    X: np.ndarray,
    header: str | None = None,
) -> Path:
    """Write matrix with optional comma-separated header names."""
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    X = np.asarray(X, dtype=float)
    if header:
        np.savetxt(path, X, delimiter=",", header=header, comments="")
    else:
        np.savetxt(path, X, delimiter=",")
    return path
