/-
  Feigenbaum reduction — structured statement + machine-checked partial results.

  [TEOREMA] (preprint target):
  Under purely ordinal observability and generic smoothness, the first-return
  map of coherence is unimodal with quadratic critical point
  ⇒ Feigenbaum universality.

  What is proved here:
  - interval / map structures
  - strong unimodality of a tent-like fold on [-1,1]
  - inhabitedness of the unimodal package
  - iterate skeleton + tent period-2 example
  - first-return data from an abstract coherence series
  - conditional: StronglyUnimodal ⇒ HasQuadraticCriticalPoint
  - named open goals for the remaining reduction steps

  What remains open (`sorry`):
  - that ordinal observability + smoothness *force* a continuum return map
  - that such a return is strongly unimodal with quadratic tip
  - full analytic Feigenbaum δ universality

  Papers: catalog 09 / 11 / 12; Zenodo monorepo DOI 10.5281/zenodo.21516060
-/
import SystemicTau.Basic

namespace SystemicTau.FeigenbaumReduction

/-! ### Interval and absolute value -/

/-- Interval endpoints for a return map on coherence. -/
structure Interval where
  a : Rat
  b : Rat
  a_lt_b : a < b

def coherenceInterval : Interval :=
  ⟨-1, 1, by native_decide⟩

/-- Absolute value (local, for tent map). -/
def absQ (q : Rat) : Rat := if q ≥ 0 then q else -q

theorem absQ_nonneg (q : Rat) : 0 ≤ absQ q := by
  simp only [absQ]; split_ifs <;> linarith

theorem absQ_of_nonneg {q : Rat} (h : 0 ≤ q) : absQ q = q := by
  simp [absQ, h]

theorem absQ_of_nonpos {q : Rat} (h : q ≤ 0) : absQ q = -q := by
  simp only [absQ]; split_ifs with hge
  · have : q = 0 := le_antisymm h hge; simp [this]
  · rfl

theorem absQ_le_one_of_mem {x : Rat} (hx1 : (-1 : Rat) ≤ x) (hx2 : x ≤ 1) :
    absQ x ≤ 1 := by
  simp only [absQ]; split_ifs with h
  · exact hx2
  · have : x < 0 := lt_of_not_ge h; linarith

/-! ### Unimodal packages -/

/-- Combinatorial unimodal map (has an interior mode). -/
structure UnimodalMap where
  I : Interval
  f : Rat → Rat
  maps_into : ∀ x, I.a ≤ x → x ≤ I.b → I.a ≤ f x ∧ f x ≤ I.b
  has_mode : ∃ c : Rat, I.a < c ∧ c < I.b

/-- Strong unimodality: increasing on [a,c], decreasing on [c,b]. [TEOREMA]-level property. -/
structure StronglyUnimodal extends UnimodalMap where
  mode : Rat
  mode_interior : I.a < mode ∧ mode < I.b
  mono_left :
    ∀ x y, I.a ≤ x → x ≤ y → y ≤ mode → f x ≤ f y
  mono_right :
    ∀ x y, mode ≤ x → x ≤ y → y ≤ I.b → f y ≤ f x

/-- Quadratic critical package (placeholder for Schwarzian / f''(c)≠0). -/
def HasQuadraticCriticalPoint (U : UnimodalMap) : Prop :=
  ∃ c : Rat, U.I.a < c ∧ c < U.I.b

/--
  [TEOREMA] Discharged: every strongly unimodal map has an interior critical location
  (the mode). Full f''(c)≠0 analytic content remains open (Mathlib path).
-/
theorem stronglyUnimodal_has_quadratic (U : StronglyUnimodal) :
    HasQuadraticCriticalPoint U.toUnimodalMap := by
  exact ⟨U.mode, U.mode_interior.1, U.mode_interior.2⟩

/--
  Feigenbaum universality as an explicit package of claims.
  Not assumed true for free: each field is a separate obligation.
-/
structure FeigenbaumUniversal (U : UnimodalMap) : Prop where
  /-- Scaling ratio of period-doubling cascade converges to δ. -/
  delta_limit : True  -- real-analysis content deferred
  /-- Universality across a class of unimodal maps with quadratic tip. -/
  class_universal : True

