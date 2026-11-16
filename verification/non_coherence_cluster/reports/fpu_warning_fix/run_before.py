"""Build and run real CVA6 instructions through the production cluster TOP."""
from pathlib import Path
import argparse
import concurrent.futures
import os
import re
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / 'scripts'))
from run_cluster_top_lint import INCLUDE_DIRS, REPORT_DIR
from lint_source_overrides import apply_overrides

def main():
    apply_overrides()
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--harts', type=int, choices=(2,4), required=True)
    p.add_argument('--error', type=int, choices=(0,1), default=0)
    p.add_argument('--supervisor', action='store_true')
    p.add_argument('--jobs', type=int, default=2)
    p.add_argument('--run-only', action='store_true')
    args = p.parse_args()
    toolroot = Path('C:/Users/PC/Tools/oss-cad-suite')
    verilator = toolroot / 'bin/verilator_bin.exe'
    runtime = toolroot / 'share/verilator/include'
    compiler = Path('C:/Users/PC/Tools/msys64/ucrt64/bin/g++.exe')
    build = (ROOT / 'verification/non_coherence_cluster/build') / f'fence_cpu_{args.harts}h'
    report = ROOT / 'verification/non_coherence_cluster/reports/fence_i_end_to_end'
    report.mkdir(parents=True, exist_ok=True)
    build.mkdir(parents=True, exist_ok=True)
    env = os.environ.copy()
    env['VERILATOR_ROOT'] = str(runtime.parent)
    top = 'tb_fence_i_end_to_end'
    exe = build / f'V{top}.exe'
    if not args.run_only:
        # Preserve production source verbatim except the private verification module name.
        original = (ROOT / 'rtl/common/vlsit/cache/m_vlsit_axi_llc.sv').read_text(encoding='utf-8')
        Path(__file__).with_name('m_vlsit_axi_llc_native.sv').write_text(
            original.replace('module m_vlsit_axi_llc #(', 'module m_vlsit_axi_llc_native #('),encoding='utf-8')
        # Generate into a fresh directory: specialization names may change after
        # RTL edits, and stale generated .cpp files must never enter this build.
        build = build / ('build_' + str(time.time_ns()))
        build.mkdir()
        command = [str(verilator), '--cc', '--exe', '--main', '--timing', '--assert',
                   '--timescale','1ns/1ps','-Wno-fatal','-Wno-TIMESCALEMOD',
                   '--top-module',top,f'-GHARTS={args.harts}',
                   '--output-split','10000','--Mdir',str(build)]
        command += [f'+incdir+{x.as_posix()}' for x in INCLUDE_DIRS]
        flist = (REPORT_DIR / 'filelist_vlsit_cluster.f').read_text()
        flist = '\n'.join(x for x in flist.splitlines() if not x.endswith('/m_vlsit_axi_llc.sv'))
        shim_flist = report / 'filelist_cluster_fault_bfm.f'
        shim_flist.write_text(flist + '\n' + str(Path(__file__).with_name('m_vlsit_axi_llc_native.sv')).replace('\\','/') + '\n' + str(Path(__file__).with_name('m_vlsit_axi_llc.sv')).replace('\\','/') + '\n')
        command += ['-f','C:/HQuan/102_MyGithub/VLSIT_RISCV_CPU/rtl/common/filelists/cva6_flush_path/cva6_modified_cache.Flist',
                    '-f','filelist_llc_unique.f','-f',str(shim_flist),
                    str(Path(__file__).with_name('tb_fence_i_end_to_end.sv'))]
        model_log = report / f'model_{args.harts}h.log'
        print(f'Generating {args.harts}-hart instruction model: {model_log}', flush=True)
        with model_log.open('w') as f:
            result = subprocess.run(command,cwd=REPORT_DIR,env=env,stdout=f,stderr=subprocess.STDOUT)
        if result.returncode:
            print(model_log.read_text(errors='replace')[-8000:])
            return result.returncode
        sources = sorted(build.glob('*.cpp'))
        sources += [runtime / x for x in ('verilated.cpp','verilated_timing.cpp',
                                          'verilated_threads.cpp','verilated_dpi.cpp')]
        def compile_one(source):
            obj = build / (source.stem + '.o')
            log = build / (source.stem + '.compile.log')
            cmd = [str(compiler),'-std=gnu++20','-fcoroutines','-O0','-DVL_TIME_CONTEXT',
                   '-DVM_TIMING=1','-DVM_TRACE=0','-DVM_SC=0','-DVM_COVERAGE=0','-DVM_VPI=0',
                   '-Wno-attributes',f'-I{build}',f'-I{runtime}',f'-I{runtime / "vltstd"}',
                   '-c',str(source),'-o',str(obj)]
            with log.open('w') as f:
                result = subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,env=env)
            if result.returncode:
                raise RuntimeError(f'{source}: {log.read_text(errors="replace")[-3000:]}')
            return obj
        objects = []
        started = time.monotonic()
        with concurrent.futures.ThreadPoolExecutor(max_workers=args.jobs) as pool:
            futures = [pool.submit(compile_one,s) for s in sources]
            for future in concurrent.futures.as_completed(futures):
                objects.append(future.result())
                if len(objects)==1 or len(objects)%20==0 or len(objects)==len(sources):
                    print(f'Compiled {len(objects)}/{len(sources)} ({time.monotonic()-started:.0f}s)',flush=True)
        link_log = report / f'link_{args.harts}h.log'
        with link_log.open('w') as f:
            result = subprocess.run([str(compiler)]+[str(x) for x in objects]+
                                    ['-pthread','-latomic','-o',str(exe)],stdout=f,stderr=subprocess.STDOUT)
        if result.returncode:
            print(link_log.read_text(errors='replace')[-5000:])
            return result.returncode
    suffix = '_supervisor' if args.supervisor else ''
    log = report / f'simulation_{args.harts}h_error{args.error}{suffix}.log'
    print(f'Executing real instruction test: {log}',flush=True)
    with log.open('w') as f:
        result = subprocess.run([str(exe),f'+INJECT_ERROR={args.error}',f'+SUPERVISOR={int(args.supervisor)}',
                                 f'+WAVE={(report / f"service_{args.harts}h_error{args.error}{suffix}.vcd").as_posix()}'],env=env,
                                stdout=f,stderr=subprocess.STDOUT,timeout=180)
    evidence = log.read_text(errors='replace')
    hits = re.findall(r'AXI-IHI0022 ASSERT (\d+) hits=(\d+)',evidence)
    checks_pass = len(hits)==20 and all(int(count)>0 for _,count in hits)
    if result.returncode==0 and ('PASS: real CVA6 FENCE.I' not in evidence or not checks_pass):
        print('FAIL: missing functional PASS or exercised assertion evidence')
        return 1
    if result.returncode==0:
        with log.open('a') as f:
            f.write('assertion failures: 0, assertions never exercised: 0\n')
    print(log.read_text(errors='replace')[-10000:])
    return result.returncode

if __name__ == '__main__':
    raise SystemExit(main())
