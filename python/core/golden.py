"""
Golden constants shared with Lean (SystemicTau.Basic / Thresholds / RECD).

[OPERACIONAL] Exact rational identities; floats are derived for runtime.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Any, Dict, List

# Match lean/SystemicTau/Basic.lean
FEIGENBAUM_DELTA_NUM = 46692016091
FEIGENBAUM_DELTA_DEN = 10000000000

DELTA_RAT = Fraction(FEIGENBAUM_DELTA_NUM, FEIGENBAUM_DELTA_DEN)
TAU_STABLE = Fraction(1, 2)
TAU_CHAOS = Fraction(41, 100)
GATE_PREFACTOR = Fraction(
    FEIGENBAUM_DELTA_NUM - FEIGENBAUM_DELTA_DEN, FEIGENBAUM_DELTA_NUM
)
TWO_OVER_DELTA = Fraction(2 * FEIGENBAUM_DELTA_DEN, FEIGENBAUM_DELTA_NUM)


def abs_rat(q: Fraction) -> Fraction:
    return q if q >= 0 else -q


def gate_rat(tau: Fraction) -> Fraction:
    """Exact rational gate matching Lean `gate`."""
    if tau >= TAU_STABLE:
        return Fraction(1)
    if abs_rat(tau) < TAU_CHAOS:
        return GATE_PREFACTOR * (TAU_CHAOS - abs_rat(tau)) / TAU_CHAOS
    if tau <= -TAU_CHAOS:
        return Fraction(-1)
    return Fraction(0)


def delta_inv_pow(k: int) -> Fraction:
    """δ^{-k} as rational, matching Lean deltaInvPow."""
    acc = Fraction(1)
    inv = Fraction(FEIGENBAUM_DELTA_DEN, FEIGENBAUM_DELTA_NUM)
    for _ in range(k):
        acc *= inv
    return acc


# Sample points used as cross-language golden vectors
GATE_SAMPLES: List[Fraction] = [
    Fraction(3, 4),
    Fraction(-3, 4),
    Fraction(45, 100),
    Fraction(0),
    Fraction(1, 10),
    Fraction(2, 10),
    Fraction(41, 100) - Fraction(1, 1000),  # just inside chaos
    Fraction(1, 2),
]


def golden_payload() -> Dict[str, Any]:
    """JSON-serializable payload (numerator/denominator pairs)."""

    def fr(q: Fraction) -> List[int]:
        return [q.numerator, q.denominator]

    return {
        "schema": "systemic-tau-formal/golden/v1",
        "feigenbaum_delta": fr(DELTA_RAT),
        "tau_stable": fr(TAU_STABLE),
        "tau_chaos": fr(TAU_CHAOS),
        "gate_prefactor": fr(GATE_PREFACTOR),
        "two_over_delta": fr(TWO_OVER_DELTA),
        "two_over_delta_gap": fr(TWO_OVER_DELTA - TAU_CHAOS),
        "delta_inv_pow": {str(k): fr(delta_inv_pow(k)) for k in range(0, 5)},
        "gate_samples": [
            {"tau": fr(t), "gate": fr(gate_rat(t))} for t in GATE_SAMPLES
        ],
        "lemmas_checked_in_lean": [
            "tauChaos_lt_tauStable",
            "gatePrefactor_bounds",
            "twoOverDelta_gt_tauChaos",
            "gate_stable_pos",
            "gate_anti_neg",
            "gate_intermediate_zero",
            "gate_at_zero",
            "gate_antitone_on_nonneg_chaos",
            "gate_chaos_nonneg_formula",
        ],
    }
