/-
  CT-2 elementary half: global orientation obstruction under sustained
  anti-synchronization (infinite visits / positive lower density).

  Module CT (docs/RECD_vs_Thermodynamic_Time.md), Statement CT-2.
  [TEOREMA] under exact (non-estimated) τ sequences on ℚ:
    · anti-sync + |τ| ≥ c > 0 ⇒ ΔT ≤ −c·δ^{-k} < 0
    · infinitely often anti-sync ⇒ T not eventually nondecreasing
    · positive lower density of anti-sync + frozen depth + amp. lower
      bound ⇒ reverse mass grows at least linearly
    · immersion on a negative-tick cell is not monotone in θ
    · period-2 sample: neither eventually nondec. nor noninc.

  Open residual (not in this module): categorical non-existence of
  orientation-preserving intertwining functors with continuum semigroups.
-/
import SystemicTau.RECD_Variation
import SystemicTau.RECD_Immersion
import SystemicTau.RECD_CT1

namespace SystemicTau

/-! ### Amplitude lower bound on the anti-sync cone -/

/--
  [TEOREMA] Anti-sync forces |τ| ≥ τ_ch > 0.
-/
theorem absRat_ge_tauChaos_of_antiSync
    (tau : Rat) (h : tau ≤ -tauChaos) :
    tauChaos ≤ absRat tau := by
  have hnonpos : tau ≤ 0 :=
    le_trans h (by native_decide : (-tauChaos : Rat) ≤ 0)
  have habs : absRat tau = -tau := absRat_of_nonpos hnonpos
  have : -tau ≥ tauChaos := by linarith
  simpa [habs] using this

/-- [TEOREMA] τ_ch > 0 (operational threshold). -/
theorem tauChaos_pos : (0 : Rat) < tauChaos := by native_decide

/-! ### Strictly negative tick on anti-sync with amplitude floor -/

/--
  [TEOREMA] CT-2 claim 1 (per step):
  if τ ≤ −τ_ch and |τ| ≥ c > 0, then
    ΔT = −δ^{-k}·|τ| ≤ −δ^{-k}·c < 0.
-/
theorem recdTick_unit_antiSync_le_neg
    (tau : Rat) (k : Nat) (c : Rat)
    (hanti : tau ≤ -tauChaos) (hc0 : 0 < c) (hc : c ≤ absRat tau) :
    recdTick_unit tau k ≤ -(deltaInvPow k * c) ∧
      recdTick_unit tau k < 0 := by
  have hg : gate tau = -1 := gate_of_antiSync tau hanti
  have hδ : 0 < deltaInvPow k := deltaInvPow_pos k
  have hδ0 : 0 ≤ deltaInvPow k := le_of_lt hδ
  have heq : recdTick_unit tau k = -(deltaInvPow k * absRat tau) := by
    simp only [recdTick_unit, deltaT_unit, hg, neg_mul, one_mul]
  constructor
  · rw [heq]
    have : deltaInvPow k * c ≤ deltaInvPow k * absRat tau :=
      mul_le_mul_of_nonneg_left hc hδ0
    linarith
  · rw [heq]
    have hprod : 0 < deltaInvPow k * c := mul_pos hδ hc0
    have hge : deltaInvPow k * c ≤ deltaInvPow k * absRat tau :=
      mul_le_mul_of_nonneg_left hc hδ0
    linarith

/--
  [TEOREMA] Default amplitude floor c = τ_ch on the anti-sync cone.
-/
theorem recdTick_unit_antiSync_lt_zero
    (tau : Rat) (k : Nat) (hanti : tau ≤ -tauChaos) :
    recdTick_unit tau k ≤ -(deltaInvPow k * tauChaos) ∧
      recdTick_unit tau k < 0 :=
  recdTick_unit_antiSync_le_neg tau k tauChaos hanti
    tauChaos_pos (absRat_ge_tauChaos_of_antiSync tau hanti)

/-! ### Infinitely often anti-sync -/

/--
  [OPERACIONAL] Infinitely many anti-sync visits with amplitude floor c:
  ∀ N, ∃ n ≥ N with τ_n ≤ −τ_ch and |τ_n| ≥ c.
-/
def InfOftenAntiSync (taus : Nat → Rat) (c : Rat) : Prop :=
  ∀ N : Nat, ∃ n : Nat, N ≤ n ∧ taus n ≤ -tauChaos ∧ c ≤ absRat (taus n)

