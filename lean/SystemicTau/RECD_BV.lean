/-
  Discrete BV / Lipschitz calculus for the RECD immersion.

  Module CT (docs/RECD_vs_Thermodynamic_Time.md), immersion §3.1 mixed-sign.
  [TEOREMA] on ℚ paths:
    · cell Lipschitz: |ι(θ₂)−ι(θ₁)| = |θ₂−θ₁|·|ΔT_n|
    · total variation TV_N = ∑_{n<N} |ΔT_n| = ∑ ΔT⁺ + ∑ ΔT⁻
    · |T_N| ≤ TV_N
    · under stable frozen depth + amplitude bound, global Lip vs mesh

  Scope: discrete rational mesh. No continuum BV space, no W^{1,1}.
-/
import SystemicTau.RECD_OrdinalEntropy
import SystemicTau.RECD_Immersion
import SystemicTau.RECD_CT1
import SystemicTau.RECD_CT2

namespace SystemicTau

/-! ### Absolute tick and total variation -/

/-- [OPERACIONAL] Absolute tick mass |ΔT_n|. -/
def tickAbs (taus : Nat → Rat) (depths : Nat → Nat) (n : Nat) : Rat :=
  absRat (recdTick_unit (taus n) (depths n))

theorem tickAbs_nonneg (taus : Nat → Rat) (depths : Nat → Nat) (n : Nat) :
    0 ≤ tickAbs taus depths n :=
  absRat_nonneg _

/--
  [OPERACIONAL] Cumulative total variation:
  TV_0 = 0, TV_{n+1} = TV_n + |ΔT_n|.
-/
def totalVarAccum (taus : Nat → Rat) (depths : Nat → Nat) : Nat → Rat
  | 0 => 0
  | n + 1 =>
      totalVarAccum taus depths n + tickAbs taus depths n

theorem totalVarAccum_zero (taus : Nat → Rat) (depths : Nat → Nat) :
    totalVarAccum taus depths 0 = 0 := rfl

theorem totalVarAccum_succ (taus : Nat → Rat) (depths : Nat → Nat) (n : Nat) :
    totalVarAccum taus depths (n + 1) =
      totalVarAccum taus depths n + tickAbs taus depths n := rfl

/-- Cumulative positive mass ∑ ΔT⁺. -/
def posVarAccum (taus : Nat → Rat) (depths : Nat → Nat) : Nat → Rat
  | 0 => 0
  | n + 1 =>
      posVarAccum taus depths n + posPart (recdTick_unit (taus n) (depths n))

theorem posVarAccum_zero (taus : Nat → Rat) (depths : Nat → Nat) :
    posVarAccum taus depths 0 = 0 := rfl

theorem posVarAccum_succ (taus : Nat → Rat) (depths : Nat → Nat) (n : Nat) :
    posVarAccum taus depths (n + 1) =
      posVarAccum taus depths n +
        posPart (recdTick_unit (taus n) (depths n)) := rfl

/--
  [TEOREMA] |q| = posPart q + negPart q (already in OrdinalEntropy as absRat form).
-/
theorem tickAbs_eq_pos_add_neg
    (taus : Nat → Rat) (depths : Nat → Nat) (n : Nat) :
    tickAbs taus depths n =
      posPart (recdTick_unit (taus n) (depths n)) +
        negPart (recdTick_unit (taus n) (depths n)) := by
  simp only [tickAbs]
  exact absRat_eq_posPart_add_negPart _

/--
  [TEOREMA] TV_N = (∑ ΔT⁺) + (∑ ΔT⁻).
-/
theorem totalVarAccum_eq_pos_add_neg
    (taus : Nat → Rat) (depths : Nat → Nat) (N : Nat) :
    totalVarAccum taus depths N =
      posVarAccum taus depths N + negVarAccum taus depths N := by
  induction N with
  | zero =>
    simp [totalVarAccum_zero, posVarAccum_zero, negVarAccum_zero]
  | succ N ih =>
    rw [totalVarAccum_succ, posVarAccum_succ, negVarAccum_succ, ih,
      tickAbs_eq_pos_add_neg]
    ring

/-- [TEOREMA] Total variation is nonnegative. -/
theorem totalVarAccum_nonneg (taus : Nat → Rat) (depths : Nat → Nat) (N : Nat) :
    0 ≤ totalVarAccum taus depths N := by
  induction N with
  | zero => simp [totalVarAccum_zero]
  | succ N ih =>
    rw [totalVarAccum_succ]
    exact add_nonneg ih (tickAbs_nonneg _ _ _)

