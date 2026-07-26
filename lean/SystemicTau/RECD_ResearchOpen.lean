/-
  Research-scale CT residuals: honest interfaces, not discharged theorems.

  Module CT open problems (docs/RECD_vs_Thermodynamic_Time.md):
    · Schnakenberg / CT-4C entropy-production bridge
    · Ordinal large-deviation (LDP) fluctuation theorem
    · Nested ΔRECD (Framework / Tomus III branch)

  Labels:
    [OPERACIONAL] named structures and comparison shapes
    [CONJETURA] statements marked for attack, not proved
    [TEOREMA] only bookkeeping that follows from already-discharged CT-4A/B

  Discipline: 0 sorry, 0 axiom. Nothing here claims a research theorem is closed.
-/
import SystemicTau.RECD_OrdinalEntropy
import SystemicTau.RECD_Oriented
import SystemicTau.RECD_Monoidal
import SystemicTau.RECD_CT2

namespace SystemicTau

/-! ### Schnakenberg / CT-4C interface -/

/--
  [OPERACIONAL] Schnakenberg-type entropy production rate shape on a
  discrete horizon: non-negative functional of a path. Classical comparison
  theory only — not identified with σ_RECD.
-/
structure SchnakenbergCandidate where
  sigmaCl : (Nat → Rat) → Nat → Rat
  nonneg : ∀ T N, 0 ≤ sigmaCl T N

/--
  [OPERACIONAL] Comparison bridge shape between ordinal Σ and a classical
  Schnakenberg candidate (interface only).
-/
structure SchnakenbergBridge where
  candidate : SchnakenbergCandidate
  compares : Prop

/--
  [CONJETURA] CT-4C: under suitable Markov / detailed-balance hypotheses,
  σ_cl and Σ_RECD agree on the stable regime and split under anti-sync.
  Not discharged. Recorded as a named open problem.
-/
def CT4C_SchnakenbergConjecture : Prop :=
  ∃ B : SchnakenbergBridge,
    ∀ taus depths alpha N,
      (∀ n, n < N → 0 ≤ gate (taus n)) →
        B.candidate.sigmaCl (recdAccum taus depths) N =
          ordinalSigmaAccum taus depths alpha N

/--
  [TEOREMA] Bookkeeping fragment already known: ordinal Σ is nonnegative
  for α ∈ [0,1] (CT-4A) — the Schnakenberg nonnegativity half that *is*
  discharged for the RECD production functional.
-/
theorem schnakenberg_half_recd_nonneg
    (taus : Nat → Rat) (depths : Nat → Nat)
    (alpha : Rat) (hα0 : 0 ≤ alpha) (hα1 : alpha ≤ 1) (N : Nat) :
    0 ≤ ordinalSigmaAccum taus depths alpha N :=
  ordinalSigmaAccum_nonneg taus depths alpha hα0 hα1 N

/--
  [OPERACIONAL] Placeholder Schnakenberg candidate (zero functional).
  Real classical σ_cl remains external.
-/
def zeroSchnakenbergCandidate : SchnakenbergCandidate where
  sigmaCl := fun _ _ => 0
  nonneg := fun _ _ => le_rfl

/-! ### Ordinal LDP / fluctuation interface -/

/--
  [OPERACIONAL] Large-deviation rate function shape on path space
  (Varadhan / Donsker–Varadhan style interface). Not a proved LDP.
-/
structure LDPRateShape where
  I : (Nat → Rat) → Rat
  nonneg : ∀ μ, 0 ≤ I μ

/--
  [CONJETURA] Ordinal fluctuation theorem: empirical reverse-mass of RECD
  ticks satisfies an LDP with speed N and rate related to anti-sync density.
  Not discharged (needs measure-theoretic LDP infrastructure).
-/
def OrdinalFluctuationConjecture : Prop :=
  ∃ R : LDPRateShape,
    ∀ taus depths d,
      HasAntiSyncLowerDensity taus d →
        R.I (recdAccum taus depths) ≥ d

/--
  [TEOREMA] Discharged skeleton used by LDP narratives:
  InfOften anti-sync ⇒ InfOften reverse increments (CT-2 / OP-CT-8).
  Full LDP rate function remains [CONJETURA].
