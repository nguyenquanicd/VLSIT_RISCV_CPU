"""Resolve preserved historical evidence after the source-only layout migration.

Purpose: translate recorded old paths without modifying raw logs/manifests, and
accept a recorded digest only against exact current bytes or the migration's
archived before/after ledger. This does not run or claim a new simulation.
Usage: import map_path, loads_legacy, matches_legacy_digest in evidence readers.
Inputs: doc/maintenance/layout_migration/manifest.json. Outputs: none.
Python standard library only; failures return False or raise normal read errors.
"""
from pathlib import Path
from functools import lru_cache
import hashlib
import json

ROOT=Path(__file__).resolve().parents[1]

@lru_cache(maxsize=1)
def migration():
    return json.loads((ROOT/'doc/maintenance/layout_migration/manifest.json').read_text(encoding='utf-8'))

def map_path(value):
    if not isinstance(value,str): return value
    text=value.replace('\\','/')
    prefix=ROOT.as_posix()+'/'
    absolute=text.lower().startswith(prefix.lower())
    relative=text[len(prefix):] if absolute else text
    moved=migration()['moves'].get(relative)
    if moved is None: return value
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
    delta=migration().get('text_changes',{}).get(name)
    if not delta or delta['before_sha256']!=expected or delta['after_sha256']!=actual: return False
    archive=ROOT/'doc/maintenance/layout_migration/before'/delta['old_path']
    return archive.is_file() and hashlib.sha256(archive.read_bytes()).hexdigest()==expected
