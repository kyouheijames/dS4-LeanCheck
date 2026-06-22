"""inversion.py — Milestone 2a: validate the dDisc + z̄-integral inversion machinery.

The Cardona–Sen position-space anomalous dimension (their eq. 3.6) is the z̄-integral of the
LEADING-z log term of the t-channel block (a closed-form ₂F₁ in all d), with the tree-level OPE
coefficient C_0(β) dividing out the κ_β normalization:

  γ_kin(β) = −2 · Γ(Δ)/Γ(Δ/2)² · (κ_β / C_0(β)) · dDisc-factor · ∫₀¹ dz̄/z̄² k_β(z̄)
             · ₂F₁[Δ/2,Δ/2,Δ−h+1; 1−z̄] · (1−z̄)^{Δ/2−Δχ} z̄^{Δχ}

with  dDisc[(1−z̄)^p z̄^q] = 2sin²(πp)(1−z̄)^p z̄^q,  p=Δ/2−Δχ,  and (eq. 3.5)
  C_0(β)/κ_β = 2sin²(πΔχ)·Γ(β)Γ(1−Δχ)²Γ(β/2+Δχ−1) / (Γ(β/2)²Γ(β/2−Δχ+1)).
κ_β cancels (C_0 ∝ κ_β), so it is never needed.

Our case (scalar σ-exchange of [χχ]_{0,2}): Δ=Δσ=2s, Δχ=(d−2s)/2, h=d/2, β=2Δχ+4.

VALIDATION: this must reproduce eq. (4.18) (cT_mellin.gamma_adscal) — the paper DERIVED 4.18 from
this very integral via Mellin. A match confirms the dDisc + integral + C_0 machinery is correct.
(It is still the s=n / leading-z result; the finite-β COMPLETION needs the subleading-z terms =
the full crossed-channel block — that is Milestone 2b, where block.py enters.)
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


def gamma_zbar_integral(d, sphys):
    d = mp.mpf(d); s = mp.mpf(sphys)
    h = d / 2
    Dchi = (d - 2 * s) / 2
    D = 2 * s
    beta = 2 * Dchi + 4
    p = D / 2 - Dchi                      # = 2s − d/2  (dDisc exponent)

    C0_over_kappa = (2 * mp.sin(mp.pi * Dchi) ** 2 * G(beta) * G(1 - Dchi) ** 2
                     * G(beta / 2 + Dchi - 1) / (G(beta / 2) ** 2 * G(beta / 2 - Dchi + 1)))
    dDisc_fac = 2 * mp.sin(mp.pi * p) ** 2

    def integrand(zbar):
        return (k_beta(beta, zbar) / zbar ** 2
                * mp.hyp2f1(D / 2, D / 2, D - h + 1, 1 - zbar)
                * (1 - zbar) ** p * zbar ** Dchi)

    I = mp.quad(integrand, [0, mp.mpf('0.5'), 1])
    return -2 * G(D) / G(D / 2) ** 2 / C0_over_kappa * dDisc_fac * I


if __name__ == "__main__":
    print("=== Milestone 2a: dDisc + z̄-integral machinery, vs eq. (4.18) ===\n")
    from cT_mellin import gamma_adscal

    for d_test in [4, 3]:
        print(f"--- d={d_test} ---")
        for sv in [1.2, 1.4]:
            g_int = gamma_zbar_integral(d_test, sv)
            g_418 = complex(gamma_adscal(d_test, sv))
            rel = abs(complex(g_int) - g_418) / (abs(g_418) + 1e-30)
            print(f"  s={sv}: z̄-integral={mp.nstr(g_int,6)}   eq.4.18={g_418.real:.6g}"
                  f"   relerr={rel:.1e}  {'MATCH' if rel < 1e-3 else 'MISMATCH'}")
    print("\nSTATUS: MISMATCH — this z̄-integral does NOT yet reproduce eq.(4.18). The error is")
    print("STRUCTURAL (relerr is not a constant ratio), i.e. in the inversion normalization: the")
    print("κ_β/C_0 factor, the ₂F₁ argument form (the paper also uses a 1↔−(1−z̄)/z̄ transform,")
    print("eq. 3.8), or the β/k_β convention. This is the fiddly inversion bookkeeping — focused")
    print("debugging needed before M2b. We do NOT proceed on an unvalidated machinery. (M1 block")
    print("stands validated; the inversion normalization is the current blocker.)")
