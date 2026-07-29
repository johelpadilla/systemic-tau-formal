"""CHB-MIT EEG I/O: summary parsing, channel filter, epoch RMS aggregation.

Data: PhysioNet chbmit 1.0.0 (DOI 10.13026/C2K01R). Loading EDF requires optional
``mne`` or ``pyedflib`` (``pip install -e ".[eeg]"``).
"""

from __future__ import annotations

import re
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Dict, List, Optional, Sequence, Tuple

import numpy as np

# 10-20 labels often appear as bipolar montage strings in CHB-MIT (e.g. FP1-F7).
_NON_EEG_EXACT = {"-", "", "ECG", "EKG", "VNS", "ECG ECG", "EKG EKG"}
_NON_EEG_SUBSTR = ("ECG", "EKG", "VNS", "ECG-", "-ECG")


@dataclass(frozen=True)
class SeizureAnnotation:
    """One clinical seizure interval relative to the start of an EDF record."""

    case: str
    record: str  # e.g. chb01_03
    edf_relpath: str  # relative to raw root, e.g. chb01/chb01_03.edf
    seizure_index: int
    t_start_s: float
    t_end_s: float
    file_duration_s: Optional[float] = None

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class AggregatedEEG:
    """Epoch-aggregated multichannel matrix ready for τₛ."""

    X: np.ndarray  # (T_epochs, N)
    channel_names: List[str]
    epoch_s: float
    fs_hz: float
    feature: str
    n_raw_samples: int
    record: str

    @property
    def n_epochs(self) -> int:
        return int(self.X.shape[0])

    @property
    def n_channels(self) -> int:
        return int(self.X.shape[1])


def is_eeg_channel(name: str) -> bool:
    """Return True if channel name looks like scalp EEG (not dummy/ECG/VNS)."""
    n = (name or "").strip()
    if n in _NON_EEG_EXACT:
        return False
    up = n.upper()
    if up in _NON_EEG_EXACT:
        return False
    for sub in _NON_EEG_SUBSTR:
        if sub in up:
            return False
    # Common CHB bipolar tokens
    if re.search(r"[FPCTOZA]\d", up) or "FZ" in up or "CZ" in up or "PZ" in up:
        return True
    if "-" in n and any(c.isalpha() for c in n):
        return True
    # Conservative: unknown names dropped unless clearly EEG-like
    return bool(re.search(r"EEG", up))


def filter_eeg_channels(
    data: np.ndarray,
    ch_names: Sequence[str],
) -> Tuple[np.ndarray, List[str]]:
    """Keep EEG columns only. ``data`` shape (n_channels, n_times) or (n_times, n_channels)."""
    names = [str(c) for c in ch_names]
    # Heuristic orientation: if first dim == n names, channels-first
    if data.ndim != 2:
        raise ValueError("data must be 2-D")
    if data.shape[0] == len(names):
        ch_first = True
    elif data.shape[1] == len(names):
        ch_first = False
    else:
        raise ValueError(
            f"channel count {len(names)} matches neither axis {data.shape}"
        )
    keep_idx = [i for i, n in enumerate(names) if is_eeg_channel(n)]
    keep_names = [names[i] for i in keep_idx]
    if ch_first:
        out = data[keep_idx, :]
        return out, keep_names
    out = data[:, keep_idx]
    return out.T, keep_names  # return channels-first


# P1-EEG v1.1.0 frozen bands (docs/P1_EEG_CHBMIT_v1.1.md §3)
BANDS_HZ_4: Tuple[Tuple[float, float], ...] = (
    (0.5, 4.0),   # delta
    (4.0, 8.0),   # theta
    (8.0, 13.0),  # alpha
    (13.0, 30.0), # beta
)
BANDPOWER_EPS_DEFAULT = 1e-12


def epoch_rms(
    data_ch_first: np.ndarray,
    *,
    fs_hz: float,
    epoch_s: float = 1.0,
) -> np.ndarray:
    """
    Non-overlapping RMS aggregation.

    Parameters
    ----------
    data_ch_first : array, shape (n_channels, n_times)

    Returns
    -------
    X : array, shape (n_epochs, n_channels)
    """
    if data_ch_first.ndim != 2:
        raise ValueError("data_ch_first must be (n_channels, n_times)")
    if fs_hz <= 0 or epoch_s <= 0:
        raise ValueError("fs_hz and epoch_s must be positive")
    n_ch, n_times = data_ch_first.shape
    L = int(round(fs_hz * epoch_s))
    if L < 1:
        raise ValueError("epoch length in samples < 1")
    n_epochs = n_times // L
    if n_epochs < 1:
        raise ValueError("recording shorter than one epoch")
    trimmed = data_ch_first[:, : n_epochs * L].reshape(n_ch, n_epochs, L)
    # RMS over sample axis
    rms = np.sqrt(np.mean(np.square(trimmed.astype(np.float64)), axis=2))
    return rms.T  # (n_epochs, n_ch)


