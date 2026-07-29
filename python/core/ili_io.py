"""ILI / FluView + FluSurv loaders and Delphi Epidata intake helpers.

Sources
-------
* CDC ILINet via Delphi ``fluview`` (``wili`` for hhs1–hhs10)
* CDC FluSurv-NET via Delphi ``flusurv`` (``rate_overall`` for ``network_all``)

Network calls use urllib; offline unit tests use committed CSVs under
``data/ili/``.
"""

from __future__ import annotations

import csv
import json
import subprocess
import urllib.parse
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, List, Optional, Sequence, Tuple

import numpy as np

from .io_data import load_matrix_csv, save_matrix_csv

DELPHI_BASE = "https://api.delphi.cmu.edu/epidata"
HHS_REGIONS: Tuple[str, ...] = tuple(f"hhs{i}" for i in range(1, 11))
FLUSURV_LOCATION = "network_all"

# CDC flu season: week 40 of start year → week 20 of next year.
SEASON_START_WEEK = 40
SEASON_END_WEEK = 20


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def default_ili_paths(root: Optional[Path] = None) -> Dict[str, Path]:
    root = Path(root) if root is not None else _repo_root()
    base = root / "data" / "ili"
    return {
        "root": root,
        "ili": base,
        "field": base / "field_hhs",
        "external": base / "external",
        "calendar": base / "field_hhs" / "calendar_map.json",
        "endpoints": base / "field_hhs" / "endpoints_hhs_yearly.json",
        "endpoints_p75": base / "field_hhs" / "endpoints_hhs_yearly_p75.json",
        "lock": base / "field_hhs" / "protocol_lock_hhs_yearly.json",
        "lock_p75": base / "field_hhs" / "protocol_lock_hhs_yearly_p75.json",
        "last_score": base / "field_hhs" / "last_p1_ili_score_hhs_yearly.json",
        "last_score_p75": base / "field_hhs" / "last_p1_ili_score_hhs_yearly_p75.json",
        "flusurv_csv": base / "external" / "flusurv_network_all.csv",
        "provenance": base / "external" / "PROVENANCE.md",
    }


def season_label(start_year: int) -> str:
    """2017 → '2017-18'."""
    return f"{start_year}-{str(start_year + 1)[2:]}"


def parse_season_label(label: str) -> int:
    """'2017-18' → 2017."""
    return int(label.split("-")[0])


def season_of_epiweek(epiweek: int) -> str:
    """Map YYYYWW → flu-season label (week ≥40 belongs to that start year)."""
    y, w = divmod(int(epiweek), 100)
    if w >= SEASON_START_WEEK:
        return season_label(y)
    return season_label(y - 1)


def candidate_season_epiweeks(start_year: int) -> List[int]:
    """Ordered epiweeks for season start_year (may include non-existent week 53)."""
    weeks: List[int] = []
    for w in range(SEASON_START_WEEK, 54):
        weeks.append(start_year * 100 + w)
    y2 = start_year + 1
    for w in range(1, SEASON_END_WEEK + 1):
        weeks.append(y2 * 100 + w)
    return weeks


def delphi_get(endpoint: str, params: Dict[str, Any], *, timeout: float = 120.0) -> dict:
    """GET Delphi epidata endpoint; return parsed JSON.

    Uses ``curl`` first (macOS Python SSL often fails on this host with
    corporate/self-signed chains), then urllib as fallback.
    """
    q = urllib.parse.urlencode(params, doseq=True)
    url = f"{DELPHI_BASE}/{endpoint}/?{q}"
    # Prefer curl — reliable on this environment
    try:
        proc = subprocess.run(
            [
                "curl",
                "-fsSL",
                "--max-time",
                str(int(timeout)),
                "-A",
                "systemic-tau-formal/p1-ili",
                url,
            ],
            check=True,
            capture_output=True,
            text=True,
        )
        return json.loads(proc.stdout)
    except (subprocess.CalledProcessError, FileNotFoundError, json.JSONDecodeError) as curl_err:
        try:
            req = urllib.request.Request(
                url, headers={"User-Agent": "systemic-tau-formal/p1-ili"}
            )
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                raw = resp.read().decode("utf-8")
            return json.loads(raw)
        except Exception as urllib_err:
            raise RuntimeError(
                f"Delphi GET failed curl={curl_err!r} urllib={urllib_err!r} url={url}"
            ) from urllib_err


def fetch_fluview_hhs(
    epiweeks: str,
    *,
    regions: Sequence[str] = HHS_REGIONS,
) -> List[dict]:
    """Fetch fluview rows for HHS regions. ``epiweeks`` e.g. ``201740-201820``."""
    params = {
        "regions": ",".join(regions),
        "epiweeks": epiweeks,
    }
    doc = delphi_get("fluview", params)
    if doc.get("result") != 1:
        raise RuntimeError(f"fluview API result={doc.get('result')} message={doc.get('message')}")
    return list(doc.get("epidata") or [])


