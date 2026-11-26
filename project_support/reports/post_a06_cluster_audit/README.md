# Post-A-06 cluster audit / Kiểm tra cluster sau A-06

> **Documentation status / Trạng thái tài liệu:** This page records the named run or focused suite; earlier missing-core, timeout or unconnected-CMO statements are historical. Use the current HDS and dated audit for cluster status. / Trang này ghi lại lần chạy hoặc suite riêng; nhận định thiếu core, timeout hoặc CMO chưa nối của mốc cũ là lịch sử. Dùng HDS hiện tại và audit có ngày để xác định trạng thái cluster.

[Current cluster HDS / HDS cluster hiện tại](../../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Recorded audit / Báo cáo đã lưu](README.md) · [Tensor specification / Đặc tả tensor](../../../doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md)

2026-11-16. Scope / Phạm vi: production AXI profile, 2/4 harts, from `m_vlsit_riscv_cluster_axi_top`. No production RTL changed in this audit. / Không sửa RTL production trong lần kiểm tra này.

## Conclusion / Kết luận

**EN:** The AXI cluster's principal RTL blocks are present and connected. Fresh native TOP lint passes at both hart counts with zero errors and warnings. A-01 through A-06 have directed evidence; the latest source-consistent campaign contains 58 actual CPU cases. This is not a complete functional qualification of the cluster. PMU software operation, debug/interrupt integration, uncached atomic execution and several configurations remain unverified. A restrictive source notice in the actual TOP filelist must be resolved before release. No new functional failure was reproduced in this read-only audit.

**VI:** Các khối RTL chính của cluster AXI đã có và đã nối từ TOP. Lint mới chạy cho 2/4 hart đều không lỗi hoặc warning. A-01 đến A-06 đã có bằng chứng directed; bộ kiểm chứng mới nhất có 58 ca CPU thật và source khớp bản bàn giao. Tuy nhiên, chưa đủ để công nhận cluster hoàn chỉnh về chức năng. PMU qua phần mềm, debug/interrupt, uncached atomic và nhiều cấu hình chưa được kiểm chứng. Có thông báo hạn chế sử dụng source trong filelist TOP cần xử lý trước phát hành. Lần audit này chưa tái hiện lỗi chức năng mới.

## Evidence and method / Bằng chứng và cách kiểm tra

- Inspected production filelists recursively, including the nested HPDcache filelist, selected local source overrides, TOP ports/parameters and VLSIT integration paths. All **464 unique source files** exist. The earlier 419 count omitted nested-filelist contents; this corrects inventory scope without changing RTL or lint results. [Inventory and hashes](source_inventory.md), [machine-readable audit](../../../verification/non_coherence_cluster/reports/post_a06_cluster_audit/audit.json).
- Traced **34 VLSIT/CSR source boundaries** plus native CVA6/LLC/AXI boundaries. The source-reference graph is lexical, not a substitute for preprocessed elaboration; native lint establishes elaboration at the two checked defaults. Generate multiplicity is not inferred from the graph.
- Re-ran [2-hart TOP lint](../../../lint/non_coherence_cluster/full_integration/top_lint_2h_20261116_040822.log) and [4-hart TOP lint](../../../lint/non_coherence_cluster/full_integration/top_lint_4h_20261116_040822.log): native exit 0, errors 0, warnings 0, latch 0, multidriver 0. No RTL warning suppression was added. This uses the existing default diagnostic set, not every optional Verilator warning class.
- Rechecked A-06's source/verification hashes, 98 PASS evidence entries and 58 CPU cases. CPU simulations were **not rerun in this audit**; their existing native logs remain the behavioral evidence. [A-06 validation](../fault_record_a06/validation.md), [source identities and comment-only proof](../fault_record_a06/manual_review.md).
- Checked source-specific feature paths, parameter claims, idle testbench inputs and stale documentation. Historical leaf results are identified as such; source inclusion or compilation alone does not prove functional activation.

VI: Đã đọc filelist production và override, lần theo TOP/core/tile/CCU/LLC/control, đối chiếu hash và log cũ, rồi chạy lại lint TOP. Không gọi 419 file là 419 khối đã verify. Không chạy lại 58 ca CPU trong audit này; chỉ xác nhận source và bằng chứng đã lưu. Graph source không thay thế elaboration, assertion hoặc coverage. Chưa đo code coverage.

Replay audit / Chạy lại kiểm tra:

```sh
python scripts/run_cluster_top_lint.py --hart-count 2 --timeout 120
python scripts/run_cluster_top_lint.py --hart-count 4 --timeout 120
python verification/non_coherence_cluster/reports/fault_record_a06/check_deliverables.py
python scripts/audit_cluster_post_a06.py
```

