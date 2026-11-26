# RV32 profile - RTL change plan, version 1 / Kế hoạch sửa RTL bản RV32, phiên bản 1

Status: **approved 2026-11-25 with the recommended answers (Q1-Q5 = A); implemented; stopped at the lint stop condition of section 6.** See section 8.
Trạng thái: **đã duyệt, đã thực hiện, dừng ở điều kiện dừng lint (mục 6)**. Xem mục 8.

Source of the change: [VLSIT_RISCV32_DUAL_QUAD_CPU_CLUSTER_HDS.md](VLSIT_RISCV32_DUAL_QUAD_CPU_CLUSTER_HDS.md) rev 0.1 (REQ-XL-001 to REQ-XL-014, DEC-101 to DEC-105, SVA-101 to SVA-103).
Rules: vlsit-rtl-generator `rule.md` and `VLSIT_RTL_Design_Rule.md` v2.

## 1. Baseline (read only, before any edit)

| Check | Command | Result |
|---|---|---|
| Rule check of `rtl/common/vlsit/cpu` | `vlsit_rtl_check.py check rtl/common/vlsit/cpu` | **FAIL, pre-existing**: TYP-07 x5 in `m_vlsit_riscv_cpu_tile.sv` lines 46-62 (parameter arrays declared `[0:15]`), same in `m_vlsit_riscv_cpu_tile_array.sv`; WARN HIE-02, NAM-08 (`PARA_DIR_SYNC_READ`) |
| Lint of the 64-bit TOP | not rerun (the project lint script writes into `lint/`) | Last recorded runs clean: `lint/non_coherence_cluster/full_integration/hds035_top_2h.log`, `hds035_top_4h.log` (Verilator 5.053) |
| Lint tools | `vlsit_lint_rtl.py tools` | Verilator and slang available (`C:\Tools\oss-cad-suite`) |

The same `[0:15]` declarations exist in 7 files (tile, tile array, address decode, cluster core, AXI TOP, SoC wrapper, and the `build_config_with_addr_regions` function). They are not caused by this change; see question Q4.

## 2. Files

All changed and new files go to the output folder (rule R-009); the originals stay untouched and the 64-bit build keeps working. Proposed output folder: `rtl/rv32_profile/` (question Q1).

| ID | File (in the output folder) | Kind | Reason |
|---|---|---|---|
| F1 | `cva6/cv32a6_imafc_sv32_hpdcache_wb_config_pkg.sv` | NEW, copy of `rtl/common/modified/cva6/core/include/cv64a6_imafdc_sv39_hpdcache_wb_config_pkg.sv` | REQ-XL-001, DEC-101/102/103 |
| F2 | `cpu/m_vlsit_riscv_cpu_tile.sv` | MODIFIED copy of `rtl/common/vlsit/cpu/m_vlsit_riscv_cpu_tile.sv` | REQ-XL-006/007/008, DEC-104 |
| F3 | `filelists/cva6_rv32.Flist`, `filelists/filelist_vlsit_cluster_rv32.f`, `filelist_rv32.f` | NEW | REQ-XL-001: select F1 and F2 instead of the 64-bit package and tile |
| F4 | `../../verification/rv32_profile/sva/m_vlsit_riscv_cpu_tile_rv32_sva.sv` | NEW, verification only, bound to the tile | SVA-101 to SVA-103; rule R-010 keeps assertions out of design files |

No other file changes. Module and port names do not change.

## 3. Exact edits

### F1 - configuration package (3 lines + header)

```systemverilog
// before (64-bit)                         // after (RV32)
localparam CVA6ConfigXlen = 64;            localparam CVA6ConfigXlen = 32;
localparam CVA6ConfigRVD = 1;              localparam CVA6ConfigRVD = 0;
localparam CVA6ConfigDataUserWidth = CVA6ConfigXlen;
                                           localparam CVA6ConfigDataUserWidth = 64;  // DEC-103: keeps AXI records
```

The package keeps the name `cva6_config_pkg`, so only one of the two packages may be in a filelist. Header: new change-history entry citing DEC-101 to DEC-103.

### F2 - CPU tile: one configuration localparam and width adapters

Before (lines 377-398, shortened):

