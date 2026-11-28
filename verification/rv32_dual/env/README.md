# env/ - simulation environment of plan Sections 5.2/5.3 / Môi trường mô phỏng

AI-generated (Claude Opus 5.5, 2026-11-28) from the specification baseline only (REF-001 rev 0.39 Section 6.2 port table, RV32 HDS rev 0.4 Sections 6/8, question_log answers, CSR workbook). No RTL read. Candidate artifacts (R-117, R-231); **no simulation has been run** (free disk below the approved 2 GiB threshold) and tb_top binds the TOP region parameters of REF-001 rev 0.40 Section 14.4.20 (Q-G3-01 answered) through `tb/generated/region_params.svh`. Engineer review pending (R-284).
Sinh bởi AI chỉ từ đặc tả; chưa chạy mô phỏng (thiếu dung lượng ổ đĩa); bảng vùng địa chỉ đã gắn theo REF-001 rev 0.40 mục 14.4.20.

## Components / Thành phần (no-VIP contract, R-262)

| File | Plan 5.2 component | Role | Supported subset | Not supported (limitations) |
|---|---|---|---|---|
| `bfm/bfm_axi_sub.sv` (PFX=MEM) | bfm_axi_mem | AXI4 subordinate, 7-bit ID, 64-bit data | INCR/WRAP/FIXED (A3.4), per-ID order and optional cross-ID reorder (A6), exclusive monitor with EXOKAY (A7.2), AWATOP AtomicStore/Load/Swap/Compare little-endian (E1.1), READY probability, latency, HOLD and ERR rules, reset drop (DEC-041), final memory dump | QoS/region semantics ignored; one R burst at a time per pick; AWATOP big-endian bit ignored |
| `bfm/bfm_axi_sub.sv` (PFX=MMIO, CTRL=1) | bfm_axi_mmio | AXI4 subordinate, 6-bit ID + testbench control window + debug ROM (Q-G0-07) | as above without atomics | - |
| `bfm/bfm_axil_mgr.sv` | bfm_axil_mgr | AXI4-Lite manager (B1) | scripted W/R/WAIT/WAITCK, AW/W skew -3..+3, random B/R READY, script position kept across a coordinated reset | no outstanding pipelining (one operation at a time) |
| `bfm/drv_sideband.sv` | drv_sideband | reset, boot address, IRQ levels, debug requests | async reset assert, clocked release; second reset on a checkpoint | - |
| `monitors/mon_axi.sv` | mon_axi_mem / mon_axi_mmio | passive, NDJSON `axi` | every handshake | - |
| `monitors/mon_axil.sv` | mon_axil | passive, NDJSON `axil` + `axilch` | AW/W pairing in arrival order | - |
| `monitors/mon_sideband.sv` | mon_sideband | passive, NDJSON `pin` | every pin change | - |
| `assertions/sva_top_bind.sv` | sva_top_bind | 12 boundary checkers with fail/attempt/cover counters | plan 5.3 list | internal SVA-101/104/105 blocked (Q-G0-13) |
| `scoreboards/chk_stale_resp.sv` | chk_stale_resp | online REQ-RST-001 check | per-ID outstanding accounting across reset | - |
| `scoreboards/chk_watchdog.sv` | chk_watchdog | cycle budget, end on TOHOST | - | - |
| `scoreboards/axi_sb_core.py`, `chk_axi_mem_sb.py`, `chk_axi_mmio_sb.py` | chk_axi_mem_sb / chk_axi_mmio_sb | transaction rebuild + rule checks | rules: write_line, no_write, no_read, read_present, write_present, lock, atop, structural | windows defined by MMIO checkpoints only |
| `scoreboards/chk_axil_sb.py` | chk_axil_sb | AXI4-Lite response accounting | - | value checks delegated to models/chk_csr_model |
| `scoreboards/chk_sig.py` | chk_sig | signature/trap-record decoder | layout of scripts/generators/rv32d_lib.py | - |
| `coverage/cov_collect.py` | cov_collect | requirement-scenario bins of plan Section 8 | set union by (bin, configuration) | not microarchitectural event coverage |
| `assertions/fv_*_props.sv`, `fv_tops.sv` | formal harnesses | t_rv32d_fv_pmu / fv_axil / fv_addr_decode | immediate assertions + $past for open-source Yosys | fv_addr_decode assumes the decoder takes the 14.4.20 parameter names |
| `generated/debug_rom.S/.memh` | debug ROM (Q-G0-07) | park loop at 0x800, dret on RESUME | - | - |

## Testbench MMIO control window (region 1, testbench-defined) / Thanh ghi điều khiển của testbench

