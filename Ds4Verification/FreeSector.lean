import Mathlib
import Ds4Verification.LongRange

/-!
# FreeSector.lean — free-sector dimension Δ(s), DERIVED from the propagator's scaling.

The honest content of the free (Gaussian) sector is not the operator `(−∂²)ˢ` itself but
the *scaling of its two-point function*. The long-range propagator is

    G(x) ~ ‖x‖^{-(d - 2s)} ,

and a field whose two-point function behaves as `‖x‖^{-2Δ}` has scaling dimension `Δ`.
So `Δ = (d - 2s)/2` is the propagator's homogeneity exponent — which we *prove* here, rather
than postulate. This upgrades `LongRange.freeDim` from a bare definition to the scaling
dimension read off a concrete propagator.

Crucially this needs NO fractional-Laplacian / Fourier-multiplier machinery (absent from
Mathlib): homogeneity of `‖x‖^α` is elementary. The operator construction is only needed to
write the equation of motion operationally, which the dimension does not require.
-/

namespace Ds4Verification

open Real

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

/-- Free long-range propagator in position space: `G(x) = ‖x‖^{-(d - 2s)}`. -/
noncomputable def propagator (d s : ℝ) (x : E) : ℝ := ‖x‖ ^ (-(d - 2 * s))

/-- **Homogeneity of the propagator.** Under a rescaling `x ↦ l • x` (`l > 0`),
    `G(l • x) = l^{-(d - 2s)} · G(x)`: the two-point function is homogeneous of degree
    `-(d - 2s)`. This is the scaling that *defines* the field's dimension. -/
theorem propagator_homog (d s : ℝ) (x : E) {l : ℝ} (hl : 0 < l) :
    propagator d s (l • x) = l ^ (-(d - 2 * s)) * propagator d s x := by
  unfold propagator
  rw [norm_smul, Real.norm_eq_abs, abs_of_pos hl, Real.mul_rpow hl.le (norm_nonneg x)]

/-- The homogeneity degree is exactly `-2 · freeDim d s`: i.e. `G(x) ~ ‖x‖^{-2Δ}` with
    `Δ = freeDim d s = (d - 2s)/2`. This is the bridge from "scaling exponent" to "dimension". -/
theorem propagator_degree_eq (d s : ℝ) : -(d - 2 * s) = -2 * freeDim d s := by
  unfold freeDim; ring

/-- **Free-sector dimension, derived.** The propagator scales as
    `G(l • x) = l^{-2 · freeDim d s} · G(x)`, so the field's scaling dimension is exactly
    `freeDim d s = (d - 2s)/2` — read off the homogeneity of `G`, not assumed. -/
theorem propagator_scaling (d s : ℝ) (x : E) {l : ℝ} (hl : 0 < l) :
    propagator d s (l • x) = l ^ (-2 * freeDim d s) * propagator d s x := by
  rw [propagator_homog d s x hl, propagator_degree_eq]

/-- Sanity check at the local point `s = 1`: the dimension is the canonical free-scalar
    value `(d - 2)/2`, and the propagator scales as the ordinary `‖x‖^{-(d-2)}`. -/
theorem propagator_scaling_local (d : ℝ) (x : E) {l : ℝ} (hl : 0 < l) :
    propagator d 1 (l • x) = l ^ (-(d - 2)) * propagator d 1 x := by
  have := propagator_homog d 1 x hl
  simpa using this

/-- **Euclidean (rotational) invariance of the free two-point function.** The propagator
    depends only on `‖x‖`, hence is invariant under any linear isometry (rotation/reflection)
    of position space: `G(f x) = G(x)`. The long-range kinetic term breaks LOCALITY, not the
    Euclidean symmetry of the boundary — the precise sense in which this is a conformal-but-
    non-local theory. (The boundary of dS₄ is Euclidean S³; the Lorentzian object is the bulk
    metric, whose `(−,+,+,+)` signature is checked separately in `Core`.) -/
theorem propagator_isometry_invariant (d s : ℝ) (f : E ≃ₗᵢ[ℝ] E) (x : E) :
    propagator d s (f x) = propagator d s x := by
  unfold propagator; rw [f.norm_map]

/-! ### Two-point free propagator and full Euclidean invariance

