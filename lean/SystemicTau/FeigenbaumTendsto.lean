/-
  Analytic Feigenbaum path — Real / `Tendsto` claim *shapes* (Mathlib).

  Purpose
  -------
  Lift the rational ε–N package in `FeigenbaumAnalytic` to the classical
  analysis statement:
    `Tendsto (fun n ↦ (scalingRatio B n : ℝ)) atTop (𝓝 δ)`

  Epistemic honesty
  -----------------
  · This module **encodes** the real-analysis interface for open goal 3.
  · It does **not** prove that logistic / physical cascades equal δ.
  · Analytic discharges ∃ cascade via **geometric** construction (exact ratio δ).
  · Do not discharge with the toy cascade (proved not a witness).
  · The bridge `cascadeDeltaLimit ↔ Tendsto` is pure bookkeeping
    (ε–N ↔ metric limit on the cast sequence) — **proved** below.
    That equivalence is not a Feigenbaum theorem.

  See `docs/MATHLIB.md`, `docs/FEIGENBAUM_STATUS.md`, `docs/EPISTEMIC_LABELS.md`.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Data.Real.Archimedean
import Mathlib.Topology.Instances.Real
import Mathlib.Order.Filter.AtTopBot
import SystemicTau.FeigenbaumAnalytic

namespace SystemicTau.FeigenbaumTendsto

open SystemicTau.FeigenbaumAnalytic
open SystemicTau.FeigenbaumReduction (absQ)
open Filter Topology Metric

/-! ### Real lifts of operational quantities -/

/--
  Operational δ as a real. Still `[OPERACIONAL]` — casting does not prove
  uniqueness or that any cascade limit equals this value.
-/
noncomputable def feigenbaumDeltaReal : ℝ := (feigenbaumDeltaApprox : ℝ)

theorem feigenbaumDeltaReal_pos : (0 : ℝ) < feigenbaumDeltaReal := by
  unfold feigenbaumDeltaReal
  exact_mod_cast feigenbaumDeltaApprox_pos

theorem feigenbaumDeltaReal_gt_four : (4 : ℝ) < feigenbaumDeltaReal := by
  unfold feigenbaumDeltaReal
  exact_mod_cast feigenbaumDeltaApprox_gt_four

theorem feigenbaumDeltaReal_lt_five : feigenbaumDeltaReal < 5 := by
  unfold feigenbaumDeltaReal
  exact_mod_cast feigenbaumDeltaApprox_lt_five

/-- Real-valued scaling ratios via the rational cascade interface. -/
noncomputable def scalingRatioReal (B : BifurcationSequence) (n : ℕ) : ℝ :=
  (scalingRatio B n : ℝ)

/-! ### Classical Tendsto form of “ratios → δ” -/

/--
  Real-analysis shape of cascade limit:
  \(\delta_n \to \delta\) along `atTop` in the neighborhood filter of δ.
  This is the Mathlib-native restatement of `cascadeDeltaLimit` (rational ε–N).
-/
def cascadeDeltaLimitTendsto (B : BifurcationSequence) (δ : ℝ) : Prop :=
  Tendsto (scalingRatioReal B) atTop (𝓝 δ)

/--
  Specialize to operational Feigenbaum δ.
  Proving this for a **physical** cascade is open goal 3a (real form).
-/
def cascadeApproachesFeigenbaumDelta (B : BifurcationSequence) : Prop :=
  cascadeDeltaLimitTendsto B feigenbaumDeltaReal

/-! ### Toy cascade sanity (not Feigenbaum) -/

/--
  Toy arithmetic progression has scaling ratio 1 for n ≥ 1, so the sequence
  of ratios does **not** tend to Feigenbaum δ. We only check the interface
  typechecks and that stage-1 ratio casts to 1.
-/
theorem toy_scalingRatioReal_one :
    scalingRatioReal toyIncreasingCascade 1 = 1 := by
  unfold scalingRatioReal
  exact_mod_cast toy_scaling_stage_one

/--
  Constant sequence `fun _ ↦ (1 : ℝ)` tends to 1.
  Documents how `Tendsto` is used; unrelated to Feigenbaum δ.
-/
theorem tendsto_const_one : Tendsto (fun _ : ℕ ↦ (1 : ℝ)) atTop (𝓝 1) :=
  tendsto_const_nhds

/-! ### Bookkeeping bridge: rational ε–N ↔ real `Tendsto`

  These lemmas equate two *interfaces* for the same cast sequence.
  They do **not** assert that any bifurcation cascade approaches Feigenbaum δ.
-/

/-- Local `absQ` coincides with Mathlib absolute value on `ℚ`. -/
theorem absQ_eq_abs (q : ℚ) : absQ q = |q| := by
  simp only [absQ]
  split_ifs with h
  · rw [abs_of_nonneg h]
  · rw [abs_of_nonpos (le_of_not_ge h)]

/--
  Distance of cast scaling ratios equals cast of `absQ` residual.
  Pure arithmetic identity used by both bridge directions.
