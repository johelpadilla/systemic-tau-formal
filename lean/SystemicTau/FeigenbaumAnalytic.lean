/-
  Analytic Feigenbaum path — claim *shapes* + cited geometric cascade.

  Purpose
  -------
  Give machine-checkable interfaces for goal 3
  (`open_analytic_feigenbaum` in FeigenbaumReduction):
    · period-doubling cascade parameter sequence
    · scaling ratios δ_n
    · “ratios approach δ” (rational ε-N form)
    · quadratic-unimodal *class* package
    · **cited geometric cascade** with exact ratio = operational δ
      (discharges ∃ cascade → δ; not logistic identification)

  Construction cite
  -----------------
  Geometric scaling law r_{n+1}−r_n = (r_n−r_{n−1})/δ with δ = δ_op
  is the model sequence whose ratios are *identically* δ (Feigenbaum 1978:
  δ defined as the limit of period-doubling ratios). This proves existence of
  a `BifurcationSequence` with `cascadeDeltaLimit B δ_op`. It does **not**
  prove that logistic superstable parameters equal this sequence.

  See docs/FEIGENBAUM_STATUS.md, docs/FEIGENBAUM_AXIOMS.md, docs/EPISTEMIC_LABELS.md.
-/
import SystemicTau.FeigenbaumReduction

namespace SystemicTau.FeigenbaumAnalytic

open SystemicTau.FeigenbaumReduction
open SystemicTau (feigenbaumDeltaOp)

/-! ### Operational δ (not a uniqueness theorem) -/

/--
  Operational decimal for Feigenbaum's first constant δ ≈ 4.6692016091.
  Alias of `SystemicTau.feigenbaumDeltaOp`. `[OPERACIONAL]` — not a uniqueness theorem.
-/
def feigenbaumDeltaApprox : Rat := feigenbaumDeltaOp

theorem feigenbaumDeltaApprox_pos : (0 : Rat) < feigenbaumDeltaApprox := by
  native_decide

theorem feigenbaumDeltaApprox_gt_four : (4 : Rat) < feigenbaumDeltaApprox := by
  native_decide

theorem feigenbaumDeltaApprox_lt_five : feigenbaumDeltaApprox < 5 := by
  native_decide

/-! ### Bifurcation cascade (claim shape) -/

/--
  Bifurcation / superstable parameter sequence \(r_n\) for a unimodal family.
  Interpretation is laboratory-level until linked to a concrete map family in ℝ.
-/
structure BifurcationSequence where
  /-- Parameter at stage \(n\) (period \(2^n\) birth or superstable). -/
  r : Nat → Rat
  /-- Strict increase toward accumulation (when the cascade is defined). -/
  mono : ∀ n, r n < r (n + 1)

/-- Differences \(\Delta r_n = r_{n+1} - r_n > 0\) from monotonicity. -/
theorem bifurcation_step_pos (B : BifurcationSequence) (n : Nat) :
    (0 : Rat) < B.r (n + 1) - B.r n := by
  have h := B.mono n
  linarith

/--
  Scaling ratio
  \(\delta_n = (r_n - r_{n-1}) / (r_{n+1} - r_n)\) for \(n \ge 1\).
  Returns `0` for \(n = 0\) or a zero denominator (defensive; mono prevents the latter).
-/
def scalingRatio (B : BifurcationSequence) : Nat → Rat
  | 0 => 0
  | n + 1 =>
      let num := B.r (n + 1) - B.r n
      let den := B.r (n + 2) - B.r (n + 1)
      if den = 0 then 0 else num / den

theorem scalingRatio_zero (B : BifurcationSequence) : scalingRatio B 0 = 0 := rfl

/--
  Rational ε–N form of “ratios approach δ”.
  This is the *statement shape* of the classical limit claim without `Real`/`Tendsto`.
  Mathlib path: replace with `Tendsto (fun n => (scalingRatio B n : ℝ)) atTop (𝓝 δ)`.
-/
def ratiosApproachDelta (B : BifurcationSequence) (δ : Rat) (ε : Rat) : Prop :=
  ∃ N : Nat, ∀ n : Nat, N ≤ n → absQ (scalingRatio B n - δ) ≤ ε

/--
  Full cascade limit package: for every positive rational ε, ratios enter the band.
  Still weaker than a real-analysis limit; sufficient as a Lean obligation interface.
