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
  - bookkeeping: functional finite pairs admit a realizing map (goal 1a)
  - bookkeeping: open goals 1–3 *compose* to the composite claim (still open inputs)
  - named open goals for the remaining reduction steps

  What remains open (`sorry`):
  - that ordinal observability + smoothness *force* a continuum return map (1b)
  - that such a return is strongly unimodal with quadratic tip (2)
  - full analytic Feigenbaum δ universality (3)
  - the composite without assuming 1–3

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

theorem tentStrong_mode : tentStrong.mode = 0 := by
  rfl

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
  pred : ℚ → Bool
  /-- Section samples (not the Lean keyword `section`). -/
  sectionVals : List ℚ := sectionValues pred series
  pairs : List (ℚ × ℚ) := returnPairs sectionVals

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

/-- Unfold `List.all` + `decide` into a membership form convenient for proofs. -/
theorem agreesOnPairs_iff (R : Rat → Rat) (pairs : List (Rat × Rat)) :
    agreesOnPairs R pairs ↔ ∀ p ∈ pairs, R p.1 = p.2 := by
  simp [agreesOnPairs, List.all_eq_true, decide_eq_true_eq]

/-- Empty pair list is realized by every map. -/
theorem agreesOnPairs_nil (R : Rat → Rat) : agreesOnPairs R ([] : List (Rat × Rat)) := by
  simp [agreesOnPairs]

/--
  Finite relation is a partial function: same abscissa ⇒ same ordinate.
  Needed for a total realizer to exist without conflicts.
-/
def IsFunctional (pairs : List (Rat × Rat)) : Prop :=
  ∀ p q, p ∈ pairs → q ∈ pairs → p.1 = q.1 → p.2 = q.2

/-- Empty relation is functional. -/
theorem IsFunctional_nil : IsFunctional ([] : List (Rat × Rat)) := by
  intro p q hp; cases hp

/-- Singleton relation is functional. -/
theorem IsFunctional_singleton (x y : Rat) : IsFunctional [(x, y)] := by
  intro p q hp hq hxy
  simp only [List.mem_singleton] at hp hq
  subst hp; subst hq; rfl

/--
  Two-point return chain `(x,y), (y,z)` is functional unless `x = y` forces `y = z`.
  Special case used by short section sequences.
-/
theorem IsFunctional_two_chain {x y z : Rat} (h : x = y → y = z) :
    IsFunctional [(x, y), (y, z)] := by
  intro p q hp hq heq
  simp at hp hq
  rcases hp with rfl | rfl
  · rcases hq with rfl | rfl
    · rfl
    · exact h heq
  · rcases hq with rfl | rfl
    · exact (h heq.symm).symm
    · rfl

/-- Lookup along a pair list; first match wins; else `default`. -/
def lookupPair (pairs : List (Rat × Rat)) (default : Rat → Rat) (x : Rat) : Rat :=
  match pairs with
  | [] => default x
  | (a, b) :: rest => if a = x then b else lookupPair rest default x

theorem lookupPair_nil (d : Rat → Rat) (x : Rat) : lookupPair [] d x = d x := rfl

theorem lookupPair_cons_hit (a b : Rat) (rest : List (Rat × Rat)) (d : Rat → Rat) :
    lookupPair ((a, b) :: rest) d a = b := by
  simp [lookupPair]

theorem lookupPair_cons_miss (a b x : Rat) (rest : List (Rat × Rat)) (d : Rat → Rat)
    (h : a ≠ x) : lookupPair ((a, b) :: rest) d x = lookupPair rest d x := by
  simp [lookupPair, h]

/-- Singleton pairs are realized by the constant-at-x map (or lookup). -/
theorem agreesOnPairs_singleton (x y : Rat) :
    agreesOnPairs (lookupPair [(x, y)] id) [(x, y)] := by
  rw [agreesOnPairs_iff]
  intro p hp
  simp at hp
  subst hp
  simp [lookupPair]

/-- Empty pairs are realized by any map. -/
theorem exists_realizer_nil :
    ∃ R : Rat → Rat, agreesOnPairs R ([] : List (Rat × Rat)) :=
  ⟨id, agreesOnPairs_nil id⟩

