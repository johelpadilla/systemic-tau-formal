/-
  CT-1 residual: estimator noise \(\widehat{\tau}_s\) + discrete semigroup
  intertwining on the stable regime.

  Module CT residual (docs/RECD_vs_Thermodynamic_Time.md).
  [TEOREMA] noise-robust stable domination ⇒ CT-1 mono / bi-Lip on hat path
  [TEOREMA] discrete shift semigroup on classical RECD clocks
  [TEOREMA] intertwining of stable RECD with classical index semigroup

  Scope: pathwise ℚ. No probabilistic consistency of Kendall; no continuum
  Markov semigroup P_t on function spaces (research residual).
-/
import SystemicTau.RECD_CT1
import SystemicTau.RECD_Projection
import SystemicTau.RECD_Oriented
import SystemicTau.RECD_BV

namespace SystemicTau

/-! ### CT-1 under estimator noise -/

/--
  [TEOREMA] CT-1 residual: if the latent τ stays ≥ τ_st + η and |ε| ≤ η,
  then the *observed* hat path is stable on the horizon, hence CT-1
  monotonicity applies to recdAccum on tauHat.
-/
theorem recdAccum_monotone_of_estimator_noise
    (E : EstimatorNoise) (depths : Nat → Nat) (η : Rat) (N : Nat)
    (hη : 0 ≤ η)
    (htrue : ∀ n, n < N → E.tauTrue n ≥ tauStable + η)
    (hnoise : NoiseBounded E.eps η N) :
    ∀ n, n < N →
      recdAccum E.tauHat depths n ≤ recdAccum E.tauHat depths (n + 1) := by
  intro n hn
  apply (recdAccum_le_succ_iff E.tauHat depths n).2
  have hst : E.tauHat n ≥ tauStable :=
    estimator_preserves_stable E η N hη htrue hnoise n hn
  exact le_of_lt (recdTick_unit_pos_of_stable (E.tauHat n) (depths n) hst)

/--
  [TEOREMA] Strict mono form under noise envelope.
-/
theorem recdAccum_strictMono_of_estimator_noise
    (E : EstimatorNoise) (depths : Nat → Nat) (η : Rat) (N : Nat)
    (hη : 0 ≤ η)
    (htrue : ∀ n, n < N → E.tauTrue n ≥ tauStable + η)
    (hnoise : NoiseBounded E.eps η N) :
    ∀ n, n < N →
      recdAccum E.tauHat depths n < recdAccum E.tauHat depths (n + 1) := by
  intro n hn
  rw [recdAccum_succ]
  have hst : E.tauHat n ≥ tauStable :=
    estimator_preserves_stable E η N hη htrue hnoise n hn
  have htick : 0 < recdTick_unit (E.tauHat n) (depths n) :=
    recdTick_unit_pos_of_stable (E.tauHat n) (depths n) hst
  linarith

/--
  [TEOREMA] Noise propagation on a single stable tick (frozen depth):
  |ΔT(τ+ε) − ΔT(τ)| = δ^{-k} · |ε| when both τ and τ+ε are ≥ τ_st.
-/
theorem recdTick_unit_noise_lipschitz
    (tau ε : Rat) (k : Nat)
    (hst : tau ≥ tauStable) (hhat : tau + ε ≥ tauStable) :
    absRat (recdTick_unit (tau + ε) k - recdTick_unit tau k) =
      deltaInvPow k * absRat ε := by
  have h1 : recdTick_unit (tau + ε) k = deltaInvPow k * (tau + ε) :=
    recdTick_unit_of_stable (tau + ε) k hhat
  have h2 : recdTick_unit tau k = deltaInvPow k * tau :=
    recdTick_unit_of_stable tau k hst
  rw [h1, h2]
  have hdiff : deltaInvPow k * (tau + ε) - deltaInvPow k * tau =
      deltaInvPow k * ε := by ring
  rw [hdiff, absRat_mul]
  have hδ : absRat (deltaInvPow k) = deltaInvPow k :=
    absRat_of_nonneg (deltaInvPow_nonneg k)
  rw [hδ]

/--
  [TEOREMA] Accumulated noise bound under stable envelope:
  |T̂_N − T_N| ≤ N · δ^{-k★} · η
  when both true and hat stay stable with frozen depth and |ε| ≤ η.
