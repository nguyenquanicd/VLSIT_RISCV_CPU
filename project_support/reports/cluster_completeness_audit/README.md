# Cluster RTL completeness audit / Kiểm tra độ hoàn thiện RTL cluster

> **Documentation status / Trạng thái tài liệu:** This page records the named run or focused suite; earlier missing-core, timeout or unconnected-CMO statements are historical. Use the current HDS and dated audit for cluster status. / Trang này ghi lại lần chạy hoặc suite riêng; nhận định thiếu core, timeout hoặc CMO chưa nối của mốc cũ là lịch sử. Dùng HDS hiện tại và audit có ngày để xác định trạng thái cluster.

[Current cluster HDS / HDS cluster hiện tại](../../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Recorded audit / Báo cáo đã lưu](../post_a06_cluster_audit/README.md) · [Tensor specification / Đặc tả tensor](../../../doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md)

**Superseded status matrix / Bảng trạng thái cũ:** Use the [post-A-06 re-audit](../post_a06_cluster_audit/README.md) for current simulated/lint-only status and work order. The matrix and pre-fix findings below are historical; in particular, A-06 now actively exercises external CSR accesses. / Xem audit sau A-06 để biết trạng thái hiện tại; không dùng các nhận định cũ bên dưới để kết luận thiếu RTL hoặc chưa từng kích hoạt CSR.

**Latest / Mới nhất (2026-11-16):** A-06 completed; [98 evidence entries, 58 CPU cases and limits](../fault_record_a06/README.md). Older findings below are historical unless explicitly updated. / A-06 đã hoàn tất; các gap cũ bên dưới cần đọc theo mốc lịch sử.


**Follow-up / Cập nhật:** A-01 is fixed; A-02 now passes actual contended AMO/LR-SC and precise-error tests at 2/4 harts, with CBO/FENCE.I regression and strict TOP lint. [A-01 evidence](../e_to_m_fix/README.md), [A-02 evidence and limits](../atomic_coherence/README.md). A-03 dirty-data retention, reset-only IRQ and recovery now pass six real CPU cases; [A-03 evidence](../l1_eviction_retention/README.md). A-04 conservative-holder reconciliation now passes eight CPU cases; [A-04 evidence](../directory_holder_lifecycle/README.md). A-05 is now verified with [victim escape evidence](../ccu_victim_escape/README.md); detailed fault-record A-06 remains open. The source findings below are historical unless explicitly updated. / A-01 đã sửa; A-02 đã có test atomic CPU thật PASS; A-03 đã có sáu ca giữ dữ liệu/IRQ/reset PASS; A-04 đã có tám ca CPU đối chiếu holder PASS; A-05 đã kiểm chứng slot thoát; fault record chi tiết A-06 vẫn còn. Các nhận định source bên dưới là lịch sử trừ mục đã cập nhật.


2026-11-15. Scope: current AXI profile, `PARA_CPU_NUM=2/4`. This audit changes verification collateral only; no production RTL is modified. / Audit profile AXI hiện tại, chỉ thêm test và báo cáo; không sửa RTL production.

## Conclusion / Kết luận

**EN:** The AXI hierarchy resolves from `m_vlsit_riscv_cluster_axi_top` at both hart counts. This is structural completeness, not functional closure. The cluster is not ready to freeze as a complete coherent 2/4-hart implementation. The private-load/store/CBO corner originally failed and is now fixed as A-01; several other source-level coherence/error-path gaps remain unverified.

**VI:** Hierarchy AXI đã nối từ TOP và elaborate được ở 2/4 hart. Tuy nhiên chưa thể chốt RTL cluster coherent là hoàn chỉnh. Ca đọc line riêng rồi store và CBO từng FAIL; A-01 nay đã sửa và replay PASS. Một số khoảng trống coherence và xử lý lỗi khác được tìm thấy khi đọc source và còn cần test riêng.

## Hierarchy checked / Hierarchy đã kiểm tra

```text
m_vlsit_riscv_cluster_axi_top
  cluster_core
    cpu_tile_array
      cpu_tile x 2/4 -> licensed CVA6 -> HPDcache + probe engine
      coh_tile_array -> tile_coh_adapter/line locks x N
                     -> coh_fabric -> directory / transaction table / bank arbiter / probe scheduler
    per-tile address router -> memory mux -> native LLC -> memory AXI
                            -> MMIO mux -> peripheral AXI
    CMO arbiter + controller -> CCU + LLC per-line maintenance
    AXI4-Lite decoder -> generated CSR + PMU
                      -> AXI4-Lite/RegBus bridge -> LLC service
  AXI data-width adapter -> external memory interface
```

