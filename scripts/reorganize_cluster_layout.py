"""Reorganize the cluster workspace without changing production RTL bytes.

Usage: python scripts/reorganize_cluster_layout.py plan|apply|check
Inputs: the current cluster tree and its existing filelists/scripts/documents.
Outputs: project_support/maintenance/layout_migration/{manifest,validation}.json and snapshots.
Exit: 0 on success; nonzero on collision, escaped path, missing source or mutation.
Only the Python standard library is used. No recursive delete is performed.
"""
from pathlib import Path
import argparse
import hashlib
import json
import os
import re
import shutil
from collections import Counter
from functools import lru_cache

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'project_support/maintenance/layout_migration'
RTL={'.sv','.v','.svh','.vh','.vhd','.vhdl','.vp','.inc'}
FLISTS={'.f','.flist'}
DOC={'.md','.rst','.pdf','.docx','.xlsx','.pptx','.html','.htm','.svg','.png','.jpg','.jpeg'}
TEXT={'.md','.py','.ps1','.f','.flist','.json','.tcl','.sdc','.sh','.yml','.yaml','.toml','.txt'}
INTEGRATION={'atomic_coherence','atomic_end_to_end','l1_eviction_retention','l1_eviction_end_to_end',
 'directory_holder_lifecycle','directory_holder_end_to_end','ccu_victim_escape','fault_record_a06',
 'cmo_end_to_end','cluster_completeness_audit','e_to_m_fix','fence_i','fence_i_end_to_end',
 'fpu_warning_fix','full_integration','cluster_top_lint','post_a06_cluster_audit'}
PRIVATE={'m_vlsit_riscv_cluster_axi_top.sv','m_vlsit_riscv_cluster_core.sv','m_vlsit_riscv_axi_dw_adapter.sv'}
GROUPS={
 'address_map':{'m_vlsit_riscv_addr_decode.sv'},
 'cpu':{'m_vlsit_riscv_cpu_tile.sv','m_vlsit_riscv_cpu_tile_array.sv'},
 'maintenance':{'m_vlsit_riscv_cmo_arbiter.sv','m_vlsit_riscv_cmo_controller.sv'},
 'control':{'m_vlsit_riscv_axil_decode.sv','m_vlsit_axil_reg_bridge.sv'},
 'diagnostics':{'m_vlsit_riscv_fault_record.sv'},
 'debug':{'m_vlsit_riscv_debug_router.sv'},
 'interconnect':{'m_vlsit_riscv_axi_route.sv','m_vlsit_riscv_axi_mem_mux.sv','m_vlsit_riscv_axi_mmio.sv'},
 'cache':{'m_vlsit_axi_llc.sv'},
}

@lru_cache(maxsize=50000)
def safe(name):
    path=(ROOT/name).resolve()
    if path!=ROOT and ROOT not in path.parents: raise ValueError('Escaped workspace: '+str(path))
    return path

def sha(path): return hashlib.sha256(path.read_bytes()).hexdigest()
def profile(suite): return 'non_coherence_cluster' if suite in INTEGRATION else 'common'
def lint_name(path): return bool(re.search(r'lint|rule[_-]?(?:report|check)|_rules(?:\.|_)',path.name,re.I))
def group(name):
    if 'pmu' in name: return 'pmu'
    for key,names in GROUPS.items():
        if name in names: return key
    return 'coherence'