`G(x,y) = ‖x − y‖^{−(d−2s)}` — the translation-covariant form. It depends only on the
separation `x − y`, so translation invariance is manifest and isometry invariance follows from
the one-point case. Together these are the full (free-sector) Euclidean group of the boundary;
still no multiplier theory needed. -/

/-- Free two-point function: `G(x,y) = ‖x − y‖^{−(d−2s)}`. -/
noncomputable def propagator₂ (d s : ℝ) (x y : E) : ℝ := ‖x - y‖ ^ (-(d - 2 * s))

/-- The two-point function depends only on the separation: `G(x,y) = G₁(x − y)`. -/
theorem propagator₂_eq_sub (d s : ℝ) (x y : E) :
    propagator₂ d s x y = propagator d s (x - y) := rfl

/-- **Translation invariance.** `G(x+t, y+t) = G(x,y)` — manifest, since the separation
    `(x+t) − (y+t) = x − y` is unchanged. -/
theorem propagator₂_translation_invariant (d s : ℝ) (x y t : E) :
    propagator₂ d s (x + t) (y + t) = propagator₂ d s x y := by
  have h : (x + t) - (y + t) = x - y := by abel
  unfold propagator₂; rw [h]

/-- **Isometry (rotation/reflection) invariance.** `G(f x, f y) = G(x,y)` for any linear
    isometry `f`, since `‖f x − f y‖ = ‖f (x − y)‖ = ‖x − y‖`. -/
theorem propagator₂_isometry_invariant (d s : ℝ) (f : E ≃ₗᵢ[ℝ] E) (x y : E) :
    propagator₂ d s (f x) (f y) = propagator₂ d s x y := by
  unfold propagator₂; rw [← map_sub f x y, f.norm_map]

/-- **Full Euclidean invariance.** Under any isometry composed with a translation
    `x ↦ f x + t`, the two-point function is invariant: the free sector carries the entire
    boundary Euclidean group `ISO(d)` (rotations/reflections + translations). -/
theorem propagator₂_euclidean_invariant (d s : ℝ) (f : E ≃ₗᵢ[ℝ] E) (t x y : E) :
    propagator₂ d s (f x + t) (f y + t) = propagator₂ d s x y := by
  rw [propagator₂_translation_invariant, propagator₂_isometry_invariant]

/-- **Scale covariance, two-point form.** `G(l·x, l·y) = l^{−2·freeDim} · G(x,y)`: the field's
    scaling dimension read off the *separation*-dependent propagator, completing the conformal
    weights `(translations, rotations, dilations)` that need no operator construction. -/
theorem propagator₂_scaling (d s : ℝ) (x y : E) {l : ℝ} (hl : 0 < l) :
    propagator₂ d s (l • x) (l • y) = l ^ (-2 * freeDim d s) * propagator₂ d s x y := by
  rw [propagator₂_eq_sub, ← smul_sub, propagator_scaling d s (x - y) hl, propagator₂_eq_sub]

/-! ### Inversion (special-conformal) covariance — closing the conformal group

The remaining conformal generator is the inversion `ι(x) = x/‖x‖²`. Its action on the two-point
function follows from one geometric identity — `‖ι x − ι y‖ = ‖x−y‖/(‖x‖‖y‖)` — which is a
parallelogram-law computation needing the inner product. With it, the free two-point function
transforms with the standard weight `‖x‖^{2Δ}‖y‖^{2Δ}`, completing the FULL conformal group
(translations + rotations + dilations + inversions) purely from norm algebra. -/

section Inversion
variable {F : Type*} [NormedAddCommGroup F] [InnerProductSpace ℝ F]
open scoped RealInnerProductSpace

/-- Conformal inversion `ι(x) = x / ‖x‖²`. -/
noncomputable def inv' (x : F) : F := (‖x‖ ^ 2)⁻¹ • x

/-- **The inversion distance identity.** `‖ι x − ι y‖ · (‖x‖‖y‖) = ‖x − y‖` — equivalently
    `‖ι x − ι y‖ = ‖x−y‖/(‖x‖‖y‖)`. A parallelogram-law computation. -/