def epoch_log_bandpower_4(
    data_ch_first: np.ndarray,
    *,
    fs_hz: float,
    epoch_s: float = 2.0,
    eps: float = BANDPOWER_EPS_DEFAULT,
    bands_hz: Sequence[Tuple[float, float]] = BANDS_HZ_4,
    collapse: str = "chmean",
) -> np.ndarray:
    """
    Non-overlapping log10 bandpower — P1-EEG v1.1.

    Parameters
    ----------
    data_ch_first : array, shape (n_channels, n_times)
    collapse :
        - ``chmean`` (v1.1 freeze): mean of 4 log-bandpowers per channel →
          shape ``(n_epochs, n_channels)``. Keeps cross-channel τ cost like RMS
          while still using multi-band spectral energy (a priori reduction of
          full 4×N layout, which is O(N²) pairwise Kendall-infeasible at CHB scale).
        - ``full``: shape ``(n_epochs, 4 * n_channels)`` channel-major bands
          (diagnostic / unit tests only; not primary scorer).

    Returns
    -------
    X : array, shape depends on ``collapse``
    """
    if data_ch_first.ndim != 2:
        raise ValueError("data_ch_first must be (n_channels, n_times)")
    if fs_hz <= 0 or epoch_s <= 0:
        raise ValueError("fs_hz and epoch_s must be positive")
    bands = list(bands_hz)
    if len(bands) != 4:
        raise ValueError(f"v1.1 freezes 4 bands; got {len(bands)}")
    n_ch, n_times = data_ch_first.shape
    L = int(round(fs_hz * epoch_s))
    if L < 8:
        raise ValueError(f"epoch length in samples too short for FFT: L={L}")
    n_epochs = n_times // L
    if n_epochs < 1:
        raise ValueError("recording shorter than one epoch")
    trimmed = data_ch_first[:, : n_epochs * L].reshape(n_ch, n_epochs, L).astype(
        np.float64, copy=False
    )
    win = np.hanning(L)
    win_energy = float(np.sum(win**2))
    if win_energy <= 0:
        raise ValueError("degenerate Hann window")
    freqs = np.fft.rfftfreq(L, d=1.0 / float(fs_hz))
    band_masks = [(freqs >= float(lo)) & (freqs < float(hi)) for lo, hi in bands]
    scale = 1.0 / (float(fs_hz) * win_energy)
    windowed = trimmed * win.reshape(1, 1, L)
    spec = np.fft.rfft(windowed, axis=-1)
    psd = (np.abs(spec) ** 2) * scale
    if L % 2 == 0:
        psd[..., 1:-1] *= 2.0
    else:
        psd[..., 1:] *= 2.0
    # energies: (n_ch, n_epochs, 4)
    energies = np.stack(
        [np.sum(psd[..., m], axis=-1) for m in band_masks],
        axis=-1,
    )
    log_e = np.log10(energies + float(eps))  # (n_ch, n_epochs, 4)
    if collapse == "full":
        # (n_epochs, 4*n_ch) channel-major
        return log_e.transpose(1, 0, 2).reshape(n_epochs, 4 * n_ch)
    if collapse == "chmean":
        # mean across bands → (n_epochs, n_ch)
        return np.mean(log_e, axis=-1).T
    raise ValueError(f"unknown collapse={collapse!r}; use 'chmean' or 'full'")


def expand_bandpower_channel_names(
    eeg_names: Sequence[str], *, collapse: str = "chmean"
) -> List[str]:
    """Column labels for log_bandpower layouts."""
    if collapse == "chmean":
        return [f"{n}|bp4mean" for n in eeg_names]
    band_tags = ("delta", "theta", "alpha", "beta")
    out: List[str] = []
    for name in eeg_names:
        for b in band_tags:
            out.append(f"{name}|{b}")
    return out


def seconds_to_epoch(t_s: float, epoch_s: float = 1.0) -> int:
    return int(np.floor(float(t_s) / float(epoch_s)))


def epoch_to_seconds(epoch_idx: int, epoch_s: float = 1.0) -> float:
    return float(epoch_idx) * float(epoch_s)


# ---------------------------------------------------------------------------
# Summary parser
# ---------------------------------------------------------------------------

