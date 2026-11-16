# LLC flush commit / Commit flush LLC

Current native CMO integration and instruction results are in [the end-to-end report](../cmo_end_to_end/README.md). Older notes below describe their checkpoint dates. / Kết quả CMO native hiện tại nằm trong báo cáo đầu-cuối; các ghi chú bên dưới mô tả mốc lịch sử tương ứng.

## Full-table deadlock fix and wrap test / Sửa deadlock bảng đầy và kiểm tra wrap

A new native tag-store regression exposed a circular wait: the fifth dirty replacement held the lookup unit busy with all four pending slots allocated, while the first successful B completion could free its slot only during idle. The baseline simulation reached its watchdog with `pending table timeout/deadlock` (`llc_pending_baseline.log`). Deferred tag writes are now allowed during a full-table lookup stall, when no new read or lookup response is issued. Completed writes also prevent endless hit look-ahead from starving the commit port.

Regression tag-store native mới phát hiện vòng chờ: replacement dirty thứ năm giữ lookup busy vì bốn slot đã đầy, nhưng entry đầu đã nhận B thành công lại chỉ được giải phóng khi idle. Baseline chạm watchdog. Bản sửa cho phép ghi tag deferred ngay trong stall do bảng đầy, khi không phát read/response lookup mới. Commit đã sẵn sàng cũng được ưu tiên để chuỗi hit liên tục không gây starvation.

`run_regression.ps1 -LlcPending` now passes: three full-table rounds, five replacements per round, 15 pending allocations, pointer wraparound, delayed completion escape, and re-reading the resulting tags. Log: `llc_pending_sim.log`. The test uses the native tag SRAM and real LLC packages, but injects ordered writeback completion pulses; it does not instantiate W-master, CCU, CPU or retirement. Failed-entry recovery, all simultaneous push/ack/pop combinations, the broader concurrency matrix remains outside this focused test. Per-line CMO is now connected and tested separately in `../cmo_end_to_end/README.md`.

Test mới pass ba vòng bảng đầy, mỗi vòng năm replacement, tổng 15 allocation, pointer wrap, giải phóng stall bằng completion trễ và đọc lại tag kết quả. Test dùng SRAM tag native và package LLC thật, nhưng phát completion writeback theo mô hình; chưa instantiate W-master, CCU, CPU hoặc retirement. Recovery entry lỗi, mọi tổ hợp push/ack/pop đồng thời và maintenance đầu-cuối vẫn chưa hoàn tất kiểm chứng.

## Pending replacement table / Bảng replacement đang chờ

The global dirty-replacement wait has been replaced by a four-entry deferred-tag FIFO sized by `axi_llc_pkg::EvictFifoDepth`. Entries retain set, way and replacement tag/dirty data. Requests to a reserved set wait; requests to other sets can complete while a B response is delayed. The native eviction AXI address master uses the fixed `AxReqId`, so successful and failed B completions advance the pending-ack pointer in descriptor order. A successful entry is written to SRAM in an idle tag-store cycle. A failed entry remains reserved until reset and blocks reuse of its FIFO slot. This is set-level exclusion, not full independent access to different ways of the same set.

Đã thay chờ dirty replacement toàn cục bằng FIFO bốn entry lưu set, way và tag/dirty cần ghi. Request cùng set đang giữ phải chờ; set khác vẫn chạy khi B bị trì hoãn. AW eviction native dùng `AxReqId` cố định, nên ACK thành công/lỗi ghép theo thứ tự descriptor. Entry thành công được ghi SRAM ở chu kỳ tag-store idle. Entry lỗi giữ tới reset và không được tái sử dụng slot. Khóa hiện ở mức set, chưa cho phép truy cập độc lập các way cùng set.

The write-master fault remains sticky, but it no longer freezes already-accepted traffic globally: an errored descriptor is prevented from entering refill while later descriptors can drain. Failed-tag entries are not marked complete by subsequent successful B responses. Reset is still the only recovery for normal eviction failures; per-line CMO has a separate terminal error callback to CCU ABORT.