Full behavioral replay remains `make fault-regression` in [the single Makefile](../../../verification/non_coherence_cluster/cmo_end_to_end/Makefile). / Chạy lại toàn regression chức năng bằng Makefile chung này.

## Hierarchy checked / Cấu trúc đã kiểm tra

```text
m_vlsit_riscv_cluster_axi_top
├── m_vlsit_riscv_cluster_core
│   ├── m_vlsit_riscv_cpu_tile_array
│   │   ├── active CPU tiles × PARA_CPU_NUM
│   │   │   ├── shared-table address classifiers
│   │   │   └── modified native CVA6
│   │   │       ├── commit/store/CMO completion and trap paths
│   │   │       ├── I-cache / fetch / MMU / FPU
│   │   │       └── HPDcache arrays, MESI, probe and writeback
│   │   └── m_vlsit_riscv_coh_tile_array
│   │       ├── tile adapters → line locks
│   │       └── CCU fabric → bank arbiter / directory / txn table / probe scheduler
│   ├── per-hart AXI route → memory mux / separate MMIO mux
│   ├── CMO arbiter → CMO controller ↔ CCU and LLC maintenance
│   ├── m_vlsit_axi_llc → modified native axi_llc_reg_wrap/top
│   ├── AXI4-Lite decode → generated CSR or AXI4-Lite-to-RegBus → LLC service
│   ├── PMU → event select / aggregate / counter / snapshot / IRQ
│   └── reset-only first-fatal record + sticky fault IRQ
└── AXI memory data-width adapter → external memory AXI4+ATOP
```

This is a functional grouping, not an instance-count-accurate diagram of native CPU internals. The shared directory is independent of LLC inclusivity. The quiet outputs in `gen_inactive_tile` represent unused hart slots in the two-hart configuration, not missing active CPU logic. External CMO is enabled by the production core. / Đây là nhóm chức năng; không phải sơ đồ đếm toàn bộ instance bên trong CPU. Các slot hart không dùng được tie-off có chủ ý; không phải thiếu RTL của hart đang hoạt động.

## Simulated versus lint-only / Đã mô phỏng và mới chỉ lint

