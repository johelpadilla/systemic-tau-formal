/-
  Discrete Extramental Clock (RECD): gate specification.

  Reference law (systemictau.recd):
    g = +1 if τ ≥ 1/2
    g = ((δ-1)/δ) * (τ_ch - |τ|) / τ_ch if |τ| < τ_ch
    g = -1 if τ ≤ -τ_ch
    g = 0 otherwise
-/
import SystemicTau.Basic
import SystemicTau.Thresholds

namespace SystemicTau

/-- Absolute value on rationals. -/
def absRat (q : Rat) : Rat := if q ≥ 0 then q else -q

theorem absRat_of_nonneg {q : Rat} (h : 0 ≤ q) : absRat q = q := by
  simp [absRat, h]

theorem absRat_of_nonpos {q : Rat} (h : q ≤ 0) : absRat q = -q := by
  simp only [absRat]
  split_ifs with hge
  · have : q = 0 := le_antisymm h hge
    simp [this]
  · rfl

theorem absRat_neg (q : Rat) : absRat (-q) = absRat q := by
  simp only [absRat]
  split_ifs with h1 h2 h2 <;> linarith

theorem absRat_nonneg (q : Rat) : 0 ≤ absRat q := by
  simp only [absRat]
  split_ifs with h
  · exact h
  · have : q < 0 := lt_of_not_ge h
    exact le_of_lt (neg_pos.mpr this)

/-- Gate function g(τₛ) on ℚ. [OPERACIONAL] -/
def gate (tau : Rat) : Rat :=
  if tau ≥ tauStable then 1
  else if absRat tau < tauChaos then
    gatePrefactor * (tauChaos - absRat tau) / tauChaos
  else if tau ≤ -tauChaos then -1
  else 0

/-- On the nonnegative chaotic half-band, gate has closed form. [TEOREMA] -/
theorem gate_chaos_nonneg_formula
    (tau : Rat) (h0 : 0 ≤ tau) (h1 : tau < tauChaos) :
    gate tau = gatePrefactor * (tauChaos - tau) / tauChaos := by
  have h_not_stable : ¬ tau ≥ tauStable := by
    intro hst
    have : tauChaos < tauStable := tauChaos_lt_tauStable
    have : tau < tauStable := lt_of_lt_of_le h1 (le_of_lt this)
    exact (not_le_of_gt this) hst
  have habs : absRat tau = tau := absRat_of_nonneg h0
  have h_chaos : absRat tau < tauChaos := by simpa [habs] using h1
  simp [gate, h_not_stable, h_chaos, habs]

/--
  [TEOREMA] On [0, τ_ch), g is antitone (decreases as τ increases toward the edge).
