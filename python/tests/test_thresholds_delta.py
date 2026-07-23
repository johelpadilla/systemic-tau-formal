"""Explore numerical relation of thresholds to Feigenbaum δ."""

import numpy as np

from core.constants import DELTA, THETA_CHAOS, THETA_STABLE


def test_delta_candidates_near_chaos_threshold():
    """Document distance of common closed forms to operational 0.41.

    [CONJETURA] / [OPERACIONAL] — not a proof that 0.41 = f(δ).
    """
    candidates = {
        "2/delta": 2.0 / DELTA,
        "(delta-1)/(2*delta)": (DELTA - 1.0) / (2.0 * DELTA),
        "1/sqrt(delta)": 1.0 / np.sqrt(DELTA),
    }
    # Operational band edge must stay fixed for protocol stability
    assert THETA_CHAOS == 0.41
    assert THETA_STABLE == 0.50
    # Nearest simple form is recorded for formalization work
    nearest = min(candidates, key=lambda k: abs(candidates[k] - THETA_CHAOS))
    assert nearest in candidates
    # 2/δ ≈ 0.428 is within 0.03 of 0.41 (motivational proximity, not equality)
    assert abs(candidates["2/delta"] - THETA_CHAOS) < 0.03