-/
theorem dist_scalingRatioReal_eq_absQ
    (B : BifurcationSequence) (δ : ℚ) (n : ℕ) :
    dist (scalingRatioReal B n) (δ : ℝ) = (absQ (scalingRatio B n - δ) : ℝ) := by
  have habs : absQ (scalingRatio B n - δ) = |scalingRatio B n - δ| := absQ_eq_abs _
  calc dist (scalingRatioReal B n) (δ : ℝ)
      = |(scalingRatioReal B n) - (δ : ℝ)| := Real.dist_eq _ _
    _ = |((scalingRatio B n : ℝ) - (δ : ℝ))| := by rfl
    _ = |((scalingRatio B n - δ : ℚ) : ℝ)| := by norm_cast
    _ = ((|scalingRatio B n - δ| : ℚ) : ℝ) := by simp [abs_eq_max_neg]
    _ = (absQ (scalingRatio B n - δ) : ℝ) := by rw [habs]

/--
  [TEOREMA · bookkeeping] Rational ε–N package ⇒ real `Tendsto`.
  Not a Feigenbaum discharge — only metric/ε–N equivalence for the cast sequence.
-/
theorem cascadeDeltaLimit_implies_tendsto
    (B : BifurcationSequence) (δ : ℚ)
    (h : cascadeDeltaLimit B δ) :
    cascadeDeltaLimitTendsto B (δ : ℝ) := by
  rw [cascadeDeltaLimitTendsto, Metric.tendsto_atTop]
  intro ε εpos
  obtain ⟨q, hqpos, hqlt⟩ := exists_pos_rat_lt εpos
  obtain ⟨N, hN⟩ := h q hqpos
  refine ⟨N, fun n hn => ?_⟩
  have hbound : absQ (scalingRatio B n - δ) ≤ q := hN n hn
  have hcast : (absQ (scalingRatio B n - δ) : ℝ) ≤ (q : ℝ) := by exact_mod_cast hbound
  calc dist (scalingRatioReal B n) (δ : ℝ)
      = (absQ (scalingRatio B n - δ) : ℝ) := dist_scalingRatioReal_eq_absQ B δ n
    _ ≤ (q : ℝ) := hcast
    _ < ε := hqlt

/--
  [TEOREMA · bookkeeping] Real `Tendsto` ⇒ rational ε–N package (same δ).
  Converse interface bridge.
-/
theorem tendsto_implies_cascadeDeltaLimit
    (B : BifurcationSequence) (δ : ℚ)
    (h : cascadeDeltaLimitTendsto B (δ : ℝ)) :
    cascadeDeltaLimit B δ := by
  intro ε hε
  have εpos : (0 : ℝ) < (ε : ℝ) := by exact_mod_cast hε
  have hT : Tendsto (scalingRatioReal B) atTop (𝓝 (δ : ℝ)) := h
  rw [Metric.tendsto_atTop] at hT
  obtain ⟨N, hN⟩ := hT (ε : ℝ) εpos
  refine ⟨N, fun n hn => ?_⟩
  have hd : dist (scalingRatioReal B n) (δ : ℝ) < (ε : ℝ) := hN n hn
  have hltR : (absQ (scalingRatio B n - δ) : ℝ) < (ε : ℝ) := by
    rwa [← dist_scalingRatioReal_eq_absQ B δ n]
  have hlt : absQ (scalingRatio B n - δ) < ε := by exact_mod_cast hltR
  exact le_of_lt hlt

/-- Bidirectional bookkeeping equivalence. -/
theorem cascadeDeltaLimit_iff_tendsto
    (B : BifurcationSequence) (δ : ℚ) :
    cascadeDeltaLimit B δ ↔ cascadeDeltaLimitTendsto B (δ : ℝ) :=
  ⟨cascadeDeltaLimit_implies_tendsto B δ, tendsto_implies_cascadeDeltaLimit B δ⟩

/--
  Toy scaling ratios are constantly 1 in ℝ for stages \(n \ge 1\).
-/
theorem toy_scalingRatioReal_succ (n : ℕ) :
    scalingRatioReal toyIncreasingCascade (n + 1) = 1 := by
  unfold scalingRatioReal
  exact_mod_cast (toy_scalingRatio_succ n)

/--
  [TEOREMA · honesty] Toy cascade ratios do **not** tend to operational
  Feigenbaum δ in ℝ. Follows from the rational ε–N negative + ε–N ↔ Tendsto.
  Blocks discharging `open_cascade_tendsto_feigenbaum_delta` with the toy.
-/
theorem toy_not_cascadeApproachesFeigenbaumDelta :
    ¬ cascadeApproachesFeigenbaumDelta toyIncreasingCascade := by
  intro h
  have hEq : cascadeDeltaLimitTendsto toyIncreasingCascade (feigenbaumDeltaApprox : ℝ) := by
    simpa [cascadeApproachesFeigenbaumDelta, feigenbaumDeltaReal] using h
  have hQ : cascadeDeltaLimit toyIncreasingCascade feigenbaumDeltaApprox :=
    tendsto_implies_cascadeDeltaLimit toyIncreasingCascade feigenbaumDeltaApprox hEq
  exact toy_not_cascadeDeltaLimit_feigenbaum hQ

