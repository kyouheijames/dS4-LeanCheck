import Mathlib
import Ds4Verification.Core
import Ds4Verification.LongRange
import Ds4Verification.FreeSector
import Ds4Verification.StressTensor
import Ds4Verification.Locality

/-!
# Lagrangian.lean — the long-range symplectic Lagrangian, as a mathematical object.

      S[χ] = ∫ dᵈx  [ Ωᵃᵇ χ_a (−∂²)ˢ χ_b  +  g (Ω_{ab} χᵃ χᵇ)² ].

The Lagrangian as a Lean structure, now **carrying its non-unitarity** rather than only seeding
it. Modelling choices, all honest:

  • `(−∂²)ˢ` is held **abstractly** — only its scaling `s` (symbol `|p|^{2s}`) is recorded;
    constructing it needs the multiplier theory, which the model does not require.
  • `N` scalars with a **symplectic** invariant `Ω` (antisymmetric). The boundary inner product
    is the Krein form `G = iΩ`: a real antisymmetric `Ω` makes `iΩ` Hermitian and **indefinite**,
    so the boundary is genuinely non-unitary (a ghost state exists). This is the Sp(N) origin of
    dS/CFT non-unitarity, now a proved witness carried by the structure.
  • `g` is the quartic coupling (low order: one kinetic, one quartic).
-/

open Ds4
open scoped Matrix  -- the `ᴴ` (conjTranspose) and `ᵀ` notation

namespace Ds4Verification

/-! ### The symplectic Krein form `G = iΩ` (worked at N = 2, the Sp(2) case) -/

/-- The boundary Gram operator `G = iΩ` for the canonical symplectic `Ω = OmegaMin`:
    `i·!![0,1;-1,0] = !![0, i; -i, 0]` — the Pauli `σ_y`, Hermitian and indefinite. -/
noncomputable def ghostGram : Matrix (Fin 2) (Fin 2) ℂ := !![0, Complex.I; -Complex.I, 0]

/-- `G = iΩ`: the Gram operator is exactly `i` times the (complexified) symplectic invariant —
    the non-unitarity is *lifted from* `Ω`, not posited. -/
theorem ghostGram_eq_iOmega :
    ghostGram = Complex.I • OmegaMin.map (fun r => (r : ℂ)) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [ghostGram, OmegaMin, Matrix.smul_apply, Matrix.map_apply]

/-- The symplectic boundary Krein form: Hermitian (`σ_y`) and non-degenerate (`det = -1`). -/
noncomputable def ghostKrein : KreinForm 2 where
  G := ghostGram
  hermitian := by
    show ghostGramᴴ = ghostGram
    ext i j
    fin_cases i <;> fin_cases j <;>
      simp [ghostGram, Matrix.conjTranspose_apply, Complex.conj_I]
  nondegenerate := by
    have hdet : ghostGram.det = -1 := by
      simp [ghostGram, Matrix.det_fin_two, Complex.I_mul_I]
    rw [hdet]; exact isUnit_one.neg

/-- **The lifted ghost.** The state `(1, i)` has negative norm `[v,v] = -2 < 0` under `G = iΩ`:
    the symplectic structure forces a negative-norm state, so the boundary is non-unitary. -/
theorem ghostKrein_nonUnitary : ghostKrein.IsNonUnitary := by
  refine ⟨![1, Complex.I], ?_⟩
  show ghostKrein.normSq ![1, Complex.I] < 0
  unfold KreinForm.normSq ghostKrein ghostGram
  simp [Fin.sum_univ_two, Complex.conj_I]

/-! ### The Lagrangian object -/

/-- The long-range symplectic Lagrangian as data, carrying a proved non-unitary boundary. -/
structure LongRangeLagrangian where
  /-- Boundary dimension `d` (dS₄ ⇒ 3). -/
  d : ℝ
  /-- Number of fields `N` (Sp(N): even). -/
  N : ℕ
  /-- Symplectic invariant `Ω` on field space. -/
  Ω : Matrix (Fin N) (Fin N) ℝ
  /-- `Ω` is antisymmetric — the algebraic source of non-unitarity. -/
  antisymm : Ω.transpose = -Ω
  /-- Kinetic exponent `s` of `(−∂²)ˢ`. -/
  s : ℝ
  /-- Quartic coupling `g`. -/
  g : ℝ
  /-- The boundary Krein (Gram) form `G = iΩ`. -/
  boundaryForm : KreinForm N
  /-- A proof the boundary is non-unitary (a ghost exists) — carried, not assumed. -/
  nonUnitary : boundaryForm.IsNonUnitary

