"""Collect A-03 native logs and hashes; reject missing/failed validation."""
from pathlib import Path
import hashlib,json,re,sys,difflib,subprocess
ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'rtl/reports/l1_eviction_retention'

def main():
 rows=[]
 def add(name,path,model=False):
  text=path.read_text(encoding='utf-8',errors='replace') if path.exists() else ''
  okay=('Verilator: Built' in text if model else 'PASS:' in text) and not re.search(r'%Warning|%Error|%Fatal',text)
  m=re.search(r'PASS:.*cycles=(\d+)',text)
  rows.append(dict(test=name,passed=okay,cycles=int(m[1]) if m else None,log=path.relative_to(ROOT).as_posix()))
 for h in (2,4):
  for e in (0,2,3):add(f'L1 eviction {h}h B={e}',OUT/f'simulation_{h}h_error{e}.log')
  for case in ('success','lrsc_contention','amo_fault','lr_fault','owner_fault'):
   add(f'Atomic {h}h {case}',ROOT/f'rtl/reports/atomic_coherence/simulation_{h}h_{case}.log')
  for e in (0,1):
   for suffix in ('','_load_first'):add(f'CBO {h}h error={e}{suffix}',ROOT/f'rtl/reports/cmo_end_to_end/simulation_{h}h_error{e}{suffix}.log')
   for suffix in ('','_supervisor'):add(f'FENCE.I {h}h error={e}{suffix}',ROOT/f'rtl/reports/fence_i_end_to_end/simulation_{h}h_error{e}{suffix}.log')
  for area in ('l1_eviction_retention','atomic_coherence','cmo_end_to_end','fence_i_end_to_end'):
   add(f'Model {area} {h}h',ROOT/f'rtl/reports/{area}/model_{h}h.log',True)
  paths=sorted(p for p in (ROOT/'rtl/reports/full_integration').glob(f'top_lint_{h}h_*.log') if re.fullmatch(rf'top_lint_{h}h_\d{{8}}_\d{{6}}\.log',p.name))
  add(f'TOP lint {h}h',paths[-1],True)
  driver=OUT/f'regression_driver_{h}h.log'
  text=driver.read_text(encoding='utf-8',errors='replace') if driver.exists() else ''
  sections=text.split('COMMAND: ')[1:]
  complete=(len(sections)==17 and all('PASS:' in part for part in sections[:-1]) and
            'Native Verilator exit code: 0' in sections[-1] and
            'Warning diagnostics: 0' in sections[-1] and
            not re.search(r'%Warning|%Error|%Fatal',text))
  rows.append(dict(test=f'Completed current regression driver {h}h',passed=complete,log=driver.relative_to(ROOT).as_posix()))

 add('LLC clean/full pending ring',OUT/'llc_pending.log')
 changes=[];added=removed=total=0
 for before in sorted((OUT/'before').rglob('*.sv')):
  rel=before.relative_to(OUT/'before')
  if rel.parts[:2] not in (('rtl','modified'),('rtl','vlsit')):continue
  after=ROOT/rel
  old=before.read_bytes();new=after.read_bytes()
  if old!=new:
   changes.append(dict(path=rel.as_posix(),before_sha256=hashlib.sha256(old).hexdigest(),after_sha256=hashlib.sha256(new).hexdigest()))
   a=old.decode().splitlines();b=new.decode().splitlines();total+=len(a)
   for op,i,j,k,l in difflib.SequenceMatcher(None,a,b,autojunk=False).get_opcodes():
    if op!='equal':removed+=j-i;added+=l-k
 sources={p.relative_to(ROOT).as_posix():hashlib.sha256(p.read_bytes()).hexdigest() for base in ('rtl/vlsit','rtl/modified') for p in sorted((ROOT/base).rglob('*.sv'))}
 result=dict(date='2026-11-15',top='m_vlsit_riscv_cluster_axi_top',results=rows,changed_rtl=changes,source_sha256=sources,diff=dict(added=added,removed=removed,baseline_lines=total),coverage='Directed checks only; code coverage not measured')
 inventory=['# Changed production RTL / RTL production đã sửa','','| File | SHA-256 after |','|---|---|']
 for item in changes:inventory.append(f"| [{item['path']}](../../../{item['path']}) | `{item['after_sha256']}` |")
 inventory+=['',f'Diff +{added}/−{removed} lines, baseline {total} lines; churn {(added+removed)*100/total:.2f}%. Includes comments; not gate area. / Gồm comment, không phải gate area.']
 (OUT/'changed_files.md').write_text('\n'.join(inventory)+'\n',encoding='utf-8')
 (OUT/'results.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
 lines=['# Validation / Kiểm chứng','','| Test | Result | Cycles | Log |','|---|---|---:|---|']
 for row in rows:lines.append(f"| {row['test']} | {'PASS' if row['passed'] else 'FAIL/missing'} | {row.get('cycles') or '—'} | [log](../../../{row['log']}) |")
 (OUT/'validation.md').write_text('\n'.join(lines)+'\n',encoding='utf-8')
 bad=[r['test'] for r in rows if not r['passed']]
 if bad:print('FAIL/missing: '+', '.join(bad));return 1
 # Use the actual scalar/vector VCD values, retaining nonuniform event times.
 render=Path('C:/Users/PC/.codex/skills/vlsit-asic-ip-microspec/scripts/vlsit_waveform_svg.py')
 out=OUT/'waveforms';out.mkdir(exist_ok=True)
 for error in (0,2,3):
  source=OUT/f'service_4h_error{error}.vcd';state={};frames=[];stamp=None
  for line in source.read_text().splitlines():
   if line.startswith('#'):
    if stamp is not None:frames.append((stamp,state.copy()))
    stamp=int(line[1:])
   elif stamp is not None and line.startswith('b'):
    value,key=line[1:].split();state[key]=value
  if stamp is not None:frames.append((stamp,state.copy()))
  samples=[];prior=None
  for t,frame in frames:
   values=tuple(frame.get(k,'0') for k in ('a','b','c'))
   if values!=prior:samples.append((t,values));prior=values
  signals=[]
  for i,name in enumerate(('eviction_error_harts','pending_evictions','completed_misses')):
   wave='';data=[];last=None
   for t,values in samples:
    value=hex(int(values[i],2))
    if value==last:wave+='.'
    else:wave+='=';data.append(value);last=value
   signals.append(dict(name=name,wave=wave,data=data))
  figure=dict(signal=signals,head=dict(text=f'TEST-050: 4 harts, B={error}; actual event samples'),foot=dict(text='Times (ns): '+', '.join(str(t) for t,_ in samples)+'. Nonuniform gaps.'),config=dict(hscale=2))
  path=out/f'4h_error{error}.json';path.write_text(json.dumps(figure,indent=2)+'\n')
  subprocess.run([sys.executable,str(render),'render',str(path),'--out',str(path.with_suffix('.svg')),'--force'],check=True)
 print(f'PASS: {len(rows)} validation entries; {len(changes)} changed RTL files; final source hashes recorded.')
 return 0
if __name__=='__main__':raise SystemExit(main())