/-- Backward-compatible names (formerly `open_*` / `sorry`). -/
theorem open_cascadeDeltaLimit_implies_tendsto
    (B : BifurcationSequence) (δ : ℚ)
    (h : cascadeDeltaLimit B δ) :
    cascadeDeltaLimitTendsto B (δ : ℝ) :=
  cascadeDeltaLimit_implies_tendsto B δ h

theorem open_tendsto_implies_cascadeDeltaLimit
    (B : BifurcationSequence) (δ : ℚ)
    (h : cascadeDeltaLimitTendsto B (δ : ℝ)) :
    cascadeDeltaLimit B δ :=
  tendsto_implies_cascadeDeltaLimit B δ h

/-! ### Real track — closed goals via geometric construction + ε–N ↔ Tendsto -/

/--
  Finite-lab Tendsto form of class universality (parallel to Analytic).
  **Not** ∀ cascades — toy is a counterexample.
-/
def FiniteClassSharesDeltaTendsto (cascades : List BifurcationSequence) (δ : ℝ) : Prop :=
  ∀ B ∈ cascades, cascadeDeltaLimitTendsto B δ

theorem FiniteClassSharesDeltaTendsto_nil (δ : ℝ) :
    FiniteClassSharesDeltaTendsto ([] : List BifurcationSequence) δ := by
  intro B h; cases h

/--
  GOAL 3aℝ — existence: geometric cascade tends to operational Feigenbaum δ in ℝ.
  From proved geometric ε–N limit + ε–N ⇒ Tendsto. Not ∀ cascades; not toy.
-/
theorem open_cascade_tendsto_feigenbaum_delta :
    ∃ B : BifurcationSequence, cascadeApproachesFeigenbaumDelta B := by
  obtain ⟨B, hQ⟩ := open_cascade_ratios_to_delta
  refine ⟨B, ?_⟩
  have hT : cascadeDeltaLimitTendsto B (feigenbaumDeltaApprox : ℝ) :=
    cascadeDeltaLimit_implies_tendsto B feigenbaumDeltaApprox hQ
  simpa [cascadeApproachesFeigenbaumDelta, feigenbaumDeltaReal] using hT

/--
  GOAL 3bℝ — non-empty class of cascades sharing δ in Tendsto form.
  From geometric singleton class + ε–N ⇒ Tendsto on each member.
-/
theorem open_class_shares_delta_tendsto (S : QuadraticUnimodalSample) :
    ∃ cascades : List BifurcationSequence,
      cascades ≠ [] ∧ FiniteClassSharesDeltaTendsto cascades feigenbaumDeltaReal := by
  obtain ⟨cascades, hne, hShare⟩ := open_class_shares_delta S
  refine ⟨cascades, hne, ?_⟩
  intro B hB
  have hQ : cascadeDeltaLimit B feigenbaumDeltaApprox := hShare B hB
  have hT : cascadeDeltaLimitTendsto B (feigenbaumDeltaApprox : ℝ) :=
    cascadeDeltaLimit_implies_tendsto B feigenbaumDeltaApprox hQ
  simpa [feigenbaumDeltaReal] using hT

/--
  GOAL 3cℝ — bridge Tendsto limit + quadratic tip → refined `FeigenbaumUniversal`.
-/
theorem open_bridge_tendsto_to_feigenbaum_universal
    (U : FeigenbaumReduction.UnimodalMap)
    (hq : FeigenbaumReduction.HasQuadraticCriticalPoint U)
    (_B : BifurcationSequence)
    (_hlim : cascadeApproachesFeigenbaumDelta _B) :
    FeigenbaumReduction.FeigenbaumUniversal U :=
  FeigenbaumReduction.open_analytic_feigenbaum U hq

/-! ### Status flags (documentation as data) -/

structure TendstoTrackStatus where
  /-- Real δ bounds via cast. -/
  delta_real_bounds_ok : True := trivial
  /-- `Tendsto` / `scalingRatioReal` interfaces encoded. -/
  tendsto_interface_ok : True := trivial
  /-- Toy cast + const-Tendsto sanity. -/
  toy_real_sanity_ok : True := trivial
  /-- Toy does **not** tend to Feigenbaum δ. PROVED (honesty). -/
  toy_not_feigenbaum_ok : True := trivial
  /-- ε–N ↔ Tendsto bridge. Proved (bookkeeping only). -/
  eps_tendsto_bridge_ok : True := trivial
  /-- Cascade → Feigenbaum δ existence (Tendsto). PROVED (geometric + bridge). -/
  cascade_tendsto_geometric_ok : True := trivial
  /-- Class universality (Tendsto). PROVED (geometric + bridge). -/
  class_tendsto_geometric_ok : True := trivial
  /-- Bridge to refined package. PROVED. -/
  bridge_tendsto_refined_ok : True := trivial

def currentTendstoStatus : TendstoTrackStatus := {}

end SystemicTau.FeigenbaumTendsto
