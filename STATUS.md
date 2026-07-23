# Formalization status

Epistemic labels follow [`docs/EPISTEMIC_LABELS.md`](docs/EPISTEMIC_LABELS.md).

**Toolchain:** Lean 4.14.0 via elan · **`lake build`: PASS**  
**Python:** `pytest` + Lean-aligned golden rationals in `python/core/golden.py`

| Module | Claim class | Status | Notes |
|--------|-------------|--------|-------|
| `Basic` | definitions | **Builds** | Window, numPairs, Kendall opaque |
| `Thresholds` | mix | **Builds + lemmas** | τ_ch < τ_st; prefactor bounds; 2/δ gap |
| `RECD` | definitions + lemmas | **Builds** | chaos formula; **antitone on [0,τ_ch)**; δ^{-k} |
| `FeigenbaumReduction` | `[TEOREMA]` target | **partial** | structure inhabited (tent-like); main thm `sorry` |
| `Ontology` | `[AFIRMACIÓN ONTOLÓGICA]` | **Spec builds** | Levels + trilemma horns |
| Golden bridge | `[OPERACIONAL]` | **Tests** | `test_lean_golden.py` matches Lean ints/Rats |

## Build

```bash
export PATH="$HOME/.elan/bin:$PATH"
cd lean && lake build

cd ../python && source .venv/bin/activate  # if present
pytest -q
python scripts/export_golden.py   # → fixtures/golden_constants.json
```

## Honesty gate

1. Operational thresholds remain Feigenbaum-**motivated**; unique `τ_ch = f(δ)` is open.  
2. `gate_antitone_on_nonneg_chaos` is a real machine-checked lemma on the operational gate.  
3. `unimodal_structure_inhabited` does **not** prove the Feigenbaum reduction from ordinal data.  
4. Never advertise `sorry` theorems as proved.

## Next formal targets

1. Remove `sorry` from `coherence_return_map_feigenbaum` (hard).  
2. Prove gate symmetry `gate(-τ) = gate(τ)` on the chaotic band.  
3. Publish GitHub remote when ready.

Last updated: 2026-07-23 (v0.1.2).
