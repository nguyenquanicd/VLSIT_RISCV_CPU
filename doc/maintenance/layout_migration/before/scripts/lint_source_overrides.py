"""Resolve license-preserving lint fixes into the generated production filelists."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / 'rtl/lint_source_overrides.json'

def rewrite_source_paths(text):
    if not REGISTRY.exists():
        return text
    overrides = json.loads(REGISTRY.read_text(encoding='utf-8'))
    for source, target in overrides.items():
        source_path=Path(source)
        target_path=Path(target)
        if not source_path.is_absolute():
            source_path=ROOT/source_path
        if not target_path.is_absolute():
            target_path=ROOT/target_path
        text = text.replace(source_path.as_posix(), target_path.as_posix())
    return text

def apply_overrides():
    for name in ('rtl/reports/cva6_flush_path/cva6_modified_cache.Flist',
                 'rtl/reports/cva6_flush_path/hpdcache_modified.Flist',
                 'rtl/reports/full_integration/filelist_llc_unique.f'):
        path = ROOT / name
        if not path.exists():
            continue
        original = path.read_text(encoding='utf-8')
        text = rewrite_source_paths(original)
        if text != original:
            path.write_text(text, encoding='utf-8')

if __name__ == '__main__':
    apply_overrides()
