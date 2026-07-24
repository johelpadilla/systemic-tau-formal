# Feigenbaum reduction — formal status

Epistemic labels: see `EPISTEMIC_LABELS.md`.  
**Full obligation map:** [`FORMAL_OBLIGATIONS.md`](FORMAL_OBLIGATIONS.md).  
**Construction map:** [`FEIGENBAUM_AXIOMS.md`](FEIGENBAUM_AXIOMS.md).

## Claim of the preprint (target)

> Under purely ordinal observability and generic smoothness, the first-return
> map of coherence is unimodal with quadratic critical point ⇒ Feigenbaum universality.

## What Lean checks today

| Result | Class | Status |
|--------|-------|--------|
| `StronglyUnimodal` / tent example | `[TEOREMA]` | ✓ |
| Tent period-2 orbit | `[TEOREMA]` | ✓ |
| Goal 1a functional realizer | `[TEOREMA · bookkeeping]` | ✓ |
| Goal 1b `lookupTent` (functional+band) | `[TEOREMA · construction]` | ✓ |
| Goal 2 tent continuum | `[TEOREMA · lab construction]` | ✓ |
| Goal 2† when R = tentF | `[TEOREMA]` | ✓ |
| Joint empty / tent-agrees | `[TEOREMA · construction]` | ✓ |
| `FeigenbaumUniversal` (band + quadratic) | `[TEOREMA · refined]` | ✓ **not** `True` placeholders |
| Composite ★ lab package | `[TEOREMA · lab]` | ✓ tent + refined pkg |
| Geometric cascade ratios ≡ δ_op | `[TEOREMA · construction]` | ✓ |
| 3a/3b existence | `[TEOREMA · construction]` | ✓ geometric |
| 3aℝ–3cℝ Tendsto | `[TEOREMA · construction]` | ✓ geometric + bridge |
| Toy ↛ δ honesty blocks | `[TEOREMA · honesty]` | ✓ |
| Research `axiom` count | — | **0** |
| `sorry` count under `SystemicTau/` | — | **0** |

## What this does *not* mean

- Tent is **not** claimed to be the τₛ return map.
- Geometric cascade is **not** the logistic superstable parameter sequence.
- Full classical Feigenbaum universality (C² class, renormalization) is **not** in Mathlib here.
- Composite ★ is a **lab construction package**, not a dynamical theorem from bare ordinal+smooth alone.

## Python twin

- `python/core/first_return.py`
- `notebooks/05_first_return_poincare.py`

## Related

Operational τ_ch vs δ: [`TAU_CH_DELTA.md`](TAU_CH_DELTA.md).

## Next classical steps (optional)

1. Logistic / quadratic-unimodal identification of cascade parameters.  
2. Mathlib C² + Schwarzian universality.  
3. Empirically motivated continuum return for τₛ (not tent).

Last updated: 2026-07-24 (axioms discharged via cited constructions; `FeigenbaumUniversal` refined).
