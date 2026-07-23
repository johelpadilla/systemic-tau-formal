# systemic-tau-formal

**Machine-verifiable, open formalization of Systemic Tau (τₛ) + RECD**

[![CI](https://github.com/johelpadilla/systemic-tau-formal/actions/workflows/ci.yml/badge.svg)](https://github.com/johelpadilla/systemic-tau-formal/actions/workflows/ci.yml)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.21516059.svg)](https://doi.org/10.5281/zenodo.21516059)
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/johelpadilla/systemic-tau-formal/main?labpath=notebooks%2F01_synthetic_chaos.ipynb)

Author: Johel Padilla-Villanueva · License: MIT · Version: **0.1.6**  
**GitHub:** https://github.com/johelpadilla/systemic-tau-formal  
**Concept DOI (all versions → latest):** https://doi.org/10.5281/zenodo.21516059  
**DOI (v0.1.5):** https://doi.org/10.5281/zenodo.21516329

This monorepo elevates the existing Zenodo / PyPI corpus to a standard where:

1. **Mathematics** is stated for Lean 4 checking (`lake build`)  
2. **Algorithms** have a minimal Python reference + tests  
3. **Empirical claims** are listed as public falsifiable predictions  
4. **Philosophy** is separated by mandatory epistemic labels  

| Layer | Path |
|-------|------|
| Formal core | [`lean/`](lean/) |
| Reference Python | [`python/`](python/) |
| Try-it scripts | [`notebooks/`](notebooks/) |
| Access map | [`docs/ACCESS_LAYERS.md`](docs/ACCESS_LAYERS.md) |
| Falsifiable list | [`docs/FALSIFIABLE_PREDICTIONS.md`](docs/FALSIFIABLE_PREDICTIONS.md) |
| Protocol | [`docs/EXPERIMENTAL_PROTOCOL.md`](docs/EXPERIMENTAL_PROTOCOL.md) |
| Challenges | [`docs/CHALLENGES.md`](docs/CHALLENGES.md) |
| Workshop 2026 | [`docs/WORKSHOP_STRESS_TEST_2026.md`](docs/WORKSHOP_STRESS_TEST_2026.md) |
| Issue board | [`docs/ISSUE_BOARD.md`](docs/ISSUE_BOARD.md) |
| τ_ch vs δ | [`docs/TAU_CH_DELTA.md`](docs/TAU_CH_DELTA.md) |
| C3 cross-domain | [`docs/CROSS_DOMAIN.md`](docs/CROSS_DOMAIN.md) |
| Build status | [`STATUS.md`](STATUS.md) |

Related production code: PyPI [`systemictau`](https://pypi.org/project/systemictau/) · DOI [10.5281/zenodo.20576241](https://doi.org/10.5281/zenodo.20576241)

---

## Epistemic labels (read first)

See [`docs/EPISTEMIC_LABELS.md`](docs/EPISTEMIC_LABELS.md):

`[TEOREMA]` · `[CONJETURA]` · `[INTERPRETACIÓN FÍSICA]` · `[AFIRMACIÓN ONTOLÓGICA]` · `[OPERACIONAL]` · `[EMPÍRICO]`

**Do not collapse levels.** Dengue data do not prove Lean theorems; δ is not Polo’s efficient cause.

---

## Verify step by step

### 1. Python (works without Lean)

```bash
cd python
python -m venv .venv && source .venv/bin/activate
pip install -e ".[dev]"
pytest -q
```

### 2. Notebooks / demos

Jupyter (from repo root, after `pip install -e ".[dev]"` in `python/`):

| Notebook | What it does |
|----------|----------------|
| [`notebooks/01_synthetic_chaos.ipynb`](notebooks/01_synthetic_chaos.ipynb) | Logistic maps → τₛ, g, T_RECD + plots |
| [`notebooks/02_aedes_puerto_rico.ipynb`](notebooks/02_aedes_puerto_rico.ipynb) | Aedes-schema **proxy** (`data/aedes/proxy/`) |
| [`notebooks/03_falsifiability_test.ipynb`](notebooks/03_falsifiability_test.ipynb) | Load your CSV under protocol defaults |
| [`notebooks/04_p3_noise_robustness.py`](notebooks/04_p3_noise_robustness.py) | P3 noise scan ρ ≤ 20% |
| [`notebooks/05_first_return_poincare.py`](notebooks/05_first_return_poincare.py) | First-return Poincaré twin (`--plot`) |
| [`notebooks/06_cross_domain_c3.py`](notebooks/06_cross_domain_c3.py) | C3 synthetic finance / EEG / grid kits |

CLI twins (no Jupyter required):

```bash
python notebooks/01_synthetic_chaos.py
python notebooks/02_aedes_puerto_rico.py
python notebooks/03_falsifiability_test.py data/synthetic/regime_switch.csv
python notebooks/04_p3_noise_robustness.py
python notebooks/05_first_return_poincare.py --plot
python notebooks/06_cross_domain_c3.py
```

Committed lab fixtures: [`data/synthetic/`](data/synthetic/), [`data/aedes/proxy/`](data/aedes/proxy/).

See [`notebooks/README.md`](notebooks/README.md).
### 3. Lean 4 (optional until toolchain installed)

```bash
# once: https://leanprover-community.github.io/get_started.html
# curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh
cd lean
lake build
```

Requires [elan](https://github.com/leanprover/elan). After install:

```bash
export PATH="$HOME/.elan/bin:$PATH"
cd lean && lake build   # currently PASS on Lean 4.14.0
```

`FeigenbaumReduction.lean` still contains `sorry` (see `STATUS.md`).

---

## What is formalized (target checklist)

| Item | Status |
|------|--------|
| Definition of τₛ (mean Kendall-τ, windows) | Interface + Python ✓ · Lean ✓ |
| Thresholds 0.50 / 0.41 from δ | Operational ✓ · band lemmas ✓ · unique f(δ) **open** |
| Gate \(g(\tau_s)\) and \(\Delta t_k\) | Python ✓ · Lean gate + δ^{-k} ✓ |
| Feigenbaum reduction theorem | Preprint exists · Lean `sorry` |
| 4-level ontology / Baron’s Trilemma | Spec in Lean + `docs/ONTOLOGY_BRIDGE.md` |
| `lake build` | **PASS** (Lean 4.14.0) |

---

## Falsifiable predictions (summary)

1. **P1** Sustained \(|\tau_s|<0.41\) ⇒ ascent signal \(t^*\) 4–6 weeks before observable transition `[EMPÍRICO]`  
2. **P2** Fractal dim. of extramental clock ≈ 1.98 on low-D chaos `[CONJETURA]`  
3. **P3** Bands robust to ≤20% Gaussian noise without re-training `[EMPÍRICO]`  
4. **P4** Anti-sync (\(\tau_s\le-0.41\)) yields distinct RECD interval structure `[CONJETURA]`  

Full text: [`docs/FALSIFIABLE_PREDICTIONS.md`](docs/FALSIFIABLE_PREDICTIONS.md)

---

## Workshop (proposed)

**Systemic Tau Stress-Test 2026** — open 48h destruction workshop (dynamics + formal + philosophy).  
Full brief: [`docs/WORKSHOP_STRESS_TEST_2026.md`](docs/WORKSHOP_STRESS_TEST_2026.md) · board: [`docs/ISSUE_BOARD.md`](docs/ISSUE_BOARD.md).  
Track issues with labels `contradiction`, `improvement`, `new-domain`, `philosophy-challenge`, `workshop`.

---

## Citation

See [`CITATION.cff`](CITATION.cff).

| What | Identifier |
|------|------------|
| Concept DOI (always latest) | [10.5281/zenodo.21516059](https://doi.org/10.5281/zenodo.21516059) |
| This formal monorepo (v0.1.5) | [10.5281/zenodo.21516329](https://doi.org/10.5281/zenodo.21516329) |
| v0.1.4 (archived) | [10.5281/zenodo.21516060](https://doi.org/10.5281/zenodo.21516060) |
| GitHub | https://github.com/johelpadilla/systemic-tau-formal · release `v0.1.6` |
| Prior Systemic Tau corpus / software archive | [10.5281/zenodo.20576241](https://doi.org/10.5281/zenodo.20576241) |

```bibtex
@software{padilla_systemic_tau_formal_2026,
  author       = {Padilla-Villanueva, Johel},
  title        = {systemic-tau-formal: Machine-verifiable Systemic Tau
                   (τₛ) and RECD},
  month        = jul,
  year         = 2026,
  publisher    = {Zenodo},
  version      = {0.1.6},
  doi          = {10.5281/zenodo.21516059},
  url          = {https://doi.org/10.5281/zenodo.21516059},
  note         = {Concept DOI; pin version DOI after Zenodo publish for v0.1.6}
}
```

---

## Repo layout

```text
systemic-tau-formal/
├── lean/                 # Lean 4 library SystemicTau
├── python/               # minimal reference core + tests
├── notebooks/            # 01–06: synthetic, proxy, P3, first-return, C3
├── papers/               # index to Zenodo / local catalog
├── data/                 # synthetic + aedes proxy (+ raw intake path)
├── docs/                 # layers, protocol, challenges, workshop, C3
├── STATUS.md
├── CITATION.cff
└── README.md
```

## What this release is *not*

- Not a claim that all preprints are machine-checked  
- Not a substitute for clinical/public-health decision systems without domain validation  
- Not a finished derivation of 0.41 from δ (that is an explicit open formal goal)  
- Not licensed field C3 results (synthetic kits only)

---

*v0.1.6 · 2026-07-23 · Ready for incremental formalization and public scrutiny.*
