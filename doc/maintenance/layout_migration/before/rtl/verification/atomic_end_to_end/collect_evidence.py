"""Collect actual A-02 results, source hashes and event-sampled VCD figures."""
from pathlib import Path
import hashlib
import json
import re
import subprocess
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[3]
REPORT = ROOT / 'rtl/reports/atomic_coherence'
RENDER = Path('C:/Users/PC/.codex/skills/vlsit-asic-ip-microspec/scripts/vlsit_waveform_svg.py')


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def result(name, path):
    text = path.read_text(encoding='utf-8', errors='replace') if path.exists() else ''
    okay = 'PASS:' in text and not re.search(r'%Warning|%Error|%Fatal', text)
    cycles = re.search(r'PASS:.*cycles=(\d+)', text)
    return dict(test=name, passed=okay, cycles=int(cycles[1]) if cycles else None,
                log=path.relative_to(ROOT).as_posix(),
                checks=[line for line in text.splitlines() if line.startswith(('PASS:', 'CHECK '))])


def waveform(harts, case):
    source = REPORT / f'service_{harts}h_{case}.vcd'
    frames, state, stamp = [], {}, None
    for line in source.read_text().splitlines():
        if line.startswith('#'):
            if stamp is not None:
                frames.append((stamp, state.copy()))
            stamp = int(line[1:])
        elif stamp is not None and line.startswith('b'):
            value, key = line[1:].split()
            state[key] = value
    if stamp is not None:
        frames.append((stamp, state.copy()))
    samples, previous = [], None
    for stamp, frame in frames:
        values = tuple(frame.get(k, '0') for k in ('a', 'b', 'c'))
        if values != previous:
            samples.append((stamp, values))
            previous = values
    samples = samples[:18]
    signals = []
    for index, name in enumerate(('atomic_response_ack', 'probe_rsp_valid', 'probe_rsp_ready')):
        wave, data, previous = '', [], None
        for stamp, values in samples:
            value = hex(int(values[index], 2))
            if value == previous:
                wave += '.'
            else:
                wave += '='
                data.append(value)
                previous = value
        signals.append(dict(name=name, wave=wave, data=data))
    figure = dict(signal=signals,
                  head=dict(text=f'A-02 {harts} harts: {case}; actual event samples'),
                  foot=dict(text='Times (ns): ' + ', '.join(str(t) for t, _ in samples)
                            + '. Nonuniform gaps; not clock-cycle columns.'),
                  config=dict(hscale=2))
    out = REPORT / 'waveforms'
    out.mkdir(exist_ok=True)
    target = out / f'{harts}h_{case}.json'
    target.write_text(json.dumps(figure, indent=2) + '\n', encoding='utf-8')
    subprocess.run([sys.executable, str(RENDER), 'render', str(target),
                    '--out', str(target.with_suffix('.svg')), '--force'], check=True)
    ET.parse(target.with_suffix('.svg'))


def main():
    rows = []
    for harts in (2, 4):
        for case in ('success', 'lrsc_contention', 'amo_fault', 'lr_fault', 'owner_fault'):
            rows.append(result(f'Atomic {harts}h {case}', REPORT / f'simulation_{harts}h_{case}.log'))
        for error in (0, 1):
            for suffix in ('', '_load_first'):
                rows.append(result(f'CBO {harts}h error={error}{suffix}',
                                   ROOT / f'rtl/reports/cmo_end_to_end/simulation_{harts}h_error{error}{suffix}.log'))
            for suffix in ('', '_supervisor'):
                rows.append(result(f'FENCE.I {harts}h error={error}{suffix}',
                                   ROOT / f'rtl/reports/fence_i_end_to_end/simulation_{harts}h_error{error}{suffix}.log'))
        for area in ('atomic_coherence', 'cmo_end_to_end', 'fence_i_end_to_end'):
            path = ROOT / f'rtl/reports/{area}/model_{harts}h.log'
            text = path.read_text(errors='replace') if path.exists() else ''
            rows.append(dict(test=f'Model {area} {harts}h',
                             passed='Verilator: Built' in text and
                             not re.search(r'%Warning|%Error|%Fatal', text),
                             log=path.relative_to(ROOT).as_posix()))
        candidates = sorted(p for p in (ROOT / 'rtl/reports/full_integration').glob(f'top_lint_{harts}h_*.log')
                            if re.fullmatch(rf'top_lint_{harts}h_\d{{8}}_\d{{6}}\.log', p.name))
        path = candidates[-1]
        text = path.read_text(errors='replace')
        rows.append(dict(test=f'TOP lint {harts}h',
                         passed='Verilator: Built' in text and not re.search(r'%Warning|%Error|%Fatal', text),
                         log=path.relative_to(ROOT).as_posix()))
    for name in ('retirement', 'llc_pending', 'llc_evict_ok', 'llc_evict_error'):
        rows.append(result(name, REPORT / f'{name}.log'))
    for name in ('probe_unit', 'refill_unit', 'bank_unit'):
        rows.append(result(name, REPORT / name / 'simulation_4h_error0.log'))
    changed = []
    baseline = REPORT / 'before'
    for before in sorted(baseline.rglob('*.sv')):
        relative = before.relative_to(baseline)
        after = ROOT / relative
        if after.exists() and before.read_bytes() != after.read_bytes():
            changed.append(dict(path=relative.as_posix(), before_sha256=sha(before),
                                after_sha256=sha(after)))
    sources = {}
    for folder in (ROOT / 'rtl/vlsit', ROOT / 'rtl/modified'):
        for path in sorted(folder.rglob('*.sv')):
            sources[path.relative_to(ROOT).as_posix()] = sha(path)
    payload = dict(date='2026-11-15', top='m_vlsit_riscv_cluster_axi_top',
                   scope='Cached atomic AXI profile; directed tests, no code coverage',
                   results=rows, changed_rtl=changed, source_sha256=sources)
    (REPORT / 'results.json').write_text(json.dumps(payload, indent=2) + '\n', encoding='utf-8')
    lines = ['# Validation results / Kết quả kiểm chứng', '',
             '| Test | Result | Cycles | Log |', '|---|---|---:|---|']
    for row in rows:
        link = '../../..' + '/' + row['log']
        lines.append(f"| {row['test']} | {'PASS' if row['passed'] else 'FAIL / missing'} | "
                     f"{row.get('cycles') or '—'} | [log]({link}) |")
    (REPORT / 'validation.md').write_text('\n'.join(lines) + '\n', encoding='utf-8')
    failed = [row['test'] for row in rows if not row['passed']]
    if failed:
        print('FAIL or missing: ' + ', '.join(failed))
        return 1
    for case in ('success', 'lrsc_contention', 'owner_fault'):
        waveform(4, case)
    print(f'PASS: {len(rows)} validation entries; {len(changed)} changed RTL files; source hashes recorded.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
