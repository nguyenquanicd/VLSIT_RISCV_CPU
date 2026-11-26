# Cluster RTL completeness audit / Kiểm tra độ hoàn thiện RTL cluster

**Follow-up / Cập nhật:** A-01 is fixed; A-02 now passes actual contended AMO/LR-SC and precise-error tests at 2/4 harts, with CBO/FENCE.I regression and strict TOP lint. [A-01 evidence](../e_to_m_fix/README.md), [A-02 evidence and limits](../atomic_coherence/README.md). A-03 through A-06 remain open. The source findings below are historical unless explicitly updated. / A-01 đã sửa; A-02 đã có test atomic CPU thật PASS; A-03–A-06 vẫn còn. Các nhận định source bên dưới là lịch sử trừ mục đã cập nhật.


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

Fresh TOP lint: [2 harts](../full_integration/top_lint_2h_20261115_170822.log), [4 harts](../full_integration/top_lint_4h_20261115_170822.log): 0 errors, 0 warnings. No undefined module, latch or multi-driver diagnostic. This does not test architectural behavior.

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

Test: initialize a private line to `49+hart_id`; execute `LD a3,0(a1); SD a3,0(a1); CBO.CLEAN` with no injected AXI error. The unchanged success oracle requires maintenance and retirement. The added load is the only instruction change relative to the original CBO success sequence. See [stimulus](../../verification/cluster_completeness_audit/tb_cmo_end_to_end.sv) and logs below.

| New audit case | Expected | Observed | Evidence |
|---|---|---|---|
| 2 harts, no injected AXI error | CLEAN succeeds and retires | Before: FAIL at 5.395 us; now PASS, 726 test cycles | [log](simulation_2h_error0.log), [VCD](service_2h_error0.vcd) |
| 4 harts, no injected AXI error | CLEAN succeeds and retires | Before: FAIL at 5.415 us; now PASS, 948 test cycles | [log](simulation_4h_error0.log), [VCD](service_4h_error0.vcd) |

This corner intentionally stores the value just loaded; a legal store still makes the cache line dirty. It isolates state/protocol handling rather than testing changed-byte visibility. The root-cause explanation below is source analysis; the failure itself is reproduced on real CPU instructions at both hart counts.

Ca này store lại giá trị vừa load; store hợp lệ vẫn làm line dirty. Test tập trung vào state/protocol, không dùng để chứng minh visibility của byte đã đổi. FAIL đã tái hiện ở cả hai cấu hình; diễn giải nguyên nhân phía dưới dựa trên source.

**Pre-fix source analysis (superseded by the linked fix):** a private read can grant E; the local store marks the cache line dirty without a CCU ownership request. PREPARE then reports M while the CCU still checks its old directory state E with exact equality. ABORT also checks that old state. This exposes a mismatch in the stable-state contract and can produce an erroneous maintenance abort or stuck recovery. Fixing it requires handling legal silent E→M transitions and actual owner state/writeback tracking; simply disabling state validation is not a correction.

VI: Đọc line riêng có thể nhận E; store cục bộ làm line M nhưng CCU vẫn ghi E. PREPARE trả M trong khi CCU yêu cầu bằng E; ABORT cũng đối chiếu state cũ. Cần sửa hợp đồng state/owner/writeback cho E→M hợp lệ, không chỉ bỏ check state.

Source: [local store dirty update](../../modified/hpdcache/rtl/src/hpdcache_ctrl_pe.sv), around lines 1190–1230; [strict PREPARE/ABORT state check](../../vlsit/m_vlsit_riscv_coh_fabric.sv), line 507; owner-present classification around line 488.

### A-02 — Cacheable AMO/LR-SC: targeted fixes verified / Bản sửa đã kiểm chứng

DEC-038 selects cached execution in L1 with CCU permission, shared-read LR, exclusive-write SC/AMO and local reservation handling. Ten actual CPU atomic scenarios pass across 2/4 harts: arithmetic/serialization, contended LR/SC retry, LR/AMO refill faults and dirty-owner writeback-error ABORT. Native model generation and TOP lint have zero RTL warnings/errors. See [source changes and validation](../atomic_coherence/README.md). Uncached AXI4+ATOP execution, full ISA/OS and general forward-progress proofs remain outside these tests.

VI: Đã kiểm chứng bản sửa AMO/LR-SC cached theo lựa chọn A, gồm tranh chấp/retry và lỗi precise, bằng instruction CPU thật ở 2/4 hart. Chưa chứng minh uncached ATOP, ISA/OS đầy đủ hoặc tiến triển dưới mọi lưu lượng. Các mục A-03–A-06 vẫn cần sửa/test riêng.

### A-03 — Ordinary L1 dirty-eviction error retention / Giữ dữ liệu khi eviction L1 lỗi

**Source finding requiring a dedicated L1-eviction B-error test.** Normal flush completion reaches the controller without its error bit: `flush_ack & origin==00`. The flush engine frees transport entries on any matching B response, while the native miss path can mark a victim FETCHING/clean and proceed to replacement. The dedicated probe path preserves M through COMMIT/ABORT, but that does not establish REQ-ERR-003 retention for ordinary L1 eviction. LLC eviction error tests exercise a different level and cannot close this gap.

VI: Nhánh eviction L1 thông thường nhận ACK nhưng không nhận error bit để giữ victim/data/lock đến reset. Không được dùng kết quả probe/CMO hoặc LLC eviction để tuyên bố nhánh này đã hoàn tất. Cần hoàn thiện giữ dirty data và drain response theo DEC-036, rồi inject lỗi ngay trên B L1→LLC.

