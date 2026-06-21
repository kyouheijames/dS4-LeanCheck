# PLAN.md — Part 2 (algebra/CAS) and Part 3 (SDPB), previewed

Part 1 (this package) outputs, per passing candidate: `(d, s, Δ, scheme, γ_T_free, local?)`,
with the non-local (s ≠ 1) ones queued in `runs/worth_investigating/`. Those are the
inputs to Part 2.

## Part 2 — the algebra framework (CAS: sympy / Mathematica)

Goal: turn each queued candidate's `s` into the **interacting** anomalous dimension
γ_T(s) and the field anomalous dimension, so "non-local" stops being a free-level label.

Pipeline (to be built when you reach it):
1. Long-range Gaussian propagator `G(p) = |p|^{-2s}` ⇒ position-space `~ |x|^{-(d-2s)}`.
2. Critical interaction `(Ω χχ)²`; large-N (Sp(N)) Hubbard–Stratonovich → σ field.
3. Compute the σ self-energy and the `T` two-point function at leading 1/N.
4. Extract γ_T(s) from the deviation Δ_T(s) − d. Cross-check the s→1 limit against
   the known short-range (local) result as a hard test.
5. Emit γ_T(s) as a series/number → feed back into Lean as CERTIFIED DATA (a new
   field on `Candidate`) with its consistency relations re-checked there.

Deliverable handshake: a JSON `{s, gamma_T_interacting, gamma_phi, N_order}` per
candidate that both the CAS and a future Lean lemma can read.

## Part 3 — SDPB (the actual test of the conjecture)

This is where "does locality-fluctuation stay consistent" is decided. Detailed
step-by-step comes when you're here; the shape:

1. **Set up the shadow/dS crossing equation** for a principal-series external
   operator (Hogervorst–Penedones–Vaziri harmonic analysis, not standard RP crossing).
2. **Discretize** into an SDP: spectrum on Re Δ = d/2 + the discrete/complementary
   contributions; positivity replaced by the **shadow-paired** condition.
3. **Single-candidate run:** feed one queued `s` (its γ_T from Part 2) as a gap
   assumption; ask SDPB whether a consistent shadow-positive solution exists.
4. **The conjecture test:** replace fixed `s` by an annealed distribution over `s`
   (your fluctuating-locality measure) and ask whether the *averaged* crossing system
   still admits a shadow-positive solution. A yes = locality-as-observable is a
   consistent theory; a no = it is a metaphor.
5. **Cleanest arena first:** do all of this in **dS₃ / 2d** (Virasoro-rigid, c and
   γ_T tightly constrained) before attempting d = 3.

You'll get the exact SDPB input-file recipe, normalization, and run commands at Part 3.
