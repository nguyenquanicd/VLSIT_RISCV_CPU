"""Resolve preserved historical evidence after the source-only layout migration.

Purpose: translate recorded old paths without modifying raw logs/manifests, and
accept a recorded digest only against exact current bytes or the migration's
archived before/after ledger. This does not run or claim a new simulation.
Usage: import map_path, loads_legacy, matches_legacy_digest in evidence readers.
Inputs: project_support/maintenance/layout_migration/manifest.json. Outputs: none.
Python standard library only; failures return False or raise normal read errors.
"""
from pathlib import Path
from functools import lru_cache
import hashlib
import json

ROOT=Path(__file__).resolve().parents[1]

@lru_cache(maxsize=1)
def doc_cleanup():
    path=ROOT/'project_support/doc_cleanup_20261116/manifest.json'
    return json.loads(path.read_text(encoding='utf-8')) if path.is_file() else {}

@lru_cache(maxsize=1)
def migration():
    result=json.loads((ROOT/'project_support/maintenance/layout_migration/manifest.json').read_text(encoding='utf-8'))
    # Apply the newer doc relocation in memory; preserve the historical ledger bytes.
    moves=doc_cleanup().get('moves',{})
    result['moves']={old:moves.get(new,new) for old,new in result['moves'].items()}
    return result

def map_path(value):
    if not isinstance(value,str): return value
    text=value.replace('\\','/')
    prefix=ROOT.as_posix()+'/'
    absolute=text.lower().startswith(prefix.lower())
    relative=text[len(prefix):] if absolute else text
    moved=migration()['moves'].get(relative,relative)
    moved=doc_cleanup().get('moves',{}).get(moved,moved)
    if moved==relative: return value
    return (ROOT/moved).as_posix() if absolute else moved

def loads_legacy(text,**kwargs):
    def visit(value):
        if isinstance(value,dict): return {map_path(k):visit(v) for k,v in value.items()}
        if isinstance(value,list): return [visit(v) for v in value]
        return map_path(value)
    return visit(json.loads(text,**kwargs))

def matches_legacy_digest(path,expected):
    path=Path(path)
    if not path.is_file(): return False
    actual=hashlib.sha256(path.read_bytes()).hexdigest()
    if actual==expected: return True
    try: name=path.resolve().relative_to(ROOT).as_posix()
    except ValueError: return False
    cleanup=doc_cleanup()
    cleanup_delta=cleanup.get('text_changes',{}).get(name)
    if cleanup_delta and cleanup_delta['after_sha256']==actual:
        backup=ROOT/'project_support/doc_cleanup_20261116/before'/cleanup_delta['old_path']
        if not backup.is_file() or hashlib.sha256(backup.read_bytes()).hexdigest()!=cleanup_delta['before_sha256']:
            return False
        actual=cleanup_delta['before_sha256']
        if actual==expected: return True
    old_name=next((old for old,new in cleanup.get('moves',{}).items() if new==name),name)
    delta=migration().get('text_changes',{}).get(old_name)
    if not delta or delta['before_sha256']!=expected or delta['after_sha256']!=actual: return False
    archive=ROOT/'project_support/maintenance/layout_migration/before'/delta['old_path']
    return archive.is_file() and hashlib.sha256(archive.read_bytes()).hexdigest()==expected
