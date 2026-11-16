"""Reproduce standalone CMO/tile-adapter lint; this is not a cluster signoff."""
from pathlib import Path
import argparse
import json
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--verilator')
    args = parser.parse_args()
    tool = args.verilator or shutil.which('verilator') or shutil.which('verilator_bin.exe')
    fallback = Path('C:/Tools/oss-cad-suite/bin/verilator_bin.exe')
    if not tool and fallback.is_file():
        tool = str(fallback)
    if not tool:
        parser.error('Verilator not found; pass --verilator')
    out = ROOT / 'rtl/reports/cmo_tile'
    out.mkdir(parents=True, exist_ok=True)
    results = []
    for module in ['m_vlsit_riscv_cmo_controller', 'm_vlsit_riscv_tile_coh_adapter']:
        source = ROOT / ('rtl/vlsit/' + module + '.sv')
        for contexts in (2, 5, 8, 16):
            harts = (2, 4) if module.endswith('controller') else (None,)
            for hart in harts:
                label = module + '_t' + str(contexts) + ('_h' + str(hart) if hart else '')
                command = [tool, '--lint-only', '-Wall', '-Wno-fatal', '--top-module',
                           module, '-GPARA_COH_TXN_NUM=' + str(contexts)]
                if hart:
                    command.append('-GPARA_CPU_NUM=' + str(hart))
                command.append(str(source))
                if module.endswith('adapter'):
                    command.append(str(ROOT / 'rtl/vlsit/m_vlsit_riscv_cache_line_locks.sv'))
                run = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
                output = run.stdout + run.stderr
                (out / (label + '.log')).write_text(subprocess.list2cmdline(command)
                    + '\n' + output, encoding='utf-8')
                errors = sum(line.startswith('%Error') for line in output.splitlines())
                warnings = sum(line.startswith('%Warning') for line in output.splitlines())
                passed = run.returncode == 0 and errors == 0 and '%Warning-LATCH' not in output
                results.append(dict(configuration=label, passed=passed,
                                    errors=errors, warnings=warnings))
                print(f'{label}: {"PASS" if passed else "FAIL"}; {errors} errors, {warnings} warnings')
    (out / 'results.json').write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
    return 0 if all(result['passed'] for result in results) else 1


if __name__ == '__main__':
    raise SystemExit(main())
