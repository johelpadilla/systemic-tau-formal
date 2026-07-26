/-
  CT-4A / CT-4B: ordinal entropy production Σ^RECD.

  Module CT (docs/RECD_vs_Thermodynamic_Time.md), Statement CT-4.
  [TEOREMA] — elementary arithmetic on RECD ticks:
    ΔT⁺ := max(ΔT, 0),  ΔT⁻ := max(−ΔT, 0),
    Σ_n := ΔT⁺ + α·ΔT⁻  (α ∈ [0,1]),
    Σ_N := ∑_{n<N} Σ_n.

  Note on sign: the module case form is
    Σ = ΔT if ΔT ≥ 0,  Σ = −α·ΔT if ΔT < 0
  which is equivalent to ΔT⁺ + α·ΔT⁻ (not ΔT⁺ − α·ΔT⁻).
  The minus in some informal writeups is a typesetting slip relative to
  “nonnegativity by construction” and the SL-RECD interpretation.

  Scope: discrete sequences on ℚ. No immersion mesh, no σ_cl comparison (CT-4C).
-/
import SystemicTau.RECD_Monotonicity

namespace SystemicTau

/-! ### Positive / negative parts on ℚ -/

/-- [OPERACIONAL] Positive part: max(q, 0). -/
def posPart (q : Rat) : Rat := if q ≥ 0 then q else 0

/-- [OPERACIONAL] Negative part: max(−q, 0). -/
def negPart (q : Rat) : Rat := if q ≥ 0 then 0 else -q

/-- [TEOREMA] posPart ≥ 0. -/
theorem posPart_nonneg (q : Rat) : 0 ≤ posPart q := by
  simp only [posPart]
  split_ifs with h
  · exact h
  · exact le_rfl

/-- [TEOREMA] negPart ≥ 0. -/
theorem negPart_nonneg (q : Rat) : 0 ≤ negPart q := by
  simp only [negPart]
  split_ifs with h
  · exact le_rfl
  · have hlt : q < 0 := lt_of_not_ge h
    exact le_of_lt (neg_pos.mpr hlt)

/-- [TEOREMA] q = posPart q − negPart q. -/
theorem posPart_sub_negPart (q : Rat) : posPart q - negPart q = q := by
  simp only [posPart, negPart]
  split_ifs with h
  · simp
  · ring

/-- [TEOREMA] |q| = posPart q + negPart q. -/
theorem absRat_eq_posPart_add_negPart (q : Rat) :
    absRat q = posPart q + negPart q := by
  simp only [absRat, posPart, negPart]
  split_ifs with h <;> ring

/-- [TEOREMA] If q ≥ 0 then posPart q = q and negPart q = 0. -/
theorem posPart_of_nonneg {q : Rat} (h : 0 ≤ q) :
    posPart q = q ∧ negPart q = 0 := by
  simp [posPart, negPart, h]

/-- [TEOREMA] If q ≤ 0 then posPart q = 0 and negPart q = −q. -/
theorem negPart_of_nonpos {q : Rat} (h : q ≤ 0) :
    posPart q = 0 ∧ negPart q = -q := by
  simp only [posPart, negPart]
  by_cases hge : q ≥ 0
  · have : q = 0 := le_antisymm h hge
    simp [this]
  · simp [hge]

/-- [TEOREMA] posPart q = 0 when q ≤ 0. -/
theorem posPart_eq_zero_of_nonpos {q : Rat} (h : q ≤ 0) : posPart q = 0 :=
  (negPart_of_nonpos h).1

/-- [TEOREMA] negPart q = 0 when q ≥ 0. -/
theorem negPart_eq_zero_of_nonneg {q : Rat} (h : 0 ≤ q) : negPart q = 0 :=
  (posPart_of_nonneg h).2

/-! ### Ordinal production increment Σ_n -/

/--
  [OPERACIONAL] One-step ordinal entropy production.
  Σ(ΔT; α) := ΔT⁺ + α·ΔT⁻.
  Default protocol uses α ∈ [0,1]; α = 1 charges full reverse mass as |ΔT|.
-/
def ordinalSigmaTick (deltaT alpha : Rat) : Rat :=
  posPart deltaT + alpha * negPart deltaT

/--
  [TEOREMA] Case form of Σ (module CT-4):
  · if ΔT ≥ 0 then Σ = ΔT
  · if ΔT < 0 then Σ = −α·ΔT
-/
theorem ordinalSigmaTick_of_nonneg (deltaT alpha : Rat) (h : 0 ≤ deltaT) :
    ordinalSigmaTick deltaT alpha = deltaT := by
  have hp := posPart_of_nonneg h
  simp only [ordinalSigmaTick, hp.1, hp.2, mul_zero, add_zero]

theorem ordinalSigmaTick_of_neg (deltaT alpha : Rat) (h : deltaT < 0) :
    ordinalSigmaTick deltaT alpha = -alpha * deltaT := by
  have hn := negPart_of_nonpos (le_of_lt h)
  -- pos = 0, neg = −ΔT ⇒ Σ = 0 + α·(−ΔT) = −α·ΔT
  simp only [ordinalSigmaTick, hn.1, hn.2, zero_add]
  ring