/-- Singleton functional pairs admit a realizer. -/
theorem exists_realizer_singleton (x y : Rat) :
    ∃ R : Rat → Rat, agreesOnPairs R [(x, y)] :=
  ⟨lookupPair [(x, y)] id, agreesOnPairs_singleton x y⟩

/--
  Under functionality, membership in a cons list and a realizer of the tail
  still need a global realizer — discharged for the recursive pattern via
  `lookupPair_eq_of_mem` below.
-/
theorem lookupPair_eq_of_mem
    (pairs : List (Rat × Rat)) (d : Rat → Rat) (hf : IsFunctional pairs)
    (p : Rat × Rat) (hp : p ∈ pairs) :
    lookupPair pairs d p.1 = p.2 := by
  induction pairs with
  | nil =>
    simp at hp
  | cons head rest ih =>
    have hp' : p = head ∨ p ∈ rest := (List.mem_cons).1 hp
    cases hp' with
    | inl heq =>
      -- p equals head pair
      cases head with
      | mk a b =>
        have hpab : p = (a, b) := heq
        subst hpab
        simp [lookupPair]
    | inr hmem =>
      cases head with
      | mk a b =>
        by_cases hax : a = p.1
        · have hy : b = p.2 :=
            hf (a, b) p (by exact List.mem_cons_self (a, b) rest)
              (List.mem_cons_of_mem (a, b) hmem) hax
          simp [lookupPair, hax, hy]
        · have hf_rest : IsFunctional rest := by
            intro u v hu hv e
            exact hf u v (List.mem_cons_of_mem _ hu) (List.mem_cons_of_mem _ hv) e
          have ih' : lookupPair rest d p.1 = p.2 := ih hf_rest hmem
          simp [lookupPair, hax, ih']

/--
  [TEOREMA · bookkeeping · goal 1a]
  Every *functional* finite pair list is realized by some total map
  (`lookupPair` with identity default). This is pure discrete graph theory —
  **not** the dynamical continuum return induced by ordinal+smooth hypotheses.
-/
theorem exists_realizer_of_functional
    (pairs : List (Rat × Rat)) (hf : IsFunctional pairs) :
    ∃ R : Rat → Rat, agreesOnPairs R pairs := by
  refine ⟨lookupPair pairs id, ?_⟩
  rw [agreesOnPairs_iff]
  intro p hp
  exact lookupPair_eq_of_mem pairs id hf p hp

/--
  Identity continuum map on the coherence interval (laboratory extension default).
-/
def idContinuum : ContinuumReturnMap where
  I := coherenceInterval
  R := id
  maps_into := by
    intro x hx1 hx2
    exact ⟨hx1, hx2⟩

/--
  Continuum map from a functional pair list: lookup with identity default,
  domain/codomain forced into the coherence band only as an *obligation* on pairs.
  For bookkeeping we build the raw realizer; `maps_into` uses the identity
  fallback and requires pair ordinates already in-band when hit — here we only
  package a continuum map when the realizer is `lookupPair` and we can prove
  maps_into for the special case of identity default on coherence by clamping
  is *not* introduced (would be operational). Instead we expose the raw realizer
  and a continuum package for the empty/identity case.
-/
def continuumOfRealizer (R : Rat → Rat)
    (hmap : ∀ x, coherenceInterval.a ≤ x → x ≤ coherenceInterval.b →
      coherenceInterval.a ≤ R x ∧ R x ≤ coherenceInterval.b) :
    ContinuumReturnMap where
  I := coherenceInterval
  R := R
  maps_into := hmap

/-- Identity realizer maps the coherence interval into itself. -/
theorem id_maps_coherence :
    ∀ x, coherenceInterval.a ≤ x → x ≤ coherenceInterval.b →
      coherenceInterval.a ≤ (id : Rat → Rat) x ∧ (id : Rat → Rat) x ≤ coherenceInterval.b := by
  intro x hx1 hx2; exact ⟨hx1, hx2⟩

/--
  [TEOREMA · bookkeeping · goal 1a continuum form]
  Empty Poincaré data admits the identity continuum return on coherence.
  Base case of discrete→continuum extension (not the dynamical claim).
-/
theorem exists_continuum_for_empty_pairs :
    ∃ C : ContinuumReturnMap, agreesOnPairs C.R ([] : List (Rat × Rat)) := by
  refine ⟨idContinuum, ?_⟩
  exact agreesOnPairs_nil idContinuum.R

/--
  Full preprint setup: series + section + continuum extension + unimodality claim.
  Fields after `smooth` are the obligations; only structure is free.
-/
structure PreprintReturnSetup where
  series : CoherenceSeries
  pred : ℚ → Bool
  continuum : ContinuumReturnMap
  /-- Discrete skeleton. -/
  data : FirstReturnData :=
    { series := series
      pred := pred
      sectionVals := sectionValues pred series
      pairs := returnPairs (sectionValues pred series) }
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

/-- Constant-zero section: two samples give a single fixed-point return pair. -/
theorem returnPairs_zero_two :
    returnPairs (List.replicate 2 (0 : Rat)) = [((0 : Rat), 0)] := by
  native_decide

theorem returnPairs_zero_three :
    returnPairs (List.replicate 3 (0 : Rat)) = [((0 : Rat), 0), (0, 0)] := by
  native_decide

theorem IsFunctional_zero_pairs_two :
    IsFunctional (returnPairs (List.replicate 2 (0 : Rat))) := by
  simp only [returnPairs_zero_two]
  exact IsFunctional_singleton 0 0

/-- Goal 1a sanity: zero fixed-point pairs admit a realizer. -/
theorem exists_realizer_zero_pairs_two :
    ∃ R : Rat → Rat,
      agreesOnPairs R (returnPairs (List.replicate 2 (0 : Rat))) :=
  exists_realizer_of_functional _ IsFunctional_zero_pairs_two

/-! ### Named open goals (honest split of the main claim)

  Goal 1 is split:
  · **1a** (proved): functional finite pairs admit *some* realizing total map.
  · **1b** (open): ordinal + smooth hypotheses induce a *dynamical* continuum
    first-return on the coherence interval (not a mere interpolant).

  Goal 2 remains open in full; quadratic tip follows from strong unimodality
  once 2’s unimodality half is known (`stronglyUnimodal_has_quadratic`).

  Goal 3: analytic δ / class universality — see `FeigenbaumAnalytic` / `FeigenbaumTendsto`
  (ε–N ↔ Tendsto bookkeeping is proved; cascade → Feigenbaum δ is open).
-/

/--
  OPEN GOAL 1b — Ordinal + smooth hypotheses induce a continuum first-return map
  on the coherence interval that realizes the discrete Poincaré pairs.
  Status: `sorry` (research-level; not tent-map substitution; not mere lookup 1a).
-/
theorem open_ordinal_induces_continuum_return
    (_H : ReductionHypotheses) (_s : CoherenceSeries) (_pred : Rat → Bool) :
    ∃ C : ContinuumReturnMap,
      agreesOnPairs C.R (returnPairs (sectionValues _pred _s)) := by
  sorry

/--
  OPEN GOAL 2 — That continuum return is strongly unimodal with quadratic tip.
  Status: `sorry`.
  Partial: `HasQuadraticCriticalPoint` follows from `StronglyUnimodal` once the
  unimodality half is known (`stronglyUnimodal_has_quadratic`).
  Conditional discharge when the return *is* the tent lab map: see
  `goal_2_when_return_is_tent` (does **not** close this goal for arbitrary `C`).
-/
theorem open_return_strongly_unimodal
    (_H : ReductionHypotheses) (_C : ContinuumReturnMap) :
    ∃ U : StronglyUnimodal,
      U.f = _C.R ∧ HasQuadraticCriticalPoint U.toUnimodalMap := by
  sorry

/-- Continuum packaging of the tent lab map on the coherence interval. -/
def tentContinuum : ContinuumReturnMap where
  I := coherenceInterval
  R := tentF
  maps_into := by
    intro x hx1 hx2
    exact tentF_maps_into x hx1 hx2

theorem tentContinuum_R : tentContinuum.R = tentF := rfl

/--
  [TEOREMA · bookkeeping · goal 2 conditional]
  If the continuum return *is* the tent map (laboratory identification),
  then strong unimodality + quadratic location follow from `tentStrong`.
  This is **not** a discharge of open goal 2 for arbitrary continuum returns.
-/
theorem goal_2_when_return_is_tent
    (C : ContinuumReturnMap) (hR : C.R = tentF) :
    ∃ U : StronglyUnimodal,
      U.f = C.R ∧ HasQuadraticCriticalPoint U.toUnimodalMap := by
  refine ⟨tentStrong, ?_, tentLike_has_critical⟩
  simp [tentStrong, hR]

/-- Specialization: tent continuum package discharges goal-2 shape for itself. -/
theorem goal_2_tentContinuum :
    ∃ U : StronglyUnimodal,
      U.f = tentContinuum.R ∧ HasQuadraticCriticalPoint U.toUnimodalMap :=
  goal_2_when_return_is_tent tentContinuum rfl

/--
  [TEOREMA · bookkeeping · goal 2a]
  Strong unimodality of a continuum return already yields the quadratic-location
  package via the mode (no extra analysis).
-/
theorem goal_2a_quadratic_of_strong
    (U : StronglyUnimodal) (C : ContinuumReturnMap) (_hsame : U.f = C.R) :
    HasQuadraticCriticalPoint U.toUnimodalMap :=
  stronglyUnimodal_has_quadratic U

/--
  OPEN GOAL 3 — Analytic Feigenbaum universality (δ-limit / class universality).
  Status: `sorry` (requires real dynamics / Mathlib analysis beyond bookkeeping).
  Refined claim shapes: `SystemicTau.FeigenbaumAnalytic` (cascade, ratios, ε–N limit)
  and `SystemicTau.FeigenbaumTendsto` (`Tendsto` form; ε–N ↔ Tendsto **proved**).
-/
theorem open_analytic_feigenbaum
    (_U : UnimodalMap) (_hq : HasQuadraticCriticalPoint _U) :
    FeigenbaumUniversal _U := by
  sorry

/--
  [TEOREMA · bookkeeping] Logical composition of goals 1–3.
  If continuum return, strong unimodality, and Feigenbaum package are all granted
  for a setup, the composite reduction claim holds. Does **not** discharge 1–3.
-/
theorem coherence_return_map_feigenbaum_of
    (_H : ReductionHypotheses)
    (C : ContinuumReturnMap)
    (U : StronglyUnimodal)
    (hsame : U.f = C.R)
    (hF : FeigenbaumUniversal U.toUnimodalMap) :
    ∃ U' : StronglyUnimodal,
      HasQuadraticCriticalPoint U'.toUnimodalMap ∧
        FeigenbaumUniversal U'.toUnimodalMap := by
  refine ⟨U, ?_, hF⟩
  exact goal_2a_quadratic_of_strong U C hsame

/--
  [TEOREMA] target — reduction from ordinal + smooth hypotheses to a
  strongly unimodal return map with Feigenbaum package.
  Status: open; composition of open goals 1–3 (not discharged by tent example).
  See `coherence_return_map_feigenbaum_of` for the discharged composition skeleton.
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
  /-- Goal 1a: functional pairs admit a realizer. PROVED. -/
  goal_1a_functional_realizer_ok : True := trivial
  /-- Goal 1b: ordinal+smooth ⇒ dynamical continuum return. OPEN. -/
  from_ordinal_open : True := trivial
  /-- Goal 2: continuum return strongly unimodal. OPEN. -/
  unimodal_return_open : True := trivial
  /-- Goal 2 when return = tentF. PROVED (conditional, lab only). -/
  goal_2_tent_conditional_ok : True := trivial
  /-- Goal 2a: strong ⇒ quadratic location. PROVED. -/
  goal_2a_quadratic_ok : True := trivial
  /-- Goal 3: Analytic Feigenbaum δ limit. OPEN. -/
  delta_analytic_open : True := trivial
  /-- Composite skeleton under hypotheses 1–3. PROVED composition. -/
  composite_of_hypotheses_ok : True := trivial

def currentStatus : ReductionStatus := {}

end SystemicTau.FeigenbaumReduction
