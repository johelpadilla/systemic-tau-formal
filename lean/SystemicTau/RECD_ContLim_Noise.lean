/-
  OP-CT-5 residual (noise half): ContLim under estimator noise on a
  finite / compact mesh horizon.

  Module CT (docs/RECD_vs_Thermodynamic_Time.md), ContLim + CT-1 noise.
  [TEOREMA] hat path stays in a degraded stable band under NoiseBounded
  [TEOREMA] uniform accum gap |T̂_N − T_N| ≤ N·δ^{-k}·η (reuses CT-1 residual)
  [TEOREMA] equi-Lipschitz immersion of the estimated path
  [TEOREMA] small-η ⇒ estimated immersion nondecreasing on stable cells

  Scope: pathwise ℚ, discrete immersion, frozen depth. No Skorokhod,
  no probabilistic Kendall consistency, no continuum random fields.
-/
import SystemicTau.RECD_ContLimFull
import SystemicTau.RECD_CT1_Noise
import SystemicTau.RECD_BV

namespace SystemicTau

/-! ### Degraded stable band for the estimator -/

/--
  [TEOREMA] Pointwise degraded lower band:
  if τ_true ≥ τ_st and |ε| ≤ η, then τ̂ ≥ τ_st − η.
-/
theorem tauHat_ge_degraded
    (tauTrue eps : Nat → Rat) (η : Rat) (N : Nat)
    (_hη : 0 ≤ η)
    (htrue : ∀ n, n < N → tauTrue n ≥ tauStable)
    (hnoise : NoiseBounded eps η N)
    (n : Nat) (hn : n < N) :
    tauTrue n + eps n ≥ tauStable - η := by
  have hlo := htrue n hn
  have hbd := hnoise n hn
  have heps : -η ≤ eps n := by
    have : -absRat (eps n) ≤ eps n := neg_absRat_le (eps n)
    have : -η ≤ -absRat (eps n) := neg_le_neg hbd
    linarith
  linarith

/--
  [TEOREMA] Pointwise upper band under noise:
  if τ_true ≤ M and |ε| ≤ η, then τ̂ ≤ M + η.
-/
theorem tauHat_le_inflated
    (tauTrue eps : Nat → Rat) (η M : Rat) (N : Nat)
    (_hη : 0 ≤ η)
    (hM : ∀ n, n < N → tauTrue n ≤ M)
    (hnoise : NoiseBounded eps η N)
    (n : Nat) (hn : n < N) :
    tauTrue n + eps n ≤ M + η := by
  have hup := hM n hn
  have hbd := hnoise n hn
  have heps : eps n ≤ η := by
    -- eps ≤ |eps| ≤ η
    have : eps n ≤ absRat (eps n) := by
      simp only [absRat]
      split_ifs <;> linarith
    linarith
  linarith

/--
  [TEOREMA] Stable band preserved under margin:
  τ_true ≥ τ_st + η and |ε| ≤ η ⇒ τ̂ ≥ τ_st (no degradation).
  Re-export of `estimator_preserves_stable` for ContLim packaging.
-/
theorem recdAccum_noise_stable_band
    (E : EstimatorNoise) (η : Rat) (N : Nat)
    (hη : 0 ≤ η)
    (htrue : ∀ n, n < N → E.tauTrue n ≥ tauStable + η)
    (hnoise : NoiseBounded E.eps η N) :
    H1_stableDomination E.tauHat N := by
  intro n hn
  exact estimator_preserves_stable E η N hη htrue hnoise n hn

/--
  [TEOREMA] ContLim-style degraded band package on the hat path:
  under NoiseBounded and true stable with amplitude ≤ M,
  the hat path satisfies
    τ_st − η ≤ τ̂_n ≤ M + η
  on the horizon (degraded/inflated envelope).
-/
theorem recdAccum_noise_degraded_envelope
    (E : EstimatorNoise) (η M : Rat) (N : Nat)
    (hη : 0 ≤ η)
    (htrue : ∀ n, n < N → E.tauTrue n ≥ tauStable)
    (hM : ∀ n, n < N → E.tauTrue n ≤ M)
    (hnoise : NoiseBounded E.eps η N)
    (n : Nat) (hn : n < N) :
    E.tauHat n ≥ tauStable - η ∧ E.tauHat n ≤ M + η := by
  rw [E.tauHat_eq]
  exact ⟨tauHat_ge_degraded E.tauTrue E.eps η N hη htrue hnoise n hn,
    tauHat_le_inflated E.tauTrue E.eps η M N hη hM hnoise n hn⟩

