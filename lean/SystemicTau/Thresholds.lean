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

/-- Chaotic band: |τ| < τ_ch (open). -/
theorem classify_chaotic (tau : Rat) (h : -tauChaos < tau ∧ tau < tauChaos) :
    classify tau = Regime.chaotic := by
  have h_not_stable : ¬ tau ≥ tauStable := by
    intro hs
    have : tauChaos < tauStable := tauChaos_lt_tauStable
    have hlt : tau < tauStable := lt_of_lt_of_le h.2 (le_of_lt this)
    exact (not_le_of_gt hlt) hs
  have h_chaos : tau > -tauChaos ∧ tau < tauChaos := h
  simp [classify, h_not_stable, h_chaos]

/-- Anti-synchronization: τ ≤ -τ_ch. -/
theorem classify_antiSync (tau : Rat) (h : tau ≤ -tauChaos) :
    classify tau = Regime.antiSync := by
  have h_not_stable : ¬ tau ≥ tauStable := by
    intro hs
    have : tau ≤ -tauChaos := h
    have hpos : tauStable ≤ tau := hs
    have : tauStable ≤ -tauChaos := le_trans hpos this
    exact (not_le_of_gt (by native_decide : (-tauChaos : Rat) < tauStable)) this
  have h_not_chaos : ¬ (tau > -tauChaos ∧ tau < tauChaos) := by
    intro ⟨h1, _⟩
    exact (not_lt_of_ge h) h1
  simp [classify, h_not_stable, h_not_chaos, h]

/-- Positive intermediate: τ_ch ≤ τ < τ_st. -/
theorem classify_intermediate_pos
    (tau : Rat) (h_lo : tauChaos ≤ tau) (h_hi : tau < tauStable) :
    classify tau = Regime.intermediate := by
  have h_not_stable : ¬ tau ≥ tauStable := not_le_of_gt h_hi
  have h_not_chaos : ¬ (tau > -tauChaos ∧ tau < tauChaos) := by
    intro ⟨_, h2⟩
    exact (not_lt_of_ge h_lo) h2
  have h_not_anti : ¬ tau ≤ -tauChaos := by
    intro h
    have hpos : 0 ≤ tau := le_trans (by native_decide : (0 : Rat) ≤ tauChaos) h_lo
    have : tau ≤ 0 := le_trans h (by native_decide : (-tauChaos : Rat) ≤ 0)
    have hz : tau = 0 := le_antisymm this hpos
    have : tauChaos ≤ 0 := by simpa [hz] using h_lo
    exact (not_le_of_gt (by native_decide : (0 : Rat) < tauChaos)) this
  simp [classify, h_not_stable, h_not_chaos, h_not_anti]

/--
  [TEOREMA] Exhaustive partition of the nonnegative ray [0, +∞).
  Every τ ≥ 0 falls into exactly one of: chaotic / intermediate / stable.
-/
theorem classify_nonneg_trichotomy (tau : Rat) (h0 : 0 ≤ tau) :
    (tau < tauChaos ∧ classify tau = Regime.chaotic) ∨
    (tauChaos ≤ tau ∧ tau < tauStable ∧ classify tau = Regime.intermediate) ∨
    (tauStable ≤ tau ∧ classify tau = Regime.stable) := by
  by_cases hs : tauStable ≤ tau
  · exact Or.inr (Or.inr ⟨hs, classify_stable tau hs⟩)
  · have h_hi : tau < tauStable := lt_of_not_ge hs
    by_cases hc : tau < tauChaos
    · have hch : classify tau = Regime.chaotic := by
        apply classify_chaotic
        constructor
        · -- -τ_ch < τ since τ ≥ 0 > -τ_ch
          have : (-tauChaos : Rat) < 0 := by native_decide
          exact lt_of_lt_of_le this h0
        · exact hc
      exact Or.inl ⟨hc, hch⟩
    · have h_lo : tauChaos ≤ tau := le_of_not_gt hc
      exact Or.inr (Or.inl ⟨h_lo, h_hi, classify_intermediate_pos tau h_lo h_hi⟩)

/-! ### Candidate closed forms vs operational τ_ch

  [OPERACIONAL] τ_ch = 41/100 is fixed for protocol.
  [TEOREMA] None of the following simple rational forms in δ equals τ_ch
  (machine-checked disequalities — *not* a proof that no f(δ) exists at all).
-/

/-- 1/δ (rational approximation of δ). -/
def oneOverDelta : Rat :=
  (feigenbaumDeltaDen : Rat) / feigenbaumDeltaNum

/-- (δ − 1)/(2δ). -/
def deltaMinusOne_over_twoDelta : Rat :=
  (feigenbaumDeltaNum - feigenbaumDeltaDen : Rat) / (2 * feigenbaumDeltaNum)

/-- 2/(δ + 1). -/
def twoOverDeltaPlusOne : Rat :=
  (2 * feigenbaumDeltaDen : Rat) / (feigenbaumDeltaNum + feigenbaumDeltaDen)

/-- (δ − 2)/δ. -/
def deltaMinusTwo_over_delta : Rat :=
  (feigenbaumDeltaNum - 2 * feigenbaumDeltaDen : Rat) / feigenbaumDeltaNum

