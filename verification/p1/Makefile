PYTHON ?= python
HELPER := scripts/vlsit_sim_workspace.py
BASELINE ?= $(shell $(PYTHON) -c "import json; print(json.load(open('env/workspace_manifest.json'))['baseline_id'])")
RUN_ID ?= initial_001
REFERENCE ?= initial_001
COMPONENT_RUN_ID ?= component_qualification_001
CLUSTER_CMO_RUN_ID ?= timing_profile1_cbo_001
FENCEI_RUN_ID ?= timing_profile1_full_cpu_001

.PHONY: plan generate resolve seal seal-quick check execute replay coverage components component-case cluster-cbo fencei-profile1 profile1-qualification status

plan:
	$(PYTHON) scripts/vlsit_verify_plan.py check docs/00_plan/vplan.csv --spec-index docs/00_plan/requirements.txt --today 2026-11-16

generate:
	$(PYTHON) scripts/generators/generate_case_manifest.py --root .

resolve:
	$(PYTHON) scripts/generators/resolve_filelists.py --root .

seal:
	$(PYTHON) $(HELPER) seal --root .

seal-quick:
	$(PYTHON) $(HELPER) seal --root . --quick --force

check:
	$(PYTHON) $(HELPER) check --root . --baseline $(BASELINE)

execute:
	$(PYTHON) $(HELPER) execute --root . --baseline $(BASELINE) --run-id $(RUN_ID)

replay:
	$(PYTHON) $(HELPER) replay --root . --baseline $(BASELINE) --run-id replay_001 --reference-run $(REFERENCE)

coverage:
	$(PYTHON) scripts/coverage_source_summary.py --scope docs/00_plan/active_rtl_source_scope.json --merged runs/$(REFERENCE)/coverage/attempt_001/merged.dat --json runs/$(REFERENCE)/reports/coverage_source_union.json --markdown runs/$(REFERENCE)/reports/coverage_source_union.md

components:
	$(PYTHON) scripts/component_runner.py run . $(BASELINE) $(COMPONENT_RUN_ID)

component-case:
	$(PYTHON) scripts/component_runner.py run . $(BASELINE) $(COMPONENT_RUN_ID) $(CASE_IDS)

cluster-cbo:
	$(PYTHON) scripts/cluster_cmo_runner.py run . $(BASELINE) $(CLUSTER_CMO_RUN_ID)

fencei-profile1:
	$(PYTHON) $(HELPER) execute --root . --baseline $(BASELINE) --run-id $(FENCEI_RUN_ID)

profile1-qualification:
	$(PYTHON) $(HELPER) execute --root . --baseline $(BASELINE) --run-id $(FENCEI_RUN_ID)
	$(PYTHON) $(HELPER) seal --root . --force
	$(PYTHON) scripts/cluster_cmo_runner.py run . $(BASELINE) $(CLUSTER_CMO_RUN_ID)
	$(PYTHON) $(HELPER) seal --root . --force

status:
	$(PYTHON) $(HELPER) check --root .
