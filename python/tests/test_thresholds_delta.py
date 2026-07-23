"""Explore numerical relation of thresholds to Feigenbaum δ."""

import numpy as np

from core.constants import DELTA, THETA_CHAOS, THETA_STABLE
from core.golden import (
    DELTA_RAT,
    GATE_PREFACTOR,
    TAU_CHAOS,
    TWO_OVER_DELTA,
)


def test_delta_candidates_near_chaos_threshold():
    """Document distance of common closed forms to operational 0.41.

    [CONJETURA] / [OPERACIONAL] — not a proof that 0.41 = f(δ).
    """
    candidates = {
        "2/delta": 2.0 / DELTA,
        "(delta-1)/(2*delta)": (DELTA - 1.0) / (2.0 * DELTA),
        "1/sqrt(delta)": 1.0 / np.sqrt(DELTA),
        "1/delta": 1.0 / DELTA,
        "(delta-1)/delta": (DELTA - 1.0) / DELTA,
    }
    # Operational band edge must stay fixed for protocol stability
    assert THETA_CHAOS == 0.41
    assert THETA_STABLE == 0.50
    # Nearest simple form is recorded for formalization work
    nearest = min(candidates, key=lambda k: abs(candidates[k] - THETA_CHAOS))
    assert nearest in candidates
    # 2/δ ≈ 0.428 is within 0.03 of 0.41 (motivational proximity, not equality)
    assert abs(candidates["2/delta"] - THETA_CHAOS) < 0.03
    # None of the simple forms equals 0.41 exactly (mirrors Lean disequalities)
    for name, val in candidates.items():
        assert abs(val - THETA_CHAOS) > 1e-6, name


def test_golden_rational_candidates_ne_tau_chaos():
    """Exact rational side of Lean `failedSimpleCandidates`."""
    assert TWO_OVER_DELTA != TAU_CHAOS
    assert GATE_PREFACTOR != TAU_CHAOS
    assert DELTA_RAT != 0
    one_over = 1 / DELTA_RAT
    half_pref = GATE_PREFACTOR / 2
    assert one_over != TAU_CHAOS
    assert half_pref != TAU_CHAOS
