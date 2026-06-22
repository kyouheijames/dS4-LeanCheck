# Correspondence test: our symplectic model ↔ long-range O(N) (Chai–Goykhman–Sinha, 2107.08052)

Tested the proposed dictionary `Ω ↔ λ*`, `G=iΩ ↔ C_χ<0` against the actual Lean theorems
(`SymmetryBreaking.lean`, `Lagrangian.lean`) and the paper. Result: **partly right, partly an
over-identification** — recorded honestly below, not forced into a clean dictionary.

## Proved on our side (Lean, no `sorry`)
- `ghostKrein_nonUnitary` — `G=iΩ` has a negative-norm state `(1,i)`, `[v,v]=−2<0`. Boundary
  non-unitary. The ghost is **sourced by** antisymmetric `Ω` (real antisym ⇒ `iΩ` Herm. indefinite).
- `sp_covariant`, `shear_fixes_OmegaMin`, `dil_moves_OmegaMin` — `Ω` is the order parameter of
  `GL(N)→Sp(N)`, a **field-space / flavor** symmetry breaking.
- `CPTLocality`, `PrincipalSpectrum` — `ε` = the **locality-breaking** order parameter; `n_s−1=2ε`.

## Proved in the paper (long-range O(N), large N)
- `C_χ = −2C(s) < 0` (eq. 7.13) — the dual GFF `χ` is **negative-norm** (a ghost), `C(s)>0`.
- `∂_μT^μν = λ* ∂^ν(φ̂χ)` (eq. 7.36) — stress-tensor non-conservation **sourced by `χ`**.
- `λ*² = α(d)·δ`, `δ=(s*−s)/2` (eq. 7.30) — `λ*` gates the ghost; **vanishes at the crossover `s*`**.
- `γ_T = (2α(d)δ/Γ(d/2))·γ_φ̂` (eq. 7.32) — locality-breaking `∝ δ`, vanishes at `s*`.
- `χ ↔ σφ` (eq. 7.17); `χ` decouples into a free sector for `s≥s*` (locality restored).

## Verdict on the proposed dictionary

| Proposed | Verdict |
|---|---|
| `Ω ↔ λ*` | ✗ **WRONG**. `Ω` is the `Sp(N)` field-space order parameter (it *creates* the ghost via `G=iΩ`); `λ*` is the locality coupling (it *activates* a pre-existing ghost). Different roles. `Ω` is symplectic-specific; the O(N) paper has no `Ω`. |
| `G=iΩ ↔ C_χ<0` | ~ **PARTIAL**. Both are real negative-norm ghosts (both models non-unitary) — genuine structural match. Different ORIGINS: ours from the symplectic Krein form, theirs from the dual GFF `χ`. Not a proven literal identity. (Rhyme: both carry a `−2`.) |

## The correspondence that DOES hold

| Honest match | Status |
|---|---|
| our `ε` (locality-breaking strength) ↔ paper's `δ=(s*−s)/2` / `λ*²` / `γ_T` | ✓ both vanish at the local point (`s=1` / crossover `s*`), gate the non-unitarity, measure the conservation defect |
| our `G=iΩ` ghost (source of non-unitarity) ↔ paper's `χ` (`C_χ<0`) | ~ same ROLE (the model's negative-norm mode), distinct realization |

## Crucial caveat
The paper is the **orthogonal O(N)** long-range model; ours is the **symplectic Sp(N)** variant.
They SHARE the locality-breaking mechanism (order-parameter-gated ghost; `γ_T ∝ breaking`; vanishing
at the local point) — which the paper makes rigorous and which strongly supports the thesis. But the
`Sp(N)`/`Ω` symplectic structure is OUR addition; the paper does NOT compute it. So the paper
validates the locality-breaking PHYSICS the thesis rests on; it does not validate the specific
symplectic construction. That stays our distinct (still-conjectural) model.

## Net for the "SSB handles the ghost" conjecture
The paper makes the chain `order parameter → ghost → locality-breaking` RIGOROUS (in O(N)): `δ→0`
**decouples** `χ` and restores conservation. Our Lean layer formalizes the same chain via
`Ω-SSB → G=iΩ → ε`. Three honest gaps remain:
1. The symplectic-specific piece (`Ω`, `Sp(N)`) is NOT validated by the paper — our addition.
2. "Fluctuating observable" (the PMF over `s`) still needs a measure `p(s)`.
3. "SSB *cures* the ghost" is refined by the paper to "the order parameter switches the ghost
   between **coupled** (broken/long-range) and **decoupled** (symmetric/short-range)" — a
   decoupling, NOT a Higgs-style absorption. The pasted "Goldstones eaten" picture is the wrong
   mechanism; the right one is coupled↔decoupled across the crossover.

So: the thesis' mechanism is literature-supported; the precise SSB statement is sharper (and
different) than the analogy; the symplectic construction remains to be earned on its own.
