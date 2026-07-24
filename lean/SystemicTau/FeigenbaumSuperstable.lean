/-
  Termwise superstable parameters of the real logistic family.

  Steps delivered here
  --------------------
  · n = 0: unique superstable r = 2 on (0,4)   (f¹(crit)=crit)
  · n = 1: unique strict superstable r = 1+√5 on (2,4);
            honesty: r = 3 is *not* superstable period-2
  · n = 2: residual characterization f⁴(crit)=crit; strictness excludes n=0,1;
            no closed-form root claimed; cascade limit remains open

  Note: IsSuperstable n means f^{2^n}(crit)=crit, so n=0 uses one iterate
  (2^0 = 1), n=1 uses two iterates, n=2 uses four.

  Does **not** prove: δ_n → δ for true roots; C²-open renorm; free-c τ_ch.

  Cite: Feigenbaum, J. Stat. Phys. 19 (1978), 21 (1979); standard logistic cascade.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Data.Real.Sqrt
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.IntervalCases
import SystemicTau.FeigenbaumLogistic

namespace SystemicTau.FeigenbaumSuperstable

open SystemicTau.FeigenbaumLogistic
open SystemicTau.FeigenbaumAnalytic

/-! ### Real logistic and iterates -/

/-- Real logistic map \(f_r(x) = r x (1-x)\). -/
noncomputable def logisticR (r x : ℝ) : ℝ := r * x * (1 - x)

/-- Critical point (quadratic mode). -/
noncomputable def crit : ℝ := 1 / 2

theorem logisticR_crit (r : ℝ) : logisticR r crit = r / 4 := by
  simp only [logisticR, crit]
  ring

/-- Forward iterates of the logistic map. -/
noncomputable def logisticIter (r : ℝ) : ℕ → ℝ → ℝ
  | 0, x => x
  | n + 1, x => logisticR r (logisticIter r n x)

theorem logisticIter_zero (r x : ℝ) : logisticIter r 0 x = x := rfl

theorem logisticIter_succ (r : ℝ) (n : ℕ) (x : ℝ) :
    logisticIter r (n + 1) x = logisticR r (logisticIter r n x) :=
  rfl

theorem logisticIter_one (r x : ℝ) : logisticIter r 1 x = logisticR r x :=
  rfl

/-- Unfold two iterates at the critical point. -/
theorem logisticIter_two_crit (r : ℝ) :
    logisticIter r 2 crit = r ^ 2 / 4 - r ^ 3 / 16 := by
  simp only [logisticIter, logisticR, crit]
  ring

/-- Composition of iterates: \(f^{m+n} = f^m \circ f^n\). -/
theorem logisticIter_add (r : ℝ) (m n : ℕ) (x : ℝ) :
    logisticIter r (m + n) x = logisticIter r m (logisticIter r n x) := by
  induction m with
  | zero => simp [logisticIter]
  | succ m ih =>
    rw [Nat.succ_add, logisticIter_succ, ih, logisticIter_succ]

/-! ### Superstable predicates -/

/--
  Superstable of nominal period \(2^n\): \(f_r^{\circ 2^n}(1/2)=1/2\).
  For \(n=0\) this is one iterate (\(2^0=1\)).
-/
def IsSuperstable (n : ℕ) (r : ℝ) : Prop :=
  logisticIter r (2 ^ n) crit = crit

/--
  Strict superstable of period \(2^n\): superstable at \(n\) and at no smaller
  stage \(k < n\).
-/
def IsStrictSuperstable (n : ℕ) (r : ℝ) : Prop :=
  IsSuperstable n r ∧ ∀ k : ℕ, k < n → ¬ IsSuperstable k r

/-! ### Step A — n = 0 (period 1: one iterate) -/

theorem isSuperstable_zero_iff (r : ℝ) :
    IsSuperstable 0 r ↔ r / 4 = (1 : ℝ) / 2 := by
  -- 2^0 = 1
  have hpow : (2 : ℕ) ^ 0 = 1 := Nat.pow_zero 2
  calc
    IsSuperstable 0 r ↔ logisticIter r 1 crit = crit := by
      simp only [IsSuperstable, hpow]
    _ ↔ logisticR r crit = crit := by rw [logisticIter_one]
    _ ↔ r / 4 = crit := by rw [logisticR_crit]
    _ ↔ r / 4 = (1 : ℝ) / 2 := by simp only [crit]

