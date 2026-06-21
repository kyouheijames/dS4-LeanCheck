import Mathlib
import Ds4Verification.LongRange
import Ds4Verification.Locality
import Ds4Verification.ShadowPairing
-- import Ds4Verification.Core   -- ← uncomment and reconcile names against your Core.lean

/-!
# Conditions.lean — the "worth investigating?" filter

A candidate boundary Lagrangian is reduced to algebraic data, and `WorthInvestigating`
bundles the gates C1–C4 that make it a legitimate dS/CFT* dual in the global ℐ⁺
(Strominger) scheme. The generator must produce a candidate together with a term of
type `WorthInvestigating candidate` containing no `sorry`; that term IS the filter pass.

RECONCILE-WITH-CORE NOTES (you have these names already in Core.lean):
  • `scheme : HolographyScheme` — replace the local stub below with your Core type
    (constructors `globalBoundary | staticPatchHorizon`).
  • `nonUnitary` — replace the `Prop` field with `IsNonUnitary c.gram` using your
    `KreinForm` / `IsNonUnitary`. Until then it is carried as an explicit hypothesis.
-/

namespace Ds4Verification

/-- LOCAL STUB — delete once you import Core's `HolographyScheme`. -/
inductive HolographyScheme where
  | globalBoundary
  | staticPatchHorizon
deriving DecidableEq

/-- The algebraic data the filter operates on. -/
structure Candidate where
  d          : ℝ                 -- boundary dimension (dS₄ ⇒ 3)
  s          : ℝ                 -- kinetic exponent of (−∂²)ˢ
  Δ          : ℂ                 -- conformal weight of the probed operator
  scheme     : HolographyScheme
  nonUnitary : Prop              -- ← replace with `IsNonUnitary gram` against Core

/-- C1–C4. A candidate worth investigating in the global ℐ⁺ scheme. -/
structure WorthInvestigating (c : Candidate) : Prop where
  /-- C1 — principal series: genuinely complex weight (heavy/propagating). -/
  principal  : IsPrincipal c.d c.Δ
  /-- C2 — shadow/CPT positivity: the shadow map is conjugation on this weight. -/
  shadowCPT  : shadow c.d c.Δ = (starRingEnd ℂ) c.Δ
  /-- C3 — global future-boundary scheme (where a boundary Lagrangian even types). -/
  scheme_ok  : c.scheme = HolographyScheme.globalBoundary
  /-- C4 — non-unitary boundary (indefinite Krein/Gram, not reflection-positive). -/
  ghost      : c.nonUnitary

/-- **Filter constructor.** Any principal candidate in the global non-unitary
    scheme passes — and C2 is *derived*, not assumed (it follows from C1). This is
    the lemma the generator targets. -/
theorem worth_of_principal (c : Candidate)
    (hp : IsPrincipal c.d c.Δ)
    (hs : c.scheme = HolographyScheme.globalBoundary)
    (hn : c.nonUnitary) :
    WorthInvestigating c where
  principal := hp
  shadowCPT := shadow_eq_conj_on_principal c.d c.Δ hp
  scheme_ok := hs
  ghost     := hn

open Classical in
/-- **Filter output for ranking.** For a passing candidate, report its locality
    order parameter so the driver can prioritize the non-local (`s ≠ 1`)
    candidates — the ones relevant to the locality-breaking program. -/
noncomputable def localityVerdict (c : Candidate) : ℝ × Bool :=
  (gammaT_free c.s, decide (c.s = 1))

end Ds4Verification