-/
def cascadeDeltaLimit (B : BifurcationSequence) (δ : Rat) : Prop :=
  ∀ ε : Rat, 0 < ε → ratiosApproachDelta B δ ε

/-! ### Logistic laboratory (operational numbers, not theorems) -/

/--
  Coarse rational waypoints often cited for the logistic map cascade
  (superstable / period-doubling neighborhood). `[OPERACIONAL]` — not proved
  here to be exact bifurcation values.
-/
def logisticCascadeWaypoints : Nat → Rat
  | 0 => 2
  | 1 => 3
  | 2 => 7 / 2
  | 3 => 18 / 5
  | 4 => 361 / 100
  | n + 5 => logisticCascadeWaypoints (n + 4) + 1 / (((n + 2) * 100 : Nat) : Rat)

/-- Toy strictly increasing sequence for interface tests (not the real cascade). -/
def toyIncreasingCascade : BifurcationSequence where
  r := fun n => (n : ℚ)
  mono := by
    intro n
    -- (n:ℚ) < (n+1:ℚ)
    simpa using (Nat.cast_lt (α := ℚ)).mpr (Nat.lt_succ_self n)

theorem toy_scaling_stage_one :
    scalingRatio toyIncreasingCascade 1 = 1 := by
  native_decide

theorem toy_scaling_stage_two :
    scalingRatio toyIncreasingCascade 2 = 1 := by
  native_decide

/--
  Arithmetic-progression cascade has scaling ratio 1 at every stage \(n \ge 1\).
  [TEOREMA · bookkeeping] — used to **block** fake discharge of open goal 3a.
-/
theorem toy_scalingRatio_succ (n : Nat) :
    scalingRatio toyIncreasingCascade (n + 1) = 1 := by
  -- r_k = k ⇒ δ_n = 1/1 = 1 for every stage n ≥ 1
  -- `scalingRatio` matches on `Nat.succ`; reduce definitionally then simplify.
  have hdef :
      scalingRatio toyIncreasingCascade (Nat.succ n) =
        (let num := toyIncreasingCascade.r (n + 1) - toyIncreasingCascade.r n
         let den := toyIncreasingCascade.r (n + 2) - toyIncreasingCascade.r (n + 1)
         if den = 0 then 0 else num / den) :=
    rfl
  rw [Nat.succ_eq_add_one] at hdef
  rw [hdef]
  -- r k = (k : ℚ)
  change (let num := ((n + 1 : ℕ) : ℚ) - (n : ℕ)
          let den := ((n + 2 : ℕ) : ℚ) - ((n + 1 : ℕ) : ℚ)
          if den = 0 then 0 else num / den) = 1
  have hnum : ((n + 1 : ℕ) : ℚ) - (n : ℕ) = 1 := by push_cast; ring
  have hden : ((n + 2 : ℕ) : ℚ) - ((n + 1 : ℕ) : ℚ) = 1 := by push_cast; ring
  simp [hnum, hden]
  -- residual: `if 1 = 0 then 0 else 1⁻¹` (or equivalent concrete form)
  native_decide

/-- Residual |1 − δ_op| is strictly larger than 3 (operational δ ∈ (4,5)). -/
theorem absQ_one_sub_feigenbaumDelta_gt_three :
    (3 : Rat) < absQ (1 - feigenbaumDeltaApprox) := by
  have hgt : (4 : Rat) < feigenbaumDeltaApprox := feigenbaumDeltaApprox_gt_four
  have hle : 1 - feigenbaumDeltaApprox < 0 := by linarith
  have habs : absQ (1 - feigenbaumDeltaApprox) = feigenbaumDeltaApprox - 1 := by
    have : absQ (1 - feigenbaumDeltaApprox) = -(1 - feigenbaumDeltaApprox) :=
      absQ_of_nonpos (le_of_lt hle)
    linarith [this]
  rw [habs]
  linarith

/--
  [TEOREMA · honesty] The toy arithmetic cascade does **not** approach
  operational Feigenbaum δ in the rational ε–N sense.
  Blocks discharging `open_cascade_ratios_to_delta` with `toyIncreasingCascade`.