/--
  [TEOREMA] InfOften anti-sync ⇒ infinitely many strictly negative ticks
  (any depth schedule).
-/
theorem InfOftenAntiSync.neg_ticks
    (taus : Nat → Rat) (depths : Nat → Nat) (c : Rat)
    (hc0 : 0 < c) (h : InfOftenAntiSync taus c) :
    ∀ N : Nat, ∃ n : Nat, N ≤ n ∧
      recdTick_unit (taus n) (depths n) ≤ -(deltaInvPow (depths n) * c) ∧
        recdTick_unit (taus n) (depths n) < 0 := by
  intro N
  obtain ⟨n, hn, hanti, hc⟩ := h N
  have htick := recdTick_unit_antiSync_le_neg (taus n) (depths n) c hanti hc0 hc
  exact ⟨n, hn, htick.1, htick.2⟩

/--
  [TEOREMA] CT-2 claim 2 (elementary half):
  under infinitely often anti-sync with |τ| ≥ c > 0, the accumulator
  T is **not eventually nondecreasing**.
  Classical thermodynamic time requires eventual nondecreasing parameter
  orientation; RECD fails it on this trajectory class.
-/
theorem not_eventually_nondecreasing_of_InfOftenAntiSync
    (taus : Nat → Rat) (depths : Nat → Nat) (c : Rat)
    (hc0 : 0 < c) (h : InfOftenAntiSync taus c) :
    ¬ ∃ N0 : Nat, ∀ n : Nat, N0 ≤ n →
        recdAccum taus depths n ≤ recdAccum taus depths (n + 1) := by
  intro hmono
  obtain ⟨N0, hN0⟩ := hmono
  obtain ⟨n, hn, _, hneg⟩ := InfOftenAntiSync.neg_ticks taus depths c hc0 h N0
  have hle : recdAccum taus depths n ≤ recdAccum taus depths (n + 1) :=
    hN0 n hn
  have hnn : 0 ≤ recdTick_unit (taus n) (depths n) :=
    (recdAccum_le_succ_iff taus depths n).1 hle
  exact not_lt_of_ge hnn hneg

/-- Convenience: default floor c = τ_ch. -/
theorem not_eventually_nondecreasing_of_InfOftenAntiSync_default
    (taus : Nat → Rat) (depths : Nat → Nat)
    (h : InfOftenAntiSync taus tauChaos) :
    ¬ ∃ N0 : Nat, ∀ n : Nat, N0 ≤ n →
        recdAccum taus depths n ≤ recdAccum taus depths (n + 1) :=
  not_eventually_nondecreasing_of_InfOftenAntiSync taus depths tauChaos
    tauChaos_pos h

/-! ### Positive lower density of anti-sync visits -/

/--
  [OPERACIONAL] Lower density bound holding on every finite horizon:
    d · N ≤ # { n < N | τ_n ≤ −τ_ch }.
  (Discrete stand-in for liminf density ≥ d; no ℝ / Tendsto.)
-/
def HasAntiSyncLowerDensity (taus : Nat → Rat) (d : Rat) : Prop :=
  ∀ N : Nat, d * (N : Rat) ≤ (antiSyncCount taus N : Rat)

/-- Count is monotone. -/
theorem antiSyncCount_mono (taus : Nat → Rat) {a b : Nat} (h : a ≤ b) :
    antiSyncCount taus a ≤ antiSyncCount taus b := by
  induction b, h using Nat.le_induction with
  | base => exact le_rfl
  | succ b _ ih =>
    rw [antiSyncCount_succ]
    exact Nat.le_trans ih (Nat.le_add_right _ _)

/--
  [TEOREMA] If the anti-sync counter strictly increases from a to b,
  some visit lies in [a, b).
