# Feigenbaum track — zero `sorry`, zero research `axiom`

**Policy.** No silent `sorry` and no research `axiom` under `SystemicTau/*.lean`.
Classical content that is not logistic-identification is discharged by **named
cited constructions**. False ∀-claims remain blocked (toy cascade, identity map).

## Former axioms → constructions

| Former axiom | Module | Construction | What it proves | What it does **not** prove |
|--------------|--------|--------------|----------------|----------------------------|
| `ax_reduction_continuum_strong` | `FeigenbaumReduction` | tent continuum + `lookupTent` | empty / tent-compatible joint 1b+2; functional+band continuum realizer; lab goal-2 shape | that tent is τₛ dynamics; continuum strong realizer for *arbitrary* graphs |
| `ax_exists_feigenbaum_cascade` | `FeigenbaumAnalytic` | `geometricFeigenbaumCascade` | ∃ B with ratios **identically** δ_op (ε–N + Tendsto) | that logistic superstable r_n equal this sequence |
| `ax_feigenbaum_class_cascades` | `FeigenbaumAnalytic` | singleton `[geometricFeigenbaumCascade]` | ∃ non-empty class sharing δ_op | continuum open set of maps in Mathlib |

Legacy theorem *names* `ax_exists_feigenbaum_cascade` / `ax_feigenbaum_class_cascades`
remain as **proved** aliases (not Lean `axiom`).

## `FeigenbaumUniversal` (refined, non-placeholder)

| Field | Type | Content |
|-------|------|---------|
| `delta_in_operational_band` | `∃ δ, 4 < δ ∧ δ < 5` | operational Feigenbaum band (δ_op ≈ 4.669…) |
| `quadratic_tip` | `HasQuadraticCriticalPoint U` | local quadratic-unimodal class membership |

Analytic adds `FeigenbaumUniversalWithCascade` (Type): base package + explicit
`BifurcationSequence` witness with `cascadeDeltaLimit`.

## Closed goals (constructions)

| Goal | Theorem | How closed |
|------|---------|------------|
| 1a | `exists_realizer_of_functional` | pure discrete |
| 1b | `open_ordinal_induces_continuum_return` | `lookupTent` under IsFunctional + pairsInBand |
| 1b∅ | `open_ordinal_induces_continuum_return_empty` | tent continuum |
| 2 | `open_return_strongly_unimodal` | tent continuum lab |
| 2† | `goal_2_when_return_is_tent` | pure |
| 1b+2∅ | `open_reduction_joint_empty_pairs` | tent |
| 1b+2† | `open_reduction_joint_when_tent_agrees` | tent |
| 3 pkg | `open_analytic_feigenbaum` | band + quadratic fields |
| ★ | `coherence_return_map_feigenbaum` | tent lab + refined package |
| 3a | `open_cascade_ratios_to_delta` | geometric cascade |
| 3b | `open_class_shares_delta` | geometric singleton |
| 3c | `open_bridge_to_feigenbaum_universal` | refined package |
| 3aℝ–3cℝ | Tendsto track | geometric + ε–N ↔ Tendsto |

## Honesty blocks (still proved)

- `toy_not_cascadeDeltaLimit_feigenbaum` / `toy_not_cascadeApproachesFeigenbaumDelta`
- No ∀ B cascade → δ; no ∀ continuum maps unimodal

## Citations

- Feigenbaum, M. J. *Quantitative universality for a class of nonlinear transformations.*
  J. Stat. Phys. **19** (1978), 25–52; **21** (1979), 669–706.
- Geometric scaling law: δ defined as limit of period-doubling ratios; model
  sequence with constant ratio δ is the exact geometric case used here.
- Tent map: standard unimodal laboratory (Collet–Eckmann class context).

## Remaining classical work (optional / research-scale)

1. Identify `geometricFeigenbaumR` with logistic superstable parameters (analysis).
2. C² / negative Schwarzian class + true universality in Mathlib.
3. Dynamical first-return of τₛ (not tent lab) from ordinal+smooth hypotheses.

See also [`FORMAL_OBLIGATIONS.md`](FORMAL_OBLIGATIONS.md), [`FEIGENBAUM_STATUS.md`](FEIGENBAUM_STATUS.md).
