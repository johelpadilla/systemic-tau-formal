/-
  Operational bands for τₛ and open derivation from δ.

  [OPERACIONAL] τ_st = 1/2, τ_ch ≈ 0.41 as rational 41/100
  [CONJETURA] Closed-form derivation of thresholds from δ alone
  [TEOREMA] (target) Machine-checked chain δ ⇝ thresholds in g
-/
import SystemicTau.Basic

namespace SystemicTau

/-- Stability threshold τ_st = 1/2. [OPERACIONAL] -/
def tauStable : Rat := 1 / 2

/-- Chaotic-band half-width τ_ch = 41/100. [OPERACIONAL] -/
def tauChaos : Rat := 41 / 100

/-- Classify a rational τₛ. [OPERACIONAL] -/
def classify (tau : Rat) : Regime :=
  if tau ≥ tauStable then Regime.stable
  else if tau > -tauChaos ∧ tau < tauChaos then Regime.chaotic
  else if tau ≤ -tauChaos then Regime.antiSync
  else Regime.intermediate

/-- Gate prefactor (δ − 1)/δ as rational from integer approximation. -/
def gatePrefactor : Rat :=
  (feigenbaumDeltaNum - feigenbaumDeltaDen) / feigenbaumDeltaNum

/--
  [CONJETURA] Universal thresholds determined by δ without dataset fit.
  Proof obligation deferred — placeholder holds trivially.
-/
theorem thresholds_from_delta_open : True := trivial

theorem tauStable_eq : tauStable = (1 : Rat) / 2 := rfl

theorem tauChaos_eq : tauChaos = (41 : Rat) / 100 := rfl

end SystemicTau