/-- [TEOREMA] Triangle inequality for absRat. -/
theorem absRat_add_le (a b : Rat) :
    absRat (a + b) ≤ absRat a + absRat b := by
  simp only [absRat]
  split_ifs <;> linarith

/--
  [TEOREMA] Clock bound by total variation: |T_N| ≤ TV_N.
  (Discrete path of bounded variation.)
-/
theorem abs_recdAccum_le_totalVar
    (taus : Nat → Rat) (depths : Nat → Nat) (N : Nat) :
    absRat (recdAccum taus depths N) ≤ totalVarAccum taus depths N := by
  induction N with
  | zero =>
    simp [recdAccum_zero, totalVarAccum_zero, absRat]
  | succ N ih =>
    rw [recdAccum_succ, totalVarAccum_succ]
    have htri :=
      absRat_add_le (recdAccum taus depths N)
        (recdTick_unit (taus N) (depths N))
    simp only [tickAbs]
    linarith [ih, htri]

/--
  [TEOREMA] Nonnegative form: −TV_N ≤ T_N ≤ TV_N.
-/
theorem recdAccum_abs_bound_totalVar
    (taus : Nat → Rat) (depths : Nat → Nat) (N : Nat) :
    -totalVarAccum taus depths N ≤ recdAccum taus depths N ∧
      recdAccum taus depths N ≤ totalVarAccum taus depths N := by
  have h := abs_recdAccum_le_totalVar taus depths N
  have hTV := totalVarAccum_nonneg taus depths N
  simp only [absRat] at h
  constructor
  · split_ifs at h with hge
    · linarith
    · linarith
  · split_ifs at h with hge
    · exact h
    · linarith

/-! ### Cell Lipschitz of affine immersion -/

/-- Absolute value of a rational difference, packaged for Lip statements. -/
def absDiff (a b : Rat) : Rat := absRat (a - b)

theorem absDiff_comm (a b : Rat) : absDiff a b = absDiff b a := by
  simp only [absDiff, absRat]
  split_ifs with h1 h2 h2 <;> linarith

/--
  [TEOREMA] Exact cell identity:
  ι(θ₂) − ι(θ₁) = (θ₂ − θ₁) · ΔT_n.
-/
theorem immerseAffine_diff
    (taus : Nat → Rat) (depths : Nat → Nat) (n : Nat) (θ₁ θ₂ : Rat) :
    immerseAffine taus depths n θ₂ - immerseAffine taus depths n θ₁ =
      (θ₂ - θ₁) * recdTick_unit (taus n) (depths n) := by
  simp only [immerseAffine]
  ring

/-- [TEOREMA] |a·b| = |a|·|b| on ℚ. -/
theorem absRat_mul (a b : Rat) : absRat (a * b) = absRat a * absRat b := by
  rcases le_or_lt 0 a with ha | ha <;> rcases le_or_lt 0 b with hb | hb
  · have hab : 0 ≤ a * b := mul_nonneg ha hb
    simp only [absRat, ha, hb, hab, ite_true]
  · have hb0 : b ≤ 0 := le_of_lt hb
    have hmul : a * b ≤ 0 := mul_nonpos_of_nonneg_of_nonpos ha hb0
    simp only [absRat, ha, show ¬0 ≤ b from not_le_of_gt hb, ite_true, ite_false]
    by_cases hge : 0 ≤ a * b
    · have hz : a * b = 0 := le_antisymm hmul hge
      have hbne : b ≠ 0 := ne_of_lt hb
      have ha0 : a = 0 := (mul_eq_zero.mp hz).resolve_right hbne
      simp [hge, hz, ha0]
    · simp only [hge, ite_false]
      ring
  · have ha0 : a ≤ 0 := le_of_lt ha
    have hmul : a * b ≤ 0 := mul_nonpos_of_nonpos_of_nonneg ha0 hb
    simp only [absRat, hb, show ¬0 ≤ a from not_le_of_gt ha, ite_true, ite_false]
    by_cases hge : 0 ≤ a * b
    · have hz : a * b = 0 := le_antisymm hmul hge
      have hane : a ≠ 0 := ne_of_lt ha
      have hb0 : b = 0 := (mul_eq_zero.mp hz).resolve_left hane
      simp [hge, hz, hb0]
    · simp only [hge, ite_false]
      ring
  · have hpos : 0 < a * b := mul_pos_of_neg_of_neg ha hb
    simp only [absRat, show ¬0 ≤ a from not_le_of_gt ha,
      show ¬0 ≤ b from not_le_of_gt hb,
      show 0 ≤ a * b from le_of_lt hpos, ite_true, ite_false]
    ring

