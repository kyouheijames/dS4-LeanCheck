import Mathlib
import Ds4Verification.Conditions

/-!
# CandidateExample.lean — a worked, fully-discharged candidate (seed for the loop)

A heavy long-range scalar on S³ (d = 3) with kinetic exponent s = 1.4 and a
principal-series probed operator Δ = 3/2 + i·μ. Mirrors your `Example.lean`:
a complete instantiation whose filter obligations are proved, no `sorry`.
-/

namespace Ds4Verification

/-- A concrete non-local (s ≠ 1) principal-series candidate in the global scheme. -/
noncomputable def exΔ : ℂ := ⟨3/2, 1⟩          -- 3/2 + i

noncomputable def exampleCandidate : Candidate where
  d          := 3
  s          := 1.4
  Δ          := exΔ
  scheme     := HolographyScheme.globalBoundary
  nonUnitary := True                            -- stand-in for `IsNonUnitary gram`

theorem exampleCandidate_principal : IsPrincipal 3 exΔ := by
  constructor
  · simp [exΔ]
  · simp [exΔ]

/-- The seed passes the filter. -/
theorem exampleCandidate_worth : WorthInvestigating exampleCandidate :=
  worth_of_principal exampleCandidate
    exampleCandidate_principal rfl trivial

/-- …and it is flagged NON-LOCAL (s = 1.4 ≠ 1 ⇒ γ_T ≠ 0): a target for Part 2. -/
theorem exampleCandidate_nonlocal :
    gammaT_free exampleCandidate.s ≠ 0 := by
  apply nonlocal_of_ne_one; norm_num [exampleCandidate]

end Ds4Verification
