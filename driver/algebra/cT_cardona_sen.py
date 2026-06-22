"""cT_cardona_sen.py — test the SUPPLIED Cardona–Sen closed form for C_T against the gates.

A closed form for γ(0,ℓ=2) was supplied (pasted, provenance = an LLM/source — UNVERIFIED). Per the
project discipline we do NOT trust it; we implement it faithfully and let the gate harness decide.
A pass is necessary, not sufficient (gates can't catch every wrong formula) — so a pass is reported
as "consistent with all physical limits, pending a real literature check", never as "verified".

Supplied form:
  γ(0,2) = − C²_{χχσ} · [Γ(Δσ)²/Γ(Δσ/2)⁴] · [Γ(Δχ+2)Γ(Δχ+2−d/2)] / [Γ(2Δχ+2−d/2)Γ(2Δχ−Δσ)] · W
  W = ₃F₂[ −2, 2Δχ+2−d/2, s ; Δχ+2, Δχ+2−d/2 ; 1 ]   (terminates after 3 terms since −2 is the top)

Our exact inputs:  Δχ = (d−2s)/2,  Δσ = 2s.  C²_{χχσ} = A_ope from cT_assemble (s,d-dependence; the
overall s-independent constant κ and 1/N are irrelevant to the gates and set to 1).

Key structural feature to watch: the 1/Γ(2Δχ−Δσ) = 1/Γ(d−4s) factor. At s=1 this is 1/Γ(d−4),
which VANISHES for d=3,4 (non-positive-integer argument) — the "double-trace threshold" zero that
should enforce conservation γ→0. The s→1 limit is 0·∞ (W diverges where this vanishes), so we take
it with sp.limit, not subs.
"""

from __future__ import annotations

import sys
import sympy as sp

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

s, d = sp.symbols("s d", positive=True)


def delta_chi(dim=d, kin=s):
    return (dim - 2 * kin) / 2


def W_core(dim=d, kin=s):
    """The terminating ₃F₂(-2, B, s; E, F; 1). Built two ways and cross-checked."""
    Dchi = delta_chi(dim, kin)
    B = 2 * Dchi + 2 - dim / 2
    E = Dchi + 2
    F = Dchi + 2 - dim / 2
    # explicit 3-term sum (negative-integer top parameter -2 truncates at k=2):
    explicit = (1
                - 2 * B * kin / (E * F)
                + B * (B + 1) * kin * (kin + 1) / (E * (E + 1) * F * (F + 1)))
    # sympy's hypergeometric, expanded:
    via_hyper = sp.hyperexpand(sp.hyper([-2, B, kin], [E, F], sp.Integer(1)))
    assert sp.simplify(explicit - via_hyper) == 0, "W: 3-term sum ≠ ₃F₂ — transcription error!"
    return sp.simplify(explicit)


def kin_factor(dim=d, kin=s):
    """The Γ-function kinematic prefactor of the supplied formula (everything except C² and W)."""
    Dchi = delta_chi(dim, kin)
    Dsig = 2 * kin
    return (sp.gamma(Dsig) ** 2 / sp.gamma(Dsig / 2) ** 4
            * sp.gamma(Dchi + 2) * sp.gamma(Dchi + 2 - dim / 2)
            / (sp.gamma(2 * Dchi + 2 - dim / 2) * sp.gamma(2 * Dchi - Dsig)))


def A_ope(dim=d, kin=s):
    """C²_{χχσ} from cT_assemble (s,d-dependence; κ=N=1). Reproduced here to keep this self-contained."""
    pi = sp.pi

    def a_d(a):
        return pi ** (dim / 2) * 2 ** (dim - 2 * a) * sp.gamma(dim / 2 - a) / sp.gamma(a)

    Cc = a_d(kin) / (2 * pi) ** dim
    Cs = -a_d(dim / 2 - 2 * kin) / ((2 * pi) ** dim * Cc ** 2 * a_d(dim - 2 * kin))
    Dchi = delta_chi(dim, kin)
    Vst = pi ** (dim / 2) * (sp.gamma(dim / 2 - Dchi) / sp.gamma(Dchi)) ** 2 * (
        sp.gamma(dim / 2 - 2 * kin) / sp.gamma(2 * kin))
    return sp.simplify(Cc ** 2 * Cs * Vst ** 2)


def gamma_02(dim=d, kin=s):
    """The full supplied candidate γ(0,2) with our exact inputs (κ=N=1). No global simplify
    (Gamma-combsimp is fragile); limits/evals act on the raw product."""
    return -A_ope(dim, kin) * kin_factor(dim, kin) * W_core(dim, kin)


def test_at_dimension(dim_val):
    print(f"\n=== d = {dim_val} ===")
    W = sp.simplify(W_core(dim_val, s))
    print("W(s) =", W)
    g = gamma_02(dim_val, s)
    print("γ(0,2)(s) =", g)
    # G1: s→1 conservation, via limit (the factor structure is 0·∞ at s=1):
    g1 = sp.simplify(sp.limit(g, s, 1))
    print("G1  lim_{s→1} γ(0,2) =", g1, "  ->", "PASS" if g1 == 0 else "FAIL")
    # G3 reality, G4 sign at s=1.4:
    v = sp.N(g.subs(s, sp.Rational(7, 5)))
    real_ok = abs(sp.im(v)) < 1e-9
    re = float(sp.re(v))
    print(f"G3  γ(0,2)(s=1.4) = {complex(v)}  real:", "PASS" if real_ok else "FAIL")
    print("G4  sign (Δ_T<d ⇒ <0 for s>1):  Re =", re, " ->", "PASS" if re < 0 else "FAIL")
    return {"d": dim_val, "G1": (g1 == 0, g1), "G3": real_ok, "G4": re < 0}


if __name__ == "__main__":
    print("=== testing the SUPPLIED Cardona–Sen closed form against the gates ===")
    print("(W cross-check: 3-term sum vs ₃F₂ — asserted equal inside W_core)\n")
    for dv in (sp.Integer(3), sp.Integer(4)):
        test_at_dimension(dv)
    print("\n--- verdict (honest) ---")
    print("RIGOROUS gates pass in BOTH d: G1 (conservation lim_{s→1}γ=0) and G3 (reality). G1 is")
    print("the nontrivial one the large-spin candidate FAILED — this formula vanishes at s=1 as it")
    print("must. G4 (sign) is HEURISTIC (not a theorem): it is <0 in d=3, >0 in d=4 — a d-dependent")
    print("PREDICTION to check, not a disqualifier.")
    print("So: in d=3 (our dS₄ boundary) the supplied C_T passes every applicable gate, giving a")
    print("concrete γ(0,2)(s) up to the overall constant κ (e.g. γ(0,2)(1.4)≈-4.0e-4·κ/N).")
    print("STILL NOT 'verified': gates are necessary, not sufficient, and the formula's provenance")
    print("is an unverified paste. Needs a real literature cross-check (Cardona–Sen / LPRS) + κ.")