Unused hart slots are tied inactive intentionally; that is not a missing core. Debug requests connect directly to active CVA6 tiles; the standalone debug-router helper is not required in this hierarchy. / Slot hart không dùng được tie-off có chủ ý. Debug request nối trực tiếp vào tile CVA6; helper debug-router riêng không phải module còn thiếu.

Fresh TOP lint: [2 harts](../../../lint/non_coherence_cluster/full_integration/top_lint_2h_20261115_170822.log), [4 harts](../../../lint/non_coherence_cluster/full_integration/top_lint_4h_20261115_170822.log): 0 errors, 0 warnings. No undefined module, latch or multi-driver diagnostic. This does not test architectural behavior.

## Verification inventory / Phân loại bằng chứng

Existing PASS logs were inspected, not all historical tests rerun. All eight existing FENCE.I cases were replayed during this audit and still PASS. Latest FENCE/FPU source identity is recorded in their reports. / Đã đọc log PASS; không chạy lại mọi test lịch sử trong lần audit này.

| Block / function | RTL and connection | Evidence found | Remaining scope |
|---|---|---|---|
| CVA6/core/tile/boot | Present, active 2/4 harts | Real boot, fetch, load/store and maintenance programs | Full RV64 ISA, privilege transitions, exceptions, OS/Sv39 and shared-memory workloads |
| HPDcache MESI / arrays / probe | Present | Ownership-gated refill/Shared-store replay leaf test; probe-engine and tile unit tests; selected real maintenance paths | Private E→M case fixed; no complete cross-hart data/refill/eviction scoreboard |
| CCU/directory/transaction/probe scheduler | Present | Modeled MESI/ABORT/bank-progress tests; native CMO subset | Saturation, all tag/phase reorderings, directory replacement and genuine multi-hart sharing under load |
| CBO CLEAN/FLUSH/INVAL | Present end-to-end | Original 2/4-hart success and SLVERR→ABORT→cause-7 tests PASS | E-load/store corner now PASS; all MESI/hit/miss/CBIE combinations, owner-vs-DRAM faults and reset races |
| FENCE.I | Present end-to-end | Eight 2/4-hart M/S success/error/retry cases PASS; self-modifying code, cause 24, ABORT ordering and I-cache ACK | Private line per hart, bare S-mode, reduced LLC; multi-line, concurrent shared writes, Sv39/PTW and reset interruption |
| FPU | Present | Independent legacy comparison: 1,600 scalar transactions plus STALL/flush stress PASS | Independent IEEE-754 / full CPU FP ISA campaign |
| LLC per-line service / eviction | Present | Real maintenance subset; native tag/writeback error tests; pending-table full/wrap leaf tests | Default 256-KiB full-system stress, CSR-driven BIST/whole flush, concurrent CPU/DMA, system reset/error recovery |
| Memory AXI mux / width adapter | Present | Mux 2/4 leaf PASS; adapter 32/64/128/256 leaf PASS; TOP programs use 64-bit memory | TOP end-to-end 32/128/256, burst packing, ID reorder/backpressure, ATOP execution, all supported burst forms |
| PMA / routing / MMIO | Present | Address-classifier and classifier+router directed PASS | CPU-originated normal-uncached/MMIO, access faults, boundary bursts, external MMIO responses through full TOP |
| AXI4-Lite CSR / LLC service bridge | Present, connected | Full TOP lint; generated register RTL present | No dedicated active cluster AXI4-Lite integration simulation found: AW/W skew, WSTRB, reserved accesses, SPM block, BIST/flush/readback |
| PMU source→CSR/counter/snapshot/IRQ | Present, connected | Full TOP lint; CCU event-tap unit simulation | No PMU functional test found: source mapping, scope, multi-hart multiplicity, counter wrap, snapshot and IRQ/W1C from external AXI4-Lite |
| Debug / external IRQ / asynchronous fault CSR | Present boundary | TOP lint; retirement interrupt-deferral unit test; FENCE cause-24 does not enter debug | No external halt/resume, per-hart IRQ delivery or ordinary-eviction fault→CSR/read/clear/reset integration test found |
| Reset / SRAM / physical implementation | Behavioral/native RTL present | Initial reset and boot exercised | Reset with outstanding traffic, SRAM binding/MBIST/DFT/ECC choice, synthesis/STA/PPA and implementation signoff |