def destination(name):
    p=Path(name);parts=p.parts;suffix=p.suffix.lower()
    if name.startswith('rtl/third_party/'):
        tail=Path(*parts[2:]);lower=[s.lower() for s in tail.parts]
        if '.git' in lower or p.name.startswith('.git'):
            return (Path('project_support/provenance/third_party')/tail).as_posix()
        if p.name.upper().startswith(('LICENSE','COPYING','NOTICE','AUTHORS')):
            return (Path('project_support/licenses/third_party')/tail).as_posix()
        test=any(s in {'test','tests','tb','dv','formal','simulation','sim','example','examples'} for s in lower)
        support=('instr_tracer' in p.name or suffix in {'.cpp','.c','.cc','.h','.hpp','.hex','.mem','.bin','.elf','.s','.ld'})
        if suffix in DOC or suffix=='.txt': return (Path('project_support/third_party')/tail).as_posix()
        if test or support: return (Path('verification/common/third_party')/tail).as_posix()
        if suffix in RTL or suffix in FLISTS: return (Path('rtl/common/third_party')/tail).as_posix()
        return (Path('scripts/third_party')/tail).as_posix()
    if name.startswith('rtl/modified/'):
        tail=Path(*parts[2:])
        if suffix in RTL or suffix in FLISTS: return (Path('rtl/common/modified')/tail).as_posix()
        if suffix in DOC: return (Path('project_support/rtl_layout/modified')/tail).as_posix()
        return (Path('lint/common/modified')/tail).as_posix()
    if name.startswith('rtl/vlsit/'):
        tail=Path(*parts[2:])
        if tail.parts[0]=='csr_generated':
            if suffix in RTL or suffix in FLISTS:
                return (Path('rtl/common/vlsit/csr')/Path(*tail.parts[1:])).as_posix()
            return (Path('project_support/csr/generated')/Path(*tail.parts[1:])).as_posix()
        if suffix in RTL:
            return ('rtl/non_coherence_cluster/'+p.name if p.name in PRIVATE else 'rtl/common/vlsit/'+group(p.name)+'/'+p.name)
        if suffix in FLISTS: return 'rtl/common/filelists/legacy_vlsit/'+p.name
        if suffix in DOC: return 'project_support/rtl_layout/vlsit/'+tail.as_posix()
        return 'lint/common/legacy_vlsit/'+tail.as_posix()
    if name.startswith('rtl/verification/'):
        suite=parts[2];tail=Path(*parts[2:])
        if suffix=='.md': return (Path('project_support/verification')/profile(suite)/tail).as_posix()
        return (Path('verification')/profile(suite)/tail).as_posix()
    if name.startswith('rtl/reports/'):
        suite=parts[2];tail=Path(*parts[2:]);kind=profile(suite)
        if suffix=='.md': return (Path('project_support/reports')/tail).as_posix()
        if suffix in FLISTS:
            # Baseline/source snapshots retain their historical filelists.
            if any(v in parts for v in ('before','source_snapshots','simulation_sources')):
                return (Path('verification')/kind/'reports'/tail).as_posix()
            fkind='non_coherence_cluster' if suite in {'full_integration','cluster_top_lint'} else 'common'
            return (Path('rtl')/fkind/'filelists'/tail).as_posix()
        if lint_name(p) or ('subtop' in name and suffix=='.log'):
            return (Path('lint')/kind/tail).as_posix()
        return (Path('verification')/kind/'reports'/tail).as_posix()
    if name=='rtl/lint_source_overrides.json': return 'lint/config/lint_source_overrides.json'
    if name=='rtl/README.md': return 'project_support/rtl_layout/README.md'
    if len(parts)==1 and suffix=='.md' and p.name!='README.md':
        category='review' if p.name.startswith('rtl_change_review') else ('architecture' if p.name.startswith('VLSIT_') else 'research')
        return 'doc/'+category+'/'+p.name
    if len(parts)==1 and suffix=='.dasm': return 'verification/non_coherence_cluster/traces/'+p.name
    if parts[0]=='figures': return (Path('project_support/architecture_figures')/Path(*parts[1:])).as_posix()
    if parts[0]=='tensor_coprocessor': return (Path('doc/tensor_coprocessor')/Path(*parts[1:])).as_posix()
    if parts[0] in {'_spec_work','.artifact_work','_acl_recovery'}:
        return (Path('project_support/maintenance/legacy_work')/p).as_posix()
    if parts[0] in {'_tmp','.test_tmp'}: return (Path('verification/work/legacy')/p).as_posix()
    return name

def directory(name,context=''):
    name=name.rstrip('/')
    if name.startswith('rtl/reports/'):
        tail=name[len('rtl/reports/'):];suite=tail.split('/')[0];kind=profile(suite)
        lint=context.startswith('scripts/lint') or context=='scripts/run_cluster_top_lint.py'
        return ('lint/'+kind+'/' if lint else 'verification/'+kind+'/reports/')+tail
    if name=='rtl/vlsit': return 'rtl/common/vlsit'
    if name=='rtl/modified': return 'rtl/common/modified'
    if name=='rtl/third_party': return 'rtl/common/third_party'
    for old,new in [('rtl/third_party/','rtl/common/third_party/'),('rtl/modified/','rtl/common/modified/')]:
        if name.startswith(old): return new+name[len(old):]
    if name.startswith('rtl/vlsit/csr_generated'): return name.replace('rtl/vlsit/csr_generated','rtl/common/vlsit/csr',1)
    if name.startswith('rtl/verification/'):
        tail=name[len('rtl/verification/'):];suite=tail.split('/')[0]
        return 'verification/'+profile(suite)+'/'+tail
    if name=='rtl/reports': return 'verification/non_coherence_cluster/reports'
    return destination(name)

