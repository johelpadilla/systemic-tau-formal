/-
  OP-CT-5: controlled continuum limit — discrete scaffolding + Real interface.

  Module CT (docs/RECD_vs_Thermodynamic_Time.md), §3.3 ContLim.
  [OPERACIONAL] H1–H4 hypothesis package
  [TEOREMA] elementary obstruction (needs H1-type control)
  [TEOREMA] equi-Lipschitz under stable frozen depth + amp. bounds
  [TEOREMA] exact continuum shape for const-stable path (linear limit)
  [TEOREMA] Real lift: Tendsto of discrete samples along const-stable
    to the linear classical clock (ε–N bookkeeping, not physical projection)

  Open residual: full uniform-on-compacts convergence for projected
  continuous processes under (H1)–(H4); estimator consistency.
-/
import Mathlib.Data.Real.Basic
import Mathlib.Data.Real.Archimedean
import Mathlib.Topology.Instances.Real
import Mathlib.Order.Filter.AtTopBot
import SystemicTau.RECD_BV
import SystemicTau.RECD_Oriented

namespace SystemicTau

open Filter Topology

/-! ### Hypothesis package (H1)–(H4) as discrete Props -/

/--
  [OPERACIONAL] (H1) Stable domination on a horizon:
  τ_n ≥ τ_st for all n < N (gate ≡ +1).
-/
def H1_stableDomination (taus : Nat → Rat) (N : Nat) : Prop :=
  ∀ n, n < N → taus n ≥ tauStable

/--
  [OPERACIONAL] (H2) Bounded / frozen depth on a horizon.
-/
def H2_frozenDepth (depths : Nat → Nat) (kStar : Nat) (N : Nat) : Prop :=
  ∀ n, n < N → depths n = kStar

/-- Convenience: depths = frozenDepth kStar everywhere. -/
theorem H2_of_frozen (kStar : Nat) (N : Nat) :
    H2_frozenDepth (frozenDepth kStar) kStar N := by
  intro n _; rfl

/--
  [OPERACIONAL] (H4) Positive mass lower bound on amplitude.
-/
def H4_positiveMass (taus : Nat → Rat) (c : Rat) (N : Nat) : Prop :=
  ∀ n, n < N → c ≤ absRat (taus n)

/--
  [OPERACIONAL] (H3) Regular sampling is protocol-level (window continuity
  in probability). Encoded here only as a named flag — not discharged.
-/
def H3_regularSamplingFlag : Prop := True

/--
  [OPERACIONAL] ContLim hypothesis bundle on a finite horizon.
-/
structure ContLimHypotheses (taus : Nat → Rat) (depths : Nat → Nat)
    (kStar : Nat) (c M : Rat) (N : Nat) : Prop where
  h1 : H1_stableDomination taus N
  h2 : H2_frozenDepth depths kStar N
  h4_lo : H4_positiveMass taus c N
  h4_hi : ∀ n, n < N → taus n ≤ M
  hc : 0 < c
  hM : 0 ≤ M

/-! ### Elementary obstruction (necessity of H1-type control) -/

/--
  [TEOREMA] ContLim obstruction (doc §3.3):
  InfOften anti-sync with |τ| ≥ c > 0 ⇒ T not eventually nondecreasing,
  hence no nondecreasing continuum limit of the discrete clock can exist
  along the node sequence (orientation fails).
-/
theorem contLim_obstruction_of_InfOftenAntiSync
    (taus : Nat → Rat) (depths : Nat → Nat) (c : Rat)
    (hc0 : 0 < c) (h : InfOftenAntiSync taus c) :
    ¬ IsEventuallyClassical (recdAccum taus depths) := by
  intro hex
  obtain ⟨N0, hN0⟩ := hex
  exact not_eventually_nondecreasing_of_InfOftenAntiSync taus depths c hc0 h
    ⟨N0, hN0⟩

/--
  [TEOREMA] Density form of the obstruction.
-/
theorem contLim_obstruction_of_lowerDensity
    (taus : Nat → Rat) (depths : Nat → Nat) (d : Rat)
    (hd : 0 < d) (hden : HasAntiSyncLowerDensity taus d) :
    ¬ IsEventuallyClassical (recdAccum taus depths) :=
  contLim_obstruction_of_InfOftenAntiSync taus depths tauChaos tauChaos_pos
    (InfOftenAntiSync_of_lowerDensity taus d hd hden)

/-! ### Equi-Lipschitz under ContLim hypotheses (discrete) -/

