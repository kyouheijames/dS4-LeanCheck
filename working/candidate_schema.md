# Candidate schema — what the generator must emit

Each round, the Anthropic model emits **one** Lean module `Ds4Verification/Generated.lean`
that (a) compiles, (b) contains no `sorry`, and (c) produces a term of type
`WorthInvestigating <candidate>`. That term is the filter pass.

The model is NOT asked to invent bulk geometry. It writes a **boundary Lagrangian's
algebraic fingerprint** and discharges the four conditions.

## Required shape

```lean
import Mathlib
import Ds4Verification.Conditions

namespace Ds4Verification

noncomputable def genΔ : ℂ := ⟨_, _⟩        -- Re must equal d/2; Im ≠ 0

noncomputable def genCandidate : Candidate where
  d          := _        -- 3 for dS₄
  s          := _        -- kinetic exponent; s ≠ 1 ⇒ non-local (the interesting case)
  Δ          := genΔ
  scheme     := HolographyScheme.globalBoundary
  nonUnitary := _        -- proof/witness of indefinite Krein form

theorem genCandidate_principal : IsPrincipal genCandidate.d genΔ := by
  constructor <;> simp [genΔ, genCandidate] <;> norm_num

theorem genCandidate_worth : WorthInvestigating genCandidate :=
  worth_of_principal genCandidate genCandidate_principal rfl _
```

## The four gates (what "satisfies the conditions" means)

| Gate | Meaning | How it is discharged |
|------|---------|----------------------|
| C1 principal | `Re Δ = d/2`, `Im Δ ≠ 0` (heavy, propagating) | `norm_num` on the literal weight |
| C2 shadow/CPT | shadow map = conjugation on Δ | **derived** from C1 (`shadow_eq_conj_on_principal`) |
| C3 scheme | global ℐ⁺ boundary | `rfl` |
| C4 ghost | non-unitary boundary (indefinite Gram) | witness against your `KreinForm`/`IsNonUnitary` |

## What the loop does with a pass

On success the driver computes the **locality verdict** from the emitted `s`:
`γ_T = 2(s − 1)`, `local? = (s == 1)`. Candidates with `s ≠ 1` (non-local,
γ_T ≠ 0) are the ones written to `runs/worth_investigating/` and handed to Part 2.
A pass with `s = 1` is a consistent but *local* dual — recorded, deprioritized.