/--
  [TEOREMA] CT-4A (tick level):
  for α ≥ 0, the ordinal production increment is nonnegative.
  (The upper bound α ≤ 1 is a protocol constraint, not needed for ≥ 0.)
-/
theorem ordinalSigmaTick_nonneg
    (deltaT alpha : Rat) (hα0 : 0 ≤ alpha) (_hα1 : alpha ≤ 1) :
    0 ≤ ordinalSigmaTick deltaT alpha := by
  by_cases h : 0 ≤ deltaT
  · -- ΔT ≥ 0 ⇒ Σ = ΔT ≥ 0
    rw [ordinalSigmaTick_of_nonneg deltaT alpha h]
    exact h
  · -- ΔT < 0 ⇒ Σ = −α·ΔT = α·|ΔT| ≥ 0
    have hlt : deltaT < 0 := lt_of_not_ge h
    rw [ordinalSigmaTick_of_neg deltaT alpha hlt]
    have hneg : 0 ≤ -deltaT := le_of_lt (neg_pos.mpr hlt)
    have : 0 ≤ alpha * (-deltaT) := mul_nonneg hα0 hneg
    -- −α * deltaT = α * (−deltaT)
    convert this using 1
    ring

/--
  [TEOREMA] α = 1 yields total-variation contribution: Σ = |ΔT|.
-/
theorem ordinalSigmaTick_alpha_one (deltaT : Rat) :
    ordinalSigmaTick deltaT 1 = absRat deltaT := by
  by_cases h : 0 ≤ deltaT
  · rw [ordinalSigmaTick_of_nonneg deltaT 1 h, absRat_of_nonneg h]
  · have hlt : deltaT < 0 := lt_of_not_ge h
    rw [ordinalSigmaTick_of_neg deltaT 1 hlt, absRat_of_nonpos (le_of_lt hlt)]
    ring

/--
  [TEOREMA] α = 0 ignores reverse ticks: Σ = ΔT⁺.
-/
theorem ordinalSigmaTick_alpha_zero (deltaT : Rat) :
    ordinalSigmaTick deltaT 0 = posPart deltaT := by
  simp [ordinalSigmaTick]

/-! ### Cumulative ordinal production Σ_N -/

/--
  [OPERACIONAL] Cumulative ordinal entropy production along a RECD path.
  Σ_0 = 0,  Σ_{n+1} = Σ_n + Σ(ΔT_n; α).
-/
def ordinalSigmaAccum (taus : Nat → Rat) (depths : Nat → Nat) (alpha : Rat) :
    Nat → Rat
  | 0 => 0
  | n + 1 =>
      ordinalSigmaAccum taus depths alpha n +
        ordinalSigmaTick (recdTick_unit (taus n) (depths n)) alpha

theorem ordinalSigmaAccum_zero
    (taus : Nat → Rat) (depths : Nat → Nat) (alpha : Rat) :
    ordinalSigmaAccum taus depths alpha 0 = 0 := rfl

theorem ordinalSigmaAccum_succ
    (taus : Nat → Rat) (depths : Nat → Nat) (alpha : Rat) (n : Nat) :
    ordinalSigmaAccum taus depths alpha (n + 1) =
      ordinalSigmaAccum taus depths alpha n +
        ordinalSigmaTick (recdTick_unit (taus n) (depths n)) alpha := rfl

/--
  [TEOREMA] CT-4A (finite horizon):
  for every path and every α ∈ [0,1], Σ_N^RECD ≥ 0.
-/
theorem ordinalSigmaAccum_nonneg
    (taus : Nat → Rat) (depths : Nat → Nat) (alpha : Rat)
    (hα0 : 0 ≤ alpha) (hα1 : alpha ≤ 1) (N : Nat) :
    0 ≤ ordinalSigmaAccum taus depths alpha N := by
  induction N with
  | zero =>
    exact le_rfl
  | succ N ih =>
    rw [ordinalSigmaAccum_succ]
    exact add_nonneg ih
      (ordinalSigmaTick_nonneg (recdTick_unit (taus N) (depths N)) alpha hα0 hα1)

/-- Convenience: default protocol α = 1. -/
theorem ordinalSigmaAccum_nonneg_alpha_one
    (taus : Nat → Rat) (depths : Nat → Nat) (N : Nat) :
    0 ≤ ordinalSigmaAccum taus depths 1 N :=
  ordinalSigmaAccum_nonneg taus depths 1 (by native_decide) (by native_decide) N

/-! ### CT-4B: stable / nonnegative-gate reduction -/

/--
  [TEOREMA] Nonnegative tick ⇒ reverse mass vanishes.
-/
theorem negPart_tick_of_nonneg (tau : Rat) (k : Nat) (h : 0 ≤ recdTick_unit tau k) :
    negPart (recdTick_unit tau k) = 0 :=
  negPart_eq_zero_of_nonneg h