Fault W-master vẫn sticky nhưng không chặn drain các descriptor sau đã được chấp nhận. Descriptor lỗi không đi vào refill; B thành công sau đó không được ghép nhầm vào entry lỗi. Normal eviction lỗi vẫn cần reset để recovery; FIFO này chưa triển khai đường per-line CMO lỗi sang ABORT.

The directed normal-eviction test now requires a lookup to the other set to complete before the first B response. Logs: `llc_normal_concurrent_okay_sim.log` and `llc_normal_concurrent_error_sim.log`. This is not a multi-core maintenance or full LLC data-array test, and does not prove table-full/wraparound or all concurrent-bank cases.

Test normal eviction hiện yêu cầu lookup set khác hoàn tất trước B đầu tiên. Log: `llc_normal_concurrent_okay_sim.log` và `llc_normal_concurrent_error_sim.log`. Đây chưa phải test maintenance đa core hoặc data-array LLC đầy đủ; chưa chứng minh table-full/wraparound và mọi ca bank đồng thời.

## Normal eviction extension — 2026-11-15 / Mở rộng eviction thông thường

Dirty replacement misses now retain the old SRAM tag until the write master accepts an OKAY B response. The tag-store retains the selected way and replacement request; only the matched normal-eviction completion permits the new tag/dirty write. An errored dirty writeback retains the descriptor and victim state, prevents its refill descriptor from advancing, and asserts a sticky hardware fault. The fault now passes through the eviction unit, LLC top, licensed register wrapper and VLSIT wrapper to the existing cluster fault CSR/interrupt. The persistent source reasserts that CSR while recovery requires reset. This change serializes the tag-store behind a pending dirty replacement; concurrency/performance still needs improvement and measurement.

Miss thay thế victim dirty hiện giữ tag SRAM cũ tới khi W-master nhận B=OKAY. Tag-store lưu way và request thay thế; chỉ completion eviction thành công mới cho ghi tag/dirty mới. Writeback lỗi giữ descriptor/victim, chặn descriptor đó tới refill và giữ fault phần cứng. Fault đi qua các wrapper tới CSR/interrupt lỗi cluster hiện có; nguồn lỗi còn giữ nên CSR được set lại tới reset. Bản sửa hiện tuần tự hóa tag-store sau dirty replacement đang chờ; cần cải thiện và đo concurrency/performance.

Directed native tag-store/W-master simulations pass normal eviction with delayed OKAY and SLVERR, plus the earlier flush success/error cases. Commands: `run_regression.ps1 -LlcTag -NormalEvict`, `run_regression.ps1 -LlcTag -NormalEvict -WriteError`, and `run_regression.ps1 -LlcTag`, from the verification directory. Logs: `llc_normal_okay_sim.log`, `llc_normal_error_sim.log`, `llc_flush_tag_sim.log`. The data-way responder is modeled; these are not full LLC or cluster maintenance simulations. The fault route is checked by source inspection and hierarchy lint, not by a CPU/CSR functional test.

Simulation native tag-store/W-master pass normal eviction delayed OKAY và SLVERR cùng các ca flush trước đó. Data-way responder là mô hình; đây chưa phải mô phỏng maintenance toàn LLC/cluster. Đường fault mới được kiểm tra bằng source và lint hierarchy, chưa có test chức năng CPU/CSR.

Post-change TOP lint completes at 2 and 4 harts: exit 0 under `-Wno-fatal`, zero errors, 595/571 warnings. Logs: `top_lint_2h_20261115_101850.log`, `top_lint_4h_20261115_101727.log`. Per-line CMO and failure-to-CCU-ABORT routing, arbiter/core integration, and precise retirement completion remain incomplete. Earlier statements below about unrepaired normal replacement are historical.

Lint TOP sau sửa hoàn tất ở 2/4 hart: exit 0 với `-Wno-fatal`, không lỗi, còn 595/571 warning. Per-line CMO, trả lỗi về CCU ABORT, nối arbiter/core và retirement completion vẫn chưa hoàn tất. Các ghi chú cũ bên dưới về normal replacement chưa sửa là lịch sử.

