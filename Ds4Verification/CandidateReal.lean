import Mathlib
import Ds4Verification.Conditions
import Ds4Verification.Example   -- Core's proved Krein ghost: kreinEx / kreinEx_nonUnitary

/-!
# CandidateReal.lean — Part 1 checked "for real": fingerprint wired to PROVED objects.

`CandidateExample.lean` passes the filter, but two of its gates are placeholders:
  • `nonUnitary := True`        — C4 discharged by `trivial`: **vacuous** (no ghost checked).
  • `Δ := ⟨3/2, 1⟩` hand-set    — C1 "principal" asserted, not grounded in a bulk mass.

Here both are replaced by `Core`'s already-proved machinery, so the gates are non-vacuous:
  • **C4 ghost** ← `Ds4.Example.kreinEx_nonUnitary`: the state (0,1) is a genuine
    negative-norm state of the indefinite Gram form `G = diag(1,−1)` (a real proof).
  • **C1 principal** ← `Ds4.BoundaryOperator.principalSeries_of_heavy`: `Im Δ ≠ 0` is
    *derived* from a heavy mass `m²ℓ² > (d/2)²` via the mass–dimension relation
    `Δ(d−Δ) = m²`; and `Re Δ = d/2` is *derived* from that same relation (`reEq_half_*`).

This is exactly "checking Part 1 for real" in the sense a type checker can: the algebraic
fingerprint is instantiated by concrete objects that carry honest proofs (indefinite Krein
form, mass-grounded complex weight) — not by `True`/`trivial`.

What this still does NOT do (honest scope, = STATUS.md):
  • It does NOT derive `Δχ = (d−2s)/2` from the `(−∂²)ˢ` action. That is the free-sector
    analysis (fractional Laplacian as a Fourier multiplier `|p|^{2s}`), which Mathlib does
    not currently have — confirmed absent. So `s` and the kinetic origin remain modeling
    data; only the *consequences* (series, ghost) are proved here.
  • It does NOT touch the interacting `γ_T(s)` (Part 2) or the averaging conjecture (Part 3).
-/

open Ds4

namespace Ds4Verification

/-- **Derived, not asserted.** The mass–dimension relation `Δ(d−Δ)=m²` (real `m²`) together
    with `Im Δ ≠ 0` *forces* `Re Δ = d/2`: the imaginary part of the relation is
    `Im Δ · (d − 2 Re Δ) = 0`, and `Im Δ ≠ 0` kills the first factor. This is the precise
    statement that "principal series ⇒ weight sits on the line `Re Δ = d/2`" is a theorem
    about the mass, not a modeling choice. -/
theorem reEq_half_of_imNe (O : BoundaryOperator) (h : O.Δ.im ≠ 0) :
    O.Δ.re = (O.d : ℝ) / 2 := by
  have him := congrArg Complex.im O.dim_relation
  simp only [Complex.mul_im, Complex.sub_re, Complex.sub_im, Complex.natCast_re,
    Complex.natCast_im, Complex.ofReal_im, zero_sub] at him
  -- him : O.Δ.re * (-O.Δ.im) + O.Δ.im * ((O.d : ℝ) - O.Δ.re) = 0
  have key : O.Δ.im * ((O.d : ℝ) - 2 * O.Δ.re) = 0 := by ring_nf; ring_nf at him; linarith
  rcases mul_eq_zero.mp key with h0 | h0
  · exact absurd h0 h
  · linarith

/-- A concrete HEAVY boundary operator: `d = 3`, `Δ = 3/2 + i`, `m² = 13/4`.
    Then `Δ(d−Δ) = (3/2+i)(3/2−i) = 9/4 + 1 = 13/4 = m²` (the relation holds), and the
    field is heavy: `m² = 13/4 > 9/4 = (d/2)²` — so it lands in the principal series. -/
noncomputable def realOp : BoundaryOperator where
  d := 3
  m2 := 13 / 4
  Δ := ⟨3 / 2, 1⟩
  dim_relation := by
    apply Complex.ext <;>
      simp [Complex.mul_re, Complex.mul_im, Complex.sub_re, Complex.sub_im,
        Complex.ofReal_re, Complex.ofReal_im] <;> norm_num

theorem realOp_heavy : ((realOp.d : ℝ) / 2) ^ 2 < realOp.m2 := by
  show ((3 : ℝ) / 2) ^ 2 < 13 / 4; norm_num

/-- C1 grounded in physics: `Im Δ ≠ 0` from the heavy mass, `Re Δ = d/2` from the relation. -/
theorem realOp_isPrincipal : IsPrincipal (realOp.d : ℝ) realOp.Δ := by
  have him : realOp.Δ.im ≠ 0 := realOp.principalSeries_of_heavy realOp_heavy
  exact ⟨reEq_half_of_imNe realOp him, him⟩

/-- The candidate: a NON-LOCAL (`s = 1.4`) heavy principal-series operator in the global
    ℐ⁺ scheme, with the non-unitarity gate carrying the *real* Krein ghost as its content
    (not `True`). -/
noncomputable def realCandidate : Candidate where
  d := (realOp.d : ℝ)
  s := 1.4
  Δ := realOp.Δ
  scheme := HolographyScheme.globalBoundary
  nonUnitary := Ds4.Example.kreinEx.IsNonUnitary    -- the genuine Prop, witnessed below

/-- **The real Part-1 pass.** Every gate is discharged by an honest proof:
    C1 from the mass (`realOp_isPrincipal`), C2 derived, C3 `rfl`, and crucially
    C4 by `kreinEx_nonUnitary` — the proved negative-norm ghost, NOT `trivial`. -/
theorem realCandidate_worth : WorthInvestigating realCandidate :=
  worth_of_principal realCandidate
    realOp_isPrincipal
    rfl
    Ds4.Example.kreinEx_nonUnitary

/-- …and it is genuinely non-local (`s = 1.4 ≠ 1 ⇒ γ_T ≠ 0`): a Part-2 target. -/
theorem realCandidate_nonlocal : gammaT_free realCandidate.s ≠ 0 := by
  apply nonlocal_of_ne_one
  show (1.4 : ℝ) ≠ 1; norm_num

end Ds4Verification
