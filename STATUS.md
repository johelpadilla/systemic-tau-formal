# Formalization status

Epistemic labels follow [`docs/EPISTEMIC_LABELS.md`](docs/EPISTEMIC_LABELS.md).

**Public repo:** https://github.com/johelpadilla/systemic-tau-formal  
**CI:** `.github/workflows/ci.yml` — Python pytest + Lean `lake build`  
**Toolchain:** Lean 4.14.0 via elan  
**Python:** Lean-aligned golden rationals in `python/core/golden.py`

**Feigenbaum narrative (canonical):** [`docs/FEIGENBAUM_STATUS.md`](docs/FEIGENBAUM_STATUS.md)  
**Honesty board:** [`docs/FORMAL_OBLIGATIONS.md`](docs/FORMAL_OBLIGATIONS.md) · **constructions:** [`docs/FEIGENBAUM_AXIOMS.md`](docs/FEIGENBAUM_AXIOMS.md)

## Lean modules

| Module | Claim class | Status | Notes |
|--------|-------------|--------|-------|
| `Basic` | definitions | **Builds** | Window, numPairs; **combinatorial `kendallTau`** (not opaque); **Mathlib** ℚ |
| `Thresholds` | mix | **Builds + lemmas** | bands; trichotomy; **failedSimpleCandidates** (10 forms) vs τ_ch |
| `ThresholdFromDelta` | mix | **Builds + lemmas** | unique inverse-scale \(f(\delta)=c/\delta\); ontology L0–L3 package |
| `RECD` | definitions + lemmas | **Builds** | gate laws; **gate_of_stable / gate_of_antiSync** |
| `RECD_Monotonicity` | `[TEOREMA]` CT-3 | **Builds + 0 sorry** | sign lemma; `recdAccum`; monotone iff ticks ≥ 0; gate support `g<0 ↔ τ≤-τ_ch`; anti-sync descent |
| `RECD_OrdinalEntropy` | `[TEOREMA]` CT-4A/B | **Builds + 0 sorry** | `posPart`/`negPart`; `ordinalSigmaTick/Accum`; Σ≥0 for α∈[0,1]; CT-4B Σ=T under g≥0; anti-sync clock/production split |
| `RECD_Variation` | `[TEOREMA]` CT-3 quant. | **Builds + 0 sorry** | `δ^{-k}≤1`; anti-sync count; `negVarAccum`; `T_N ≥ −B·M` under `‖τ‖≤B` and ≤M anti-sync visits |
| `RECD_Immersion` | `[TEOREMA]` mesh + σ | **Builds + 0 sorry** | uniform mesh `s_n=n·h`; `immerseNode`/`immerseAffine`; `sigmaRECD≥0` on every cell; CT-4B mesh form |
| `RECD_CT1` | `[TEOREMA]` CT-1 skeleton | **Builds + 0 sorry** | stable frozen-depth; strict mono; bi-Lipschitz vs index and mesh; const-stable sample |
| `RECD_CT2` | `[TEOREMA]` CT-2 elementary | **Builds + 0 sorry** | InfOften anti-sync; not eventually nondec; density → reverse mass linear; period-2 true non-mono |
| `RECD_BV` | `[TEOREMA]` immersion BV/Lip | **Builds + 0 sorry** | cell Lip exact; TV=∑\|ΔT\|; \|T\|≤TV; period-2 TV linear |
| `RECD_Oriented` | `[TEOREMA]` OP-CT-8 elementary | **Builds + 0 sorry** | classical clock; orientation-respecting obstruction; stable is classical |
| `RECD_ContLim` | mix OP-CT-5 scaffold | **Builds + 0 sorry** | H1–H4 props; obstruction; equi-Lip; const-stable Tendsto linear |
| `RECD_Projection` | mix π + estimator | **Builds + 0 sorry** | `systemicTauWindow`; `projectPath`; `EstimatorNoise`; stable under \|ε\|≤η |
| `RECD_CT1_Noise` | `[TEOREMA]` CT-1 residual | **Builds + 0 sorry** | noise-robust CT-1; tick Lip; accum noise bound; shift/inc semigroup intertwining |
| `RECD_Monoidal` | `[TEOREMA]` OP-CT-8 residual | **Builds + 0 sorry** | `NatMonoidHom`; `OrientedMonoidBridge` obstruction; `pathTensor` classical closure |
| `RECD_ContLimFull` | mix OP-CT-5 residual | **Builds + 0 sorry** | const-mass ContLim; uniform envelope; equicont modulus; projected ContLim |
| `RECD_ContLim_Noise` | `[TEOREMA]` OP-CT-5 noise residual | **Builds + 0 sorry** | stable band under NoiseBounded; accum gap ≤N·δ^{-k}·η; equi-Lip immersion; small-η mono; ContLimNoisePackage |
| `RECD_ResearchOpen` | `[CONJETURA]` registry | **Builds + 0 sorry** | Schnakenberg/CT-4C; LDP; nested RECD interfaces (honest open board) |
| `FeigenbaumReduction` | mix | **0 sorry, 0 axiom** | 1a/1b `lookupTent`; 2 tent lab; **2τ `tauReturnFour`**; ★ **non-tent**; `logisticStrong` |
| `FeigenbaumAnalytic` | mix | **0 sorry, 0 axiom** | geometric cascade ratios ≡ δ_op; 3a/3b; toy ↛ δ |
| `FeigenbaumTendsto` | mix | **0 sorry, 0 axiom** | ε–N ↔ `Tendsto`; 3aℝ–3cℝ via geometric |
| `FeigenbaumSchwarzian` | mix | **0 sorry, 0 axiom** | C² tip \(f''≠0\); Schwarzian ≤ 0 (logistic formal derivatives); `FeigenbaumUniversalC2` |
| `FeigenbaumLogistic` | mix | **0 sorry, 0 axiom** | logistic-anchored cascade **scale-ID** with geometric (not full termwise roots) |
| `FeigenbaumSuperstable` | mix | **0 sorry, 0 axiom** | real logistic: n=0 unique \(r=2\); n=1 unique \(1+\sqrt5\); honesty \(3\neq r_1^{ss}\); n=2 residual + exclusion |
| `FeigenbaumCascade` | mix | **0 sorry, 0 axiom** | period-4 ∃ cascade window; secondary ~3.96; conditional mono unique; hybrid tail geometric; free-c op |
| Mathlib | dep | **wired** | mathlib4 `v4.14.0` · Real/Topology · [`docs/MATHLIB.md`](docs/MATHLIB.md) |
| `Ontology` | `[AFIRMACIÓN ONTOLÓGICA]` | **Spec builds** | Levels + trilemma horns; `stratifiedFour` / well-sited claims |