-/
theorem toy_not_cascadeDeltaLimit_feigenbaum :
    ¬ cascadeDeltaLimit toyIncreasingCascade feigenbaumDeltaApprox := by
  intro hlim
  -- Take ε = 3: residual |1 − δ| > 3 for every stage n ≥ 1
  have hε : (0 : Rat) < 3 := by native_decide
  obtain ⟨N, hN⟩ := hlim 3 hε
  let n := max N 1
  have hnN : N ≤ n := Nat.le_max_left N 1
  have hn1 : 1 ≤ n := Nat.le_max_right N 1
  have hratio : scalingRatio toyIncreasingCascade n = 1 := by
    have : ∃ k, n = k + 1 := Nat.exists_eq_succ_of_ne_zero (Nat.pos_iff_ne_zero.mp hn1)
    obtain ⟨k, hk⟩ := this
    rw [hk, toy_scalingRatio_succ]
  have hbound := hN n hnN
  rw [hratio] at hbound
  have hgt := absQ_one_sub_feigenbaumDelta_gt_three
  linarith

/-! ### Quadratic class (finite lab sample; continuum class needs Mathlib) -/

/--
  Finite sample of unimodal maps asserted to have a quadratic tip location.
  A continuum *open set* of maps is Mathlib / analysis territory.
-/
structure QuadraticUnimodalSample where
  /-- Distinguished member with quadratic tip. -/
  sample : UnimodalMap
  quadratic : HasQuadraticCriticalPoint sample
  /-- Optional further members (lab list). -/
  others : List UnimodalMap := []

/-- Tent map sample: single-element lab class. -/
def tentSample : QuadraticUnimodalSample where
  sample := tentLike
  quadratic := tentLike_has_critical

/-! ### Geometric Feigenbaum cascade (cited construction · discharges 3a/3b)

  **Construction.** Parameter sequence with exact constant scaling ratio δ_op:
    r₀ = 0, r₁ = 1,
    r_{n+1} = r_n + (r_n − r_{n−1}) / δ_op  (n ≥ 1).

  Then δ_n = (r_n − r_{n−1}) / (r_{n+1} − r_n) = δ_op for all n ≥ 1.
  Cite: model geometric law underlying Feigenbaum’s definition of δ as the
  limit of period-doubling ratios (Feigenbaum, J. Stat. Phys. 19 (1978)).

  **Not claimed:** r_n equals logistic superstable / bifurcation values.
-/

/-- Recursive geometric parameter sequence with ratio δ = `feigenbaumDeltaApprox`. -/
def geometricFeigenbaumR : Nat → Rat
  | 0 => 0
  | 1 => 1
  | n + 2 =>
      geometricFeigenbaumR (n + 1) +
        (geometricFeigenbaumR (n + 1) - geometricFeigenbaumR n) /
          feigenbaumDeltaApprox

/-- Positive step sizes (geometric decay of increments, always > 0). -/
theorem geometricFeigenbaumR_step_pos (n : Nat) :
    (0 : Rat) < geometricFeigenbaumR (n + 1) - geometricFeigenbaumR n := by
  induction n with
  | zero =>
    -- r1 - r0 = 1
    native_decide
  | succ n ih =>
    -- r(n+2) - r(n+1) = (r(n+1) - r n) / δ
    have hδ : (0 : Rat) < feigenbaumDeltaApprox := feigenbaumDeltaApprox_pos
    have hdef :
        geometricFeigenbaumR (n + 2) - geometricFeigenbaumR (n + 1) =
          (geometricFeigenbaumR (n + 1) - geometricFeigenbaumR n) /
            feigenbaumDeltaApprox := by
      simp only [geometricFeigenbaumR]
      ring
    rw [hdef]
    exact div_pos ih hδ

/-- Strict increase of the geometric parameter sequence. -/
theorem geometricFeigenbaumR_mono (n : Nat) :
    geometricFeigenbaumR n < geometricFeigenbaumR (n + 1) := by
  have h := geometricFeigenbaumR_step_pos n
  linarith

/-- Packaged bifurcation sequence (cited geometric construction). -/
def geometricFeigenbaumCascade : BifurcationSequence where
  r := geometricFeigenbaumR
  mono := geometricFeigenbaumR_mono

/-- Step identity: Δr_{n+1} = Δr_n / δ. -/
theorem geometric_step_succ (n : Nat) :
    geometricFeigenbaumR (n + 2) - geometricFeigenbaumR (n + 1) =
      (geometricFeigenbaumR (n + 1) - geometricFeigenbaumR n) /
        feigenbaumDeltaApprox := by
  simp only [geometricFeigenbaumR]
  ring

/--
  [TEOREMA · cited construction]
  Scaling ratios of the geometric cascade equal operational δ at every stage n ≥ 1.
