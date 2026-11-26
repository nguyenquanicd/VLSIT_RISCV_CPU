"""Build the RV32 cluster testbench with Verilator and run testcases.

Usage:
  python run.py build [--harts 2] [--profile 0]
  python run.py run TC-01 [TC-02 ...] [--harts 2] [--profile 0] [--fault N] [--boot-hi N] [--tag NAME]
  python run.py all            # every testcase of the plan on its configuration
Outputs: verification/rv32_profile/build/<cfg>/, runs/<tag or TC>/ (program, expectations, log, wave.vcd).
"""
from pathlib import Path
import argparse
import concurrent.futures
import json
import os
import re
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
TOOLS = Path('C:/Users/PC/Tools')
VERILATOR = TOOLS / 'oss-cad-suite/bin/verilator_bin.exe'
VROOT = TOOLS / 'oss-cad-suite/share/verilator'
GXX = TOOLS / 'msys64/ucrt64/bin/g++.exe'
INCLUDE_DIRS = [ROOT / p for p in (
    'rtl/common/third_party/axi_llc_locked/common_cells/include', 'rtl/common/third_party/axi_llc_locked/axi/include',
    'rtl/common/third_party/apb/include', 'rtl/common/third_party/register_interface/include',
    'rtl/common/third_party/tech_cells_generic/include', 'rtl/common/third_party/axi_llc/include')]
FILELIST = Path(os.environ['VLSIT_TB_FILELIST']) if os.environ.get('VLSIT_TB_FILELIST') else ROOT / 'rtl/rv32_profile/filelist_rv32.f'
FL_TAG = os.environ.get('VLSIT_TB_FL_TAG', '')                  # build-folder suffix for an alternative RV32 filelist
FILELIST64 = ROOT / 'rtl/non_coherence_cluster/filelist.f'      # 64-bit cluster (DEC-046/047 merged 2026-11-27)
FILELIST64_BASE = ROOT / 'rtl/coherence_fix/filelists/pre_merge/filelist_pre.f'  # pre-fix RTL snapshot, reproduces the TC-07 hang
BASE64 = os.environ.get('VLSIT_TB_BASE64', '0') == '1'           # set by --base-64
WAIVERS = ROOT / 'rtl/rv32_profile/lint/rv32_upstream_waivers.vlt'
SVA = ROOT / 'verification/rv32_profile/sva/m_vlsit_riscv_cpu_tile_rv32_sva.sv'
TB = HERE / 'tb/tb_rv32_cluster.sv'


# VLSIT_TB_TRACE_DEPTH > 1 makes a debug build with deep waveform (step 2b); it gets its own build folder.
TRACE_DEPTH = int(os.environ.get('VLSIT_TB_TRACE_DEPTH', '1'))


def cfg_name(harts, profile, xlen=32):
    return (f'rv{xlen}_{harts}h_p{profile}' + ('_base' if BASE64 and xlen == 64 else '')
            + (f'_t{TRACE_DEPTH}' if TRACE_DEPTH > 1 else '') + (f'_{FL_TAG}' if FL_TAG else ''))


