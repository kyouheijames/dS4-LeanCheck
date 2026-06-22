"""cT_6j.py — the exact ℓ=2 6j / inversion residue: precise spec + gate-checked interface.

This is the final frontier for C_T, and the honest boundary of what can be done from memory.

WHY THERE IS NO CLOSED FORM WRITTEN HERE.
The exact finite-spin double-twist anomalous dimension from a single scalar exchange is the
Lorentzian-inversion 6j symbol (a specific published ₄F₃-type expression). Reproducing it from
memory risks a wrong-but-plausible formula that could pass some gates and yield a fabricated
number — exactly the failure mode this project refuses (cf. the Ric-trap, STATUS.md). The gate
harness catches INCOMPLETE candidates (it rejected the large-spin one) but cannot fully validate
a from-memory closed form. So we do NOT write one. We pin the object and gate any VERIFIED input.

THE EXACT OBJECT (what must be evaluated):
  γ_{0,2}(s,d) = C_T(s,d)/N = the order-1/N anomalous dimension of [χχ]_{0,2} from σ-exchange,
  = (OPE coeff)² × [ 6j symbol / Lorentzian-inversion residue ]_{n=0, ℓ=2}
  with EXACT inputs we have:
      external  Δχ = (d−2s)/2
      exchanged Δσ = 2s          (scalar, J=0)
      spin      ℓ  = 2,  twist n = 0
      conformal spin  J̄² = (ℓ + Δχ)(ℓ + Δχ − 1)   [the variable the 6j is natural in]

SPECIAL SIMPLIFICATIONS our case enjoys (worth using when evaluating):
  • Vertex uniqueness: 2Δχ + Δσ = d exactly  ⇒  σ is the SHADOW of [χχ]_{0,0}
    (Δσ = d − 2Δχ). This is the Lang–Ruhl-solvable structure of the large-N vector model.
  • So the 6j here is the *self-energy* 6j of the critical-vector-model type, not a generic one.

REFERENCES to pull the closed form from (do NOT recall — verify):
  • Liu, Perlmutter, Rosenhaus, Simmons-Duffin, "The Bootstrap for the AdS/SYK 6j symbol"
    (JHEP 2018) — the explicit 6j.
  • Cardona, Sen, "Anomalous dimensions at finite conformal spin from OPE inversion" (2018).
  • Caron-Huot, "Analyticity in spin" (2017) — the inversion formula.
  • Lang & Ruhl (1990s) — the critical O(N) higher-spin current dims (the s=1 / short-range
    cross-check; our long-range case is the Δχ=(d−2s)/2 generalization).

WHAT THIS MODULE PROVIDES: `gate_candidate(C_T_expr)` — supply a VERIFIED closed form (in symbols
s, d) and it is substituted at ℓ=2 and run through the full gate harness. The instant a trusted
6j value exists, it is validated here. Until then, no number is asserted.
"""

from __future__ import annotations

import sys
import sympy as sp

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

from gate_checks import run_all_gates, s, d, ell
from cT_largespin import delta_chi


def conformal_spin_sq(dim=d, kin=s, spin=ell):
    """J̄² = (ℓ + Δχ)(ℓ + Δχ − 1) — the natural variable for the finite-spin 6j."""
    Dchi = delta_chi(dim, kin)
    return (spin + Dchi) * (spin + Dchi - 1)


def shadow_check(dim=d, kin=s):
    """Confirm σ is the shadow of [χχ]_{0,0}: Δσ = d − 2Δχ  (⇔ vertex uniqueness)."""
    return sp.simplify(2 * kin - (dim - 2 * delta_chi(dim, kin)))


