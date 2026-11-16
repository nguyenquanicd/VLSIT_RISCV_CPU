"""Lint the modified real HPDcache flush engine with its native types and modules."""
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
    tool = args.verilator or shutil.which('verilator')
    fallback = Path('C:/Tools/oss-cad-suite/bin/verilator_bin.exe')
    if not tool and fallback.is_file():
        tool = str(fallback)
    if not tool:
        parser.error('Verilator not found')
    upstream = ROOT / 'rtl/third_party/hpdcache_cva6_pinned'
    out = ROOT / 'rtl/reports/hpdcache_flush'
    sources = [upstream / 'rtl/src/hpdcache_pkg.sv']
    sources += sorted((upstream / 'rtl/src/common').glob('*.sv'))
    sources += [ROOT / 'rtl/modified/hpdcache/rtl/src/hpdcache_flush.sv',
                out / 'hpdcache_flush_lint.sv']
    filelist = out / 'filelist.f'
    filelist.write_text('+incdir+' + (upstream / 'rtl/include').as_posix() + '\n'
                        + '\n'.join(source.as_posix() for source in sources) + '\n',
                        encoding='utf-8')
    command = [tool, '--lint-only', '-Wall', '-Wno-fatal', '--top-module',
               'hpdcache_flush_lint', '-f', str(filelist)]
    run = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
    output = run.stdout + run.stderr
    (out / 'lint.log').write_text(subprocess.list2cmdline(command) + '\n' + output,
                                  encoding='utf-8')
    errors = sum(line.startswith('%Error') for line in output.splitlines())
    warnings = sum(line.startswith('%Warning') for line in output.splitlines())
    passed = run.returncode == 0 and errors == 0 and '%Warning-LATCH' not in output
    result = dict(passed=passed, errors=errors, warnings=warnings)
    (out / 'lint_result.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(result)
    return 0 if passed else 1


if __name__ == '__main__':
    raise SystemExit(main())