Source: [normal ACK connection](../../modified/hpdcache/rtl/src/hpdcache.sv), line 710; [flush ACK/free path](../../modified/hpdcache/rtl/src/hpdcache_flush.sv), lines 252 and 295; [victim/FETCHING path](../../modified/hpdcache/rtl/src/hpdcache_ctrl_pe.sv), around lines 870–890 and 1095–1110.

### A-04 — L1 eviction versus directory holders / Vòng đời holder sau eviction

**Static integration risk, not a reproduced result.** The tile ownership channel emits shared/exclusive miss requests; no explicit ordinary L1 eviction/drop notification was found. If the directory conservatively retains a holder after L1 replacement, the later probe can return I. Current PREPARE validation expects the old recorded state, and COMMIT-to-S/E on a missing line is rejected by the probe engine. Close either an explicit L1 eviction protocol or a formally consistent conservative-directory miss-response policy.

VI: Cần xử lý rõ trường hợp directory còn ghi holder nhưng L1 đã evict line. Hiện check state và probe COMMIT có thể từ chối response I hợp lệ. Phải có protocol thông báo eviction hoặc semantics directory bảo thủ được thiết kế/kiểm chứng đầy đủ.

Source: [ownership request encoding](../../modified/hpdcache/rtl/src/hpdcache_miss_handler.sv), line 362; [probe COMMIT branch](../../vlsit/m_vlsit_riscv_hpd_probe_engine.sv), around lines 233–244.

### A-05 — Full context table and victim child / Nguy cơ deadlock khi hết context

**Static progress risk, not a simulated deadlock claim.** Directory replacement leaves a parent in `EVICT_ALLOC` and allocates another transaction slot for victim work. The allocator accepts ordinary roots until all slots are occupied; internal priority does not reserve capacity. With two slots, two replacement parents can consume both slots and wait for children with no free entry. Add a capacity invariant, reserved escape resource or in-place victim processing; prove progress at 2/8/16 slots, including same-bank/set pressure.

VI: Khi mọi context bị parent giữ và mỗi parent còn cần child cho victim, ưu tiên internal request không tự tạo được slot trống. Cần cơ chế escape và test saturation; không nhầm test wraparound của bảng pending LLC với bảng transaction CCU.

Source: [request/child arbitration](../../vlsit/m_vlsit_riscv_coh_fabric.sv), around lines 333–405 and 866–878; [first-free allocator](../../vlsit/m_vlsit_riscv_coh_txn_table.sv), around lines 149 and 186–195.

### A-06 — Fault record detail / Nội dung fault record

The cluster combines several sources into one W1C `cpucl_coh_fault` bit. No fault line/hart/origin/AXI response metadata registers were found. REQ-ERR-003 asks for an associated CSR fault record, but the detailed field contract is not frozen in the current HDS. Specify the minimum record and update the workbook/generator/integration before claiming effective diagnosis or TEST-050 closure.

VI: Hiện chỉ có bit fault tổng hợp; chưa có record phân biệt địa chỉ, hart, nguồn và response lỗi. Cần chốt fields rồi sinh CSR, không hand-edit generated RTL. Đây vừa là gap đặc tả chi tiết vừa là phần diagnostic cần hoàn thiện.

Source: [combined fault and sticky IRQ](../../vlsit/m_vlsit_riscv_cluster_core.sv), lines 1002–1009; generated CSR offset `0x0010` contains the single fault bit.

## Remaining work order / Thứ tự hoàn thiện

1. A-01 is fixed with unit sharing/negative cases and real CPU load→store→CBO success/error at 2/4 harts. Continue broader shared-data and state coverage; see the fix report for the exact closed scope.
2. Complete ordinary L1 eviction lifecycle/error retention, directory-holder policy, and CCU full-table victim escape; reproduce and close A-03–05.
3. Extend the verified A-02 cached atomic tests to uncached ATOP targets, wider configuration/stall matrices and randomized shared-memory programs.
4. Exercise external AXI4-Lite→CSR/LLC/PMU and IRQ/debug paths with active traffic; finish diagnostic record A-06 and reserved/WSTRB/BIST/flush/reset tests.
5. Qualify the parameter matrix: 2/4 harts, 2/8/16 contexts, external 32/64/128/256 bits, PMU 1/16/32 counters × 32/64 bits and legal LLC geometry. A parameter declaration or leaf PASS does not qualify the whole cluster.
6. Run multi-hart shared-memory litmus/random coherence, Sv39/PTW, instruction/data ordering, concurrent CBO/FENCE/eviction, response reordering and reset recovery. Only then freeze RTL, bind ASIC SRAMs and perform synthesis/STA/PPA/DFT checks.

VI: Ưu tiên sửa state coherence và vòng đời eviction trước; sau đó atomic/progress, CSR/PMU/debug/IRQ, matrix cấu hình và verification toàn hệ thống. Thiếu PDK/SRAM/SDC/PVT là dependency tích hợp ASIC, không phải bằng chứng thuật toán RTL đã đúng.

External ACE/proxy is explicitly deferred by the approved AXI-first scope. JTAG/DMI Debug Module, interrupt controllers, DRAM target and a non-ATOP SoC atomic-service bridge are SoC responsibilities; do not count them as accidentally missing AXI-cluster modules. Runtime SPM is deliberately disabled.

ACE ngoài được hoãn có chủ ý; Debug Module/JTAG/DMI, interrupt controller, memory target và bridge atomic cho SoC không hỗ trợ ATOP nằm ngoài phạm vi cluster hiện tại. Không tính các khối đó là RTL bị bỏ sót.
