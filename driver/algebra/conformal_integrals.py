"""conformal_integrals.py — exact position-space conformal integral toolbox.

These are the *genuinely computable* primitives Part 2 stands on: closed-form
Gamma-function identities for the integrals that appear in the large-N expansion
of a (long-range) conformal scalar. Nothing here is asserted or fit — every
function below is an exact identity that sympy evaluates symbolically. This is
the "real algebra Lean cannot do" layer from STATUS.md, done where it belongs.

Conventions
-----------
* Euclidean R^d, d kept symbolic (so we can epsilon-continue / set d=3 for dS_4).
* A "propagator power" a means a factor 1/|x|^{2a}. A scalar of dimension Delta
  has propagator power a = Delta.
* All results are the coefficient functions; the |x|-power structure is returned
  separately so callers can track dimensions.

References (standard): Symanzik star-triangle / "uniqueness"; the one-loop
conformal bubble U(a,b). See e.g. Lang-Ruhl; Petkou; Gracey for large-N use.
"""

from __future__ import annotations

import sympy as sp

# Symbols used throughout Part 2.
d = sp.symbols("d", positive=True)          # boundary spacetime dimension
s = sp.symbols("s", positive=True)          # kinetic exponent of (-d^2)^s
N = sp.symbols("N", positive=True)          # large-N rank (Sp(N)/O(N))
G = sp.Function("Gamma")                      # display alias; we use sp.gamma below


def half(x):
    return sp.Rational(1, 2) * x


def bubble_U(a, b, dim=d):
    r"""Exact coefficient of the one-loop conformal bubble.

        \int d^dx  1/(|x|^{2a} |x-y|^{2b})
            = pi^{d/2} * U(a,b) * |y|^{d - 2a - 2b},

    with
        U(a,b) = Gamma(d/2 - a) Gamma(d/2 - b) Gamma(a + b - d/2)
                 / ( Gamma(a) Gamma(b) Gamma(d - a - b) ).

    Returns the *coefficient* U(a,b) (the pi^{d/2} and the |y|-power are tracked
    by the caller). Valid as a meromorphic identity in (a, b, d).
    """
    h = half(dim)
    num = sp.gamma(h - a) * sp.gamma(h - b) * sp.gamma(a + b - h)
    den = sp.gamma(a) * sp.gamma(b) * sp.gamma(dim - a - b)
    return sp.simplify(num / den)


def bubble_power(a, b, dim=d):
    """The |y|-exponent E in |y|^{-2E} produced by bubble_U: 2a + 2b - d -> here
    we return the dimension of the composite, Delta = a + b - d/2 (so the bubble
    behaves as an operator of that dimension). Handy for fixing induced fields."""
    return a + b - half(dim)


def star_triangle(a1, a2, a3, dim=d):
    r"""Symanzik uniqueness (star-triangle), valid when a1 + a2 + a3 = d:

        \int d^dx  prod_i 1/|x - x_i|^{2 a_i}
            = pi^{d/2} * V(a1,a2,a3)
              * 1/( |x12|^{d-2a3} |x13|^{d-2a2} |x23|^{d-2a1} ),

        V(a1,a2,a3) = prod_i Gamma(d/2 - a_i) / Gamma(a_i).

    Returns (coefficient V, residual_constraint). residual_constraint must be 0
    for the identity to hold; the caller should assert it.
    """
    h = half(dim)
    V = sp.simplify(
        (sp.gamma(h - a1) / sp.gamma(a1))
        * (sp.gamma(h - a2) / sp.gamma(a2))
        * (sp.gamma(h - a3) / sp.gamma(a3))
    )
    constraint = sp.simplify(a1 + a2 + a3 - dim)
    return V, constraint


def free_dim_chi(dim=d, kin=s):
    """Free (Gaussian) dimension of the long-range scalar: propagator |p|^{-2s}
    => |x|^{-(d-2s)} => Delta_chi = (d - 2s)/2. Matches Ds4Verification.freeDim."""
    return (dim - 2 * kin) / 2


def hs_field_dim_LO(dim=d, kin=s):
    """Leading large-N dimension of the Hubbard-Stratonovich field sigma coupling
    as sigma*chi*chi. Marginality of the cubic vertex pins
        Delta_sigma + 2 Delta_chi = d  =>  Delta_sigma = d - 2 Delta_chi = 2s.
    (1/N corrections come from the self-energy; see long_range_gamma.py.)"""
    return sp.simplify(dim - 2 * free_dim_chi(dim, kin))


if __name__ == "__main__":
    # Smoke checks of the identities at the dS_4 boundary value d = 3.
    a, b = sp.symbols("a b", positive=True)
    print("U(a,b)      =", bubble_U(a, b))
    print("Delta_chi   =", sp.simplify(free_dim_chi()))
    print("Delta_sigma =", sp.simplify(hs_field_dim_LO()), "(should be 2*s)")
    V, c = star_triangle(a, b, d - a - b)
    print("star-triangle constraint (must be 0):", sp.simplify(c))
