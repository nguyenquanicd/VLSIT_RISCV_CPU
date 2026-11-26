"""Compare five real-CVA6 CPU scenarios for timing profiles 0 and 2."""
import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

from cluster_cmo_runner import compile_harts, context
from resource_guard import run_logged

TESTS = "tests/t/n"
# Each scenario uses the production cluster hierarchy and a retained CPU program.
SUITE = (
    ("holder", f"{TESTS}/directory_holder_end_to_end/tb_directory_holder_end_to_end.sv",
     "PASS: real holder lifecycle", "dirty_eviction.hex", (("dirty", "+CASE_ID=0"),)),
    ("atomic", f"{TESTS}/atomic_end_to_end/tb_atomic_end_to_end.sv",
     "PASS: real cached AMO/LR-SC", "lrsc_contention.hex", (("contention", "+INJECT_ERROR=0"),)),
    ("eviction", f"{TESTS}/l1_eviction_end_to_end/tb_l1_eviction_end_to_end.sv",
     "PASS: real ordinary L1 eviction", "program.hex",
     (("okay", "+INJECT_ERROR=0"), ("slverr", "+INJECT_ERROR=2"))),
    ("cbo", f"{TESTS}/cmo_end_to_end/tb_cmo_end_to_end.sv",
     "PASS: real CVA6 CBO", None, (("okay", "+INJECT_ERROR=0"), ("slverr", "+INJECT_ERROR=1"))),
    ("fence", "tb/fence_i_end_to_end/tb_fence_i_end_to_end.sv",
     "PASS: real CVA6 FENCE.I", None, (("okay", "+INJECT_ERROR=0"), ("slverr", "+INJECT_ERROR=1"))),
)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", type=Path)
    parser.add_argument("baseline")
    parser.add_argument("run_id")
    parser.add_argument("--profile", type=int, choices=(0, 2))
    parser.add_argument("--harts", type=int, choices=(2, 4))
    parser.add_argument("--scenario", choices=tuple(row[0] for row in SUITE))
    parser.add_argument("--variant")
    parser.add_argument("--block-wave", action="store_true")
    parser.add_argument("--hierarchical", action="store_true", help="build LLC and directory separately")
    parser.add_argument("--low-ram", action="store_true", help="disable module inlining during Verilation")
    parser.add_argument("--wave-start-ns", type=int, default=0)
    parser.add_argument("--wave-end-ns", type=int, default=20000)
    args = parser.parse_args()
    if args.block_wave and (args.harts != 2 or args.scenario != "fence"):
        parser.error("--block-wave requires --harts 2 --scenario fence")
    if not 0 <= args.wave_start_ns < args.wave_end_ns <= 100000:
        parser.error("wave window must satisfy 0 <= start < end <= 100000 ns")
    if args.variant and not any(args.variant == variant[0] for name, _, _, _, variants in SUITE
                               if args.scenario in (None, name) for variant in variants):
        parser.error("variant is not defined for the selected scenario")
    root, snapshot, run, tools, order, env = context(args.root, args.baseline, args.run_id)
    subprocess.run([sys.executable, str(snapshot / "scripts/vlsit_sim_workspace.py"), "check",
                    "--root", str(root), "--baseline", args.baseline], check=True, cwd=root)
    run.mkdir(parents=True)
    # Retain partial evidence if a later build or case fails.
    with (run / "results.jsonl").open("x", encoding="utf-8") as results:
        for profile in ((0, 2) if args.profile is None else (args.profile,)):
            for harts in ((2, 4) if args.harts is None else (args.harts,)):
                for name, source, marker, image, variants in SUITE:
                    if args.scenario and name != args.scenario:
                        continue
                    variants = tuple(item for item in variants if args.variant in (None, item[0]))
                    if not variants:
                        continue
                    model = compile_harts(snapshot, run, tools, order, env, harts, False,
                                          profile=profile, top=Path(source).stem, test_path=source,
                                          low_ram=args.low_ram, hierarchical=args.hierarchical)
                    for kind, option in variants:
                        cmd = [str(model), option]
                        if image:
                            cmd.append(f"+PROGRAM={snapshot / Path(source).parent / image}")
                        case = f"p{profile}_{harts}h_{name}_{kind}"
                        log = run / "reports" / f"{case}.log"
                        waveform = None
                        if args.block_wave:
                            waveform = run / "waveforms" / f"{case}.vcd"
                            waveform.parent.mkdir(exist_ok=True)
                            cmd.extend((f"+BLOCK_WAVE={waveform.as_posix()}",
                                        f"+TRACE_START_NS={args.wave_start_ns}",
                                        f"+TRACE_END_NS={args.wave_end_ns}"))
                        run_logged(cmd, model.parent, env, log, 600)
                        output = log.read_text(encoding="utf-8", errors="replace")
                        match = next((line for line in output.splitlines() if marker in line), "")
                        cycles = re.search(r"cycles=(\d+)", match)
                        if not cycles or (name == "fence" and profile == 2 and
                                          "CHECK profile=2 PMU CCU request snapshot=" not in output):
                            raise RuntimeError(f"missing pass evidence for {case}: {log}")
                        counters = re.search(
                            r"PROFILE_METRICS cycles=(\d+) retired=(\d+) mem_r=(\d+) mem_w=(\d+)", output)
                        if not counters or int(counters[1]) == 0 or int(counters[2]) == 0:
                            raise RuntimeError(f"missing CPU/AXI performance counters for {case}: {log}")
                        if waveform:
                            with waveform.open(encoding="ascii") as stream:
                                if not any(line.startswith("#") for line in stream):
                                    raise RuntimeError(f"waveform contains no sampled transition: {waveform}")
                        active, retired, read_beats, write_beats = map(int, counters.groups())
                        print(f"PASS {case}: {cycles[1]} cycles, cluster IPC {retired / active:.3f}", flush=True)
                        results.write(json.dumps(dict(case=case, profile=profile, harts=harts,
                                                      scenario=name, variant=kind,
                                                      cycles=int(cycles[1]), baseline=args.baseline, low_ram=args.low_ram,
                                                      hierarchical=args.hierarchical,
                                                      active_cycles=active, instructions_retired=retired,
                                                      cluster_ipc=retired / active,
                                                      memory_read_beats=read_beats,
                                                      memory_write_beats=write_beats,
                                                      waveform=str(waveform.relative_to(run)) if waveform else None,
                                                      log=str(log.relative_to(run)))) + "\n")
                        results.flush()


if __name__ == "__main__":
    main()
