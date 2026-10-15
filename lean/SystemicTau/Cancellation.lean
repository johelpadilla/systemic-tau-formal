/-
  Exact cancellation split of a finite edge-change vector.

  For Δ_e ∈ ℚ on a finite edge list E,
    Δ̄_E = (1/|E|) Σ Δ_e,
    D_E  = (1/|E|) Σ |Δ_e|,
    S₊   = Σ_{Δ_e > 0} Δ_e,
    S₋   = Σ_{Δ_e < 0} |Δ_e|,
    C_E  = 2 min(S₊, S₋) / |E|,
  the identity D_E = |Δ̄_E| + C_E holds in ℚ.

  S₊ and S₋ are total masses. The factor 1/|E| is required because
  D_E and Δ̄_E are means. This file does not modify the gate, the
  bands, or the tick. It is not part of the released Module CT
  (systemic-tau-formal v0.1.11). No sorry and no research axiom.
-/
import Mathlib.Algebra.Order.GroupWithZero.Unbundled
import Mathlib.Algebra.Order.Ring.Unbundled.Rat
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Ring
import SystemicTau.RECD

namespace SystemicTau

theorem absRat_zero : absRat 0 = 0 := absRat_of_nonneg (le_refl (0 : ℚ))

/-- Sum of a rational list. -/
@[simp] def qsum : List ℚ → ℚ
  | [] => 0
  | x :: xs => x + qsum xs

/-- Total mass of strictly positive changes. -/
@[simp] def massPlus : List ℚ → ℚ
  | [] => 0
  | x :: xs => (if 0 < x then x else 0) + massPlus xs

/-- Total absolute mass of strictly negative changes. -/
@[simp] def massMinus : List ℚ → ℚ
  | [] => 0
  | x :: xs => (if x < 0 then -x else 0) + massMinus xs

/-- Signed mean Δ̄_E. Empty list gives 0, matching division by zero in ℚ. -/
def deltaBar (d : List ℚ) : ℚ := qsum d / (d.length : ℚ)

/-- Mean absolute change D_E. -/
def edgeD (d : List ℚ) : ℚ := qsum (d.map absRat) / (d.length : ℚ)

/-- Cancellation term C_E = 2 min(S₊, S₋) / |E|. -/
def edgeC (d : List ℚ) : ℚ :=
  2 * min (massPlus d) (massMinus d) / (d.length : ℚ)

theorem massPlus_nonneg (d : List ℚ) : 0 ≤ massPlus d := by
  induction d with
  | nil => simp
  | cons x xs ih =>
    by_cases hx : 0 < x
    · simp [hx, ih]
      linarith
    · simp [hx, ih]

theorem massMinus_nonneg (d : List ℚ) : 0 ≤ massMinus d := by
  induction d with
  | nil => simp
  | cons x xs ih =>
    by_cases hx : x < 0
    · have : 0 ≤ -x := by linarith
      simp [hx, ih]
      linarith
    · simp [hx, ih]

theorem qsum_eq_plus_minus (d : List ℚ) :
    qsum d = massPlus d - massMinus d := by
  induction d with
  | nil => simp
  | cons x xs ih =>
    by_cases hp : 0 < x
    · have hn : ¬ x < 0 := by linarith
      simp [hp, hn, ih]
      ring
    · by_cases hn : x < 0
      · simp [hp, hn, ih]
        ring
      · have hx : x = 0 := by
          have hle : x ≤ 0 := le_of_not_gt hp
          have hge : 0 ≤ x := le_of_not_gt hn
          exact le_antisymm hle hge
        simp [hp, hn, ih, hx]

theorem qsum_abs_eq_plus_plus_minus (d : List ℚ) :
    qsum (d.map absRat) = massPlus d + massMinus d := by
  induction d with
  | nil => simp
  | cons x xs ih =>
    simp only [List.map_cons, qsum, massPlus, massMinus, ih]
    by_cases hp : 0 < x
    · have hn : ¬ x < 0 := by linarith
      simp only [if_pos hp, if_neg hn, absRat_of_nonneg (le_of_lt hp)]
      ring
    · by_cases hn : x < 0
      · simp only [if_neg hp, if_pos hn, absRat_of_nonpos (le_of_lt hn)]
        ring
      · have hx : x = 0 := le_antisymm (le_of_not_gt hp) (le_of_not_gt hn)
        subst hx
        simp only [if_neg hp, if_neg hn, absRat_zero]
        ring

/-- Algebraic split: |a − b| + 2 min(a, b) = a + b for every pair of rationals. -/
theorem abs_sub_add_two_min {a b : ℚ} :
    absRat (a - b) + 2 * min a b = a + b := by
  by_cases h : a ≤ b
  · have hnonpos : a - b ≤ 0 := by linarith
    have hmin : min a b = a := min_eq_left h
    rw [absRat_of_nonpos hnonpos, hmin]
    ring
  · have hba : b ≤ a := le_of_not_ge h
    have hnonneg : 0 ≤ a - b := by linarith
    have hmin : min a b = b := min_eq_right hba
    rw [absRat_of_nonneg hnonneg, hmin]
    ring

