/-
  CT-3 quantitative recovery: finite negative variation bound.

  Module CT (docs/RECD_vs_Thermodynamic_Time.md), Statement CT-3
  (quantitative recovery fragment, upgraded from [CONJETURA] to [TEOREMA]
  on discrete ℚ paths with uniform |τ| bound).

  Claim (unit case B = 1):
    if # { n < N | τ_n ≤ −τ_ch } ≤ M and |τ_n| ≤ 1 for all n < N,
    then T_N ≥ T_0 − M  (and T_0 = 0 ⇒ T_N ≥ −M).

  Scope: discrete sequences on ℚ. No immersion / BV calculus.
-/
import SystemicTau.RECD_Monotonicity
import SystemicTau.RECD_OrdinalEntropy

namespace SystemicTau

/-! ### Depth scale: δ^{-k} ≤ 1 -/

/-- [TEOREMA] Operational Feigenbaum δ > 1. -/
theorem feigenbaumDeltaOp_gt_one : (1 : Rat) < feigenbaumDeltaOp := by
  native_decide

/-- [TEOREMA] δ^{-k} ≤ 1 for every depth k. -/
theorem deltaInvPow_le_one (k : Nat) : deltaInvPow k ≤ 1 := by
  induction k with
  | zero =>
    simp only [deltaInvPow]
    exact le_rfl
  | succ k ih =>
    -- δ^{-(k+1)} = δ^{-k} / δ ≤ δ^{-k} ≤ 1  (δ > 1)
    have hδ : (1 : Rat) < feigenbaumDeltaOp := feigenbaumDeltaOp_gt_one
    have hδpos : 0 < feigenbaumDeltaOp :=
      lt_trans (by native_decide : (0 : Rat) < 1) hδ
    have hdiv : deltaInvPow (k + 1) = deltaInvPow k / feigenbaumDeltaOp := by
      simp only [deltaInvPow, feigenbaumDeltaOp]
    rw [hdiv]
    have ha0 : 0 ≤ deltaInvPow k := deltaInvPow_nonneg k
    have hle : deltaInvPow k / feigenbaumDeltaOp ≤ deltaInvPow k := by
      -- a/δ ≤ a ↔ a ≤ a·δ (δ > 0)
      rw [div_le_iff₀ hδpos]
      have : deltaInvPow k * (1 : Rat) ≤ deltaInvPow k * feigenbaumDeltaOp :=
        mul_le_mul_of_nonneg_left (le_of_lt hδ) ha0
      simpa using this
    exact le_trans hle ih

/-! ### Tick bounds under |τ| ≤ B -/

/--
  [TEOREMA] Unit skeleton ≤ B when |τ| ≤ B
  (using δ^{-k} ≤ 1).
-/
theorem deltaT_unit_le_of_abs_le
    (tau : Rat) (k : Nat) (B : Rat) (hB : absRat tau ≤ B) :
    deltaT_unit tau k ≤ B := by
  simp only [deltaT_unit]
  -- δ^{-k} * |τ| ≤ 1 * |τ| ≤ B
  have hδ : deltaInvPow k ≤ 1 := deltaInvPow_le_one k
  have habs0 : 0 ≤ absRat tau := absRat_nonneg tau
  have h1 : deltaInvPow k * absRat tau ≤ 1 * absRat tau :=
    mul_le_mul_of_nonneg_right hδ habs0
  have h2 : (1 : Rat) * absRat tau = absRat tau := one_mul _
  calc
    deltaInvPow k * absRat tau ≤ 1 * absRat tau := h1
    _ = absRat tau := h2
    _ ≤ B := hB

/--
  [TEOREMA] On anti-sync, g = −1 ⇒ ΔT = −δ^{-k}|τ| ≥ −B
  whenever |τ| ≤ B and B ≥ 0.
-/
theorem recdTick_unit_antiSync_ge
    (tau : Rat) (k : Nat) (B : Rat)
    (hanti : tau ≤ -tauChaos) (_hB0 : 0 ≤ B) (hB : absRat tau ≤ B) :
    -B ≤ recdTick_unit tau k := by
  have hg : gate tau = -1 := gate_of_antiSync tau hanti
  simp only [recdTick_unit, hg, neg_mul, one_mul]
  -- goal: −B ≤ −δ^{-k}|τ| ⇔ δ^{-k}|τ| ≤ B
  have hΔ : deltaT_unit tau k ≤ B := deltaT_unit_le_of_abs_le tau k B hB
  linarith

/--
  [TEOREMA] Outside anti-sync, g ≥ 0 ⇒ ΔT ≥ 0.
