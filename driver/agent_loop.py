#!/usr/bin/env python3
"""
dS4-LeanCheck — automated Generator/Verifier loop.

Orchestrates a closed loop between an Anthropic Claude model (the *generator*) and the
local Lean 4 / Mathlib toolchain (the *verifier*):

    [ Claude generates a Lean module ]
                 │
                 ▼
    [ lake build <module> ]  ──success──►  save validated dictionary, stop
                 │
              failure
                 │
                 ▼
    [ compiler errors fed back to Claude ]  ──► next iteration

The generated module is required to `import Ds4Verification.Core` and to instantiate the
`HolographicDS4Hypothesis` contract (boundary Hilbert space + dictionary + a
`DeSitterUniverse` instance with a real Λ > 0 proof). If it doesn't actually type-check,
Lean rejects it and the error is fed back.

Usage:
    pip install -r driver/requirements.txt
    export ANTHROPIC_API_KEY=sk-ant-...        # PowerShell: $env:ANTHROPIC_API_KEY="sk-ant-..."
    python driver/agent_loop.py --iterations 5

Run with --dry-run to exercise the loop wiring without calling the API or the compiler.
"""
from __future__ import annotations

import argparse
import datetime as _dt
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

# Project layout ------------------------------------------------------------------------
PROJECT_ROOT = Path(__file__).resolve().parent.parent
CORE_PATH = PROJECT_ROOT / "Ds4Verification" / "Core.lean"
EXAMPLE_PATH = PROJECT_ROOT / "Ds4Verification" / "Example.lean"
GENERATED_MODULE = "Ds4Verification.Generated"
GENERATED_PATH = PROJECT_ROOT / "Ds4Verification" / "Generated.lean"
RUNS_DIR = PROJECT_ROOT / "runs"

DEFAULT_MODEL = "claude-opus-4-8"

SYSTEM_PROMPT = """\
You are an advanced mathematical-physics translation engine specialized in Lean 4 + Mathlib.
Your objective is to generate a candidate instantiation of the `HolographicDS4Hypothesis`
contract defined in `Ds4Verification.Core`.

Hard constraints:
1. Output ONE Lean 4 code block and nothing else. No prose outside the ```lean fence.
2. The module MUST begin with `import Ds4Verification.Core` and `open Ds4`.
3. Define a CONCRETE `BoundaryHilbertSpace` (e.g. `EuclideanSpace ℂ (Fin n)`), a
   `MetricField Real4D` (covariant `g` + its inverse `gInv`, with proofs of `IsSymm` and
   `g * gInv = 1`), a `holographic_dictionary`, and a `DeSitterUniverse` instance.
4. The `DeSitterUniverse` instance must discharge ALL real obligations with honest proofs:
   `pos_Λ` (Λ > 0), `einstein` (Ric = Λ • g), `scalar_curvature` (gᵘᵛ Ric_μν = 4Λ), and
   `lorentzian` (∃ invertible P, Pᵀ g P = minkowski — the (-,+,+,+) signature).
5. NEVER use `sorry`, `admit`, or `native_decide`. Proofs must be complete and honest.
6. Produce a novel mapping (vary the boundary theory / Λ expression / frame P), not a copy
   of the seed.
"""

SEED_TASK = (
    "Generate a NOVEL instantiation mapping a 3D CFT stress-tensor anomaly mode to a dS4 "
    "metric. Use the Core framework below as the contract you must satisfy, and the seed "
    "example as a style reference (do not copy it verbatim).\n\n"
    "=== Ds4Verification/Core.lean ===\n{core}\n\n"
    "=== Seed example (style reference) ===\n{example}\n"
)

CODE_FENCE = re.compile(r"```(?:lean)?\s*(.*?)```", re.DOTALL)


def log(msg: str) -> None:
    stamp = _dt.datetime.now().strftime("%H:%M:%S")
    print(f"[{stamp}] {msg}", flush=True)


def extract_lean(text: str) -> str:
    """Pull the first fenced code block; fall back to the raw text."""
    m = CODE_FENCE.search(text)
    code = (m.group(1) if m else text).strip()
    if "import Ds4Verification.Core" not in code:
        code = "import Ds4Verification.Core\nopen Ds4\n\n" + code
    return code + "\n"


def load_dotenv() -> None:
    """Load driver/.env (simple KEY=VALUE lines) into os.environ if present."""
    env_file = Path(__file__).resolve().parent / ".env"
    if not env_file.exists():
        return
    for line in env_file.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, val = line.partition("=")
        os.environ.setdefault(key.strip(), val.strip())


def _elan_bin() -> Path:
    return Path.home() / ".elan" / "bin"


def _lake_env() -> dict:
    """A PATH that includes elan's bin dir (elan installs to ~/.elan/bin)."""
    env = os.environ.copy()
    if _elan_bin().is_dir():
        env["PATH"] = str(_elan_bin()) + os.pathsep + env.get("PATH", "")
    return env


