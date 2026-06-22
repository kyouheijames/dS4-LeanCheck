# NOTES — current state & what's open (latest agent note)

`working/` holds **work-in-progress only**. Anything finished lives in `Ds4Verification/`
(compiling source) and is logged in `STATUS.md`. This file = where we are + what's next.

## Done and compiling (in `Ds4Verification/`, no `sorry`)

The whole Lean-certifiable layer of the program is built and type-checks:

| Module | What it certifies |
|--------|-------------------|
| `LongRange`, `FreeSector` | free-sector dimension `Δ=(d−2s)/2` DERIVED from propagator homogeneity; **full conformal group** on the free 2-pt function (translations, rotations, dilations, inversions) |
| `Locality`, `StressTensor` | locality rail: `γ_T=0 ⟺ conserved local stress tensor ⟺ s=1` |
| `ShadowPairing`, `CPTLocality` | CPT = shadow pairing; **CPT-break = locality-break = non-conservation**, one shared `ε`; non-contradiction proved (`locality_cpt_equiv`) |
| `Model`, `ModelP`, `LocalityObservable` | locality as a fluctuating observable: two-point law, general `PMF` (`⟨γ_T⟩=∫`), and a genuine self-adjoint **operator** with spectrum + `⟨v|L|v⟩` |
| `Conditions`, `CandidateExample`, `CandidateReal` | the WorthInvestigating filter + a non-vacuous worked candidate (real Krein ghost, mass-derived principal weight) |
| `Lagrangian`, `LagrangianDuality` | the action as an object, carrying a PROVED non-unitary boundary `G=iΩ`; instantiates the forced-nonUnitary / unitary-horizon toggle for the model itself |
| `SymmetryBreaking` | **Ω is an order parameter, not a background**: `sp_covariant` (Ω transforms as a tensor), `GL(N)→Sp(N)` SSB (dilation moves Ω, shear fixes it) |
| `PowerCounting` | engineering dims: `[g]=4s−d`, super-renormalizable ⇔ `s>d/4` (power counting only) |
| `PrincipalSpectrum` | principal-series CMB scaling: scale-invariant base + log-oscillation `μ=Im Δ`; **`n_s−1=2ε`** (tilt = the breaking) |

Honest ledger of proved / convention / out-of-scope: see `STATUS.md` (incl. §D, the cosmology triage).

## Open / NOT done (the genuinely hard parts, correctly isolated)

1. **Interacting `γ_T(s)`** — CAS, not Lean. Progress: exact sector (`large_n_selfenergy.py`);
   spin-2 inversion setup (`cT_spin2.py`); **validation-gate harness** (`gate_checks.py`,
   working); and the **large-spin crack** (`cT_largespin.py`): the would-be T = double-twist
   `[χχ]_{0,2}`, its σ-exchange γ has rigorous falloff `1/ℓ^{2s}` and exact kinematic coefficient
   `γ_kin(s,d)`. Gating it pinned the one remaining unknown: the χχσ OPE factor `A(s,d)` (∝1/N),
   which G1 forces to satisfy `A(1,d)=0` (free higher-spin symmetry).
   **`A(s,d)` ASSEMBLED** (`cT_assemble.py`): the χχσ vertex is conformally unique
   (`2Δχ+Δσ=d`), so `A=κ/N·C_χ²·C_σ·V_st²` from the exact star-triangle + induced-σ data.
   Result: `A(s=1,d) ∝ sin(πd/2)` — vanishes at EVEN d but NOT at d=3 (`A(1,3)=2/π²`). Gated, the
   full candidate is **REJECTED** (G1, G4 fail at d=3). **Honest diagnosis:** the leading
   large-spin form `γ_kin/ℓ^{2s}` at ℓ=2 cannot reproduce the s=1 free-HS cancellation in odd d —
   that is a finite-spin (6j) effect. So `C_T=γ_{0,2}` needs the full **6j / inversion residue at
   ℓ=2** (+ literature κ), not the large-spin shortcut. Frontier now precisely located; ingredients
   (`γ_kin`, `A`) and the gate harness are in place. We did NOT force-fit A. No coefficient faked.
   (Also fixed: the `freeStressTensor` sign — physical `Δ_T=2Δχ+2=d−2(s-1)`, free `γ_T=2(1−s)`,
   below the bound for s>1, consistent with non-unitarity.)
   **Final step** (`cT_6j.py`): exact ℓ=2 residue = `(OPE)²×[6j]_{n=0,ℓ=2}`, inputs `(Δχ,Δσ=2s)`;
   σ is the SHADOW of `[χχ]_{0,0}` (vertex uniqueness) ⇒ Lang–Ruhl-solvable. **Principled stop:** the
   LPRS 6j closed form is NOT reproduced from memory (a wrong-but-plausible `₄F₃` could pass gates =
   Ric-trap). `gate_candidate(...)` validates any VERIFIED closed form the instant it is supplied
   (refs: LPRS 2018, Cardona–Sen 2018, Caron-Huot 2017, Lang–Ruhl). The one irreducible look-up /
   focused-calc step — deliberately not faked.
