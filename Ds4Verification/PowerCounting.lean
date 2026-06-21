import Mathlib
import Ds4Verification.LongRange
import Ds4Verification.FreeSector

/-!
# PowerCounting.lean — engineering dimensions and the "super-renormalizability" claim.

This formalizes the *dimensional-analysis* content of the cosmology discussion — and ONLY that.
The pasted dS-XFT material makes a chain of claims; this module pins down the one rung that is
pure algebra and genuinely correct (power counting), and the docstrings mark exactly where the
chain leaves what Lean (or honest power counting) can support.

PROVED here (engineering dimensions, given `Δ = freeDim d s = (d-2s)/2`):
  • `[g] = 4s − d` for the quartic `g(Ωχχ)²` — the coupling's mass dimension.
  • super-renormalizability ⇔ `[g] > 0` ⇔ `s > d/4` (a power-counting statement).
  • the power-spectrum scaling exponent `d − 2s = 2·freeDim` (the field 2-pt scaling).

NOT proved here (and NOT derivable from power counting alone — see STATUS.md):
  • UV-finiteness / that the interacting `γ_T(s)` is small ⇒ `s` is stable. Power counting
    `[g]>0` is NECESSARY but not sufficient; the actual anomalous dimension is the Part-2 CAS
    computation, still open. "Super-renormalizable ⇒ UV-finite ⇒ s stable" hand-waves the
    middle links.
  • `n_s = 4 − 2s` and `s ≈ 1.52`. This uses a REAL boundary dimension `Δ = (d-2s)/2`, which is
    the COMPLEMENTARY/real series — in tension with the PRINCIPAL series (complex `Δ`, `Re Δ =
    d/2`) that the rest of this repo's non-unitarity / CPT / shadow machinery is built on. One
    field cannot simultaneously be the real-Δ cosmology field and the complex-Δ dS/CFT field.
  • Any claim of a UNITARY / ghost-free gauge sector. A non-integer `(−∂²)ˢ` generically carries
    extra/complex poles (ghosts) — which is precisely the NON-unitarity this repo proves is
    FORCED by Λ>0 (`lagrangianDuality_forced_nonUnitary`). A "healthy, unitary" reading would
    undo the dS/CFT structure, not support it.
-/

namespace Ds4Verification

/-- Engineering (mass) dimension of the quartic coupling `g` in `S = ∫ g(Ωχχ)²`:
    `[g] = d − 4Δ`, with `Δ = freeDim d s`. -/
noncomputable def couplingDim (d s : ℝ) : ℝ := d - 4 * freeDim d s

/-- `[g] = 4s − d`. Pure power counting. -/
theorem couplingDim_eq (d s : ℝ) : couplingDim d s = 4 * s - d := by
  unfold couplingDim freeDim; ring

/-- **Super-renormalizability as power counting:** `[g] > 0 ⇔ s > d/4`. This is a necessary
    condition for UV-softness — NOT a proof of UV-finiteness (that needs the loop computation). -/
theorem couplingDim_pos_iff (d s : ℝ) : 0 < couplingDim d s ↔ d / 4 < s := by
  rw [couplingDim_eq]; constructor <;> intro h <;> linarith

/-- The field's (dimensionless) power-spectrum scaling exponent `d − 2s` is exactly `2·Δ`,
    i.e. twice the free dimension — the momentum-space face of `propagator_scaling`. The further
    step `n_s − 1 = d − 2s` is a cosmological-dictionary CONJECTURE, not proved (see header). -/
theorem spectralExponent_eq (d s : ℝ) : d - 2 * s = 2 * freeDim d s := by
  unfold freeDim; ring

/-- At the worked point (`d = 3`, `s = 1.4`) the quartic is super-renormalizable by power
    counting (`[g] = 2.6 > 0`). (Note: `2.6`, not the pasted `3.08`, which used `s = 1.52`.) -/
theorem example_superRenormalizable : 0 < couplingDim 3 1.4 := by
  rw [couplingDim_eq]; norm_num

end Ds4Verification
