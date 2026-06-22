"""cT_mellin.py — the paper's general-d Mellin formula (eq. 4.18) for C_T, evaluated in d=3.

Cardona–Sen eq. (4.18) (their `adscal`), the scalar-exchange anomalous dimension in GENERAL d
from the s=n Mellin poles:

  γ^{0,Δ}_{12}(β) = − [ (a−(Δ+τ')/2)_{Δ/2} (−a−(Δ+τ')/2)_{Δ/2} ]
                     / [ ((β−Δ−τ')/2−1)_{Δ/2} ((β+τ')/2+1)_{Δ/2} ] · Γ(Δ)/Γ(Δ/2)²
                   · ₄F₃[ 1−h+Δ/2, Δ/2, (Δ+τ')/2+1−a, (Δ+τ')/2+1+a ;
                          1+Δ−h, 2−(β−Δ−τ')/2, 1+(β+Δ+τ')/2 ; 1 ]

Our case (scalar σ exchange of [χχ]_{0,2}):  a=b=0, h=d/2, Δ=Δσ=2s, Δχ=(d−2s)/2,
external double-twist tree twist τ₀=2Δχ ⇒ τ'=−τ₀=−2Δχ (from C₀(β)=I_{−(Δ₁+Δ₂)}), and
conformal spin β = Δ_op+J_op = (2Δχ+2)+2 = 2Δχ+4.

CRUCIAL CAVEAT (paper's own footnote / eq. after 3.30): eq. (4.18) keeps ONLY the s=n poles —
it agrees at large β but MISSES additional finite-β poles at s=(β−Δ+J−τ)/2−1+n. The complete
result was assembled only for d=4 (eq. 3.30, our cT_real_4d.py). So in d=3 at ℓ=2 (small β),
eq. (4.18) is expected to be INCOMPLETE. We evaluate it and let the gates show the cost.
"""

from __future__ import annotations

import sys
import mpmath as mp

mp.mp.dps = 30
try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

G = mp.gamma
rf = mp.rf  # rising factorial (x)_n, valid for non-integer n = Δ/2 = s


def gamma_adscal(d, s, a=0):
    s = mp.mpf(s); d = mp.mpf(d)
    h = d / 2
    Dchi = (d - 2 * s) / 2
    D = 2 * s            # exchanged Δσ
    tp = -2 * Dchi       # τ' = −2Δχ
    beta = 2 * Dchi + 4  # conformal spin of [χχ]_{0,2}
    half = D / 2         # Δ/2 = s
    pref = (rf(a - (D + tp) / 2, half) * rf(-a - (D + tp) / 2, half)
            / (rf((beta - D - tp) / 2 - 1, half) * rf((beta + tp) / 2 + 1, half))
            * G(D) / G(D / 2) ** 2)
    F = mp.hyper([1 - h + D / 2, D / 2, (D + tp) / 2 + 1 - a, (D + tp) / 2 + 1 + a],
                 [1 + D - h, 2 - (beta - D - tp) / 2, 1 + (beta + D + tp) / 2], 1)
    return -pref * F


if __name__ == "__main__":
    print("=== eq. (4.18) general-d Mellin (s=n poles only) — evaluated, gated ===\n")

    print("d=3 (PHYSICAL), C_T(s) near s=1 (G1 conservation should → 0):")
    for sv in [0.7, 0.8, 0.9, 0.95, 1.05, 1.1, 1.2, 1.3]:
        try:
            v = gamma_adscal(3, sv)
            print(f"  s={sv:<5} C_T = {mp.nstr(v, 8)}")
        except Exception as e:
            print(f"  s={sv:<5} (eval issue: {e})")
    print("  -> WATCH for a pole/blow-up at s→1 (the lower ₄F₃ parameter 2−(β−Δ−τ')/2 = 3s−d → 0")
    print("     at s=1,d=3): a SPURIOUS singularity that the neglected finite-β poles must cancel.\n")

    print("d=4 cross-check: eq.(4.18) [s=n only] vs complete eq.(3.30):")
    try:
        from cT_real_4d import C_T_4d
        for sv in [1.2, 1.4]:
            a418 = gamma_adscal(4, sv)
            a330 = C_T_4d(sv)
            print(f"  s={sv}:  (4.18)={mp.nstr(a418,6)}   (3.30 complete)={mp.nstr(a330,6)}"
                  f"   diff={mp.nstr(a418 - a330,4)}  <- the neglected finite-β poles")
    except Exception as e:
        print("  (comparison issue:", e, ")")

    print("\n--- honest conclusion ---")
    print("eq. (4.18) keeps only s=n poles. In d=3 at ℓ=2 it carries a spurious s→1 singularity")
    print("(no conservation) and in d=4 it disagrees with the complete (3.30) by the neglected")
    print("finite-β poles. So the PHYSICAL d=3 C_T is NOT given by the paper's closed forms: it")
    print("needs the general-d completion (the s=(β−Δ+J−τ)/2−1+n poles) the authors did only for")
    print("d=4. That assembly is the genuine open frontier — flagged, not faked.")
