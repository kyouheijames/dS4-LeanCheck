"""block.py — Milestone 1: the scalar conformal block via the Casimir recursion, d-validated.

Builds the spin-0 conformal block G_{Δ,0}(z,z̄) in GENERAL d by solving the quadratic-Casimir
PDE as a power series, and validates it against the closed forms in d=2 and d=4. If it matches
both, the block is trustworthy and can be used for the d=3 inversion (Milestone 2/3).

Casimir operator (identical external scalars, a=b=0), verified to reproduce the eigenvalue at
leading order analytically:
  𝒟₂ = 𝒟_z + 𝒟_z̄ + (d−2)·(z z̄/(z−z̄))·[(1−z)∂_z − (1−z̄)∂_z̄],   𝒟_x = x²(1−x)∂_x² − x²∂_x,
  𝒟₂ G = ½ C₂ G,   C₂ = Δ(Δ−d) + ℓ(ℓ+d−2).
Ansatz: G = (z z̄)^{Δ/2} Σ_{m,n} a_{m,n} z^m z̄^n,  a_{0,0}=1, symmetric a_{m,n}=a_{n,m}.

Closed forms used as oracles:
  k_β(x) = x^{β/2} ₂F₁(β/2, β/2, β; x)
  d=2:  G = k_{Δ−ℓ}(z)k_{Δ+ℓ}(z̄) + k_{Δ+ℓ}(z)k_{Δ−ℓ}(z̄)
  d=4:  G = (z z̄/(z̄−z)) [k_{Δ−ℓ−2}(z)k_{Δ+ℓ}(z̄) − k_{Δ+ℓ}(z)k_{Δ−ℓ−2}(z̄)]
"""

from __future__ import annotations

import sys
import sympy as sp

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

z, zb = sp.symbols("z zb", positive=True)


def k_beta(beta, x):
    return x ** (sp.Rational(1, 2) * beta) * sp.hyper([beta / 2, beta / 2], [beta], x)


def block_d2_closed(D, ell):
    return k_beta(D - ell, z) * k_beta(D + ell, zb) + k_beta(D + ell, z) * k_beta(D - ell, zb)


def block_d4_closed(D, ell):
    return (z * zb / (zb - z)) * (k_beta(D - ell - 2, z) * k_beta(D + ell, zb)
                                  - k_beta(D + ell, z) * k_beta(D - ell - 2, zb))


def casimir_series_block(d, D, ell=0, M=6):
    """Solve the Casimir recursion to total order M; return G as a sympy expression in z,zb."""
    d = sp.nsimplify(d); D = sp.nsimplify(D); ell = sp.nsimplify(ell)
    # unknown coefficients a[m][n] = a[n][m], a[0][0]=1
    a = {}
    syms = []
    for m in range(M + 1):
        for n in range(m, M + 1 - m + m):  # ensure m+n<=M handled below
            pass
    # build symmetric unknowns with m<=n and m+n<=M
    for tot in range(M + 1):
        for m in range(0, tot + 1):
            n = tot - m
            if m <= n:
                if (m, n) == (0, 0):
                    a[(0, 0)] = sp.Integer(1)
                else:
                    s = sp.Symbol(f"a_{m}_{n}")
                    a[(m, n)] = s
                    syms.append(s)
    def aget(m, n):
        if m < 0 or n < 0 or m + n > M:
            return sp.Integer(0)
        return a[(min(m, n), max(m, n))]

    H = sum(aget(m, n) * z ** m * zb ** n for m in range(M + 1) for n in range(M + 1) if m + n <= M)
    h = D / 2
    C2 = D * (D - d) + ell * (ell + d - 2)

    def DxH(f, x):  # 𝒟_x(w·f)/w, derived analytically (fully polynomial, no w):
        return ((1 - x) * (h * (h - 1) * f + D * x * sp.diff(f, x) + x ** 2 * sp.diff(f, x, 2))
                - h * x * f - x ** 2 * sp.diff(f, x))

    # multiply the whole equation by (z−z̄) to clear the cross-term denominator → polynomial:
    EQ = sp.expand(
        (z - zb) * (DxH(H, z) + DxH(H, zb) - sp.Rational(1, 2) * C2 * H)
        + (d - 2) * (-h * (z - zb) * H
                     + z * zb * ((1 - z) * sp.diff(H, z) - (1 - zb) * sp.diff(H, zb))))

    poly = sp.Poly(EQ, z, zb)
    eqs = list(poly.coeffs())
    A, bvec = sp.linear_eq_to_matrix(eqs, syms)
    solset = sp.linsolve((A, bvec), syms)
    sub = dict(zip(syms, list(solset)[0]))
    return ((z * zb) ** (D / 2)) * H.subs(sub)


def num(expr, zv, zbv):
    return complex(expr.subs({z: sp.Rational(zv).limit_denominator(10**6),
                              zb: sp.Rational(zbv).limit_denominator(10**6)}).evalf(20))


if __name__ == "__main__":
    print("=== Milestone 1: scalar block via Casimir recursion, validated vs closed forms ===\n")
    pts = [(0.2, 0.1), (0.3, 0.15), (0.25, 0.2)]

    for d_test, closed in [(2, block_d2_closed), (4, block_d4_closed)]:
        D = sp.Rational(28, 10)        # Δ = 2.8 (a generic scalar)
        print(f"--- d={d_test}, Δ=2.8, ℓ=0 ---")
        Gser = casimir_series_block(d_test, D, ell=0, M=6)
        Gcl = closed(D, 0)
        ok = True
        for (zv, zbv) in pts:
            vs = num(Gser, zv, zbv)
            vc = num(Gcl, zv, zbv)
            rel = abs(vs - vc) / (abs(vc) + 1e-30)
            ok = ok and rel < 1e-4
            print(f"  (z,z̄)=({zv},{zbv}): series={vs:.6g}  closed={vc:.6g}  relerr={rel:.1e}")
        print("  ->", "PASS (series == closed form)" if ok else "FAIL", "\n")
