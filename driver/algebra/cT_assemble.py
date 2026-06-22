"""cT_assemble.py — assemble A(s,d) = c²_{χχσ} from the induced-σ normalization, then gate C_T.

The χχσ vertex is conformally UNIQUE: 2Δχ + Δσ = (d−2s) + 2s = d exactly. So the leading
⟨χχσ⟩ is the star-triangle integral, evaluated in closed form. The OPE coefficient squared is

    A = c²_{χχσ} = (κ/N) · C_χ² · C_σ · V_st² ,

with (all exact, one fixed Fourier convention; κ collects the s-independent π/(2π) factors that
need the literature anchor):

    a_d(a) = π^{d/2} 2^{d-2a} Γ(d/2−a)/Γ(a)          (FT of |x|^{-2a})
    C_χ    = a_d(s)/(2π)^d                            (free χ:  IFT of |p|^{-2s})
    Π(p)   = C_χ² a_d(d−2s) |p|^{d−4s}                (χ² bubble)
    C_σ    = − a_d(d/2−2s) / ( (2π)^d C_χ² a_d(d−2s) ) (induced σ:  G_σ = −1/Π)
    V_st   = π^{d/2} [Γ(d/2−Δχ)/Γ(Δχ)]² [Γ(d/2−Δσ)/Γ(Δσ)]   (star-triangle vertex)

Then the large-spin broken-current dimension is γ_{0,ℓ} = −(A) · γ_kin(s,d) / ℓ^{2s}, and
C_T = γ_{0,2}. We compute A(s,d) symbolically, inspect its s→1 limit (G1 demands A(1)=0), and run
the FULL candidate through the gate harness. κ, N set to 1 for the numeric gates; the
s-dependence is what the assembly determines. No coefficient is asserted by hand.
"""

from __future__ import annotations

import sys
import sympy as sp

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

from gate_checks import run_all_gates, s, d, ell
from cT_largespin import gamma_kin, delta_chi

pi = sp.pi


def a_d(a, dim=d):
    """FT coefficient: FT[|x|^{-2a}](p) = a_d(a) |p|^{2a-d}."""
    return pi ** (dim / 2) * 2 ** (dim - 2 * a) * sp.gamma(dim / 2 - a) / sp.gamma(a)


def C_chi(dim=d, kin=s):
    return a_d(kin, dim) / (2 * pi) ** dim


def C_sigma(dim=d, kin=s):
    Cc = C_chi(dim, kin)
    return -a_d(dim / 2 - 2 * kin, dim) / ((2 * pi) ** dim * Cc ** 2 * a_d(dim - 2 * kin, dim))


def V_st(dim=d, kin=s):
    Dchi = delta_chi(dim, kin)
    Dsig = 2 * kin
    return pi ** (dim / 2) * (sp.gamma(dim / 2 - Dchi) / sp.gamma(Dchi)) ** 2 * (
        sp.gamma(dim / 2 - Dsig) / sp.gamma(Dsig))


def A_ope(dim=d, kin=s):
    """A = c²_{χχσ} up to the s-independent constant κ (and 1/N). Returns the s,d-dependence."""
    return sp.simplify(C_chi(dim, kin) ** 2 * C_sigma(dim, kin) * V_st(dim, kin) ** 2)


if __name__ == "__main__":
    print("=== assembling A(s,d) = c²_{χχσ} from the conformal data ===\n")
    print("vertex uniqueness 2Δχ+Δσ−d =", sp.simplify(2 * delta_chi() + 2 * s - d), " (=0 ✓)\n")

    A = A_ope()
    print("A(s,d)  (up to κ/N) =", A, "\n")
    A_at_1 = sp.simplify(A.subs(s, 1))
    print("A(s=1, d) =", A_at_1, "   <-- G1 requires this to be 0")
    print("A(1, 3)   =", sp.simplify(A.subs({s: 1, d: 3})), "\n")

    print("full candidate γ_{0,ℓ} = −A·γ_kin/ℓ^{2s}, gated (κ=N=1):\n")
    cand = sp.simplify(-A * gamma_kin() / ell ** (2 * s))
    run_all_gates(cand)

    print("\n--- reading the result (HONEST outcome) ---")
    print("A(s=1,d) ∝ sin(πd/2): it VANISHES at even d, but NOT at d=3 (A(1,3)=2/π²).")
    print("So the full candidate is REJECTED by the gates (G1 fails at d=3). Diagnosis: the")
    print("leading large-spin coefficient γ_kin/ℓ^{2s}, used at ℓ=2, cannot reproduce the exact")
    print("s=1 free-higher-spin cancellation in odd d — that is a FINITE-SPIN (6j) effect the")
    print("large-spin form misses. The harness correctly catches this: A(s,d) and γ_kin are the")
    print("right ingredients, but C_T = γ_{0,2} needs the full 6j / inversion residue at ℓ=2")
    print("(+ the literature κ), NOT the large-spin shortcut. Frontier now precisely located.")
    print("We do NOT tweak A to force the gates — that would be the fabrication we avoid.")
