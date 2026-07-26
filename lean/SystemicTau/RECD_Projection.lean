/-
  Projection π: multivariate series → Systemic Tau sequence.

  Module CT residual — estimator / projection half.
  [OPERACIONAL] combinatorial projection API beyond opaque Kendall
  [TEOREMA] mean-of-pairs samples, noise envelope for stable band

  Scope: finite windows on ℤ samples; rational τ. No probability space,
  no consistency-in-probability of the estimator (research residual).
-/
import SystemicTau.RECD
import SystemicTau.Basic

namespace SystemicTau

/-! ### Pair enumeration helpers -/

/-- Sum of a rational function over unordered pairs i < j < d. -/
def sumUnorderedPairs (d : Nat) (f : Nat → Nat → Rat) : Rat :=
  match d with
  | 0 => 0
  | 1 => 0
  | d' + 2 =>
      let rec go (i : Nat) (acc : Rat) : Rat :=
        if hi : i ≥ d' + 1 then acc
        else
          let rec goJ (j : Nat) (acc' : Rat) : Rat :=
            if hj : j ≥ d' + 2 then acc'
            else goJ (j + 1) (acc' + f i j)
          termination_by (d' + 2 - j)
          go (i + 1) (goJ (i + 1) acc)
      termination_by (d' + 1 - i)
      go 0 0

/--
  [OPERACIONAL] Mean pairwise Kendall-τ of a d-variate window.
  Columns are variables: `cols i : List Int` is the sample of variable i.
  Returns 0 if d < 2.
-/
def systemicTauWindow (cols : List (List Int)) : Rat :=
  let d := cols.length
  if d < 2 then 0
  else
    let total := sumUnorderedPairs d fun i j =>
      match cols[i]?, cols[j]? with
      | some xs, some ys => kendallTau xs ys
      | _, _ => 0
    total / (numPairs d : Rat)

/--
  [OPERACIONAL] Projection π of a multivariate path along sliding windows.
  `series t v` = value of variable v at time t.
  At time index t ≥ W−1, the window is series[t−W+1 .. t] for each variable.
-/
def projectAt
    (d W : Nat) (series : Nat → Nat → Int) (t : Nat) : Rat :=
  if W < 2 ∨ d < 2 then 0
  else if t + 1 < W then 0
  else
    let cols : List (List Int) :=
      (List.range d).map fun v =>
        (List.range W).map fun k =>
          series (t + 1 - W + k) v
    systemicTauWindow cols

/-- [OPERACIONAL] Full projected τ-sequence: t ↦ π(window ending at t). -/
def projectPath (d W : Nat) (series : Nat → Nat → Int) : Nat → Rat :=
  fun t => projectAt d W series t

/-! ### Elementary samples -/

/--
  [TEOREMA] Mean of empty / single-variable window is 0.
-/
theorem systemicTauWindow_lt_two (cols : List (List Int))
    (h : cols.length < 2) :
    systemicTauWindow cols = 0 := by
  simp only [systemicTauWindow, h, ↓reduceIte]

/--
  [TEOREMA] Sample: bivariate length-2 concordant columns ⇒ systemic τ = 1.
-/
theorem systemicTauWindow_bivariate_concordant :
    systemicTauWindow [[0, 1], [0, 1]] = 1 := by
  native_decide

/--
  [TEOREMA] Sample: bivariate length-2 discordant columns ⇒ systemic τ = −1.
-/
theorem systemicTauWindow_bivariate_discordant :
    systemicTauWindow [[0, 1], [1, 0]] = -1 := by
  native_decide

/--
  [TEOREMA] Sample projection: two perfectly concordant series of length 2
  give systemic τ = 1 at the first complete window.
-/
theorem projectAt_concordant_sample :
    projectAt 2 2 (fun t _v => (t : Int)) 1 = 1 := by
  native_decide

/--
  [TEOREMA] Sample projection: discordant series give τ = −1.
-/
theorem projectAt_discordant_sample :
    projectAt 2 2
      (fun t v => if v = 0 then (t : Int) else ((1 - t : Nat) : Int)) 1 = -1 := by
  native_decide

/-! ### Estimator noise interface -/

/--
  [OPERACIONAL] Additive estimator noise model:
  \(\widehat{\tau}_s = \tau^{\mathrm{true}}_s + \varepsilon_s\).
  Pathwise envelope — not a probabilistic model.
-/
structure EstimatorNoise where
  tauTrue : Nat → Rat
  eps : Nat → Rat

/-- Observed estimator from true + noise. -/
def EstimatorNoise.tauHat (E : EstimatorNoise) : Nat → Rat :=
  fun n => E.tauTrue n + E.eps n

theorem EstimatorNoise.tauHat_eq (E : EstimatorNoise) (n : Nat) :
    E.tauHat n = E.tauTrue n + E.eps n := rfl

/--
  [OPERACIONAL] Uniform noise envelope |ε_n| ≤ η on a horizon.
-/
def NoiseBounded (eps : Nat → Rat) (η : Rat) (N : Nat) : Prop :=
  ∀ n, n < N → absRat (eps n) ≤ η

/--
  [TEOREMA] eps ≥ −|eps|.
-/
theorem neg_absRat_le (q : Rat) : -absRat q ≤ q := by
  simp only [absRat]
  split_ifs with h
  · linarith
  · linarith

/--
  [TEOREMA] If |ε| ≤ η and τ_true ≥ τ_st + η, then τ̂ ≥ τ_st
  (stable band is noise-robust under the envelope).
-/
theorem tauHat_stable_of_noise_envelope
    (tauTrue eps : Nat → Rat) (η : Rat) (N : Nat)
    (_hη : 0 ≤ η)
    (htrue : ∀ n, n < N → tauTrue n ≥ tauStable + η)
    (hnoise : NoiseBounded eps η N)
    (n : Nat) (hn : n < N) :
    tauTrue n + eps n ≥ tauStable := by
  have hlo := htrue n hn
  have hbd := hnoise n hn
  have heps : -η ≤ eps n := by
    have : -absRat (eps n) ≤ eps n := neg_absRat_le (eps n)
    have : -η ≤ -absRat (eps n) := neg_le_neg hbd
    linarith
  linarith

/--
  [TEOREMA] Noise envelope + true stable margin ⇒ observed estimator is stable.
-/
theorem estimator_preserves_stable
    (E : EstimatorNoise) (η : Rat) (N : Nat)
    (hη : 0 ≤ η)
    (htrue : ∀ n, n < N → E.tauTrue n ≥ tauStable + η)
    (hnoise : NoiseBounded E.eps η N)
    (n : Nat) (hn : n < N) :
    E.tauHat n ≥ tauStable := by
  rw [E.tauHat_eq]
  exact tauHat_stable_of_noise_envelope E.tauTrue E.eps η N hη htrue hnoise n hn

/--
  [OPERACIONAL] Projection-as-estimator: π with additive residual vs a
  latent true τ path (interface for CT-1 residual).
-/
structure ProjectedEstimator where
  d : Nat
  W : Nat
  series : Nat → Nat → Int
  tauTrue : Nat → Rat

def ProjectedEstimator.tauHat (P : ProjectedEstimator) : Nat → Rat :=
  projectPath P.d P.W P.series

def ProjectedEstimator.eps (P : ProjectedEstimator) : Nat → Rat :=
  fun n => P.tauHat n - P.tauTrue n

theorem ProjectedEstimator.hat_eq_true_add_eps
    (P : ProjectedEstimator) (n : Nat) :
    P.tauHat n = P.tauTrue n + P.eps n := by
  simp only [ProjectedEstimator.eps, ProjectedEstimator.tauHat]
  ring

/-- Convert a projected estimator into an EstimatorNoise package. -/
def ProjectedEstimator.toNoise (P : ProjectedEstimator) : EstimatorNoise where
  tauTrue := P.tauTrue
  eps := P.eps

end SystemicTau