| Block or feature / Khối hoặc chức năng | Implementation / RTL | Behavioral evidence / Bằng chứng mô phỏng | Remaining qualification / Còn thiếu |
|---|---|---|---|
| CVA6 core/tile/boot | Present and connected / Đã nối | Real boot, instructions, loads/stores, selected M/S traps in 2/4-hart CPU campaigns | Full ISA, privilege/delegation matrix, Sv39/PTW, OS boot / ISA, MMU và OS đầy đủ |
| HPDcache MESI, array arbitration, line locks, probes | Present / Đã có | Actual E→M, sharing/ownership, AMO/LR-SC, dirty owner, eviction/refill errors; focused probe/array units | Independent multi-hart memory scoreboard, all races and memory-ordering cases / Scoreboard chung và race đầy đủ |
| CCU directory, contexts, probe scheduler | Present / Đã có | Control units plus real shared-data/atomic/maintenance cases; A-05 full/wrap/victim escape at 2/8/16 contexts in units | Random context/tag/phase reorderings, contention/fairness and formal invariants; not global deadlock proof |
| Cached AMO/LR-SC | Present at L1 with CCU permission / Tại L1 có CCU bảo vệ | **10 CPU cases**: success, LR/SC contention, refill/dirty-owner errors across 2/4 harts | All encodings, widths/alignment, interrupts/reservations and broader progress / Toàn bộ encoding, reservation và tiến triển |
| CBO CLEAN/FLUSH/INVAL path | Present end-to-end / Đã nối đầu-cuối | **8 CPU cases** in latest baseline: ordinary and LOAD-first success/error at 2/4 harts | Treat this as tested maintenance paths, not proof every opcode × MESI × CBIE × privilege combination |
| FENCE.I | Present end-to-end / Đã nối đầu-cuối | **8 CPU cases**, M/S success/error/retry, cause 24 after ABORT, fetch invalidation and new-code execution | Shared/multi-line self-modifying code, virtual memory and concurrent maintenance |
| Ordinary L1 eviction/error | Present / Đã có | A-03 **6 CPU cases**, retained SRAM/tag/context, raw B failures, reset-only fault/recovery | Many outstanding faults, reset/transport races and random replacements |
| Conservative holder reconciliation | Present / Đã có | A-04 **8 CPU cases** plus units; absence proof, COMMIT pruning, ABORT preservation | Formal no-false-negative invariant; randomized refill/eviction/probe races |
| CCU victim escape | Present / Đã có | A-05 **8 CPU cases** plus context-capacity units and caught mutants | Full mixed-traffic progress with default 8 contexts; no-timeout ACK behavior remains intentional |
| LLC normal and per-line maintenance | Present / Đã có | Native maintenance/eviction units, real CBO/FENCE/atomic paths, A-06 native failed LLC B | Default **256-KiB** system stress, CSR BIST/whole flush, competing requests and all response reorderings |
| First-fatal record and fault IRQ | Present / Đã có | A-06 **10 CPU cases**: L1/LLC SLVERR/DECERR, CSR reads, RO/WSTRB/reserved accesses, reordered first hart, reset. Priority/high address/multiple also tested in units | Broader firmware/reset integration; record is diagnostic, not data recovery |
| AXI memory data-width adapter | Present / Đã có | Leaf tests **32/64/128/256**; real CPU campaigns use **64-bit** external memory | End-to-end TOP 32/128/256, packing/strobes, bursts, IDs/errors and atomic operands |
| PMA/address table → routing → MMIO | Present / Đã có | Classifier/routing leaf tests; cacheable traffic active in CPU campaigns | **TOP peripheral behavior is lint-only**: CPU-originated MMIO/normal-uncached, unmapped and boundary faults not functionally qualified |
| AXI4-Lite decode and generated CSR | Present / Đã có | A-06 drives external CSR transactions; three map/base units exercise all group targets | Do not call this entirely lint-only anymore. PMU operations and actual LLC service side effects still untested |
| AXI4-Lite → RegBus → LLC service | Present / Đã có | Structural lint; map units use synthetic endpoint cookies | **Native service behavior is lint-only**: BIST, whole-way flush, SPM rejection, status/error/readback under CPU traffic |
| PMU event→counter→snapshot→CSR/IRQ | Present / Đã có | CCU tap units only; PMU hierarchy elaborates | **Functional software path is lint-only**: event IDs/scopes, multiplicity, 32/64-bit wrap, atomic snapshot, W1C/IRQ and concurrent updates |
| External per-hart interrupts / debug | Boundary wired / Đã nối cổng | Retirement deferral unit and internal precise-trap CPU paths | **External service is lint-only**: halt/resume, debug ROM entry, IRQ delivery/delegation, WFI wakeup and interrupt during CMO |
| Uncached AXI4+ATOP execution | Transport present / Có đường truyền | Metadata/ID leaf checks; cached atomic CPU tests do not exercise this target | **Execution is not verified**: need real atomic-capable memory target and old-value/B/R/reservation oracle |
| FPU | Native block with local fixes / Đã có | Historical differential scalar and stall/flush comparisons; production lint clean | Independent IEEE-754/ISA reference and full CPU FP exceptions; legacy comparison can share algorithmic bugs |
| SRAM, reset, physical implementation | Behavioral SRAM/reset present / Có mô hình chức năng | Initial boot/reset and directed fatal-reset recovery | ASIC macro binding, in-flight reset contract, MBIST/DFT/ECC decisions, synthesis/STA/PPA |

Latest CPU total / Tổng số ca CPU: **10 + 8 + 8 + 6 + 10 + 8 + 8 = 58** (A-06, A-05, A-04, A-03, atomic, CBO, FENCE.I). These are scenarios, not coverage percentages. A-01 LOAD-first checks are already within the eight CBO cases; do not count them again. The 98 evidence entries also include model/identity/unit/lint checks, so they are not 98 CPU tests.

Evidence / Bằng chứng: [A-06](../fault_record_a06/README.md), [A-05](../ccu_victim_escape/README.md), [A-04](../directory_holder_lifecycle/README.md), [A-03](../l1_eviction_retention/README.md), [atomic](../atomic_coherence/README.md), [FENCE.I](../fence_i/README.md), [FPU](../fpu_warning_fix/README.md), [width adapter](../../verification/common/axi_dw_adapter/README.md), [CCU units](../../verification/common/coherence/README.md).

## Concrete open items / Các điểm còn thiếu cụ thể

### B-01 — Source-use provenance before release / Quyền sử dụng source trước phát hành

The production CVA6 filelist includes [vendored lzc.sv](../../../rtl/common/third_party/cva6/vendor/pulp-platform/common_cells/src/lzc.sv), whose header explicitly restricts reuse/redistribution without written permission. [Filelist entry](../../../rtl/common/filelists/cva6_flush_path/cva6_modified_cache.Flist) line 122. The earlier MMIO leaf source set excluded this file, but the complete TOP set still uses it. A repository-level license or the clean lint result does not resolve this file-specific notice. This audit reports the notice; it does not determine legal permission.