-/
theorem recdAccum_noise_bound
    (tauTrue eps : Nat → Rat) (kStar : Nat) (η : Rat) (N : Nat)
    (hη : 0 ≤ η)
    (htrue : ∀ n, n < N → tauTrue n ≥ tauStable)
    (hhat : ∀ n, n < N → tauTrue n + eps n ≥ tauStable)
    (hnoise : NoiseBounded eps η N) :
    absRat
        (recdAccum (fun n => tauTrue n + eps n) (frozenDepth kStar) N -
          recdAccum tauTrue (frozenDepth kStar) N) ≤
      (N : Rat) * (deltaInvPow kStar * η) := by
  induction N with
  | zero =>
    simp [recdAccum_zero, absRat]
  | succ N ih =>
    have hN : N < N + 1 := Nat.lt_succ_self N
    have ih' := ih
      (fun n hn => htrue n (Nat.lt_trans hn hN))
      (fun n hn => hhat n (Nat.lt_trans hn hN))
      (fun n hn => hnoise n (Nat.lt_trans hn hN))
    rw [recdAccum_succ, recdAccum_succ]
    simp only [frozenDepth]
    -- | (T̂_N + Δ̂) - (T_N + Δ) | ≤ |T̂_N - T_N| + |Δ̂ - Δ|
    set Tdiff :=
      recdAccum (fun n => tauTrue n + eps n) (frozenDepth kStar) N -
        recdAccum tauTrue (frozenDepth kStar) N
    set Ddiff :=
      recdTick_unit (tauTrue N + eps N) kStar - recdTick_unit (tauTrue N) kStar
    have htriangle :
        absRat
            (recdAccum (fun n => tauTrue n + eps n) (frozenDepth kStar) N +
                recdTick_unit (tauTrue N + eps N) kStar -
              (recdAccum tauTrue (frozenDepth kStar) N +
                recdTick_unit (tauTrue N) kStar)) ≤
          absRat Tdiff + absRat Ddiff := by
      have : recdAccum (fun n => tauTrue n + eps n) (frozenDepth kStar) N +
            recdTick_unit (tauTrue N + eps N) kStar -
            (recdAccum tauTrue (frozenDepth kStar) N +
              recdTick_unit (tauTrue N) kStar) =
          Tdiff + Ddiff := by
        simp only [Tdiff, Ddiff]
        ring
      rw [this]
      -- |a+b| ≤ |a|+|b|
      simp only [absRat]
      split_ifs <;> linarith
    have hD :
        absRat Ddiff = deltaInvPow kStar * absRat (eps N) := by
      simp only [Ddiff]
      exact recdTick_unit_noise_lipschitz (tauTrue N) (eps N) kStar
        (htrue N hN) (hhat N hN)
    have hDη : absRat Ddiff ≤ deltaInvPow kStar * η := by
      rw [hD]
      have hδ : 0 ≤ deltaInvPow kStar := deltaInvPow_nonneg kStar
      exact mul_le_mul_of_nonneg_left (hnoise N hN) hδ
    have hcast : ((N + 1 : Nat) : Rat) = (N : Rat) + 1 := by
      simp [Nat.cast_succ]
    have hgoal :
        absRat Tdiff + absRat Ddiff ≤
          (N : Rat) * (deltaInvPow kStar * η) + deltaInvPow kStar * η := by
      linarith [ih', hDη]
    have hrewrite :
        (N : Rat) * (deltaInvPow kStar * η) + deltaInvPow kStar * η =
          ((N + 1 : Nat) : Rat) * (deltaInvPow kStar * η) := by
      rw [hcast]
      ring
    linarith [htriangle, hgoal, hrewrite]

/-! ### Discrete shift semigroup (classical intertwining) -/

/--
  [OPERACIONAL] Discrete shift semigroup on path values:
  (S_m T)(n) = T(n + m). Composition S_a ∘ S_b = S_{a+b}.
-/
def shiftPath (T : Nat → Rat) (m n : Nat) : Rat := T (n + m)

theorem shiftPath_zero (T : Nat → Rat) (n : Nat) : shiftPath T 0 n = T n := by
  simp [shiftPath]

theorem shiftPath_compose (T : Nat → Rat) (a b n : Nat) :
    shiftPath (fun k => shiftPath T a k) b n = shiftPath T (a + b) n := by
  simp only [shiftPath]
  ac_rfl

/--
  [OPERACIONAL] Increment semigroup (additive cocycle):
  Γ(n, m) = T(n+m) − T(n). Satisfies Γ(n, m+k) = Γ(n,m) + Γ(n+m, k).
-/
def incCocycle (T : Nat → Rat) (n m : Nat) : Rat :=
  discreteTickCompose T n m

theorem incCocycle_cocycle (T : Nat → Rat) (n m k : Nat) :
    incCocycle T n (m + k) =
      incCocycle T n m + incCocycle T (n + m) k :=
  discreteTickCompose_add T n m k

/--
  [TEOREMA] On a classical oriented path, the increment cocycle is
  nonnegative (semigroup of forward clocks).
-/
theorem incCocycle_nonneg_of_classical
    (T : Nat → Rat) (h : IsClassicalOriented T) (n m : Nat) :
    0 ≤ incCocycle T n m := by
  induction m with
  | zero => simp [incCocycle, discreteTickCompose]
  | succ m ih =>
    have hstep : T (n + m) ≤ T (n + m + 1) := h (n + m)
    have : incCocycle T n (m + 1) =
        incCocycle T n m + (T (n + m + 1) - T (n + m)) := by
      have hcoc := incCocycle_cocycle T n m 1
      simp only [incCocycle, discreteTickCompose] at hcoc ⊢
      -- T(n+m+1)-T n = (T(n+m)-T n) + (T(n+m+1)-T(n+m))
      have : n + (m + 1) = n + m + 1 := by omega
      simp only [this] at hcoc ⊢
      linarith
    have hinc : 0 ≤ T (n + m + 1) - T (n + m) := sub_nonneg.mpr hstep
    linarith

/--
  [TEOREMA] Stable RECD ⇒ nonnegative increment cocycle (CT-1 / semigroup
  intertwining elementary half: RECD walk generates a classical discrete
  semigroup of forward increments).
-/
theorem recdAccum_incCocycle_nonneg_of_stable
    (taus : Nat → Rat) (depths : Nat → Nat)
    (hst : ∀ n, taus n ≥ tauStable) (n m : Nat) :
    0 ≤ incCocycle (recdAccum taus depths) n m :=
  incCocycle_nonneg_of_classical _
    (recdAccum_allStable_isClassical taus depths hst) n m

/--
  [OPERACIONAL] Intertwining map: discrete index monoid → RECD clock values.
  φ(n) = T_n. Under stable domination this is a monoid hom into (ℚ,+)
  relative to the increment cocycle (not absolute values from 0 unless T_0=0).
-/
structure DiscreteIntertwining where
  T : Nat → Rat
  /-- φ(0) = T_0. -/
  map_zero : T 0 = 0
  /-- Classical orientation (forward semigroup). -/
  classical : IsClassicalOriented T

/--
  [TEOREMA] Const-stable RECD yields a discrete intertwining into a
  classical forward clock.
-/
def constStableIntertwining : DiscreteIntertwining where
  T := recdAccum constStable (frozenDepth 0)
  map_zero := recdAccum_zero _ _
  classical := constStable_isClassical

/--
  [TEOREMA] Intertwining cocycle identity for any DiscreteIntertwining:
  T(n+m) = T n + Γ(n,m) with Γ ≥ 0.
-/
theorem DiscreteIntertwining.cocycle_split
    (I : DiscreteIntertwining) (n m : Nat) :
    I.T (n + m) = I.T n + incCocycle I.T n m ∧
      0 ≤ incCocycle I.T n m := by
  constructor
  · simp only [incCocycle, discreteTickCompose]
    ring
  · exact incCocycle_nonneg_of_classical I.T I.classical n m

/--
  [TEOREMA] Obstruction: InfOftenNegInc paths admit no DiscreteIntertwining
  structure (cannot be classical forward semigroups).
-/
theorem no_DiscreteIntertwining_of_InfOftenNegInc
    (T : Nat → Rat) (h : InfOftenNegInc T) :
    ¬ ∃ I : DiscreteIntertwining, I.T = T := by
  intro hex
  obtain ⟨I, hI⟩ := hex
  have hclass : IsClassicalOriented T := by
    simpa [hI] using I.classical
  exact embed_not_classical_of_InfOftenNegInc T h hclass

end SystemicTau
