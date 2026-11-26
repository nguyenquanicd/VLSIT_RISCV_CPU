"""Resume the retained two-hart FENCE.I hierarchy build with the emitted LLC."""
import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

from cluster_cmo_runner import build_hierarchical, context, sha
from resource_guard import run_logged


PLAN_RUN = "dual_hart_hier_002"
TOP = "tb_fence_i_end_to_end"
PREFIX = f"V{TOP}"


def windows_paths(text: str) -> str:
    # Retain SV literal escapes such as 32\\'h40 in Verilator argument files.
    return re.sub(r'([A-Za-z]:\\[^"]+)(?=")', lambda m: m[1].replace(chr(92), "/"), text)


def read(path: Path):
    return json.loads(path.read_text(encoding="utf-8-sig"))


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", type=Path)
    parser.add_argument("run_id")
    args = parser.parse_args()
    package = args.root.resolve()
    active = read(package / "env/workspace_manifest.json")
    root, snapshot, run, tools, _, env = context(package, active["baseline_id"], args.run_id)
    subprocess.run([sys.executable, str(root / "scripts/vlsit_sim_workspace.py"), "check",
                    "--root", str(root), "--baseline", active["baseline_id"]], cwd=root, check=True)
    old = root / "runs" / PLAN_RUN / "build/fence_2h_tp2_hier"
    former_obj = old / "obj"
    former_plan = former_obj / f"{PREFIX}.json"
    if PLAN_RUN not in read(root / "env/retention_catalog.json")["runs"]:
        raise RuntimeError("retained hierarchy plan is not in the verified run catalog")
    former_args = read(root / "runs" / PLAN_RUN / "resource_usage.json")["commands"][0]["command"]
    if former_args[0].casefold() != tools["verilator"].casefold() or any(
            option not in former_args for option in ("-GHARTS=2", "-GTIMING_PROFILE=2", "--hierarchical")):
        raise RuntimeError("retained plan execution is not the required tool/configuration")
    old_baseline = next(
        parent for parent in Path((old / "ordered_sources.f").read_text().splitlines()[0]).parents
        if parent.parent.name == "snapshots")
    old_manifest = read(old_baseline / "env/workspace_manifest.json")
    prefixes = ("dut/source/", "tb/fence_i_end_to_end/")
    select = lambda data: {key: value for key, value in data["files"].items() if key.startswith(prefixes)}
    if select(old_manifest) != select(active):
        raise RuntimeError("retained DUT/testbench inputs differ from the selected active baseline")

    build = run / "build" / "hier"
    objdir = build / "obj"
    objdir.mkdir(parents=True)
    plan = read(former_plan)
    old_obj = former_obj.as_posix()
    new_obj = objdir.as_posix()
    for entry in plan["submodules"]:
        part = entry["prefix"]
        expected = Path(entry["verilator_args"])
        corrected = windows_paths(expected.read_text(encoding="utf-8"))
        # The original partition controls remain in the sealed prior run.
        new_args = build / expected.name
        new_args.write_text(corrected, encoding="utf-8")
        entry["verilator_args"] = new_args.as_posix()
        entry["directory"] = Path(entry["directory"]).as_posix().replace(old_obj, new_obj, 1)
        entry["sources"] = [Path(source).as_posix().replace(old_obj, new_obj, 1)
                            for source in entry["sources"]]

    llc = next(entry for entry in plan["submodules"] if entry["prefix"].startswith("Vm_vlsit_axi_llc_"))
    directory = next(entry for entry in plan["submodules"] if "sharer_directory" in entry["prefix"])
    probe = root.parents[1] / "lint/non_coherence_cluster/hierarchy_llc_path_probe"
    probe_receipt = read(probe / "resource_usage.json")
    probe_args = probe_receipt["commands"][0]["command"]
    if (probe_receipt["status"] != "completed" or probe_args[0].casefold() != tools["verilator"].casefold()
            or (probe / "corrected_args.f").read_bytes() != Path(llc["verilator_args"]).read_bytes()):
        raise RuntimeError("emitted LLC arguments or tool differ from the retained partition plan")
    seen_sources = [Path(line.strip().strip('"')).as_posix()
                    for line in (probe / "sources.f").read_text(encoding="utf-8").splitlines()]
    if seen_sources != llc["sources"]:
        raise RuntimeError("emitted LLC input manifest differs from retained partition sources")
    retained = probe / "obj"
    artifacts = {path.name: sha(path) for path in sorted(retained.iterdir())
                 if path.is_file() and path.suffix in {".cpp", ".h", ".sv", ".json"}}
    if not artifacts or len(list(retained.glob("*.sv"))) != 1:
        raise RuntimeError("missing generated LLC partition or RTL wrapper")

    # This directory module has no imports, include directives or child modules.
    # Restrict only that partition's parse step to its standalone source.
    directory["sources"] = [source for source in directory["sources"]
                            if source.endswith("/m_vlsit_riscv_sharer_directory.sv")]
    if len(directory["sources"]) != 1:
        raise RuntimeError("missing standalone directory source")
    (build / "resume.json").write_text(json.dumps({
        "active_baseline": active["baseline_id"], "plan_baseline": old_manifest["baseline_id"],
        "plan_run": PLAN_RUN, "plan_sha256": sha(former_plan), "llc_artifacts": artifacts,
        "llc_probe_receipt_sha256": sha(probe / "resource_usage.json"), "invocation": sys.argv,
        "verilator_sha256": sha(Path(tools["verilator"])),
    }, indent=2), encoding="utf-8")
    (build / "resumed_plan.json").write_text(json.dumps(plan, indent=2), encoding="utf-8")
    exe = build_hierarchical([], TOP, objdir, build, tools, env, plan=plan,
                             retained={llc["prefix"]: retained})
    wave = run / "waveforms" / "dual_hart_fence_p2.vcd"
    wave.parent.mkdir()
    log = run / "simulation.log"
    run_logged([str(exe), "+INJECT_ERROR=0", f"+BLOCK_WAVE={wave.as_posix()}"],
               exe.parent, env, log, 600)
    text = log.read_text(encoding="utf-8", errors="replace")
    if ("PASS: real CVA6 FENCE.I" not in text or "CHECK profile=2 PMU CCU request snapshot=" not in text
            or "PROFILE_METRICS" not in text or not wave.is_file()):
        raise RuntimeError("simulation did not produce the required CPU/PMU pass and VCD evidence")
    with wave.open(encoding="ascii") as stream:
        if not any(line.startswith("#") for line in stream):
            raise RuntimeError("VCD has no sampled transitions")
    print(f"PASS: dual-hart FENCE.I/PMU, VCD={wave}", flush=True)


if __name__ == "__main__":
    main()
