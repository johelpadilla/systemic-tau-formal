/-
  CT-3: sign lemma and monotonicity recovery for RECD accumulation.

  Module CT (docs/RECD_vs_Thermodynamic_Time.md), Statement CT-3.
  [TEOREMA] — elementary arithmetic on the operational tick law:
    Δt_k = g(τ) · δ^{-k} · |τ|

  Scope: discrete sequences on ℚ. No immersion, projection, or continuum limit.
-/
import SystemicTau.RECD

namespace SystemicTau

/-! ### Positivity of the Feigenbaum depth scale -/

/-- [TEOREMA] δ^{-k} > 0 for every depth k. -/
theorem deltaInvPow_pos (k : Nat) : 0 < deltaInvPow k := by
  induction k with
  | zero =>
    simp only [deltaInvPow]
    native_decide
  | succ k ih =>
    -- δ^{-(k+1)} = δ^{-k} / (δ_num/δ_den) = δ^{-k} · (δ_den/δ_num)
    have hδ : 0 < (feigenbaumDeltaNum : Rat) / (feigenbaumDeltaDen : Rat) := by
      native_decide
    have : 0 < deltaInvPow k / ((feigenbaumDeltaNum : Rat) / (feigenbaumDeltaDen : Rat)) :=
      div_pos ih hδ
    simpa [deltaInvPow] using this

/-- [TEOREMA] δ^{-k} ≥ 0. -/
theorem deltaInvPow_nonneg (k : Nat) : 0 ≤ deltaInvPow k :=
  le_of_lt (deltaInvPow_pos k)

/-! ### Unit skeleton Δt and absolute value -/

/-- [TEOREMA] |τ| > 0 whenever τ ≠ 0. -/
theorem absRat_pos_of_ne {tau : Rat} (h : tau ≠ 0) : 0 < absRat tau := by
  simp only [absRat]
  split_ifs with hge
  · exact lt_of_le_of_ne hge (Ne.symm h)
  · have hlt : tau < 0 := lt_of_not_ge hge
    exact neg_pos.mpr hlt

/-- [TEOREMA] |τ| = 0 ↔ τ = 0. -/
theorem absRat_eq_zero_iff (tau : Rat) : absRat tau = 0 ↔ tau = 0 := by
  constructor
  · intro h
    simp only [absRat] at h
    split_ifs at h with hge
    · exact h
    · have : -tau = 0 := h
      exact neg_eq_zero.mp this
  · intro h
    simp [absRat, h]

/-- [TEOREMA] Unit skeleton is nonnegative. -/
theorem deltaT_unit_nonneg (tau : Rat) (k : Nat) : 0 ≤ deltaT_unit tau k := by
  simp only [deltaT_unit]
  exact mul_nonneg (deltaInvPow_nonneg k) (absRat_nonneg tau)

/-- [TEOREMA] Unit skeleton is strictly positive when τ ≠ 0. -/
theorem deltaT_unit_pos_of_ne (tau : Rat) (k : Nat) (h : tau ≠ 0) :
    0 < deltaT_unit tau k := by
  simp only [deltaT_unit]
  exact mul_pos (deltaInvPow_pos k) (absRat_pos_of_ne h)

/-- [TEOREMA] Zero τ freezes the unit skeleton. -/
theorem deltaT_unit_zero (k : Nat) : deltaT_unit 0 k = 0 := by
  simp [deltaT_unit, absRat]

/-! ### Sign lemma for the operational tick -/

/-- [TEOREMA] Zero τ freezes the RECD tick regardless of depth. -/
theorem recdTick_unit_zero (k : Nat) : recdTick_unit 0 k = 0 := by
  simp [recdTick_unit, deltaT_unit_zero]

/-- [TEOREMA] Nonnegative gate ⇒ nonnegative tick. -/
theorem recdTick_unit_nonneg_of_gate_nonneg
    (tau : Rat) (k : Nat) (hg : 0 ≤ gate tau) :
    0 ≤ recdTick_unit tau k := by
  simp only [recdTick_unit]
  exact mul_nonneg hg (deltaT_unit_nonneg tau k)

