"""graviton_probe.py — UNVALIDATED order-of-magnitude probe of the graviton mass γ_2.

*** THIS IS NOT A RESULT. *** It is option (a): a labeled estimate to see "roughly where it lands",
since the one missing ingredient α(d)=1/β₃^{connected} is genuinely uncomputed (literature check (b)
found no usable large-N value). We BRACKET α and read off the scale of γ_2. Do NOT cite the number.

Structure (CGS 2107.08052 eq. 7.32, near crossover, paper convention s_p):
   γ_2 = (2 α δ / Γ(d/2)) · γ_φ̂ ,   δ=(s*−s_p)/2,   γ_φ̂ = η/2 = η₁/(2N),   η₁(3)=8/(3π²).
Sign is solid (γ_2>0, from β₃>0); only α (hence magnitude) is the gap. α bracketed:
   0.01 (small) … 0.0816 (the N=1 Ising α=1/β₃) … 0.3 (a few× larger) — NOT the O(N) value.
"""
from __future__ import annotations
import sys
import mpmath as mp
mp.mp.dps = 20
try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass

d = mp.mpf(3)
eta1 = 8 / (3 * mp.pi ** 2)            # short-range O(N) η coefficient, d=3 (verified)
gphi = eta1 / 2                         # γ_φ̂ = η/2  (×1/N)
Gam = mp.gamma(d / 2)                   # Γ(3/2)=√π/2

print("=== UNVALIDATED graviton-mass probe  γ_2 = (2αδ/Γ(3/2))·γ_φ̂  (×1/N) — NOT A RESULT ===\n")
print(f"  fixed: η₁=8/(3π²)={mp.nstr(eta1,5)}, γ_φ̂=η₁/2={mp.nstr(gphi,5)}·(1/N), Γ(3/2)={mp.nstr(Gam,5)}\n")
print("  s_p (paper)   δ=(2−s_p)/2     γ_2  for  α = 0.01 / 0.0816 / 0.30   (units 1/N)")
for sp in [mp.mpf('1.9'), mp.mpf('1.8'), mp.mpf('1.6'), mp.mpf('1.4')]:
    delta = (2 - sp) / 2               # s*≈2 at leading N
    row = []
    for a in [mp.mpf('0.01'), mp.mpf('0.0816'), mp.mpf('0.30')]:
        g2 = (2 * a * delta / Gam) * gphi
        row.append(mp.nstr(g2, 3))
    print(f"   s_p={mp.nstr(sp,3)}      δ={mp.nstr(delta,3):>6}        "
          f"{row[0]:>9} / {row[1]:>9} / {row[2]:>9}")

print("\n--- reading (heavily caveated) ---")
print("γ_2 (graviton mass², in 1/N units) lands around 10^-4 … 10^-2 across this bracket — i.e. SMALL")
print("and POSITIVE, growing linearly into the long-range phase (∝ δ). That is the only robust")
print("content: SCALE ~ 1e-3/N, sign +, vanishing at the crossover. The PRECISE value needs the")
print("connected β₃ (O(N) σ-exchange integral) — uncomputed, unchecked. DO NOT treat any cell as a")
print("prediction; it is a bracket over a guessed α. The graviton mass = the locality order parameter")
print("= the same ε as the CMB tilt (n_s−1=2ε): small, positive, 1/N-suppressed.")
