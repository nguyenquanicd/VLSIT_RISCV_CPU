"""Preserve upstream sources and baseline snapshots for reviewed lint remediation."""
from pathlib import Path
import json
import re
import shutil

ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / 'lint/config/lint_source_overrides.json'
SNAPSHOT = ROOT / 'lint/non_coherence_cluster/full_integration/source_snapshots/lint_cleanup_20261115'

def vendor(relative):
    source = ROOT / 'rtl/common/third_party'/relative
    overrides = json.loads(REGISTRY.read_text(encoding='utf-8')) if REGISTRY.exists() else {}
    key=source.relative_to(ROOT).as_posix()
    target = Path(overrides.get(key, overrides.get(source.as_posix(), str(ROOT / 'rtl/common/modified'/relative))))
    if not target.is_absolute():
        target=ROOT/target
    if not target.exists():
        target.parent.mkdir(parents=True,exist_ok=True)
        shutil.copy2(source,target)
    overrides[key] = target.relative_to(ROOT).as_posix()
    REGISTRY.write_text(json.dumps(overrides,indent=2)+'\n',encoding='utf-8')
    return target,target.read_text(encoding='utf-8')

def save(path, text, rationale):
    backup = SNAPSHOT/path.relative_to(ROOT)
    if not backup.exists():
        backup.parent.mkdir(parents=True,exist_ok=True)
        shutil.copy2(path,backup)
    if rationale not in text:
        match=re.search(r'^(?:module|package)\s',text,re.M)
        assert match,path
        text=text[:match.start()]+'// 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:\n// '+rationale+'\n'+text[match.start():]
    path.write_text(text,encoding='utf-8')