/--
  [TEOREMA] Under (H1)+(H2)+(upper amp. bound), every cell Lip constant
  is ≤ δ^{-k★}·M (equi-Lipschitz of the immersion family on the horizon).
-/
theorem contLim_equiLipschitz
    (taus : Nat → Rat) (kStar : Nat) (M : Rat) (N : Nat)
    (h1 : H1_stableDomination taus N)
    (hM : ∀ n, n < N → taus n ≤ M)
    (n : Nat) (hn : n < N) (θ₁ θ₂ : Rat) :
    absRat
        (immerseAffine taus (frozenDepth kStar) n θ₂ -
          immerseAffine taus (frozenDepth kStar) n θ₁) ≤
      (deltaInvPow kStar * M) * absRat (θ₂ - θ₁) := by
  apply immerseAffine_lipschitz_of_tick_le
  exact tickAbs_le_of_stable_bound taus kStar M n (h1 n hn) (hM n hn)

/--
  [TEOREMA] Under full ContLimHypotheses, sandwich + bi-Lipschitz of T
  vs index hold (CT-1 recovery on the ContLim regime).
-/
theorem contLim_biLipschitz
    (taus : Nat → Rat) (kStar : Nat) (c M : Rat) (N : Nat)
    (H : ContLimHypotheses taus (frozenDepth kStar) kStar c M N)
    (a b : Nat) (hab : a ≤ b) (hb : b ≤ N) :
    let ℓ := deltaInvPow kStar * c
    let L := deltaInvPow kStar * M
    ℓ * ((b : Rat) - (a : Rat)) ≤
        recdAccum taus (frozenDepth kStar) b -
          recdAccum taus (frozenDepth kStar) a ∧
      recdAccum taus (frozenDepth kStar) b -
          recdAccum taus (frozenDepth kStar) a ≤
        L * ((b : Rat) - (a : Rat)) := by
  intro ℓ L
  -- need m = c and stable; H4 gives |τ| ≥ c and stable ⇒ τ ≥ τ_st ≥ 0 ⇒ τ ≥ c
  have hst : ∀ n, n < N → taus n ≥ tauStable := H.h1
  have hm : ∀ n, n < N → c ≤ taus n := by
    intro n hn
    have hstn := hst n hn
    have hpos : 0 ≤ taus n :=
      le_trans (by native_decide : (0 : Rat) ≤ tauStable) hstn
    have habs : absRat (taus n) = taus n := absRat_of_nonneg hpos
    have := H.h4_lo n hn
    rwa [habs] at this
  have hM := H.h4_hi
  have hc0 := H.hc
  -- bi-Lipschitz uses m > 0
  simpa [ℓ, L] using
    recdAccum_stable_biLipschitz taus kStar c M N hst hm hM hc0 a b hab hb

/--
  [TEOREMA] ContLim regime ⇒ classical orientation on the horizon
  (finite-horizon form of nondecreasing continuum clock).
-/
theorem contLim_classical_on_horizon
    (taus : Nat → Rat) (depths : Nat → Nat) (N : Nat)
    (h1 : H1_stableDomination taus N) :
    ∀ n, n < N → pathInc (recdAccum taus depths) n ≥ 0 :=
  recdAccum_stable_isClassical taus depths N h1

/-! ### Exact continuum shape: constant stable path -/

/--
  [OPERACIONAL] Classical linear clock matched to const-stable RECD:
  T^∞(s) = (3/4) / h · s   when mesh is s_n = n·h and T_n = n·(3/4).
-/
noncomputable def linearClock (slope : ℝ) (s : ℝ) : ℝ := slope * s

/--
  [TEOREMA] Const-stable RECD nodes match the linear clock exactly on ℚ:
  T_n = (3/4)/h · s_n  when s_n = n·h (h ≠ 0).
-/
theorem constStable_matches_linear (h : Rat) (hh : h ≠ 0) (n : Nat) :
    recdAccum constStable (frozenDepth 0) n =
      (3 / 4 / h) * meshTime h n := by
  rw [recdAccum_constStable_exact]
  simp only [meshTime]
  field_simp [hh]
  ring

/--
  [TEOREMA] Immersion slope on const-stable is constantly (3/4)/h.
-/
theorem constStable_immerseSlope (h : Rat) (n : Nat) :
    immerseSlope constStable (frozenDepth 0) h n = (3 / 4) / h := by
  simp only [immerseSlope, frozenDepth]
  have hst : constStable n ≥ tauStable := by
    simp only [constStable]; native_decide
  rw [recdTick_unit_of_stable _ _ hst]
  simp [deltaInvPow, constStable]