2. **s-averaging stays shadow-positive** — SDPB, not Lean. Handoff scaffold in `driver/sdpb/`.
   `ModelP.expectedGammaT` states `⟨γ_T⟩=∫`; only the bootstrap can decide it. The actual test
   of the conjecture.
3. **Cosmology amplitude** — `PrincipalSpectrum` fixes the scaling *structure* (tilt=2ε,
   oscillation freq μ). The overall amplitude `A_s` and the oscillation size `~e^{−πμ}` need the
   late-time wavefunction / cosmological-bootstrap calc. The `n_s=4−2s, s≈1.52, Axis-of-Evil`
   claims from the dS-XFT pitch are unverified / postdictions — see `STATUS.md §D`.
4. ~~Parent SSB theory skeleton~~ — **DONE** (`ParentTheory.lean` + `ParentAction.lean`):
   vacuum manifold + action-preserves-it + Sp submonoid + EXACT Goldstone structure for N=2;
   AND the dynamical-Ω potential `V(Ω)` with `V=0 ⟺` symplectic vacuum, `OmegaMin` a global
   minimum, `canonicalParent` bundling the action. Remaining (optional): Ω kinetic term as a
   field-theory term, Goldstone counting for general even N, V's full GL-orbit structure.
5. **Loop integration** — `agent_loop_patch.md` + `candidate_schema.md` describe wiring the
   WorthInvestigating filter into `driver/agent_loop.py`. Not applied to the driver yet.

## Latest note (this session)

- Resolved the principal-vs-complementary tension the dS-XFT pitch introduced: the consistent
  cosmology is the **principal-series** one (`PrincipalSpectrum`) — `n_s≈1` is automatic from
  `Re Δ=d/2`, the red tilt is `2ε` (our locality-breaking order parameter), and the genuine
  prediction is a log-periodic (cosmological-collider) oscillation of frequency `μ=Im Δ`. This is
  framework-consistent; the `s≈1.52` power-law story is not.
- Triaged the whole dS-XFT pitch into `STATUS.md §D`: dimensional analysis ✅, cosmological
  numbers ❌ (unverified), and two claims ("unitary/healthy", real-Δ cosmology) that directly
  contradict the proved forced-non-unitarity / principal-series structure.

## Suggested next step

Either (a) build the **parent SSB theory** skeleton (dynamical Ω + `GL(N)/Sp(N)` vacuum +
Goldstone coset) — cheap, Lean-native, deepens the background-independence answer; or (b) start
the **Part-2 `C_T` computation** in `driver/algebra/` for real (large-N conformal integrals),
accepting it's a genuine research calc. (a) is the lower-risk, higher-certainty increment.
