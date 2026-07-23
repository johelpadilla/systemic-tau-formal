# Python reference core

Minimal, dependency-light implementation of τₛ + RECD gate for automated tests and notebooks.

For the full production stack (Studio, RQA, multi-scale), use PyPI:

```bash
pip install systemictau
```

## Install (this package)

```bash
cd python
pip install -e ".[dev]"
pytest -q
```

## Modules

| Module | Role |
|--------|------|
| `core.tau` | Kendall-τ, systemic tau over windows |
| `core.recd` | g(τₛ), Δtₖ, accumulate_time |
| `core.constants` | δ, 0.50, 0.41 |
| `core.golden` | Exact rationals shared with Lean |
| `core.synthetic` | Lab generators + protocol noise |
| `core.io_data` | CSV matrix load/save for fixtures |

Fixtures: `../data/synthetic/`, `../data/aedes/proxy/`  
Regenerate: `python scripts/export_fixtures.py`

Epistemic labels: see `../docs/EPISTEMIC_LABELS.md`.
