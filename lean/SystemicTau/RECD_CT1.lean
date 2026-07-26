/-
  CT-1 skeleton: local equivalence in the stable regime.

  Module CT (docs/RECD_vs_Thermodynamic_Time.md), Statement CT-1.
  [TEOREMA] under exact (non-estimated) τ sequences:
    · stable band ⇒ g ≡ +1
    · frozen depth k★ ⇒ ΔT_n = δ^{-k★} · τ_n > 0
    · T nondecreasing (strictly increasing)
    · amplitude bounds m ≤ τ ≤ M ⇒ bi-Lipschitz of n ↦ T_n
      and of classical mesh parameter s_n = n·h vs T_n

  Scope: finite discrete horizons on ℚ. No projection noise, no semigroup
  intertwining, no continuum limit (those remain open / [CONJETURA]).
-/
import SystemicTau.RECD_Immersion

namespace SystemicTau

/-! ### Stable frozen-depth tick law -/

/-- Constant depth schedule k_n = k★. -/
def frozenDepth (kStar : Nat) (_n : Nat) : Nat := kStar

/--
  [TEOREMA] Under τ ≥ τ_st, the unit tick collapses to δ^{-k}·τ
  (gate = +1 and |τ| = τ).
-/
theorem recdTick_unit_of_stable
    (tau : Rat) (k : Nat) (h : tau ≥ tauStable) :
    recdTick_unit tau k = deltaInvPow k * tau := by
  have hg : gate tau = 1 := gate_of_stable tau h
  have hpos : 0 ≤ tau :=
    le_trans (by native_decide : (0 : Rat) ≤ tauStable) h
  have habs : absRat tau = tau := absRat_of_nonneg hpos
  simp only [recdTick_unit, deltaT_unit, hg, one_mul, habs]

/--
  [TEOREMA] Stable samples are strictly positive ticks
  (τ_st > 0 and δ^{-k} > 0).
-/
theorem recdTick_unit_pos_of_stable
    (tau : Rat) (k : Nat) (h : tau ≥ tauStable) :
    0 < recdTick_unit tau k := by
  rw [recdTick_unit_of_stable tau k h]
  have hδ : 0 < deltaInvPow k := deltaInvPow_pos k
  have hτ : 0 < tau :=
    lt_of_lt_of_le (by native_decide : (0 : Rat) < tauStable) h
  exact mul_pos hδ hτ

/--
  [TEOREMA] CT-1 elementary fragment: under τ ≥ τ_st and frozen depth,
  ΔT_n = δ^{-k★} · τ_n ≥ δ^{-k★} · τ_st > 0.
-/
theorem recdTick_unit_stable_bounds
    (tau : Rat) (k : Nat) (h : tau ≥ tauStable) :
    recdTick_unit tau k ≥ deltaInvPow k * tauStable ∧
      0 < deltaInvPow k * tauStable := by
  have heq : recdTick_unit tau k = deltaInvPow k * tau :=
    recdTick_unit_of_stable tau k h
  have hδ : 0 < deltaInvPow k := deltaInvPow_pos k
  have hst : 0 < tauStable := by native_decide
  constructor
  · rw [heq]
    exact mul_le_mul_of_nonneg_left h (le_of_lt hδ)
  · exact mul_pos hδ hst

/-! ### Monotonicity on a stable horizon -/

/--
  [TEOREMA] CT-1: if τ_n ≥ τ_st for all n < N, then T is nondecreasing
  on the horizon (any depth schedule).
-/
theorem recdAccum_monotone_of_stable
    (taus : Nat → Rat) (depths : Nat → Nat) (N : Nat)
    (hst : ∀ n, n < N → taus n ≥ tauStable) :
    ∀ n, n < N → recdAccum taus depths n ≤ recdAccum taus depths (n + 1) := by
  intro n hn
  apply (recdAccum_le_succ_iff taus depths n).2
  exact le_of_lt (recdTick_unit_pos_of_stable (taus n) (depths n) (hst n hn))

/--
  [TEOREMA] CT-1 strict form: successive steps strictly increase T.
