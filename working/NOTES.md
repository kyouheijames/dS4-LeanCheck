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

1. **Interacting `γ_T(s)`** — CAS, not Lean. Scaffold in `driver/algebra/`; `C_T(s,d)` left
   SYMBOLIC. Needs the real large-N / ε computation, then fed back as certified data. Do NOT
   fabricate a coefficient.
2. **s-averaging stays shadow-positive** — SDPB, not Lean. Handoff scaffold in `driver/sdpb/`.
   `ModelP.expectedGammaT` states `⟨γ_T⟩=∫`; only the bootstrap can decide it. The actual test
   of the conjecture.
3. **Cosmology amplitude** — `PrincipalSpectrum` fixes the scaling *structure* (tilt=2ε,
   oscillation freq μ). The overall amplitude `A_s` and the oscillation size `~e^{−πμ}` need the
   late-time wavefunction / cosmological-bootstrap calc. The `n_s=4−2s, s≈1.52, Axis-of-Evil`
   claims from the dS-XFT pitch are unverified / postdictions — see `STATUS.md §D`.
4. **Parent SSB theory skeleton** — promote Ω to a dynamical field with `V(Ω)` whose vacuum
   manifold is the symplectic orbit `GL(N)/Sp(N)`; Goldstones = the coset. `SymmetryBreaking`
   has the covariance + orbit facts; the dynamical-Ω structure + Goldstone counting is not built.
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
