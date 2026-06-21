import Mathlib
import Ds4Verification.Locality

/-!
# LocalityObservable.lean — locality as a genuine quantum observable (operator + spectrum).

`Model`/`ModelP` carried locality as a *random variable* `γ_T(s)` over a distribution. Here we
upgrade it to an actual **self-adjoint operator** with a **spectrum** and **expectation values**
`⟨v|L|v⟩` — the literal "locality as a quantum observable" object.

Given the available kinetic exponents `s : Fin n → ℝ`, the locality observable is the diagonal
operator `L = diag(γ_T(s₀), …, γ_T(s_{n-1}))` on `ℝⁿ`:

  • self-adjoint (`localityOp_isSymm`),
  • its **eigenstate** `eᵢ` has **eigenvalue** the order parameter `γ_T(sᵢ)`
    (`localityOp_mulVec_single`) — the spectrum IS the set of locality order parameters,
  • the **expectation value** in a state `v` is `⟨v|L|v⟩ = Σᵢ γ_T(sᵢ) vᵢ²`
    (`localityExpectation_eq`), the probability-weighted average matching `ModelP.⟨γ_T⟩`,
  • an eigenvalue **vanishes iff that branch is local** (`localityOp_eigenvalue_zero_iff`):
    the zero-eigenspace is exactly the local sector.
-/

namespace Ds4Verification

open Matrix

variable {n : ℕ}

/-- **The locality observable.** Diagonal self-adjoint operator on `ℝⁿ` whose spectrum is the
    set of order-parameter values `{γ_T(sᵢ)}`. -/
noncomputable def localityOp (s : Fin n → ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.diagonal (fun i => gammaT_free (s i))

/-- The observable is self-adjoint (symmetric). -/
theorem localityOp_isSymm (s : Fin n → ℝ) : (localityOp s).IsSymm :=
  Matrix.isSymm_diagonal _

/-- **Eigenvalue equation.** The basis state `eᵢ` is an eigenstate of the locality observable
    with eigenvalue the order parameter `γ_T(sᵢ)`: a measurement returns `γ_T(sᵢ)`. -/
theorem localityOp_mulVec_single (s : Fin n → ℝ) (i : Fin n) :
    (localityOp s).mulVec (Pi.single i 1 : Fin n → ℝ)
      = gammaT_free (s i) • (Pi.single i 1 : Fin n → ℝ) := by
  funext j
  simp only [localityOp, Matrix.mulVec_diagonal, Pi.single_apply, Pi.smul_apply, smul_eq_mul]
  rcases eq_or_ne j i with h | h
  · subst h; simp
  · simp [h]

/-- **Expectation value** `⟨v|L|v⟩` of locality in state `v`: the probability-weighted average
    of the order parameter, `Σᵢ γ_T(sᵢ) · vᵢ²`. -/
noncomputable def localityExpectation (s : Fin n → ℝ) (v : Fin n → ℝ) : ℝ :=
  ∑ i, gammaT_free (s i) * (v i) ^ 2

/-- The expectation is genuinely the operator quadratic form `⟨v, L v⟩`. -/
theorem localityExpectation_eq (s : Fin n → ℝ) (v : Fin n → ℝ) :
    localityExpectation s v = v ⬝ᵥ (localityOp s).mulVec v := by
  unfold localityExpectation
  simp only [dotProduct, localityOp, Matrix.mulVec_diagonal]
  exact Finset.sum_congr rfl (fun i _ => by ring)

/-- Measuring locality in the eigenstate `eᵢ` returns exactly the eigenvalue `γ_T(sᵢ)`. -/
theorem localityExpectation_single (s : Fin n → ℝ) (i : Fin n) :
    localityExpectation s (Pi.single i 1 : Fin n → ℝ) = gammaT_free (s i) := by
  unfold localityExpectation
  rw [Finset.sum_eq_single i]
  · simp [Pi.single_apply]
  · intro j _ hj; simp [Pi.single_apply, hj]
  · intro h; exact absurd (Finset.mem_univ i) h

/-- **The locality spectrum is the order parameter.** An eigenvalue vanishes iff that branch is
    local (`sᵢ = 1`): the zero-eigenspace is exactly the local sector, and a nonzero eigenvalue
    is a non-local ("broken") measurement outcome. -/
theorem localityOp_eigenvalue_zero_iff (s : Fin n → ℝ) (i : Fin n) :
    gammaT_free (s i) = 0 ↔ s i = 1 :=
  gammaT_zero_iff_local (s i)

end Ds4Verification