/-! ### Uniform accumulation gap (reuse CT-1 residual) -/

/--
  [TEOREMA] ContLim form of the accum noise bound:
  if both true and hat stay stable at frozen depth k★ and |ε| ≤ η,
  then |T̂_N − T_N| ≤ N · δ^{-k★} · η uniformly on the compact horizon.
-/
theorem contLim_noise_accum_bound
    (tauTrue eps : Nat → Rat) (kStar : Nat) (η : Rat) (N : Nat)
    (hη : 0 ≤ η)
    (htrue : ∀ n, n < N → tauTrue n ≥ tauStable)
    (hhat : ∀ n, n < N → tauTrue n + eps n ≥ tauStable)
    (hnoise : NoiseBounded eps η N) :
    absRat
        (recdAccum (fun n => tauTrue n + eps n) (frozenDepth kStar) N -
          recdAccum tauTrue (frozenDepth kStar) N) ≤
      (N : Rat) * (deltaInvPow kStar * η) :=
  recdAccum_noise_bound tauTrue eps kStar η N hη htrue hhat hnoise

/--
  [TEOREMA] EstimatorNoise packaging of the uniform accum gap.
-/
theorem contLim_noise_accum_bound_estimator
    (E : EstimatorNoise) (kStar : Nat) (η : Rat) (N : Nat)
    (hη : 0 ≤ η)
    (htrue : ∀ n, n < N → E.tauTrue n ≥ tauStable + η)
    (hnoise : NoiseBounded E.eps η N) :
    absRat
        (recdAccum E.tauHat (frozenDepth kStar) N -
          recdAccum E.tauTrue (frozenDepth kStar) N) ≤
      (N : Rat) * (deltaInvPow kStar * η) := by
  have hst : ∀ n, n < N → E.tauTrue n ≥ tauStable := by
    intro n hn
    have := htrue n hn
    linarith [hη]
  have hhat : ∀ n, n < N → E.tauTrue n + E.eps n ≥ tauStable := by
    intro n hn
    simpa [E.tauHat_eq] using
      estimator_preserves_stable E η N hη htrue hnoise n hn
  -- tauHat is defeq to true+eps
  simpa [EstimatorNoise.tauHat] using
    contLim_noise_accum_bound E.tauTrue E.eps kStar η N hη hst hhat hnoise

/-! ### Equi-Lipschitz immersion under noise -/

/--
  [TEOREMA] Tick amplitude of the hat path under stable + inflated upper bound:
  if τ̂ ≥ τ_st and τ̂ ≤ M+η then |ΔT̂| ≤ δ^{-k}·(M+η).
-/
theorem tickAbs_hat_le_of_noise_bound
    (E : EstimatorNoise) (kStar : Nat) (η M : Rat) (n : Nat)
    (hst : E.tauHat n ≥ tauStable)
    (hup : E.tauHat n ≤ M + η) :
    tickAbs E.tauHat (frozenDepth kStar) n ≤
      deltaInvPow kStar * (M + η) :=
  tickAbs_le_of_stable_bound E.tauHat kStar (M + η) n hst hup

/--
  [TEOREMA] Equi-Lipschitz immersion of the *estimated* path on a compact
  horizon: under NoiseBounded, true stable with margin η, and true ≤ M,
  the affine immersion of τ̂ is equi-Lipschitz with modulus
    L = δ^{-k★} · (M + η).
-/
theorem immerse_noise_equiLipschitz
    (E : EstimatorNoise) (kStar : Nat) (η M : Rat) (N : Nat)
    (hη : 0 ≤ η)
    (htrue : ∀ n, n < N → E.tauTrue n ≥ tauStable + η)
    (hM : ∀ n, n < N → E.tauTrue n ≤ M)
    (hnoise : NoiseBounded E.eps η N)
    (n : Nat) (hn : n < N) (θ₁ θ₂ : Rat) :
    absRat
        (immerseAffine E.tauHat (frozenDepth kStar) n θ₂ -
          immerseAffine E.tauHat (frozenDepth kStar) n θ₁) ≤
      (deltaInvPow kStar * (M + η)) * absRat (θ₂ - θ₁) := by
  have hst : E.tauHat n ≥ tauStable :=
    estimator_preserves_stable E η N hη htrue hnoise n hn
  have hup : E.tauHat n ≤ M + η := by
    rw [E.tauHat_eq]
    exact tauHat_le_inflated E.tauTrue E.eps η M N hη hM hnoise n hn
  apply immerseAffine_lipschitz_of_tick_le
  exact tickAbs_hat_le_of_noise_bound E kStar η M n hst hup