```systemverilog
cva6 #(
  .CVA6Cfg(build_config_pkg::build_config_with_addr_regions(
    cva6_config_pkg::cva6_cfg, PARA_ADDR_REGION_NUM, ... ))
) u_dont_touch_cva6 (
  .cmo_pa_line_o(o_cmo_req_pa_line),
  .boot_addr_i(i_boot_addr),
  ...
```

After:

```systemverilog
// DEC-104: core-side widths follow the selected CVA6 configuration.
localparam config_pkg::cva6_cfg_t LPARA_CVA6_CFG = build_config_pkg::build_config_with_addr_regions(
  cva6_config_pkg::cva6_cfg, PARA_ADDR_REGION_NUM, ... );
localparam logic [31:0] LPARA_CORE_NLINE_W = 32'(LPARA_CVA6_CFG.PLEN) - 32'd4;

logic [LPARA_CVA6_CFG.VLEN-1:0] w_core_boot_addr;
logic [LPARA_CORE_NLINE_W-1:0]  w_core_cmo_req_pa_line;
...
assign w_core_boot_addr  = i_boot_addr[LPARA_CVA6_CFG.VLEN-1:0];
assign o_cmo_req_pa_line = 52'(w_core_cmo_req_pa_line);     // zero-extend
...
cva6 #(.CVA6Cfg(LPARA_CVA6_CFG), ...) u_dont_touch_cva6 (
  .cmo_pa_line_o(w_core_cmo_req_pa_line),
  .boot_addr_i(w_core_boot_addr),
  ...
```

Connections adapted (16 groups, all from REF lines 376-460 of the original):

| Direction | Ports | Rule |
|---|---|---|
| Out, zero-extend to 52 bits | `cmo_pa_line_o`, `cmo_entry_pa_line_o`, `dcache_flush_ack_nline_o`, `dcache_access_nline_o`, `dcache_victim_nline_o`, `dcache_probe_rsp_nline_o`, `dcache_own_req_nline_o` | `o_x = 52'(w_core_x)` |
| Out, zero-extend to 64 bits | `cmo_vaddr_o`, `cmo_pc_o`, `cmo_entry_vaddr_o` | `o_x = 64'(w_core_x)` |
| In, keep low bits | `boot_addr_i`, `hart_id_i` | `w_core_x = i_x[VLEN-1:0]` / `[XLEN-1:0]` |
| In, keep low bits | `dcache_probe_query_nline_i`, `dcache_coh_lock_nline_i` (16 entries), `dcache_probe_req_nline_i`, `dcache_own_gnt_nline_i` | `w_core_x = i_x[LPARA_CORE_NLINE_W-1:0]` |

Unchanged: the AXI record packing and slicing (lines 209-320), region decode, interrupt mapping, every port of the tile. Header: change-history entry citing DEC-104. Estimated size: about 50 added lines, about 20 changed lines in a 460-line file.

### F3 - filelists

- `cva6_rv32.Flist`: copy of `rtl/common/filelists/cva6_flush_path/cva6_modified_cache.Flist` with line 89 (64-bit package) replaced by F1.
- `filelist_vlsit_cluster_rv32.f`: copy of `filelists/full_integration/filelist_vlsit_cluster.f` with line 23 (tile) replaced by F2.
- `filelist_rv32.f`: same three `-f` entries as `rtl/non_coherence_cluster/filelist.f`, pointing to the two new lists.

### F4 - assertions (bind file)

| ID | Property | Requirement |
|---|---|---|
| SVA-101 | When a probe-query, lock, probe-request or grant valid is high, bits 51:30 of its line address are 0 | REQ-XL-007 |
| SVA-102 | While reset is asserted, `i_boot_addr[63:32]` is 0 | REQ-XL-008 |
| SVA-103 | When `o_axi_awvalid` or `o_axi_arvalid` is high, address bits 63:34 are 0 | REQ-XL-006 |

The spec (section 14.3) currently says "immediate assertion in the tile". Rule R-010 requires assertions outside design RTL, so the spec text changes to "bind file" (question Q3).

## 4. Behavior

| Changes | Stays the same |
|---|---|
| RV32 build: core is RV32, line addresses carry zero bits 51:30, AXI addresses zero bits 63:34 | Every port, name, width and timing of the tile and cluster |
| | 64-bit build with F2: widths are equal, so every adapter is an identity connection (F2 can later replace the original tile for both profiles) |
| | CCU, directory, LLC, router, PMU, CSR: no file touched |