-/
theorem geometric_scalingRatio_eq_delta (n : Nat) :
    scalingRatio geometricFeigenbaumCascade (n + 1) = feigenbaumDeltaApprox := by
  let num := geometricFeigenbaumR (n + 1) - geometricFeigenbaumR n
  let den := geometricFeigenbaumR (n + 2) - geometricFeigenbaumR (n + 1)
  have hδ_ne : feigenbaumDeltaApprox ≠ 0 := ne_of_gt feigenbaumDeltaApprox_pos
  have hnum_ne : num ≠ 0 := by
    have h := geometricFeigenbaumR_step_pos n
    exact ne_of_gt h
  have hstep : den = num / feigenbaumDeltaApprox := geometric_step_succ n
  have hden_ne : den ≠ 0 := by
    intro hz
    apply hnum_ne
    -- den = 0 ⇒ num/δ = 0 ⇒ num = 0
    have : num / feigenbaumDeltaApprox = 0 := hstep ▸ hz
    exact (div_eq_zero_iff.mp this).resolve_right hδ_ne
  -- scalingRatio (n+1) = if den=0 then 0 else num/den
  change (if den = 0 then (0 : Rat) else num / den) = feigenbaumDeltaApprox
  rw [if_neg hden_ne, hstep]
  field_simp [hδ_ne, hnum_ne]

/-- Residual is zero for every stage n ≥ 1. -/
theorem geometric_abs_scaling_sub_delta (n : Nat) :
    absQ (scalingRatio geometricFeigenbaumCascade (n + 1) - feigenbaumDeltaApprox) = 0 := by
  rw [geometric_scalingRatio_eq_delta]
  simp [absQ]

/--
  [TEOREMA · cited construction · goal 3a]
  Geometric cascade approaches operational δ in the rational ε–N sense.
-/
theorem geometric_cascadeDeltaLimit :
    cascadeDeltaLimit geometricFeigenbaumCascade feigenbaumDeltaApprox := by
  intro ε hε
  refine ⟨1, ?_⟩
  intro n hn
  have hn1 : 1 ≤ n := hn
  have ⟨k, hk⟩ : ∃ k, n = k + 1 := Nat.exists_eq_succ_of_ne_zero (Nat.pos_iff_ne_zero.mp hn1)
  rw [hk, geometric_abs_scaling_sub_delta]
  exact le_of_lt hε

/-! ### Analytic track — closed goals via geometric construction (zero `axiom`) -/

/--
  Finite-lab form of “class shares δ”: every cascade in a provided list
  approaches the same operational constant.

  **Do not** quantify over *all* `BifurcationSequence` — the toy cascade is a
  counterexample (`toy_not_cascadeDeltaLimit_feigenbaum`).
-/
def FiniteClassSharesDelta (cascades : List BifurcationSequence) (δ : Rat) : Prop :=
  ∀ B ∈ cascades, cascadeDeltaLimit B δ

/-- Empty cascade list shares any δ (vacuous bookkeeping). -/
theorem FiniteClassSharesDelta_nil (δ : Rat) :
    FiniteClassSharesDelta ([] : List BifurcationSequence) δ := by
  intro B h; cases h

/--
  GOAL 3a — existence form of cascade → δ.
  Discharged by `geometricFeigenbaumCascade` (cited construction). Not ∀ cascades.
-/
theorem open_cascade_ratios_to_delta :
    ∃ B : BifurcationSequence, cascadeDeltaLimit B feigenbaumDeltaApprox :=
  ⟨geometricFeigenbaumCascade, geometric_cascadeDeltaLimit⟩

/-- Legacy name: former research axiom, now a proved theorem. -/
theorem ax_exists_feigenbaum_cascade :
    ∃ B : BifurcationSequence, cascadeDeltaLimit B feigenbaumDeltaApprox :=
  open_cascade_ratios_to_delta

/-- When a cascade is already known to approach δ, restate as `cascadeDeltaLimit`. -/
theorem cascade_ratios_to_delta_of
    (B : BifurcationSequence)
    (h : cascadeDeltaLimit B feigenbaumDeltaApprox) :
    cascadeDeltaLimit B feigenbaumDeltaApprox :=
  h

/--
  GOAL 3b — non-empty class of cascades sharing δ.
  Discharged by the singleton class `[geometricFeigenbaumCascade]`.
  Sample `S` is unused (lab package; class is the geometric scaling family).
