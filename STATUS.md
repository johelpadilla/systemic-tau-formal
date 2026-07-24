# Formalization status

Epistemic labels follow [`docs/EPISTEMIC_LABELS.md`](docs/EPISTEMIC_LABELS.md).

**Public repo:** https://github.com/johelpadilla/systemic-tau-formal  
**CI:** `.github/workflows/ci.yml` — Python pytest + Lean `lake build`  
**Toolchain:** Lean 4.14.0 via elan  
**Python:** Lean-aligned golden rationals in `python/core/golden.py`

| Module | Claim class | Status | Notes |
|--------|-------------|--------|-------|
| `Basic` | definitions | **Builds** | Window, numPairs, Kendall opaque; **Mathlib** ℚ |
| `Thresholds` | mix | **Builds + lemmas** | bands; trichotomy; **failedSimpleCandidates** vs τ_ch |
| `RECD` | definitions + lemmas | **Builds** | gate laws; **gate_of_stable / gate_of_antiSync** |
| `FeigenbaumReduction` | mix | **partial** | tent + first-return; **1a/2a/composite-of-hyp** proved; 1b/2/3/`composite` open `sorry` |
| `FeigenbaumAnalytic` | mix | **partial** | cascade / δ ε–N interfaces; open goals 3a–3c `sorry` |
| `FeigenbaumTendsto` | mix | **partial** | Real / `Tendsto`; ε–N bridge **proved**; 3aℝ–3cℝ research `sorry` |
| Mathlib | dep | **wired** | mathlib4 `v4.14.0` · Real/Topology for Tendsto · `docs/MATHLIB.md` |
| `Ontology` | `[AFIRMACIÓN ONTOLÓGICA]` | **Spec builds** | Levels + trilemma horns |
| Golden bridge | `[OPERACIONAL]` | **Tests** | `test_lean_golden.py` |
| Synthetic fixtures | `[OPERACIONAL]` | **CSV + tests** | `data/synthetic/`, P3/P4 harness |
| Aedes proxy | `[OPERACIONAL]` | **CSV** | `data/aedes/proxy/` (not field data) |
| C3 synthetic kits | `[OPERACIONAL]` | **generators + nb** | finance/EEG/grid · `docs/CROSS_DOMAIN.md` |
| First-return twin | `[OPERACIONAL]` | **Python + nb 05** | `python/core/first_return.py` |
| Real Aedes raw | `[EMPÍRICO]` | **pending license** | drop under `data/aedes/raw/` |
| C3 field results | `[EMPÍRICO]` | **pending** | licensed intake + community |
| CI | ops | **Workflow** | ubuntu-latest dual jobs |

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

- GitHub release: `v0.1.7`  
- **Concept DOI:** [10.5281/zenodo.21516059](https://doi.org/10.5281/zenodo.21516059) (version DOI filled after Zenodo publish)  
- **DOI (v0.1.6):** [10.5281/zenodo.21516523](https://doi.org/10.5281/zenodo.21516523)  
- **DOI (v0.1.5):** [10.5281/zenodo.21516329](https://doi.org/10.5281/zenodo.21516329)  
- **DOI (v0.1.4):** [10.5281/zenodo.21516060](https://doi.org/10.5281/zenodo.21516060)  
- Deposit guide: [`docs/ZENODO.md`](docs/ZENODO.md)  
- Prior corpus DOI: `10.5281/zenodo.20576241`

## Next formal targets

See [`ROADMAP.md`](ROADMAP.md), [`docs/FEIGENBAUM_STATUS.md`](docs/FEIGENBAUM_STATUS.md),  
and the single-page honesty board [`docs/FORMAL_OBLIGATIONS.md`](docs/FORMAL_OBLIGATIONS.md).

Last updated: 2026-07-23 (release **v0.1.7**: formal track + obligations map).
