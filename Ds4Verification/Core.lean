/-
  dS4-LeanCheck — Core verification framework (component formulation).

  Lean's type checker is the verifier: a generated holographic dictionary "passes" only
  if it compiles as a value satisfying the contract below — including REAL proof
  obligations for the metric signature and the de Sitter / Einstein curvature relation.

  ──────────────────────────────────────────────────────────────────────────────
  WHAT IS GENUINELY CHECKED
  ──────────────────────────────────────────────────────────────────────────────
    • type-safety of the boundary→bulk dictionary 𝓗_∂ → MetricField,
    • symmetry of the metric components g_μν = g_νμ,
    • invertibility of g (it carries its inverse g^{μν} with g·g⁻¹ = 1),
    • Lorentzian signature (-,+,+,+):  via Sylvester's law of inertia, g is congruent
      to the Minkowski form  η = diag(-1,1,1,1)  (∃ invertible P, Pᵀ g P = η),
    • the de Sitter / Einstein equation  Ric = Λ • g  with Λ > 0, together with the
      4D maximally-symmetric trace identity  R = gᵘᵛ Ric_μν = 4Λ
      (so that R_μν − ½R g_μν + Λ g_μν = 0 holds identically).

  ──────────────────────────────────────────────────────────────────────────────
  HONEST SCOPE NOTE
  ──────────────────────────────────────────────────────────────────────────────
  The Ricci tensor `ric` is carried as data constrained by the Einstein equation; it is
  NOT yet *derived* from g via Christoffel symbols (that needs the full connection
  machinery and is the remaining open milestone — see README). So the framework verifies
  the Einstein equation as an algebraic relation between g and a postulated Ric, plus a
  genuine, non-axiomatic signature check. This is strictly stronger than the previous
  `ricci_curvature_flatness : True`.

  Components are taken in the canonical chart of the bulk (modelled on ℝ⁴), so a bulk
  "point" is just an element of an arbitrary index type `M`; no manifold typeclass is
  needed for the algebra, which also removes Mathlib-version sensitivity.
-/
import Mathlib.Data.Matrix.Basic
import Mathlib.LinearAlgebra.Matrix.Trace
import Mathlib.LinearAlgebra.Matrix.Symmetric
import Mathlib.LinearAlgebra.Matrix.Hermitian
import Mathlib.LinearAlgebra.Matrix.Determinant.Basic
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Tactic

open scoped Matrix  -- enables the `ᵀ` transpose notation

namespace Ds4

/-- Spacetime index μ ∈ {0,1,2,3}. -/
abbrev Idx : Type := Fin 4

/-- A rank-2 component matrix (e.g. g_μν or Ric_μν) in the canonical chart. -/
abbrev Comp : Type := Matrix Idx Idx ℝ

/-- Coordinate model space for the 4D bulk. -/
abbrev Real4D : Type := EuclideanSpace ℝ (Fin 4)

/-- The Minkowski component matrix with signature (-,+,+,+). -/
def minkowski : Comp := Matrix.diagonal ![(-1 : ℝ), 1, 1, 1]

variable (M : Type*)

/--
  A (pseudo-)metric field on the bulk: at each point `x`, a symmetric invertible
  component matrix `g x`, together with its inverse `gInv x`.
-/
structure MetricField where
  /-- Covariant components g_μν(x). -/
  g : M → Comp
  /-- Contravariant components g^{μν}(x). -/
  gInv : M → Comp
  /-- g is symmetric: g_μν = g_νμ. -/
  symm : ∀ x, (g x).IsSymm
  /-- gInv is a genuine inverse: g · g⁻¹ = 1. -/
  inv : ∀ x, g x * gInv x = 1

variable {M}

/--
  Lorentzian signature (-,+,+,+). By Sylvester's law of inertia, a real symmetric
  matrix has signature (-,+,+,+) iff it is congruent to `minkowski`: there is an
  invertible change of frame `P` with `Pᵀ g P = η`.