-/
theorem recdTick_unit_nonneg_of_not_antiSync
    (tau : Rat) (k : Nat) (h : ¬ tau ≤ -tauChaos) :
    0 ≤ recdTick_unit tau k := by
  have hgt : -tauChaos < tau := lt_of_not_ge h
  exact recdTick_unit_nonneg_of_gate_nonneg tau k
    (gate_nonneg_of_gt_neg_chaos tau hgt)

/--
  [TEOREMA] Every unit tick is ≥ −B under |τ| ≤ B (B ≥ 0),
  whether or not the sample is anti-sync.
-/
theorem recdTick_unit_ge_neg_bound
    (tau : Rat) (k : Nat) (B : Rat)
    (hB0 : 0 ≤ B) (hB : absRat tau ≤ B) :
    -B ≤ recdTick_unit tau k := by
  by_cases hanti : tau ≤ -tauChaos
  · exact recdTick_unit_antiSync_ge tau k B hanti hB0 hB
  · have hnn : 0 ≤ recdTick_unit tau k :=
      recdTick_unit_nonneg_of_not_antiSync tau k hanti
    linarith

/-! ### Anti-sync visit counter -/

/--
  [OPERACIONAL] Number of anti-sync visits on {0,…,N−1}.
  `antiSyncCount taus N = # { n < N | τ_n ≤ −τ_ch }`.
-/
def antiSyncCount (taus : Nat → Rat) : Nat → Nat
  | 0 => 0
  | n + 1 =>
      antiSyncCount taus n + if taus n ≤ -tauChaos then 1 else 0

theorem antiSyncCount_zero (taus : Nat → Rat) : antiSyncCount taus 0 = 0 := rfl

theorem antiSyncCount_succ (taus : Nat → Rat) (n : Nat) :
    antiSyncCount taus (n + 1) =
      antiSyncCount taus n + if taus n ≤ -tauChaos then 1 else 0 := rfl

theorem antiSyncCount_succ_anti
    (taus : Nat → Rat) (n : Nat) (h : taus n ≤ -tauChaos) :
    antiSyncCount taus (n + 1) = antiSyncCount taus n + 1 := by
  simp [antiSyncCount, h]

theorem antiSyncCount_succ_not_anti
    (taus : Nat → Rat) (n : Nat) (h : ¬ taus n ≤ -tauChaos) :
    antiSyncCount taus (n + 1) = antiSyncCount taus n := by
  simp [antiSyncCount, h]

/-! ### Negative variation (sum of reverse masses) -/

/--
  [OPERACIONAL] Cumulative reverse mass ∑_{n<N} ΔT_n⁻.
-/
def negVarAccum (taus : Nat → Rat) (depths : Nat → Nat) : Nat → Rat
  | 0 => 0
  | n + 1 =>
      negVarAccum taus depths n + negPart (recdTick_unit (taus n) (depths n))

theorem negVarAccum_zero (taus : Nat → Rat) (depths : Nat → Nat) :
    negVarAccum taus depths 0 = 0 := rfl

theorem negVarAccum_succ (taus : Nat → Rat) (depths : Nat → Nat) (n : Nat) :
    negVarAccum taus depths (n + 1) =
      negVarAccum taus depths n +
        negPart (recdTick_unit (taus n) (depths n)) := rfl

/--
  [TEOREMA] Clock vs reverse mass:
  T_N ≥ − (∑ ΔT⁻)  (since T_N = ∑(ΔT⁺ − ΔT⁻) ≥ −∑ ΔT⁻).
-/
theorem recdAccum_ge_neg_negVar
    (taus : Nat → Rat) (depths : Nat → Nat) (N : Nat) :
    -negVarAccum taus depths N ≤ recdAccum taus depths N := by
  induction N with
  | zero =>
    simp only [negVarAccum_zero, recdAccum_zero, neg_zero]
    exact le_rfl
  | succ N ih =>
    rw [negVarAccum_succ, recdAccum_succ]
    -- −(V + n) ≤ A + t  from −V ≤ A and −n ≤ t (t = p − n, so t ≥ −n)
    have ht : recdTick_unit (taus N) (depths N) =
        posPart (recdTick_unit (taus N) (depths N)) -
          negPart (recdTick_unit (taus N) (depths N)) :=
      (posPart_sub_negPart _).symm
    have hpos : 0 ≤ posPart (recdTick_unit (taus N) (depths N)) :=
      posPart_nonneg _
    -- t ≥ − negPart
    have ht_ge : -negPart (recdTick_unit (taus N) (depths N)) ≤
        recdTick_unit (taus N) (depths N) := by
      linarith [ht, hpos]
    linarith

/--
  [TEOREMA] On a non-anti-sync step, reverse mass is 0.
