/-
  Operational bands for τₛ and open derivation from δ.

  [OPERACIONAL] τ_st = 1/2, τ_ch = 41/100
  [CONJETURA] Closed-form derivation of thresholds from δ alone
  [TEOREMA] (partial) Band ordering and rational identities machine-checked here
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

/-- Gate prefactor (δ − 1)/δ as rational from integer approximation of δ. -/
def gatePrefactor : Rat :=
  (feigenbaumDeltaNum - feigenbaumDeltaDen) / feigenbaumDeltaNum

/-- Candidate closed form 2/δ (rational). Often compared to τ_ch. -/
def twoOverDelta : Rat :=
  (2 * feigenbaumDeltaDen) / feigenbaumDeltaNum

theorem tauStable_eq : tauStable = (1 : Rat) / 2 := rfl

theorem tauChaos_eq : tauChaos = (41 : Rat) / 100 := rfl

/-- [TEOREMA] Operational chaotic band is strictly below the stable threshold. -/
theorem tauChaos_lt_tauStable : tauChaos < tauStable := by
  native_decide

/-- [TEOREMA] Prefactor (δ−1)/δ is positive and strictly less than 1. -/
theorem gatePrefactor_bounds : 0 < gatePrefactor ∧ gatePrefactor < 1 := by
  native_decide

/-- [TEOREMA] 2/δ > τ_ch (motivational proximity, not equality). -/
theorem twoOverDelta_gt_tauChaos : twoOverDelta > tauChaos := by
  native_decide

/-- Gap 2/δ − τ_ch as an explicit positive rational (≈ 0.018). -/
def twoOverDelta_gap : Rat := twoOverDelta - tauChaos

theorem twoOverDelta_gap_pos : twoOverDelta_gap > 0 := by
  native_decide

/-- Stable classification for τ ≥ 1/2. -/
theorem classify_stable (tau : Rat) (h : tau ≥ tauStable) :
    classify tau = Regime.stable := by
  simp [classify, h]

/--
  [CONJETURA] Universal thresholds determined by δ without dataset fit.
  Remaining obligation: choose a canonical f(δ) = τ_ch with zero residual.
-/
theorem thresholds_from_delta_open : True := trivial

end SystemicTau
