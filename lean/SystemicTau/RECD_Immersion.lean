/-
  Discrete immersion mesh and ordinal production density σ_RECD.

  Module CT (docs/RECD_vs_Thermodynamic_Time.md), §§3.1 and CT-4A (mesh half).
  [OPERACIONAL] mesh + immersion node API
  [TEOREMA] σ_RECD ≥ 0 on every open mesh cell (discrete a.e.)

  Scope: rational mesh, piecewise-constant density, piecewise-affine
  immersion evaluated on nodes and on rational fractions of cells.
  No continuum limit, no C([0,∞)), no measure-theoretic L¹.
-/
import SystemicTau.RECD_OrdinalEntropy

namespace SystemicTau

/-! ### Uniform chronological mesh -/

/--
  [OPERACIONAL] Uniform immersion mesh: s_n = n · h.
  Mesh size h > 0 is a chronological convention (not wall-clock).
-/
def meshTime (h : Rat) (n : Nat) : Rat := (n : Rat) * h

theorem meshTime_zero (h : Rat) : meshTime h 0 = 0 := by
  simp [meshTime]

theorem meshTime_succ (h : Rat) (n : Nat) :
    meshTime h (n + 1) = meshTime h n + h := by
  simp only [meshTime]
  have : ((n + 1 : Nat) : Rat) = (n : Rat) + 1 := by
    simp [Nat.cast_succ]
  rw [this]
  ring

/-- [TEOREMA] Adjacent mesh spacing is exactly h. -/
theorem meshTime_diff (h : Rat) (n : Nat) :
    meshTime h (n + 1) - meshTime h n = h := by
  rw [meshTime_succ]
  ring

/--
  [TEOREMA] Strictly increasing mesh when h > 0.
-/
theorem meshTime_strictMono (h : Rat) (hh : 0 < h) (n m : Nat) (hnm : n < m) :
    meshTime h n < meshTime h m := by
  simp only [meshTime]
  have hnm' : (n : Rat) < (m : Rat) := Nat.cast_lt.mpr hnm
  exact mul_lt_mul_of_pos_right hnm' hh

/-- [TEOREMA] Nondecreasing mesh when h ≥ 0. -/
theorem meshTime_mono (h : Rat) (hh : 0 ≤ h) (n m : Nat) (hnm : n ≤ m) :
    meshTime h n ≤ meshTime h m := by
  simp only [meshTime]
  exact mul_le_mul_of_nonneg_right (Nat.cast_le.mpr hnm) hh

/-! ### Immersion on mesh nodes and open cells -/

/--
  [OPERACIONAL] Immersion at mesh nodes: (ι γ)(s_n) = T_n.
  Full piecewise-linear path is recovered by `immerseAffine` below.
-/
def immerseNode (taus : Nat → Rat) (depths : Nat → Nat) (n : Nat) : Rat :=
  recdAccum taus depths n

theorem immerseNode_zero (taus : Nat → Rat) (depths : Nat → Nat) :
    immerseNode taus depths 0 = 0 :=
  recdAccum_zero taus depths

theorem immerseNode_succ
    (taus : Nat → Rat) (depths : Nat → Nat) (n : Nat) :
    immerseNode taus depths (n + 1) =
      immerseNode taus depths n + recdTick_unit (taus n) (depths n) :=
  recdAccum_succ taus depths n

/--
  [OPERACIONAL] Piecewise-affine immersion on cell n, parameterized by
  θ ∈ [0,1]:  ι(s_n + θ·h) = T_n + θ · ΔT_n.
  (θ = 0 recovers the left node; θ = 1 recovers the right node.)
-/
def immerseAffine
    (taus : Nat → Rat) (depths : Nat → Nat) (n : Nat) (theta : Rat) : Rat :=
  immerseNode taus depths n + theta * recdTick_unit (taus n) (depths n)

theorem immerseAffine_left
    (taus : Nat → Rat) (depths : Nat → Nat) (n : Nat) :
    immerseAffine taus depths n 0 = immerseNode taus depths n := by
  simp [immerseAffine]

