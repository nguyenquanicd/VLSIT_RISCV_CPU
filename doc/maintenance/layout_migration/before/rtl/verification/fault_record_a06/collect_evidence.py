"""Reject incomplete A-06 tests, inactive protocol assertions and stale source identities."""
from pathlib import Path
import json,re,hashlib,subprocess,sys,difflib,base64
ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'rtl/reports/fault_record_a06'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 rows=[]
 def add(name,path,model=False):
  text=path.read_text(encoding='utf-8',errors='replace') if path.exists() else ''
  good=('Verilator: Built' in text if model else 'PASS:' in text) and not re.search(r'%Error|%Warning|%Fatal',text)
  m=re.search(r'PASS:.*cycles=(\d+)',text)
  rows.append(dict(test=name,passed=good,cycles=int(m[1]) if m else None,log=path.relative_to(ROOT).as_posix()));return text
 def hits(text,pattern):
  found={int(k):int(v) for k,v in re.findall(pattern,text)}
  return len(found)==20 and all(found.values())
 current={p.relative_to(ROOT).as_posix():sha(p) for d in ('rtl/vlsit','rtl/modified') for p in sorted((ROOT/d).rglob('*.sv'))}
 if current!=json.loads((OUT/'source_sha256.json').read_text()):raise RuntimeError('production RTL changed after source freeze')
 # Post-validation insertions are restricted to comments. Every old fingerprint
 # must restore the exact compiled bytes after deleting the recorded insertion.
 ledger_path=OUT/'comment_only_cleanup.json'
 ledger=json.loads(ledger_path.read_text()) if ledger_path.exists() else {}
 for name,delta in ledger.items():
  now=(ROOT/name).read_bytes();old=(ROOT/delta['compiled_snapshot']).read_bytes();insert=base64.b64decode(delta['inserted_comment_base64'])
  if sha(ROOT/name)!=delta['after_sha256'] or sha(ROOT/delta['compiled_snapshot'])!=delta['before_sha256'] or now.count(insert)!=1 or now.replace(insert,b'',1)!=old:raise RuntimeError('unverified comment cleanup')
  def stripped(text):return ''.join(re.sub(r'("(?:\\.|[^"\\])*")|(/\*.*?\*/|//[^\r\n]*)',lambda m:m[1] if m[1] is not None else '',text,flags=re.S).split())
  if stripped(now.decode())!=stripped(old.decode()):raise RuntimeError('comment cleanup changed tokens')
 def compatible(name,digest):
  if not (ROOT/name).exists():return False
  if sha(ROOT/name)==digest:return True
  return name in ledger and ledger[name]['before_sha256']==digest
 def compatible_map(mapping):return mapping.keys()==current.keys() and all(compatible(n,d) for n,d in mapping.items())

 for h in (2,4):
  for source in ('l1','llc'):
   for error in (2,3):
    text=add(f'A-06 CPU {h}h {source} B={error}',OUT/f'simulation_{h}h_{source}_error{error}.log')
    okay=hits(text,r'AXIL-IHI0022 ASSERT (\d+) hits=(\d+)') and hits(text,r'AXI-IHI0022 ASSERT (\d+) hits=(\d+)')
    pattern=r'AXI-memory-before-reset ASSERT (\d+) hits=(\d+)' if source=='llc' else r'AXI-IHI0022 external check=(\d+) hits=(\d+)'
    rows[-1]['passed'] &= okay and hits(text,pattern) and f'exact_BRESP={error}' in text
  text=add(f'A-06 CPU {h}h highest-hart-first B response',OUT/f'simulation_{h}h_l1_error2_reverse.log')
  m=re.search(r'CHECK TEST-054 source_llc=0 addr=[0-9a-f]+ info=([0-9a-f]+)',text)
  rows[-1]['passed'] &= bool(m and ((int(m[1],16)>>8)&3)==h-1)
  for pat in (r'AXIL-IHI0022 ASSERT (\d+) hits=(\d+)',r'AXI-IHI0022 ASSERT (\d+) hits=(\d+)',r'AXI-IHI0022 external check=(\d+) hits=(\d+)'):
   rows[-1]['passed'] &= hits(text,pat)
  for area,prefix in (('ccu_victim_escape','A-05 CPU'),('directory_holder_lifecycle','A-04 CPU')):
   for case in ('dirty_eviction','clean_eviction','amo_refill_error','lr_refill_error'):
    suffix=f'{h}h_2slots_{case}' if area=='ccu_victim_escape' else f'{h}h_{case}'
    add(f'{prefix} {h}h {case}',ROOT/f'rtl/reports/{area}/simulation_{suffix}.log')
  for error in (0,2,3):add(f'A-03 CPU {h}h B={error}',ROOT/f'rtl/reports/l1_eviction_retention/simulation_{h}h_error{error}.log')
  for case in ('success','lrsc_contention','amo_fault','lr_fault','owner_fault'):add(f'Atomic CPU {h}h {case}',ROOT/f'rtl/reports/atomic_coherence/simulation_{h}h_{case}.log')
  for e in (0,1):
   for tail in ('','_load_first'):add(f'CBO CPU {h}h error={e}{tail}',ROOT/f'rtl/reports/cmo_end_to_end/simulation_{h}h_error{e}{tail}.log')
   for tail in ('','_supervisor'):add(f'FENCE.I CPU {h}h error={e}{tail}',ROOT/f'rtl/reports/fence_i_end_to_end/simulation_{h}h_error{e}{tail}.log')
  for area in ('directory_holder_lifecycle','l1_eviction_retention','atomic_coherence','cmo_end_to_end','fence_i_end_to_end','fault_record_a06'):
   add(f'Native model {area} {h}h',ROOT/f'rtl/reports/{area}/model_{h}h.log',True)
  add(f'Native A-05 model {h}h',ROOT/f'rtl/reports/ccu_victim_escape/model_{h}h_2slots.log',True)
  paths=sorted((ROOT/'rtl/reports/full_integration').glob(f'top_lint_{h}h_????????_??????.log'));add(f'Production TOP lint {h}h',paths[-1],True)
  for area in ('directory_holder_lifecycle','ccu_victim_escape','fault_record_a06'):
   folder=ROOT/'rtl/reports'/area;m=folder/f'regression_sources_{h}h.json'
   if not m.exists() or not compatible_map(json.loads(m.read_text())):raise RuntimeError('stale/missing driver identity: '+str(m))
   driver=folder/f'regression_driver_{h}h.log';t=driver.read_text(errors='replace') if driver.exists() else '';parts=t.split('COMMAND: ')[1:]
   good=not re.search(r'%Error|%Warning|%Fatal|FAIL:',t)
   if area=='directory_holder_lifecycle':good &= len(parts)==21 and all('PASS:' in x for x in parts[:-1]) and 'Native Verilator exit code: 0' in parts[-1] and 'Warning diagnostics: 0' in parts[-1]
   else:good &= len(parts) in ((5,6) if area=='fault_record_a06' else (4,5)) and all('PASS:' in x for x in parts)
   rows.append(dict(test=f'Completed {area} driver {h}h',passed=good,log=driver.relative_to(ROOT).as_posix()))
  for label,build in (('A-06',f'fault_record_cpu_{h}h'),('A-05',f'victim_cpu_{h}h_2slots'),('A-04',f'holder_cpu_{h}h')):
   file=Path('C:/HQuan/.test_tmp')/build/'model_inputs.json';inputs=json.loads(file.read_text()) if file.exists() else {}
   good=bool(inputs) and all(compatible(n,d) for n,d in inputs.items())
   target=OUT/f'model_inputs_{label}_{h}h.json';target.write_text(json.dumps(inputs,indent=2)+'\n')
   rows.append(dict(test=f'{label} model/bench/program compatibility {h}h',passed=good,log=target.relative_to(ROOT).as_posix()))
  add(f'First fatal unit {h} active harts',OUT/f'unit/simulation_{h}h_error0.log');add(f'Native fault unit {h}h',OUT/f'unit/model_{h}h.log',True)
 for mode in (0,1,2):
  text=add(f'CSR group routing/base mode {mode}',OUT/f'map_mode{mode}/simulation_4h_error0.log');rows[-1]['passed'] &= hits(text,r'AXIL-MAP ASSERT (\d+) hits=(\d+)')
  add(f'Native CSR routing mode {mode}',OUT/f'map_mode{mode}/model_4h.log',True)
 f=OUT/'unit_mutant/mutation_result.txt';text=f.read_text() if f.exists() else ''
 rows.append(dict(test='First-fault overwrite mutant caught',passed=text.startswith('PASS:'),log=f.relative_to(ROOT).as_posix()))
 with (OUT/'csr_verify.log').open('w') as f:proc=subprocess.run([sys.executable,'scripts/generate_cluster_fault_csr.py'],cwd=ROOT,stdout=f,stderr=subprocess.STDOUT)
 add('Canonical CSR workbook/generator byte identity',OUT/'csr_verify.log');rows[-1]['passed'] &= proc.returncode==0
 baseline=json.loads((OUT/'baseline_sha256.json').read_text());changes=[];added=removed=total=0
 for name,d in current.items():
  if baseline.get(name)==d:continue
  item=dict(path=name,kind='MODIFIED' if name in baseline else 'NEW',after_sha256=d);before=OUT/'before'/name
  if before.exists():
   item['before_sha256']=sha(before);a=before.read_text(encoding='utf-8').splitlines();b=(ROOT/name).read_text(encoding='utf-8').splitlines();total+=len(a)
   for op,i,j,k,l in difflib.SequenceMatcher(None,a,b,autojunk=False).get_opcodes():
    if op!='equal':removed+=j-i;added+=l-k
  else:added+=len((ROOT/name).read_text(encoding='utf-8').splitlines())
  changes.append(item)
 verification={p.relative_to(ROOT).as_posix():sha(p) for p in Path(__file__).parent.rglob('*') if p.is_file() and p.suffix in ('.sv','.svh','.py','.hex')}
 result=dict(comment_only_cleanup=ledger,date='2026-11-16',top='m_vlsit_riscv_cluster_axi_top',results=rows,source_sha256=current,verification_sha256=verification,changed_rtl=changes,diff=dict(added=added,removed=removed,baseline_lines=total),coverage='Directed checks only; no code coverage measured')
 (OUT/'results.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
 lines=['# Validation / Kiem chung','','| Test | Result | Cycles | Evidence |','|---|---|---:|---|']
 for x in rows:lines.append(f"| {x['test']} | {'PASS' if x['passed'] else 'FAIL/missing'} | {x.get('cycles') or '-'} | [log](../../../{x['log']}) |")
 (OUT/'validation.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
 lines=['# Changed production RTL / RTL production da sua','','| File | Kind | SHA-256 |','|---|---|---|']
 for x in changes:lines.append(f"| [{x['path']}](../../../{x['path']}) | {x['kind']} | `{x['after_sha256']}` |")
 lines+=['',f'Diff +{added}/-{removed}; baseline {total} lines. Includes generated files/comments; not gate area. Pristine third_party sources were not edited.']
 (OUT/'changed_files.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
 bad=[x['test'] for x in rows if not x['passed']]
 if bad:print('FAIL/missing: '+', '.join(bad));return 1
 # Render actual post-rising-edge unit samples; never invent AXI latency.
 source=OUT/'unit/service_4h_error0.vcd';frames=[];time=None;values={}
 for line in source.read_text().splitlines():
  if line.startswith('#'):
   if time is not None and time<=117:frames.append((time,values.copy()))
   time=int(line[1:])
  elif time is not None and line.startswith('b'):
   value,key=line[1:].split();values[key]=value
 if time is not None and time<=117:frames.append((time,values.copy()))
 signals=[]
 for key,name in (('f','reset_n'),('a','L1 fatal event'),('b','LLC fatal event'),('c','record status'),('d','source/hart/BRESP'),('e','record address')):
  wave='';data=[];last=None
  for t,v in frames:
   value=int(v.get(key,'0'),2)
   if key in ('b','f'):wave+=str(value) if value!=last else '.'
   elif value==last:wave+='.'
   else:wave+='=';data.append(hex(value))
   last=value
  item=dict(name=name,wave=wave)
  if data:item['data']=data
  signals.append(item)
 dest=OUT/'waveforms';dest.mkdir(exist_ok=True)
 figure=dict(signal=signals,head=dict(text='A-06 / TEST-054 measured first fault, later event, reset'),foot=dict(text='Actual samples 2 ns after rising edges; times (ns): '+','.join(str(t) for t,_ in frames)+'. Not an AXI latency bound.'),config=dict(hscale=2))
 file=dest/'first_fault_4h.json';file.write_text(json.dumps(figure,indent=2)+'\n')
 subprocess.run([sys.executable,'C:/Users/PC/.codex/skills/vlsit-asic-ip-microspec/scripts/vlsit_waveform_svg.py','render',str(file),'--out',str(file.with_suffix('.svg')),'--force'],check=True)
 print(f'PASS: {len(rows)} evidence entries, 58 real CPU cases, {len(changes)} changed/new production RTL files; source identities and protocol activation verified.')
 return 0
if __name__=='__main__':raise SystemExit(main())