_FILE_RE = re.compile(r"^File Name:\s*(.+\.edf)\s*$", re.I)
_START_RE = re.compile(r"^File Start Time:\s*(.+)\s*$", re.I)
_END_RE = re.compile(r"^File End Time:\s*(.+)\s*$", re.I)
_NSEIZ_RE = re.compile(r"^Number of Seizures in File:\s*(\d+)\s*$", re.I)
_SEIZ_START_RE = re.compile(
    r"^Seizure\s+(?:(\d+)\s+)?Start Time:\s*(\d+(?:\.\d+)?)\s*seconds\s*$", re.I
)
_SEIZ_END_RE = re.compile(
    r"^Seizure\s+(?:(\d+)\s+)?End Time:\s*(\d+(?:\.\d+)?)\s*seconds\s*$", re.I
)


def _parse_hhmmss_duration(start: str, end: str) -> Optional[float]:
    """Best-effort duration from HH:MM:SS clocks (may wrap midnight)."""

    def to_s(tok: str) -> Optional[float]:
        parts = tok.strip().replace(".", ":").split(":")
        try:
            if len(parts) == 3:
                h, m, s = (int(parts[0]), int(parts[1]), float(parts[2]))
            elif len(parts) == 2:
                h, m, s = 0, int(parts[0]), float(parts[1])
            else:
                return None
            return h * 3600 + m * 60 + s
        except ValueError:
            return None

    a, b = to_s(start), to_s(end)
    if a is None or b is None:
        return None
    d = b - a
    if d < 0:
        d += 24 * 3600
    return float(d)


def parse_chbmit_summary(path: Path, *, case: Optional[str] = None) -> List[SeizureAnnotation]:
    """
    Parse ``chbNN-summary.txt`` into seizure annotations.

    Handles both ``Seizure Start Time:`` and ``Seizure 1 Start Time:`` styles.
    """
    path = Path(path)
    text = path.read_text(encoding="utf-8", errors="replace")
    if case is None:
        # chb01-summary.txt → chb01
        m = re.match(r"(chb\d+)", path.name, re.I)
        case = m.group(1).lower() if m else path.stem.split("-")[0].lower()

    out: List[SeizureAnnotation] = []
    current_file: Optional[str] = None
    file_start: Optional[str] = None
    file_end: Optional[str] = None
    pending_starts: List[Tuple[Optional[str], float]] = []

    def flush_file_meta() -> Optional[float]:
        if file_start and file_end:
            return _parse_hhmmss_duration(file_start, file_end)
        return None

    for line in text.splitlines():
        line = line.strip()
        if not line:
            continue
        m = _FILE_RE.match(line)
        if m:
            current_file = m.group(1).strip()
            file_start = file_end = None
            pending_starts = []
            continue
        m = _START_RE.match(line)
        if m:
            file_start = m.group(1).strip()
            continue
        m = _END_RE.match(line)
        if m:
            file_end = m.group(1).strip()
            continue
        if _NSEIZ_RE.match(line):
            continue
        m = _SEIZ_START_RE.match(line)
        if m:
            pending_starts.append((m.group(1), float(m.group(2))))
            continue
        m = _SEIZ_END_RE.match(line)
        if m and pending_starts:
            idx_tok, t_end = m.group(1), float(m.group(2))
            s_tok, t_start = pending_starts.pop(0)
            if current_file is None:
                continue
            record = Path(current_file).stem
            seiz_i = int(idx_tok or s_tok or len(out))
            # seizure_index 0-based within record by order
            prior = sum(1 for a in out if a.record == record)
            dur = flush_file_meta()
            rel = f"{case}/{current_file}" if not current_file.startswith(case) else current_file
            # normalize relpath
            if "/" not in current_file:
                rel = f"{case}/{current_file}"
            else:
                rel = current_file
            out.append(
                SeizureAnnotation(
                    case=case,
                    record=record,
                    edf_relpath=rel.replace("\\", "/"),
                    seizure_index=prior if s_tok is None and idx_tok is None else prior,
                    t_start_s=float(t_start),
                    t_end_s=float(t_end),
                    file_duration_s=dur,
                )
            )
            # fix index to sequential per record
            out[-1] = SeizureAnnotation(
                case=out[-1].case,
                record=out[-1].record,
                edf_relpath=out[-1].edf_relpath,
                seizure_index=prior,
                t_start_s=out[-1].t_start_s,
                t_end_s=out[-1].t_end_s,
                file_duration_s=out[-1].file_duration_s,
            )
    return out


def discover_summaries(raw_root: Path) -> List[Path]:
    raw_root = Path(raw_root)
    return sorted(raw_root.glob("**/chb*-summary.txt"))


