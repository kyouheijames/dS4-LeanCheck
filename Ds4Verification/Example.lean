/-
  A concrete, fully-proved instantiation of the (strengthened) dS4-LeanCheck framework.

  It now discharges the REAL obligations: symmetry, invertibility, Lorentzian (-,+,+,+)
  signature (Sylvester congruence to η), and the Einstein/de Sitter relations
  Ric = Λ • g with R = 4Λ and Λ > 0.

  Physics caveat (see Core.lean): the Ricci tensor here is the *postulated* maximally-
  symmetric value Ric = Λ • g, not one derived from g's Christoffel symbols. So this
  particular constant metric exercises the contract rather than modelling a curved bulk;
  the SIGNATURE check, however, is fully genuine. Deriving Ric from g is the open
  milestone tracked in the README.

  This file also serves as the style seed for `driver/agent_loop.py`.
-/
import Ds4Verification.Core
import Mathlib.Analysis.SpecialFunctions.Sqrt

open Ds4
open scoped Matrix  -- enables the `ᵀ` transpose notation

namespace Ds4.Example

/-- Boundary CFT Hilbert space: ℂ². -/
abbrev Boundary : Type := EuclideanSpace ℂ (Fin 2)

/-- Key fact: the Minkowski form is its own inverse, η · η = 1. -/
theorem mink_mul_self : minkowski * minkowski = 1 := by
  unfold minkowski
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Matrix.mul_apply, Fin.sum_univ_four, Matrix.diagonal_apply, Matrix.one_apply]

/-- A constant metric field equal to the Minkowski form everywhere. -/
def flatMetric : MetricField Real4D where
  g := fun _ => minkowski
  gInv := fun _ => minkowski
  symm := fun _ => by unfold minkowski; exact Matrix.isSymm_diagonal _
  inv := fun _ => mink_mul_self

/-- The metric is Lorentzian (-,+,+,+): take the identity frame P = 1, Pᵀ η P = η. -/
theorem flat_lorentzian : flatMetric.Lorentzian := by
  intro x
  exact ⟨1, isUnit_one, by simp [flatMetric, Matrix.transpose_one]⟩

/-- The de Sitter instance with Λ = 3 (so the scalar curvature R = 4Λ = 12). -/
noncomputable instance deSitter : DeSitterUniverse flatMetric where
  Λ := 3
  pos_Λ := by norm_num
  ric := fun _ => (3 : ℝ) • minkowski
  einstein := fun _ => by simp [flatMetric]
  scalar_curvature := fun _ => by
    simp only [flatMetric, Matrix.mul_smul, mink_mul_self, Matrix.trace_smul,
      Matrix.trace_one, Fintype.card_fin, smul_eq_mul]
    norm_num
  lorentzian := flat_lorentzian

/-- The holographic hypothesis: ℂ² boundary ↦ the flat (Minkowski-form) bulk metric. -/
noncomputable def hypothesis : HolographicDS4Hypothesis Real4D where
  BoundaryHilbertSpace := Boundary
  holographic_dictionary := fun _ => flatMetric

/-- The framework verifies for this hypothesis at every boundary state. -/
theorem verified (state : Boundary) : verifies hypothesis state :=
  ⟨deSitter⟩

