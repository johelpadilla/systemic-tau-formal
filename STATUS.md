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
| `Basic` | definitions | **Builds** | Window, numPairs, Kendall opaque; **Mathlib** ℚ |
| `Thresholds` | mix | **Builds + lemmas** | bands; trichotomy; **failedSimpleCandidates** vs τ_ch |
| `RECD` | definitions + lemmas | **Builds** | gate laws; **gate_of_stable / gate_of_antiSync** |
| `FeigenbaumReduction` | mix | **0 sorry, 0 axiom** | 1a/1b `lookupTent`; 2 tent lab; **2τ `tauReturnFour`**; ★ **non-tent**; `logisticStrong` |
| `FeigenbaumAnalytic` | mix | **0 sorry, 0 axiom** | geometric cascade ratios ≡ δ_op; 3a/3b; toy ↛ δ |
| `FeigenbaumTendsto` | mix | **0 sorry, 0 axiom** | ε–N ↔ `Tendsto`; 3aℝ–3cℝ via geometric |
| `FeigenbaumSchwarzian` | mix | **0 sorry, 0 axiom** | C² tip \(f''≠0\); Schwarzian ≤ 0 (logistic formal derivatives); `FeigenbaumUniversalC2` |
| `FeigenbaumLogistic` | mix | **0 sorry, 0 axiom** | logistic-anchored cascade **scale-ID** with geometric (not superstable roots) |
| Mathlib | dep | **wired** | mathlib4 `v4.14.0` · Real/Topology · [`docs/MATHLIB.md`](docs/MATHLIB.md) |
| `Ontology` | `[AFIRMACIÓN ONTOLÓGICA]` | **Spec builds** | Levels + trilemma horns |

## Ops / empirical (not Lean discharge)

| Track | Claim class | Status | Notes |
|-------|-------------|--------|-------|
| Golden bridge | `[OPERACIONAL]` | **Tests** | `test_lean_golden.py` |
| Synthetic fixtures | `[OPERACIONAL]` | **CSV + tests** | `data/synthetic/`, P3/P4 harness |
| Aedes proxy | `[OPERACIONAL]` | **CSV** | `data/aedes/proxy/` (fallback only) |
| Aedes field (`raw/`) | `[EMPÍRICO]` | **3 series + P3/P4 scan** | SJU1/2/3 · nb 07–10; P1 scaffold only |
| C3 synthetic kits | `[OPERACIONAL]` | **generators + nb** | finance/EEG/grid · `docs/CROSS_DOMAIN.md` |
| First-return twin | `[OPERACIONAL]` | **Python + nb 05** | `python/core/first_return.py` |
| More Aedes series | `[EMPÍRICO]` | **intake ready** | CSVs under `data/aedes/raw/` |
| C3 field results | `[EMPÍRICO]` | **pending** | community / other domains |
| CI | ops | **Workflow** | ubuntu-latest dual jobs |

## Feigenbaum snapshot (aligned with `FEIGENBAUM_STATUS`)

| Package | Status | What it is **not** |
|---------|--------|---------------------|
| Composite ★ | ✓ lab, **non-tent** (`tauReturnFour` + refined `FeigenbaumUniversal`) | dynamical theorem from ordinal+smooth alone |
| Logistic scale-ID | ✓ ratios ≡ geometric cascade | termwise superstable \(r_n\) of the logistic family |
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

- GitHub release: **`v0.1.8`**  
- **DOI (v0.1.8):** [10.5281/zenodo.21522882](https://doi.org/10.5281/zenodo.21522882)  
- Record: https://zenodo.org/records/21522882  
- **Concept DOI:** [10.5281/zenodo.21516059](https://doi.org/10.5281/zenodo.21516059)  
- **DOI (v0.1.7):** [10.5281/zenodo.21522346](https://doi.org/10.5281/zenodo.21522346)  
- **DOI (v0.1.6):** [10.5281/zenodo.21516523](https://doi.org/10.5281/zenodo.21516523)  
- **DOI (v0.1.5):** [10.5281/zenodo.21516329](https://doi.org/10.5281/zenodo.21516329)  
- **DOI (v0.1.4):** [10.5281/zenodo.21516060](https://doi.org/10.5281/zenodo.21516060)  
- Deposit guide: [`docs/ZENODO.md`](docs/ZENODO.md)  
- Prior corpus DOI: `10.5281/zenodo.20576241`

## Next formal targets (research-scale only)

Same list as [`docs/FEIGENBAUM_STATUS.md`](docs/FEIGENBAUM_STATUS.md):

1. Termwise / asymptotic superstable logistic roots (analysis).  
2. Mathlib C²-open universality + renorm fixed point.  
3. Field-derived continuum return of τₛ (not a cited lab map).

Do **not** re-open discharged lab/construction goals as if they were `sorry`.

Roadmap overview: [`ROADMAP.md`](ROADMAP.md).

Last updated: 2026-07-24 (v0.1.8 published: 10.5281/zenodo.21522882).
