# Authoring input record (R-103, R-232, R-233, R-234)

## 1. Statement

The verification plan, vplan, requirement inventory, scope record and specification-gap list in this folder were written in a clean, specification-only AI authoring context. **No RTL and no RTL-derived artifact was opened, searched, listed or summarised** for this work: nothing under `rtl/`, no `*.sv/*.v/*.svh/*.f/*.Flist`, no lint, synthesis, waveform or log file, no other folder under `verification/` (in particular not `verification/rv32_profile` or `verification/non_coherence_cluster`), no `project_support/`, not `doc/specification_32/RV32_RTL_CHANGE_PLAN.md`, not `doc/specification/HPDCACHE_ATOMIC_DEADLOCK_CHANGE_PLAN.md`, and no git history. RTL file names, port declarations and signal names that appear *inside* the two HDS documents (for example the component port tables of REF-001 Section 14.4, the WF-020 port names or `w_update_hs[bank]`) were used only as specification text; the named files were not opened.

Two specification statements are themselves derived from earlier RTL work (RV32 HDS 8.2/8.3 cite `build_config_pkg.sv` lines; REF-001 14.4 lists "exact source declarations"). They are part of the approved specification baseline (question log Q-02) and are used as such; this dependence is recorded as RISK-09 in the plan.

## 2. Files read

| # | File | Parts read | SHA-256 |
|---|---|---|---|
| 1 | `C:\Users\PC\.claude\skills\vlsit-verification-generator\rule.md` | whole file (rules R-100-R-286) | not recorded (skill file) |
| 2 | `...\reference\vlsit_verification_plan.md` | whole file | - |
| 3 | `...\reference\vlsit_test_design_guide.md` | whole file | - |
| 4 | `...\reference\vlsit_large_ip_verification.md` | whole file (processor profile) | - |
| 5 | `...\reference\vlsit_level_profiles.md` | section 3 (question format), section 4 (gates) | - |
| 6 | `...\reference\templates\vlsit_verification_plan.md.tpl`, `vlsit_vplan.csv.tpl`, `vlsit_requirements.txt.tpl`, `vlsit_scope_matrix.json.tpl`, `vlsit_testcase_header.md.tpl` | whole files | - |
| 7 | `...\scripts\vlsit_verify_plan.py` | `--help` of each action; header lines 1-80 and the message strings, to know the column vocabulary and check rules | - |
| 8 | `verification\rv32_dual\docs\00_plan\question_log.md` | whole file (Q-01 to Q-04) | - |
| 9 | `verification\rv32_dual\env\resource_budget.json` | whole file | - |
| 10 | `doc\specification_32\VLSIT_RISCV32_DUAL_QUAD_CPU_CLUSTER_HDS.md` rev 0.4 | whole file (673 lines) | `81923890dc7b70b415fbb8947e48c82e666860c2c5e23243fa2dbe72253a115c` |
| 11 | `doc\specification\VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md` rev 0.39 | lines 1-240 (front matter, Sections 1-4, requirement table 3.1); 775-1145 (5.3-5.4, 6.1-6.4, 7, 8.1-8.3, 9; long figure-JSON lines skipped); 1435-1800 (10.2-10.6, 11, 12; figure JSON skipped); 2292-2322 and 2444-2476 (14.4.8, 14.4.13 component contracts, as format examples); 9035-9172 (14.7, 15.1-15.5); 9380-9451 (20.1-20.7); heading outline (grep `^#`) | `12615b0bbcf64571b5e202876207eb89825cc5375c518d680528204f6565e1a9` |
| 11a | `doc\specification\VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md` rev 0.40 (2026-11-28) | only the Section 14.4.20 block "TOP address-region parameters." (lines 3204-3258) for Q-G3-01; `DRAFT_REGION_TABLE_PARAMETERS.md` not opened | `1a3cade56c5819a01743d86ddfd2d4c6d944f0817ec19a450eac986c732364bc` |
| 12 | `doc\specification\VLSIT_RISCV_CPU_Cluster_CSR.xlsx` | sheet list; AXIL_QUEUED rows 1-45 (register table); Address_Map; Event_Map ID/name/scope columns | `59872e8809ee51a0a380b4642ec94230ba6ed097c4a62d38f2366e01e60ccec1` |

REF-001 sections not read: 5.1-5.2 (block-diagram JSON), 10.1 FSM definitions, 13, 14.1-14.6 except the two contracts above, 16-19, 21-22. Requirements and tests of those sections were taken from Sections 3.1 and 15 only.

## 3. Protocol and ISA knowledge used (author's own knowledge, cited by clause)

AMBA AXI4 and AXI4-Lite (IHI 0022H Part A handshake/transaction structure/ID ordering/exclusive access, Part B AXI4-Lite), AMBA 5 atomic transactions (E1.1 as cited by REF-001 2.3), RISC-V Unprivileged ISA (RV32I/M/A/F/C, Zba/Zbb/Zbc/Zbs, Zcb, Zicond, Zkn, Zicbom per REF-001 REF-012, Zifencei 2.0 Section 4.1) and Privileged ISA (machine/supervisor CSRs, trap causes, Sv32, PMP). No licensed document was opened in this context; clause numbers must be confirmed against controlled copies before sign-off (plan RISK-08). The HDS itself flags the same need (REF-001 Section 2.2).

## 4. Requirement IDs and clauses grounding the artifacts (R-233)

All 70 IDs of `requirements.txt`; the 19 excluded REF-001 IDs are in `scope_record.md` Section 6.2.

## 5. AI provenance facts (R-234 inputs)

| Field | Value |
|---|---|
| Model | Claude Opus 5.5 (`claude-opus-5-5`), Anthropic, used through Claude Code |
| Date | 2026-11-27 |
| Role | Plan author (candidate artifacts, R-231); not a gate approver (R-230) |
| Prompt | Task brief from the coordinating agent restating the hard input boundary, campaign decisions Q-01 to Q-04 and the deliverable list |
| Generation method | Plan data held in one generator script in the session scratchpad (`gen_plan.py`, `gen_frag2.py`) that writes `vplan.csv`, `requirements.txt` and the Markdown tables pasted into `verification_plan.md`; the scripts read no DUT source |
| Tool runs | `vlsit_verify_plan.py check` and `matrix` (results in verification_plan.md Section 11) |
| Output hashes, prompt hash, context hashes | To be computed into `ai/provenance.json` of the first evidence bundle (template `vlsit_ai_provenance.json.tpl`); not produced at G0 |
| Human reviewer | pending (G0) |
| Data classification / external AI approval (R-119, R-239) | Not recorded in the campaign records read; the G0 approver must confirm |
