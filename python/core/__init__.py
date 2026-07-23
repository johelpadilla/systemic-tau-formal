"""Minimal Systemic Tau + RECD reference core."""

from .constants import DELTA, THETA_CHAOS, THETA_STABLE
from .tau import compute_taus, kendall_tau
from .recd import accumulate_time, gate_function, compute_recd_increments
from .golden import gate_rat, golden_payload
from .io_data import load_matrix_csv, save_matrix_csv
from .synthetic import (
    add_column_noise,
    aedes_proxy_two_sites,
    anti_synchronized,
    coupled_logistic,
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
    "add_column_noise",
    "aedes_proxy_two_sites",
    "anti_synchronized",
    "coupled_logistic",
    "independent_noise",
    "regime_switch",
    "synchronized_seasonal",
]

__version__ = "0.1.0"
