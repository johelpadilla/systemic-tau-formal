# Notebooks

Interactive demos for Systemic Tau (τₛ) + RECD.  
CLI twins (same logic, no Jupyter): `01_*.py` … `10_*.py`.

| Notebook | Content | Label |
|----------|---------|--------|
| [`01_synthetic_chaos.ipynb`](01_synthetic_chaos.ipynb) | Coupled logistic maps → τₛ, g, T_RECD | `[OPERACIONAL]` |
| [`02_aedes_puerto_rico.ipynb`](02_aedes_puerto_rico.ipynb) | Aedes raw-first (field → proxy fallback) | `[EMPÍRICO]` if raw present |
| [`03_falsifiability_test.ipynb`](03_falsifiability_test.ipynb) | Load your CSV; protocol defaults | demo ops / your data empiric |
| [`04_p3_noise_robustness.py`](04_p3_noise_robustness.py) | P3 noise scan ρ ≤ 20% (script) | `[OPERACIONAL]` on synthetic |
| [`05_first_return_poincare.py`](05_first_return_poincare.py) | Poincaré section on τₛ (Lean twin; `--plot`) | `[OPERACIONAL]` combinatorial |
| [`06_cross_domain_c3.py`](06_cross_domain_c3.py) | Finance / EEG / grid-like synthetic C3 kits | `[OPERACIONAL]` not field data |
| [`07_aedes_field_report.py`](07_aedes_field_report.py) | τₛ/RECD on `data/aedes/raw/` (SJU1–3) | `[EMPÍRICO]` series; P1 not scored |
| [`08_aedes_p3_field.py`](08_aedes_p3_field.py) | P3 noise on field Aedes ρ≤0.20 | field + protocol noise |
| [`09_aedes_p4_field.py`](09_aedes_p4_field.py) | P4 structure vs sync/anti baselines | field EMPÍRICO; no false anti discharge |
| [`10_aedes_empirical_board.py`](10_aedes_empirical_board.py) | Unified P1/P3/P4 board + multi-year keys | one honest field dashboard |

## Run in the browser (Binder)

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/johelpadilla/systemic-tau-formal/main?labpath=notebooks%2F01_synthetic_chaos.ipynb)

First launch can take several minutes while the environment builds.

## Run locally

From the **repo root**:

```bash
cd python && pip install -e ".[dev]"   # includes matplotlib, ipykernel
cd ..
jupyter notebook notebooks/01_synthetic_chaos.ipynb
# or:
jupyter nbconvert --to notebook --execute notebooks/01_synthetic_chaos.ipynb --stdout > /dev/null
```

Or as scripts (no Jupyter):

```bash
python notebooks/01_synthetic_chaos.py
python notebooks/02_aedes_puerto_rico.py
python notebooks/03_falsifiability_test.py your.csv
python notebooks/03_falsifiability_test.py data/synthetic/regime_switch.csv
python notebooks/04_p3_noise_robustness.py
python notebooks/05_first_return_poincare.py
python notebooks/05_first_return_poincare.py --plot   # optional PNG
python notebooks/06_cross_domain_c3.py
python notebooks/07_aedes_field_report.py
python notebooks/08_aedes_p3_field.py
python notebooks/09_aedes_p4_field.py
python notebooks/10_aedes_empirical_board.py
```

## Epistemic rules

- Do not report synthetic demos as field validation.
- Use `docs/EXPERIMENTAL_PROTOCOL.md` for comparable reports.
- Failed predictions → GitHub issue label `contradiction`.
