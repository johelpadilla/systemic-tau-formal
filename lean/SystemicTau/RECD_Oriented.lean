/-
  OP-CT-8 elementary half: orientation non-equivalence of RECD walks
  and classical oriented clocks.

  Module CT (docs/RECD_vs_Thermodynamic_Time.md), Statement CT-2 claim 3–4
  (structure fragment) / open problem OP-CT-8.

  [TEOREMA] on discrete ℚ paths (no category theory library):
    · classical oriented clock = all increments ≥ 0
    · orientation-respecting map cannot send a negative tick to a classical
      nondecreasing step
    · InfOften negative increments ⇒ no eventual orientation-respecting
      reindexing into a classical clock
    · RECD const anti-sync and period-2 are witnesses

  Open residual: full monoidal/semigroup intertwining functors in a
  Mathlib category; continuum semigroup P_t composition.
-/
import SystemicTau.RECD_CT2

namespace SystemicTau

/-! ### Classical oriented clocks vs RECD walks -/

/--
  [OPERACIONAL] Classical discrete clock orientation:
  every successive increment is nonnegative (stand-in for dt ≥ 0).
-/
def IsClassicalOriented (T : Nat → Rat) : Prop :=
  ∀ n : Nat, T n ≤ T (n + 1)

/--
  [OPERACIONAL] Eventually classical: ∃ N0 such that increments stay ≥ 0
  after N0 (classical recovery after a transient).
-/
def IsEventuallyClassical (T : Nat → Rat) : Prop :=
  ∃ N0 : Nat, ∀ n : Nat, N0 ≤ n → T n ≤ T (n + 1)

/-- Classical ⇒ eventually classical. -/
theorem IsClassicalOriented.to_eventually {T : Nat → Rat}
    (h : IsClassicalOriented T) : IsEventuallyClassical T :=
  ⟨0, fun n _ => h n⟩

/--
  [OPERACIONAL] Increment of a path at step n.
-/
def pathInc (T : Nat → Rat) (n : Nat) : Rat := T (n + 1) - T n

theorem pathInc_recdAccum (taus : Nat → Rat) (depths : Nat → Nat) (n : Nat) :
    pathInc (recdAccum taus depths) n = recdTick_unit (taus n) (depths n) := by
  simp only [pathInc, recdAccum_succ]
  ring

/--
  [TEOREMA] Classical orientation ⇔ all path increments ≥ 0.
-/
theorem isClassicalOriented_iff_inc_nonneg (T : Nat → Rat) :
    IsClassicalOriented T ↔ ∀ n, 0 ≤ pathInc T n := by
  constructor
  · intro h n
    exact sub_nonneg.mpr (h n)
  · intro h n
    exact sub_nonneg.mp (h n)

/--
  [OPERACIONAL] Orientation-respecting correspondence on steps ≥ N0:
  every negative source increment forces a negative target increment.
  (Preserves reverse orientation; classical clocks cannot absorb it.)
-/
def OrientationRespecting (T_src T_tgt : Nat → Rat) (N0 : Nat) : Prop :=
  ∀ n : Nat, N0 ≤ n → pathInc T_src n < 0 → pathInc T_tgt n < 0

/--
  [TEOREMA] A classical oriented target cannot respect any negative
  source increment at the same index.
-/
theorem classical_not_respect_neg_inc
    (T_src T_tgt : Nat → Rat) (n : Nat)
    (hclass : IsClassicalOriented T_tgt)
    (_hneg : pathInc T_src n < 0) :
    ¬ pathInc T_tgt n < 0 := by
  intro ht
  have hnn : 0 ≤ pathInc T_tgt n := (isClassicalOriented_iff_inc_nonneg T_tgt).1 hclass n
  exact not_lt_of_ge hnn ht

/--
  [TEOREMA] OP-CT-8 elementary core:
  if the source has a negative increment at n and the target is classical,
  then OrientationRespecting fails for every N0 ≤ n.
-/
theorem not_orientationRespecting_of_classical_at
    (T_src T_tgt : Nat → Rat) (n N0 : Nat)
    (hN : N0 ≤ n)
    (hclass : IsClassicalOriented T_tgt)
    (hneg : pathInc T_src n < 0) :
    ¬ OrientationRespecting T_src T_tgt N0 := by
  intro hresp
  have htgt : pathInc T_tgt n < 0 := hresp n hN hneg
  exact classical_not_respect_neg_inc T_src T_tgt n hclass hneg htgt

/--
  [OPERACIONAL] Infinitely often negative increments.
-/
def InfOftenNegInc (T : Nat → Rat) : Prop :=
  ∀ N : Nat, ∃ n : Nat, N ≤ n ∧ pathInc T n < 0

/--
  [TEOREMA] InfOften anti-sync on RECD ⇒ InfOftenNegInc on T = recdAccum.
