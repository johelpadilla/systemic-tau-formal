# Feigenbaum reduction — formal status

Epistemic labels: see `EPISTEMIC_LABELS.md`.

## Claim of the preprint (target)

> Under purely ordinal observability and generic smoothness, the first-return
> map of coherence is unimodal with quadratic critical point ⇒ Feigenbaum universality.

## What Lean checks today (`SystemicTau/FeigenbaumReduction.lean`)

| Result | Class | Status |
|--------|-------|--------|
| `StronglyUnimodal` structure | definition | ✓ |
| Tent map `tentF` strongly unimodal on [-1,1] | `[TEOREMA]` example | ✓ proved |
| `iterate` / period-2 skeleton | definition | ✓ |
| Logistic family ambient `logistic r` | `[OPERACIONAL]` lab | ✓ defined |
| Package inhabited | theorem | ✓ |
| Ordinal data ⇒ return map unimodal | `[TEOREMA]` target | **open** (`sorry`) |
| Analytic δ-limit / class universality | `[TEOREMA]` target | **open** (`True` placeholders) |

## What this does *not* mean

- The tent example is **not** the claim that τₛ dynamics are a tent map.
- `FeigenbaumUniversal.delta_limit : True` is a **placeholder**, not a proof of δ ≈ 4.669…
- Dengue / empirical lead times are unrelated to this module.

## Next formal steps

1. Encode first-return construction from an abstract ordinal coherence series.  
2. State unimodality hypotheses that match the preprint without overclaiming.  
3. Optional Mathlib: real-analytic logistic cascade (large dependency).
