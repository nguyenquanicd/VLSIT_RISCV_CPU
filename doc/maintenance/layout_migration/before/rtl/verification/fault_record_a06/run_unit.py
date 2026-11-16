"""Build and run CCU fabric units, including concurrent same-bank contexts."""
from pathlib import Path
import argparse
import concurrent.futures
import os
import re
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'scripts'))
from run_cluster_top_lint import INCLUDE_DIRS, REPORT_DIR
from lint_source_overrides import apply_overrides

def main():
    apply_overrides()
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--harts', type=int, choices=(2,4), required=True)
    p.add_argument('--mutant',action='store_true')
    p.add_argument('--error', type=int, choices=(0,1), default=0)
    p.add_argument('--jobs', type=int, default=2)
    p.add_argument('--run-only', action='store_true')
    args = p.parse_args()
    toolroot = Path('C:/Users/PC/Tools/oss-cad-suite')
    verilator = toolroot / 'bin/verilator_bin.exe'
    runtime = toolroot / 'share/verilator/include'
    compiler = Path('C:/Users/PC/Tools/msys64/ucrt64/bin/g++.exe')
    build = Path('C:/HQuan/.test_tmp') / (f'fault_record_unit_{args.harts}h'+('_mutant' if args.mutant else ''))
    report = ROOT / ('rtl/reports/fault_record_a06/unit_mutant' if args.mutant else 'rtl/reports/fault_record_a06/unit')
    report.mkdir(parents=True, exist_ok=True)
    build.mkdir(parents=True, exist_ok=True)
    env = os.environ.copy()
    env['VERILATOR_ROOT'] = str(runtime.parent)
    top = 'tb_fault_record'
    exe = build / f'V{top}.exe'
    if not args.run_only:
        # Generate into a fresh directory: specialization names may change after
        # RTL edits, and stale generated .cpp files must never enter this build.
        build = build / ('build_' + str(time.time_ns()))
        build.mkdir()
        command = [str(verilator), '--cc', '--exe', '--main', '--timing', '--assert',
                   '--timescale','1ns/1ps',
                   '--top-module',top,f'-GHARTS={args.harts}',
                   '--output-split','10000','--Mdir',str(build)]
        command += [f'+incdir+{x.as_posix()}' for x in INCLUDE_DIRS]
        command += [str(ROOT/'rtl/vlsit/m_vlsit_riscv_fault_record.sv'),str(Path(__file__).with_name('tb_fault_record.sv'))]
        if args.mutant:
            original=ROOT/'rtl/vlsit/m_vlsit_riscv_fault_record.sv'
            text=original.read_text();old="if (~reg_fault_sts[0])"
            if old not in text:raise RuntimeError('mutation anchor missing')
            altered=build/original.name;altered.write_text(text.replace(old,"if (1'b1)",1))
            command=[str(altered) if x==str(original) else x for x in command]
        model_log = report / f'model_{args.harts}h.log'
        print(f'Generating focused unit model ({args.harts} cache ports): {model_log}', flush=True)
        with model_log.open('w') as f:
            result = subprocess.run(command,cwd=REPORT_DIR,env=env,stdout=f,stderr=subprocess.STDOUT)
        if result.returncode:
            print(model_log.read_text(errors='replace')[-8000:])
            return result.returncode
        warnings = re.findall(r'^%Warning-[^:]+',model_log.read_text(errors='replace'),re.M)
        if warnings:
            print('FAIL: model warnings: ' + ', '.join(warnings))
            return 1
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
    log = report / f'simulation_{args.harts}h_error{args.error}.log'
    print(f'Executing focused unit test: {log}',flush=True)
    with log.open('w') as f:
        result = subprocess.run([str(exe),f'+INJECT_ERROR={args.error}',
                                 f'+WAVE={(report / f"service_{args.harts}h_error{args.error}.vcd").as_posix()}'],env=env,
                                stdout=f,stderr=subprocess.STDOUT,timeout=180)
    contents=log.read_text(errors='replace');print(contents[-10000:])
    if args.mutant:
        caught=result.returncode!=0 and 'fault oracle' in contents
        message=f"{'PASS' if caught else 'FAIL'}: overwrite-first-fault mutant {'caught' if caught else 'not caught'}; native exit={result.returncode}"
        (report/'mutation_result.txt').write_text(message+'\n');print(message);return 0 if caught else 1
    return result.returncode

if __name__ == '__main__':
    raise SystemExit(main())