## 5. Checks after the edit

| Check | Configuration | Pass criterion |
|---|---|---|
| `vlsit_rtl_check.py check` on F1 and F2 | - | No new finding versus baseline (question Q4 decides TYP-07) |
| Verilator lint of the TOP with `filelist_rv32.f` | RV32, 2 and 4 harts, timing profile 0/1/2 | No error (TEST-101, TEST-114) |
| Verilator lint of the TOP with the 64-bit package and F2 | 64-bit, 2 and 4 harts | Same result as baseline (no regression) |
| Port list comparison script | RV32 TOP versus 64-bit TOP | Identical (TEST-110) |
| Lint of F4 bound to the tile | RV32 | No error |

Not in this plan: the simulation testbench of rule R-022 (at least ten integrated testcases). It needs RV32 test programs and toolchain; proposed as phase 2 (question Q5).

## 6. Risks and stop conditions

- If lint fails inside CVA6 or HPDcache with XLEN=32 (OPEN-X32-HPD, OPEN-X32-USER), I stop and report the failure with analysis; no file outside this plan is edited without a new plan version.
- `AxiUserWidth=64` with `XLEN=32` is used by no upstream package; lint is the first check of it.

## 7. Questions for the designer

**Q1. Output folder (rule R-009, R-018).**
- A (recommended): `rtl/rv32_profile/` with subfolders `cva6/`, `cpu/`, `filelists/`; example: F2 at `rtl/rv32_profile/cpu/m_vlsit_riscv_cpu_tile.sv`. Keeps the 64-bit build untouched.
- B: a folder outside the repository, for example `C:\HQuan\rv32_out`. Nothing in the repository changes, but the files are not versioned.
- C: your own choice.

**Q2. Header values (rule R-007).** Use the values of the existing headers: Project "VLSIT RISC-V CPU Cluster", Author "Quan Nguyen (user)"?
- A (recommended): yes, same as existing files.
- B: other values (please give them).

**Q3. Specification edits (rule R-061).** Section 14.3 and the DEC-101 to DEC-105 status must be updated after approval.
- A (recommended): edit `doc/specification_32/...HDS.md` in place after saving a copy of the original in the output folder.
- B: write the updated copy to the output folder only.
- C: other.

**Q4. Pre-existing TYP-07 errors (rule R-012: only passing files may be delivered).**
- A (recommended): keep `[0:15]` as it is and record a designer waiver for this pre-existing finding. Reversing the dimension safely needs the same change in 7 files, including the TOP parameter interface; it is a separate change for both profiles. Example: F2 delivered with the 5 TYP-07 lines listed as "pre-existing, waived".
- B: fix TYP-07 now in all 7 files (`[15:0]`, keeping element index meaning). Larger change, touches the TOP interface used by the SoC.
- C: other.

**Q5. Testbench (rule R-022).**
- A (recommended): phase 2, after the RTL lints; needs an RV32 toolchain and the RV32 test programs of section 15.2.
- B: in the same delivery as the RTL.
- C: other.

Reply **APPROVE plan version 1** with your answers to Q1-Q5, **REVISE** with the changes, or **STOP**.

## 8. Implementation results (2026-11-25)

Answers used: Q1 output folder `rtl/rv32_profile/`; Q2 header "VLSIT RISC-V CPU Cluster" / "Quan Nguyen (user)"; Q3 spec edited in place, original saved as `rtl/rv32_profile/spec_backup/VLSIT_RISCV32_DUAL_QUAD_CPU_CLUSTER_HDS_rev0.1_original.md`; Q4 TYP-07 waived (recorded in the tile header); Q5 testbench in phase 2.

**Deviation from the plan text (one line).** F1 also changes the `VLEN: unsigned'(64)` field to 32. The plan listed three localparams only, but the approved spec (section 8.2) requires VLEN=32 and the first lint showed the core ports still 64 bits wide. No other unplanned edit.

