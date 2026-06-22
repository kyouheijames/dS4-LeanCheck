"""gamma_spin.py — spin dependence γ_ℓ of the double-twist [χχ]_{0,ℓ} from σ-exchange.

Tests the "lift the tower" gravity question: does the higher-spin tower get MORE anomalous (lifted,
Einstein-like — spin-2 special) or LESS (democratically higher-spin) as ℓ grows?

Same validated inversion engine (inversion.py), generalized to spin ℓ by the s-channel conformal
spin β = Δ_op + J = (2Δχ+ℓ) + ℓ = 2Δχ + 2ℓ. Only β changes with ℓ; the exchanged σ (Δσ=2s) is fixed.

HONEST CAVEAT: this is the GENERIC σ-exchange γ_ℓ (the same object our γ_T retraction applies to) —
the KINEMATIC large-spin structure, not the physical higher-spin anomalous dimensions. But the
large-spin DECAY law is a universal lightcone result (double-twists → conserved at large ℓ), so the
TREND (which way the tower goes) is robust even if absolute values are generic.
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


def gamma_ell(d, sphys, ell):
    """Generic σ-exchange anomalous dimension of [χχ]_{0,ℓ} (the /2-convention, as validated)."""
    d = mp.mpf(d); s = mp.mpf(sphys); ell = mp.mpf(ell)
    h = d / 2
    Dchi = (d - 2 * s) / 2
    D = 2 * s
    beta = 2 * Dchi + 2 * ell                 # conformal spin of [χχ]_{0,ℓ}
    p = D / 2 - Dchi
    C0p = (2 * mp.sin(mp.pi * Dchi) ** 2 * G(beta) * G(1 - Dchi) ** 2
           * G(beta / 2 + Dchi - 1) / (G(beta / 2) ** 2 * G(beta / 2 - Dchi + 1)))
    dfac = 2 * mp.sin(mp.pi * p) ** 2

    def integ(zb):
        return (k_beta(beta, zb) / zb ** 2
                * mp.hyp2f1(D / 2, D / 2, D - h + 1, 1 - zb)
                * (1 - zb) ** p * zb ** Dchi)

    I = mp.quad(integ, [0, mp.mpf('0.5'), 1])
    return (-2 * G(D) / G(D / 2) ** 2 / C0p * dfac * I) / 2


if __name__ == "__main__":
    print("=== γ_ℓ spin dependence (generic σ-exchange) — the 'lift the tower?' test ===\n")
    ells = [2, 4, 6, 8, 10, 12, 16, 24]
    for d_t, sv in [(4, 1.4), (3, 0.9)]:
        s = mp.mpf(sv)
        print(f"--- d={d_t}, s={sv}  (Δσ=2s={mp.nstr(2*s,4)}; expect γ_ℓ ~ 1/ℓ^{{2s}} large-spin) ---")
        g2 = gamma_ell(d_t, sv, 2)
        for L in ells:
            gL = gamma_ell(d_t, sv, L)
            ratio = gL / g2
            scal = gL * mp.mpf(L) ** (2 * s)     # γ_ℓ·ℓ^{2s} → const if the 1/ℓ^{2s} law holds
            print(f"   ℓ={L:>2}:  γ_ℓ={mp.nstr(gL,6):>12}   γ_ℓ/γ_2={mp.nstr(ratio,4):>8}"
                  f"   γ_ℓ·ℓ^(2s)={mp.nstr(scal,5)}")
        print()

    print("--- reading ---")
    print("If γ_ℓ DECREASES with ℓ (and γ_ℓ·ℓ^{2s}→const): higher spins are LESS anomalous = MORE")
    print("conserved at large ℓ; the spin-2 (graviton) is the MOST broken. That is the OPPOSITE of")
    print("'lift the tower for Einstein' — the vector-model bulk keeps the graviton heaviest, tower")
    print("asymptotically conserved. (Universal lightcone behaviour: double-twists→conserved at large")
    print("spin.) Honest: generic-exchange values, but the DECAY trend is the robust, gravity-relevant")
    print("content — and it says this setup does NOT naturally isolate an Einstein graviton.")
