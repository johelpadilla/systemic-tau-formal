# Feigenbaum reduction — formal status

Epistemic labels: see `EPISTEMIC_LABELS.md`.

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
| Ordinal data ⇒ continuum return | `[TEOREMA]` | **open** (`open_ordinal_induces_continuum_return`) |
| Continuum return strongly unimodal | `[TEOREMA]` | **open** (`open_return_strongly_unimodal`) |
| Analytic δ / class universality | `[TEOREMA]` | **open** (`open_analytic_feigenbaum`) |
| Full composite reduction | `[TEOREMA]` | **open** (`coherence_return_map_feigenbaum`) |

## Named open goals

The main `sorry` is split so progress can land one lemma at a time:

1. **`open_ordinal_induces_continuum_return`** — discrete Poincaré pairs extend to a total map on the coherence interval.  
2. **`open_return_strongly_unimodal`** — that map is strongly unimodal with quadratic tip.  
3. **`open_analytic_feigenbaum`** — Feigenbaum δ-limit / class universality (real analysis; optional Mathlib).

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
| OPEN bookkeeping ε–N ⇒ Tendsto | `sorry` |
| OPEN bookkeeping Tendsto ⇒ ε–N | `sorry` |
| OPEN 3aℝ cascade → Feigenbaum δ (`Tendsto`) | `sorry` |
| OPEN 3bℝ class shares δ | `sorry` |
| OPEN 3cℝ bridge → `FeigenbaumUniversal` | `sorry` |

Mathlib notes: [`MATHLIB.md`](MATHLIB.md).

## Next formal steps

1. Instantiations of `PreprintReturnSetup` for concrete synthetic series (still operational).  
2. Discharge ε–N ↔ `Tendsto` bookkeeping (analysis only; not Feigenbaum).  
3. Research discharge of 3aℝ for a cited cascade — **not** the toy sequence.  
4. Do **not** close `coherence_return_map_feigenbaum` without discharging goals 1–3.
