# systemic-tau-formal

**Machine-verifiable, open formalization of Systemic Tau (τₛ) + RECD**

Author: Johel Padilla-Villanueva · License: MIT · Version: **0.1.0** (scaffold)

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

### 2. Synthetic demos

```bash
python notebooks/01_synthetic_chaos.py
python notebooks/02_aedes_puerto_rico.py   # synthetic proxy until public Aedes data
python notebooks/03_falsifiability_test.py # or pass your.csv
```

### 3. Lean 4 (optional until toolchain installed)

```bash
# once: https://leanprover-community.github.io/get_started.html
# curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh
cd lean
lake build
```

**Note:** This environment may not ship `lake` yet. Lean sources are complete **stubs + partial proofs**; `FeigenbaumReduction.lean` still contains `sorry` (see `STATUS.md`).

---

## What is formalized (target checklist)

| Item | Status |
|------|--------|
| Definition of τₛ (mean Kendall-τ, windows) | Interface + Python ✓ · Lean scaffold ✓ |
| Thresholds 0.50 / 0.41 from δ | **Operational defaults** ✓ · full δ-derivation **open** |
| Gate \(g(\tau_s)\) and \(\Delta t_k\) | Python ✓ · Lean gate lemmas ✓ |
| Feigenbaum reduction theorem | Preprint exists · Lean `sorry` |
| 4-level ontology / Baron’s Trilemma | Spec in Lean + `docs/ONTOLOGY_BRIDGE.md` |

---

## Falsifiable predictions (summary)

1. **P1** Sustained \(|\tau_s|<0.41\) ⇒ ascent signal \(t^*\) 4–6 weeks before observable transition `[EMPÍRICO]`  
2. **P2** Fractal dim. of extramental clock ≈ 1.98 on low-D chaos `[CONJETURA]`  
3. **P3** Bands robust to ≤20% Gaussian noise without re-training `[EMPÍRICO]`  
4. **P4** Anti-sync (\(\tau_s\le-0.41\)) yields distinct RECD interval structure `[CONJETURA]`  

Full text: [`docs/FALSIFIABLE_PREDICTIONS.md`](docs/FALSIFIABLE_PREDICTIONS.md)

---

## Workshop (proposed)

**Systemic Tau Stress-Test 2026** — open 48h destruction workshop (dynamics + philosophy of time + Polo specialists). Format TBD; track issues with labels `contradiction`, `improvement`, `new-domain`, `philosophy-challenge`.

---

## Citation

See [`CITATION.cff`](CITATION.cff). Preferred corpus DOI: `10.5281/zenodo.20576241`.

---

## Repo layout

```text
systemic-tau-formal/
├── lean/                 # Lean 4 library SystemicTau
├── python/               # minimal reference core + tests
├── notebooks/            # 01 synthetic · 02 aedes proxy · 03 falsify
├── papers/               # index to Zenodo / local catalog
├── data/                 # synthetic + aedes placeholder
├── docs/                 # layers, protocol, challenges, labels
├── STATUS.md
├── CITATION.cff
└── README.md
```

## What this release is *not*

- Not a claim that all preprints are machine-checked  
- Not a substitute for clinical/public-health decision systems without domain validation  
- Not a finished derivation of 0.41 from δ (that is an explicit open formal goal)

---

*Scaffold date: 2026-07-23 · Ready for incremental formalization and public scrutiny.*
