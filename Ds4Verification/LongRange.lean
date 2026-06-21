import Mathlib

/-!
# LongRange.lean — the free (Gaussian) sector of the long-range symplectic CFT*

Reduces the candidate boundary Lagrangian

    S = ∫ dᵈx  Ωᵃᵇ χ_a (−∂²)ˢ χ_b   (+ interactions, not in this module)

to its **dimensional-classification algebra**. We deliberately do NOT formalize the
analysis (existence/construction of the fractional operator (−∂²)ˢ as a Fourier
multiplier |p|^{2s}); see STATUS.md. What is formalized here is the part that the
"worth investigating?" filter actually needs and that Lean can genuinely prove:
the s-dependence of the scaling dimension and the locality order parameter.

Physical value for dS₄ : boundary S³ ⇒ d = 3.  s = 1 is the ordinary Laplacian.
-/

namespace Ds4Verification

/-- Boundary spatial dimension `d` (the sphere Sᵈ at ℐ⁺). Kept real so we can
    ε-continue later; physical dS₄ value is `d = 3`. -/
abbrev BoundaryDim := ℝ

/-- Fractional kinetic exponent `s` of `(−∂²)ˢ`. `s = 1` ↔ local Laplacian;
    `s ≠ 1` ↔ long-range / non-local kinetic term. -/
abbrev KineticExponent := ℝ

/-- Free scaling dimension of the fundamental scalar in the long-range Gaussian
    theory: propagator `~ |p|^{−2s}` ⇒ `Δχ = (d − 2s)/2`. -/
noncomputable def freeDim (d : BoundaryDim) (s : KineticExponent) : ℝ := (d - 2 * s) / 2

@[simp] lemma freeDim_local (d : ℝ) : freeDim d 1 = (d - 2) / 2 := by
  unfold freeDim; ring

/-- The symplectic (antisymmetric) invariant `Ω` that makes the theory
    non-unitary, modeled minimally as the 2×2 symplectic form. This is the
    Sp(N) `N → −N` mechanism in miniature; unify with your `KreinForm` in
    Conditions.lean. -/
def OmegaMin : Matrix (Fin 2) (Fin 2) ℝ := !![0, 1; -1, 0]

lemma OmegaMin_antisymm : OmegaMin.transpose = -OmegaMin := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [OmegaMin, Matrix.transpose]

/-- An antisymmetric bilinear invariant has no nonzero diagonal: the field is
    its own "wrong-statistics" partner — the algebraic seed of non-unitarity. -/
lemma OmegaMin_diag_zero (i : Fin 2) : OmegaMin i i = 0 := by
  fin_cases i <;> simp [OmegaMin]

end Ds4Verification
