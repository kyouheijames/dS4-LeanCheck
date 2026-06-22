# STATUS.md — what is proved, what is convention, what is out of scope

The whole point of this layer is to NOT repeat the `ricci_curvature_flatness : True`
→ postulated-Ric pattern silently. Here is the exact epistemic status of every claim.

## A. Genuinely PROVED (real Lean theorems — algebra/linear algebra, no physics asserted)

| Theorem | Content |
|---------|---------|
| `freeDim_local` | Δχ(s=1) = (d−2)/2 — sanity of the dimension formula |
| `OmegaMin_antisymm`, `OmegaMin_diag_zero` | the symplectic invariant is antisymmetric with zero diagonal (non-unitarity seed) |
| `gammaT_zero_iff_local` | **γ_T = 0 ⟺ s = 1** — locality ⟺ conserved local T, as an iff |
| `nonlocal_of_ne_one` | s ≠ 1 ⇒ γ_T ≠ 0 (the non-local regime is well-defined) |
| `shadow_eq_conj_on_principal` | **shadow map = complex conjugation on the principal series** (CPT = shadow positivity) |
| `shadow_involutive`, `shadow_re_eq` | shadow is an involution preserving Re Δ = d/2 |
| `worth_of_principal` | the filter: principal + global + ghost ⇒ WorthInvestigating, with C2 derived |

These are the load-bearing structural facts. They pin down WHAT the theory is and
make "locality" and "CPT/shadow positivity" decidable predicates rather than prose.

### A2. PROVED in the later modules (the theory built on top of Part 1)

| Theorem (module) | Content |
|------------------|---------|
| `propagator_homog`, `propagator_scaling` (`FreeSector`) | free-sector **Δ(s) DERIVED** from the propagator's homogeneity `G(l·x)=l^{−2·freeDim}G(x)` — no multiplier theory used |
| `propagator_isometry_invariant`, `propagator₂_translation_invariant`, `propagator₂_isometry_invariant`, `propagator₂_euclidean_invariant`, `propagator₂_scaling` (`FreeSector`) | **free-sector Euclidean invariance PROVED**: the two-point function `G(x,y)=‖x−y‖^{−(d−2s)}` is invariant under the boundary Euclidean group `ISO(d)` (translations + rotations/reflections) and scale-covariant — the long-range term breaks locality, not spacetime symmetry |
| `norm_inv_sub_inv`, `propagator₂_inversion_covariant` (`FreeSector`) | **inversion (special-conformal) covariance PROVED**: under `ι(x)=x/‖x‖²`, `G(ι x, ι y)=‖x‖^{2Δ}‖y‖^{2Δ}G(x,y)` with `2Δ=d−2s`. Together with the above this closes the **FULL conformal group** on the free two-point function — purely norm/inner-product algebra, no operator |
| `StressTensor.gammaT_zero_iff_conserved` (`StressTensor`) | **γ_T = 0 ⟺ Δ_T = d** (conserved local stress tensor), γ_T now defined as `Δ_T − d` |
| `freeStressTensor_conserved_iff_local` (`StressTensor`) | the free construction's `Δ_T` discharges/violates conservation exactly at `s = 1` |
| `expectedGammaT_ne_zero` (`Model`), `expectedGammaT_eq`, `expectedGammaT_ne_zero_iff` (`ModelP`) | fluctuating-locality observable: ⟨γ_T⟩ over a two-point law, then a general `PMF ℝ` as an **integral**; broken-on-average ⟺ mean exponent non-local |
| `shadow_eq_conj_iff` (`CPTLocality`) | **CPT-exact ⟺ Re Δ = d/2** (full iff) — CPT-exactness as a decidable predicate |
| `cptExact_iff_local`, `cptExact_iff_conserved`, `locality_cpt_equiv` (`CPTLocality`) | **CPT-break = locality-break = non-conservation**, one shared `ε`; the five conditions are *mutually equivalent* (machine-checked non-contradiction) |
| `ghostKrein_nonUnitary`, `boundary_not_unitary` (`Lagrangian`) | the symplectic Gram `G = iΩ` has a **proved ghost** `(1,i)`, so the Lagrangian *carries* a non-unitary boundary (not just seeds it) |
| `ghostGram_eq_iOmega` (`Lagrangian`) | the boundary Krein form is exactly `iΩ` — non-unitarity **lifted from Ω**, not posited |
| `sp_covariant` (`SymmetryBreaking`), `isSymplecticVacuum_congr`, `isUnbroken_one/_mul`, `deltaOmega_OmegaMin`, `isUnbrokenGen_OmegaMin_iff`, `identity_isGoldstone` (`ParentTheory`) | **Ω = order parameter of `GL(N)→Sp(N)` SSB**: action preserves the symplectic vacuum manifold; the stabilizer (Sp) is a submonoid; for N=2 the breaking is EXACT — `δΩ = (tr X)·Ω`, so `sp(2)`= traceless (`sl₂`, dim 3) and the **single Goldstone is the dilation** `X∝1` (`dim gl(2)−dim sp(2)=1`) |
| `potentialV_nonneg`, `OmegaMin_sq`, `potentialV_OmegaMin`, `OmegaMin_isMinimum`, `potentialV_eq_zero_iff`, `isSymplecticVacuum_of_potentialV_zero` (`ParentAction`) | **dynamical-Ω potential**: `V(Ω)=‖Ωᵀ+Ω‖²+‖Ω²+𝟙‖² ≥ 0`, with `V=0 ⟺ Ωᵀ=−Ω ∧ Ω²=−𝟙` (the symplectic/complex-structure vacuum manifold); `OmegaMin` is a global minimum, and every `V=0` config is a symplectic vacuum — so Ω emerges as a VEV, not a background |