-/
def MetricField.Lorentzian (m : MetricField M) : Prop :=
  ∀ x, ∃ P : Comp, IsUnit P ∧ Pᵀ * m.g x * P = minkowski

/--
  A valid 4D de Sitter universe for the metric `m`.

  Every field is a real proof obligation checked by the compiler:
    • `pos_Λ`            : Λ > 0,
    • `einstein`         : Ric_μν = Λ g_μν   (Einstein/de Sitter relation),
    • `scalar_curvature` : gᵘᵛ Ric_μν = 4Λ   (4D maximally-symmetric trace identity),
    • `lorentzian`       : g has signature (-,+,+,+).
-/
class DeSitterUniverse (m : MetricField M) where
  /-- Cosmological constant Λ. -/
  Λ : ℝ
  /-- de Sitter requires Λ > 0. -/
  pos_Λ : 0 < Λ
  /-- Postulated Ricci components Ric_μν. -/
  ric : M → Comp
  /-- Einstein equation for a de Sitter space: Ric = Λ • g. -/
  einstein : ∀ x, ric x = Λ • m.g x
  /-- Scalar curvature R = gᵘᵛ Ric_μν = 4Λ in 4 dimensions. -/
  scalar_curvature : ∀ x, (m.gInv x * ric x).trace = 4 * Λ
  /-- The metric is Lorentzian (-,+,+,+). -/
  lorentzian : m.Lorentzian

/--
  The target the LLM must instantiate: a boundary CFT Hilbert space together with a
  dictionary turning boundary states into bulk metric fields.
-/
structure HolographicDS4Hypothesis (M : Type*) where
  /-- The boundary CFT Hilbert space 𝓗_∂. -/
  BoundaryHilbertSpace : Type*
  [normed : NormedAddCommGroup BoundaryHilbertSpace]
  [innerSpace : InnerProductSpace ℂ BoundaryHilbertSpace]
  /-- The dictionary: boundary state ↦ emergent bulk metric. -/
  holographic_dictionary : BoundaryHilbertSpace → MetricField M

attribute [instance] HolographicDS4Hypothesis.normed HolographicDS4Hypothesis.innerSpace

/-- `hyp` verifies at boundary state `state` when its emergent metric is a dS₄ universe. -/
def verifies (hyp : HolographicDS4Hypothesis M) (state : hyp.BoundaryHilbertSpace) : Prop :=
  Nonempty (DeSitterUniverse (hyp.holographic_dictionary state))

/-- Discharge `verifies` from an available `DeSitterUniverse` instance. -/
theorem verifies_of_instance
    (hyp : HolographicDS4Hypothesis M) (state : hyp.BoundaryHilbertSpace)
    [inst : DeSitterUniverse (hyp.holographic_dictionary state)] :
    verifies hyp state :=
  ⟨inst⟩

/-! ───────────────────────────────────────────────────────────────────────────
    ## Boundary unitarity lever — the AdS/CFT ↔ dS/CFT toggle

    AdS/CFT pairs the bulk with a *unitary* boundary CFT (positive-definite inner
    product). dS/CFT (Strominger) pairs it with a *non-unitary* boundary, modelled
    here as a Krein space: a Hermitian, non-degenerate but **indefinite** Gram
    operator G, whose indefiniteness means negative-norm ("ghost") states exist.

    The toggle `BoundaryKind` plus `DualityConsistent` ties boundary unitarity to the
    sign of Λ, so that a genuine de Sitter bulk (Λ > 0) *forces* a non-unitary
    boundary (`HolographicDuality.boundary_nonUnitary`).
    ─────────────────────────────────────────────────────────────────────────── -/

/-- A boundary state vector in 𝓗_∂ = ℂⁿ. -/
abbrev StateVec (n : ℕ) : Type := Fin n → ℂ

/-- A boundary Gram operator G defining the inner product [x,y] = xᴴ G y.
    Hermitian + non-degenerate = a (possibly indefinite) inner product. -/