Required: establish applicable permission/provenance, or select a demonstrably licensed compatible implementation and verify every used width/mode and integration. Keep the original source pristine; document any replacement and all dependency licenses. Treat release/tapeout readiness as blocked until disposition is recorded. / Cần chứng minh quyền áp dụng hoặc thay bằng implementation tương thích có license rõ ràng, rồi kiểm tra đầy đủ. Chưa được kết luận quyền sử dụng chỉ từ license cấp repo; đây là điểm chặn xác nhận sẵn sàng phát hành/tapeout.

### B-02 — LLC geometry contract / Hợp đồng kích thước line LLC

The TOP advertises `PARA_LLC_BLOCK_NUM` as a configurable power of two, default 2. The CPU/CCU maintenance interface carries a fixed 52-bit line number with **four omitted address bits**, and the LLC reconstructs `{8'b0, maint_pa_line_i, 4'b0}`. Default 2 × 64-bit blocks = 16 bytes matches it. An arbitrary larger LLC line changes the physical maintenance granularity while the CCU still tracks 16-byte L1 lines. That configuration has neither an explicit multi-L1-line maintenance contract nor end-to-end evidence.

This is a configuration-contract risk, **not a reproduced failure of the default RTL**. Prefer initially qualifying capacity through ways × line count with `PARA_LLC_BLOCK_NUM=2`. Either explicitly restrict that parameter in the supported profile, or specify and prove larger-line interactions before advertising them. [TOP parameter](../../../rtl/non_coherence_cluster/m_vlsit_riscv_cluster_axi_top.sv), [maintenance address reconstruction](../../../rtl/common/modified/axi_llc/src/axi_llc_top.sv).

VI: Cấu hình mặc định line 16 byte khớp toàn đường. Không nên suy ra mọi giá trị parameter đều được hỗ trợ chỉ vì khai báo cho phép. Trước mắt giữ hai block/line, đổi dung lượng bằng way/line count; nếu cần line lớn phải định nghĩa tác động lên nhiều line L1 và verify riêng.

### B-03 — PMU/CSR/LLC service has RTL but lacks functional closure

No missing PMU instance was found. The missing deliverable is an independent active test and source/event oracle. In particular, [PMU IRQ](../../../rtl/common/vlsit/pmu/m_vlsit_pmu_irq.sv) reloads old causes OR new overflow; the generated CSR gives hardware update priority over W1C. Simultaneous clear/new overflow must be tested against the intended contract, including a clear for a different counter. [Snapshot](../../../rtl/common/vlsit/pmu/m_vlsit_pmu_snapshot.sv) must be checked via real software commands and stable low/high reads. LLC map-cookie tests do not execute native BIST or flush.

VI: Không thiếu instance PMU; thiếu kiểm chứng chức năng. Cần test event thật, scope, overflow đồng thời W1C, snapshot và dịch vụ BIST/flush thật của LLC. Chưa có ca tái hiện lỗi PMU trong audit này; các tình huống trên là test bắt buộc, không phải lỗi đã xác nhận.

### B-04 — System traffic and progress / Lưu lượng hệ thống và tiến triển

Missing: CPU MMIO/normal-uncached tests, functional uncached ATOP target, independent shared-memory/coherence scoreboard, concurrent cache/CBO/FENCE/atomic/CSR traffic, and bounded-response stress. Formal safety properties should cover unique writer, no false-negative holder, no loss of dirty data, tag association and terminal-phase release. Any liveness statement must assume downstream responses and ACKs eventually arrive; the approved no-timeout policy deliberately allows a missing ACK to hold a slot indefinitely.

VI: Chưa có scoreboard độc lập cho toàn coherence hoặc chứng minh tiến triển toàn cục. ACK/B bị mất có thể chờ vô hạn theo lựa chọn đã duyệt; không được gọi đó là deadlock đã sửa hoặc hứa progress vô điều kiện. Lỗi eviction thường còn có thể dừng controller cache đến reset, làm mất tiến triển workload phụ thuộc hart đó.

### B-05 — Documentation status is inconsistent / Trạng thái tài liệu chưa đồng nhất

Some historical spec checkpoints still say the core is undefined or per-line CMO absent; HDS DEP-019/023/025 still describe work now at least partly implemented. The LLC wrapper header says maintenance is not integrated despite its actual maintenance ports and native connections. These are stale descriptions, not proof of absent RTL. The previous completeness matrix also described external AXI4-Lite as idle; A-06 invalidates that blanket claim. This report supersedes those completeness statements. RTL headers were not edited in this audit.