def _lake_exe() -> str:
    """Full path to the `lake` executable. On Windows, subprocess resolves the
    program from the parent PATH (not the child env), so we locate it ourselves."""
    found = shutil.which("lake", path=_lake_env()["PATH"])
    if found:
        return found
    for name in ("lake.exe", "lake"):
        cand = _elan_bin() / name
        if cand.exists():
            return str(cand)
    return "lake"  # last resort; will raise a clear FileNotFoundError if truly missing


def compile_module(module: str) -> tuple[bool, str]:
    """Invoke `lake build <module>` and report (ok, combined_output)."""
    proc = subprocess.run(
        [_lake_exe(), "build", module],
        cwd=PROJECT_ROOT,
        capture_output=True,
        text=True,
        env=_lake_env(),
    )
    out = (proc.stdout or "") + (proc.stderr or "")
    # Lean emits `sorry`/`error:` markers even at returncode 0 in some configs; treat any
    # `error:` (or a leftover sorry) as a verification failure.
    ok = proc.returncode == 0 and "error:" not in out and "sorry" not in out.lower()
    return ok, out.strip()


def call_claude(client, model: str, system: str, prompt: str) -> str:
    msg = client.messages.create(
        model=model,
        max_tokens=4096,
        system=system,
        messages=[{"role": "user", "content": prompt}],
    )
    # Concatenate any text blocks in the response.
    return "".join(getattr(b, "text", "") for b in msg.content)


def make_client(dry_run: bool):
    if dry_run:
        return None
    load_dotenv()
    try:
        import anthropic
    except ImportError:
        sys.exit("anthropic SDK not installed. Run: pip install -r driver/requirements.txt")
    if not os.environ.get("ANTHROPIC_API_KEY"):
        sys.exit("ANTHROPIC_API_KEY is not set (export it, or put it in driver/.env).")
    return anthropic.Anthropic()


def run_verification_loop(iterations: int, model: str, dry_run: bool) -> int:
    client = make_client(dry_run)
    core_lean = CORE_PATH.read_text(encoding="utf-8")
    example_lean = EXAMPLE_PATH.read_text(encoding="utf-8") if EXAMPLE_PATH.exists() else ""
    RUNS_DIR.mkdir(exist_ok=True)

    prompt = SEED_TASK.format(core=core_lean, example=example_lean)

    for i in range(1, iterations + 1):
        log(f"--- Iteration {i}/{iterations} ---")

        if dry_run:
            generated = (
                "```lean\nimport Ds4Verification.Core\nopen Ds4\n"
                "-- (dry-run placeholder; no API call made)\n```"
            )
        else:
            log(f"Querying {model} ...")
            generated = call_claude(client, model, SYSTEM_PROMPT, prompt)

        code = extract_lean(generated)
        GENERATED_PATH.write_text(code, encoding="utf-8")
        (RUNS_DIR / f"iter_{i:02d}.lean").write_text(code, encoding="utf-8")

        if dry_run:
            log("Dry run: skipping `lake build`. Wrote Ds4Verification/Generated.lean.")
            return 0

        log(f"Verifying with `lake build {GENERATED_MODULE}` ...")
        ok, output = compile_module(GENERATED_MODULE)
        (RUNS_DIR / f"iter_{i:02d}.log").write_text(output, encoding="utf-8")

        if ok:
            log("🎉 Success! Valid holographic dictionary generated and verified.")
            artifact = RUNS_DIR / "validated_dictionary.lean"
            artifact.write_text(code, encoding="utf-8")
            log(f"Saved validated artifact -> {artifact.relative_to(PROJECT_ROOT)}")
            return 0

        log("❌ Verification failed. Feeding compiler errors back to the model.")
        prompt = (
            "Your previous Lean 4 code failed to type-check. Compiler output:\n\n"
            f"{output}\n\n"
            "Fix the type mismatches / proof errors and regenerate the FULL module "
            "(still importing Ds4Verification.Core, still no `sorry`)."
        )

    log(f"Reached the {iterations}-iteration limit without a verified dictionary.")
    return 1


def parse_args(argv: list[str]) -> argparse.Namespace:
    p = argparse.ArgumentParser(description="dS4-LeanCheck generator/verifier loop.")
    p.add_argument("--iterations", type=int, default=5, help="max self-correction rounds")
    p.add_argument("--model", default=os.environ.get("DS4_MODEL", DEFAULT_MODEL))
    p.add_argument("--dry-run", action="store_true",
                   help="exercise the loop wiring without calling the API or compiler")
    return p.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv if argv is not None else sys.argv[1:])
    return run_verification_loop(args.iterations, args.model, args.dry_run)


if __name__ == "__main__":
    raise SystemExit(main())
