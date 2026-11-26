"""Check the final A-06 evidence package without rebuilding RTL."""
from pathlib import Path
import hashlib
import json
import re
import xml.etree.ElementTree as ET

OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[2]
result = json.loads((OUT / 'results.json').read_text())
assert len(result['results']) == 98
assert all(row['passed'] for row in result['results'])
assert sum(' CPU ' in row['test'] for row in result['results']) == 58
assert len(result['changed_rtl']) == 13
for group in ('source_sha256', 'verification_sha256'):
    for name, expected in result[group].items():
        assert hashlib.sha256((ROOT / name).read_bytes()).hexdigest() == expected, name
for row in result['results']:
    assert (ROOT / row['log']).is_file(), row
ET.parse(OUT / 'waveforms/first_fault_4h.svg')
for name in ('README.md', 'validation.md', 'changed_files.md', 'waveform_compare.md'):
    text = (OUT / name).read_text(encoding='utf-8')
    for target in re.findall(r'\]\(([^)]+)\)', text):
        if '://' in target or target.startswith('#'):
            continue
        assert (OUT / target.split('#')[0]).exists(), (name, target)
assert 'A-06 / TEST-054 measured' in (OUT / 'waveforms/first_fault_4h.json').read_text()
for harts in (2, 4):
    row = next(r for r in result['results'] if r['test'] == f'Production TOP lint {harts}h')
    log = (ROOT / row['log']).read_text(encoding='utf-8')
    assert 'Verilator: Built' in log and not re.search(r'%Error|%Warning|%Fatal', log)
print('PASS: 98 evidence entries, 58 CPU cases, 13 RTL changes; hashes, links, SVG and final TOP lint intact')
