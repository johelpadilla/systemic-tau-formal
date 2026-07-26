/-
  OP-CT-8 residual: monoidal / monoid-hom form of orientation non-equivalence.

  Module CT (docs/RECD_vs_Thermodynamic_Time.md), OP-CT-8 residual.
  [OPERACIONAL] discrete monoids of time and of increments
  [TEOREMA] monoid-hom obstruction for InfOften reverse orientation
  [TEOREMA] tensor (product) of classical clocks stays classical
  [TEOREMA] no monoidal bridge from anti-sync RECD into classical product

  Scope: elementary monoid algebra on Nat / ℚ paths — not Mathlib
  CategoryTheory functors on Top or Measure. Continuum monoidal
  categories remain a research residual.
-/
import SystemicTau.RECD_Oriented
import SystemicTau.RECD_CT2

namespace SystemicTau

/-! ### Discrete time monoid -/

/--
  [OPERACIONAL] Additive monoid of discrete time steps (ℕ, +, 0).
-/
structure NatMonoidHom where
  toFun : Nat → Nat
  map_zero : toFun 0 = 0
  map_add : ∀ a b, toFun (a + b) = toFun a + toFun b

theorem NatMonoidHom.map_id_zero (f : NatMonoidHom) : f.toFun 0 = 0 :=
  f.map_zero

/-- Identity monoid endomorphism. -/
def NatMonoidHom.idHom : NatMonoidHom where
  toFun := fun n => n
  map_zero := rfl
  map_add := fun _ _ => rfl

/--
  [TEOREMA] Every NatMonoidHom is multiplication by f(1)
  (classification of endomorphisms of (ℕ,+)).
-/
theorem NatMonoidHom.eq_mul_one (f : NatMonoidHom) (n : Nat) :
    f.toFun n = n * f.toFun 1 := by
  induction n with
  | zero =>
    simp only [Nat.zero_mul]
    exact f.map_zero
  | succ n ih =>
    have hadd : f.toFun (n + 1) = f.toFun n + f.toFun 1 := f.map_add n 1
    rw [hadd, ih]
    exact (Nat.succ_mul n (f.toFun 1)).symm

/-! ### Increment monoid of a path -/

/--
  [OPERACIONAL] Strong monoid orientation: a monoid-hom ρ preserves the
  sign pattern of increments of the source when pushed to a target.
  (Homomorphism of oriented walks — discrete monoidal orientation.)
-/
def OrientedMonoidBridge
    (T_src T_tgt : Nat → Rat) (ρ : NatMonoidHom) : Prop :=
  ∀ n : Nat, pathInc T_src n < 0 → pathInc T_tgt (ρ.toFun n) < 0

/--
  [TEOREMA] OP-CT-8 monoidal core:
  if T_src has InfOften negative increments and T_tgt is classical,
  no OrientedMonoidBridge exists for any NatMonoidHom ρ.
-/
theorem no_OrientedMonoidBridge_classical
    (T_src T_tgt : Nat → Rat)
    (hsrc : InfOftenNegInc T_src)
    (hclass : IsClassicalOriented T_tgt)
    (ρ : NatMonoidHom) :
    ¬ OrientedMonoidBridge T_src T_tgt ρ := by
  intro hbridge
  -- pick a negative source increment at some n ≥ 0
  obtain ⟨n, _, hneg⟩ := hsrc 0
  have htgt : pathInc T_tgt (ρ.toFun n) < 0 := hbridge n hneg
  have hnn : 0 ≤ pathInc T_tgt (ρ.toFun n) :=
    (isClassicalOriented_iff_inc_nonneg T_tgt).1 hclass (ρ.toFun n)
  exact not_lt_of_ge hnn htgt

/--
  [TEOREMA] Sample: no monoid bridge from const anti-sync into any classical
  clock (including const-stable).
-/
theorem constAntiSync_no_monoid_bridge
    (T_class : Nat → Rat) (hclass : IsClassicalOriented T_class)
    (ρ : NatMonoidHom) :
    ¬ OrientedMonoidBridge
        (recdAccum constAntiSync constDepth0) T_class ρ :=
  no_OrientedMonoidBridge_classical _ _ constAntiSync_InfOftenNegInc hclass ρ

/--
  [TEOREMA] Same for period-2.
-/
theorem period2_no_monoid_bridge
    (T_class : Nat → Rat) (hclass : IsClassicalOriented T_class)
    (ρ : NatMonoidHom) :
    ¬ OrientedMonoidBridge
        (recdAccum period2AntiSync constDepth0) T_class ρ :=
  no_OrientedMonoidBridge_classical _ _ period2_InfOftenNegInc hclass ρ

/-! ### Monoidal product of clocks -/

/--
  [OPERACIONAL] Product (tensor stand-in) of two path clocks:
  (T ⊗ S)(n) = T n + S n. Models parallel classical time channels.
-/
def pathTensor (T S : Nat → Rat) : Nat → Rat :=
  fun n => T n + S n

theorem pathInc_tensor (T S : Nat → Rat) (n : Nat) :
    pathInc (pathTensor T S) n = pathInc T n + pathInc S n := by
  simp only [pathInc, pathTensor]
  ring

/--
  [TEOREMA] Tensor of classical clocks is classical
  (monoidal closure of the classical orientation).
-/
theorem pathTensor_classical
    (T S : Nat → Rat)
    (hT : IsClassicalOriented T) (hS : IsClassicalOriented S) :
    IsClassicalOriented (pathTensor T S) := by
  intro n
  have h1 : T n ≤ T (n + 1) := hT n
  have h2 : S n ≤ S (n + 1) := hS n
  simp only [pathTensor]
  linarith