theorem superstable_period1_eq_two {r : ℝ} (h : IsSuperstable 0 r) : r = 2 := by
  have : r / 4 = (1 : ℝ) / 2 := (isSuperstable_zero_iff r).1 h
  linarith

theorem two_is_superstable_period1 : IsSuperstable 0 (2 : ℝ) := by
  rw [isSuperstable_zero_iff]
  norm_num

theorem two_is_strict_superstable_period1 : IsStrictSuperstable 0 (2 : ℝ) := by
  refine ⟨two_is_superstable_period1, ?_⟩
  intro k hk
  exact (Nat.not_lt_zero k hk).elim

/--
  [TEOREMA] Unique period-1 superstable parameter on \((0,4)\).
-/
theorem unique_superstable_period1_on_Ioo
    {r : ℝ} (_hr0 : 0 < r) (_hr4 : r < 4) (h : IsSuperstable 0 r) :
    r = 2 :=
  superstable_period1_eq_two h

/-- Fixed critical point propagates to all dyadic iterates. -/
theorem isSuperstable_of_period1 {r : ℝ} (h : IsSuperstable 0 r) (n : ℕ) :
    IsSuperstable n r := by
  have hr : r = 2 := superstable_period1_eq_two h
  subst hr
  have hfix : logisticR (2 : ℝ) crit = crit := by
    simp only [logisticR, crit]; norm_num
  have hiter : ∀ m, logisticIter (2 : ℝ) m crit = crit := by
    intro m
    induction m with
    | zero => rfl
    | succ m ih =>
      simp only [logisticIter_succ, ih, hfix]
  exact hiter (2 ^ n)

/-! ### Step B — n = 1 (period 2: two iterates) -/

/-- Residual polynomial after clearing denominators from \(f^2(\mathrm{crit})=\mathrm{crit}\). -/
noncomputable def period2Poly (r : ℝ) : ℝ := r ^ 3 - 4 * r ^ 2 + 8

theorem period2Poly_factor (r : ℝ) :
    period2Poly r = (r - 2) * (r ^ 2 - 2 * r - 4) := by
  simp only [period2Poly]
  ring

theorem isSuperstable_one_iff_iter (r : ℝ) :
    IsSuperstable 1 r ↔ logisticIter r 2 crit = crit := by
  simp only [IsSuperstable, pow_one]

theorem isSuperstable_one_iff (r : ℝ) :
    IsSuperstable 1 r ↔ r ^ 2 / 4 - r ^ 3 / 16 = (1 : ℝ) / 2 := by
  rw [isSuperstable_one_iff_iter, logisticIter_two_crit, crit]

theorem isSuperstable_one_iff_poly (r : ℝ) :
    IsSuperstable 1 r ↔ period2Poly r = 0 := by
  rw [isSuperstable_one_iff, period2Poly]
  constructor
  · intro h
    -- From r²/4 - r³/16 = 1/2, multiply by 16: 4r² - r³ = 8
    have h16 : (16 : ℝ) * (r ^ 2 / 4 - r ^ 3 / 16) = 16 * (1 / 2) := by
      rw [h]
    have hL : (16 : ℝ) * (r ^ 2 / 4 - r ^ 3 / 16) = 4 * r ^ 2 - r ^ 3 := by ring
    have hR : (16 : ℝ) * (1 / 2) = 8 := by norm_num
    have : 4 * r ^ 2 - r ^ 3 = 8 := by rw [← hL, h16, hR]
    nlinarith
  · intro h
    -- period2Poly = 0 ⇒ 4r² - r³ = 8 ⇒ divide by 16
    have : 4 * r ^ 2 - r ^ 3 = 8 := by nlinarith
    have hform : r ^ 2 / 4 - r ^ 3 / 16 = (4 * r ^ 2 - r ^ 3) / 16 := by ring
    rw [hform, this]
    norm_num

