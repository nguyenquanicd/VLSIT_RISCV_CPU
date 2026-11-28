# models/ - Python oracles, checkers and assembler / Mô hình tham chiếu Python

AI-generated (Claude Opus 5.5, 2026-11-27) in a specification-only context (R-103, R-232). Candidate artifacts: machine-qualified by `scripts/run_model_qualification.py`, **not human-reviewed** (R-231, R-284).
Sinh bởi AI trong ngữ cảnh chỉ dùng đặc tả; đã chạy qualification tự động, **chưa có review của kỹ sư**.

| File | Plan 5.2 component | Inputs (specification) |
|---|---|---|
| `asm_rv32/asm_rv32.py` | asm_rv32 (RISK-04, decided at G1) | RISC-V ISA encoding tables |
| `asm_rv32/kat_encodings.json`, `kat_negative.json` | assembler known answers | ISA tables, cited per vector |
| `chk_fp_model.py` | chk_fp_model | IEEE 754, RISC-V F, RV32 HDS 14.5 |
| `chk_isa_kat.py` | chk_isa_kat | RISC-V B/Zicond/Zcb/scalar crypto, FIPS 197, FIPS 180-4 |
| `chk_trap_oracle.py` | chk_trap_oracle | Privileged ISA, REF-001 REQ-MEM-017/018, Q-G0-06/08 |
| `chk_mem_oracle.py` | chk_mem_oracle | ISA memory/AMO rules, REF-001 REQ-RST-001 |
| `chk_litmus_oracle.py` | chk_litmus_oracle | RVWMO chapter and litmus appendix |
| `chk_pmu_model.py` | chk_pmu_model | REF-001 REQ-PMU-002..008, workbook Event_Map |
| `chk_fault_oracle.py` | chk_fault_oracle | REF-001 REQ-ERR-003, DEC-039/040, workbook, Q-G0-12 |
| `chk_region_table.py`, `configs/region_table_campaign.json` | chk_region_table (Q-G0-09) | RV32 HDS REQ-XL-011, REF-001 REQ-IF-011, Q-G0-03 |
| `chk_csr_model.py` | chk_csr_model | workbook AXIL_QUEUED/Address_Map, REF-001 11.4 |
| `common/xlsx_min.py` | shared workbook reader (stdlib zipfile + xml) | - |
| `qual/qual_*.py` | qualification suites (plan 5.6) | - |

Not in this folder yet (later phases): BFMs, monitors, SVA, `chk_axi_mem_sb`, `chk_axi_mmio_sb`, `chk_axil_sb`, `chk_stale_resp`, `chk_watchdog`, `gen_prog`, coverage collector, `chk_port_audit`, `chk_cfg_audit`.

## NDJSON record schemas consumed by the oracles / Lược đồ bản ghi NDJSON

One JSON object per line, UTF-8. Integers may be JSON numbers or strings `"0x..."`. Every record carries `"type"`, and records written by a simulation run also carry `"run_id"`, `"test"` and `"cycle"` (cluster clock count from reset release). Monitors (R-124) only observe; they never compute expected values.

| type | Producer (planned) | Fields | Consumer |
|---|---|---|---|
| `fp` | program signature decoder | `op` (e.g. `"fdiv.s"`), `rm` (`rne/rtz/rdn/rup/rmm`, the effective mode), `a`, `b`, `c` (operand bits, absent if unused), `result` (bits), `fflags` (5 bits read after the op), `hart` | `chk_fp_model.check_record` |
| `isa` | program signature decoder | `op`, `rs1`, `rs2`, `imm` (shamt or `bs`), `rd`, `hart` | `chk_isa_kat.check_record` |
| `trap` | trap handler record in the signature area | `hart`, `level` (`M`/`S`), `mcause`, `mepc`, `mtval` (when `level`=M) or `scause`, `sepc`, `stval` (when S), `seq` (per-hart order) | `chk_trap_oracle.compare` |
| `memop` | test generator (expected side) | `op` (`store`/`amo`), `addr`, `size` (1/2/4), `data` or `rs2`, `amo_op`, `hart` | `chk_mem_oracle.Memory.apply` |
| `mem` | memory BFM final dump / signature lines | `addr`, `size` (4 or 8), `data` (little-endian value) | `chk_mem_oracle.compare_image` |
| `litmus` | litmus program signature | `pattern` (`MP`/`SB`/`LB`/`2+2W`), `fenced` (bool), `outcome` (`{"r0":..,"r1":..}` or `{"fx":..,"fy":..}`), `iteration` | `chk_litmus_oracle.check_record` |
| `pmu_cfg` | AXI4-Lite monitor (writes to `pmu_evt[k]`) | `k`, `word` (decoded by `decode_pmu_evt`) | `chk_pmu_model` |
| `pmu_evt` | test intent / program event log | `event_id`, `hart` (null for cluster scope 5), `count`, `cycle` | `chk_pmu_model.expected_counts` |
| `pmu_snap` | AXI4-Lite monitor | `k`, `lo`, `hi` (reads of `pmu_count_lo/hi[k]` after `snapshot_done`) | `chk_pmu_model.check_snapshot` |
| `axil` | AXI4-Lite monitor (one record per completed B or R) | `op` (`write`/`read`), `addr` (cluster-local offset), `wdata`, `wstrb`, `resp` (`OKAY`/`SLVERR`/`DECERR`), `rdata` | `chk_csr_model.check_log` |
| `fault_evt` | memory BFM error-injection log | `source` (`L1`/`LLC`), `hart` (L1 only), `bresp` (2/3), `pa` (victim byte address), `cycle` | `chk_fault_oracle.FaultRecord.events` |
| `pin` | sideband monitor | `name` (`o_int_fault`, `o_int_pmu`, `o_hart_debug_mode[n]`, ...), `value`, `cycle` | `chk_fault_oracle.check`, later SVA cross-checks |

## Commands / Lệnh

```sh
# from verification/rv32_dual
python models/asm_rv32/asm_rv32.py tests/<case>.S --base 0x80000000 -o build.memh --symbols build.sym
python models/chk_region_table.py models/configs/region_table_campaign.json      # exit 0 = accepted
python scripts/run_model_qualification.py --force                                 # all qualification suites
```
