# dS4-LeanCheck

**A verification framework for 4D de Sitter holography** — an automated Generator/Verifier
loop that pairs a Claude LLM with the Lean 4 + Mathlib theorem prover to *formally
type-check* candidate holographic dictionaries mapping a 3D boundary CFT to a 4D de Sitter
(dS₄) bulk.

The system does not run numerical simulations. Instead it uses Lean's type checker as an
oracle: a generated hypothesis only "passes" if it actually compiles as a value satisfying
the framework's contract (correct types, a symmetric metric, and a *proved* positive
cosmological constant Λ > 0).

```
[ Claude — hypothesis generator ] ──(Lean 4 code)──► [ lake build ]
            ▲                                              │
            │                                       (type-checks)
   [ error feedback loop ] ◄──(compiler errors)──────── ✗ / ✓
                                                           │
                                                           ▼
                                               [ validated dS4 dictionary ]
```

## What Lean actually verifies

The metric is formulated by its **coordinate components** (a symmetric, invertible 4×4
matrix `g_μν` per point, in the canonical chart). This makes the physical constraints
expressible as real, compiler-checked proof obligations:

- **type-safety** of the boundary→bulk dictionary `𝓗_∂ → MetricField`,
- **symmetry** `g_μν = g_νμ` and **invertibility** `g · g⁻¹ = 1` (real proofs),
- **Lorentzian signature (-,+,+,+)** — via *Sylvester's law of inertia*, `g` must be
  congruent to the Minkowski form `η = diag(-1,1,1,1)`: `∃` invertible `P`, `Pᵀ g P = η`,
- **Einstein / de Sitter relation** `Ric_μν = Λ · g_μν` with **Λ > 0**, plus the 4D
  maximally-symmetric **trace identity** `R = gᵘᵛ Ric_μν = 4Λ` (so the full Einstein
  equation `R_μν − ½R g_μν + Λ g_μν = 0` holds identically).

