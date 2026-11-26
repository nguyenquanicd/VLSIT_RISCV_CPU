#!/usr/bin/env python3
"""Finish a generated model after a corrected custom C++ main was retained."""
import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) != 3 or sys.argv[2] not in ("2", "4"):
        raise SystemExit("usage: finalize_generated_model.py RUN_ROOT 2|4")
    run = Path(sys.argv[1]).resolve()
    harts = int(sys.argv[2])
    snapshot = Path(os.environ["VLSIT_SNAPSHOT"]).resolve()
    tc = json.loads((snapshot / "env/toolchain.json").read_text(encoding="utf-8"))
    runtime = Path(tc["runtime_include"])
    build = run / "build" / f"fence_{harts}h"
    objdir = build / "obj"
    main_cpp = build / "sim_main.cpp"
    template = snapshot / "scripts/generators/templates/sim_main.cpp.tpl"
    generator = snapshot / "scripts/generators/generate_sim_main.py"
    env = os.environ.copy()
    compiler = tc["compiler"]
    env["PATH"] = str(Path(compiler).parent) + os.pathsep + env.get("PATH", "")
    generate = subprocess.run([sys.executable, str(generator), "--template", str(template),
                               "--out", str(main_cpp), "--force"], cwd=build, env=env,
                              stdout=subprocess.PIPE, stderr=subprocess.STDOUT, check=False)
    (build / "finalize_generate.log").write_bytes(generate.stdout)
    if generate.returncode:
        return generate.returncode
    obj = build / "objects" / (main_cpp.stem + "_" + hashlib.sha1(str(main_cpp).encode()).hexdigest()[:8] + ".o")
    cmd = [compiler, "-std=gnu++20", "-fcoroutines", "-O0", "-DVL_TIME_CONTEXT", "-DVM_TIMING=1",
           "-DVM_TRACE=0", "-DVM_SC=0", "-DVM_COVERAGE=1", "-DVM_VPI=0", "-Wno-attributes",
           f"-I{objdir}", f"-I{runtime}", f"-I{runtime / 'vltstd'}", "-c", str(main_cpp), "-o", str(obj)]
    result = subprocess.run(cmd, cwd=build, env=env, stdout=subprocess.PIPE,
                            stderr=subprocess.STDOUT, check=False)
    (build / "finalize_compile_main.log").write_bytes(result.stdout)
    if result.returncode:
        return result.returncode
    objects = sorted((build / "objects").glob("*.o"))
    source_count = len(list(objdir.glob("*.cpp"))) + 1 + 5
    if len(objects) != source_count:
        raise SystemExit(f"expected {source_count} objects, found {len(objects)}")
    exe = build / "Vtb_fence_i_end_to_end.exe"
    response = build / "finalize_link.rsp"
    response.write_text("\n".join([*(f'"{p}"' for p in objects), "-pthread", "-latomic",
                                     "-o", f'"{exe}"']) + "\n", encoding="utf-8")
    link = subprocess.run([compiler, "@" + str(response)],
                          cwd=build, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, check=False)
    (build / "finalize_link.log").write_bytes(link.stdout)
    if link.returncode:
        return link.returncode
    if not exe.is_file() or exe.stat().st_size < 100_000:
        raise SystemExit("linked model executable is missing or unexpectedly small")
    print(f"FINALIZED: {exe}; warning count remains recorded in compile_summary.json")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
