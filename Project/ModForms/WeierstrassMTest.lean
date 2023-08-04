import Mathbin.Order.Filter.Archimedean
import Mathbin.Data.Complex.Basic
import Mathbin.Topology.Instances.Nnreal
import Mathbin.Analysis.Complex.Basic
import Mathbin.Order.Filter.AtTopBot
import Mathbin.Analysis.Normed.Group.InfiniteSum

#align_import mod_forms.Weierstrass_M_test

universe u v w

noncomputable section

open Complex Metric

open scoped BigOperators NNReal Classical Filter

variable {α : Type u} {β : Type v}

theorem summable_if_complex_abs_summable {f : α → ℂ} :
    (Summable fun x => Complex.abs (f x)) → Summable f :=
  by
  intro h
  apply summable_of_norm_bounded (fun x => Complex.abs (f x)) h
  intro i
  unfold norm
  exact complete_of_proper

theorem M_test_summable (F : ℕ → α → ℂ) (M : ℕ → ℝ)
    (h1 : ∀ n : ℕ, ∀ a : α, Complex.abs (F n a) ≤ M n) (h2 : Summable M) :
    ∀ a : α, Summable fun n : ℕ => F n a := by
  intro a
  apply summable_if_complex_abs_summable
  have c1 : ∀ n : ℕ, 0 ≤ Complex.abs (F n a) := by intro n; apply complex.abs.nonneg (F n a)
  have H1 : ∀ n : ℕ, Complex.abs (F n a) ≤ M n := by simp only [h1, forall_const]
  apply summable_of_nonneg_of_le c1 H1
  exact h2

theorem sum_sub_tsum_nat_add {f : ℕ → ℂ} (k : ℕ) (h : Summable f) :
    ∑' i, f i - ∑ i in Finset.range k, f i = ∑' i, f (i + k) :=
  haveI := sum_add_tsum_nat_add k h
  sub_eq_of_eq_add' (Eq.symm this)

theorem abs_tsum (f : ℕ → ℂ) (h : Summable fun i : ℕ => Complex.abs (f i)) :
    Complex.abs (∑' i : ℕ, f i) ≤ ∑' i : ℕ, Complex.abs (f i) :=
  by
  rw [← Complex.norm_eq_abs]
  simp_rw [← Complex.norm_eq_abs]
  apply norm_tsum_le_tsum_norm
  exact h

theorem abs_tsum' {f : α → ℂ} (h : Summable fun i : α => Complex.abs (f i)) :
    Complex.abs (∑' i : α, f i) ≤ ∑' i : α, Complex.abs (f i) :=
  by
  rw [← Complex.norm_eq_abs]
  simp_rw [← Complex.norm_eq_abs]
  apply norm_tsum_le_tsum_norm
  exact h

example (r : ℝ) : Complex.abs (r : ℂ) = |r| :=
  abs_of_real r

theorem M_test_uniform (h : Nonempty α) (F : ℕ → α → ℂ) (M : ℕ → ℝ)
    (h1 : ∀ n : ℕ, ∀ a : α, Complex.abs (F n a) ≤ M n) (h2 : Summable M) :
    TendstoUniformly (fun n : ℕ => fun a : α => ∑ i in Finset.range n, F i a)
      (fun a : α => ∑' n : ℕ, F n a) Filter.atTop :=
  by
  have Mpos : ∀ n : ℕ, 0 ≤ M n := by
    intro n
    have := h1 n
    have t1 : ∀ a : α, 0 ≤ Complex.abs (F n a) := by intro a; apply complex.abs.nonneg
    apply le_trans (t1 _) (this _)
    have ne := exists_true_iff_nonempty.2 h
    use Classical.choose Ne
  rw [Metric.tendstoUniformly_iff]
  intro ε hε
  have hS := M_test_summable F M h1 h2
  simp only [Filter.eventually_atTop, gt_iff_lt, ge_iff_le] at *
  have H := summable_iff_vanishing_norm.1 h2 ε hε
  simp only at H 
  have HU : ∃ a : ℕ, ∀ b : ℕ, a ≤ b → |∑' i, M (i + b)| < ε :=
    by
    have HC := tendsto_sum_nat_add M
    simp [tendsto_iff_dist_tendsto_zero] at HC 
    simp only [dist_zero_right, norm_norm] at HC 
    simp_rw [Metric.tendsto_nhds] at HC 
    simp only [Filter.eventually_atTop, gt_iff_lt, ge_iff_le, dist_zero_right, norm_norm] at HC 
    simp at *
    have HXX := HC ε hε
    obtain ⟨a, ha⟩ := HXX
    refine' ⟨a, _⟩
    intro b hb
    convert ha b hb
  have c1 : ∀ (a : α) (n : ℕ), 0 ≤ Complex.abs (F n a) := by intro a n;
    apply complex.abs.nonneg (F n a)
  have H1 : ∀ (a : α) (n : ℕ), Complex.abs (F n a) ≤ M n := by simp [h1]
  have B1 : ∀ a : α, ∑' n : ℕ, Complex.abs (F n a) ≤ ∑' n : ℕ, M n :=
    by
    intro a
    apply tsum_le_tsum
    simp only [h1, forall_const]
    apply summable_of_nonneg_of_le (c1 a) (H1 a) h2
    exact h2
  have S1 : ∀ a : α, Summable fun i : ℕ => Complex.abs (F i a) := by intro a;
    apply summable_of_nonneg_of_le (c1 a) (H1 a) h2
  have BU : ∃ a : ℕ, ∀ b : ℕ, a ≤ b → ∀ r : α, ∑' i, Complex.abs (F (i + b) r) < ε :=
    by
    cases HU
    use HU_w
    intro b hb
    intro r
    have : ∑' i, Complex.abs (F (i + b) r) ≤ |∑' i, M (i + b)| :=
      by
      have r1 : |∑' i, M (i + b)| = ∑' i, M (i + b) :=
        by
        apply Real.norm_of_nonneg
        apply tsum_nonneg
        simp only [Mpos, forall_const]
      rw [r1]
      apply tsum_le_tsum
      simp only [h1, forall_const]
      apply (summable_nat_add_iff b).2 (S1 r)
      apply (summable_nat_add_iff b).2 h2
    cases H
    cases h2
    dsimp at *
    have hut := HU_h b hb; exact gt_of_gt_of_ge (HU_h b hb) this
  have H2 :
    ∀ (a : α) (k : ℕ), ∑' n : ℕ, F n a - ∑ i : ℕ in Finset.range k, F i a = ∑' n : ℕ, F (n + k) a :=
    by
    intro a k
    apply sum_sub_tsum_nat_add k
    exact hS a
  simp_rw [dist_eq_norm]
  simp_rw [H2]
  simp only [norm_eq_abs] at *
  cases BU
  use BU_w
  intro b hb r
  have BUC := BU_h b hb r
  let G := fun i : ℕ => F i r
  have f_um := abs_tsum (fun i : ℕ => F (i + b) r) _
  exact gt_of_gt_of_ge BUC f_um
  have f_sum := S1 r
  apply (summable_nat_add_iff b).2 f_sum

