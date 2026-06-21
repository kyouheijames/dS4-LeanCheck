import Mathlib
import Ds4Verification.ShadowPairing
import Ds4Verification.Locality
import Ds4Verification.StressTensor

/-!
# CPTLocality.lean — "CPT-like breaking *is* the locality breaking", as a theorem.

The dS antipodal (CPT-like) map descends to the shadow map `Δ ↦ d − Δ` on the boundary, and
on the principal line `Re Δ = d/2` it equals complex conjugation (`shadow_eq_conj_on_principal`).
This module turns the prose link "CPT breaking and locality breaking are the same event" into
a proved equivalence.

Two ingredients:
  1. `shadow_eq_conj_iff` — CPT-exactness is *exactly* sitting on the critical line
     `Re Δ = d/2` (the full iff, strengthening the earlier ⟸).
  2. A configuration `CPTLocality` that couples the kinetic exponent and the weight through a
     single deviation `ε` from the dS-symmetric point. Then CPT-exact ⟺ local ⟺ ε = 0 ⟺ the
     stress tensor is conserved: one parameter, all four faces — they cannot break independently.
-/

namespace Ds4Verification

/-- **CPT-exactness ⟺ critical line.** The shadow (CPT) map equals conjugation iff `Δ` sits on
    the principal line `Re Δ = d/2`. (The imaginary parts always agree; only `Re Δ = d/2`
    bites.) This makes "CPT exact" a decidable predicate on the weight. -/
theorem shadow_eq_conj_iff (d : ℝ) (Δ : ℂ) :
    shadow d Δ = (starRingEnd ℂ) Δ ↔ Δ.re = d / 2 := by
  unfold shadow
  constructor
  · intro h
    have hre := congrArg Complex.re h
    simp only [Complex.sub_re, Complex.ofReal_re, Complex.conj_re] at hre
    linarith
  · intro h
    apply Complex.ext
    · simp only [Complex.sub_re, Complex.ofReal_re, Complex.conj_re]; linarith
    · simp only [Complex.sub_im, Complex.ofReal_im, Complex.conj_im, zero_sub]

/-- A coupled CPT/locality configuration. A single deviation `ε` from the de Sitter–symmetric
    point drives both knobs:

      `s = 1 + ε`        (`ε = 0` ⇔ ordinary local kinetic term),
      `Re Δ = d/2 + ε`   (`ε = 0` ⇔ weight on the CPT-exact principal line).

    The shared `ε` is the formal content of "the dual's CPT structure and its locality
    structure are the same operator-conjugation". (Unit coupling is a normalization; the
    load-bearing claim is the shared zero, as with `γ_T`.) -/
structure CPTLocality where
  d : ℝ
  ε : ℝ
  s : ℝ
  Δ : ℂ
  s_coupling : s = 1 + ε
  reΔ_coupling : Δ.re = d / 2 + ε

namespace CPTLocality

/-- The configuration is **CPT-exact** iff its weight is on the critical line. -/
def CPTExact (C : CPTLocality) : Prop := shadow C.d C.Δ = (starRingEnd ℂ) C.Δ

/-- The configuration is **local** iff its kinetic term is ordinary (`s = 1`). -/
def IsLocalCfg (C : CPTLocality) : Prop := IsLocal C.s

/-- **The shared-zero theorem.** CPT-exact ⟺ local: a single deviation `ε` governs both, so
    breaking CPT (`ε ≠ 0`) breaks locality and conversely. They are one event, not two. -/
theorem cptExact_iff_local (C : CPTLocality) : C.CPTExact ↔ C.IsLocalCfg := by
  unfold CPTExact IsLocalCfg IsLocal
  rw [shadow_eq_conj_iff, C.reΔ_coupling, gammaT_zero_iff_local, C.s_coupling]
  constructor <;> intro h <;> linarith

/-- …and the same event is the non-conservation of the stress tensor: CPT-exact ⟺ the free
    stress tensor is conserved. CPT breaking, locality breaking, and `γ_T ≠ 0` coincide. -/
theorem cptExact_iff_conserved (C : CPTLocality) :
    C.CPTExact ↔ (freeStressTensor C.d C.s).IsConserved := by
  rw [cptExact_iff_local]
  exact (freeStressTensor_conserved_iff_isLocal C.d C.s).symm

/-- The breaking is intermittent in `ε`: at `ε = 0` everything is exact (CPT + locality), and
    any `ε ≠ 0` breaks both at once — the precise "breaks once in a while" picture, now tied
    to the CPT structure rather than asserted alongside it. -/
theorem exact_iff_eps_zero (C : CPTLocality) : C.CPTExact ↔ C.ε = 0 := by
  rw [cptExact_iff_local]
  unfold IsLocalCfg IsLocal
  rw [gammaT_zero_iff_local, C.s_coupling]
  constructor <;> intro h <;> linarith

/-- **Non-contradiction, machine-checked.** `StressTensor`'s locality rail
    (`γ_T = 0 ⟺ conserved`) and this module's CPT identity (`CPT-exact ⟺ local`) are not in
    tension — they pick out the *same* equivalence class. For any coupled configuration the
    conditions `ε = 0`, CPT-exact, local, stress-tensor conserved, and `γ_T = 0` are all
    mutually equivalent. `CPTLocality` strictly *extends* the rail; it does not collide with it.
    (If they were contradictory, this chain of iffs could not be constructed.) -/
theorem locality_cpt_equiv (C : CPTLocality) :
    (C.ε = 0 ↔ C.CPTExact) ∧
    (C.CPTExact ↔ C.IsLocalCfg) ∧
    (C.CPTExact ↔ (freeStressTensor C.d C.s).IsConserved) ∧
    ((freeStressTensor C.d C.s).IsConserved ↔ (freeStressTensor C.d C.s).gammaT = 0) := by
  refine ⟨(exact_iff_eps_zero C).symm, cptExact_iff_local C, cptExact_iff_conserved C, ?_⟩
  exact (StressTensor.gammaT_zero_iff_conserved _).symm

end CPTLocality

end Ds4Verification