/-- Roots of the quadratic factor \(r^2-2r-4=0\). -/
theorem quadratic_factor_roots (r : ℝ) :
    r ^ 2 - 2 * r - 4 = 0 ↔ r = 1 + Real.sqrt 5 ∨ r = 1 - Real.sqrt 5 := by
  have h5 : (0 : ℝ) ≤ 5 := by norm_num
  have hsq : (Real.sqrt 5) ^ 2 = 5 := Real.sq_sqrt h5
  constructor
  · intro h
    -- Complete the square: (r-1)² = 5
    have hcomp : (r - 1) ^ 2 = 5 := by
      have : r ^ 2 - 2 * r + 1 = 5 := by nlinarith
      convert this using 1
      ring
    -- Cases by comparing r-1 with 0
    by_cases hpos : 0 ≤ r - 1
    · left
      have : r - 1 = Real.sqrt 5 := by
        have := congrArg Real.sqrt hcomp
        -- √((r-1)²) = √5 and r-1 ≥ 0 ⇒ r-1 = √5
        rw [Real.sqrt_sq hpos] at this
        exact this
      linarith
    · right
      push_neg at hpos
      have hnonpos : r - 1 ≤ 0 := le_of_lt hpos
      have habs : |r - 1| = -(r - 1) := abs_of_nonpos hnonpos
      have : Real.sqrt ((r - 1) ^ 2) = Real.sqrt 5 := by rw [hcomp]
      rw [Real.sqrt_sq_eq_abs, habs] at this
      -- -(r-1) = √5 ⇒ r-1 = -√5
      have : r - 1 = -Real.sqrt 5 := by linarith
      linarith
  · intro h
    cases h with
    | inl hp =>
      rw [hp]
      nlinarith [hsq]
    | inr hm =>
      rw [hm]
      nlinarith [hsq]

theorem period2Poly_eq_zero_iff (r : ℝ) :
    period2Poly r = 0 ↔
      r = 2 ∨ r = 1 + Real.sqrt 5 ∨ r = 1 - Real.sqrt 5 := by
  constructor
  · intro h
    have hmul : (r - 2) * (r ^ 2 - 2 * r - 4) = 0 := by
      rw [← period2Poly_factor]; exact h
    rcases mul_eq_zero.mp hmul with h2 | hq
    · left; linarith
    · rcases (quadratic_factor_roots r).1 hq with hp | hm
      · right; left; exact hp
      · right; right; exact hm
  · intro h
    rw [period2Poly_factor]
    rcases h with h2 | hp | hm
    · simp [h2]
    · have : r ^ 2 - 2 * r - 4 = 0 := (quadratic_factor_roots r).2 (Or.inl hp)
      simp [this]
    · have : r ^ 2 - 2 * r - 4 = 0 := (quadratic_factor_roots r).2 (Or.inr hm)
      simp [this]

theorem one_add_sqrt5_gt_two : (2 : ℝ) < 1 + Real.sqrt 5 := by
  have h : (1 : ℝ) < Real.sqrt 5 := by
    rw [Real.lt_sqrt (by norm_num : (0 : ℝ) ≤ 1)]
    norm_num
  linarith

theorem one_add_sqrt5_lt_four : 1 + Real.sqrt 5 < (4 : ℝ) := by
  have h : Real.sqrt 5 < (3 : ℝ) := by
    rw [Real.sqrt_lt (by norm_num : (0 : ℝ) ≤ 5) (by norm_num : (0 : ℝ) ≤ 3)]
    norm_num
  linarith

theorem one_add_sqrt5_ne_two : (1 + Real.sqrt 5 : ℝ) ≠ 2 :=
  ne_of_gt one_add_sqrt5_gt_two

theorem one_add_sqrt5_is_superstable_period2 :
    IsSuperstable 1 (1 + Real.sqrt 5) := by
  rw [isSuperstable_one_iff_poly, period2Poly_eq_zero_iff]
  right; left; rfl