-/
theorem gate_antitone_on_nonneg_chaos
    (a b : Rat)
    (ha0 : 0 ≤ a) (hab : a ≤ b) (hb : b < tauChaos) :
    gate b ≤ gate a := by
  have ha1 : a < tauChaos := lt_of_le_of_lt hab hb
  have ha0' := ha0
  have hb0 : 0 ≤ b := le_trans ha0 hab
  rw [gate_chaos_nonneg_formula a ha0' ha1, gate_chaos_nonneg_formula b hb0 hb]
  -- gatePrefactor > 0, τ_ch > 0, and (τ_ch - b) ≤ (τ_ch - a)
  have hpref : 0 < gatePrefactor := (gatePrefactor_bounds).1
  have hch : 0 < tauChaos := by native_decide
  have hdiff : tauChaos - b ≤ tauChaos - a := by
    have : -b ≤ -a := neg_le_neg hab
    linarith
  have hnum : 0 ≤ gatePrefactor * (tauChaos - b) :=
    mul_nonneg (le_of_lt hpref) (sub_nonneg.mpr (le_of_lt hb))
  -- compare quotients: (p * x) / c ≤ (p * y) / c when x ≤ y, c > 0, p > 0
  have hx : tauChaos - b ≤ tauChaos - a := hdiff
  have : gatePrefactor * (tauChaos - b) ≤ gatePrefactor * (tauChaos - a) :=
    mul_le_mul_of_nonneg_left hx (le_of_lt hpref)
  exact div_le_div_of_nonneg_right this (le_of_lt hch)

/-- Stable regime opens the gate positively. -/
theorem gate_stable_pos : gate (3 / 4) = 1 := by
  native_decide

/-- Strong anti-synchronization opens the gate negatively. -/
theorem gate_anti_neg : gate (-3 / 4) = -1 := by
  native_decide

/-- Intermediate sample (between 0.41 and 0.50) keeps gate closed. -/
theorem gate_intermediate_zero : gate (45 / 100) = 0 := by
  native_decide

/--
  [TEOREMA] Positive intermediate band: τ_ch ≤ τ < τ_st ⇒ g(τ) = 0.

  Asymmetry [OPERACIONAL]: τ ≤ -τ_ch yields g = -1 (anti-sync), even when
  |τ| < τ_st. There is no matching open interval with g ≡ 0 on the negative side.
-/
theorem gate_intermediate_nonneg
    (tau : Rat) (h_lo : tauChaos ≤ tau) (h_hi : tau < tauStable) :
    gate tau = 0 := by
  have h_not_stable : ¬ tau ≥ tauStable := not_le_of_gt h_hi
  have habs : absRat tau = tau := absRat_of_nonneg (le_trans (by native_decide : (0 : Rat) ≤ tauChaos) h_lo)
  have h_not_chaos : ¬ absRat tau < tauChaos := by
    simpa [habs] using not_lt_of_ge h_lo
  have h_not_anti : ¬ tau ≤ -tauChaos := by
    intro h
    have hpos : 0 ≤ tau := le_trans (by native_decide : (0 : Rat) ≤ tauChaos) h_lo
    have : tau ≤ 0 := le_trans h (by native_decide : -tauChaos ≤ 0)
    have : tau = 0 := le_antisymm this hpos
    have : tauChaos ≤ 0 := by simpa [this] using h_lo
    exact (not_le_of_gt (by native_decide : (0 : Rat) < tauChaos)) this
  simp [gate, h_not_stable, h_not_chaos, h_not_anti]

/-- Under the reference law, τ = -0.45 is anti-sync (g = -1), not intermediate. -/
theorem gate_neg_near_chaos_is_anti : gate (-45 / 100) = -1 := by
  native_decide

/-- Center of chaotic band: g(0) = (δ−1)/δ. -/
theorem gate_at_zero : gate 0 = gatePrefactor := by
  native_decide

/-- Chaotic-band gate is nonnegative at center. -/
theorem gate_chaos_center_nonneg : 0 ≤ gate 0 := by
  native_decide

/-- Concrete check of antitone property on sample points. -/
theorem gate_antitone_sample : gate (2 / 10) ≤ gate (1 / 10) := by
  native_decide

/-- On the full open chaotic band, gate depends only on |τ|. [TEOREMA] -/
theorem gate_chaos_abs_formula
    (tau : Rat) (h : absRat tau < tauChaos) :
    gate tau = gatePrefactor * (tauChaos - absRat tau) / tauChaos := by
  have h_not_stable : ¬ tau ≥ tauStable := by
    intro hst
    have hbound : absRat tau ≤ tau := by
      -- |τ| ≤ τ is false in general; use |τ| < τ_ch < τ_st ≤ τ ⇒ contradiction via |τ|≥τ when τ≥0
      have hpos : 0 ≤ tau := le_trans (by native_decide : (0 : Rat) ≤ tauStable) hst
      simpa [absRat_of_nonneg hpos] using le_rfl
    have : tauChaos < tauStable := tauChaos_lt_tauStable
    have hlt : absRat tau < tauStable := lt_of_lt_of_le h (le_of_lt this)
    have : tau < tauStable := by
      have hpos : 0 ≤ tau := le_trans (by native_decide : (0 : Rat) ≤ tauStable) hst
      simpa [absRat_of_nonneg hpos] using hlt
    exact (not_le_of_gt this) hst
  simp [gate, h_not_stable, h]

/-- [TEOREMA] Evenness on the chaotic band: g(-τ) = g(τ) whenever |τ| < τ_ch. -/
theorem gate_chaos_even
    (tau : Rat) (h : absRat tau < tauChaos) :
    gate (-tau) = gate tau := by
  have hneg : absRat (-tau) < tauChaos := by simpa [absRat_neg] using h
  rw [gate_chaos_abs_formula (-tau) hneg, gate_chaos_abs_formula tau h, absRat_neg]

/-- Sample evenness check. -/
theorem gate_even_sample : gate (-1 / 10) = gate (1 / 10) := by
  native_decide

/-- Outside chaos, anti-sync and stable are opposite signs (samples). -/
theorem gate_extreme_opposite_sample : gate (3 / 4) = -(gate (-3 / 4)) := by
  native_decide

/--
  RECD depth scaling factor δ^{-k} as iterated division of 1 by δ.
-/
def deltaInvPow : Nat → Rat
  | 0 => 1
  | k + 1 => deltaInvPow k / ((feigenbaumDeltaNum : Rat) / (feigenbaumDeltaDen : Rat))

theorem deltaInvPow_zero : deltaInvPow 0 = 1 := rfl

theorem deltaInvPow_one :
    deltaInvPow 1 = (feigenbaumDeltaDen : Rat) / (feigenbaumDeltaNum : Rat) := by
  simp [deltaInvPow]
  ring

theorem deltaInvPow_succ (k : Nat) :
    deltaInvPow (k + 1) =
      deltaInvPow k * ((feigenbaumDeltaDen : Rat) / (feigenbaumDeltaNum : Rat)) := by
  simp [deltaInvPow]
  field_simp
  ring

/-- Increment skeleton Δt ∝ δ^{-k} · |τ| (unit dt0=1, w=1). -/
def deltaT_unit (tau : Rat) (k : Nat) : Rat :=
  deltaInvPow k * absRat tau

theorem deltaT_unit_zero_depth (tau : Rat) : deltaT_unit tau 0 = absRat tau := by
  simp [deltaT_unit, deltaInvPow]

/-- Tick contribution g(τ)·Δt_unit. -/
def recdTick_unit (tau : Rat) (k : Nat) : Rat :=
  gate tau * deltaT_unit tau k

/-- In stable regime, |τ| does not drive chaotic Δt depth runs (gate=1 but k=0 by ops). -/
theorem recdTick_stable_unit (k : Nat) : recdTick_unit (3 / 4) k = deltaT_unit (3 / 4) k := by
  simp [recdTick_unit, gate_stable_pos]

/-- [TEOREMA] Stable classification ⇒ gate = +1. -/
theorem gate_of_stable (tau : Rat) (h : tau ≥ tauStable) : gate tau = 1 := by
  simp [gate, h]

/-- [TEOREMA] Anti-sync classification ⇒ gate = -1. -/
theorem gate_of_antiSync (tau : Rat) (h : tau ≤ -tauChaos) : gate tau = -1 := by
  have h_not_stable : ¬ tau ≥ tauStable := by
    intro hs
    have : tauStable ≤ -tauChaos := le_trans hs h
    exact (not_le_of_gt (by native_decide : (-tauChaos : Rat) < tauStable)) this
  have h_not_chaos : ¬ absRat tau < tauChaos := by
    intro habs
    -- |τ| < τ_ch and τ ≤ -τ_ch ⇒ |τ| ≥ τ_ch when τ ≤ 0
    have hnonpos : tau ≤ 0 := le_trans h (by native_decide : (-tauChaos : Rat) ≤ 0)
    have : absRat tau = -tau := absRat_of_nonpos hnonpos
    have : -tau < tauChaos := by simpa [this] using habs
    have : -tauChaos < tau := by linarith
    exact (not_lt_of_ge h) this
  simp [gate, h_not_stable, h_not_chaos, h]

/-- Consistency samples: classify ↔ gate sign pattern. -/
theorem classify_gate_stable_sample :
    classify (3 / 4) = Regime.stable ∧ gate (3 / 4) = 1 := by
  native_decide

theorem classify_gate_anti_sample :
    classify (-3 / 4) = Regime.antiSync ∧ gate (-3 / 4) = -1 := by
  native_decide

theorem classify_gate_inter_sample :
    classify (45 / 100) = Regime.intermediate ∧ gate (45 / 100) = 0 := by
  native_decide

end SystemicTau
