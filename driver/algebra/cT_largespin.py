"""cT_largespin.py — Part 2(iii): the large-spin / leading-twist crack at C_T, gated.

The Lorentzian inversion of a single scalar exchange (dim Δσ) into the double-twist [χχ]_{0,ℓ}
has a KNOWN large-spin form (Fitzpatrick–Kaplan–Poland–Simmons-Duffin 2012; Komargodski–Zhiboedov):

    γ_{0,ℓ}(s,d) ≈ - (A / N) · γ_kin(s,d) / ℓ^{Δσ},   Δσ = 2s,

with the EXACT kinematic coefficient (n=0, scalar exchange of twist Δσ, external Δχ):

    γ_kin = 2 Γ(Δσ) Γ(Δχ)² / ( Γ(Δσ/2)² Γ(Δχ − Δσ/2)² ),   Δχ = (d−2s)/2.

What is rigorous here: the FALLOFF EXPONENT 2s (= Δσ) and the kinematic coefficient γ_kin(s,d).
What is NOT pinned: A(s,d) = the χχσ OPE coefficient squared (∝ 1/N), which needs the induced-σ
normalization (computed exactly in large_n_selfenergy.py) AND a literature cross-check.

We run the bare kinematic candidate (A=1) through the gate harness. The harness then PINPOINTS
what A must supply — and the result is informative: γ_kin does NOT vanish at s=1, so gate G1
forces A(1)=0. That is the honest output: the structure is fixed, and the one remaining unknown
A(s,d) is constrained (A(1)=0) and localized — no coefficient is invented.
"""

from __future__ import annotations

import sys
import sympy as sp

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

from gate_checks import run_all_gates, s, d, ell


def delta_chi(dim=d, kin=s):
    return (dim - 2 * kin) / 2


def gamma_kin(dim=d, kin=s):
    """Exact n=0 large-spin kinematic coefficient for scalar exchange Δσ=2s, external Δχ."""
    Dchi = delta_chi(dim, kin)
    Dsig = 2 * kin
    return sp.simplify(
        2 * sp.gamma(Dsig) * sp.gamma(Dchi) ** 2
        / (sp.gamma(Dsig / 2) ** 2 * sp.gamma(Dchi - Dsig / 2) ** 2))


def gamma_largespin(dim=d, kin=s, spin=ell):
    """Bare large-spin candidate with the OPE factor set to 1 (A=1): γ = -γ_kin/ℓ^{2s}."""
    return -gamma_kin(dim, kin) / spin ** (2 * kin)


if __name__ == "__main__":
    print("=== Part 2(iii): large-spin kinematic coefficient (gated) ===\n")
    print("Δχ           =", sp.simplify(delta_chi()))
    print("γ_kin(s,d)   =", gamma_kin())
    print("γ_kin(s=1,d) =", sp.simplify(gamma_kin().subs(s, 1)), " (≠ 0 in general!)")
    print("γ_kin(1,3)   =", sp.simplify(gamma_kin().subs({s: 1, d: 3})), "\n")

    print("falloff: γ_{0,ℓ} ∝ 1/ℓ^(2s) = 1/ℓ^Δσ  (rigorous large-spin exponent)\n")

    print("Running the BARE kinematic candidate (A=1) through the gates:\n")
    cand = gamma_largespin()
    run_all_gates(cand)

    print("\n--- reading the gates ---")
    print("G1 FAILS because γ_kin(s=1) =", sp.simplify(gamma_kin().subs(s, 1)),
          "≠ 0. Free higher-spin symmetry at s=1 then REQUIRES the OPE factor A(s,d) to vanish")
    print("at s=1:  A(1,d) = 0.  So the honest remaining unknown is the χχσ OPE coefficient")
    print("squared A(s,d) — fixed by the induced-σ normalization (large_n_selfenergy.py) up to")
    print("a constant needing literature cross-check. C_T(s,d) = -A(s,d)·γ_kin(s,d)/2^(2s) at ℓ=2.")
    print("No coefficient invented; the structure + the A(1)=0 constraint are the real output.")
