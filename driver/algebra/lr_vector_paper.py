"""lr_vector_paper.py — VERIFIED CFT data for our model from Chai–Goykhman–Sinha (arXiv:2107.08052),
"Long-Range Vector Models at Large N". This paper IS our theory (long-range O(N) at large N), and
its results are the literature ground truth. This file transcribes the relevant formulas and
evaluates them for our case, AND records the honest correction they force on our earlier work.

CONVENTION MAP. Paper kinetic ∫ φφ/|x−y|^{d+s_p} ⇒ Δφ=(d−s_p)/2, Δσ=s_p. OUR kinetic (−∂²)^{s}
⇒ Δχ=(d−2s)/2. Matching Δχ=Δφ gives  s_p = 2·s_(ours).  So our s=1 ↔ paper s_p=2 (short-range),
and Δσ(ours)=2s = s_p. ✓

WHAT THE PAPER ESTABLISHES (and what it overturns in our driver/):
• γ_φ = 0 exactly — the long-range field is protected (matches our Lean FreeSector: Δχ exact).
• "This fixed point is characterized by the LACK of a local stress-energy tensor." The would-be T
  is NOT conserved in the long-range regime — γ_T ≠ 0 — and conservation is restored only at the
  long-range/short-range CROSSOVER s* = 2−2γ_φ̂ (their s) = 1−η_SR/2 (ours). This is EXACTLY our
  "locality is a quantum observable that breaks" thesis — now a published, rigorous result. Our
  Lean locality rail (γ_T=0 ⟺ s=1) is the N→∞ leading-order statement (s*→1); the 1/N shift is η.
• PHYSICAL stress-tensor anomalous dimension (their eq. 7.32, conformal perturbation theory):
      γ_T = (2 α(d) δ / Γ(d/2)) · γ_φ̂ + O(δ², γ_φ̂²),   δ=(s*−s)/2,  γ_φ̂ = short-range η/2.
  γ_T ∝ (s*−s) [vanishes AT the crossover] and ∝ γ_φ̂ [=0 whenever short-range is free, e.g. d=4].

HONEST RETRACTION (the literature cross-check did its job):
Our inversion engine (inversion.py / cT_real_4d.py) computes the GENERIC Cardona–Sen scalar-exchange
anomalous dimension. That is NOT the physical long-range γ_T: (i) the paper's γ_T(d=4)=0 since
γ_φ̂=0, but our engine gives −0.666(s−1)²; (ii) the paper's γ_T vanishes at the crossover s*≈1,
ours vanishes at the dDisc-zero s=0.75 (d=3). So the engine's d=4 "−0.0219" and the d=3 generic
values are NOT the physical stress-tensor anomalous dimension. They are a correct GENERIC-exchange
calculation applied to the wrong assembly. The "crossover prediction C²=40/π²" was built on the
false relation γ_T=C²·γ_kin and is withdrawn. The discipline (cross-check vs the definitive
reference) caught a plausible-but-wrong program — exactly what it exists to do.

VERIFIED literature datum implemented below: the leading-order OPE coefficient, eq. (5.3).
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


def C2_phiphisigma(d, s_ours):
    """Paper eq. (5.3): leading-order |C_φφσ|² with unit-normalized fields (×N factored out).
    Returns N·C²  (i.e. the O(1) coefficient). s_p = 2·s_ours is the paper's exponent."""
    d = mp.mpf(d); sp = 2 * mp.mpf(s_ours)
    # C̄^{(0)}_φφσ = −(1/√N) Γ(s/2)²Γ(d/2−s) √[(d−2s)Γ(s)sin(½π(d−2s))Γ(d−s)] / [√π Γ(s)Γ((d−s)/2)²]
    rad = (d - 2 * sp) * G(sp) * mp.sin(mp.pi * (d - 2 * sp) / 2) * G(d - sp)
    Cbar = (G(sp / 2) ** 2 * G(d / 2 - sp) * mp.sqrt(rad)
            / (mp.sqrt(mp.pi) * G(sp) * G((d - sp) / 2) ** 2))
    return Cbar ** 2          # = N · C²_φφσ


def gamma_sigma_diag1(d, s_ours):
    """Paper eq. (3.7): the first-diagram contribution to γ_σ (×N factored). Partial (1 of 3)."""
    d = mp.mpf(d); sp = 2 * mp.mpf(s_ours)
    return -4 * G(sp / 2) ** 2 * G(d - sp) / (G(d / 2) * G((d - sp) / 2) ** 2 * G(sp - d / 2))