/--
  [TEOREMA] Under a nonnegative tick, Σ(ΔT; α) = ΔT for any α.
-/
theorem ordinalSigmaTick_eq_tick_of_nonneg
    (deltaT alpha : Rat) (h : 0 ≤ deltaT) :
    ordinalSigmaTick deltaT alpha = deltaT :=
  ordinalSigmaTick_of_nonneg deltaT alpha h

/--
  [TEOREMA] CT-4B (stepwise): if g(τ_n) ≥ 0 then the production step
  coincides with the clock step, independent of α.
-/
theorem ordinalSigmaTick_eq_recdTick_of_gate_nonneg
    (tau : Rat) (k : Nat) (alpha : Rat) (hg : 0 ≤ gate tau) :
    ordinalSigmaTick (recdTick_unit tau k) alpha = recdTick_unit tau k := by
  apply ordinalSigmaTick_of_nonneg
  exact recdTick_unit_nonneg_of_gate_nonneg tau k hg

/--
  [TEOREMA] CT-4B (finite horizon):
  if g(τ_n) ≥ 0 for all n < N, then Σ_N^RECD = T_N − T_0 (= T_N since T_0 = 0).
-/
theorem ordinalSigmaAccum_eq_recdAccum_of_gate_nonneg
    (taus : Nat → Rat) (depths : Nat → Nat) (alpha : Rat) (N : Nat)
    (hg : ∀ n, n < N → 0 ≤ gate (taus n)) :
    ordinalSigmaAccum taus depths alpha N = recdAccum taus depths N := by
  induction N with
  | zero =>
    simp only [ordinalSigmaAccum_zero, recdAccum_zero]
  | succ N ih =>
    rw [ordinalSigmaAccum_succ, recdAccum_succ]
    have hgN : 0 ≤ gate (taus N) := hg N (Nat.lt_succ_self N)
    have hstep :
        ordinalSigmaTick (recdTick_unit (taus N) (depths N)) alpha =
          recdTick_unit (taus N) (depths N) :=
      ordinalSigmaTick_eq_recdTick_of_gate_nonneg (taus N) (depths N) alpha hgN
    have ih' : ordinalSigmaAccum taus depths alpha N = recdAccum taus depths N := by
      apply ih
      intro n hn
      exact hg n (Nat.lt_trans hn (Nat.lt_succ_self N))
    rw [ih', hstep]

/--
  [TEOREMA] CT-4B corollary via τ > −τ_ch (zero samples allowed).
-/
theorem ordinalSigmaAccum_eq_recdAccum_of_gt_neg_chaos
    (taus : Nat → Rat) (depths : Nat → Nat) (alpha : Rat) (N : Nat)
    (hτ : ∀ n, n < N → -tauChaos < taus n) :
    ordinalSigmaAccum taus depths alpha N = recdAccum taus depths N := by
  apply ordinalSigmaAccum_eq_recdAccum_of_gate_nonneg
  intro n hn
  exact gate_nonneg_of_gt_neg_chaos (taus n) (hτ n hn)

/-! ### Anti-sync sample: production stays nonnegative while T decreases -/

/--
  [TEOREMA] On the constant anti-sync path with α = 1,
  Σ_{n+1} > 0 while T is strictly decreasing (CT-2 fragment).
  Structural split: clock can reverse; ordinal production cannot.
-/
theorem ordinalSigmaAccum_constAntiSync_pos (n : Nat) :
    0 < ordinalSigmaAccum constAntiSync constDepth0 1 (n + 1) := by
  -- each anti-sync step contributes |ΔT| > 0 under α = 1
  have hstep_pos (m : Nat) :
      0 < ordinalSigmaTick (recdTick_unit (constAntiSync m) (constDepth0 m)) 1 := by
    have htick : recdTick_unit (constAntiSync m) (constDepth0 m) < 0 := by
      simp only [constAntiSync, constDepth0]
      exact recdTick_constAntiSync_neg 0
    rw [ordinalSigmaTick_alpha_one,
      absRat_of_nonpos (le_of_lt htick)]
    exact neg_pos.mpr htick
  induction n with
  | zero =>
    -- Σ_1 = 0 + Σ(ΔT_0) = |ΔT_0| > 0
    simpa [ordinalSigmaAccum] using hstep_pos 0
  | succ n ih =>
    rw [ordinalSigmaAccum_succ]
    have hprior : 0 ≤ ordinalSigmaAccum constAntiSync constDepth0 1 (n + 1) :=
      le_of_lt ih
    have hstep := hstep_pos (n + 1)
    linarith

/-- Sample: Σ_1 > 0 and T_1 < 0 on the same anti-sync path. -/
theorem ordinal_vs_clock_split_sample :
    0 < ordinalSigmaAccum constAntiSync constDepth0 1 1 ∧
      recdAccum constAntiSync constDepth0 1 < 0 :=
  ⟨by simpa using ordinalSigmaAccum_constAntiSync_pos 0,
    recdAccum_constAntiSync_T1_neg⟩

end SystemicTau