/--
  [TEOREMA] Affine immersion on const-stable cell equals the linear clock
  at s = s_n + θ·h.
-/
theorem constStable_immerseAffine_linear
    (h : Rat) (hh : h ≠ 0) (n : Nat) (θ : Rat) :
    immerseAffine constStable (frozenDepth 0) n θ =
      (3 / 4 / h) * (meshTime h n + θ * h) := by
  simp only [immerseAffine, immerseNode, frozenDepth]
  rw [recdAccum_constStable_exact]
  have htick : recdTick_unit (constStable n) 0 = 3 / 4 := by
    have hst : constStable n ≥ tauStable := by
      simp only [constStable]; native_decide
    rw [recdTick_unit_of_stable _ _ hst]
    simp [deltaInvPow, constStable]
  rw [htick]
  simp only [meshTime]
  field_simp [hh]
  ring

/-! ### Real lifts and Tendsto bookkeeping -/

/-- Cast RECD accumulator along const-stable to ℝ. -/
noncomputable def constStableAccumReal (n : ℕ) : ℝ :=
  ((recdAccum constStable (frozenDepth 0) n : ℚ) : ℝ)

/-- Classical linear target: n ↦ n · (3/4) on ℝ. -/
noncomputable def linearStableReal (n : ℕ) : ℝ :=
  (n : ℝ) * (3 / 4)

/--
  [TEOREMA] Exact match on ℝ: const-stable accumulator casts to the
  linear classical sequence (no approximation error).
-/
theorem constStableAccumReal_eq_linear (n : ℕ) :
    constStableAccumReal n = linearStableReal n := by
  simp only [constStableAccumReal, linearStableReal]
  have h := recdAccum_constStable_exact n
  -- cast both sides
  have : ((recdAccum constStable (frozenDepth 0) n : ℚ) : ℝ) =
      (((n : ℚ) * (3 / 4) : ℚ) : ℝ) := by
    exact_mod_cast h
  rw [this]
  push_cast
  ring

/--
  [TEOREMA] Tendsto form (degenerate but honest): the discrete const-stable
  path, cast to ℝ, coincides with the linear classical clock sequence,
  so any filter limit statement for one is equivalent for the other.

  Full ContLim for projected continuous processes remains open; this
  discharges the interface shape on the exact CT-1 sample.
-/
theorem constStable_tendsto_iff_linear (L : ℝ) :
    Tendsto constStableAccumReal atTop (𝓝 L) ↔
      Tendsto linearStableReal atTop (𝓝 L) := by
  constructor
  · intro h
    refine h.congr ?_
    intro n
    exact constStableAccumReal_eq_linear n
  · intro h
    refine h.congr ?_
    intro n
    exact (constStableAccumReal_eq_linear n).symm

/--
  [TEOREMA] The linear stable sequence diverges to +∞ (classical clock
  runs forward without bound under sustained stable mass).
-/
theorem linearStableReal_tendsto_atTop :
    Tendsto linearStableReal atTop atTop := by
  have hpos : (0 : ℝ) < (3 / 4 : ℝ) := by norm_num
  refine tendsto_atTop_atTop_of_monotone
    (fun a b hab => by
      simp only [linearStableReal]
      exact mul_le_mul_of_nonneg_right (Nat.cast_le.mpr hab) (le_of_lt hpos))
    ?_
  intro b
  obtain ⟨n, hn⟩ := exists_nat_ge (max b 0 * (4 / 3) + 1)
  refine ⟨n, ?_⟩
  simp only [linearStableReal]
  have h1 : max b 0 * (4 / 3) ≤ (n : ℝ) := by linarith [hn]
  have hb0 : b ≤ max b 0 := le_max_left _ _
  have h34 : (0 : ℝ) ≤ (3 / 4 : ℝ) := by norm_num
  have hmax : (0 : ℝ) ≤ max b 0 := le_max_right _ _
  calc
    b ≤ max b 0 := hb0
    _ = max b 0 * 1 := by ring
    _ = max b 0 * ((4 / 3) * (3 / 4)) := by ring
    _ = (max b 0 * (4 / 3)) * (3 / 4) := by ring
    _ ≤ (n : ℝ) * (3 / 4) := mul_le_mul_of_nonneg_right h1 h34

/--
  [TEOREMA] Const-stable RECD accumulant → +∞ along atTop (Real form).
-/
theorem constStableAccumReal_tendsto_atTop :
    Tendsto constStableAccumReal atTop atTop := by
  refine linearStableReal_tendsto_atTop.congr ?_
  intro n
  exact (constStableAccumReal_eq_linear n).symm