Important: a block instantiated in a TOP simulation is not functionally verified if its inputs stay idle. Both existing CPU benches drive external AXI4-Lite and debug requests inactive; the memory BFM rejects ATOP traffic. The maintenance tests use separate data lines per hart and a 4-KiB simulation LLC. The newer A-02 suite exercises shared data and dirty owners; neither suite proves the default 256-KiB LLC.

Lưu ý: module có mặt trong mô phỏng TOP chưa được coi là kiểm chứng chức năng nếu input vẫn idle. Test CPU hiện tại không kích hoạt AXI4-Lite/debug, memory BFM không thực thi ATOP. Test maintenance dùng data line riêng và LLC mô phỏng 4 KiB. A-02 bổ sung shared data/dirty owner giữa các hart; chưa chứng minh cấu hình LLC 256 KiB mặc định.

## RTL gaps and risks / Khoảng trống và rủi ro RTL

### A-01 — Private E→M state consistency: RESOLVED / Đã sửa

Test: initialize a private line to `49+hart_id`; execute `LD a3,0(a1); SD a3,0(a1); CBO.CLEAN` with no injected AXI error. The unchanged success oracle requires maintenance and retirement. The added load is the only instruction change relative to the original CBO success sequence. See [stimulus](../../../verification/non_coherence_cluster/cluster_completeness_audit/tb_cmo_end_to_end.sv) and logs below.

| New audit case | Expected | Observed | Evidence |
|---|---|---|---|
| 2 harts, no injected AXI error | CLEAN succeeds and retires | Before: FAIL at 5.395 us; now PASS, 726 test cycles | [log](../../../verification/non_coherence_cluster/reports/cluster_completeness_audit/simulation_2h_error0.log), [VCD](../../../verification/non_coherence_cluster/reports/cluster_completeness_audit/service_2h_error0.vcd) |
| 4 harts, no injected AXI error | CLEAN succeeds and retires | Before: FAIL at 5.415 us; now PASS, 948 test cycles | [log](../../../verification/non_coherence_cluster/reports/cluster_completeness_audit/simulation_4h_error0.log), [VCD](../../../verification/non_coherence_cluster/reports/cluster_completeness_audit/service_4h_error0.vcd) |

This corner intentionally stores the value just loaded; a legal store still makes the cache line dirty. It isolates state/protocol handling rather than testing changed-byte visibility. The root-cause explanation below is source analysis; the failure itself is reproduced on real CPU instructions at both hart counts.

Ca này store lại giá trị vừa load; store hợp lệ vẫn làm line dirty. Test tập trung vào state/protocol, không dùng để chứng minh visibility của byte đã đổi. FAIL đã tái hiện ở cả hai cấu hình; diễn giải nguyên nhân phía dưới dựa trên source.

**Pre-fix source analysis (superseded by the linked fix):** a private read can grant E; the local store marks the cache line dirty without a CCU ownership request. PREPARE then reports M while the CCU still checks its old directory state E with exact equality. ABORT also checks that old state. This exposes a mismatch in the stable-state contract and can produce an erroneous maintenance abort or stuck recovery. Fixing it requires handling legal silent E→M transitions and actual owner state/writeback tracking; simply disabling state validation is not a correction.

VI: Đọc line riêng có thể nhận E; store cục bộ làm line M nhưng CCU vẫn ghi E. PREPARE trả M trong khi CCU yêu cầu bằng E; ABORT cũng đối chiếu state cũ. Cần sửa hợp đồng state/owner/writeback cho E→M hợp lệ, không chỉ bỏ check state.

Source: [local store dirty update](../../../rtl/common/modified/hpdcache/rtl/src/hpdcache_ctrl_pe.sv), around lines 1190–1230; [strict PREPARE/ABORT state check](../../../rtl/common/vlsit/coherence/m_vlsit_riscv_coh_fabric.sv), line 507; owner-present classification around line 488.

### A-02 — Cacheable AMO/LR-SC: targeted fixes verified / Bản sửa đã kiểm chứng

