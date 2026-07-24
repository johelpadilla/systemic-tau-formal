# Feigenbaum track — zero `sorry`, zero research `axiom`

**Policy.** No silent `sorry` and no research `axiom` under `SystemicTau/*.lean`.
Classical content is discharged by **named cited constructions**. False ∀-claims
remain blocked (toy cascade, identity map).

## Former axioms → constructions

| Former axiom | Module | Construction | What it proves | What it does **not** prove |
|--------------|--------|--------------|----------------|----------------------------|
| `ax_reduction_continuum_strong` | `FeigenbaumReduction` | tent continuum + `lookupTent` | empty / tent-compatible joint 1b+2; functional+band continuum realizer; lab goal-2 shape | that tent is τₛ dynamics; continuum strong realizer for *arbitrary* graphs |
| `ax_exists_feigenbaum_cascade` | `FeigenbaumAnalytic` | `geometricFeigenbaumCascade` | ∃ B with ratios **identically** δ_op (ε–N + Tendsto) | that logistic superstable r_n equal this sequence *termwise* |
| `ax_feigenbaum_class_cascades` | `FeigenbaumAnalytic` | singleton / logistic+geometric class | ∃ non-empty class sharing δ_op | continuum open set of maps in Mathlib |

Legacy theorem *names* `ax_exists_feigenbaum_cascade` / `ax_feigenbaum_class_cascades`
remain as **proved** aliases (not Lean `axiom`).

## Three classical upgrades (this pack)

### 1. Logistic cascade identification (`FeigenbaumLogistic`)

| Item | Content |
|------|---------|
| Construction | `logisticAnchoredR n = 2 + geometricFeigenbaumR n` |
| Landmarks | \(r_0 = 2\), \(r_1 = 3\) (logistic chart) |
| Theorem | `logistic_scale_identified_geometric` — ratios agree ∀ stages |
| Limit | `logistic_cascadeDeltaLimit` — same δ_op limit |
| **Not proved** | termwise equality with true logistic superstable roots |

### 2. C² / Schwarzian (`FeigenbaumSchwarzian`)

| Item | Content |
|------|---------|
| Formal derivatives | \(f' = r(1-2x)\), \(f'' = -2r\), \(f''' = 0\) |
| C² tip | `HasC2QuadraticTip` (Type): interior tip + \(f'' ≠ 0\) |
| Schwarzian | \(S = f'''/f' - \tfrac32(f''/f')^2 ≤ 0\) off critical point |
| Package | `FeigenbaumUniversalC2` on logistic-4 and `tauReturnFour` |
| **Not proved** | open-set universality / renorm fixed point in Mathlib |

### 3. Non-tent τₛ return (`FeigenbaumReduction`)

| Item | Content |
|------|---------|
| Map | `tauReturnF r = φ⁻¹ ∘ logistic_r ∘ φ`, φ(y)=(y+1)/2 |
| Lab | `tauReturnFourStrong` / `tauReturnFourContinuum` (\(r=4\)) |
| ★ | `coherence_return_map_feigenbaum` uses **non-tent** return |
| Tent retained | `coherence_return_map_feigenbaum_tent` |
| **Not proved** | derivation of return from ordinal ranks alone |

## `FeigenbaumUniversal` (refined)

| Field | Type | Content |
|-------|------|---------|
| `delta_in_operational_band` | `∃ δ, 4 < δ ∧ δ < 5` | operational Feigenbaum band |
| `quadratic_tip` | `HasQuadraticCriticalPoint U` | local quadratic-unimodal class |

Analytic adds `FeigenbaumUniversalWithCascade` (Type).
Schwarzian adds `FeigenbaumUniversalC2` (Type) with second-derivative witness.

## Closed goals (constructions)

| Goal | Theorem | How closed |
|------|---------|------------|
| 1a | `exists_realizer_of_functional` | pure discrete |
| 1b | `open_ordinal_induces_continuum_return` | `lookupTent` |
| 1b∅ | empty pairs | tent / tau continuum |
| 2 | `open_return_strongly_unimodal` | tent lab |
| 2τ | `open_return_strongly_unimodal_tau` | **non-tent** logistic conjugacy |
| 2† | `goal_2_when_return_is_tent` | pure |
| ★ | `coherence_return_map_feigenbaum` | **tauReturnFour** + package |
| 3 pkg | `open_analytic_feigenbaum` | band + quadratic |
| 3a | geometric / logistic-anchored cascade | exact ratio δ |
| 3b | class shares δ | geometric + logistic-anchored |
| 3c / C² | `FeigenbaumUniversalC2` | second deriv + Schwarzian |
| 3aℝ–3cℝ | Tendsto track | geometric + ε–N ↔ Tendsto |

## Honesty blocks (still proved)

- `toy_not_cascadeDeltaLimit_feigenbaum` / `toy_not_cascadeApproachesFeigenbaumDelta`
- No ∀ B cascade → δ; no ∀ continuum maps unimodal
- Logistic ID is **scale** identification, not superstable root table
- Tent ≠ dynamical derivation of τₛ; tauReturn is still a laboratory model

## Citations

- Feigenbaum, M. J. *Quantitative universality…* J. Stat. Phys. **19** (1978); **21** (1979).
- Singer, *Stable orbits and bifurcation of maps of the interval* (1978) — negative Schwarzian.
- Geometric scaling law; Ulam–von Neumann conjugacy setup for logistic on coherence.

## Remaining classical work (research-scale)

1. Termwise / asymptotic ID of true logistic superstable parameters with analysis.
2. Mathlib C²-open neighborhood universality + renorm fixed point.
3. Dynamical first-return of τₛ from ordinal + smooth *field* hypotheses (not a cited lab map).

See also [`FORMAL_OBLIGATIONS.md`](FORMAL_OBLIGATIONS.md), [`FEIGENBAUM_STATUS.md`](FEIGENBAUM_STATUS.md), [`MATHLIB.md`](MATHLIB.md).
