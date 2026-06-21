import Mathlib
import Ds4Verification.Locality
import Ds4Verification.LongRange

/-!
# StressTensor.lean — locality as a conserved-current predicate (the structural rail).

Target: turn "locality" into a machine-checked equivalence rather than a docstring claim.
Previously `Locality.gammaT_free` was defined as `2(s-1)` directly, and the link to a
*conserved stress tensor* lived only in prose. Here we close that gap:

  • carry the would-be stress tensor by its scaling dimension `Δ_T`,
  • define CONSERVATION as saturating the spin-2 bound `Δ_T = d`
    (a conserved spin-ℓ current has `Δ = d - 2 + ℓ`; `ℓ = 2 ⇒ Δ_T = d`),
  • define the anomalous dimension `γ_T := Δ_T - d` (now derived from `Δ_T`, not posited),
  • prove the **definitional equivalence** `γ_T = 0 ⟺ ∃ conserved local stress tensor`,
  • and show a given construction's `Δ_T` *discharges or violates* it.

This is "locality as a physical observable" as a decidable predicate: the equivalence is the
consistency rail, and any construction is checked against it by its `Δ_T` alone.
-/

namespace Ds4Verification

/-- The would-be (spin-2) stress tensor of the boundary theory, carried by its scaling
    dimension `Δ_T` over a boundary of dimension `d`. -/
structure StressTensor where
  /-- Boundary dimension `d`. -/
  d : ℝ
  /-- Scaling dimension `Δ_T` of the (would-be) stress tensor. -/
  dimT : ℝ

namespace StressTensor

/-- **Conservation = locality.** A spin-2 current is a conserved *local* stress tensor iff it
    saturates the conservation bound `Δ_T = d`. (Conserved spin-ℓ currents have
    `Δ = d - 2 + ℓ`; at `ℓ = 2` this is `Δ_T = d`.) A theory with such a current is local. -/
def IsConserved (T : StressTensor) : Prop := T.dimT = T.d

/-- Anomalous dimension of the stress tensor: `γ_T = Δ_T - d` — derived from `Δ_T`. -/
def gammaT (T : StressTensor) : ℝ := T.dimT - T.d

/-- **The locality rail (definitional equivalence).** `γ_T = 0 ⟺ the stress tensor is a
    conserved local current`. This is exactly "γ_T = 0 ⟺ ∃ conserved local stress tensor"
    as a machine-checked predicate, with `γ_T` the order parameter. -/
theorem gammaT_zero_iff_conserved (T : StressTensor) :
    T.gammaT = 0 ↔ T.IsConserved := by
  unfold gammaT IsConserved; exact sub_eq_zero

end StressTensor

/-- The would-be stress tensor of the free long-range theory at exponent `s`: its dimension
    is `Δ_T = d + 2(s - 1)`, so `γ_T = 2(s - 1)` reproduces `Locality.gammaT_free`. -/
def freeStressTensor (d s : ℝ) : StressTensor where
  d := d
  dimT := d + 2 * (s - 1)

/-- The new (dimension-based) `γ_T` of the free stress tensor agrees with the old order
    parameter `gammaT_free s = 2(s-1)`: the `Δ_T - d` definition and the Part-1 convention
    coincide, so nothing drifted between the layers. -/
theorem freeStressTensor_gammaT (d s : ℝ) :
    (freeStressTensor d s).gammaT = gammaT_free s := by
  unfold StressTensor.gammaT freeStressTensor gammaT_free; ring

/-- **A construction discharging the rail.** The free long-range stress tensor is conserved
    (local) iff `s = 1`. For `s ≠ 1` the bound `Δ_T = d` is *violated* (`γ_T ≠ 0`): locality
    is broken, now as a checked consequence of the construction's `Δ_T`, not a label. -/
theorem freeStressTensor_conserved_iff_local (d s : ℝ) :
    (freeStressTensor d s).IsConserved ↔ s = 1 := by
  unfold StressTensor.IsConserved freeStressTensor
  constructor
  · intro h; dsimp only at h; linarith
  · intro h; subst h; ring

/-- **End-to-end locality equivalence.** For the free construction the following coincide:
    the stress-tensor anomalous dimension vanishes; the stress tensor is a conserved local
    current (`Δ_T = d`); the kinetic term is local (`s = 1`); and the Part-1 locality
    predicate `IsLocal s` holds. Locality is a single machine-checked equivalence class. -/
theorem freeStressTensor_locality_iff (d s : ℝ) :
    (freeStressTensor d s).gammaT = 0 ↔ IsLocal s := by
  simp only [freeStressTensor_gammaT, IsLocal]

/-- Corollary tying the chain together explicitly (conserved ⟺ local kinetic term). -/
theorem freeStressTensor_conserved_iff_isLocal (d s : ℝ) :
    (freeStressTensor d s).IsConserved ↔ IsLocal s := by
  rw [freeStressTensor_conserved_iff_local]
  simp only [IsLocal, gammaT_zero_iff_local]

end Ds4Verification