theorem one_add_sqrt5_is_strict_superstable_period2 :
    IsStrictSuperstable 1 (1 + Real.sqrt 5) := by
  refine ⟨one_add_sqrt5_is_superstable_period2, ?_⟩
  intro k hk
  have hk0 : k = 0 := Nat.lt_one_iff.mp hk
  subst hk0
  intro h0
  exact one_add_sqrt5_ne_two (superstable_period1_eq_two h0)

/--
  [TEOREMA] Unique strict period-2 superstable on \((2,4)\).
-/
theorem unique_strict_superstable_period2_on_Ioo
    {r : ℝ} (hr2 : (2 : ℝ) < r) (_hr4 : r < 4) (h : IsStrictSuperstable 1 r) :
    r = 1 + Real.sqrt 5 := by
  have hss : IsSuperstable 1 r := h.1
  have hpoly : period2Poly r = 0 := (isSuperstable_one_iff_poly r).1 hss
  have hroots := (period2Poly_eq_zero_iff r).1 hpoly
  rcases hroots with h2 | hp | hm
  · exact absurd h2 (ne_of_gt hr2)
  · exact hp
  · -- r = 1 - √5 < 0 contradicts r > 2
    have hneg : 1 - Real.sqrt 5 < (0 : ℝ) := by
      have : (1 : ℝ) < Real.sqrt 5 := by
        rw [Real.lt_sqrt (by norm_num : (0 : ℝ) ≤ 1)]
        norm_num
      linarith
    have : False := by
      rw [hm] at hr2
      linarith [hneg]
    exact this.elim

/--
  [TEOREMA · honesty]
  The logistic period-doubling *onset* landmark \(r=3\) is **not** the period-2
  superstable parameter (which is \(1+\sqrt5 \approx 3.236\)).
-/
theorem three_ne_period2_superstable : ¬ IsSuperstable 1 (3 : ℝ) := by
  intro h
  have hp : period2Poly (3 : ℝ) = 0 := (isSuperstable_one_iff_poly 3).1 h
  -- 27 - 36 + 8 = -1 ≠ 0
  norm_num [period2Poly] at hp

/-- Anchored chart \(r_1=3\) matches onset, not superstable period-2. -/
theorem logisticAnchoredR_one_ne_superstable_period2 :
    ¬ IsSuperstable 1 ((logisticAnchoredR 1 : ℚ) : ℝ) := by
  have h : (logisticAnchoredR 1 : ℚ) = 3 := logisticAnchoredR_one
  have : ((logisticAnchoredR 1 : ℚ) : ℝ) = 3 := by exact_mod_cast h
  rw [this]
  exact three_ne_period2_superstable

theorem logisticAnchoredR_zero_is_superstable_period1 :
    IsSuperstable 0 ((logisticAnchoredR 0 : ℚ) : ℝ) := by
  have h : (logisticAnchoredR 0 : ℚ) = 2 := logisticAnchoredR_zero
  have : ((logisticAnchoredR 0 : ℚ) : ℝ) = 2 := by exact_mod_cast h
  rw [this]
  exact two_is_superstable_period1

/-! ### Step C — n = 2 (period 4 residual + strict exclusion) -/

/-- Residual \(f_r^{\circ 4}(1/2) - 1/2\). Zero iff superstable at stage 2 (divisor form). -/
noncomputable def period4Residual (r : ℝ) : ℝ :=
  logisticIter r 4 crit - crit

theorem isSuperstable_two_iff (r : ℝ) :
    IsSuperstable 2 r ↔ period4Residual r = 0 := by
  have hpow : (2 : ℕ) ^ 2 = 4 := by native_decide
  simp only [IsSuperstable, period4Residual, hpow]
  constructor
  · intro h; linarith
  · intro h; linarith

/-- Period-1 superstable implies period-4 residual vanishes (not strict). -/
theorem period4Residual_of_period1 {r : ℝ} (h : IsSuperstable 0 r) :
    period4Residual r = 0 := by
  have h2 : IsSuperstable 2 r := isSuperstable_of_period1 h 2
  exact (isSuperstable_two_iff r).1 h2