## B. MODELING CONVENTION (faithful, but a choice — the zero set is the physics)

| Object | Convention | What is real vs. chosen |
|--------|-----------|-------------------------|
| `gammaT_free s = 2(s−1)` | linear order parameter | The **zero set {s=1}** is physical (conserved T iff s=1). The slope/coefficient is normalization — it is NOT the interacting anomalous dimension. |
| `freeDim` | (d−2s)/2 | Correct at Gaussian level; receives interacting corrections (Part 2). |
| `freeStressTensor` `Δ_T = d − 2(s−1)` (`StressTensor`) | **Sign now PINNED** by the double-twist computation: the would-be T is `[χχ]_{0,2}`, `Δ_T=2Δχ+2=d−2(s−1)`, free `γ_T=2(1−s)`. (Was `+2(s−1)`; zero set unchanged, but the physical sign is `−`, putting `Δ_T<d` for `s>1` — below the spin-2 bound, consistent with non-unitarity.) `gammaT_free` stays the (sign-convention) order parameter; physical `γ_T = −gammaT_free`. |
| `CPTLocality` couplings `s = 1+ε`, `Re Δ = d/2 + ε` (`CPTLocality`) | The **shared zero {ε=0}** is the physics (CPT-exact ⟺ local); the unit slopes are normalization. |
| `ghostKrein` / `G = iΩ` (`Lagrangian`) | Modeling the boundary inner product as `iΩ` is a *choice* of how the Sp(N) symplectic structure becomes the Krein form; the **indefiniteness (ghost) is real and proved**, not chosen. |

## C. OUT OF SCOPE — deliberately NOT formalized (honest gaps, by design)

| Gap | Why it is not here | Where it lives |
|-----|--------------------|----------------|
| Construction of `(−∂²)ˢ` as an *operator* (Fourier multiplier / subordination) | needs C₀-semigroups or Riesz potentials — both ABSENT from Mathlib (verified). **Not needed for the dimension**: `FreeSector` derives Δ(s) from the propagator's homogeneity instead | optional future Lean rigor upgrade only |
| **Operator-level `(−∂²)ˢ`-invariance** and **interacting** conformal covariance | the `LongRangeLagrangian` structure carries no spacetime/transformation data; the operator statement needs the multiplier theory above. The **full conformal group is now proved on the free two-point function** (translations + rotations + dilations + inversions, `FreeSector`); what remains asserted-not-proved is the *operator-level* statement and *interacting* covariance | future Lean (after multiplier theory) |
| **Interacting γ_T(s)** | needs ε-expansion / large-N loop & conformal integrals — no QFT in Mathlib | **Part 2 (CAS)** — `driver/algebra/` scaffold built; the `C_T(s,d)` integral is left SYMBOLIC and must be evaluated by hand/CAS, then fed back as certified data (NOT fabricated) |
| Sphere partition function → e^{iS_dS}, Gibbons–Hawking entropy sign | non-perturbative; not algebraic | Part 2/3 |
| **Averaging consistency** (does crossing + shadow positivity survive s-fluctuation) | infinite crossing system; no proof object exists | **Part 3 (SDPB)** — `ModelP.expectedGammaT` now *states* it as `⟨γ_T⟩ = ∫ γ_T d(sDist)`, but only the bootstrap can decide it. The actual test of the conjecture. |

