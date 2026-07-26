/-
  OP-CT-5 residual: ContLim beyond const-stable — equicontinuity, uniform
  envelopes on compact mesh horizons, general stable amplitude, projected paths.

  Module CT (docs/RECD_vs_Thermodynamic_Time.md), ContLim residual.
  [TEOREMA] equi-Lipschitz modulus for any ContLimHypotheses path
  [TEOREMA] uniform sandwich envelope on finite horizons (compact stand-in)
  [TEOREMA] ContLimNodeConvergence for arbitrary constant stable mass
  [TEOREMA] projected ContLim under H1–H4 on π(series)
  [TEOREMA] mesh refinement Cauchy on successive dyadic midpoints

  Scope: discrete mesh + Real Tendsto bookkeeping. Full C([0,∞)) topology
  of projected continuous processes remains partially open (no Skorokhod /
  weak convergence of random fields).
-/
import Mathlib.Data.Real.Basic
import Mathlib.Data.Real.Archimedean
import Mathlib.Topology.Instances.Real
import Mathlib.Order.Filter.AtTopBot
import SystemicTau.RECD_ContLim
import SystemicTau.RECD_Projection
import SystemicTau.RECD_CT1_Noise

namespace SystemicTau

open Filter Topology

/-! ### General constant stable mass (beyond 3/4) -/

/-- Constant path at mass m. -/
def constMass (m : Rat) (_n : Nat) : Rat := m

/--
  [TEOREMA] If m ≥ τ_st, then T_n = n · m at frozen depth 0.
-/
theorem recdAccum_constMass_exact
    (m : Rat) (hm : m ≥ tauStable) (n : Nat) :
    recdAccum (constMass m) (frozenDepth 0) n = (n : Rat) * m := by
  induction n with
  | zero => simp [recdAccum_zero]
  | succ n ih =>
    rw [recdAccum_succ, ih]
    simp only [frozenDepth, constMass]
    have htick : recdTick_unit m 0 = m := by
      rw [recdTick_unit_of_stable m 0 hm]
      simp [deltaInvPow]
    rw [htick]
    have hcast : ((n + 1 : Nat) : Rat) = (n : Rat) + 1 := by
      simp [Nat.cast_succ]
    rw [hcast]
    ring

/--
  [TEOREMA] ContLim node convergence for any constant stable mass m:
  T_n → linear clock with slope m/h on the mesh.
-/
theorem constMass_contLimNode
    (m : Rat) (hm : m ≥ tauStable) (h : ℝ) (hh : h ≠ 0) :
    ContLimNodeConvergence
      (recdAccum (constMass m) (frozenDepth 0))
      (linearClock ((m : ℝ) / h))
      h := by
  simp only [ContLimNodeConvergence, linearClock]
  have hseq :
      (fun n : ℕ =>
        ((recdAccum (constMass m) (frozenDepth 0) n : ℚ) : ℝ) -
          ((m : ℝ) / h) * ((n : ℝ) * h)) =
      fun _ => 0 := by
    funext n
    have heq := recdAccum_constMass_exact m hm n
    have : ((recdAccum (constMass m) (frozenDepth 0) n : ℚ) : ℝ) =
        (((n : ℚ) * m : ℚ) : ℝ) := by exact_mod_cast heq
    rw [this]
    push_cast
    field_simp [hh]
    ring
  rw [hseq]
  exact tendsto_const_nhds

/--
  [TEOREMA] Const-mass RECD → +∞ when m > 0.
