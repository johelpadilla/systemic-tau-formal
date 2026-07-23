# Formalization status

Epistemic labels follow [`docs/EPISTEMIC_LABELS.md`](docs/EPISTEMIC_LABELS.md).

**Public repo:** https://github.com/johelpadilla/systemic-tau-formal  
**CI:** `.github/workflows/ci.yml` — Python pytest + Lean `lake build`  
**Toolchain:** Lean 4.14.0 via elan  
**Python:** Lean-aligned golden rationals in `python/core/golden.py`

| Module | Claim class | Status | Notes |
|--------|-------------|--------|-------|
| `Basic` | definitions | **Builds** | Window, numPairs, Kendall opaque |
| `Thresholds` | mix | **Builds + lemmas** | bands; classify; **nonneg trichotomy** |
| `RECD` | definitions + lemmas | **Builds** | gate laws; **gate_of_stable / gate_of_antiSync** |
| `FeigenbaumReduction` | mix | **partial** | strong tent unimodal **proved**; reduction `sorry` |
| `Ontology` | `[AFIRMACIÓN ONTOLÓGICA]` | **Spec builds** | Levels + trilemma horns |
| Golden bridge | `[OPERACIONAL]` | **Tests** | `test_lean_golden.py` |
| Synthetic fixtures | `[OPERACIONAL]` | **CSV + tests** | `data/synthetic/`, P3/P4 harness |
| Aedes proxy | `[OPERACIONAL]` | **CSV** | `data/aedes/proxy/` (not field data) |
| Real Aedes raw | `[EMPÍRICO]` | **pending license** | drop under `data/aedes/raw/` |
| CI | ops | **Workflow** | ubuntu-latest dual jobs |

## Asymmetry of the operational gate

The reference piecewise law is **not** even outside the chaotic band:

- \(\tau_{\mathrm{ch}} \le \tau < \tau_{\mathrm{st}}\) ⇒ \(g = 0\)
- \(\tau \le -\tau_{\mathrm{ch}}\) ⇒ \(g = -1\) (anti-sync), even if \(|\tau| < \tau_{\mathrm{st}}\)

Documented and tested; do not “fix” by forcing odd/even symmetry globally.

## Build

```bash
export PATH="$HOME/.elan/bin:$PATH"
cd lean && lake build
cd ../python && pip install -e ".[dev]" && pytest -q
```

## Citation / Zenodo

- GitHub release: `v0.1.4`  
- **DOI (v0.1.4):** [10.5281/zenodo.21516060](https://doi.org/10.5281/zenodo.21516060)  
- **Concept DOI:** [10.5281/zenodo.21516059](https://doi.org/10.5281/zenodo.21516059)  
- Record: https://zenodo.org/records/21516060  
- Deposit guide: [`docs/ZENODO.md`](docs/ZENODO.md)  
- Prior corpus DOI: `10.5281/zenodo.20576241`

## Next formal targets

See [`ROADMAP.md`](ROADMAP.md) and [`docs/FEIGENBAUM_STATUS.md`](docs/FEIGENBAUM_STATUS.md).

Last updated: 2026-07-23 (synthetic + Aedes proxy fixtures, P3/P4 tests).
