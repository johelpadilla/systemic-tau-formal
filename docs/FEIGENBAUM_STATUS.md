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
| `logisticStrong` / `tauReturnFourStrong` | `[TEOREMA · non-tent]` | ✓ logistic conjugacy on coherence |
| Tent period-2 orbit | `[TEOREMA]` | ✓ |
| Goal 1a functional realizer | `[TEOREMA · bookkeeping]` | ✓ |
| Goal 1b `lookupTent` (functional+band) | `[TEOREMA · construction]` | ✓ |
| Goal 2 tent continuum | `[TEOREMA · lab construction]` | ✓ |
| Goal 2τ non-tent continuum | `[TEOREMA · construction]` | ✓ `tauReturnFourContinuum` |
| Goal 2† when R = tentF | `[TEOREMA]` | ✓ |
| Joint empty / tent-agrees | `[TEOREMA · construction]` | ✓ |
| `FeigenbaumUniversal` (band + quadratic) | `[TEOREMA · refined]` | ✓ **not** `True` placeholders |
| `FeigenbaumUniversalC2` + Schwarzian ≤ 0 | `[TEOREMA · algebra]` | ✓ logistic formal derivatives |
| Composite ★ lab package | `[TEOREMA · lab]` | ✓ **non-tent** τₛ return + refined pkg |
| Geometric cascade ratios ≡ δ_op | `[TEOREMA · construction]` | ✓ |
| Logistic-anchored scale ID | `[TEOREMA · identification]` | ✓ ratios ≡ geometric (not superstable roots) |
| 3a/3b existence | `[TEOREMA · construction]` | ✓ geometric + logistic-anchored |
| 3aℝ–3cℝ Tendsto | `[TEOREMA · construction]` | ✓ geometric + bridge |
| Toy ↛ δ honesty blocks | `[TEOREMA · honesty]` | ✓ |
| Research `axiom` count | — | **0** |
| `sorry` count under `SystemicTau/` | — | **0** |

## What this does *not* mean

- Tent is **not** claimed to be the τₛ return map.
- `tauReturnF` is a **laboratory** quadratic return (logistic conjugacy), not derived from ordinal ranks alone.
- Logistic-anchored cascade is **scale-identified** with the geometric model; true superstable roots open.
- Full classical Feigenbaum universality (C²-open renorm) is **not** in Mathlib here.
- Composite ★ is a **lab construction package**, not a dynamical theorem from bare ordinal+smooth alone.

## Modules

| Module | Role |
|--------|------|
| `FeigenbaumReduction` | tent + **non-tent** τₛ return, 1a/1b/2/★ |
| `FeigenbaumAnalytic` | geometric cascade, 3a–3c |
| `FeigenbaumTendsto` | Real Tendsto bridge |
| `FeigenbaumSchwarzian` | C² tip + negative Schwarzian (logistic) |
| `FeigenbaumLogistic` | logistic-chart cascade scale ID |

## Python twin

- `python/core/first_return.py`
- `notebooks/05_first_return_poincare.py`

## Related

Operational τ_ch vs δ: [`TAU_CH_DELTA.md`](TAU_CH_DELTA.md).

## Next classical steps (research-scale)

1. Termwise / asymptotic superstable logistic roots (analysis).  
2. Mathlib C²-open universality + renorm fixed point.  
3. Field-derived continuum return of τₛ (not a cited lab map).

**Zenodo:** **v0.1.8** (this pin) · concept [10.5281/zenodo.21516059](https://doi.org/10.5281/zenodo.21516059) · see `FORMAL_OBLIGATIONS` §7.  
**Module board:** [`../STATUS.md`](../STATUS.md).

Last updated: 2026-07-24 (v0.1.8: logistic scale-ID + Schwarzian + non-tent τₛ return; docs cross-aligned).