theorem norm_inv_sub_inv (x y : F) (hx : x ≠ 0) (hy : y ≠ 0) :
    ‖inv' x - inv' y‖ * (‖x‖ * ‖y‖) = ‖x - y‖ := by
  have hx2 : ‖x‖ ^ 2 ≠ 0 := pow_ne_zero 2 (norm_ne_zero_iff.mpr hx)
  have hy2 : ‖y‖ ^ 2 ≠ 0 := pow_ne_zero 2 (norm_ne_zero_iff.mpr hy)
  have hnx : ‖inv' x‖ ^ 2 = (‖x‖ ^ 2)⁻¹ := by
    rw [← real_inner_self_eq_norm_sq]
    simp only [inv', real_inner_smul_left, real_inner_smul_right]
    rw [real_inner_self_eq_norm_sq]; field_simp
  have hny : ‖inv' y‖ ^ 2 = (‖y‖ ^ 2)⁻¹ := by
    rw [← real_inner_self_eq_norm_sq]
    simp only [inv', real_inner_smul_left, real_inner_smul_right]
    rw [real_inner_self_eq_norm_sq]; field_simp
  have hin : ⟪inv' x, inv' y⟫ = (‖x‖ ^ 2)⁻¹ * (‖y‖ ^ 2)⁻¹ * ⟪x, y⟫ := by
    simp only [inv', real_inner_smul_left, real_inner_smul_right]; ring
  have sq_id : ‖inv' x - inv' y‖ ^ 2 * (‖x‖ ^ 2 * ‖y‖ ^ 2) = ‖x - y‖ ^ 2 := by
    rw [norm_sub_sq_real, norm_sub_sq_real, hnx, hny, hin]; field_simp; ring
  have hnn : (0:ℝ) ≤ ‖inv' x - inv' y‖ * (‖x‖ * ‖y‖) := by positivity
  have hsq : (‖inv' x - inv' y‖ * (‖x‖ * ‖y‖)) ^ 2 = ‖x - y‖ ^ 2 := by
    rw [mul_pow, mul_pow]; exact sq_id
  calc ‖inv' x - inv' y‖ * (‖x‖ * ‖y‖)
      = Real.sqrt ((‖inv' x - inv' y‖ * (‖x‖ * ‖y‖)) ^ 2) := (Real.sqrt_sq hnn).symm
    _ = Real.sqrt (‖x - y‖ ^ 2) := by rw [hsq]
    _ = ‖x - y‖ := Real.sqrt_sq (norm_nonneg _)

/-- **Inversion (special-conformal) covariance.** Under `ι(x) = x/‖x‖²` the free two-point
    function transforms with the standard conformal weight:
        `G(ι x, ι y) = ‖x‖^{2Δ} · ‖y‖^{2Δ} · G(x, y)`,  with `2Δ = 2·freeDim d s = d − 2s`.
    Together with translations, rotations and dilations this closes the FULL conformal group on
    the free two-point function — no operator construction, just norm algebra. -/
theorem propagator₂_inversion_covariant (d s : ℝ) (x y : F) (hx : x ≠ 0) (hy : y ≠ 0) :
    propagator₂ d s (inv' x) (inv' y)
      = ‖x‖ ^ (2 * freeDim d s) * ‖y‖ ^ (2 * freeDim d s) * propagator₂ d s x y := by
  have hfd : 2 * freeDim d s = d - 2 * s := by unfold freeDim; ring
  have hxn : (0:ℝ) < ‖x‖ := norm_pos_iff.mpr hx
  have hyn : (0:ℝ) < ‖y‖ := norm_pos_iff.mpr hy
  have hsep : ‖inv' x - inv' y‖ = ‖x - y‖ / (‖x‖ * ‖y‖) := by
    rw [eq_div_iff (mul_ne_zero (norm_ne_zero_iff.mpr hx) (norm_ne_zero_iff.mpr hy))]
    exact norm_inv_sub_inv x y hx hy
  have hxm : ‖x‖ ^ (d - 2 * s) ≠ 0 := (Real.rpow_pos_of_pos hxn _).ne'
  have hym : ‖y‖ ^ (d - 2 * s) ≠ 0 := (Real.rpow_pos_of_pos hyn _).ne'
  simp only [propagator₂, hfd]
  rw [hsep, Real.div_rpow (norm_nonneg _) (by positivity), Real.mul_rpow hxn.le hyn.le,
      Real.rpow_neg hxn.le, Real.rpow_neg hyn.le]
  field_simp
  ring

end Inversion

end Ds4Verification
