"""Build and run real CVA6 instructions through the production cluster TOP."""
from pathlib import Path
import argparse
import concurrent.futures
import os
import re
import subprocess
import sys
import time
import json
import hashlib

ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / 'scripts'))
from run_cluster_top_lint import INCLUDE_DIRS, REPORT_DIR
from lint_source_overrides import apply_overrides

def main():
    from build_program import generate
    generate();generate(True)
    apply_overrides()
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--harts', type=int, choices=(2,4), required=True)
    p.add_argument('--error',type=int,choices=(2,3),default=2)
    p.add_argument('--llc',action='store_true')
    p.add_argument('--reverse',action='store_true',help='complete highest-hart initial B response first')
    p.add_argument('--jobs', type=int, default=2)
    p.add_argument('--run-only', action='store_true')
    args = p.parse_args()
    toolroot = Path('C:/Users/PC/Tools/oss-cad-suite')
    verilator = toolroot / 'bin/verilator_bin.exe'
    runtime = toolroot / 'share/verilator/include'
    compiler = Path('C:/Users/PC/Tools/msys64/ucrt64/bin/g++.exe')
    build = Path('C:/HQuan/.test_tmp') / f'fault_record_cpu_{args.harts}h'
    report = ROOT / 'rtl/reports/fault_record_a06'
    report.mkdir(parents=True, exist_ok=True)
    build.mkdir(parents=True, exist_ok=True)
    env = os.environ.copy()
    env['VERILATOR_ROOT'] = str(runtime.parent)
    top = 'tb_fault_record_cpu'
    exe = build / f'V{top}.exe'
    inputs = {p.relative_to(ROOT).as_posix():hashlib.sha256(p.read_bytes()).hexdigest()
              for folder in ('rtl/vlsit','rtl/modified') for p in sorted((ROOT/folder).rglob('*.sv'))}
    for name in ('tb_fault_record_cpu.sv','m_vlsit_axi_llc.sv','program_constants.svh','program_checks.svh',
                 'program.hex','llc_program.hex'):
        source=Path(__file__).with_name(name)
        inputs[source.relative_to(ROOT).as_posix()]=hashlib.sha256(source.read_bytes()).hexdigest()
    manifest=build/'model_inputs.json'
    if args.run_only:
        if not manifest.exists() or json.loads(manifest.read_text())!=inputs:
            print('FAIL: DUT/testbench/program identity changed or not recorded; build before --run-only.')
            return 1
    else:
        manifest.unlink(missing_ok=True)
    if not args.run_only:
        original=(ROOT/'rtl/vlsit/m_vlsit_axi_llc.sv').read_text(encoding='utf-8')
        Path(__file__).with_name('m_vlsit_axi_llc_native.sv').write_text(
            original.replace('module m_vlsit_axi_llc #(', 'module m_vlsit_axi_llc_native #('),encoding='utf-8')
        # Generate into a fresh directory: specialization names may change after
        # RTL edits, and stale generated .cpp files must never enter this build.
        build = build / ('build_' + str(time.time_ns()))
        build.mkdir()
        command = [str(verilator), '--cc', '--exe', '--main', '--timing', '--assert',
                   '--timescale','1ns/1ps',
                   '--top-module',top,f'-GHARTS={args.harts}',
                   '--output-split','10000','--Mdir',str(build)]
        command += [f'+incdir+{x.as_posix()}' for x in INCLUDE_DIRS]
        flist=(REPORT_DIR/'filelist_vlsit_cluster.f').read_text()
        flist='\n'.join(line for line in flist.splitlines() if not line.endswith('/m_vlsit_axi_llc.sv'))
        shim_flist=build/'filelist_atomic_shim.f'
        shim_flist.write_text(flist+'\n'+str(Path(__file__).with_name('m_vlsit_axi_llc_native.sv')).replace('\\','/')+'\n'+str(Path(__file__).with_name('m_vlsit_axi_llc.sv')).replace('\\','/')+'\n')
        command += ['-f','../cva6_flush_path/cva6_modified_cache.Flist',
                    '-f','filelist_llc_unique.f','-f',str(shim_flist),
                    str(Path(__file__).with_name('tb_fault_record_cpu.sv'))]
        command += [f'+incdir+{Path(__file__).parent.as_posix()}']
        model_log = report / f'model_{args.harts}h.log'
        print(f'Generating {args.harts}-hart instruction model: {model_log}', flush=True)
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
        manifest.write_text(json.dumps(inputs,indent=2)+'\n')
    log = report / f'simulation_{args.harts}h_{"llc" if args.llc else "l1"}_error{args.error}{"_reverse" if args.reverse else ""}.log'
    print(f'Executing real instruction test: {log}',flush=True)
    with log.open('w') as f:
        result = subprocess.run([str(exe),f'+PROGRAM={Path(__file__).with_name(("llc_program.hex" if args.llc else "program.hex")).as_posix()}',
                                 f'+LLC_MODE={int(args.llc)}',f'+INJECT_ERROR={args.error}',f'+REVERSE={int(args.reverse)}',f'+FAULT_HARTS={args.harts}',
                                 f'+WAVE={(report / f"service_{args.harts}h_{"llc" if args.llc else "l1"}_error{args.error}{"_reverse" if args.reverse else ""}.vcd").as_posix()}'],env=env,
                                stdout=f,stderr=subprocess.STDOUT,timeout=180)
    contents=log.read_text(errors='replace');print(contents[-10000:])
    if args.reverse:
        m=re.search(r'CHECK TEST-054 source_llc=0 addr=[0-9a-f]+ info=([0-9a-f]+)',contents)
        if not m or ((int(m[1],16)>>8)&3)!=args.harts-1:
            print('FAIL: highest-hart-first B ordering was not exercised');return 1
    return result.returncode

if __name__ == '__main__':
    raise SystemExit(main())
