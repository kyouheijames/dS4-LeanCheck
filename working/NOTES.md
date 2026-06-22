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
   **Milestone 2 DONE — inversion engine VALIDATED** (`inversion.py`): the direct z̄-integral of
   the leading-z log term IS the COMPLETE inversion (the Mellin s=n eq.4.18 was the incomplete
   one; I'd compared to the wrong target). It equals the exact complete d=4 eq.(3.30) to ~1e-30,
   constant convention factor EXACTLY 2 (7 s-values, spread 5e-11). So `C_T_inversion=(z̄-int)/2`
   is the validated complete generic-scalar-exchange C_T in any d — no block/Mellin bookkeeping.
   **d=3 result + finding:** real, smooth C_T(s), vanishes exactly at the d=3 threshold s=0.75
   (confirms dDisc), BUT FAILS G1 conservation: `C_T(s=1,d=3)=−1/15 ≠ 0`. The validated engine
   thereby EXPOSES that GENERIC σ-exchange ≠ physical stress tensor in d=3 — the **HS-σ shadow/EOM
   structure** (σ = shadow of [χχ]_{0,0}) is required. In d=4 the threshold Δσ=2Δχ⇔s=1 makes
   generic=physical (γ_T→0); in d=3 it doesn't, and the gate exposes it. The HS-σ correction is the
   now-precisely-located final piece (a research sub-computation: the shadow combination /
   inverse-bubble σ-propagator). Gate score: caught a fabrication, a wrong completion, AND a physics
   gap — discipline working 3× over. The validated engine + block are reusable assets.
   **HS-σ attempt → CROSSOVER resolution** (`hs_sigma.py`): (a) the naive shadow exchange Δσ→d−2s
   is EMPTY — its dDisc exponent p_e=(d−2s)/2−Δχ=0, so it contributes exactly 0; the HS-σ fix is
   NOT a shadow sum. (b) The real point: I had the WRONG gate. In a LONG-RANGE model the would-be
   stress tensor conserves at the long-range/short-range CROSSOVER s*=1−η_SR/2, NOT at s=1. s*=1 ⇔
   η_SR=0 ⇔ short-range free ⇔ d=4; in d=3 short-range O(N) is interacting (η₁≠0) so s*<1 and
   γ_T(s=1)≠0 is PHYSICAL, not a failure. Clean prediction: γ_T^phys(1,d)=−η₁(d), η₁(3)=8/(3π²)
   [literature-verified, η₁(4)=0]. d=4 passes trivially (0=0) and EXPLAINS why d=4 conserves at s=1.
   The engine is KINEMATIC (γ_kin(1,3)=−1/15 exact), so this is a SHARP FALSIFIABLE target for the
   OPE coefficient: **C²_χχσ(1,3) = −η₁/γ_kin = 40/π² ≈ 4.053**. NOT closed — needs the independent
   OPE coefficient; definitive reference for THIS theory is **arXiv:2107.08052 "Long-Range Vector
   Models at Large N"**. No physical d=3 number shipped until that check closes. NET: the conservation
   question is now a concrete literature check, not a mystery; discipline held (kinematic solid,
   physical gated on an unverified input).
   **CLOSED by the literature — with a RETRACTION (`lr_vector_paper.py`).** Read the definitive
   reference, **Chai–Goykhman–Sinha arXiv:2107.08052 "Long-Range Vector Models at Large N"** — it
   IS our model. Findings: (CONFIRMED) the long-range fixed point is, in their words, "characterized
   by the LACK of a local stress-energy tensor"; the would-be T is non-conserved (γ_T≠0) in the
   long-range regime and conserved only at the crossover s*=1−η_SR/2 — EXACTLY our "locality is a
   quantum observable that breaks" thesis, now published rigorous physics. γ_φ=0 exactly (matches
   our Lean FreeSector). Their **physical** γ_T (eq. 7.32, conformal perturbation theory):
   γ_T=(2α(d)δ/Γ(d/2))·γ_φ̂, δ=(s*−s)/2 — ∝(s*−s) [vanishes AT the crossover] and ∝γ_φ̂ [=0 when
   short-range is free, i.e. ALL of d=4]. (RETRACTION) our inversion engine computes the GENERIC
   Cardona–Sen scalar-exchange γ, which is NOT this physical γ_T: paper γ_T(d=4)=0 but our engine
   gives −0.666(s−1)²; paper vanishes at s*≈1, ours at the dDisc-zero s=0.75. So the engine's d=4
   "−0.0219" and the d=3 generic values are a correct generic-exchange calc applied to the WRONG
   assembly — not the physical stress-tensor anomalous dimension. The "C²=40/π²" crossover
   prediction (built on the false γ_T=C²·γ_kin) is WITHDRAWN. (VERIFIED datum) the paper's leading
   OPE coefficient eq.(5.3) gives **N·C²_φφσ(s=1,d=3)=4/π²** (≈0.4053) — implemented and matched to
   1e-12. The literature cross-check did exactly its job: it caught a plausible-but-wrong program.
   Net: thesis vindicated by published work; our physical γ_T is eq.(7.32); generic engine kept as
   a validated Cardona–Sen tool but no longer claimed as the physical long-range γ_T.
   **Physical γ_T structure + the locality↔non-unitarity ANCHOR (paper §7).** Physical γ_T (eq.
   7.32): γ_T=(2α(d)δ/Γ(d/2))γ_φ̂, δ=(s*−s)/2 — vanishes at s*, ∝ short-range η. GAP: α(d) is NOT
   in 2107.08052; it comes from ref [11] (Behan–Rastelli–Rychkov–Zan IR duality). So the ABSOLUTE
   near-s* number needs ref [11]; deep-long-range needs the non-perturbative λ*²(s). We do NOT
   fabricate α(d). **KEY finding for the SSB/ghost conjecture:** the paper's dual description makes
   the locality↔non-unitarity link an EQUATION, not an analogy: ∂_μT^μν=λ*∂^ν(φ̂χ) (eq. 7.36, the
   non-conservation is sourced by χ); ⟨χχ⟩=C_χ/|x|^{2Δχ} with C_χ=−2C(s)<0 (eq. 7.13, χ is a
   NEGATIVE-norm / ghost-like field, since C(s)>0); χ↔σφ (eq. 7.17, the dual ghost is the
   shadow/EOM composite). ⇒ locality-breaking (γ_T) is literally mediated by a negative-norm mode —
   a literature-backed physical anchor for the Ω-SSB / Krein-ghost story. (`lr_vector_paper.py`.)
   NEXT decision: (a) fetch ref [11] for α(d) to get the absolute near-s* γ_T number, or (b) build
   the conjecture test on this ghost-χ structure (the more direct route to the SSB↔ghost question).
   **Did BOTH.** (b) `CORRESPONDENCE.md`: tested Ω↔λ*, G=iΩ↔C_χ — Ω↔λ* is WRONG (Ω=Sp(N)
   field-space param that *creates* the ghost; λ*=locality coupling that *activates* it; and the
   O(N) paper has no Ω), G=iΩ↔C_χ<0 is a PARTIAL/structural match (both negative-norm, distinct
   origins). The match that holds: our ε ↔ paper's δ/λ*²/γ_T (locality-breaking strength). Caveat
   logged: the paper is ORTHOGONAL O(N); our Sp(N)/Ω is unvalidated by it. "SSB cures ghost"
   refined to "order parameter switches the ghost coupled↔decoupled across the crossover" (a
   decoupling, not Higgs absorption). (a) α(d): ref [11] gives g*²=δ/β₃ (eq. 2.25) ⇒ **α(d)=1/β₃**,
   with **β₃>0 proved** (real fixed point) ⇒ **γ_T>0** (eq. 7.32) — Δ_T>d, the UNITARY direction;
   locality-breaking is "soft", non-unitarity carried separately by the χ ghost. (Our retracted
   engine gave γ_T<0 — opposite sign, a 2nd confirmation it was the wrong object.) Numbers:
   β₃(d=3)=12.26 ⇒ α(3)=0.0816, β₃(d=2)=1.2684 ⇒ α(2)=0.788 — but these are **N=1 ISING** (3d-Ising
   bootstrap); OUR large-N O(N)/Sp(N) β₃ differs and is in NEITHER paper (needs the large-N σσσσ
   integral). So α(3)=0.0816 is NOT our value — not misreported as such. (`lr_vector_paper.py`.)