-/
theorem recdAccum_strictMono_of_stable
    (taus : Nat → Rat) (depths : Nat → Nat) (N : Nat)
    (hst : ∀ n, n < N → taus n ≥ tauStable) :
    ∀ n, n < N → recdAccum taus depths n < recdAccum taus depths (n + 1) := by
  intro n hn
  rw [recdAccum_succ]
  have htick : 0 < recdTick_unit (taus n) (depths n) :=
    recdTick_unit_pos_of_stable (taus n) (depths n) (hst n hn)
  linarith

/--
  [TEOREMA] Order embedding of discrete index into T on a stable horizon:
  i ≤ j ≤ N ⇒ T_i ≤ T_j; and i < j ≤ N ⇒ T_i < T_j.
-/
theorem recdAccum_le_of_le_stable
    (taus : Nat → Rat) (depths : Nat → Nat) (N : Nat)
    (hst : ∀ n, n < N → taus n ≥ tauStable)
    (i j : Nat) (hij : i ≤ j) (hj : j ≤ N) :
    recdAccum taus depths i ≤ recdAccum taus depths j := by
  induction j, hij using Nat.le_induction with
  | base => exact le_rfl
  | succ j hij ih =>
    have hj' : j < N := Nat.lt_of_lt_of_le (Nat.lt_succ_self j)
      (by omega : j + 1 ≤ N)
    have hstep : recdAccum taus depths j ≤ recdAccum taus depths (j + 1) :=
      recdAccum_monotone_of_stable taus depths N hst j hj'
    exact le_trans (ih (Nat.le_of_succ_le hj)) hstep

theorem recdAccum_lt_of_lt_stable
    (taus : Nat → Rat) (depths : Nat → Nat) (N : Nat)
    (hst : ∀ n, n < N → taus n ≥ tauStable)
    (i j : Nat) (hij : i < j) (hj : j ≤ N) :
    recdAccum taus depths i < recdAccum taus depths j := by
  have hle : i ≤ j := Nat.le_of_lt hij
  -- write j = i + (j - i) with j - i ≥ 1
  have hpos : 0 < j - i := Nat.sub_pos_of_lt hij
  -- chain: T_i < T_{i+1} ≤ T_j
  have hi : i < N := Nat.lt_of_lt_of_le hij hj
  have hstep : recdAccum taus depths i < recdAccum taus depths (i + 1) :=
    recdAccum_strictMono_of_stable taus depths N hst i hi
  have hrest : recdAccum taus depths (i + 1) ≤ recdAccum taus depths j := by
    apply recdAccum_le_of_le_stable taus depths N hst (i + 1) j
    · exact Nat.succ_le_of_lt hij
    · exact hj
  exact lt_of_lt_of_le hstep hrest

/-! ### Amplitude sandwich and bi-Lipschitz bounds -/

/--
  [TEOREMA] Single-tick sandwich under frozen depth and amplitude bounds.
  If m ≤ τ ≤ M and τ ≥ τ_st, then
    δ^{-k}·m ≤ ΔT ≤ δ^{-k}·M.
-/
theorem recdTick_unit_stable_sandwich
    (tau m M : Rat) (k : Nat)
    (hst : tau ≥ tauStable) (hm : m ≤ tau) (hM : tau ≤ M) :
    deltaInvPow k * m ≤ recdTick_unit tau k ∧
      recdTick_unit tau k ≤ deltaInvPow k * M := by
  have heq : recdTick_unit tau k = deltaInvPow k * tau :=
    recdTick_unit_of_stable tau k hst
  have hδ : 0 ≤ deltaInvPow k := deltaInvPow_nonneg k
  constructor
  · rw [heq]
    exact mul_le_mul_of_nonneg_left hm hδ
  · rw [heq]
    exact mul_le_mul_of_nonneg_left hM hδ

/--
  [TEOREMA] Horizon sandwich under frozen depth + uniform amplitude bounds.
  For all n ≤ N,
    n · (δ^{-k★} · m) ≤ T_n ≤ n · (δ^{-k★} · M),
  whenever m ≤ τ_j ≤ M and τ_j ≥ τ_st for all j < N.