/-- Period-2 superstable ⇒ \(f^2(\mathrm{crit})=\mathrm{crit}\) ⇒ \(f^4(\mathrm{crit})=\mathrm{crit}\). -/
theorem isSuperstable_two_of_one {r : ℝ} (h : IsSuperstable 1 r) :
    IsSuperstable 2 r := by
  have h2 : logisticIter r 2 crit = crit := by
    simpa [IsSuperstable, pow_one] using h
  have h4 : logisticIter r 4 crit = crit := by
    have hcomp : logisticIter r 4 crit = logisticIter r 2 (logisticIter r 2 crit) := by
      -- 4 = 2 + 2
      simpa using (logisticIter_add r 2 2 crit).symm
    rw [hcomp, h2, h2]
  simpa [IsSuperstable] using h4

theorem period4Residual_of_period2 {r : ℝ} (h : IsSuperstable 1 r) :
    period4Residual r = 0 :=
  (isSuperstable_two_iff r).1 (isSuperstable_two_of_one h)

/--
  [TEOREMA] Strict period-4 superstable excludes period-1 and period-2 stages.
-/
theorem strict_period4_excludes_lower {r : ℝ} (h : IsStrictSuperstable 2 r) :
    ¬ IsSuperstable 0 r ∧ ¬ IsSuperstable 1 r := by
  constructor
  · exact h.2 0 (by norm_num : (0 : ℕ) < 2)
  · exact h.2 1 (by norm_num : (1 : ℕ) < 2)

/-- Two is not a strict period-4 superstable. -/
theorem two_not_strict_period4 : ¬ IsStrictSuperstable 2 (2 : ℝ) := by
  intro h
  exact (strict_period4_excludes_lower h).1 two_is_superstable_period1

/-- \(1+\sqrt5\) is not a strict period-4 superstable. -/
theorem one_add_sqrt5_not_strict_period4 :
    ¬ IsStrictSuperstable 2 (1 + Real.sqrt 5) := by
  intro h
  exact (strict_period4_excludes_lower h).2 one_add_sqrt5_is_superstable_period2

/--
  Literature-scale rational pin near the classical period-4 superstable
  \(r_2 \approx 3.498561\). **Operational**, not proved equal to the true root.
-/
def period4SuperstableOp : ℚ := 3498561 / 1000000

theorem period4SuperstableOp_bounds :
    (3 : ℚ) < period4SuperstableOp ∧ period4SuperstableOp < 4 := by
  native_decide

/-- Clearing-denominator form of the period-4 residual equation. -/
noncomputable def period4Eq (r : ℝ) : Prop := period4Residual r = 0

theorem period4Eq_iff_superstable_two (r : ℝ) :
    period4Eq r ↔ IsSuperstable 2 r :=
  (isSuperstable_two_iff r).symm

/--
  Named residual package for stage \(n=2\): characterization + exclusion.
  Existence of a cascade-window strict root and secondary residual zero are in
  `FeigenbaumCascade`. Full-interval uniqueness is false (~3.96). Formal mono
  discharge in the cascade window remains analysis residual.
-/
structure Period4Track where
  residual_char : ∀ r : ℝ, IsSuperstable 2 r ↔ period4Residual r = 0 :=
    isSuperstable_two_iff
  excludes_period1 : ∀ {_r : ℝ}, IsStrictSuperstable 2 _r → ¬ IsSuperstable 0 _r :=
    fun h => (strict_period4_excludes_lower h).1
  excludes_period2 : ∀ {_r : ℝ}, IsStrictSuperstable 2 _r → ¬ IsSuperstable 1 _r :=
    fun h => (strict_period4_excludes_lower h).2
  /-- Cascade-window existence closed in FeigenbaumCascade (IVT). -/
  existence_window_closed : True := trivial
  /-- Full (1+√5,4) uniqueness false; formal window mono open. -/
  full_interval_unique_false_window_mono_open : True := trivial

def period4Track : Period4Track := {}

/-! ### Partial termwise bridge to logistic-anchored chart -/

/-- Real lift of rational logistic-anchored parameters (scale-ID chart). -/
noncomputable def anchoredR (n : ℕ) : ℝ := (logisticAnchoredR n : ℚ)

theorem anchoredR_zero_eq_two : anchoredR 0 = 2 := by
  simp only [anchoredR, logisticAnchoredR_zero]
  norm_cast

