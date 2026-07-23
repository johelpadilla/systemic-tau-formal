# Formalization status

Epistemic labels follow [`docs/EPISTEMIC_LABELS.md`](docs/EPISTEMIC_LABELS.md).

**Toolchain:** Lean 4.14.0 via elan · **`lake build`: PASS** (2026-07-23)

| Module | Claim class | Status | Notes |
|--------|-------------|--------|-------|
| `Basic` | definitions | **Builds** | Window, numPairs, Kendall opaque |
| `Thresholds` | mix | **Builds + lemmas** | τ_ch < τ_st; prefactor bounds; 2/δ > τ_ch gap |
| `RECD` | definitions + lemmas | **Builds** | gate cases; g(0)=prefactor; δ^{-k} skeleton |
| `FeigenbaumReduction` | `[TEOREMA]` target | **`sorry`** | Statement only; preprint port pending |
| `Ontology` | `[AFIRMACIÓN ONTOLÓGICA]` | **Spec builds** | Levels + trilemma horns |

## Build

```bash
export PATH="$HOME/.elan/bin:$PATH"
cd lean && lake build
```

Python (no Lean required):

```bash
cd python && pip install -e ".[dev]" && pytest -q
```

## Honesty gate

1. **Operational thresholds** 0.50 / ±0.41 are Feigenbaum-**motivated** defaults. Machine-checked so far: band *ordering*, prefactor bounds, and gap `2/δ − τ_ch > 0` — **not** a unique closed form τ_ch = f(δ).
2. Early-warning lead times are **empirical**, not Lean theorems.
3. Polo homology is **ontological**, not dynamical-systems necessity.
4. Any theorem with `sorry` must not be advertised as proved.

## Next formal targets

1. Pack ordinal-observability hypotheses for Feigenbaum reduction (remove `sorry` stepwise).  
2. Prove gate monotonicity on `[0, τ_ch)`.  
3. Link Python golden tests ↔ Lean rationals via exported fixtures.

Last updated: 2026-07-23 (v0.1.1 — lake green).
