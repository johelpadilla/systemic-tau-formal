# Roadmap

Public status after **v0.1.5** (concept DOI [10.5281/zenodo.21516059](https://doi.org/10.5281/zenodo.21516059)).

## Done

- [x] Monorepo scaffold (Lean + Python + docs + notebooks)
- [x] Operational gate formalized (chaos formula, antitone, evenness, intermediate+)
- [x] Regime classification lemmas + nonnegative trichotomy
- [x] Python ↔ Lean golden bridge + CI
- [x] GitHub public + release `v0.1.4` + Zenodo DOI
- [x] Release `v0.1.5`: fixtures, P3/P4, Feigenbaum first-return skeleton, Binder

## Near term (v0.2)

- [x] Documented Jupyter notebooks 01–03 (with CLI `.py` twins)
- [x] Feigenbaum module: strong unimodality example + honest open/sorry split (`docs/FEIGENBAUM_STATUS.md`)
- [x] Binder runtime files + badge (mybinder.org)
- [x] Synthetic fixtures + Aedes **proxy** CSVs (`data/synthetic/`, `data/aedes/proxy/`)
- [x] P3 noise / P4 anti-sync protocol tests + notebook `04_p3_noise_robustness.py`
- [x] Feigenbaum first-return skeleton + named open goals 1–3 (`docs/FEIGENBAUM_STATUS.md`)
- [ ] Discharge open goals 1–3 / composite reduction `sorry` (research-level)
- [ ] **Licensed** real Aedes / dengue into `data/aedes/raw/` (intake path ready)
- [ ] Optional Mathlib dependency for analytic Feigenbaum path

## Medium term

- [x] Partial: finite simple f(δ) candidates ≠ τ_ch (`docs/TAU_CH_DELTA.md`, Lean `failedSimpleCandidates`)
- [ ] Full derivation of τ_ch from δ *or* agreed larger class with uniqueness/non-existence
- [x] Stress-Test 2026 workshop brief + issue board (`docs/WORKSHOP_STRESS_TEST_2026.md`, `docs/ISSUE_BOARD.md`)
- [x] First-return Python twin (`python/core/first_return.py`, notebook 05)
- [ ] Cross-domain challenge track (finance / EEG / networks) — templates ready; results pending

## Non-goals (for honesty)

- Proving ontological claims in Lean
- Replacing domain validation with formal proofs
- Claiming dengue lead times as theorems
