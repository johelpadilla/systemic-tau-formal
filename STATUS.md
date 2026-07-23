# Formalization status

Epistemic labels follow [`docs/EPISTEMIC_LABELS.md`](docs/EPISTEMIC_LABELS.md).

| Module | Claim class | Status | Notes |
|--------|-------------|--------|-------|
| `Basic` | `[TEOREMA]` / definitions | **Scaffold** | Definitions of τₛ, windows, Kendall interface |
| `Thresholds` | mix | **Scaffold** | Operational 0.50 / 0.41; full δ-derivation open |
| `RECD` | definitions + `[CONJETURA]` | **Scaffold** | g(τₛ), Δtₖ matching `systemictau` reference |
| `FeigenbaumReduction` | `[TEOREMA]` (preprint) | **Scaffold + `sorry`** | Target: port Feigenbaum reduction preprint |
| `Ontology` | `[AFIRMACIÓN ONTOLÓGICA]` | **Scaffold** | 4 levels + Baron's Trilemma avoidance (spec) |

## Build

```bash
# Requires elan + Lean 4 (not bundled; see README)
cd lean && lake build
```

If Lean is not installed, Python verification still works:

```bash
cd python && pip install -e ".[dev]" && pytest -q
```

## Honesty gate (do not collapse levels)

1. **Operational thresholds** 0.50 / ±0.41 are used in the reference implementation and papers as Feigenbaum-**motivated** bands. A fully closed machine-checked derivation from δ alone is a **goal of this repo**, not yet an established theorem.
2. Early-warning lead times (4–6 weeks) are **empirical claims** about specific domains, not Lean theorems.
3. Homology with Polo's efficient causality is **philosophical interpretation**, not a dynamical-systems theorem.

Last updated: 2026-07-23 (v0.1.0 scaffold).