-/
theorem exists_antiSync_of_count_lt
    (taus : Nat → Rat) (a b : Nat)
    (hcnt : antiSyncCount taus a < antiSyncCount taus b) (hle : a ≤ b) :
    ∃ n, a ≤ n ∧ n < b ∧ taus n ≤ -tauChaos := by
  induction b, hle using Nat.le_induction with
  | base =>
    exact (lt_irrefl _ hcnt).elim
  | succ b hle ih =>
    by_cases hanti : taus b ≤ -tauChaos
    · exact ⟨b, hle, Nat.lt_succ_self b, hanti⟩
    · have hcb : antiSyncCount taus (b + 1) = antiSyncCount taus b :=
        antiSyncCount_succ_not_anti taus b hanti
      have hcnt' : antiSyncCount taus a < antiSyncCount taus b := by
        rwa [hcb] at hcnt
      obtain ⟨n, hn0, hnb, hτ⟩ := ih hcnt'
      exact ⟨n, hn0, Nat.lt_trans hnb (Nat.lt_succ_self b), hτ⟩

/--
  [TEOREMA] Positive lower density ⇒ the anti-sync counter is unbounded.
  Uses the denominator of d: d · d.den = d.num ≥ 1 when d > 0.
-/
theorem antiSyncCount_unbounded_of_lowerDensity
    (taus : Nat → Rat) (d : Rat)
    (hd : 0 < d) (hden : HasAntiSyncLowerDensity taus d) :
    ∀ B : Nat, ∃ M : Nat, B < antiSyncCount taus M := by
  intro B
  -- Choose M so that d · M ≥ B + 1. Take M = (B + 1) * d.den.
  -- Then d · M = (B + 1) * (d · d.den) = (B + 1) * d.num ≥ B + 1.
  -- d ≥ 1/d.den > 0, so M = (B+1)*d.den gives d·M ≥ B+1.
  let M := (B + 1) * d.den
  have hdenpos : (0 : Nat) < d.den := d.den_pos
  have hdne : (d.den : Rat) ≠ 0 := by
    exact_mod_cast (ne_of_gt hdenpos)
  have hnumpos : (0 : Int) < d.num := Rat.num_pos.mpr hd
  have hnum1 : (1 : Int) ≤ d.num := (Int.lt_iff_add_one_le).mp hnumpos
  have hge_inv : (1 : Rat) / (d.den : Rat) ≤ d := by
    -- 1/den ≤ num/den ⇔ 1 ≤ num (den > 0)
    have hden_pos_rat : (0 : Rat) < (d.den : Rat) := by exact_mod_cast hdenpos
    rw [div_le_iff₀ hden_pos_rat]
    have : d * (d.den : Rat) = (d.num : Rat) := by
      calc
        d * (d.den : Rat)
            = ((d.num : Rat) / (d.den : Rat)) * (d.den : Rat) := by
              rw [Rat.num_div_den]
        _ = (d.num : Rat) := by
              field_simp [hdne]
    rw [this]
    exact_mod_cast hnum1
  have hMcast : (M : Rat) = ((B + 1 : Nat) : Rat) * (d.den : Rat) := by
    simp only [M]; exact_mod_cast rfl
  have hge : ((B + 1 : Nat) : Rat) ≤ d * (M : Rat) := by
    rw [hMcast]
    -- d * ((B+1)*den) ≥ (1/den) * ((B+1)*den) = B+1
    have h1 :
        ((1 : Rat) / (d.den : Rat)) * (((B + 1 : Nat) : Rat) * (d.den : Rat)) ≤
          d * (((B + 1 : Nat) : Rat) * (d.den : Rat)) := by
      have hnn : (0 : Rat) ≤ ((B + 1 : Nat) : Rat) * (d.den : Rat) :=
        mul_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)
      exact mul_le_mul_of_nonneg_right hge_inv hnn
    have h2 :
        ((1 : Rat) / (d.den : Rat)) * (((B + 1 : Nat) : Rat) * (d.den : Rat)) =
          ((B + 1 : Nat) : Rat) := by
      field_simp [hdne]
    linarith
  have hcnt : d * (M : Rat) ≤ (antiSyncCount taus M : Rat) := hden M
  have : ((B + 1 : Nat) : Rat) ≤ (antiSyncCount taus M : Rat) :=
    le_trans hge hcnt
  refine ⟨M, ?_⟩
  have hB1 : (B : Rat) + 1 ≤ (antiSyncCount taus M : Rat) := by
    have : ((B + 1 : Nat) : Rat) = (B : Rat) + 1 := by exact_mod_cast rfl
    rwa [← this]
  have hcast : (B : Rat) < (antiSyncCount taus M : Rat) := by linarith
  exact_mod_cast hcast

