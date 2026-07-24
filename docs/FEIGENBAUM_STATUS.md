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
| Logistic-anchored scale ID | `[TEOREMA · identification]` | ✓ ratios ≡ geometric (not full termwise roots) |
| Superstable n=0 unique \(r=2\) | `[TEOREMA · analysis]` | ✓ `FeigenbaumSuperstable` |
| Superstable n=1 unique \(1+\sqrt5\) | `[TEOREMA · analysis]` | ✓ + honesty \(3\neq r_1^{ss}\) |
| Superstable n=2 residual + exclusion | `[TEOREMA · algebra]` | ✓ residual char |
| Superstable n=2 existence (cascade window) | `[TEOREMA · analysis]` | ✓ IVT in [3.498, 3.499] |
| Secondary residual zero ~3.96 | `[TEOREMA · honesty]` | ✓ uniqueness on full (1+√5,4) **false** |
| Conditional unique in window (StrictMonoOn) | `[TEOREMA · conditional]` | ✓ under mono hyp; formal Rolle/Q' open |
| Hybrid cascade + \(\delta_n\to\delta\) | `[TEOREMA · construction]` | ✓ true SS n≤2 + geometric tail (not termwise) |
| Free-c inverse-scale + 2/δ fails | `[TEOREMA · honesty]` | ✓ operational; free-c without pin open |
| 3a/3b existence | `[TEOREMA · construction]` | ✓ geometric + logistic-anchored |
| 3aℝ–3cℝ Tendsto | `[TEOREMA · construction]` | ✓ geometric + bridge |
| Toy ↛ δ honesty blocks | `[TEOREMA · honesty]` | ✓ |
| Research `axiom` count | — | **0** |
| `sorry` count under `SystemicTau/` | — | **0** |

## What this does *not* mean

- Tent is **not** claimed to be the τₛ return map.
- `tauReturnF` is a **laboratory** quadratic return (logistic conjugacy), not derived from ordinal ranks alone.
- Logistic-anchored cascade is **scale-identified** with the geometric model; termwise superstable closed for n=0,1 (n≥2 residual/open).
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
| `FeigenbaumSuperstable` | termwise superstable roots (n=0,1; n=2 residual) |
| `FeigenbaumCascade` | period-4 existence; hybrid cascade; free-c pack |

## Python twin

- `python/core/first_return.py`
- `notebooks/05_first_return_poincare.py`
- `python/tests/test_superstable_logistic.py`

## Related

Operational τ_ch vs δ: [`TAU_CH_DELTA.md`](TAU_CH_DELTA.md).

## Honesty residual (closed packaging; open discharge)

| Item | Machine-checked | Still open |
|------|-----------------|------------|
| Uniqueness on full (1+√5,4) | **False** (secondary ~3.96) | — |
| Uniqueness in cascade window | Conditional on `StrictMonoOn residual` + Horner lo > 0 | Formal Rolle/Q' mono discharge |
| Hybrid \(R_n\), \(\delta_n\to\delta\) | Prefix SS n≤2 + geometric tail ratios ≡ δ | Termwise SS for all \(n\) |
| Free-\(c\) for τ_ch | Unique in inverse-scale + pin; 2/δ fails | Without Kendall pin; C² map-space renorm |

## Next classical steps (research-scale only)

1. Discharge `Period4ResidualStrictMonoOnWindow` (Rolle + cleared poly \(Q'\), Horner IA in Lean).  
2. True superstable \(R_n\) for all \(n\) (not hybrid geometric tail).  
3. Mathlib C²-open renorm fixed point + free-\(c\) without Kendall pin.  
4. Field-derived continuum return of τₛ (not a cited lab map).

**Zenodo:** **v0.1.9** · concept [10.5281/zenodo.21516059](https://doi.org/10.5281/zenodo.21516059) · see `FORMAL_OBLIGATIONS` §7.  
**Module board:** [`../STATUS.md`](../STATUS.md).

Last updated: 2026-07-24 (honesty pack: secondary zero; conditional mono unique; hybrid geometric honesty; 0 sorry).