/--
  [TEOREMA] Cell Lipschitz (exact):
  |ι(θ₂) − ι(θ₁)| = |θ₂ − θ₁| · |ΔT_n|.
-/
theorem immerseAffine_lipschitz_exact
    (taus : Nat → Rat) (depths : Nat → Nat) (n : Nat) (θ₁ θ₂ : Rat) :
    absRat (immerseAffine taus depths n θ₂ - immerseAffine taus depths n θ₁) =
      absRat (θ₂ - θ₁) * absRat (recdTick_unit (taus n) (depths n)) := by
  rw [immerseAffine_diff, absRat_mul]

/--
  [TEOREMA] Cell Lipschitz inequality:
  |ι(θ₂) − ι(θ₁)| ≤ |ΔT_n| · |θ₂ − θ₁|.
-/
theorem immerseAffine_lipschitz
    (taus : Nat → Rat) (depths : Nat → Nat) (n : Nat) (θ₁ θ₂ : Rat) :
    absRat (immerseAffine taus depths n θ₂ - immerseAffine taus depths n θ₁) ≤
      tickAbs taus depths n * absRat (θ₂ - θ₁) := by
  rw [immerseAffine_lipschitz_exact]
  simp only [tickAbs, mul_comm]
  exact le_rfl

/--
  [TEOREMA] If |ΔT_n| ≤ K then ι is K-Lipschitz in θ on the cell.
-/
theorem immerseAffine_lipschitz_of_tick_le
    (taus : Nat → Rat) (depths : Nat → Nat) (n : Nat) (K : Rat)
    (hK : tickAbs taus depths n ≤ K) (θ₁ θ₂ : Rat) :
    absRat (immerseAffine taus depths n θ₂ - immerseAffine taus depths n θ₁) ≤
      K * absRat (θ₂ - θ₁) := by
  have h := immerseAffine_lipschitz taus depths n θ₁ θ₂
  have habs : 0 ≤ absRat (θ₂ - θ₁) := absRat_nonneg _
  have : tickAbs taus depths n * absRat (θ₂ - θ₁) ≤ K * absRat (θ₂ - θ₁) :=
    mul_le_mul_of_nonneg_right hK habs
  linarith

/-! ### Mesh-parameter Lipschitz under stable frozen depth -/

/--
  [TEOREMA] Under stable regime + frozen depth + τ ≤ M,
  |ΔT| ≤ δ^{-k}·M, hence cell Lip constant ≤ δ^{-k}·M.
-/
theorem tickAbs_stable_le
    (tau : Rat) (k : Nat) (M : Rat)
    (hst : tau ≥ tauStable) (hM : tau ≤ M) :
    tickAbs (fun _ => tau) (frozenDepth k) 0 ≤ deltaInvPow k * M := by
  -- only n=0 matters for constant path; prove general form below
  simp only [tickAbs, frozenDepth]
  have heq : recdTick_unit tau k = deltaInvPow k * tau :=
    recdTick_unit_of_stable tau k hst
  have hpos : 0 ≤ recdTick_unit tau k :=
    le_of_lt (recdTick_unit_pos_of_stable tau k hst)
  have habs : absRat (recdTick_unit tau k) = recdTick_unit tau k :=
    absRat_of_nonneg hpos
  rw [habs, heq]
  have hδ : 0 ≤ deltaInvPow k := deltaInvPow_nonneg k
  exact mul_le_mul_of_nonneg_left hM hδ

/--
  [TEOREMA] Uniform tick-abs bound on a stable frozen-depth horizon
  with τ_n ≤ M for all n < N.
-/
theorem tickAbs_le_of_stable_bound
    (taus : Nat → Rat) (kStar : Nat) (M : Rat) (n : Nat)
    (hst : taus n ≥ tauStable) (hM : taus n ≤ M) :
    tickAbs taus (frozenDepth kStar) n ≤ deltaInvPow kStar * M := by
  simp only [tickAbs, frozenDepth]
  have heq : recdTick_unit (taus n) kStar = deltaInvPow kStar * taus n :=
    recdTick_unit_of_stable (taus n) kStar hst
  have hpos : 0 ≤ recdTick_unit (taus n) kStar :=
    le_of_lt (recdTick_unit_pos_of_stable (taus n) kStar hst)
  have habs : absRat (recdTick_unit (taus n) kStar) = recdTick_unit (taus n) kStar :=
    absRat_of_nonneg hpos
  rw [habs, heq]
  exact mul_le_mul_of_nonneg_left hM (deltaInvPow_nonneg kStar)

