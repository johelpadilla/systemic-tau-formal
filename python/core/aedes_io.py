"""Load Aedes trap matrices: prefer field ``raw/``, else synthetic ``proxy/``."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Literal, Optional

import numpy as np

from .io_data import load_matrix_csv
from .synthetic import aedes_proxy_two_sites

SourceKind = Literal["raw", "proxy", "generated"]


@dataclass(frozen=True)
class AedesLoadResult:
    """Sites matrix dict plus epistemic source tag."""

    sites: Dict[str, np.ndarray]
    source: SourceKind
    label: str
    directory: Optional[Path]


def _repo_root_from_here() -> Path:
    # python/core/aedes_io.py → repo root
    return Path(__file__).resolve().parents[2]


def discover_matrix_csvs(directory: Path) -> Dict[str, Path]:
    """Map stem → path for every ``*.csv`` in *directory* (non-recursive)."""
    if not directory.is_dir():
        return {}
    out: Dict[str, Path] = {}
    for path in sorted(directory.glob("*.csv")):
        if path.is_file():
            out[path.stem] = path
    return out


def load_aedes_sites(
    *,
    root: Optional[Path] = None,
    prefer_raw: bool = True,
    clip_nonneg: bool = True,
) -> AedesLoadResult:
    """
    Load trap matrices for demos / tests.

    Priority:

    1. ``data/aedes/raw/*.csv`` if any (``[EMPÍRICO]``)
    2. committed ``data/aedes/proxy/*.csv`` (``[OPERACIONAL]``)
    3. in-memory ``aedes_proxy_two_sites()`` (``[OPERACIONAL]``)
    """
    root = Path(root) if root is not None else _repo_root_from_here()
    raw_dir = root / "data" / "aedes" / "raw"
    proxy_dir = root / "data" / "aedes" / "proxy"

    if prefer_raw:
        raw_paths = discover_matrix_csvs(raw_dir)
        if raw_paths:
            sites = {name: load_matrix_csv(p) for name, p in raw_paths.items()}
            if clip_nonneg:
                sites = {k: np.maximum(np.asarray(v, dtype=float), 0.0) for k, v in sites.items()}
            return AedesLoadResult(
                sites=sites,
                source="raw",
                label="[EMPÍRICO]",
                directory=raw_dir,
            )

    proxy_paths = discover_matrix_csvs(proxy_dir)
    if proxy_paths:
        sites = {name: load_matrix_csv(p) for name, p in proxy_paths.items()}
        if clip_nonneg:
            sites = {k: np.maximum(np.asarray(v, dtype=float), 0.0) for k, v in sites.items()}
        return AedesLoadResult(
            sites=sites,
            source="proxy",
            label="[OPERACIONAL]",
            directory=proxy_dir,
        )

    sites = aedes_proxy_two_sites()
    if clip_nonneg:
        sites = {k: np.maximum(np.asarray(v, dtype=float), 0.0) for k, v in sites.items()}
    return AedesLoadResult(
        sites=sites,
        source="generated",
        label="[OPERACIONAL]",
        directory=None,
    )
