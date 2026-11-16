"""Verify or regenerate the A-06 canonical AXI4-Lite CSR workbook output."""
from pathlib import Path
import argparse,hashlib,json,subprocess,sys,shutil,re
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'rtl/reports/fault_record_a06'
BOOK=ROOT/'doc/specification/VLSIT_RISCV_CPU_Cluster_CSR.xlsx'
DEST=ROOT/'rtl/vlsit/csr_generated'
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--regenerate',action='store_true');p.add_argument('--generator',type=Path,default=ROOT.parent/'APB-CSR-Generator/CSR_Generation.py');a=p.parse_args()
 if a.regenerate:
  work=OUT/'generated';cmd=[sys.executable,str(a.generator),str(BOOK),'AXIL_QUEUED','--out',str(work),'--project','VLSIT RISC-V CPU Cluster','--author','Quan Nguyen (user)','--vlsit-style']
  with (OUT/'generator.log').open('w') as f:subprocess.run(cmd,cwd=ROOT,stdout=f,stderr=subprocess.STDOUT,check=True)
  for folder in ('RTL','Debug'):
   for source in (work/folder).rglob('*'):
    if source.is_file():
     target=DEST/source.relative_to(work);target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(source,target)
  m=dict(generator=str(a.generator),generator_sha256=digest(a.generator),version=re.search(r'VERSION = "([^"]+)"',a.generator.read_text())[1],workbook=BOOK.relative_to(ROOT).as_posix(),workbook_sha256=digest(BOOK),sheet='AXIL_QUEUED',files={p.relative_to(ROOT).as_posix():digest(p) for folder in ('RTL','Debug') for p in (DEST/folder).rglob('*') if p.is_file()})
  m['generator_dependencies']={p.name:digest(p) for p in (a.generator.parent/'CSR_Protocol_Generation.py',) if p.exists()}
  (OUT/'csr_generation.json').write_text(json.dumps(m,indent=2)+'\n')
 m=json.loads((OUT/'csr_generation.json').read_text())
 if digest(BOOK)!=m['workbook_sha256'] or digest(Path(m['generator']))!=m['generator_sha256']:raise RuntimeError('workbook/generator provenance changed; regenerate explicitly')
 for name,d in m['files'].items():
  if digest(ROOT/name)!=d:raise RuntimeError('generated file hand-edited or stale: '+name)
 for name,d in m.get('generator_dependencies',{}).items():
  if digest(Path(m['generator']).parent/name)!=d:raise RuntimeError('generator dependency changed')
 print('PASS: canonical workbook, generator provenance and byte-exact generated CSR output');return 0
if __name__=='__main__':raise SystemExit(main())
