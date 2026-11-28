"""
AI-GENERATED (Claude Opus 5.5, 2026-11-28) testcase source - candidate (R-117, R-231); engineer review pending (R-284).
Authored from the specification baseline only (RV32 HDS rev 0.4, REF-001 rev 0.39, CSR workbook, question_log answers); no RTL used (R-103, R-232).

| Field | Content |
|---|---|
| Test ID and title | t_rv32d_elab_port_audit - Static audit: elaborated TOP port list vs REF-001 Section 6 |
| Priority and rationale | high; outside the ten R-283 waveform tests; priority from plan 6.1 |
| Purpose | Static audit: elaborated TOP port list vs REF-001 Section 6.2 (111 ports, PARA_CPU_NUM-wide IRQ/debug vectors per Q-G0-14), no CVXIF ports, RV32 package fields vs RV32 HDS Section 8.2, negative elaboration, pre-build region-table check (Q-G0-09). |
| Requirements and features | REQ-IF-003, REQ-IF-006, REQ-SYS-001, REQ-SYS-004, REQ-XL-001, REQ-XL-010, REQ-XL-011; features: elab_config; functions: elab_config (single) |
| DUT configuration and preconditions | Static audit; inputs: elaborated TOP interface (execution phase, Verilator --xml-only of the RTL top), RV32 configuration package, REF-001 6.2 table (tb/generated/dut_ports.json), RV32 HDS 8.2 table, campaign region table. Plan configuration column: CFG-RV32-2-P0. Campaign region table bound through tb/generated/region_params.svh (REF-001 rev 0.40 14.4.20, Q-G3-01 answered) |
| Software flow | N/A (static audit, no software): 1 dump the elaborated TOP interface for PARA_CPU_NUM=2; 2 compare names/directions/widths with the 111-row REF-001 6.2 table; 3 check that no CVXIF port exists and that the memory port has AWATOP and no snoop channels; 4 elaborate PARA_CPU_NUM=3 and PARA_TIMING_PROFILE=3 and expect rejection; 5 compare RV32 package fields with RV32 HDS 8.2; 6 run chk_region_table on the campaign table and on a mutated table with base+size > 2^34 |
| Stimulus | Elaboration with legal and illegal TOP parameters; table comparison; region-table check script |
| Functional checkpoints and assertions | See the check table below (7 planned checks; R-286 requires >= 5). Every check runs through scripts/evaluate_run.py with the oracle/scoreboard named; deadline = test cycle budget unless stated; failure condition as listed |
| Expected outcome | Port list identical; vectors [1:0]; no CVXIF; illegal configurations rejected; package matches; campaign table accepted, mutated table rejected |
| Defect/fault targeted | Port list/width differs from REF-001 6.2, CVXIF port present, illegal configuration accepted, package field differs, region table above 2^34 accepted; failure modes FM-ELB-01, FM-ELB-02, FM-ELB-03, FM-ELB-04, FM-REG-03 |
| Checker/oracle | chk_cfg_audit, chk_port_audit, chk_region_table; qualification records under docs/01_qualification and docs/02_env |
| Reproducibility | SEED and every plusarg in tests/generated/t_rv32d_elab_port_audit/plusargs.txt (generated deterministically by scripts/generators/gen_prog.py); replay: build tb_top, run the simulator with +f-style plusargs from that file in a fresh runs/<run_id>/, then python scripts/evaluate_run.py runs/<run_id> |
| Waveform | N/A: outside the ten R-283 priority tests (plan 6.3); targeted capture only for diagnosis (R-278) |
| Evidence | Not run: no simulation in this phase (free disk below the approved 2 GiB threshold) |

Planned checks (from verification_plan.md Section 6.1, R-286):

| Check ID | Requirement / clause | Trigger | Expected observation | Checker / assertion | Deadline | Failure condition |
|---|---|---|---|---|---|---|
| CK-ELB-01 | REQ-XL-010 | TOP interface dump | names/directions/widths equal the 111-row table | chk_port_audit | build | difference |
| CK-ELB-02 | REQ-IF-006 | PARA_CPU_NUM=2 | IRQ/debug vectors [1:0]; AXI ID widths 6/7 | chk_port_audit | build | mismatch |
| CK-ELB-03 | REQ-SYS-004 | TOP interface | no CVXIF port | chk_port_audit | build | present |
| CK-ELB-04 | REQ-XL-001 | package audit (execution phase) | fields equal RV32 HDS 8.2 table | chk_cfg_audit | build | difference |
| CK-ELB-05 | REQ-SYS-001 | PARA_CPU_NUM=3, profile=3 | elaboration rejected | chk_port_audit | build | accepted |
| CK-ELB-06 | REQ-IF-003 | TOP interface | memory port has AWATOP and no snoop channels | chk_port_audit | build | mismatch |
| CK-ELB-07 | REQ-XL-011 | pre-build region-table check script | campaign table accepted; a mutated table with base+size > 2^34 rejected before build (Q-G0-09) | chk_region_table | build | mutated table accepted |
"""
TEST = 't_rv32d_elab_port_audit'
SEED = 1
KIND = 'static'
REQS = {
    'CK-ELB-01': 'REQ-XL-010',
    'CK-ELB-02': 'REQ-IF-006',
    'CK-ELB-03': 'REQ-SYS-004',
    'CK-ELB-04': 'REQ-XL-001',
    'CK-ELB-05': 'REQ-SYS-001',
    'CK-ELB-06': 'REQ-IF-003',
    'CK-ELB-07': 'REQ-XL-011',
}

STATIC = {
    "runner": "scripts/static/elab_port_audit.py",
    "needs": ["verilator --xml-only on the RTL top (execution phase, RTL read only by the tool)"],
    "checks": [
        ("CK-ELB-01", "port_table_equal", {"reference": "tb/generated/dut_ports.json"}),
        ("CK-ELB-02", "vector_widths", {"PARA_CPU_NUM": 2, "irq_debug_width": 2, "mem_id": 7, "mmio_id": 6}),
        ("CK-ELB-03", "no_port_matching", {"pattern": "cvxif"}),
        ("CK-ELB-04", "package_fields_equal", {"reference": "RV32 HDS rev 0.4 Section 8.2 table"}),
        ("CK-ELB-05", "elab_rejected", {"overrides": [{"PARA_CPU_NUM": 3}, {"PARA_TIMING_PROFILE": 3}]}),
        ("CK-ELB-06", "ports_present_absent", {"present": ["o_axi_mem_awatop"], "absent_prefix": ["i_ace_", "o_ace_", "i_axi_mem_ac", "o_axi_mem_cr"]}),
        ("CK-ELB-07", "region_table_script", {"campaign": "models/configs/region_table_campaign.json", "mutate": "entry 4 size + 16"}),
    ],
}