DEC-038 selects cached execution in L1 with CCU permission, shared-read LR, exclusive-write SC/AMO and local reservation handling. Ten actual CPU atomic scenarios pass across 2/4 harts: arithmetic/serialization, contended LR/SC retry, LR/AMO refill faults and dirty-owner writeback-error ABORT. Native model generation and TOP lint have zero RTL warnings/errors. See [source changes and validation](../atomic_coherence/README.md). Uncached AXI4+ATOP execution, full ISA/OS and general forward-progress proofs remain outside these tests.

VI: Đã kiểm chứng bản sửa AMO/LR-SC cached theo lựa chọn A, gồm tranh chấp/retry và lỗi precise, bằng instruction CPU thật ở 2/4 hart. Chưa chứng minh uncached ATOP, ISA/OS đầy đủ hoặc tiến triển dưới mọi lưu lượng. Các mục A-03–A-06 vẫn cần sửa/test riêng.

### A-03 — Ordinary L1 dirty-eviction retention: verified / Đã kiểm chứng giữ dữ liệu

DEC-036 now gates actual MSHR allocation and directory replacement until ordinary writeback B succeeds. A matching error preserves the resident dirty victim and stage-2 context, drains transport/older refills, and holds fatal IRQ through W1C until reset. Six real CVA6 cases (OKAY/SLVERR/DECERR × 2/4 harts) compare actual SRAM/tag contents and reset recovery. [Changes, final regression and scope](../l1_eviction_retention/README.md).

The same workload exposed clean-miss overflow of the LLC pending ring; all misses now backpressure at capacity, with a focused clean/full/escape unit. This is distinct from the CCU A-05 issue. The implementation serializes an ordinary dirty replacement behind its B round trip, pausing that controller; it does not claim multiple ordinary evictions per hart. Detailed source/address CSR records remain A-06.

VI: Đã giữ dirty victim/context L1 đến B thành công; B lỗi báo IRQ chỉ xóa bằng reset, không tự retry hoặc giả completion. Sáu ca CPU thật kiểm tra SRAM/tag, lỗi và reset recovery. Bảng pending LLC cũng đã sửa guard clean/full; khác A-05. Fault record chi tiết vẫn thuộc A-06.

### A-04 — Conservative holder lifecycle: verified / Đã kiểm chứng đối chiếu holder

DEC-013 keeps a conservative directory: successful L1 replacement or failed post-grant refill can leave an extra holder bit. A matching error-free PREPARE-I now proves absence; the cache remains I at COMMIT without allocation, and the CCU publishes the pruned mask only after all terminal ACKs. Empty committed masks become I. ABORT preserves old conservative metadata. This is probe-time reconciliation, not an eager eviction notification.

Eight actual 2/4-hart CPU programs cover dirty/clean replacement and AMO/LR refill faults followed by peer reads/upgrades, exact AMO totals and CBO.CLEAN visibility to DRAM. Two focused protocol units cover mixed holders, empty-mask CMO and invalid terminal-state recovery. A-03/atomic/CBO/FENCE.I regression and strict TOP lint pass. [Source changes, logs, input hashes and limits](../directory_holder_lifecycle/README.md).

VI: Directory vẫn bảo thủ; bit dư được loại sau probe I hợp lệ và COMMIT, không tạo line cache giả. Tám ca CPU thật và hai unit đã kiểm chứng; regression và lint 2/4 hart pass. Không phải cơ chế thông báo eviction tức thời. A-05 đã kiểm chứng ở mục dưới; A-06 vẫn cần xử lý riêng.

### A-05 — Verified victim escape / Đã kiểm chứng slot thoát cho victim

[Full evidence, exact changes and replay](../ccu_victim_escape/README.md). CPU/CMO roots require two free entries so the last credit is reserved for non-recursive victim children. Child allocation, grant load and immediate release match the selected context tag. If another transaction locks the victim line, the parent cancels its uncommitted set reservation before lookup retry; it does not retain the set while waiting for that other context.

Focused tests pass at N=2/8/16, including physical full-table service, multiple pending parents, same-bank/set conflicts, victim PREPARE error/ABORT, tag reuse and exact request-ID/address checks. Eight new native CPU cases with two contexts pass at 2/4 harts, together with 40 baseline CPU cases and strict production TOP lint (0 errors, 0 warnings). Three mutated build-only copies are rejected. This closes the directed A-05 capacity/identity scenario; it is not a formal global deadlock proof. At default N=8, at most seven CPU/CMO roots may be admitted; a missing ACK still follows the approved wait-until-ACK/reset policy.

