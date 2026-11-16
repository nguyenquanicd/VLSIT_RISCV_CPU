"""Replay A-03 and the approved atomic/maintenance/TOP-lint regression."""
from pathlib import Path
import argparse,subprocess,sys,json,hashlib
ROOT=Path(__file__).resolve().parents[3]
REPORT=ROOT/'rtl/reports/l1_eviction_retention'
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--harts',type=int,choices=(2,4),required=True);p.add_argument('--jobs',type=int,default=2);p.add_argument('--skip-eviction',action='store_true');args=p.parse_args()
 commands=[]
 def add(folder,*extra,build=False):
  cmd=[sys.executable,f'rtl/verification/{folder}/run.py','--harts',str(args.harts)]
  cmd+=['--jobs',str(args.jobs)] if build else ['--run-only']
  commands.append(cmd+list(extra))
 if not args.skip_eviction:
  add('l1_eviction_end_to_end',build=True)
  for error in ('2','3'):add('l1_eviction_end_to_end','--error',error)
 add('atomic_end_to_end',build=True)
 for case in ('lrsc_contention','amo_fault','lr_fault','owner_fault'):add('atomic_end_to_end','--case',case)
 add('cmo_end_to_end',build=True);add('cmo_end_to_end','--error','1')
 add('cmo_end_to_end','--load-first');add('cmo_end_to_end','--load-first','--error','1')
 add('fence_i_end_to_end',build=True);add('fence_i_end_to_end','--error','1')
 add('fence_i_end_to_end','--supervisor');add('fence_i_end_to_end','--supervisor','--error','1')
 commands.append([sys.executable,'scripts/run_cluster_top_lint.py','--hart-count',str(args.harts),'--timeout','120'])
 REPORT.mkdir(exist_ok=True)
 def source_hashes():
  return {p.relative_to(ROOT).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for folder in ('rtl/vlsit','rtl/modified') for p in sorted((ROOT/folder).rglob('*.sv'))}
 sources=source_hashes()
 (REPORT/f'regression_sources_{args.harts}h.json').write_text(json.dumps(sources,indent=2)+'\n',encoding='utf-8')
 with (REPORT/f'regression_driver_{args.harts}h.log').open('w',encoding='utf-8') as log:
  for cmd in commands:
   print('RUN: '+' '.join(cmd),flush=True);log.write('COMMAND: '+repr(cmd)+'\n');log.flush()
   result=subprocess.run(cmd,cwd=ROOT,stdout=log,stderr=subprocess.STDOUT)
   log.flush()
   if result.returncode:
    print(f'FAIL exit={result.returncode}; see {log.name}',flush=True);return result.returncode
   print('PASS: '+' '.join(cmd[1:]),flush=True)
 if sources!=source_hashes():
  print('FAIL: RTL changed during regression; rebuild all affected models.',flush=True);return 1
 return 0
if __name__=='__main__':raise SystemExit(main())