| Check | Result | Log |
|---|---|---|
| Originals unchanged | SHA-256 match for the 64-bit tile and package | `rtl/rv32_profile/spec_backup/original_sha256.txt` |
| Tile port list | 115 ports, identical to the original | script comparison |
| Rule check, tile | Only the 5 waived TYP-07 (pre-existing) and WARN HIE-02 (pre-existing) | `vlsit_rtl_check.py check rtl/rv32_profile/cpu` |
| Rule check, package | Same 7 findings as the original third-party package (license header, no module, no timescale); no new finding | `vlsit_rtl_check.py check rtl/rv32_profile/cva6` |
| Lint, 64-bit TOP, original filelist (baseline) | 0 errors, 0 warnings | `lint/base64_2h.log` |
| Lint, 64-bit TOP with the new tile, 2 and 4 harts | 0 errors, 0 warnings (no regression) | `lint/rv64_newtile_2h.log`, `rv64_newtile_4h.log` |
| Lint, RV32 TOP, 2 harts profile 0/1/2, 4 harts profile 0, with SVA bind | No real error; Verilator stops on 79 width warnings, identical in every run; none in the new tile | `lint/rv32_*.log` |

**Stop condition reached.** All 79 warnings are in CVA6 and HPDcache sources compiled at XLEN=32: aes.sv (16), fpu_wrap.sv (13), MMU/TLB/PTW Sv39 index paths (13), alu/mult (10), csr_regfile (3), HPDcache AMO path in `hpdcache_uncached.sv` and `cva6_hpdcache_if_adapter.sv` (5), the VLSIT probe engine ports in `hpdcache.sv` (7, fixed 52-bit `m_vlsit_riscv_hpd_probe_engine` ports on 30-bit signals), and 12 others. As planned, no file outside this plan was edited.

**Proposed plan version 2 (needs approval):** (a) classify each warning as upstream RV32 pattern (lint waiver file) or real width defect; (b) parameterize the line width of `m_vlsit_riscv_hpd_probe_engine` or document the zero-extension; (c) check the 64-bit AMO data truncation in the HPDcache AMO path with an RV32 AMO test; (d) then phase 2 testbench.

## 9. Plan version 2 results (2026-11-25)

Approved by the designer: "Duyệt plan v2".

**(a) Warning classification.** All 79 RV32 warnings were reviewed line by line (`rtl/rv32_profile/lint/rv32_upstream_waivers.md`, 68 entries). 72 are constant-selected arms of XLEN/RVD/Sv39 code (CVA6 aes, fpu_wrap, alu, mult, MMU/TLB/PTW, csr_regfile, frontend) or width mismatches whose value is exact (AMO path, miss handler, CMO cause compare). They are waived one rule, one file, one line each in `rtl/rv32_profile/lint/rv32_upstream_waivers.vlt`. Lint of the RV32 TOP (2 harts) with the waivers: only the 7 probe-engine warnings remain (`lint/rv32_2h_p0_waived.log`). Waivers apply to RV32 runs only; the 64-bit lint stays at 0 warnings without them.

**(c) AMO path, static check.** `prepare_amo_data_result` returns `{2{word}}` for a 32-bit AMO or SC result (`hpdcache_uncached.sv:189-202`), so keeping the low 32 bits (lines 631, 824) is exact. In `cva6_hpdcache_if_adapter.sv:257-265` the RV32 operand travels in a 64-bit field with a zero upper half; the low 32 bits and the 4-bit byte enable are the intended word. These lines are upstream CVA6 code that the cv32a65x configuration also uses. A simulation check is still needed (TEST-112, phase 2).

**(b) Probe engine, static check.** `m_vlsit_riscv_hpd_probe_engine` loads `reg_probe_nline` only from `i_probe_req_nline` (line 323) and drives all four line outputs from `reg_probe_nline` or `reg_rsp_nline` (lines 137-150, 359-379). With a 30-bit input zero-extended to 52 bits, bits 51:30 are always zero, so the output truncation and the compares (lines 210-401) are exact. Behavior is correct; the choice between parameterizing and waiving is question Q6.

**Q6. Probe-engine line width.**
- A (recommended): add `PARA_NLINE_W` (default 52) to `m_vlsit_riscv_hpd_probe_engine` (9 width declarations) and pass `HPDcacheCfg.nlineWidth` from its instance in `hpdcache.sv` (1 line). Both files are copied to `rtl/rv32_profile/`; the 64-bit build is identical (default 52). Removes the last 7 warnings and 44 flops per hart in RV32 (2 x 22 bits).
- B: keep the RTL and add the 7 lines to the waiver file with the proof above. No RTL change, 22 unused constant-zero bits per register remain.
- C: your own choice.

