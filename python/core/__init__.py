"""Minimal Systemic Tau + RECD reference core."""

from .constants import DELTA, THETA_CHAOS, THETA_STABLE
from .tau import compute_taus, kendall_tau
from .recd import accumulate_time, gate_function, compute_recd_increments
from .golden import gate_rat, golden_payload
from .io_data import load_matrix_csv, save_matrix_csv
from .first_return import (
    first_return_crossing,
    first_return_from_local_maxima,
    nonneg_pred,
    return_pairs,
    section_values,
)
from .report import format_report, pipeline_report
from .synthetic import (
    add_column_noise,
    aedes_proxy_two_sites,
    anti_synchronized,
    coupled_logistic,
    eeg_like_channels,
    finance_like_returns,
    grid_like_loads,
    independent_noise,
    regime_switch,
    synchronized_seasonal,
)

__all__ = [
    "DELTA",
    "THETA_CHAOS",
    "THETA_STABLE",
    "kendall_tau",
    "compute_taus",
    "gate_function",
    "compute_recd_increments",
    "accumulate_time",
    "gate_rat",
    "golden_payload",
    "load_matrix_csv",
    "save_matrix_csv",
    "first_return_crossing",
    "first_return_from_local_maxima",
    "nonneg_pred",
    "return_pairs",
    "section_values",
    "add_column_noise",
    "aedes_proxy_two_sites",
    "anti_synchronized",
    "coupled_logistic",
    "eeg_like_channels",
    "finance_like_returns",
    "grid_like_loads",
    "independent_noise",
    "regime_switch",
    "synchronized_seasonal",
    "pipeline_report",
    "format_report",
]

__version__ = "0.1.6"