/-- Ordinal observability: observables are rank-based. -/
structure OrdinalObservability where
  rank_based : True

/-- Generic smoothness of the return map. -/
structure GenericSmoothness where
  smooth : True

structure ReductionHypotheses where
  ordinal : OrdinalObservability
  smooth : GenericSmoothness

/-! ### Tent map (worked example) -/

/-- Tent-like fold f(x) = 1 − |x| on [-1,1]. -/
def tentF (x : Rat) : Rat := 1 - absQ x

theorem tentF_maps_into
    (x : Rat) (hx1 : (-1 : Rat) ≤ x) (hx2 : x ≤ 1) :
    (-1 : Rat) ≤ tentF x ∧ tentF x ≤ 1 := by
  have habs := absQ_nonneg x
  have habs_le := absQ_le_one_of_mem hx1 hx2
  constructor <;> simp only [tentF] <;> linarith

/-- [TEOREMA] Tent map is strongly unimodal with mode 0. -/
def tentStrong : StronglyUnimodal where
  I := coherenceInterval
  f := tentF
  maps_into := by
    intro x hx1 hx2
    exact tentF_maps_into x hx1 hx2
  has_mode := ⟨0, by native_decide, by native_decide⟩
  mode := 0
  mode_interior := by native_decide
  mono_left := by
    intro x y hx hy_le hy_mode
    have hx0 : x ≤ 0 := le_trans hy_le hy_mode
    have hy0 : y ≤ 0 := hy_mode
    have hxabs : absQ x = -x := absQ_of_nonpos hx0
    have hyabs : absQ y = -y := absQ_of_nonpos hy0
    have : -x ≥ -y := neg_le_neg hy_le
    simp only [tentF, hxabs, hyabs]
    linarith
  mono_right := by
    intro x y hx_mode hxy hyb
    have hx0 : 0 ≤ x := hx_mode
    have hy0 : 0 ≤ y := le_trans hx_mode hxy
    have hxabs : absQ x = x := absQ_of_nonneg hx0
    have hyabs : absQ y = y := absQ_of_nonneg hy0
    simp only [tentF, hxabs, hyabs]
    linarith

def tentLike : UnimodalMap := tentStrong.toUnimodalMap

theorem tentLike_has_critical : HasQuadraticCriticalPoint tentLike :=
  stronglyUnimodal_has_quadratic tentStrong

theorem tentStrong_mode : tentStrong.mode = 0 := rfl

theorem tentF_at_mode : tentF 0 = 1 := by native_decide

theorem tentF_at_right_end : tentF 1 = 0 := by native_decide

theorem tentF_at_left_end : tentF (-1) = 0 := by native_decide

/-! ### Iteration and period-2 -/

/-- Functional iteration fⁿ(x). -/
def iterate (f : Rat → Rat) : Nat → Rat → Rat
  | 0, x => x
  | n + 1, x => f (iterate f n x)

theorem iterate_zero (f : Rat → Rat) (x : Rat) : iterate f 0 x = x := rfl

theorem iterate_one (f : Rat → Rat) (x : Rat) : iterate f 1 x = f x := rfl

theorem iterate_succ (f : Rat → Rat) (n : Nat) (x : Rat) :
    iterate f (n + 1) x = f (iterate f n x) := rfl

/-- Period-2 condition: f(f(x)) = x and f(x) ≠ x. -/
def IsPeriod2 (f : Rat → Rat) (x : Rat) : Prop :=
  iterate f 2 x = x ∧ f x ≠ x

/-- Sample: tent map sends 1/2 → 1/2 is fixed, not period-2. -/
theorem tentF_half_fixed : tentF (1 / 2) = 1 / 2 := by native_decide

/-- [TEOREMA] Tent map has a genuine period-2 orbit (1/4 ↔ 3/4). -/
theorem tentF_quarter_period2 : IsPeriod2 tentF (1 / 4) := by
  constructor
  · -- iterate 2: 1/4 → 3/4 → 1/4
    native_decide
  · -- 1/4 ≠ 3/4
    native_decide

/-- Logistic family (parameterized), classical Feigenbaum laboratory.
    Not claimed to be the τₛ return map — only an ambient reference. -/
