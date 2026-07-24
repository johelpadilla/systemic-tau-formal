/-
  [OPERACIONAL] / definitions — Systemic Tau core interface.

  τₛ is the mean pairwise Kendall-τ over sliding windows on a
  multivariate series. Full combinatorial Kendall is refined later;
  this module fixes names and types used by RECD.
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

/-- Abstract Kendall-τ on two samples (implementation deferred). -/
opaque kendallTau (xs : List Int) (ys : List Int) : ℚ

/-- Number of unordered pairs among n variables. -/
def numPairs (n : Nat) : Nat := n * (n - 1) / 2

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

end SystemicTau