/--
  [TEOREMA] ContLim equi-Lipschitz under H1 on the hat path with upper
  amplitude bound M̂ (direct form, no inflation step).
-/
theorem immerse_noise_equiLipschitz_of_H1
    (E : EstimatorNoise) (kStar : Nat) (Mhat : Rat) (N : Nat)
    (h1 : H1_stableDomination E.tauHat N)
    (hM : ∀ n, n < N → E.tauHat n ≤ Mhat)
    (n : Nat) (hn : n < N) (θ₁ θ₂ : Rat) :
    absRat
        (immerseAffine E.tauHat (frozenDepth kStar) n θ₂ -
          immerseAffine E.tauHat (frozenDepth kStar) n θ₁) ≤
      (deltaInvPow kStar * Mhat) * absRat (θ₂ - θ₁) :=
  contLim_equiLipschitz E.tauHat kStar Mhat N h1 hM n hn θ₁ θ₂

/-! ### Small-η monotonicity of the estimated immersion -/

/--
  [TEOREMA] If the true path has stable margin η₀ (τ_true ≥ τ_st + η₀) and
  the noise level satisfies 0 ≤ η ≤ η₀ with |ε| ≤ η, then the hat path is
  stable on the horizon, hence the estimated immersion is nondecreasing
  in θ on every cell of the compact horizon.
-/
theorem contLim_noise_mono_of_small_η
    (E : EstimatorNoise) (kStar : Nat) (η η₀ : Rat) (N : Nat)
    (hη0 : 0 ≤ η)
    (hη : η ≤ η₀)
    (htrue : ∀ n, n < N → E.tauTrue n ≥ tauStable + η₀)
    (hnoise : NoiseBounded E.eps η N)
    (n : Nat) (hn : n < N) (θ₁ θ₂ : Rat) (hθ : θ₁ ≤ θ₂) :
    immerseAffine E.tauHat (frozenDepth kStar) n θ₁ ≤
      immerseAffine E.tauHat (frozenDepth kStar) n θ₂ := by
  -- strengthen: true ≥ τ_st + η₀ ≥ τ_st + η ⇒ margin η works
  have htrue' : ∀ m, m < N → E.tauTrue m ≥ tauStable + η := by
    intro m hm
    have := htrue m hm
    linarith
  have hst : E.tauHat n ≥ tauStable :=
    estimator_preserves_stable E η N hη0 htrue' hnoise n hn
  have htick : 0 ≤ recdTick_unit (E.tauHat n) (frozenDepth kStar n) :=
    le_of_lt (recdTick_unit_pos_of_stable (E.tauHat n) (frozenDepth kStar n) hst)
  -- frozenDepth kStar n = kStar
  simp only [frozenDepth] at htick ⊢
  exact immerseAffine_mono_of_tick_nonneg E.tauHat (frozenDepth kStar) n
    htick θ₁ θ₂ hθ

/--
  [TEOREMA] Accumulator form: under the same small-η hypotheses the
  estimated RECD clock is nondecreasing on the compact horizon.
-/
theorem contLim_noise_accum_mono_of_small_η
    (E : EstimatorNoise) (η η₀ : Rat) (N : Nat)
    (hη0 : 0 ≤ η)
    (hη : η ≤ η₀)
    (htrue : ∀ n, n < N → E.tauTrue n ≥ tauStable + η₀)
    (hnoise : NoiseBounded E.eps η N) :
    ∀ n, n < N →
      recdAccum E.tauHat (frozenDepth 0) n ≤
        recdAccum E.tauHat (frozenDepth 0) (n + 1) := by
  have htrue' : ∀ m, m < N → E.tauTrue m ≥ tauStable + η := by
    intro m hm
    have := htrue m hm
    linarith
  exact recdAccum_monotone_of_estimator_noise E (frozenDepth 0) η N
    hη0 htrue' hnoise

/-! ### ContLim noise package -/

/--
  [OPERACIONAL] ContLim + estimator noise hypothesis bundle on a finite
  compact horizon: true path has stable margin η₀, amplitude ≤ M,
  noise |ε| ≤ η ≤ η₀, frozen depth k★.
