"""
Synthetic multivariate generators for protocol demos and CI fixtures.

All outputs are **[OPERACIONAL]** lab series — not field entomology.
"""

from __future__ import annotations

from typing import Dict, Literal, Optional, Tuple

import numpy as np

RegimeName = Literal["sync", "chaos", "anti", "switch"]


def coupled_logistic(
    T: int = 800,
    N: int = 4,
    r: float = 3.85,
    eps: float = 0.05,
    seed: int = 0,
) -> np.ndarray:
    """Coupled logistic maps; high *r* → chaotic-looking ordinal structure."""
    rng = np.random.default_rng(seed)
    X = rng.uniform(0.1, 0.9, size=(T, N))
    for t in range(1, T):
        mean = X[t - 1].mean()
        for i in range(N):
            x = (1 - eps) * X[t - 1, i] + eps * mean
            X[t, i] = r * x * (1 - x)
    return X


def synchronized_seasonal(
    T: int = 260,
    N: int = 4,
    period: float = 52.0,
    noise: float = 0.05,
    seed: int = 0,
) -> np.ndarray:
    """Strongly co-moving seasonal drivers (expect high τₛ)."""
    rng = np.random.default_rng(seed)
    t = np.arange(T, dtype=float)
    base = 1.2 + np.sin(2 * np.pi * t / period)
    cols = [base + noise * rng.normal(size=T) for _ in range(N)]
    return np.column_stack(cols)


def anti_synchronized(
    T: int = 260,
    N: int = 4,
    period: float = 52.0,
    noise: float = 0.05,
    seed: int = 1,
) -> np.ndarray:
    """
    Half the series track +sin, half track −sin (expect low / negative τₛ).

    N must be even for balanced anti-pairs.
    """
    if N < 2:
        raise ValueError("N >= 2 required")
    rng = np.random.default_rng(seed)
    t = np.arange(T, dtype=float)
    pos = np.sin(2 * np.pi * t / period)
    neg = -pos
    cols = []
    for i in range(N):
        driver = pos if i % 2 == 0 else neg
        cols.append(driver + noise * rng.normal(size=T))
    return np.column_stack(cols)


def independent_noise(T: int = 260, N: int = 4, seed: int = 2) -> np.ndarray:
    """IID Gaussian columns (expect τₛ near 0 / chaotic band)."""
    rng = np.random.default_rng(seed)
    return rng.normal(size=(T, N))


def regime_switch(
    T: int = 400,
    N: int = 4,
    t_switch: Optional[int] = None,
    seed: int = 3,
) -> Tuple[np.ndarray, Dict[str, int]]:
    """
    Concatenate sync → chaos-like independent noise at *t_switch*.

    Returns X and metadata with switch index (for demos; not a dengue endpoint).
    """
    if t_switch is None:
        t_switch = T // 2
    t_switch = int(t_switch)
    A = synchronized_seasonal(T=t_switch, N=N, seed=seed)
    B = independent_noise(T=T - t_switch, N=N, seed=seed + 11)
    # scale B to similar amplitude
    scale = float(np.std(A)) or 1.0
    B = B * scale + float(np.mean(A))
    X = np.vstack([A, B])
    meta = {"t_switch": t_switch, "T": T, "N": N, "seed": seed}
    return X, meta


def aedes_proxy_two_sites(
    T: int = 200,
    traps_per_site: int = 3,
    seed: int = 1,
) -> Dict[str, np.ndarray]:
    """
    Schema stand-in for two Puerto Rico sites (weekly-like length).

    Names are **proxies** — not Caño Martín Peña / Candelaria field data.
    """
    rng = np.random.default_rng(seed)
    t = np.arange(T)
    seasonal = 1.2 + np.sin(2 * np.pi * t / 52)
    site_a = np.column_stack(
        [np.maximum(seasonal + 0.3 * rng.normal(size=T), 0.0) for _ in range(traps_per_site)]
    )
    vol = np.where(t > 120, 1.5, 0.3)
    site_b = np.column_stack(
        [
            np.maximum(seasonal * 0.8 + vol * rng.normal(size=T), 0.0)
            for _ in range(traps_per_site)
        ]
    )
    return {
        "Cano_Martin_Pena_proxy": site_a,
        "Candelaria_proxy": site_b,
    }


def add_column_noise(
    X: np.ndarray,
    rho: float,
    seed: int = 0,
) -> np.ndarray:
    """
    Protocol § Noise: ε ~ N(0, (ρ · std_j)²) per column.

    ρ = 0 returns a copy.
    """
    X = np.asarray(X, dtype=float)
    if rho < 0:
        raise ValueError("rho must be >= 0")
    if rho == 0:
        return X.copy()
    rng = np.random.default_rng(seed)
    out = X.copy()
    for j in range(X.shape[1]):
        s = float(np.nanstd(X[:, j]))
        if s == 0.0:
            s = 1.0
        out[:, j] = X[:, j] + rng.normal(0.0, rho * s, size=X.shape[0])
    return out
