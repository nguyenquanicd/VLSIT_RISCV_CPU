#!/usr/bin/env python3
"""Generate the retained Verilator timing/coverage C++ environment entrypoint."""
import argparse
import hashlib
import json
from pathlib import Path


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--template", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--force", action="store_true")
    args = parser.parse_args()
    template = args.template.resolve()
    output = args.out.resolve()
    if output.exists() and not args.force:
        raise SystemExit(f"refusing to overwrite generated file: {output}")
    output.parent.mkdir(parents=True, exist_ok=True)
    source = template.read_text(encoding="utf-8")
    if "Vtb_fence_i_end_to_end" not in source or "coveragep()->write()" not in source:
        raise SystemExit("template is missing expected model or coverage output")
    output.write_text(source, encoding="utf-8", newline="\n")
    manifest = {
        "schema_version": 1,
        "generator": "scripts/generators/generate_sim_main.py",
        "generator_version": "1.0.0",
        "template_sha256": sha(template),
        "output": output.name,
        "output_sha256": sha(output),
        "review_status": "reviewed",
        "purpose": "Verilator timed model entrypoint; emits native coverage after a completed simulation.",
    }
    output.with_suffix(output.suffix + ".generation.json").write_text(
        json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"GENERATED: {output}")
    print(f"SHA256: {manifest['output_sha256']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
