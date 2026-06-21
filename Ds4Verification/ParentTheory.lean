import Mathlib
import Ds4Verification.LongRange

/-!
# ParentTheory.lean — the symmetric parent: Ω as a `GL(N) → Sp(N)` order parameter.

`SymmetryBreaking` showed the coupling is covariant (`sp_covariant`), so Ω is a tensor field,
not a background. Here is the parent-theory skeleton that makes the spontaneous breaking precise:

  • **Vacuum manifold** `IsSymplecticVacuum` — nondegenerate antisymmetric forms (the minima a
    `GL(N)`-invariant `V(Ω)` would have). `OmegaMin` is one.
  • **The action preserves it** (`isSymplecticVacuum_congr`): `GL(N)` acts on the order-parameter
    space `Ω ↦ PᵀΩP`.
  • **Unbroken subgroup** `IsUnbroken` (the symplectic group): contains `1`, closed under product
    (a submonoid — the surviving symmetry).
  • **Goldstones** (`deltaOmega`, the infinitesimal variation): for `N = 2` the breaking is
    EXACT — `δΩ = (tr X)·Ω`, so the unbroken Lie algebra `sp(2)` is the traceless matrices
    (`sl₂`, dim 3) and the *single* Goldstone is the dilation `X ∝ 1` (dim 1), matching
    `dim gl(2) − dim sp(2) = 4 − 3 = 1`. The Goldstone direction is exactly the finite dilation
    that `dil_moves_OmegaMin` (SymmetryBreaking) showed breaks the symmetry.
-/

namespace Ds4Verification

open Matrix

variable {n : ℕ}

/-- `OmegaMin` is nonzero. -/
theorem OmegaMin_ne_zero : OmegaMin ≠ (0 : Matrix (Fin 2) (Fin 2) ℝ) := by
  intro h
  have := congrFun (congrFun h 0) 1
  simp [OmegaMin] at this

