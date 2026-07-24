# Roadmap

Public status after **v0.1.8** (concept DOI [10.5281/zenodo.21516059](https://doi.org/10.5281/zenodo.21516059)).

## Done

- [x] Monorepo scaffold (Lean + Python + docs + notebooks)
- [x] Operational gate formalized (chaos formula, antitone, evenness, intermediate+)
- [x] Regime classification lemmas + nonnegative trichotomy
- [x] Python ↔ Lean golden bridge + CI
- [x] GitHub public + release `v0.1.4` + Zenodo DOI
- [x] Release `v0.1.5`: fixtures, P3/P4, Feigenbaum first-return skeleton, Binder
- [x] Release `v0.1.6`: C3 synthetic kits, first-return Python twin, τ_ch simple-candidate non-identity, Stress-Test 2026 board
- [x] Release `v0.1.7`: Mathlib + Tendsto interfaces; ε–N↔Tendsto; goals 1a/2a/C∘; `docs/FORMAL_OBLIGATIONS.md`
- [x] Release `v0.1.8`: zero sorry/axiom; logistic scale-ID; C²/Schwarzian; non-tent τₛ lab return; docs aligned

## Near term (v0.2)

- [x] Formal obligations map for scrutiny (`docs/FORMAL_OBLIGATIONS.md`)
- [x] Cut release **v0.1.7** + Zenodo new version (formal bookkeeping track)
- [x] Cut release **v0.1.8** + Zenodo (construction pack + honesty docs)
- [ ] Cut **v0.2** when workshop date and/or licensed Aedes intake land (or further formal discharge)
- [x] Documented Jupyter notebooks 01–03 (with CLI `.py` twins)
- [x] Feigenbaum module: strong unimodality example + honest open/sorry split (`docs/FEIGENBAUM_STATUS.md`)
- [x] Binder runtime files + badge (mybinder.org)
- [x] Synthetic fixtures + Aedes **proxy** CSVs (`data/synthetic/`, `data/aedes/proxy/`)
- [x] P3 noise / P4 anti-sync protocol tests + notebook `04_p3_noise_robustness.py`
- [x] Feigenbaum first-return skeleton + named open goals 1–3 (`docs/FEIGENBAUM_STATUS.md`)
- [x] First-return Python twin + notebook 05
- [x] C3 synthetic starters + notebook 06 + `docs/CROSS_DOMAIN.md`
- [x] Workshop brief + issue board
- [x] Feigenbaum goal **1a** (functional pairs realizer) + **2a** (strong⇒quadratic) + composite-of-hypotheses skeleton
- [ ] Discharge open goals **1b–3** / composite from `H` alone (research-level)
- [x] Real Aedes into `data/aedes/raw/` (SJU1/2/3 2018 + raw-first loader + nb 07 report)
- [x] P3 noise scan on field Aedes (nb 08 + tests; agreement @ρ≤0.20)
- [x] P1 endpoint scaffold (`endpoints.example.json` + scorer; no invented dates)
- [ ] Fill real `endpoints.json` (pre-registered t_obs) and score P1
- [ ] Expand `raw/` with more years / municipalities
- [x] Mathlib dependency wired (`mathlib4` v4.14.0) + `FeigenbaumAnalytic` claim shapes
- [x] Real/`Tendsto` claim shapes (`FeigenbaumTendsto`; limit still open/`sorry`)
- [x] ε–N ↔ `Tendsto` bookkeeping proved (`cascadeDeltaLimit_iff_tendsto`)
- [ ] Real/Tendsto **research discharge** of cascade → Feigenbaum δ (3aℝ; not bookkeeping)

## Medium term

- [x] Partial: finite simple f(δ) candidates ≠ τ_ch (`docs/TAU_CH_DELTA.md`, Lean `failedSimpleCandidates`, 10 forms)
- [x] Unique operational inverse-scale bridge \(f(\delta)=c/\delta\) (`ThresholdFromDelta.lean`)
- [ ] Classical free-\(c\) derivation of τ_ch from pure Feigenbaum *or* larger class without operational pin
- [ ] Cross-domain **field** results (licensed data) — pending community / intake
- [ ] Workshop date / host (issue #1)

## Non-goals (for honesty)

- Proving ontological claims in Lean
- Replacing domain validation with formal proofs
- Claiming dengue lead times as theorems
