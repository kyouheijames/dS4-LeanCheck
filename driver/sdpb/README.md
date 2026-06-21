# Part 3 — the SDPB handoff (the actual test of the conjecture)

This directory is **not** a solver. It is the structural object that states the semidefinite
program whose feasibility decides the conjecture:

> Does the **s-averaged** shadow-bootstrap crossing system admit a shadow-positive solution?

A *yes* means locality-as-a-fluctuating-observable is a consistent theory; a *no* means it is a
metaphor. No type-checker and no CAS can answer this — only SDPB, with conformal blocks.

## The handoff chain

```
Lean ModelP.expectedGammaT  ──(s-distribution, ⟨γ_T⟩)──┐
Part 2 driver/algebra       ──(per-s d, Δ, γ_T(s))─────┤
                                                        ▼
                              part3_shadow_crossing.py  (assembles the SDP)
                                                        │  emit_sdpb_problem_skeleton()
                                                        ▼
                              SDPB + conformal-blocks provider  →  feasible? (the answer)
```

## What is here vs. what you must supply

| Piece | Status |
|-------|--------|
| Input contract (`PerSData`, `ShadowCrossingProblem`) matching Lean + Part 2 output | ✅ here |
| Annealed external dimension `⟨Δ⟩ = Σ wᵢ Δᵢ`, readiness checks | ✅ here |
| SDPB problem skeleton emitter (objective + constraint shape) | ✅ here (structure only) |
| **Shadow conformal blocks** (principal-series external op, shadow-paired) | ❌ external input — `scalar_blocks` / `blocks_3d` / PyCFTBoot. Raises `NotImplementedError`; never faked. |
| **Interacting γ_T(s)** per branch | ❌ from Part 2 (`driver/algebra`); `None` until evaluated |
| **The feasibility decision** | ❌ SDPB only |

## Why it is structured this way (honesty discipline)

Mirrors `../algebra/README.md` and `../../working/STATUS.md`: the parts that are real
bookkeeping are implemented; the parts that are genuine physics input (the shadow blocks) or a
genuine numerical decision (SDPB feasibility) are left as explicit, un-fakeable gaps. Running
`python part3_shadow_crossing.py` prints the assembled problem and reports `ready_to_run: false`
with the exact list of what is still missing — no silent gaps.

## Run

```bash
python driver/sdpb/part3_shadow_crossing.py    # prints the SDP skeleton + what's blocking it
```