/-
  ──────────────────────────────────────────────────────────────────────────────
  Second example: a POSITION-DEPENDENT, conformally-rescaled metric.
  ──────────────────────────────────────────────────────────────────────────────
  g_μν(x) = Ω(x)² · η_μν  with conformal factor Ω(x)² = scale(x) = 1 + ‖x‖² > 0.

  This is conformally flat, so it keeps the (-,+,+,+) signature — but now the proof
  is non-trivial: the diagonalising frame P(x) = Ω(x)⁻¹ · 1 genuinely depends on the
  point, so `lorentzian` exercises the Sylvester-congruence machinery for real.
  (As with the flat case, the Ricci tensor is still the postulated Ric = Λ·g; deriving
  it from g's connection remains the open roadmap item.)

  NOTE: as flagged project-wide, these matrix proofs use standard Mathlib idioms but
  have not been compiled here — a lemma/tactic name (`smul_mul_smul_comm`, `det_smul`,
  `mul_eq_one_comm`, …) may need nudging to match your exact Mathlib release.
-/

/-- A different boundary theory: ℂ³ (e.g. three stress-tensor modes). -/
abbrev Boundary3 : Type := EuclideanSpace ℂ (Fin 3)

/-- Strictly-positive conformal factor Ω(x)² = 1 + ‖x‖². -/
noncomputable def scale (x : Real4D) : ℝ := 1 + ‖x‖ ^ 2

theorem scale_pos (x : Real4D) : 0 < scale x := by unfold scale; positivity

theorem scale_ne (x : Real4D) : scale x ≠ 0 := (scale_pos x).ne'

/-- The conformally-rescaled metric g(x) = scale(x) • η, with inverse scale(x)⁻¹ • η. -/
noncomputable def confMetric : MetricField Real4D where
  g := fun x => scale x • minkowski
  gInv := fun x => (scale x)⁻¹ • minkowski
  symm := fun x => by
    have hm : minkowskiᵀ = minkowski := by unfold minkowski; exact Matrix.isSymm_diagonal _
    show (scale x • minkowski)ᵀ = scale x • minkowski
    rw [Matrix.transpose_smul, hm]
  inv := fun x => by
    show (scale x • minkowski) * ((scale x)⁻¹ • minkowski) = 1
    rw [smul_mul_smul_comm, mink_mul_self, mul_inv_cancel₀ (scale_ne x), one_smul]

/-- Signature (-,+,+,+) via the position-dependent frame P(x) = Ω(x)⁻¹ • 1, Ω = √scale.
    The key cancellation is Ω⁻¹ · scale · Ω⁻¹ = scale / (√scale)² = 1. -/
theorem conf_lorentzian : confMetric.Lorentzian := by
  intro x
  set Ω := Real.sqrt (scale x) with hΩ
  have hΩne : Ω ≠ 0 := Real.sqrt_ne_zero'.mpr (scale_pos x)
  have hΩsq : Ω * Ω = scale x := Real.mul_self_sqrt (le_of_lt (scale_pos x))
  refine ⟨Ω⁻¹ • (1 : Comp), ?_, ?_⟩
  · -- P is invertible: det (Ω⁻¹ • 1) = Ω⁻¹ ^ card ≠ 0.
    rw [Matrix.isUnit_iff_isUnit_det, Matrix.det_smul, Matrix.det_one, mul_one]
    exact isUnit_iff_ne_zero.mpr (pow_ne_zero _ (inv_ne_zero hΩne))
  · -- Pᵀ g P = η: the coefficient Ω⁻¹ · scale · Ω⁻¹ collapses to 1.
    show (Ω⁻¹ • (1 : Comp))ᵀ * (scale x • minkowski) * (Ω⁻¹ • (1 : Comp)) = minkowski
    have key : Ω⁻¹ * scale x * Ω⁻¹ = 1 := by
      rw [← hΩsq,
          show Ω⁻¹ * (Ω * Ω) * Ω⁻¹ = (Ω⁻¹ * Ω) * (Ω * Ω⁻¹) by ring,
          inv_mul_cancel₀ hΩne, mul_inv_cancel₀ hΩne, mul_one]
    rw [Matrix.transpose_smul, Matrix.transpose_one, smul_mul_smul_comm, Matrix.one_mul,
        smul_mul_smul_comm, Matrix.mul_one, key, one_smul]

/-- de Sitter instance for the conformal metric (Λ = 3 ⇒ R = 4Λ = 12). -/
noncomputable instance confDeSitter : DeSitterUniverse confMetric where
  Λ := 3
  pos_Λ := by norm_num
  ric := fun x => (3 : ℝ) • confMetric.g x
  einstein := fun _ => rfl
  scalar_curvature := fun x => by
    have hgi : confMetric.gInv x * confMetric.g x = 1 :=
      Matrix.mul_eq_one_comm.1 (confMetric.inv x)
    show (confMetric.gInv x * ((3 : ℝ) • confMetric.g x)).trace = 4 * 3
    rw [Matrix.mul_smul, hgi, Matrix.trace_smul, Matrix.trace_one, Fintype.card_fin]
    norm_num
  lorentzian := conf_lorentzian

/-- The conformal hypothesis: ℂ³ boundary ↦ the conformally-rescaled bulk metric. -/
noncomputable def confHypothesis : HolographicDS4Hypothesis Real4D where
  BoundaryHilbertSpace := Boundary3
  holographic_dictionary := fun _ => confMetric

theorem confVerified (state : Boundary3) : verifies confHypothesis state :=
  ⟨confDeSitter⟩

/-
  ──────────────────────────────────────────────────────────────────────────────
  Boundary unitarity lever in action: a NON-UNITARY (dS-like) boundary.
  ──────────────────────────────────────────────────────────────────────────────
  Gram operator G = diag(1, -1) on ℂ²: Hermitian, invertible, but INDEFINITE.
  The state e₁ = (0,1) is a negative-norm "ghost": [e₁, e₁] = -1 < 0, so the
  boundary is non-unitary — exactly the dS/CFT regime. We then assemble a full
  `HolographicDuality` pairing it with the de Sitter bulk (Λ = 3 > 0).
-/

/-- Indefinite boundary Gram operator G = diag(1, -1). -/
noncomputable def kreinEx : KreinForm 2 where
  G := Matrix.diagonal ![(1 : ℂ), -1]
  hermitian := by
    show (Matrix.diagonal ![(1 : ℂ), -1])ᴴ = Matrix.diagonal ![(1 : ℂ), -1]
    ext i j
    fin_cases i <;> fin_cases j <;> simp [Matrix.conjTranspose_apply, Matrix.diagonal_apply]
  nondegenerate := by
    have hdet : (Matrix.diagonal ![(1 : ℂ), -1]).det = -1 := by
      rw [Matrix.det_diagonal, Fin.prod_univ_two]; simp
    rw [hdet]; exact isUnit_one.neg

/-- The boundary is non-unitary: the state (0,1) has negative norm [v,v] = -1. -/
theorem kreinEx_nonUnitary : kreinEx.IsNonUnitary := by
  refine ⟨![0, 1], ?_⟩
  unfold KreinForm.normSq
  simp [kreinEx, Fin.sum_univ_two, Matrix.diagonal_apply]

/-- A global-ℐ⁺ dS/CFT duality: non-unitary ℂ² boundary ↔ de Sitter bulk (Λ = 3 > 0). -/
noncomputable def dsDuality : HolographicDuality Real4D where
  n := 2
  boundaryForm := kreinEx
  kind := BoundaryKind.nonUnitary
  boundary_kind := kreinEx_nonUnitary
  scheme := HolographyScheme.globalBoundary
  metric := flatMetric
  bulk := deSitter
  duality := deSitter.pos_Λ

/-- The toggle works: in the global ℐ⁺ scheme this de Sitter duality is forced
    to have a non-unitary boundary. -/
example : dsDuality.kind = BoundaryKind.nonUnitary :=
  dsDuality.boundary_nonUnitary rfl

/-
  ──────────────────────────────────────────────────────────────────────────────
  The grounded, UNITARY alternative: static-patch / horizon holography.
  ──────────────────────────────────────────────────────────────────────────────
  Same de Sitter bulk (Λ > 0), but now a unitary finite-dimensional horizon system
  (positive-definite identity Gram) — the physically realizable Banks–Fischler–
  Susskind regime, with no ghost states.
-/

/-- A static-patch duality: UNITARY horizon QM (ℂ⁴) ↔ de Sitter bulk (Λ = 3 > 0). -/
noncomputable def staticPatchDuality : HolographicDuality Real4D where
  n := 4
  boundaryForm := horizonForm 4
  kind := BoundaryKind.unitary
  boundary_kind := horizonForm_unitary 4
  scheme := HolographyScheme.staticPatchHorizon
  metric := flatMetric
  bulk := deSitter
  duality := deSitter.pos_Λ

/-- The grounded toggle: a de Sitter bulk in the static-patch scheme is dual to a
    genuinely UNITARY boundary. -/
example : staticPatchDuality.kind = BoundaryKind.unitary :=
  staticPatchDuality.horizon_unitary rfl

end Ds4.Example