def build(harts, profile, jobs, xlen=32):
    out = HERE / 'build' / cfg_name(harts, profile, xlen)
    out.mkdir(parents=True, exist_ok=True)
    mdir = out / ('obj_' + str(time.time_ns()))
    mdir.mkdir()
    env = os.environ.copy()
    env['VERILATOR_ROOT'] = str(VROOT)
    cmd = [str(VERILATOR), '--cc', '--exe', '--main', '--timing', '--assert', '--trace', '--trace-depth', str(TRACE_DEPTH),
           '--timescale', '1ns/1ps', '--top-module', 'tb_rv32_cluster', f'-GHARTS={harts}', f'-GPROFILE={profile}',
           '-Wno-fatal', '--output-split', '10000', '--Mdir', str(mdir)] + ([str(WAIVERS)] if xlen == 32 else ['-DTB_RV64'])
    cmd += [f'+incdir+{p.as_posix()}' for p in INCLUDE_DIRS] + [f'+incdir+{(HERE / "tb").as_posix()}']
    # The RV32 SVA bind and the faults use signals of the RV32 tile only; the 64-bit build omits them.
    cmd += ['-f', str(FILELIST), str(SVA), str(TB)] if xlen == 32 else ['-f', str(FILELIST64_BASE if BASE64 else FILELIST64), str(TB)]
    log = out / 'verilate.log'
    t0 = time.monotonic()
    with log.open('w') as f:
        res = subprocess.run(cmd, cwd=out, env=env, stdout=f, stderr=subprocess.STDOUT)
    print(f'verilate rc={res.returncode} ({time.monotonic() - t0:.0f}s) {log}', flush=True)
    if res.returncode:
        print(log.read_text(errors='replace')[-6000:])
        return 1
    rt = VROOT / 'include'
    srcs = sorted(mdir.glob('*.cpp')) + [rt / x for x in ('verilated.cpp', 'verilated_timing.cpp', 'verilated_threads.cpp',
                                                          'verilated_dpi.cpp', 'verilated_vcd_c.cpp')]

    def cc(s):
        o = mdir / (s.stem + '.o')
        c = [str(GXX), '-std=gnu++20', '-fcoroutines', '-O1', '-DVL_TIME_CONTEXT', '-DVM_TIMING=1', '-DVM_TRACE=1',
             '-DVM_TRACE_VCD=1', '-DVM_SC=0', '-DVM_COVERAGE=0', '-DVM_VPI=0', '-Wno-attributes', f'-I{mdir}', f'-I{rt}',
             f'-I{rt / "vltstd"}', '-c', str(s), '-o', str(o)]
        r = subprocess.run(c, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, env=env, text=True)
        if r.returncode:
            raise RuntimeError(f'{s}: {r.stdout[-3000:]}')
        return o
    objs = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=jobs) as pool:
        for fut in concurrent.futures.as_completed([pool.submit(cc, s) for s in srcs]):
            objs.append(fut.result())
            if len(objs) % 25 == 0 or len(objs) == len(srcs):
                print(f'compiled {len(objs)}/{len(srcs)} ({time.monotonic() - t0:.0f}s)', flush=True)
    exe = out / 'Vtb_rv32_cluster.exe'
    rsp = mdir / 'link.rsp'      # response file: deep-trace builds exceed the Windows command-line limit
    rsp.write_text(''.join(o.as_posix() + chr(10) for o in objs))
    r = subprocess.run([str(GXX), f'@{rsp.as_posix()}', '-pthread', '-latomic', '-o', str(exe)],
                       stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    if r.returncode:
        print(r.stdout[-4000:])
        return 1
    (out / 'build_info.json').write_text(json.dumps({'harts': harts, 'profile': profile, 'xlen': xlen, 'mdir': mdir.name,
                                                     'seconds': round(time.monotonic() - t0)}, indent=1))
    print(f'built {exe} in {time.monotonic() - t0:.0f}s', flush=True)
    return 0


def run_case(tc, harts, profile, fault=0, boot_hi=0, tag=None, timeout=400000, xlen=32):
    os.environ['VLSIT_TB_XLEN'] = str(xlen)      # read by asm_rv32.Prog before the program is built
    import tests
    run_dir = HERE / 'runs' / (tag or f'{tc}_{cfg_name(harts, profile, xlen)}' + (f'_f{fault}' if fault else '')
                                + (f'_bh{boot_hi}' if boot_hi else ''))
    run_dir.mkdir(parents=True, exist_ok=True)
    tests.write_case(tc, harts, run_dir)
    exe = HERE / 'build' / cfg_name(harts, profile, xlen) / 'Vtb_rv32_cluster.exe'
    env = os.environ.copy()
    t0 = time.monotonic()
    with (run_dir / 'sim.log').open('w') as f:
        res = subprocess.run([str(exe), f'+RUN={run_dir.as_posix()}', f'+FAULT={fault}', f'+BOOT_HI={boot_hi}',
                              f'+TIMEOUT={timeout}', f'+EXPERIMENT={os.environ.get("VLSIT_TB_EXPERIMENT", "0")}'], stdout=f, stderr=subprocess.STDOUT, env=env, timeout=3600)
    text = (run_dir / 'sim.log').read_text(errors='replace')
    verdict = 'PASS' if 'RESULT: PASS' in text and res.returncode == 0 else 'FAIL'
    m = re.search(r'checks passed: (\d+), checks failed: (\d+)', text)
    summary = {'tc': tc, 'xlen': xlen, 'harts': harts, 'profile': profile, 'fault': fault, 'boot_hi': boot_hi, 'rc': res.returncode,
               'verdict': verdict, 'passed': int(m.group(1)) if m else 0, 'failed': int(m.group(2)) if m else -1,
               'seconds': round(time.monotonic() - t0), 'run_dir': str(run_dir.relative_to(HERE))}
    (run_dir / 'result.json').write_text(json.dumps(summary, indent=1))
    print(json.dumps(summary), flush=True)
    return summary


def main():
    sys.path.insert(0, str(HERE))
    p = argparse.ArgumentParser()
    p.add_argument('cmd', choices=('build', 'run'))
    p.add_argument('tcs', nargs='*')
    p.add_argument('--harts', type=int, default=2)
    p.add_argument('--profile', type=int, default=0)
    p.add_argument('--fault', type=int, default=0)
    p.add_argument('--boot-hi', type=int, default=0)
    p.add_argument('--jobs', type=int, default=8)
    p.add_argument('--tag')
    p.add_argument('--timeout', type=int, default=400000)
    p.add_argument('--xlen', type=int, choices=(32, 64), default=32)
    p.add_argument('--base-64', action='store_true', help='64-bit build from the pre-fix RTL snapshot (no DEC-046/047)')
    a = p.parse_args()
    if a.base_64:
        global BASE64
        BASE64 = True
    if a.cmd == 'build':
        return build(a.harts, a.profile, a.jobs, a.xlen)
    rc = 0
    for tc in a.tcs:
        s = run_case(tc, a.harts, a.profile, a.fault, a.boot_hi, a.tag, a.timeout, a.xlen)
        rc |= s['verdict'] != 'PASS'
    return rc


if __name__ == '__main__':
    raise SystemExit(main())
