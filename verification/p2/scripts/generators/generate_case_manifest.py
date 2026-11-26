#!/usr/bin/env python3
"""Validate and materialize a deterministic initial qualification case list."""
import argparse
import hashlib
import json
from pathlib import Path


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()
    root = args.root.resolve()
    source = root / "tests/qualification_case_matrix.json"
    output = root / "tests/generated/initial_case_manifest.json"
    if output.exists() and not args.force:
        raise SystemExit(f"refusing to overwrite generated file: {output}")
    data = json.loads(source.read_text(encoding="utf-8"))
    cases = data.get("cases", [])
    ids = [case.get("id") for case in cases]
    if len(ids) != 4 or len(ids) != len(set(ids)):
        raise SystemExit("initial qualification matrix must contain four unique cases")
    expected = {f"H{h}_FENCEI_{kind}" for h in (2, 4) for kind in ("SUCCESS", "AXI_ERROR")}
    if set(ids) != expected:
        raise SystemExit("matrix does not cover the approved two/four-hart success/error cross")
    result = {
        "schema_version": 1,
        "generator": "scripts/generators/generate_case_manifest.py",
        "generator_version": "1.0.0",
        "input": "tests/qualification_case_matrix.json",
        "input_sha256": sha(source),
        "cases": cases,
        "review_status": "G0 approved; initial scope only, not full HDS closure",
    }
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    manifest = {
        "schema_version": 1,
        "testcase_generator": {
            "command": "python scripts/generators/generate_case_manifest.py --root .",
            "input": "tests/qualification_case_matrix.json",
            "input_sha256": sha(source),
            "output": "tests/generated/initial_case_manifest.json",
            "output_sha256": sha(output),
            "version": "1.0.0",
            "review_status": result["review_status"],
        },
        "environment_component_generator": {
            "generator": "scripts/generators/generate_sim_main.py",
            "template": "scripts/generators/templates/sim_main.cpp.tpl",
            "version": "1.0.0",
            "review_status": "reviewed; generated per fresh run and retained with build artifacts",
        },
    }
    (root / "scripts/generators/generation_manifest.json").write_text(
        json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"GENERATED: {output.relative_to(root)} ({len(cases)} cases)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
