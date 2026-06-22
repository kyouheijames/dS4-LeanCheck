"""hs_sigma.py — the HS-σ / conservation question, resolved into a sharp literature target.

Two findings, in order:

(1) The naive "add the shadow exchange Δσ→d−2s" is EMPTY: the shadow's dDisc exponent
    p_e = (d−2s)/2 − Δχ = 0 identically, so its dDisc factor sin²(π·0)=0 and it contributes 0.
    So the HS-σ correction is NOT a shadow-block sum.

(2) The real issue was the WRONG conservation gate. In a LONG-RANGE model the would-be stress
    tensor is conserved not at s=1 but at the long-range/short-range CROSSOVER
         s* = 1 − η_SR/2,    η_SR = η₁/N   (η₁ = the short-range large-N anomalous dimension).
    s*=1 ⇔ η_SR=0 ⇔ short-range theory is FREE ⇔ d=4. In d=3 the short-range O(N) model is
    interacting (η₁≠0), so s*<1 and γ_T(s=1)≠0 is PHYSICAL, not a failure.

    The would-be T dimension is Δ_T = (d−2s)+2+γ_T/N (η_χ=0 exactly in the long-range model).
    Conservation Δ_T=d at s* with s*=1−η₁/(2N) gives the clean prediction
         γ_T^phys(1,d) = −η₁(d).
    η₁(d) = 2(μ−2)Γ(2μ−1)/(Γ(1−μ)Γ(μ)²Γ(μ+1)),  μ=d/2   [verified: η₁(3)=8/(3π²), η₁(4)=0].

    Our ENGINE (inversion.py / cT_real_4d) returns the KINEMATIC γ (per unit OPE coefficient f²).
    So γ_T^phys = C²_{χχσ}·γ_kin, and the prediction becomes a sharp target for the OPE coefficient:
         C²_{χχσ}(1,d) = −η₁(d)/γ_kin(1,d).
    d=4: 0/0 — both sides 0, passes trivially (and is WHY d=4 conserves at s=1).
    d=3: γ_kin(1,3) = −1/15 (exact), η₁(3)=8/(3π²)  ⇒  C²_{χχσ}(1,3) = 40/π² ≈ 4.0528.

STATUS: kinematic d=3 is solid; the PHYSICAL d=3 number needs C²_{χχσ}, an independent input.
The crossover turns conservation into the falsifiable check C²_{χχσ}(1,3)=40/π² (equiv.
γ_T^phys(1,3)=−8/(3π²)). The definitive cross-check reference for THIS theory is
arXiv:2107.08052 "Long-Range Vector Models at Large N". Not yet closed — no physical d=3 shipped.
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


def k_beta(beta, x):
    return x ** (beta / 2) * mp.hyp2f1(beta / 2, beta / 2, beta, x)


def C_T_exch(d, sphys, De):
    """KINEMATIC inversion for an exchanged scalar of dimension De (per unit OPE coeff), /2 factor."""
    d = mp.mpf(d); s = mp.mpf(sphys); De = mp.mpf(De)
    h = d / 2
    Dchi = (d - 2 * s) / 2
    beta = 2 * Dchi + 4
    p = De / 2 - Dchi
    dfac = 2 * mp.sin(mp.pi * p) ** 2
    if abs(dfac) < mp.mpf('1e-40'):
        return mp.mpf(0)
    C0p = (2 * mp.sin(mp.pi * Dchi) ** 2 * G(beta) * G(1 - Dchi) ** 2
           * G(beta / 2 + Dchi - 1) / (G(beta / 2) ** 2 * G(beta / 2 - Dchi + 1)))

    def integ(zbar):
        return (k_beta(beta, zbar) / zbar ** 2
                * mp.hyp2f1(De / 2, De / 2, De - h + 1, 1 - zbar)
                * (1 - zbar) ** p * zbar ** Dchi)

    I = mp.quad(integ, [0, mp.mpf('0.5'), 1])
    return (-2 * G(De) / G(De / 2) ** 2 / C0p * dfac * I) / 2


def eta1(d):
    """Short-range critical O(N) large-N anomalous dimension coefficient η₁(d) (η = η₁/N).
    Reflection-formula form 1/Γ(1−μ)=Γ(μ)sin(πμ)/π — finite at even d (η₁=0 there)."""
    mu = mp.mpf(d) / 2
    return 2 * (mu - 2) * G(2 * mu - 1) * mp.sin(mp.pi * mu) / (mp.pi * G(mu) * G(mu + 1))


if __name__ == "__main__":
    print("=== HS-σ resolution: shadow is empty; conservation lives at the crossover s* ===\n")

    print("(1) shadow exchange Δe=d−2s gives EXACTLY 0 (dDisc exponent p_e=0):")
    for d_t in [3]:
        for sv in [0.9, 1.0, 1.1, 1.2]:
            cs = C_T_exch(d_t, sv, d_t - 2 * sv)
            print(f"    d={d_t} s={sv}: C(shadow) = {mp.nstr(cs,4)}")

    print("\n(2) η₁(d) [verified]:  η₁(3) =", mp.nstr(eta1(3), 8),
          " = 8/(3π²)=", mp.nstr(8 / (3 * mp.pi ** 2), 8), "  η₁(4) =", mp.nstr(eta1(4), 4))

    print("\nCROSSOVER GATE  γ_T^phys(1,d) = −η₁(d)  (conservation at s*=1−η₁/(2N)):")
    for d_t in [4, 3]:
        # γ_kin(1,d): use s slightly off 1 in d=4 (Γ-pole exactly at s=1), exact rational in d=3
        if d_t == 4:
            gk = (C_T_exch(4, 0.999, 2 * 0.999) + C_T_exch(4, 1.001, 2 * 1.001)) / 2
        else:
            gk = C_T_exch(3, 1.0, 2.0)
        e1 = eta1(d_t)
        print(f"  d={d_t}: γ_kin(1)={mp.nstr(gk,6)}   −η₁={mp.nstr(-e1,6)}", end="")
        if abs(gk) < 1e-6 and abs(e1) < 1e-6:
            print("   → 0 = 0  PASS (short-range free; conserves at s=1)")
        else:
            Csq = -e1 / gk
            print(f"   ⇒ predict C²_χχσ(1,{d_t}) = −η₁/γ_kin = {mp.nstr(Csq,6)}"
                  f"  (=40/π²={mp.nstr(40/mp.pi**2,6)})")

    print("\n--- honest status ---")
    print("• Engine validated in d=4; d=3 KINEMATIC γ_kin(1)=−1/15 is solid.")
    print("• Shadow correction is empty (=0). Conservation is at the crossover s*, not s=1 —")
    print("  this EXPLAINS d=4 (s*=1, short-range free, γ_T(1)=0) and d=3 (s*<1, γ_T(1)≠0).")
    print("• Sharp falsifiable target: physical γ_T(1,3)=−8/(3π²), i.e. C²_χχσ(1,3)=40/π²≈4.053.")
    print("• NOT yet closed: needs the independent OPE coefficient C²_χχσ. Definitive reference for")
    print("  this exact theory: arXiv:2107.08052 'Long-Range Vector Models at Large N'. No physical")
    print("  d=3 number is shipped until C²_χχσ is checked against it — discipline holds.")