2. **s-averaging stays shadow-positive** — SDPB, not Lean. Handoff scaffold in `driver/sdpb/`.
   `ModelP.expectedGammaT` states `⟨γ_T⟩=∫`; only the bootstrap can decide it. The actual test
   of the conjecture.
   **Measure CHOSEN: principal-series Plancherel** (`plancherel.py`). User picked the principled
   (falsifiable, parameter-free) measure over the kinetic exponent. Setup: principal series
   Δσ=2s=d/2+iμ ⇒ s=d/4+iμ/2; average γ_T by continuing it onto the principal line vs the d=3
   Plancherel density ρ(μ)=μ(μ²+1/4)tanh(πμ) [=|c(μ)|⁻², SO(4,1); EVEN in μ]. **ROBUST result** (no
   free inputs): ρ even + γ_T real-analytic ⇒ Im γ_T (the cosmological-collider OSCILLATION) is odd
   ⇒ **cancels**; Re γ_T (even) survives ⇒ **⟨γ_T⟩ is REAL** — the dS-natural average ERASES the
   oscillation. With the bump form γ_T≈A(s−d/4)(s*−s): Re γ_T(d/4+iμ/2)=Aμ²/4>0 ⇒ **⟨γ_T⟩=(A/4)⟨μ²⟩
   > 0** (averaged theory non-local, scale set by the dS mass spread ⟨μ²⟩). GAPS (flagged, not
   faked): A=large-N bump amplitude (needs large-N γ_T); ⟨μ²⟩ regulator-dependent (1.72 / 0.37 /
   1.84 for e^{−πμ} / e^{−2πμ} / e^{−μ²}); continuation uses near-edge parabola. So NO single number
   shipped — robust content = oscillation cancels, mean real & positive ∝⟨μ²⟩. (NB this is the mean;
   the genuine "fluctuating observable" signature is Var(γ_T)=⟨γ_T²⟩>0, also regulated by e^{−πμ}.)
   **β₃ for A — machinery VALIDATED, large-N BLOCKED** (`brrz_beta3.py`). To get the bump amplitude
   A (=the only thing between the robust structure and a ⟨γ_T⟩ number) we need the large-N β₃
   (α=1/β₃). Built + PASSED a validation gate: reproduced BRRZ's d=2 Ising region integral
   I_{d=2}=−0.40346 (target −0.403746, 0.07%), β₃=1.2675 (target 1.2684); the z=0 divergences came
   out exactly π/a² (identity) + (π/2)/a (energy), no log. So the cutoff-extraction machinery works.
   BUT large-N O(N) is NOT a drop-in: O=φ̂ⁱχⁱ needs O(N) index combinatorics + N-counting (aligned
   channels ~N² ⇒ O~GFF of Δ_O, but φ̂×φ̂→σ=φ̂² with σ relevant at Δ=d−2 injects an extra operator),
   d=3 (3d integral), and there is NO independent large-N check. A factor slip ⇒ plausible-but-wrong
   β₃ = Ric-trap at large N. So NO large-N β₃ shipped; A and the ⟨γ_T⟩ MAGNITUDE stay open. Also
   noted: even with A, the magnitude needs the FULL analytic γ_T(s) (the Plancherel average samples
   γ_T continued to complex s, not just the near-s* slope) + a fixed regulator. The PARAMETER-FREE
   predictions (oscillation cancels; γ_T>0; locality genuinely fluctuates) are unaffected by all this.
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
