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
   **UPDATE — a gate-passing candidate now exists** (`cT_cardona_sen.py`): a Cardona–Sen closed
   form was supplied (paste, UNVERIFIED). Implemented faithfully (the `W` core is a terminating
   ₃F₂, 3-term sum cross-checked vs `hyperexpand`), assembled with our `C²_{χχσ}` and exact dims.
   **Gate verdict:** in **d=3 (our case) it passes every applicable gate** — G1 `lim_{s→1}γ=0`
   (RIGOROUS; the large-spin form failed this), G3 reality, G4 sign(<0). In d=4 it passes G1,G3
   and fails the HEURISTIC G4 (sign >0 — a d-dependent prediction, not a disqualifier). Concrete
   output (up to κ/N): `γ(0,2)(s=1.4, d=3) ≈ −4.0e-4·κ/N`.
   **LITERATURE CROSS-CHECK (arXiv:1806.10919 TeX in `papers/`) — the pasted ₃F₂ is REFUTED.** It
   does NOT match Cardona–Sen (paper = ₄F₃ in conformal spin β, prefactor Γ(Δ)/Γ(Δ/2)²; no "−ℓ"
   termination). It passed the d=3 gates anyway = a textbook FALSE POSITIVE — gates necessary, not
   sufficient; the discipline of not calling gate-pass "verified" is vindicated.
   **GENUINE RESULT (`cT_real_4d.py`):** implemented the paper's complete d=4 formula (eq. 3.30 +
   Liu et al. Ω, via Ω's defining INTEGRAL to dodge the divergent ₄F₃(1) series). In d=4 it passes
   EVERY gate: G1 `C_T→0` as `s→1` quadratically (`≈ −0.666·(s−1)²`, the Maldacena–Zhiboedov
   `γ∝(breaking)²` form), G3 reality, G4 sign (`C_T<0`, OPPOSITE the pasted formula → independent
   refutation). Concrete: `C_T(1.4, d=4) = −0.0219/N`. A literature-correct, gate-passing C_T — but
   in **d=4 (dS₅), not physical d=3**. d=3 lacks closed-form blocks ⇒ needs the paper's general-d
   Mellin treatment (Sec. 4) incl. the finite-β poles the authors neglect — the real d=3 frontier.
   **d=3 Mellin attempt (`cT_mellin.py`, eq. 4.18, s=n poles only):** evaluated — and it DEMONSTRATES
   the incompleteness rather than yielding a number. In d=3 it carries a spurious singularity across
   s=1 (`+0.27`@0.95, `−0.99`@1.05 — NO conservation, G1 fails); in d=4 it disagrees with the complete
   eq.(3.30) by the neglected poles (`s=1.2`: `+0.015` vs correct `−0.0215`, even wrong sign). So the
   **physical d=3 `C_T` is NOT given by the paper's closed forms** — it requires the general-d
   completion (poles `s=(β−Δ+J−τ)/2−1+n`) the authors assembled only for d=4. That extension is the
   genuine open frontier — rigorously located from the actual paper, not faked. Net: verified
   gate-passing `C_T(s,d=4)`; physical d=3 precisely characterized as open (needs the d=3 completion).
   **d=3 completion ATTEMPTED (`cT_mellin_complete.py`):** summed the residues of the full Mellin-
   Barnes integrand (eq. 4.16) over BOTH pole sets (s=n AND the neglected s=P+n), to assemble the
   general-d completion. **GROUND-TRUTH CHECK in d=4 vs exact eq.(3.30): FAILED** — the completion
   returns a COMPLEX value not matching the exact answer. Diagnosis: eq.(4.16)'s `(−1)^s` form is
   valid only at the integer s=n poles; the neglected poles need the proper double-discontinuity
   (sin-factor) treatment at non-integer s (and/or a third pole set from Γ(1−s−Δ/2)) — exactly the
   subtlety the paper resolved ONLY in d=4 via Liu et al. So the d=4 cross-check **REJECTED** my
   completion → NO d=3 number shipped (the discipline working: a wrong completion caught, not
   faked). The general-d completion is genuine open research. The verified d=4 C_T stands as the
   established result.
   **NEW PATH — numerical Lorentzian-inversion engine** (gets d=3 from the *definition*, no pole
   bookkeeping): **Milestone 1 DONE** (`block.py`) — the general-d scalar conformal block via the
   quadratic-Casimir power-series recursion, VALIDATED to ~1e-8 against both d=2 and d=4 closed
   forms; runs in d=3 (no closed form there) on the same validated code. This was the hardest
   piece. **Milestone 2 (next):** build dDisc + the Lorentzian inversion integral, validate it
   reproduces the exact `C_T(s,d=4)=−0.0219/N` (eq. 3.30) using the d=4 block. **Milestone 3:**
   run at d=3, gate. If M2 reproduces d=4, the M3 d=3 number is trustworthy; if not, fix before
   believing it — same discipline (d=4 as the rail at every step).
2. **s-averaging sta     ys shadow-positive** — SDPB, not Lean. Handoff scaffold in `driver/sdpb/`.
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
