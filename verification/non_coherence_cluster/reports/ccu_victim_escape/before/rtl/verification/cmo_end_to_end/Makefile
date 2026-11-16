# Real instruction tests use the production TOP; logs are under rtl/reports/cmo_end_to_end.
PYTHON ?= python
.PHONY: all success2 error2 success4 error4 lint2 lint4 focused retirement ccu2 ccu4 pending eviction-ok eviction-error refactor fpu-refactor fpu-wrapper alu-refactor
all: success2 error2 success4 error4 lint2 lint4
success2:
	$(PYTHON) run.py --harts 2
error2: success2
	$(PYTHON) run.py --harts 2 --error 1 --run-only
success4:
	$(PYTHON) run.py --harts 4
error4: success4
	$(PYTHON) run.py --harts 4 --error 1 --run-only
lint2:
	$(PYTHON) ../../../scripts/run_cluster_top_lint.py --hart-count 2
lint4:
	$(PYTHON) ../../../scripts/run_cluster_top_lint.py --hart-count 4

# Focused native-block checks complement the real CPU instruction tests.
PSRUN = powershell -NoProfile -ExecutionPolicy Bypass -File ../cmo_metadata/run_regression.ps1
focused: retirement ccu2 ccu4 pending eviction-ok eviction-error
retirement:
	$(PSRUN) -Retirement
ccu2:
	$(PSRUN) -Ccu -Harts 2
ccu4:
	$(PSRUN) -Ccu -Harts 4
pending:
	$(PSRUN) -LlcPending
eviction-ok:
	$(PSRUN) -LlcTag -NormalEvict
eviction-error:
	$(PSRUN) -LlcTag -NormalEvict -WriteError

# Differential checks use independent pre-change sources; they supplement spec tests.
refactor:
	$(PYTHON) ../../../scripts/run_lint_refactor_checks.py
fpu-refactor:
	$(PYTHON) ../../../scripts/run_lint_refactor_checks.py --fpu
fpu-wrapper:
	$(PYTHON) ../../../scripts/run_lint_refactor_checks.py --wrap
alu-refactor:
	$(PYTHON) ../../../scripts/run_lint_refactor_checks.py --alu

# DEC-030/031: real self-modifying code, cause-24 ABORT, handler retry, M/S modes.
.NOTPARALLEL: fence
.PHONY: fence fence2 fence4 fence-error2 fence-error4 fence-s2 fence-s4
fence: retirement fence2 fence-error2 fence-s2 fence4 fence-error4 fence-s4 lint2 lint4 fence-evidence
fence2:
	$(PYTHON) ../fence_i_end_to_end/run.py --harts 2 --jobs 4
fence-error2:
	$(PYTHON) ../fence_i_end_to_end/run.py --harts 2 --error 1 --run-only
fence-s2:
	$(PYTHON) ../fence_i_end_to_end/run.py --harts 2 --supervisor --run-only
	$(PYTHON) ../fence_i_end_to_end/run.py --harts 2 --supervisor --error 1 --run-only
fence4:
	$(PYTHON) ../fence_i_end_to_end/run.py --harts 4 --jobs 4
fence-error4:
	$(PYTHON) ../fence_i_end_to_end/run.py --harts 4 --error 1 --run-only
fence-s4:
	$(PYTHON) ../fence_i_end_to_end/run.py --harts 4 --supervisor --run-only
	$(PYTHON) ../fence_i_end_to_end/run.py --harts 4 --supervisor --error 1 --run-only

.PHONY: fence-evidence
fence-evidence:
	$(PYTHON) ../fence_i_end_to_end/collect_evidence.py

# No warning suppression: native FENCE.I model generation fails on any warning.
.NOTPARALLEL: fpu-warning-regression
.PHONY: fpu-warning-check fpu-warning-regression
fpu-warning-check:
	$(PYTHON) ../fpu_warning_fix/run.py
fpu-warning-regression: fpu-warning-check fence

# Private LOAD -> STORE -> CBO regression, including retained-M ABORT on memory error.
.PHONY: audit-e-to-m2 audit-e-to-m4
audit-e-to-m2:
	$(PYTHON) ../cluster_completeness_audit/run.py --harts 2 --jobs 4
audit-e-to-m4:
	$(PYTHON) ../cluster_completeness_audit/run.py --harts 4 --jobs 4

.PHONY: e-to-m-unit e-to-m-regression e-to-m-error2 e-to-m-error4
.NOTPARALLEL: e-to-m-regression
e-to-m-unit:
	$(PYTHON) ../e_to_m_fix/run.py --harts 4 --jobs 4
e-to-m-error2:
	$(PYTHON) ../cluster_completeness_audit/run.py --harts 2 --error 1 --run-only
e-to-m-error4:
	$(PYTHON) ../cluster_completeness_audit/run.py --harts 4 --error 1 --run-only
e-to-m-regression: e-to-m-unit audit-e-to-m2 e-to-m-error2 audit-e-to-m4 e-to-m-error4 all fence