-/
theorem recdAccum_stable_sandwich
    (taus : Nat → Rat) (kStar : Nat) (m M : Rat) (N : Nat)
    (hst : ∀ n, n < N → taus n ≥ tauStable)
    (hm : ∀ n, n < N → m ≤ taus n)
    (hM : ∀ n, n < N → taus n ≤ M) :
    ∀ n, n ≤ N →
      (n : Rat) * (deltaInvPow kStar * m) ≤
          recdAccum taus (frozenDepth kStar) n ∧
        recdAccum taus (frozenDepth kStar) n ≤
          (n : Rat) * (deltaInvPow kStar * M) := by
  intro n hn
  induction n with
  | zero =>
    simp [recdAccum_zero]
  | succ n ih =>
    have hn' : n < N := Nat.lt_of_lt_of_le (Nat.lt_succ_self n) hn
    have ih' := ih (Nat.le_of_succ_le hn)
    rw [recdAccum_succ]
    simp only [frozenDepth]
    have htick :=
      recdTick_unit_stable_sandwich (taus n) m M kStar
        (hst n hn') (hm n hn') (hM n hn')
    have hcast : ((n + 1 : Nat) : Rat) = (n : Rat) + 1 := by
      simp [Nat.cast_succ]
    constructor
    · -- lower: T_n + ΔT ≥ n·c_m + c_m = (n+1)·c_m
      have :
          recdAccum taus (frozenDepth kStar) n + recdTick_unit (taus n) kStar ≥
            (n : Rat) * (deltaInvPow kStar * m) + deltaInvPow kStar * m := by
        linarith [ih'.1, htick.1]
      calc
        ((n + 1 : Nat) : Rat) * (deltaInvPow kStar * m)
            = ((n : Rat) + 1) * (deltaInvPow kStar * m) := by rw [hcast]
        _ = (n : Rat) * (deltaInvPow kStar * m) + deltaInvPow kStar * m := by
            ring
        _ ≤ recdAccum taus (frozenDepth kStar) n +
              recdTick_unit (taus n) kStar := this
    · -- upper analogous
      have :
          recdAccum taus (frozenDepth kStar) n + recdTick_unit (taus n) kStar ≤
            (n : Rat) * (deltaInvPow kStar * M) + deltaInvPow kStar * M := by
        linarith [ih'.2, htick.2]
      calc
        recdAccum taus (frozenDepth kStar) n + recdTick_unit (taus n) kStar
            ≤ (n : Rat) * (deltaInvPow kStar * M) + deltaInvPow kStar * M := this
        _ = ((n : Rat) + 1) * (deltaInvPow kStar * M) := by ring
        _ = ((n + 1 : Nat) : Rat) * (deltaInvPow kStar * M) := by rw [hcast]

/--
  [TEOREMA] Discrete bi-Lipschitz of the index map n ↦ T_n on a stable
  frozen-depth horizon with m ≤ τ ≤ M and m > 0:
    ℓ · |a − b| ≤ |T_a − T_b| ≤ L · |a − b|
  with ℓ = δ^{-k★}·m and L = δ^{-k★}·M (here a ≤ b ≤ N).
-/
theorem recdAccum_stable_biLipschitz
    (taus : Nat → Rat) (kStar : Nat) (m M : Rat) (N : Nat)
    (hst : ∀ n, n < N → taus n ≥ tauStable)
    (hm : ∀ n, n < N → m ≤ taus n)
    (hM : ∀ n, n < N → taus n ≤ M)
    (hm0 : 0 < m)
    (a b : Nat) (hab : a ≤ b) (hb : b ≤ N) :
    let ℓ := deltaInvPow kStar * m
    let L := deltaInvPow kStar * M
    ℓ * ((b : Rat) - (a : Rat)) ≤
        recdAccum taus (frozenDepth kStar) b -
          recdAccum taus (frozenDepth kStar) a ∧
      recdAccum taus (frozenDepth kStar) b -
          recdAccum taus (frozenDepth kStar) a ≤
        L * ((b : Rat) - (a : Rat)) := by
  intro ℓ L
  -- reduce to sandwich on the shifted path from a
  -- T_b − T_a = sum of ticks a..b-1
  -- sandwich gives a·c ≤ T_a ≤ a·C and b·c ≤ T_b ≤ b·C,
  -- but difference needs a direct induction on (b - a)
  have hδ : 0 < deltaInvPow kStar := deltaInvPow_pos kStar
  have hℓ : 0 < ℓ := by
    simp only [ℓ]
    exact mul_pos hδ hm0
  -- prove by induction on b starting from a
  induction b, hab using Nat.le_induction with
  | base =>
    simp
  | succ b hab ih =>
    have hb' : b < N := Nat.lt_of_lt_of_le (Nat.lt_succ_self b)
      (by omega : b + 1 ≤ N)
    have ih' := ih (Nat.le_of_succ_le hb)
    rw [recdAccum_succ]
    simp only [frozenDepth]
    have htick :=
      recdTick_unit_stable_sandwich (taus b) m M kStar
        (hst b hb') (hm b hb') (hM b hb')
    have hcast : ((b + 1 : Nat) : Rat) - (a : Rat) =
        ((b : Rat) - (a : Rat)) + 1 := by
      have : ((b + 1 : Nat) : Rat) = (b : Rat) + 1 := by simp [Nat.cast_succ]
      rw [this]
      ring
    constructor
    · -- lower
      have :
          recdAccum taus (frozenDepth kStar) b + recdTick_unit (taus b) kStar -
              recdAccum taus (frozenDepth kStar) a ≥
            ℓ * ((b : Rat) - (a : Rat)) + ℓ := by
        -- ih'.1: ℓ*(b-a) ≤ T_b - T_a; htick.1: ℓ ≤ ΔT (since ℓ = δ^{-k}·m)
        have hℓtick : ℓ ≤ recdTick_unit (taus b) kStar := by
          simp only [ℓ]
          exact htick.1
        linarith [ih'.1, hℓtick]
      calc
        ℓ * (((b + 1 : Nat) : Rat) - (a : Rat))
            = ℓ * (((b : Rat) - (a : Rat)) + 1) := by rw [hcast]
        _ = ℓ * ((b : Rat) - (a : Rat)) + ℓ := by ring
        _ ≤ recdAccum taus (frozenDepth kStar) b +
              recdTick_unit (taus b) kStar -
              recdAccum taus (frozenDepth kStar) a := this
    · -- upper
      have hLtick : recdTick_unit (taus b) kStar ≤ L := by
        simp only [L]
        exact htick.2
      have :
          recdAccum taus (frozenDepth kStar) b + recdTick_unit (taus b) kStar -
              recdAccum taus (frozenDepth kStar) a ≤
            L * ((b : Rat) - (a : Rat)) + L := by
        linarith [ih'.2, hLtick]
      calc
        recdAccum taus (frozenDepth kStar) b + recdTick_unit (taus b) kStar -
            recdAccum taus (frozenDepth kStar) a
            ≤ L * ((b : Rat) - (a : Rat)) + L := this
        _ = L * (((b : Rat) - (a : Rat)) + 1) := by ring
        _ = L * (((b + 1 : Nat) : Rat) - (a : Rat)) := by rw [hcast]

/--
  [TEOREMA] CT-1 mesh form: bi-Lipschitz of classical mesh parameter
  s_n = n·h versus T_n under stable frozen depth and amplitude bounds.
  With ℓ = δ^{-k★}·m / h and L = δ^{-k★}·M / h (h > 0):
    ℓ · (s_b − s_a) ≤ T_b − T_a ≤ L · (s_b − s_a)   (a ≤ b ≤ N).
-/
theorem recdAccum_stable_biLipschitz_mesh
    (taus : Nat → Rat) (kStar : Nat) (m M h : Rat) (N : Nat)
    (hst : ∀ n, n < N → taus n ≥ tauStable)
    (hm : ∀ n, n < N → m ≤ taus n)
    (hM : ∀ n, n < N → taus n ≤ M)
    (hm0 : 0 < m) (hh : 0 < h)
    (a b : Nat) (hab : a ≤ b) (hb : b ≤ N) :
    let ℓ := deltaInvPow kStar * m / h
    let L := deltaInvPow kStar * M / h
    ℓ * (meshTime h b - meshTime h a) ≤
        recdAccum taus (frozenDepth kStar) b -
          recdAccum taus (frozenDepth kStar) a ∧
      recdAccum taus (frozenDepth kStar) b -
          recdAccum taus (frozenDepth kStar) a ≤
        L * (meshTime h b - meshTime h a) := by
  intro ℓ L
  have hbilip :=
    recdAccum_stable_biLipschitz taus kStar m M N hst hm hM hm0 a b hab hb
  have hmesh : meshTime h b - meshTime h a =
      ((b : Rat) - (a : Rat)) * h := by
    simp only [meshTime]
    ring
  have hh0 : h ≠ 0 := ne_of_gt hh
  constructor
  · -- lower: (δ^{-k} m / h) · ((b-a)·h) = δ^{-k} m · (b-a)
    have h1 := hbilip.1
    simp only [ℓ] at *
    -- rewrite goal using hmesh
    have hrewrite :
        (deltaInvPow kStar * m / h) * (meshTime h b - meshTime h a) =
          deltaInvPow kStar * m * ((b : Rat) - (a : Rat)) := by
      rw [hmesh]
      field_simp [hh0]
      ring
    rw [hrewrite]
    -- h1: (δ^{-k}·m)·(b−a) ≤ T_b − T_a
    simpa [mul_assoc] using h1
  · have h2 := hbilip.2
    simp only [L] at *
    have hrewrite :
        (deltaInvPow kStar * M / h) * (meshTime h b - meshTime h a) =
          deltaInvPow kStar * M * ((b : Rat) - (a : Rat)) := by
      rw [hmesh]
      field_simp [hh0]
      ring
    rw [hrewrite]
    simpa [mul_assoc] using h2

/-! ### Sample: constant stable path -/

/-- Constant stable sample τ ≡ 3/4 ≥ τ_st. -/
def constStable (_n : Nat) : Rat := 3 / 4

/--
  [TEOREMA] Sample CT-1: constant stable path at depth 0 is exactly
  T_n = n · (3/4), hence bi-Lipschitz with ℓ = L = 3/4.
-/
theorem recdAccum_constStable_exact (n : Nat) :
    recdAccum constStable (frozenDepth 0) n = (n : Rat) * (3 / 4) := by
  induction n with
  | zero => simp [recdAccum_zero]
  | succ n ih =>
    rw [recdAccum_succ, ih]
    simp only [frozenDepth, constStable]
    have htick : recdTick_unit (3 / 4) 0 = 3 / 4 := by
      rw [recdTick_unit_of_stable (3 / 4) 0 (by native_decide)]
      simp [deltaInvPow]
    rw [htick]
    have hcast : ((n + 1 : Nat) : Rat) = (n : Rat) + 1 := by
      simp [Nat.cast_succ]
    rw [hcast]
    ring

theorem recdAccum_constStable_strictMono (n : Nat) :
    recdAccum constStable (frozenDepth 0) n <
      recdAccum constStable (frozenDepth 0) (n + 1) := by
  rw [recdAccum_constStable_exact, recdAccum_constStable_exact]
  have hcast : ((n + 1 : Nat) : Rat) = (n : Rat) + 1 := by
    simp [Nat.cast_succ]
  rw [hcast]
  -- n·(3/4) < (n+1)·(3/4)
  have : (0 : Rat) < 3 / 4 := by native_decide
  linarith

/--
  [TEOREMA] Immersion slope on the constant stable path is (3/4)/h ≥ 0.
-/
theorem immerseSlope_constStable_nonneg (h : Rat) (hh : 0 < h) (n : Nat) :
    0 ≤ immerseSlope constStable (frozenDepth 0) h n := by
  apply immerseSlope_nonneg_of_tick_nonneg
  · exact hh
  · have hst : constStable n ≥ tauStable := by
      simp only [constStable]
      native_decide
    exact le_of_lt (recdTick_unit_pos_of_stable (constStable n) 0 hst)

/--
  [TEOREMA] σ_RECD on the constant stable path equals the immersion slope
  (CT-4B + CT-1 alignment).
-/
theorem sigmaRECD_constStable_eq_slope
    (alpha h : Rat) (n : Nat) :
    sigmaRECD constStable (frozenDepth 0) alpha h n =
      immerseSlope constStable (frozenDepth 0) h n := by
  apply sigmaRECD_eq_immerseSlope_of_gate_nonneg
  -- g(3/4) = 1 ≥ 0
  simp only [constStable]
  rw [gate_of_stable (3 / 4) (by native_decide)]
  native_decide

end SystemicTau
