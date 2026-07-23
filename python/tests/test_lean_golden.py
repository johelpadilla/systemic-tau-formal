"""Cross-check Python core against Lean-aligned golden rationals."""

from fractions import Fraction

import numpy as np
import pytest

from core.constants import DELTA, THETA_CHAOS, THETA_STABLE
from core.golden import (
    DELTA_RAT,
    FEIGENBAUM_DELTA_DEN,
    FEIGENBAUM_DELTA_NUM,
    GATE_PREFACTOR,
    GATE_SAMPLES,
    TAU_CHAOS,
    TAU_STABLE,
    TWO_OVER_DELTA,
    delta_inv_pow,
    gate_rat,
    golden_payload,
)
from core.recd import gate_function


def test_delta_matches_lean_integers():
    assert FEIGENBAUM_DELTA_NUM == 46692016091
    assert FEIGENBAUM_DELTA_DEN == 10000000000
    assert float(DELTA_RAT) == pytest.approx(DELTA, rel=0, abs=1e-12)


def test_thresholds_match_lean():
    assert TAU_STABLE == Fraction(1, 2)
    assert TAU_CHAOS == Fraction(41, 100)
    assert float(TAU_STABLE) == THETA_STABLE
    assert float(TAU_CHAOS) == THETA_CHAOS


def test_gate_prefactor_bounds():
    assert 0 < GATE_PREFACTOR < 1
    assert float(GATE_PREFACTOR) == pytest.approx((DELTA - 1.0) / DELTA)


def test_two_over_delta_gap():
    assert TWO_OVER_DELTA > TAU_CHAOS
    assert float(TWO_OVER_DELTA - TAU_CHAOS) == pytest.approx(
        2.0 / DELTA - THETA_CHAOS, abs=1e-12
    )


def test_gate_samples_match_float_impl():
    for t in GATE_SAMPLES:
        g_exact = gate_rat(t)
        g_float = gate_function(float(t))
        assert float(g_exact) == pytest.approx(g_float, abs=1e-12)


def test_gate_antitone_on_samples():
    a, b = Fraction(1, 10), Fraction(2, 10)
    assert a < b < TAU_CHAOS
    assert gate_rat(b) <= gate_rat(a)


def test_gate_chaos_formula():
    tau = Fraction(1, 10)
    expected = GATE_PREFACTOR * (TAU_CHAOS - tau) / TAU_CHAOS
    assert gate_rat(tau) == expected


def test_delta_inv_pow():
    assert delta_inv_pow(0) == 1
    assert delta_inv_pow(1) == Fraction(
        FEIGENBAUM_DELTA_DEN, FEIGENBAUM_DELTA_NUM
    )
    assert delta_inv_pow(2) == delta_inv_pow(1) * delta_inv_pow(1)


def test_golden_payload_schema():
    p = golden_payload()
    assert p["schema"] == "systemic-tau-formal/golden/v1"
    assert len(p["gate_samples"]) == len(GATE_SAMPLES)
    assert "gate_antitone_on_nonneg_chaos" in p["lemmas_checked_in_lean"]


def test_float_gate_vectorized_matches_rat():
    taus = np.array([float(t) for t in GATE_SAMPLES])
    g = gate_function(taus)
    for i, t in enumerate(GATE_SAMPLES):
        assert g[i] == pytest.approx(float(gate_rat(t)), abs=1e-12)
