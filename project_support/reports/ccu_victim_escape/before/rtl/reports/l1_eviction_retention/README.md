# A-03: L1 dirty-eviction retention / Giữ dirty data khi eviction L1 lỗi

**A-04 follow-up / Cập nhật:** [Latest conservative-holder reconciliation and full regression](../directory_holder_lifecycle/README.md) pass at 2/4 harts. This report retains its earlier source-hash snapshot; replay logs may be newer. A-05/A-06 remain open. / A-04 đã kiểm chứng đối chiếu holder và regression 2/4 hart. Hash bên dưới giữ snapshot cũ, log có thể mới hơn; A-05/A-06 vẫn còn.

DEC-036 / REQ-ERR-003 / TEST-050. Production TOP: `m_vlsit_riscv_cluster_axi_top`, AXI profile, 2/4 harts.

## English

The native ordinary miss path previously changed the victim to clean/FETCHING and allocated its replacement before the writeback B result. Normal ACK also lost the error bit. The fix retains the original stage-2 context and resident dirty victim until B=OKAY. SLVERR/DECERR consumes the transport response, holds victim/context until reset, and reports an asynchronous fatal IRQ. No retry or precise exception at an already retired store is fabricated.

### Changed production sources

| File | Change |
|---|---|
| [hpdcache.sv](../../../../../../../verification/non_coherence_cluster/reports/ccu_victim_escape/before/rtl/modified/hpdcache/rtl/src/hpdcache.sv) | Forward ordinary writeback B error to the controller. |
| [hpdcache_ctrl.sv](../../../../../../../verification/non_coherence_cluster/reports/ccu_victim_escape/before/rtl/modified/hpdcache/rtl/src/hpdcache_ctrl.sv) | Send one writeback; retain stage-2 payload; gate actual MSHR VALID and CS plus directory mutation; match completion line; exclude victim/pending replacement from probes. |
| [hpdcache_ctrl_pe.sv](../../../../../../../verification/non_coherence_cluster/reports/ccu_victim_escape/before/rtl/modified/hpdcache/rtl/src/hpdcache_ctrl_pe.sv) | Pause new controller admission/replay during the wait/fatal hold; keep older refill arbitration enabled. |
| [axi_llc_tag_store.sv](../../../../../../../verification/non_coherence_cluster/reports/ccu_victim_escape/before/rtl/modified/axi_llc/src/hit_miss_detect/axi_llc_tag_store.sv) | Backpressure every miss when the pending allocation ring is full; clean misses also reserve entries. |
| [cluster_core.sv](../../../../../../../verification/non_coherence_cluster/reports/ccu_victim_escape/before/rtl/vlsit/m_vlsit_riscv_cluster_core.sv) | Reset-only ordinary-eviction fatal source keeps IRQ and diagnostic hardware-set active through software W1C. |

The miss handler allocates from VALID independently of SRAM CS. Gating only CS was insufficient; the directed test caught concurrent MSHR ACK/allocation and the actual VALID is now gated too. [Diagnostic](../../../../../../../verification/non_coherence_cluster/reports/ccu_victim_escape/before/rtl/reports/l1_eviction_retention/diagnostics/before_allocation_gate.log). The native assertion remains enabled. A 4-hart read-only diagnostic dump is retained in `diagnostics/state_4h.log`; its temporary executable intentionally stopped with exit 3 and is not a PASS test. A separate initial fixture race changed READY at the sampling edge; the BFM now changes backpressure at the falling edge and retains the AXI stability assertions. Both retirement ports are checked.

The 4-hart conflict workload also exposed LLC pending-ring overwrite: the existing full-table check gated only dirty-victim misses although every miss reserved a slot. The fix gates all misses at full capacity. The focused unit fills the ring with four clean misses, holds a fifth request, completes the oldest refill and checks every resulting tag. This does not resolve A-05, which is the separate CCU context/victim-child allocation issue.

### Verification and replay

**Completed:** 32 real-CPU cases (6 eviction, 10 atomic, 8 CBO, 8 FENCE.I) and the focused LLC pending-ring test pass. Eight native model generations and TOP lint at 2/4 harts have zero RTL warnings/errors. The validation index has 45 entries, including two completed-driver checks that prevent old logs from masquerading as a finished current regression. No RTL warning was disabled. [Five-file inventory and diff size](../../../../../../../verification/non_coherence_cluster/reports/ccu_victim_escape/before/rtl/reports/l1_eviction_retention/changed_files.md), [manual review](../../../../../../../verification/non_coherence_cluster/reports/ccu_victim_escape/before/rtl/reports/l1_eviction_retention/manual_review.md).