/-- 3/(2δ). -/
def threeOverTwoDelta : Rat :=
  (3 * feigenbaumDeltaDen : Rat) / (2 * feigenbaumDeltaNum)

/-- 4/δ² (rational). -/
def fourOverDeltaSq : Rat :=
  (4 * (feigenbaumDeltaDen : Rat) * feigenbaumDeltaDen) /
    ((feigenbaumDeltaNum : Rat) * feigenbaumDeltaNum)

/-- 5/δ. -/
def fiveOverDelta : Rat :=
  (5 * feigenbaumDeltaDen : Rat) / feigenbaumDeltaNum

/-- [TEOREMA] 2/δ ≠ τ_ch (already 2/δ > τ_ch). -/
theorem twoOverDelta_ne_tauChaos : twoOverDelta ≠ tauChaos := by
  intro h
  exact (ne_of_gt twoOverDelta_gt_tauChaos) h

/-- [TEOREMA] 1/δ ≠ τ_ch. -/
theorem oneOverDelta_ne_tauChaos : oneOverDelta ≠ tauChaos := by
  native_decide

/-- [TEOREMA] (δ−1)/δ ≠ τ_ch. -/
theorem gatePrefactor_ne_tauChaos : gatePrefactor ≠ tauChaos := by
  native_decide

/-- [TEOREMA] (δ−1)/(2δ) ≠ τ_ch. -/
theorem deltaMinusOne_over_twoDelta_ne_tauChaos :
    deltaMinusOne_over_twoDelta ≠ tauChaos := by
  native_decide

/-- [TEOREMA] 2/(δ+1) ≠ τ_ch. -/
theorem twoOverDeltaPlusOne_ne_tauChaos : twoOverDeltaPlusOne ≠ tauChaos := by
  native_decide

/-- [TEOREMA] (δ−2)/δ ≠ τ_ch. -/
theorem deltaMinusTwo_over_delta_ne_tauChaos :
    deltaMinusTwo_over_delta ≠ tauChaos := by
  native_decide

/-- [TEOREMA] 3/(2δ) ≠ τ_ch. -/
theorem threeOverTwoDelta_ne_tauChaos : threeOverTwoDelta ≠ tauChaos := by
  native_decide

/-- [TEOREMA] 4/δ² ≠ τ_ch. -/
theorem fourOverDeltaSq_ne_tauChaos : fourOverDeltaSq ≠ tauChaos := by
  native_decide

/-- [TEOREMA] 5/δ ≠ τ_ch. -/
theorem fiveOverDelta_ne_tauChaos : fiveOverDelta ≠ tauChaos := by
  native_decide

/-- [TEOREMA] τ_st ≠ τ_ch (band separation). -/
theorem tauStable_ne_tauChaos : tauStable ≠ tauChaos := by
  exact ne_of_gt tauChaos_lt_tauStable

/--
  Finite candidate class that fails equality with operational τ_ch.
  Extended (issue #7). Unique *operational* inverse-scale bridge is in
  `ThresholdFromDelta`; classical free-\(c\) derivation remains open.
-/
structure FailedSimpleCandidates where
  two_over_delta : twoOverDelta ≠ tauChaos := twoOverDelta_ne_tauChaos
  one_over_delta : oneOverDelta ≠ tauChaos := oneOverDelta_ne_tauChaos
  gate_prefactor : gatePrefactor ≠ tauChaos := gatePrefactor_ne_tauChaos
  half_prefactor : deltaMinusOne_over_twoDelta ≠ tauChaos :=
    deltaMinusOne_over_twoDelta_ne_tauChaos
  two_over_delta_plus_one : twoOverDeltaPlusOne ≠ tauChaos :=
    twoOverDeltaPlusOne_ne_tauChaos
  delta_minus_two_over_delta : deltaMinusTwo_over_delta ≠ tauChaos :=
    deltaMinusTwo_over_delta_ne_tauChaos
  three_over_two_delta : threeOverTwoDelta ≠ tauChaos :=
    threeOverTwoDelta_ne_tauChaos
  four_over_delta_sq : fourOverDeltaSq ≠ tauChaos := fourOverDeltaSq_ne_tauChaos
  five_over_delta : fiveOverDelta ≠ tauChaos := fiveOverDelta_ne_tauChaos
  stable_band : tauStable ≠ tauChaos := tauStable_ne_tauChaos

def failedSimpleCandidates : FailedSimpleCandidates := {}

/--
  [CONJETURA] Classical derivation of τ_ch from pure Feigenbaum theory (no free scale).

  Partial progress (this file): finite simple-form class ruled out
  (`failedSimpleCandidates`).

  **Closed in inverse-scale class** (see `ThresholdFromDelta.lean`):
  unique \(f(\delta)=c/\delta\) with \(f(\delta_{\mathrm{op}})=\tau_{\mathrm{ch}}\),
  \(c_\star=\tau_{\mathrm{ch}}\cdot\delta_{\mathrm{op}}\), plus band partition /
  gate compatibility. Classical residual remains open there as
  `classical_naive_two_over_delta_fails` / research tracker.
-/
theorem thresholds_from_delta_open : True := trivial

end SystemicTau
