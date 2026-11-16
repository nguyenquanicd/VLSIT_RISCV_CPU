"""Replay TEST-053 CPU tests and the complete approved A-04 baseline regression."""
from pathlib import Path
import argparse,subprocess,sys,json,hashlib
ROOT=Path(__file__).resolve().parents[3]
REPORT=ROOT / 'verification/non_coherence_cluster/reports/ccu_victim_escape'
def main():
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('--harts',type=int,choices=(2,4),required=True)
 p.add_argument('--jobs',type=int,default=2)
 p.add_argument('--cpu-run-only',action='store_true')
 p.add_argument('--reuse-approved-regression',action='store_true',help='validate and reuse completed current-source baseline driver evidence')
 a=p.parse_args(); REPORT.mkdir(exist_ok=True)
 def hashes():return {p.relative_to(ROOT).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for f in ('rtl/common/vlsit','rtl/common/modified','rtl/non_coherence_cluster','rtl/coherence_cluster') for p in sorted((ROOT/f).rglob('*.sv'))}
 before=hashes();commands=[]
 if a.reuse_approved_regression:
  base=ROOT / 'verification/non_coherence_cluster/reports/directory_holder_lifecycle'
  if json.loads((base/f'regression_sources_{a.harts}h.json').read_text())!=before:raise RuntimeError('baseline source identity changed')
  text=(base/f'regression_driver_{a.harts}h.log').read_text()
  if text.count('COMMAND:')!=21 or 'Warning diagnostics: 0' not in text or 'Native Verilator exit code: 0' not in text:raise RuntimeError('baseline driver incomplete')
 else:commands.append([sys.executable,'verification/non_coherence_cluster/directory_holder_end_to_end/run_regression.py','--harts',str(a.harts),'--jobs',str(a.jobs)])
 for idx,case in enumerate(('dirty_eviction','clean_eviction','amo_refill_error','lr_refill_error')):
  cmd=[sys.executable,'verification/non_coherence_cluster/ccu_victim_escape/run.py','--harts',str(a.harts),'--case',case]
  cmd+=['--run-only'] if idx or a.cpu_run_only else ['--jobs',str(a.jobs)]
  commands.append(cmd)
 (REPORT/f'regression_sources_{a.harts}h.json').write_text(json.dumps(before,indent=2)+'\n')
 with (REPORT/f'regression_driver_{a.harts}h.log').open('w') as log:
  if a.reuse_approved_regression:log.write('REUSED: completed current-source 21-command A-04 regression driver, verified above.\n')
  for cmd in commands:
   print('RUN: '+' '.join(cmd),flush=True);log.write('COMMAND: '+repr(cmd)+'\n');log.flush()
   result=subprocess.run(cmd,cwd=ROOT,stdout=log,stderr=subprocess.STDOUT)
   if result.returncode:print(f'FAIL: exit={result.returncode}; see {log.name}');return result.returncode
   print('PASS: '+' '.join(cmd[1:]),flush=True)
 if hashes()!=before:raise RuntimeError('RTL changed during regression')
 print('PASS: A-05 CPU plus approved baseline regression complete',flush=True)
 return 0
if __name__=='__main__':raise SystemExit(main())
