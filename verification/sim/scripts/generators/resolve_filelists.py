#!/usr/bin/env python3
"""Flatten the retained cluster filelist closure into package-relative inputs."""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

EXTENSIONS = {".sv", ".v", ".vh", ".svh"}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--project-root", type=Path, default=None,
                        help="original tree prefix only needed while materializing copied absolute filelists")
    args = parser.parse_args()
    root = args.root.resolve()
    source_root = root / "dut/source"
    project_root = args.project_root.resolve() if args.project_root else None
    ordered: list[str] = []
    include_dirs: list[str] = []
    seen_files: set[str] = set()
    seen_includes: set[str] = set()
    active: set[Path] = set()

    def localize(raw: str, owner: Path) -> Path:
        item = raw.strip().strip('"').replace("\\", "/")
        if re.match(r"^[A-Za-z]:/", item):
            if project_root is None:
                rel = item.split("/VLSIT_RISCV_CPU/", 1)
                if len(rel) != 2:
                    raise RuntimeError(f"absolute path outside source project: {raw}")
                path = source_root / rel[1]
            else:
                path = Path(item)
                try:
                    rel = path.resolve().relative_to(project_root)
                except ValueError as exc:
                    raise RuntimeError(f"filelist path outside original project: {raw}") from exc
                path = source_root / rel
        else:
            path = (owner.parent / item).resolve()
            if source_root.resolve() not in path.parents and path != source_root.resolve():
                path = source_root / item.lstrip("./")
        path = path.resolve()
        if source_root.resolve() not in path.parents:
            raise RuntimeError(f"localized path escapes DUT snapshot: {raw} -> {path}")
        return path

    def consume(filelist: Path) -> None:
        filelist = filelist.resolve()
        if filelist in active:
            raise RuntimeError(f"recursive filelist cycle: {filelist}")
        if not filelist.is_file():
            raise RuntimeError(f"missing filelist: {filelist}")
        active.add(filelist)
        for raw in filelist.read_text(encoding="utf-8-sig").splitlines():
            line = raw.split("//", 1)[0].strip()
            if not line or line.startswith("#"):
                continue
            if line.startswith("-f ") or line.startswith("-F "):
                child = localize(line.split(None, 1)[1], filelist)
                consume(child)
                continue
            if line.startswith("+incdir+"):
                for token in line[len("+incdir+"):].split("+"):
                    path = localize(token, filelist)
                    rel = path.relative_to(root).as_posix()
                    if not path.is_dir():
                        raise RuntimeError(f"missing include directory: {rel}")
                    if rel not in seen_includes:
                        include_dirs.append(rel)
                        seen_includes.add(rel)
                continue
            token = line.split()[0]
            if Path(token.replace("\\", "/")).suffix.lower() not in EXTENSIONS:
                continue
            path = localize(token, filelist)
            rel = path.relative_to(root).as_posix()
            if not path.is_file():
                raise RuntimeError(f"missing HDL source: {rel}")
            if rel not in seen_files:
                ordered.append(rel)
                seen_files.add(rel)
        active.remove(filelist)

    top_filelist = source_root / "rtl/non_coherence_cluster/filelist.f"
    consume(top_filelist)
    # Match the production TOP lint include precedence. The locked LLC's
    # common_cells headers must win over the CVA6 snapshot with the same names.
    required_first = [
        "rtl/common/third_party/axi_llc_locked/common_cells/include",
        "rtl/common/third_party/axi_llc_locked/axi/include",
        "rtl/common/third_party/apb/include",
        "rtl/common/third_party/register_interface/include",
        "rtl/common/third_party/tech_cells_generic/include",
        "rtl/common/third_party/axi_llc/include",
    ]
    first_dirs = []
    for rel in required_first:
        path = source_root / rel
        package_rel = path.relative_to(root).as_posix()
        if not path.is_dir():
            # Some vendor integrations pass an empty/nonexistent optional -I.
            # Record only directories materialized in the isolated package.
            continue
        if package_rel not in seen_includes:
            first_dirs.append(package_rel)
            seen_includes.add(package_rel)
    include_dirs = first_dirs + include_dirs
    result = {
        "schema_version": 1,
        "top": "m_vlsit_riscv_cluster_axi_top",
        "source_order": ordered,
        "include_dirs": include_dirs,
        "source_count": len(ordered),
        "filelist_root": "dut/source/rtl/non_coherence_cluster/filelist.f",
    }
    output = root / "env/source_order.json"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(f"SOURCE CLOSURE: {len(ordered)} HDL files; {len(include_dirs)} include directories")
    print(f"OUTPUT: {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
