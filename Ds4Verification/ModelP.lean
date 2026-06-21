import Mathlib
import Ds4Verification.Locality

/-!
# ModelP.lean — fluctuating locality over a general distribution (the Part-3 form).

`Model.lean` modelled the kinetic exponent `s` as a two-point random variable. Here we
generalize to an arbitrary law `sDist : PMF ℝ`, with the locality order parameter's average
written as a genuine **integral**

    ⟨γ_T⟩ = ∫ γ_T(s) d(sDist) ,

which is exactly the object Part 3 (the annealed average / shadow-bootstrap) consumes.

Key structural fact, proved below: since `γ_T` is *affine* in `s`, the annealed average
collapses to the order parameter at the mean exponent — `⟨γ_T⟩ = 2(⟨s⟩ − 1)` — so "broken on
average" is exactly "the mean exponent is non-local". (The two-point `FluctuatingLocality` is
the special case where `sDist` is Bernoulli-supported.)
-/

namespace Ds4Verification

open MeasureTheory

/-- Fluctuating locality with an arbitrary distribution over the kinetic exponent. -/
structure FluctuatingLocalityP where
  /-- The law of the kinetic exponent `s`. -/
  sDist : PMF ℝ

namespace FluctuatingLocalityP

/-- Mean kinetic exponent `⟨s⟩ = ∫ s d(sDist)`. -/
noncomputable def meanS (F : FluctuatingLocalityP) : ℝ := ∫ s, s ∂F.sDist.toMeasure

/-- Annealed average of the locality order parameter `⟨γ_T⟩ = ∫ γ_T(s) d(sDist)` — the
    quantity whose shadow-positivity Part 3 must decide. -/
noncomputable def expectedGammaT (F : FluctuatingLocalityP) : ℝ :=
  ∫ s, gammaT_free s ∂F.sDist.toMeasure

/-- **Affine collapse.** Because `γ_T(s) = 2(s−1)` is affine, the annealed average equals
    the order parameter evaluated at the mean exponent: `⟨γ_T⟩ = 2(⟨s⟩ − 1)`. (Requires the
    mean to be finite — a genuine condition, since a `PMF ℝ` may have no first moment.) -/
theorem expectedGammaT_eq (F : FluctuatingLocalityP)
    (hInt : Integrable (fun s => s) F.sDist.toMeasure) :
    F.expectedGammaT = 2 * (F.meanS - 1) := by
  have hg : (fun s : ℝ => gammaT_free s) = fun s => 2 * (s - 1) := by
    funext s; rfl
  unfold expectedGammaT meanS
  rw [hg, integral_mul_left, integral_sub hInt (integrable_const 1), integral_const,
    measure_univ]
  simp

/-- `⟨γ_T⟩ = gammaT_free ⟨s⟩`: the average breaking is the order parameter at the mean. -/
theorem expectedGammaT_eq_gammaT_meanS (F : FluctuatingLocalityP)
    (hInt : Integrable (fun s => s) F.sDist.toMeasure) :
    F.expectedGammaT = gammaT_free F.meanS := by
  rw [expectedGammaT_eq F hInt]; rfl

/-- **Locality is broken on average iff the mean exponent is non-local.** The clean
    generalization of the two-point payoff to an arbitrary distribution. -/
theorem expectedGammaT_ne_zero_iff (F : FluctuatingLocalityP)
    (hInt : Integrable (fun s => s) F.sDist.toMeasure) :
    F.expectedGammaT ≠ 0 ↔ F.meanS ≠ 1 := by
  rw [expectedGammaT_eq F hInt]
  constructor
  · intro h hc; exact h (by rw [hc]; ring)
  · intro h hc
    rcases mul_eq_zero.mp hc with h2 | h2
    · norm_num at h2
    · exact h (by linarith)

end FluctuatingLocalityP

end Ds4Verification
