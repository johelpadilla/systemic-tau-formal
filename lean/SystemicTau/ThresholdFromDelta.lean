/-
  Unique operational bridge f(δ) relating Feigenbaum δ to band thresholds.

  Epistemic posture
  -----------------
  [OPERACIONAL]  τ_st = 1/2, τ_ch = 41/100 are protocol pins.
  [TEOREMA]      Uniqueness of the *inverse-scale* bridge
                   f(δ) = c / δ
                 with c fixed by f(δ_op) = τ_ch; monotonicity; band partition
                 compatibility; comparison with the failed simple candidate 2/δ.
  [CONJETURA]    Classical dynamical derivation of τ_ch from pure Feigenbaum
                 renormalization (no free c) remains open — see
                 `classical_threshold_from_delta_open`.

  Ingredients used
  ----------------
  · Feigenbaum scaling: operational δ_op; geometric ratios ≡ δ (cited);
  · Gate prefactor (δ−1)/δ; verified gate antitonicity on the chaos band;
  · Core τₛ partition (nonneg trichotomy of regimes);
  · Four-level ontology tags (L0–L3) for claim siting.

  This module does **not** claim that 0.41 is forced by Feigenbaum theory alone.
  It forces uniqueness *inside* the inverse-homogeneous class pinned at δ_op.
-/
import SystemicTau.Basic
import SystemicTau.Thresholds
import SystemicTau.RECD
import SystemicTau.Ontology
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Positivity

namespace SystemicTau.ThresholdFromDelta

open SystemicTau
open SystemicTau.Ontology

/-! ### L0 / L1 anchors (observational + metric) -/

/--
  [OPERACIONAL · L1 metric]
  Stable threshold is the positive midpoint of the Kendall range \([-1,1]\).
  Independent of δ: ordinal coherence saturates at half-scale of the metric.
-/
def tauStableOfDelta (_δ : Rat) : Rat := 1 / 2

theorem tauStableOfDelta_eq (δ : Rat) : tauStableOfDelta δ = tauStable := by
  simp [tauStableOfDelta, tauStable]

theorem tauStableOfDelta_eq_half (δ : Rat) : tauStableOfDelta δ = (1 : Rat) / 2 := rfl

/--
  [OPERACIONAL · L1]
  Operational chaotic half-width pin.
-/
def tauChaosOp : Rat := tauChaos

theorem tauChaosOp_eq : tauChaosOp = (41 : Rat) / 100 := tauChaos_eq

/-! ### Inverse-scale bridge class (Feigenbaum length scaling ∝ 1/δ) -/

/--
  Inverse-homogeneous bridge: \(f(\delta) = c / \delta\).

  Motivation (L2 dynamical, scaling): period-doubling ratios approach δ, so
  successive length scales contract by \(1/\delta\). Maps of the form \(c/\delta\)
  are the unique degree-\((-1)\) homogeneous candidates on \(\mathbb{Q}_{>0}\).
-/
structure InverseScaleBridge where
  /-- Homogeneous constant (scale). -/
  c : Rat
  /-- Positivity of the scale (chaos half-width must be positive). -/
  c_pos : 0 < c

/-- Evaluate the bridge at a positive δ. -/
def InverseScaleBridge.eval (F : InverseScaleBridge) (δ : Rat) : Rat :=
  F.c / δ

/--
  The unique scale that matches operational τ_ch at operational δ_op:
  \(c_\star = \tau_{\mathrm{ch}} \cdot \delta_{\mathrm{op}}\).
-/
def cStar : Rat := tauChaos * feigenbaumDeltaOp

theorem cStar_pos : (0 : Rat) < cStar := by
  have hτ : (0 : Rat) < tauChaos := by native_decide
  have hδ : (0 : Rat) < feigenbaumDeltaOp := by native_decide
  exact mul_pos hτ hδ

/-- Canonical inverse-scale bridge pinned by the operational pair. -/
def fDeltaBridge : InverseScaleBridge where
  c := cStar
  c_pos := cStar_pos

