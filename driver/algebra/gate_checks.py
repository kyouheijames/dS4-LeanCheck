"""gate_checks.py — validation gates for any candidate double-twist anomalous dimension.

This is HONEST INFRASTRUCTURE: it asserts no physics. It takes a candidate closed form for the
broken-current anomalous dimension γ_{0,ℓ}(s,d) (the σ-exchange shift of [χχ]_{0,ℓ}; C_T is its
value at ℓ=2) and checks it against the physical limits any correct answer must satisfy. A
candidate that passes ALL gates is a strong candidate PENDING LITERATURE confirmation; one that
fails any gate is rejected. This is how we use a formula we cannot independently verify without
falling into the Ric-trap.

The gates:
  G1  free higher-spin symmetry / conservation at s=1: at s=1 the theory is the LOCAL free
      scalar, which has an exact higher-spin symmetry — ALL γ_{0,ℓ} vanish. So γ_{0,ℓ}(1,d)=0.
      (For ℓ=2 this is the stress-tensor conservation rail.)
  G2  large-spin decay (Komargodski–Zhiboedov): γ_{0,ℓ} → 0 as ℓ → ∞ (double-twists return to
      mean-field). A single leading-twist exchange of dim Δσ gives a 1/ℓ^{Δσ} falloff.
  G3  reality: γ_{0,ℓ}(s,d) is real for real s,d in range (the anomalous dimension of a real
      operator). Checked numerically at sample points.
  G4  non-unitarity sign: for s>1 the spin-2 dimension Δ_T = d - 2(s-1) < d drops below the
      spin-2 unitarity bound — allowed ONLY because the boundary is non-unitary. We report the
      sign of γ_T(s>1); it should be negative, consistent with the Krein/ghost structure.
"""

from __future__ import annotations

import sys
import sympy as sp

try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

s, d, ell = sp.symbols("s d ell", positive=True)


def gate_G1_conservation(gamma, dim_val=None):
    """γ_{0,ℓ}(s=1) = 0 (free higher-spin symmetry). Symbolic in d, ℓ unless dim_val given."""
    expr = gamma.subs(s, 1)
    if dim_val is not None:
        expr = expr.subs(d, dim_val)
    val = sp.simplify(expr)
    return bool(val == 0), val


def gate_G2_largespin(gamma):
    """lim_{ℓ→∞} γ_{0,ℓ} = 0 (Komargodski–Zhiboedov)."""
    try:
        lim = sp.limit(gamma, ell, sp.oo)
    except Exception as e:  # pragma: no cover
        return None, f"limit failed: {e}"
    return bool(sp.simplify(lim) == 0), sp.simplify(lim)


def gate_G3_reality(gamma, samples=((sp.Rational(7, 5), 3, 2), (sp.Rational(6, 5), 3, 4))):
    """γ real at sample (s,d,ℓ). Returns (all_real, per-sample values)."""
    vals = []
    ok = True
    for sv, dv, lv in samples:
        v = sp.N(gamma.subs({s: sv, d: dv, ell: lv}))
        if v.free_symbols:                      # leftover parameters: can't decide reality
            ok = None
            vals.append((float(sv), float(dv), float(lv), str(v), "indeterminate"))
            continue
        is_real = abs(sp.im(v)) < 1e-12
        ok = ok and bool(is_real)
        vals.append((float(sv), float(dv), float(lv), complex(v), bool(is_real)))
    return ok, vals


def gate_G4_nonunitary_sign(gamma, s_val=sp.Rational(7, 5), dim_val=3):
    """Sign of γ at ℓ=2 for s>1; expected < 0 (Δ_T below the bound — non-unitary-consistent)."""
    v = sp.N(gamma.subs({s: s_val, d: dim_val, ell: 2}))
    if v.free_symbols:
        return None, str(v)
    re = float(sp.re(v))
    return (re < 0), re


def run_all_gates(gamma, dim_val=3):
    """Run every gate on a candidate γ_{0,ℓ}(s,d). Returns a report dict; prints a summary."""
    g1_ok, g1 = gate_G1_conservation(gamma)
    g2_ok, g2 = gate_G2_largespin(gamma)
    g3_ok, g3 = gate_G3_reality(gamma)
    g4_ok, g4 = gate_G4_nonunitary_sign(gamma)
    report = {
        "G1_conservation(s=1)=0": (g1_ok, str(g1)),
        "G2_largespin->0": (g2_ok, str(g2)),
        "G3_reality": (g3_ok, g3),
        "G4_nonunitary_sign(<0 for s>1)": (g4_ok, g4),
        "all_pass": bool(g1_ok and g2_ok and g3_ok and g4_ok),
    }
    print("  G1 conservation  γ(s=1)=0 :", "PASS" if g1_ok else "FAIL", " value:", g1)
    print("  G2 large-spin    γ(ℓ→∞)=0:", "PASS" if g2_ok else "FAIL", " value:", g2)
    print("  G3 reality                :", "PASS" if g3_ok else "FAIL")
    print("  G4 sign(<0, s>1)          :", "PASS" if g4_ok else "FAIL", " Re γ_T(1.4):", g4)
    print("  => ALL GATES:", "PASS (candidate, pending literature)" if report["all_pass"]
          else "FAIL (rejected)")
    return report


if __name__ == "__main__":
    print("=== validation-gate harness — demo on a TOY candidate ===")
    print("toy γ_{0,ℓ} = -(s-1) / ℓ^(2s)  (vanishes at s=1, decays at large ℓ):\n")
    toy = -(s - 1) / ell ** (2 * s)
    run_all_gates(toy)
    print("\n(The harness asserts no physics — it only checks the limits a real γ must satisfy.)")
