"""Replay the approved full cluster baseline and A-06 real-CPU fault CSR tests."""
from pathlib import Path
import argparse,subprocess,sys,json,hashlib,re
ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'rtl/reports/fault_record_a06'
def hashes():return {p.relative_to(ROOT).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for f in ('rtl/vlsit','rtl/modified') for p in sorted((ROOT/f).rglob('*.sv'))}
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--harts',type=int,choices=(2,4),required=True);p.add_argument('--jobs',type=int,default=3);p.add_argument('--cpu-run-only',action='store_true');p.add_argument('--reuse-baseline',action='store_true');a=p.parse_args()
 before=hashes();commands=[]
 if a.reuse_baseline:
  for area in ('ccu_victim_escape','directory_holder_lifecycle'):
   folder=ROOT/'rtl/reports'/area
   if json.loads((folder/f'regression_sources_{a.harts}h.json').read_text())!=before:raise RuntimeError('baseline source fingerprint mismatch')
   text=(folder/f'regression_driver_{a.harts}h.log').read_text(errors='replace')
   if re.search(r'%Error|%Warning|%Fatal|FAIL:',text):raise RuntimeError('failed baseline driver')
   parts=text.split('COMMAND: ')[1:]
   if area=='directory_holder_lifecycle':
    if len(parts)!=21 or not all('PASS:' in x for x in parts[:-1]) or 'Warning diagnostics: 0' not in parts[-1]:raise RuntimeError('incomplete baseline')
   elif len(parts) not in (4,5) or not all('PASS:' in x for x in parts):raise RuntimeError('incomplete A-05 driver')
 else:commands.append([sys.executable,'rtl/verification/ccu_victim_escape/run_regression.py','--harts',str(a.harts),'--jobs',str(a.jobs)])
 for idx,(llc,error) in enumerate(((False,2),(False,3),(True,2),(True,3))):
  cmd=[sys.executable,'rtl/verification/fault_record_a06/run.py','--harts',str(a.harts),'--error',str(error)]
  if llc:cmd+=['--llc']
  cmd+=['--run-only'] if idx or a.cpu_run_only else ['--jobs',str(a.jobs)]
  commands.append(cmd)
 commands.append([sys.executable,'rtl/verification/fault_record_a06/run.py','--harts',str(a.harts),'--error','2','--reverse','--run-only'])
 OUT.mkdir(exist_ok=True);(OUT/f'regression_sources_{a.harts}h.json').write_text(json.dumps(before,indent=2)+'\n')
 with (OUT/f'regression_driver_{a.harts}h.log').open('w') as log:
  if a.reuse_baseline:log.write('REUSED: complete current-source A-05/A-04 drivers verified before reuse.\n')
  for cmd in commands:
   print('RUN: '+' '.join(cmd),flush=True);log.write('COMMAND: '+repr(cmd)+'\n');log.flush()
   proc=subprocess.run(cmd,cwd=ROOT,stdout=log,stderr=subprocess.STDOUT)
   if proc.returncode:print(f'FAIL exit={proc.returncode}; see {log.name}',flush=True);return proc.returncode
   print('PASS: '+' '.join(cmd[1:]),flush=True)
 if before!=hashes():raise RuntimeError('RTL changed during A-06 regression')
 print('PASS: A-06 plus full cluster regression complete',flush=True);return 0
if __name__=='__main__':raise SystemExit(main())
