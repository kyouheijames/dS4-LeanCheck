import Mathlib
import Ds4Verification.Locality

/-!
# Model.lean — locality as a fluctuating observable that breaks "once in a while".

This is the novel core of the program, made into a precise object rather than an intuition.

In Part 1, `s` is a fixed number and `γ_T(s) = 2(s-1)` is a fixed order parameter. The
conjecture is different: **locality is a quantum observable that fluctuates** — most of the
time the theory is local (`s = 1`, `γ_T = 0`), but the CPT-like structure breaks
*intermittently*, so `s` occasionally departs from `1` and locality is broken part of the time.

The minimal object carrying that idea is a **two-point random kinetic exponent**: `s = 1`
(local) with probability `p`, and `s = s₀` (non-local) with probability `1 - p`. The locality
order parameter `γ_T` is then the *observable*, with eigenvalues `γ_T(1) = 0` and `γ_T(s₀)`,
realised with probabilities `p` and `1 - p`. (The general case replaces this two-point law by
a `PMF ℝ` / measure and the average below by an integral — that is Part 3 territory; the
two-point law is the smallest model in which the statement is already nontrivial and provable.)
-/

namespace Ds4Verification

/-- A minimal model of *fluctuating locality*. -/
structure FluctuatingLocality where
  /-- The non-local branch value of the kinetic exponent. -/
  s₀ : ℝ
  /-- Probability of the LOCAL branch (`s = 1`). -/
  p : ℝ
  /-- `p` is a genuine probability. -/
  p_mem : p ∈ Set.Icc (0 : ℝ) 1

namespace FluctuatingLocality

/-- `γ_T(1) = 0`: on the local branch the order parameter vanishes — locality is exact there. -/
@[simp] theorem gammaT_free_one : gammaT_free 1 = 0 := by unfold gammaT_free; ring

/-- The locality observable's expectation `⟨γ_T⟩ = p·γ_T(1) + (1-p)·γ_T(s₀)`: the average
    amount of locality breaking across the fluctuation. -/
noncomputable def expectedGammaT (F : FluctuatingLocality) : ℝ :=
  F.p * gammaT_free 1 + (1 - F.p) * gammaT_free F.s₀

/-- Since the local branch contributes nothing, `⟨γ_T⟩ = (1 - p) · γ_T(s₀)`. -/
theorem expectedGammaT_eq (F : FluctuatingLocality) :
    F.expectedGammaT = (1 - F.p) * gammaT_free F.s₀ := by
  unfold expectedGammaT; rw [gammaT_free_one]; ring

/-- **"Breaks locality once in a while."** The system is local with positive probability
    (`p > 0`, mass on the `s = 1` branch) but not always: the non-local branch `s₀ ≠ 1`
    also has positive probability (`p < 1`). -/
def breaksIntermittently (F : FluctuatingLocality) : Prop :=
  0 < F.p ∧ F.p < 1 ∧ F.s₀ ≠ 1

/-- **Payoff theorem.** Under intermittent breaking the locality observable is broken
    *on average* (`⟨γ_T⟩ ≠ 0`) — even though the theory is exactly local with positive
    probability `p`. Locality is therefore neither exact nor absent: it is a genuine
    fluctuating observable that breaks part of the time. This is the precise premise the
    averaging-consistency conjecture (Part 3 / SDPB) is *about*. -/
theorem expectedGammaT_ne_zero (F : FluctuatingLocality) (h : F.breaksIntermittently) :
    F.expectedGammaT ≠ 0 := by
  obtain ⟨hp0, hp1, hs⟩ := h
  rw [expectedGammaT_eq]
  exact mul_ne_zero (by linarith) (nonlocal_of_ne_one hs)

/-- …and the complementary half of "once in a while": locality genuinely *holds* on the
    `s = 1` branch, which carries positive probability `p > 0`. So the system is exactly
    local part of the time. -/
theorem localBranch_holds (F : FluctuatingLocality) (h : F.breaksIntermittently) :
    0 < F.p ∧ IsLocal 1 := by
  refine ⟨h.1, ?_⟩
  show gammaT_free 1 = 0
  exact gammaT_free_one

/-- The two regimes are exhaustive at the level of a single draw: every realised `s` is
    either the exact-local branch or a non-local one — locality is a sharp (decidable)
    eigenvalue of each draw, the hallmark of an observable. -/
theorem draw_local_or_not (F : FluctuatingLocality) :
    IsLocal 1 ∧ (F.s₀ = 1 ∨ ¬ IsLocal F.s₀) := by
  refine ⟨gammaT_free_one, ?_⟩
  rcases eq_or_ne F.s₀ 1 with h | h
  · exact Or.inl h
  · exact Or.inr (nonlocal_of_ne_one h)

end FluctuatingLocality

end Ds4Verification