-/
theorem negPart_tick_of_not_antiSync
    (tau : Rat) (k : Nat) (h : ¬ tau ≤ -tauChaos) :
    negPart (recdTick_unit tau k) = 0 := by
  exact negPart_eq_zero_of_nonneg
    (recdTick_unit_nonneg_of_not_antiSync tau k h)

/--
  [TEOREMA] On anti-sync with |τ| ≤ B, reverse mass ≤ B.
-/
theorem negPart_tick_antiSync_le
    (tau : Rat) (k : Nat) (B : Rat)
    (hanti : tau ≤ -tauChaos) (hB0 : 0 ≤ B) (hB : absRat tau ≤ B) :
    negPart (recdTick_unit tau k) ≤ B := by
  have htick : recdTick_unit tau k ≤ 0 := by
    have hg : gate tau = -1 := gate_of_antiSync tau hanti
    have : gate tau ≤ 0 := by simp [hg]
    exact recdTick_unit_nonpos_of_gate_nonpos tau k this
  -- negPart = −ΔT when ΔT ≤ 0
  have hn : negPart (recdTick_unit tau k) = -recdTick_unit tau k :=
    (negPart_of_nonpos htick).2
  rw [hn]
  have hge : -B ≤ recdTick_unit tau k :=
    recdTick_unit_antiSync_ge tau k B hanti hB0 hB
  linarith

/-! ### Main quantitative recovery theorems -/

