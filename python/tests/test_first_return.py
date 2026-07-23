"""First-return combinatorial skeleton tests."""

import numpy as np

from core.first_return import (
    first_return_crossing,
    first_return_from_local_maxima,
    nonneg_pred,
    return_pairs,
    section_values,
)


def test_return_pairs_shapes():
    assert return_pairs([]) == []
    assert return_pairs([1.0]) == []
    assert return_pairs([1.0, 2.0]) == [(1.0, 2.0)]
    assert return_pairs([1.0, 2.0, 3.0]) == [(1.0, 2.0), (2.0, 3.0)]


def test_section_nonneg():
    s = [-0.2, 0.0, 0.3, -0.1, 0.5]
    sec = section_values(s, nonneg_pred)
    assert list(sec) == [0.0, 0.3, 0.5]


def test_local_max_sine():
    t = np.linspace(0, 4 * np.pi, 200)
    y = np.sin(t)
    sec, pairs = first_return_from_local_maxima(y)
    assert len(sec) >= 2
    assert len(pairs) == len(sec) - 1
    # local maxima of sin near +1
    assert float(np.mean(sec)) > 0.5


def test_crossing_up():
    y = np.array([-0.2, -0.1, 0.05, 0.2, -0.05, 0.1], dtype=float)
    sec, pairs = first_return_crossing(y, level=0.0, direction="up")
    assert len(sec) >= 1
    assert all(x >= 0 for x in sec)
