# A-06 fatal fault record / Bản ghi lỗi fatal

**Completed / Hoàn tất (2026-11-16):** 98 evidence entries PASS, including 58 real CPU cases and production TOP lint at 2/4 harts with zero errors and warnings. / 98 mục bằng chứng PASS, gồm 58 ca CPU thật và lint TOP 2/4 hart không lỗi hoặc warning. [Validation](validation.md), [results and source identities](../../../verification/non_coherence_cluster/reports/fault_record_a06/results.json), [13 changed/new production RTL files](changed_files.md), [manual rule review](manual_review.md), [measured waveform](waveform_compare.md).

## Behavior / Hành vi

DEC-039/040 retains the first fatal ordinary L1 or non-maintenance LLC writeback failure until cluster reset. Later independent fatal events set `multiple` without replacing the payload. Simultaneous events prefer the lowest active L1 hart, then LLC. Protocol/lock diagnostics keep their separate W1C status and do not populate this record. CBO/FENCE.I and precise atomic errors retain their existing trap contracts.

L1 records its exact hart. Shared LLC records use `hart_valid=0`; hart bits zero do **not** identify hart 0. Address and raw two-bit AXI B response remain valid. A native matching flush ACK proves which L1 transaction is reporting; the record captures the raw B code before the cache adapter compresses SLVERR/DECERR into a one-bit error. LLC metadata comes from its accepted failed B and retained victim descriptor: **victim tag + set index**, rather than the replacement/refill address.

VI: Giữ lỗi fatal đầu tiên đến reset. Lỗi sau chỉ đặt multiple; cùng chu kỳ ưu tiên L1 hart nhỏ nhất rồi LLC. L1 có hart chính xác; LLC dùng hart_valid=0, không được hiểu là hart 0. Ghi BRESP thực và địa chỉ victim đúng transaction. Diagnostic không fatal và lỗi precise AMO/CBO/FENCE.I giữ hợp đồng riêng.

## CSR and software / CSR và phần mềm

All addresses below are local offsets from `PARA_AXIL_BASE_ADDR`. The fault registers are read-only; software writes do not clear them.

| Offset | Register | Definition |
|---|---|---|
| `0x4000` | `cpucl_fault_sts` | bit 0 valid; 1 multiple; 2 addr_valid; 3 hart_valid; 4 resp_valid; upper bits zero |
| `0x4004` | `cpucl_fault_info` | bits 3:0 source (1 L1, 2 LLC); 5:4 raw BRESP; 9:8 hart only when hart_valid; other bits zero |
| `0x4008` | `cpucl_fault_lo` | Physical line address 31:0 |
| `0x400C` | `cpucl_fault_hi` | Physical line address 55:32 in bits 23:0; upper byte zero |

Read status and check valid, then assemble `address = (uint64_t(hi) << 32) | lo`. Payload stays stable until reset, so low/high reads need no snapshot command. `multiple` may rise later. W1C of legacy `cpucl_coh_fault` at `0x0010` cannot recover a fatal cache failure or clear this record. Read the record before requesting SoC/cluster reset.

The earlier approved **4-KiB group spacing is now implemented**: control/IRQ `0x0000`, PMU selectors `0x1000`, count low `0x2000`, count high `0x3000`, fault `0x4000`, LLC service `0x5000`. The total aperture is **24 KiB**, with a 4-KiB-aligned base no greater than `0xFFFFA000`. This replaces legacy selector/count offsets `0x0100/0200/0300` and LLC offset `0x1000`; firmware must use the new map. PMU **event IDs** are unchanged. Unassigned CSR words return zero/DECERR; RO writes follow the generator's ignored-write/OKAY policy.

VI: Đọc valid trước, sau đó ghép high/low thành địa chỉ 56 bit. Payload không đổi đến reset; multiple có thể tăng. Xóa status W1C cũ không giải phóng dirty data/context hoặc xóa record. Firmware phải cập nhật map: mỗi nhóm cách 4 KiB, fault tại 0x4000 và LLC tại 0x5000; mã event PMU không thay đổi.

## Verification and replay / Kiểm chứng và chạy lại

- Five native CPU scenarios per hart count: L1 SLVERR/DECERR, LLC SLVERR/DECERR, and L1 highest-hart-first response ordering. Both 2/4-hart production hierarchies run real RV64 loads/stores and native cache replacements. First-event address/hart/response is independently score-boarded from the fault-injection endpoint; SRAM/tag retention and reset recovery are checked. The L1 recovery program performs real CBO cleans so memory AW/W/B assertions activate after reset.
- Every primary CPU case requires **20 native AXI + 20 external memory AXI + 20 AXI4-Lite** assertions to activate and pass. Reset clears per-epoch transport counts, so pre-reset/cumulative counters retain the evidence. No inactive assertion is silently accepted.
- Record units test every active hart, both responses, high physical address bits, first-event hold, simultaneous priority, later-event multiple, inactive harts and reset. Decoder units check all six groups at a nonzero base, maximum legal base and invalid overflowing base; each requires 20 activated AXI4-Lite checks.
- A build-only overwrite-first-fault mutant must fail its independent oracle. Expected mutant failures are separated from production logs.
- Full baseline replay includes A-03 eviction retention, A-04 holder reconciliation, A-05 victim-context escape, AMO/LR-SC contention/faults, and CBO/FENCE.I M/S success/error, followed by production TOP lint at 2/4 harts. Atomic/CBO/FENCE.I benches also assert that their precise/nonfatal errors do not populate the fatal record.

From `verification/non_coherence_cluster/cmo_end_to_end`:

```sh
make fault-regression
```

The existing single [Makefile](../../../verification/non_coherence_cluster/cmo_end_to_end/Makefile) contains every replay command, including explicit `fault-csr-regenerate` and read-only `fault-csr-verify`. Generated RTL is never hand-edited. [Canonical workbook](../../specification/VLSIT_RISCV_CPU_Cluster_CSR.xlsx), [generation provenance](../../../verification/non_coherence_cluster/reports/fault_record_a06/csr_generation.json), [verification source](../../verification/non_coherence_cluster/fault_record_a06/README.md), [implementation plan](plan_v1.md).

VI: Test CPU dùng RTL thật, fault từ AXI, đọc CSR qua cổng AXI4-Lite ngoài; không force cache hoặc giả retirement. Unit kiểm tra priority/multiple/reset/địa chỉ cao, unit decoder kiểm tra biên map. Tất cả lệnh nằm trong Makefile chung. CSR sinh từ workbook chuẩn, có hash generator/output; không sửa tay RTL được sinh.

## Limits / Giới hạn

Directed checks only; no code coverage target or formal/global deadlock proof is claimed. The CPU tests use native 4-KiB LLC geometry to force replacements; production TOP lint uses the configured default hierarchy. Higher address bits are verified in the record unit, not a high-physical-address/Sv39 CPU campaign. External ACE, Linux/ISA/random coherence, broad CSR/PMU/debug traffic, uncached ATOP, width/configuration matrices, ASIC SRAMs, synthesis/STA/PPA/DFT remain broader qualification work. A record is diagnostic: it does not repair corrupted memory, roll back an externally visible write or make reset traffic-safe.

VI: Chưa đo code coverage hoặc signoff ASIC. Test directed không thay thế formal/random/OS/ISA, PPA/STA hay matrix cấu hình. Địa chỉ cao kiểm tra ở unit record. Record chỉ phục vụ chẩn đoán, không phục hồi dữ liệu hoặc đảm bảo hot-reset khi còn giao dịch ngoài.
