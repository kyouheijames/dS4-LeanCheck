import Mathlib
import Ds4Verification.PrincipalSpectrum

/-!
# ScalarTensor.lean — the scalar↔tensor correlation `γ_T = −(n_s − 1)`, parameter-free.

The framework couples the kinetic exponent and the boundary weight through ONE deviation `ε`
(`CPTLocality`: `s = 1 + ε` and `Re Δ = d/2 + ε`). Two observables ride on that single `ε`:

  • the SCALAR tilt:  `n_s − 1 = Re(2Δ − d) = 2ε`   (`PrincipalSpectrum.specExponent_re`),
  • the TENSOR / graviton mass:  `γ_T = Δ_T − d = 2Δχ + 2 − d = −2ε`  (`freeStressTensor`).

Hence `γ_T = −(n_s − 1)`: the would-be-graviton anomalous dimension is exactly MINUS the scalar
tilt — a parameter-free ratio of −1, carrying NO `1/N` coefficient `A`. This is the framework's
unifying claim ("one order parameter `ε` drives scalar and tensor sectors") as a machine-checked
identity, and it is FALSIFIABLE: an independent measurement of the graviton-mass imprint (tensor
spectrum / B-modes) and the scalar tilt (`n_s`) must satisfy it.

Tree-level (leading) statement: interacting `1/N` (σ-exchange) corrections shift `γ_T` at order
`1/N` and are subleading to this `O(ε)` correlation.
-/

namespace Ds4Verification

/-- **The scalar↔tensor correlation, parameter-free.** For any coupled CPT/locality configuration,
    the (would-be) graviton anomalous dimension equals minus the scalar tilt:
    `γ_T = −(n_s − 1)`. Both are `±2ε`; the single `ε` ties them with ratio exactly `−1`, with no
    `1/N` coefficient. -/
theorem gammaT_eq_neg_tilt (C : CPTLocality) :
    (freeStressTensor C.d C.s).gammaT = - (specExponent C.d C.Δ).re := by
  have hL : (freeStressTensor C.d C.s).gammaT = -2 * C.ε := by
    simp only [StressTensor.gammaT, freeStressTensor, C.s_coupling]; ring
  have hR : (specExponent C.d C.Δ).re = 2 * C.ε := by
    rw [specExponent_re, C.reΔ_coupling]; ring
  rw [hL, hR]; ring

/-- Equivalent form: the scalar tilt is recovered as minus the graviton anomalous dimension,
    `n_s − 1 = −γ_T`. (Same content, read tensor→scalar.) -/
theorem tilt_eq_neg_gammaT (C : CPTLocality) :
    (specExponent C.d C.Δ).re = - (freeStressTensor C.d C.s).gammaT := by
  rw [gammaT_eq_neg_tilt]; ring

/-- Both vanish together: the spectrum is exactly scale-invariant (`n_s = 1`) iff the graviton is
    massless (`γ_T = 0`) iff `ε = 0` — the local / CPT-exact point. The correlation has a shared
    zero, so "near scale-invariance" and "nearly-massless graviton" are the SAME smallness. -/
theorem tilt_zero_iff_gammaT_zero (C : CPTLocality) :
    (specExponent C.d C.Δ).re = 0 ↔ (freeStressTensor C.d C.s).gammaT = 0 := by
  rw [tilt_eq_neg_gammaT]; constructor <;> intro h <;> linarith

end Ds4Verification