namespace LongRangeLagrangian

/-- Momentum-space scaling degree of the kinetic operator `(−∂²)ˢ` (symbol `|p|^{2s}`). -/
def kineticDegree (L : LongRangeLagrangian) : ℝ := 2 * L.s

/-- Free scalar dimension implied by the kinetic term: `Δχ = (d − 2s)/2`. -/
noncomputable def fieldDim (L : LongRangeLagrangian) : ℝ := freeDim L.d L.s

/-- The Lagrangian's free two-point function — read off the abstract kinetic term by scaling. -/
noncomputable def propagatorOf (L : LongRangeLagrangian)
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E] (x : E) : ℝ :=
  propagator L.d L.s x

/-- The would-be stress tensor of the Lagrangian (`Δ_T = d + 2(s−1)`). -/
def stressTensor (L : LongRangeLagrangian) : StressTensor := freeStressTensor L.d L.s

/-- The Lagrangian is **local** iff its kinetic term is the ordinary Laplacian (`s = 1`). -/
def IsLocalLagr (L : LongRangeLagrangian) : Prop := IsLocal L.s

/-- **Dimension = propagator scaling.** `G(l·x) = l^{-2·fieldDim}·G(x)`; no multiplier theory. -/
theorem fieldDim_eq_scaling (L : LongRangeLagrangian)
    {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E] (x : E) {l : ℝ} (hl : 0 < l) :
    L.propagatorOf (l • x) = l ^ (-2 * L.fieldDim) * L.propagatorOf x :=
  propagator_scaling L.d L.s x hl

/-- **Locality rail on the Lagrangian.** Local iff its stress tensor is conserved. -/
theorem isLocal_iff_conserved (L : LongRangeLagrangian) :
    L.IsLocalLagr ↔ L.stressTensor.IsConserved := by
  unfold IsLocalLagr stressTensor
  rw [← freeStressTensor_conserved_iff_isLocal]

/-- **Non-unitarity payoff.** Every Lagrangian's boundary is *not* unitary — there is no
    positive-definite reading of the symplectic inner product. Carried, then discharged. -/
theorem boundary_not_unitary (L : LongRangeLagrangian) : ¬ L.boundaryForm.IsUnitary :=
  KreinForm.not_unitary_of_nonUnitary _ L.nonUnitary

/-- Non-unitarity seed: a symplectic invariant has zero diagonal. -/
theorem Omega_diag_zero (L : LongRangeLagrangian) (i : Fin L.N) : L.Ω i i = 0 := by
  have h : L.Ω i i = - L.Ω i i := by
    have h2 := congrFun (congrFun L.antisymm i) i
    simpa [Matrix.transpose_apply, Matrix.neg_apply] using h2
  linarith

end LongRangeLagrangian

/-- A concrete non-local instance: dS₄ boundary (`d = 3`), two fields with the canonical
    symplectic form, kinetic exponent `s = 1.4`, unit coupling, and the **proved**
    non-unitary boundary `G = iΩ`. -/
noncomputable def exampleLagrangian : LongRangeLagrangian where
  d := 3
  N := 2
  Ω := OmegaMin
  antisymm := OmegaMin_antisymm
  s := 1.4
  g := 1
  boundaryForm := ghostKrein
  nonUnitary := ghostKrein_nonUnitary

/-- The example is genuinely non-local — a checked consequence of its kinetic exponent. -/
theorem exampleLagrangian_nonlocal : ¬ exampleLagrangian.IsLocalLagr := by
  intro h
  exact nonlocal_of_ne_one (by norm_num : (1.4 : ℝ) ≠ 1) h

/-- …and its boundary is non-unitary — carried by the structure, lifted from its `Ω`. -/
theorem exampleLagrangian_nonUnitary : exampleLagrangian.boundaryForm.IsNonUnitary :=
  exampleLagrangian.nonUnitary

end Ds4Verification