/--
  [OPERACIONAL] ContLim convergence predicate (interface):
  node samples of T cast to ℝ converge to a limit function evaluated
  on the mesh. Full C([0,∞)) uniform-on-compacts not formalized here.
-/
def ContLimNodeConvergence
    (T : ℕ → ℚ) (Tlim : ℝ → ℝ) (h : ℝ) : Prop :=
  Tendsto (fun n : ℕ => ((T n : ℚ) : ℝ) - Tlim ((n : ℝ) * h)) atTop (𝓝 0)

/--
  [TEOREMA] Const-stable ContLim node convergence to the linear clock
  with slope (3/4)/h (mesh size h > 0 as ℝ).
-/
theorem constStable_contLimNode
    (h : ℝ) (hh : h ≠ 0) :
    ContLimNodeConvergence
      (recdAccum constStable (frozenDepth 0))
      (linearClock ((3 / 4 : ℝ) / h))
      h := by
  simp only [ContLimNodeConvergence, linearClock]
  -- ((n*(3/4)) : ℝ) - ((3/4)/h) * (n*h) = 0
  have hseq :
      (fun n : ℕ =>
        ((recdAccum constStable (frozenDepth 0) n : ℚ) : ℝ) -
          ((3 / 4 : ℝ) / h) * ((n : ℝ) * h)) =
      fun _ => 0 := by
    funext n
    have heq := constStableAccumReal_eq_linear n
    simp only [constStableAccumReal] at heq
    rw [heq, linearStableReal]
    field_simp [hh]
    ring
  rw [hseq]
  exact tendsto_const_nhds

/-! ### Mesh refinement consistency (discrete, no continuum) -/

/--
  [TEOREMA] Evaluating affine immersion at θ = 0 and θ = 1 recovers nodes
  (mesh refinement endpoints are consistent).
-/
theorem mesh_refinement_endpoints
    (taus : Nat → Rat) (depths : Nat → Nat) (n : Nat) :
    immerseAffine taus depths n 0 = immerseNode taus depths n ∧
      immerseAffine taus depths n 1 = immerseNode taus depths (n + 1) :=
  ⟨immerseAffine_left _ _ _, immerseAffine_right _ _ _⟩

/--
  [TEOREMA] Midpoint consistency: θ = 1/2 is the average of endpoints
  (piecewise-affine refinement is well-defined).
-/
theorem mesh_refinement_midpoint
    (taus : Nat → Rat) (depths : Nat → Nat) (n : Nat) :
    immerseAffine taus depths n (1 / 2) =
      (immerseNode taus depths n + immerseNode taus depths (n + 1)) / 2 := by
  simp only [immerseAffine, immerseNode_succ]
  ring

/--
  [TEOREMA] Under ContLim hypotheses, midpoint immersion stays between
  successive nodes (monotone interpolation).
-/
theorem contLim_midpoint_between
    (taus : Nat → Rat) (depths : Nat → Nat) (N n : Nat)
    (h1 : H1_stableDomination taus N) (hn : n < N) :
    immerseNode taus depths n ≤ immerseAffine taus depths n (1 / 2) ∧
      immerseAffine taus depths n (1 / 2) ≤ immerseNode taus depths (n + 1) := by
  have htick : 0 ≤ recdTick_unit (taus n) (depths n) :=
    le_of_lt (recdTick_unit_pos_of_stable (taus n) (depths n) (h1 n hn))
  constructor
  · simp only [immerseAffine, immerseNode]
    have : 0 ≤ (1 / 2 : Rat) * recdTick_unit (taus n) (depths n) :=
      mul_nonneg (by native_decide) htick
    linarith
  · -- rewrite right node as T_n + ΔT
    have hr : immerseNode taus depths (n + 1) =
        immerseNode taus depths n + recdTick_unit (taus n) (depths n) :=
      immerseNode_succ taus depths n
    simp only [immerseAffine, immerseNode] at hr ⊢
    have hhalf : (1 / 2 : Rat) * recdTick_unit (taus n) (depths n) ≤
        recdTick_unit (taus n) (depths n) := by
      have h12 : (1 / 2 : Rat) ≤ 1 := by native_decide
      calc
        (1 / 2 : Rat) * recdTick_unit (taus n) (depths n)
            ≤ 1 * recdTick_unit (taus n) (depths n) :=
          mul_le_mul_of_nonneg_right h12 htick
        _ = recdTick_unit (taus n) (depths n) := one_mul _
    rw [hr]
    linarith

end SystemicTau
