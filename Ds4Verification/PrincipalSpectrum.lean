import Mathlib
import Ds4Verification.CPTLocality

/-!
# PrincipalSpectrum.lean — the principal-series power spectrum, consistent with the framework.

The pasted dS-XFT pitch used a REAL boundary dimension and got `n_s = 4 − 2s ⇒ s ≈ 1.52`. That
is the *complementary* series and is in tension with this repo's *principal* series (complex Δ,
`Re Δ = d/2`). Here is the principal-series version — what the cosmology must look like to be
consistent with the non-unitarity / CPT / shadow structure we proved.

Boundary 2-point function: `⟨O(k) O(−k)⟩ ∝ |k|^{2Δ − d}`. Split the complex exponent:

  • **Real part = spectral tilt.** `Re(2Δ − d) = 2(Re Δ − d/2)`. The amplitude scales as
    `|k|^{Re(2Δ−d)}`, so `n_s − 1 = 2(Re Δ − d/2)`.
  • **Imaginary part = log-oscillation frequency.** `Im(2Δ − d) = 2·Im Δ`. The factor
    `|k|^{2i·Im Δ} = cos(2·Im Δ · ln k) + i sin(…)` is a log-PERIODIC modulation — the
    cosmological-collider signature — with frequency `μ = Im Δ`.

Consequences (all proved below), which fix the inconsistencies flagged in STATUS.md §D:

  1. **Scale invariance is automatic on the principal line.** `Re Δ = d/2 ⇒ tilt = 0`, so
     `n_s ≈ 1` comes for free from the principal series — no tuning of `s` to 1.52, and no
     contradiction with standard inflation (`n_s ≈ 1`, not the pitch's `n_s = 2` at `s = 1`).
  2. **The tilt IS the breaking.** For a coupled CPT/locality configuration (`Re Δ = d/2 + ε`),
     `n_s − 1 = 2ε`: the observed red tilt is a direct measure of the SAME `ε` that controls
     CPT-breaking ⟺ locality-breaking ⟺ non-conservation (`locality_cpt_equiv`).
  3. **The genuine prediction is an oscillation**, frequency `μ = Im Δ`, set by the heavy
     field's mass via `Δ(d−Δ) = m²` — a parameter-free signature, unlike orienting `Ω` to fit
     an axis.

HONEST SCOPE: this fixes the *scaling structure* (tilt, oscillation frequency) from the
conformal weight. The overall amplitude and the oscillation's size (Boltzmann `e^{−πμ}`) need
the full late-time wavefunction / cosmological-bootstrap computation — out of scope here, like
the interacting `γ_T` (Part 2) and the averaging (Part 3).
-/

namespace Ds4Verification

/-- Momentum-space scaling exponent of the boundary 2-point function `⟨O(k)O(−k)⟩ ∝ |k|^{2Δ−d}`.
    (Written `Δ + Δ - d` so the algebra avoids `(2 : ℂ)` coercions.) -/
def specExponent (d : ℝ) (Δ : ℂ) : ℂ := Δ + Δ - (d : ℂ)

/-- **Real part = spectral tilt:** `Re(2Δ − d) = 2(Re Δ − d/2)`, i.e. `n_s − 1 = 2(Re Δ − d/2)`. -/
theorem specExponent_re (d : ℝ) (Δ : ℂ) :
    (specExponent d Δ).re = 2 * (Δ.re - d / 2) := by
  simp only [specExponent, Complex.sub_re, Complex.add_re, Complex.ofReal_re]; ring

/-- **Imaginary part = log-oscillation frequency:** `Im(2Δ − d) = 2·Im Δ`. For the principal
    series `Im Δ = μ ≠ 0`, so the spectrum carries a log-periodic modulation of frequency `μ`. -/
theorem specExponent_im (d : ℝ) (Δ : ℂ) :
    (specExponent d Δ).im = 2 * Δ.im := by
  simp only [specExponent, Complex.sub_im, Complex.add_im, Complex.ofReal_im]; ring

/-- **Principal series ⇒ scale-invariant base (`n_s = 1`).** On `Re Δ = d/2` the tilt vanishes;
    all k-dependence is the log-oscillation. Scale invariance is automatic — no `s`-tuning. -/
theorem specExponent_re_principal (d : ℝ) (Δ : ℂ) (h : IsPrincipal d Δ) :
    (specExponent d Δ).re = 0 := by
  rw [specExponent_re, h.1]; ring

/-- The oscillation frequency is genuinely nonzero on the principal series (`Im Δ ≠ 0`): the
    spectrum is not a pure power law but carries the cosmological-collider modulation. -/
theorem specExponent_im_ne_zero (d : ℝ) (Δ : ℂ) (h : IsPrincipal d Δ) :
    (specExponent d Δ).im ≠ 0 := by
  rw [specExponent_im]
  exact mul_ne_zero two_ne_zero h.2

/-- **The tilt IS the breaking.** For a coupled CPT/locality configuration (`Re Δ = d/2 + ε`),
    `n_s − 1 = Re(2Δ − d) = 2ε`. So scale invariance (`n_s = 1`) ⟺ `ε = 0` ⟺ CPT-exact ⟺ local
    ⟺ conserved (`locality_cpt_equiv`). The red tilt is, in this model, a measure of `ε`. -/
theorem spectralTilt_eq_twoEps (C : CPTLocality) :
    (specExponent C.d C.Δ).re = 2 * C.ε := by
  rw [specExponent_re, C.reΔ_coupling]; ring

end Ds4Verification