theorem immerseAffine_right
    (taus : Nat → Rat) (depths : Nat → Nat) (n : Nat) :
    immerseAffine taus depths n 1 = immerseNode taus depths (n + 1) := by
  simp only [immerseAffine, one_mul, immerseNode_succ]

/--
  [OPERACIONAL] Chronological immersion slope on cell n:
  dι/ds = ΔT_n / h  (h ≠ 0).
-/
def immerseSlope (taus : Nat → Rat) (depths : Nat → Nat) (h : Rat) (n : Nat) : Rat :=
  recdTick_unit (taus n) (depths n) / h

theorem immerseAffine_eq_node_add_slope
    (taus : Nat → Rat) (depths : Nat → Nat) (h : Rat) (n : Nat) (theta : Rat)
    (hh : h ≠ 0) :
    immerseAffine taus depths n theta =
      immerseNode taus depths n +
        (theta * h) * immerseSlope taus depths h n := by
  simp only [immerseAffine, immerseSlope]
  -- θ · ΔT = (θ · h) · (ΔT / h)
  have hne : (h : Rat) ≠ 0 := hh
  field_simp [hne]
  ring

/--
  [TEOREMA] Nonnegative ticks ⇒ nonnegative chronological slope when h > 0.
-/
theorem immerseSlope_nonneg_of_tick_nonneg
    (taus : Nat → Rat) (depths : Nat → Nat) (h : Rat) (n : Nat)
    (hh : 0 < h) (htick : 0 ≤ recdTick_unit (taus n) (depths n)) :
    0 ≤ immerseSlope taus depths h n := by
  simp only [immerseSlope]
  exact div_nonneg htick (le_of_lt hh)

/--
  [TEOREMA] Immersion on cell n is nondecreasing in θ ∈ ℝ when ΔT_n ≥ 0.
  (Discrete stand-in for “ι nondecreasing on the cell”.)
-/
theorem immerseAffine_mono_of_tick_nonneg
    (taus : Nat → Rat) (depths : Nat → Nat) (n : Nat)
    (htick : 0 ≤ recdTick_unit (taus n) (depths n))
    (θ₁ θ₂ : Rat) (hθ : θ₁ ≤ θ₂) :
    immerseAffine taus depths n θ₁ ≤ immerseAffine taus depths n θ₂ := by
  simp only [immerseAffine]
  have : θ₁ * recdTick_unit (taus n) (depths n) ≤
      θ₂ * recdTick_unit (taus n) (depths n) :=
    mul_le_mul_of_nonneg_right hθ htick
  linarith

/-! ### Ordinal production density σ_RECD on mesh cells -/

/--
  [OPERACIONAL] Piecewise-constant ordinal production density on cell n:
    σ_RECD|_((s_n,s_{n+1})) := Σ(ΔT_n; α) / h.
  This is the discrete stand-in for the module formula
    (Σ_{n+1} − Σ_n) / (s_{n+1} − s_n).
-/
def sigmaRECD
    (taus : Nat → Rat) (depths : Nat → Nat) (alpha h : Rat) (n : Nat) : Rat :=
  ordinalSigmaTick (recdTick_unit (taus n) (depths n)) alpha / h

/--
  [TEOREMA] Mesh increment of cumulative production equals the tick production:
  Σ_{n+1} − Σ_n = Σ(ΔT_n; α).
-/
theorem ordinalSigmaAccum_diff
    (taus : Nat → Rat) (depths : Nat → Nat) (alpha : Rat) (n : Nat) :
    ordinalSigmaAccum taus depths alpha (n + 1) -
        ordinalSigmaAccum taus depths alpha n =
      ordinalSigmaTick (recdTick_unit (taus n) (depths n)) alpha := by
  rw [ordinalSigmaAccum_succ]
  ring

/--
  [TEOREMA] Density formula matches the module definition under uniform mesh:
  σ_n = (Σ_{n+1} − Σ_n) / (s_{n+1} − s_n).