/--
  [TEOREMA] Reverse-mass bound:
  under |τ_n| ≤ B (n < N),  ∑_{n<N} ΔT_n⁻ ≤ B · (# anti-sync visits).
-/
theorem negVarAccum_le_antiSync_mass
    (taus : Nat → Rat) (depths : Nat → Nat) (B : Rat) (N : Nat)
    (hB0 : 0 ≤ B)
    (hB : ∀ n, n < N → absRat (taus n) ≤ B) :
    negVarAccum taus depths N ≤ B * (antiSyncCount taus N : Rat) := by
  induction N with
  | zero =>
    simp only [negVarAccum_zero, antiSyncCount_zero]
    simp
  | succ N ih =>
    rw [negVarAccum_succ, antiSyncCount_succ]
    have ih' : negVarAccum taus depths N ≤ B * (antiSyncCount taus N : Rat) := by
      apply ih
      intro n hn
      exact hB n (Nat.lt_trans hn (Nat.lt_succ_self N))
    have hBN : absRat (taus N) ≤ B := hB N (Nat.lt_succ_self N)
    by_cases hanti : taus N ≤ -tauChaos
    · -- anti-sync step: reverse mass ≤ B, count += 1
      have hnp : negPart (recdTick_unit (taus N) (depths N)) ≤ B :=
        negPart_tick_antiSync_le (taus N) (depths N) B hanti hB0 hBN
      simp only [hanti, ite_true]
      have hcast :
          ((antiSyncCount taus N + 1 : Nat) : Rat) =
            (antiSyncCount taus N : Rat) + 1 := by
        exact_mod_cast rfl
      have hsum :
          negVarAccum taus depths N +
              negPart (recdTick_unit (taus N) (depths N)) ≤
            B * (antiSyncCount taus N : Rat) + B := by
        linarith
      have hmul : B * (antiSyncCount taus N : Rat) + B =
          B * ((antiSyncCount taus N : Rat) + 1) := by
        ring
      rw [hmul] at hsum
      rwa [← hcast] at hsum
    · -- non-anti-sync: reverse mass = 0, count unchanged
      have hnp : negPart (recdTick_unit (taus N) (depths N)) = 0 :=
        negPart_tick_of_not_antiSync (taus N) (depths N) hanti
      simp only [hanti, ite_false, hnp, add_zero]
      simpa using ih'

/--
  [TEOREMA] CT-3 quantitative recovery (B-form):
  if |τ_n| ≤ B for all n < N, then
    T_N ≥ − B · (# anti-sync visits on the horizon).
-/
theorem recdAccum_ge_neg_antiSync_mass
    (taus : Nat → Rat) (depths : Nat → Nat) (B : Rat) (N : Nat)
    (hB0 : 0 ≤ B)
    (hB : ∀ n, n < N → absRat (taus n) ≤ B) :
    -B * (antiSyncCount taus N : Rat) ≤ recdAccum taus depths N := by
  have hV : negVarAccum taus depths N ≤ B * (antiSyncCount taus N : Rat) :=
    negVarAccum_le_antiSync_mass taus depths B N hB0 hB
  have hT : -negVarAccum taus depths N ≤ recdAccum taus depths N :=
    recdAccum_ge_neg_negVar taus depths N
  linarith

/--
  [TEOREMA] CT-3 quantitative recovery (M-form):
  if |τ_n| ≤ B for n < N and # anti-sync visits ≤ M, then T_N ≥ −B·M.
-/
theorem recdAccum_ge_neg_of_antiSync_le
    (taus : Nat → Rat) (depths : Nat → Nat) (B : Rat) (M N : Nat)
    (hB0 : 0 ≤ B)
    (hB : ∀ n, n < N → absRat (taus n) ≤ B)
    (hM : antiSyncCount taus N ≤ M) :
    -B * (M : Rat) ≤ recdAccum taus depths N := by
  have hmain :
      -B * (antiSyncCount taus N : Rat) ≤ recdAccum taus depths N :=
    recdAccum_ge_neg_antiSync_mass taus depths B N hB0 hB
  have hcnt : (antiSyncCount taus N : Rat) ≤ (M : Rat) := by
    exact_mod_cast hM
  -- −B·c ≥ −B·M when B ≥ 0 and c ≤ M, so lower bound −B·M is weaker
  have hBcnt : -B * (M : Rat) ≤ -B * (antiSyncCount taus N : Rat) := by
    -- multiply by −B ≤ 0 reverses inequality? Wait: −B ≤ 0, c ≤ M
    -- (−B)*M ≤ (−B)*c  because multiplying by nonpositive reverses
    nlinarith
  linarith

/--
  [TEOREMA] Unit quantitative recovery (module form with B = 1):
  |τ_n| ≤ 1 and # anti-sync ≤ M ⇒ T_N ≥ −M.
-/
theorem recdAccum_ge_neg_M_unit
    (taus : Nat → Rat) (depths : Nat → Nat) (M N : Nat)
    (hB : ∀ n, n < N → absRat (taus n) ≤ 1)
    (hM : antiSyncCount taus N ≤ M) :
    -(M : Rat) ≤ recdAccum taus depths N := by
  have h := recdAccum_ge_neg_of_antiSync_le taus depths 1 M N
    (by native_decide : (0 : Rat) ≤ 1) hB hM
  -- −1 * M = −M
  simpa using h

/--
  [TEOREMA] Zero anti-sync visits ⇒ T_N ≥ 0
  (under any |τ| bound; in fact under g ≥ 0 alone — recovered here as M = 0).
-/
theorem recdAccum_nonneg_of_no_antiSync
    (taus : Nat → Rat) (depths : Nat → Nat) (B : Rat) (N : Nat)
    (hB0 : 0 ≤ B)
    (hB : ∀ n, n < N → absRat (taus n) ≤ B)
    (hM : antiSyncCount taus N = 0) :
    0 ≤ recdAccum taus depths N := by
  have h := recdAccum_ge_neg_of_antiSync_le taus depths B 0 N hB0 hB (by simp [hM])
  simpa using h

/-! ### Sample checks -/

/-- Constant anti-sync with |τ| = 3/4 ≤ 1: after N steps, count = N and T_N ≥ −N. -/
theorem recdAccum_constAntiSync_ge_neg_N (N : Nat) :
    -(N : Rat) ≤ recdAccum constAntiSync constDepth0 N := by
  apply recdAccum_ge_neg_M_unit (M := N)
  · intro n hn
    simp only [constAntiSync, absRat]
    native_decide
  · -- every step is anti-sync ⇒ count = N
    induction N with
    | zero => simp [antiSyncCount]
    | succ N ih =>
      have hanti : constAntiSync N ≤ -tauChaos := by
        simp only [constAntiSync, tauChaos]
        native_decide
      rw [antiSyncCount_succ_anti _ _ hanti]
      exact Nat.succ_le_succ ih

/-- Sharper: on constant anti-sync with depth 0, T_N = −N·(3/4). -/
theorem recdAccum_constAntiSync_exact (N : Nat) :
    recdAccum constAntiSync constDepth0 N = -(N : Rat) * (3 / 4) := by
  induction N with
  | zero => simp [recdAccum]
  | succ N ih =>
    rw [recdAccum_succ, ih]
    have htick : recdTick_unit (constAntiSync N) (constDepth0 N) = -(3 / 4 : Rat) := by
      simp only [constAntiSync, constDepth0, recdTick_unit, deltaT_unit, deltaInvPow]
      have hg : gate (-3 / 4 : Rat) = -1 := gate_anti_neg
      have habs : absRat (-3 / 4 : Rat) = 3 / 4 := by native_decide
      simp [hg, habs]
    have hcast : ((N + 1 : Nat) : Rat) = (N : Rat) + 1 := by exact_mod_cast rfl
    rw [htick, hcast]
    ring

end SystemicTau