def fetch_flusurv_network(
    epiweeks: str,
    *,
    location: str = FLUSURV_LOCATION,
) -> List[dict]:
    """Fetch FluSurv hospitalization rates for network_all (or other location)."""
    params = {
        "locations": location,
        "epiweeks": epiweeks,
    }
    doc = delphi_get("flusurv", params)
    if doc.get("result") != 1:
        raise RuntimeError(f"flusurv API result={doc.get('result')} message={doc.get('message')}")
    return list(doc.get("epidata") or [])


def epiweek_range_str(start_year: int, end_year: int) -> str:
    """Inclusive multi-season download range: start_year w40 → end_year w20."""
    return f"{start_year}{SEASON_START_WEEK:02d}-{(end_year + 1)}{SEASON_END_WEEK:02d}"


def build_hhs_season_matrix(
    rows: Sequence[dict],
    start_year: int,
    *,
    regions: Sequence[str] = HHS_REGIONS,
    signal: str = "wili",
) -> Tuple[np.ndarray, List[int], List[str]]:
    """
    Build (T, N) matrix for one flu season from fluview rows.

    Only keeps epiweeks where **all** regions have a finite signal value.
    Returns matrix, ordered epiweeks, region names.
    """
    grid: Dict[str, Dict[int, float]] = {r: {} for r in regions}
    for r in rows:
        reg = str(r.get("region", "")).lower()
        if reg not in grid:
            continue
        ew = int(r["epiweek"])
        if season_of_epiweek(ew) != season_label(start_year):
            continue
        val = r.get(signal)
        if val is None:
            continue
        try:
            f = float(val)
        except (TypeError, ValueError):
            continue
        if np.isfinite(f):
            grid[reg][ew] = f

    candidates = candidate_season_epiweeks(start_year)
    kept: List[int] = []
    for ew in candidates:
        if all(ew in grid[reg] for reg in regions):
            kept.append(ew)
    if len(kept) < 20:
        raise ValueError(
            f"season {season_label(start_year)}: only {len(kept)} complete weeks "
            f"(need ≥20 for w=13 + lead window)"
        )
    X = np.zeros((len(kept), len(regions)), dtype=float)
    for j, reg in enumerate(regions):
        for i, ew in enumerate(kept):
            X[i, j] = grid[reg][ew]
    return X, kept, list(regions)


def epiweek_to_season_row(epiweek: int, season_epiweeks: Sequence[int]) -> Optional[int]:
    """Exact map epiweek → 0-based row; None if not in season matrix."""
    ew = int(epiweek)
    for i, w in enumerate(season_epiweeks):
        if int(w) == ew:
            return i
    return None


def write_flusurv_csv(path: Path, rows: Sequence[dict]) -> Path:
    """Write FluSurv long table (rate_overall as total_cases for scorer reuse)."""
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = [
        "season",
        "year",
        "weekofyear",
        "epiweek",
        "total_cases",
        "rate_overall",
        "location",
    ]
    with path.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        for r in sorted(rows, key=lambda x: int(x["epiweek"])):
            rate = r.get("rate_overall")
            if rate is None:
                continue
            ew = int(r["epiweek"])
            y, wk = divmod(ew, 100)
            try:
                rate_f = float(rate)
            except (TypeError, ValueError):
                continue
            w.writerow(
                {
                    "season": season_of_epiweek(ew),
                    "year": y,
                    "weekofyear": wk,
                    "epiweek": ew,
                    "total_cases": rate_f,  # scorer alias
                    "rate_overall": rate_f,
                    "location": r.get("location", FLUSURV_LOCATION),
                }
            )
    return path


