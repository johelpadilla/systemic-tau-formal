# Formalization status

Epistemic labels follow [`docs/EPISTEMIC_LABELS.md`](docs/EPISTEMIC_LABELS.md).

**Public repo:** https://github.com/johelpadilla/systemic-tau-formal  
**CI:** `.github/workflows/ci.yml` — Python pytest + Lean `lake build`  
**Toolchain:** Lean 4.14.0 via elan  
**Python:** Lean-aligned golden rationals in `python/core/golden.py`

| Module | Claim class | Status | Notes |
|--------|-------------|--------|-------|
| `Basic` | definitions | **Builds** | Window, numPairs, Kendall opaque |
| `Thresholds` | mix | **Builds + lemmas** | τ_ch < τ_st; prefactor bounds; 2/δ gap |
| `RECD` | definitions + lemmas | **Builds** | chaos formula; antitone; evenness; **intermediate g=0 (+)** |
| `FeigenbaumReduction` | `[TEOREMA]` target | **partial** | structure inhabited; main thm `sorry` |
| `Ontology` | `[AFIRMACIÓN ONTOLÓGICA]` | **Spec builds** | Levels + trilemma horns |
| Golden bridge | `[OPERACIONAL]` | **Tests** | `test_lean_golden.py` |
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
- Deposit guide: [`docs/ZENODO.md`](docs/ZENODO.md)  
- Metadata: [`zenodo/metadata.json`](zenodo/metadata.json)  
- **DOI for this monorepo:** *pending* (run GitHub↔Zenodo or `scripts/deposit_zenodo.py` with `ZENODO_TOKEN`)  
- Prior corpus DOI: `10.5281/zenodo.20576241`

## Next formal targets

1. Mint monorepo DOI (Zenodo) and write it into `CITATION.cff`.  
2. Remove `sorry` from `coherence_return_map_feigenbaum` (hard).  
3. Optional: Mathlib dependency for real-analysis Feigenbaum path.

Last updated: 2026-07-23 (v0.1.4 — CI + release packaging).