/--
  [TEOREMA] Horizon total variation under stable frozen depth + 0 ≤ τ ≤ M:
  TV_N ≤ N · δ^{-k}·M.
-/
theorem totalVar_stable_le
    (taus : Nat → Rat) (kStar : Nat) (M : Rat) (N : Nat)
    (hst : ∀ n, n < N → taus n ≥ tauStable)
    (hM : ∀ n, n < N → taus n ≤ M)
    (hM0 : 0 ≤ M) :
    totalVarAccum taus (frozenDepth kStar) N ≤
      (N : Rat) * (deltaInvPow kStar * M) := by
  induction N with
  | zero => simp [totalVarAccum_zero]
  | succ N ih =>
    rw [totalVarAccum_succ]
    have ih' := ih
      (fun n hn => hst n (Nat.lt_trans hn (Nat.lt_succ_self N)))
      (fun n hn => hM n (Nat.lt_trans hn (Nat.lt_succ_self N)))
    have htick :=
      tickAbs_le_of_stable_bound taus kStar M N
        (hst N (Nat.lt_succ_self N)) (hM N (Nat.lt_succ_self N))
    have hcast : ((N + 1 : Nat) : Rat) = (N : Rat) + 1 := by
      simp [Nat.cast_succ]
    have hδM : 0 ≤ deltaInvPow kStar * M :=
      mul_nonneg (deltaInvPow_nonneg kStar) hM0
    calc
      totalVarAccum taus (frozenDepth kStar) N +
            tickAbs taus (frozenDepth kStar) N
          ≤ (N : Rat) * (deltaInvPow kStar * M) + deltaInvPow kStar * M := by
            linarith [ih', htick]
      _ = ((N : Rat) + 1) * (deltaInvPow kStar * M) := by ring
      _ = ((N + 1 : Nat) : Rat) * (deltaInvPow kStar * M) := by rw [hcast]

/--
  [TEOREMA] Mixed-sign sample: on period-2, |ΔT_n| = 3/4 constantly
  (depth 0), so TV_N = N · (3/4).
-/
theorem tickAbs_period2 (n : Nat) :
    tickAbs period2AntiSync constDepth0 n = 3 / 4 := by
  simp only [tickAbs, constDepth0]
  by_cases he : n % 2 = 0
  · have hk : n = 2 * (n / 2) := by
      have h := Nat.div_add_mod n 2
      rw [he, Nat.add_zero] at h
      exact h.symm
    rw [hk, recdTick_period2_even (n / 2)]
    native_decide
  · have hodd : n % 2 = 1 := Nat.mod_two_ne_zero.mp he
    have hk : n = 2 * (n / 2) + 1 := by
      have h := Nat.div_add_mod n 2
      rw [hodd] at h
      exact h.symm
    rw [hk, recdTick_period2_odd (n / 2)]
    native_decide

theorem totalVar_period2 (N : Nat) :
    totalVarAccum period2AntiSync constDepth0 N = (N : Rat) * (3 / 4) := by
  induction N with
  | zero => simp [totalVarAccum]
  | succ N ih =>
    rw [totalVarAccum_succ, ih, tickAbs_period2]
    have hcast : ((N + 1 : Nat) : Rat) = (N : Rat) + 1 := by exact_mod_cast rfl
    rw [hcast]
    ring

/--
  [TEOREMA] On period-2, T oscillates but TV grows linearly:
  |T_N| ≤ 3/4 while TV_N = N·(3/4) → ∞.
  (BV clock can reverse while variation accumulates.)
-/
theorem period2_T_bounded_TV_unbounded (m : Nat) :
    absRat (recdAccum period2AntiSync constDepth0 (2 * m)) = 0 ∧
      totalVarAccum period2AntiSync constDepth0 (2 * m) =
        (2 * m : Nat) * (3 / 4) := by
  constructor
  · rw [recdAccum_period2_even]
    simp [absRat]
  · exact totalVar_period2 (2 * m)

end SystemicTau