/-- The **vacuum manifold**: nondegenerate antisymmetric (symplectic) forms. -/
def IsSymplecticVacuum (Ω : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  Ω.transpose = -Ω ∧ IsUnit Ω.det

/-- `OmegaMin` is a symplectic vacuum (`det = 1`). -/
theorem OmegaMin_isVacuum : IsSymplecticVacuum OmegaMin := by
  refine ⟨OmegaMin_antisymm, ?_⟩
  have hdet : OmegaMin.det = 1 := by
    rw [OmegaMin, Matrix.det_fin_two]; norm_num
  rw [hdet]; exact isUnit_one

/-- **The `GL(N)` action preserves the vacuum manifold.** Congruence `Ω ↦ PᵀΩP` by an
    invertible `P` sends symplectic vacua to symplectic vacua: `GL(N)` acts on Ω-space. -/
theorem isSymplecticVacuum_congr {Ω P : Matrix (Fin n) (Fin n) ℝ}
    (hΩ : IsSymplecticVacuum Ω) (hP : IsUnit P.det) :
    IsSymplecticVacuum (Pᵀ * Ω * P) := by
  obtain ⟨hanti, hdet⟩ := hΩ
  refine ⟨?_, ?_⟩
  · rw [Matrix.transpose_mul, Matrix.transpose_mul, Matrix.transpose_transpose, hanti]
    simp [Matrix.mul_neg, Matrix.neg_mul, Matrix.mul_assoc]
  · rw [Matrix.det_mul, Matrix.det_mul, Matrix.det_transpose]
    exact (hP.mul hdet).mul hP

/-- The **unbroken subgroup** (stabilizer of the vacuum) = the symplectic group `Sp(N, Ω₀)`. -/
def IsUnbroken (Ω₀ P : Matrix (Fin n) (Fin n) ℝ) : Prop :=
  IsUnit P.det ∧ Pᵀ * Ω₀ * P = Ω₀

/-- The identity is unbroken. -/
theorem isUnbroken_one (Ω₀ : Matrix (Fin n) (Fin n) ℝ) : IsUnbroken Ω₀ 1 := by
  refine ⟨by simp, ?_⟩
  simp [Matrix.transpose_one]

/-- Unbroken transformations are closed under product (the stabilizer is a submonoid). -/
theorem isUnbroken_mul {Ω₀ P Q : Matrix (Fin n) (Fin n) ℝ}
    (hP : IsUnbroken Ω₀ P) (hQ : IsUnbroken Ω₀ Q) : IsUnbroken Ω₀ (P * Q) := by
  obtain ⟨hPu, hPe⟩ := hP
  obtain ⟨hQu, hQe⟩ := hQ
  refine ⟨by rw [Matrix.det_mul]; exact hPu.mul hQu, ?_⟩
  calc (P * Q)ᵀ * Ω₀ * (P * Q)
      = Qᵀ * (Pᵀ * Ω₀ * P) * Q := by rw [Matrix.transpose_mul]; noncomm_ring
    _ = Qᵀ * Ω₀ * Q := by rw [hPe]
    _ = Ω₀ := hQe

/-- Infinitesimal variation of `Ω₀` along a generator `X` (the Lie derivative): `δΩ = XᵀΩ₀ + Ω₀X`.
    Its kernel is the unbroken (symplectic) Lie algebra; its nonzero values are Goldstones. -/
def deltaOmega (Ω₀ X : Matrix (Fin n) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  Xᵀ * Ω₀ + Ω₀ * X

/-- **Exact Goldstone structure (N = 2).** `δΩ along X = (tr X)·Ω`. Hence `sp(2)` is the
    traceless matrices (`sl₂`) and the lone Goldstone is the trace/dilation direction. -/
theorem deltaOmega_OmegaMin (X : Matrix (Fin 2) (Fin 2) ℝ) :
    deltaOmega OmegaMin X = (Matrix.trace X) • OmegaMin := by
  have htr : Matrix.trace X = X 0 0 + X 1 1 := by
    simp [Matrix.trace, Matrix.diag, Fin.sum_univ_two]
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp only [deltaOmega, Matrix.add_apply, Matrix.smul_apply, Matrix.mul_apply,
      Fin.sum_univ_two, Matrix.transpose_apply, OmegaMin, Fin.mk_zero, Fin.mk_one,
      Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.head_cons, Matrix.of_apply,
      smul_eq_mul, htr] <;> ring

/-- A generator is **unbroken** iff its variation vanishes (symplectic Lie algebra). -/
def IsUnbrokenGen (Ω₀ X : Matrix (Fin n) (Fin n) ℝ) : Prop := deltaOmega Ω₀ X = 0

/-- A generator is a **Goldstone** iff it moves the vacuum. -/
def IsGoldstoneGen (Ω₀ X : Matrix (Fin n) (Fin n) ℝ) : Prop := deltaOmega Ω₀ X ≠ 0

/-- **`sp(2)` = traceless matrices.** A generator is unbroken iff `tr X = 0` (dim 3 = `sl₂`). -/
theorem isUnbrokenGen_OmegaMin_iff (X : Matrix (Fin 2) (Fin 2) ℝ) :
    IsUnbrokenGen OmegaMin X ↔ Matrix.trace X = 0 := by
  unfold IsUnbrokenGen
  rw [deltaOmega_OmegaMin]
  constructor
  · intro h
    rcases smul_eq_zero.mp h with h1 | h2
    · exact h1
    · exact absurd h2 OmegaMin_ne_zero
  · intro h; rw [h, zero_smul]

/-- **The single Goldstone.** The dilation generator `X = 1` is broken (`tr 1 = 2 ≠ 0`) — the one
    Goldstone of `gl(2) → sp(2)`, the same direction `dil_moves_OmegaMin` breaks at finite size. -/
theorem identity_isGoldstone : IsGoldstoneGen OmegaMin (1 : Matrix (Fin 2) (Fin 2) ℝ) := by
  unfold IsGoldstoneGen
  rw [deltaOmega_OmegaMin]
  intro h
  rcases smul_eq_zero.mp h with h1 | h2
  · rw [Matrix.trace_one, Fintype.card_fin] at h1; norm_num at h1
  · exact OmegaMin_ne_zero h2

end Ds4Verification