# DEC-038/A-02: real cached atomics, precise access faults, and baseline regressions.
.PHONY: atomic-regression atomic2 atomic4 atomic-probe-owner cbo-load2 cbo-load4
.NOTPARALLEL: atomic-regression
atomic-regression: atomic-probe-owner atomic2 atomic4 success2 error2 cbo-load2 success4 error4 cbo-load4 fence2 fence-error2 fence-s2 fence4 fence-error4 fence-s4 lint2 lint4 fence-evidence
atomic-probe-owner:
	$(PYTHON) ../atomic_end_to_end/run_probe_owner.py --harts 4 --jobs 2
atomic2:
	$(PYTHON) ../atomic_end_to_end/run.py --harts 2 --jobs 2
	$(PYTHON) ../atomic_end_to_end/run.py --harts 2 --case lrsc_contention --run-only
	$(PYTHON) ../atomic_end_to_end/run.py --harts 2 --case amo_fault --run-only
	$(PYTHON) ../atomic_end_to_end/run.py --harts 2 --case lr_fault --run-only
	$(PYTHON) ../atomic_end_to_end/run.py --harts 2 --case owner_fault --run-only
atomic4:
	$(PYTHON) ../atomic_end_to_end/run.py --harts 4 --jobs 2
	$(PYTHON) ../atomic_end_to_end/run.py --harts 4 --case lrsc_contention --run-only
	$(PYTHON) ../atomic_end_to_end/run.py --harts 4 --case amo_fault --run-only
	$(PYTHON) ../atomic_end_to_end/run.py --harts 4 --case lr_fault --run-only
	$(PYTHON) ../atomic_end_to_end/run.py --harts 4 --case owner_fault --run-only
cbo-load2: success2
	$(PYTHON) run.py --harts 2 --load-first --run-only
	$(PYTHON) run.py --harts 2 --load-first --error 1 --run-only
cbo-load4: success4
	$(PYTHON) run.py --harts 4 --load-first --run-only
	$(PYTHON) run.py --harts 4 --load-first --error 1 --run-only

.PHONY: atomic-bank-tag atomic-refill-error atomic-llc-pending atomic-llc-evict-ok atomic-llc-evict-error
atomic-bank-tag:
	$(PYTHON) ../atomic_end_to_end/run_bank_tag.py --harts 4 --jobs 2
atomic-refill-error:
	$(PYTHON) ../atomic_end_to_end/run_refill_error.py --harts 4 --jobs 2
atomic-llc-pending:
	$(PSRUN) -LlcPending
atomic-llc-evict-ok:
	$(PSRUN) -LlcTag -NormalEvict
atomic-llc-evict-error:
	$(PSRUN) -LlcTag -NormalEvict -WriteError
atomic-regression: atomic-bank-tag atomic-refill-error atomic-llc-pending atomic-llc-evict-ok atomic-llc-evict-error retirement

.PHONY: atomic-evidence
atomic-evidence:
	$(PYTHON) ../atomic_end_to_end/collect_evidence.py
atomic-regression: atomic-evidence

# A-03 / DEC-036: real ordinary L1 eviction error retention and full regression.
.PHONY: l1-eviction-regression l1-eviction2 l1-eviction4
.NOTPARALLEL: l1-eviction-regression
l1-eviction-regression: l1-eviction-pending l1-eviction2 l1-eviction4 fence-evidence l1-eviction-evidence
l1-eviction2:
	$(PYTHON) ../l1_eviction_end_to_end/run_regression.py --harts 2 --jobs 2
l1-eviction4:
	$(PYTHON) ../l1_eviction_end_to_end/run_regression.py --harts 4 --jobs 2

.PHONY: l1-eviction-evidence
l1-eviction-evidence:
	$(PYTHON) ../l1_eviction_end_to_end/collect_evidence.py

.PHONY: l1-eviction-pending
l1-eviction-pending:
	$(PSRUN) -LlcPending > ../../reports/l1_eviction_retention/llc_pending.log 2>&1

# A-04 / DEC-013: conservative-holder pruning and full CPU regression.
.PHONY: holder-regression holder-fabric holder-probe holder2 holder4 holder-evidence
.NOTPARALLEL: holder-regression
holder-regression: holder-fabric holder-probe holder2 holder4 fence-evidence holder-evidence
holder-fabric:
	$(PYTHON) ../directory_holder_end_to_end/run_fabric.py --harts 4 --jobs 4
holder-probe:
	$(PYTHON) ../directory_holder_end_to_end/run_probe.py --harts 4 --jobs 4
holder2:
	$(PYTHON) ../directory_holder_end_to_end/run_regression.py --harts 2 --jobs 4
holder4:
	$(PYTHON) ../directory_holder_end_to_end/run_regression.py --harts 4 --jobs 4
holder-evidence:
	$(PYTHON) ../directory_holder_end_to_end/collect_evidence.py