structure KreinForm (n : ℕ) where
  /-- The Gram matrix G. -/
  G : Matrix (Fin n) (Fin n) ℂ
  /-- G is Hermitian (so [x,y] = conj [y,x] and [v,v] is real). -/
  hermitian : G.IsHermitian
  /-- G is non-degenerate (invertible). -/
  nondegenerate : IsUnit G.det

/-- Indefinite norm-squared [v,v] = Σᵢⱼ conj(vᵢ) Gᵢⱼ vⱼ (real, since G is Hermitian). -/
noncomputable def KreinForm.normSq {n : ℕ} (K : KreinForm n) (v : StateVec n) : ℝ :=
  (∑ i, ∑ j, (starRingEnd ℂ) (v i) * K.G i j * v j).re

/-- Unitary (AdS-like) boundary: positive-definite — no negative-norm states. -/
def KreinForm.IsUnitary {n : ℕ} (K : KreinForm n) : Prop :=
  ∀ v : StateVec n, v ≠ 0 → 0 < K.normSq v

/-- Non-unitary (dS-like / Krein) boundary: a negative-norm (ghost) state exists. -/
def KreinForm.IsNonUnitary {n : ℕ} (K : KreinForm n) : Prop :=
  ∃ v : StateVec n, K.normSq v < 0

/-- The two regimes are mutually exclusive — the lever is non-vacuous. -/
theorem KreinForm.not_unitary_of_nonUnitary {n : ℕ} (K : KreinForm n)
    (h : K.IsNonUnitary) : ¬ K.IsUnitary := by
  obtain ⟨v, hv⟩ := h
  intro hpos
  rcases eq_or_ne v 0 with rfl | hne
  · simp [KreinForm.normSq] at hv
  · exact absurd hv (not_lt.mpr (hpos v hne).le)

/-- The dS-vs-AdS boundary toggle. -/
inductive BoundaryKind where
  /-- AdS/CFT: a unitary boundary CFT. -/
  | unitary
  /-- dS/CFT: a non-unitary boundary (Strominger). -/
  | nonUnitary
deriving DecidableEq

/-- Which regime a given form realises. -/
def KreinForm.Satisfies {n : ℕ} (K : KreinForm n) : BoundaryKind → Prop
  | .unitary => K.IsUnitary
  | .nonUnitary => K.IsNonUnitary

/-- Holographic consistency: a de Sitter bulk (Λ > 0) is dual to a NON-unitary
    boundary; an anti-de Sitter bulk (Λ < 0) to a unitary one. -/
def DualityConsistent : BoundaryKind → ℝ → Prop
  | .unitary, Λ => Λ < 0
  | .nonUnitary, Λ => 0 < Λ

/-- A full holographic duality: a boundary form of a definite kind, a bulk de Sitter
    metric, and the consistency relation tying boundary unitarity to the sign of Λ. -/
structure HolographicDuality (M : Type*) where
  /-- Boundary Hilbert-space dimension. -/
  n : ℕ
  /-- The boundary Gram operator. -/
  boundaryForm : KreinForm n
  /-- Unitary or non-unitary. -/
  kind : BoundaryKind
  /-- Proof the form realises the declared kind. -/
  boundary_kind : boundaryForm.Satisfies kind
  /-- The emergent bulk metric. -/
  metric : MetricField M
  /-- A de Sitter structure on it (so Λ > 0). -/
  bulk : DeSitterUniverse metric
  /-- Boundary unitarity is consistent with the sign of Λ. -/
  duality : DualityConsistent kind bulk.Λ

/-- The heart of dS/CFT: a genuine de Sitter bulk forces a NON-unitary boundary. -/
theorem HolographicDuality.boundary_nonUnitary (D : HolographicDuality M) :
    D.kind = BoundaryKind.nonUnitary := by
  cases hk : D.kind with
  | unitary =>
      have hd := D.duality
      rw [hk] at hd
      exact absurd (hd : D.bulk.Λ < 0) (not_lt.mpr D.bulk.pos_Λ.le)
  | nonUnitary => rfl

end Ds4
