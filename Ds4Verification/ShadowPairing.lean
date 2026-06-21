import Mathlib

/-!
# ShadowPairing.lean — the CPT / shadow positivity structure

The dS antipodal map (the CPT-like involution exchanging ℐ⁺ ↔ ℐ⁻) descends on
the boundary to the shadow map on conformal dimensions, Δ ↦ d − Δ. On the
principal series (Δ = d/2 + iμ) this map is exactly complex conjugation, so the
shadow-paired inner product that replaces reflection positivity is the boundary
face of bulk CPT. This module proves that identification.
-/

namespace Ds4Verification

/-- Shadow map on conformal dimensions: Δ ↦ d − Δ. -/
def shadow (d : ℝ) (Δ : ℂ) : ℂ := (d : ℂ) - Δ

/-- Principal series: Re Δ = d/2 and Δ genuinely complex (heavy/propagating
    bulk field, m²ℓ² > (d/2)²). -/
def IsPrincipal (d : ℝ) (Δ : ℂ) : Prop := Δ.re = d / 2 ∧ Δ.im ≠ 0

/-- **The CPT = shadow identification.** On the principal series, the shadow map
    coincides with complex conjugation. This is why dS positivity is
    shadow-paired (O_Δ paired with O_{d−Δ}* ) rather than reflection-positive. -/
theorem shadow_eq_conj_on_principal (d : ℝ) (Δ : ℂ)
    (h : IsPrincipal d Δ) : shadow d Δ = (starRingEnd ℂ) Δ := by
  obtain ⟨hre, -⟩ := h
  apply Complex.ext
  · simp only [shadow, Complex.sub_re, Complex.ofReal_re, Complex.conj_re]
    rw [hre]; ring
  · simp only [shadow, Complex.sub_im, Complex.ofReal_im, Complex.conj_im,
      zero_sub]

/-- The shadow map is an involution: shadowing twice returns Δ. -/
@[simp] theorem shadow_involutive (d : ℝ) (Δ : ℂ) :
    shadow d (shadow d Δ) = Δ := by
  simp only [shadow]; ring

/-- A principal weight and its shadow share the same real part d/2 (they sit on
    the same vertical line — the unitarity axis of the principal series). -/
theorem shadow_re_eq (d : ℝ) (Δ : ℂ) (h : IsPrincipal d Δ) :
    (shadow d Δ).re = Δ.re := by
  obtain ⟨hre, -⟩ := h
  simp only [shadow, Complex.sub_re, Complex.ofReal_re]
  rw [hre]; ring

end Ds4Verification