theorem absRat_div_of_pos {a c : ℚ} (hc : 0 < c) :
    absRat (a / c) = absRat a / c := by
  by_cases ha : 0 ≤ a
  · have hdiv : 0 ≤ a / c := div_nonneg ha (le_of_lt hc)
    rw [absRat_of_nonneg ha, absRat_of_nonneg hdiv]
  · have ha' : a < 0 := lt_of_not_ge ha
    have hinv : 0 < c⁻¹ := inv_pos.mpr hc
    have hdiv : a / c < 0 := by
      rw [div_eq_mul_inv]
      exact mul_neg_of_neg_of_pos ha' hinv
    rw [absRat_of_nonpos (le_of_lt ha'), absRat_of_nonpos (le_of_lt hdiv)]
    ring

/-- D_E = |Δ̄_E| + C_E on every finite edge list, including the empty list. -/
theorem d_eq_abs_dbar_add_C (d : List ℚ) :
    edgeD d = absRat (deltaBar d) + edgeC d := by
  set n : ℚ := (d.length : ℚ)
  set Sp : ℚ := massPlus d
  set Sm : ℚ := massMinus d
  have hkey : absRat (Sp - Sm) + 2 * min Sp Sm = Sp + Sm :=
    abs_sub_add_two_min
  have hsum : qsum d = Sp - Sm := qsum_eq_plus_minus d
  have habs : qsum (d.map absRat) = Sp + Sm := qsum_abs_eq_plus_plus_minus d
  by_cases hlen : d.length = 0
  · have hd : d = [] := List.eq_nil_of_length_eq_zero hlen
    simp [edgeD, deltaBar, edgeC, hd, absRat_zero]
  · have hn : 0 < n := by
      have hpos : 0 < d.length := Nat.pos_of_ne_zero hlen
      rw [show n = (d.length : ℚ) from rfl]
      exact Nat.cast_pos.mpr hpos
    have hsplit : (Sp + Sm) / n =
        absRat (Sp - Sm) / n + (2 * min Sp Sm) / n := by
      rw [← add_div, hkey]
    calc
      edgeD d = (Sp + Sm) / n := by
        simp only [edgeD, habs, n]
      _ = absRat (Sp - Sm) / n + (2 * min Sp Sm) / n := hsplit
      _ = absRat ((Sp - Sm) / n) + (2 * min Sp Sm) / n := by
            rw [← absRat_div_of_pos (a := Sp - Sm) hn]
      _ = absRat ((Sp - Sm) / n) + edgeC d := by
            simp only [edgeC, Sp, Sm, n]
      _ = absRat (deltaBar d) + edgeC d := by
            simp only [deltaBar, hsum, n]

theorem edgeC_nonneg (d : List ℚ) : 0 ≤ edgeC d := by
  have hmin : 0 ≤ min (massPlus d) (massMinus d) :=
    le_min (massPlus_nonneg d) (massMinus_nonneg d)
  have hnum : 0 ≤ 2 * min (massPlus d) (massMinus d) := by linarith
  by_cases hlen : d.length = 0
  · have hd : d = [] := List.eq_nil_of_length_eq_zero hlen
    simp [edgeC, hd]
  · have hn : 0 < (d.length : ℚ) := Nat.cast_pos.mpr (Nat.pos_of_ne_zero hlen)
    exact div_nonneg hnum (le_of_lt hn)

/-- When D_E > 0, κ_E = C_E / D_E lies in [0, 1]. -/
theorem kappa_mem_unitInterval (d : List ℚ) (hD : 0 < edgeD d) :
    0 ≤ edgeC d / edgeD d ∧ edgeC d / edgeD d ≤ 1 := by
  have hC : 0 ≤ edgeC d := edgeC_nonneg d
  have hlo : 0 ≤ edgeC d / edgeD d := div_nonneg hC (le_of_lt hD)
  have hdecomp : edgeD d = absRat (deltaBar d) + edgeC d := d_eq_abs_dbar_add_C d
  have habs : 0 ≤ absRat (deltaBar d) := absRat_nonneg (deltaBar d)
  have hle : edgeC d ≤ edgeD d := by linarith
  have hhi : edgeC d / edgeD d ≤ 1 := by
    have hne : edgeD d ≠ 0 := ne_of_gt hD
    have hinv : 0 ≤ (edgeD d)⁻¹ := le_of_lt (inv_pos.mpr hD)
    rw [div_eq_mul_inv, ← mul_inv_cancel₀ hne]
    exact mul_le_mul_of_nonneg_right hle hinv
  exact ⟨hlo, hhi⟩

/-- κ_E = 0 when D_E > 0 and every change has the same sign (one mass vanishes). -/
theorem kappa_zero_of_one_mass_zero (d : List ℚ) (hD : 0 < edgeD d)
    (h : massPlus d = 0 ∨ massMinus d = 0) :
    edgeC d / edgeD d = 0 := by
  have hC : edgeC d = 0 := by
    cases h with
    | inl hp =>
        have hmin : min (massPlus d) (massMinus d) = 0 := by
          rw [hp]
          exact min_eq_left (massMinus_nonneg d)
        simp [edgeC, hmin]
    | inr hm =>
        have hmin : min (massPlus d) (massMinus d) = 0 := by
          rw [hm]
          exact min_eq_right (massPlus_nonneg d)
        simp [edgeC, hmin]
  rw [div_eq_iff (ne_of_gt hD), hC]
  ring

/-- κ_E = 1 when D_E > 0 and the two masses are equal. -/
theorem kappa_one_of_balanced (d : List ℚ) (hD : 0 < edgeD d)
    (h : massPlus d = massMinus d) :
    edgeC d / edgeD d = 1 := by
  have hbar : deltaBar d = 0 := by
    have hsum : qsum d = massPlus d - massMinus d := qsum_eq_plus_minus d
    simp [deltaBar, hsum, h]
  have hdecomp : edgeD d = absRat (deltaBar d) + edgeC d := d_eq_abs_dbar_add_C d
  have hEq : edgeD d = edgeC d := by
    simp [hdecomp, hbar, absRat_of_nonneg (le_refl (0 : ℚ))]
  rw [div_eq_one_iff_eq hD.ne']
  exact hEq.symm

end SystemicTau
