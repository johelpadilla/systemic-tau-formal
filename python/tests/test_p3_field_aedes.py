"""P3 noise scan on committed field Aedes series ([EMPÍRICO] provenance)."""

from __future__ import annotations

from pathlib import Path

import numpy as np
import pytest

from core import load_aedes_sites, p3_noise_scan

REPO = Path(__file__).resolve().parents[2]


@pytest.fixture(scope="module")
def raw_sites():
    result = load_aedes_sites(root=REPO, prefer_raw=True)
    if result.source != "raw":
        pytest.skip("no field CSVs in data/aedes/raw/")
    return result.sites


def test_p3_field_zero_noise_identity_agreement(raw_sites):
    name, X = next(iter(raw_sites.items()))
    rows = p3_noise_scan(X, rhos=(0.0,), window_size=13, seed=1)
    assert rows[0]["agree_vs_rho0"] == 1.0
    assert rows[0]["frac_chaos"] >= 0.5


@pytest.mark.parametrize("rho", [0.05, 0.10, 0.20])
def test_p3_field_agreement_usable_at_protocol_noise(raw_sites, rho):
    """
    Qualitative P3 on field: regime labels should not fully scramble at ρ≤0.20.

    Short trap series are noisier than long synthetic; threshold is looser than
    test_p3_noise (synthetic) but still requires majority agreement.
    """
    agreements = []
    for name, X in raw_sites.items():
        if X.shape[0] < 20:
            continue
        rows = p3_noise_scan(X, rhos=(0.0, rho), window_size=13, seed=42)
        r = next(x for x in rows if x["rho"] == rho)
        agreements.append((name, r["agree_vs_rho0"], r["frac_chaos"]))
    assert agreements, "no series long enough"
    # each series: agreement floor
    min_agree = 0.50 if rho < 0.20 else 0.45
    for name, agr, chaos in agreements:
        assert agr >= min_agree, f"{name} P3 field fail: agree={agr:.3f} at rho={rho}"
        # these San Juan series sit in chaos band at ρ=0; should not flip to all-stable
        assert chaos >= 0.40, f"{name} lost chaos band at rho={rho}: chaos={chaos:.3f}"