[Validation table](../../../../../../../verification/non_coherence_cluster/reports/ccu_victim_escape/before/rtl/reports/l1_eviction_retention/validation.md), [machine-readable results and source hashes](../../../../../../../verification/non_coherence_cluster/reports/ccu_victim_escape/before/rtl/reports/l1_eviction_retention/results.json), [testbench description](../../../../../../../verification/non_coherence_cluster/reports/ccu_victim_escape/before/rtl/verification/l1_eviction_end_to_end/README.md). Run `make l1-eviction-regression` from `verification/non_coherence_cluster/cmo_end_to_end`; that single Makefile builds and runs L1 OKAY/SLVERR/DECERR, AMO/LR-SC, CBO/FENCE.I and strict TOP lint for both hart counts.

TEST-050 uses real CPU stores/loads, direct read-only comparison of actual victim SRAM/tag contents, delayed B, an older pending refill, no premature replacement, no retry/precise trap, fault CSR/IRQ, W1C attempt and public-reset recovery. Error injection changes only the native LLC response after the native write completes; no DUT state or completion is forced. Original upstream sources remain unchanged; licensed modified copies retain copyright/license and dated Quan Nguyen and Codex - VLSI Technology page history.

[OKAY waveform](../../../../../../../verification/non_coherence_cluster/reports/ccu_victim_escape/before/rtl/reports/l1_eviction_retention/waveforms/4h_error0.svg), [SLVERR/reset waveform](../../../../../../../verification/non_coherence_cluster/reports/ccu_victim_escape/before/rtl/reports/l1_eviction_retention/waveforms/4h_error2.svg), [DECERR/reset waveform](../../../../../../../verification/non_coherence_cluster/reports/ccu_victim_escape/before/rtl/reports/l1_eviction_retention/waveforms/4h_error3.svg). These are nonuniform event samples from actual VCDs, not fixed-latency diagrams. Full selected-signal VCDs are kept beside the logs.

### Performance and remaining scope

One native stage-2 ordinary replacement context waits for the B round trip before refill starts. New controller requests/replays pause; older issued refill responses can drain. A failed context blocks that hart's controller until reset. This sacrifices dirty-conflict miss overlap for retention correctness; it does not implement multiple simultaneous ordinary dirty evictions per hart. Missing B still has no timeout under the existing contract. Peer transactions needing a probe to the retained line/cache can also wait until reset; this is not fault isolation.

The existing CSR exposes the sticky fault bit; detailed address/source records remain A-06. A-04 directory holder lifecycle and A-05 full-table CCU victim allocation also remain open. Tests use AXI64, bare M-mode and a 4-KiB LLC; FENCE.I regressions also cover bare S-mode. Rule checking of the modified VLSIT core has zero errors and the same six pre-existing naming/hierarchy heuristic warnings as its snapshot; see [baseline](../../../../../../../verification/non_coherence_cluster/reports/ccu_victim_escape/before/rtl/reports/l1_eviction_retention/rule_baseline.md) and [final check](../../../../../../../verification/non_coherence_cluster/reports/ccu_victim_escape/before/rtl/reports/l1_eviction_retention/rule_check.md). Native RTL warning counts are recorded separately. Host C++ runtime header warnings remain visible in the focused-unit build log; no new suppression was introduced.

No code coverage, default-size-LLC stress, full ISA/OS, reset-with-arbitrary-traffic, physical SRAM, STA/PPA or ASIC signoff is claimed.

## Tiếng Việt

Bản sửa giữ context stage 2 và tag/dirty/data của victim L1 đến B=OKAY. Khi SLVERR/DECERR, chỉ giải phóng transport response, giữ victim/context đến reset và báo IRQ fault bất đồng bộ; không tự retry, không giả completion hoặc trap chính xác cho store đã retire.

Bài test 4 hart còn phát hiện bảng pending LLC đầy vẫn nhận clean miss và ghi đè entry. Đã backpressure mọi miss khi đầy và thêm test riêng clean/full-ring; khác với bảng context CCU thuộc A-05.

Đã nối error bit, chặn cả allocation VALID/CS thật của MSHR và cập nhật directory, giữ metadata, chặn probe cùng line. Refill cũ vẫn được phân xử. Nguồn fatal giữ IRQ và bit diagnostic dù software thử W1C; reset mới xóa nguồn này.

Đã PASS 32 ca CPU thật (6 eviction, 10 atomic, 8 CBO, 8 FENCE.I) và unit pending LLC. Tám lần sinh model cùng lint TOP 2/4 hart có 0 lỗi/warning RTL; không tắt warning. Bảng kiểm chứng và JSON ghi log/hash nguồn thực. Test CPU thật kiểm tra SRAM/tag, lỗi B, response cũ, IRQ/CSR, W1C và reset recovery; không force state DUT. Makefile nêu trên chứa toàn bộ lệnh chạy lại. Nguồn reuse không đổi, bản sửa giữ license/history.

Đánh đổi: miss thay dirty line phải đợi round trip B trước refill; controller tạm dừng admission/replay. Khi lỗi, controller của hart đó chờ reset. Đây chưa phải thiết kế hỗ trợ nhiều eviction dirty đồng thời. A-04/A-05 và fault record chi tiết A-06 vẫn còn; bộ test chưa phải signoff toàn cluster hoặc ASIC.