## Ops / empirical (not Lean discharge)

| Track | Claim class | Status | Notes |
|-------|-------------|--------|-------|
| Golden bridge | `[OPERACIONAL]` | **Tests** | `test_lean_golden.py` |
| Synthetic fixtures | `[OPERACIONAL]` | **CSV + tests** | `data/synthetic/`, P3/P4 harness |
| Aedes proxy | `[OPERACIONAL]` | **CSV** | `data/aedes/proxy/` (fallback only) |
| Aedes field (`raw/`) | `[EMPÍRICO]` | **3 series + P3/P4 + field return** | SJU1/2/3 · nb 07–11; P1 scaffold; exploratory leads only |
| Field return multi-site | `[EMPÍRICO]` diagnostic | **Board v2** | `core.field_return` · not lab unimodality |
| P1 exploratory trap-surge | `[EMPÍRICO]` characterization | **Tests** | never `pre_registered`; true P1 still open |
| C3 synthetic kits | `[OPERACIONAL]` | **generators + nb** | finance/EEG/grid · `docs/CROSS_DOMAIN.md` |
| First-return twin | `[OPERACIONAL]` | **Python + nb 05** | `python/core/first_return.py` |
| More Aedes series | `[EMPÍRICO]` | **intake ready** | CSVs under `data/aedes/raw/` |
| C3 field results | `[EMPÍRICO]` | **pending** | community / other domains |
| CI | ops | **Workflow** | ubuntu-latest dual jobs |

