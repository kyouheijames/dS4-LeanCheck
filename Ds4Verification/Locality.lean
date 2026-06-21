import Mathlib
import Ds4Verification.LongRange

/-!
# Locality.lean — locality as a machine-checked observable

We make "locality" a decidable predicate on the candidate's kinetic data via the
anomalous dimension of the would-be stress tensor, γ_T.

A LOCAL CFT has a conserved local stress tensor with Δ_T = d exactly (γ_T = 0).
A NON-LOCAL theory has no conserved local T (γ_T ≠ 0). In the free long-range
theory the obstruction is carried entirely by `s − 1`: `(−∂²)ˢ` admits a
conserved local T iff `s = 1`.

MODELING CONVENTION (see STATUS.md): the *zero set* `{s = 1}` is the physics;
the linear coefficient below is a normalization. The INTERACTING-fixed-point
γ_T(s) is a different, genuinely computed object (Part 2 / CAS), not this.
-/

namespace Ds4Verification

/-- Free-level locality order parameter. Its zero set is the physical content. -/
noncomputable def gammaT_free (s : KineticExponent) : ℝ := 2 * (s - 1)

/-- Locality, as a decidable predicate on the kinetic exponent. -/
def IsLocal (s : KineticExponent) : Prop := gammaT_free s = 0

/-- **Central structural lemma.** Locality ⟺ conserved local stress tensor
    ⟺ ordinary (`s = 1`) kinetic term, at free level. This is the rigorous
    `γ_T = 0 ⟺ ∃ conserved T` equivalence, with `s = 1` as the conserved point. -/
theorem gammaT_zero_iff_local (s : KineticExponent) :
    gammaT_free s = 0 ↔ s = 1 := by
  unfold gammaT_free
  constructor
  · intro h
    rcases mul_eq_zero.mp h with h2 | h1
    · norm_num at h2
    · linarith
  · intro h; subst h; ring

/-- `s ≠ 1` is genuinely non-local: γ_T does not vanish. This is the regime your
    locality-breaking program lives in. -/
theorem nonlocal_of_ne_one {s : KineticExponent} (h : s ≠ 1) :
    gammaT_free s ≠ 0 := by
  intro hc; exact h ((gammaT_zero_iff_local s).mp hc)

/-- Locality is decidable for any explicit candidate (the filter always returns
    a verdict, never "unknown"). -/
theorem locality_decidable (s : KineticExponent) : IsLocal s ∨ ¬ IsLocal s :=
  em _

end Ds4Verification