**Q6 answer: A (parameterize), implemented 2026-11-25.**

| File (output folder) | Change |
|---|---|
| `rtl/rv32_profile/coherence/m_vlsit_riscv_hpd_probe_engine.sv` | New parameter `PARA_NLINE_W` (default 52); 9 `[51:0]` declarations become `[PARA_NLINE_W-1:0]`; port columns realigned (FIL-05) |
| `rtl/rv32_profile/hpdcache/hpdcache.sv` | Instance passes `.PARA_NLINE_W(32'(HPDcacheCfg.nlineWidth))` (1 line) |
| `rtl/rv32_profile/filelists/hpdcache_rv32.Flist` | Copy of `hpdcache_modified.Flist` with the two files above |
| `rtl/rv32_profile/filelists/cva6_rv32.Flist` | Line 201 points to `hpdcache_rv32.Flist` |

| Check | Result | Log (`rtl/rv32_profile/lint/`) |
|---|---|---|
| Originals unchanged | SHA-256 match for all four original files | `spec_backup/original_sha256.txt` |
| Rule check, probe engine | Only COM-11 at the existing nested FSM branch, also present in the original (pre-existing, not in this change) | - |
| Lint 64-bit TOP with all new files, 2 and 4 harts | 0 errors, 0 warnings | `v2_rv64_2h.log`, `v2_rv64_4h.log` |
| Lint RV32 TOP with waivers, 2 and 4 harts, timing profiles 0, 1, 2 | 0 errors, 0 warnings in all six runs | `v2_rv32_*h_p*.log` |
| Lint RV32 TOP with the SVA bind file | 0 errors, 0 warnings | `v2_rv32_2h_sva.log` |

Remaining: phase 2 testbench (rule R-022, at least ten integrated testcases, RV32 toolchain and programs), including TEST-112 for the AMO and probe paths.

## 10. Plan version 3 - FPU divider operand boxing (approved 2026-11-26)

Approved by the designer on 2026-11-26 ("Duyệt change plan"). Specification: DEC-106 and HDS Section 14.5.

| Item | Content |
|---|---|
| Trigger | TC-03 FAIL: FDIV.S/FSQRT.S return canonical NaN with FLEN=32 |
| Root cause | `fpnew_divsqrt_th_64_multi.sv` zero-extends FP32 operands to 64 bits; `ct_vfdsu_prepare.v:330-331, 370-377` treats a single operand whose bits 63:32 are not all ones as canonical NaN |
| File | NEW copy `rtl/rv32_profile/cvfpu/fpnew_divsqrt_th_64_multi.sv` of `rtl/common/modified/cvfpu/src/fpnew_divsqrt_th_64_multi.sv` (original SHA-256 appended to `rtl/rv32_profile/spec_backup/original_sha256.txt`; original untouched) |
| Exact edit | Lines 360-361: `{{(64-WIDTH){1'b0}}, srcfX_q}` to `{{(64-WIDTH){1'b1}}, srcfX_q}`; 3 header comment lines (date, author, reason) |
| Filelist | `rtl/rv32_profile/filelists/cva6_rv32.Flist` line 70 points to the copy |
| 64-bit impact | None: 64-bit filelist unchanged; with WIDTH=64 the extension is empty |
| Lint | Verilator 5.053, `--lint-only --timing --timescale 1ns/1ps`, TOP `m_vlsit_riscv_cluster_axi_top`, 2 harts profiles 0/1/2 and 4 harts profile 0: 0 errors, 0 warnings (`rtl/rv32_profile/lint/v3_rv32_*.log`) |
| Simulation | 2 harts: TC-01 to TC-10 PASS (TC-03 76/0); 4 harts: TC-01, 02, 03 PASS (TC-03 152/0); fault 7 detected; unchanged testcases give bit-identical waveforms |
| Test changes | TC-03: 13 divide/square-root cases with per-case fflags; FCVT.W.S NX ordering defect fixed |
| Not done | TC-07 4-hart hang (OPEN-X32-CBO4), unrelated to this change |

