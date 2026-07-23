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


# ---------------------------------------------------------------------------
# Cross-domain *synthetic* labs (C3 starters) — not market / clinical / grid data
# ---------------------------------------------------------------------------


def finance_like_returns(
    T: int = 500,
    N: int = 5,
    t_break: Optional[int] = None,
    rho_pre: float = 0.75,
    rho_post: float = 0.05,
    seed: int = 10,
) -> Tuple[np.ndarray, Dict[str, float]]:
    """
    Synthetic multi-asset log-return panel with a correlation break.

    [OPERACIONAL] Not real market data. Endpoint proxy: known *t_break*.
    """
    if t_break is None:
        t_break = T // 2
    t_break = int(t_break)
    rng = np.random.default_rng(seed)

    def block(n_rows: int, rho: float) -> np.ndarray:
        # equicorrelated Gaussian factor model
        f = rng.normal(size=n_rows)
        idio = rng.normal(size=(n_rows, N))
        w = np.sqrt(max(rho, 0.0))
        wi = np.sqrt(max(1.0 - rho, 0.0))
        return w * f[:, None] + wi * idio

    A = block(t_break, rho_pre)
    B = block(T - t_break, rho_post)
    X = np.vstack([A, B])
    meta = {
        "domain": "finance_like",
        "t_break": float(t_break),
        "rho_pre": float(rho_pre),
        "rho_post": float(rho_post),
        "label": "[OPERACIONAL]",
    }
    return X, meta


def eeg_like_channels(
    T: int = 800,
    N: int = 6,
    t_desync: Optional[int] = None,
    seed: int = 11,
) -> Tuple[np.ndarray, Dict[str, float]]:
    """
    Synthetic multi-channel oscillatory panel (phase-locked → independent).

    [OPERACIONAL] Not clinical EEG. Frequencies are lab parameters only.
    """
    if t_desync is None:
        t_desync = T // 2
    t_desync = int(t_desync)
    rng = np.random.default_rng(seed)
    t = np.arange(T, dtype=float)
    # shared alpha-like carrier before desync
    f0 = 0.08
    shared = np.sin(2 * np.pi * f0 * t)
    cols = []
    for i in range(N):
        phase = 0.15 * i
        locked = shared + 0.15 * np.sin(2 * np.pi * f0 * t + phase)
        # independent after desync
        fi = f0 * (1.0 + 0.3 * (i + 1) / N)
        free = np.sin(2 * np.pi * fi * t + rng.uniform(0, 2 * np.pi))
        x = np.where(t < t_desync, locked, free)
        x = x + 0.08 * rng.normal(size=T)
        cols.append(x)
    X = np.column_stack(cols)
    meta = {
        "domain": "eeg_like",
        "t_desync": float(t_desync),
        "label": "[OPERACIONAL]",
    }
    return X, meta


def grid_like_loads(
    T: int = 400,
    N: int = 4,
    t_event: Optional[int] = None,
    seed: int = 12,
) -> Tuple[np.ndarray, Dict[str, float]]:
    """
    Synthetic nodal load / frequency-deviation proxy with a common shock.

    [OPERACIONAL] Not SCADA or utility data.
    """
    if t_event is None:
        t_event = (2 * T) // 3
    t_event = int(t_event)
    rng = np.random.default_rng(seed)
    t = np.arange(T, dtype=float)
    diurnal = np.sin(2 * np.pi * t / 48.0)  # half-day-ish index
    cols = []
    for i in range(N):
        base = 1.0 + 0.2 * diurnal + 0.05 * i
        noise = 0.05 * rng.normal(size=T)
        # after event: one node detaches (anti-ish), others jitter
        shock = np.zeros(T)
        if i == 0:
            shock[t_event:] = -0.8 + 0.3 * rng.normal(size=T - t_event)
        else:
            shock[t_event:] = 0.2 * rng.normal(size=T - t_event)
        cols.append(base + noise + shock)
    X = np.column_stack(cols)
    meta = {
        "domain": "grid_like",
        "t_event": float(t_event),
        "label": "[OPERACIONAL]",
    }
    return X, meta


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