if __name__ == "__main__":
    print("=== VERIFIED long-range O(N) CFT data (Chai–Goykhman–Sinha 2107.08052) ===\n")
    print("Convention: paper s_p = 2·s_ours.  Δχ=(d−2s)/2,  Δσ=2s=s_p.\n")

    print("Leading-order OPE coefficient  N·C²_φφσ  (eq. 5.3):")
    for d_t, s_t in [(3, 1.0), (3, 0.9), (3, 0.8), (4, 0.9), (4, 0.8)]:  # d=4,s=1 is a Γ(0) pole
        v = C2_phiphisigma(d_t, s_t)
        print(f"  d={d_t}, s={s_t}:  N·C²_φφσ = {mp.nstr(v, 8)}")

    target = 4 / mp.pi ** 2
    got = C2_phiphisigma(3, 1.0)
    print(f"\nCHECK at our (s=1,d=3):  N·C²_φφσ = {mp.nstr(got,10)}   vs  4/π² = {mp.nstr(target,10)}",
          "  MATCH" if abs(got - target) < mp.mpf('1e-12') else "  MISMATCH")
    print("  (NOT 40/π² — the withdrawn 'crossover prediction'; NOT 0.25/π⁴ — the wrong bubble.)")

    print("\nFor contrast, our generic-exchange engine gave γ_kin(1,3)=−1/15 — a DIFFERENT object")
    print("(generic σ-exchange, not the physical γ_T). Physical γ_T is eq. 7.32: ∝(s*−s)·γ_φ̂,")
    print("vanishing at the crossover s* and =0 whenever short-range is free (all of d=4).")

    print("\n=== Physical γ_T structure + the locality↔non-unitarity link (paper §7) ===")
    print("Physical stress-tensor anomalous dimension (eq. 7.32, near the crossover s*):")
    print("   γ_T = (2 α(d) δ / Γ(d/2)) · γ_φ̂ + O(δ²,γ_φ̂²),   δ = (s*−s)/2.")
    print("   • ∝ (s*−s): vanishes AT the crossover (T conserved there).")
    print("   • ∝ γ_φ̂ (short-range η/2): =0 whenever short-range is free (all of d=4).")
    print("   GAP: the coefficient α(d) is NOT in 2107.08052 — it is imported from ref [11]")
    print("   (Behan–Rastelli–Rychkov–Zan IR duality). Absolute γ_T needs that paper; we do NOT")
    print("   fabricate α(d). Deep-long-range γ_T further needs the non-perturbative λ*²(s).")
    print("")
    print("KEY for the locality-as-observable / SSB-ghost conjecture (rigorous, from the paper):")
    print("   ∂_μ T^μν = λ* ∂^ν(φ̂ χ)          (eq. 7.36)  — non-conservation SOURCED by χ")
    print("   ⟨χχ⟩ = C_χ/|x|^{2Δχ}, C_χ = −2C(s) < 0   (eq. 7.13)  — χ is NEGATIVE-norm (ghost-like)")
    print("   χ ↔ σφ                            (eq. 7.17)  — the dual ghost = shadow/EOM composite")
    print("   ⇒ locality-breaking (γ_T) is literally mediated by a negative-norm mode. This is a")
    print("   literature-backed equation form of the locality↔Krein/non-unitarity thesis — not an")
    print("   analogy. It is the honest physical anchor for the Ω-SSB / ghost question.")

    print("\n=== α(d) from ref [11] (Behan–Rastelli–Rychkov–Zan 1703.05325) ===")
    print("Fixed-point coupling g*² = δ/β₃ (their eq. 2.25) ⇒ α(d) = 1/β₃(d). β₃ = cubic")
    print("beta-function coeff of the σχ flow. β₃>0 (proved, d=2,3) ⇒ real fixed point ⇒ α>0.")
    beta3 = {2: mp.mpf('1.268404'), 3: mp.mpf('12.26')}   # eq. 2.19 (d=2), eq. 2.24 (d=3); N=1 Ising
    for d_t in (2, 3):
        a = 1 / beta3[d_t]
        print(f"  d={d_t}:  β₃ = {mp.nstr(beta3[d_t],6)}  ⇒  α({d_t}) = 1/β₃ = {mp.nstr(a,5)}")
    print("\nSIGN RESULT (the physical headline): α>0, δ>0, γ_φ̂>0, Γ(d/2)>0  ⇒  γ_T = (2αδ/Γ(d/2))γ_φ̂")
    print("  is POSITIVE ⇒ Δ_T = d + γ_T > d, the UNITARY direction (locality-breaking is 'soft').")
    print("  Our retracted generic engine gave γ_T<0 — OPPOSITE sign, confirming it was wrong.")
    print("  The non-unitarity is carried separately by the χ ghost (C_χ<0), NOT by γ_T pushing")
    print("  below the spin-2 bound.")
    # d=3 Ising illustration of the magnitude (N=1, η_Ising≈0.03627 ⇒ γ_φ̂=η/2):
    eta_ising3 = mp.mpf('0.036298'); gphi = eta_ising3 / 2
    slope = 2 * (1 / beta3[3]) / G(mp.mpf(3) / 2) * gphi
    print(f"\n  d=3 ISING illustration: γ_T ≈ {mp.nstr(slope,4)}·δ  (δ=(s*−s)/2), small & positive.")
    print("  CAVEAT: β₃=12.26 is the N=1 ISING value (3d-Ising bootstrap). OUR model is large-N")
    print("  O(N) (and symplectic Sp(N)); its β₃ differs and is NOT in either paper — it needs the")
    print("  large-N σσσσ integral (BRRZ eq. 2.18/2.20 at large N). So α(3)=0.0816 is ISING, not")
    print("  our value. We do NOT misreport it as the large-N number.")
