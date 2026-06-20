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

/-- Which holographic scheme relates the boundary to the bulk. -/
inductive HolographyScheme where
  /-- Boundary CFT at future infinity ℐ⁺ (Strominger global dS/CFT). -/
  | globalBoundary
  /-- A unitary system on the observer's static-patch horizon (Banks–Fischler–Susskind). -/
  | staticPatchHorizon
deriving DecidableEq

/-- Holographic consistency between boundary unitarity and the sign of Λ, *per scheme*:

    • global ℐ⁺ :  de Sitter (Λ>0) ↔ NON-unitary CFT;  anti-de Sitter (Λ<0) ↔ unitary CFT.
    • static patch :  de Sitter (Λ>0) ↔ UNITARY horizon QM; the non-unitary pairing is
      *excluded* — horizon holography is unitary by construction.

    This is the physically grounded fix: the unitary, lab-realizable regime is the static
    patch, not the global ℐ⁺ boundary (whose complex weights / ghosts make it non-unitary). -/
def DualityConsistent : HolographyScheme → BoundaryKind → ℝ → Prop
  | .globalBoundary,    .nonUnitary, Λ => 0 < Λ
  | .globalBoundary,    .unitary,    Λ => Λ < 0
  | .staticPatchHorizon, .unitary,   Λ => 0 < Λ
  | .staticPatchHorizon, .nonUnitary, _ => False

/-- A full holographic duality: a boundary form of a definite kind, the holographic
    scheme, a bulk de Sitter metric, and the consistency relation tying them together. -/
structure HolographicDuality (M : Type*) where
  /-- Boundary Hilbert-space dimension. -/
  n : ℕ
  /-- The boundary Gram operator. -/
  boundaryForm : KreinForm n
  /-- Unitary or non-unitary. -/
  kind : BoundaryKind
  /-- Proof the form realises the declared kind. -/
  boundary_kind : boundaryForm.Satisfies kind
  /-- Which holographic scheme (global ℐ⁺ vs static-patch horizon). -/
  scheme : HolographyScheme
  /-- The emergent bulk metric. -/
  metric : MetricField M
  /-- A de Sitter structure on it (so Λ > 0). -/
  bulk : DeSitterUniverse metric
  /-- Boundary unitarity is consistent with the sign of Λ, given the scheme. -/
  duality : DualityConsistent scheme kind bulk.Λ

/-- In the GLOBAL ℐ⁺ scheme, a de Sitter bulk forces a NON-unitary boundary (Strominger). -/
theorem HolographicDuality.boundary_nonUnitary (D : HolographicDuality M)
    (hs : D.scheme = HolographyScheme.globalBoundary) :
    D.kind = BoundaryKind.nonUnitary := by
  cases hk : D.kind with
  | unitary =>
      have hd := D.duality
      rw [hs, hk] at hd
      exact absurd (hd : D.bulk.Λ < 0) (not_lt.mpr D.bulk.pos_Λ.le)
  | nonUnitary => rfl

/-- In the STATIC-PATCH scheme, the de Sitter bulk is dual to a UNITARY horizon system —
    the physically grounded, lab-realizable regime (SYK / matrix QM on the horizon). -/
theorem HolographicDuality.horizon_unitary (D : HolographicDuality M)
    (hs : D.scheme = HolographyScheme.staticPatchHorizon) :
    D.kind = BoundaryKind.unitary := by
  cases hk : D.kind with
  | unitary => rfl
  | nonUnitary =>
      have hd := D.duality
      rw [hs, hk] at hd
      exact hd.elim

/-! ───────────────────────────────────────────────────────────────────────────
    ## Grounding in real field theories

    The non-unitary boundary is not a free parameter: the concrete dS₄ realisation is
    the **Sp(N) model** — N anticommuting (Grassmann) scalars in 3D with Sp(N)
    symmetry, dual to Vasiliev higher-spin gravity on dS₄ (Anninos–Hartman–Strominger).
    It is the analytic continuation N → −N of the *unitary* O(N) vector model (dual to
    higher-spin on AdS₄). The symplectic invariant makes its inner product indefinite
    (→ `KreinForm`), and N → −N flips the central charge (→ imaginary/negative `c`).

    A bulk scalar of mass m on dS_{d+1} maps to a boundary operator of dimension Δ
    fixed by the **mass–dimension relation Δ(d − Δ) = m²ℓ²**. Heavy fields land in the
    **principal series** (complex Δ = d/2 ± iμ); light fields in the **complementary
    series** (real Δ). The lever below makes this precise and proves the threshold.
    ─────────────────────────────────────────────────────────────────────────── -/

/-- A boundary operator dual to a bulk scalar of mass² `m2` (in units ℓ = 1) on dS_{d+1}.
    Its conformal weight `Δ` is fixed by the dS mass–dimension relation Δ(d − Δ) = m². -/
structure BoundaryOperator where
  /-- Boundary CFT dimension (3 for dS₄). -/
  d : ℕ
  /-- Bulk mass² in units of the dS radius, m²ℓ². -/
  m2 : ℝ
  /-- Conformal weight of the dual operator (generically complex). -/
  Δ : ℂ
  /-- The dS mass–dimension relation. -/
  dim_relation : Δ * ((d : ℂ) - Δ) = (m2 : ℂ)

/-- Principal series: complex conformal weight (the generic, non-unitary dS regime). -/
def BoundaryOperator.IsPrincipalSeries (O : BoundaryOperator) : Prop := O.Δ.im ≠ 0

