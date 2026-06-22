# Productive-roadmap results (steps 1–4)

Going "one by one" through the A-independent / testable directions. Honest scorecard.

## (1) Scalar↔tensor correlation — DONE, the real win
PROVED (Lean, `ScalarTensor.lean`, builds): **γ_T = −(n_s−1)**, parameter-free ratio −1, no 1/N
coefficient A. Both halves were already proved (n_s−1=2ε; γ_T=−2ε); the single ε ties them.
Anchor: n_s−1=−0.035 (Planck) ⇒ γ_T=+0.035. Falsifiable vs independent tensor-sector + n_s data.
Scope: the framework's shared-ε coupling made quantitative (tree level), not an independent dynamical
derivation — but the first parameter-free testable correlation.

## (2) Cosmological-collider frequency — WALLS (and corrects an earlier overclaim)
The collider oscillation needs a HEAVY field (principal series, Δ=d/2+iμ, μ≠0). Our explicit fields
are LIGHT: Δχ=(d−2s)/2 and Δσ=2s are REAL (complementary series, μ=0) for the whole physical s-range.
⇒ the model predicts the TILT but NO oscillation. A collider oscillation requires ADDING a heavy
field — a model extension, μ a free input, NOT a parameter-free output. CORRECTION: the "cosmological
collider" entry in PREDICTIONS.md/OBSERVATIONS.md was too optimistic; the oscillation is not a
feature of the basic content. The tilt (n_s−1=2ε) stands; the oscillation does not.

## (3) Positivity of ⟨γ_T⟩ — PASSES (clean, parameter-free)
The conjecture's consistency leg holds. Continuing the tree γ_T=2−2s onto the principal line
(s=d/4+iμ/2): γ_T=(2−d/2)−iμ; the odd −iμ (oscillation) cancels against the even Plancherel measure
⇒ **⟨γ_T⟩_tree = 2−d/2 = +0.5 (d=3)** — real, positive, parameter-free, Δ_T>d (unitary direction).
Genuine fluctuation Var(γ_T)>0. So positivity + nontriviality (the checkable conditions) PASS.
NOT done: the full crossing-bootstrap (SDPB) with the non-unitary (Krein/shadow) modification — a
bigger computation.

## (4) Emergent unitarity / black-hole information — concrete STANCE, not a resolution
From what is PROVED: non-unitarity is G=iΩ (Krein ghost, `ghostKrein_nonUnitary`), tied to Ω; and Ω
is the order parameter of GL(N)→Sp(N) SSB (`sp_covariant`, `dil_moves_OmegaMin`). ⇒ unitarity is, in
this formalization, an ORDER-PARAMETER-DEPENDENT (emergent) property — exactly Arkani-Hamed's
"locality & unitarity are emergent, not fundamental", realized concretely (the ghost is a feature of
the broken/symplectic vacuum). Genuine conceptual contribution; NOT a resolution of the information
paradox. Do not overclaim.

## Literature placement (user's food-for-thought, accurate)
MZ theorem (inverse) = our locality⟺T-isolation; Vasiliev = the unbroken (non-local) phase;
Giombi–Yin = the HS-breaking mechanism / HS correlators; Arkani-Hamed (cosmological collider,
emergent locality/unitarity) = steps (2),(4); Unfolding school (Boulanger–Sezgin–Sundell) =
spacetime-from-VEVs. The synthesis (locality-SSB as a phase transition of the T-operator) is the
modern reframing uniting these — correctly situated.

## Net
One solid parameter-free win (1), one honest negative + correction (2), one clean partial pass (3),
one concrete-but-not-resolution stance (4). The theory's strongest concrete content is (1) the
scalar↔tensor correlation and (3) the positive averaged graviton mass — both parameter-free.
