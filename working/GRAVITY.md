# The gravity reading: γ_T is the graviton mass, locality-SSB is gravitational-gauge SSB

Honest synthesis of where the program touches gravity. Grounded in the standard holographic
dictionary + dS higher-spin holography; the frontier (Einstein limit) flagged as open.

## The dictionary (solid — standard holography)
- The boundary stress tensor T_μν is dual to the BULK GRAVITON in any holographic duality.
- Our central object: γ_T = anomalous dimension of the would-be stress tensor [χχ]_{0,2}. Then:
    γ_T = 0  ⟺  T conserved  ⟺  diffeomorphism invariance  ⟺  MASSLESS graviton (exact gravity)
    γ_T ≠ 0  ⟺  T non-conserved  ⟺  diff broken  ⟺  MASSIVE graviton,  m²_grav ∝ (d−2)·γ_T near Δ=d.
- So **γ_T IS the graviton mass²** (linearized), and our result γ_T>0 (unitary direction) = a small
  POSITIVE graviton mass², massless exactly at the local point (s=1 / crossover s*).

## The Sp(N) is not a coincidence (real, literature-grounded)
- dS₄ higher-spin (Vasiliev) gravity is dual to an **Sp(N)** vector model on the boundary
  (Anninos–Denef–Harlow dS/CFT; Klebanov–Polyakov HS holography). Our model is symplectic Sp(N).
- The boundary non-unitarity we PROVED (Krein form G=iΩ, ghostKrein_nonUnitary) IS the known
  non-unitarity of dS/CFT. So our boundary theory sits on the boundary of a de Sitter gravity.

## The reframing (sound)
- "Locality is a fluctuating observable that breaks via SSB" = "the graviton mass fluctuates / the
  gravitational gauge symmetry is spontaneously broken and restored."
- Symmetric phase (γ_T=0, local point) = exact (massless) higher-spin gravity.
  Broken phase (γ_T>0) = massive / weakly-broken gravity.
- This makes the whole γ_T program a statement ABOUT THE GRAVITON.

## The frontier (HONEST — open)
- The bulk dual of a VECTOR model is HIGHER-SPIN gravity: a whole tower of light spin-ℓ gauge
  fields, not just the graviton. So it is gravity, but the EXOTIC (Vasiliev) kind, NOT Einstein GR.
- To reach realistic (Einstein) gravity one must LIFT the higher-spin tower (spins ℓ≥4 heavy,
  spin-2 light). Suggestively, locality-breaking does exactly this kind of thing: γ_ℓ≠0 gives every
  would-be current a mass, and Maldacena–Zhiboedov says weakly-broken (not exact) HS currents are
  precisely how an interacting gravity-like bulk emerges. The SSB that masses the graviton is the
  same mechanism that lifts the tower.
- NOT established: that the lifting leaves a clean Einstein-graviton limit. That is the genuine open
  problem (Einstein gravity from a broken-HS vector model) — promising mechanism, unproven endpoint.

## The spin test (γ_ℓ) — what it does and does NOT show (`gamma_spin.py`)
The leading-twist [χχ]_{0,ℓ} ARE the single-trace HS currents J_ℓ = χ∂^ℓχ, dual to the bulk spin-ℓ
gauge fields (graviton = J_2). So γ_ℓ = the spin-ℓ gauge-field mass². Computed (generic σ-exchange,
validated engine):  γ_ℓ ~ const / ℓ^{2s}  (γ_ℓ·ℓ^{2s}→const in d=3,4) — γ_ℓ DECREASES with ℓ, so the
spin-2 graviton is the LARGEST-γ (heaviest) and higher spins are asymptotically conserved (light).

CORRECTION (an earlier draft overclaimed "does not flow to Einstein" — wrong). This is the
MICROSCOPIC SPIN SPECTRUM, not the classical limit. By Weinberg's theorem a light spin-2 MUST couple
universally to T_μν and reproduce General Relativity at long distance — that is forced by
consistency, not vetoable by the spectrum. So the correct reading of γ_ℓ is "Einstein + a light
higher-spin tower" (which CONTAINS Einstein), not "non-Einstein":
  • spin-2 present, couples universally ⇒ Einstein at long distance (Weinberg);
  • slightly massive (γ_2>0, largest γ_ℓ) ⇒ small calculable corrections;
  • light HS tower ⇒ extra higher-spin forces on top.