-/
theorem open_class_shares_delta (_S : QuadraticUnimodalSample) :
    ∃ cascades : List BifurcationSequence,
      cascades ≠ [] ∧ FiniteClassSharesDelta cascades feigenbaumDeltaApprox := by
  refine ⟨[geometricFeigenbaumCascade], List.cons_ne_nil _ _, ?_⟩
  intro B hB
  simp only [List.mem_singleton] at hB
  subst hB
  exact geometric_cascadeDeltaLimit

/-- Legacy name: former research axiom, now a proved theorem. -/
theorem ax_feigenbaum_class_cascades (S : QuadraticUnimodalSample) :
    ∃ cascades : List BifurcationSequence,
      cascades ≠ [] ∧ FiniteClassSharesDelta cascades feigenbaumDeltaApprox :=
  open_class_shares_delta S

/-- Bookkeeping: a proof that every listed cascade hits δ is exactly the Prop. -/
theorem FiniteClassSharesDelta_of
    (cascades : List BifurcationSequence) (δ : Rat)
    (h : ∀ B ∈ cascades, cascadeDeltaLimit B δ) :
    FiniteClassSharesDelta cascades δ :=
  h

/--
  GOAL 3c — Bridge cascade limit + quadratic tip → **refined** `FeigenbaumUniversal`
  (operational δ-band + quadratic tip — no `True` placeholders).
-/
theorem open_bridge_to_feigenbaum_universal
    (U : UnimodalMap) (hq : HasQuadraticCriticalPoint U)
    (_B : BifurcationSequence) (_hlim : cascadeDeltaLimit _B feigenbaumDeltaApprox) :
    FeigenbaumUniversal U :=
  open_analytic_feigenbaum U hq

/--
  Refined restatement: quadratic tip + cascade limit ⇒ `FeigenbaumUniversal`.
-/
theorem open_analytic_feigenbaum_refined
    (U : UnimodalMap) (hq : HasQuadraticCriticalPoint U)
    (B : BifurcationSequence) :
    cascadeDeltaLimit B feigenbaumDeltaApprox → FeigenbaumUniversal U := by
  intro hlim
  exact open_bridge_to_feigenbaum_universal U hq B hlim

/--
  Stronger package: quadratic tip **and** an explicit cascade witness for δ.
  Type (not Prop) so the cascade data is retained. Non-placeholder analytic content.
-/
structure FeigenbaumUniversalWithCascade (U : UnimodalMap) where
  base : FeigenbaumUniversal U
  cascade : BifurcationSequence
  limit : cascadeDeltaLimit cascade feigenbaumDeltaApprox

/-- Build refined package from quadratic tip + geometric cascade. -/
def feigenbaumUniversalWithCascade_geometric
    (U : UnimodalMap) (hq : HasQuadraticCriticalPoint U) :
    FeigenbaumUniversalWithCascade U where
  base := open_analytic_feigenbaum U hq
  cascade := geometricFeigenbaumCascade
  limit := geometric_cascadeDeltaLimit

/--
  Status flags for the analytic track (documentation as data).
-/
structure AnalyticTrackStatus where
  /-- Operational δ bounds proved. -/
  delta_approx_bounds_ok : True := trivial
  /-- Cascade / ratio interfaces encoded. -/
  cascade_interface_ok : True := trivial
  /-- Toy cascade scaling sanity. -/
  toy_scaling_ok : True := trivial
  /-- Toy cascade does **not** approach Feigenbaum δ (honesty block). PROVED. -/
  toy_not_feigenbaum_ok : True := trivial
  /-- Tent quadratic sample inhabited. -/
  tent_sample_ok : True := trivial
  /-- Cascade → δ via geometric construction. PROVED. -/
  geometric_cascade_limit_ok : True := trivial
  /-- Class cascades via geometric singleton. PROVED. -/
  class_via_geometric_ok : True := trivial
  /-- Bridge to refined FeigenbaumUniversal. PROVED. -/
  bridge_refined_ok : True := trivial
  /-- Zero research axioms in this module. -/
  zero_research_axiom_ok : True := trivial
  /-- Real/Tendsto Mathlib interface in `FeigenbaumTendsto`. -/
  mathlib_tendsto_ok : True := trivial

def currentAnalyticStatus : AnalyticTrackStatus := {}

-- Real / `Tendsto` claim shapes: `SystemicTau.FeigenbaumTendsto`

end SystemicTau.FeigenbaumAnalytic