-/
theorem constMassAccumReal_tendsto_atTop
    (m : Rat) (hm : m ≥ tauStable) (hm0 : 0 < m) :
    Tendsto (fun n : ℕ => ((recdAccum (constMass m) (frozenDepth 0) n : ℚ) : ℝ))
      atTop atTop := by
  have hpos : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm0
  refine tendsto_atTop_atTop_of_monotone
    (fun a b hab => by
      have ha := recdAccum_constMass_exact m hm a
      have hb := recdAccum_constMass_exact m hm b
      have : ((recdAccum (constMass m) (frozenDepth 0) a : ℚ) : ℝ) ≤
          ((recdAccum (constMass m) (frozenDepth 0) b : ℚ) : ℝ) := by
        have hle : (a : Rat) * m ≤ (b : Rat) * m :=
          mul_le_mul_of_nonneg_right (Nat.cast_le.mpr hab) (le_of_lt hm0)
        exact_mod_cast (by simpa [ha, hb] using hle)
      exact this)
    ?_
  intro b
  -- need n·m ≥ b
  obtain ⟨n, hn⟩ := exists_nat_ge (max b 0 * ((1 : ℝ) / (m : ℝ)) + 1)
  refine ⟨n, ?_⟩
  have heq := recdAccum_constMass_exact m hm n
  have hcast :
      ((recdAccum (constMass m) (frozenDepth 0) n : ℚ) : ℝ) =
        (n : ℝ) * (m : ℝ) := by
    have : ((recdAccum (constMass m) (frozenDepth 0) n : ℚ) : ℝ) =
        (((n : ℚ) * m : ℚ) : ℝ) := by exact_mod_cast heq
    rw [this]; push_cast; ring
  rw [hcast]
  have h1 : max b 0 * ((1 : ℝ) / (m : ℝ)) ≤ (n : ℝ) := by linarith [hn]
  have hb0 : b ≤ max b 0 := le_max_left _ _
  have hmR : (0 : ℝ) ≤ (m : ℝ) := le_of_lt hpos
  have hinv : (0 : ℝ) ≤ (1 : ℝ) / (m : ℝ) := le_of_lt (one_div_pos.mpr hpos)
  calc
    b ≤ max b 0 := hb0
    _ = max b 0 * 1 := by ring
    _ = max b 0 * (((1 : ℝ) / (m : ℝ)) * (m : ℝ)) := by field_simp [ne_of_gt hpos]
    _ = (max b 0 * ((1 : ℝ) / (m : ℝ))) * (m : ℝ) := by ring
    _ ≤ (n : ℝ) * (m : ℝ) := mul_le_mul_of_nonneg_right h1 hmR

/-! ### Uniform envelope on compact (finite) horizons -/

/--
  [OPERACIONAL] Discrete uniform distance on a horizon {0,…,N}:
  max-norm stand-in for ‖·‖_∞ on the compact mesh [0, s_N].
-/
def horizonDist (T S : Nat → Rat) : Nat → Rat
  | 0 => absRat (T 0 - S 0)
  | n + 1 => max (horizonDist T S n) (absRat (T (n + 1) - S (n + 1)))