-/
theorem sigmaRECD_eq_mesh_quotient
    (taus : Nat → Rat) (depths : Nat → Nat) (alpha h : Rat) (n : Nat) :
    sigmaRECD taus depths alpha h n =
      (ordinalSigmaAccum taus depths alpha (n + 1) -
          ordinalSigmaAccum taus depths alpha n) /
        (meshTime h (n + 1) - meshTime h n) := by
  simp only [sigmaRECD, meshTime_diff, ordinalSigmaAccum_diff]

/--
  [TEOREMA] CT-4A (mesh density half):
  for α ∈ [0,1] and h > 0, σ_RECD ≥ 0 on every mesh cell.
  Discrete “almost everywhere”: every open cell of the immersion mesh
  carries a nonnegative constant density. No continuum measure theory.
-/
theorem sigmaRECD_nonneg
    (taus : Nat → Rat) (depths : Nat → Nat) (alpha h : Rat)
    (hα0 : 0 ≤ alpha) (hα1 : alpha ≤ 1) (hh : 0 < h) (n : Nat) :
    0 ≤ sigmaRECD taus depths alpha h n := by
  simp only [sigmaRECD]
  have hnum :
      0 ≤ ordinalSigmaTick (recdTick_unit (taus n) (depths n)) alpha :=
    ordinalSigmaTick_nonneg
      (recdTick_unit (taus n) (depths n)) alpha hα0 hα1
  exact div_nonneg hnum (le_of_lt hh)

/-- Convenience: default protocol α = 1. -/
theorem sigmaRECD_nonneg_alpha_one
    (taus : Nat → Rat) (depths : Nat → Nat) (h : Rat)
    (hh : 0 < h) (n : Nat) :
    0 ≤ sigmaRECD taus depths 1 h n :=
  sigmaRECD_nonneg taus depths 1 h
    (by native_decide) (by native_decide) hh n

/--
  [TEOREMA] CT-4B mesh form: under g ≥ 0 on the horizon,
  σ_RECD coincides with the immersion slope (chronological density of T).
-/
theorem sigmaRECD_eq_immerseSlope_of_gate_nonneg
    (taus : Nat → Rat) (depths : Nat → Nat) (alpha h : Rat) (n : Nat)
    (hg : 0 ≤ gate (taus n)) :
    sigmaRECD taus depths alpha h n = immerseSlope taus depths h n := by
  simp only [sigmaRECD, immerseSlope]
  rw [ordinalSigmaTick_eq_recdTick_of_gate_nonneg (taus n) (depths n) alpha hg]

/--
  [OPERACIONAL] Partial sum of mesh densities: S_0 = 0, S_{n+1} = S_n + σ_n.
-/
def sigmaRECDAccum
    (taus : Nat → Rat) (depths : Nat → Nat) (alpha h : Rat) : Nat → Rat
  | 0 => 0
  | n + 1 =>
      sigmaRECDAccum taus depths alpha h n +
        sigmaRECD taus depths alpha h n

/--
  [TEOREMA] Cumulative production recovers as mesh-sum of densities:
  Σ_N = h · S_N  (uniform step h ≠ 0).
-/
theorem ordinalSigmaAccum_eq_h_mul_sigmaAccum
    (taus : Nat → Rat) (depths : Nat → Nat) (alpha h : Rat) (N : Nat)
    (hh : h ≠ 0) :
    ordinalSigmaAccum taus depths alpha N =
      h * sigmaRECDAccum taus depths alpha h N := by
  induction N with
  | zero =>
    simp [ordinalSigmaAccum_zero, sigmaRECDAccum]
  | succ N ih =>
    rw [ordinalSigmaAccum_succ, sigmaRECDAccum, ih, mul_add]
    have :
        h * sigmaRECD taus depths alpha h N =
          ordinalSigmaTick (recdTick_unit (taus N) (depths N)) alpha := by
      simp only [sigmaRECD]
      field_simp [hh]
    rw [this]

end SystemicTau