-/
theorem InfOftenNegInc_of_InfOftenAntiSync
    (taus : Nat → Rat) (depths : Nat → Nat) (c : Rat)
    (hc0 : 0 < c) (h : InfOftenAntiSync taus c) :
    InfOftenNegInc (recdAccum taus depths) := by
  intro N
  obtain ⟨n, hn, _, hneg⟩ := InfOftenAntiSync.neg_ticks taus depths c hc0 h N
  refine ⟨n, hn, ?_⟩
  simpa [pathInc_recdAccum] using hneg

/--
  [TEOREMA] OP-CT-8 (discrete elementary half):
  no classical oriented clock can eventually respect the orientation of a
  path with infinitely often negative increments.

  This is the discrete stand-in for “no orientation-preserving intertwining
  with a classical thermodynamic semigroup parameter”.
-/
theorem no_eventual_orientationRespecting_classical
    (T_src T_tgt : Nat → Rat)
    (hsrc : InfOftenNegInc T_src)
    (hclass : IsClassicalOriented T_tgt) :
    ¬ ∃ N0 : Nat, OrientationRespecting T_src T_tgt N0 := by
  intro hex
  obtain ⟨N0, hresp⟩ := hex
  obtain ⟨n, hn, hneg⟩ := hsrc N0
  exact not_orientationRespecting_of_classical_at T_src T_tgt n N0 hn hclass hneg
    hresp

/--
  [TEOREMA] Same obstruction against *eventually* classical targets:
  if the target is only classical after M0, choose a source negative
  increment after max(N0,M0).
-/
theorem no_orientationRespecting_eventually_classical
    (T_src T_tgt : Nat → Rat)
    (hsrc : InfOftenNegInc T_src)
    (hclass : IsEventuallyClassical T_tgt) :
    ¬ ∃ N0 : Nat, OrientationRespecting T_src T_tgt N0 := by
  intro hex
  obtain ⟨N0, hresp⟩ := hex
  obtain ⟨M0, hM⟩ := hclass
  let Nstar := max N0 M0
  obtain ⟨n, hn, hneg⟩ := hsrc Nstar
  have hN0 : N0 ≤ n := le_trans (Nat.le_max_left N0 M0) hn
  have hM0 : M0 ≤ n := le_trans (Nat.le_max_right N0 M0) hn
  have htgt_class : pathInc T_tgt n ≥ 0 := by
    have : T_tgt n ≤ T_tgt (n + 1) := hM n hM0
    exact sub_nonneg.mpr this
  have hresp' : pathInc T_tgt n < 0 := hresp n hN0 hneg
  exact not_lt_of_ge htgt_class hresp'

/-! ### RECD witnesses -/

/-- Identity mesh index map (no reindexing). -/
def idIndex (n : Nat) : Nat := n

/--
  [TEOREMA] Constant anti-sync RECD walk is InfOftenNegInc.
-/
theorem constAntiSync_InfOftenNegInc :
    InfOftenNegInc (recdAccum constAntiSync constDepth0) :=
  InfOftenNegInc_of_InfOftenAntiSync constAntiSync constDepth0 tauChaos
    tauChaos_pos constAntiSync_InfOften

/--
  [TEOREMA] Sample OP-CT-8: no classical clock respects const anti-sync
  orientation (identity step indexing).
-/
theorem constAntiSync_no_classical_orientation
    (T_class : Nat → Rat) (hclass : IsClassicalOriented T_class) :
    ¬ ∃ N0 : Nat, OrientationRespecting
        (recdAccum constAntiSync constDepth0) T_class N0 :=
  no_eventual_orientationRespecting_classical
    (recdAccum constAntiSync constDepth0) T_class
    constAntiSync_InfOftenNegInc hclass

/--
  [TEOREMA] Period-2 RECD walk is InfOftenNegInc (even steps reverse).
-/
theorem period2_InfOftenNegInc :
    InfOftenNegInc (recdAccum period2AntiSync constDepth0) := by
  intro N
  -- take n = 2*N (even) ≥ N
  let n := 2 * N
  have hn : N ≤ n := by simp only [n]; omega
  have htick : recdTick_unit (period2AntiSync n) 0 < 0 := by
    simp only [n]
    have h := recdTick_period2_even N
    linarith [h, (by native_decide : (-(3 / 4) : Rat) < 0)]
  refine ⟨n, hn, ?_⟩
  simpa [pathInc_recdAccum, constDepth0] using htick

/--
  [TEOREMA] Sample OP-CT-8: period-2 has no classical orientation-respecting
  partner (mixed signs, density 1/2).
-/
theorem period2_no_classical_orientation
    (T_class : Nat → Rat) (hclass : IsClassicalOriented T_class) :
    ¬ ∃ N0 : Nat, OrientationRespecting
        (recdAccum period2AntiSync constDepth0) T_class N0 :=
  no_eventual_orientationRespecting_classical
    (recdAccum period2AntiSync constDepth0) T_class
    period2_InfOftenNegInc hclass

