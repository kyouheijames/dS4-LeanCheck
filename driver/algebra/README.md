# Part 2 — the algebra framework (CAS)

This is the layer the Lean harness **cannot** do (no QFT in Mathlib): turning a
queued candidate's kinetic exponent `s` into the *interacting* would-be
stress-tensor anomalous dimension `γ_T(s)`, by large-N (Sp(N)) algebra. It closes
the handshake with Part 1: Lean fixes the goalposts, the CAS takes the shot, and
the evaluated number comes back to Lean as certified data.

## Files

| File | Role |
|------|------|
| `conformal_integrals.py` | Exact position-space conformal-integral toolbox — the one-loop bubble `U(a,b)`, Symanzik star-triangle (uniqueness), free/HS dimensions. Every function is an exact Gamma-function identity sympy evaluates symbolically; nothing is fit. |
| `long_range_gamma.py` | The Part 2 derivation: LO dimensions, the long-range non-renormalization result `γ_φ = 0`, the induced σ propagator, and the `γ_T(s)` extraction with the `s→1` conservation rail. Emits the JSON handshake. |
| `large_n_selfenergy.py` | The **exact** large-N self-energy sector: free χ propagator coefficient via the d-dim FT of `|p|^{-2s}`, the χ² bubble Π(x) and its FT Π(p)∝|p|^{d-4s}, the induced σ propagator (Δσ=2s), and η_χ=0. Sets up — explicitly, but does **not** fake — the spin-2 broken-current integral whose value is `C_T(s,d)`; enforces the `s→1` rail. This is "starting the real computation": the computable sector is computed exactly; the one remaining conformal integral is flagged for evaluation / literature cross-check. |
| `cT_spin2.py` | Part 2(a) proper: the exact uniqueness/self-energy toolkit; `η_χ=0` shown structurally (self-energy power ≠ kinetic power); and the spin-2 anomalous dimension `γ_{ℓ=2}` extraction **set up via the Lorentzian inversion formula** — the dDisc of the σ-exchange `⟨χχχχ⟩` projected on spin 2, with EXACT inputs `Δχ,Δσ`. The remaining spinning-integral/inversion residue is the open coefficient; `s→1` rail + short-range `O(N)` boundary condition enforced; literature anchors (Lang–Ruhl, Giombi–Kirilin–Skvortsov, Caron-Huot, Behan–Rastelli–Rychkov–Zan) listed. **No coefficient is invented.** |
| `requirements.txt` | `sympy`. |

## Run

```bash
pip install -r driver/algebra/requirements.txt
python driver/algebra/conformal_integrals.py   # toolbox smoke checks
python driver/algebra/long_range_gamma.py       # LO report + s→1 rail + handshake
```

## Epistemic status (same discipline as ../../working/STATUS.md)

**Derived, exact (no physics asserted):**
- `Δ_χ(s) = (d − 2s)/2` — free long-range dimension (matches `Ds4Verification.freeDim`).
- `Δ_σ,LO = 2s` — Hubbard–Stratonovich marginality of the `σχχ` vertex.
- `γ_φ = 0` — long-range **non-renormalization**: an analytic counterterm cannot
  renormalize the non-analytic `|p|^{2s}` kinetic term. A genuine statement, not a convention.
- The induced σ-propagator normalization `U(Δ_χ, Δ_χ)`, exact from the bubble identity.
- The hard rail `C_T(1, d) = 0` — at `s = 1` the theory is local, the spin-2 current
  is conserved, `γ_T = 0`. Any candidate `C_T(s,d)` that fails this is rejected.

**Physics input, deliberately left symbolic (the actual research integral):**
- `C_T(s, d)` — the order-`1/N` coefficient of the spin-2 broken-current self-energy,
  so that `γ_T(s) = C_T(s,d)/N + O(1/N²)`. It is a specific conformal integral assembled
  from `conformal_integrals.py`. **We refuse to fabricate its value** — that would be the
  exact analog of the repo's Ric-trap (asserting a number that looks derived). Plugging in
  the evaluated integral is the one genuinely new computation; the scaffold checks the
  `s→1` limit and the `1/N` scaling for whatever you supply.

## Handshake to Lean (Part 1 ↔ Part 2 contract)

`certified_record(s, d, evaluated_CT=...)` emits, per candidate:

```json
{ "s": 1.4, "d": 3.0, "delta_chi": 0.1, "delta_sigma_LO": 2.8,
  "gamma_phi": 0.0, "N_order": 1, "C_T": <number|null>,
  "gamma_T_coeff_over_N": <number>, "gamma_T_status": "derived|symbolic ..." }
```

This is the record a future Lean lemma reads back as a new certified field on
`Candidate` (replacing the free-level convention `gammaT_free = 2(s−1)` with the
derived `γ_T`). Until `C_T` is evaluated, `gamma_T_status` is `"symbolic …"` so
nothing downstream can mistake a placeholder for a result.

## Cross-check (the hard test of the algebra)

The `s → 1` limit must reproduce the local result `γ_T → 0` (stress-tensor
conservation). `assert_local_limit` enforces this on any candidate `C_T`. This is
the analog of the negative control in the main README: it keeps the derivation
non-vacuous.

## Next: Part 3 (SDPB)

Once `γ_T(s)` is a real number for a few queued `s`, Part 3 (see `../../working/PLAN.md`)
feeds it as a gap assumption into a shadow/dS crossing SDP and asks whether the
**s-averaged** (fluctuating-locality) system stays shadow-positive. No type-checker
and no CAS can settle that — it is the actual test of the conjecture.
