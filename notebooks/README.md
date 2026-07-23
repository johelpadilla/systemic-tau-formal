# Notebooks

Interactive demos for Systemic Tau (τₛ) + RECD.  
CLI twins (same logic, no plots): `01_*.py`, `02_*.py`, `03_*.py`.

| Notebook | Content | Label |
|----------|---------|--------|
| [`01_synthetic_chaos.ipynb`](01_synthetic_chaos.ipynb) | Coupled logistic maps → τₛ, g, T_RECD | `[OPERACIONAL]` |
| [`02_aedes_puerto_rico.ipynb`](02_aedes_puerto_rico.ipynb) | Two-site trap schema (synthetic proxy) | `[OPERACIONAL]` until real data |
| [`03_falsifiability_test.ipynb`](03_falsifiability_test.ipynb) | Load your CSV; protocol defaults | demo ops / your data empiric |

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
python notebooks/03_falsifiability_test.py your.csv
```

## Epistemic rules

- Do not report synthetic demos as field validation.
- Use `docs/EXPERIMENTAL_PROTOCOL.md` for comparable reports.
- Failed predictions → GitHub issue label `contradiction`.
