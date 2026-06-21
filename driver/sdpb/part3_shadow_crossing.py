"""part3_shadow_crossing.py — Part 3 HANDOFF scaffold (the SDPB problem statement).

This is NOT a solver and does NOT decide the conjecture. It is the structural object that
takes the Lean-side data — the s-distribution from `ModelP.FluctuatingLocalityP` and the
per-s data `(d, Δ, γ_T)` from Part 2 — and assembles the **shadow-crossing semidefinite
program** whose feasibility is the actual test:

    Does the s-AVERAGED shadow-bootstrap crossing system admit a shadow-positive solution?

A "yes" = locality-as-fluctuating-observable is a consistent theory; a "no" = it is a metaphor.
Only SDPB (plus a conformal-blocks provider) can answer it; this file pins down WHAT to hand it.

Honesty (same discipline as ../../working/STATUS.md and ../algebra/README.md):
  • The crossing functional's matrix elements are conformal blocks for a PRINCIPAL-series
    external operator in the shadow (Hogervorst–Penedones–Vaziri) harmonic analysis — NOT
    ordinary reflection-positive blocks. Computing them needs a blocks library
    (scalar_blocks / blocks_3d / PyCFTBoot-style), which is the required external input.
    They are left as an explicit `NotImplementedError`, never faked.
  • The "annealed" step replaces a single external dimension by an AVERAGE over the
    s-distribution; the question is whether ONE positive functional works for the average.
"""

from __future__ import annotations

from dataclasses import dataclass, field
import json


# --- Input contract: exactly what Lean / Part 2 produce -----------------------------------

@dataclass
class PerSData:
    """One realised kinetic exponent and its certified data (Part 1 + Part 2)."""
    s: float
    d: float
    delta_ext: complex          # external principal-series weight Δ = d/2 + iμ
    gamma_T: float | None       # interacting γ_T(s) from Part 2 (None ⇒ not yet evaluated)
    weight: float               # probability of this s under the fluctuation law (sDist)


@dataclass
class ShadowCrossingProblem:
    """The annealed shadow-bootstrap SDP, assembled but unsolved."""
    d: float
    branches: list[PerSData]
    # spectrum assumption: gaps / which sectors are shadow-paired. Filled by the user.
    spectrum: dict = field(default_factory=dict)

    def total_weight(self) -> float:
        return sum(b.weight for b in self.branches)

    def mean_delta_ext(self) -> complex:
        """Annealed external dimension ⟨Δ⟩ = Σ wᵢ Δᵢ — the operator whose crossing is tested.
        (Re part stays d/2 on the principal line; only the μ = Im Δ averages.)"""
        w = self.total_weight()
        if w == 0:
            raise ValueError("empty distribution")
        return sum(b.weight * b.delta_ext for b in self.branches) / w

    def is_ready_for_sdpb(self) -> tuple[bool, list[str]]:
        """A run is only meaningful once every branch has its Part-2 γ_T evaluated and the
        distribution is normalised. Reports what is still missing — no silent gaps."""
        missing = []
        if abs(self.total_weight() - 1.0) > 1e-9:
            missing.append(f"distribution not normalised (Σw = {self.total_weight()})")
        for b in self.branches:
            if b.gamma_T is None:
                missing.append(f"branch s={b.s}: γ_T not evaluated (Part 2 incomplete)")
        return (len(missing) == 0, missing)


def shadow_crossing_matrix_element(d: float, delta_ext: complex,
                                   delta_exchange: complex, spin: int) -> float:
    """Matrix element of the SHADOW crossing equation (the SDP's positivity constraint).

    This is the one genuinely external piece: a conformal block for a principal-series
    external operator, paired by the shadow map Δ ↦ d−Δ rather than by reflection positivity.
    It must come from a conformal-blocks provider. We refuse to fabricate it.
    """
    raise NotImplementedError(
        "Shadow conformal block required: supply via a blocks library "
        "(scalar_blocks / blocks_3d / PyCFTBoot). This is the external input Part 3 needs; "
        "it is deliberately not faked. See README.md."
    )


def emit_sdpb_problem_skeleton(prob: ShadowCrossingProblem) -> dict:
    """Emit the SDPB problem STRUCTURE (objective + constraint shape) as JSON, with the block
    data left as a marked TODO. This is the file you hand to the bootstrap stack — not a result."""
    ready, missing = prob.is_ready_for_sdpb()
    return {
        "problem": "annealed_shadow_crossing_feasibility",
        "d": prob.d,
        "external_dimension_mean": str(prob.mean_delta_ext()),
        "n_branches": len(prob.branches),
        "spectrum_assumption": prob.spectrum,
        "objective": "feasibility (does a shadow-positive functional exist for the average?)",
        "constraints": "TODO: shadow conformal blocks per (Δ_exchange, spin) — external input",
        "ready_to_run": ready,
        "blocking": missing,
        "decided_by": "SDPB — NOT this scaffold",
    }


if __name__ == "__main__":
    # A toy two-branch instance mirroring Model.lean: mostly local (s=1), occasionally s=1.4.
    # γ_T values are placeholders (None) until Part 2 evaluates C_T — surfaced honestly below.
    prob = ShadowCrossingProblem(
        d=3.0,
        branches=[
            PerSData(s=1.0, d=3.0, delta_ext=complex(1.5, 1.0), gamma_T=0.0, weight=0.9),
            PerSData(s=1.4, d=3.0, delta_ext=complex(1.5, 1.3), gamma_T=None, weight=0.1),
        ],
        spectrum={"external": "principal series Re Δ = d/2", "pairing": "shadow Δ ↦ d−Δ"},
    )
    print("mean external Delta:", prob.mean_delta_ext())
    print(json.dumps(emit_sdpb_problem_skeleton(prob), indent=2))
    print("\n(ready_to_run is False until Part 2 supplies gamma_T and SDPB supplies the blocks.)")