/--
  [TEOREMA] Tensor with a classical clock cannot absorb InfOften reverse
  orientation of the other factor: pathTensor T_src T_class remains
  InfOftenNegInc when T_src is (because class increments ≥ 0 do not cancel
  a strictly negative source increment unless |class| compensates — we
  prove the uncancelled case when class increments are 0, and the general
  obstruction via monoid bridge on the source alone).
-/
theorem pathTensor_preserves_InfOftenNegInc_of_flat_classical
    (T_src T_class : Nat → Rat)
    (hsrc : InfOftenNegInc T_src)
    (hflat : ∀ n, pathInc T_class n = 0) :
    InfOftenNegInc (pathTensor T_src T_class) := by
  intro N
  obtain ⟨n, hn, hneg⟩ := hsrc N
  refine ⟨n, hn, ?_⟩
  have : pathInc (pathTensor T_src T_class) n =
      pathInc T_src n + pathInc T_class n := pathInc_tensor _ _ n
  rw [this, hflat n]
  simpa using hneg

/--
  [TEOREMA] Monoidal non-equivalence package:
  classical clocks form a monoidal class under ⊗; RECD anti-sync walks
  lie outside it and admit no OrientedMonoidBridge into it.
-/
theorem monoidal_orientation_split :
    IsClassicalOriented (recdAccum constStable (frozenDepth 0)) ∧
      IsClassicalOriented
        (pathTensor
          (recdAccum constStable (frozenDepth 0))
          (recdAccum constStable (frozenDepth 0))) ∧
      InfOftenNegInc (recdAccum constAntiSync constDepth0) ∧
      (∀ ρ : NatMonoidHom,
        ¬ OrientedMonoidBridge
            (recdAccum constAntiSync constDepth0)
            (recdAccum constStable (frozenDepth 0)) ρ) := by
  refine ⟨constStable_isClassical, ?_, constAntiSync_InfOftenNegInc, ?_⟩
  · exact pathTensor_classical _ _ constStable_isClassical constStable_isClassical
  · intro ρ
    exact constAntiSync_no_monoid_bridge _ constStable_isClassical ρ

/-! ### Additive parameter monoid on ℚ≥0 (continuum interface) -/

/--
  [OPERACIONAL] Monoid of nonnegative rational times under addition.
  ContinuumParameterAdditive is the monoid-hom law into (ℚ, +).
-/
structure AdditiveTimeHom where
  φ : Rat → Rat
  map_zero : φ 0 = 0
  map_add : ContinuumParameterAdditive φ

/--
  [TEOREMA] Linear clocks φ(t) = c·t are AdditiveTimeHom when restricted
  to the additive law on all ℚ (not only ≥0 domain check).
-/
def linearTimeHom (c : Rat) : AdditiveTimeHom where
  φ := fun t => c * t
  map_zero := by ring
  map_add := fun t s _ _ => by ring

/--
  [OPERACIONAL] Discrete-to-continuum monoidal candidate:
  embed : ℕ → ℕ monoid-hom + additive time hom φ.
-/
structure MonoidalIntertwiningCandidate where
  T_recd : Nat → Rat
  embed : NatMonoidHom
  timeHom : AdditiveTimeHom

/-- Parameter values along embedded steps: φ(n). -/
def MonoidalIntertwiningCandidate.param (M : MonoidalIntertwiningCandidate) :
    Nat → Rat :=
  fun n => M.timeHom.φ (n : Rat)

/--
  [TEOREMA] Failure mode under InfOftenNegInc: T_recd cannot itself be classical.
-/
theorem MonoidalIntertwiningCandidate.classical_obstruction
    (M : MonoidalIntertwiningCandidate)
    (h : InfOftenNegInc M.T_recd) :
    ¬ IsClassicalOriented M.T_recd :=
  embed_not_classical_of_InfOftenNegInc M.T_recd h

/--
  [TEOREMA] Bookkeeping: NatMonoidHom embed is automatically nondecreasing
  (n ≤ m ⇒ embed n ≤ embed m) because embed k = k·embed 1.
-/
theorem NatMonoidHom.monotone (f : NatMonoidHom) :
    ∀ i j, i ≤ j → f.toFun i ≤ f.toFun j := by
  intro i j hij
  have hi := NatMonoidHom.eq_mul_one f i
  have hj := NatMonoidHom.eq_mul_one f j
  rw [hi, hj]
  exact Nat.mul_le_mul_right (f.toFun 1) hij

/--
  [TEOREMA] OP-CT-8 monoidal residual (discharged elementary form):
  no OrientedMonoidBridge from InfOften reverse RECD into classical,
  and classical clocks are closed under pathTensor.
  Full Mathlib monoidal category of thermodynamic semigroups remains open.
-/
theorem op_ct8_monoidal_package :
    (∀ (T_src T_tgt : Nat → Rat) (ρ : NatMonoidHom),
      InfOftenNegInc T_src → IsClassicalOriented T_tgt →
        ¬ OrientedMonoidBridge T_src T_tgt ρ) ∧
      (∀ T S, IsClassicalOriented T → IsClassicalOriented S →
        IsClassicalOriented (pathTensor T S)) :=
  ⟨fun _ _ ρ hsrc hclass => no_OrientedMonoidBridge_classical _ _ hsrc hclass ρ,
    fun _ _ hT hS => pathTensor_classical _ _ hT hS⟩

end SystemicTau
