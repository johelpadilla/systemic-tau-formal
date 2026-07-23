"""Minimal Systemic Tau + RECD reference core."""

from .constants import DELTA, THETA_CHAOS, THETA_STABLE
from .tau import compute_taus, kendall_tau
from .recd import accumulate_time, gate_function, compute_recd_increments
from .golden import gate_rat, golden_payload

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
]

__version__ = "0.1.0"
