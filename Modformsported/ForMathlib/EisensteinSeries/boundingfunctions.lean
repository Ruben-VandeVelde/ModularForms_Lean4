import Mathlib.Analysis.Complex.UpperHalfPlane.Basic
import Mathlib.NumberTheory.Modular
import Mathlib.Data.Int.Interval
import Mathlib.Analysis.SpecialFunctions.Pow.Complex
import Mathlib.Analysis.SpecialFunctions.Pow.Real

noncomputable section

open Complex

open scoped BigOperators NNReal Classical Filter Matrix UpperHalfPlane Complex

lemma upper_half_im_pow_pos (z : ℍ) (n : ℕ) : 0 < (z.1.2)^n := by
    have:= pow_pos z.2 n
    norm_cast

namespace EisensteinSeries

/-- Auxilary function used for bounding Eisentein series-/
def lowerBound1 (z : ℍ) : ℝ :=
  ((z.1.2 ^ (4 : ℕ) + (z.1.1 * z.1.2) ^ (2 : ℕ)) / (z.1.1 ^ (2 : ℕ) + z.1.2 ^ (2 : ℕ)) ^ (2 : ℕ))

theorem lowerBound1_pos (z : ℍ) : 0 < lowerBound1 z := by
  rw [lowerBound1]
  have H1 : 0 < z.1.2 ^ (4 : ℕ) + (z.1.1 * z.1.2) ^ (2 : ℕ) :=
    by
    rw [add_comm]
    apply add_pos_of_nonneg_of_pos
    have := pow_two_nonneg (z.1.1*z.1.2)
    simpa using this
    exact upper_half_im_pow_pos z 4
  have H2 : 0 < (z.1.1 ^ (2 : ℕ) + z.1.2 ^ (2 : ℕ)) ^ (2 : ℕ) := by
    norm_cast
    apply_rules [pow_pos, add_pos_of_nonneg_of_pos, pow_two_nonneg]
    exact z.2
  have := div_pos H1 H2
  norm_cast at *

/-- This function is used to give an upper bound on Eisenstein series-/
def r (z : ℍ) : ℝ :=
  min (Real.sqrt (z.1.2 ^ (2))) (Real.sqrt (lowerBound1 z))

theorem r_pos (z : ℍ) : 0 < r z :=
  by
  have H := z.property; simp at H
  rw [r]
  simp only [lt_min_iff, Real.sqrt_pos, UpperHalfPlane.coe_im]
  constructor
  have := upper_half_im_pow_pos z 2
  norm_cast at *
  apply lowerBound1_pos

theorem r_ne_zero (z : ℍ) :  r z ≠ 0 := ne_of_gt (r_pos z)

lemma r_mul_n_pos (k : ℕ) (z : ℍ) (n : ℕ)  (hn : 1 ≤ n) :
  0 < (Complex.abs ((r z : ℂ) ^ (k : ℤ) * (n : ℂ)^ (k : ℤ))) := by
  apply Complex.abs.pos
  apply mul_ne_zero
  norm_cast
  apply pow_ne_zero
  apply r_ne_zero
  norm_cast
  apply pow_ne_zero
  linarith

theorem ineq1 (x y d : ℝ) :
  0 ≤ d ^ 2 * (x ^ 2 + y ^ 2) ^ 2 + 2 * d * x * (x ^ 2 + y ^ 2) + x ^ 2 := by
  have h1 :
    d ^ 2 * (x ^ 2 + y ^ 2) ^ 2 + 2 * d * x * (x ^ 2 + y ^ 2) + x ^ 2 =
      (d * (x ^ 2 + y ^ 2) + x) ^ 2 := by
        norm_cast
        ring
  rw [h1]
  apply pow_two_nonneg  (d * (x ^ 2 + y ^ 2) + x)

theorem lowbound (z : ℍ) (δ : ℝ) :
    (z.1.2 ^ 4 + (z.1.1 * z.1.2) ^ 2) / (z.1.1 ^ 2 + z.1.2 ^ 2) ^ 2 ≤
      (δ * z.1.1 + 1) ^ 2 + (δ * z.1.2) ^ 2 := by
  have H1 : (δ * z.1.1 + 1) ^ 2 + (δ * z.1.2) ^ 2 =
        δ ^ 2 * (z.1.1 ^ 2 + z.1.2 ^ 2) + 2 * δ * z.1.1 + 1 := by
    ring
  have H4 :
    δ ^ 2 * (z.1.1 ^ 2 + z.1.2 ^ 2) ^ 3 +
      2 * δ * z.1.1 * (z.1.1 ^ 2 + z.1.2 ^ 2) ^ 2 +
        (z.1.1 ^ 2 + z.1.2 ^ 2) ^ 2 -
    (z.1.2 ^ 4 + (z.1.1 * z.1.2) ^ 2) =
      (z.1.1 ^ 2 + z.1.2 ^ 2) *
        (δ ^ 2 * (z.1.1 ^ 2 + z.1.2 ^ 2) ^ 2 +
            2 * δ * z.1.1 * (z.1.1 ^ 2 + z.1.2 ^ 2) + z.1.1 ^ 2) := by
     ring
  have H2 :
  (δ ^ 2 * ((z.1.1) ^ 2 + z.1.2 ^ 2) + 2 * δ * z.1.1 + 1) *
      (z.1.1 ^ 2 + z.1.2 ^ 2) ^ 2 =
    δ ^ 2 * (z.1.1 ^ 2 + z.1.2 ^ 2) ^ 3 +
        2 * δ * z.1.1 * (z.1.1 ^ 2 + z.1.2 ^ 2) ^ 2 +
          (z.1.1^ 2 + z.1.2 ^ 2) ^ 2 := by
        ring
  rw [H1, div_le_iff, H2, ← sub_nonneg, H4]
  have H5 :
    0 ≤
      δ ^ 2 * (z.1.1 ^ 2 + z.1.2 ^ 2) ^ 2 +
          2 * δ * z.1.1 * (z.1.1 ^ 2 + z.1.2 ^ 2) +
      z.1.1 ^ 2 := by apply ineq1
  have H6 : 0 ≤ z.1.1 ^ 2 + z.1.2 ^ 2 := by
    nlinarith
  apply mul_nonneg H6 H5
  have H8 : 0 < z.1.2 ^ 2 := by
    exact upper_half_im_pow_pos z 2
  have H9 : 0 < z.1.2 ^ 2 + z.1.1 ^ 2 := by
    rw [add_comm]
    apply_rules [add_pos_of_nonneg_of_pos, pow_two_nonneg,  H8]
  apply sq_pos_of_ne_zero
  simp at H9
  linarith

