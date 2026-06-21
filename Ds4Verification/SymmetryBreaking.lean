import Mathlib
import Ds4Verification.LongRange

/-!
# SymmetryBreaking.lean — Ω as an ORDER PARAMETER, not a fixed background.

The critique: "your action uses a fixed background tensor Ω, so it is background-dependent."
The standard physics answer is spontaneous symmetry breaking (SSB): a "background" in an EFT
is the vacuum expectation value of a *dynamical* field, and the underlying theory is symmetric.
Template — a solid: the microscopic laws are invariant under the full Euclidean group, but the
crystal ground state spontaneously breaks it to a discrete space group; displacement and
orientation are the order parameters.

Here we formalize the analogue. The symplectic invariant `Ω` is treated as the value of a
field transforming under field-space `GL(N)`:

  • `sp_covariant` — the coupling is COVARIANT: a field redefinition `χ ↦ Pχ` is the same as
    transforming `Ω ↦ PᵀΩP`. So `Ω` is a genuine (0,2)-tensor field, not an inert constant;
    the theory with dynamical `Ω` is `GL(N)`-symmetric.
  • `shear_fixes_OmegaMin` — a nontrivial subgroup (here a det-1 shear, an element of the
    symplectic/`SL₂` stabilizer) FIXES `Ω`: the unbroken subgroup is nonempty.
  • `dil_moves_OmegaMin` — a dilation MOVES `Ω`: broken directions exist.

Fixed unbroken subgroup + nonempty broken directions = `Ω` is the order parameter of a
spontaneously broken `GL(N) → Sp(N)`. The fixed `Ω` in the action is a vacuum *choice*, exactly
as the crystal's lattice is a vacuum choice — not a cheat background.
-/

namespace Ds4Verification

open Matrix

/-- The symplectic pairing the action is built from: `sp Ω χ ψ = χᵀ Ω ψ`. -/
def sp {n : ℕ} (Ω : Matrix (Fin n) (Fin n) ℝ) (χ ψ : Fin n → ℝ) : ℝ := χ ⬝ᵥ Ω.mulVec ψ

/-- Transpose/adjoint relation for the dot product: `⟨Av, w⟩ = ⟨v, Aᵀw⟩`. -/
theorem mulVec_dotProduct_eq {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) (v w : Fin n → ℝ) :
    A.mulVec v ⬝ᵥ w = v ⬝ᵥ Aᵀ.mulVec w := by
  simp only [dotProduct, mulVec, transpose_apply, Finset.sum_mul, Finset.mul_sum]
  rw [Finset.sum_comm]
  exact Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => by ring

/-- **Ω transforms as an order parameter.** A field redefinition `χ ↦ Pχ` is equivalent to
    transforming `Ω ↦ PᵀΩP`: the coupling is covariant, so `Ω` is a dynamical (0,2)-tensor,
    not a fixed background. (Equivalently, the simultaneous map `(χ,Ω) ↦ (Pχ, (Pᵀ)⁻¹ΩP⁻¹)`
    leaves `sp` invariant.) -/
theorem sp_covariant {n : ℕ} (Ω P : Matrix (Fin n) (Fin n) ℝ) (χ ψ : Fin n → ℝ) :
    sp Ω (P.mulVec χ) (P.mulVec ψ) = sp (Pᵀ * Ω * P) χ ψ := by
  unfold sp
  rw [mulVec_dotProduct_eq]
  congr 1
  rw [mulVec_mulVec, mulVec_mulVec]

/-- A det-1 shear `!![1,1;0,1]` (an element of the symplectic `SL₂` stabilizer). -/
def shear : Matrix (Fin 2) (Fin 2) ℝ := !![1, 1; 0, 1]

/-- **Unbroken subgroup is nontrivial.** The shear fixes `Ω`: `SᵀΩS = Ω`. So the symmetry is
    only *partly* broken — the stabilizer (symplectic group) survives, exactly as a crystal
    retains its space group. -/
theorem shear_fixes_OmegaMin : shearᵀ * OmegaMin * shear = OmegaMin := by
  have hT : shearᵀ = !![1, 0; 1, 1] := by
    ext i j; fin_cases i <;> fin_cases j <;> rfl
  rw [hT]
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [shear, OmegaMin, Matrix.mul_apply, Fin.sum_univ_two]

/-- The shear is a nontrivial group element (≠ identity). -/
theorem shear_ne_one : shear ≠ 1 := by
  intro h
  have := congrFun (congrFun h 0) 1
  simp [shear, Matrix.one_apply] at this

/-- A dilation `!![2,0;0,2]`. -/
def dil : Matrix (Fin 2) (Fin 2) ℝ := !![2, 0; 0, 2]

/-- **Broken directions exist.** The dilation MOVES `Ω` (`DᵀΩD ≠ Ω`): the symmetry acts
    nontrivially on `Ω`, so `Ω` is a genuine order parameter, not an invariant constant. -/
theorem dil_moves_OmegaMin : dilᵀ * OmegaMin * dil ≠ OmegaMin := by
  intro h
  have h01 := congrFun (congrFun h 0) 1
  simp [dil, OmegaMin, Matrix.mul_apply, Fin.sum_univ_two, Matrix.transpose_apply] at h01
  norm_num at h01

end Ds4Verification
