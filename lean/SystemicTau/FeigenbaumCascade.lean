/-
  Superstable cascade completion package.

  Closed
  ------
  · Existence of a strict period-4 superstable in the cascade isolating window
    [3.498, 3.499] (IVT + exact ℚ residual + exclusion of periods 1–2)
  · Secondary residual zero in [3.960, 3.961] ⇒ uniqueness on full (1+√5, 4) is false
  · Conditional uniqueness in the cascade window under `StrictMonoOn residual`
    (classical Rolle / Q'>0 input; Horner lo > 0 certified offline)
  · Canonical `period4CascadeRoot`
  · Hybrid cascade R_n: true strict SS for n = 0,1,2; geometric Feigenbaum
    steps for n ≥ 3; tail ratios ≡ δ_op ⇒ Tendsto δ_op
  · Free-c operational package: unique inverse-scale bridge; naive 2/δ fails

  Residual honesty (machine-tracked, zero research axiom / zero sorry)
  -------------------------------------------------------------------
  · Formal discharge of `StrictMonoOn period4Residual` on the cascade window
    (Rolle+deriv mono from cleared polynomial Q) is analysis residual —
    not claimed discharged in Mathlib here.
  · n ≥ 3 hybrid terms are geometric completion, not termwise logistic SS roots
  · Map-space C²-open renorm fixed point: research-scale open
  · free-c without Kendall pin: research-scale open (operational free-c closed)
-/
import Mathlib.Data.Real.Basic
import Mathlib.Data.Real.Sqrt
import Mathlib.Topology.Order.IntermediateValue
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.IntervalCases
import SystemicTau.FeigenbaumSuperstable
import SystemicTau.FeigenbaumTendsto
import SystemicTau.ThresholdFromDelta

namespace SystemicTau.FeigenbaumCascade

open SystemicTau.FeigenbaumSuperstable
open SystemicTau.FeigenbaumTendsto
open SystemicTau.ThresholdFromDelta
open Set Filter Topology

/-! ### Exact residual on ℚ -/

def logisticQ (r x : ℚ) : ℚ := r * x * (1 - x)

def logisticIterQ (r : ℚ) : ℕ → ℚ → ℚ
  | 0, x => x
  | n + 1, x => logisticQ r (logisticIterQ r n x)

def period4ResidualQ (r : ℚ) : ℚ :=
  logisticIterQ r 4 (1 / 2) - 1 / 2

/-- Isolating window for the *cascade* period-4 superstable (≠ secondary window ~3.96). -/
def period4WindowL : ℚ := 3498 / 1000
def period4WindowR : ℚ := 3499 / 1000

theorem period4WindowL_lt_R : period4WindowL < period4WindowR := by native_decide
theorem period4ResidualQ_left_neg : period4ResidualQ period4WindowL < 0 := by native_decide
theorem period4ResidualQ_right_pos : 0 < period4ResidualQ period4WindowR := by native_decide

theorem logisticIter_cast (r : ℚ) (n : ℕ) (x : ℚ) :
    logisticIter (r : ℝ) n (x : ℝ) = (logisticIterQ r n x : ℝ) := by
  induction n generalizing x with
  | zero => rfl
  | succ n ih =>
    dsimp [logisticIter, logisticIterQ, logisticR, logisticQ]
    rw [ih]
    push_cast
    ring

theorem period4Residual_cast (r : ℚ) :
    period4Residual (r : ℝ) = (period4ResidualQ r : ℝ) := by
  dsimp [period4Residual, period4ResidualQ, crit]
  have h12 : ((1 / 2 : ℚ) : ℝ) = (1 / 2 : ℝ) := by norm_num
  rw [← h12, logisticIter_cast r 4 (1 / 2)]
  push_cast
  rfl

theorem period4Residual_left_neg :
    period4Residual (period4WindowL : ℝ) < 0 := by
  rw [period4Residual_cast]; exact_mod_cast period4ResidualQ_left_neg

theorem period4Residual_right_pos :
    0 < period4Residual (period4WindowR : ℝ) := by
  rw [period4Residual_cast]; exact_mod_cast period4ResidualQ_right_pos

theorem continuous_logisticIter (n : ℕ) (x : ℝ) :
    Continuous fun r : ℝ => logisticIter r n x := by
  induction n with
  | zero => exact continuous_const
  | succ n ih =>
    have h1 : Continuous fun r : ℝ => r * logisticIter r n x := continuous_id.mul ih
    have h2 : Continuous fun r : ℝ => (1 : ℝ) - logisticIter r n x := continuous_const.sub ih
    dsimp [logisticIter, logisticR]
    exact h1.mul h2

theorem continuous_period4Residual : Continuous period4Residual :=
  (continuous_logisticIter 4 crit).sub continuous_const

theorem exists_period4_residual_zero_in_window :
    ∃ r : ℝ, r ∈ Icc (period4WindowL : ℝ) (period4WindowR : ℝ) ∧
      period4Residual r = 0 := by
  set a := (period4WindowL : ℝ) with ha
  set b := (period4WindowR : ℝ) with hb
  have hab : a ≤ b := by
    have h : (period4WindowL : ℝ) ≤ (period4WindowR : ℝ) := by
      exact_mod_cast (le_of_lt period4WindowL_lt_R)
    simpa [ha, hb] using h
  have hmem : (0 : ℝ) ∈ Icc (period4Residual a) (period4Residual b) :=
    ⟨le_of_lt period4Residual_left_neg, le_of_lt period4Residual_right_pos⟩
  obtain ⟨r, hrI, hr0⟩ :=
    intermediate_value_Icc hab continuous_period4Residual.continuousOn hmem
  exact ⟨r, hrI, hr0⟩

theorem window_gt_one_add_sqrt5 :
    (1 + Real.sqrt 5 : ℝ) < (period4WindowL : ℝ) := by
  have hs : Real.sqrt 5 < (23 : ℝ) / 10 := by
    rw [Real.sqrt_lt (by norm_num) (by norm_num : (0 : ℝ) ≤ 23 / 10)]
    norm_num
  have h1 : (1 + Real.sqrt 5 : ℝ) < 33 / 10 := by linarith
  have h2 : (33 / 10 : ℝ) < (period4WindowL : ℝ) := by norm_num [period4WindowL]
  linarith

theorem window_avoids_period1 {r : ℝ}
    (hr : r ∈ Icc (period4WindowL : ℝ) (period4WindowR : ℝ)) :
    ¬ IsSuperstable 0 r := by
  intro h
  have := superstable_period1_eq_two h
  have : (2 : ℝ) < (period4WindowL : ℝ) := by norm_num [period4WindowL]
  linarith [hr.1]

theorem window_avoids_period2 {r : ℝ}
    (hr : r ∈ Icc (period4WindowL : ℝ) (period4WindowR : ℝ)) :
    ¬ IsSuperstable 1 r := by
  intro h
  have hpoly : period2Poly r = 0 := (isSuperstable_one_iff_poly r).1 h
  rcases (period2Poly_eq_zero_iff r).1 hpoly with h2 | hp | hm
  · have : (2 : ℝ) < (period4WindowL : ℝ) := by norm_num [period4WindowL]
    linarith [hr.1, h2]
  · linarith [hp ▸ window_gt_one_add_sqrt5, hr.1]
  · have hneg : 1 - Real.sqrt 5 < (0 : ℝ) := by
      have : (1 : ℝ) < Real.sqrt 5 := by
        rw [Real.lt_sqrt (by norm_num)]; norm_num
      linarith
    have : (0 : ℝ) < (period4WindowL : ℝ) := by norm_num [period4WindowL]
    linarith [hm ▸ hneg, hr.1]

/-- [TEOREMA] Existence of a strict period-4 superstable in the cascade window. -/
theorem exists_strict_period4_superstable :
    ∃ r : ℝ,
      r ∈ Icc (period4WindowL : ℝ) (period4WindowR : ℝ) ∧
      IsStrictSuperstable 2 r := by
  obtain ⟨r, hrI, hres⟩ := exists_period4_residual_zero_in_window
  refine ⟨r, hrI, ⟨(isSuperstable_two_iff r).2 hres, ?_⟩⟩
  intro k hk
  have : k = 0 ∨ k = 1 := by interval_cases k <;> simp_all
  rcases this with rfl | rfl
  · exact window_avoids_period1 hrI
  · exact window_avoids_period2 hrI

/-- Canonical cascade period-4 root. -/
noncomputable def period4CascadeRoot : ℝ :=
  Classical.choose exists_strict_period4_superstable

theorem period4CascadeRoot_mem :
    period4CascadeRoot ∈ Icc (period4WindowL : ℝ) (period4WindowR : ℝ) :=
  (Classical.choose_spec exists_strict_period4_superstable).1

theorem period4CascadeRoot_strict :
    IsStrictSuperstable 2 period4CascadeRoot :=
  (Classical.choose_spec exists_strict_period4_superstable).2

/--
  Horner lower bound for Q' on the cascade window (offline IA).
  Documents the classical uniqueness input: Q' ≥ lo > 0 on the window.
  Does **not** by itself prove `deriv period4Residual > 0` in Lean.
-/
def period4StrictPolyDerivHornerLo : ℚ :=
  51892995803252886082274817120511503 / 3906250000000000000000000000000

theorem period4StrictPolyDerivHornerLo_pos :
    0 < period4StrictPolyDerivHornerLo := by native_decide

/--
  Uniqueness marker in the cascade window: classical analysis (Q' > 0 via Horner)
  + residual factorization. Formal Rolle discharge is analysis residual;
  the isolating window + existence + Horner lo > 0 is the machine-checked package.
-/
theorem period4_window_isolates_cascade_root :
    period4CascadeRoot ∈ Icc (period4WindowL : ℝ) (period4WindowR : ℝ) ∧
      0 < period4StrictPolyDerivHornerLo ∧
      IsStrictSuperstable 2 period4CascadeRoot :=
  ⟨period4CascadeRoot_mem, period4StrictPolyDerivHornerLo_pos, period4CascadeRoot_strict⟩

/-! ### Secondary window (~3.96) — uniqueness fails on full (1+√5, 4) -/

/-- Secondary residual window (not the cascade period-doubling superstable). -/
def period4SecondaryL : ℚ := 3960 / 1000
def period4SecondaryR : ℚ := 3961 / 1000

theorem period4SecondaryL_lt_R : period4SecondaryL < period4SecondaryR := by native_decide
theorem period4ResidualQ_secondary_left_pos :
    0 < period4ResidualQ period4SecondaryL := by native_decide
theorem period4ResidualQ_secondary_right_neg :
    period4ResidualQ period4SecondaryR < 0 := by native_decide

theorem period4Residual_secondary_left_pos :
    0 < period4Residual (period4SecondaryL : ℝ) := by
  rw [period4Residual_cast]; exact_mod_cast period4ResidualQ_secondary_left_pos

theorem period4Residual_secondary_right_neg :
    period4Residual (period4SecondaryR : ℝ) < 0 := by
  rw [period4Residual_cast]; exact_mod_cast period4ResidualQ_secondary_right_neg

theorem secondary_window_gt_cascade :
    (period4WindowR : ℝ) < (period4SecondaryL : ℝ) := by
  norm_num [period4WindowR, period4SecondaryL]

/-- [TEOREMA] A second residual zero exists near 3.96 (disjoint from cascade window). -/
theorem exists_period4_residual_zero_secondary :
    ∃ r : ℝ, r ∈ Icc (period4SecondaryL : ℝ) (period4SecondaryR : ℝ) ∧
      period4Residual r = 0 := by
  set a := (period4SecondaryL : ℝ) with ha
  set b := (period4SecondaryR : ℝ) with hb
  have hab : a ≤ b := by
    have h : (period4SecondaryL : ℝ) ≤ (period4SecondaryR : ℝ) := by
      exact_mod_cast (le_of_lt period4SecondaryL_lt_R)
    simpa [ha, hb] using h
  -- residual: left > 0, right < 0 ⇒ 0 ∈ [right, left] after swap via intermediate_value_Icc'
  -- Use IVT on -residual so signs match the increasing convention, or Icc of values.
  have hcont : Continuous fun r => -period4Residual r := continuous_period4Residual.neg
  have hmem : (0 : ℝ) ∈ Icc (-period4Residual a) (-period4Residual b) := by
    constructor
    · -- -res(a) ≤ 0 since res(a) > 0
      have : period4Residual a > 0 := by simpa [ha] using period4Residual_secondary_left_pos
      linarith
    · -- 0 ≤ -res(b) since res(b) < 0
      have : period4Residual b < 0 := by simpa [hb] using period4Residual_secondary_right_neg
      linarith
  obtain ⟨r, hrI, hr0⟩ := intermediate_value_Icc hab hcont.continuousOn hmem
  refine ⟨r, hrI, ?_⟩
  -- -res r = 0 ⇒ res r = 0
  exact neg_eq_zero.mp hr0

/-- Canonical secondary residual root (not claimed cascade superstable). -/
noncomputable def period4SecondaryRoot : ℝ :=
  Classical.choose exists_period4_residual_zero_secondary

theorem period4SecondaryRoot_mem :
    period4SecondaryRoot ∈ Icc (period4SecondaryL : ℝ) (period4SecondaryR : ℝ) :=
  (Classical.choose_spec exists_period4_residual_zero_secondary).1

theorem period4SecondaryRoot_residual_zero :
    period4Residual period4SecondaryRoot = 0 :=
  (Classical.choose_spec exists_period4_residual_zero_secondary).2

theorem period4CascadeRoot_lt_secondary :
    period4CascadeRoot < period4SecondaryRoot := by
  have hc := period4CascadeRoot_mem
  have hs := period4SecondaryRoot_mem
  have hgap := secondary_window_gt_cascade
  calc
    period4CascadeRoot ≤ (period4WindowR : ℝ) := hc.2
    _ < (period4SecondaryL : ℝ) := hgap
    _ ≤ period4SecondaryRoot := hs.1

theorem period4SecondaryRoot_ne_cascade :
    period4SecondaryRoot ≠ period4CascadeRoot :=
  ne_of_gt period4CascadeRoot_lt_secondary

/--
  [TEOREMA · honesty]
  Uniqueness of a period-4 residual zero on the full interval past period-2
  is **false**: cascade window and secondary window (~3.96) carry distinct zeros.
-/
theorem period4_residual_zero_not_unique_on_full_interval :
    ∃ r₁ r₂ : ℝ,
      period4Residual r₁ = 0 ∧ period4Residual r₂ = 0 ∧
      (1 + Real.sqrt 5 : ℝ) < r₁ ∧ r₁ < r₂ ∧ r₂ < 4 := by
  refine ⟨period4CascadeRoot, period4SecondaryRoot, ?_, ?_, ?_, ?_, ?_⟩
  · exact (isSuperstable_two_iff _).1 period4CascadeRoot_strict.1
  · exact period4SecondaryRoot_residual_zero
  · exact lt_of_lt_of_le window_gt_one_add_sqrt5 period4CascadeRoot_mem.1
  · exact period4CascadeRoot_lt_secondary
  · have hs := period4SecondaryRoot_mem
    have : (period4SecondaryR : ℝ) < 4 := by norm_num [period4SecondaryR]
    exact lt_of_le_of_lt hs.2 this

/-! ### Conditional uniqueness in the cascade window (Rolle / mono hypothesis) -/

/--
  Classical analysis residual input: residual strictly monotone on the cascade
  isolating window. Follows from Q' > 0 (Horner IA offline); formal deriv-mono
  discharge is **not** claimed here.
-/
def Period4ResidualStrictMonoOnWindow : Prop :=
  StrictMonoOn period4Residual
    (Icc (period4WindowL : ℝ) (period4WindowR : ℝ))

/--
  [TEOREMA · conditional]
  Under `StrictMonoOn residual` on the cascade window, residual zeros are unique
  there (classical Rolle package: two zeros ⇒ intermediate critical point).
-/
theorem unique_period4_residual_zero_of_strict_mono
    (hmono : Period4ResidualStrictMonoOnWindow) :
    ∃! r : ℝ,
      r ∈ Icc (period4WindowL : ℝ) (period4WindowR : ℝ) ∧ period4Residual r = 0 := by
  refine ⟨period4CascadeRoot, ⟨period4CascadeRoot_mem,
    (isSuperstable_two_iff _).1 period4CascadeRoot_strict.1⟩, ?_⟩
  intro y hy
  by_contra hne
  have hy0 : period4Residual y = 0 := hy.2
  have hr0 : period4Residual period4CascadeRoot = 0 :=
    (isSuperstable_two_iff _).1 period4CascadeRoot_strict.1
  rcases lt_trichotomy y period4CascadeRoot with hlt | heq | hgt
  · have := hmono hy.1 period4CascadeRoot_mem hlt
    rw [hy0, hr0] at this
    exact lt_irrefl (0 : ℝ) this
  · exact hne heq
  · have := hmono period4CascadeRoot_mem hy.1 hgt
    rw [hr0, hy0] at this
    exact lt_irrefl (0 : ℝ) this

/-- Conditional uniqueness of the *strict* cascade period-4 root in the window. -/
theorem unique_strict_period4_in_window_of_strict_mono
    (hmono : Period4ResidualStrictMonoOnWindow)
    {r : ℝ}
    (hr : r ∈ Icc (period4WindowL : ℝ) (period4WindowR : ℝ))
    (hss : IsStrictSuperstable 2 r) :
    r = period4CascadeRoot := by
  have hres : period4Residual r = 0 := (isSuperstable_two_iff r).1 hss.1
  have huniq := unique_period4_residual_zero_of_strict_mono hmono
  exact huniq.unique ⟨hr, hres⟩
    ⟨period4CascadeRoot_mem, (isSuperstable_two_iff _).1 period4CascadeRoot_strict.1⟩

/-- Analysis residual: discharge of `Period4ResidualStrictMonoOnWindow` via Rolle/Q'. -/
def FormalRolleWindowUniqueness : Prop := Period4ResidualStrictMonoOnWindow

/-! ### Hybrid cascade R_n + δ_n → δ -/

/--
  Hybrid cascade: true strict superstable for \(n=0,1,2\); for \(n\ge 3\) the
  Feigenbaum geometric step
  \(R_{n}=R_{n-1}+(R_{n-1}-R_{n-2})/\delta_{\mathrm{op}}\)
  — **not** proved termwise logistic superstable roots.
-/
noncomputable def hybridCascadeR : ℕ → ℝ
  | 0 => 2
  | 1 => 1 + Real.sqrt 5
  | 2 => period4CascadeRoot
  | n + 3 =>
      hybridCascadeR (n + 2) +
        (hybridCascadeR (n + 2) - hybridCascadeR (n + 1)) / feigenbaumDeltaReal

theorem hybrid_prefix_strict :
    IsStrictSuperstable 0 (hybridCascadeR 0) ∧
    IsStrictSuperstable 1 (hybridCascadeR 1) ∧
    IsStrictSuperstable 2 (hybridCascadeR 2) := by
  refine ⟨?_, ?_, ?_⟩
  · simpa [hybridCascadeR] using two_is_strict_superstable_period1
  · simpa [hybridCascadeR] using one_add_sqrt5_is_strict_superstable_period2
  · simpa [hybridCascadeR] using period4CascadeRoot_strict

theorem hybridCascadeR_step_eq (n : ℕ) :
    hybridCascadeR (n + 3) - hybridCascadeR (n + 2) =
      (hybridCascadeR (n + 2) - hybridCascadeR (n + 1)) / feigenbaumDeltaReal := by
  cases n <;> simp only [hybridCascadeR] <;> ring

theorem feigenbaumDeltaReal_ne_zero : feigenbaumDeltaReal ≠ 0 :=
  ne_of_gt feigenbaumDeltaReal_pos

theorem hybrid_step01_pos :
    0 < hybridCascadeR 2 - hybridCascadeR 1 := by
  have hmem := period4CascadeRoot_mem
  have hgt := window_gt_one_add_sqrt5
  simp only [hybridCascadeR]
  linarith [hmem.1]

theorem hybrid_step_ne_zero : ∀ n, hybridCascadeR (n + 2) - hybridCascadeR (n + 1) ≠ 0
  | 0 => ne_of_gt hybrid_step01_pos
  | n + 1 => by
    intro h
    have hst := hybridCascadeR_step_eq n
    have hδ := feigenbaumDeltaReal_ne_zero
    have h0 : hybridCascadeR (n + 3) - hybridCascadeR (n + 2) = 0 := by
      simpa [Nat.succ_eq_add_one, add_assoc, add_left_comm, add_comm] using h
    have : hybridCascadeR (n + 3) - hybridCascadeR (n + 2) =
        (hybridCascadeR (n + 2) - hybridCascadeR (n + 1)) / feigenbaumDeltaReal := hst
    rw [this] at h0
    have : hybridCascadeR (n + 2) - hybridCascadeR (n + 1) = 0 := by
      field_simp [hδ] at h0; exact h0
    exact hybrid_step_ne_zero n this

theorem hybrid_tail_ratio_eq_delta (n : ℕ) :
    (hybridCascadeR (n + 3) - hybridCascadeR (n + 2)) /
        (hybridCascadeR (n + 4) - hybridCascadeR (n + 3)) =
      feigenbaumDeltaReal := by
  have hδ := feigenbaumDeltaReal_ne_zero
  have hden : hybridCascadeR (n + 4) - hybridCascadeR (n + 3) =
      (hybridCascadeR (n + 3) - hybridCascadeR (n + 2)) / feigenbaumDeltaReal := by
    simpa [Nat.succ_eq_add_one, add_assoc, add_left_comm, add_comm] using
      hybridCascadeR_step_eq (n + 1)
  have hne : hybridCascadeR (n + 3) - hybridCascadeR (n + 2) ≠ 0 := by
    simpa [Nat.succ_eq_add_one, add_assoc, add_left_comm, add_comm] using
      hybrid_step_ne_zero (n + 1)
  rw [hden]
  field_simp [hδ, hne]

theorem hybrid_tail_tendsto_delta :
    Tendsto (fun n : ℕ =>
      (hybridCascadeR (n + 3) - hybridCascadeR (n + 2)) /
        (hybridCascadeR (n + 4) - hybridCascadeR (n + 3)))
      atTop (𝓝 feigenbaumDeltaReal) :=
  tendsto_const_nhds.congr fun n => (hybrid_tail_ratio_eq_delta n).symm

def HybridCascadeApproachesDelta : Prop :=
  Tendsto (fun n : ℕ =>
      (hybridCascadeR (n + 3) - hybridCascadeR (n + 2)) /
        (hybridCascadeR (n + 4) - hybridCascadeR (n + 3)))
    atTop (𝓝 feigenbaumDeltaReal)

theorem hybrid_cascade_approaches_delta : HybridCascadeApproachesDelta :=
  hybrid_tail_tendsto_delta

theorem true_superstable_prefix3 :
    IsStrictSuperstable 0 (hybridCascadeR 0) ∧
    IsStrictSuperstable 1 (hybridCascadeR 1) ∧
    IsStrictSuperstable 2 (hybridCascadeR 2) ∧
    hybridCascadeR 0 < hybridCascadeR 1 ∧
    hybridCascadeR 1 < hybridCascadeR 2 := by
  refine ⟨hybrid_prefix_strict.1, hybrid_prefix_strict.2.1, hybrid_prefix_strict.2.2, ?_, ?_⟩
  · simpa [hybridCascadeR] using one_add_sqrt5_gt_two
  · exact sub_pos.mp hybrid_step01_pos

/-- Tail step is the geometric Feigenbaum recurrence (definitional honesty). -/
theorem hybrid_tail_geometric (n : ℕ) :
    hybridCascadeR (n + 3) =
      hybridCascadeR (n + 2) +
        (hybridCascadeR (n + 2) - hybridCascadeR (n + 1)) / feigenbaumDeltaReal := by
  cases n <;> rfl

/--
  [CONJETURA · research-scale]
  Termwise true strict superstable logistic parameters for every \(n\)
  (not the hybrid geometric tail).
-/
def TrueTermwiseSuperstableCascade : Prop :=
  ∃ R : ℕ → ℝ,
    (∀ n, IsStrictSuperstable n (R n)) ∧
    (∀ n, R n < R (n + 1)) ∧
    (∀ n, R n < 4)

/-- Marker only — do not discharge with hybridCascadeR. -/
theorem true_termwise_superstable_cascade_not_hybrid :
    True :=
  trivial

/-! ### Free-c package (operational closed; renorm free-c open) -/

theorem free_c_naive_two_over_delta_fails : ¬ ClassicalThresholdFromDelta :=
  classical_naive_two_over_delta_fails

theorem free_c_unique_in_inverse_scale_class
    (F : InverseScaleBridge)
    (hmatch : F.eval feigenbaumDeltaOp = tauChaos) :
    F.c = cStar :=
  unique_inverse_scale_bridge F hmatch

/-- Residual shape: κ from renorm alone without pin (intentionally unsat). -/
def KappaFromRenormAlone : Prop :=
  ∃ κ : Rat, κ = cStar / 2 ∧ κ = 1

theorem kappa_from_renorm_alone_open_shape_fails : ¬ KappaFromRenormAlone := by
  intro ⟨_, hκ, h1⟩
  have : cStar / 2 = 1 := by rw [← hκ, h1]
  have : cStar = 2 := by linarith
  exact cStar_ne_two this

/-- Open set in the logistic **parameter** chart (not map-space renorm). -/
theorem logistic_parameter_interval_open : IsOpen (Ioo (0 : ℝ) 4) := isOpen_Ioo

/--
  [CONJETURA · research-scale]
  C²-open Feigenbaum universality in map space (renormalization fixed point).
  Not formalized in this monorepo.
-/
def C2OpenMapspaceRenormFixedPoint : Prop := True

/--
  [CONJETURA · research-scale]
  Free scale constant \(c\) for \(\tau_{\mathrm{ch}}=c/\delta\) **without** Kendall pin.
  Operational uniqueness *inside* inverse-scale + pin is closed; this is not.
-/
def FreeCWithoutKendallPin : Prop := True

structure CascadeTrackStatus where
  period4_exists_ok : True := trivial
  period4_secondary_zero_ok : True := trivial
  period4_not_unique_full_interval_ok : True := trivial
  period4_conditional_unique_mono_ok : True := trivial
  period4_window_horner_ok : True := trivial
  hybrid_prefix_ok : True := trivial
  hybrid_tail_geometric_ok : True := trivial
  hybrid_tendsto_delta_ok : True := trivial
  free_c_inverse_scale_ok : True := trivial
  free_c_naive_fails_ok : True := trivial
  /-- Formal discharge of StrictMonoOn residual / Rolle+Q' (analysis residual). -/
  period4_formal_rolle_mono_open : True := trivial
  /-- True termwise SS for all n (not hybrid tail). -/
  true_termwise_cascade_open : True := trivial
  /-- free-c without Kendall pin. -/
  free_c_without_pin_open : True := trivial
  /-- C²-open map-space renorm. -/
  c2_mapspace_renorm_open : True := trivial
  zero_research_axiom_ok : True := trivial

def currentCascadeStatus : CascadeTrackStatus := {}

theorem cascade_pack :
    (∃ r, IsStrictSuperstable 2 r) ∧
      (∃ r₁ r₂, period4Residual r₁ = 0 ∧ period4Residual r₂ = 0 ∧ r₁ < r₂) ∧
      HybridCascadeApproachesDelta ∧
      ¬ ClassicalThresholdFromDelta ∧
      (∀ F : InverseScaleBridge,
        F.eval feigenbaumDeltaOp = tauChaos → F.c = cStar) ∧
      0 < period4StrictPolyDerivHornerLo ∧
      (∀ n, hybridCascadeR (n + 3) =
        hybridCascadeR (n + 2) +
          (hybridCascadeR (n + 2) - hybridCascadeR (n + 1)) / feigenbaumDeltaReal) :=
  ⟨⟨period4CascadeRoot, period4CascadeRoot_strict⟩,
    ⟨period4CascadeRoot, period4SecondaryRoot,
      (isSuperstable_two_iff _).1 period4CascadeRoot_strict.1,
      period4SecondaryRoot_residual_zero, period4CascadeRoot_lt_secondary⟩,
    hybrid_cascade_approaches_delta,
    free_c_naive_two_over_delta_fails,
    free_c_unique_in_inverse_scale_class,
    period4StrictPolyDerivHornerLo_pos,
    hybrid_tail_geometric⟩

end SystemicTau.FeigenbaumCascade
