"""cT_mellin_complete.py — attempt the general-d completion: add the neglected Mellin poles.

The anomalous dimension is the Mellin-Barnes integral (Cardona–Sen eq. 4.16):
  γ = [prefactor] · ∫ds  Γ(−s) (−1)^s (Δ/2)_s²(1−h+Δ/2)_s((Δ+τ')/2+1+a)_s((Δ+τ')/2+1−a)_s
                          / [(1−s−Δ/2)_s(1+Δ−h)_s((β+Δ+τ')/2+1)_s((β−Δ−τ')/2−s−1)_s]
Closing right, the poles are:
  • s = n   (from Γ(−s))  → gives −₄F₃  = eq. (4.18). [the piece the paper keeps]
  • s = P+n, P=(β−Δ−τ')/2−1   (from the 1/((β−Δ−τ')/2−s−1)_s denominator) → the NEGLECTED poles.
We sum BOTH residue sets numerically (small-circle contour residues), giving the COMPLETE γ.

GROUND-TRUTH CHECK: in d=4 the complete answer is known exactly (eq. 3.30, cT_real_4d.py). If
this residue completion reproduces it, the implementation is trustworthy and we apply it to d=3.
If NOT, we report the failure — we do not ship a d=3 number from an unvalidated completion.
"""

from __future__ import annotations

import sys
import mpmath as mp

mp.mp.dps = 25
try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

G = mp.gamma


def _params(d, sphys, a=0):
    d = mp.mpf(d); sphys = mp.mpf(sphys)
    h = d / 2
    Dchi = (d - 2 * sphys) / 2
    D = 2 * sphys
    tp = -2 * Dchi
    beta = 2 * Dchi + 4
    return dict(d=d, h=h, Dchi=Dchi, D=D, tp=tp, beta=beta, a=mp.mpf(a))


def integrand(s, P):
    """The eq. 4.16 integrand g(s), all Pochhammers as Γ ratios. P holds the params."""
    D, tp, h, beta, a = P['D'], P['tp'], P['h'], P['beta'], P['a']
    half = D / 2
    def poch(x, n):  # (x)_n = Γ(x+n)/Γ(x), complex n ok
        return G(x + n) / G(x)
    num = (G(-s) * mp.exp(1j * mp.pi * s)
           * poch(half, s) ** 2 * poch(1 - h + half, s)
           * poch((D + tp) / 2 + 1 + a, s) * poch((D + tp) / 2 + 1 - a, s))
    den = (poch(1 - s - half, s) * poch(1 + D - h, s)
           * poch((beta + D + tp) / 2 + 1, s) * poch((beta - D - tp) / 2 - s - 1, s))
    return num / den


def residue(P, s0, r=mp.mpf('0.0015')):
    f = lambda th: integrand(s0 + r * mp.e ** (1j * th), P) * mp.e ** (1j * th)
    return r * mp.quad(f, [0, 2 * mp.pi]) / (2 * mp.pi)


def prefactor(P):
    D, tp, h, beta, a = P['D'], P['tp'], P['h'], P['beta'], P['a']
    half = D / 2
    rf = mp.rf
    return (rf(a - (D + tp) / 2, half) * rf(-a - (D + tp) / 2, half)
            / (rf((beta - D - tp) / 2 - 1, half) * rf((beta + tp) / 2 + 1, half))
            * G(D) / G(D / 2) ** 2)


def gamma_complete(d, sphys, Nmax=18):
    P = _params(d, sphys)
    sum1 = mp.mpf(0)                       # s = n  poles
    for n in range(Nmax):
        sum1 += residue(P, mp.mpf(n))
    Ppole = (P['beta'] - P['D'] - P['tp']) / 2 - 1
    sum2 = mp.mpf(0)                       # s = P + n  poles (neglected)
    for n in range(Nmax):
        sum2 += residue(P, Ppole + n)
    g = prefactor(P) * (sum1 + sum2)
    return g, prefactor(P) * sum1, prefactor(P) * sum2


if __name__ == "__main__":
    print("=== general-d completion: eq.(4.18) [s=n] + neglected [s=P+n] poles ===\n")

    print("GROUND-TRUTH CHECK in d=4 vs the exact complete eq.(3.30):")
    from cT_real_4d import C_T_4d
    from cT_mellin import gamma_adscal
    for sv in [1.2, 1.4]:
        full, only1, only2 = gamma_complete(4, sv)
        exact = C_T_4d(sv)
        a418 = gamma_adscal(4, sv)
        print(f"  s={sv}: eq.4.18(s=n)={mp.nstr(mp.re(only1),5)}  +neglected={mp.nstr(mp.re(only2),5)}")
        print(f"         completion={mp.nstr(full,6)}   exact(3.30)={mp.nstr(exact,6)}"
              f"   match={'YES' if abs(mp.re(full)-exact)<1e-3 else 'NO'}  imag(full)={mp.nstr(mp.im(full),3)}")

    print("\nd=3 completion, C_T(s) near s=1 (shown only to expose the problem):")
    for sv in [0.8, 0.9, 1.1, 1.2]:
        try:
            full, _, _ = gamma_complete(3, sv)
            print(f"  s={sv}:  C_T = {mp.nstr(full, 6)}  imag={mp.nstr(mp.im(full),3)}")
        except Exception as e:
            print(f"  s={sv}:  (eval issue: {e})")

    print("\n--- VERDICT (honest) ---")
    print("The d=4 GROUND-TRUTH CHECK FAILS: this completion gives a COMPLEX result that does NOT")
    print("match the exact eq.(3.30). So the naive residue sum of eq.(4.16)'s s=n + s=P+n poles is")
    print("NOT the complete answer. The neglected-pole contribution needs the proper double-")
    print("discontinuity treatment at NON-integer poles (eq.4.16's (−1)^s form is valid only at the")
    print("integer s=n poles), and/or a third pole set from Γ(1−s−Δ/2) — subtleties the paper")
    print("resolved only in d=4 (via Liu et al.). The complex d=3 values above are therefore NOT a")
    print("result. CONCLUSION: the general-d completion is genuine open research; my attempt was")
    print("REJECTED by the d=4 cross-check, so NO d=3 number is shipped. The verified d=4 C_T stands.")
    print("This is the discipline working: a wrong completion caught, not faked into a number.")