What is genuinely OPEN (quantitative, not binary): does the HS tower decouple at observable scales?
is the graviton mass ∝γ_2 ~ (1/N)·breaking small enough? is there a regime where the tower lifts to
leave cleaner Einstein? None settled — but Einstein being PRESENT in the classical limit is the
expected/required outcome, not in doubt.

## Why Einstein isolation is STRUCTURAL, not a calculational roadblock
A common misframing: "unbroken phase = non-local, broken phase = GR, the intermediate regime is just
hard to calculate." Wrong for a vector model, in two ways:
 1. The "broken" end (s≥s*, short-range critical O(N)) is STILL higher-spin gravity at large N —
    NOT Einstein GR. Both ends of the s-line are HS gravity; there is no GR phase to flow to.
 2. It is NOT a calculational difficulty. We CAN and DID calculate: γ_ℓ~1/ℓ^{2s}, DECREASING with ℓ.
    "Lift the tower" for Einstein needs the OPPOSITE (γ_ℓ growing with ℓ). And the universal
    large-spin (lightcone) theorem forces γ_ℓ→0 as ℓ→∞ — the HS tower is asymptotically conserved
    (LIGHT) at every s. A vector Lagrangian has NO heavy-tower phase.
Reason (Klebanov–Polyakov + Maldacena–Zhiboedov): the HS currents are BILINEARS χ∂^ℓχ with uniformly
small (1/N) anomalous dimensions ⇒ vector model ⟺ HS gravity, tower light, ALWAYS. Heavy higher
spins (Einstein isolation) require LONG operators — matrix/adjoint (Tr φⁿ) or string d.o.f., where
the tower lifts to the string scale at strong coupling. That is a DIFFERENT Lagrangian, not a harder
computation of ours. So calculating our Lagrangian more heroically does NOT reach Einstein.

## CORRECT TARGET: "include Einstein", not "be Einstein"
Real quantum gravity is NOT Einstein gravity — Einstein is the non-renormalizable IR EFT that any
UV-complete theory must REDUCE TO, while being richer above (string theory CONTAINS Einstein, isn't
it). So the requirement is that the graviton sector give Einstein at long distance, with the rest as
extra UV structure. Against THAT (correct) test our theory PASSES:
 • graviton present (T_μν) + Weinberg ⇒ Einstein at long distance — Einstein is INCLUDED ✓;
 • the HS tower is the "more than Einstein" part — exactly the role string states play ✓.
The earlier "isolate a lone graviton / structural obstruction" was testing the WRONG goal.

The one honest DIFFERENCE: in string theory the extra states are HEAVY (Planck/string scale) ⇒
decouple ⇒ pure Einstein at low energy. Here the HS tower is LIGHT (1/N-suppressed masses AND
couplings, Hubble-ish). Two consequences:
 • SIGNATURE: the light HS sector is TESTABLE — the cosmological-collider / HS imprints (PREDICTIONS.md).
 • CONSTRAINT: it must sit below GR-test precision (fifth-force/dispersion) ⇒ needs N large enough
   that the 1/N corrections hide from GR tests while still showing in the CMB collider channel.
   Quantitative requirement, NOT a structural failure.

## Net
It is a quantum gravity that INCLUDES Einstein (graviton + Weinberg) with a calculable, LIGHT,
testable higher-spin sector as its UV/extra structure — "Einstein + a 1/N higher-spin sector",
not "fails to be Einstein". Open question (correct form): is N large enough that the HS corrections
evade GR tests while remaining visible in the CMB cosmological-collider channel? The value: HS dS
gravity + locality-as-observable + non-unitarity, with Einstein correctly contained in the IR.
Refs: Klebanov–Polyakov 2002; Anninos–Denef–Harlow (dS/CFT, Sp(N)); Maldacena–Zhiboedov 2011/2012
(weakly broken HS); Anninos–Hartman–Strominger. (Conceptual note; nothing here is computed/proved.)
