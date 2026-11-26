# RV32 testbench - fault qualification plan (rule R-096)

Each fault is applied with `+FAULT=<n>` through `tb/tb_faults.svh` (a `force` on one DUT signal after reset), on the
unchanged DUT build. The expected detecting check is recorded here **before** the negative run; the actual result is
added in `REPORT.md` after the run.

| Fault | Testcase | Forced signal | Plausible defect it models | Expected detecting check |
|---|---|---|---|---|
| 1 | TC-01 | tile 1 `w_core_hart_id = 0` | identity adapter takes the wrong bits | `CHECK h1 #1` (mhartid) fails; hart 1 then runs hart 0 code, count check fails |
| 2 | TC-10 | tile 0 `w_core_boot_addr = 0x8000_0004` | boot address adapter offset | `CHECK h0 #0` (boot.pc) fails |
| 3 | TC-05 | tile 1 `w_core_probe_req_nline` bit 0 inverted | line adapter corrupts entering line address | value check of hart 0 after a probe of hart 1, or watchdog |
| 4 | TC-04 | tile 0 `w_core_probe_req_nline` bit 0 inverted | same, on the writer side | hart 1 read checks or watchdog |
| 5 | TC-07 | tile 0 `o_cmo_req_pa_line` + 1 | line adapter output offset | `CHECK mem` of line A or B fails |
| BOOT_HI | TC-10 negative | `i_boot_addr[63:32] = 1` (`+BOOT_HI=1`, not a `+FAULT` number) | SoC drives a 64-bit boot address | SVA-102 assertion failure |
| 6 | TC-02 | `ex_stage_i.i_mult.result_o = 0` | multiplier result lost | `CHECK h0` of the first MUL fails |
| 7 | TC-03 | `fpu_status = 0` | FPU exception flags lost | every `*.flags` check that expects NX, DZ or NV fails (12 on 2 harts) |
| 8 | TC-06 | tile 1 `w_core_own_gnt_nline` bit 0 inverted | grant line adapter corrupt | `CHECK h1 #0` (amoswap old value) fails |
| 9 | TC-08 | `csr_regfile_i.satp_q = 0` | translation disabled | `CHECK h0 #0` (S-mode load through Sv32) fails |
| 10 | TC-09 | `o_axi_mmio_wstrb = 8'h0F` | MMIO write strobes in the wrong lane | assertion MMIO-15 fails |

Rows 6 to 10 were added to this file on 2026-11-26. Before their first runs their target testcase and modelled defect were recorded only in the comments of `tb/tb_faults.svh`; the expected detecting check of fault 7 was written here before its rerun on 2026-11-26 with the DEC-106 divider.
