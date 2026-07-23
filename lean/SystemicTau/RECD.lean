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

end SystemicTau
