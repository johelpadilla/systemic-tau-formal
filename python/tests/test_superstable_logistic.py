"""
Python twin of SystemicTau.FeigenbaumSuperstable.

Checks:
  · period-1 superstable r = 2
  · period-2 superstable r = 1 + sqrt(5) ≈ 3.236
  · r = 3 is *not* period-2 superstable (onset ≠ superstable)
  · period-4 residual vanishes near literature pin ≈ 3.498561
  · strict exclusion: period-1/2 roots also zero the period-4 residual
"""

from __future__ import annotations

import math

import pytest


def logistic(r: float, x: float) -> float:
    return r * x * (1.0 - x)


def logistic_iter(r: float, n: int, x: float) -> float:
    for _ in range(n):
        x = logistic(r, x)
    return x


CRIT = 0.5


def is_superstable(n: int, r: float, tol: float = 1e-10) -> bool:
    """f^{2^n}(1/2) ≈ 1/2."""
    return abs(logistic_iter(r, 2**n, CRIT) - CRIT) < tol


def period2_poly(r: float) -> float:
    return r**3 - 4 * r**2 + 8


def period4_residual(r: float) -> float:
    return logistic_iter(r, 4, CRIT) - CRIT


class TestPeriod1:
    def test_two_is_superstable(self) -> None:
        assert is_superstable(0, 2.0)

    def test_unique_nearby(self) -> None:
        # Only r=2 zeros f(crit)-crit = r/4 - 1/2 on a coarse grid
        hits = [r for r in [i * 0.05 for i in range(1, 80)] if is_superstable(0, r, tol=1e-8)]
        assert hits == pytest.approx([2.0], abs=1e-8) or (
            len(hits) == 1 and abs(hits[0] - 2.0) < 1e-8
        )


class TestPeriod2:
    def test_one_plus_sqrt5(self) -> None:
        r = 1.0 + math.sqrt(5.0)
        assert 2.0 < r < 4.0
        assert is_superstable(1, r)
        assert abs(period2_poly(r)) < 1e-12

    def test_three_is_not_superstable(self) -> None:
        assert not is_superstable(1, 3.0, tol=1e-8)
        assert abs(period2_poly(3.0) + 1.0) < 1e-12  # poly(3) = -1

    def test_poly_roots(self) -> None:
        # Roots: 2, 1±√5
        for r in (2.0, 1 + math.sqrt(5), 1 - math.sqrt(5)):
            assert abs(period2_poly(r)) < 1e-12

    def test_strict_excludes_period1(self) -> None:
        r = 1.0 + math.sqrt(5.0)
        assert is_superstable(1, r)
        assert not is_superstable(0, r)


class TestPeriod4:
    def test_residual_char_at_lower_roots(self) -> None:
        # Divisor roots also zero the period-4 residual
        assert abs(period4_residual(2.0)) < 1e-12
        r2 = 1.0 + math.sqrt(5.0)
        assert abs(period4_residual(r2)) < 1e-10

    def test_literature_pin_near_root(self) -> None:
        # Operational pin ≈ 3.498561 (not proved equal in Lean)
        r_op = 3498561 / 1000000
        assert 3.0 < r_op < 4.0
        res = abs(period4_residual(r_op))
        # Should be small compared to residual at 3.4 or 3.6
        res_lo = abs(period4_residual(3.4))
        res_hi = abs(period4_residual(3.6))
        assert res < res_lo
        assert res < res_hi
        assert res < 5e-3  # coarse numerical neighborhood

    def test_bisection_finds_strict_root(self) -> None:
        """Numerical existence of a root of period4 residual in (1+√5, 4)."""
        a = 1.0 + math.sqrt(5.0) + 1e-3
        b = 3.9
        fa = period4_residual(a)
        fb = period4_residual(b)
        # Prefer an interval that changes sign
        if fa * fb > 0:
            # scan for sign change
            xs = [a + (b - a) * i / 50 for i in range(51)]
            found = False
            for i in range(len(xs) - 1):
                if period4_residual(xs[i]) * period4_residual(xs[i + 1]) <= 0:
                    a, b = xs[i], xs[i + 1]
                    found = True
                    break
            assert found, "no sign change for period-4 residual"
        for _ in range(60):
            m = 0.5 * (a + b)
            if period4_residual(a) * period4_residual(m) <= 0:
                b = m
            else:
                a = m
        r = 0.5 * (a + b)
        assert is_superstable(2, r, tol=1e-8)
        assert not is_superstable(0, r, tol=1e-8)
        assert not is_superstable(1, r, tol=1e-8)
        assert 3.4 < r < 3.6  # classical neighborhood

    def test_cascade_window_sign_change(self) -> None:
        """Lean cascade isolating window [3.498, 3.499]."""
        lo, hi = 3.498, 3.499
        assert period4_residual(lo) < 0
        assert period4_residual(hi) > 0

    def test_secondary_window_sign_change(self) -> None:
        """Secondary residual zero near 3.96 — uniqueness fails on full (1+√5,4)."""
        lo, hi = 3.960, 3.961
        assert period4_residual(lo) > 0
        assert period4_residual(hi) < 0
        # Disjoint from cascade window
        assert hi > 3.499


class TestAnchoredHonesty:
    def test_anchored_r0_is_superstable(self) -> None:
        assert is_superstable(0, 2.0)

    def test_anchored_r1_is_not_period2_superstable(self) -> None:
        assert not is_superstable(1, 3.0)
