# Holder lifecycle tests / Test vòng đời holder

## English

TEST-052 uses real CVA6 instructions through `m_vlsit_riscv_cluster_axi_top`, with 2 or 4 harts and a 4-KiB native LLC.

| Case | Independent stimulus and oracle |
|---|---|
| `dirty_eviction` | Hart 0 overwrites nine same-set lines with known values different from DRAM; peer loads must read those values after real dirty L1 replacement. |
| `clean_eviction` | Nine read-only lines force clean replacement; the ordinary dirty-eviction count must remain zero. |
| `amo_refill_error` | The first native X refill receives RRESP error after AMO permission; hart 0 traps cause 7 without retirement/GPR update, then peers read/upgrade X. |
| `lr_refill_error` | Same for LR, cause 5; a subsequent peer request reconciles the stale E/read holder. |

Every peer checks both 64-bit words of all nine lines and performs one AMOADD.D.aqrl on X. Old values must be unique and the final total is `256 + HARTS - 1`. Hart 0 waits for peer markers, rechecks all lines and executes CBO.CLEAN; the external memory model must contain that exact total. Active-hart count is a software configuration word initialized by the BFM, not a forced hardware signal.

The native probe/cache and CCU monitors require PREPARE-I, committed pruning and no false protocol/fault diagnostic. `COMMIT_I_responses` counts every successful I terminal response, including legitimate invalidation of a resident holder; it is not an absence-only count. The proof is PREPARE-I plus the tagged committed-mask assertion. Both commit ports are checked.

The LLC shim wraps the native production wrapper; it does not model a replacement cache. Only the external BFM's first X R burst is faulted in error cases; B responses are normal. No DUT/cache/retirement state is written by the bench. The native and external AXI assertion activation counts are printed, and any missing checkpoint fails. Each has 20 checks; stable stalled channel payloads also have SVA.

From the repository root:

```powershell
python verification/non_coherence_cluster/directory_holder_end_to_end/run.py --harts 2 --jobs 4
python verification/non_coherence_cluster/directory_holder_end_to_end/run.py --harts 2 --case clean_eviction --run-only
python verification/non_coherence_cluster/directory_holder_end_to_end/run.py --harts 2 --case amo_refill_error --run-only
python verification/non_coherence_cluster/directory_holder_end_to_end/run.py --harts 2 --case lr_refill_error --run-only
```

Repeat with 4 harts. `run_fabric.py --harts 4` models four cache ports without CPUs; `run_probe.py --harts 4` is a single-cache protocol unit. Both are supplementary to real CPU simulations. Complete replay: `make holder-regression` from `verification/non_coherence_cluster/cmo_end_to_end`. All tool commands and evidence steps are in that Makefile. Build before `--run-only`; the runner compares RTL/bench/program hashes and records the identity only after successful linking. [Results and limits](../../../reports/directory_holder_lifecycle/README.md).

## Tiếng Việt

Bốn ca kiểm tra eviction dirty/clean và refill AMO/LR lỗi từ CPU thật. Mọi peer đọc hai word của chín line, thực hiện AMO rồi hart 0 kiểm tra tổng và CBO.CLEAN tới DRAM. Check dữ liệu dựa vào chương trình/golden độc lập; không force cache hoặc retirement.

Monitor xác nhận PREPARE-I và holder mask được prune đúng theo tag. Bộ đếm COMMIT-I có cả invalidate line thật, không được hiểu là số cache vắng. Test quan sát cả hai commit port và yêu cầu đủ activation của 20 check AXI mỗi phía LLC. Unit fabric/probe không chứa CPU; được ghi riêng.

Dùng các lệnh trên hoặc Makefile duy nhất để chạy đầy đủ. Runner từ chối `--run-only` nếu hash RTL/testbench/program đổi. Chưa đo code coverage; xem báo cáo về phạm vi và các gap còn lại.
