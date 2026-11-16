"""Check cycle equivalence against the independent unmodified FPU implementation."""
from pathlib import Path
import sys
ROOT=Path(__file__).resolve().parents[3]
sys.path.insert(0,str(ROOT/'scripts'))
import run_lint_refactor_checks as checks
from lint_source_overrides import apply_overrides
apply_overrides()
checks.OUT=ROOT/'rtl/reports/fpu_warning_fix'
checks.run_one('wrap',ROOT/'rtl/third_party/cva6/core/fpu_wrap.sv',[
    '-f',str(ROOT/'rtl/reports/cva6_flush_path/cva6_modified_cache.Flist')])