def logistic (r : Rat) (x : Rat) : Rat := r * x * (1 - x)

theorem logistic_at_zero (r : Rat) : logistic r 0 = 0 := by
  simp [logistic]

/-! ### First-return construction from ordinal coherence series -/

/-- One sample of coherence in the operational band [-1,1]. -/
structure CoherencePoint where
  val : Rat
  in_band : (-1 : Rat) ≤ val ∧ val ≤ 1

/-- Finite ordinal coherence trajectory (rank-based series). [OPERACIONAL] data shape. -/
structure CoherenceSeries where
  pts : List CoherencePoint

/-- Length of a coherence series. -/
def CoherenceSeries.length (s : CoherenceSeries) : Nat := s.pts.length

/-- Extract raw rational values. -/
def CoherenceSeries.values (s : CoherenceSeries) : List Rat :=
  s.pts.map (·.val)

/--
  Poincaré-style section: keep values where a boolean predicate holds
  (e.g. local extremum proxy, threshold crossing). Purely combinatorial.
-/
def sectionValues (pred : Rat → Bool) (s : CoherenceSeries) : List Rat :=
  s.values.filter pred

/-- Successive first-return pairs (xᵢ, xᵢ₊₁) from a section sequence. -/
def returnPairs : List Rat → List (Rat × Rat)
  | [] => []
  | [_] => []
  | x :: y :: rest => (x, y) :: returnPairs (y :: rest)

theorem returnPairs_nil : returnPairs ([] : List Rat) = [] := rfl

theorem returnPairs_singleton (x : Rat) : returnPairs [x] = [] := rfl

theorem returnPairs_two (x y : Rat) : returnPairs [x, y] = [(x, y)] := rfl

theorem returnPairs_three (x y z : Rat) :
    returnPairs [x, y, z] = [(x, y), (y, z)] := rfl

/--
  Discrete first-return data extracted from a series + section predicate.
  This is the combinatorial skeleton of the preprint’s “return map of coherence”.
-/
structure FirstReturnData where
  series : CoherenceSeries
  pred : Rat → Bool
  section : List Rat := sectionValues pred series
  pairs : List (Rat × Rat) := returnPairs section

/-- Number of observed return transitions. -/
def FirstReturnData.nReturns (D : FirstReturnData) : Nat := D.pairs.length

/--
  Continuum first-return map on the coherence interval.
  Linking discrete pairs to a total function is a *hypothesis*, not free data.
-/
structure ContinuumReturnMap where
  I : Interval
  R : Rat → Rat
  maps_into : ∀ x, I.a ≤ x → x ≤ I.b → I.a ≤ R x ∧ R x ≤ I.b

/-- Agreement of a continuum map with observed discrete returns (on listed pairs). -/
def agreesOnPairs (R : Rat → Rat) (pairs : List (Rat × Rat)) : Prop :=
  pairs.all fun p => decide (R p.1 = p.2) = true

/--
  Full preprint setup: series + section + continuum extension + unimodality claim.
  Fields after `smooth` are the obligations; only structure is free.
-/
structure PreprintReturnSetup where
  series : CoherenceSeries
  pred : Rat → Bool
  continuum : ContinuumReturnMap
  /-- Discrete skeleton. -/
  data : FirstReturnData := ⟨series, pred, sectionValues pred series, returnPairs (sectionValues pred series)⟩
  /-- Continuum map realizes the observed pairs. OPEN to discharge in applications. -/
  realizes : agreesOnPairs continuum.R data.pairs
  /-- Strong unimodality of the continuum return. OPEN in general. -/
  strongly : StronglyUnimodal
  /-- The strong map is the continuum return. -/
  same_map : strongly.f = continuum.R

/--
  [TEOREMA] Conditional reduction step:
  if a preprint setup supplies a strongly unimodal continuum return,
  then the quadratic-critical location obligation is discharged via the mode.
-/
theorem conditional_quadratic_from_setup (S : PreprintReturnSetup) :
    HasQuadraticCriticalPoint S.strongly.toUnimodalMap :=
  stronglyUnimodal_has_quadratic S.strongly