def plan():
    OUT.mkdir(parents=True,exist_ok=True)
    files=[]
    for base in ('rtl','figures','tensor_coprocessor','_spec_work','.artifact_work','_acl_recovery','_tmp','.test_tmp'):
        print('Inventory:',base,flush=True)
        root=ROOT/base
        if root.exists(): files.extend(p for p in root.rglob('*') if p.is_file())
    files.extend(p for p in ROOT.iterdir() if p.is_file())
    moves={p.relative_to(ROOT).as_posix():destination(p.relative_to(ROOT).as_posix()) for p in files}
    moves={a:b for a,b in moves.items() if a!=b}
    targets={}
    for old,new in moves.items():
        safe(old);target=safe(new)
        if target.exists() and old!=new: raise RuntimeError('Destination exists: '+new)
        if new in targets: raise RuntimeError('Collision: '+new)
        targets[new]=old
    print('Hashing design sources',flush=True)
    production={p.relative_to(ROOT).as_posix():sha(p) for p in (ROOT/'rtl').rglob('*')
                if p.is_file() and p.suffix.lower() in RTL and not any(v in p.parts for v in ('reports','verification'))}
    payload=dict(root=str(ROOT),moves=moves,production_sha256=production,text_changes={},status='planned')
    (OUT/'manifest.json').write_text(json.dumps(payload,indent=2)+'\n',encoding='utf-8')
    print('PLAN:',len(moves),'file moves;',len(production),'production source hashes recorded')
    print(dict(Counter('/'.join(v.split('/')[:2]) for v in moves.values())))

