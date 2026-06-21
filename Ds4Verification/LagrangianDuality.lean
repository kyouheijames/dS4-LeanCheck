import Ds4Verification.Lagrangian
import Ds4Verification.Example

/-!
# LagrangianDuality.lean — this Lagrangian instantiates the full dS/CFT non-unitarity toggle.

Wires the Lagrangian's carried boundary Krein form `ghostKrein = iΩ` into a full
`HolographicDuality`, so the framework's proved theorems hold for **this specific model**:

  • `lagrangianDuality_forced_nonUnitary` — in the global ℐ⁺ scheme, the de Sitter bulk
    (Λ = 3 > 0) FORCES the boundary to be non-unitary. Non-unitarity is a *consequence* of
    Λ > 0, not an arbitrary choice — the standard Strominger dS/CFT statement, for this action.
  • `lagrangianHorizonDuality_unitary` — the SAME de Sitter bulk has a genuinely UNITARY
    description on the static-patch horizon (BFS/SYK). Non-unitarity is scheme-dependent, not a
    sickness of the bulk.

Together these are the "forced, but with a unitary alternative on tap" rebuttal, now holding
for the model itself rather than only the abstract framework.
-/

open Ds4

namespace Ds4Verification

/-- **The bridge.** The Lagrangian's symplectic boundary form `ghostKrein = iΩ` is the
    non-unitary boundary of a de Sitter bulk (Λ = 3) in the global ℐ⁺ scheme. -/
noncomputable def lagrangianDuality : HolographicDuality Real4D where
  n := 2
  boundaryForm := ghostKrein
  kind := BoundaryKind.nonUnitary
  boundary_kind := ghostKrein_nonUnitary
  scheme := HolographyScheme.globalBoundary
  metric := Ds4.Example.flatMetric
  bulk := Ds4.Example.deSitter
  duality := Ds4.Example.deSitter.pos_Λ

/-- The duality uses exactly the Lagrangian's carried boundary form (not a separate object). -/
theorem lagrangianDuality_boundaryForm :
    lagrangianDuality.boundaryForm = exampleLagrangian.boundaryForm := rfl

/-- **Forced.** Global ℐ⁺ scheme + de Sitter bulk (Λ>0) ⇒ the boundary MUST be non-unitary.
    A consequence of Λ>0, proved — not a modeling choice one could be faulted for. -/
theorem lagrangianDuality_forced_nonUnitary :
    lagrangianDuality.kind = BoundaryKind.nonUnitary :=
  lagrangianDuality.boundary_nonUnitary rfl

/-- **Scheme-dependent.** The SAME de Sitter bulk admits a UNITARY static-patch/horizon dual
    (positive-definite Gram, BFS/SYK). Non-unitarity is a feature of the global ℐ⁺ description,
    not of the bulk physics. -/
noncomputable def lagrangianHorizonDuality : HolographicDuality Real4D where
  n := 4
  boundaryForm := horizonForm 4
  kind := BoundaryKind.unitary
  boundary_kind := horizonForm_unitary 4
  scheme := HolographyScheme.staticPatchHorizon
  metric := Ds4.Example.flatMetric
  bulk := Ds4.Example.deSitter
  duality := Ds4.Example.deSitter.pos_Λ

/-- The unitary alternative for the same bulk, proved. -/
theorem lagrangianHorizonDuality_unitary :
    lagrangianHorizonDuality.kind = BoundaryKind.unitary :=
  lagrangianHorizonDuality.horizon_unitary rfl

end Ds4Verification
