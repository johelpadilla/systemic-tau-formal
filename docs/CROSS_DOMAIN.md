# Cross-domain track (C3) — starter kits

**Label:** synthetic demos here are `[OPERACIONAL]`.  
Field / market / clinical / SCADA results are `[EMPÍRICO]` only with license + protocol.

## Purpose

Lower the cost of attempting **challenge C3** (domain transfer) without pretending that synthetic panels *are* those domains.

| Generator | Module | Synthetic story | Known break |
|-----------|--------|-----------------|-------------|
| Multi-asset returns | `finance_like_returns` | Factor model correlation break | `t_break` |
| Multi-channel oscillators | `eeg_like_channels` | Phase-locked → independent | `t_desync` |
| Nodal load proxies | `grid_like_loads` | Common diurnal + asymmetric shock | `t_event` |

Code: `python/core/synthetic.py`  
Summary helper: `python/core/report.py` (`pipeline_report`)  
CLI: `notebooks/06_cross_domain_c3.py`

## How to run

```bash
cd python && pip install -e ".[dev]" && pytest -q tests/test_cross_domain.py
cd .. && python notebooks/06_cross_domain_c3.py
```

## What counts as a real C3 hit

Not this starter kit alone. A hit requires:

1. Real domain data with **license** and citation  
2. Pre-registered endpoint (protocol)  
3. Report per `EXPERIMENTAL_PROTOCOL.md` §7  
4. Explicit **confirm or refute** of P1–P4 / operational ontology  
5. GitHub issue label `new-domain` (tracking: issue #4)

## P1-EEG clinical track (CHB-MIT) — serious protocol

Gold-standard **clinical `t_obs`** (annotated seizure onset) for domain transfer:

| Item | Path |
|------|------|
| Protocol (frozen v1.0.0) | [`P1_EEG_CHBMIT.md`](P1_EEG_CHBMIT.md) |
| Data layout / download | [`../data/chbmit/README.md`](../data/chbmit/README.md) |
| Core | `python/core/chbmit_io.py`, `python/core/p1_eeg.py` |
| CLI | `notebooks/12_chbmit_p1_eeg.py` |
| CI tests | `python/tests/test_p1_eeg_chbmit.py` (synthetic; no 42 GB) |

**Label:** `[EMPÍRICO]` C3 neuro. Lead horizon in **seconds** (30–300 s), not dengue 4–6 weeks.  
Integrity: SHA-256 lock of pre-registered endpoints before scoring.

```bash
cd python && pip install -e ".[dev,eeg]"
pytest -q tests/test_p1_eeg_chbmit.py
python ../notebooks/12_chbmit_p1_eeg.py selftest
```

## P1-ILI influenza track (HHS → FluSurv)

Multi-region outpatient ILI with **external** hospital-rate endpoint:

| Item | Path |
|------|------|
| Protocol (frozen v1.0.0) | [`P1_ILI_EXTERNAL_TOBS.md`](P1_ILI_EXTERNAL_TOBS.md) |
| Score report | [`P1_ILI_REPORT.md`](P1_ILI_REPORT.md) |
| Data | [`../data/ili/`](../data/ili/) |
| Core | `python/core/ili_io.py`, `python/core/p1_ili.py` |
| CLI | `notebooks/15_ili_p1_external.py` |

**Label:** `[EMPÍRICO]` C3 respiratory. Lead 4–6 **weeks**. Primary lock: FluSurv peak **0/10**.

```bash
python notebooks/15_ili_p1_external.py status
python notebooks/15_ili_p1_external.py score
cd python && pytest -q tests/test_p1_ili.py
```

## P1-Synthetic Canonical (instrument)

Controlled order→chaos plant with the **same** frozen P1 detector as field tracks:

| Item | Path |
|------|------|
| Protocol | [`P1_SYNTHETIC_CANONICAL.md`](P1_SYNTHETIC_CANONICAL.md) |
| Report | [`P1_SYNTHETIC_CANONICAL_REPORT.md`](P1_SYNTHETIC_CANONICAL_REPORT.md) |
| Data | [`../data/synthetic/p1_canonical/`](../data/synthetic/p1_canonical/) |
| CLI | `notebooks/16_p1_synthetic_canonical.py` |

**Result (v1.0.0):** G1–G4 **INSTRUMENT_PASS** (plant 20/20). Does **not** discharge empirical P1.

```bash
python notebooks/16_p1_synthetic_canonical.py run
cd python && pytest -q tests/test_p1_synthetic.py
```

## Related

- Challenge text: [`CHALLENGES.md`](CHALLENGES.md)  
- Workshop tracks: [`WORKSHOP_STRESS_TEST_2026.md`](WORKSHOP_STRESS_TEST_2026.md)  
- Falsifiable list: [`FALSIFIABLE_PREDICTIONS.md`](FALSIFIABLE_PREDICTIONS.md)