def load_flusurv_csv(path: Path) -> List[dict]:
    """Load FluSurv CSV written by ``write_flusurv_csv``."""
    path = Path(path)
    out: List[dict] = []
    with path.open(newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for raw in reader:
            try:
                item = {
                    "season": raw["season"],
                    "year": int(raw["year"]),
                    "weekofyear": int(raw["weekofyear"]),
                    "epiweek": int(raw["epiweek"]),
                    "total_cases": float(raw["total_cases"]),
                    "rate_overall": float(raw.get("rate_overall") or raw["total_cases"]),
                    "location": raw.get("location") or FLUSURV_LOCATION,
                }
            except (KeyError, TypeError, ValueError):
                continue
            out.append(item)
    return out


@dataclass(frozen=True)
class IliLoadResult:
    sites: Dict[str, np.ndarray]
    source: str
    label: str
    directory: Optional[Path]


def load_ili_sites(
    *,
    root: Optional[Path] = None,
    directory: Optional[Path] = None,
) -> IliLoadResult:
    """Load committed HHS season matrices under field_hhs/."""
    paths = default_ili_paths(root)
    d = Path(directory) if directory is not None else paths["field"]
    sites: Dict[str, np.ndarray] = {}
    if d.is_dir():
        for p in sorted(d.glob("HHS_wILI_*.csv")):
            sites[p.stem] = load_matrix_csv(p)
    return IliLoadResult(
        sites=sites,
        source="field" if sites else "empty",
        label="[EMPÍRICO]" if sites else "[OPERACIONAL]",
        directory=d if sites else None,
    )


def write_season_matrix_csv(
    path: Path,
    X: np.ndarray,
    regions: Sequence[str],
    epiweeks: Sequence[int],
) -> Path:
    """Write matrix with header = regions; no epiweek column (row order is calendar)."""
    header = ",".join(regions)
    return save_matrix_csv(path, X, header=header)


def intake_seasons(
    start_years: Sequence[int],
    *,
    root: Optional[Path] = None,
    download: bool = True,
) -> dict:
    """
    Download (optional) HHS + FluSurv for given season start years and write field CSVs.

    Returns a summary dict with paths and peak candidates (FluSurv only; no τ).
    """
    paths = default_ili_paths(root)
    paths["field"].mkdir(parents=True, exist_ok=True)
    paths["external"].mkdir(parents=True, exist_ok=True)

    years = sorted(int(y) for y in start_years)
    y0, y1 = years[0], years[-1]
    summary: Dict[str, Any] = {
        "seasons": {},
        "flusurv_csv": str(paths["flusurv_csv"]),
        "download": download,
    }

    if download:
        ew_range = epiweek_range_str(y0, y1)
        hhs_rows = fetch_fluview_hhs(ew_range)
        # FluSurv history may start earlier; pull a wide range for peaks
        flusurv_rows = fetch_flusurv_network(epiweek_range_str(max(2003, y0 - 1), y1))
        write_flusurv_csv(paths["flusurv_csv"], flusurv_rows)
    else:
        hhs_rows = []
        flusurv_rows = []
        if paths["flusurv_csv"].is_file():
            # rebuild list-shaped rows from CSV for peak summary
            for r in load_flusurv_csv(paths["flusurv_csv"]):
                flusurv_rows.append(
                    {
                        "epiweek": r["epiweek"],
                        "rate_overall": r["rate_overall"],
                        "location": r["location"],
                    }
                )

    calendar_series: Dict[str, Any] = {}
    for sy in years:
        label = season_label(sy)
        if download:
            X, ews, regs = build_hhs_season_matrix(hhs_rows, sy)
            out_csv = paths["field"] / f"HHS_wILI_{label}.csv"
            write_season_matrix_csv(out_csv, X, regs, ews)
        else:
            out_csv = paths["field"] / f"HHS_wILI_{label}.csv"
            if not out_csv.is_file():
                summary["seasons"][label] = {"ok": False, "reason": "matrix missing offline"}
                continue
            X = load_matrix_csv(out_csv)
            # recover epiweeks from calendar if present later; for offline rebuild
            # use candidate weeks filtered by T
            ews = candidate_season_epiweeks(sy)[: X.shape[0]]
            regs = list(HHS_REGIONS)

        calendar_series[f"HHS_wILI_{label}"] = {
            "file": out_csv.name,
            "calendar_kind": "flu_season_epiweek",
            "season": label,
            "start_year": sy,
            "T": int(X.shape[0]),
            "N": int(X.shape[1]),
            "regions": list(regs) if download else list(HHS_REGIONS),
            "epiweeks": [int(e) for e in ews] if download else None,
            "signal": "wili",
            "source": "Delphi Epidata fluview (CDC ILINet)",
        }
        summary["seasons"][label] = {
            "ok": True,
            "file": str(out_csv),
            "shape": list(X.shape),
            "epiweek_start": int(ews[0]) if ews else None,
            "epiweek_end": int(ews[-1]) if ews else None,
        }

    # Fill epiweeks from download-built calendar only; if offline and calendar exists, keep
    cal_path = paths["calendar"]
    if download:
        cal = {
            "schema": "systemic-tau-formal/ili-calendar/v1",
            "protocol_version": "1.0.0",
            "geo": "USA_HHS_regions",
            "series": calendar_series,
        }
        cal_path.parent.mkdir(parents=True, exist_ok=True)
        cal_path.write_text(json.dumps(cal, indent=2) + "\n", encoding="utf-8")
        summary["calendar"] = str(cal_path)

    return summary
