# agent_loop.py — patch for the WorthInvestigating filter

Three focused changes to your existing loop. Nothing else changes.

## 1. System-prompt block (append to the generator prompt)

```python
WORTH_PROMPT = r"""
You are generating ONE Lean 4 module `Ds4Verification.Generated` describing the
ALGEBRAIC FINGERPRINT of a candidate dS/CFT* boundary Lagrangian — NOT bulk geometry.

It must compile against Mathlib with NO `sorry`, and must produce a term
`genCandidate_worth : WorthInvestigating genCandidate`.

Rules:
- d = 3 (boundary S^3 of dS_4).
- Choose a kinetic exponent s. Prefer s ≠ 1 (non-local; the research target).
- Choose Δ on the principal series: Re Δ = d/2 = 3/2, Im Δ ≠ 0.
- scheme = HolographyScheme.globalBoundary.
- Discharge IsPrincipal with `norm_num`; get WorthInvestigating from
  `worth_of_principal`. C2 (shadow/CPT) is derived for you — do not re-prove it.
Follow driver/candidate_schema.md exactly.
"""
```

## 2. Success check (replace your pass/fail predicate)

```python
import re, pathlib

def check_worth(build_ok: bool, lean_src: str) -> bool:
    """A run passes iff it compiles, has no sorry, and asserts the filter term."""
    if not build_ok:
        return False
    if "sorry" in lean_src:
        return False
    # the WorthInvestigating term must be present (the gate)
    return re.search(r"WorthInvestigating\s+genCandidate", lean_src) is not None
```

## 3. Locality verdict + ranking (run on every pass)

Lean keeps γ_T over ℝ (non-computable) for the *proofs*; the driver does the
trivial arithmetic for the *report*, so we never need `#eval` on reals.

```python
def locality_verdict(lean_src: str):
    m = re.search(r"\bs\s*:=\s*([0-9]*\.?[0-9]+)", lean_src)
    if not m:
        return None
    s = float(m.group(1))
    gamma_T = 2.0 * (s - 1.0)
    return {"s": s, "gamma_T": gamma_T, "local": abs(gamma_T) < 1e-12,
            "worth_investigating": abs(gamma_T) >= 1e-12}

# in the loop, after a pass:
v = locality_verdict(lean_src)
if v and v["worth_investigating"]:
    out = pathlib.Path("runs/worth_investigating"); out.mkdir(parents=True, exist_ok=True)
    (out / f"candidate_s{v['s']}.lean").write_text(lean_src)
    print(f"[WORTH] s={v['s']}  γ_T={v['gamma_T']:+.4f}  → non-local, queued for Part 2")
else:
    print(f"[ok] consistent but local (s=1) — recorded, deprioritized")
```

## Negative controls (keep the filter non-vacuous, mirroring your Λ<0 control)

Add these as expected-FAIL fixtures:
- `Im Δ = 0` (real weight) → C1 fails → must be rejected.
- `Re Δ ≠ 3/2` → C1 fails → rejected.
- `scheme = staticPatchHorizon` → C3 fails → rejected (boundary-Lagrangian
  filter only types in the global scheme).
