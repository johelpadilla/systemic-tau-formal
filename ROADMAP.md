# Roadmap

Public status after **v0.1.6** (concept DOI [10.5281/zenodo.21516059](https://doi.org/10.5281/zenodo.21516059)).

## Done

- [x] Monorepo scaffold (Lean + Python + docs + notebooks)
- [x] Operational gate formalized (chaos formula, antitone, evenness, intermediate+)
- [x] Regime classification lemmas + nonnegative trichotomy
- [x] Python ↔ Lean golden bridge + CI
- [x] GitHub public + release `v0.1.4` + Zenodo DOI
- [x] Release `v0.1.5`: fixtures, P3/P4, Feigenbaum first-return skeleton, Binder
- [x] Release `v0.1.6`: C3 synthetic kits, first-return Python twin, τ_ch simple-candidate non-identity, Stress-Test 2026 board

## Near term (v0.2)

- [x] Documented Jupyter notebooks 01–03 (with CLI `.py` twins)
- [x] Feigenbaum module: strong unimodality example + honest open/sorry split (`docs/FEIGENBAUM_STATUS.md`)
- [x] Binder runtime files + badge (mybinder.org)
- [x] Synthetic fixtures + Aedes **proxy** CSVs (`data/synthetic/`, `data/aedes/proxy/`)
- [x] P3 noise / P4 anti-sync protocol tests + notebook `04_p3_noise_robustness.py`
- [x] Feigenbaum first-return skeleton + named open goals 1–3 (`docs/FEIGENBAUM_STATUS.md`)
- [x] First-return Python twin + notebook 05
- [x] C3 synthetic starters + notebook 06 + `docs/CROSS_DOMAIN.md`
- [x] Workshop brief + issue board
- [ ] Discharge open goals 1–3 / composite reduction `sorry` (research-level)
- [ ] **Licensed** real Aedes / dengue into `data/aedes/raw/` (intake path ready)
- [x] Mathlib dependency wired (`mathlib4` v4.14.0) + `FeigenbaumAnalytic` claim shapes
- [x] Real/`Tendsto` claim shapes (`FeigenbaumTendsto`; limit still open/`sorry`)
- [ ] Real/Tendsto **discharge** of cascade limit (research + ε–N bridge bookkeeping)

## Medium term

- [x] Partial: finite simple f(δ) candidates ≠ τ_ch (`docs/TAU_CH_DELTA.md`, Lean `failedSimpleCandidates`)
- [ ] Full derivation of τ_ch from δ *or* agreed larger class with uniqueness/non-existence
- [ ] Cross-domain **field** results (licensed data) — pending community / intake
- [ ] Workshop date / host (issue #1)

## Non-goals (for honesty)

- Proving ontological claims in Lean
- Replacing domain validation with formal proofs
- Claiming dengue lead times as theorems
