"""Collect A-05 evidence, rejecting incomplete regressions or stale model identities."""

from pathlib import Path

import json,hashlib,re,difflib,sys,subprocess

ROOT=Path(__file__).resolve().parents[3]

OUT=ROOT/'rtl/reports/ccu_victim_escape'

BASE=ROOT/'rtl/reports/directory_holder_lifecycle'

def main():

 rows=[]

 def add(name,path,model=False):

  text=path.read_text(encoding='utf-8',errors='replace') if path.exists() else ''

  okay=('Verilator: Built' in text if model else 'PASS:' in text) and not re.search(r'%Warning|%Error|%Fatal',text)

  m=re.search(r'PASS:.*cycles=(\d+)',text)

  rows.append(dict(test=name,passed=okay,cycles=int(m[1]) if m else None,log=path.relative_to(ROOT).as_posix()))

  return text

 sources={p.relative_to(ROOT).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for d in ('rtl/vlsit','rtl/modified') for p in sorted((ROOT/d).rglob('*.sv'))}

 if sources!=json.loads((OUT/'source_sha256.json').read_text(encoding='utf-8')):raise RuntimeError('production source changed after A-05 regression start')

 for h in (2,4):

  for case in ('dirty_eviction','clean_eviction','amo_refill_error','lr_refill_error'):

   text=add(f'A-05 real CPU {h}h {case}',OUT/f'simulation_{h}h_2slots_{case}.log')

   counts=re.search(r'CHECK slots=2 children=(\d+) full_table_cycles=(\d+) root_credit_stalls=(\d+)',text)

   rows[-1]['passed'] &= bool(counts and all(int(x)>0 for x in counts.groups()))

   for pat in (r'AXI-IHI0022 ASSERT (\d+) hits=(\d+)',r'AXI-IHI0022 external ASSERT (\d+) hits=(\d+)'):

    hits={int(k):int(v) for k,v in re.findall(pat,text)}

    rows[-1]['passed'] &= len(hits)==20 and all(hits.values())

   add(f'A-04 real CPU {h}h {case}',BASE/f'simulation_{h}h_{case}.log')

  for e in (0,2,3):add(f'L1 eviction {h}h B={e}',ROOT/f'rtl/reports/l1_eviction_retention/simulation_{h}h_error{e}.log')

  for case in ('success','lrsc_contention','amo_fault','lr_fault','owner_fault'):

   add(f'Atomic {h}h {case}',ROOT/f'rtl/reports/atomic_coherence/simulation_{h}h_{case}.log')

  for e in (0,1):

   for tail in ('','_load_first'):add(f'CBO {h}h error={e}{tail}',ROOT/f'rtl/reports/cmo_end_to_end/simulation_{h}h_error{e}{tail}.log')

   for tail in ('','_supervisor'):add(f'FENCE.I {h}h error={e}{tail}',ROOT/f'rtl/reports/fence_i_end_to_end/simulation_{h}h_error{e}{tail}.log')

  for area in ('directory_holder_lifecycle','l1_eviction_retention','atomic_coherence','cmo_end_to_end','fence_i_end_to_end'):

   add(f'Native model {area} {h}h',ROOT/f'rtl/reports/{area}/model_{h}h.log',True)

  add(f'Native A-05 CPU model {h}h',OUT/f'model_{h}h_2slots.log',True)

  paths=sorted((ROOT/'rtl/reports/full_integration').glob(f'top_lint_{h}h_????????_??????.log'))

  add(f'Production TOP lint {h}h',paths[-1],True)

  for folder in (BASE,OUT):

   manifest=folder/f'regression_sources_{h}h.json'

   if not manifest.exists() or json.loads(manifest.read_text(encoding='utf-8'))!=sources:raise RuntimeError(f'stale driver sources {manifest}')

  driver=BASE/f'regression_driver_{h}h.log';text=driver.read_text(encoding='utf-8',errors='replace');parts=text.split('COMMAND: ')[1:]

  complete=len(parts)==21 and all('PASS:' in t for t in parts[:-1]) and 'Native Verilator exit code: 0' in parts[-1] and 'Warning diagnostics: 0' in parts[-1] and not re.search(r'%Error|%Warning|%Fatal',text)

  rows.append(dict(test=f'Complete baseline driver {h}h',passed=complete,log=driver.relative_to(ROOT).as_posix()))

  driver=OUT/f'regression_driver_{h}h.log';text=driver.read_text(encoding='utf-8',errors='replace') if driver.exists() else '';parts=text.split('COMMAND: ')[1:]

  complete=len(parts) in (4,5) and all('PASS:' in t for t in parts) and not re.search(r'%Error|%Warning|%Fatal',text)

  rows.append(dict(test=f'Complete A-05 driver {h}h',passed=complete,log=driver.relative_to(ROOT).as_posix()))

  for area,build in (('A-05',f'victim_cpu_{h}h_2slots'),('A-04',f'holder_cpu_{h}h')):

   path=Path('C:/HQuan/.test_tmp')/build/'model_inputs.json'

   inputs=json.loads(path.read_text(encoding='utf-8')) if path.exists() else {}

   valid=bool(inputs) and all((ROOT/name).exists() and hashlib.sha256((ROOT/name).read_bytes()).hexdigest()==digest for name,digest in inputs.items())

   target=OUT/f'model_inputs_{area}_{h}h.json';target.write_text(json.dumps(inputs,indent=2)+'\n',encoding='utf-8')

   rows.append(dict(test=f'{area} CPU model/bench/program identity {h}h',passed=valid,log=target.relative_to(ROOT).as_posix()))

 for n in (2,8,16):

  text=add(f'TEST-053 {n} context saturation',OUT/f'unit_{n}/simulation_4h_error0.log')

  fields=dict(re.findall(r'(full|root_guard|parent|PREPARE|COMMIT|ABORT|retry|cancels|children)=(\d+)',text))

  required=('full','root_guard','parent','PREPARE','COMMIT','ABORT')+(('retry','cancels') if n==16 else ())

  rows[-1]['passed'] &= all(int(fields.get(k,0))>0 for k in required)

  if n>2:rows[-1]['passed'] &= int(fields.get('parent',0))>int(fields.get('children',0))

  add(f'Native TEST-053 {n} context model',OUT/f'unit_{n}/model_4h.log',True)

 for unit in ('fabric_unit','probe_unit'):

  add(f'A-04 {unit}',BASE/unit/'simulation_4h_error0.log');add(f'Native A-04 {unit}',BASE/unit/'model_4h.log',True)

 for mutant,n in (('no-credit',2),('wrong-parent',8),('wrong-grant',16)):

  path=OUT/f'unit_{n}_{mutant}/mutation_result.txt'

  text=path.read_text(encoding='utf-8') if path.exists() else ''

  rows.append(dict(test=f'Mutation {mutant} caught',passed=text.startswith('PASS:'),log=path.relative_to(ROOT).as_posix()))

 changed=[];added=removed=total=0

 for before in (OUT/'before/rtl/vlsit').glob('*.sv'):

  after=ROOT/'rtl/vlsit'/before.name

  old=before.read_bytes();new=after.read_bytes()

  if old!=new:

   changed.append(dict(path=after.relative_to(ROOT).as_posix(),before_sha256=hashlib.sha256(old).hexdigest(),after_sha256=hashlib.sha256(new).hexdigest()))

   a=old.decode().splitlines();b=new.decode().splitlines();total+=len(a)

   for op,i,j,k,l in difflib.SequenceMatcher(None,a,b,autojunk=False).get_opcodes():

    if op!='equal':removed+=j-i;added+=l-k

 verify={p.relative_to(ROOT).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for p in Path(__file__).parent.rglob('*') if p.is_file() and p.suffix in ('.py','.sv','.svh','.hex','.lst')}

 result=dict(date='2026-11-15',top='m_vlsit_riscv_cluster_axi_top',results=rows,source_sha256=sources,verification_sha256=verify,changed_rtl=changed,diff=dict(added=added,removed=removed,baseline_lines=total),coverage='Directed checks only; no code coverage measured')

 (OUT/'results.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')

 lines=['# Validation / Kiem chung','','| Test | Result | Cycles | Evidence |','|---|---|---:|---|']

 for row in rows:lines.append(f"| {row['test']} | {'PASS' if row['passed'] else 'FAIL/missing'} | {row.get('cycles') or '-'} | [log](../../../{row['log']}) |")

 (OUT/'validation.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')

 lines=['# Changed production RTL / RTL production da sua','','Only the following production file differs from the A-04 baseline. Licensed reuse sources are unchanged. / Chi file sau thay doi so voi baseline A-04; khong sua RTL reuse co license.','']

 for item in changed:lines.append(f"- [{item['path']}](../../../{item['path']}) — SHA-256 `{item['after_sha256']}`")

 lines+=['',f'Diff +{added}/-{removed}; baseline {total} lines; churn {(added+removed)*100/total:.2f}% (includes comments; not gate area).']

 (OUT/'changed_files.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')

 bad=[row['test'] for row in rows if not row['passed']]

 if bad:print('FAIL/missing: '+', '.join(bad));return 1

 print(f'PASS: {len(rows)} validation entries, 48 real CPU cases, one production RTL file; hashes recorded.')

 return 0

if __name__=='__main__':raise SystemExit(main())

