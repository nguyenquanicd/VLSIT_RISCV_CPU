"""Differential checks for cycle-preserving lint refactors; not a golden-model spec test."""
from pathlib import Path
import os
import re
import subprocess
import sys
import time

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT / 'verification/common/reports/lint_cleanup'
TB=ROOT / 'verification/common/cmo_metadata'
TOOL=Path('C:/Users/PC/Tools/oss-cad-suite')
INC=TOOL/'share/verilator/include'
GXX=Path('C:/Users/PC/Tools/msys64/ucrt64/bin/g++.exe')
env=os.environ.copy();env['VERILATOR_ROOT']=str(INC.parent)

def run_one(name, original, sources):
    folder=OUT/name;folder.mkdir(parents=True,exist_ok=True)
    baseline=folder/'baseline.sv'
    text=original.read_text(encoding='utf-8')
    module='commit_stage' if name=='csr_payload' else ('alu' if name=='alu' else ('fpu_wrap' if name=='wrap' else ('fpnew_'+name[4:] if name.startswith('fpu_') else 'axi_isolate')))
    text=re.sub(r'^module '+module+r'\b','module '+module+'_lint_baseline',text,count=1,flags=re.M)
    if name.startswith('fpu_') or name=='wrap':
        # Keep the pre-change package and helper types independent. This checks
        # format-index mapping as well as arithmetic and pipeline refactors.
        legacy=[]
        helpers=['fpnew_pkg','fpnew_classifier','fpnew_rounding']
        if name=='wrap':
            helpers=['fpnew_pkg']+sorted(p.stem for p in (ROOT / 'rtl/common/third_party/cvfpu/src').glob('fpnew_*.sv') if p.stem!='fpnew_pkg')
        for helper in helpers:
            content=(ROOT/f'rtl/common/third_party/cvfpu/src/{helper}.sv').read_text(encoding='utf-8')
            for symbol in helpers:
                content=re.sub(r'\b'+symbol+r'\b',symbol+'_lint_baseline',content)
            path=folder/(helper+'_baseline.sv');path.write_text(content,encoding='utf-8')
            legacy.append(str(path))
        for symbol in helpers:
            text=re.sub(r'\b'+symbol+r'\b',symbol+'_lint_baseline',text)
        sources=sources[:2]+legacy+sources[2:]
    baseline.write_text(text,encoding='utf-8')
    top='tb_csr_payload_equivalence' if name=='csr_payload' else ('tb_'+module+'_equivalence' if name.startswith('fpu_') or name in ('wrap','alu') else 'tb_isolate_equivalence')
    build=(ROOT / 'verification/common/build/lint_refactor')/name/str(time.time_ns())
    build.mkdir(parents=True)
    args=[str(TOOL/'bin/verilator_bin.exe'),'--cc','--exe','--main','--timing','--assert',
          '-Wno-fatal','--top-module',top,'--Mdir',str(build)]
    for path in ('rtl/common/third_party/axi_llc_locked/axi/include','rtl/common/third_party/axi_llc_locked/common_cells/include'):
        args+=['+incdir+'+(ROOT/path).as_posix()]
    args+=sources+[str(baseline),str(TB/(top+'.sv'))]
    with (folder/'build.log').open('w') as log:
        result=subprocess.run(args,cwd=TB,env=env,stdout=log,stderr=subprocess.STDOUT)
        if result.returncode:raise RuntimeError((folder/'build.log').read_text()[-4000:])
        cpp=list(build.glob('*.cpp'))+[INC/f for f in ('verilated.cpp','verilated_timing.cpp','verilated_threads.cpp')]
        exe=build/(top+'.exe')
        args=[str(GXX),'-std=gnu++20','-fcoroutines','-O0','-DVL_TIME_CONTEXT','-DVM_TIMING=1',
              '-DVM_TRACE=0','-DVM_COVERAGE=0',f'-I{build}',f'-I{INC}',f'-I{INC/"vltstd"}']
        result=subprocess.run(args+[str(x) for x in cpp]+['-pthread','-latomic','-o',str(exe)],env=env,stdout=log,stderr=subprocess.STDOUT)
        if result.returncode:raise RuntimeError((folder/'build.log').read_text()[-4000:])
    with (folder/'simulation.log').open('w') as log:
        result=subprocess.run([str(exe)],env=env,stdout=log,stderr=subprocess.STDOUT,timeout=60)
    print((folder/'simulation.log').read_text(),flush=True)
    if result.returncode:raise RuntimeError(name+' differential check failed')

if __name__=='__main__':
    if '--alu' in sys.argv:
        sources=(TB/'filelist_retirement.f').read_text().splitlines()[:-2]
        sources += [str(ROOT/p) for p in (
            'rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/cf_math_pkg.sv',
            'rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/lzc.sv',
            'rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/popcount.sv',
            'rtl/common/modified/cva6/core/alu.sv')]
        run_one('alu',ROOT / 'rtl/common/third_party/cva6/core/alu.sv',sources)
        sys.exit(0)
    if '--fpu' in sys.argv:
        shared=[str(ROOT/p) for p in (
            'rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/cf_math_pkg.sv',
            'rtl/common/modified/cvfpu/src/fpnew_pkg.sv',
            'rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/lzc.sv',
            'rtl/common/third_party/cvfpu/src/fpnew_classifier.sv',
            'rtl/common/third_party/cvfpu/src/fpnew_rounding.sv')]
        for unit in ('fma','noncomp','cast_multi'):
            run_one('fpu_'+unit, ROOT/f'rtl/common/third_party/cvfpu/src/fpnew_{unit}.sv',
                    shared+[str(ROOT/f'rtl/common/modified/cvfpu/src/fpnew_{unit}.sv')])
        sys.exit(0)
    if '--wrap' in sys.argv:
        run_one('wrap',ROOT / 'rtl/common/third_party/cva6/core/fpu_wrap.sv',[
            '-f',str(ROOT / 'rtl/common/filelists/cva6_flush_path/cva6_modified_cache.Flist')])
        sys.exit(0)
    sources=(TB/'filelist_retirement.f').read_text().splitlines()[:-1]
    run_one('csr_payload',ROOT / 'verification/non_coherence_cluster/reports/full_integration/source_snapshots/lint_cleanup_20261115/rtl/modified/cva6/core/commit_stage.sv',sources)
    run_one('isolate',ROOT / 'rtl/common/third_party/axi_llc_locked/axi/src/axi_isolate.sv',[
        str(ROOT / 'rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/cf_math_pkg.sv'),
        str(ROOT / 'rtl/common/third_party/cva6/vendor/pulp-platform/axi/src/axi_pkg.sv'),
        str(ROOT / 'rtl/common/modified/axi_llc_locked/axi/src/axi_isolate.sv')])
