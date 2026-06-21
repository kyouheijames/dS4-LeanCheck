"""large_n_selfenergy.py — Part 2, the real large-N computation (exact sector + γ_T setup).

Goal: turn the long-range Sp(N) action's kinetic exponent `s` into interacting data via the
large-N (Hubbard-Stratonovich) expansion. This module does the parts that are UNAMBIGUOUSLY
computable with exact Fourier/conformal identities, and sets up — but does NOT fake — the
spin-2 broken-current integral whose value is `γ_T(s)`.

Honest scope (same discipline as STATUS.md):
  • EXACT here: the free χ propagator coefficient, the χ² bubble and its FT, the induced σ
    propagator and its dimension Δσ = 2s, and the long-range non-renormalization η_χ = 0.
  • SET UP, not evaluated: the order-1/N spin-2 self-energy that gives γ_T(s). The integrand is
    written explicitly from the exact propagators; evaluating its specific conformal integral
    (or cross-checking against the long-range-CFT literature) is the remaining research step.
    A fabricated coefficient would be the Ric-trap; we refuse it. The `s→1 ⇒ γ_T→0` rail is
    enforced on any candidate.

Convention: Euclidean R^d, Fourier transform  ∫ d^dx e^{-ip·x} |x|^{-2a} = K(a,d) |p|^{2a-d}.
"""

from __future__ import annotations

import sys
import sympy as sp

# Windows consoles default to cp1252; force UTF-8 so the symbols (Δ, χ, σ) print.
try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

d, s, N, p, x = sp.symbols("d s N p x", positive=True)


def K(a, dim=d):
    """Exact coefficient of the d-dim Fourier transform of |x|^{-2a}:
        ∫ d^dx e^{-ip·x} |x|^{-2a} = K(a,d) · |p|^{2a-d},
        K(a,d) = π^{d/2} · 2^{d-2a} · Γ(d/2 - a) / Γ(a).
    (Exact identity — the 'Fourier transform of a power'.)"""
    return sp.pi ** (dim / 2) * 2 ** (dim - 2 * a) * sp.gamma(dim / 2 - a) / sp.gamma(a)


# --- 1. Free χ sector (exact) ------------------------------------------------------------

def delta_chi(dim=d, kin=s):
    """Δχ = (d - 2s)/2, from the kinetic symbol |p|^{2s}."""
    return (dim - 2 * kin) / 2


def chi_position_coeff(dim=d, kin=s):
    """χ propagator in position space: G_χ(x) = C_χ · |x|^{-(d-2s)}. C_χ is the inverse FT of
    1/|p|^{2s}, i.e. K evaluated for the inverse transform (a = s, with the |p|↔|x| roles
    swapped and a (2π)^{-d} from the inverse convention absorbed into the constant)."""
    a = kin
    # inverse FT of |p|^{-2s} ∝ |x|^{-(d-2s)} with coefficient K(d/2 - s, d)/(2π)^d-type factor;
    # the s-dependent ratio that matters downstream is the Gamma-structure:
    return sp.simplify(sp.gamma(dim / 2 - a) / (sp.gamma(a) * 4 ** a * sp.pi ** (dim / 2)))


# --- 2. The χ² bubble and the induced σ propagator (exact) -------------------------------

def bubble_position(dim=d, kin=s):
    """σ self-energy at leading order = the χ² bubble Π(x) = G_χ(x)^2 ∝ |x|^{-2(d-2s)}.
    Returns (coefficient ∝ C_χ^2, the power 2(d-2s))."""
    Cchi = chi_position_coeff(dim, kin)
    power = 2 * (dim - 2 * kin)
    return sp.simplify(Cchi ** 2), power


def bubble_momentum(dim=d, kin=s):
    """FT of the bubble: Π(p) ∝ |p|^{(d-4s)}. Returns (coefficient, power d-4s)."""
    Ccoeff, _ = bubble_position(dim, kin)
    a = dim - 2 * kin           # bubble ~ |x|^{-2a}
    coeff = sp.simplify(Ccoeff * K(a, dim))
    power = 2 * a - dim          # = d - 4s
    return coeff, sp.simplify(power)


def delta_sigma(dim=d, kin=s):
    """Induced σ propagator G_σ(p) = -1/Π(p) ∝ |p|^{4s-d} ⇒ position ∝ |x|^{-2·(2s)}.
    So Δσ = 2s at leading order in 1/N (HS marginality, confirmed by the bubble inversion)."""
    return 2 * kin


# --- 3. Field anomalous dimension (exact, known result) ---------------------------------

def gamma_chi(dim=d, kin=s):
    """η_χ = 0 to all orders in 1/N: a long-range kinetic term |p|^{2s} (non-integer s) is
    non-analytic in p² and cannot be renormalized by the analytic counterterms the 1/N
    expansion generates. So Δχ = (d-2s)/2 is EXACT. (Long-range non-renormalization.)"""
    return sp.Integer(0)


# --- 4. The spin-2 broken current γ_T (SET UP, not faked) -------------------------------

C_T = sp.Function("C_T")   # the order-1/N coefficient: γ_T(s) = C_T(s,d)/N

def gamma_T_integrand_note():
    return (
        "γ_T(s) = C_T(s,d)/N, where C_T is the order-1/N spin-2 broken-current self-energy: a\n"
        "σ-exchange between the two χ legs of the would-be stress tensor T ~ χ ∂_{μ}∂_{ν} χ.\n"
        "The integrand is built from the EXACT propagators above:\n"
        "   G_χ(x) ∝ |x|^{-(d-2s)},   G_σ(x) ∝ |x|^{-4s}   (Δσ=2s),\n"
        "contracted with the spin-2 vertex. Its conformal integral (star-triangle / uniqueness)\n"
        "is the remaining evaluation — left symbolic; cross-check vs long-range-CFT literature.\n"
        "HARD RAIL: C_T(1,d) = 0 (locality/conservation at s=1)."
    )


def assert_local_rail(C_T_candidate, dim=d):
    """Any candidate C_T(s,d) MUST vanish at s=1 (stress-tensor conservation). Raises if not."""
    val = sp.simplify(C_T_candidate.subs(s, 1))
    if val != 0:
        raise AssertionError(f"C_T(1,d) = {val} ≠ 0 violates s→1 conservation.")
    return val


if __name__ == "__main__":
    print("=== Part 2: large-N self-energy — EXACT sector ===\n")
    print("Δχ(s)            =", sp.simplify(delta_chi()))
    print("C_χ (pos. coeff) =", chi_position_coeff())
    bc, bp = bubble_position()
    print("bubble Π(x)      ∝ |x|^(-(", sp.simplify(bp), "))   (= |x|^(-2(d-2s))),  coeff =", bc)
    mc, mp = bubble_momentum()
    print("bubble Π(p)      ∝ |p|^(", mp, ")   (= d-4s)")
    print("Δσ (LO)          =", sp.simplify(delta_sigma()), " (= 2s, marginality + bubble)")
    print("η_χ              =", gamma_chi(), " (long-range non-renormalization, exact)\n")

    print("s→1 sanity (local free scalar): Δχ(s=1) =", sp.simplify(delta_chi().subs(s, 1)),
          " (= (d-2)/2)\n")

    print("=== γ_T(s): the remaining research integral (NOT faked) ===")
    print(gamma_T_integrand_note())

    # Demonstrate the rail with a conservation-respecting toy C_T = k·(s-1):
    k = sp.symbols("k")
    print("\nrail check on toy C_T = k·(s-1):  C_T(1,d) =", assert_local_rail(k * (s - 1)))