/--
  [TEOREMA] Positive lower density ⇒ InfOften anti-sync
  (with default amplitude floor τ_ch via the cone law).
-/
theorem InfOftenAntiSync_of_lowerDensity
    (taus : Nat → Rat) (d : Rat)
    (hd : 0 < d) (hden : HasAntiSyncLowerDensity taus d) :
    InfOftenAntiSync taus tauChaos := by
  intro N
  let C := antiSyncCount taus N
  obtain ⟨M, hM⟩ :=
    antiSyncCount_unbounded_of_lowerDensity taus d hd hden C
  -- count N = C < count M ⇒ visit in [N, M) if N ≤ M; else if M < N,
  -- mono gives count M ≤ count N = C, contradiction.
  have hNM : N ≤ M := by
    by_contra hlt
    have hlt' : M < N := Nat.lt_of_not_ge hlt
    have hmono := antiSyncCount_mono taus (Nat.le_of_lt hlt')
    -- count M ≤ count N = C, but C < count M
    exact not_lt_of_ge hmono hM
  have hcnt : antiSyncCount taus N < antiSyncCount taus M := hM
  obtain ⟨n, hn0, _, hanti⟩ := exists_antiSync_of_count_lt taus N M hcnt hNM
  exact ⟨n, hn0, hanti, absRat_ge_tauChaos_of_antiSync (taus n) hanti⟩

/--
  [TEOREMA] CT-2 density form: positive lower density of anti-sync
  ⇒ T not eventually nondecreasing (any depth schedule).
-/
theorem not_eventually_nondecreasing_of_lowerDensity
    (taus : Nat → Rat) (depths : Nat → Nat) (d : Rat)
    (hd : 0 < d) (hden : HasAntiSyncLowerDensity taus d) :
    ¬ ∃ N0 : Nat, ∀ n : Nat, N0 ≤ n →
        recdAccum taus depths n ≤ recdAccum taus depths (n + 1) :=
  not_eventually_nondecreasing_of_InfOftenAntiSync_default taus depths
    (InfOftenAntiSync_of_lowerDensity taus d hd hden)

/-! ### Reverse-mass linear growth under density + frozen depth -/

/--
  [TEOREMA] On anti-sync with |τ| ≥ c, reverse mass of one tick is
  ≥ δ^{-k}·c (exactly −ΔT = δ^{-k}|τ| ≥ δ^{-k}·c).
-/
theorem negPart_tick_antiSync_ge
    (tau : Rat) (k : Nat) (c : Rat)
    (hanti : tau ≤ -tauChaos) (hc0 : 0 < c) (hc : c ≤ absRat tau) :
    deltaInvPow k * c ≤ negPart (recdTick_unit tau k) := by
  have htick := recdTick_unit_antiSync_le_neg tau k c hanti hc0 hc
  have hle0 : recdTick_unit tau k ≤ 0 := le_of_lt htick.2
  have hn : negPart (recdTick_unit tau k) = -recdTick_unit tau k :=
    (negPart_of_nonpos hle0).2
  rw [hn]
  linarith [htick.1]

/--
  [TEOREMA] Under frozen depth and |τ| ≥ c on every anti-sync visit,
  reverse mass grows at least as (δ^{-k★}·c) · (# anti-sync).
-/
theorem negVarAccum_ge_antiSync_mass
    (taus : Nat → Rat) (kStar : Nat) (c : Rat) (N : Nat)
    (hc0 : 0 < c)
    (hamp : ∀ n, n < N → taus n ≤ -tauChaos → c ≤ absRat (taus n)) :
    deltaInvPow kStar * c * (antiSyncCount taus N : Rat) ≤
      negVarAccum taus (frozenDepth kStar) N := by
  induction N with
  | zero =>
    simp [negVarAccum_zero, antiSyncCount_zero]
  | succ N ih =>
    rw [negVarAccum_succ, antiSyncCount_succ]
    simp only [frozenDepth]
    have ih' :
        deltaInvPow kStar * c * (antiSyncCount taus N : Rat) ≤
          negVarAccum taus (frozenDepth kStar) N := by
      apply ih
      intro n hn hanti
      exact hamp n (Nat.lt_trans hn (Nat.lt_succ_self N)) hanti
    by_cases hanti : taus N ≤ -tauChaos
    · have hcN : c ≤ absRat (taus N) := hamp N (Nat.lt_succ_self N) hanti
      have hnp :
          deltaInvPow kStar * c ≤
            negPart (recdTick_unit (taus N) kStar) :=
        negPart_tick_antiSync_ge (taus N) kStar c hanti hc0 hcN
      simp only [hanti, ite_true]
      have hcast :
          ((antiSyncCount taus N + 1 : Nat) : Rat) =
            (antiSyncCount taus N : Rat) + 1 := by
        exact_mod_cast rfl
      have hsum :
          deltaInvPow kStar * c * (antiSyncCount taus N : Rat) +
              deltaInvPow kStar * c ≤
            negVarAccum taus (frozenDepth kStar) N +
              negPart (recdTick_unit (taus N) kStar) := by
        linarith [ih', hnp]
      have hmul :
          deltaInvPow kStar * c * (antiSyncCount taus N : Rat) +
              deltaInvPow kStar * c =
            deltaInvPow kStar * c *
              ((antiSyncCount taus N : Rat) + 1) := by
        ring
      rw [hmul] at hsum
      rwa [← hcast] at hsum
    · have hnp : negPart (recdTick_unit (taus N) kStar) = 0 :=
        negPart_tick_of_not_antiSync (taus N) kStar hanti
      simp only [hanti, ite_false, hnp, add_zero]
      simpa using ih'

/--
  [TEOREMA] Density + frozen depth + amplitude floor ⇒ linear reverse mass:
    δ^{-k★}·c·d · N ≤ ∑_{n<N} ΔT_n⁻.
-/
theorem negVarAccum_ge_linear_of_density
    (taus : Nat → Rat) (kStar : Nat) (c d : Rat) (N : Nat)
    (hc0 : 0 < c)
    (hden : HasAntiSyncLowerDensity taus d)
    (hamp : ∀ n, n < N → taus n ≤ -tauChaos → c ≤ absRat (taus n)) :
    deltaInvPow kStar * c * d * (N : Rat) ≤
      negVarAccum taus (frozenDepth kStar) N := by
  have hmass :
      deltaInvPow kStar * c * (antiSyncCount taus N : Rat) ≤
        negVarAccum taus (frozenDepth kStar) N :=
    negVarAccum_ge_antiSync_mass taus kStar c N hc0 hamp
  have hcnt : d * (N : Rat) ≤ (antiSyncCount taus N : Rat) := hden N
  have hδc : 0 ≤ deltaInvPow kStar * c :=
    mul_nonneg (deltaInvPow_nonneg kStar) (le_of_lt hc0)
  have h1 :
      deltaInvPow kStar * c * (d * (N : Rat)) ≤
        deltaInvPow kStar * c * (antiSyncCount taus N : Rat) :=
    mul_le_mul_of_nonneg_left hcnt hδc
  have h2 :
      deltaInvPow kStar * c * d * (N : Rat) =
        deltaInvPow kStar * c * (d * (N : Rat)) := by
    ring
  linarith

/-! ### Immersion non-monotonicity on a negative-tick cell -/

/--
  [TEOREMA] CT-2 immersion fragment:
  if ΔT_n < 0 then the affine immersion on cell n is not nondecreasing in θ
  (take θ₁ = 0 < 1 = θ₂ ⇒ ι(θ₂) < ι(θ₁)).
-/
theorem immerseAffine_not_mono_of_neg_tick
    (taus : Nat → Rat) (depths : Nat → Nat) (n : Nat)
    (hneg : recdTick_unit (taus n) (depths n) < 0) :
    ¬ (∀ θ₁ θ₂ : Rat, θ₁ ≤ θ₂ →
        immerseAffine taus depths n θ₁ ≤ immerseAffine taus depths n θ₂) := by
  intro hmono
  have h01 : (0 : Rat) ≤ 1 := by native_decide
  have hle := hmono 0 1 h01
  simp only [immerseAffine, zero_mul, add_zero, one_mul] at hle
  linarith

/--
  [TEOREMA] Explicit descent on a negative cell: θ₁ < θ₂ and ΔT < 0
  ⇒ ι(θ₂) < ι(θ₁).
-/
theorem immerseAffine_strict_anti_of_neg_tick
    (taus : Nat → Rat) (depths : Nat → Nat) (n : Nat)
    (hneg : recdTick_unit (taus n) (depths n) < 0)
    (θ₁ θ₂ : Rat) (hθ : θ₁ < θ₂) :
    immerseAffine taus depths n θ₂ < immerseAffine taus depths n θ₁ := by
  simp only [immerseAffine]
  have hdiff : 0 < θ₂ - θ₁ := sub_pos.mpr hθ
  nlinarith

/-! ### Samples: constant anti-sync (density 1) -/

/--
  [TEOREMA] Constant anti-sync path has lower density d = 1.
-/
theorem constAntiSync_lowerDensity :
    HasAntiSyncLowerDensity constAntiSync 1 := by
  intro N
  have hcnt : antiSyncCount constAntiSync N = N := by
    induction N with
    | zero => rfl
    | succ N ih =>
      have hanti : constAntiSync N ≤ -tauChaos := by
        simp only [constAntiSync, tauChaos]
        native_decide
      rw [antiSyncCount_succ_anti _ _ hanti, ih]
  simp only [hcnt, one_mul]
  exact le_rfl

/--
  [TEOREMA] Constant anti-sync is InfOften with floor τ_ch.
-/
theorem constAntiSync_InfOften :
    InfOftenAntiSync constAntiSync tauChaos :=
  InfOftenAntiSync_of_lowerDensity constAntiSync 1
    (by native_decide : (0 : Rat) < 1) constAntiSync_lowerDensity

/--
  [TEOREMA] CT-2 sample: constant anti-sync ⇒ T not eventually nondecreasing.
  (Strengthens the finite-horizon strict descent already in RECD_Monotonicity.)
-/
theorem constAntiSync_not_eventually_nondecreasing :
    ¬ ∃ N0 : Nat, ∀ n : Nat, N0 ≤ n →
        recdAccum constAntiSync constDepth0 n ≤
          recdAccum constAntiSync constDepth0 (n + 1) :=
  not_eventually_nondecreasing_of_InfOftenAntiSync_default
    constAntiSync constDepth0 constAntiSync_InfOften

/--
  [TEOREMA] On constant anti-sync, reverse mass = −T_N = N·(3/4).
-/
theorem negVarAccum_constAntiSync (N : Nat) :
    negVarAccum constAntiSync constDepth0 N = (N : Rat) * (3 / 4) := by
  induction N with
  | zero => simp [negVarAccum]
  | succ N ih =>
    rw [negVarAccum_succ, ih]
    have htick : recdTick_unit (constAntiSync N) (constDepth0 N) =
        -(3 / 4 : Rat) := by
      simp only [constAntiSync, constDepth0, recdTick_unit, deltaT_unit, deltaInvPow]
      have hg : gate (-3 / 4 : Rat) = -1 := gate_anti_neg
      have habs : absRat (-3 / 4 : Rat) = 3 / 4 := by native_decide
      simp [hg, habs]
    have hnp : negPart (recdTick_unit (constAntiSync N) (constDepth0 N)) =
        (3 / 4 : Rat) := by
      rw [htick]
      simp only [negPart]
      split_ifs with h
      · exact (not_le_of_gt (by native_decide : (-(3 / 4) : Rat) < 0) h).elim
      · ring
    have hcast : ((N + 1 : Nat) : Rat) = (N : Rat) + 1 := by exact_mod_cast rfl
    rw [hnp, hcast]
    ring

/-! ### Sample: period-2 anti-sync / stable alternation (density 1/2) -/

/--
  [OPERACIONAL] Period-2 sample: even indices anti-sync (−3/4),
  odd indices stable (+3/4). Lower density d = 1/2.
-/
def period2AntiSync (n : Nat) : Rat :=
  if n % 2 = 0 then -3 / 4 else 3 / 4

theorem period2AntiSync_even (k : Nat) :
    period2AntiSync (2 * k) = -3 / 4 := by
  unfold period2AntiSync
  rw [if_pos (Nat.mul_mod_right 2 k)]

theorem period2AntiSync_odd (k : Nat) :
    period2AntiSync (2 * k + 1) = 3 / 4 := by
  unfold period2AntiSync
  have hmod : (2 * k + 1) % 2 = 1 := by
    rw [Nat.add_mod, Nat.mul_mod_right]
  have hne : ¬ (2 * k + 1) % 2 = 0 := by
    rw [hmod]; native_decide
  rw [if_neg hne]

/-- Exactly one of two consecutive indices is anti-sync on period-2. -/
theorem antiSyncCount_period2_add_two (n : Nat) :
    antiSyncCount period2AntiSync (n + 2) =
      antiSyncCount period2AntiSync n + 1 := by
  rw [antiSyncCount_succ, antiSyncCount_succ]
  by_cases he : n % 2 = 0
  · have hanti : period2AntiSync n ≤ -tauChaos := by
      unfold period2AntiSync; rw [if_pos he]; native_decide
    have hodd : (n + 1) % 2 = 1 := by
      rw [Nat.add_mod, he]
    have hne : ¬ (n + 1) % 2 = 0 := by rw [hodd]; native_decide
    have hnot : ¬ period2AntiSync (n + 1) ≤ -tauChaos := by
      unfold period2AntiSync; rw [if_neg hne]; native_decide
    simp [hanti, hnot]
  · have hodd : n % 2 = 1 := Nat.mod_two_ne_zero.mp he
    have hne0 : ¬ n % 2 = 0 := he
    have hnot : ¬ period2AntiSync n ≤ -tauChaos := by
      unfold period2AntiSync; rw [if_neg hne0]; native_decide
    have heven : (n + 1) % 2 = 0 := by
      rw [Nat.add_mod, hodd]
    have hanti : period2AntiSync (n + 1) ≤ -tauChaos := by
      unfold period2AntiSync; rw [if_pos heven]; native_decide
    simp [hnot, hanti]

/--
  Anti-sync count on period-2 equals ⌈N/2⌉ = (N + 1) / 2 in Nat division.
-/
theorem antiSyncCount_period2 : ∀ N : Nat,
    antiSyncCount period2AntiSync N = (N + 1) / 2
  | 0 => rfl
  | 1 => by
    have hanti : period2AntiSync 0 ≤ -tauChaos := by
      simp only [period2AntiSync]
      native_decide
    simp [antiSyncCount, hanti]
  | n + 2 => by
    rw [antiSyncCount_period2_add_two n, antiSyncCount_period2 n]
    -- (n+1)/2 + 1 = (n+3)/2
    omega

/--
  [TEOREMA] Period-2 sample has lower density d = 1/2
  (since (N+1)/2 ≥ N/2 for all N).
-/
theorem period2AntiSync_lowerDensity :
    HasAntiSyncLowerDensity period2AntiSync (1 / 2) := by
  intro N
  rw [antiSyncCount_period2]
  -- (1/2)·N ≤ (N+1)/2 as rationals
  have hnat : N ≤ 2 * ((N + 1) / 2) := by omega
  have hle : (N : Rat) ≤ 2 * (((N + 1) / 2 : Nat) : Rat) := by
    exact_mod_cast hnat
  have : (N : Rat) * (1 / 2) ≤ (((N + 1) / 2 : Nat) : Rat) := by
    calc
      (N : Rat) * (1 / 2)
          = (N : Rat) / 2 := by ring
      _ ≤ (2 * (((N + 1) / 2 : Nat) : Rat)) / 2 :=
          div_le_div_of_nonneg_right hle (by native_decide : (0 : Rat) ≤ 2)
      _ = (((N + 1) / 2 : Nat) : Rat) := by ring
  simpa [mul_comm] using this

/--
  [TEOREMA] CT-2 sample: period-2 anti-sync/stable ⇒ T not eventually
  nondecreasing (positive density 1/2, mixed signs).
-/
theorem period2AntiSync_not_eventually_nondecreasing :
    ¬ ∃ N0 : Nat, ∀ n : Nat, N0 ≤ n →
        recdAccum period2AntiSync constDepth0 n ≤
          recdAccum period2AntiSync constDepth0 (n + 1) :=
  not_eventually_nondecreasing_of_lowerDensity period2AntiSync constDepth0
    (1 / 2) (by native_decide) period2AntiSync_lowerDensity

/--
  [TEOREMA] Period-2 exact ticks at depth 0:
  even n ⇒ ΔT = −3/4; odd n ⇒ ΔT = +3/4.
-/
theorem recdTick_period2_even (k : Nat) :
    recdTick_unit (period2AntiSync (2 * k)) 0 = -(3 / 4) := by
  rw [period2AntiSync_even]
  simp only [recdTick_unit, deltaT_unit, deltaInvPow]
  have hg : gate (-3 / 4 : Rat) = -1 := gate_anti_neg
  have habs : absRat (-3 / 4 : Rat) = 3 / 4 := by native_decide
  simp [hg, habs]

theorem recdTick_period2_odd (k : Nat) :
    recdTick_unit (period2AntiSync (2 * k + 1)) 0 = 3 / 4 := by
  rw [period2AntiSync_odd]
  have hst : (3 / 4 : Rat) ≥ tauStable := by native_decide
  rw [recdTick_unit_of_stable (3 / 4) 0 hst]
  simp [deltaInvPow]

/--
  [TEOREMA] On period-2 at depth 0, after 2m steps: T_{2m} = 0.
-/
theorem recdAccum_period2_even (m : Nat) :
    recdAccum period2AntiSync constDepth0 (2 * m) = 0 := by
  induction m with
  | zero => simp [recdAccum_zero]
  | succ m ih =>
    have h2 : 2 * (m + 1) = 2 * m + 1 + 1 := by ring
    rw [h2, recdAccum_succ, recdAccum_succ]
    simp only [constDepth0]
    rw [recdTick_period2_even m, recdTick_period2_odd m, ih]
    ring

/--
  [TEOREMA] On period-2 at depth 0, after 2m+1 steps: T_{2m+1} = −3/4.
-/
theorem recdAccum_period2_odd (m : Nat) :
    recdAccum period2AntiSync constDepth0 (2 * m + 1) = -(3 / 4) := by
  rw [recdAccum_succ]
  simp only [constDepth0]
  rw [recdAccum_period2_even m, recdTick_period2_even m]
  ring

/--
  [TEOREMA] Period-2 is not eventually nonincreasing either:
  every odd→even step increases T (stable recovery).
-/
theorem period2AntiSync_not_eventually_nonincreasing :
    ¬ ∃ N0 : Nat, ∀ n : Nat, N0 ≤ n →
        recdAccum period2AntiSync constDepth0 (n + 1) ≤
          recdAccum period2AntiSync constDepth0 n := by
  intro hmono
  obtain ⟨N0, hN0⟩ := hmono
  let n := 2 * N0 + 1
  have hn : N0 ≤ n := by simp only [n]; omega
  have hle := hN0 n hn
  have htick : recdTick_unit (period2AntiSync n) 0 = 3 / 4 := by
    simp only [n]
    exact recdTick_period2_odd N0
  have hsucc :
      recdAccum period2AntiSync constDepth0 (n + 1) =
        recdAccum period2AntiSync constDepth0 n +
          recdTick_unit (period2AntiSync n) 0 := by
    simpa [constDepth0] using recdAccum_succ period2AntiSync constDepth0 n
  rw [hsucc, htick] at hle
  linarith

/--
  [TEOREMA] CT-2 structural sample: period-2 trajectory is neither
  eventually nondecreasing nor eventually nonincreasing
  (true non-monotonicity, not mere reverse orientation).
-/
theorem period2AntiSync_not_eventually_monotone :
    (¬ ∃ N0 : Nat, ∀ n : Nat, N0 ≤ n →
        recdAccum period2AntiSync constDepth0 n ≤
          recdAccum period2AntiSync constDepth0 (n + 1)) ∧
      (¬ ∃ N0 : Nat, ∀ n : Nat, N0 ≤ n →
          recdAccum period2AntiSync constDepth0 (n + 1) ≤
            recdAccum period2AntiSync constDepth0 n) :=
  ⟨period2AntiSync_not_eventually_nondecreasing,
    period2AntiSync_not_eventually_nonincreasing⟩

/--
  [TEOREMA] Immersion on an even (anti-sync) cell of period-2 is strictly
  antitone in θ.
-/
theorem immerseAffine_period2_even_antitone (k : Nat) (θ₁ θ₂ : Rat)
    (hθ : θ₁ < θ₂) :
    immerseAffine period2AntiSync constDepth0 (2 * k) θ₂ <
      immerseAffine period2AntiSync constDepth0 (2 * k) θ₁ := by
  apply immerseAffine_strict_anti_of_neg_tick
  · simp only [constDepth0]
    have h := recdTick_period2_even k
    linarith [h, (by native_decide : (-(3 / 4) : Rat) < 0)]
  · exact hθ

end SystemicTau