def apply(rebase=False):
    m=json.loads((OUT/'manifest.json').read_text());moves=m['moves']
    if m['status'] not in {'planned','files_moved'} and not rebase: raise RuntimeError('Migration already applied; use check')
    # All destinations are validated before the first move. No file is overwritten.
    if not rebase:
        for old,new in moves.items():
            source=safe(old);target=safe(new)
            if not source.exists() and target.exists(): continue
            if not source.exists() or target.exists(): raise RuntimeError('State changed: '+old)
        for old,new in moves.items():
            source=safe(old);target=safe(new);target.parent.mkdir(parents=True,exist_ok=True)
            if not source.exists() and target.exists(): continue
            source.rename(target)
    m['status']='files_moved';(OUT/'manifest.json').write_text(json.dumps(m,indent=2)+'\n',encoding='utf-8')
    # Remember old locations for active sources; historical logs/manifests remain
    # immutable. Only live tooling, filelists and Markdown links are rebased.
    active=[]
    active.extend((old,new) for old,new in moves.items() if old.startswith('rtl/verification/') and (Path(old).suffix.lower() in {'.py','.ps1','.sv','.svh'} or Path(old).name=='Makefile') or old.startswith('rtl/reports/') and Path(old).suffix.lower()=='.py')
    active.extend((p.relative_to(ROOT).as_posix(),p.relative_to(ROOT).as_posix()) for p in (ROOT/'scripts').glob('*.py') if p.name!=Path(__file__).name)
    active.extend((old,new) for old,new in moves.items() if Path(old).suffix.lower() in FLISTS and '/before/' not in old and '/source_snapshots/' not in old)
    active.extend((old,new) for old,new in moves.items() if Path(old).suffix.lower()=='.md')
    active.extend((p.relative_to(ROOT).as_posix(),p.relative_to(ROOT).as_posix()) for p in (ROOT/'doc').rglob('*.md') if 'layout_migration' not in p.parts and p.relative_to(ROOT).as_posix() not in moves.values())
    active.extend((p.relative_to(ROOT).as_posix(),p.relative_to(ROOT).as_posix()) for p in (ROOT/'doc/specification').rglob('*') if p.is_file() and p.suffix in {'.json','.drawio','.svg'} and 'revision_history' not in p.parts)
    active.append(('README.md','README.md'))
    for number,(old,new) in enumerate(dict(active).items()):
        if number%250==0: print('Rebasing live text:',number,'/',len(dict(active)),flush=True)
        path=safe(new)
        before=OUT/'before'/old
        try: original=before.read_bytes() if before.exists() else path.read_bytes();text=original.decode('utf-8-sig')
        except (UnicodeError,FileNotFoundError): continue
        def mapped(value,absolute=False):
            original_value=value
            value=value.replace('\\','/');prefix=ROOT.as_posix()+'/'
            if value.lower().startswith(prefix.lower()):
                tail=value[len(prefix):];target=moves.get(tail,directory(tail,old));return (ROOT/target).as_posix()
            if value.startswith(('rtl/','doc/','figures/','tensor_coprocessor/')):
                return moves.get(value,directory(value,old))
            if value.startswith('../'):
                bases=[safe(old).parent,ROOT/'rtl/reports/full_integration',ROOT/'rtl/reports/cva6_flush_path']
                for base in bases:
                    target=(base/value).resolve()
                    try: tail=target.relative_to(ROOT).as_posix()
                    except ValueError: continue
                    if tail in moves:
                        result=safe(moves[tail])
                        return result.as_posix() if absolute else os.path.relpath(result,safe(new).parent).replace('\\','/')
            return original_value
        if path.suffix.lower()=='.md':
            def mdlink(match):
                value=match[1]
                if '://' in value or value.startswith('#'): return match[0]
                raw,sep,anchor=value.partition('#');target=(safe(old).parent/raw).resolve()
                try: rel=target.relative_to(ROOT).as_posix()
                except ValueError: return match[0]
                updated=moves.get(rel,directory(rel,old))
                if rel.startswith('rtl/reports/') and safe('project_support/reports/'+rel[len('rtl/reports/'):]).is_dir():
                    updated='project_support/reports/'+rel[len('rtl/reports/'):]
                return ']('+os.path.relpath(safe(updated),path.parent).replace('\\','/')+(sep+anchor if sep else '')+')'
            text=re.sub(r'\]\(([^)]+)\)',mdlink,text)
            # Rebase literal project-relative paths in code/examples as well.
            text=re.sub(r'(?<![A-Za-z0-9_/])rtl/(?:third_party|modified|vlsit|verification|reports)(?:/[A-Za-z0-9_.-]+)*',lambda x:mapped(x[0]),text)
        elif path.suffix.lower() in {'.json','.drawio','.svg'} and old.startswith('doc/specification/'):
            text=re.sub(r'(?<![A-Za-z0-9_/])rtl/(?:third_party|modified|vlsit|verification|reports)(?:/[A-Za-z0-9_.-]+)*',lambda x:mapped(x[0]),text)
        elif path.suffix.lower() in FLISTS:
            lines=[]
            for line in text.splitlines():
                stripped=line.strip()
                if not stripped or stripped.startswith('//'): lines.append(line);continue
                if '$' in stripped or stripped.startswith('+define+'):
                    lines.append(line);continue
                marker=''
                if stripped.startswith('+incdir+'): marker='+incdir+';stripped=stripped[len(marker):]
                elif stripped.startswith(('-f ','-F ')): marker=stripped[:3];stripped=stripped[3:].strip()
                target=Path(stripped)
                if not target.is_absolute():
                    base=safe(old).parent.parent if 'csr_generated/RTL/' in old and stripped.startswith('RTL/') else safe(old).parent
                    target=(base/target).resolve()
                try: rel=target.relative_to(ROOT).as_posix()
                except ValueError: lines.append(line);continue
                if rel not in moves and not target.exists():
                    lines.append(line);continue
                target=safe(moves.get(rel,directory(rel,old)))
                lines.append(marker+target.as_posix())
            text='\n'.join(lines)+'\n'
        else:
            # Flatten only literal ROOT/path chains, not arbitrary expressions.
            chain=r'\b(ROOT|PROJECT_ROOT|PROJECT_DIR)\s*((?:/\s*(?:\x27[^\x27]+\x27|"[^"]+")\s*)+)' 
            def rootchain(match):
                parts=re.findall(r'[\x27"]([^\x27"]+)[\x27"]',match[2]);value='/'.join(parts)
                trailing=re.search(r'\s*$',match[0])[0]
                return match[1]+" / "+repr(mapped(value))+trailing
            text=re.sub(chain,rootchain,text)
            text=re.sub(r'([\x27"])([^\x27"\r\n]+)\1',lambda x:x[1]+mapped(x[2],True)+x[1],text)
            # Source-root discovery remains complete after the AXI-private split.
            text=re.sub(r'\(\s*[\x27"]rtl/common/vlsit[\x27"]\s*,\s*[\x27"]rtl/common/modified[\x27"]\s*\)',
                        "('rtl/common/vlsit','rtl/common/modified','rtl/non_coherence_cluster','rtl/coherence_cluster')",text)
            # __file__ nesting changes for report helpers, not test interfaces.
            index=len(Path(new).parts)-1
            text=re.sub(r'(?m)^(\s*(?:ROOT|PROJECT_ROOT|PROJECT_DIR)\s*=\s*)Path\(__file__\)\.resolve\(\)\.parents\[\d+\]',lambda x:x[1]+'Path(__file__).resolve().parents['+str(index)+']',text)
            text=re.sub(r'(?m)^(\s*ROOT\s*=\s*)OUT\.parents\[\d+\]',lambda x:x[1]+'OUT.parents['+str(len(Path(new).parts)-2)+']',text)
            text=text.replace("Path('C:/HQuan/.test_tmp')", "(ROOT / 'verification/non_coherence_cluster/build')")
            if path.name=='Makefile':
                text=re.sub(r'(?<![A-Za-z0-9_/])(?:\.\./)+(?:[A-Za-z0-9_.-]+/)*[A-Za-z0-9_.-]+',lambda x:mapped(x[0]),text)
        rewritten=text.encode('utf-8')
        if rewritten!=path.read_bytes():
            before=OUT/'before'/old;before.parent.mkdir(parents=True,exist_ok=True);before.write_bytes(original)
            path.write_text(text,encoding='utf-8',newline='\n')
        if rewritten!=original:
            m['text_changes'][new]=dict(old_path=old,before_sha256=hashlib.sha256(original).hexdigest(),after_sha256=sha(path))
        else:
            m['text_changes'].pop(new,None)
    # Empty directory removal only; source and destination are workspace-checked.
    for base in ('rtl','figures','tensor_coprocessor','_spec_work','.artifact_work','_acl_recovery','_tmp','.test_tmp'):
        path=safe(base)
        if not path.exists(): continue
        dirs=sorted((p for p in path.rglob('*') if p.is_dir()),key=lambda p:len(p.parts),reverse=True)
        for folder in dirs+[path]:
            safe(folder.relative_to(ROOT).as_posix())
            try: folder.rmdir()
            except OSError: pass
    safe('rtl/coherence_cluster').mkdir(parents=True,exist_ok=True)
    safe('rtl/coherence_cluster/filelist.f').write_text('// ACE profile not implemented. Intentionally no placeholder RTL.\n// See project_support/rtl_layout/README.md.\n',encoding='utf-8')
    for name in ('lint/non_coherence_cluster','verification/coherence_cluster','project_support/rtl_layout'):
        safe(name).mkdir(parents=True,exist_ok=True)
    m['status']='applied';(OUT/'manifest.json').write_text(json.dumps(m,indent=2)+'\n',encoding='utf-8')
    print('APPLIED:',len(moves),'moves;',len(m['text_changes']),'live path/link updates')

def check():
    m=json.loads((OUT/'manifest.json').read_text());bad=[]
    for old,digest in m['production_sha256'].items():
        path=safe(m['moves'].get(old,old))
        if not path.exists() or sha(path)!=digest: bad.append('Source changed: '+old)
    extra=[p.relative_to(ROOT).as_posix() for p in (ROOT/'rtl').rglob('*') if p.is_file() and p.suffix.lower() not in RTL|FLISTS]
    if extra: bad+=['Non-RTL file: '+p for p in extra]
    result=dict(status='PASS' if not bad else 'FAIL',production_source_hashes=len(m['production_sha256']),
                moves=len(m['moves']),live_path_updates=len(m['text_changes']),findings=bad)
    (OUT/'validation.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    if bad: raise RuntimeError('\n'.join(bad[:30]))
    print('PASS: production bytes unchanged; rtl contains only RTL/include/filelist files')

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('action',choices=('plan','apply','rebase','check'))
    args=parser.parse_args();{'plan':plan,'apply':apply,'rebase':lambda:apply(True),'check':check}[args.action]()
