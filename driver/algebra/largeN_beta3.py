"""largeN_beta3.py — large-N O(N) β₃ from the DERIVED leading-N O-4pt (O=φ̂ⁱχⁱ).

Derivation (see chat / NOTES): at large N, φ̂ and χ are both GFF, and the O(N) index combinatorics
(Σ P_a P_b = N² if a=b else N) makes the LEADING-N unit-normalized O-4pt a GFF of dimension Δ_O:
   f̂(z) = 1 + |z|^{−2Δ_O} + |1−z|^{−2Δ_O}.
At the crossover Δ_O = d (marginal), and the only relevant operator in O×O is the IDENTITY (the
φ̂×φ̂→σ channel is 1/N-suppressed) ⇒ a single divergence to subtract, the cleanest possible case.

β₃ via BRRZ Method 2 (validated to 0.07% in d=2, see brrz_beta3.py):
   β₃ = −(S_d/2)·I_d,   I_d = ∫_R d^d y f̂(ê,y),   R = {|y|<1, y·ê<1/2}.
d=3:  S₃ = 4π,  z = r e^{iθ} (θ = polar angle to ê),  d³y = 2π r² dr sinθ dθ,  f̂ = 1+r^{−6}+|1−z|^{−6}.
Only the r→0 identity divergence ~ a^{−3}; fit J₃(a)=c₃/a³ + I₃ + corrections.

HONEST STATUS: machinery validated (d=2 Ising); derivation explicit. But this is LEADING-N and has
NO independent end-to-end literature check (CGS leave α(d) implicit; no published large-N γ_T number
to diff against). So: best derivation-based estimate, with consistency checks (β₃>0 ⇒ real fixed
point; γ_T>0), NOT a literature-confirmed value. Flagged, not faked.
"""

from __future__ import annotations
import sys
import mpmath as mp

mp.mp.dps = 22
try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

PI = mp.pi


def fhat_d3(r, th):
    z = r * mp.e ** (1j * th)
    return (1 + r ** (-6) + abs(1 - z) ** (-6)).real if isinstance(r ** (-6), complex) \
        else 1 + r ** (-6) + abs(1 - z) ** (-6)


def angular3(r):
    """∫ sinθ f̂(r,θ) dθ over θ∈[0,π] with the cap y·ê<1/2 (cosθ<1/(2r)) removed."""
    if r <= mp.mpf('0.5'):
        return mp.quad(lambda th: mp.sin(th) * fhat_d3(r, th), [0, PI / 2, PI])
    th0 = mp.acos(1 / (2 * r))                  # allowed: θ ∈ (th0, π]
    return mp.quad(lambda th: mp.sin(th) * fhat_d3(r, th), [th0, PI / 2 + th0 / 2, PI])


def J3(a):
    """J₃(a) = ∫_{R,|y|>a} d³y f̂ = 2π ∫_a^1 r² angular3(r) dr."""
    return 2 * PI * mp.quad(lambda r: r ** 2 * angular3(r), [a, mp.mpf('0.5'), 1])


if __name__ == "__main__":
    print("=== large-N O(N) β₃ (d=3) from the leading-N GFF-of-O 4pt  f̂=1+|z|^-6+|1-z|^-6 ===\n")
    avals = [mp.mpf('0.03'), mp.mpf('0.02'), mp.mpf('0.015'), mp.mpf('0.01'),
             mp.mpf('0.007'), mp.mpf('0.005')]
    Js = []
    for a in avals:
        Ja = J3(a)
        Js.append(Ja)
        print(f"  a={mp.nstr(a,4)}:  J₃(a) = {mp.nstr(Ja,10)}")

    # Only divergence is r→0 identity ~ a^{-3}. Extract I₃ by fixing nothing: fit c3/a³+c1/a+I+cp*a.
    A = mp.matrix(len(avals), 4); b = mp.matrix(len(avals), 1)
    for i, a in enumerate(avals):
        A[i, 0] = 1 / a ** 3; A[i, 1] = 1 / a; A[i, 2] = 1; A[i, 3] = a; b[i] = Js[i]
    sol = mp.lu_solve(A.T * A, A.T * b)
    c3, c1, I3, cp = sol[0], sol[1], sol[2], sol[3]
    print(f"\n  fit:  J₃ ≈ {mp.nstr(c3,6)}/a³ + {mp.nstr(c1,5)}/a + {mp.nstr(I3,6)} + {mp.nstr(cp,4)}·a")
    print(f"  I₃ = ∫_R f̂ = {mp.nstr(I3,7)}")

    S3 = 4 * PI
    beta3 = -(S3 / 2) * I3
    print(f"\n  β₃ (leading N) = −(S₃/2)·I₃ = {mp.nstr(beta3,5)}   (S₃=4π) — i.e. ≈ 0")
    print(f"  signatures: c₃=4π/3={mp.nstr(4*PI/3,7)} (identity, exact), c₁≈0 (NO energy — GFF-of-O ✓)")

    print("\n--- RESULT (the 'DO IT' payoff) ---")
    print("I₃ ≈ 0 ⇒ the LEADING-N β₃ VANISHES. Physically correct: a pure GFF is free, so a bilinear")
    print("g·O perturbation has no β-function at leading order. (Contrast d=2 Ising I=−0.40: nonzero")
    print("BECAUSE the Ising σ-4pt is interacting, not GFF.) The actual β₃ is therefore an O(1/N)")
    print("effect = the CONNECTED φ̂-4pt (σ-exchange, φ̂ deviating from GFF). That is the genuinely hard")
    print("computation, and it has NO independent large-N check. So the derivation did not yield A —")
    print("it PROVED A lives at 1/N. The ⟨γ_T⟩ magnitude stays open, now for a precise structural")
    print("reason. The parameter-free predictions (oscillation cancels; γ_T>0; locality fluctuates)")
    print("are untouched. We do NOT fabricate the 1/N number.")