def parse_all_summaries(raw_root: Path, *, cases: Optional[Sequence[str]] = None) -> List[SeizureAnnotation]:
    raw_root = Path(raw_root)
    ann: List[SeizureAnnotation] = []
    for p in discover_summaries(raw_root):
        m = re.search(r"(chb\d+)", p.name, re.I)
        case = m.group(1).lower() if m else None
        if cases is not None and case not in {c.lower() for c in cases}:
            continue
        ann.extend(parse_chbmit_summary(p, case=case))
    return ann


# ---------------------------------------------------------------------------
# EDF loading (optional backends)
# ---------------------------------------------------------------------------

def _load_edf_mne(path: Path) -> Tuple[np.ndarray, List[str], float]:
    import mne  # type: ignore

    raw = mne.io.read_raw_edf(str(path), preload=True, verbose="ERROR")
    data = raw.get_data()  # (n_ch, n_times)
    names = list(raw.ch_names)
    fs = float(raw.info["sfreq"])
    return data, names, fs


def _load_edf_pyedflib(path: Path) -> Tuple[np.ndarray, List[str], float]:
    import pyedflib  # type: ignore

    r = pyedflib.EdfReader(str(path))
    try:
        n = r.signals_in_file
        names = [str(r.getLabel(i)).strip() for i in range(n)]
        fs_list = [float(r.getSampleFrequency(i)) for i in range(n)]
        fs = float(fs_list[0])
        sigs = []
        for i in range(n):
            sigs.append(r.readSignal(i).astype(np.float64))
        # truncate to min length
        L = min(len(s) for s in sigs)
        data = np.vstack([s[:L] for s in sigs])
        return data, names, fs
    finally:
        r.close()


def load_edf_channels(path: Path) -> Tuple[np.ndarray, List[str], float]:
    """
    Load EDF → (data channels-first, names, fs_hz).

    Tries ``mne`` then ``pyedflib``.
    """
    path = Path(path)
    if not path.is_file():
        raise FileNotFoundError(path)
    errors: List[str] = []
    for loader, name in ((_load_edf_mne, "mne"), (_load_edf_pyedflib, "pyedflib")):
        try:
            return loader(path)
        except ImportError as e:
            errors.append(f"{name}: not installed ({e})")
        except Exception as e:  # backend-specific read errors
            errors.append(f"{name}: {e}")
    raise ImportError(
        "Could not load EDF. Install optional EEG deps: pip install -e \".[eeg]\" "
        f"(mne and/or pyedflib). Details: {'; '.join(errors)}"
    )


def load_and_aggregate(
    edf_path: Path,
    *,
    epoch_s: float = 1.0,
    feature: str = "rms",
    record: Optional[str] = None,
    bandpower_eps: float = BANDPOWER_EPS_DEFAULT,
) -> AggregatedEEG:
    """Load EDF, filter EEG channels, aggregate to epoch feature matrix.

    Supported features:
    - ``rms`` — P1-EEG v1.0.0
    - ``log_bandpower_4`` — P1-EEG v1.1.0 (columns = 4 bands × EEG channels)
    """
    data, names, fs = load_edf_channels(edf_path)
    data_eeg, eeg_names = filter_eeg_channels(data, names)
    if data_eeg.shape[0] < 1:
        raise ValueError(f"no EEG channels kept from {edf_path}")
    if feature == "rms":
        X = epoch_rms(data_eeg, fs_hz=fs, epoch_s=epoch_s)
        ch_out = eeg_names
    elif feature in ("log_bandpower_4", "log_bandpower_4_chmean"):
        # v1.1 primary: chmean collapse (see docs/P1_EEG_CHBMIT_v1.1.md §3.0)
        X = epoch_log_bandpower_4(
            data_eeg,
            fs_hz=fs,
            epoch_s=epoch_s,
            eps=bandpower_eps,
            collapse="chmean",
        )
        ch_out = expand_bandpower_channel_names(eeg_names, collapse="chmean")
        feature = "log_bandpower_4_chmean"
    else:
        raise ValueError(
            f"unsupported feature={feature!r}; use 'rms' (v1.0) or "
            "'log_bandpower_4_chmean' (v1.1). Bump protocol version for others."
        )
    return AggregatedEEG(
        X=X,
        channel_names=ch_out,
        epoch_s=float(epoch_s),
        fs_hz=float(fs),
        feature=str(feature),
        n_raw_samples=int(data_eeg.shape[1]),
        record=record or Path(edf_path).stem,
    )


def resolve_edf(raw_root: Path, edf_relpath: str) -> Path:
    raw_root = Path(raw_root)
    p = raw_root / edf_relpath
    if p.is_file():
        return p
    # try basename search
    name = Path(edf_relpath).name
    hits = list(raw_root.rglob(name))
    if len(hits) == 1:
        return hits[0]
    if hits:
        return hits[0]
    raise FileNotFoundError(f"EDF not found under {raw_root}: {edf_relpath}")