# --- confirmed structure (from the very-well-poised ₇F₆(1) form) -------------------------
#
# The 6j is  N · ₇F₆[a1..a7; b1..b6; 1]  (very-well-poised). With
#   exchange σ:  Δ=Δσ=2s, J=0     ⇒ h_σ  = (Δσ−0)/2 = s,        h̄_σ  = (Δσ+0)/2 = s
#   inversion [χχ]_{0,2}: Δ'=2Δχ+2, J'=2 ⇒ h' = (Δ'−2)/2 = Δχ,   h̄' = (Δ'+2)/2 = Δχ+2
#   external Δφ = Δχ
# The a_i,b_j are linear combinations of {Δφ, h_σ, h̄_σ, h', h̄'} + shadow reflections (Δ→d−Δ);
# the b_j are fixed by the well-poised relations a1+1 = a2+b1 = a3+b2 = …  γ(n,J') is the
# RESIDUE of the 6j at the double-twist pole Δ' = 2Δφ + 2n + J'.
#
# EVALUABLE SPECIAL POINTS (half-integer reduction: Δφ half-integer ⇒ ₇F₆ terminates to a
# finite ₄F₃/₃F₂ sum, which sympy CAN evaluate exactly):
#   • d=4, s=3/2 : Δχ = 2−s = 1/2 (half-integer!), Δσ=3, super-renorm (s>d/4=1). ⇒ TERMINATES.
#     This is the first place a fully-verifiable C_T can be obtained (dS₅ boundary).
#   • d=4, s=1/2 : Δχ = 3/2 (half-integer) ⇒ terminates too.
#   In our physical d=3, Δχ=(3−2s)/2 is half-integer only for integer s (s=1 is the free point),
#   so d=3 needs the non-terminating ₇F₆ — hence the d=4 terminating point is the right first
#   verifiable target.

def h_hbar(Delta, J):
    """Conformal (h, h̄) = ((Δ−J)/2, (Δ+J)/2)."""
    return (Delta - J) / 2, (Delta + J) / 2


def doubletwist_pole(dim=d, kin=s, n=0, spin=2):
    """The pole location Δ' = 2Δχ + 2n + J' whose residue is γ_{n,J'}."""
    return 2 * delta_chi(dim, kin) + 2 * n + spin


def seven_F_six(a_params, b_params, prefactor=1):
    """Build the very-well-poised ₇F₆(1) once the 7 numerator + 6 denominator params are
    supplied (as the VERIFIED linear combinations of Δφ,h,h̄,h',h̄'). Returns a sympy expr;
    `hyperexpand` evaluates it (and terminates it at half-integer Δφ). The a_i,b_j themselves
    are the one input still needed from a verified source — not guessed here."""
    return prefactor * sp.hyper(a_params, b_params, sp.Integer(1))


def gate_candidate(C_T_expr, label="supplied 6j value"):
    """Run a VERIFIED closed form C_T(s,d) (the ℓ=2 residue) through the full gate harness.
    Pass an expression in symbols s, d; it is treated as γ_{0,2} and gated."""
    print(f"gating candidate [{label}]:  C_T(s,d) =", C_T_expr)
    cand = C_T_expr  # already at ℓ=2; the harness's ℓ→∞ gate uses the general-ℓ form if given
    return run_all_gates(cand)


if __name__ == "__main__":
    print("=== ℓ=2 6j / inversion residue — spec + interface (no formula invented) ===\n")
    print("inputs:  Δχ =", sp.simplify(delta_chi()), "   Δσ = 2s   ℓ = 2   n = 0")
    print("shadow/uniqueness check  Δσ − (d − 2Δχ) =", shadow_check(), " (=0 ✓ ⇒ σ = shadow of [χχ]_{0,0})")
    print("conformal spin  J̄²(ℓ=2) =", sp.simplify(conformal_spin_sq(spin=2)), "\n")

    print("The exact C_T = (OPE coeff)² × [6j]_{n=0,ℓ=2} must be pulled from the references in the")
    print("header and VERIFIED — not recalled. This module gates it the moment it is supplied:\n")

    # Interface demonstration ONLY — a hypothetical placeholder, NOT a claimed result:
    print("interface demo on a HYPOTHETICAL placeholder (not C_T): -(s-1)·(s+1)/ (4 ℓ**2) at ℓ=2")
    placeholder = -(s - 1) * (s + 1) / (4 * ell ** 2)
    gate_candidate(placeholder.subs(ell, 2), label="HYPOTHETICAL placeholder")
    print("\n(The placeholder is illustrative; it is NOT the 6j value. Supply a verified closed")
    print(" form via gate_candidate(...) to obtain a validated C_T.)")