**Honest caveat:** the Ricci tensor is carried as data *constrained* by the Einstein
equation — it is not yet *derived* from `g` via Christoffel symbols (that needs the full
connection machinery; see [Roadmap](#roadmap)). So the curvature condition is checked as an
algebraic relation between `g` and a postulated `Ric`, while the **signature condition is
fully genuine**. This is strictly stronger than the original `ricci_curvature_flatness :
True` placeholder.

### Boundary unitarity lever — the AdS/CFT ↔ dS/CFT toggle

AdS/CFT pairs the bulk with a **unitary** boundary CFT; dS/CFT (Strominger) pairs it with a
**non-unitary** boundary. We model the boundary inner product by a Hermitian, non-degenerate
Gram operator `G` (`KreinForm`), and classify it:

- `IsUnitary`    — positive-definite: no negative-norm states (AdS-like),
- `IsNonUnitary` — a negative-norm "ghost" state exists (dS-like / Krein).

`BoundaryKind` (`unitary | nonUnitary`) is the toggle. Because the dS↔unitarity relation
depends on *how* you do holography, consistency is keyed by a `HolographyScheme`:

| Scheme | de Sitter (Λ > 0) dual | Physics |
|--------|------------------------|---------|
| `globalBoundary` (ℐ⁺) | **non-unitary** CFT | Strominger dS/CFT — complex weights, ghosts |
| `staticPatchHorizon` | **unitary** finite-dim QM | Banks–Fischler–Susskind / SYK — lab-realizable |

Two payoff theorems make this precise:
- `HolographicDuality.boundary_nonUnitary` — in the global ℐ⁺ scheme, a de Sitter bulk
  **forces a non-unitary boundary** (the defining feature of standard dS/CFT). Worked
  example `dsDuality`: `G = diag(1,−1)` with a proven negative-norm ghost state.
- `HolographicDuality.horizon_unitary` — in the static-patch scheme, a de Sitter bulk is
  dual to a **genuinely unitary** boundary. Worked example `staticPatchDuality`: the
  positive-definite horizon Gram operator (`horizonForm`), proven `IsUnitary`.

### Grounding in real field theories

The levers are tied to concrete physics, not free parameters:

- **Mass–dimension relation** `Δ(d−Δ) = m²ℓ²` (`BoundaryOperator`): the theorem
  `principalSeries_of_heavy` proves a heavy field (`m²ℓ² > (d/2)²`) has a genuinely complex
  conformal weight (principal series) — the field-theory origin of dS/CFT's complex dimensions.
- **Sp(N) model** (Anninos–Hartman–Strominger): the `N → −N` continuation of the unitary
  O(N) vector model gives the non-unitary boundary (indefinite Gram = `KreinForm`); this is
  why the `globalBoundary` branch is non-unitary.
- **Static-patch metric** `staticPatchComp` (`ds² = −u dt² + u⁻¹ dr² + r² dΩ²`, `u = 1−r²/R²`):
  `staticPatch_signature` proves the causality check `g₀₀<0, gᵢᵢ>0` inside the horizon —
  the physically grounded, unitary alternative to the global ℐ⁺ boundary.

## Layout

| Path | Purpose |
|------|---------|
| `Ds4Verification/Core.lean` | The framework: `MetricField`, `MetricField.Lorentzian`, `DeSitterUniverse`, `HolographicDS4Hypothesis`, `verifies`. |
| `Ds4Verification/Example.lean` | A worked, fully-proved instantiation (ℂ² boundary → dS₄) — signature + Einstein relations discharged. Seed for the loop. |
| `Ds4Verification.lean` | Library root (imports the above). |
| `driver/agent_loop.py` | The Claude ↔ Lean orchestration loop. |
| `driver/requirements.txt` | Python deps (`anthropic`). |
| `lakefile.toml`, `lean-toolchain` | Lake project + pinned toolchain. |

## Prerequisites & setup

### 1. Lean toolchain (Elan)

Install [`elan`](https://github.com/leanprover/elan) (the Lean version manager). It reads
`lean-toolchain` and fetches the pinned compiler automatically.

```bash
# macOS / Linux
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh
# Windows: download & run elan-init.exe from the elan releases page
```

### 2. Build Lean + Mathlib

From the project root:

```bash
lake exe cache get   # downloads prebuilt Mathlib oleans (skip the multi-hour rebuild)
lake build           # builds Core + the worked Example
```

> **Version pin:** `lakefile.toml` pins Mathlib to a release tag and `lean-toolchain` must
> match it. If `lake exe cache get` reports a mismatch, set `rev = "main"` in
> `lakefile.toml`, then run `lake update && lake exe cache get && lake build`. If you hit
> `unknown identifier 'IsManifold'`, your Mathlib predates the `IsManifold` rename — swap to
> `SmoothManifoldWithCorners modelDS4 M` on the marked line in `Core.lean`.

### 3. Python driver

```bash
pip install -r driver/requirements.txt
cp driver/.env.example driver/.env      # then add your key, or export it directly
export ANTHROPIC_API_KEY=sk-ant-...     # PowerShell: $env:ANTHROPIC_API_KEY="sk-ant-..."
```

## Running the loop

```bash
# Smoke-test the wiring with no API key and no compiler:
python driver/agent_loop.py --dry-run

# Full run (needs ANTHROPIC_API_KEY and a working `lake build`):
python driver/agent_loop.py --iterations 5
python driver/agent_loop.py --iterations 8 --model claude-opus-4-8
```

Each round Claude is asked to emit a Lean module instantiating the contract. The driver:

1. writes it to `Ds4Verification/Generated.lean`,
2. runs `lake build Ds4Verification.Generated`,
3. on success → saves `runs/validated_dictionary.lean` and stops;
   on failure → feeds the compiler errors back for self-correction.

Per-iteration code and logs are archived under `runs/`. A run is only counted as a success
if the module type-checks **and** contains no `sorry`.

## Roadmap

- [x] Replace `ricci_curvature_flatness : True` with a genuine `Ric = Λ • g` relation (+ `R = 4Λ`).
- [x] Enforce a Lorentzian `(-,+,+,+)` signature constraint (Sylvester congruence to η).
- [x] Boundary unitarity lever: Krein/non-unitary boundary + dS/CFT-vs-AdS/CFT toggle.
- [x] Holography-scheme toggle: global ℐ⁺ (non-unitary) vs static-patch horizon (unitary).
- [x] Complex conformal weights via the mass–dimension relation (principal-series threshold).
- [x] Static-patch metric with an inside-horizon causality (signature) check.
- [ ] **Derive** `Ric` from `g` via Christoffel symbols, so the Einstein equation is checked
  against the metric's actual curvature rather than a postulated Ricci tensor.
- [ ] Full Sylvester congruence proof for the static-patch metric (not just the sign check).
- [ ] Imaginary central charge from the O(N)→Sp(N), `N → −N` continuation.
- [ ] A concrete free-scalar-field / SYK boundary theory.
- [ ] Convergence metrics / structured logging for the generator loop.

## Build status

Compiled and verified against **Lean 4.15.0 + Mathlib v4.15.0** (Windows):

- `lake build` → Core + both examples compile, **no `sorry`**.
- Boundary lever verified: `dsDuality` (non-unitary `G = diag(1,−1)` ↔ Λ = 3 de Sitter bulk)
  compiles, and `HolographicDuality.boundary_nonUnitary` proves the dS bulk forces it.
- Grounded unitary alternative verified: `staticPatchDuality` (unitary horizon Gram ↔ Λ = 3
  bulk) compiles, with `horizon_unitary`, `horizonForm_unitary`, `staticPatch_signature`, and
  the `principalSeries_of_heavy` threshold all proven.
- `lake build Ds4Verification.Generated` → a generated state-dependent-Λ candidate verifies.
- **Negative control:** a hypothesis with Λ = −1 is *rejected* (`positivity` fails on
  `pos_Λ`) — confirming the check is non-vacuous (valid physics compiles, invalid is refused).

## Notes

This repository was scaffolded with realistic, fixed-up code (the original spec's Python had
`response.choices.message` and an OpenAI client; this driver uses the Anthropic SDK and
`msg.content[0].text`). Two Mathlib-version nudges were needed and are already applied:
`open scoped Matrix` for the `ᵀ` transpose notation, and `smul_mul_smul → smul_mul_smul_comm`
(the former is deprecated). Structures bundling a complex Hilbert space must be
`noncomputable`.