theorem auxlem (z : ℍ) (δ : ℝ) :
    r z ≤ Complex.abs ((z : ℂ) + δ) ∧ r z ≤ Complex.abs (δ * (z : ℂ) + 1) := by
  constructor
  · rw [r]
    rw [Complex.abs]
    simp
    have H1 :
      Real.sqrt ((z : ℂ).im ^ 2) ≤
        Real.sqrt (((z : ℂ).re + δ) * ((z : ℂ).re + δ) + (z : ℂ).im * (z : ℂ).im) :=
      by
      rw [Real.sqrt_le_sqrt_iff]
      norm_cast
      nlinarith; nlinarith
    simp at *
    left
    norm_cast
    rw [normSq_apply]
    simp
    norm_cast at *
  · rw [r]
    rw [Complex.abs]
    simp
    have H1 :
      Real.sqrt (lowerBound1 z) ≤
        Real.sqrt
          ((δ * (z : ℂ).re + 1) * (δ * (z : ℂ).re + 1) + δ * (z : ℂ).im * (δ * (z : ℂ).im)) :=
      by
      rw [lowerBound1]
      rw [Real.sqrt_le_sqrt_iff]
      have := lowbound z δ
      rw [← pow_two]
      rw [← pow_two]
      simp only [UpperHalfPlane.coe_im, UpperHalfPlane.coe_re] at *
      norm_cast at *
      nlinarith
    simp only [UpperHalfPlane.coe_im, UpperHalfPlane.coe_re] at H1
    rw [normSq_apply]
    right
    simp at *
    norm_cast

theorem baux (a : ℝ) (k : ℤ) (hk : 0 ≤ k) (b : ℂ) (h : 0 ≤ a) (h2 : a ≤ Complex.abs b) :
    a ^ k ≤ Complex.abs (b ^ k) := by
  lift k to ℕ using hk
  norm_cast at *
  simp only [Complex.cpow_int_cast, map_pow]
  norm_cast at *
  apply pow_le_pow_left h h2

theorem baux2 (z : ℍ) (k : ℤ) : Complex.abs (r z ^ k) = r z ^ k := by
  have ha := (r_pos z).le
  have := Complex.abs_of_nonneg ha
  rw [←this]
  simp  [abs_ofReal, cpow_nat_cast, map_pow, _root_.abs_abs, Real.rpow_nat_cast]

theorem auxlem2 (z : ℍ) (x : ℤ × ℤ) (k : ℤ) (hk : 0 ≤ k) :
    Complex.abs ((r z : ℂ) ^ k) ≤ Complex.abs (((z : ℂ) + (x.2 : ℂ) / (x.1 : ℂ)) ^ k) :=
  by
  norm_cast
  have H1 : Complex.abs (r z ^ k) = r z ^ k := by apply baux2
  norm_cast at H1
  rw [H1]
  have := auxlem z (x.2 / x.1 : ℝ)
  norm_cast at this
  have t2 := this.1
  lift k to ℕ using hk
  norm_cast at *
  simp only [Complex.cpow_int_cast, map_pow]
  simp
  norm_cast at *
  apply pow_le_pow_left (r_pos _).le
  simp at *
  convert t2




theorem auxlem3 (z : ℍ) (x : ℤ × ℤ) (k : ℤ) (hk : 0 ≤ k) :
    Complex.abs ((r z : ℂ) ^ k) ≤ Complex.abs (((x.1 : ℂ) / (x.2 : ℂ) * (z : ℂ) + 1) ^ k) :=
  by
  norm_cast
  have H1 : Complex.abs (r z ^ k) = r z ^ k := by apply baux2
  norm_cast at H1
  rw [H1]
  have := auxlem z (x.1 / x.2 : ℝ)
  norm_cast at this
  have t2 := this.2
  lift k to ℕ using hk
  norm_cast at *
  simp only [Complex.cpow_int_cast, map_pow]
  simp
  norm_cast at *
  apply pow_le_pow_left (r_pos _).le
  simp at *
  convert t2