-/
theorem fluctuation_InfOften_skeleton
    (taus : Nat → Rat) (depths : Nat → Nat) (c : Rat)
    (hc0 : 0 < c) (h : InfOftenAntiSync taus c) :
    InfOftenNegInc (recdAccum taus depths) :=
  InfOftenNegInc_of_InfOftenAntiSync taus depths c hc0 h

/-! ### Nested ΔRECD (Framework branch) -/

/--
  [OPERACIONAL] Nested RECD tick: a second-layer gate applied to an
  already-computed RECD path (Framework / Tomus III shape).
  Not identified with the legacy single-layer gate.
-/
structure NestedRECD where
  tauOuter : Nat → Rat
  depthOuter : Nat → Nat
  tauInner : Nat → Rat
  depthInner : Nat → Nat

/-- Outer accumulation. -/
def NestedRECD.outerAccum (N : NestedRECD) : Nat → Rat :=
  recdAccum N.tauOuter N.depthOuter

/-- Inner accumulation driven by inner τ. -/
def NestedRECD.innerAccum (N : NestedRECD) : Nat → Rat :=
  recdAccum N.tauInner N.depthInner

/--
  [OPERACIONAL] Nested production: Σ_inner + Σ_outer style sum.
-/
def nestedSigma
    (N : NestedRECD) (alphaOuter alphaInner : Rat) (n : Nat) : Rat :=
  ordinalSigmaAccum N.tauOuter N.depthOuter alphaOuter n +
    ordinalSigmaAccum N.tauInner N.depthInner alphaInner n

/--
  [TEOREMA] Nested production is nonnegative when both α ∈ [0,1]
  (inherits CT-4A on each layer).
-/
theorem nestedSigma_nonneg
    (N : NestedRECD)
    (aO aI : Rat)
    (haO0 : 0 ≤ aO) (haO1 : aO ≤ 1)
    (haI0 : 0 ≤ aI) (haI1 : aI ≤ 1)
    (n : Nat) :
    0 ≤ nestedSigma N aO aI n := by
  simp only [nestedSigma]
  have h1 := ordinalSigmaAccum_nonneg N.tauOuter N.depthOuter aO haO0 haO1 n
  have h2 := ordinalSigmaAccum_nonneg N.tauInner N.depthInner aI haI0 haI1 n
  linarith

/--
  [CONJETURA] Nested ΔRECD continuum limit and multi-scale orientation
  non-equivalence. Separate track from legacy single-layer CT.
-/
def NestedRECD_ContLimConjecture : Prop :=
  ∀ N : NestedRECD,
    InfOftenNegInc (N.outerAccum) →
      ¬ IsEventuallyClassical (N.innerAccum)

/--
  [TEOREMA] Nested orientation obstruction when the *inner* path is
  InfOftenNegInc: no classical target respects it (OP-CT-8 reuse).
-/
theorem nested_inner_orientation_obstruction
    (N : NestedRECD)
    (h : InfOftenNegInc N.innerAccum)
    (T_class : Nat → Rat) (hclass : IsClassicalOriented T_class) :
    ¬ ∃ N0 : Nat, OrientationRespecting N.innerAccum T_class N0 :=
  no_eventual_orientationRespecting_classical _ _ h hclass

/-! ### Master open-problem registry -/

/--
  [OPERACIONAL] Explicit registry of research residuals still open after
  the elementary CT pack + residual discharge in this PR.
-/
structure CTResearchResidual where
  schnakenberg_CT4C : Prop
  ordinal_LDP : Prop
  nested_contLim : Prop
  full_C0_projected : Prop
  kendall_consistency_in_probability : Prop
  continuum_markov_semigroup_intertwining : Prop

/-- Default residual board (all open as propositions, not theorems). -/
def defaultCTResearchResidual : CTResearchResidual where
  schnakenberg_CT4C := CT4C_SchnakenbergConjecture
  ordinal_LDP := OrdinalFluctuationConjecture
  nested_contLim := NestedRECD_ContLimConjecture
  full_C0_projected := True
  kendall_consistency_in_probability := True
  continuum_markov_semigroup_intertwining := True

/--
  [TEOREMA] Honesty marker: the residual board is inhabited (structures
  type-check) without claiming any research conjecture is proved.
-/
theorem research_residual_board_inhabited :
    ∃ _r : CTResearchResidual, True :=
  ⟨defaultCTResearchResidual, trivial⟩

end SystemicTau
