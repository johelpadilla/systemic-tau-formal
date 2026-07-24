"""Explore numerical relation of thresholds to Feigenbaum δ.

Mirrors Lean `failedSimpleCandidates` + `ThresholdFromDelta` (issue #7).
"""

from fractions import Fraction

import numpy as np

from core.constants import DELTA, THETA_CHAOS, THETA_STABLE
from core.golden import (
    DELTA_RAT,
    FEIGENBAUM_DELTA_DEN,
    FEIGENBAUM_DELTA_NUM,
    GATE_PREFACTOR,
    TAU_CHAOS,
    TAU_STABLE,
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
        "2/(delta+1)": 2.0 / (DELTA + 1.0),
        "(delta-2)/delta": (DELTA - 2.0) / DELTA,
        "3/(2*delta)": 3.0 / (2.0 * DELTA),
        "4/delta**2": 4.0 / (DELTA**2),
        "5/delta": 5.0 / DELTA,
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
    """Exact rational side of Lean `failedSimpleCandidates` (extended #7)."""
    assert TWO_OVER_DELTA != TAU_CHAOS
    assert GATE_PREFACTOR != TAU_CHAOS
    assert DELTA_RAT != 0
    one_over = Fraction(FEIGENBAUM_DELTA_DEN, FEIGENBAUM_DELTA_NUM)
    half_pref = GATE_PREFACTOR / 2
    two_over_plus = Fraction(
        2 * FEIGENBAUM_DELTA_DEN, FEIGENBAUM_DELTA_NUM + FEIGENBAUM_DELTA_DEN
    )
    delta_m2 = Fraction(
        FEIGENBAUM_DELTA_NUM - 2 * FEIGENBAUM_DELTA_DEN, FEIGENBAUM_DELTA_NUM
    )
    three_half = Fraction(3 * FEIGENBAUM_DELTA_DEN, 2 * FEIGENBAUM_DELTA_NUM)
    four_sq = Fraction(
        4 * FEIGENBAUM_DELTA_DEN * FEIGENBAUM_DELTA_DEN,
        FEIGENBAUM_DELTA_NUM * FEIGENBAUM_DELTA_NUM,
    )
    five_over = Fraction(5 * FEIGENBAUM_DELTA_DEN, FEIGENBAUM_DELTA_NUM)
    for name, val in {
        "1/delta": one_over,
        "half_pref": half_pref,
        "2/(delta+1)": two_over_plus,
        "(delta-2)/delta": delta_m2,
        "3/(2delta)": three_half,
        "4/delta^2": four_sq,
        "5/delta": five_over,
        "tau_st": TAU_STABLE,
    }.items():
        assert val != TAU_CHAOS, name


def test_unique_inverse_scale_bridge_python():
    """Mirror Lean `ThresholdFromDelta`: unique c with c/δ_op = τ_ch."""
    c_star = TAU_CHAOS * DELTA_RAT
    f_at_op = c_star / DELTA_RAT
    assert f_at_op == TAU_CHAOS
    # Any other scale fails the pin
    assert (Fraction(2) / DELTA_RAT) != TAU_CHAOS
    # Antitone sample: larger δ ⇒ smaller f
    f_lo = c_star / Fraction(4)
    f_hi = c_star / Fraction(5)
    assert f_hi < f_lo