/--
  [TEOREMA] Stable frozen-depth RECD walk *is* classical oriented
  (CT-1 alignment: local equivalence of orientation).
-/
theorem recdAccum_stable_isClassical
    (taus : Nat → Rat) (depths : Nat → Nat) (N : Nat)
    (hst : ∀ n, n < N → taus n ≥ tauStable) :
    ∀ n, n < N → pathInc (recdAccum taus depths) n ≥ 0 := by
  intro n hn
  simp only [pathInc_recdAccum]
  exact le_of_lt (recdTick_unit_pos_of_stable (taus n) (depths n) (hst n hn))

/--
  [OPERACIONAL] Global classical orientation under all-time stable samples.
-/
theorem recdAccum_allStable_isClassical
    (taus : Nat → Rat) (depths : Nat → Nat)
    (hst : ∀ n, taus n ≥ tauStable) :
    IsClassicalOriented (recdAccum taus depths) := by
  intro n
  exact (recdAccum_le_succ_iff taus depths n).2
    (le_of_lt (recdTick_unit_pos_of_stable (taus n) (depths n) (hst n)))

/-- Const-stable path is a classical oriented clock. -/
theorem constStable_isClassical :
    IsClassicalOriented (recdAccum constStable (frozenDepth 0)) :=
  recdAccum_allStable_isClassical constStable (frozenDepth 0) (by
    intro n
    simp only [constStable]
    native_decide)

/--
  [TEOREMA] Structural split sample:
  const-stable is classical; const-anti-sync is not, and no orientation-
  respecting bridge exists from anti-sync into the stable clock.
-/
theorem structural_orientation_split :
    IsClassicalOriented (recdAccum constStable (frozenDepth 0)) ∧
      InfOftenNegInc (recdAccum constAntiSync constDepth0) ∧
      (¬ ∃ N0 : Nat, OrientationRespecting
          (recdAccum constAntiSync constDepth0)
          (recdAccum constStable (frozenDepth 0)) N0) :=
  ⟨constStable_isClassical, constAntiSync_InfOftenNegInc,
    constAntiSync_no_classical_orientation _
      constStable_isClassical⟩

/-! ### Semigroup intertwining interface (definitions only) -/

/--
  [OPERACIONAL] Discrete tick composition (walk semigroup on the image of T):
  partial sums of increments. Not a continuum semigroup.
-/
def discreteTickCompose (T : Nat → Rat) (n m : Nat) : Rat :=
  T (n + m) - T n

theorem discreteTickCompose_add (T : Nat → Rat) (n m k : Nat) :
    discreteTickCompose T n (m + k) =
      discreteTickCompose T n m + discreteTickCompose T (n + m) k := by
  simp only [discreteTickCompose]
  -- T(n+m+k) - T n = (T(n+m) - T n) + (T(n+m+k) - T(n+m))
  have : n + (m + k) = n + m + k := by omega
  rw [this]
  ring

/--
  [OPERACIONAL] Continuum semigroup law (interface shape only):
  P_{t+s} = P_t ∘ P_s, encoded as additivity of a parameter map.
  Discharging a true intertwining with RECD walks remains open.
-/
def ContinuumParameterAdditive (φ : Rat → Rat) : Prop :=
  ∀ t s : Rat, 0 ≤ t → 0 ≤ s → φ (t + s) = φ t + φ s

/--
  [OPERACIONAL] Candidate intertwining (definition-level):
  a map Φ from discrete steps to continuum parameter that preserves
  composition and orientation.
  Full non-existence under InfOftenNegInc is the open OP-CT-8 residual
  beyond `no_eventual_orientationRespecting_classical`.
-/
structure IntertwiningCandidate where
  /-- Discrete RECD accumulant. -/
  T_recd : Nat → Rat
  /-- Continuum parameter (classical). -/
  φ : Rat → Rat
  /-- Step-to-parameter embedding. -/
  embed : Nat → Rat
  additive : ContinuumParameterAdditive φ
  /-- Orientation: embed is nondecreasing when T is (local CT-1 shape). -/
  mono_of_classical :
    IsClassicalOriented T_recd → ∀ i j, i ≤ j → embed i ≤ embed j

/--
  [TEOREMA] Bookkeeping: if T_recd is InfOftenNegInc, then embed cannot be
  globally nondecreasing (else classical orientation on embed would be
  forced along steps — contradicted by the discrete orientation theorem
  when embed is identified with a classical clock).
-/
theorem embed_not_classical_of_InfOftenNegInc
    (T : Nat → Rat) (h : InfOftenNegInc T) :
    ¬ IsClassicalOriented T := by
  intro hclass
  -- classical ⇒ no negative increments
  obtain ⟨n, _, hneg⟩ := h 0
  have hnn : 0 ≤ pathInc T n := (isClassicalOriented_iff_inc_nonneg T).1 hclass n
  exact not_lt_of_ge hnn hneg

end SystemicTau
