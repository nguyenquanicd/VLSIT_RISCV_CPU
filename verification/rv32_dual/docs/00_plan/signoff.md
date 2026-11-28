# Gate records / Hồ sơ gate (R-113, R-230)

Campaign: CFG-RV32-2 (32-bit cluster, two harts), block level, workspace `verification/rv32_dual/`.
An AI model never signs a gate; every record below is a decision stated by the human approver in this session.

| Gate | Date | Approver | Decision | Evidence | Conditions |
|---|---|---|---|---|---|
| G0 — plan approved | 2026-11-27 | Project owner (user of this session, VLSI Technology); name to be written here by the approver | **Approved** ("Duyệt G0") | `verification_plan.md`, `vplan.csv` (156 rows: 142 planned, 14 blocked), `requirements.txt` (70 IDs), `scope_record.md`, `spec_gaps.md` (Q-G0-01..16 answered), `question_log.md`; `vlsit_verify_plan.py check`: ROWS 156, ERRORS 0, FINDINGS 0, PASS (plan validation only) | 1. The 14 blocked rows stay blocked until their dependencies land or a waiver is approved: Q-G0-04 (LLC service register table in REF-001 Section 11), Q-G0-05 / DEP-DV-01 (CSR error-injection test hook, design change), Q-G0-13 (SVA observation-point table in the RV32 HDS). 2. Coverage, assertion, formal and mutation targets of plan Section 9 are approved as proposed. 3. No build or simulation starts while free disk is below the approved 2 GiB threshold (`env/resource_budget.json`). 4. RISK-04 (RISC-V assembler/toolchain) is decided at G1 |
| G1 — architecture | 2026-11-27 | Project owner (user of this session, VLSI Technology); name to be written here by the approver | **Approved** ("Duyệt G1") | `verification_plan.md` Section 5 (5.1 block diagram, 5.2 components, 5.3 always-on checkers, 5.4 clocks/resets/knobs incl. the five-region table, 5.5 tools and software flow, 5.6 oracle qualification plan); RISK-04 decided: project-local Python assembler qualified by encoding KAT | 1. `sva_internal_bind` (SVA-101/104/105) stays blocked until the observation-point table is in the RV32 HDS (Q-G0-13). 2. No build or simulation while free disk is below 2 GiB. 3. Environment code, models, assertions and testcases are authored in a specification-only context (R-103, R-232); RTL is used only in the later integration phase |
| G3 — block plan and model | — | — | Pending | Reference model and coverage model qualification | — |
| G5 — coverage closure | — | — | Pending | Closure report | — |
| G6 — sign-off | — | — | Pending | Verification report, clean regression, residual risk | — |
