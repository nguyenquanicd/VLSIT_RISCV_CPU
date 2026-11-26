# A-05 CCU victim escape / Thoát deadlock khi CCU đầy context

> **Documentation status / Trạng thái tài liệu:** This page records the named run or focused suite; earlier missing-core, timeout or unconnected-CMO statements are historical. Use the current HDS and dated audit for cluster status. / Trang này ghi lại lần chạy hoặc suite riêng; nhận định thiếu core, timeout hoặc CMO chưa nối của mốc cũ là lịch sử. Dùng HDS hiện tại và audit có ngày để xác định trạng thái cluster.

[Current cluster HDS / HDS cluster hiện tại](../../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Recorded audit / Báo cáo đã lưu](../post_a06_cluster_audit/README.md) · [Tensor specification / Đặc tả tensor](../../../doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md)

**Follow-up / Cập nhật 2026-11-16:** [A-06 and full directed regression](../fault_record_a06/README.md) now pass. Source hashes and open-item statements in this older report describe its original checkpoint. / A-06 và regression đã PASS; hash và gap trong báo cáo cũ phản ánh mốc kiểm tra ban đầu.


**Completed:** 83 evidence checks PASS, including **48 real CPU cases**, five directed protocol units, three caught mutations and production TOP lint at 2/4 harts with **0 errors and 0 warnings**. No native RTL warning was disabled or waived. [Validation and logs](validation.md), [changed file](changed_files.md), [machine-readable results and hashes](../../../verification/non_coherence_cluster/reports/ccu_victim_escape/results.json), [deliverables](collateral.md).

**Hoàn tất:** 83 mục bằng chứng PASS, gồm **48 ca CPU thật**, năm unit protocol, ba mutation bị phát hiện và lint TOP 2/4 hart **0 lỗi, 0 warning**. Không tắt hoặc waive warning RTL. Xem bảng kiểm chứng, log và danh sách file ở các liên kết trên.

## RTL behavior / Hành vi RTL

The physical context count remains `PARA_COH_TXN_NUM` (2–16, default 8), including victim children. CPU and CMO admission requires two free entries. One credit is exclusively available to victim children, which do not themselves allocate children. Root admission is therefore at most **N−1 roots**, or 1/7/15 with N=2/8/16; it can be lower while children are active. Completion, owner writeback, terminal directory operations and release never depend on new-root admission.

Only the selected parent enters child-wait. Per-hart grant loading and release match the selected context tag; a grant for one request cannot strand or release another request on that hart. An independent request-ID/address scoreboard checks this behavior.

If another context locks a prospective victim line, the parent cancels its own uncommitted set reservation and retries directory lookup. It does not hold the set while waiting for that other context to access it. Stable cache/directory metadata is not changed by this resource-conflict cancellation. Dirty-owner writeback and two-phase COMMIT/ABORT remain unchanged; a victim failure reaches only its owning parent.

VI: Tổng context vẫn là N, tính cả child. CPU/CMO chỉ nhận khi còn ít nhất hai slot; slot cuối dành cho victim. Tối đa N−1 root, và ít hơn khi có child đang chạy. Chỉ parent được chọn mới chờ child. Load/release grant đều đối chiếu tag; grant của request này không làm mất completion của request khác cùng hart. Nếu victim bị context khác khóa, parent hủy reservation chưa commit và lookup lại, không giữ set để tạo vòng chờ. Quy tắc giữ dirty data và hai pha không đổi.

## Tests / Kiểm thử

- Focused fabric scenarios at 2/8/16 contexts: root backpressure at N−1, actual full table with a victim child, multiple pending parents, same-bank/different-set and cross-bank replacements, PREPARE/COMMIT/ABORT, victim-error recovery, tag reuse. The 16-context test also locks all eight possible victims with real outstanding requests and requires reservation cancellation/relookup before completion.
- New CPU programs: nine 16-KiB-spaced lines exceed the directory's eight ways for both 2/4-hart geometries. Native CVA6 instructions drive the production TOP with **two contexts**, a native 4-KiB LLC, independent AXI memory and deterministic finite backpressure. Dirty/clean replacement, AMO/LR refill faults, exact architectural load/AMO results, final CBO memory publication, full-table/escape-credit activation and 20 native plus 20 external AXI checks are required.
- Full baseline regression: A-04 holder lifecycle, A-03 eviction OKAY/SLVERR/DECERR, cached AMO/LR-SC contention/faults, CBO and M/S-mode FENCE.I success/error, then production TOP lint with default eight contexts at 2/4 harts.
- Mutation checks alter only a build-directory copy: remove the reserved credit, remove selected-parent matching, or remove selected-grant matching. The directed test must reject each mutant. Expected mutant failures are separate from production PASS logs.

VI: Test unit tạo đầy bảng thật ở 2/8/16 slot, nhiều parent, victim lỗi và tái dùng tag. Chương trình CPU dùng chín line cách nhau 16 KiB để ép thay directory; cấu hình hai context buộc dùng slot thoát. Oracle kiểm tra giá trị kiến trúc và DRAM, không suy ra golden từ RTL. Regression giữ đầy đủ AMO/LR-SC, CBO/FENCE.I và lint TOP. Mutation chỉ sửa bản sao trong thư mục build để chứng minh assertion bắt được lỗi.

## Replay / Chạy lại

From `verification/non_coherence_cluster/cmo_end_to_end`, run:

```sh
make victim-regression
```

All commands remain in the existing single [Makefile](../../../verification/non_coherence_cluster/cmo_end_to_end/Makefile). Standalone runners and program listings are in [verification/ccu_victim_escape](../../verification/non_coherence_cluster/ccu_victim_escape/README.md). Build artifacts remain under `C:/HQuan/.test_tmp`; source, images, logs and evidence stay in the project.

Native tool: OSS CAD Suite Verilator 5.053 devel (`v5.052-119-g014c9820d mod`) with its matching runtime; MSYS2 UCRT64 g++ compiles generated C++. Native model warnings are fatal; no new warning suppression or waiver is added. The VLSIT rule checker has the pre-existing HIE-02 notice for this functional fabric containing submodules; it is not the structural TOP. [Rule baseline](rule_baseline.md), [final rule report](rule_check.md), [manual review](manual_review.md).

## Limits / Giới hạn

Progress assumes finite completion of the testbench's probe/AXI/grant responses. The approved missing-ACK policy still waits indefinitely until ACK or reset; reserving capacity cannot recover an unresponsive endpoint. A fixed-latency or formal starvation bound is not claimed. Conservative stale-positive directory holders, no single-sharer E promotion and A-03 reset-only fatal eviction recovery remain in force. No code coverage, formal proof, random race campaign, Linux/ISA, uncached ATOP, default 256-KiB LLC simulation, PPA/STA or ASIC signoff is claimed. Detailed asynchronous fault source/address CSR recording remains A-06.

VI: Kết quả progress phụ thuộc endpoint cuối cùng trả lời. ACK mất vẫn giữ lock đến ACK/reset theo quyết định trước; slot dự phòng không sửa endpoint treo. Chưa có formal bound, random stress, coverage, OS/ISA hay signoff ASIC. Fault record chi tiết vẫn thuộc A-06.