VI: Giữ một slot cho child victim; matching đúng parent/grant và hủy reservation trước khi chờ victim bị transaction khác khóa. Unit 2/8/16 context và tám ca CPU mới đều PASS; 40 ca regression và lint TOP 2/4 hart cũng PASS. Ba mutation bị phát hiện. Đã đóng phạm vi A-05 được kiểm thử, chưa phải formal proof mọi deadlock. Mặc định N=8 nhận tối đa bảy root; ACK mất vẫn chờ ACK/reset.

### A-06 — Fault record detail / Nội dung fault record

A-06 is implemented and verified: first fatal L1/LLC record is retained until reset; later faults set multiple. L1 identifies the exact hart; LLC uses hart_valid=0. 58 real CPU cases PASS, including ten A-06 scenarios and AMO/LR-SC/CBO/FENCE.I regression; production TOP lint at 2/4 harts has zero errors and warnings. Firmware must use the 4-KiB group map: fault 0x4000–0x400C, LLC 0x5000 (24-KiB aperture). Directed validation does not establish global coherence, OS or ASIC signoff.

A-06 đã triển khai và kiểm chứng: giữ record fatal L1/LLC đầu tiên đến reset; lỗi sau đặt multiple. L1 ghi đúng hart; LLC dùng hart_valid=0. 58 ca CPU thật PASS, gồm mười ca A-06 và regression AMO/LR-SC/CBO/FENCE.I; lint TOP 2/4 hart không lỗi hoặc warning. Firmware phải dùng map cách 4 KiB: fault 0x4000–0x400C, LLC 0x5000, aperture 24 KiB. Chưa phải signoff coherence toàn cục, OS hoặc ASIC.

[Evidence, register map and limits](../fault_record_a06/README.md).

## Remaining work order / Thứ tự hoàn thiện

1. A-01 is fixed with unit sharing/negative cases and real CPU load→store→CBO success/error at 2/4 harts. Continue broader shared-data and state coverage; see the fix report for the exact closed scope.
2. A-05 directed victim escape is verified; A-06 directed fault-record validation is complete; extend the verified A-04 lifecycle tests with randomized replacement/refill/probe races and formal no-false-negative invariants.
3. Extend the verified A-02 cached atomic tests to uncached ATOP targets, wider configuration/stall matrices and randomized shared-memory programs.
4. Exercise external AXI4-Lite→CSR/LLC/PMU and IRQ/debug paths with active traffic; extend beyond the A-06 RO/reserved/WSTRB/reset tests to broad BIST/flush/PMU/debug qualification.
5. Qualify the parameter matrix: 2/4 harts, 2/8/16 contexts, external 32/64/128/256 bits, PMU 1/16/32 counters × 32/64 bits and legal LLC geometry. A parameter declaration or leaf PASS does not qualify the whole cluster.
6. Run multi-hart shared-memory litmus/random coherence, Sv39/PTW, instruction/data ordering, concurrent CBO/FENCE/eviction, response reordering and reset recovery. Only then freeze RTL, bind ASIC SRAMs and perform synthesis/STA/PPA/DFT checks.

VI: Ưu tiên sửa state coherence và vòng đời eviction trước; sau đó atomic/progress, CSR/PMU/debug/IRQ, matrix cấu hình và verification toàn hệ thống. Thiếu PDK/SRAM/SDC/PVT là dependency tích hợp ASIC, không phải bằng chứng thuật toán RTL đã đúng.

External ACE/proxy is explicitly deferred by the approved AXI-first scope. JTAG/DMI Debug Module, interrupt controllers, DRAM target and a non-ATOP SoC atomic-service bridge are SoC responsibilities; do not count them as accidentally missing AXI-cluster modules. Runtime SPM is deliberately disabled.

ACE ngoài được hoãn có chủ ý; Debug Module/JTAG/DMI, interrupt controller, memory target và bridge atomic cho SoC không hỗ trợ ATOP nằm ngoài phạm vi cluster hiện tại. Không tính các khối đó là RTL bị bỏ sót.
