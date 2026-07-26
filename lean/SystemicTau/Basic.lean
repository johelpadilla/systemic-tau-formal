/-
  [OPERACIONAL] / definitions — Systemic Tau core interface.

  τₛ is the mean pairwise Kendall-τ over sliding windows on a
  multivariate series. This module fixes names, types, and a full
  combinatorial Kendall-τ on finite samples (no longer opaque).
-/
import Mathlib.Algebra.Order.Ring.Unbundled.Rat
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp

namespace SystemicTau

/-- Feigenbaum δ as a rational approximation (operational lab constant).
    46692016091 / 10000000000 ≈ 4.6692016091 (Feigenbaum 1978 / standard tables).
    Not a uniqueness or cascade-limit theorem. -/
def feigenbaumDeltaNum : Nat := 46692016091
def feigenbaumDeltaDen : Nat := 10000000000

/-- Operational Feigenbaum δ ∈ ℚ. Shared by Reduction / Analytic / Tendsto. -/
def feigenbaumDeltaOp : Rat :=
  (feigenbaumDeltaNum : Rat) / (feigenbaumDeltaDen : Rat)

/-- Sliding window length (default matching systemictau). [OPERACIONAL] -/
structure Window where
  size : Nat
  size_pos : 0 < size

def defaultWindow : Window := ⟨13, by decide⟩

/-- Number of unordered pairs among n variables. -/
def numPairs (n : Nat) : Nat := n * (n - 1) / 2

/-- Sign of an integer as −1 / 0 / +1. [OPERACIONAL] -/
def signZ (z : Int) : Int :=
  if 0 < z then (1 : Int) else if z < 0 then (-1 : Int) else 0

theorem signZ_pos {z : Int} (h : 0 < z) : signZ z = 1 := by
  simp [signZ, h]

theorem signZ_neg {z : Int} (h : z < 0) : signZ z = -1 := by
  have hne : ¬ 0 < z := not_lt_of_gt h
  simp [signZ, hne, h]

theorem signZ_zero : signZ 0 = 0 := by simp [signZ]

theorem signZ_eq_of_lt {a b : Int} (h : a < b) : signZ (b - a) = 1 := by
  have : 0 < b - a := by omega
  exact signZ_pos this

theorem signZ_eq_of_gt {a b : Int} (h : b < a) : signZ (b - a) = -1 := by
  have : b - a < 0 := by omega
  exact signZ_neg this

/--
  Concordance score of two samples: sum over i < j of
  sign(xⱼ−xᵢ)·sign(yⱼ−yᵢ). Recursive on the tails.
  [OPERACIONAL]
-/
def kendallScore : List Int → List Int → Int
  | [], _ => 0
  | _, [] => 0
  | x :: xs, y :: ys =>
      let rec withHead : List Int → List Int → Int
        | [], _ => 0
        | _, [] => 0
        | x' :: xs', y' :: ys' =>
            signZ (x' - x) * signZ (y' - y) + withHead xs' ys'
      withHead xs ys + kendallScore xs ys

/--
  [OPERACIONAL] Combinatorial Kendall-τ on two integer samples.
  τ = score / binom(n,2) with n = min(|xs|,|ys|); returns 0 if n < 2.
  Matches the classical definition on tie-free equal-length samples.
-/
def kendallTau (xs : List Int) (ys : List Int) : ℚ :=
  let n := min xs.length ys.length
  if n < 2 then 0
  else (kendallScore xs ys : ℚ) / (numPairs n : ℚ)

/-- Regime classification labels. -/
inductive Regime where
  | stable
  | chaotic
  | antiSync
  | intermediate
  deriving DecidableEq, Repr

/-- Sanity: default window is positive. -/
theorem defaultWindow_pos : 0 < defaultWindow.size := defaultWindow.size_pos

/-- Sanity: pairs formula for N=4. -/
example : numPairs 4 = 6 := by decide

/-- [TEOREMA] numPairs n = 0 for n < 2. -/
theorem numPairs_lt_two (n : Nat) (h : n < 2) : numPairs n = 0 := by
  match n with
  | 0 => rfl
  | 1 => rfl
  | n + 2 => omega

/-- [TEOREMA] numPairs 2 = 1. -/
theorem numPairs_two : numPairs 2 = 1 := by decide

/--
  [TEOREMA] Sample: perfectly concordant length-2 lists ⇒ τ = 1.
-/
theorem kendallTau_len2_concordant :
    kendallTau [0, 1] [0, 1] = 1 := by
  native_decide

/--
  [TEOREMA] Sample: perfectly discordant length-2 lists ⇒ τ = −1.
-/
theorem kendallTau_len2_discordant :
    kendallTau [0, 1] [1, 0] = -1 := by
  native_decide

/--
  [TEOREMA] Sample: ties ⇒ τ = 0 on length-2.
-/
theorem kendallTau_len2_tie :
    kendallTau [0, 0] [0, 1] = 0 := by
  native_decide

/-- Short samples return 0. -/
theorem kendallTau_short (xs ys : List Int)
    (h : min xs.length ys.length < 2) :
    kendallTau xs ys = 0 := by
  simp [kendallTau, h]

end SystemicTau
