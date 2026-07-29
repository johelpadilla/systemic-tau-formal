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
- [x] Release `v0.1.9`: unique inverse-scale f(δ); extended candidates; ontology L0–L3; Zenodo software+preprint
- [x] Release `v0.1.10`: superstable termwise + cascade honesty pack; hybrid R_n; Zenodo software+preprint
- [x] Release `v0.1.11`: Module CT residual pack (RECD CT-1..4, ContLim+noise, π/Kendall, OP-CT-8 monoidal); 0 sorry

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
- [x] Field-derived multi-site return + exploratory trap-surge leads (nb 11; **not** P1 discharge)
- [x] Empirical board v2 wires `field_return` + `p1_exploratory` (`docs/FIELD_EMPIRICAL_STATUS.md`)
- [x] P1-Aedes protocol v1.0.0 design freeze — `docs/P1_AEDES_EXTERNAL_TOBS.md` + `calendar_map.json` + lock/score CLI (nb 14)
- [ ] Fill real Aedes `endpoints.json` (pre-registered **external** clinical/intervention \(t_{\mathrm{obs}}\)) and score true P1
- [ ] Intake 2018 San Juan / PR **weekly dengue cases** under `data/aedes/external/` (known gap; DengAI ends ~2013)
- [x] P1-EEG clinical track scaffold (CHB-MIT protocol v1.0.0, lock+score+C1, CI synthetic)
- [x] P1-EEG first locked pilot on real CHB-MIT EDFs (`chb01`, 2026-07-27): hit 1/7, C1 FP 1.0 — see `docs/P1_EEG_CHB01_PILOT_REPORT.md`
- [x] P1-EEG v1.1.0 *a priori* design freeze — `docs/P1_EEG_CHBMIT_v1.1.md`
- [x] P1-EEG v1.1.0 implement + G1–G4 PASS + lock + score + C1 + report (`chb01`, 2026-07-29): hit **0/7**, C1 FP **0.643** — `docs/P1_EEG_CHB01_PILOT_REPORT_v1.1.md`
- [x] **EEG track paused (2026-07-29):** not convenient for paradigm EWS proof after v1.0 ambient-chaos + v1.1 order-timing fails; freeze history kept; no v1.2 unless program reopens explicitly
- [x] True P1 multi-site **Aedes** score with external domain \(t_{\mathrm{obs}}\) — Vitória yearly **0/5** (miss_lead); pipeline unlocked, EWS not supported
- [x] **P1-ILI v1.0.0** design freeze + Delphi intake + lock/score — HHS→FluSurv peak **0/10**; p75 **1/10** (`docs/P1_ILI_REPORT.md`)
- [x] **P1-Synthetic Canonical v1.0.0** instrument validation — plant **20/20**, G1–G4 **INSTRUMENT_PASS** (`docs/P1_SYNTHETIC_CANONICAL_REPORT.md`; nb 16)
- [x] **C1 synthetic companion** — C1A/B PASS, **C1C FAIL** (noise FP 1.0) → `C1_STRESS_FAIL` (`last_c1.json`)
- [x] **P1 fail-triptych** synthesis — instrument / field residual / C1 stress (`docs/P1_FAIL_TRIPTYCH.md`)
- [x] **P1 C1 guard design sketch** (not implemented) — `docs/P1_C1_GUARD_DESIGN.md`
- [ ] Optional: implement C1 guard only after checklist freeze in `P1_C1_GUARD_DESIGN.md` (new protocol version)
- [ ] Expand Aedes `raw/` with more years / municipalities (or new protocol version before re-score)
- [ ] Optional P1-ILI v1.1 only if **a priori** redesign of \(t^*\) / endpoint (do not retune on current lock)
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