VI: Cần đồng bộ bảng dependency và header cũ theo source/test hiện tại, giữ lịch sử dưới nhãn lịch sử. Không dùng đoạn README cũ để kết luận thiếu module, cũng không dùng lint để đóng phần verify chưa chạy.

## Recommended work order and exit criteria / Thứ tự đề xuất và điều kiện hoàn tất

| Order | Work / Công việc | Required exit / Điều kiện hoàn tất |
|---|---|---|
| 0 | Resolve B-01 source notice; freeze a supported parameter profile; reconcile B-02/B-05 | License disposition and source hashes recorded; no ambiguous supported line geometry; current spec/module/test matrix agreed / Chốt nguồn, cấu hình hỗ trợ và ma trận hiện trạng |
| 1 | **PMU + AXI4-Lite + native LLC service** at both hart counts | CSR program/select/count/snapshot/IRQ/W1C and native BIST/flush/readback pass under CPU traffic; protocol assertions actually activate; test simultaneous updates / Đóng đường điều khiển hiện còn chỉ lint |
| 2 | **CPU PMA/routing/MMIO/normal-uncached + ATOP** | Real RV64 programs prove correct target, data, ordering, errors and every supported atomic encoding; no unsupported ATOP silently accepted / Đóng đường truy cập peripheral và atomic ngoài |
| 3 | **External IRQ/debug/WFI and in-flight reset** | Per-hart delivery, halt/resume, privilege/delegation, CMO deferral and recovery tested with transactions outstanding; reset assumptions documented / Kiểm chứng quản lý hart và reset |
| 4 | **Random multi-hart coherence and progress** | Independent data scoreboard; contention/probe/eviction/CBO/FENCE/atomic mixes; tag reuse/full tables; safety assertions/formal; no unexplained hangs under bounded response assumptions / Kiểm chứng tương tác toàn cluster |
| 5 | **Qualify the supported configuration matrix** | TOP 2/4 harts × memory 32/64/128/256; focused context 2/8/16; PMU 1/16/32 × 32/64; native default 256-KiB LLC and selected legal geometries; functional evidence per advertised feature / Verify từng cấu hình được công bố |
| 6 | **ISA, MMU and software workloads; performance** | RISC-V ISA/privilege and Sv39/PTW/OS tests, memory-order litmus; measure cycles/instret/IPC and bandwidth with checked PMU; cache hit/miss/dirty/error worst cases / Đo đúng chức năng và hiệu năng |
| 7 | **ASIC implementation qualification** | Target SRAM/clock/reset/scan integration; synthesis, timing and area/power reports at chosen library/corner; CDC/RDC where applicable; DFT/physical signoff / Triển khai theo thư viện và ràng buộc SoC |

Start with order 0 and then order 1. PMU/CSR is a concrete gap on a required interface and will provide trustworthy observability for later performance work. Random coherence remains essential; passing peripheral control tests cannot replace it. Retain the single replay Makefile, native exit codes, saved testbench/program/oracle/logs, source hashes and activated protocol assertions. Decide any new coverage metric/target separately; no percentage can be inferred from the present 58 cases.

VI: Đề xuất xử lý nguồn/cấu hình trước, sau đó kiểm chứng PMU–CSR–dịch vụ LLC. Đây là khoảng trống rõ nhất trên cổng bắt buộc và là nền để đo hiệu năng. Sau đó đóng MMIO/ATOP, IRQ/debug/reset, coherence hỗn hợp, matrix và ISA/SoC. Lưu toàn bộ lệnh trong Makefile chung. Chưa có dữ liệu để tuyên bố tỷ lệ coverage hoặc IPC đạt mục tiêu.

## Deliberate exclusions / Phần loại trừ có chủ ý

External ACE/proxy remains deferred under AXI-first scope. The SoC supplies JTAG/DMI DM/DTM, interrupt controllers, memory/DRAM target and any ATOP service bridge. Runtime SPM, hot-add, power gating/retention/DVFS and guaranteed PPA targets are excluded in the present spec. Their absence is not an accidentally missing AXI-cluster module. Native WFI behavior still needs integration testing; no cluster-level low-power claim is made.

VI: ACE ngoài, DM/DTM/JTAG, interrupt controller, DRAM và bridge ATOP thuộc phạm vi hoãn hoặc SoC. SPM runtime, hot-add, power gating/retention/DVFS không thuộc v1. Phải phân biệt loại trừ có chủ ý với RTL thiếu và chức năng chưa verify.
