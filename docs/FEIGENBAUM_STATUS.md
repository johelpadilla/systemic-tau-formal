# Feigenbaum reduction — formal status

Epistemic labels: see `EPISTEMIC_LABELS.md`.  
**Full obligation map (v0.2 prep):** [`FORMAL_OBLIGATIONS.md`](FORMAL_OBLIGATIONS.md).

## Claim of the preprint (target)

> Under purely ordinal observability and generic smoothness, the first-return
> map of coherence is unimodal with quadratic critical point ⇒ Feigenbaum universality.

## What Lean checks today (`SystemicTau/FeigenbaumReduction.lean`)

| Result | Class | Status |
|--------|-------|--------|
| `StronglyUnimodal` structure | definition | ✓ |
| Tent map `tentF` strongly unimodal on [-1,1] | `[TEOREMA]` | ✓ proved |
| Tent period-2 orbit `1/4 ↔ 3/4` | `[TEOREMA]` | ✓ proved |
| `iterate` / period-2 skeleton | definition | ✓ |
| Logistic family ambient `logistic r` | `[OPERACIONAL]` lab | ✓ defined |
| `CoherenceSeries` / `sectionValues` / `returnPairs` | definition | ✓ |
| `FirstReturnData` / `ContinuumReturnMap` / `PreprintReturnSetup` | definition | ✓ |
| `stronglyUnimodal_has_quadratic` | `[TEOREMA]` | ✓ proved |
| `conditional_quadratic_from_setup` | `[TEOREMA]` | ✓ proved |
| Package inhabited | theorem | ✓ |
| Goal 1a: functional pairs admit a realizer | `[TEOREMA · bookkeeping]` | ✓ `exists_realizer_of_functional` |
| Goal 1b+2 joint research axiom | `[AXIOMA]` | `ax_reduction_continuum_strong` |
| Goal 1b from axiom | `[TEOREMA · from axiom]` | ✓ `open_ordinal_induces_continuum_return` |
| Goal 2a: strong unimodal ⇒ quadratic location | `[TEOREMA]` | ✓ `goal_2a_quadratic_of_strong` |
| Goal 2 from axiom (∃ C,U — not ∀ C) | `[TEOREMA · from axiom]` | ✓ `open_return_strongly_unimodal` |
| Goal 2†: if `C.R = tentF` then strong + quadratic | `[TEOREMA · bookkeeping]` | ✓ `goal_2_when_return_is_tent` (lab only) |
| Analytic package (placeholder `True` fields) | `[TEOREMA · bookkeeping]` | ✓ `open_analytic_feigenbaum` |
| Composite *under* hypotheses 1–3 | `[TEOREMA · bookkeeping]` | ✓ `coherence_return_map_feigenbaum_of` |
| Full composite from H | `[TEOREMA · from axiom]` | ✓ `coherence_return_map_feigenbaum` |

## Named goals (zero `sorry`; research = axioms)

See [`FEIGENBAUM_AXIOMS.md`](FEIGENBAUM_AXIOMS.md).

1. **1a** proved: `exists_realizer_of_functional`.  
2. **1b+2** research axiom `ax_reduction_continuum_strong` → corollaries proved.  
3. **2† / 2a** pure proofs (tent lab / mode).  
4. **3 package** placeholder `True` fields → bookkeeping constructor.  
5. **3a/3b** existence axioms; **3aℝ/3bℝ** via ε–N ↔ Tendsto.  
6. **★** composite from H via axiom + placeholder.

**Composition skeleton:** `coherence_return_map_feigenbaum_of` (pure). Full `coherence_return_map_feigenbaum` uses the research axiom.

Conditional progress already machine-checked: *if* a `PreprintReturnSetup` supplies strong unimodality, the quadratic-location obligation follows from the mode (`conditional_quadratic_from_setup`).

## What this does *not* mean

- The tent example is **not** the claim that τₛ dynamics are a tent map.
- `FeigenbaumUniversal.delta_limit : True` remains a **placeholder** field type, not a proof of δ ≈ 4.669…  
- Discharging the composite theorem by returning `tentStrong` under arbitrary hypotheses would be **invalid** — we keep the honest `sorry`.
- Dengue / empirical lead times are unrelated to this module.

## Python twin

Combinatorial first-return extraction (no continuum claims):

- `python/core/first_return.py`
- `notebooks/05_first_return_poincare.py`

## Related open problem

Operational τ_ch vs δ: [`TAU_CH_DELTA.md`](TAU_CH_DELTA.md) (finite simple forms ruled out in Lean).

## Analytic track (`FeigenbaumAnalytic.lean`)

| Interface | Status |
|-----------|--------|
| `feigenbaumDeltaApprox` bounds | ✓ proved |
| `BifurcationSequence` / `scalingRatio` / `cascadeDeltaLimit` | ✓ encoded |
| Toy cascade scaling checks | ✓ proved |
| `toy_scalingRatio_succ` (ratios ≡ 1) | ✓ proved |
| **`toy_not_cascadeDeltaLimit_feigenbaum`** | ✓ **honesty** (blocks fake 3a) |
| 3a **∃** cascade → δ | ✓ `ax_exists_feigenbaum_cascade` |
| `FiniteClassSharesDelta` / nil vacuous | ✓ encoded |
| 3b **∃** class cascades | ✓ `ax_feigenbaum_class_cascades` |
| 3c bridge → placeholder package | ✓ bookkeeping |

## Real / Tendsto track (`FeigenbaumTendsto.lean`)

| Interface | Status |
|-----------|--------|
| `feigenbaumDeltaReal` bounds (cast) | ✓ proved |
| `scalingRatioReal` / `cascadeDeltaLimitTendsto` | ✓ encoded |
| Toy cast + `tendsto_const_one` sanity | ✓ proved |
| `absQ_eq_abs` / `dist_scalingRatioReal_eq_absQ` | ✓ proved |
| Bookkeeping ε–N ⇒ Tendsto | ✓ proved |
| Bookkeeping Tendsto ⇒ ε–N | ✓ proved |
| `cascadeDeltaLimit_iff_tendsto` | ✓ proved |
| **`toy_not_cascadeApproachesFeigenbaumDelta`** | ✓ **honesty** (blocks fake 3aℝ) |
| 3aℝ **∃** cascade (`Tendsto`) | ✓ axiom + ε–N⇒Tendsto |
| 3bℝ **∃** class (`Tendsto`) | ✓ axiom + bridge |
| 3cℝ bridge → placeholder package | ✓ bookkeeping |

Mathlib notes: [`MATHLIB.md`](MATHLIB.md).

## Next formal steps (classical — replace axioms)

1. Prove or replace `ax_reduction_continuum_strong` with a cited construction.  
2. Prove or replace `ax_exists_feigenbaum_cascade` for a concrete cascade — **not** toy.  
3. Prove or replace `ax_feigenbaum_class_cascades`.  
4. Refine `FeigenbaumUniversal` fields off `True` placeholders.  
5. See [`FEIGENBAUM_AXIOMS.md`](FEIGENBAUM_AXIOMS.md).