/-- [TEOREMA] Nonpositive gate ⇒ nonpositive tick. -/
theorem recdTick_unit_nonpos_of_gate_nonpos
    (tau : Rat) (k : Nat) (hg : gate tau ≤ 0) :
    recdTick_unit tau k ≤ 0 := by
  simp only [recdTick_unit]
  exact mul_nonpos_of_nonpos_of_nonneg hg (deltaT_unit_nonneg tau k)

/--
  [TEOREMA] Sign lemma (nonzero τ):
  0 ≤ g(τ)·δ^{-k}·|τ|  ↔  0 ≤ g(τ).
-/
theorem recdTick_unit_nonneg_iff_gate
    (tau : Rat) (k : Nat) (hτ : tau ≠ 0) :
    0 ≤ recdTick_unit tau k ↔ 0 ≤ gate tau := by
  constructor
  · intro htick
    -- gate * Δt ≥ 0 and Δt > 0 ⇒ gate ≥ 0
    have hΔ : 0 < deltaT_unit tau k := deltaT_unit_pos_of_ne tau k hτ
    simp only [recdTick_unit] at htick
    exact nonneg_of_mul_nonneg_left htick hΔ
  · exact recdTick_unit_nonneg_of_gate_nonneg tau k

/--
  [TEOREMA] Strict sign lemma (nonzero τ):
  g(τ)·δ^{-k}·|τ| < 0  ↔  g(τ) < 0.
-/
theorem recdTick_unit_neg_iff_gate
    (tau : Rat) (k : Nat) (hτ : tau ≠ 0) :
    recdTick_unit tau k < 0 ↔ gate tau < 0 := by
  constructor
  · intro htick
    have hΔ : 0 < deltaT_unit tau k := deltaT_unit_pos_of_ne tau k hτ
    simp only [recdTick_unit] at htick
    exact neg_of_mul_neg_left htick (le_of_lt hΔ)
  · intro hg
    simp only [recdTick_unit]
    exact mul_neg_of_neg_of_pos hg (deltaT_unit_pos_of_ne tau k hτ)

/-! ### Gate sign support (reference law) -/

/-- [TEOREMA] On the open chaotic band the gate is nonnegative. -/
theorem gate_chaos_nonneg (tau : Rat) (h : absRat tau < tauChaos) :
    0 ≤ gate tau := by
  rw [gate_chaos_abs_formula tau h]
  have hpref : 0 ≤ gatePrefactor := le_of_lt (gatePrefactor_bounds).1
  have hch : 0 < tauChaos := by native_decide
  have hdiff : 0 ≤ tauChaos - absRat tau := sub_nonneg.mpr (le_of_lt h)
  have hnum : 0 ≤ gatePrefactor * (tauChaos - absRat tau) :=
    mul_nonneg hpref hdiff
  exact div_nonneg hnum (le_of_lt hch)

/--
  [TEOREMA] τ > −τ_ch ⇒ g(τ) ≥ 0.
  Combined with anti-sync, this pins the negative cone of the gate.
-/
theorem gate_nonneg_of_gt_neg_chaos (tau : Rat) (h : -tauChaos < tau) :
    0 ≤ gate tau := by
  unfold gate
  split_ifs with hst hch hanti
  · -- stable: g = 1
    exact (by native_decide : (0 : Rat) ≤ 1)
  · -- chaotic band
    have : 0 ≤ gatePrefactor * (tauChaos - absRat tau) / tauChaos := by
      have hpref : 0 ≤ gatePrefactor := le_of_lt (gatePrefactor_bounds).1
      have hτch : 0 < tauChaos := by native_decide
      have hdiff : 0 ≤ tauChaos - absRat tau := sub_nonneg.mpr (le_of_lt hch)
      exact div_nonneg (mul_nonneg hpref hdiff) (le_of_lt hτch)
    exact this
  · -- anti-sync branch is incompatible with τ > −τ_ch
    exact (not_le_of_gt h hanti).elim
  · -- residual intermediate / closed band: g = 0
    exact le_rfl