/-- Complementary series: real conformal weight (light fields). -/
def BoundaryOperator.IsComplementarySeries (O : BoundaryOperator) : Prop := O.Δ.im = 0

/-- **Threshold theorem:** a heavy field (m²ℓ² > (d/2)²) is in the principal series —
    its conformal weight is genuinely complex. This is the field-theory origin of the
    complex dimensions in dS/CFT. -/
theorem BoundaryOperator.principalSeries_of_heavy (O : BoundaryOperator)
    (h : ((O.d : ℝ) / 2) ^ 2 < O.m2) : O.IsPrincipalSeries := by
  intro hb
  -- If Δ is real, the real part of the relation gives Δ.re (d − Δ.re) = m², which is
  -- bounded above by (d/2)² — contradicting the heavy-mass hypothesis.
  have hre : O.Δ.re * ((O.d : ℝ) - O.Δ.re) = O.m2 := by
    have hr := congrArg Complex.re O.dim_relation
    simpa [Complex.mul_re, Complex.sub_re, Complex.sub_im, Complex.natCast_re,
      Complex.natCast_im, Complex.ofReal_re, hb] using hr
  nlinarith [sq_nonneg ((O.d : ℝ) - 2 * O.Δ.re), hre, h]

/-! ### Static-patch / horizon holography — the unitary, lab-realizable grounding

    Banks–Fischler–Susskind: rather than a boundary CFT at ℐ⁺, the dS static patch is
    described by a UNITARY, finite-dimensional quantum system on the observer's horizon
    (à la SYK / matrix QM). Below: the static-patch metric with its causality (signature)
    check, and a positive-definite horizon Gram operator (a genuinely unitary boundary). -/

/-- Static-patch lapse u(r) = 1 − r²/R². Strictly positive inside the horizon (r < R). -/
noncomputable def lapse (R r : ℝ) : ℝ := 1 - r ^ 2 / R ^ 2

/-- dS static-patch metric components diag(−u, u⁻¹, r², r²) (θ = π/2 slice), u = lapse R r,
    in coordinates (t, r, θ, φ):  ds² = −u dt² + u⁻¹ dr² + r² dΩ². -/
noncomputable def staticPatchComp (R r : ℝ) : Comp :=
  Matrix.diagonal ![-(lapse R r), (lapse R r)⁻¹, r ^ 2, r ^ 2]

/-- Causality / signature check inside the horizon: g₀₀ < 0 and g₁₁, g₂₂, g₃₃ > 0, i.e. the
    Lorentzian (-,+,+,+) signature. No Euclidean variation (all-positive g) can pass. -/
theorem staticPatch_signature (R r : ℝ) (hr : 0 < r) (hu : 0 < lapse R r) :
    staticPatchComp R r 0 0 < 0 ∧ 0 < staticPatchComp R r 1 1 ∧
      0 < staticPatchComp R r 2 2 ∧ 0 < staticPatchComp R r 3 3 := by
  unfold staticPatchComp
  refine ⟨?_, ?_, ?_, ?_⟩ <;> rw [Matrix.diagonal_apply_eq]
  · simpa using hu
  · simpa using inv_pos.mpr hu
  · simpa using pow_pos hr 2
  · simpa using pow_pos hr 2

/-- The unitary horizon Hilbert space: positive-definite identity Gram. A stand-in for a
    finite-dimensional unitary system (SYK / matrix QM) on the static-patch horizon. -/
noncomputable def horizonForm (n : ℕ) : KreinForm n where
  G := 1
  hermitian := Matrix.isHermitian_one
  nondegenerate := by rw [Matrix.det_one]; exact isUnit_one

/-- The horizon norm is the standard positive sum [v,v] = Σᵢ ‖vᵢ‖². -/
theorem horizonForm_normSq (n : ℕ) (v : StateVec n) :
    (horizonForm n).normSq v = ∑ i, Complex.normSq (v i) := by
  unfold KreinForm.normSq horizonForm
  have hsum : (∑ i, ∑ j, (starRingEnd ℂ) (v i) * (1 : Matrix (Fin n) (Fin n) ℂ) i j * v j)
      = ∑ i, (starRingEnd ℂ) (v i) * v i := by
    refine Finset.sum_congr rfl (fun i _ => ?_)
    rw [Finset.sum_eq_single i]
    · rw [Matrix.one_apply_eq, mul_one]
    · intro j _ hj; rw [Matrix.one_apply_ne (Ne.symm hj), mul_zero, zero_mul]
    · intro h; exact absurd (Finset.mem_univ i) h
  rw [hsum, Complex.re_sum]
  refine Finset.sum_congr rfl (fun i _ => ?_)
  rw [mul_comm, Complex.mul_conj, Complex.ofReal_re]

/-- The horizon boundary is genuinely UNITARY: positive-definite, no ghost states. -/
theorem horizonForm_unitary (n : ℕ) : (horizonForm n).IsUnitary := by
  intro v hv
  rw [horizonForm_normSq]
  obtain ⟨i, hi⟩ := Function.ne_iff.mp hv
  simp only [Pi.zero_apply] at hi
  exact Finset.sum_pos' (fun j _ => Complex.normSq_nonneg _)
    ⟨i, Finset.mem_univ i, Complex.normSq_pos.mpr hi⟩

end Ds4