/--
  [TEOREMA · L1/L2]
  The unique operational bridge \(f_\delta\):
  \(f(\delta) = (\tau_{\mathrm{ch}} \cdot \delta_{\mathrm{op}}) / \delta\).
-/
def fDelta (δ : Rat) : Rat := fDeltaBridge.eval δ

theorem fDelta_def (δ : Rat) : fDelta δ = cStar / δ := rfl

theorem fDelta_def' (δ : Rat) :
    fDelta δ = (tauChaos * feigenbaumDeltaOp) / δ := by
  rfl

theorem feigenbaumDeltaOp_ne_zero : feigenbaumDeltaOp ≠ 0 := by
  native_decide

/-! ### Uniqueness of the scale constant -/

/--
  [TEOREMA] Uniqueness of \(c\) in the inverse-scale class.

  If \(c / \delta_{\mathrm{op}} = \tau_{\mathrm{ch}}\) and \(\delta_{\mathrm{op}} \ne 0\),
  then \(c = c_\star\).
-/
theorem unique_scale_constant
    (c : Rat) (hδ : feigenbaumDeltaOp ≠ 0)
    (hmatch : c / feigenbaumDeltaOp = tauChaos) :
    c = cStar := by
  -- Multiply both sides of the match by δ_op
  have hmul : (c / feigenbaumDeltaOp) * feigenbaumDeltaOp =
      tauChaos * feigenbaumDeltaOp := by
    rw [hmatch]
  have hcancel : (c / feigenbaumDeltaOp) * feigenbaumDeltaOp = c :=
    div_mul_cancel₀ c hδ
  -- c = τ_ch * δ_op = c⋆
  calc
    c = (c / feigenbaumDeltaOp) * feigenbaumDeltaOp := hcancel.symm
    _ = tauChaos * feigenbaumDeltaOp := hmul
    _ = cStar := by rfl

/-- Specialization: matching at δ_op forces c = c⋆. -/
theorem unique_scale_constant_op (c : Rat)
    (hmatch : c / feigenbaumDeltaOp = tauChaos) :
    c = cStar :=
  unique_scale_constant c feigenbaumDeltaOp_ne_zero hmatch

/--
  [TEOREMA] Uniqueness of the bridge *as a function* on the positive ray,
  among inverse-scale maps that hit τ_ch at δ_op.
-/
theorem unique_inverse_scale_bridge
    (F : InverseScaleBridge)
    (hmatch : F.eval feigenbaumDeltaOp = tauChaos) :
    F.c = fDeltaBridge.c := by
  change F.c / feigenbaumDeltaOp = tauChaos at hmatch
  simpa [fDeltaBridge] using unique_scale_constant_op F.c hmatch

theorem unique_inverse_scale_bridge_eval
    (F : InverseScaleBridge)
    (hmatch : F.eval feigenbaumDeltaOp = tauChaos)
    (δ : Rat) :
    F.eval δ = fDelta δ := by
  have hc : F.c = fDeltaBridge.c := unique_inverse_scale_bridge F hmatch
  simp only [InverseScaleBridge.eval, fDelta, hc]

/-! ### Pinning: f(δ_op) = τ_ch and failed 2/δ -/

/--
  [TEOREMA] The operational bridge recovers τ_ch exactly at δ_op.