/-- [TEOREMA] g(τ) < 0 if and only if τ ≤ −τ_ch (reference law). -/
theorem gate_neg_iff_antiSync (tau : Rat) :
    gate tau < 0 ↔ tau ≤ -tauChaos := by
  constructor
  · intro hg
    by_contra hnot
    have hgt : -tauChaos < tau := lt_of_not_ge hnot
    have : 0 ≤ gate tau := gate_nonneg_of_gt_neg_chaos tau hgt
    exact not_lt_of_ge this hg
  · intro hanti
    rw [gate_of_antiSync tau hanti]
    native_decide

/-- [TEOREMA] g(τ) ≥ 0 if and only if τ > −τ_ch. -/
theorem gate_nonneg_iff_gt_neg_chaos (tau : Rat) :
    0 ≤ gate tau ↔ -tauChaos < tau := by
  constructor
  · intro hg
    by_contra hnot
    have hanti : tau ≤ -tauChaos := le_of_not_gt hnot
    have hneg : gate tau < 0 := (gate_neg_iff_antiSync tau).mpr hanti
    exact not_lt_of_ge hg hneg
  · exact gate_nonneg_of_gt_neg_chaos tau

/--
  [TEOREMA] Tick nonnegativity criterion under the reference gate:
  if τ ≠ 0 then (Δt ≥ 0 ↔ τ > −τ_ch).
-/
theorem recdTick_unit_nonneg_iff_gt_neg_chaos
    (tau : Rat) (k : Nat) (hτ : tau ≠ 0) :
    0 ≤ recdTick_unit tau k ↔ -tauChaos < tau := by
  rw [recdTick_unit_nonneg_iff_gate tau k hτ, gate_nonneg_iff_gt_neg_chaos]

/-! ### Accumulation T_n and CT-3 monotonicity recovery -/

/--
  [OPERACIONAL] Partial-sum accumulator of unit RECD ticks.
  T_0 = 0, T_{n+1} = T_n + g(τ_n)·δ^{-k_n}·|τ_n|.
-/
def recdAccum (taus : Nat → Rat) (depths : Nat → Nat) : Nat → Rat
  | 0 => 0
  | n + 1 => recdAccum taus depths n + recdTick_unit (taus n) (depths n)

theorem recdAccum_zero (taus : Nat → Rat) (depths : Nat → Nat) :
    recdAccum taus depths 0 = 0 := rfl

theorem recdAccum_succ (taus : Nat → Rat) (depths : Nat → Nat) (n : Nat) :
    recdAccum taus depths (n + 1) =
      recdAccum taus depths n + recdTick_unit (taus n) (depths n) := rfl

/--
  [TEOREMA] One-step monotonicity ⇔ nonnegative tick.
  (a ≤ a + b ↔ 0 ≤ b on ordered groups.)
-/
theorem recdAccum_le_succ_iff
    (taus : Nat → Rat) (depths : Nat → Nat) (n : Nat) :
    recdAccum taus depths n ≤ recdAccum taus depths (n + 1) ↔
      0 ≤ recdTick_unit (taus n) (depths n) := by
  rw [recdAccum_succ]
  constructor
  · intro h
    exact (le_add_iff_nonneg_right (recdAccum taus depths n)).1 h
  · intro h
    exact (le_add_iff_nonneg_right (recdAccum taus depths n)).2 h

/--
  [TEOREMA] CT-3 (core equivalence, finite horizon N).

  The following are equivalent:
  1. T is nondecreasing on successive steps for all n < N;
  2. every tick ΔT_n is nonnegative for n < N.
-/
theorem recdAccum_monotone_iff_ticks
    (taus : Nat → Rat) (depths : Nat → Nat) (N : Nat) :
    (∀ n, n < N → recdAccum taus depths n ≤ recdAccum taus depths (n + 1)) ↔
      (∀ n, n < N → 0 ≤ recdTick_unit (taus n) (depths n)) := by
  constructor
  · intro h n hn
    exact (recdAccum_le_succ_iff taus depths n).1 (h n hn)
  · intro h n hn
    exact (recdAccum_le_succ_iff taus depths n).2 (h n hn)

/--
  [TEOREMA] CT-3 (gate form, nonzero samples).

  If τ_n ≠ 0 for all n < N, then T monotone on the horizon
  ⇔ g(τ_n) ≥ 0 for all n < N
  ⇔ τ_n > −τ_ch for all n < N.