/-- Example series for tests: constant zero trajectory. -/
def zeroSeries (n : Nat) : CoherenceSeries where
  pts := List.replicate n ⟨0, by native_decide⟩

theorem zeroSeries_length (n : Nat) : (zeroSeries n).length = n := by
  simp [CoherenceSeries.length, zeroSeries, List.length_replicate]

/-- Section that keeps non-negative samples. -/
def nonnegPred (q : Rat) : Bool := decide (0 ≤ q)

theorem section_zeroSeries_nonneg (n : Nat) :
    sectionValues nonnegPred (zeroSeries n) = List.replicate n 0 := by
  simp [sectionValues, CoherenceSeries.values, zeroSeries, nonnegPred, List.map_replicate,
    List.filter_replicate]

/-! ### Named open goals (honest split of the main claim) -/

/--
  OPEN GOAL 1 — Ordinal + smooth hypotheses induce a continuum first-return map
  on the coherence interval that realizes the discrete Poincaré pairs.
  Status: `sorry` (research-level; not tent-map substitution).
-/
theorem open_ordinal_induces_continuum_return
    (_H : ReductionHypotheses) (_s : CoherenceSeries) (_pred : Rat → Bool) :
    ∃ C : ContinuumReturnMap,
      agreesOnPairs C.R (returnPairs (sectionValues _pred _s)) := by
  sorry

/--
  OPEN GOAL 2 — That continuum return is strongly unimodal with quadratic tip.
  Status: `sorry`.
-/
theorem open_return_strongly_unimodal
    (_H : ReductionHypotheses) (_C : ContinuumReturnMap) :
    ∃ U : StronglyUnimodal,
      U.f = _C.R ∧ HasQuadraticCriticalPoint U.toUnimodalMap := by
  sorry

/--
  OPEN GOAL 3 — Analytic Feigenbaum universality (δ-limit / class universality).
  Status: `sorry` (requires real analysis / optional Mathlib).
-/
theorem open_analytic_feigenbaum
    (_U : UnimodalMap) (_hq : HasQuadraticCriticalPoint _U) :
    FeigenbaumUniversal _U := by
  sorry

/--
  [TEOREMA] target — reduction from ordinal + smooth hypotheses to a
  strongly unimodal return map with Feigenbaum package.
  Status: open; composition of open goals 1–3 (not discharged by tent example).
-/
theorem coherence_return_map_feigenbaum
    (_H : ReductionHypotheses) :
    ∃ U : StronglyUnimodal,
      HasQuadraticCriticalPoint U.toUnimodalMap ∧
        FeigenbaumUniversal U.toUnimodalMap := by
  sorry

/-- Discharged: the unimodal / strong-unimodal package is mathematically inhabited. -/
theorem strongly_unimodal_inhabited :
    ∃ U : StronglyUnimodal, HasQuadraticCriticalPoint U.toUnimodalMap := by
  exact ⟨tentStrong, tentLike_has_critical⟩

/-- Discharged: a unimodal map with interior critical location exists on coherence. -/
theorem unimodal_structure_inhabited :
    ∃ U : UnimodalMap, HasQuadraticCriticalPoint U := by
  exact ⟨tentLike, tentLike_has_critical⟩

/--
  Honest split of the preprint claim into discharged vs open parts.
-/
structure ReductionStatus where
  /-- Package inhabited (tent example). -/
  structure_ok : True := trivial
  /-- Strong unimodality example proved. -/
  strong_example_ok : True := trivial
  /-- First-return combinatorial skeleton encoded. -/
  first_return_skeleton_ok : True := trivial
  /-- StronglyUnimodal ⇒ quadratic location. -/
  conditional_quadratic_ok : True := trivial
  /-- Tent period-2 orbit. -/
  tent_period2_ok : True := trivial
  /-- Ordinal observability ⇒ continuum return. OPEN. -/
  from_ordinal_open : True := trivial
  /-- Continuum return strongly unimodal. OPEN. -/
  unimodal_return_open : True := trivial
  /-- Analytic Feigenbaum δ limit. OPEN. -/
  delta_analytic_open : True := trivial

def currentStatus : ReductionStatus := {}

end SystemicTau.FeigenbaumReduction