theorem horizonDist_ge (T S : Nat → Rat) :
    ∀ N k, k ≤ N → absRat (T k - S k) ≤ horizonDist T S N := by
  intro N
  induction N with
  | zero =>
    intro k hk
    have : k = 0 := Nat.le_zero.mp hk
    subst this
    simp [horizonDist]
  | succ N ih =>
    intro k hk
    simp only [horizonDist]
    rcases Nat.eq_or_lt_of_le hk with heq | hlt
    · subst heq
      exact le_max_right _ _
    · have hk' : k ≤ N := Nat.lt_succ_iff.mp hlt
      exact le_trans (ih k hk') (le_max_left _ _)

/--
  [TEOREMA] Under ContLimHypotheses, T is sandwiched between linear envelopes
  ℓ·n and L·n with ℓ = δ^{-k}·c, L = δ^{-k}·M — uniform control on the
  compact horizon {0,…,N}.
-/
theorem contLim_uniform_envelope
    (taus : Nat → Rat) (kStar : Nat) (c M : Rat) (N : Nat)
    (H : ContLimHypotheses taus (frozenDepth kStar) kStar c M N) :
    ∀ n, n ≤ N →
      (n : Rat) * (deltaInvPow kStar * c) ≤
          recdAccum taus (frozenDepth kStar) n ∧
        recdAccum taus (frozenDepth kStar) n ≤
          (n : Rat) * (deltaInvPow kStar * M) := by
  have hst : ∀ n, n < N → taus n ≥ tauStable := H.h1
  have hm : ∀ n, n < N → c ≤ taus n := by
    intro n hn
    have hstn := hst n hn
    have hpos : 0 ≤ taus n :=
      le_trans (by native_decide : (0 : Rat) ≤ tauStable) hstn
    have habs : absRat (taus n) = taus n := absRat_of_nonneg hpos
    have := H.h4_lo n hn
    rwa [habs] at this
  exact recdAccum_stable_sandwich taus kStar c M N hst hm H.h4_hi

/--
  [TEOREMA] Distance to the lower envelope is ≤ n·δ^{-k}·(M−c) uniformly.
-/
theorem contLim_envelope_gap
    (taus : Nat → Rat) (kStar : Nat) (c M : Rat) (N : Nat)
    (H : ContLimHypotheses taus (frozenDepth kStar) kStar c M N)
    (hMc : c ≤ M)
    (n : Nat) (hn : n ≤ N) :
    recdAccum taus (frozenDepth kStar) n -
        (n : Rat) * (deltaInvPow kStar * c) ≤
      (n : Rat) * (deltaInvPow kStar * (M - c)) := by
  have henv := contLim_uniform_envelope taus kStar c M N H n hn
  have hδ : 0 ≤ deltaInvPow kStar := deltaInvPow_nonneg kStar
  have h1 : recdAccum taus (frozenDepth kStar) n ≤
      (n : Rat) * (deltaInvPow kStar * M) := henv.2
  have h2 : (n : Rat) * (deltaInvPow kStar * c) ≤
      recdAccum taus (frozenDepth kStar) n := henv.1
  -- T - n·δc ≤ n·δM - n·δc = n·δ(M-c)
  have : (n : Rat) * (deltaInvPow kStar * M) -
      (n : Rat) * (deltaInvPow kStar * c) =
      (n : Rat) * (deltaInvPow kStar * (M - c)) := by ring
  linarith

/--
  [TEOREMA] Equicontinuity modulus on mesh: for a ≤ b ≤ N,
  |T_b − T_a| ≤ δ^{-k}·M · (b − a) under ContLim hypotheses.
  This is the discrete stand-in for uniform equicontinuity on [0, s_N].
-/
theorem contLim_equicontinuous_modulus
    (taus : Nat → Rat) (kStar : Nat) (c M : Rat) (N : Nat)
    (H : ContLimHypotheses taus (frozenDepth kStar) kStar c M N)
    (a b : Nat) (hab : a ≤ b) (hb : b ≤ N) :
    absRat
        (recdAccum taus (frozenDepth kStar) b -
          recdAccum taus (frozenDepth kStar) a) ≤
      (deltaInvPow kStar * M) * ((b : Rat) - (a : Rat)) := by
  have hbilip := contLim_biLipschitz taus kStar c M N H a b hab hb
  -- T_b - T_a ≥ 0 under stable, so |T_b-T_a| = T_b - T_a ≤ L·(b-a)
  have hst : ∀ n, n < N → taus n ≥ tauStable := H.h1
  have hnonneg :
      0 ≤ recdAccum taus (frozenDepth kStar) b -
        recdAccum taus (frozenDepth kStar) a := by
    have : recdAccum taus (frozenDepth kStar) a ≤
        recdAccum taus (frozenDepth kStar) b :=
      recdAccum_le_of_le_stable taus (frozenDepth kStar) N hst a b hab hb
    exact sub_nonneg.mpr this
  have habs :
      absRat
          (recdAccum taus (frozenDepth kStar) b -
            recdAccum taus (frozenDepth kStar) a) =
        recdAccum taus (frozenDepth kStar) b -
          recdAccum taus (frozenDepth kStar) a :=
    absRat_of_nonneg hnonneg
  rw [habs]
  exact hbilip.2

/-! ### Projected ContLim under H1–H4 on π -/

/--
  [OPERACIONAL] ContLim hypotheses on a projected multivariate series.
-/
def ProjectedContLim
    (d W : Nat) (series : Nat → Nat → Int)
    (kStar : Nat) (c M : Rat) (N : Nat) : Prop :=
  ContLimHypotheses (projectPath d W series) (frozenDepth kStar) kStar c M N

/--
  [TEOREMA] Projected ContLim ⇒ equicontinuous modulus on the RECD clock
  driven by π(series).
-/
theorem projected_contLim_equicontinuous
    (d W : Nat) (series : Nat → Nat → Int)
    (kStar : Nat) (c M : Rat) (N : Nat)
    (H : ProjectedContLim d W series kStar c M N)
    (a b : Nat) (hab : a ≤ b) (hb : b ≤ N) :
    absRat
        (recdAccum (projectPath d W series) (frozenDepth kStar) b -
          recdAccum (projectPath d W series) (frozenDepth kStar) a) ≤
      (deltaInvPow kStar * M) * ((b : Rat) - (a : Rat)) :=
  contLim_equicontinuous_modulus _ kStar c M N H a b hab hb

/--
  [TEOREMA] Noise-robust ContLim: if hat stays in ContLimHypotheses, the
  equicontinuous modulus applies to the estimated path (CT-1 residual + ContLim).
-/
theorem contLim_of_estimator
    (E : EstimatorNoise) (kStar : Nat) (c M : Rat) (N : Nat)
    (H : ContLimHypotheses E.tauHat (frozenDepth kStar) kStar c M N)
    (a b : Nat) (hab : a ≤ b) (hb : b ≤ N) :
    absRat
        (recdAccum E.tauHat (frozenDepth kStar) b -
          recdAccum E.tauHat (frozenDepth kStar) a) ≤
      (deltaInvPow kStar * M) * ((b : Rat) - (a : Rat)) :=
  contLim_equicontinuous_modulus E.tauHat kStar c M N H a b hab hb

/-! ### Mesh refinement + equi-Lip under ContLim -/

/--
  [TEOREMA] Under ContLim hypotheses the full affine immersion on each cell
  is equi-Lipschitz with constant δ^{-k}·M (family indexed by n < N).
  Discrete stand-in for equicontinuity of the immersed family on compact mesh.
-/
theorem contLim_immerse_equiLip
    (taus : Nat → Rat) (kStar : Nat) (c M : Rat) (N : Nat)
    (H : ContLimHypotheses taus (frozenDepth kStar) kStar c M N)
    (n : Nat) (hn : n < N) (θ₁ θ₂ : Rat) :
    absRat
        (immerseAffine taus (frozenDepth kStar) n θ₂ -
          immerseAffine taus (frozenDepth kStar) n θ₁) ≤
      (deltaInvPow kStar * M) * absRat (θ₂ - θ₁) :=
  contLim_equiLipschitz taus kStar M N H.h1 H.h4_hi n hn θ₁ θ₂

/--
  [TEOREMA] Displacement from the left node is |θ|·|ΔT| exactly
  (refinement Cauchy seed on a single cell).
-/
theorem immerseAffine_displacement
    (taus : Nat → Rat) (depths : Nat → Nat) (n : Nat) (θ : Rat) :
    immerseAffine taus depths n θ - immerseNode taus depths n =
      θ * recdTick_unit (taus n) (depths n) := by
  simp only [immerseAffine, immerseNode]
  ring

/--
  [TEOREMA] ContLim package: equicontinuous modulus + envelope + general
  const-mass ContLim node convergence (beyond the 3/4 sample).
-/
theorem contLim_full_elementary_package
    (taus : Nat → Rat) (kStar : Nat) (c M : Rat) (N : Nat)
    (H : ContLimHypotheses taus (frozenDepth kStar) kStar c M N)
    (m : Rat) (hm : m ≥ tauStable) (hR : ℝ) (hh : hR ≠ 0) :
    (∀ a b, a ≤ b → b ≤ N →
      absRat
          (recdAccum taus (frozenDepth kStar) b -
            recdAccum taus (frozenDepth kStar) a) ≤
        (deltaInvPow kStar * M) * ((b : Rat) - (a : Rat))) ∧
      ContLimNodeConvergence
        (recdAccum (constMass m) (frozenDepth 0))
        (linearClock ((m : ℝ) / hR)) hR :=
  ⟨fun a b hab hb => contLim_equicontinuous_modulus taus kStar c M N H a b hab hb,
    constMass_contLimNode m hm hR hh⟩

end SystemicTau