| Address | Access | Meaning |
|---|---|---|
| 0x10000000 + 8*h | W | TOHOST[h]: 1 = pass, other = fail code; ends the hart's test |
| 0x10000100 | W | IRQ_CTRL: [2:0] source (0 msip, 1 mtip, 2 meip, 3 ssip, 4 stip, 5 seip), [8] hart, [16] level |
| 0x10000104 | W | DBG_REQ: bit h = debug request level of hart h |
| 0x10000200 | W | CKPT: checkpoint value (windows for scoreboards, AXI4-Lite synchronisation, reset trigger) |
| 0x10000300 + 4*h | R/W | RESUME[h] (debug ROM consumes it) |
| 0x10000400 + 4*h | R/W | HALTED[h] (written by the debug ROM) |
| 0x10000500 + 4*h | R/W | DBG_EXC[h] (debug-mode exception flag) |
| 0x10000600 | R | number of AXI4-Lite script lines completed |
| other region-1/2 addresses | R/W | plain RAM; 0x800-0x8FF of region 2 holds the debug ROM image |

## Plusargs (written per test into tests/generated/<test>/plusargs.txt)

`+TEST +SEED +TIMEOUT_CYCLES +WAVE +WAVE_SCOPE +BOOT_ADDR +RST_CYCLES +RESET_AT_CKPT +RESET_HOLD`; per BFM `+MEM_/+MMIO_{IMAGE,ROM,ERR,DUMP,DUMP_OUT,RDY,LAT,REORDER,LOG,MON,STALE_LOG}`; `+AXIL_{SCRIPT,RDY,MON}`, `+PIN_MON`, `+SVA_LOG`, `+WD_LOG`. NDJSON schemas: models/README.md.

## Self-test plans (to run once disk allows) / Kế hoạch self-test (chạy khi đủ dung lượng)

Each self-test is a small top that instantiates only the component and a scripted counterpart; it records its own NDJSON log and is evaluated by the Python checkers. Pass criterion for every item: expected observation reached, no checker error, finite timeout.

| ID | Component | Scenario | Expected observation | Checker |
|---|---|---|---|---|
| ST-MEM-01 | bfm_axi_sub MEM | INCR 2-beat write then read back, READY 100 % and 30 % | data equal, B/R OKAY, ID echoed | chk_axi_mem_sb structural + data |
| ST-MEM-02 | bfm_axi_sub MEM | WRAP 4-beat read starting mid-burst | beat addresses wrap (A3.4) | waveform + log addresses |
| ST-MEM-03 | bfm_axi_sub MEM | exclusive pair with and without intervening write | EXOKAY then OKAY (A7.2), memory unchanged on failure | log + dump |
| ST-MEM-04 | bfm_axi_sub MEM | every AWATOP op (ADD/CLR/EOR/SET/SMAX/SMIN/UMAX/UMIN, swap, compare) on 4- and 8-byte operands | returned old value and memory = chk_mem_oracle.amo / E1.1 | dump vs model |
| ST-MEM-05 | bfm_axi_sub MEM | ERR rules nth/count, HOLD rule, REORDER=1 | error on the selected occurrence only; held R released after N cycles; cross-ID reorder, in-order per ID | BFM log + chk_axi_mem_sb |
| ST-MEM-06 | bfm_axi_sub MEM | reset with queued AW/AR/B/R | reset_drop record; no response after release; memory kept | chk_stale_resp + dump |
| ST-MMIO-01 | bfm_axi_sub MMIO | writes to TOHOST/IRQ/DBG/CKPT/RESUME, reads of HALTED/0x600, ROM fetch at 0x800 | control outputs follow; ROM words equal env/generated/debug_rom.memh | waveform + log |
| ST-AXIL-01 | bfm_axil_mgr | script with skew -3..+3, WAIT, WAITCK, random READY | one B per write, one R per read, ops_done counts lines | chk_axil_sb |
| ST-SB-01 | drv_sideband | reset length, second reset on a checkpoint, IRQ/debug pass-through | pin log matches script | mon_sideband log |
| ST-MON-01 | mon_axi / mon_axil / mon_sideband | replay of a scripted bus trace | one record per handshake/change; no driving (static review: no assignment to an input) | Python diff against the script |
| ST-SVA-01 | sva_top_bind | per assertion: legal trace (0 fails, covers > 0) and one mutant trace (payload change while stalled, address bit 34, WRAP len 5, AWATOP 0x3F, VALID in reset, boot hi, fault falling, output high after reset, debug mode without request, o_int_pmu high) | each mutant raises exactly its own assertion | sva.ndjson |
| ST-STALE-01 | chk_stale_resp | response delivered after reset to a pre-reset ID | violation counted | stale log |
| ST-WD-01 | chk_watchdog | budget expiry and TOHOST completion | expired / tohost records | watchdog log |

## Lint (no build output) / Kiểm tra lint

`bash scripts/lint_env.sh` - Verilator 5.053 `--lint-only -Wall` on tb_top + every SV component against lint-only stubs generated from the REF-001 port tables (`tb/generated/`), plus the formal harnesses. Last result: `docs/02_env/lint_env.log` (0 warnings, 0 errors; waivers documented in the sources and the script).