-/
theorem fDelta_at_op : fDelta feigenbaumDeltaOp = tauChaos := by
  -- (τ_ch * δ_op) / δ_op = τ_ch
  have hδ : feigenbaumDeltaOp ≠ 0 := feigenbaumDeltaOp_ne_zero
  rw [fDelta_def', mul_comm tauChaos]
  exact mul_div_cancel_left₀ tauChaos hδ

/--
  [TEOREMA] Recover the failed simple candidate: the inverse-scale map with
  c = 2 is exactly 2/δ, already known ≠ τ_ch at δ_op.
-/
def twoOverDeltaBridge : InverseScaleBridge where
  c := 2
  c_pos := by native_decide

theorem twoOverDeltaBridge_eval (δ : Rat) :
    twoOverDeltaBridge.eval δ = (2 : Rat) / δ :=
  rfl

/-- 2/δ_op equals the operational `twoOverDelta` candidate. -/
theorem two_div_deltaOp_eq_twoOverDelta :
    (2 : Rat) / feigenbaumDeltaOp = twoOverDelta := by
  native_decide

theorem twoOverDelta_eq_eval_op :
    twoOverDeltaBridge.eval feigenbaumDeltaOp = twoOverDelta := by
  rw [twoOverDeltaBridge_eval, two_div_deltaOp_eq_twoOverDelta]

theorem twoOverDeltaBridge_ne_fDelta :
    twoOverDeltaBridge.eval feigenbaumDeltaOp ≠
      fDelta feigenbaumDeltaOp := by
  rw [twoOverDelta_eq_eval_op, fDelta_at_op]
  exact twoOverDelta_ne_tauChaos

/-- c⋆ ≠ 2 (equivalently 2/δ_op ≠ τ_ch). -/
theorem cStar_ne_two : cStar ≠ 2 := by
  intro h
  have hne := twoOverDelta_ne_tauChaos
  -- twoOverDelta = 2/δ_op and τ_ch = cStar/δ_op
  have h2 : twoOverDelta = (2 : Rat) / feigenbaumDeltaOp :=
    two_div_deltaOp_eq_twoOverDelta.symm
  have hτ : tauChaos = cStar / feigenbaumDeltaOp := by
    have := fDelta_at_op
    -- fDelta δ_op = cStar/δ_op = τ_ch
    simpa [fDelta_def] using this.symm
  rw [h2, hτ, h] at hne
  exact hne rfl

/-! ### Monotonicity (scaling ⇒ larger δ ⇒ narrower chaos band) -/

/--
  [TEOREMA] On \(\delta > 0\), \(f\) is strictly antitone:
  larger Feigenbaum scale ⇒ smaller chaos half-width under inverse scaling.
-/
theorem fDelta_antitone
    {δ₁ δ₂ : Rat} (h1 : 0 < δ₁) (h12 : δ₁ < δ₂) :
    fDelta δ₂ < fDelta δ₁ := by
  have h2 : 0 < δ₂ := lt_trans h1 h12
  have hc : 0 < cStar := cStar_pos
  -- c/δ₂ < c/δ₁ ⇔ c * δ₁ < c * δ₂  (positive denominators)
  have hdiv : cStar / δ₂ < cStar / δ₁ := by
    exact div_lt_div_of_pos_left hc h1 h12
  simpa [fDelta_def] using hdiv

theorem fDelta_pos {δ : Rat} (hδ : 0 < δ) : 0 < fDelta δ := by
  have hc : 0 < cStar := cStar_pos
  exact div_pos hc hδ

/-- Operational δ lies in (4,5); f is positive there. -/
theorem fDelta_op_pos : 0 < fDelta feigenbaumDeltaOp := by
  rw [fDelta_at_op]
  native_decide

/-! ### Threshold pair and uniqueness under the operational pin class -/

/--
  A threshold pair (stable edge, chaos half-width).
-/
structure ThresholdPair where
  tau_st : Rat
  tau_ch : Rat
  chaos_pos : 0 < tau_ch
  chaos_lt_stable : tau_ch < tau_st

/-- Operational pair (1/2, 41/100). -/
def operationalPair : ThresholdPair where
  tau_st := tauStable
  tau_ch := tauChaos
  chaos_pos := by native_decide
  chaos_lt_stable := tauChaos_lt_tauStable

/--
  Admissible operational threshold assignment relative to δ_op:
  · stable edge fixed at 1/2;
  · chaos edge realized by an inverse-scale bridge matching τ_ch at δ_op.
-/
structure AdmissibleThresholds where
  bridge : InverseScaleBridge
  /-- Match operational chaos pin at δ_op. -/
  match_chaos : bridge.eval feigenbaumDeltaOp = tauChaos
  /-- Stable anchor is the Kendall mid. -/
  stable_anchor : tauStableOfDelta feigenbaumDeltaOp = tauStable

/-- Canonical admissible assignment. -/
def canonicalThresholds : AdmissibleThresholds where
  bridge := fDeltaBridge
  match_chaos := fDelta_at_op
  stable_anchor := tauStableOfDelta_eq feigenbaumDeltaOp

/--
  [TEOREMA] Uniqueness of the admissible assignment:
  every `AdmissibleThresholds` uses the same bridge constant c⋆ and the same
  stable edge, hence induces the same pair (1/2, 41/100) at δ_op.
-/
theorem unique_admissible_bridge (A : AdmissibleThresholds) :
    A.bridge.c = cStar := by
  simpa [cStar, fDeltaBridge] using unique_inverse_scale_bridge A.bridge A.match_chaos

theorem unique_admissible_eval (A : AdmissibleThresholds) (δ : Rat) :
    A.bridge.eval δ = fDelta δ :=
  unique_inverse_scale_bridge_eval A.bridge A.match_chaos δ

theorem unique_admissible_pair_at_op (A : AdmissibleThresholds) :
    A.bridge.eval feigenbaumDeltaOp = operationalPair.tau_ch ∧
    tauStableOfDelta feigenbaumDeltaOp = operationalPair.tau_st := by
  constructor
  · simpa [operationalPair] using A.match_chaos
  · simpa [operationalPair] using A.stable_anchor

/--
  [TEOREMA] The operational pair is the unique value of
  \((\tau_{\mathrm{st}}(\delta_{\mathrm{op}}), f(\delta_{\mathrm{op}}))\)
  over the admissible class.
-/
theorem unique_operational_thresholds (A : AdmissibleThresholds) :
    (tauStableOfDelta feigenbaumDeltaOp, A.bridge.eval feigenbaumDeltaOp) =
      (tauStable, tauChaos) := by
  ext
  · exact A.stable_anchor
  · exact A.match_chaos

/-! ### Threshold pair at δ_op (inhabited cleanly) -/

/-- Thresholds recovered from δ_op via the unique bridge. -/
def thresholdsAtOp : ThresholdPair where
  tau_st := tauStableOfDelta feigenbaumDeltaOp
  tau_ch := fDelta feigenbaumDeltaOp
  chaos_pos := by
    rw [fDelta_at_op]
    native_decide
  chaos_lt_stable := by
    rw [fDelta_at_op, tauStableOfDelta_eq]
    exact tauChaos_lt_tauStable

theorem thresholdsAtOp_eq_operational :
    thresholdsAtOp.tau_st = tauStable ∧ thresholdsAtOp.tau_ch = tauChaos := by
  constructor
  · exact tauStableOfDelta_eq feigenbaumDeltaOp
  · exact fDelta_at_op

/-! ### Compatibility with core τₛ partition and gate monotonicity -/

/--
  [TEOREMA · L1] Nonneg trichotomy still holds for the recovered thresholds
  (they equal the operational pins).
-/
theorem classify_nonneg_trichotomy_from_delta
    (tau : Rat) (h0 : 0 ≤ tau) :
    (tau < thresholdsAtOp.tau_ch ∧ classify tau = Regime.chaotic) ∨
    (thresholdsAtOp.tau_ch ≤ tau ∧ tau < thresholdsAtOp.tau_st ∧
      classify tau = Regime.intermediate) ∨
    (thresholdsAtOp.tau_st ≤ tau ∧ classify tau = Regime.stable) := by
  have hst : thresholdsAtOp.tau_st = tauStable := (thresholdsAtOp_eq_operational).1
  have hch : thresholdsAtOp.tau_ch = tauChaos := (thresholdsAtOp_eq_operational).2
  simpa [hst, hch] using classify_nonneg_trichotomy tau h0

/--
  [TEOREMA · L1] Gate antitonicity on the chaos band is compatible with
  thresholds recovered from δ (same pins).
-/
theorem gate_antitone_from_delta
    (a b : Rat)
    (ha0 : 0 ≤ a) (hab : a ≤ b) (hb : b < thresholdsAtOp.tau_ch) :
    gate b ≤ gate a := by
  have hch : thresholdsAtOp.tau_ch = tauChaos := (thresholdsAtOp_eq_operational).2
  rw [hch] at hb
  exact gate_antitone_on_nonneg_chaos a b ha0 hab hb

/--
  [TEOREMA] On the chaos band of the recovered pair, the gate uses the
  Feigenbaum prefactor \((\delta-1)/\delta\).
-/
theorem gate_uses_feigenbaum_prefactor
    (tau : Rat) (h0 : 0 ≤ tau) (h1 : tau < thresholdsAtOp.tau_ch) :
    gate tau = gatePrefactor * (tauChaos - tau) / tauChaos := by
  have hch : thresholdsAtOp.tau_ch = tauChaos := (thresholdsAtOp_eq_operational).2
  rw [hch] at h1
  exact gate_chaos_nonneg_formula tau h0 h1

/-! ### Relation to geometric Feigenbaum scaling (interface) -/

/--
  [TEOREMA · bookkeeping · L2]
  Scaling interpretation: \(f(\delta) = \kappa \cdot (2/\delta)\) with constant
  \(\kappa = c_\star / 2 = \tau_{\mathrm{ch}} \cdot \delta_{\mathrm{op}} / 2\).
  So the operational chaos edge is a fixed multiple of the simple candidate 2/δ.
-/
def kappa : Rat := cStar / 2

theorem fDelta_eq_kappa_two_over (δ : Rat) (_hδ : δ ≠ 0) :
    fDelta δ = kappa * ((2 : Rat) / δ) := by
  -- cStar/δ = (cStar/2) * (2/δ)
  simp only [fDelta_def, kappa]
  ring

theorem kappa_eq :
    kappa = tauChaos * feigenbaumDeltaOp / 2 := by
  rfl

/-- At δ_op: f = κ · (2/δ_op) and 2/δ_op = twoOverDelta. -/
theorem fDelta_op_eq_kappa_twoOverDelta :
    fDelta feigenbaumDeltaOp = kappa * twoOverDelta := by
  have hδ : feigenbaumDeltaOp ≠ 0 := feigenbaumDeltaOp_ne_zero
  have h := fDelta_eq_kappa_two_over feigenbaumDeltaOp hδ
  rw [two_div_deltaOp_eq_twoOverDelta] at h
  exact h

/-- κ < 1 because 2/δ_op > τ_ch. -/
theorem kappa_lt_one : kappa < 1 := by
  native_decide

/-! ### Ontology siting (4 levels) -/

/-- L0 observational claim: ranks / samples feed τₛ (interface only). -/
def claim_L0_ranks : Claim where
  text := "Ordinal ranks and sliding windows produce τₛ samples in [-1,1]"
  level := Level.observational
  avoids := [TrilemmaHorn.dogmatism]

/-- L1 metric claim: unique inverse-scale bridge pinned at (δ_op, τ_ch). -/
def claim_L1_bridge : Claim where
  text :=
    "Unique f(δ)=c/δ with f(δ_op)=τ_ch; τ_st=1/2 independent of δ; \
partition and gate antitonicity hold for the recovered pair"
  level := Level.metric
  avoids := [TrilemmaHorn.circularity, TrilemmaHorn.infiniteRegress]

/-- L2 dynamical claim: inverse scale motivated by Feigenbaum length ratios. -/
def claim_L2_scaling : Claim where
  text :=
    "Period-doubling ratios → δ motivates inverse-homogeneous bridges; \
κ-scaled 2/δ recovers operational τ_ch without equating τ_ch to 2/δ"
  level := Level.dynamical
  avoids := [TrilemmaHorn.dogmatism]

/-- L3 ontological claim: band architecture is not pure L3 free stipulation. -/
def claim_L3_siting : Claim where
  text :=
    "Thresholds are sited at L1 with L2 scaling motivation; L3 time/ascent \
claims must not redefine τ_ch without L0–L2 contact"
  level := Level.ontological
  avoids := [TrilemmaHorn.dogmatism, TrilemmaHorn.circularity]

/-- Registry of the four-level claim package for this module. -/
def ontologyPackage : List Claim :=
  [claim_L0_ranks, claim_L1_bridge, claim_L2_scaling, claim_L3_siting]

theorem ontologyPackage_levels :
    ontologyPackage.map Claim.level =
      [Level.observational, Level.metric, Level.dynamical, Level.ontological] :=
  rfl

/-- [TEOREMA · bookkeeping] The f(δ) claim registry is stratified L0–L3. -/
theorem ontologyPackage_stratified : stratifiedFour ontologyPackage := by
  simp only [stratifiedFour, ontologyPackage_levels, allLevels]

theorem ontology_architecture_ok : architectureAvoidsTrilemma := architecture_spec

theorem ontologyPackage_each_wellSited :
    ∀ c ∈ ontologyPackage, c.wellSited := by
  intro c hc
  exact c.wellSited_of

/-! ### Residual open classical derivation (honest) -/

/--
  [CONJETURA · L2 research-scale]
  There is **no** free scale constant: classical Feigenbaum renormalization
  alone determines τ_ch without operational pin.

  Status: **open**. Lab uniqueness above is *conditional* on the inverse-scale
  class + pin f(δ_op)=τ_ch. Do not discharge with `trivial` disguised as dynamics.
-/
def ClassicalThresholdFromDelta : Prop :=
  ∃ f : Rat → Rat,
    (∀ δ₁ δ₂ : Rat, 0 < δ₁ → δ₁ < δ₂ → f δ₂ < f δ₁) ∧
    (∀ δ : Rat, 0 < δ → 0 < f δ ∧ f δ < (1 : Rat) / 2) ∧
    -- no free operational τ_ch in the *definition* of f — only δ
    f feigenbaumDeltaOp = tauChaos ∧
    -- and f arises from a pure scaling law with universal numerator  (placeholder shape)
    (∀ δ : Rat, δ ≠ 0 → f δ = (2 : Rat) / δ)
    -- the last conjunct is intentionally the *failed* simple candidate shape,
    -- so this Prop is false (see theorem below) — documenting that "pure 2/δ"
    -- does not work. A genuine classical derivation would replace the last
    -- conjunct by a renormalization construction.

/--
  [TEOREMA · honesty] The naive classical shape f(δ)=2/δ does **not** recover
  τ_ch. Blocks false discharge of `ClassicalThresholdFromDelta` as stated.
-/
theorem classical_naive_two_over_delta_fails :
    ¬ ClassicalThresholdFromDelta := by
  intro ⟨f, _hmono, _hband, hmatch, hshape⟩
  have hδ : feigenbaumDeltaOp ≠ 0 := feigenbaumDeltaOp_ne_zero
  have hf : f feigenbaumDeltaOp = (2 : Rat) / feigenbaumDeltaOp :=
    hshape feigenbaumDeltaOp hδ
  have : twoOverDelta = tauChaos := by
    calc
      twoOverDelta = (2 : Rat) / feigenbaumDeltaOp :=
        two_div_deltaOp_eq_twoOverDelta.symm
      _ = f feigenbaumDeltaOp := hf.symm
      _ = tauChaos := hmatch
  exact twoOverDelta_ne_tauChaos this

/--
  Named residual: unique *operational* bridge is proved; unique *classical*
  derivation without pin is open. Marker equals `True` only as a bookkeeping
  placeholder for issue trackers — not a dynamical theorem.
-/
theorem operational_bridge_closed : True := trivial

/-- Tracker alias (formerly empty open goal). -/
theorem thresholds_from_delta_unique_in_class :
    (∀ A : AdmissibleThresholds,
      (tauStableOfDelta feigenbaumDeltaOp, A.bridge.eval feigenbaumDeltaOp) =
        (tauStable, tauChaos)) ∧
    fDelta feigenbaumDeltaOp = tauChaos ∧
    cStar ≠ 2 :=
  ⟨unique_operational_thresholds, fDelta_at_op, cStar_ne_two⟩

end SystemicTau.ThresholdFromDelta
