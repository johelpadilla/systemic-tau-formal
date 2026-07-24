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
| Goal 1b: ordinal+smooth ⇒ dynamical continuum return | `[TEOREMA]` | **open** (`open_ordinal_induces_continuum_return`) |
| Goal 2a: strong unimodal ⇒ quadratic location | `[TEOREMA]` | ✓ `goal_2a_quadratic_of_strong` |
| Goal 2: continuum return strongly unimodal | `[TEOREMA]` | **open** (`open_return_strongly_unimodal`) |
| Analytic δ / class universality | `[TEOREMA]` | **open** (`open_analytic_feigenbaum`) |
| Composite *under* hypotheses 1–3 | `[TEOREMA · bookkeeping]` | ✓ `coherence_return_map_feigenbaum_of` |
| Full composite reduction (from H alone) | `[TEOREMA]` | **open** (`coherence_return_map_feigenbaum`) |

## Named open goals

The main `sorry` is split so progress can land one lemma at a time:

1. **Goal 1b** `open_ordinal_induces_continuum_return` — ordinal + smooth force a *dynamical* continuum first-return (not a mere interpolant).  
   - **1a proved:** `exists_realizer_of_functional` — any *functional* finite pair list has *some* total realizer (`lookupPair`). Pure discrete graph theory.  
2. **`open_return_strongly_unimodal`** — that map is strongly unimodal with quadratic tip.  
   - **2a proved:** `goal_2a_quadratic_of_strong` / `stronglyUnimodal_has_quadratic` — mode ⇒ quadratic location once strong unimodality is known.  
3. **`open_analytic_feigenbaum`** — Feigenbaum δ-limit / class universality (real dynamics; ε–N ↔ `Tendsto` bookkeeping is already proved in `FeigenbaumTendsto`).

**Composition skeleton (proved):** `coherence_return_map_feigenbaum_of` — if continuum map + strong unimodality + `FeigenbaumUniversal` are granted, the composite package follows. This does **not** discharge goals 1–3.

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
| OPEN 3a cascade → δ (ε–N) | `sorry` |
| OPEN 3b class shares δ | `sorry` |
| OPEN 3c bridge → `FeigenbaumUniversal` | `sorry` |

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
| OPEN 3aℝ cascade → Feigenbaum δ (`Tendsto`) | `sorry` |
| OPEN 3bℝ class shares δ | `sorry` |
| OPEN 3cℝ bridge → `FeigenbaumUniversal` | `sorry` |

Mathlib notes: [`MATHLIB.md`](MATHLIB.md).

## Next formal steps

1. Research discharge of **1b** (dynamical continuum from ordinal+smooth — not lookup).  
2. Research discharge of **2** (strong unimodality of that return).  
3. Research discharge of **3 / 3aℝ** for a cited cascade — **not** the toy sequence.  
4. Instantiations of `PreprintReturnSetup` for concrete synthetic series (still operational).  
5. Do **not** close `coherence_return_map_feigenbaum` without discharging goals 1b–3.