The production filelist now selects four licensed source copies under `rtl/modified/axi_llc/src`: top, hit/miss, tag store and write master. Original license headers are retained, followed by a dated modification history. Upstream snapshots are under `rtl/reports/full_integration/source_snapshots/llc_flush_commit_20261115`.

Filelist production hiện dùng bốn bản sao có license ở `rtl/modified/axi_llc/src`: top, hit/miss, tag store và write master. Header license gốc được giữ, sau đó bổ sung history. Snapshot upstream ở `rtl/reports/full_integration/source_snapshots/llc_flush_commit_20261115`.

## Implemented behavior / Hành vi đã triển khai

The existing way-flush path no longer invalidates a dirty tag when its descriptor is accepted. The tag-store retains the flush request until the write master reports successful completion. A clean line without writeback uses the existing terminal descriptor event. A dirty line requires an OKAY B response. SLVERR/DECERR latch a write-master fault and prevent the flush-success pulse; tag/data remain protected until reset. This is currently fail-stop behavior. It is not the required per-line CMO failure-to-ABORT return path.

Đường way-flush hiện có không invalidate tag dirty khi descriptor được nhận. Tag store giữ request tới completion thành công từ write master. Line sạch không cần writeback dùng terminal descriptor event hiện có; line dirty cần B=OKAY. SLVERR/DECERR giữ fault, chặn pulse flush thành công và bảo vệ tag/data đến reset. Đây hiện là hành vi dừng chờ reset; chưa phải đường lỗi per-line CMO trả về ABORT.

## Evidence / Bằng chứng

Run `rtl/verification/cmo_metadata/run_regression.ps1 -LlcTag`. The test instantiates the modified native tag store and write master, uses real LLC packages/macros and a modeled data-way responder. It checks two 64-bit W beats, WLAST, payload, tag-write suppression during delayed B, successful invalidation after OKAY, and retained pending/tag state after SLVERR. Result: PASS; log `llc_flush_tag_sim.log`. This does not instantiate the complete LLC, CPU, CCU, arbiter, or retirement path.

Chạy `rtl/verification/cmo_metadata/run_regression.ps1 -LlcTag`. Test instantiate tag store và write master native đã sửa, dùng package/macro LLC thật và responder mô hình cho data way. Test kiểm tra hai W beat 64-bit, WLAST, payload, không ghi tag khi chờ B, invalidate sau OKAY và giữ pending/tag sau SLVERR. Kết quả PASS; log `llc_flush_tag_sim.log`. Test chưa instantiate toàn LLC, CPU, CCU, arbiter hoặc retirement.

Full hierarchy lint from the production TOP completes with exit 0 under `-Wno-fatal`: 2 harts, 595 warnings (`top_lint_2h_20261115_095444.log`); 4 harts, 571 warnings (`top_lint_4h_20261115_095824.log`). No errors were reported. Warnings, including combinational-loop diagnostics, remain unresolved; no synthesis/signoff claim is made.

Lint toàn hierarchy từ TOP production hoàn tất, exit 0 với `-Wno-fatal`: 2 hart có 595 warning, 4 hart có 571 warning; không báo lỗi. Các warning, gồm diagnostic vòng tổ hợp, còn mở; chưa có kết quả synthesis/signoff.

## Remaining scope / Phạm vi còn thiếu

Normal replacement eviction still follows upstream tag-update timing and is not repaired by this way-flush change. Per-line CLEAN/FLUSH/INVAL, B-error response to CCU, two-phase abort/commit, retirement completion/fault delivery, and core arbitration integration are not complete. The successful simulation and TOP lint above must not be presented as end-to-end CMO verification.

Eviction thay thế thông thường vẫn theo timing cập nhật tag upstream, chưa được bản sửa way-flush này xử lý. Per-line CLEAN/FLUSH/INVAL, trả lỗi B về CCU, abort/commit hai pha, retirement completion/fault và nối arbitration vào core chưa hoàn tất. Không được xem simulation và lint trên là kiểm chứng CMO đầu-cuối.
