import Mathlib
import Ds4Verification.LongRange
import Ds4Verification.ParentTheory

/-!
# ParentAction.lean — the dynamical-Ω parent action and its symplectic vacuum.

`ParentTheory` showed Ω is an order parameter (the SSB `GL(N)→Sp(N)`). This module promotes Ω to
a DYNAMICAL field with a potential `V(Ω)` whose minimum is the symplectic vacuum — so the fixed-Ω
EFT (`Lagrangian`) is the broken phase of a theory in which Ω is not put in by hand.

      S[χ, Ω] = ∫ dᵈx [ Ωᵃᵇ χ_a (−∂²)ˢ χ_b + g(Ω_{ab}χᵃχᵇ)² + ½ ∂Ω·∂Ω − V(Ω) ]

The kinetic/coupling sector's covariance is `SymmetryBreaking.sp_covariant`. Here we build `V`:

  • `V(Ω) = ‖Ωᵀ + Ω‖² + ‖Ω·Ω + 𝟙‖²` (Frobenius squares) — a sum of squares, so `V ≥ 0`.
  • `V(Ω) = 0 ⟺ Ωᵀ = −Ω ∧ Ω² = −𝟙` — antisymmetric unit symplectic forms (complex structures):
    exactly the vacuum manifold.
  • `OmegaMin` is a vacuum (`V(OmegaMin)=0`), hence a global minimum, and `V = 0 ⇒
    IsSymplecticVacuum` — tying V's minima to `ParentTheory`'s SSB (Goldstones etc.).
-/

namespace Ds4Verification

open Matrix

variable {n : ℕ}

/-- Frobenius square: the sum of squares of the entries. -/
def sqNorm (M : Matrix (Fin n) (Fin n) ℝ) : ℝ := ∑ i, ∑ j, (M i j) ^ 2

theorem sqNorm_nonneg (M : Matrix (Fin n) (Fin n) ℝ) : 0 ≤ sqNorm M :=
  Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _

theorem sqNorm_eq_zero_iff (M : Matrix (Fin n) (Fin n) ℝ) : sqNorm M = 0 ↔ M = 0 := by
  unfold sqNorm
  rw [Finset.sum_eq_zero_iff_of_nonneg fun i _ => Finset.sum_nonneg fun j _ => sq_nonneg _]
  constructor
  · intro h
    ext i j
    have hi := h i (Finset.mem_univ i)
    rw [Finset.sum_eq_zero_iff_of_nonneg fun j _ => sq_nonneg _] at hi
    have hij := hi j (Finset.mem_univ j)
    simpa using (pow_eq_zero_iff (by norm_num : (2 : ℕ) ≠ 0)).mp hij
  · intro h i _
    simp [h]

/-- The potential selecting symplectic vacua. -/
def potentialV (Ω : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  sqNorm (Ωᵀ + Ω) + sqNorm (Ω * Ω + 1)

theorem potentialV_nonneg (Ω : Matrix (Fin n) (Fin n) ℝ) : 0 ≤ potentialV Ω :=
  add_nonneg (sqNorm_nonneg _) (sqNorm_nonneg _)

/-- `OmegaMin² = −𝟙` — `OmegaMin` is a complex structure. -/
theorem OmegaMin_sq : OmegaMin * OmegaMin = -1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp only [OmegaMin, Matrix.mul_apply, Fin.sum_univ_two, Fin.mk_zero, Fin.mk_one,
      Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons, Matrix.of_apply,
      Matrix.neg_apply, Matrix.one_apply] <;> norm_num

/-- **`OmegaMin` is a vacuum:** `V(OmegaMin) = 0`. -/
theorem potentialV_OmegaMin : potentialV OmegaMin = 0 := by
  have h1 : OmegaMinᵀ + OmegaMin = 0 := by rw [OmegaMin_antisymm]; exact neg_add_cancel _
  have h2 : OmegaMin * OmegaMin + 1 = 0 := by rw [OmegaMin_sq]; exact neg_add_cancel _
  unfold potentialV
  rw [h1, h2]
  simp [sqNorm]

/-- **`OmegaMin` is a global minimum** of `V`. -/
theorem OmegaMin_isMinimum (Ω : Matrix (Fin 2) (Fin 2) ℝ) :
    potentialV OmegaMin ≤ potentialV Ω := by
  rw [potentialV_OmegaMin]; exact potentialV_nonneg Ω

/-- **The vacuum manifold:** `V(Ω) = 0 ⟺ Ω` is an antisymmetric unit symplectic form. -/
theorem potentialV_eq_zero_iff (Ω : Matrix (Fin n) (Fin n) ℝ) :
    potentialV Ω = 0 ↔ Ωᵀ = -Ω ∧ Ω * Ω = -1 := by
  unfold potentialV
  rw [add_eq_zero_iff_of_nonneg (sqNorm_nonneg _) (sqNorm_nonneg _),
      sqNorm_eq_zero_iff, sqNorm_eq_zero_iff, add_eq_zero_iff_eq_neg, add_eq_zero_iff_eq_neg]

/-- **V's minima are symplectic vacua.** Any `V = 0` configuration is antisymmetric and
    invertible (`IsSymplecticVacuum`), so `ParentTheory`'s SSB / Goldstone structure applies. -/
theorem isSymplecticVacuum_of_potentialV_zero (Ω : Matrix (Fin n) (Fin n) ℝ)
    (h : potentialV Ω = 0) : IsSymplecticVacuum Ω := by
  rw [potentialV_eq_zero_iff] at h
  obtain ⟨hanti, hsq⟩ := h
  refine ⟨hanti, ?_⟩
  have hinv : Ω * (-Ω) = 1 := by rw [Matrix.mul_neg, hsq, neg_neg]
  exact isUnit_of_mul_eq_one Ω.det (-Ω).det (by rw [← Matrix.det_mul, hinv, Matrix.det_one])

/-- The parent action with a **dynamical** Ω: kinetic exponent `s`, coupling `g`, and the
    symplectic-selecting potential, whose vacuum is `OmegaMin`. Freezing Ω at the vacuum gives
    back the fixed-Ω EFT (`Lagrangian`); the broken generators are the Goldstones of `ParentTheory`. -/
structure ParentAction where
  s : ℝ
  g : ℝ
  V : Matrix (Fin 2) (Fin 2) ℝ → ℝ
  /-- `OmegaMin` minimizes the potential (it is the vacuum). -/
  vacuum_min : ∀ Ω, V OmegaMin ≤ V Ω

/-- The canonical parent action with the symplectic-selecting potential. -/
def canonicalParent (s g : ℝ) : ParentAction where
  s := s
  g := g
  V := potentialV
  vacuum_min := OmegaMin_isMinimum

end Ds4Verification
