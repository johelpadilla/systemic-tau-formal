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

theorem absRat_nonneg (q : Rat) : 0 ≤ absRat q := by
  simp only [absRat]
  split_ifs with h
  · exact h
  · -- q < 0 ⇒ -q > 0
    have : q < 0 := lt_of_not_ge h
    exact le_of_lt (neg_pos.mpr this)

/-- Gate function g(τₛ) on ℚ. [OPERACIONAL] -/
def gate (tau : Rat) : Rat :=
  if tau ≥ tauStable then 1
  else if absRat tau < tauChaos then
    gatePrefactor * (tauChaos - absRat tau) / tauChaos
  else if tau ≤ -tauChaos then -1
  else 0

/-- Stable regime opens the gate positively. -/
theorem gate_stable_pos : gate (3 / 4) = 1 := by
  native_decide

/-- Strong anti-synchronization opens the gate negatively. -/
theorem gate_anti_neg : gate (-3 / 4) = -1 := by
  native_decide

/-- Intermediate band (between 0.41 and 0.50) keeps gate closed. -/
theorem gate_intermediate_zero : gate (45 / 100) = 0 := by
  native_decide

/-- Center of chaotic band: g(0) = (δ−1)/δ. -/
theorem gate_at_zero : gate 0 = gatePrefactor := by
  native_decide

/-- Chaotic-band gate is nonnegative when |τ| < τ_ch (at τ = 0). -/
theorem gate_chaos_center_nonneg : 0 ≤ gate 0 := by
  native_decide

/--
  RECD depth scaling factor δ^{-k} as iterated division of 1 by δ.
  For k = 1 this is 1/δ.
-/
def deltaInvPow : Nat → Rat
  | 0 => 1
  | k + 1 => deltaInvPow k / ((feigenbaumDeltaNum : Rat) / (feigenbaumDeltaDen : Rat))

theorem deltaInvPow_zero : deltaInvPow 0 = 1 := rfl

theorem deltaInvPow_one :
    deltaInvPow 1 = (feigenbaumDeltaDen : Rat) / (feigenbaumDeltaNum : Rat) := by
  simp [deltaInvPow]
  ring

/-- Increment skeleton Δt ∝ δ^{-k} · |τ| · dt0 / w  (unit dt0=1, w=1). -/
def deltaT_unit (tau : Rat) (k : Nat) : Rat :=
  deltaInvPow k * absRat tau

theorem deltaT_unit_zero_depth (tau : Rat) : deltaT_unit tau 0 = absRat tau := by
  simp [deltaT_unit, deltaInvPow]

end SystemicTau