## D. COSMOLOGY MAPPING — physics conjecture, NOT derived/verified (the "dS-XFT" pitch)

A separate discussion proposed mapping the model to CMB observables. Triaged against this repo:

| Claim | Status here |
|-------|-------------|
| `Δ = (d−2s)/2` | ✅ PROVED (`FreeSector`, `freeDim`) — the one solid anchor |
| `[g] = 4s − d`, super-renormalizable ⇔ `s > d/4` | ✅ PROVED as power counting (`PowerCounting`). NECESSARY, not sufficient for UV-finiteness |
| power-spectrum exponent `d − 2s = 2·Δ` | ✅ PROVED (`spectralExponent_eq`) — but only the exponent, not the `n_s` identification |
| `n_s = 4 − 2s ⇒ s ≈ 1.52` | ⚠️ CONJECTURE + INTERNAL TENSION. Uses a REAL `Δ` (complementary series); the repo's non-unitarity/CPT/shadow machinery is PRINCIPAL series (complex `Δ`, `Re Δ = d/2`). One field can't be both. Also `s=1` gives `n_s=2`, but standard local inflation gives `n_s≈1` — so the "localism ruled out" argument is built on a nonstandard dictionary. NOT derived. |
| principal-series power spectrum (the CONSISTENT version) | ✅ FORMALIZED (`PrincipalSpectrum`): `⟨O(k)O(−k)⟩ ∝ k^{2Δ−d}`. On `Re Δ=d/2`: tilt `Re(2Δ−d)=0` (scale-invariant base, `n_s≈1` *automatically*), `Im(2Δ−d)=2μ` (log-periodic cosmological-collider oscillation, frequency `μ=Im Δ`). For a `CPTLocality` config (`Re Δ=d/2+ε`): **`n_s−1 = 2ε`** — the tilt IS the CPT/locality-breaking order parameter. This replaces the inconsistent `n_s=4−2s`. (Amplitude / `e^{−πμ}` size still need the late-time wavefunction computation — out of scope.) |
| `f_NL`, "Axis of Evil = Ω orientation", `δα/α` bounds, matching `A_s` | ❌ NOT predictions — parameter *fits*/postdictions (a free background tensor can be oriented to any observed axis). Unverified. |
| "UV-finite, Ward identities hold, unitary, massless photon, healthy" | ❌ CONTRADICTS the framework. Non-integer `(−∂²)ˢ` carries ghosts = the NON-unitarity proved FORCED by Λ>0 (`lagrangianDuality_forced_nonUnitary`). A unitary reading would undo dS/CFT, not support it. |
| UV-finiteness ⇒ `s` stable (no anomalous-dim shift) | ❌ this IS the interacting `γ_T(s)` — Part 2 (CAS), still open. Power counting does not settle it. |

**One-line:** the dimensional analysis is real and now formalized; the cosmological *numbers*
(`s≈1.52`, axis fits) are unverified conjecture, and two claims (real-Δ cosmology vs principal
series; "unitary" vs forced non-unitarity) are in direct tension with what the repo proves.

## The one-line summary

This Lean layer **certifies that a candidate IS a consistent dS/CFT* dual and reports
its locality**. It does **not** and cannot certify that the *fluctuating-locality*
average stays consistent — that is Part 3, and no type-checker can do it. Lean fixes
the goalposts; it does not take the shot.
