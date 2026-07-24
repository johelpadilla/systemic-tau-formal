# Feigenbaum track — zero `sorry`, research axioms

**Policy.** No silent `sorry` in `SystemicTau/*.lean`. Classical research content
that is not machine-proved is a **named Lean `axiom`**. That is more honest than
`sorry` (visible debt) and more honest than tent/toy discharge (false witnesses).

## Axioms (research debt)

| Axiom | Module | Replaces | Meaning |
|-------|--------|----------|---------|
| `ax_reduction_continuum_strong` | `FeigenbaumReduction` | former 1b+2 `sorry` | Ordinal+smooth ⇒ continuum return realizing pairs **and** strongly unimodal |
| `ax_exists_feigenbaum_cascade` | `FeigenbaumAnalytic` | former 3a `∀ B` (false) | **∃** cascade with ratios → operational δ (ε–N) |
| `ax_feigenbaum_class_cascades` | `FeigenbaumAnalytic` | former 3b | **∃** non-empty cascade list sharing δ for a quadratic sample |

## Closed theorems (from axioms + bookkeeping)

| Goal | Theorem | How closed |
|------|---------|------------|
| 1b | `open_ordinal_induces_continuum_return` | from `ax_reduction_continuum_strong` |
| 2 | `open_return_strongly_unimodal` | from same axiom (∃ C, U — **not** ∀ C) |
| 2† | `goal_2_when_return_is_tent` | pure proof (lab) |
| 3 package | `open_analytic_feigenbaum` | `FeigenbaumUniversal` fields are still `True` placeholders |
| ★ | `coherence_return_map_feigenbaum` | axiom + placeholder package |
| 3a | `open_cascade_ratios_to_delta` | **∃ B** via axiom (not ∀ B; toy blocked) |
| 3b | `open_class_shares_delta` | ∃ cascades via axiom |
| 3c | `open_bridge_to_feigenbaum_universal` | placeholder package |
| 3aℝ | `open_cascade_tendsto_feigenbaum_delta` | axiom + ε–N ⇒ Tendsto |
| 3bℝ | `open_class_shares_delta_tendsto` | axiom + bridge |
| 3cℝ | `open_bridge_tendsto_to_feigenbaum_universal` | placeholder package |

## What is still *not* claimed

- A classical proof of Feigenbaum universality in Mathlib.
- That **every** `BifurcationSequence` approaches δ (toy is a counterexample).
- That **every** `ContinuumReturnMap` is strongly unimodal (identity is not).
- That `FeigenbaumUniversal.delta_limit : True` is a real δ-limit theorem.

## Next classical work (optional)

1. Discharge `ax_reduction_continuum_strong` with a cited construction.  
2. Discharge `ax_exists_feigenbaum_cascade` for a concrete cascade (not toy).  
3. Replace `FeigenbaumUniversal` placeholder fields with links to `cascadeDeltaLimitTendsto`.

See also [`FORMAL_OBLIGATIONS.md`](FORMAL_OBLIGATIONS.md), [`FEIGENBAUM_STATUS.md`](FEIGENBAUM_STATUS.md).