theorem anchoredR_one_eq_three : anchoredR 1 = 3 := by
  simp only [anchoredR, logisticAnchoredR_one]
  norm_cast

theorem anchored_matches_superstable_at_zero :
    IsStrictSuperstable 0 (anchoredR 0) := by
  rw [anchoredR_zero_eq_two]
  exact two_is_strict_superstable_period1

/-- Partial agreement only at \(n=0\); \(n=1\) intentionally disagrees. -/
theorem anchored_partial_termwise :
    IsSuperstable 0 (anchoredR 0) ∧ ¬ IsSuperstable 1 (anchoredR 1) := by
  constructor
  · exact anchored_matches_superstable_at_zero.1
  · rw [anchoredR_one_eq_three]
    exact three_ne_period2_superstable

/-! ### Open residual: full cascade of true roots + δ-limit -/

/--
  [CONJETURA · research-scale]
  There exists a strictly increasing sequence of true strict superstable
  parameters with \(R_n < 4\).
-/
def TrueSuperstableCascadeLimit : Prop :=
  ∃ R : ℕ → ℝ,
    (∀ n, IsStrictSuperstable n (R n)) ∧
    (∀ n, R n < R (n + 1)) ∧
    (∀ n, R n < 4)

/-- Tracker only — do not discharge with `trivial` as dynamics. -/
theorem true_superstable_cascade_open_marker : True := trivial

/-! ### Status package (zero research axiom) -/

structure SuperstableTrackStatus where
  period1_unique_ok : True := trivial
  period2_unique_ok : True := trivial
  period2_honesty_three_ok : True := trivial
  period4_residual_char_ok : True := trivial
  period4_excludes_lower_ok : True := trivial
  /-- Existence of strict period-4 root in cascade window: see FeigenbaumCascade. -/
  period4_existence_closed : True := trivial
  /-- Secondary residual zero + non-uniqueness on full interval: FeigenbaumCascade. -/
  period4_secondary_honesty_closed : True := trivial
  /-- Hybrid cascade + ratios → δ: see FeigenbaumCascade. -/
  cascade_limit_hybrid_closed : True := trivial
  /-- Conditional uniqueness under StrictMonoOn residual: FeigenbaumCascade. -/
  period4_conditional_mono_unique_closed : True := trivial
  /-- Formal discharge of StrictMonoOn residual (Rolle+Q'): analysis residual. -/
  period4_formal_rolle_mono_open : True := trivial
  /-- True termwise SS for all n (not hybrid geometric tail): research-scale. -/
  true_termwise_cascade_open : True := trivial
  zero_research_axiom_ok : True := trivial

def currentSuperstableStatus : SuperstableTrackStatus := {}

/-- Bundled theorems for CI / golden imports. -/
theorem superstable_pack_period1 :
    IsStrictSuperstable 0 (2 : ℝ) ∧
      ∀ r : ℝ, 0 < r → r < 4 → IsSuperstable 0 r → r = 2 :=
  ⟨two_is_strict_superstable_period1, fun _r h0 h4 h =>
    unique_superstable_period1_on_Ioo h0 h4 h⟩

theorem superstable_pack_period2 :
    IsStrictSuperstable 1 (1 + Real.sqrt 5) ∧
      ¬ IsSuperstable 1 (3 : ℝ) ∧
      ∀ r : ℝ, 2 < r → r < 4 → IsStrictSuperstable 1 r → r = 1 + Real.sqrt 5 :=
  ⟨one_add_sqrt5_is_strict_superstable_period2, three_ne_period2_superstable,
    fun _r h2 h4 h => unique_strict_superstable_period2_on_Ioo h2 h4 h⟩

theorem superstable_pack_period4 :
    (∀ r, IsSuperstable 2 r ↔ period4Residual r = 0) ∧
      (¬ IsStrictSuperstable 2 (2 : ℝ)) ∧
      (¬ IsStrictSuperstable 2 (1 + Real.sqrt 5)) :=
  ⟨isSuperstable_two_iff, two_not_strict_period4, one_add_sqrt5_not_strict_period4⟩

end SystemicTau.FeigenbaumSuperstable