-/
theorem recdAccum_monotone_iff_gate
    (taus : Nat → Rat) (depths : Nat → Nat) (N : Nat)
    (hτ : ∀ n, n < N → taus n ≠ 0) :
    (∀ n, n < N → recdAccum taus depths n ≤ recdAccum taus depths (n + 1)) ↔
      (∀ n, n < N → 0 ≤ gate (taus n)) := by
  rw [recdAccum_monotone_iff_ticks]
  constructor
  · intro h n hn
    exact (recdTick_unit_nonneg_iff_gate (taus n) (depths n) (hτ n hn)).1 (h n hn)
  · intro h n hn
    exact (recdTick_unit_nonneg_iff_gate (taus n) (depths n) (hτ n hn)).2 (h n hn)

/--
  [TEOREMA] CT-3 sufficient condition (module corollary):
  τ_n > −τ_ch for all n < N ⇒ T nondecreasing on the horizon
  (zero samples allowed: they contribute ΔT = 0).
-/
theorem recdAccum_monotone_of_gt_neg_chaos
    (taus : Nat → Rat) (depths : Nat → Nat) (N : Nat)
    (hτ : ∀ n, n < N → -tauChaos < taus n) :
    ∀ n, n < N → recdAccum taus depths n ≤ recdAccum taus depths (n + 1) := by
  intro n hn
  apply (recdAccum_le_succ_iff taus depths n).2
  apply recdTick_unit_nonneg_of_gate_nonneg
  exact gate_nonneg_of_gt_neg_chaos (taus n) (hτ n hn)

/--
  [TEOREMA] CT-3 sufficient condition via gate:
  g(τ_n) ≥ 0 for all n < N ⇒ T nondecreasing on the horizon.
-/
theorem recdAccum_monotone_of_gate_nonneg
    (taus : Nat → Rat) (depths : Nat → Nat) (N : Nat)
    (hg : ∀ n, n < N → 0 ≤ gate (taus n)) :
    ∀ n, n < N → recdAccum taus depths n ≤ recdAccum taus depths (n + 1) := by
  intro n hn
  exact (recdAccum_le_succ_iff taus depths n).2
    (recdTick_unit_nonneg_of_gate_nonneg (taus n) (depths n) (hg n hn))

/-! ### Negative-tick existence (CT-2 elementary fragment) -/

/-- Constant anti-sync sample path. -/
def constAntiSync (_n : Nat) : Rat := -3 / 4

/-- Constant zero depth schedule. -/
def constDepth0 (_n : Nat) : Nat := 0

/-- [TEOREMA] Constant anti-sync produces a strictly negative unit tick. -/
theorem recdTick_constAntiSync_neg (k : Nat) :
    recdTick_unit (-3 / 4) k < 0 := by
  have hτ : (-3 / 4 : Rat) ≠ 0 := by native_decide
  have hg : gate (-3 / 4 : Rat) < 0 := by
    rw [gate_anti_neg]
    native_decide
  exact (recdTick_unit_neg_iff_gate (-3 / 4) k hτ).2 hg

/--
  [TEOREMA] On the constant anti-sync path, every successive step decreases T.
  Elementary half of CT-2 (infinite negative orientation).
-/
theorem recdAccum_constAntiSync_strict_anti_monotone (n : Nat) :
    recdAccum constAntiSync constDepth0 (n + 1) < recdAccum constAntiSync constDepth0 n := by
  rw [recdAccum_succ]
  have htick : recdTick_unit (constAntiSync n) (constDepth0 n) < 0 := by
    simp only [constAntiSync, constDepth0]
    exact recdTick_constAntiSync_neg 0
  -- a + b < a when b < 0
  linarith

/-- Sample: T_1 < T_0 = 0 on the constant anti-sync path. -/
theorem recdAccum_constAntiSync_T1_neg :
    recdAccum constAntiSync constDepth0 1 < 0 := by
  simpa [recdAccum_zero] using recdAccum_constAntiSync_strict_anti_monotone 0

end SystemicTau