## Feigenbaum snapshot (aligned with `FEIGENBAUM_STATUS`)

| Package | Status | What it is **not** |
|---------|--------|---------------------|
| Composite ★ | ✓ lab, **non-tent** (`tauReturnFour` + refined `FeigenbaumUniversal`) | dynamical theorem from ordinal+smooth alone |
| Logistic scale-ID | ✓ ratios ≡ geometric cascade | full termwise \(r_n\) for all \(n\) |
| Superstable termwise | ✓ n=0,1 unique; n=2 residual + cascade ∃; secondary ~3.96 | formal StrictMonoOn residual (Rolle/Q') |
| Cascade hybrid | ✓ hybrid \(R_n\); geometric tail honesty; \(\to\delta_{\mathrm{op}}\); free-c op | termwise SS all \(n\); C² renorm; free-\(c\) without pin |
| C² / Schwarzian | ✓ algebraic on logistic / `tauReturnFour` | Mathlib C²-open renorm / universality |
| Research `axiom` / `sorry` under `SystemicTau/` | **0 / 0** | — |

## Asymmetry of the operational gate

The reference piecewise law is **not** even outside the chaotic band:

- \(\tau_{\mathrm{ch}} \le \tau < \tau_{\mathrm{st}}\) ⇒ \(g = 0\)
- \(\tau \le -\tau_{\mathrm{ch}}\) ⇒ \(g = -1\) (anti-sync), even if \(|\tau| < \tau_{\mathrm{st}}\)

Documented and tested; do not “fix” by forcing odd/even symmetry globally.

## Build

```bash
export PATH="$HOME/.elan/bin:$PATH"
cd lean
lake exe cache get   # recommended (Ubuntu CI); may fail on some macOS — then source build
lake build
cd ../python && pip install -e ".[dev]" && pytest -q
```

Mathlib notes: [`docs/MATHLIB.md`](docs/MATHLIB.md).

## Citation / Zenodo

- GitHub release: **`v0.1.11`**  
- **DOI (v0.1.11):** *pending Zenodo publish* (will pin after `deposit_zenodo.py --newversion --publish`)  
- **DOI (v0.1.10):** [10.5281/zenodo.21537465](https://doi.org/10.5281/zenodo.21537465)  
- **DOI (v0.1.9):** [10.5281/zenodo.21536462](https://doi.org/10.5281/zenodo.21536462)
- **DOI (v0.1.8):** [10.5281/zenodo.21522882](https://doi.org/10.5281/zenodo.21522882)  
- Record (v0.1.10): https://zenodo.org/records/21537465  
- **Concept DOI:** [10.5281/zenodo.21516059](https://doi.org/10.5281/zenodo.21516059)  
- **DOI (v0.1.7):** [10.5281/zenodo.21522346](https://doi.org/10.5281/zenodo.21522346)  
- **DOI (v0.1.6):** [10.5281/zenodo.21516523](https://doi.org/10.5281/zenodo.21516523)  
- **DOI (v0.1.5):** [10.5281/zenodo.21516329](https://doi.org/10.5281/zenodo.21516329)  
- **DOI (v0.1.4):** [10.5281/zenodo.21516060](https://doi.org/10.5281/zenodo.21516060)  
- Deposit guide: [`docs/ZENODO.md`](docs/ZENODO.md)  
- Prior corpus DOI: `10.5281/zenodo.20576241`

## Next formal targets (research-scale only)

Same list as [`docs/FEIGENBAUM_STATUS.md`](docs/FEIGENBAUM_STATUS.md):

1. Discharge `Period4ResidualStrictMonoOnWindow` (formal Rolle + \(Q'\) / Horner in Lean).  
2. True superstable \(R_n\) for all \(n\) (not hybrid geometric tail).  
3. Mathlib C²-open renorm fixed point + free-\(c\) without Kendall pin.  
4. Field-derived continuum return of τₛ (not a cited lab map).

Do **not** re-open discharged lab/construction goals as if they were `sorry`.

Roadmap overview: [`ROADMAP.md`](ROADMAP.md).

Last updated: 2026-07-25 (CT BV + ContLim scaffold + OP-CT-8 orientation; 0 sorry).