-/
structure ContLimNoiseHypotheses
    (E : EstimatorNoise) (kStar : Nat) (η η₀ M : Rat) (N : Nat) : Prop where
  hη0 : 0 ≤ η
  hη_le : η ≤ η₀
  htrue_margin : ∀ n, n < N → E.tauTrue n ≥ tauStable + η₀
  htrue_amp : ∀ n, n < N → E.tauTrue n ≤ M
  hnoise : NoiseBounded E.eps η N
  hM : 0 ≤ M

/--
  [TEOREMA] Under ContLimNoiseHypotheses the hat path satisfies ContLim
  H1 with inflated upper amplitude M+η.
-/
theorem ContLimNoiseHypotheses.hat_H1
    {E : EstimatorNoise} {kStar : Nat} {η η₀ M : Rat} {N : Nat}
    (H : ContLimNoiseHypotheses E kStar η η₀ M N) :
    H1_stableDomination E.tauHat N := by
  have htrue' : ∀ n, n < N → E.tauTrue n ≥ tauStable + η := by
    intro n hn
    have := H.htrue_margin n hn
    linarith [H.hη_le]
  exact recdAccum_noise_stable_band E η N H.hη0 htrue' H.hnoise

/--
  [TEOREMA] Full ContLim-noise elementary package on a compact horizon:
  (1) hat stable band (H1)
  (2) uniform accum gap ≤ N·δ^{-k}·η
  (3) equi-Lipschitz immersion with modulus δ^{-k}·(M+η)
  (4) immersion mono under small η
-/
theorem contLim_noise_package
    (E : EstimatorNoise) (kStar : Nat) (η η₀ M : Rat) (N : Nat)
    (H : ContLimNoiseHypotheses E kStar η η₀ M N) :
    H1_stableDomination E.tauHat N ∧
      absRat
          (recdAccum E.tauHat (frozenDepth kStar) N -
            recdAccum E.tauTrue (frozenDepth kStar) N) ≤
        (N : Rat) * (deltaInvPow kStar * η) ∧
      (∀ n, n < N → ∀ θ₁ θ₂,
        absRat
            (immerseAffine E.tauHat (frozenDepth kStar) n θ₂ -
              immerseAffine E.tauHat (frozenDepth kStar) n θ₁) ≤
          (deltaInvPow kStar * (M + η)) * absRat (θ₂ - θ₁)) ∧
      (∀ n, n < N → ∀ θ₁ θ₂, θ₁ ≤ θ₂ →
        immerseAffine E.tauHat (frozenDepth kStar) n θ₁ ≤
          immerseAffine E.tauHat (frozenDepth kStar) n θ₂) := by
  have htrue' : ∀ n, n < N → E.tauTrue n ≥ tauStable + η := by
    intro n hn
    have := H.htrue_margin n hn
    linarith [H.hη_le]
  refine ⟨H.hat_H1, ?_, ?_, ?_⟩
  · exact contLim_noise_accum_bound_estimator E kStar η N H.hη0 htrue' H.hnoise
  · intro n hn θ₁ θ₂
    exact immerse_noise_equiLipschitz E kStar η M N H.hη0 htrue' H.htrue_amp
      H.hnoise n hn θ₁ θ₂
  · intro n hn θ₁ θ₂ hθ
    exact contLim_noise_mono_of_small_η E kStar η η₀ N H.hη0 H.hη_le
      H.htrue_margin H.hnoise n hn θ₁ θ₂ hθ

/--
  [TEOREMA] Named alias matching the residual statement list.
-/
theorem ContLimNoisePackage
    (E : EstimatorNoise) (kStar : Nat) (η η₀ M : Rat) (N : Nat)
    (H : ContLimNoiseHypotheses E kStar η η₀ M N) :
    H1_stableDomination E.tauHat N ∧
      absRat
          (recdAccum E.tauHat (frozenDepth kStar) N -
            recdAccum E.tauTrue (frozenDepth kStar) N) ≤
        (N : Rat) * (deltaInvPow kStar * η) ∧
      (∀ n, n < N → ∀ θ₁ θ₂,
        absRat
            (immerseAffine E.tauHat (frozenDepth kStar) n θ₂ -
              immerseAffine E.tauHat (frozenDepth kStar) n θ₁) ≤
          (deltaInvPow kStar * (M + η)) * absRat (θ₂ - θ₁)) ∧
      (∀ n, n < N → ∀ θ₁ θ₂, θ₁ ≤ θ₂ →
        immerseAffine E.tauHat (frozenDepth kStar) n θ₁ ≤
          immerseAffine E.tauHat (frozenDepth kStar) n θ₂) :=
  contLim_noise_package E kStar η η₀ M N H

end SystemicTau
