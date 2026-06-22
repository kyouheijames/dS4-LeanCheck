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

## Net
It IS gravity — the boundary of de Sitter HIGHER-SPIN gravity — with γ_T the graviton mass and
locality-SSB the breaking of the gravitational gauge symmetry. The classical limit is expected to
CONTAIN Einstein gravity (light graviton + Weinberg); the spin test shows it as "Einstein + light HS
tower." The open questions are the SIZE of the corrections (tower decoupling, graviton mass), not
whether Einstein is there.
Refs: Klebanov–Polyakov 2002; Anninos–Denef–Harlow (dS/CFT, Sp(N)); Maldacena–Zhiboedov 2011/2012
(weakly broken HS); Anninos–Hartman–Strominger. (Conceptual note; nothing here is computed/proved.)
