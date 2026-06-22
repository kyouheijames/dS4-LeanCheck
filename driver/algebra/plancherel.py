"""plancherel.py — ⟨γ_T⟩ under the principal-series Plancherel measure (the user's chosen measure).

Framework (PrincipalSpectrum.lean): principal series Δ=d/2+iμ; ε=ReΔ−d/2 is the locality breaking
(↔γ_T); μ=ImΔ is the oscillation frequency; n_s−1=2ε. A principal-series σ has Δσ=2s=d/2+iμ, so
  s = d/4 + iμ/2.
Averaging γ_T over the dS-natural measure ⇒ continue γ_T(s) onto the principal line and integrate
against the Plancherel density.

Plancherel measure for the scalar principal series of SO(d+1,1) (=|c(μ)|^−2, Harish-Chandra):
  ρ(μ) ∝ |Γ(d/2+iμ)|² / |Γ(iμ)|².  For d=3 this reduces to  ρ(μ) = μ(μ²+1/4)tanh(πμ)  — EVEN in μ.

KEY (robust) STRUCTURE: γ_T(s) is real-analytic, so γ_T(d/4−iμ/2)=conj γ_T(d/4+iμ/2):
  Re γ_T is EVEN in μ, Im γ_T is ODD in μ. Since ρ is EVEN:
   • the IMAGINARY part of γ_T (the cosmological-collider OSCILLATION) CANCELS in the average;
   • the REAL part survives ⇒ ⟨γ_T⟩ is REAL.
Using the bump form γ_T(s) ≈ A(s−d/4)(s*−s) (zero at both window ends, A>0), the continuation gives
  γ_T(d/4+iμ/2) = A[ μ²/4 + i (W μ/2) ],  W=s*−d/4  ⇒  Re γ_T = A μ²/4 (>0),  Im γ_T = A W μ/2 (odd).
Hence  ⟨γ_T⟩ = (A/4)·⟨μ²⟩_ρ  > 0,  with ⟨μ²⟩ a regulated Plancherel moment.

HONEST GAPS (no fabricated number): (i) A = the large-N bump amplitude (needs the large-N γ_T, not
in hand); (ii) the continuation uses the near-edge parabola; (iii) ⟨μ²⟩ needs a regulator — the
physical one is the late-time-wavefunction Boltzmann factor e^{−πμ} (PrincipalSpectrum scope note).
We report the ROBUST structure + the regulator-dependence, not a single fake number.
"""

from __future__ import annotations
import sys
import mpmath as mp

mp.mp.dps = 25
try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass


def rho_d3(mu):
    """d=3 scalar principal-series Plancherel density (even in μ)."""
    return mu * (mu ** 2 + mp.mpf(1) / 4) * mp.tanh(mp.pi * mu)


def moment(n, reg):
    """⟨μ^n⟩ over ρ(μ) with regulator reg(μ) (μ≥0, ρ even ⇒ integrate [0,∞) and normalize)."""
    num = mp.quad(lambda mu: mu ** n * rho_d3(mu) * reg(mu), [0, 1, 5, mp.inf])
    den = mp.quad(lambda mu: rho_d3(mu) * reg(mu), [0, 1, 5, mp.inf])
    return num / den


if __name__ == "__main__":
    print("=== Principal-series Plancherel average of γ_T (d=3) ===\n")
    print("Plancherel density ρ(μ) = μ(μ²+1/4)tanh(πμ)  [d=3, SO(4,1), even in μ].\n")

    # (1) Robust parity result: the odd part (oscillation) cancels.
    W = mp.mpf('0.25')   # window width s*-d/4 = 1 - 0.75 (illustrative)
    reg = lambda mu: mp.e ** (-mp.pi * mu)         # Boltzmann e^{-πμ} (physical regulator)
    odd_integral = mp.quad(lambda mu: (W * mu / 2) * rho_d3(mu) * reg(mu) * 0, [0, mp.inf])
    # the odd part over the FULL line (-∞,∞) is identically 0 by parity; demonstrate on the moment:
    m1 = moment(1, reg)   # ⟨μ⟩ over [0,∞)≠0, but over (-∞,∞) the odd integrand cancels:
    print("PARITY (robust): ρ even ⇒ ∫_{-∞}^{∞} (odd-in-μ)·ρ = 0.")
    print("  ⇒ the IMAGINARY part of γ_T (the log-oscillation / cosmological collider) AVERAGES TO 0.")
    print("  ⇒ ⟨γ_T⟩ is REAL. The dS-natural average ERASES the oscillation, keeps the even part.\n")

    # (2) The surviving even part ⇒ ⟨γ_T⟩ = (A/4)⟨μ²⟩. Show ⟨μ²⟩ for several regulators.
    print("Surviving: ⟨γ_T⟩ = (A/4)·⟨μ²⟩  (A = large-N bump amplitude, NOT in hand). ⟨μ²⟩ by regulator:")
    regs = {
        "Boltzmann e^{-πμ}":   lambda mu: mp.e ** (-mp.pi * mu),
        "Boltzmann e^{-2πμ}":  lambda mu: mp.e ** (-2 * mp.pi * mu),
        "Gaussian e^{-μ²}":    lambda mu: mp.e ** (-mu ** 2),
    }
    for name, r in regs.items():
        print(f"   ⟨μ²⟩  [{name:18s}] = {mp.nstr(moment(2, r), 6)}")

    print("\n--- HONEST READING ---")
    print("ROBUST (no free inputs): the Plancherel (even) measure cancels the ODD part of γ_T, so the")
    print("dS-natural average kills the cosmological-collider OSCILLATION and leaves ⟨γ_T⟩ REAL.")
    print("With the bump form, the surviving even part is POSITIVE ⇒ ⟨γ_T⟩ = (A/4)⟨μ²⟩ > 0: the")
    print("averaged theory is NON-local, magnitude set by the dS mass spread ⟨μ²⟩.")
    print("GAPS (flagged, not faked): A needs the large-N γ_T; ⟨μ²⟩ is regulator-dependent (factor ~few")
    print("across reasonable choices above); the continuation uses the near-edge parabola. So NO single")
    print("number is claimed — the robust content is: oscillation cancels, mean real & positive ∝⟨μ²⟩.")
