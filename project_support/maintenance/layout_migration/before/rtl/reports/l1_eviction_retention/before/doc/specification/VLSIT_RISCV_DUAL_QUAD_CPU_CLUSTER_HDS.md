---
document_type: asic_ip_design_specification
document_id: "VLSIT-RISCV-DUAL-QUAD-CPU-CLUSTER"
title: "VLSIT RISC-V Dual/Quad CPU Cluster Design Specification"
ip_name: "VLSIT RISC-V Dual/Quad CPU Cluster"
version: "0.27"
status: "Draft - external CMO integrated; directed CPU instruction and TOP lint evidence in rtl/reports/cmo_end_to_end; broader verification remains open"
language: "English and Vietnamese"
rtl_rules: "VLSIT_RTL_Design_Rule.md v2"
csr_spec: "VLSIT_RISCV_CPU_Cluster_CSR.xlsx"
---

# VLSIT RISC-V Dual/Quad CPU Cluster Design Specification

# Đặc tả cụm CPU RISC-V cấu hình 2/4 lõi VLSIT

**Lint checkpoint (2026-11-15):** Both production AXI TOP profiles (2/4 harts) complete lint with 0 errors and 0 warnings. Real CBO retire/trap regressions pass after the source fixes. Pipeline latency and the external cluster contract are unchanged. [Evidence, source changes and limits](../../rtl/reports/lint_cleanup/README.md).

**Mốc lint (2026-11-15):** Hai profile AXI TOP 2/4 hart lint với 0 lỗi và 0 warning; regression CBO retire/trap đã pass sau sửa. Latency pipeline và hợp đồng ngoài cluster giữ nguyên. Xem bằng chứng và giới hạn trong liên kết trên.

**Current implementation checkpoint (2026-11-15):** The production AXI core enables external CMO. Retirement captures PC/effective VA/op/translated line, waits for older stores to leave both LSU and HPDcache replay/refill/pipeline activity, then uses the shared arbiter/controller and CCU context/lock service. The native LLC per-line operation returns terminal success/error only after its writeback response. CCU COMMIT/ABORT and lock release precede CPU completion. See [reproducible validation evidence](../../rtl/reports/cmo_end_to_end/README.md). Earlier revision notes below are historical, not a statement of the current integration boundary.

**Mốc triển khai hiện tại (2026-11-15):** Core AXI production bật external CMO. Retirement giữ PC/VA/op/line và chờ store cũ rời cả LSU lẫn replay/refill/pipeline HPDcache; sau đó dùng arbiter/controller và context/lock CCU chung. LLC native chỉ trả kết quả cuối sau writeback response. CCU hoàn tất COMMIT/ABORT và nhả khóa trước khi trả completion cho CPU. Xem bằng chứng kiểm chứng tại liên kết trên; các ghi chú phiên bản cũ bên dưới là lịch sử.

**Approved CBO interrupt/debug policy (2026-11-15):** Once a CMO request has been accepted, defer interrupt entry and entry into Debug Mode for the issuing hart until that CBO retires successfully or reports its terminal synchronous maintenance fault. Cache, probe, CCU and AXI service must remain active during the wait. A missing B response or required phase ACK can therefore defer interrupt/debug entry indefinitely under the approved no-timeout policy. Reset remains available. This decision specifies functional behavior; it is not a claim that the retirement integration is implemented or verified.

**Chính sách interrupt/debug của CBO đã duyệt (2026-11-15):** Sau khi request CMO được nhận, hart phát lệnh hoãn nhận interrupt và vào Debug Mode tới khi CBO retire thành công hoặc báo lỗi maintenance đồng bộ cuối cùng. Cache, probe, CCU và AXI phải tiếp tục hoạt động trong thời gian chờ. Nếu thiếu B response hoặc ACK bắt buộc, interrupt/debug có thể bị hoãn vô hạn theo chính sách không timeout đã duyệt. Reset vẫn có hiệu lực. Đây là quyết định hành vi, chưa phải xác nhận triển khai hoặc kiểm chứng retirement.

**RTL implementation checkpoint (2026-11-15):** The structural cluster core is now instantiated under the AXI top and elaborated through the configured CVA6/HPDcache hierarchy, CCU, shared directory, LLC wrapper, address routing, CSR bridges, and PMU. The captured default 4-hart TOP lint log contains no `%Error` diagnostics and 263 warnings under `-Wno-fatal`; the shell did not return a reliable native exit code, so this is not recorded as a clean lint pass. Directed CCU fabric and tile-array simulations pass; the tile-array test runs at 2 and 4 harts and checks PMU taps. CCU event IDs `0x0300–0x030B` are connected through the cluster PMU. Event `0x0306` source wording in the CSR workbook still needs reconciliation with the no-payload probe/writeback-completion interface. Full CPU-to-memory functional simulation, CMO/`FENCE.I` completion and error handling, system atomic verification, synthesis and PPA remain open. Older dated implementation notes below are historical checkpoints. This checkpoint updates implementation status only; the requirements and approved behavior in this HDS are unchanged.

**Mốc triển khai RTL (2026-11-15):** Cluster core cấu trúc hiện được instantiate dưới AXI top và đã elaborate qua hierarchy CVA6/HPDcache cấu hình, CCU, directory dùng chung, wrapper LLC, address routing, CSR bridge và PMU. Log lint TOP mặc định 4 hart được ghi lại không có diagnostic `%Error` và có 263 cảnh báo với `-Wno-fatal`; shell không trả exit code native đáng tin cậy nên chưa ghi đây là lint pass sạch. Mô phỏng directed CCU fabric và tile array pass; test tile array chạy ở 2/4 hart và kiểm tra tap PMU. Event CCU `0x0300–0x030B` đã nối qua PMU cluster. Mô phỏng chức năng CPU tới memory, hoàn tất/xử lý lỗi CMO/`FENCE.I`, kiểm chứng atomic toàn hệ thống, synthesis và PPA còn mở. Mốc này chỉ cập nhật trạng thái triển khai; không thay đổi requirement hoặc hành vi đã duyệt trong HDS.

**CMO controller verification checkpoint (2026-11-15):** The standalone CMO sequencer passes five directed scenarios and 134 checks at both 2- and 4-hart parameter values. A temporary mutation that incorrectly enables owner writeback for INVAL is caught by the testbench. The VLSIT rule check reports no errors and two NAM-08 warnings for approved port spellings. This is leaf-level controller evidence only; CVA6 retirement/trap, HPDcache writeback, CCU line locking, LLC per-line maintenance, and external AXI error behavior remain unverified end to end. Code coverage is not measured because no HDS target is defined.

**Mốc kiểm chứng CMO controller (2026-11-15):** Sequencer CMO độc lập pass năm kịch bản directed và 134 check ở cả cấu hình tham số 2/4 hart. Testbench bắt được mutation tạm thời bật nhầm owner writeback cho INVAL. VLSIT rule check không có lỗi, còn hai cảnh báo NAM-08 cho tên port đã duyệt. Đây chỉ là bằng chứng ở controller leaf; retirement/trap CVA6, writeback HPDcache, line lock CCU, maintenance LLC theo line và lỗi AXI ngoài chưa được kiểm chứng đầu-cuối. Không đo code coverage vì HDS chưa đặt target.

**TOP lint status (2026-11-15):** A complete 2-hart TOP lint attempt timed out at 420 seconds with 263 warnings and no `%Error` diagnostics; the wrapper exit code indicates timeout, not a successful Verilator exit. This is not a lint pass. PA/VA/CBO operation metadata now reaches the cluster-core boundary through licensed CVA6 copies, but PC joining, retirement hold/error handling, and controller/CCU/LLC service are not integrated. These implementation gaps do not change the normative CMO requirements; see the integration report for logs and source mapping.

**Trạng thái lint TOP (2026-11-15):** Lần lint TOP đầy đủ ở cấu hình 2 hart timeout sau 420 giây, có 263 cảnh báo và không có diagnostic `%Error`; exit code của wrapper thể hiện timeout, không phải Verilator kết thúc thành công. Đây không phải lint pass. PA/VA/op CBO hiện đã tới biên cluster core qua các bản CVA6 có license; ghép PC, giữ CBO tại retirement và nối controller/CCU/LLC vẫn chưa triển khai. Khoảng trống này không thay đổi requirement CMO chuẩn tắc; log và ánh xạ source xem trong báo cáo tích hợp.

**CBO metadata route checkpoint (2026-11-15):** Licensed CVA6 copies retain PA, effective VA, and operation in the speculative store buffer and route them through LSU/EX, CVA6, tile, and tile array to the cluster-core boundary. A directed store-buffer simulation checks capture, ordering behind an older store, stability until dequeue/flush, and flush removal. PC joining, CBO retirement hold, precise error delivery, CMO controller consumption, CCU/LLC service, and full-cluster lint/verification remain open. The test uses package/type stubs and is not full CVA6 verification. Normative requirements are unchanged.

**Mốc nối metadata CBO (2026-11-15):** Các bản CVA6 có license giữ PA, VA hiệu dụng và operation trong store buffer speculative rồi nối qua LSU/EX, CVA6, tile và tile array tới biên cluster core. Mô phỏng directed store buffer kiểm tra capture, thứ tự sau store cũ hơn, ổn định đến dequeue/flush và xóa khi flush. Ghép PC, giữ CBO tại retirement, báo lỗi chính xác, nối CMO controller, dịch vụ CCU/LLC và lint/verification toàn cluster vẫn còn mở. Test dùng package/type stub, chưa phải kiểm chứng CVA6 đầy đủ. Requirement chuẩn tắc không đổi.

**RTL implementation checkpoint (2026-11-14):** The standalone CCU fabric connects transaction allocation, four-bank directory lookup/update, two-phase probes, and grant retention. Its seven directed control-plane cases pass: cold `E`, `E→S`, `S→M`, dirty `M` transfer, failed writeback followed by PREPARE→ABORT/error grant, successful retry, bank 2 progress while a bank 1 grant is stalled, and grant backpressure. The failed-writeback test exposed and fixed a real bug that lost the requester error after a successful ABORT. Probe and writeback outcomes are modeled at the fabric boundary; this is not end-to-end cache or AXI writeback verification. HPDcache permission-before-refill/upgrade is still absent, the fabric is not connected through `m_vlsit_riscv_cluster_core`, and current cluster TOP lint fails because that module is undefined.

**Mốc triển khai RTL (2026-11-14):** CCU fabric độc lập nối transaction allocation, lookup/update directory bốn bank, probe hai pha và giữ grant. Bảy ca control-plane directed pass: cấp `E` lạnh, `E→S`, `S→M`, chuyển owner `M` dirty, writeback lỗi rồi PREPARE→ABORT/error grant, retry thành công, bank 2 vẫn tiến triển khi grant bank 1 bị stall và backpressure grant. Ca writeback lỗi phát hiện và sửa bug làm mất cờ lỗi requester sau ABORT thành công. Probe và writeback được mô hình hóa tại biên fabric; đây chưa phải kiểm chứng cache hoặc AXI đầu-cuối. HPDcache vẫn chưa xin quyền trước refill/upgrade, fabric chưa nối qua `m_vlsit_riscv_cluster_core`, và lint TOP hiện lỗi vì module đó chưa được định nghĩa.

**Revision 0.27 RTL integration status:** New `m_vlsit_riscv_coh_tile_array` joins one tile adapter per hart to the shared MESI fabric. Verilator lint and a directed integration simulation pass at 2 and 4 harts for cold E grant, E-to-S sharing, same-line busy-query gating, per-tag locking, and successful terminal release. The test models native-cache responses; it does not instantiate CVA6, HPDcache arrays, LLC, or AXI data channels. The wrapper is not yet instantiated in `m_vlsit_riscv_cluster_core`; TOP elaboration and full-cluster verification remain incomplete.

**Trạng thái tích hợp RTL bản 0.27:** Module mới `m_vlsit_riscv_coh_tile_array` nối một adapter tile cho mỗi hart vào MESI fabric dùng chung. Verilator lint và mô phỏng directed pass ở cấu hình 2/4 hart cho cấp E lạnh, chia sẻ E-to-S, chặn theo busy query cùng dòng, khóa theo tag và nhả khóa khi kết thúc thành công. Test mô hình hóa response của cache; chưa instantiate CVA6, mảng HPDcache, LLC hoặc kênh dữ liệu AXI. Wrapper chưa được instantiate trong `m_vlsit_riscv_cluster_core`; TOP chưa elaborate được và kiểm chứng toàn cluster còn thiếu.

**Revision 0.26 implementation status:** The modified HPDcache now accepts tagged two-phase probe requests through CVA6 and the CPU-tile boundary. PREPARE performs a native directory lookup and optionally writes back a dirty M line through the existing flush-data/AXI path; the engine checks the matching origin and line on B response. COMMIT writes the requested MESI state through a dedicated directory RAM update path, while ABORT leaves directory state unchanged. Failed or mismatched writeback responses prevent COMMIT. CPU victim, CMO, and coherence-probe flush allocations are arbitrated, and only CPU-origin ACKs release CPU RTAB flush dependencies. Each cache services one probe at a time. This does not implement permission-before-refill/upgrade or the missing cluster core/CCU integration. Standalone configured HPDcache lint passes with 0 errors and 131 warnings; full CVA6+HPDcache subsystem lint still has five Verilator parameterized-range errors and 517 warnings. The cluster TOP still cannot elaborate because `m_vlsit_riscv_cluster_core` is missing.

**Cập nhật trạng thái triển khai bản 0.26:** HPDcache sửa đổi hiện nhận probe hai pha có tag qua CVA6 và biên CPU tile. PREPARE tra directory native và có thể ghi trả line M dirty qua đường flush-data/AXI sẵn có; engine kiểm tra origin và line khớp khi nhận B response. COMMIT ghi MESI state yêu cầu qua đường cập nhật directory RAM riêng, còn ABORT giữ nguyên directory state. Writeback lỗi hoặc response sai line ngăn COMMIT. Flush victim CPU, CMO và probe coherence được phân xử; chỉ ACK từ CPU mới giải phóng dependency flush RTAB của CPU. Mỗi cache phục vụ một probe tại một thời điểm. Permission-before-refill/upgrade và cluster core/CCU còn thiếu chưa được triển khai. Lint HPDcache cấu hình riêng pass với 0 lỗi, 131 cảnh báo; lint toàn subsystem CVA6+HPDcache còn 5 lỗi range parameterized Verilator và 517 cảnh báo. TOP cluster chưa elaborate được vì thiếu `m_vlsit_riscv_cluster_core`.

**Revision 0.25 update:** Added a per-tag line-lock vector from the tile coherence adapter through CVA6 to the licensed HPDcache controller. PREPARE forwarding waits until matching MSHR/refill activity and accepted Stage-0 or active Stage-1 CPU requests clear. A same-edge CPU request therefore holds PREPARE off; after lock acquisition, matching requests and misses selecting the locked victim wait in an RTAB sidecar dependency until release. This protects request admission and replacement only; resident-tag probe lookup, tag/data-array arbitration, dirty-owner transfer, MESI transitions, and permission-before-refill remain unimplemented. The configured HPDcache lint completes with zero errors and 71 warnings. CVA6+HPDcache subsystem lint currently fails on Verilator parameterized-type constant-range errors in modified HPDcache/subsystem sources and an upstream HWPF wrapper; it is not a pass. The cluster TOP still cannot elaborate because `m_vlsit_riscv_cluster_core` is missing.

**Cập nhật bản 0.25:** Bổ sung vector khóa line theo tag từ adapter coherence của tile, qua CVA6 tới bộ điều khiển HPDcache có license. PREPARE chờ MSHR/refill và request CPU Stage 0 đã nhận hoặc Stage 1 đang hoạt động của đúng line kết thúc. Request CPU nhận cùng cạnh cũng giữ PREPARE lại; sau khi khóa, request cùng line và miss chọn victim đang bị khóa được giữ trong sidecar dependency RTAB đến khi nhả khóa. Cơ chế này mới bảo vệ admission request và chọn victim; tra tag resident, phân xử tag/data array, chuyển dữ liệu owner dirty, chuyển MESI và xin quyền trước refill vẫn chưa có. Lint HPDcache cấu hình xong với 0 lỗi, 71 cảnh báo. Lint subsystem CVA6+HPDcache hiện thất bại do Verilator báo range constant từ kiểu parameter trong source HPDcache/subsystem sửa đổi và wrapper HWPF upstream; không xem là pass. TOP cluster chưa elaborate được vì thiếu `m_vlsit_riscv_cluster_core`.

**Revision 0.24 history:** Added an `exclusive` bit to the licensed HPDcache directory-entry copy and updated refill/legacy directory constructors to initialize it to zero (clean Shared). This is metadata preparation only: E/M transitions, probe lookup, array arbitration, and CCU permission-before-refill remain unimplemented. The selected CVA6 lint run timed out at 300 seconds with 570 warnings and no reported errors before timeout; it does not establish a pass. The cluster TOP still cannot elaborate because `m_vlsit_riscv_cluster_core` is missing.

**Cập nhật bản 0.24:** Thêm bit `exclusive` vào bản sao directory-entry HPDcache có giữ license và cập nhật refill/directory constructor cũ đặt bit bằng 0 (Shared sạch). Đây mới là chuẩn bị metadata: chuyển E/M, probe lookup, arbitration array và xin quyền CCU trước refill chưa làm. Lint cấu hình CVA6 đã hết timeout sau 300 giây với 570 warning và không báo error trước timeout; chưa thể kết luận pass. TOP cluster vẫn chưa elaborate được vì thiếu `m_vlsit_riscv_cluster_core`.

**Revision 0.23 update:** Added the standalone `m_vlsit_riscv_axi_route` leaf. It routes cacheable and normal-uncached traffic to the memory path, carries the class sideband for LLC bypass, sends MMIO to the external peripheral path, and returns local DECERR for unmapped, malformed, or unsupported MMIO atomic/exclusive requests. It is linted against pinned PULP AXI sources at MaxTrans 1, 8, and 32. The leaf is not connected to the cluster top because `m_vlsit_riscv_cluster_core` is still missing. Invalid address-table parameters still lower `o_config_valid`; a hard elaboration failure is not guaranteed.

**Cập nhật bản 0.23:** Bổ sung khối leaf độc lập `m_vlsit_riscv_axi_route`. Khối đưa cacheable và normal-uncached tới đường memory, giữ sideband class để LLC bypass, chuyển MMIO tới đường ngoại vi và trả DECERR cục bộ cho địa chỉ không khớp, transaction sai hoặc atomic/exclusive MMIO không hỗ trợ. Khối đã lint với source PULP AXI đã pin tại MaxTrans 1, 8 và 32. Leaf chưa nối vào top vì còn thiếu `m_vlsit_riscv_cluster_core`. Parameter bảng địa chỉ sai vẫn làm `o_config_valid` xuống thấp; RTL chưa bảo đảm lỗi elaboration.

**Revision 0.20 history:** DEC-036 selected asynchronous reporting for ordinary dirty-eviction writeback failures, added `o_int_fault`, and retained affected data/locks until reset. CBO and FENCE.I keep their previously selected synchronous-fault contracts.

**Lịch sử bản 0.20:** DEC-036 chốt báo lỗi bất đồng bộ cho writeback eviction dirty thông thường, thêm `o_int_fault` và giữ dữ liệu/lock đến reset. CBO/FENCE.I giữ hợp đồng lỗi đồng bộ đã chốt.

**Revision 0.19 history:** Added liveness contracts for directory reservations, request-token consumption, response draining, and transaction-context retention; expanded worst-case performance analysis; and evaluated external AXI data-width options. That revision was originally a specification-only update.

**Cập nhật bản 0.19:** Bổ sung hợp đồng tiến triển cho reservation directory, tiêu thụ request đúng một lần, xử lý response và duy trì transaction context; phân tích hiệu năng trường hợp xấu nhất và đánh giá các lựa chọn độ rộng dữ liệu AXI bên ngoài. Bản cập nhật chỉ sửa đặc tả; RTL chưa thay đổi.

This specification defines a synthesis-time configurable two- or four-hart CVA6 cluster, with four harts as the default. The selected baseline is upstream CVA6 configuration `cv64a6_imafdc_sv39_hpdcache_wb`; its license-preserving local configuration copy disables CVXIF because the cluster has no external accelerator boundary. The design uses HPDcache, an internally coherent MESI D-cache domain with an independent sharer directory, and tagged concurrent coherence transactions with two-phase PREPARE/COMMIT/ABORT probes and no timeout for any phase ACK. A dirty M owner writes its line through its existing HPDcache AXI path for coherence requests and writeback-required CMOs; PREPARE waits for the matching B response while the owner retains M and its line lock. Zicbom CBO operations route through the CCU and relevant D-cache holders. CLEAN and FLUSH write dirty data through the per-line LLC service to external memory; FLUSH then invalidates copies. A true CBIE-decoded invalidate locks and invalidates matching copies without writeback and may discard dirty data; an INVAL decoded as FLUSH follows FLUSH. A writeback error on CLEAN, FLUSH, or INVAL-as-FLUSH raises a precise synchronous Store/AMO access fault after ABORT completes and before retirement. `FENCE.I` transfers dirty local D-cache lines to shared LLC, then invalidates the executing hart's I-cache and fetch pipeline; it does not wait for LLC-to-DRAM writeback. If the L1-to-LLC B response fails, the line is aborted with M/directory state preserved, then a custom synchronous maintenance exception (cause 24) is raised at the `FENCE.I` PC with the aligned physical line address in `mtval`/`stval`. The cluster also has a static shared LLC, one AXI4-Lite control port, and AXI4+ATOP memory plus AXI4 MMIO boundaries. A shared 64-bit boot-address input fans out to every active hart. The current RTL phase covers the AXI profile; the external ACE profile is deferred. OpenHW CVA6/HPDcache and PULP LLC sources remain pristine in `rtl/third_party`; required changes use separately licensed, provenance-preserving copies. Directory geometry, tree-PLRU replacement, round-robin bank arbitration, transaction count, CSR local windows, ATOP handling, LLC service bridge, PMU source groups/ranges, and hybrid event-multiplicity semantics are selected. Detailed source mapping, CCU tap ports, internal module port tables, and implementation verification remain to be reviewed.

Đặc tả này xác định cluster CVA6 cấu hình trước tổng hợp với hai hoặc bốn hart, mặc định bốn hart. Baseline là cấu hình upstream `cv64a6_imafdc_sv39_hpdcache_wb`; bản cấu hình cục bộ giữ license sẽ tắt CVXIF vì cluster không có biên accelerator ngoài. Thiết kế dùng HPDcache, coherence MESI nội bộ cho D-cache bằng sharer directory độc lập và transaction đồng thời có tag với probe hai pha PREPARE/COMMIT/ABORT không timeout ở mọi phase ACK. Dirty owner M ghi qua AXI path HPDcache hiện có cho coherence request và CMO cần writeback; PREPARE đợi B response tương ứng trong khi owner giữ M và line lock. Lệnh Zicbom CBO đi qua CCU và các D-cache holder liên quan. CLEAN và FLUSH ghi dữ liệu dirty qua dịch vụ LLC từng line ra bộ nhớ ngoài; FLUSH sau đó invalidate các bản sao. INVAL thật theo CBIE khóa rồi invalidate bản sao mà không writeback và có thể bỏ dữ liệu dirty; INVAL được giải mã thành FLUSH sẽ theo FLUSH. Nếu writeback lỗi trong CLEAN, FLUSH hoặc INVAL-as-FLUSH, cluster đợi ABORT hoàn tất rồi phát Store/AMO access fault đồng bộ chính xác trước retire. `FENCE.I` chuyển line D-cache dirty của hart lên LLC chia sẻ rồi invalidate I-cache và fetch pipeline cục bộ; không đợi LLC ghi ra DRAM. Nếu B response L1-to-LLC lỗi, line được ABORT, giữ M/directory state rồi phát custom synchronous maintenance exception cause 24 tại PC `FENCE.I`, với địa chỉ physical line căn chỉnh trong `mtval`/`stval`. Cluster còn có LLC chia sẻ dung lượng tĩnh, một cổng AXI4-Lite, AXI4+ATOP cho bộ nhớ và AXI4 cho MMIO. Một input boot address 64-bit dùng chung được nối tới mọi hart đang hoạt động. Giai đoạn RTL hiện tại chỉ gồm profile AXI; profile ACE bên ngoài được hoãn. Nguồn OpenHW CVA6/HPDcache và PULP LLC được giữ nguyên trong `rtl/third_party`; phần sửa nằm ở bản sao riêng có giữ license và truy vết nguồn. Hình học directory, tree-PLRU, phân xử round-robin mỗi bank, số transaction, vùng địa chỉ AXI4-Lite local, bridge LLC và nhóm/dải event PMU đã chọn. Ánh xạ chi tiết, độ rộng cổng, port source nội bộ và kiểm chứng triển khai còn chờ review.

Requirement words have their ordinary specification meaning: shall is mandatory, should is recommended, and may is optional. Each requirement has one verification method in Section 3 and one traceability row in Section 19.

Các từ quy định có nghĩa theo chuẩn đặc tả: shall là bắt buộc, should là khuyến nghị và may là tùy chọn. Mỗi yêu cầu có phương pháp kiểm chứng ở Mục 3 và dòng truy vết ở Mục 19.

## Document map

1. Purpose, scope, and product context
2. Normative references and precedence
3. Requirements and traceability
4. Features and configurations
5. Architecture
6. External interfaces and ports
7. Clock, reset, and power
8. Parameters and elaboration configurations
9. Data representation and arithmetic
10. Detailed functional behavior
11. Register and programming model
12. Error handling and recovery
13. Performance, power, and area
14. RTL implementation contract
15. Verification specification
16. DFT and testability
17. Physical design and timing integration
18. Security, safety, and reliability
19. Requirement-to-verification traceability
20. Assumptions, dependencies, and decisions
21. Glossary
22. References used to shape this specification

## 1. Purpose, scope, and product context

### 1.1 Purpose and scope

The IP integrates two or four identical 64-bit application-class CVA6 harts into one internally cache-coherent cluster. Each hart has private L1 caches; the D-caches participate in a MESI domain coordinated by the cluster coherence controller (CCU). D-cache misses and ownership requests flow through the CCU to the shared LLC, and LLC misses use external AXI4+ATOP with the six-bit AWATOP field preserved. Non-cacheable peripheral traffic bypasses the coherent cache path over ordinary AXI4. Software configuration uses AXI4-Lite; the cluster also provides PMU facilities and per-hart debug control/status connections to an external RISC-V Debug Module.

The current delivery has one structural AXI top. It exposes AXI4+ATOP memory traffic and does not snoop external agents; external DMA therefore requires a software/system cache-maintenance contract. Non-cacheable peripheral traffic uses ordinary AXI4. A future ACE top may add external-agent coherence after a separate specification and approval. It is not a runtime mode and is not included in this RTL phase.

Included in the current RTL phase: two/four-hart elaboration; selected CVA6/HPDcache integration; internal MESI D-cache coherence; shared LLC; one AXI4+ATOP memory boundary; non-coherent AXI4 peripheral access; 32-bit AXI4-Lite configuration with LLC RegBus bridge; cluster PMU; per-hart debug request/status connections; reset and integration contracts. The external ACE profile is future work and is not part of the current RTL hierarchy or port plan.

Excluded: DRAM controller/PHY; complete SoC interconnect and interrupt controller; external Debug Transport Module/Debug Module; runtime LLC capacity changes; runtime scratchpad (SPM) mode; CPU hot-add; cache coherence across the AXI-only boundary; power gating, retention, and DVFS; guaranteed frequency, area, or power targets.

Giai đoạn RTL hiện tại gồm cluster CVA6 hai hoặc bốn hart, coherence MESI cho D-cache, LLC chia sẻ tĩnh, biên bộ nhớ AXI4+ATOP, ngoại vi AXI4 không coherence, AXI4-Lite có bridge RegBus cho LLC, PMU và debug từng hart. Profile ACE coherence với agent ngoài là phần mở rộng tương lai, chưa thuộc hierarchy/port plan hiện tại.

Giai đoạn hiện tại có một top cấu trúc AXI. Top này đưa traffic bộ nhớ AXI4 thông thường và không snoop agent ngoài. Nếu bổ sung top ACE trong tương lai, top đó phải là module cổng cố định riêng và cần đặc tả/phê duyệt riêng; không có chuyển profile lúc chạy.

### 1.2 Deployment assumptions

| Item | Specification |
|---|---|
| Target SoC / product class | Candidate Linux-capable industrial edge gateway; proposed application, not a user-confirmed product |
| Workload | Linux SMP packet filtering, protocol handling, and security services; representative workload to be supplied by system integration |
| Technology / library | ASIC standard-cell library and SRAM macros not yet selected |
| Security / privilege | CVA6 application profile with machine/supervisor/user execution; system protection policy is owned by SoC |
| External dependencies | Upstream CVA6, modified HPDcache, Culsans coherence reference, axi_llc, AXI fabric, clock/reset controller, external RISC-V Debug Module; ACE fabric is future scope |
| Evidence status | Public FPGA/simulation evidence exists for reference projects; this exact upstream combination has not been demonstrated |

Ứng dụng dự kiến là gateway công nghiệp chạy Linux SMP để lọc gói, xử lý giao thức và dịch vụ bảo mật. Đây là ứng dụng đề xuất vì người dùng chưa cung cấp sản phẩm/workload cụ thể. Library ASIC, SRAM macro và số liệu workload thực tế do tích hợp SoC cung cấp.

### 1.3 Feature summary

| Feature ID | Feature | Required / optional | Configuration condition | Requirements |
|---|---|---|---|---|
| FEAT-001 | Two- or four-hart CVA6 cluster | Required | PARA_CPU_NUM is 2 or 4 | REQ-SYS-001 |
| FEAT-002 | Internal MESI coherence for active harts' D-caches | Required | AXI profile, 2/4 harts | REQ-MEM-001 |
| FEAT-003 | Non-coherent AXI4 peripheral manager | Required | Current AXI phase | REQ-IF-002 |
| FEAT-004 | AXI-only memory profile | Required profile | AXI structural top | REQ-IF-003 |
| FEAT-005 | External ACE coherent memory profile | Deferred | Future separate phase | REQ-IF-004 |
| FEAT-006 | Static shared LLC | Required | Current AXI phase; default 256 KiB | REQ-MEM-002 |
| FEAT-007 | Cluster PMU and aggregate interrupt | Required | Current AXI phase | REQ-PMU-001 |
| FEAT-008 | External Debug Module connection | Required integration | Current AXI phase; DM/DTM outside | REQ-DBG-001 |
| FEAT-009 | AXI4-Lite management and LLC service access | Required | Current AXI phase | REQ-IF-001 |
| FEAT-010 | System-wide Zicbom CBO clean/flush/invalidate with precise writeback faults | Required | Zicbom enabled; per-line LLC service; CVA6 commit integration | REQ-MEM-015–017 |
| FEAT-011 | Local FENCE.I instruction-fetch synchronization through the shared LLC | Required | DcacheFlushOnFenceI=1; local I-cache is not coherent | REQ-MEM-007, REQ-MEM-018 |

### 1.4 Real-world applications of the features

Values below are proposal baselines from this specification, not measured workload limits. The system owner must replace them when a product workload is known.

Các giá trị dưới đây là cấu hình đề xuất của đặc tả, không phải giới hạn workload đã đo. Chủ hệ thống cần thay thế khi có workload sản phẩm.

| Feature ID | Real-world application | What the application needs | Proposed measurable values | Consequence if missing or wrong | Requirements | Source |
|---|---|---|---|---|---|---|
| FEAT-001 | Linux industrial edge gateway handling packet filtering and encryption | SMP execution capacity and software-compatible virtual memory | 2 or 4 harts; 64-bit XLEN | Linux cannot use the configured hart count or the cluster lacks capacity for parallel services | REQ-SYS-001 | ASM-001 |
| FEAT-002 | Gateway workers sharing packet descriptors and queues in normal memory | CPU harts must observe coherent ownership/data for shared cacheable lines | 2 or 4 harts; 16-byte L1 line | Stale descriptors or duplicate ownership can corrupt packet processing | REQ-MEM-001 | ASM-001, REF-004 |
| FEAT-003 | Gateway UART, timer, watchdog, and network-control registers | Device accesses must use a non-cacheable path with AXI handshake | 64-bit AXI4 data/address baseline | Cached or reordered device accesses can lose commands or misread status | REQ-IF-002 | ASM-001, REF-001 |
| FEAT-004 | Gateway whose DMA/network agent uses explicit software cache maintenance | AXI-only memory egress must be identified as non-coherent with external agents | AXI4 profile; 64-bit data; explicit cache-maintenance contract | DMA may observe old memory or overwrite dirty cache data | REQ-IF-003 | ASM-001, ASM-003 |
| FEAT-005 | Future gateway sharing buffers with an ACE-capable DMA/accelerator | A future external ACE profile would route snoops to a dirty cache owner | Deferred ACE phase; 2 or 4 harts | External DMA can consume stale data if the future snoop proxy is incomplete | REQ-IF-004 | ASM-001, DEP-002 |
| FEAT-006 | Linux gateway retaining shared code/data close to the cores | LLC capacity and cache-line geometry must be fixed before synthesis | 4 ways × 4096 lines/way × 16 bytes = 256 KiB | Wrong geometry or failed writeback can lose data or reduce hit rate | REQ-MEM-002 | User decision, 2026-11-06 |
| FEAT-007 | Gateway performance diagnosis under packet bursts | Software must count selected cluster events and identify overflow | 16 counters default, maximum 32; counter width 32 or 64 bits | Bottlenecks remain hidden or counters silently wrap without status | REQ-PMU-001, REQ-PMU-002 | User decision, 2026-11-06 |
| FEAT-008 | Field debug of a multi-hart Linux gateway | Debugger must identify and stop/resume individual active harts | 2 or 4 hart debug request/status bits | A failure cannot be isolated to one hart or recovered safely | REQ-DBG-001 | User decision, 2026-11-06 |
| FEAT-009 | Firmware configuration of PMU and LLC service functions | One compact control bus must reach both cluster CSRs and LLC control | AXI4-Lite, 32-bit address and data | Firmware requires a second control fabric or cannot inspect cache service state | REQ-IF-001 | User decision, 2026-11-06 |
| FEAT-010 | Network/DMA buffer handoff to non-coherent agents | Software needs per-line CLEAN/FLUSH/INVAL operations and an architectural fault on failed required writeback | 16-byte cache-block operations; precise Store/AMO fault after ABORT ACKs | DMA may read stale memory, or failed writeback may be reported as success | REQ-MEM-015–017 | User decision, 2026-11-07 |
| FEAT-011 | Hart-local self-modifying-code execution in the Linux gateway | A later instruction fetch by the executing hart must see prior stores to code | DcacheFlushOnFenceI=1; dirty D-cache data reaches LLC before local I-cache/fetch invalidation | The hart may execute stale instructions | REQ-MEM-007, REQ-MEM-018 | RISC-V Zifencei REF-013; DEC-030 |

## 2. Normative references and precedence

### 2.1 Normative references

| Ref ID | Document and revision | Applicable clauses | Authority / notes |
|---|---|---|---|
| REF-001 | Arm AMBA AXI and ACE Protocol Specification, IHI 0022H | AXI4-Lite Part B/B1; AXI4 Part A; ACE Part D, especially channels and sequencing | Official Arm PDF read on the web; the user approved use without a local converted copy. No local md_doc conversion exists. |
| REF-002 | IEEE 1800-2017 SystemVerilog | Synthesizable RTL subset | Subject to VLSIT RTL rules and selected frontend support |
| REF-003 | VLSIT RTL Design Rule v2, VLSIT_RTL_Design_Rule.md | All applicable rules | User-selected default rule; source path recorded in Section 20 |
| REF-004 | OpenHW CVA6 configuration cv64a6_imafdc_sv39_hpdcache_wb_config_pkg.sv | Selected configuration values | Exact package name; upstream branch URL in Section 22; source commit must be pinned before RTL integration |
| REF-005 | OpenHW HPDcache User Guide v1.0.1 | Static configuration, cache-line width, interfaces | HPDcache settings are compile-time parameters |
| REF-006 | RISC-V ISA specifications implemented by the selected CVA6 configuration | Privileged and unprivileged architecture behavior; see the official [Machine Interrupt `mip`/`mie` specification](https://docs.riscv.org/reference/isa/priv/machine.html) for writable SSIP/STIP state and external pending-source behavior | Exact ratified revision and enabled extension list must be pinned with the RTL commit |
| REF-007 | RISC-V Debug Specification 0.13.2 | External DM-to-hart integration concepts | DTM/DM implementation is outside this IP |
| REF-008 | PULP axi_llc architecture document | Static geometry, AXI4-Lite service interface, BIST/flush/counters | Runtime SPM controls shall be disabled by this IP |
| REF-009 | CSR_Generation.py v3.4, commit c40f319 | AXI4-Lite CSR generation and field behavior | Local repository C:\HQuan\102_MyGithub\APB-CSR-Generator; canonical bus behavior is generator source/spec, not stale APB-only skill note |
| REF-010 | PULP Culsans repository, current public master as observed 2026-11-06 | CVA6 coherence reference implementation | Pins a PlanV CVA6 fork; not proof of compatibility with upstream CVA6 + HPDcache |
| REF-011 | OpenHW CVA6 CSR performance-counter documentation | Candidate per-hart event names and event IDs | Event availability must be rechecked against the exact selected CVA6 configuration and commit; not a cluster selector map |
| REF-012 | RISC-V Unprivileged ISA, 2024-04-11, CMO Sections 19.3.2, 19.4.2, 19.4, 19.6, 19.7.1–19.7.3 | Clean/flush/invalidate semantics, coherent-agent scope, CBIE behavior, Store/AMO exception class and faulting effective address | [Official RISC-V specification PDF](https://docs.riscv.org/reference/isa/v20240411/_attachments/riscv-unprivileged.pdf) |
| REF-013 | RISC-V Zifencei Extension, Version 2.0, Section 4.1 | Local instruction-fetch synchronization semantics of `FENCE.I` | Official RISC-V ISA documentation; no local converted copy; [official specification](https://docs.riscv.org/reference/isa/unpriv/zifencei.html) |
| REF-014 | RISC-V Privileged Architecture, Machine-Level ISA, Exception Causes | Exception cause codes 24–31 are reserved for custom use; the cluster assigns synchronous exception code 24 to a failed FENCE.I maintenance transfer | [Official RISC-V specification](https://docs.riscv.org/reference/isa/priv/machine.html) |
| REF-015 | PULP AXI width-converter sources `axi_dw_converter.sv`, `axi_dw_upsizer.sv`, and `axi_dw_downsizer.sv` at the pinned local revision | Candidate external 32/64/128/256-bit conversion; source comments document burst limitations | Source is in `rtl/third_party/axi/src`; see Section 22, item 13. Pin and verify the exact revision before signoff. It is implementation evidence, not a protocol guarantee. |

### 2.2 Source-of-truth and conflict handling

Protocol behavior follows REF-001 for the named AXI4, AXI4-Lite, and ACE profiles. Core behavior follows the selected upstream CVA6 configuration and exact pinned source revision. Product-specific behavior follows this specification and explicit user decisions. REF-003 governs newly authored VLSIT RTL; third-party source is retained under its own license and coding conventions rather than silently rewritten. The workbook in Section 11 is the sole authority for software-visible CSR fields and reset values. No register offsets or reset values are defined in this Markdown file.

The ACE standard was approved for web-based use, not local conversion. Therefore protocol clause references in this draft are based on the official PDF source and still require a later controlled-document review before signoff.

**Language:** This specification is bilingual English–Vietnamese per the user’s project-wide instruction for documents. This intentionally overrides skill rule R-005, which otherwise requires English-only specifications; the RTL source and agent skills remain English-only.

**Naming rule:** VLSIT RTL Design Rule v2, selected by the user; path C:\HQuan\102_MyGithub\VLSIT_RTL_Generator_AI_Model\spec_template\VLSIT_RTL_Design_Rule.md; names use m_ module prefix, i_/o_ port prefix, protocol tags such as axi, axil, and ace, PARA_ parameters, and zero-based indices.

Protocol tuân thủ theo REF-001. Hành vi core theo cấu hình CVA6 và commit sẽ được pin. Yêu cầu sản phẩm theo đặc tả này và quyết định của người dùng. REF-003 áp dụng cho RTL VLSIT mới; mã nguồn bên thứ ba giữ license và coding convention riêng, không tự sửa. Workbook ở Mục 11 là nguồn duy nhất cho CSR. Tài liệu ACE được duyệt dùng bản PDF chính thức trên web, chưa chuyển đổi cục bộ; cần kiểm soát tài liệu trước signoff.

### 2.3 Compliance declaration

| Standard | Revision / profile | Role implemented | Options | Deviations |
|---|---|---|---|---|
| AMBA AXI4 / AXI4+ATOP | IHI 0022H | Manager on memory/peripheral egress | 64-bit address/data; native CVA6 ID 4 bits; MMIO ID 6 bits after fixed four-way mux; LLC memory ID 7 bits; 6-bit AWATOP on memory egress; no USER signals in selected profile | Preserve source-derived widths and AWATOP; final optional sidebands follow the pinned interfaces |
| AMBA AXI4-Lite | IHI 0022H, B1 | Subordinate for software control | 32-bit address/data; 4 byte strobes; single clock | Internal address windows and outstanding depths are project-defined |
| AMBA ACE | IHI 0022H, D | Internal local-probe subset only; no external ACE boundary in current phase | Read-shared, read-unique/invalidate, and clean-invalidate outcomes; AC/CR/CD-style channels | Exact packed-field mapping is pinned with source integration; external ACE is deferred |
| RISC-V ISA | Selected CVA6 package | Two/four application harts | XLEN=64, Sv39 configuration, enabled extensions as defined by pinned package | No ISA extension is added by cluster wrapper |

## 3. Requirements and traceability

### 3.1 Normative requirements

| ID | Requirement | Source | Applies to | Verification method |
|---|---|---|---|---|
| REQ-SYS-001 | The cluster shall elaborate with PARA_CPU_NUM equal to 2 or 4, default to 4, and assign active hart indices contiguously from zero. | User decision; DEC-019; Section 8 | Both profiles | Elaboration and hierarchy check |
| REQ-SYS-002 | Every active tile shall use the selected cv64a6_imafdc_sv39_hpdcache_wb configuration unless a new approved spec revision changes it. | User decision; REF-004 | Both profiles | Configuration/package comparison |
| REQ-SYS-003 | The cluster shall provide one shared 64-bit `i_boot_addr` input and connect it to `boot_addr_i` of every active CVA6 hart. The SoC shall hold the value stable while reset is asserted and through reset release. All harts begin at that address; boot software may branch on `mhartid` for per-hart startup. | User decision; DEC-021 | Both profiles | Boot-address fanout and two/four-hart startup test |
| REQ-SYS-004 | The cluster's license-preserving local CVA6 configuration copy shall set `CVA6ConfigCvxifEn=0`. The cluster shall expose no CVXIF accelerator ports; if the pinned source signature retains native CVXIF pins, the licensed integration boundary shall leave them inactive. The pristine upstream configuration shall remain unchanged. | User decision; DEC-022 | Both profiles | Config comparison, elaboration, and inactive-native-pin check |
| REQ-MEM-001 | Every active hart's D-cache shall participate in one internal MESI coherence domain for cacheable shared memory. The current implementation phase shall provide the AXI profile only. | User decisions; DEC-007, DEC-008 | AXI profile, 2/4 harts | MESI state-transition tests, multi-hart litmus, dirty-owner tests, and formal invariants |
| REQ-MEM-005 | The CCU shall use a per-line sharer directory to target only D-caches recorded as possible holders; it shall collect tagged probe status responses and complete every required owner AXI writeback before granting E/S/M. It shall not broadcast every request to all active harts. | User decisions; DEC-007, DEC-013, DEC-027 | AXI profile | Directory-targeting tests, tagged probe/writeback scoreboard, and MESI state checks |
| REQ-MEM-006 | Coherence arbitration shall lock only the target physical cache line: same-line CPU requests shall wait until the current probe/refill transaction resolves; unrelated lines shall remain eligible subject to directory, cache-bank, port, MSHR, CCU, LLC, and AXI resource conflicts. | User decisions; DEC-008, DEC-013 | AXI profile | Same-line collision and independent-line progress tests |
| REQ-MEM-007 | D-cache coherence shall not snoop I-caches. Software that modifies executable memory shall perform the platform-required inter-hart notification and each executing hart shall execute `FENCE.I` before fetching the changed instructions. `FENCE.I` synchronizes only the executing hart's instruction stream; it shall not be treated as a remote-hart broadcast. | User decision; DEC-009; REF-013 | AXI profile | Self-modifying-code integration and per-hart FENCE.I test |
| REQ-MEM-008 | The directory shall never omit an active D-cache that may hold a line. A stale extra sharer bit may cause a harmless probe, which shall be reconciled; a missing sharer bit shall not permit stale data or conflicting ownership. Directory metadata shall be committed only with the corresponding cache-state transition. | User decision; DEC-013; exact update handshakes are implementation detail | AXI profile | Directory invariant assertions and cache/directory refinement checks |
| REQ-MEM-009 | The CCU shall support `PARA_COH_TXN_NUM` active coherence transactions, default 8 and legal from 2 through 16. Every active transaction shall have a slot-derived tag unique among active entries. Probe/response traffic shall carry that tag and target hart identity; a tag shall not be reused until all prepare/commit/abort responses for the previous use have drained. | User decisions; DEC-013, DEC-015 | AXI profile | 2/8/16-slot elaboration, tag reuse, backpressure, and response-reordering tests |
| REQ-MEM-010 | The sharer directory shall be independent of and non-inclusive with the LLC, use four banks and eight ways, and contain `PARA_CPU_NUM × 2,048` entries: 4,096 for two harts and 8,192 for four harts. LLC eviction alone shall not invalidate a private D-cache line. A directory replacement with active holders shall prepare targeted invalidations and complete any M-owner writeback before replacing the entry. | User decisions; DEC-014, DEC-027 | AXI profile | Directory geometry, LLC-eviction independence, full-set replacement, owner-writeback and dirty-victim tests |
| REQ-MEM-011 | The directory shall select one of four banks using the two least-significant bits of the line address, equivalent to physical-address bits `[5:4]` for the selected 16-byte line (`line_addr[1:0] = physical_address[5:4]`); each bank shall arbitrate one operation per cycle, allowing different-bank operations to proceed concurrently and serializing same-bank conflicts. Each private D-cache shall queue up to `PARA_COH_TXN_NUM` probes and service one probe at a time. | User decisions; DEC-014, DEC-015 | AXI profile | Bank-conflict, cross-bank overlap, and per-cache probe queue tests |
| REQ-MEM-012 | A coherence probe shall use two phases. PREPARE locks the target line, waits for same-line miss/refill completion, and reports the stable MESI state without changing stable MESI state. If the target is M, it shall write the complete 16-byte line to the LLC through that hart's existing HPDcache AXI path; the cache shall retain M and the line lock until COMMIT or ABORT. PREPARE ACK shall wait for the matching LLC B response. A B error fails PREPARE, triggers ABORT for every prepared target, and shall not update the directory or grant the requester. The probe response carries writeback completion/status, not the 128-bit line payload. After all required PREPARE responses and writebacks succeed, COMMIT applies the target state and returns an acknowledgement. The CCU shall update directory metadata and grant permission only after every required COMMIT acknowledgement. A permission grant admits the requester's normal HPDcache refill; CPU completion follows refill. | User decisions; DEC-016, DEC-027 | AXI profile | Prepare-state invariants, owner AXI writeback/B response, B-error ABORT, commit ordering, and concurrent-line tests |
| REQ-MEM-013 | PREPARE, COMMIT, and ABORT have no acknowledgement timeout. The CCU shall retain the line lock and transaction slot until every required phase ACK arrives or reset occurs. During PREPARE wait, stable cache MESI and directory metadata remain unchanged; no COMMIT, requester grant, or directory update may occur. A pre-COMMIT error sends ABORT to every targeted cache; caches release their local line locks only after accepting ABORT and preserve their pre-transaction stable state. During COMMIT wait, no rollback is allowed; the directory remains unchanged and the requester is not granted until all COMMIT ACKs arrive. A missing ACK can stall that line indefinitely. Independent lines may progress only with independent slots and resources. Reset clears cache and directory valid state and is the only recovery. Repeated COMMIT with the same tag is idempotent. | User decisions; DEC-016, DEC-018; reset contract | AXI profile | Missing PREPARE/COMMIT/ABORT ACK, independent-line progress, and reset-recovery tests |
| REQ-MEM-014 | Each directory bank shall select only eligible transaction slots using round-robin arbitration and expose a registered `valid/ready` grant that remains stable while not ready. An ineligible request shall not occupy that grant. A matching reservation-owner terminal update/cancel shall not be blocked by another slot's ineligible request, as detailed in REQ-MEM-019. The priority pointer resets to slot 0 and advances to the slot after an accepted grant. Each bank accepts at most one grant per cycle; independent banks may grant concurrently. Each 8-way set stores seven tree-PLRU bits, reset to zero; victim-walk bit 0 selects the left child and bit 1 the right child. A committed access/allocation updates each traversed bit away from the accessed way. Select the lowest-index invalid way before replacement; a full set follows the seven-bit tree. If the victim is locked/reserved or cannot obtain a transaction context, keep that request pending and allow other eligible bank operations to proceed. | User decision; DEC-020/032 | AXI profile | Round-robin fairness, stable eligible grant under backpressure, owner terminal escape, PLRU and cross-bank tests |
| REQ-MEM-015 | Zicbom cache-block operations shall be routed through the cluster CMO controller and serialized by the shared CCU line lock. `CBO.CLEAN` shall write any dirty L1 owner line through the owner's HPDcache AXI path, then clean the matching LLC line to external memory; retain valid copies and change the sole M owner to E only after both writebacks succeed. `CBO.FLUSH` shall perform the same clean-to-memory sequence, then invalidate all matching L1 D-cache copies and the LLC copy only after successful memory B response. `CBO.INVAL` shall follow CVA6's CBIE-decoded operation: a true invalidate locks and invalidates matching L1 and LLC copies without writeback, including discarding dirty copies at commit; when decoded as flush, it follows `CBO.FLUSH`. True-invalidate PREPARE shall not issue owner writeback. An LLC CMO miss shall not allocate/refill a line. | User decisions; DEC-028; RISC-V CMO rules REF-012 | AXI profile | All op × L1/LLC hit-state × dirty-state combinations, DMA-visibility sequence, per-line lock and MESI/directory refinement |
| REQ-MEM-016 | The LLC shall provide a per-line maintenance service with tag lookup, same-line exclusion, clean, and invalidate operations. A clean shall retain the valid tag and clear dirty only after successful full-line AXI writeback; invalidate shall clear the tag only at its specified commit point. Any non-OKAY memory B response shall be returned to the CMO controller and shall leave the LLC valid/dirty/tag state unchanged. If the L1 M owner has already supplied the line to the LLC, that owner shall retain M and its line lock until CMO commit/abort; a later memory error shall not update the directory or invalidate the L1 copy. | User decision; DEC-028; pinned `axi_llc` source audit | AXI profile | AXI B error injection at owner and LLC writeback; tag/data preservation; no premature invalidation; retry test |
| REQ-MEM-017 | A CBO instruction shall remain at the CVA6 retirement head until the complete CMO succeeds or its error recovery finishes; younger instructions shall not retire past it. On success, retire the CBO exactly once. If a writeback-required operation (`CBO.CLEAN`, `CBO.FLUSH`, or `CBO.INVAL` decoded as flush) receives an owner/LLC writeback error, preserve recoverable cache state, wait for every required ABORT acknowledgement, suppress CBO retirement, and raise a precise synchronous Store/AMO access-fault exception (`mcause/scause` exception code 7) with the CBO's original effective address in `mtval`/`stval` and its instruction PC in `mepc`/`sepc`. A true invalidate does not write back and has no writeback B-error path. The local CVA6 integration shall propagate CMO completion/error to commit logic; it shall not treat request acceptance as completion. | User decision; DEC-029; RISC-V CMO trap rules REF-012 | AXI profile | Delayed success/error, no-younger-retire, exact-once retirement, exception cause/PC/tval, ABORT completion, and retry-state checks |
| REQ-MEM-018 | With `DcacheFlushOnFenceI=1`, a local `FENCE.I` shall remain at the retirement head and block younger retirement while the hart's D-cache is scanned. Each dirty M line shall be locked and written through its HPDcache AXI path into the shared LLC; the CCU shall commit the owner from M to E only after successful LLC acceptance and keep the directory holder consistent. `FENCE.I` shall not request LLC-to-external-memory writeback solely for instruction-fetch synchronization. After all required L1-to-LLC transfers complete, invalidate the executing hart's I-cache and fetch pipeline before retiring `FENCE.I`. If an L1-to-LLC B response is non-OKAY, preserve the failed line's M state and directory holder, send ABORT, and wait for every required ABORT acknowledgement without timeout; do not invalidate the local I-cache/fetch pipeline or retire `FENCE.I`. After ABORT completes, raise a precise synchronous custom maintenance exception (exception code 24, `REF-014`) at the `FENCE.I` PC; write the failed physical line's aligned base address to `mtval` or `stval` according to the selected trap privilege. The handler may correct the cause and return to the faulting PC to retry `FENCE.I`. | User decisions; DEC-030/031; selected CVA6 configuration; REF-013/014 | AXI profile | Success and B-error FENCE.I tests; check no younger retirement, ABORT completion before trap, cause/PC/aligned physical line address, failed M/directory preservation, no local fetch invalidation on error, and no LLC-to-DRAM write request |
| REQ-MEM-019 | Each directory bank shall determine whether lookup/update/cancel requests are eligible before arbitration. An update or cancel matching the active set-reservation owner is a terminal operation and shall have an escape path that cannot be blocked by a valid but ineligible request from another transaction. A matching owner cancel shall be accepted and clear that reservation even if another transaction's update remains valid; a matching owner update shall commit and release the reservation. Only one directory operation may be accepted per bank per cycle. Round-robin arbitration shall be fair among continuously eligible transaction slots; when the bank accepts one operation per cycle, a continuously eligible slot shall be selected within one full round of eligible slots. | Review finding CC-01; v0.19 directory liveness contract; DEC-032 | AXI profile | Exact CC-01 reproducer; same-set update/cancel escape; eligible-slot fairness assertions; WF-020 |
| REQ-MEM-020 | The CCU, directory, caches, and AXI writeback path shall obey the resource-ordering contract in Section 10.2.4: no directory bank port or cache tag/data-array port may be held while waiting for an ACK/B response that requires that resource; line locks and transaction contexts may remain held as specified by DEC-018. A cache must not wait for new CCU permission to complete a refill that is itself blocking the probe needed for that permission. | Review finding CC-01; v0.19 resource wait-graph analysis | AXI profile | Formal wait-for graph review; same-line refill/probe stress; resource ownership assertions |
| REQ-MEM-021 | A response receiver shall accept each transport-valid internal probe ACK when its response buffer can accept it, independent of whether its tag/line/phase matches an active context. Only a unique expected response may update transaction state. Stale, duplicate, unknown-tag, wrong-hart, wrong-line, or wrong-phase responses shall be consumed and discarded, shall not modify any transaction/cache/directory state, and shall set the coherence-protocol diagnostic. | Review finding CC-02; v0.19 response-drain contract; DEC-033 | AXI profile | Duplicate/stale/mismatched ACK drain test; confirm a following valid ACK is accepted; diagnostic status test |
| REQ-MEM-022 | Each per-slot bank request shall represent one pending operation token. A bank arbiter shall consume an accepted token exactly once and disarm that slot until it samples `i_req_valid[slot]=0`; a later assertion rearms the slot for a new token. This prevents a delayed VALID deassertion from receiving a duplicate grant. While a grant is stalled, its valid and slot identity shall remain stable, and the request's bank and operation payload shall remain stable. Each bank still accepts at most one token per cycle; different slots may be accepted in adjacent cycles. | Review finding CC-03; v0.19 request-token contract; DEC-035 | AXI profile | Delayed-deassertion/duplicate-grant test; stable grant and rearm assertions |
| REQ-MEM-023 | An active transaction context shall retain its tag, line, requester/owner, transaction kind, target MESI state, phase, expected/received ACK masks, owner-writeback completion/status, and LLC/AXI completion/status until commit/abort is complete and all required responses drain. Starting a new phase shall not clear fields required by later phases. A probe scheduler shall use state associated with the matching context, not an uncorrelated live value. Owner-writeback completion is set only by the matching successful B response; COMMIT shall not proceed after a writeback error. | Review finding CC-03; v0.19 context-retention contract; DEC-027/035 | AXI profile | PREPARE-to-COMMIT/ABORT context-retention test; target-state and B-response association checks |
| REQ-MEM-002 | The shared LLC shall default to 4 ways, 4096 lines per way, 2 64-bit blocks per line, and 16 bytes per line, for 256 KiB total capacity. | User decision; REF-008 | Both profiles | Parameter/elaboration check |
| REQ-MEM-003 | LLC geometry shall be static after synthesis; software shall not change total capacity or enable SPM mode. | User decision; REF-008 | Both profiles | CSR access test and RTL inspection |
| REQ-MEM-004 | LLC BIST and flush requests shall follow the selected axi_llc behavior; traffic shall not be treated as usable until the applicable BIST-ready condition is met. | REF-008 | Both profiles | BIST/flush sequence simulation |
| REQ-IF-001 | The cluster shall expose one 32-bit-address, 32-bit-data AXI4-Lite Subordinate port for cluster CSR and LLC service windows. | User decision; REF-001 | Both profiles | AXI4-Lite protocol checker |
| REQ-IF-002 | The cluster shall expose a non-coherent AXI4 Manager interface for peripheral/device traffic. | User requirement; REF-001 | Both profiles | AXI4 protocol checker and address-attribute tests |
| REQ-IF-003 | The AXI memory profile shall expose AXI4+ATOP memory traffic without external snoop channels; software/SoC shall maintain cache visibility for external DMA. | User decision; DEC-023; REF-001 | AXI top only | ATOP pass-through/atomic response test and DMA visibility review |
| REQ-IF-004 | A future ACE profile may expose external coherent-memory channels after a separate ACE boundary specification and approval; it is not part of the current RTL phase. | Deferred scope decision | Future ACE phase only | Future ACE protocol checker and snoop tests |
| REQ-IF-005 | AXI and ACE source payloads shall remain stable while VALID is high and READY is low, and responses shall be accepted only on VALID and READY handshakes. | REF-001 | Applicable interfaces | Protocol assertions |
| REQ-IF-006 | The current delivery shall expose one fixed-port AXI structural top. Any future ACE top shall be a separate fixed-port module and requires a new approved specification phase. | User scope decision; VLSIT PRT-03 | Current AXI phase | Port-list/elaboration audit |
| REQ-IF-007 | AXI4-Lite writes shall honor WSTRB; aligned unmapped CSR addresses shall return DECERR and reads shall return zero. | REF-009; user-selected CSR generator v3.5 | Both profiles | Generated-CSR protocol simulation |
| REQ-IF-008 | The cluster-local AXI4-Lite aperture shall contain a 4-KiB CSR window at offsets `0x0000–0x0FFF` and a 4-KiB LLC-service window at `0x1000–0x1FFF`; the absolute SoC base is integration-defined and at least 4-KiB aligned. Unassigned offsets are reserved: reads return zero with DECERR and writes have no side effect with DECERR. | Approved CSR workbook; DEC-017 | AXI profile | Window boundary, reserved-offset, and base-alignment tests |
| REQ-IF-009 | The AXI memory output shall preserve the 6-bit AWATOP field from the LLC. The SoC integration shall connect it to an AXI4+ATOP-capable memory path or place a verified atomic-service bridge before a fabric that lacks ATOP. The bridge shall execute the supported atomic operation at the memory serialization point and preserve ID/response/error association. A filter that returns SLVERR is not an atomic bridge. | User decision; DEC-023; pinned PULP `axi_llc` and HPDcache sources | AXI profile | LR/SC and AMO end-to-end atomicity test; unsupported-fabric integration check |
| REQ-IF-010 | LLC-service accesses in local window `0x1000–0x1FFF` shall pass through a new VLSIT AXI4-Lite-to-RegBus bridge to the unchanged pinned LLC register interface. AXI AW and W may handshake independently; the bridge shall issue one complete write only after both are captured and shall return the matching response. | User decision; DEC-024; `axi_llc_reg_wrap` source audit | AXI profile | Independent AW/W order, backpressure, response association, and error tests |
| REQ-IF-011 | One synthesis-time address-region table shall be the source of truth for both the cluster router and CVA6 PMA attributes. The adapter shall derive CVA6 `CachedRegion*` entries only from class `00` and `NonIdempotent*` entries only from class `10`; class `01` remains idempotent and uncached by being outside both lists. It shall support one cacheable normal-memory entry (default base `0x80000000`, size 1 GiB), plus configurable normal-uncached and MMIO entries, up to 16 total. Cacheable and normal-uncached requests shall use the memory path; normal-uncached traffic shall bypass LLC allocation. MMIO shall bypass CCU/LLC. Entries shall be non-overlapping, 16-byte aligned, and confined to PLEN=56. Unmatched or boundary-crossing accesses shall receive a local error without external AXI traffic. The default table shall contain only the cacheable entry; the SoC supplies uncached/MMIO entries. | User decision; DEC-037; selected CVA6 PMA capacity and LLC mapping | AXI profile | TEST-051, PMA/router parity, overlap/boundary/error tests |
| REQ-PMU-001 | The cluster PMU shall support PARA_PMU_COUNTER_NUM counters, legal range 1–32 and default 16. | User decision, 2026-11-06 | Both profiles | Parameter-boundary elaboration |
| REQ-PMU-002 | PMU counter width shall be configurable as 32 or 64 bits; the proposed default is 64 bits. Counters shall wrap modulo 2^W. | User decision; default tracked in Section 20 | Both profiles | Counter boundary simulation |
| REQ-PMU-003 | A software snapshot request shall capture all PMU counters and keep the snapshot stable until the next accepted snapshot request or reset. | User decision, 2026-11-06 | Both profiles | Snapshot and concurrent increment test |
| REQ-PMU-004 | PMU overflow causes shall be sticky and software-visible; one aggregate level interrupt shall remain asserted while any enabled pending cause remains. | User decision, 2026-11-06 | Both profiles | Overflow, mask, clear, and interrupt tests |
| REQ-PMU-005 | Every PMU counter shall select either one active hart (scope 0–3), all active harts (scope 4), or a cluster-global event (scope 5); scopes 6–7 are reserved. | User decision, 2026-11-06 | Both profiles | Scope encoding, 2/4-hart and event-source tests |
| REQ-PMU-006 | Aggregate per-hart events shall add the number of occurrences across active harts in each cycle; simultaneous events from four harts increment the selected counter by four. | User decision, 2026-11-06 | Both profiles | Multi-hart simultaneous-event scoreboard |
| REQ-PMU-007 | The 16-bit `event_id` shall use the fixed source ranges and complete source mapping in workbook `Event_Map`: CVA6 `0x0001–0x0016`, HPDcache `0x0100–0x010F`, LLC `0x0200–0x0217` and `0x0240–0x0243`, and VLSIT CCU `0x0300–0x030B`. The workbook is the selector-code source of truth. Unknown/reserved IDs, disabled SPM events, unavailable sources, and invalid scope/source combinations shall contribute zero. | User decision; DEC-025; pinned source audit | AXI profile | Exact ID/source scoreboard; reserved and unavailable ID tests |
| REQ-PMU-008 | Per-hart event sources shall expose one sampled indicator per hart; scope 0–3 selects one active hart and scope 4 sums indicators across active harts. For scope 5, CCU transaction/handshake IDs `0x0300–0x0307` and `0x030B` shall count actual occurrences each cycle, up to four, using 3-bit taps. CCU stall IDs `0x0308–0x030A` shall count one per cycle while asserted. Each single-instance LLC event field contributes one when `.active` is high; `.num_bytes` is not accumulated. CVA6 sources that OR-reduce commit ports contribute at most one per hart per cycle. | User decision; DEC-026; pinned CVA6, HPDcache, and LLC source semantics | AXI profile | Multi-occurrence CCU, held-stall, descriptor, aggregate, counter increment, and wrap tests |
| REQ-DBG-001 | The cluster shall expose per-hart debug request and debug-mode/status connections; the DTM and Debug Module shall remain outside the cluster. | User decision; REF-007 | Both profiles | Hart-by-hart debug integration test |
| REQ-IRQ-001 | Platform interrupt inputs shall be level-sensitive and routed only to the addressed active hart; inputs for absent harts shall be ignored. | Proposed interface contract; ASM-004 | Both profiles | Directed interrupt routing tests |
| REQ-IRQ-002 | For each active hart, `i_int_ssip` and `i_int_stip` shall be ORed with the corresponding software-writable `mip` state to form the effective pending view used by interrupt logic and CSR reads. External levels shall not be copied into software-writable state by CSR read-modify-write operations. Gate SSIP with `RVS && SoftwareInterruptEn` and STIP with `RVS`. | REF-006; selected CVA6 configuration | Both profiles | Assert/deassert each external level; verify MIP/SIP visibility, interrupt delivery, software clear/set, and no sticky state after external deassertion |
| REQ-CLK-001 | All cluster AXI/ACE/AXI4-Lite ports and internal active harts shall use the cluster clock unless a separately specified CDC bridge is inserted outside the cluster. | Integration assumption | Both profiles | CDC analysis and clock-domain lint |
| REQ-RST-001 | Reset shall clear valid/control state and reset all generated CSR fields to workbook reset values; SoC shall provide synchronized deassertion to the cluster clock. | Proposed interface contract; ASM-005 | Both profiles | Reset assertion/release tests |
| REQ-ERR-001 | AXI/ACE error responses shall be returned to the originating request path without changing the transaction ID or fabricating successful data. | REF-001 | Applicable interfaces | Error injection and response association tests |
| REQ-ERR-002 | An unsupported or malformed internal address/control request shall not silently alter architectural cache or CSR state. | Product requirement | Both profiles | Negative tests and assertions |
| REQ-ERR-003 | An ordinary dirty-eviction writeback failure shall preserve recoverable dirty data and retain the affected transaction/line lock until reset. It shall assert a sticky asynchronous `o_int_fault` and expose an associated CSR fault record. Already issued AXI responses shall still be drained; no successful completion, automatic retry or retroactive precise exception at an already retired store shall be fabricated. Reset is the recovery. CBO and FENCE.I retain REQ-MEM-017/018. | User selected asynchronous fault, DEC-036 | AXI profile | TEST-050 |
| REQ-PD-001 | The cluster shall not claim a frequency, area, or power limit until a library, PVT corner, SDC, and activity workload are supplied. | User decision | Both profiles | Review of constraints and reports |
| REQ-VER-001 | Verification shall derive expected behavior from this specification, RISC-V architectural models, and the applicable protocol standards; generated RTL shall not be the golden reference. | User direction from prior verification-flow decision | Both profiles | Verification-plan review |
| REQ-VER-002 | Each supported CPU-count/profile combination shall have an independent reproducible test target and saved command/log manifest. | Project verification policy | Both profiles | Build-flow audit |

### 3.2 Requirement change control

A change to core package, line size, memory profile, CSR behavior, or supported ACE subset requires a new spec version and traceability review. Requirements that depend on an unproven adapter remain conditional until the adapter architecture is verified; they are not evidence that such an adapter already exists.

Nếu thay core package, line size, memory profile, CSR behavior hoặc tập ACE hỗ trợ thì phải tăng version và rà soát truy vết. Yêu cầu phụ thuộc adapter chưa được chứng minh sẽ giữ trạng thái có điều kiện, không được hiểu là adapter đã tồn tại.

## 4. Features and configurations

| Configuration ID | Enabled features | Disabled features | Interfaces / widths | Intended use | Verification target |
|---|---|---|---|---|---|
| CFG-AXI-2 | 2 CVA6 harts; internal coherence; LLC; PMU; debug hooks | External snoop/coherence; SPM | AXI4 mem 64/64, AXI4 MMIO 64/64, AXI4-Lite 32/32 | Two-hart Linux SMP with software DMA cache maintenance | 2-hart AXI profile |
| CFG-AXI-4 | 4 CVA6 harts; internal coherence; LLC; PMU; debug hooks | External snoop/coherence; SPM | Same fixed widths and port names | Four-hart Linux SMP with software DMA cache maintenance | 4-hart AXI profile |
| CFG-ACE-2 | 2 CVA6 harts; internal coherence; LLC; ACE external coherence; PMU | SPM; runtime profile switch | ACE memory 64/64 plus AXI4 MMIO 64/64 and AXI4-Lite 32/32 | Two-hart cluster sharing cacheable memory with external ACE agents | 2-hart ACE profile |
| CFG-ACE-4 | 4 CVA6 harts; internal coherence; LLC; ACE external coherence; PMU | SPM; runtime profile switch | Same fixed widths and port names | Four-hart cluster sharing cacheable memory with external ACE agents | 4-hart ACE profile |

The two top module port lists are structurally distinct: the AXI top has an AXI4 memory port and no ACE snoop ports; the ACE top has one ACE memory port and no parallel AXI memory port. The AXI4 MMIO and AXI4-Lite control ports are present in both. CPU-count selection changes the number of synthesized tiles, not top-level port names; interrupt/debug vectors stay four bits wide and bits 3:2 are ignored in a two-hart build.

Hai profile bộ nhớ là các top module riêng có port list cố định: top AXI có AXI4 memory và không có cổng snoop ACE; top ACE có một ACE memory và không có AXI memory song song. AXI4 MMIO và AXI4-Lite có trong cả hai. Cấu hình số hart chỉ đổi số tile synthesis; vector interrupt/debug luôn rộng bốn bit, bit 3:2 không dùng khi build hai hart.

## 5. Architecture

### 5.1 Overview and block responsibilities

| Block | Responsibility | Inputs / outputs | Clock/reset domain | State or storage |
|---|---|---|---|---|
| Structural profile top | Fixed-port shell for AXI or ACE profile | All cluster interfaces | CLK-CLUSTER / RST-CLUSTER | No functional state |
| CPU tile array | PARA_CPU_NUM identical CVA6 + private I/D cache tiles | Interrupts, debug, private cache requests | CLK-CLUSTER / RST-CLUSTER | Core, TLB, L1 state |
| Internal coherence fabric / CCU | Allocates tagged transactions, consults the independent sharer directory, targets recorded D-cache holders, runs two-phase probes, and routes non-cacheable device requests to MMIO | Tile cache requests/responses, tagged local prepare/commit/abort channels, directory requests, device requests | CLK-CLUSTER / RST-CLUSTER | 2–16 transaction contexts, per-line locks, prepare/commit tracking, owner-writeback completion and recovery state |
| Coherence transaction table | Holds independent line transactions and their requester, tag, target MESI state, phase/ACK masks, dirty-owner writeback status, LLC status, and completion/error state through final release | Tile requests, directory, probe scheduler, LLC request/response | CLK-CLUSTER / RST-CLUSTER | `PARA_COH_TXN_NUM` entries; default 8, legal 2–16; tag derives from slot index |
| Sharer directory | Independently tracks D-cache holders; four banks permit independent-bank work while same-bank conflicts serialize | Transaction table, tagged probes, committed cache fill/eviction/invalidation events | CLK-CLUSTER / RST-CLUSTER | 8-way; 4,096 entries for 2 harts or 8,192 for 4 harts; non-inclusive of LLC |
| Modified HPDcache D-cache boundary | Adds MESI state and accepts/returns tagged probes while preserving correct same-line ordering with CPU misses/refills; permits distinct-line progress when local ports and MSHRs allow | CPU requests, tagged CCU probes, LLC refill/writeback | CLK-CLUSTER / RST-CLUSTER | Data/tag arrays, MSHRs/write buffer, MESI stable/transient state, probe response association |
| ACE proxy (future ACE profile only) | Converts external ACE snoops/transactions to supported local cache probes | Deferred with external ACE profile | Not in current RTL scope | Not in current RTL scope |
| Shared axi_llc | Shared static 256-KiB last-level cache, BIST, flush, counters | Coherent path and memory egress | CLK-CLUSTER / RST-CLUSTER | SRAM tags/data and transaction state |
| AXI4 MMIO router | Routes non-cacheable device transactions | Coherence-fabric device requests and AXI4 output | CLK-CLUSTER / RST-CLUSTER | Outstanding response association |
| AXI-Lite decoder and CSR | Routes cluster PMU/management CSR accesses and LLC service accesses within separate 4-KiB local windows | AXI4-Lite input | CLK-CLUSTER / RST-CLUSTER | CSR state and address decode; unassigned offsets are reserved |
| Cluster PMU | Selects and counts cluster event sources; snapshots counters; creates IRQ | Events from harts/cache/fabric | CLK-CLUSTER / RST-CLUSTER | 1–32 counters and snapshot bank |
| External debug adapter | Routes halt/resume request/status per hart | External DM and CPU debug pins | CLK-CLUSTER / RST-CLUSTER | Minimal synchronizing/control state |

The selected parts are references, not evidence of direct compatibility. Culsans currently documents a coherent cache integration and pins a different PlanV CVA6 fork; the selected upstream OpenHW configuration uses HPDcache. Its D-cache lacks the required external probe port, so this design modifies a separate HPDcache source copy and adds CCU/tile integration. The upstream clone remains unchanged. The current RTL phase is the internal-coherence AXI profile; external ACE support is deferred.

Các IP được chọn là nguồn tham khảo, chưa chứng minh có thể ghép trực tiếp. Culsans ghim một fork CVA6 của PlanV; cấu hình OpenHW upstream được chọn lại dùng HPDcache. D-cache này chưa có probe port cần thiết, vì vậy thiết kế phải sửa một bản sao HPDcache riêng và bổ sung tích hợp tile/CCU. Bản clone upstream được giữ nguyên. Giai đoạn RTL hiện tại là profile AXI có coherence nội bộ; hỗ trợ ACE bên ngoài được hoãn.

### 5.2 Block diagram

**CFG-AXI profile:** internal coherence with AXI4+ATOP memory egress and ordinary AXI4 MMIO; external agents require the software cache-maintenance contract.

![CFG-AXI cluster architecture](figures/VLSIT_RISCV_CLUSTER_AXI.svg)

[Editable AXI-profile draw.io source](figures/VLSIT_RISCV_CLUSTER_AXI.drawio).

**Future CFG-ACE profile (deferred):** would add an external ACE snoop boundary through a separately specified proxy. It is not included in the current RTL scope.

![CFG-ACE cluster architecture](figures/VLSIT_RISCV_CLUSTER_ACE.svg)

[Editable ACE-profile draw.io source](figures/VLSIT_RISCV_CLUSTER_ACE.drawio).

**Cấu hình CFG-AXI:** coherence nội bộ, memory egress dùng AXI4 thường; agent ngoài cần tuân thủ quy trình cache-maintenance của phần mềm.

**Cấu hình CFG-ACE trong tương lai (đã hoãn):** có thể bổ sung giao tiếp snoop ACE bên ngoài sau khi có đặc tả proxy riêng. Cấu hình này không thuộc phạm vi RTL hiện tại.

#### Level-2 subsystem diagrams / Sơ đồ phân rã subsystem cấp 2

Each page expands one cluster subsystem by one architectural level. The detailed draw.io source contains the editable block-function and interface tables. `REUSE*` marks an upstream module that is a reuse candidate pending exact commit, port, and configuration checks. `MODIFY` marks source adaptation or a VLSIT wrapper/macro binding. `NEW` is VLSIT logic to design. `GENERATED` is CSR RTL produced after the workbook is reviewed and approved. Dashed boxes indicate that this is a document-grounded proposal, not an integrated RTL hierarchy.

Mỗi trang mở rộng một subsystem thêm một cấp kiến trúc. File draw.io có thể sửa chứa các bảng chức năng khối và giao diện. `REUSE*` là module upstream có thể tái sử dụng sau khi chốt commit, cổng và cấu hình. `MODIFY` là phần cần điều chỉnh nguồn hoặc viết wrapper/gắn macro. `NEW` là logic VLSIT cần thiết kế. `GENERATED` là RTL CSR sinh từ workbook được duyệt. Khung nét đứt thể hiện đây là kiến trúc đề xuất từ tài liệu, chưa phải hierarchy RTL đã tích hợp.

[Editable seven-page draw.io source / File draw.io bảy trang](figures/detail_level2/VLSIT_RISCV_CLUSTER_DETAIL_LEVEL2.drawio).

**CPU tile / Tile CPU**

![CPU tile internals](figures/detail_level2/01_tile_preview.svg)

[Editable detail page](figures/detail_level2/VLSIT_RISCV_CLUSTER_DETAIL_01_TILE.drawio).

**Directory-based coherence and MMIO routing / Coherence dùng directory và định tuyến MMIO**

![Directory-based MESI coherence and MMIO routing](figures/detail_level2/VLSIT_RISCV_CLUSTER_DETAIL_02_COHERENCE_DIRECTORY.svg)

[Editable detail page](figures/detail_level2/VLSIT_RISCV_CLUSTER_DETAIL_02_COHERENCE_DIRECTORY.drawio).

The selected design uses an independent, non-inclusive sharer directory with a transaction table and tagged two-phase probe tracking. It has four banks and eight ways. The directory holds 4,096 entries in a two-hart build (8 ways × 512 sets) and 8,192 entries in a four-hart build (8 ways × 1,024 sets), matching the aggregate D-cache line capacity. Directory bank is selected by the two least-significant line-address bits; for a 16-byte line, `line_addr[1:0]` is physical-address `[5:4]` (not physical-address `[1:0]`). Each bank grants at most one eligible directory operation per cycle using round-robin arbitration across eligible transaction slots; different banks may progress concurrently. `PARA_COH_TXN_NUM` defaults to 8 and is legal from 2 through 16; tag width is derived from the slot count and tags are not reused until all responses drain. Each D-cache can queue up to one probe per active transaction and services one probe at a time. These choices enable independent miss/probe work to overlap when resources allow; they do not establish an IPC or throughput target.

Thiết kế dùng sharer directory độc lập, không inclusive với LLC, cùng transaction table và probe hai pha có tag. Directory có bốn bank, tám way. Bản hai hart có 4.096 entry (8 way × 512 set); bản bốn hart có 8.192 entry (8 way × 1.024 set), bằng tổng số line của các D-cache. Hai bit thấp nhất của địa chỉ line chọn bank; với line 16 byte, `line_addr[1:0]` tương ứng bit địa chỉ vật lý `[5:4]`, không phải `[1:0]`; xung đột cùng bank phải tuần tự, các bank khác có thể chạy đồng thời. `PARA_COH_TXN_NUM` mặc định 8, hợp lệ từ 2 đến 16; độ rộng tag suy ra từ số slot và tag không được tái sử dụng khi response cũ chưa kết thúc. Mỗi D-cache có thể xếp hàng tối đa một probe cho mỗi transaction đang active nhưng chỉ phục vụ một probe tại một thời điểm. Cấu hình cho phép chồng lấp miss/probe khi đủ tài nguyên, không cam kết IPC hay thông lượng.

**Shared LLC / LLC chia sẻ**

![Shared LLC datapath](figures/detail_level2/03_llc_preview.svg)

[Editable detail page](figures/detail_level2/VLSIT_RISCV_CLUSTER_DETAIL_03_LLC.drawio).

**AXI4-Lite control and CSR / Điều khiển AXI4-Lite và CSR**

![Control and CSR routing](figures/detail_level2/04_control_preview.svg)

[Editable detail page](figures/detail_level2/VLSIT_RISCV_CLUSTER_DETAIL_04_CONTROL.drawio).

**Cluster PMU / PMU cụm**

![Cluster PMU internals](figures/detail_level2/05_pmu_preview.svg)

[Editable detail page](figures/detail_level2/VLSIT_RISCV_CLUSTER_DETAIL_05_PMU.drawio).

**Per-hart debug routing / Định tuyến debug từng hart**

![Per-hart debug routing](figures/detail_level2/06_debug_preview.svg)

[Editable detail page](figures/detail_level2/VLSIT_RISCV_CLUSTER_DETAIL_06_DEBUG.drawio).

**External ACE coherence / Coherence ACE bên ngoài**

![ACE coherence boundary](figures/detail_level2/07_ace_preview.svg)

[Editable detail page](figures/detail_level2/VLSIT_RISCV_CLUSTER_DETAIL_07_ACE.drawio).

### 5.3 Transaction and dataflow

1. A D-cache hit is served locally when its MESI state permits the operation. A D-cache miss or request for write ownership allocates a transaction context and physical-line lock; the CCU looks up that line's sharer directory entry.
2. The directory supplies the candidate holder set. The CCU sends tagged probes only to recorded active D-caches and collects one matching status response per target. If a target is M, that owner writes the full 16-byte line through its existing HPDcache AXI writeback path; the CCU waits for the matching AXI B response before accepting PREPARE. The owner retains M and its line lock until COMMIT or ABORT. After permission is granted, the requester's HPDcache refills the current line through its normal path; an LLC miss causes an AXI4 memory transaction. The LLC must be current before a shared handoff completes.
3. A read miss with no recorded holder may receive E permission; a read miss with existing clean/dirty holders receives S permission after required probe, writeback, and COMMIT actions; a write/AMO request receives M permission only after all other recorded holders are invalidated. Permission grant is not CPU completion: the requester's HPDcache performs the refill, and a same-line probe waits for an admitted refill to stabilize. The directory update and permission grant must describe the same committed ownership state.
4. At least two distinct-line coherence transactions may remain active. Their tags associate probes, data, directory results and responses with the correct requester. Same-line requests serialize under one line lock; different lines can overlap only when directory, cache, LLC, and AXI resources permit.
5. A directory bank reservation is logical state, not ownership of its physical array port. The array port is used only to accept a directory operation; it is released before the CCU waits for probe ACKs, owner writeback, or LLC/AXI completion. The matching reservation owner's terminal update/cancel must remain serviceable even while other requests are blocked.
6. The resource order is: allocate a transaction context, acquire the physical-line lock, perform short directory operations, acquire target-cache line locks, and perform required owner writeback. Do not retain a directory array port or cache tag/data-array port while waiting for a downstream ACK/B response. An already granted refill may finish to a stable point before a same-line probe; a refill that has not received permission is not a directory holder and must not block the probe that would grant permission.
7. Response channels must be able to drain out-of-window acknowledgements. A stale or duplicate response is discarded and diagnosed; it cannot occupy a response slot ahead of a later valid acknowledgement.
8. The current AXI profile does not snoop external agents. External DMA requires software/system cache maintenance. External ACE transactions are deferred to a future profile.
9. Device accesses are classified as non-cacheable and bypass the coherent cache/LLC allocation path to the AXI4 MMIO manager.
10. Software accesses cluster management through AXI4-Lite. The address decoder selects cluster CSR or the axi_llc service target; LLC SPM control remains disabled.
11. PMU event selectors count only implemented sources. The snapshot command freezes a coherent counter image. Overflow cause state drives one aggregate PMU interrupt.
12. External Debug Module requests are routed per hart. Debug transport and DMI stay outside the cluster.

Cache hit được phục vụ tại D-cache nếu trạng thái MESI cho phép. Cache miss hoặc yêu cầu quyền ghi cấp một transaction context và khóa physical line, sau đó CCU tra sharer directory. Directory xác định các cache có thể giữ line; CCU chỉ gửi probe có tag tới các cache đó và ghép response trạng thái theo tag. Nếu holder ở M, chính HPDcache của owner writeback đủ 16 byte qua AXI hiện có; CCU đợi AXI B response tương ứng trước khi chấp nhận PREPARE. Owner giữ M và line lock đến COMMIT hoặc ABORT. Sau permission grant, HPDcache của requester refill line hiện hành qua path bình thường; LLC miss đi ra AXI4. LLC phải được cập nhật trước khi hoàn tất chia sẻ. Read miss không có holder có thể nhận quyền E; read miss có holder nhận quyền S sau probe, writeback và COMMIT; write/AMO chỉ nhận quyền M sau khi invalidate các holder khác. Permission grant không phải CPU completion: HPDcache requester thực hiện refill, probe cùng line phải chờ refill được chấp nhận ổn định. Tối thiểu hai transaction trên hai line khác nhau có thể cùng hoạt động, nhưng tiến triển phụ thuộc directory/cache/LLC/AXI. Profile AXI không snoop agent ngoài; DMA cần cache maintenance. Truy cập thiết bị bypass cache/LLC tới AXI4 MMIO. AXI4-Lite chọn CSR cụm hoặc service axi_llc. PMU hỗ trợ snapshot và IRQ tổng hợp. Debug Module/DTM ở ngoài cluster.

Reservation directory là trạng thái logic; cổng đọc/ghi mảng được nhả sau mỗi thao tác được nhận, không giữ trong lúc đợi probe hoặc AXI response. Phân xử loại request không đủ điều kiện trước khi chọn grant, để update/cancel của đúng chủ reservation luôn có lối thoát. Response ACK sai tag được nhận rồi bỏ và báo lỗi, không chặn ACK hợp lệ đến sau.

### 5.4 Invariants

- Active hart IDs are unique and zero-based within this cluster.
- A line in M has exactly one owner and may be newer than LLC/memory; a read or ownership grant cannot bypass that owner.
- E and M are exclusive states; S may exist in multiple active D-caches and is clean with respect to the LLC.
- A requester may enter E only after all peer probes report no copy; it may enter M only after all peer copies are invalidated and all dirty-data obligations are complete.
- Every accepted probe is answered exactly once. A probe does not release its target-line lock before its required status response and, for an M owner, the full-line AXI writeback B response complete.
- A probe to one line shall not globally stall unrelated lines; actual parallel progress remains limited by cache ports, bank conflicts, MSHRs, CCU capacity, and AXI arbitration.
- AXI-only memory is not system-coherent with external DMA. A coherent alias and non-coherent alias to the same physical line are prohibited unless the SoC defines and verifies a maintenance protocol.
- Internal probe status is associated with the probed `(tag, hart, line)` and cannot be dropped under backpressure. Dirty-line data travels only through the owner's existing AXI writeback path, with its AXI response associated back to that probe.
- Directory state may contain a stale extra holder indication only if it is resolved by a tagged probe; it shall never omit a cache that can return a valid or dirty line.
- A directory entry shall not be discarded while any private D-cache can hold the line. An LLC/directory replacement shall first resolve all recorded sharers, or use separately retained directory storage.
- Every active transaction tag is unique within the active transaction table. A response with an inactive or mismatched tag shall not update cache state, directory state, or another transaction's completion state.
- At least two transactions to distinct lines may be active; same-line requests remain serialized by the physical-line lock.
- LLC capacity and SPM policy do not change at runtime.
- AXI4-Lite responses remain associated with one accepted read/write request; unmapped windows do not update CSR state.
- PMU snapshot reads are stable while active. Counter source selection is valid only for implemented event encodings.
- Signals for absent harts are ignored in two-hart builds.
- A blocked directory request cannot hold a bank arbitration grant. A terminal update/cancel with the matching reservation tag can release or commit that reservation even when another transaction's valid request is ineligible.
- No directory bank port or cache tag/data-array port is held while waiting for a remote probe acknowledgement or AXI response. Transaction contexts and physical-line locks may remain allocated during the wait under DEC-018.
- Stale, duplicate, or mismatched probe responses are drained without changing active state; the next valid response remains receivable.
- Each bank request token is accepted at most once; a slot must be observed low before it can be granted again. Transaction fields needed across phases remain valid until the whole context is released.


Các bất biến: hart ID duy nhất, bắt đầu từ 0; M có đúng một owner và dữ liệu M có thể mới hơn LLC/bộ nhớ; E/M là exclusive, S là clean và có thể nằm ở nhiều D-cache; chỉ cấp E/S/M sau khi hoàn tất probe và writeback bắt buộc. Directory không được bỏ sót cache holder; stale bit thừa phải được giải quyết bằng probe. Không xóa directory entry khi cache riêng còn giữ line. Mỗi transaction tag chỉ thuộc một yêu cầu đang hoạt động; response sai tag không được cập nhật trạng thái. Dirty data chỉ đi qua AXI writeback của owner; PREPARE ACK phải chờ B response đúng line/tag. Ít nhất hai transaction trên line khác nhau có thể hoạt động; cùng line phải khóa riêng. Backpressure không được làm mất probe, writeback hoặc status. Profile AXI không coherence với DMA ngoài; không dùng alias cacheable/non-cacheable cùng line khi chưa có quy trình maintenance; LLC/SPM không đổi lúc chạy; CSR/PMU snapshot không bị trộn; tín hiệu hart không có phải được bỏ qua.

Phân xử bank directory không được giữ grant cho request bị chặn; terminal update/cancel của đúng tag chủ phải nhả reservation dù có request không đủ điều kiện khác đang giữ VALID. Mỗi request token chỉ được nhận một lần; slot phải được quan sát ở mức VALID thấp trước khi được cấp grant lại. Giữ nguyên các trường transaction cần qua nhiều phase cho đến khi giải phóng context. Không giữ cổng mảng directory hoặc tag/data array của cache khi chờ ACK/B response từ khối khác. ACK stale/trùng/sai được drain và chẩn đoán mà không đổi trạng thái hay chặn ACK đúng.

### 5.5 FSM flow diagrams / Lưu đồ FSM

FSM V4 is the current review draft. It preserves the V3 two-phase coherence flows and adds FSM-011 for system-wide CBO maintenance, precise CBO faults, and CBO retirement control. FSM-012 adds the directory reservation-owner escape contract in this revision; its abstract transition table is in Section 10.2.4 and its waveform is WF-020. Update of the editable FSM draw.io source is tracked by DEP-024 before RTL approval. FSM V2 and V3 remain historical review sources. The diagrams use the bundled VLSIT draw.io library and show functional flow, not final source encodings or cycle counts. PREPARE locks a line and reports stable state plus status without changing stable MESI. For normal coherence requests and writeback-required CMOs, an M owner writes the full line through its existing AXI path and PREPARE waits for the matching B response; true CBO.INVAL only locks/reports the M line and skips writeback. The probe response carries no line payload. ABORT preserves the prior state; COMMIT changes the requested stable state and is acknowledged before directory update/requester grant. PREPARE, COMMIT, and ABORT have no ACK timeout: retain the lock and slot until all expected ACKs or reset. WF-016/017 show missing PREPARE/ABORT ACKs; WF-018 shows the CBO fault ordering. Exact pinned-source port mapping remains open.

FSM V4 là bản nháp xem xét hiện tại. Bản này giữ các luồng coherence hai pha của V3 và thêm FSM-011 cho bảo trì CBO toàn hệ thống, lỗi CBO chính xác và điều khiển nghỉ hưu CBO. FSM-012 bổ sung hợp đồng thoát reservation directory trong phiên bản này; bảng chuyển trạng thái trừu tượng nằm ở Mục 10.2.4 và waveform là WF-020. DEP-024 theo dõi việc cập nhật file draw.io có thể chỉnh sửa trước khi duyệt RTL. FSM V2 và V3 được giữ làm bản lịch sử. Sơ đồ dùng thư viện draw.io VLSIT, mô tả luồng chức năng nhưng chưa chốt mã hóa source hay số chu kỳ. PREPARE khóa line và trả state/status nhưng không đổi MESI ổn định. Với coherence request và CMO cần writeback, owner M ghi đủ line qua AXI hiện có và PREPARE đợi B response tương ứng; CBO.INVAL thật chỉ khóa/báo line M và bỏ qua writeback. Probe response không mang payload line. ABORT giữ state cũ; COMMIT đổi state đích và phải được ACK trước khi cập nhật directory/cấp quyền requester. PREPARE, COMMIT và ABORT không timeout ACK: giữ lock và slot đến khi nhận đủ ACK hoặc reset. WF-016/017 mô tả thiếu ACK ở PREPARE/ABORT; WF-018 mô tả thứ tự fault CBO. Ánh xạ port theo source đã pin vẫn còn mở.

![FSM-001 two-phase read sharing](figures/fsm/VLSIT_RISCV_CLUSTER_FSM_V3_FSM001.svg)

![FSM-002 two-phase write ownership](figures/fsm/VLSIT_RISCV_CLUSTER_FSM_V3_FSM002.svg)

![FSM-003 two-phase cache probe](figures/fsm/VLSIT_RISCV_CLUSTER_FSM_V3_FSM003.svg)

![FSM-010 tagged transaction context](figures/fsm/VLSIT_RISCV_CLUSTER_FSM_V3_FSM010.svg)

| FSM ID | Scope / Phạm vi | Main flow / Luồng chính | Review state / Trạng thái duyệt |
|---|---|---|---|
| FSM-001 | `m_vlsit_riscv_coh_fabric` | Target holders, PREPARE, owner AXI writeback/B response if M, LLC read, COMMIT(S), directory update, shared grant / PREPARE holder, owner ghi AXI và nhận B response nếu M, đọc LLC, COMMIT(S), cập nhật directory, cấp shared | V3 draft; user review pending; source port mapping open / Bản V3; chờ người dùng xem; ánh xạ port còn mở |
| FSM-002 | `m_vlsit_riscv_coh_fabric` | Target holders, PREPARE, resolve requester data, COMMIT(I), update owner, grant M / PREPARE holder, chuẩn bị data, COMMIT(I), cập nhật owner, cấp M | V3 draft; user review pending; source port mapping open / Bản V3; chờ người dùng xem; ánh xạ port còn mở |
| FSM-003 | Modified HPDcache probe controller / Bộ điều khiển probe HPDcache cần sửa | Lock line, wait same-line refill, PREPARE; if M, request flush-engine writeback and await matching AXI B status; COMMIT(S/I) or ABORT; tagged ACK / Khóa line, chờ refill cùng line, PREPARE; nếu M thì yêu cầu flush engine writeback và đợi status B AXI khớp; COMMIT(S/I) hoặc ABORT; ACK có tag | V3 draft; source-port mapping open; no-ACK behavior selected in DEC-018 / Bản V3; còn ánh xạ port; hành vi thiếu ACK đã chốt tại DEC-018 |
| FSM-004 | `m_vlsit_riscv_tile_coh_adapter` | Cache miss/upgrade request, CCU grant, cache response / Request miss/upgrade, nhận grant CCU, trả response cache | V2 review draft; CVA6 source mapping open / Bản nháp V2; ánh xạ source CVA6 còn mở |
| FSM-005 | `m_vlsit_riscv_axil_decode` | AXI4-Lite read route and response / Định tuyến AXI4-Lite read và response | V2 review draft; target decode follows approved local windows / Bản nháp V2; decode theo cửa sổ local đã duyệt |
| FSM-006 | `m_vlsit_riscv_axil_decode` | Independent AW/W collection, CSR/LLC write route and B response / Thu AW/W độc lập, định tuyến ghi CSR/LLC và trả B | V2 review draft; queue depth and partial-write behavior follow workbook / Bản nháp V2; queue và partial write theo workbook |
| FSM-007 | PMU snapshot control / Điều khiển snapshot PMU | Capture counter bank and hold snapshot status / Chụp counter bank và giữ trạng thái snapshot | V2 review draft; exact generated-CSR handshake mapping open / Bản nháp V2; ánh xạ handshake CSR sinh tự động còn mở |
| FSM-008 | `m_vlsit_riscv_axi_route` + PULP `axi_demux` / `m_vlsit_riscv_axi_mmio` | Classify AR by the shared table; select memory, MMIO, or local DECERR; route the returned R burst / Phân loại AR bằng bảng chung; chọn memory, MMIO hoặc DECERR cục bộ; định tuyến burst R trả về | Route leaf linted; full-core handshake and response verification pending / Leaf đã lint; còn chờ kiểm chứng handshake và response ở core hoàn chỉnh |
| FSM-009 | `m_vlsit_riscv_axi_route` + PULP `axi_demux` / `m_vlsit_riscv_axi_mmio` | Classify AW; collect/route AW and W; return local DECERR or target B response / Phân loại AW; thu/định tuyến AW và W; trả DECERR cục bộ hoặc response B của target | Upstream channel handling reused; full-core error/order verification pending / Tái sử dụng xử lý kênh upstream; còn chờ kiểm chứng lỗi/thứ tự ở core hoàn chỉnh |
| FSM-010 | `m_vlsit_riscv_coh_txn_table` | Allocate one of 2–16 contexts (default 8); track PREPARE/COMMIT/ABORT masks; release after all required ACKs and directory completion / Cấp 1 trong 2–16 context (mặc định 8); theo dõi mask PREPARE/COMMIT/ABORT; giải phóng sau ACK và hoàn tất directory | V3 draft; user review pending / Bản V3; chờ người dùng xem |
| FSM-012 | `m_vlsit_riscv_sharer_directory` | Free set → reserve on accepted miss; while reserved, block non-owner requests to that set without occupying arbitration; matching owner UPDATE commits and releases; matching owner CANCEL releases without changing directory contents; reset clears reservation/valid state | v0.19 contract draft; WF-020 covers the escape sequence; add to editable FSM draw.io before RTL approval |

FSM-012 abstract transition contract / Hợp đồng chuyển trạng thái trừu tượng FSM-012:

| Current condition | Accepted event / guard | Action | Next condition |
|---|---|---|---|
| Set free | Accepted miss lookup for tag T | Record one reservation `(set,T)` and return miss/victim information | Set reserved by T |
| Set reserved by T | Matching `UPDATE(T)` accepted | Apply directory update atomically, then clear reservation | Set free |
| Set reserved by T | Matching pre-COMMIT `CANCEL(T)` accepted | Clear reservation only; do not change holder/MESI contents | Set free |
| Set reserved by T | Lookup/update for another tag to same set | Hold requester VALID; do not allocate the grant or bank port; service other eligible operation if present | Set remains reserved by T |
| Any | Reset | Clear reservation and valid bits under the cluster reset contract | Set free/invalid |

The table specifies protocol states, not RTL state encodings or cycle counts. The matching-owner escape takes precedence over a blocked request; terminal-event corruption (both UPDATE and CANCEL for one owner) is handled by REQ-MEM-019.

Bảng này quy định trạng thái giao thức, không quy định mã hóa RTL hoặc số chu kỳ. Thao tác kết thúc đúng chủ được ưu tiên đi qua request đang bị chặn; lỗi phát đồng thời UPDATE/CANCEL được xử lý theo REQ-MEM-019.

#### Request-token and transaction-context lifetime / Vòng đời request-token và transaction-context

The bank arbiter interface is slot-based: one `i_req_valid[slot]` denotes one pending operation, not an unbounded stream. On `grant_valid && grant_ready`, the consumer accepts that operation once. The arbiter records the slot as consumed and ignores a still-high VALID for that slot until a sampled low rearms it. A new operation from the same slot may be presented only after this low phase. This makes a late VALID drop harmless to exactly-once behavior. A stalled grant keeps its bank/slot identity stable, and the source keeps the corresponding request payload stable. Independent slots can still sustain one accepted operation per bank per cycle.

Bank arbiter interface là kiểu slot: `i_req_valid[slot]` biểu thị một thao tác đang chờ, không phải luồng không giới hạn. Khi `grant_valid && grant_ready`, consumer nhận thao tác đúng một lần. Arbiter ghi nhận slot đã tiêu thụ và bỏ qua VALID vẫn đang cao cho đến khi quan sát một pha thấp để tái kích hoạt. Slot chỉ được phát thao tác mới sau pha VALID thấp này. Cách này bảo đảm không cấp grant trùng dù VALID hạ trễ. Grant đang stall giữ ổn định bank/slot; nguồn giữ ổn định payload tương ứng. Các slot độc lập vẫn có thể duy trì một thao tác được nhận mỗi chu kỳ trên mỗi bank.

Each active context is the source of truth for all phase-to-phase information. In particular, the owner identity and target MESI state survive PREPARE, COMMIT, and ABORT; the owner-writeback flag/status changes only on the matching `(tag, hart, line, AXI ID)` response and remains available until the transaction is released. The probe scheduler must receive or derive its target state from that same context. An error status cannot be erased by entering another phase, and a failed PREPARE cannot transition to COMMIT.

Mỗi context đang hoạt động là nguồn dữ liệu chuẩn cho thông tin dùng qua các phase. Đặc biệt, danh tính owner và MESI đích được giữ qua PREPARE, COMMIT và ABORT; cờ/trạng thái owner-writeback chỉ đổi theo response đúng `(tag, hart, line, AXI ID)` và còn hiệu lực đến khi giải phóng transaction. Probe scheduler phải nhận hoặc suy ra MESI đích từ cùng context đó. Không được xóa trạng thái lỗi khi chuyển phase; PREPARE lỗi không được chuyển sang COMMIT.

[Editable FSM V4 draw.io source / File draw.io FSM V4 có thể chỉnh sửa](figures/fsm/VLSIT_RISCV_CLUSTER_FSM_V4.drawio), including FSM-011 CBO/CMO maintenance. [Historical FSM V3 / FSM V3 lịch sử](figures/fsm/VLSIT_RISCV_CLUSTER_FSM_V3.drawio). [FSM V2 archive / Lưu trữ FSM V2](figures/fsm/VLSIT_RISCV_CLUSTER_FSM_V2.drawio).

## 6. External interfaces and ports

### 6.1 Interface inventory

| Interface ID | Type and revision | Role | Direction at IP boundary | Clock domain | Required / optional | Configurations |
|---|---|---|---|---|---|---|
| IF-CLK | Single synchronous clock | Input clock | Into cluster | CLK-CLUSTER | Required | All |
| IF-RST | Active-low reset | Input reset | Into cluster | RST-CLUSTER | Required | All |
| IF-BOOT | CVA6 boot address | Shared 64-bit runtime input | Into cluster and fanned out to active harts | CLK-CLUSTER; held stable across reset release | Required | All |
| IF-AXIL | AXI4-Lite IHI 0022H | Subordinate | Into cluster | CLK-CLUSTER | Required | All |
| IF-MMIO | AXI4 IHI 0022H | Manager | Out of cluster | CLK-CLUSTER | Required | All |
| IF-MEM-AXI | AXI4 IHI 0022H | Manager | Out of cluster | CLK-CLUSTER | Required | CFG-AXI only |
| IF-MEM-ACE | ACE full IHI 0022H | Coherent manager | Bidirectional request/response and snoop channels | CLK-CLUSTER | Deferred | Future ACE phase only |
| IF-IRQ | RISC-V platform interrupt levels | Per-hart inputs | Into cluster | CLK-CLUSTER | Required | All |
| IF-PMU-IRQ | Cluster PMU interrupt | Level output | Out of cluster | CLK-CLUSTER | Required | All |
| IF-DBG | RISC-V external DM-to-hart integration | Per-hart request/status | Bidirectional | CLK-CLUSTER | Required integration | All |
| IF-CVXIF | CVA6 eXtension interface | Disabled in license-preserving local configuration; no cluster-boundary ports | Not exposed | No clock (no port) | Disabled by DEC-022 | All |

### 6.2 Complete AXI-profile port list

Ports follow the VLSIT naming rule. Widths are fixed across profiles unless the row explicitly describes a four-hart vector or a parameterized AXI memory data bus. AXI response/data/address attributes are valid with their channel VALID. All synchronous inputs are sampled on the rising edge of i_clk_cluster. Reset values below are logical inactive values; AXI response payload is ignored when its VALID is low.

Port tuân theo quy tắc VLSIT. Độ rộng cố định giữa các profile, trừ vector bốn hart hoặc bus dữ liệu AXI memory có parameter. Payload AXI hợp lệ khi VALID tương ứng bằng 1. Input đồng bộ được lấy mẫu ở cạnh lên i_clk_cluster. Giá trị reset bên dưới là trạng thái không hoạt động; response payload bị bỏ qua khi VALID=0.

**Source mapping:** the top-level `i_boot_addr[63:0]` fans out to each active CVA6 `boot_addr_i`. The upstream configuration enables CVXIF, but the separately licensed local configuration copy sets `CVA6ConfigCvxifEn=0`; no accelerator ports are exposed. The pristine upstream configuration remains unchanged.

**Pinned-source interface audit:** the selected CVA6 configuration has a 4-bit AXI ID and enables the RISC-V A extension. A fixed four-input PULP `axi_mux` adds two hart-select ID bits, making the LLC slave-side ID 6 bits; `axi_llc_reg_wrap` adds one bit, so the external memory ID is 7 bits. The separate MMIO mux also emits 6-bit IDs. The selected memory boundary carries the LLC's 6-bit AWATOP field. The SoC fabric must support AXI4+ATOP or connect a real atomic-service bridge. The LLC service register port is PULP RegBus, so a new VLSIT AXI4-Lite-to-RegBus bridge is included. See the source-grounded port plan for integration details and source-level deltas.

**Ánh xạ source:** `i_boot_addr[63:0]` của top được nối tới `boot_addr_i` của mọi CVA6 đang hoạt động. Cấu hình upstream bật CVXIF, nhưng bản cấu hình cục bộ có giữ license đặt `CVA6ConfigCvxifEn=0`; cluster không đưa port accelerator ra ngoài. Bản cấu hình upstream nguyên gốc không bị sửa.

**Đối chiếu interface source đã pin:** cấu hình CVA6 đã chọn có AXI ID 4-bit và bật extension A của RISC-V. `axi_mux` cố định bốn cổng thêm hai bit chọn hart, nên ID phía slave LLC rộng 6 bit; `axi_llc_reg_wrap` thêm một bit nên ID bộ nhớ ngoài rộng 7 bit. Mux MMIO riêng cũng có ID 6 bit. Biên memory giữ trường AWATOP 6 bit của LLC. Fabric SoC phải hỗ trợ AXI4+ATOP hoặc nối atomic-service bridge thực sự. Cổng service LLC dùng PULP RegBus nên design thêm bridge VLSIT AXI4-Lite-to-RegBus. Xem port plan theo source trước khi duyệt RTL.

#### Global, interrupt, debug, and PMU ports

| Port | Direction | Width | Meaning (function) | Clock domain | Signal type | Reset / idle value | Timing / sampling | Configurations |
|---|---|---:|---|---|---|---|---|---|
| i_clk_cluster | Input | 1 | Main cluster clock | CLK-CLUSTER | Clock | Not resettable; sampled on rising edge | Rising edge | All |
| i_rst_n_cluster | Input | 1 | Active-low cluster reset; SoC supplies synchronized deassertion | RST-CLUSTER | Reset (active-low) | 0 asserted | Assertion asynchronous; release synchronous before use | All |
| i_boot_addr | Input | 64 | Shared boot address connected to every active hart's CVA6 `boot_addr_i` | CLK-CLUSTER | Data | No reset value; SoC holds stable through reset release | Stable while reset is asserted and through startup capture; exact core sampling follows pinned CVA6 | All |
| i_int_msip | Input | 4 [3:0] | Per-hart machine software interrupt level | CLK-CLUSTER | Level | 0 | Sampled each rising edge; bits 3:2 ignored with 2 harts | All |
| i_int_mtip | Input | 4 [3:0] | Per-hart machine timer interrupt level | CLK-CLUSTER | Level | 0 | Sampled each rising edge; bits 3:2 ignored with 2 harts | All |
| i_int_meip | Input | 4 [3:0] | Per-hart machine external interrupt level | CLK-CLUSTER | Level | 0 | Sampled each rising edge; bits 3:2 ignored with 2 harts | All |
| i_int_ssip | Input | 4 [3:0] | Per-hart supervisor software interrupt level, ORed with software-writable MIP.SSIP | CLK-CLUSTER | Level | 0 | Synchronous level; effective pending is evaluated each cycle; bits 3:2 ignored with 2 harts | All |
| i_int_stip | Input | 4 [3:0] | Per-hart supervisor timer interrupt level, ORed with software-writable MIP.STIP | CLK-CLUSTER | Level | 0 | Synchronous level; effective pending is evaluated each cycle; bits 3:2 ignored with 2 harts | All |
| i_int_seip | Input | 4 [3:0] | Per-hart supervisor external interrupt level | CLK-CLUSTER | Level | 0 | Sampled each rising edge; bits 3:2 ignored with 2 harts | All |
| i_hart_debug_req | Input | 4 [3:0] | External DM request to enter debug for each hart | CLK-CLUSTER | Level | 0 | Hold until accepted by target hart; unused-hart bits ignored | All |
| o_hart_debug_mode | Output | 4 [3:0] | Per-hart indication that hart is in debug mode | CLK-CLUSTER | Level | 0 | Stable while corresponding mode is active | All |
| o_int_pmu | Output | 1 | Aggregate PMU interrupt to SoC interrupt controller | CLK-CLUSTER | Level | 0 | Assert while enabled pending cause exists; clear through CSR | All |
| o_int_fault | Output | 1 | Sticky asynchronous notification of ordinary dirty-eviction writeback failure; associated information is readable through CSR | CLK-CLUSTER | Level | 0 | Assert on the accepted fault event and hold until reset; no software-clear recovery | CFG-AXI-2/4 |

#### AXI4-Lite Subordinate ports

| Port | Direction | Width | Meaning (function) | Clock domain | Signal type | Reset / idle value | Timing / sampling | Configurations |
|---|---|---:|---|---|---|---|---|---|
| i_axil_awaddr | Input | 32 | Write address, byte-addressed | CLK-CLUSTER | Data (valid with i_axil_awvalid) | 0 | Hold until AW handshake | All |
| i_axil_awprot | Input | 3 | Write protection attribute | CLK-CLUSTER | Data (valid with i_axil_awvalid) | 0 | Sample on AW handshake | All |
| i_axil_awvalid | Input | 1 | Write-address channel valid | CLK-CLUSTER | Level | 0 | Hold high until AWREADY | All |
| o_axil_awready | Output | 1 | Write-address acceptance | CLK-CLUSTER | Level | 0 | Handshake when AWVALID and AWREADY | All |
| i_axil_wdata | Input | 32 | Write data | CLK-CLUSTER | Data (valid with i_axil_wvalid) | 0 | Hold until W handshake | All |
| i_axil_wstrb | Input | 4 | Write byte strobes | CLK-CLUSTER | Data (valid with i_axil_wvalid) | 0 | Sample on W handshake | All |
| i_axil_wvalid | Input | 1 | Write-data channel valid | CLK-CLUSTER | Level | 0 | Hold high until WREADY | All |
| o_axil_wready | Output | 1 | Write-data acceptance | CLK-CLUSTER | Level | 0 | Handshake when WVALID and WREADY | All |
| o_axil_bresp | Output | 2 | Write response code | CLK-CLUSTER | Data (valid with o_axil_bvalid) | 0 | Hold until B handshake | All |
| o_axil_bvalid | Output | 1 | Write response valid | CLK-CLUSTER | Level | 0 | Hold high until BREADY | All |
| i_axil_bready | Input | 1 | Write response acceptance | CLK-CLUSTER | Level | 0 | Sample on rising edge | All |
| i_axil_araddr | Input | 32 | Read address, byte-addressed | CLK-CLUSTER | Data (valid with i_axil_arvalid) | 0 | Hold until AR handshake | All |
| i_axil_arprot | Input | 3 | Read protection attribute | CLK-CLUSTER | Data (valid with i_axil_arvalid) | 0 | Sample on AR handshake | All |
| i_axil_arvalid | Input | 1 | Read-address channel valid | CLK-CLUSTER | Level | 0 | Hold high until ARREADY | All |
| o_axil_arready | Output | 1 | Read-address acceptance | CLK-CLUSTER | Level | 0 | Handshake when ARVALID and ARREADY | All |
| o_axil_rdata | Output | 32 | Read data | CLK-CLUSTER | Data (valid with o_axil_rvalid) | 0 | Hold until R handshake | All |
| o_axil_rresp | Output | 2 | Read response code | CLK-CLUSTER | Data (valid with o_axil_rvalid) | 0 | Hold until RREADY | All |
| o_axil_rvalid | Output | 1 | Read response valid | CLK-CLUSTER | Level | 0 | Hold high until RREADY | All |
| i_axil_rready | Input | 1 | Read response acceptance | CLK-CLUSTER | Level | 0 | Sample on rising edge | All |

AXI4-Lite uses independent AW/W handshakes. A write takes effect only after both halves have been accepted and the selected register target commits the write. No CSR state may change solely because AWVALID or WVALID is asserted without its handshake. The selected CSR generator default is synchronous, 32-bit data, 32-bit address, four strobes, WSTRB honored, and queued read/write mode; final queue depths and response timing are recorded with the workbook.

AW và W có thể bắt tay độc lập; ghi chỉ có hiệu lực khi cả hai phần đã được nhận và register target commit. CSR không đổi chỉ vì AWVALID hoặc WVALID lên mà chưa bắt tay. Generator dùng clock đồng bộ, 32-bit data/address, 4 strobe, WSTRB được áp dụng và mode queued; độ sâu queue và response timing sẽ khóa cùng workbook.

#### AXI4 Manager ports

CFG-AXI exposes the memory and MMIO managers. CFG-ACE exposes the MMIO AXI4 manager and the full ACE coherent memory interface. The table names every AXI4 port individually; the width column carries vector widths.

CFG-AXI có hai AXI4 Manager: memory và MMIO. CFG-ACE có AXI4 MMIO và giao diện nhớ ACE đầy đủ. Bảng liệt kê riêng từng port; độ rộng vector nằm trong cột Width.

| Port | Direction | Width | Meaning / function | Clock domain | Signal type | Reset / idle value | Timing / sampling | Configurations |
|---|---|---:|---|---|---|---|---|---|
| o_axi_mmio_awid | Output | 6 | Write transaction ID after a fixed four-input `axi_mux` adds two source-select bits to each 4-bit CVA6 ID | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | All profiles |
| o_axi_mmio_awaddr | Output | 64 | Write start address | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | All profiles |
| o_axi_mmio_awlen | Output | 8 | Write burst length minus one | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | All profiles |
| o_axi_mmio_awsize | Output | 3 | Write bytes per beat encoding | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | All profiles |
| o_axi_mmio_awburst | Output | 2 | Write burst type | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | All profiles |
| o_axi_mmio_awlock | Output | 1 | Write lock attribute | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | All profiles |
| o_axi_mmio_awcache | Output | 4 | Write cache attribute | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | All profiles |
| o_axi_mmio_awprot | Output | 3 | Write protection attribute | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | All profiles |
| o_axi_mmio_awqos | Output | 4 | Write quality-of-service value | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | All profiles |
| o_axi_mmio_awregion | Output | 4 | Write region identifier | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | All profiles |
| o_axi_mmio_awvalid | Output | 1 | Write address/control valid | CLK-CLUSTER | Level | 0 during reset; payload ignored when VALID=0 | Hold until AWREADY handshake | All profiles |
| i_axi_mmio_awready | Input | 1 | Write address accepted | CLK-CLUSTER | Level | 0 when idle | Sample on rising edge | All profiles |
| o_axi_mmio_wdata | Output | 64 | Write data beat | CLK-CLUSTER | Data (valid with WVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | All profiles |
| o_axi_mmio_wstrb | Output | 8 | Write byte enables | CLK-CLUSTER | Data (valid with WVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | All profiles |
| o_axi_mmio_wlast | Output | 1 | Final write data beat | CLK-CLUSTER | Data (valid with WVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | All profiles |
| o_axi_mmio_wvalid | Output | 1 | Write data valid | CLK-CLUSTER | Level | 0 during reset; payload ignored when VALID=0 | Hold until WREADY handshake | All profiles |
| i_axi_mmio_wready | Input | 1 | Write data beat accepted | CLK-CLUSTER | Level | 0 when idle | Sample on rising edge | All profiles |
| i_axi_mmio_bid | Input | 6 | Write response transaction ID, including the two source-select bits | CLK-CLUSTER | Data (valid with BVALID) | Ignored when associated VALID=0 | Sample on BVALID and BREADY handshake | All profiles |
| i_axi_mmio_bresp | Input | 2 | Write response status | CLK-CLUSTER | Data (valid with BVALID) | Ignored when associated VALID=0 | Sample on BVALID and BREADY handshake | All profiles |
| i_axi_mmio_bvalid | Input | 1 | Write response valid | CLK-CLUSTER | Level | 0 when idle | Hold until BREADY handshake | All profiles |
| o_axi_mmio_bready | Output | 1 | Accept write response | CLK-CLUSTER | Level | 0 during reset; payload ignored when VALID=0 | Assert when response can be consumed | All profiles |
| o_axi_mmio_arid | Output | 6 | Read transaction ID after a fixed four-input `axi_mux` adds two source-select bits to each 4-bit CVA6 ID | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | All profiles |
| o_axi_mmio_araddr | Output | 64 | Read start address | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | All profiles |
| o_axi_mmio_arlen | Output | 8 | Read burst length minus one | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | All profiles |
| o_axi_mmio_arsize | Output | 3 | Read bytes per beat encoding | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | All profiles |
| o_axi_mmio_arburst | Output | 2 | Read burst type | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | All profiles |
| o_axi_mmio_arlock | Output | 1 | Read lock attribute | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | All profiles |
| o_axi_mmio_arcache | Output | 4 | Read cache attribute | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | All profiles |
| o_axi_mmio_arprot | Output | 3 | Read protection attribute | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | All profiles |
| o_axi_mmio_arqos | Output | 4 | Read quality-of-service value | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | All profiles |
| o_axi_mmio_arregion | Output | 4 | Read region identifier | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | All profiles |
| o_axi_mmio_arvalid | Output | 1 | Read address/control valid | CLK-CLUSTER | Level | 0 during reset; payload ignored when VALID=0 | Hold until ARREADY handshake | All profiles |
| i_axi_mmio_arready | Input | 1 | Read address accepted | CLK-CLUSTER | Level | 0 when idle | Sample on rising edge | All profiles |
| i_axi_mmio_rid | Input | 6 | Read response transaction ID, including the two source-select bits | CLK-CLUSTER | Data (valid with RVALID) | Ignored when associated VALID=0 | Sample on RVALID and RREADY handshake | All profiles |
| i_axi_mmio_rdata | Input | 64 | Read data beat | CLK-CLUSTER | Data (valid with RVALID) | Ignored when associated VALID=0 | Sample on RVALID and RREADY handshake | All profiles |
| i_axi_mmio_rresp | Input | 2 | Read response status | CLK-CLUSTER | Data (valid with RVALID) | Ignored when associated VALID=0 | Sample on RVALID and RREADY handshake | All profiles |
| i_axi_mmio_rlast | Input | 1 | Final read data beat | CLK-CLUSTER | Data (valid with RVALID) | Ignored when associated VALID=0 | Sample on RVALID and RREADY handshake | All profiles |
| i_axi_mmio_rvalid | Input | 1 | Read data/response valid | CLK-CLUSTER | Level | 0 when idle | Hold until RREADY handshake | All profiles |
| o_axi_mmio_rready | Output | 1 | Accept read data beat | CLK-CLUSTER | Level | 0 during reset; payload ignored when VALID=0 | Assert when data can be consumed | All profiles |
| o_axi_mem_awid | Output | 7 | Write transaction ID; four-hart mux adds two bits to the 4-bit CVA6 ID, then LLC adds one master-ID bit | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-AXI only |
| o_axi_mem_awatop | Output | 6 | AXI atomic operation code forwarded from LLC; zero encodes a non-atomic write | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-AXI only |
| o_axi_mem_awaddr | Output | 64 | Write start address | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-AXI only |
| o_axi_mem_awlen | Output | 8 | Write burst length minus one | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-AXI only |
| o_axi_mem_awsize | Output | 3 | Write bytes per beat encoding | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-AXI only |
| o_axi_mem_awburst | Output | 2 | Write burst type | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-AXI only |
| o_axi_mem_awlock | Output | 1 | Write lock attribute | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-AXI only |
| o_axi_mem_awcache | Output | 4 | Write cache attribute | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-AXI only |
| o_axi_mem_awprot | Output | 3 | Write protection attribute | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-AXI only |
| o_axi_mem_awqos | Output | 4 | Write quality-of-service value | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-AXI only |
| o_axi_mem_awregion | Output | 4 | Write region identifier | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-AXI only |
| o_axi_mem_awvalid | Output | 1 | Write address/control valid | CLK-CLUSTER | Level | 0 during reset; payload ignored when VALID=0 | Hold until AWREADY handshake | CFG-AXI only |
| i_axi_mem_awready | Input | 1 | Write address accepted | CLK-CLUSTER | Level | 0 when idle | Sample on rising edge | CFG-AXI only |
| o_axi_mem_wdata | Output | PARA_AXI_MEM_DATA_W | Write data beat at the external memory width | CLK-CLUSTER | Data (valid with WVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-AXI only |
| o_axi_mem_wstrb | Output | PARA_AXI_MEM_DATA_W/8 | Write byte enables at the external memory width | CLK-CLUSTER | Data (valid with WVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-AXI only |
| o_axi_mem_wlast | Output | 1 | Final write data beat | CLK-CLUSTER | Data (valid with WVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-AXI only |
| o_axi_mem_wvalid | Output | 1 | Write data valid | CLK-CLUSTER | Level | 0 during reset; payload ignored when VALID=0 | Hold until WREADY handshake | CFG-AXI only |
| i_axi_mem_wready | Input | 1 | Write data beat accepted | CLK-CLUSTER | Level | 0 when idle | Sample on rising edge | CFG-AXI only |
| i_axi_mem_bid | Input | 7 | Write response transaction ID; matches LLC master-ID width | CLK-CLUSTER | Data (valid with BVALID) | Ignored when associated VALID=0 | Sample on BVALID and BREADY handshake | CFG-AXI only |
| i_axi_mem_bresp | Input | 2 | Write response status | CLK-CLUSTER | Data (valid with BVALID) | Ignored when associated VALID=0 | Sample on BVALID and BREADY handshake | CFG-AXI only |
| i_axi_mem_bvalid | Input | 1 | Write response valid | CLK-CLUSTER | Level | 0 when idle | Hold until BREADY handshake | CFG-AXI only |
| o_axi_mem_bready | Output | 1 | Accept write response | CLK-CLUSTER | Level | 0 during reset; payload ignored when VALID=0 | Assert when response can be consumed | CFG-AXI only |
| o_axi_mem_arid | Output | 7 | Read transaction ID; four-hart mux adds two bits to the 4-bit CVA6 ID, then LLC adds one master-ID bit | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-AXI only |
| o_axi_mem_araddr | Output | 64 | Read start address | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-AXI only |
| o_axi_mem_arlen | Output | 8 | Read burst length minus one | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-AXI only |
| o_axi_mem_arsize | Output | 3 | Read bytes per beat encoding | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-AXI only |
| o_axi_mem_arburst | Output | 2 | Read burst type | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-AXI only |
| o_axi_mem_arlock | Output | 1 | Read lock attribute | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-AXI only |
| o_axi_mem_arcache | Output | 4 | Read cache attribute | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-AXI only |
| o_axi_mem_arprot | Output | 3 | Read protection attribute | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-AXI only |
| o_axi_mem_arqos | Output | 4 | Read quality-of-service value | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-AXI only |
| o_axi_mem_arregion | Output | 4 | Read region identifier | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-AXI only |
| o_axi_mem_arvalid | Output | 1 | Read address/control valid | CLK-CLUSTER | Level | 0 during reset; payload ignored when VALID=0 | Hold until ARREADY handshake | CFG-AXI only |
| i_axi_mem_arready | Input | 1 | Read address accepted | CLK-CLUSTER | Level | 0 when idle | Sample on rising edge | CFG-AXI only |
| i_axi_mem_rid | Input | 7 | Read response transaction ID; matches LLC master-ID width | CLK-CLUSTER | Data (valid with RVALID) | Ignored when associated VALID=0 | Sample on RVALID and RREADY handshake | CFG-AXI only |
| i_axi_mem_rdata | Input | PARA_AXI_MEM_DATA_W | Read data beat at the external memory width | CLK-CLUSTER | Data (valid with RVALID) | Ignored when associated VALID=0 | Sample on RVALID and RREADY handshake | CFG-AXI only |
| i_axi_mem_rresp | Input | 2 | Read response status | CLK-CLUSTER | Data (valid with RVALID) | Ignored when associated VALID=0 | Sample on RVALID and RREADY handshake | CFG-AXI only |
| i_axi_mem_rlast | Input | 1 | Final read data beat | CLK-CLUSTER | Data (valid with RVALID) | Ignored when associated VALID=0 | Sample on RVALID and RREADY handshake | CFG-AXI only |
| i_axi_mem_rvalid | Input | 1 | Read data/response valid | CLK-CLUSTER | Level | 0 when idle | Hold until RREADY handshake | CFG-AXI only |
| o_axi_mem_rready | Output | 1 | Accept read data beat | CLK-CLUSTER | Level | 0 during reset; payload ignored when VALID=0 | Assert when data can be consumed | CFG-AXI only |

#### ACE coherent memory ports

ACE uses the AXI4 base channels plus ACE attributes and AC/CR/CD snoop channels. This table lists the complete fixed port set for the ACE top. RRESP is four bits in the ACE interface; the supported transaction subset is an integration dependency in Section 20.

ACE dùng các channel cơ sở AXI4, thuộc tính ACE và các channel snoop AC/CR/CD. Bảng liệt kê đầy đủ port cố định của ACE top. RRESP rộng 4 bit; tập transaction hỗ trợ được ghi là dependency ở Mục 20.

| Port | Direction | Width | Meaning / function | Clock domain | Signal type | Reset / idle value | Timing / sampling | Configurations |
|---|---|---:|---|---|---|---|---|---|
| o_ace_mem_awid | Output | 4 | Write transaction ID | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-ACE only |
| o_ace_mem_awaddr | Output | 64 | Write start address | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-ACE only |
| o_ace_mem_awlen | Output | 8 | Write burst length minus one | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-ACE only |
| o_ace_mem_awsize | Output | 3 | Write bytes per beat encoding | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-ACE only |
| o_ace_mem_awburst | Output | 2 | Write burst type | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-ACE only |
| o_ace_mem_awlock | Output | 1 | Write lock attribute | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-ACE only |
| o_ace_mem_awcache | Output | 4 | Write cache attribute | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-ACE only |
| o_ace_mem_awprot | Output | 3 | Write protection attribute | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-ACE only |
| o_ace_mem_awqos | Output | 4 | Write quality-of-service value | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-ACE only |
| o_ace_mem_awregion | Output | 4 | Write region identifier | CLK-CLUSTER | Data (valid with AWVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-ACE only |
| o_ace_mem_awvalid | Output | 1 | Write address/control valid | CLK-CLUSTER | Level | 0 during reset; payload ignored when VALID=0 | Hold until AWREADY handshake | CFG-ACE only |
| i_ace_mem_awready | Input | 1 | Write address accepted | CLK-CLUSTER | Level | 0 when idle | Sample on rising edge | CFG-ACE only |
| o_ace_mem_wdata | Output | 64 | Write data beat | CLK-CLUSTER | Data (valid with WVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-ACE only |
| o_ace_mem_wstrb | Output | 8 | Write byte enables | CLK-CLUSTER | Data (valid with WVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-ACE only |
| o_ace_mem_wlast | Output | 1 | Final write data beat | CLK-CLUSTER | Data (valid with WVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-ACE only |
| o_ace_mem_wvalid | Output | 1 | Write data valid | CLK-CLUSTER | Level | 0 during reset; payload ignored when VALID=0 | Hold until WREADY handshake | CFG-ACE only |
| i_ace_mem_wready | Input | 1 | Write data beat accepted | CLK-CLUSTER | Level | 0 when idle | Sample on rising edge | CFG-ACE only |
| i_ace_mem_bid | Input | 4 | Write response transaction ID | CLK-CLUSTER | Data (valid with BVALID) | Ignored when associated VALID=0 | Sample on BVALID and BREADY handshake | CFG-ACE only |
| i_ace_mem_bresp | Input | 2 | Write response status | CLK-CLUSTER | Data (valid with BVALID) | Ignored when associated VALID=0 | Sample on BVALID and BREADY handshake | CFG-ACE only |
| i_ace_mem_bvalid | Input | 1 | Write response valid | CLK-CLUSTER | Level | 0 when idle | Hold until BREADY handshake | CFG-ACE only |
| o_ace_mem_bready | Output | 1 | Accept write response | CLK-CLUSTER | Level | 0 during reset; payload ignored when VALID=0 | Assert when response can be consumed | CFG-ACE only |
| o_ace_mem_arid | Output | 4 | Read transaction ID | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-ACE only |
| o_ace_mem_araddr | Output | 64 | Read start address | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-ACE only |
| o_ace_mem_arlen | Output | 8 | Read burst length minus one | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-ACE only |
| o_ace_mem_arsize | Output | 3 | Read bytes per beat encoding | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-ACE only |
| o_ace_mem_arburst | Output | 2 | Read burst type | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-ACE only |
| o_ace_mem_arlock | Output | 1 | Read lock attribute | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-ACE only |
| o_ace_mem_arcache | Output | 4 | Read cache attribute | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-ACE only |
| o_ace_mem_arprot | Output | 3 | Read protection attribute | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-ACE only |
| o_ace_mem_arqos | Output | 4 | Read quality-of-service value | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-ACE only |
| o_ace_mem_arregion | Output | 4 | Read region identifier | CLK-CLUSTER | Data (valid with ARVALID) | 0 during reset; payload ignored when VALID=0 | Stable while VALID=1 and READY=0 | CFG-ACE only |
| o_ace_mem_arvalid | Output | 1 | Read address/control valid | CLK-CLUSTER | Level | 0 during reset; payload ignored when VALID=0 | Hold until ARREADY handshake | CFG-ACE only |
| i_ace_mem_arready | Input | 1 | Read address accepted | CLK-CLUSTER | Level | 0 when idle | Sample on rising edge | CFG-ACE only |
| i_ace_mem_rid | Input | 4 | Read response transaction ID | CLK-CLUSTER | Data (valid with RVALID) | Ignored when associated VALID=0 | Sample on RVALID and RREADY handshake | CFG-ACE only |
| i_ace_mem_rdata | Input | 64 | Read data beat | CLK-CLUSTER | Data (valid with RVALID) | Ignored when associated VALID=0 | Sample on RVALID and RREADY handshake | CFG-ACE only |
| i_ace_mem_rresp | Input | 4 | Read response status | CLK-CLUSTER | Data (valid with RVALID) | Ignored when associated VALID=0 | Sample on RVALID and RREADY handshake | CFG-ACE only |
| i_ace_mem_rlast | Input | 1 | Final read data beat | CLK-CLUSTER | Data (valid with RVALID) | Ignored when associated VALID=0 | Sample on RVALID and RREADY handshake | CFG-ACE only |
| i_ace_mem_rvalid | Input | 1 | Read data/response valid | CLK-CLUSTER | Level | 0 when idle | Hold until RREADY handshake | CFG-ACE only |
| o_ace_mem_rready | Output | 1 | Accept read data beat | CLK-CLUSTER | Level | 0 during reset; payload ignored when VALID=0 | Assert when data can be consumed | CFG-ACE only |
| o_ace_mem_ardomain | Output | 2 | Read shareability domain | CLK-CLUSTER | Data (valid with o_ace_mem_arvalid) | 0 | Stable through AR handshake | CFG-ACE only |
| o_ace_mem_arsnoop | Output | 4 | Read snoop transaction type | CLK-CLUSTER | Data (valid with o_ace_mem_arvalid) | 0 | Stable through AR handshake | CFG-ACE only |
| o_ace_mem_arbar | Output | 2 | Read barrier attribute | CLK-CLUSTER | Data (valid with o_ace_mem_arvalid) | 0 | Stable through AR handshake | CFG-ACE only |
| o_ace_mem_awdomain | Output | 2 | Write shareability domain | CLK-CLUSTER | Data (valid with o_ace_mem_awvalid) | 0 | Stable through AW handshake | CFG-ACE only |
| o_ace_mem_awsnoop | Output | 3 | Write snoop transaction type | CLK-CLUSTER | Data (valid with o_ace_mem_awvalid) | 0 | Stable through AW handshake | CFG-ACE only |
| o_ace_mem_awbar | Output | 2 | Write barrier attribute | CLK-CLUSTER | Data (valid with o_ace_mem_awvalid) | 0 | Stable through AW handshake | CFG-ACE only |
| o_ace_mem_awunique | Output | 1 | Unique write transaction attribute | CLK-CLUSTER | Data (valid with o_ace_mem_awvalid) | 0 | Stable through AW handshake | CFG-ACE only |
| i_ace_mem_acaddr | Input | 64 | Snoop address | CLK-CLUSTER | Data (valid with i_ace_mem_acvalid) | Ignored when ACVALID=0 | Sample on ACVALID and ACREADY handshake | CFG-ACE only |
| i_ace_mem_acsnoop | Input | 4 | Snoop operation | CLK-CLUSTER | Data (valid with i_ace_mem_acvalid) | Ignored when ACVALID=0 | Sample on ACVALID and ACREADY handshake | CFG-ACE only |
| i_ace_mem_acprot | Input | 3 | Snoop protection attribute | CLK-CLUSTER | Data (valid with i_ace_mem_acvalid) | Ignored when ACVALID=0 | Sample on ACVALID and ACREADY handshake | CFG-ACE only |
| i_ace_mem_acvalid | Input | 1 | Snoop request valid | CLK-CLUSTER | Level | 0 when idle | Hold until ACREADY handshake | CFG-ACE only |
| o_ace_mem_acready | Output | 1 | Accept snoop request | CLK-CLUSTER | Level | 0 during reset | Handshake with ACVALID | CFG-ACE only |
| o_ace_mem_crresp | Output | 5 | Snoop response attributes | CLK-CLUSTER | Data (valid with o_ace_mem_crvalid) | 0 during reset | Stable while CRVALID=1 and CRREADY=0 | CFG-ACE only |
| o_ace_mem_crvalid | Output | 1 | Snoop response valid | CLK-CLUSTER | Level | 0 during reset | Hold until CRREADY handshake | CFG-ACE only |
| i_ace_mem_crready | Input | 1 | Accept snoop response | CLK-CLUSTER | Level | 0 when idle | Sample on rising edge | CFG-ACE only |
| o_ace_mem_cddata | Output | 64 | Snoop response data | CLK-CLUSTER | Data (valid with o_ace_mem_cdvalid) | 0 during reset | Stable while CDVALID=1 and CDREADY=0 | CFG-ACE only |
| o_ace_mem_cdlast | Output | 1 | Final snoop data beat | CLK-CLUSTER | Data (valid with o_ace_mem_cdvalid) | 0 during reset | Stable through CD handshake | CFG-ACE only |
| o_ace_mem_cdvalid | Output | 1 | Snoop response data valid | CLK-CLUSTER | Level | 0 during reset | Hold until CDREADY handshake | CFG-ACE only |
| i_ace_mem_cdready | Input | 1 | Accept snoop response data | CLK-CLUSTER | Level | 0 when idle | Sample on rising edge | CFG-ACE only |
| o_ace_mem_rack | Output | 1 | Read transaction completion acknowledgment | CLK-CLUSTER | Pulse (1 cycle per completed read) | 0 | After accepted final R beat | CFG-ACE only |
| o_ace_mem_wack | Output | 1 | Write transaction completion acknowledgment | CLK-CLUSTER | Pulse (1 cycle per completed write) | 0 | After accepted B response | CFG-ACE only |

### 6.3 Protocol behavior

**AXI4 and AXI4-Lite.** Implement only the named interface roles and widths. Every VALID payload remains stable until READY. AXI4 write data has no WID; W beats follow the single accepted write-data ordering required by AXI4. IDs associate read/write responses with accepted requests. AXI4-Lite AW and W are independent; B is returned after both are accepted. The cluster does not promise fixed latency. Unmapped internal AXI4-Lite windows return DECERR; misaligned CSR accesses and rejected partial strobes return SLVERR per generator configuration. WSTRB=0000 is a no-op in HONOR mode.

**ACE.** The ACE top shall support the full ACE channel set needed by its declared transaction subset. AC snoops are accepted only when internal probe resources can retain the request. CR/CD and R/B responses obey channel handshakes. RACK follows the final accepted read beat; WACK follows the accepted write response. The adapter must serialize conflicting accesses to the same cache line and preserve dirty data. Supported ARSNOOP/AWSNOOP/DOMAIN/BAR values, DVM behavior, ACE atomics, and ordering limits remain an explicit integration dependency, not inferred from port presence.

**Memory attributes and address-region table (DEC-037).** One synthesis-time table is the source of truth for CVA6 PMA generation and the cluster router. It has up to 16 active entries. Each entry contains a 56-bit physical base, a non-zero byte length, and a 32-bit class word whose bits `[1:0]` are `00` cacheable normal memory, `01` normal uncached memory, or `10` device/MMIO; `11` and nonzero bits `[31:2]` are reserved and invalid. Entries are indexed from zero. Entry 0 is the sole cacheable range and defaults to base `0x0000000080000000`, length `0x0000000040000000`, preserving the selected CVA6 range `[0x80000000,0xC0000000)`. Its base and length may be overridden only when the same values also configure the LLC cache window. Entries 1–15 default inactive and are supplied by the SoC for normal-uncached RAM and MMIO; because entry 0 is reserved for the sole cacheable range, at most 15 additional regions can be active. There are no guessed ROM or peripheral addresses. Regions shall not overlap, shall be 16-byte aligned and sized in 16-byte multiples, shall fit within the 56-bit physical address space, and the cacheable entry shall satisfy the LLC's power-of-two size/alignment limits. The CVA6 adapter derives `CachedRegionAddrBase/Length` exclusively from class `00`, and derives `NonIdempotentAddrBase/Length` exclusively from class `10`. Class `01` is idempotent and uncached because it appears in neither CVA6 list. The tile classifies AXI AW/AR spans from address, size, length, and burst type using the original table. Fixed bursts cover the first-beat byte range, incrementing bursts cover their byte-address span, and legal wrapping bursts cover their aligned wrap window. Illegal burst/size, unmatched addresses, and transactions crossing a region boundary produce local-access-error metadata; the cluster router shall return an access error and issue no external AXI request. Normal-uncached entries use the LLC AXI bypass path without tag/data allocation; MMIO entries bypass CCU/LLC and use the AXI4 MMIO manager; cacheable entries use the CCU and LLC. The constant-table validator shall mark overlap, invalid class (including nonzero `[31:2]`), zero length, overflow, unsupported multiple cacheable ranges, or invalid count as `o_config_valid=0`; each decoded access then reports a local error. RTL does not force an elaboration failure. The SoC build flow must treat an invalid table as a configuration error before synthesis, and must prove the same parameters feed PMA, router, and LLC window. Cached atomic accesses execute in coherent L1 under DEC-038; normal-uncached atomics use the AXI4+ATOP service; MMIO atomics are rejected before reaching the peripheral fabric. The AXI-only profile still requires an SoC/software cache-maintenance contract for external DMA.

**Thuộc tính bộ nhớ và bảng vùng địa chỉ (DEC-037).** Một bảng compile-time là nguồn dữ liệu gốc để tạo thuộc tính PMA CVA6 và giải mã router. Bảng có tối đa 16 entry. Mỗi entry gồm base vật lý 56-bit, độ dài byte khác 0 và word class 32-bit; bits `[1:0]` là `00` normal memory cacheable, `01` normal memory uncached, hoặc `10` device/MMIO; `11` và bits `[31:2]` khác 0 đều không hợp lệ. Entry đánh số từ 0. Entry 0 là vùng cacheable duy nhất, mặc định base `0x0000000080000000`, length `0x0000000040000000`, giữ vùng CVA6 `[0x80000000,0xC0000000)`. Chỉ được override base/length khi cùng giá trị đó cũng cấu hình cửa sổ cache của LLC. Entry 1–15 mặc định không hoạt động; vì entry 0 dành cho vùng cacheable duy nhất, tối đa 15 vùng bổ sung được active. SoC cung cấp vùng normal-uncached và MMIO; không tự đoán địa chỉ ROM hay ngoại vi. Các vùng không được chồng lấn, phải căn chỉnh 16 byte và có kích thước bội số 16 byte, nằm trong không gian địa chỉ vật lý 56-bit; vùng cacheable phải thỏa giới hạn căn chỉnh/kích thước lũy thừa hai của LLC. Bộ chuyển đổi CVA6 chỉ đưa class `00` vào `CachedRegionAddrBase/Length`, chỉ đưa class `10` vào `NonIdempotentAddrBase/Length`; class `01` idempotent và uncached vì không nằm trong hai danh sách. Tile phân loại span AXI AW/AR từ address, size, length và burst type theo bảng gốc. Fixed burst bao byte range của beat đầu, incrementing burst bao span địa chỉ byte, legal wrapping burst bao cửa sổ wrap đã căn chỉnh. Burst/size không hợp lệ, địa chỉ không khớp hoặc transaction vượt ranh giới vùng tạo metadata lỗi cục bộ; router cluster phải trả access error và không phát AXI ra ngoài. Normal-uncached đi qua đường AXI bypass của LLC, không cấp phát tag/data; MMIO bỏ qua CCU/LLC, đi qua AXI4 MMIO; cacheable đi qua CCU và LLC. Bộ kiểm tra bảng hằng đánh dấu vùng chồng lấn, class sai (kể cả `[31:2]` khác 0), length bằng 0, overflow, nhiều vùng cacheable hoặc số entry sai bằng `o_config_valid=0`; mỗi access được decode sau đó báo lỗi cục bộ. RTL không ép elaboration thất bại. Luồng build SoC phải coi bảng sai là lỗi cấu hình trước synthesis và bảo đảm cùng parameter được đưa tới PMA, router và cửa sổ LLC. Atomic cacheable thực hiện tại L1 coherent theo DEC-038; normal-uncached dùng dịch vụ AXI4+ATOP; atomic tới MMIO bị từ chối trước fabric ngoại vi. Profile AXI vẫn yêu cầu SoC/software quản lý cache visibility cho DMA.

**AXI4 / AXI4-Lite.** VALID lên thì payload giữ ổn định tới READY. AXI4 không có WID; write data theo thứ tự AXI4. ID gắn response với request. AW và W của AXI4-Lite độc lập; B chỉ trả sau khi cả hai được nhận. Không cam kết latency cố định. Địa chỉ nội bộ chưa ánh xạ trả DECERR; misaligned hoặc partial write bị cấu hình từ chối trả SLVERR. WSTRB=0 không thay đổi dữ liệu ở mode HONOR.

**ACE.** Top ACE phải hỗ trợ đủ channel full ACE theo transaction subset công bố. Chỉ nhận AC snoop khi có thể giữ yêu cầu nội bộ; CR/CD và response đọc/ghi tuân handshake. RACK sau beat đọc cuối được nhận; WACK sau write response được nhận. Adapter phải phân xử truy cập cùng cache line và bảo toàn dirty data. Tập giá trị ARSNOOP/AWSNOOP/DOMAIN/BAR, DVM, atomic và ordering phải được chốt khi thiết kế adapter; không thể suy ra từ việc port tồn tại.

| Case | Legal behavior | Illegal / unsupported case | IP response | Requirement IDs |
|---|---|---|---|---|
| AXI4 normal read/write | Aligned supported burst; VALID/READY handshake; ID returned with response | Unsupported burst or response error | Preserve response code and association; no fabricated success | REQ-IF-002, REQ-ERR-001 |
| AXI4 backpressure | Payload remains stable while stalled | Payload changes while VALID and not READY | Protocol violation; checker failure | REQ-IF-005 |
| AXI4-Lite CSR | Aligned 32-bit access; WSTRB honored | Unmapped window or misaligned CSR address | DECERR for unmapped; SLVERR for misaligned | REQ-IF-001, REQ-IF-007 |
| AXI-only DMA sharing | Software clean/invalidate/fence sequence per SoC policy | External DMA accesses dirty cache data without maintenance | Outside hardware-coherent guarantee; system must prevent/use maintenance | REQ-IF-003 |
| ACE snoop | Supported snoop arrives through AC and is answered through CR/CD | Unsupported snoop value or no available tracking resource | Backpressure AC; never drop; exact unsupported response is DEP-002 | REQ-IF-004 |
| ACE completion | RACK/WACK indicates the accepted completion point | Acknowledge before final data/response handshake | Protocol violation | REQ-IF-004 |

### 6.4 Interrupts and events

| Signal/event | Polarity | Assert condition | Clear/deassert condition | Mask/priority | Crossing | Reset state |
|---|---|---|---|---|---|---|
| i_int_msip/stip/mtip/meip/ssip/seip | Active high | Driven by platform for each hart | Platform deasserts source | Platform owns priority | Must be synchronous to CLK-CLUSTER or synchronized externally | Low |
| o_int_pmu | Active high | Any enabled sticky PMU cause is pending | Software clears cause through CSR; deassert after no enabled causes remain | Aggregate, no internal hart priority | CLK-CLUSTER | Low |
| o_int_fault | Active high | Ordinary dirty-eviction writeback failure, DEC-036 | Cluster reset; CSR access does not resume the failed transaction | Separate from PMU masking | CLK-CLUSTER; SoC routes to its fault/interrupt controller | Low |
| ACE snoop/error event | Internal event | Selected event source occurs | Counter/CSR policy | PMU selector and enable | CLK-CLUSTER | Clear on reset |
| AXI/ACE protocol error event | Internal event | Error response or adapter violation | Sticky status clear policy in CSR | PMU/fault status policy | CLK-CLUSTER | Clear on reset |

## 7. Clock, reset, and power

### 7.1 Clock domains

| Domain | Clock port | Edge | Frequency range | Source | Relationship to other clocks | Gating policy |
|---|---|---|---|---|---|---|
| CLK-CLUSTER | i_clk_cluster | Rising | No numeric limit supplied | SoC clock controller | One synchronous domain for core, AXI, ACE, AXI4-Lite | Clock gating only by SoC-approved integrated clock-gating cells; not part of functional CSR |

The AXI4/ACE/AXI4-Lite peers shall be synchronous to CLK-CLUSTER in this version. If a peer uses another clock, the SoC inserts a protocol-compliant CDC bridge outside the cluster and verifies it separately.

### 7.2 CDC and RDC

| Crossing ID | From → to | Signals | Structure | Reset handling | Constraints / verification |
|---|---|---|---|---|---|
| CDC-001 | External AXI/ACE fabric ↔ cluster | AXI/ACE channels | Same-clock assumption; otherwise external CDC bridge | Bridge owns reset sequencing | CDC analysis on SoC wrapper |
| CDC-002 | External Debug Module ↔ cluster | Per-hart debug request/status | Same-clock level interface or SoC synchronizer; exact DM clock relation is DEP-006 | No unsynchronized pulse crossing | CDC review |
| CDC-003 | Platform interrupt source → hart | Six interrupt vectors | Source synchronized before cluster boundary | Platform reset contract | CDC/RDC and interrupt tests |
| RDC-001 | SoC reset controller → cluster | i_rst_n_cluster | Synchronous deassertion supplied by SoC | Active-low assertion | Reset-domain analysis |

No internal asynchronous clock domain is defined. DTM TCK and DMI are outside this IP.

### 7.3 Reset domains and sequencing

| Reset ID | Port | Polarity / assertion | Sync or async | Scope | Deassertion | Reset value |
|---|---|---|---|---|---|---|
| RST-CLUSTER | i_rst_n_cluster | Active-low assertion | Asynchronous assertion permitted | All harts, coherence state, LLC control, CSR, PMU, adapters | SoC guarantees deassertion synchronous to CLK-CLUSTER | Valid/control state zero; generated fields use workbook values |

The reset controller shall hold the cluster in reset until CLK-CLUSTER is stable. Software shall wait for the axi_llc BIST-ready state before using memory paths that the LLC blocks during BIST. Reset aborts outstanding traffic according to the enclosing AXI/ACE system reset contract; the SoC must reset or drain corresponding external agents consistently.

Reset controller giữ IP reset tới khi CLK-CLUSTER ổn định. Software chờ trạng thái BIST-ready của axi_llc trước khi dùng memory path bị BIST chặn. Reset hủy transaction đang chạy theo hợp đồng reset AXI/ACE của SoC; SoC phải reset hoặc drain các agent ngoài nhất quán.

### 7.4 Power intent

No power gating, retention, isolation, or DVFS is included in v1. The implementation may use technology-approved clock gating after the clock/reset and scan methodology are supplied. WFI/power-state behavior must be checked against the pinned CVA6 integration. Power intent is owned by the SoC.

Không có power gating, retention, isolation hoặc DVFS trong v1. Có thể dùng clock gating theo cell/methodology đã duyệt của công nghệ sau khi có clock/reset và scan flow. Hành vi WFI phải đối chiếu với CVA6 commit được pin. SoC sở hữu power intent.

## 8. Parameters and elaboration configurations

| Parameter | Purpose | Default | Legal values / range | Dependencies / invalid combinations | Effect |
|---|---|---:|---|---|---|
| PARA_CPU_NUM | Number of synthesized CVA6 tiles | 4 | 2 or 4 | Other values are illegal | Hierarchy, area, power, active vector bits |
| PARA_COH_TXN_NUM | Number of active tagged coherence transactions and per-cache probe queue entries | 8 | 2–16 | Tag width is `$clog2(PARA_COH_TXN_NUM)`; source cache resources must be audited at endpoints | Independent-line overlap, slot/tag width, queue storage |
| PARA_LLC_WAY_NUM | LLC associativity | 4 | 1–32, subject to axi_llc limits | Static; SPM remains disabled | Capacity and SRAM/tag geometry |
| PARA_LLC_NO_LINES | Lines per LLC way | 4096 | Power of two, greater than 2 | SRAM capacity and physical macro fit | Capacity and address index |
| PARA_LLC_BLOCK_NUM | 64-bit blocks per line | 2 | Power of two, at least 2 | Data width 64; line size = blocks × 8 bytes | LLC line size |
| PARA_PMU_COUNTER_NUM | Number of cluster event counters | 16 | 1–32 | CSR repeated-bank count is passed from this top-level parameter | PMU area, event capacity, verification |
| PARA_PMU_COUNTER_W | PMU counter width | 64 (proposal) | 32 or 64 | 64-bit mode uses snapshot command before reading low/high words | Counter range and CSR mapping |
| PARA_ADDR_REGION_NUM | Number of active address-region entries shared by PMA and router | 1 | 1–16 | Entry 0 is the sole cacheable region; all active entries must be valid and non-overlapping | Address classification and CVA6 PMA configuration |
| PARA_ADDR_REGION_BASE_LO / `_HI` | 16-entry arrays of 32-bit low/high words for each 64-bit physical base | Entry 0 low=`0x80000000`, high=0; other entries zero | Active bases are 16-byte aligned and below `2^56` | Both arrays are passed identically to PMA, router, and LLC configuration | Address comparison and route selection |
| PARA_ADDR_REGION_SIZE_LO / `_HI` | 16-entry arrays of 32-bit low/high words for each 64-bit byte length | Entry 0 low=`0x40000000`, high=0; other entries zero | Active sizes are non-zero 16-byte multiples; entry 0 is a power of two | `base + size` shall not exceed `2^56`; inactive indices are ignored | Address comparison and PMA range generation |
| PARA_ADDR_REGION_TYPE | 16-entry array of 32-bit words; bits `[1:0]` encode class and `[31:2]` must be zero | All entries zero | `00` cacheable, `01` normal uncached, `10` MMIO; `11` or nonzero upper bits make the table invalid | Exactly entry 0 is cacheable; MMIO entries map to CVA6 non-idempotent PMA rules | PMA attributes and AXI destination |

Fixed interface widths from the selected CVA6 package and user decisions: CVA6 physical addresses are 56 bits (`PLEN=56`) and are zero-extended onto the 64-bit AXI memory/peripheral address ports; AXI data is 64 bits and AXI ID is 4 bits; AXI4-Lite address/data are 32 bits with 4-bit strobes; L1/LLC lines are 16 bytes. These widths are not user-overridable RTL parameters in this revision.

Độ rộng cố định theo cấu hình CVA6 đã chọn và các quyết định của người dùng: địa chỉ vật lý CVA6 rộng 56 bit (`PLEN=56`), được mở rộng bằng 0 lên cổng địa chỉ AXI 64 bit; dữ liệu AXI rộng 64 bit và AXI ID rộng 4 bit; địa chỉ/dữ liệu AXI4-Lite rộng 32 bit, strobe 4 bit; cache line L1/LLC dài 16 byte. Các độ rộng này không phải parameter để người dùng thay đổi trong phiên bản này.

### AXI data-width feasibility / Khả năng cấu hình độ rộng dữ liệu AXI

The current CVA6 → HPDcache → LLC datapath remains natively 64-bit. The external AXI memory port is adapted by `m_vlsit_riscv_axi_dw_adapter`; its `PARA_AXI_MEM_DATA_W` parameter supports 32/64/128/256-bit buses while preserving the 64-bit LLC side. The MMIO AXI port remains 64-bit; no MMIO width converter is included. Keep AXI4-Lite control fixed at 32-bit. Full cluster-level response/error and burst verification remains open.

Datapath CVA6 → HPDcache → LLC giữ nguyên độ rộng nội bộ 64-bit. Cổng AXI memory ngoài được chuyển đổi bởi `m_vlsit_riscv_axi_dw_adapter`; parameter `PARA_AXI_MEM_DATA_W` hỗ trợ bus 32/64/128/256-bit và giữ nguyên giao diện phía LLC 64-bit. Cổng AXI MMIO vẫn 64-bit; chưa có converter độ rộng MMIO. AXI4-Lite điều khiển giữ cố định 32-bit. Kiểm chứng response/lỗi/burst ở cấp cluster vẫn còn mở.

| Candidate external AXI data width | 16-byte coherent line data beats | Compatibility with the current native datapath | Assessment |
|---:|---:|---|---|
| 32 bits | 4 beats | Not a direct HPDcache width: 32-bit memory data is narrower than the selected 64-bit request word. A 64→32 downsizer after the 64-bit LLC is required. | Feasible as an external-port candidate; doubles the data beats per line versus 64-bit. Verify all burst, response, ID, strobe, and ATOP behavior. |
| 64 bits | 2 beats | Native selected configuration for CVA6, HPDcache, and LLC. | Baseline; lowest integration risk. |
| 128 bits | 1 beat | Directly changing LLC width also changes its minimum line size: `NumBlocks>=2` gives at least 32 bytes. Retain the 16-byte coherent line by keeping the internal LLC at 64-bit and adding a 64→128 upsizer externally. | Feasible as a candidate; can combine two 64-bit beats into one 128-bit beat when transaction shape permits. Verify ATOP and burst mapping. |
| 256 bits | 1 narrow 16-byte beat | Direct LLC configuration requires at least a 64-byte line (`NumBlocks>=2`); this does not match the 16-byte L1/directory coherence granule. A boundary converter avoids changing internal line geometry. | Feasible only as an external candidate. A single 16-byte line uses half a 256-bit beat; full-width utilization needs adjacent-line coalescing or a redesigned line/sector architecture. |

The AXI memory boundary now has synthesis-time parameter `PARA_AXI_MEM_DATA_W`, default 64 and legal values `{32, 64, 128, 256}`. The LLC-side interface remains 64-bit; `m_vlsit_riscv_axi_dw_adapter` wraps the pinned PULP `axi_dw_converter` without modifying upstream RTL. The structural top instantiates this adapter, and directed leaf tests pass for all four widths; the cluster core and LLC connection are still incomplete. The AXI MMIO width remains 64-bit. The converter must preserve 6-bit AWATOP semantics, IDs, ordering, and B/R error association. The pinned PULP width converter has burst-type limitations: supported burst behavior and error mapping still require end-to-end verification before SoC signoff. See REF-001, REF-004, REF-005, REF-008, and REF-015.

Biên AXI memory có parameter synthesis-time `PARA_AXI_MEM_DATA_W`, mặc định 64 và nhận các giá trị `{32, 64, 128, 256}`. Giao diện phía LLC vẫn là 64-bit; `m_vlsit_riscv_axi_dw_adapter` bọc PULP `axi_dw_converter` đã pin, không sửa RTL upstream. TOP cấu trúc đã instantiate adapter và mô phỏng leaf pass ở cả bốn độ rộng; cluster core và kết nối LLC vẫn chưa hoàn thành. Độ rộng AXI MMIO vẫn là 64-bit. Converter phải giữ AWATOP 6-bit, ID, thứ tự và ghép đúng B/R response. PULP width converter đã pin có giới hạn burst: vẫn cần kiểm chứng end-to-end hành vi burst được hỗ trợ và ánh xạ lỗi trước khi signoff SoC. Tham khảo REF-001, REF-004, REF-005, REF-008 và REF-015.

For a one-line transfer with no stalls, the data-channel lower bound is `beats = ceil(16 bytes / (W/8))`: 4, 2, 1, and 1 beat for 32, 64, 128, and 256-bit external buses respectively. This is not a transaction-latency guarantee; address, response, arbitration, converter buffering, and backpressure add time. Keep 64-bit as the default; select another legal width only after the SoC confirms an ATOP-capable fabric and end-to-end validation passes.

Với một lần truyền một cache line và không stall, số beat dữ liệu tối thiểu là `ceil(16 byte / (W/8))`: tương ứng 4, 2, 1 và 1 beat cho bus ngoài 32, 64, 128 và 256-bit. Đây không phải cam kết latency giao dịch; địa chỉ, response, phân xử, buffer converter và backpressure làm tăng thời gian. Giữ 64-bit làm mặc định; chỉ chọn độ rộng khác khi SoC xác nhận fabric hỗ trợ ATOP và kiểm chứng end-to-end pass.

The default LLC capacity is calculated as follows:

1. One AXI data block = 64 bits ÷ 8 = 8 bytes.
2. One LLC line = PARA_LLC_BLOCK_NUM × 8 bytes = 2 × 8 = 16 bytes.
3. One way = PARA_LLC_NO_LINES × 16 bytes = 4096 × 16 = 65,536 bytes = 64 KiB.
4. Total = PARA_LLC_WAY_NUM × 64 KiB = 4 × 64 KiB = 256 KiB.

Dung lượng LLC mặc định:

1. Một block AXI = 64 bit ÷ 8 = 8 byte.
2. Một line = 2 block × 8 = 16 byte.
3. Một way = 4096 line × 16 = 65.536 byte = 64 KiB.
4. Tổng = 4 way × 64 KiB = 256 KiB.

| Configuration | Parameter overrides | Features/interfaces | Expected hierarchy | Elaboration target |
|---|---|---|---|---|
| CFG-AXI-2 | CPU=2; LLC=4×4096×2; PMU=16×64 | AXI memory + MMIO + AXI-Lite | Two tiles, AXI top | Lint/elaboration |
| CFG-AXI-4 | CPU=4; LLC=4×4096×2; PMU=16×64 | AXI memory + MMIO + AXI-Lite | Four tiles, AXI top | Lint/elaboration |
| CFG-ACE-2 | CPU=2; LLC=4×4096×2; PMU=16×64 | Future ACE memory + MMIO + AXI-Lite | Deferred; not current RTL | Future-phase elaboration |
| CFG-ACE-4 | CPU=4; LLC=4×4096×2; PMU=16×64 | Future ACE memory + MMIO + AXI-Lite | Deferred; not current RTL | Future-phase elaboration |

Illegal parameter values must fail the project elaboration check before synthesis. This draft does not prescribe a simulation-only initial block in synthesizable RTL; a static configuration checker is an acceptable enforcement method.

## 9. Data representation and arithmetic

| Quantity | Width | Encoding / range | Extension / truncation | Overflow / invalid behavior |
|---|---:|---|---|---|
| Hart index | 2-bit vector index | 0 through PARA_CPU_NUM−1; zero-based | No extension at cluster vectors | Bits beyond active count ignored |
| CVA6 physical address | 56 | Unsigned byte address (`PLEN=56`) | Zero-extend to 64-bit AXI address; no truncation | Address decode is SoC map dependent |
| AXI data | 64 | Unsigned data; byte lane 0 is bits [7:0] | WSTRB has 8 lanes | Bus response reports failure |
| AXI4-Lite data | 32 | Unsigned CSR word; little-endian byte lanes | WSTRB has 4 lanes | Misaligned/invalid access follows Section 6.3 |
| Cache line | 128 bits | 16 bytes; two 64-bit beats | Address alignment is 16 bytes | Coherence identity is full physical line address |
| PMU counter | 32 or 64 | Unsigned modulo counter | Event adds one count per qualified event | Wrap sets sticky overflow cause |
| AXI/ACE response | 2 bits AXI; 4-bit ACE RRESP | Protocol-defined response encoding | No reinterpretation | Error passed to originator |

All signals are unsigned bit vectors in the VLSIT RTL. The selected memory system uses little-endian byte lanes. No signed RTL arithmetic is permitted. A 64-bit PMU read requires a prior snapshot; the low and high words then represent the same captured count.

Mọi tín hiệu là vector unsigned theo rule VLSIT; byte lane theo little-endian. Không dùng signed arithmetic trong RTL. Khi counter 64 bit, phần mềm yêu cầu snapshot trước, rồi low/high biểu diễn cùng giá trị đã chụp.

## 10. Detailed functional behavior

### 10.1 Modes and state transitions

| Mode/state | Entry condition | Behavior | Exit condition | Outputs / side effects |
|---|---|---|---|---|
| Reset | i_rst_n_cluster asserted | Clear protocol-valid/control, coherence transient state, PMU control and CSR state | Reset released synchronously to clock | Outputs inactive |
| LLC initialization | Reset release; axi_llc BIST active | Wait for BIST completion; do not report LLC ready early | BIST done/status valid | LLC status becomes readable |
| Normal coherent operation | Reset released and LLC ready | Harts issue cacheable requests; internal coherence resolves ownership | Reset or system quiesce | Responses follow request and protocol |
| AXI profile operation | CFG-AXI top selected | External memory transactions are AXI4+ATOP; MMIO transactions are AXI4; no external snoop acceptance | Reset/reconfiguration before synthesis | Software maintains external-DMA cache visibility |
| Future ACE profile operation | Separate future phase approved | External ACE requests/snoops use a future proxy | Not active in this RTL phase | No current implementation claim |
| PMU counting | Counter enabled and selected source event occurs | Selected event increments modulo 2^W | Disable, reset, or counter configuration change | Overflow cause becomes sticky |
| PMU snapshot | Software requests snapshot | Capture all configured counter values atomically; hold until next snapshot | New snapshot or reset | Snapshot-done/status visible; software reads stable words |
| LLC flush | Software starts flush through LLC service window | Follow axi_llc flush sequencing; do not claim completion before status says done | Flush completion/error | Dirty lines are written back per axi_llc |

### 10.2 Operations

| Operation ID | Operation | Preconditions | Observable result | Latency / throughput contract |
|---|---|---|---|---|
| OP-001 | Cluster reset and boot | Stable cluster clock; reset controller releases reset | Active harts leave reset with unique zero-based IDs; software boot sequence is SoC-owned | No boot latency target specified |
| OP-002 | Cacheable memory access | LLC ready; request addresses normal memory | Internal coherence, then private/shared cache or selected external profile services request | No numeric latency target |
| OP-003 | Non-coherent peripheral access | Address decoded as device/MMIO region | AXI4 MMIO transaction and associated response | AXI backpressure permitted; no fixed latency |
| OP-004 | External DMA shared-memory access in AXI profile | Software/SoC performs required cache maintenance | AXI4+ATOP memory traffic with no external snoop service | Correctness depends on system maintenance sequence |
| OP-005 | Future external coherent access | Future ACE profile approved and externally verified | ACE snoop/request/response path preserves latest permitted data | Deferred; not a current AXI-phase operation |
| OP-006 | PMU event counting and snapshot | Event source is implemented; counter is enabled | Counter increments, snapshot freezes a consistent read image | One snapshot command; no cycle bound until RTL design |
| OP-007 | LLC BIST and flush | Software uses LLC control target; no prohibited concurrent reconfiguration | Status reports busy/done/error; SPM remains disabled | BIST/flush duration depends on macro geometry |
| OP-008 | Per-hart debug | External Debug Module is connected and target hart exists | Requested hart enters debug and reports mode; other harts are unaffected | Debug timing depends on CVA6 and DM integration |
| OP-009 | Zicbom cache-block maintenance | CBO is permitted by CVA6 privilege/CBIE controls; target memory is stable against concurrent non-coherent DMA for the operation interval | CLEAN writes dirty data through LLC to memory; FLUSH cleans then invalidates; INVAL follows the CBIE-decoded invalidate/flush behavior; writeback errors fault before CBO retirement | Waits for probes, AXI responses, and backpressure; no fixed latency |
| OP-010 | Hart-local `FENCE.I` instruction-fetch synchronization | Older stores have reached the local cache hierarchy; the executing hart is not being reset | On success, dirty local D-cache lines reach the shared LLC, then local I-cache/fetch state is invalidated and the fence retires; on L1-to-LLC B error, preserve the failed M line/directory holder, finish ABORT, raise synchronous cause 24 with the aligned physical line base, and suppress fence retirement and local fetch invalidation; no LLC-to-DRAM writeback | Success or fault waits for the D-cache scan, owner B responses, and any ABORT acknowledgements; no fixed latency |

Operations are defined from the IP contract and standards, not from generated RTL. Latency values not yet measured are intentionally left open.

### 10.2.1 Internal D-cache MESI protocol

The current cluster keeps I-caches outside the coherence domain and applies MESI to each private D-cache. The selected design uses a sharer directory and tagged local probe transactions. The directory stores a conservative set of active D-caches that may hold each physical line; the CCU targets only those recorded holders, not every active hart. A stale extra holder bit is safe only if the probe resolves it; a missing holder bit is forbidden because it can expose stale data or conflicting ownership.

| Stable state | Meaning | Read hit | Write/AMO hit |
|---|---|---|---|
| I — Invalid | This cache has no usable line copy. | Read miss; request shared access. | Write miss; request unique ownership and line data. |
| S — Shared | Clean copy; the LLC contains the current line. Other caches may also hold S. | Return locally; remain S. | Request unique ownership; invalidate all peer copies, then enter M before committing the store/AMO. |
| E — Exclusive | Clean copy; no other D-cache holds the line. The LLC is current. | Return locally; remain E. | Change locally to M and commit; no peer probe is needed. |
| M — Modified | Sole owner; this copy may be newer than the LLC and external memory. | Return locally; remain M. | Return/update locally; remain M. |
| Request / event | Peer action | Data source and completion condition | Requester / owner stable state after completion |
|---|---|---|---|
| Read miss, directory has no holder | No peer probe is issued. | Grant E permission; the requester's HPDcache obtains all 16 bytes from LLC, using AXI4 on an LLC miss. The CPU load completes after refill. | Requester is recorded as a possible E holder at grant |
| Read miss, one or more clean holders have S/E | Probe only recorded holders with the transaction tag; E owner downgrades to S; S holders remain S. | Grant S permission after matching responses and COMMIT; the requester's HPDcache refills from current LLC data and then completes the CPU load. | Requester is recorded as a possible S holder at grant; existing holders S |
| Read miss, a recorded holder has M | PREPARE the recorded owner. Owner writes the latest 16-byte line to LLC through its own AXI writeback path; after successful B response, COMMIT changes the owner M→S. The requester then refills from LLC through its normal HPDcache AXI path. | Grant S permission only after owner writeback and COMMIT ACK. The CPU load completes after the requester's refill; a probe arriving during refill waits for the same-line miss to stabilize. A B error fails PREPARE and triggers ABORT. | Requester is recorded as a possible S holder at grant; former M owner S |
| Write miss / AMO miss | PREPARE and invalidate only the recorded holders other than the requester. An M holder first writes its latest line through its own AXI path. After all COMMIT ACKs, the requester receives M permission and refills through its normal HPDcache AXI path. | Grant unique permission only after successful owner writeback and matching invalidation COMMIT acknowledgements. A same-line probe waits for an admitted refill to stabilize; the CPU operation completes after refill. | Requester is recorded as a possible M holder at grant; all other holders I |
| S-to-M upgrade / AMO hit in S | Invalidate only recorded holders other than the requester. DEC-038 retains the clean S copy while awaiting unique permission, then performs a preparatory refill; older probes may complete before that grant. | Grant unique ownership after all matching invalidation responses. Hold same-line serialization through refill/replay and the AMO update/response. | Requester M; all other holders I |
| E-to-M store | No peer probe. | Local state transition, then store commits. | Owner M |
| Dirty M eviction / explicit clean-invalidate | Owner sends the full line to the LLC and invalidates only after LLC accepts the writeback; the matching directory holder bit is then cleared. | Two 64-bit data beats for the 16-byte line; external AXI writeback occurs if the LLC later evicts it. | Owner I; LLC has current data; directory no longer lists the owner |

The local probe subset is limited to the read-sharing, unique-ownership/invalidation, and clean-invalidate behaviors needed above. DVM and external ACE transactions are outside the current AXI RTL phase. The exact packed port records and response encodings must be mapped to the pinned source revision before RTL generation; protocol-level outcomes in this table are normative even if an internal port uses different record names.

### 10.2.3 System-wide Zicbom maintenance

The selected CVA6 configuration enables Zicbom. CBO operations shall not use HPDcache's local per-line CMO path because that path would bypass other L1 D-cache holders, the CCU directory, and dirty data in the LLC. CVA6 resolves privilege and CBIE behavior before a legal operation reaches the CMO controller; the cluster shall preserve the resolved operation. For enabled lower-privilege execution, CBIE=01 selects FLUSH behavior and CBIE=11 selects invalidate unless an enclosing privilege setting requires FLUSH; CBIE=00 disables the operation at that privilege level, and reserved encodings are not accepted as configuration. A true resolved invalidate locks and invalidates matching copies without writeback, so dirty data may be discarded; software must clean first when those bytes must be preserved. A resolved FLUSH follows the writeback path. RISC-V permits an implementation to flush instead of invalidating; this design selects true invalidation when the resolved operation is invalidate. RISC-V defines clean as transferring modified data to another cache or memory, flush as clean followed by invalidate, and invalidate as deallocating copies. CLEAN/FLUSH operations cover the coherent cache hierarchy to the common point used by non-coherent agents. The selected cluster treats external memory as that common point. [REF-012](#22-references-used-to-shape-this-specification)

| Operation reaching the CMO controller | L1 D-cache action | LLC action | Completion condition |
|---|---|---|---|
| `CBO.CLEAN` | Lock the line; if an M owner exists, write all 16 bytes through that owner's normal HPDcache AXI writeback path. Keep M and the line lock until commit. On success, M becomes E; clean S/E copies remain valid. | Per-line lookup without refill. If valid and dirty, write all 16 bytes to memory. Keep the tag valid and clear dirty only on successful memory B; a miss or clean hit is a no-op. | Owner-to-LLC B and LLC-to-memory B succeed, then cache state and directory commit. |
| `CBO.FLUSH` | Lock and prepare every directory holder. Write back an M owner as above. Invalidate all L1 D-cache copies only after the LLC reports successful clean-to-memory. | Per-line lookup without refill. Write dirty data to memory; invalidate the LLC tag only after successful B. A miss is a no-op. | All required probes and writebacks succeed, L1 invalidations commit, and directory holder metadata is updated. |
| `CBO.INVAL` decoded as invalidate | Lock and prepare every holder without owner writeback; invalidate all L1 D-cache copies only at COMMIT. Dirty data may be discarded under true-invalidate semantics. | Invalidate a matching LLC tag without writeback; do not refill. | All required probe acknowledgements and LLC invalidation complete; directory becomes empty for the line. No memory B response is required. |
| `CBO.INVAL` decoded as flush by CBIE | Same behavior as `CBO.FLUSH`. | Same behavior as `CBO.FLUSH`. | Same behavior as `CBO.FLUSH`. |

For CLEAN/FLUSH and INVAL-as-FLUSH, the CCU first prepares the line and retains its line lock. A dirty L1 M owner writes the full line to LLC; the CCU waits for that exact owner B response. The LLC then performs its per-line memory writeback and returns status. Only after both stages succeed may the CCU send COMMIT and update L1/directory state. If either B response is an error, the CCU sends ABORT to all prepared L1 holders, keeps their prior stable MESI states, and does not grant another requester. If the owner writeback reached LLC but the later DRAM write failed, the L1 owner remains M and the LLC must retain its updated dirty line; those copies may temporarily contain identical data, with M remaining authoritative. For true INVAL, PREPARE only locks and records the holders; an M owner keeps its dirty line without writing it back, and COMMIT invalidates L1 and LLC copies. This path has no writeback B response. Software must clean data first when it must preserve dirty bytes before true invalidation.

The CCU must serialize CMO with CPU coherence activity for the same physical line. Different lines may continue subject to the existing transaction, bank, cache, LLC, and AXI limits. The external DMA interface is non-coherent: the SoC/software must stop or order concurrent DMA accesses to the target line while CMO is in progress. CBO completion provides the visibility operation; it does not arbitrate a non-coherent agent that bypasses the cluster.

The selected CVA6 configuration sets `DcacheFlushOnFenceI=1` because the separate I-cache is not coherent with the D-cache. A local `FENCE.I` scans that hart's D-cache and uses the CCU to transfer each dirty M line through the owner's HPDcache AXI path into the shared LLC. The CCU waits for the successful L1-to-LLC B response, then commits the owner from M to E while retaining the directory holder. It shall not request an LLC-to-external-memory writeback for this instruction-fetch synchronization; the latest line must be available at the LLC refill point. After the D-cache walk completes, invalidate the executing hart's I-cache and fetch pipeline, then complete `FENCE.I`. This operation is local to one hart; software must notify every other hart that will execute the modified code and have each one execute its own `FENCE.I`. On a non-OKAY L1-to-LLC B response, preserve the failed line's M/directory state, complete ABORT, and raise the precise cause-24 maintenance exception defined in REQ-MEM-018/DEC-031; do not retire the fence or invalidate local fetch state. The trap-path implementation remains DEP-021. No latency bound is defined.

Precise CBO failure handling is part of the architectural contract. The commit stage holds the CBO at the retirement head while older stores reach the cache hierarchy and the CMO transaction runs. The CBO itself cannot retire on request acceptance. For CLEAN, FLUSH, and INVAL-as-FLUSH, an owner or LLC writeback error returns a completion error to CVA6; commit logic waits for all required ABORT acknowledgements, then raises the Store/AMO access fault before retirement and uses the retained CBO PC/effective address for trap state. True INVAL does not perform writeback and cannot take this writeback-error path. This maps the cluster's reported CMO writeback failure to the Store/AMO access-fault exception; the CMO operation and faulting effective address follow REF-012. For example, hart 2 executes `CBO.CLEAN` at PC `0x8020_1040` using effective address `0x9000_0007`; after owner writeback succeeds but the LLC receives `SLVERR`, the cluster holds that CBO, waits for all ABORT ACKs, then traps with Store/AMO access fault code 7, `mepc/sepc=0x8020_1040`, and `mtval/stval=0x9000_0007`. No CBO or younger instruction retires, and the dirty owner line remains recoverable. The error path must not issue the same CBO twice after exception entry.

FENCE.I failure is distinct from a CBO fault. Its success path waits only for L1-to-LLC acceptance, not for LLC-to-DRAM completion. If an L1-to-LLC B response is non-OKAY, the owner line remains dirty and the fence cannot retire. The CCU sends ABORT and waits for all required acknowledgements with no timeout; it preserves the failed line's M state and directory holder. Only after ABORT completes does CVA6 raise a precise synchronous maintenance exception with exception code 24 in `mcause` or `scause`, according to the selected trap privilege. The corresponding `mepc` or `sepc` shall contain the faulting `FENCE.I` PC; the corresponding `mtval` or `stval` shall contain the aligned physical base address of the failed line. No younger instruction retires, and local I-cache/fetch invalidation is not performed for the failed fence. The handler may resolve the underlying write-path error and return to the saved PC to retry. Exception code 24 is a cluster-defined use of the custom exception range (REF-014); the address value and recovery sequence are product-specific contracts, not behavior prescribed by the ISA.

**Directory correctness and geometry.** A directory lookup uses the physical cache-line address and returns a conservative holder bitmap. The directory is independent of and non-inclusive with the LLC. It has eight ways and four banks. The total set counts across all banks are 512 for two harts and 1,024 for four harts, giving 4,096 and 8,192 total entries; each bank therefore has 128 or 256 sets, respectively. The bank is selected by the two least-significant line-address bits; for a 16-byte line, `line_addr[1:0]` is physical-address `[5:4]` (not physical-address `[1:0]`). Each bank accepts at most one eligible lookup/update/cancel operation per cycle; different banks may progress concurrently, and same-bank conflicts serialize. Each bank uses round-robin arbitration across eligible transaction slots; a valid but ineligible slot does not consume a grant or hold the array port. Each set stores seven tree-PLRU bits, reset to zero; bit 0 selects the left child and bit 1 the right child on a victim walk. A successful committed lookup/allocation updates each traversed bit to point away from the accessed way. Select the lowest-index invalid way before replacement; for a full set, follow the seven bits from root to leaf. If that victim is locked/reserved or its holder transaction cannot obtain a context, keep the request pending and continue serving other eligible operations in the bank. The holder bitmap is set when a permission grant commits, so an admitted but incomplete refill is conservatively tracked as a possible holder; it is cleared only after the matching cache transition commits. A stale positive indication may cause an extra probe, but a false negative is forbidden. LLC eviction alone shall not invalidate a private D-cache line or remove its directory entry. On directory set replacement, the selected victim entry remains allocated while every recorded holder is prepared for invalidation, any M owner completes writeback through its AXI path, and all cache invalidations commit; only then may the directory reuse that way. Replacement shall not lose a holder or dirty data.

**Tính đúng đắn và hình học directory.** Lookup dùng địa chỉ cache-line vật lý và trả bitmap holder theo hướng bảo thủ. Directory độc lập, không bao hàm trong LLC. Cấu hình có tám way và bốn bank. Tổng số set trên bốn bank là 512 ở cấu hình hai hart và 1.024 ở cấu hình bốn hart, tương ứng 4.096 và 8.192 entry; mỗi bank có 128 hoặc 256 set. Bank được chọn bằng hai bit thấp nhất của địa chỉ line; với line 16 byte, `line_addr[1:0] = physical_address[5:4]`, không phải bit địa chỉ vật lý `[1:0]`. Mỗi bank cấp tối đa một thao tác đủ điều kiện mỗi chu kỳ bằng bộ phân xử round-robin trên các slot transaction đang hoạt động; sau mỗi lần cấp, con trỏ chuyển sang slot kế tiếp. Các bank khác nhau có thể tiến song song, còn xung đột cùng bank được phân xử công bằng theo thứ tự vòng. Mỗi set lưu bảy bit tree-PLRU, khởi tạo bằng 0; khi lần theo cây chọn victim, bit 0 chọn nhánh trái và bit 1 chọn nhánh phải. Access/cấp phát đã commit cập nhật từng bit trên đường đi để trỏ ra xa way vừa truy cập. Trước khi dùng PLRU, chọn way invalid có index thấp nhất; nếu cả tám way hợp lệ thì lần theo bảy bit từ gốc tới lá. Nếu victim đang bị khóa/đặt trước hoặc chưa lấy được transaction context, request vẫn chờ và thao tác đủ điều kiện khác trong bank có thể tiếp tục. Bitmap holder chỉ được set khi cache grant commit và chỉ được clear sau khi transition cache tương ứng commit. Holder thừa có thể gây probe dư nhưng không được bỏ sót holder. LLC eviction không được invalidate D-cache riêng hoặc xóa entry directory. Khi thay set, giữ entry victim cho tới khi mọi holder được prepare để invalidate, dữ liệu M được LLC chấp nhận và mọi invalidate cache đã commit; sau đó mới tái sử dụng way. Không được làm mất holder hoặc dirty data khi thay thế.

**Tagged concurrency.** The CCU shall maintain `PARA_COH_TXN_NUM` contexts, default 8 and legal from 2 through 16. The tag is the allocated context slot index; its width is `max(1, ceil(log2(PARA_COH_TXN_NUM)))`. A slot/tag cannot be reused until all responses from its prior use have drained. Every context tracks the physical line lock, requester, target-holder mask, prepare mask, commit/abort mask, dirty-owner writeback status, owner AXI B-response status, LLC/refill status, and completion/error status. The tag and target hart index associate each probe response. Internal tags are separate from external AXI IDs. Same-line requests serialize and re-check the directory after the prior transaction finishes. Independent lines may overlap subject to the four directory banks, cache resources, LLC, and AXI.

**Two-phase probe and recovery.** PREPARE reserves the target line in each selected cache and waits for an accepted same-line miss/refill to reach a stable point. The cache reports its stable MESI state and status, not line data. If the target is M, its existing flush engine reads the complete 16-byte line from the cache array as two 64-bit words and writes them through that hart's existing AXI path; PREPARE completes only after the matching B response. Stable MESI remains M and the owner line stays locked through COMMIT or ABORT. The CCU may begin COMMIT only after all targeted PREPARE responses and required writebacks succeed. COMMIT names the target stable state (`S` for read sharing, `I` for invalidation); a cache applies it and acknowledges. The CCU waits for all acknowledgements, commits the directory holder set, grants permission to the requester, and releases the transaction line lock. A grant is permission for the requester's existing HPDcache miss path to refill from LLC; it is not the CPU load/store completion. The requester is recorded as a possible holder at grant, so a later same-line probe waits for an admitted refill to become stable before responding. COMMIT is idempotent so a delayed acknowledgement cannot cause a second state transition. If an owner B response or another operation fails before COMMIT, the CCU reports a failed transaction, sends ABORT to every selected target and waits for all ABORT acknowledgements; targets release their locks with their original stable states intact. In particular, an M owner remains the authoritative copy after a failed writeback. There is no acknowledgement timeout in any phase. Until all targeted PREPARE ACKs arrive, the CCU holds the line lock and transaction slot, leaves the directory unchanged, and sends neither COMMIT nor requester grant. Before COMMIT, an error sends ABORT to every targeted cache; the CCU retains the lock and slot until all ABORT ACKs arrive, while each cache that accepts ABORT releases its local lock and preserves its old stable MESI state. After COMMIT begins, rollback is prohibited. Until all COMMIT ACKs arrive, the CCU keeps the lock and slot, leaves directory metadata unchanged, and withholds the requester grant. A missing ACK in PREPARE, COMMIT, or ABORT may stall that line indefinitely; different-line transactions may progress only with independent slots and resources. Cluster reset is the only recovery. Cluster reset clears all private-cache valid bits and directory valid bits, so no dirty state is claimed to survive reset.

**Same-line arbitration and refill races.** The CCU locks the physical cache-line address for an accepted ownership transaction. A cache shall finish or cancel its already accepted miss/refill for that line before servicing the tagged probe; the CCU shall not grant a competing request for the locked line. After the cache reports the line stable, the probe is serviced and new same-line CPU requests remain blocked until the matching response and, for an M owner, the owner AXI writeback B response complete. The CCU shall collect exactly one status response from every targeted cache for that transaction tag. A missing response holds the transaction; it is never treated as an implicit miss.

**Probe concurrency.** Up to `PARA_COH_TXN_NUM` distinct-line transactions can own contexts concurrently. A per-cache probe queue can hold one probe for each active context, but each D-cache services only one probe at a time because its shared tag/data-array path is single-probe. Probes to different lines may queue without globally freezing unrelated CPU hits that do not conflict with cache resources. The lock is line-specific. Four directory banks allow work on different banks to proceed concurrently; same-bank conflicts serialize. Cache-bank conflicts, MSHR pressure, LLC arbitration, and AXI backpressure may also serialize progress. Slot count is a concurrency ceiling, not an IPC or requests-per-cycle guarantee.

**Reset and instruction visibility.** Reset clears coherence transient state but does not preserve dirty D-cache contents. If normal-memory contents must survive a warm cluster reset, software/SoC must quiesce the harts and complete cache clean/flush before asserting reset. I-cache lines are not probed. For self-modifying code, the writer publishes the new bytes, sends the platform-required inter-hart notification, and each executing hart performs `FENCE.I` before fetching the modified address, as required by the RISC-V software contract.

Giao thức hiện tại chỉ coherence các D-cache; I-cache không nhận probe. Directory độc lập với LLC, có 8 way và 4 bank: 4.096 entry cho hai hart, 8.192 entry cho bốn hart. Mỗi bank xử lý tối đa một thao tác lookup/update mỗi chu kỳ; bank khác có thể tiến đồng thời. `PARA_COH_TXN_NUM` mặc định 8, cho phép 2–16 context; tag là chỉ số slot và không được tái sử dụng khi response cũ chưa kết thúc. PREPARE khóa line tại cache đích, chờ miss/refill cùng line hoàn tất và trả MESI hiện tại cùng status, không đổi trạng thái stable. Nếu line ở M, owner giữ M và line lock, ghi đủ 16 byte qua AXI writeback path HPDcache hiện có, rồi chỉ trả PREPARE completion sau B response tương ứng; probe không mang payload dữ liệu. Sau khi mọi PREPARE và writeback cần thiết thành công, COMMIT yêu cầu cache chuyển sang S hoặc I; cache trả ACK sau khi áp dụng. CCU chỉ commit directory, cấp quyền requester và nhả line lock sau mọi COMMIT ACK. Lỗi trước COMMIT phát ABORT và đợi toàn bộ ACK; cache giữ nguyên state trước transaction. Không phase nào có timeout ACK. Trong lúc chờ PREPARE ACK, CCU giữ line lock và transaction slot, không đổi directory, không gửi COMMIT và không cấp quyền requester. Lỗi trước COMMIT gửi ABORT tới mọi cache đích; CCU tiếp tục giữ lock và slot đến khi đủ ABORT ACK. Cache nhận ABORT nhả lock cục bộ và giữ stable MESI cũ. Sau khi COMMIT bắt đầu, không rollback; CCU giữ lock/slot, không đổi directory và không cấp quyền requester đến khi đủ COMMIT ACK. Thiếu ACK ở PREPARE, COMMIT hoặc ABORT có thể làm line bị chặn vô thời hạn. Line khác chỉ tiến khi dùng slot và tài nguyên độc lập. COMMIT lặp cùng tag là idempotent. Reset xóa valid state của cache riêng và directory.

Directory giữ bitmap holder bảo thủ theo physical cache line: bit thừa chỉ tạo thêm probe; thiếu holder bị cấm. Directory không inclusive với LLC; LLC eviction không xóa directory entry hoặc invalidate line ở L1. Khi thay entry directory đang có holder, phải PREPARE invalidate holder, ghi dữ liệu M cần thiết về LLC, COMMIT invalidation và chỉ sau đó mới dùng lại way. Probe response ghép theo (tag, hart index). Request cùng line bị khóa; line khác có thể tiến nếu không tranh chấp bank, cache array, MSHR, LLC hoặc AXI. Cấu hình không cam kết IPC hoặc latency cố định. Reset xóa valid state; muốn giữ memory qua reset, SoC/software phải quiesce và clean/flush trước. Với mã tự sửa đổi, phần mềm thông báo các hart liên quan và chạy `FENCE.I` trước khi thực thi code mới.

**Example 1 — Missing COMMIT ACK.** In a four-hart build, harts 0 and 1 hold line X in S while hart 2 requests M. PREPARE succeeds for both holders. The CCU sends COMMIT(I); hart 0 acknowledges and hart 1 does not. The directory remains conservatively `{hart 0, hart 1}`, hart 2 receives no grant, and X's lock and transaction slot remain allocated. A request for line Y may complete through a different free slot if directory, cache, LLC, and AXI resources do not conflict. Reset clears cache and directory valid state and releases X's context; software must clean/flush before a warm reset if dirty contents must survive.

**Ví dụ 1 — Thiếu COMMIT ACK.** Trong cấu hình bốn hart, hart 0 và hart 1 giữ line X ở S, còn hart 2 yêu cầu M. PREPARE thành công với cả hai holder. CCU gửi COMMIT(I); hart 0 ACK nhưng hart 1 không ACK. Directory vẫn giữ bitmap bảo thủ `{hart 0, hart 1}`, hart 2 không được cấp quyền, còn line lock và transaction slot của X vẫn được giữ. Request line Y có thể hoàn tất qua slot trống khác nếu không xung đột tài nguyên directory, cache, LLC và AXI. Reset xóa valid state cache/directory và giải phóng context của X; software phải clean/flush trước warm reset nếu cần giữ dữ liệu dirty.

### 10.2.2 Coherence performance and IPC evaluation

| Scenario | Expected hardware work | Expected performance effect; not a numeric guarantee |
|---|---|---|
| D-cache read hit in S/E/M | Tag/data lookup and local response; no CCU probe, directory lookup, LLC access, or AXI traffic. | Lowest-latency path; the directory does not sit on an L1 hit. A hit to another line may continue during a probe if cache-array resources do not conflict. |
| Store hit in M or E | Local update; E changes to M. | No coherence round trip. MESI avoids an upgrade for a private line first read into E. |
| Store hit in S | Directory lookup and tagged invalidation probes only to recorded peer holders; wait for all required responses. | Same-line store stalls through ownership grant. Sharer count, not total hart count alone, controls probe work; write ping-pong and false sharing can still reduce IPC. |
| D-cache miss, LLC hit, no holder | Directory lookup, then LLC tag/data service and a 16-byte refill; no peer probe. | Directory lookup adds work to the miss path, while avoiding unnecessary fanout. A dependent load waits; independent instructions may overlap according to core and MSHR behavior. |
| D-cache miss, LLC hit, with holders | Directory lookup, tagged probes to recorded holders, required owner AXI writeback/B response, then requester HPDcache refill from LLC. | Latency depends on actual holder count, dirty-owner writeback, directory/LLC ports, and backpressure; no fixed cycle reduction is claimed. |
| D-cache miss, LLC miss | Above plus an external AXI4 line fetch; 16 bytes require two 64-bit data beats. | DRAM/interconnect latency and AXI backpressure usually dominate; exact effect requires the selected memory model and workload. |
| Read miss with peer M | Probe the recorded owner; owner writes the full line through its existing AXI path; wait for the matching B response; read current line from LLC and supply requester. | Adds owner writeback plus LLC-read work. The line remains locked until writeback and coherence commit complete; exact latency depends on AXI/LLC/cache-array contention. |
| Independent line transactions overlap | At least two line transactions can be active with distinct tags; directory, probe, LLC and AXI work may proceed concurrently. | Overlap is limited by directory lookup/update ports, per-cache probe service, bank conflicts, MSHRs, LLC capacity and AXI arbitration. Measure occupancy and overlap; do not infer throughput from slot count. |
| Two-hart versus four-hart directory probe | Probe only the recorded sharer set: zero to one target for two harts, zero to three for four harts. | A private line can require no probe in either configuration. More harts increase potential sharer count and metadata, not an unconditional probe count. |
| Directory storage estimate | Four-hart geometry has 8,192 entries; two-hart geometry has 4,096. Each entry includes its physical tag, valid bit, 4-bit maximum holder bitmap, and replacement metadata. | The entry count is selected; SRAM bit count/area depends on physical-address width, ECC, implementation, and macro mapping. Directory capacity is independent of LLC capacity. |
| Same-bank arbitration and directory replacement | Round-robin arbitration serves eligible transaction slots; tree-PLRU chooses a victim only when all eight ways are valid. | Same-bank contention is serialized fairly; replacement may take longer while holders are invalidated or dirty data is written back. Different banks can continue when resources allow. Measure grant wait, bank occupancy, victim-resolution cycles, and IPC under same-bank conflicts; no numerical speedup is guaranteed. |

IPC is measured, not inferred: `IPC_hart = retired instructions for hart h / elapsed cluster clock cycles`; `IPC_cluster = sum(retired instructions for active harts) / the same elapsed cycles`. Also report per-hart CPI, completed workload units/second, D-cache hit/miss class, S-to-M upgrades, directory holder count/fanout, directory stalls, transaction-table occupancy, tagged-probe wait cycles, dirty-owner writeback count and B-response wait cycles, LLC hit/miss, AXI wait cycles, and cycles in which two independent line transactions make progress concurrently. Use identical software, compiler, cache geometry, AXI/DRAM model, clock, and run length when comparing 2 versus 4 harts or a private-data baseline versus shared-line workloads. Include warm-cache private reads, cold misses, LLC hits/misses, producer-consumer sharing, read-mostly sharing, write ping-pong/false sharing, dirty-owner forwarding, and randomized memory backpressure. Report both per-hart and aggregate IPC; do not present IPC gain as proportional to hart count.

The selected upstream config sets `SuperscalarEn=0` and declares `NrCommitPorts=2`; the latter alone is not a dual-issue or 2-IPC guarantee. No IPC target or percentage improvement is claimed until an executable build, representative benchmark, and timing/memory model are available. PMU counters can support this evaluation only after the event dictionary is pinned; simulation traces and independent performance models remain required meanwhile.

IPC phải được đo: `IPC_hart = số lệnh đã retire của hart h / tổng chu kỳ clock`; `IPC_cluster = tổng lệnh retire của các hart hoạt động / cùng số chu kỳ`. Báo cáo thêm CPI từng hart, throughput workload, nhóm hit/miss D-cache, số lần S-to-M, số sharer mỗi transaction, probe wait, directory stall, mức sử dụng transaction table, số dirty-owner writeback và thời gian đợi B response, LLC hit/miss, AXI wait và số chu kỳ hai transaction line khác nhau cùng tiến triển. So sánh 2/4 hart với cùng chương trình, compiler, cache, mô hình AXI/DRAM, clock và thời gian chạy. Bao gồm private read nóng, cold miss, LLC hit/miss, producer-consumer, read-mostly, write ping-pong/false sharing, dirty owner và backpressure ngẫu nhiên. Báo cáo IPC từng hart và toàn cluster; không giả định IPC tăng tuyến tính theo số hart.

Trong cấu hình upstream đã chọn, `SuperscalarEn=0` và `NrCommitPorts=2`; không thể suy ra dual-issue hay 2 IPC chỉ từ `NrCommitPorts`. Chưa có mục tiêu IPC hoặc phần trăm tăng hiệu năng; cần build chạy được, benchmark đại diện và mô hình timing/bộ nhớ. PMU chỉ hỗ trợ đo sau khi chốt event dictionary; trước đó vẫn cần trace mô phỏng và performance model độc lập.

### 10.2.4 Deadlock avoidance, forward progress, and worst-case stalls / Tránh deadlock, bảo đảm tiến triển và stall xấu nhất

#### Directory reservation escape / Lối thoát reservation directory

The reviewed CC-01 failure is a circular wait, not ordinary same-set serialization. Transaction T2 misses in a set and reserves it. T1 had already hit another line in that set and then presents an update. T1's update is correctly ineligible while T2 owns the reservation, but the old channel-priority logic lets the blocked T1 update suppress T2's valid cancel. T1 holds `VALID` until `READY`, so neither transaction can release the set.

Lỗi CC-01 trong bản review là chờ vòng, không phải tuần tự hóa cùng set thông thường. T2 miss và đặt reservation trên một set. T1 đã hit một line khác trong set rồi gửi update. Update của T1 không đủ điều kiện khi T2 giữ reservation; tuy nhiên logic ưu tiên channel cũ để update bị chặn của T1 ngăn cancel hợp lệ của T2. T1 phải giữ `VALID` đến khi có `READY`, nên cả hai giao dịch đều không thể nhả set.

The directory contract in this revision is:

1. Compute eligibility using bank, set, tag, reservation ownership, and operation type **before** choosing a request. An ineligible request may remain `VALID`, but it shall not occupy a registered grant, consume an arbitration turn, or hold the directory array port.
2. While a set is reserved by tag T2, a lookup/update for that set from another tag is ineligible. Requests to other sets remain eligible, subject to the bank's one-operation-per-cycle limit.
3. A matching reservation-owner `UPDATE` or pre-COMMIT `CANCEL` is terminal and must be serviceable independently of a blocked non-owner update. Accepting `CANCEL(T2)` clears only T2's reservation; it does not change MESI or holder state. The waiting T1 update remains asserted and may be accepted after the reservation clears. A matching `UPDATE(T2)` commits its directory state and releases the reservation.
4. Each bank accepts at most one operation per cycle. Round-robin arbitration advances only after an accepted operation and rotates across eligible transaction slots. A continuously eligible slot is selected within one full round if the bank continues accepting one operation per cycle. The arbitration guarantee does not cover a held downstream response or reset.
5. A producer shall assert exactly one terminal action for a reservation. If the owner presents `UPDATE` and `CANCEL` for the same reservation concurrently, this is a protocol fault: preserve directory state and reservation, latch the diagnostic, and require system-level recovery; do not guess commit versus abort.

Hợp đồng directory trong phiên bản này:

1. Xác định điều kiện hợp lệ dựa trên bank, set, tag, chủ reservation và loại thao tác **trước** khi chọn request. Request không hợp lệ có thể vẫn giữ `VALID`, nhưng không được chiếm grant đã đăng ký, dùng lượt phân xử hoặc giữ cổng mảng directory.
2. Khi tag T2 giữ reservation của một set, lookup/update từ tag khác vào set đó không hợp lệ. Request sang set khác vẫn đủ điều kiện, theo giới hạn một thao tác mỗi chu kỳ của bank.
3. `UPDATE` hoặc `CANCEL` trước COMMIT của đúng chủ reservation là thao tác kết thúc và phải được phục vụ độc lập với update bị chặn của transaction khác. Nhận `CANCEL(T2)` chỉ xóa reservation T2, không đổi MESI hay holder. Update T1 vẫn giữ VALID và có thể được nhận sau khi reservation nhả. `UPDATE(T2)` commit trạng thái directory rồi nhả reservation.
4. Mỗi bank nhận tối đa một thao tác mỗi chu kỳ. Round-robin chỉ tăng sau thao tác được nhận và quay vòng qua các slot đủ điều kiện. Slot liên tục đủ điều kiện được chọn trong một vòng nếu bank liên tục nhận một thao tác mỗi chu kỳ. Bảo đảm phân xử không áp dụng khi response phía sau bị giữ hoặc reset đang hoạt động.
5. Producer chỉ được phát một terminal action cho mỗi reservation. Nếu owner đồng thời phát `UPDATE` và `CANCEL` cùng reservation, đây là lỗi giao thức: giữ nguyên directory và reservation, chốt diagnostic, chờ recovery cấp hệ thống; không tự đoán commit hay abort.

#### Resource ordering and wait-for graph / Thứ tự tài nguyên và đồ thị chờ

| Resource | May remain held while waiting | Must be released or independently serviceable | Deadlock control |
|---|---|---|---|
| Transaction context and physical-line lock | Yes, through PREPARE/COMMIT/ABORT under DEC-018 | Do not acquire the same line in a second active context; different lines use other free contexts | Unique active tag and line lock; no timeout behavior is unchanged |
| Directory set reservation | Yes, until matching owner UPDATE/CANCEL | Physical bank array port is released immediately after each accepted operation; owner terminal operation bypasses blocked requests | Eligibility-aware bank arbitration and cancellation escape |
| Cache line lock | Yes, while preserving MESI across a probe | Do not hold a global tag/data-array port or unrelated MSHR while waiting on AXI or another cache | Line-specific locking; refill must not wait on a probe that is waiting for that refill's new permission |
| Probe/ACK channel | A valid expected ACK may wait for response-buffer space | Stale/duplicate/mismatched ACKs are drained when accepted and cannot block later responses | Response matching is performed after channel acceptance; only the first expected ACK updates the context |
| AXI ID and writeback state | Yes, until the matching B response | AXI B/R response routing remains independent of new AW/AR arbitration | Keep the owner M and line lock until response; do not hold directory/cache-array ports over B wait |
| Directory replacement victim | Yes, while holders are resolved | Bank array port is released between lookup/update operations | Victim stays allocated until all holder transitions and dirty data complete |

Forward-progress claims are conditional. Assume reset is deasserted, the clock runs, each cache eventually services a queued probe, AXI sources eventually see `READY`, and every accepted AXI transaction eventually receives its response. Under these assumptions and fair arbitration, the design shall not create an internal resource wait cycle or indefinitely starve an eligible request. The specification does **not** give a finite latency bound. If a PREPARE/COMMIT/ABORT ACK or AXI response never arrives, DEC-018 intentionally retains the transaction slot and line lock without timeout. Once all 8 default (or 16 maximum) contexts are occupied, new CCU-dependent misses/CMOs can stop cluster-wide; independent L1 hits may continue where no line/cache resource conflict exists. Reset clears cache valid state and can discard dirty data, so reset is not a safe data-preserving recovery for a warm system.

Các cam kết tiến triển có điều kiện. Giả định reset đã nhả, clock chạy, mỗi cache xử lý probe đang chờ, nguồn AXI cuối cùng thấy `READY` và mỗi AXI transaction được chấp nhận cuối cùng có response. Với các giả định đó và phân xử công bằng, thiết kế không tạo vòng chờ tài nguyên nội bộ hoặc bỏ đói request đủ điều kiện vô thời hạn. Đặc tả **không** cam kết latency tối đa. Nếu một ACK PREPARE/COMMIT/ABORT hoặc AXI response không bao giờ đến, DEC-018 vẫn giữ transaction slot và line lock, không timeout. Khi cả 8 context mặc định (hoặc 16 context tối đa) đều bị chiếm, miss/CMO cần CCU mới có thể dừng trên toàn cluster; L1 hit độc lập vẫn có thể chạy nếu không xung đột line/cache. Reset xóa valid state cache và có thể làm mất dữ liệu dirty, vì vậy reset không phải cách recovery an toàn để bảo toàn dữ liệu khi hệ thống đang chạy.

#### Worst-case performance envelope / Giới hạn hiệu năng trong trường hợp xấu nhất

| Worst case | Work serialized or contended | Performance consequence and bound |
|---|---|---|
| Four-hart miss with three recorded peer holders | Up to three targeted probe responses; each target cache services one probe at a time. If the authoritative owner is M, it writes 16 bytes over two 64-bit W beats and the CCU waits for the matching B response before COMMIT/grant. | One slow target/owner controls the phase completion. An LLC miss adds an external line fetch and the requester refill. No finite cycle bound exists without response-latency limits. |
| Same-line write ping-pong or false sharing | Each alternating writer must obtain M and invalidate other holders; 16-byte lines make unrelated words in one line contend. | Stores that would otherwise hit locally can become serial coherence transactions. Throughput can approach one ownership transfer at a time for that line; dependent CPU progress waits for the grant/refill. |
| Same directory set conflict | The set reservation lasts for the complete coherence transaction, including holder probes, dirty-owner B wait, and terminal directory update/cancel. All other lookups to that set stall even when they target another way/tag. | This is intentional set-level serialization and can dominate adversarial conflict traffic. The escape rule prevents deadlock but does not make same-set requests parallel. Other sets may use the bank one accepted operation per cycle. |
| Same-bank contention | One directory operation is accepted per bank per cycle. Up to 8 contexts by default (16 maximum) can map to one bank. | Fair service takes a full arbitration round for a continuously eligible slot when the bank accepts every cycle; each remote probe/AXI stall extends wall-clock wait beyond that arbitration bound. Other banks can progress independently only if downstream resources are free. |
| One cache receives many probes | Queue depth is up to `PARA_COH_TXN_NUM`; service is one probe at a time per cache. | A slow first probe causes head-of-line delay for later probes to that cache. Other harts/caches and unrelated L1 hits can continue only when their ports/MSHRs are independent. |
| All transaction contexts occupied | Default 8 and maximum 16 global contexts are shared by all harts; there is no fixed per-hart quota. | New misses, upgrades, directory replacements, and CMOs requiring a context wait. A stalled ACK can retain a slot forever by design; a high slot count increases concurrency capacity but does not guarantee higher IPC. |
| Full 8-way directory set with live holders | PLRU selects a victim; the entry cannot be reused until each recorded holder is invalidated and any M-owner data reaches LLC. | Directory replacement latency includes probe service and dirty-owner writeback; repeated address conflicts can cause extra back-invalidation and refills. Stale-positive holders add probes but preserve correctness. |
| External AXI backpressure/error | AW/W/AR READY may stall; B/R may be delayed or return an error. The cluster has no bus timeout in this specification. | AXI wait can dominate any coherence latency; B error triggers the specified ABORT/fault path. A missing response leaves the affected context allocated indefinitely. |
| Local `FENCE.I`, all D-cache lines dirty | A 32-KiB D-cache with 16-byte lines has 2,048 lines. Transferring every dirty line through the native 64-bit path requires two W beats and one B response per line, in addition to the tag scan and local I-cache/fetch invalidation. | Up to 4,096 owner W data beats plus 2,048 B responses are required in this all-dirty envelope; actual cycles depend on cache service and AXI timing and are unbounded under backpressure. |

For measurement, decompose a miss as `T_miss = T_dir_wait + T_probe_queue + T_prepare + T_owner_W/B + T_commit + T_LLC + T_external (if LLC miss) + T_refill`. `T_prepare` and peer probes may overlap across different harts; the slowest required target controls that phase, while requests queued to the same cache serialize. The equation is an accounting model, not a cycle-accurate additive timing contract. For external data width W and clock frequency f, the peak data-channel rate is `W/8 × f` bytes/s per direction. Effective bandwidth is bounded by the minimum of that bus peak, LLC/cache service rate, outstanding-line capacity divided by average latency, and the SoC memory target. A 64-bit bus carries at most 8 data bytes per beat; read and write channels may progress concurrently, but this does not imply a guaranteed aggregate rate.

Để đo, phân rã miss theo `T_miss = T_dir_wait + T_probe_queue + T_prepare + T_owner_W/B + T_commit + T_LLC + T_external (nếu LLC miss) + T_refill`. Probe tới các hart khác nhau có thể chạy song song; target chậm nhất quyết định hoàn tất phase, còn probe trong cùng cache phải tuần tự. Công thức là mô hình phân tích, không phải hợp đồng cộng chu kỳ chính xác. Với độ rộng dữ liệu ngoài W và tần số f, tốc độ dữ liệu đỉnh là `W/8 × f` byte/s cho mỗi chiều. Băng thông thực tế bị giới hạn bởi giá trị nhỏ nhất giữa bus peak, tốc độ phục vụ LLC/cache, số line outstanding chia latency trung bình và khả năng memory của SoC. Bus 64-bit mang tối đa 8 byte dữ liệu mỗi beat; kênh đọc/ghi có thể hoạt động đồng thời nhưng không đảm bảo thông lượng tổng cụ thể.

### 10.3 Waveform plan

The user approved the original 14 waveform topics. WF-015 shows a missing COMMIT ACK; WF-016 and WF-017 add missing PREPARE and ABORT ACKs under the same all-phase no-timeout contract. WF-018 shows a writeback-required CBO error, ABORT completion, and the precise trap before retirement. WF-019 shows a successful local FENCE.I and a separate failed FENCE.I with ABORT, preserved M/directory state, and the custom cause-24 trap. WF-020 illustrates the CC-01 escape: an ineligible T1 update remains VALID, the reservation owner's T2 cancel handshakes, the reservation clears, and T1 update can then be accepted. WF-020 shows only the ordering contract; its spacing is not a cycle-latency guarantee. These diagrams show the retained lock/slot, unchanged directory and requester grant during missing-ACK waits, independent-line progress only when resources permit, and reset recovery. Probe and retirement-control names are logical aliases unless a figure points to an existing RTL port.

Người dùng đã duyệt 14 chủ đề waveform. WF-015 mô tả thiếu COMMIT ACK; WF-016/017 bổ sung thiếu PREPARE/ABORT ACK theo cùng hợp đồng không timeout ở mọi phase. Các hình thể hiện lock/slot được giữ, directory và quyền requester không đổi, line độc lập chỉ tiến khi tài nguyên cho phép, và reset để recovery. WF-002 mô tả tra directory, gửi probe tới holder, ghép trạng thái theo tag giao dịch và hart index, owner writeback qua AXI hiện có (hai beat W 64-bit), nhận B response, COMMIT, cập nhật directory rồi cấp shared. Tín hiệu probe là alias logic, không phải port RTL. Trình tự chỉ giải thích thứ tự; khoảng cách chu kỳ là minh họa, không cam kết latency/throughput.

WF-020 minh họa lối thoát CC-01: update T1 không đủ điều kiện vẫn giữ VALID; cancel T2 của chủ reservation bắt tay; reservation được xóa; sau đó update T1 có thể được nhận. Hình chỉ thể hiện thứ tự hợp đồng, không cam kết latency theo chu kỳ.

WF-022 gives a close-up of the same escape: T1 holds UPDATE VALID while READY is low; reservation-owner T2 CANCEL handshakes independently; the reservation releases; then T1 UPDATE handshakes. Each column is an abstract event phase, not a clock cycle.

WF-022 là sơ đồ cận cảnh cùng luồng: UPDATE của T1 giữ VALID khi READY thấp; CANCEL của T2, chủ reservation, bắt tay độc lập; reservation được giải phóng; sau đó UPDATE T1 bắt tay. Các cột là pha sự kiện theo thứ tự, không phải chu kỳ clock hay cam kết latency.

| Waveform ID | Function / operation | Scenario | Signals shown | Figure | Confirmed by user |
|---|---|---|---|---|---|
| WF-001 | OP-001 Reset/boot and LLC BIST | Reset release, BIST busy then done | reset, clock, BIST busy/done, ready | ![WF-001 pending detail](figures/waveforms/WF-001_pending_status.svg); [offline status card](figures/waveforms/WF-001_pending_status.html) |Plan approved; BIST/status field and ready timing are pending|
| WF-002 | OP-002 Internal MESI read sharing | Hart 1 requests X held M by hart 0; PREPARE locks and reports M; hart 0 writes X through its existing AXI path; matching B response completes PREPARE; COMMIT(S) ACK precedes directory update and shared grant | Abstract request, directory lookup, tagged PREPARE/COMMIT response `(tag, hart)`, owner AXI AW/W/B, MESI state | ![WF-002 two-phase read sharing](figures/waveforms/WF-002_mesi_dirty_owner.svg); [WaveJSON source](figures/waveforms/WF-002_mesi_dirty_owner.json); [offline SVG viewer](figures/waveforms/WF-002_mesi_dirty_owner.html) |Approved ordering illustration; aliases, not RTL ports; cycle spacing is not a latency/throughput contract|
| WF-003 | OP-003 AXI4 MMIO read/write | Successful read and write response | AW/W/B and AR/R handshakes | ![WF-003 AXI MMIO transactions](figures/waveforms/WF-003_axi_mmio_read_write.svg); [offline viewer](figures/waveforms/WF-003_axi_mmio_read_write.html) |Plan approved; WaveDrom trace; timing is not a bound|
| WF-004 | OP-003 AXI4 backpressure | AW/W/R/B stall and stable payload | VALID/READY and payload | ![WF-004 AXI backpressure](figures/waveforms/WF-004_axi_mmio_backpressure.svg); [offline viewer](figures/waveforms/WF-004_axi_mmio_backpressure.html) |Plan approved; WaveDrom trace; timing is not a bound|
| WF-005 | OP-004 AXI-only DMA visibility | Correct cache-maintenance sequence | clean/invalidate event, AXI write/read completion | ![WF-005 pending detail](figures/waveforms/WF-005_pending_status.svg); [offline status card](figures/waveforms/WF-005_pending_status.html) |Plan approved; platform software sequence is pending|
| WF-006 | OP-005 future ACE read snoop | External read hits a dirty local owner | AC/CR/CD, AR/R, RACK | ![WF-006 deferred](figures/waveforms/WF-006_pending_status.svg); [offline status card](figures/waveforms/WF-006_pending_status.html) |Deferred with external ACE profile|
| WF-007 | OP-005 future ACE write/invalidate snoop | External write needs ownership transition | AC/CR/CD, AW/W/B, WACK | ![WF-007 deferred](figures/waveforms/WF-007_pending_status.svg); [offline status card](figures/waveforms/WF-007_pending_status.html) |Deferred with external ACE profile|
| WF-008 | OP-005 future ACE response ordering | Snoop overlaps outstanding same-line request | AC/CR, R/B response, IDs | ![WF-008 deferred](figures/waveforms/WF-008_pending_status.svg); [offline status card](figures/waveforms/WF-008_pending_status.html) |Deferred with external ACE profile|
| WF-009 | OP-006 PMU snapshot | Counter increments during snapshot and two-word read | snapshot command/done, count low/high | ![WF-009 pending detail](figures/waveforms/WF-009_pending_status.svg); [offline status card](figures/waveforms/WF-009_pending_status.html) |Plan approved; CSR command/done field timing is pending|
| WF-010 | OP-006 PMU overflow IRQ | Counter wraps and cause is cleared | event, counter, raw/en/status, o_int_pmu | ![WF-010 pending detail](figures/waveforms/WF-010_pending_status.svg); [offline status card](figures/waveforms/WF-010_pending_status.html) |Plan approved; event encoding and cause-clear sequence are pending|
| WF-011 | OP-007 LLC flush | Flush request under traffic and completion | flush request, AXI traffic, busy/done/error | ![WF-011 pending detail](figures/waveforms/WF-011_pending_status.svg); [offline status card](figures/waveforms/WF-011_pending_status.html) |Plan approved; CSR/source-level sequencing is pending|
| WF-012 | OP-008 Hart debug | Halt/resume one hart only | debug request/mode vectors | ![WF-012 pending detail](figures/waveforms/WF-012_pending_status.svg); [offline status card](figures/waveforms/WF-012_pending_status.html) |Plan approved; exact source/DM timing is pending|
| WF-013 | IF-AXIL Error response | Misaligned and unmapped CSR access | AW/AR, WSTRB, BRESP/RRESP | ![WF-013 AXI4-Lite errors](figures/waveforms/WF-013_axil_error_responses.svg); [offline viewer](figures/waveforms/WF-013_axil_error_responses.html) |Plan approved; WaveDrom trace; timing is not a bound|
| WF-014 | Reset/error recovery | Reset with outstanding AXI/internal-probe activity | reset, VALID/READY, response state | ![WF-014 pending detail](figures/waveforms/WF-014_pending_status.svg); [offline status card](figures/waveforms/WF-014_pending_status.html) |Plan approved; outstanding-transaction reset response is pending|
| WF-015 | REQ-MEM-013 post-COMMIT missing acknowledgement | One of two invalidation targets ACKs COMMIT; the other does not; an independent line may complete; reset clears the stalled context | COMMIT ACKs, directory holder set, requester grant, line lock, transaction slot, independent-line completion, reset | ![WF-015 COMMIT ACK wait](figures/waveforms/WF-015_commit_ack_wait.svg); [WaveJSON source](figures/waveforms/WF-015_commit_ack_wait.json); [offline viewer](figures/waveforms/WF-015_commit_ack_wait.html) |User-selected no-timeout behavior, DEC-018; abstract ordering, not a cycle-latency contract|
| WF-016 | REQ-MEM-013 missing PREPARE acknowledgement | One recorded holder ACKs PREPARE; another does not; no COMMIT or requester grant occurs; reset clears the stalled context | PREPARE requests/ACKs, stable MESI, directory holders, requester grant, line lock, transaction slot, reset | ![WF-016 PREPARE ACK wait](figures/waveforms/WF-016_prepare_ack_wait.svg); [WaveJSON source](figures/waveforms/WF-016_prepare_ack_wait.json); [offline viewer](figures/waveforms/WF-016_prepare_ack_wait.html) |All-phase no-timeout decision, DEC-018; logical aliases and illustrative spacing|
| WF-017 | REQ-MEM-013 missing ABORT acknowledgement | A pre-COMMIT error sends ABORT to two holders; one ACKs/releases its local lock, the other does not; reset clears the stalled context | Error, ABORT requests/ACKs, stable MESI, local/CCU line locks, directory, transaction slot, reset | ![WF-017 ABORT ACK wait](figures/waveforms/WF-017_abort_ack_wait.svg); [WaveJSON source](figures/waveforms/WF-017_abort_ack_wait.json); [offline viewer](figures/waveforms/WF-017_abort_ack_wait.html) |All-phase no-timeout decision, DEC-018; logical aliases and illustrative spacing|
| WF-018 | OP-009, REQ-MEM-017 precise CBO writeback-error trap | An M-owner writeback succeeds; LLC B returns SLVERR; the CBO remains at retirement head while ABORT ACKs arrive; trap follows all ACKs | CBO held at retirement head, owner/LLC B status, ABORT request/ACKs, dirty MESI state, CBO/younger retirement, fault valid, trap PC/address | ![WF-018 CBO error and precise trap](figures/waveforms/WF-018_cbo_writeback_fault.svg); [WaveJSON source](figures/waveforms/WF-018_cbo_writeback_fault.json); [offline viewer](figures/waveforms/WF-018_cbo_writeback_fault.html) |DEC-029; contract event order only; aliases are not RTL ports, spacing is illustrative and not a latency bound|
| WF-019 | OP-010, REQ-MEM-018 local FENCE.I success and L1-to-LLC error trap | First operation succeeds after dirty-line LLC acceptance and local fetch synchronization; a separate later operation fails with B=SLVERR, completes ABORT, then raises cause 24 | FENCE.I retirement hold/retire, owner AXI AW/W/B, M→E success transition, local I-cache/fetch invalidate, LLC external-memory AW, ABORT request/ACKs, preserved failed M/directory state, exception cause/PC/mtval or stval | ![WF-019 FENCE.I success and failure](figures/waveforms/WF-019_fence_i_sync.svg); [WaveJSON source](figures/waveforms/WF-019_fence_i_sync.json); [offline viewer](figures/waveforms/WF-019_fence_i_sync.html) |User approved both cases, 2026-11-08; DEC-030/031; two separate illustrative transactions, aliases are not RTL ports, spacing is not a latency contract|
| WF-020 | REQ-MEM-019 directory reservation cancel escape | T2 owns a set reservation; T1 update is held valid but ineligible; T2 cancel is accepted despite T1; reservation clears; T1 update then handshakes | Existing bank-0 ports `i_update_valid[0]`, `o_update_ready[0]`, `i_cancel_valid[0]`, `o_cancel_ready[0]`; `reg_dir_resv_valid` is an internal state label | [WaveJSON source](figures/waveforms/WF-020_directory_cancel_escape.json); [offline waveform viewer](figures/waveforms/WF-020_directory_cancel_escape.html) |User selected signal set A; abstract event spacing, no cycle-latency claim; RTL unchanged|
| WF-021 | REQ-IF-011 address-region classification | Separate illustrative requests show cacheable, normal-uncached, MMIO, and unmapped destinations; the last is rejected locally | Physical address/class, route class, memory-bypass request, MMIO request, local access-error response | [WaveJSON source](figures/waveforms/WF-021_address_region_routing.json); [offline viewer](figures/waveforms/WF-021_address_region_routing.html) |Approved 2026-11-14; independent cases, not cycles; standalone route leaf exists, full-core wiring remains pending|
| WF-022 | REQ-MEM-019 directory reservation cancel escape detail | T1 UPDATE remains valid but ineligible; reservation-owner T2 CANCEL handshakes; reservation releases; T1 UPDATE handshakes | Existing bank-0 ports `i_update_valid[0]`, `o_update_ready[0]`, `i_cancel_valid[0]`, `o_cancel_ready[0]`; internal `reg_dir_resv_valid` | [WaveJSON source](figures/waveforms/WF-022_directory_cancel_escape_detail.json); [offline viewer](figures/waveforms/WF-022_directory_cancel_escape_detail.html) |Approved 2026-11-14; columns are abstract event phases, not clock cycles or latency promises|

### 10.4 Timing boundaries

No deterministic AXI/ACE latency or maximum snoop response time is claimed. For internal PREPARE, COMMIT, and ABORT, the cluster has no ACK timeout: a missing ACK keeps the line lock and transaction slot allocated until all required ACKs arrive or cluster reset occurs; no requester grant or directory update occurs while waiting. A system that requires a bounded timeout must define timeout ownership, termination response, and data-safety behavior in a future approved interface contract. AXI/ACE backpressure remains legal for an unbounded interval unless the integration system states otherwise.

Không cam kết latency AXI/ACE cố định hoặc thời gian snoop tối đa. PREPARE, COMMIT và ABORT nội bộ đều không có timeout ACK: nếu thiếu ACK, line lock và transaction slot được giữ đến khi nhận đủ ACK hoặc reset cluster; trong thời gian chờ không cập nhật directory và không cấp quyền requester. Backpressure AXI/ACE được phép kéo dài nếu hợp đồng tích hợp không quy định giới hạn.

## 11. Register and programming model

### 11.1 CSR workbook and generator

The required software control bus is AXI4-Lite, not APB. The workbook is `VLSIT_RISCV_CPU_Cluster_CSR.xlsx`; its `AXIL_QUEUED` sheet was generated by the local CSR_Generation.py v3.5 `--vlsit-style` path, based on commit c40f319. The external port is 32-bit address/data with four byte strobes and synchronous register clock. The register prefix selected by the user is `cpucl`. The PMU counter bank count is passed into generated repeated-register parameters from top-level `PARA_PMU_COUNTER_NUM`. The cluster-local map reserves offsets `0x0000–0x0FFF` for cluster CSR and `0x1000–0x1FFF` for LLC service; each region is 4 KiB. The SoC supplies the absolute base address, aligned to 4 KiB. Workbook rows define assigned offsets; all other offsets in either window are reserved and return zero/DECERR for reads or DECERR with no side effect for writes. The new `m_vlsit_riscv_axil_decode` routes the windows; the LLC service window is converted by new module `m_vlsit_axil_reg_bridge` to the pinned PULP RegBus interface; the upstream LLC register wrapper remains unchanged.

Each counter selector includes an event ID and a three-bit scope: 0–3 selects hart 0–3, 4 aggregates the event over all active harts, and 5 selects a cluster-global event such as an LLC or CCU event. Scope values 6–7 are reserved. Selecting an absent hart or using a scope incompatible with the event source produces no counter increment. Aggregate per-hart events sum each hart's one-bit event indicator; four simultaneous hart indicators add four. For scope 5, transaction/handshake sources count their actual occurrences per cycle, up to four; CCU taps carry a 3-bit count from zero through four. Stall, full, and conflict sources count one per cycle while asserted. The workbook `Event_Map` draft maps the user-confirmed ranges: CVA6 `0x0001–0x0016`, HPDcache `0x0100–0x010F`, LLC `0x0200–0x0217` and `0x0240–0x0243`, and CCU `0x0300–0x030B`. CVA6 expressions that OR-reduce commit ports remain at most one per hart per cycle. LLC `event_num_bytes_t` fields count one accepted AXI transfer or internal descriptor according to the source field when `.active` is set; byte-weighted counting is excluded. Unknown, reserved, unavailable and disabled-SPM events count zero. Per-event mappings and exact CCU tap points remain subject to designer review.

The CSR workbook is `VLSIT_RISCV_CPU_Cluster_CSR.xlsx`. `AXIL_QUEUED` defines the cluster CSR register map; `Event_Map` records the selected source ranges and the source-grounded PMU catalog. Exact source pins and proposed CCU event taps remain implementation review items. The CSR and LLC local windows are each 4 KiB; the base address is a SoC integration value. Unassigned offsets are reserved. The stale APB-only CSR note in the microspec skill is not authoritative for this design.

Giao diện điều khiển là AXI4-Lite, không phải APB. Workbook `VLSIT_RISCV_CPU_Cluster_CSR.xlsx`, sheet `AXIL_QUEUED`, được sinh bằng CSR_Generation.py v3.5 `--vlsit-style`, dựa trên commit c40f319. Cổng address/data 32-bit, bốn byte strobe, clock đồng bộ; QUEUED có một entry đọc và một entry ghi; WSTRB=HONOR. Prefix workbook là `cpucl`; module sinh ra là `m_vlsit_cpucl_csr`. CSR dùng offset `0x0000–0x0FFF`, LLC service dùng `0x1000–0x1FFF`; các offset chưa gán là reserved. Base tuyệt đối do SoC chọn và căn 4 KiB. Số register lặp lấy từ `PARA_PMU_COUNTER_NUM`. RTL PMU selector/counter/snapshot/IRQ đã được tạo; kết nối event taps với đúng source pin CVA6/HPDcache/LLC và các CCU tap vẫn cần hoàn tất trong integration.

Workbook `VLSIT_RISCV_CPU_Cluster_CSR.xlsx` là nguồn CSR hiện tại. Sheet `AXIL_QUEUED` mô tả register/offset; `Event_Map` ghi các source range đã chọn và catalog PMU theo source. Range CVA6 `0x0001–0x0016`, HPDcache `0x0100–0x010F`, LLC `0x0200–0x0217`/`0x0240–0x0243`, CCU `0x0300–0x030B` đã xác nhận. Chính sách đếm hybrid đã chốt: transaction/handshake toàn cluster đếm số lần xảy ra mỗi chu kỳ (tối đa 4); stall/full/conflict đếm chu kỳ. Trong LLC, `0x0200–0x0205` là AXI transfer; `0x0206–0x0217` là descriptor; mỗi `.active` đếm một event, không cộng byte. Ánh xạ event chi tiết và điểm tap CCU cần xác minh với RTL source khi tích hợp. Event không khả dụng, reserved hoặc thuộc SPM bị tắt sẽ đếm 0. Offset chưa gán là reserved: read trả `DECERR` và zero data; write trả `DECERR` và không gây side effect. Base tuyệt đối 8 KiB do SoC chọn, căn 4 KiB. CSR được sinh bằng CSR_Generation.py v3.5 `--vlsit-style`; ghi chú APB-only cũ của skill không áp dụng cho design AXI4-Lite này.

#### PMU event catalog / Danh mục event PMU

| Selector range | Source | Scope | Definition |
|---|---|---|---|
| `0x0001–0x0016` | CVA6 performance events 1–22 from the pinned `core/perf_counters.sv` | Per-hart: 0–3; aggregate: 4 | The 16-bit IDs preserve the selected source's 5-bit `mhpmevent` values. Proposed names and source expressions are listed in the `Event_Map` draft. |
| `0x0100–0x010F` | Sixteen pinned HPDcache `evt_*_o` outputs | Per-hart: 0–3; aggregate: 4 | Each selector maps to one named cache event output. A high event indicator contributes once for each sampled cycle. |
| `0x0200–0x0205` | Six `axi_llc_pkg::events_t` AXI transfer fields | Cluster: 5 | Each asserted `.active` records one accepted AXI address-vector transfer at the named LLC interface point. `.num_bytes` is not accumulated. |
| `0x0206–0x0217` | Eighteen `axi_llc_pkg::events_t` descriptor fields | Cluster: 5 | Each asserted `.active` records one accepted internal descriptor at the named LLC processing point. Disabled SPM entries count zero; `.num_bytes` is not accumulated. |
| `0x0240–0x0243` | Four `axi_llc_pkg::events_t` scalar storage-request fields | Cluster: 5 | Counts one accepted request when the corresponding one-bit handshake indicator is asserted; this single LLC source contributes 0 or 1 per cycle. |
| `0x0300–0x0307`, `0x030B` | Proposed new VLSIT CCU transaction/handshake taps | Cluster: 5 | Counts actual same-cycle occurrences from the four directory banks, using a 3-bit count from 0 through 4. Exact tap points require review with the CCU module/port plan. |
| `0x0308–0x030A` | Proposed new VLSIT CCU stall taps | Cluster: 5 | Counts one cycle while the corresponding full, same-line conflict, or bank-conflict stall is asserted; it does not count blocked requests. |

No event IDs are inferred from a candidate signal name. CVA6 and HPDcache entries are wired from the exact pinned source outputs or approved modifications. LLC meanings follow the pinned `events_t` comments. CCU event taps are new VLSIT-defined signals. An event's allowed scope is encoded in the workbook; a scope mismatch, reserved code, absent hart, or unavailable source contributes zero. Per-hart CVA6/HPDcache indicators contribute at most one per source per hart per cycle; aggregate scope sums the active-hart indicators. For cluster scope, transaction and handshake events count occurrences rather than merely active cycles: the CCU exports a 3-bit count from 0 through 4 for the selected transaction events, reflecting concurrent bank activity. Full, conflict, and other stall events count one per asserted cycle. The single LLC instance exposes one-bit `.active` fields, so each LLC selector contributes zero or one accepted descriptor/request per cycle; `.num_bytes` is never accumulated.

Không tự suy luận ID từ tên tín hiệu dự kiến. Event CVA6/HPDcache lấy từ output source đã pin hoặc từ phần sửa được duyệt. Ý nghĩa LLC theo comment trong `events_t` đã pin. Tap CCU do VLSIT định nghĩa mới. Scope hợp lệ của từng event nằm trong workbook; scope không khớp, mã reserved, hart vắng mặt hoặc source không khả dụng đều cộng 0. Indicator CVA6/HPDcache theo từng hart đóng góp 0 hoặc 1; scope aggregate cộng indicator của các hart đang hoạt động. Với scope toàn cluster, event giao dịch/bắt tay đếm số lần xảy ra thực tế; CCU xuất số đếm 3-bit từ 0 đến 4 để giữ các hoạt động đồng thời ở các bank. Event full/conflict/stall chỉ tăng một lần cho mỗi chu kỳ được giữ mức active. Mỗi trường `.active` của LLC đơn instance đóng góp 0 hoặc 1 event mỗi chu kỳ; không cộng `.num_bytes`.

### 11.2 Software programming and use flow

The steps and register names below are a proposed programming path. Final field names and values shall match the workbook.

Trình tự dưới đây là đề xuất; tên field và giá trị cuối cùng phải khớp workbook.

~~~mermaid

flowchart TD

  S01["S01 [M] Release cluster reset after clock stable"] --> S02["S02 [M] Poll LLC BIST ready"]

  S02 --> S03{"S03 [O] Enable PMU diagnostics?"}

  S03 -->|yes| S04["S04 [O] Program event selectors and enable counters"]

  S03 -->|no| S05["S05 [M] Start software on active harts"]

  S04 --> S05

  S05 --> S06{"S06 [O] Need a counter snapshot?"}

  S06 -->|yes| S07["S07 [O] Request snapshot and poll done"]

  S06 -->|no| S08["S08 [M] Use normal memory and MMIO"]

  S07 --> S09["S09 [O] Read counter low/high words"]

  S09 --> S08

  S08 --> S10{"S10 [O] PMU interrupt asserted?"}

  S10 -->|yes| S11["S11 [O] Read cause and clear handled cause"]

  S10 -->|no| S12["S12 [M] Continue or stop workload"]

  S11 --> S12

~~~

| No. | Step | Option (M/O) | Interface | CSR | Description |
|---|---|---|---|---|---|
| S01 | Release cluster reset after clock stable | M | SoC reset controller releases i_rst_n_cluster | N/A: reset pin, not a CSR | Keeps all protocol and coherence state in reset until the clock is usable |
| S02 | Poll LLC BIST ready | M | AXI4-Lite read of LLC service status | Exact axi_llc workbook name pending | Do not use an LLC path while BIST blocks it |
| S03 | Enable PMU diagnostics? | O | Software branch | N/A: decision only | Selects whether the run needs performance measurements |
| S04 | Program event selectors and enable counters | O | AXI4-Lite writes | cpucl_pmu_evt[*], exact field names pending | Counts selected event sources during the workload |
| S05 | Start software on active harts | M | SoC boot/debug mechanism | N/A: boot is owned by the SoC | Starts the selected Linux or bare-metal workload |
| S06 | Need a counter snapshot? | O | Software branch | N/A: decision only | Selects atomic readback when 64-bit counters are used |
| S07 | Request snapshot and poll completion | O | AXI4-Lite write/read | cpucl_pmu_ctrl snapshot request/done, exact fields pending | Captures the counter bank before software reads it |
| S08 | Use normal memory and MMIO | M | RISC-V memory operations; AXI4 MMIO where required | N/A: runtime transaction interface | Runs the actual software workload |
| S09 | Read counter low/high words | O | AXI4-Lite reads | cpucl_pmu_count_lo[*], cpucl_pmu_count_hi[*] | Reads one stable snapshot for each enabled counter |
| S10 | PMU interrupt asserted? | O | SoC interrupt controller samples o_int_pmu | N/A: external interrupt pin | Routes aggregate PMU cause to firmware |
| S11 | Read cause and clear handled cause | O | AXI4-Lite read/write | cpucl_irq_raw, cpucl_irq_en, cpucl_irq_sts | Identifies and acknowledges counter overflow |
| S12 | Continue or stop workload | M | Software execution or external debug control | N/A: processor operation | Ends or repeats the measurement interval |

CSR field names, offsets, reset values, access types, and repeat counts are defined by the workbook draft and require review before generation. The SoC absolute base and the exact pinned `axi_llc` service target mapping remain integration/source audit inputs.

### 11.3 CSR connection to the design

| Workbook register.field | Direction at the CSR | Design signal | Clock domain of the signal | Behavior notes |
|---|---|---|---|---|
| cpucl_pmu_evt[*].event_id | Control out | PMU event selector per counter | CLK-CLUSTER | Legal IDs and scope compatibility are defined by workbook Event_Map and REQ-PMU-007/008; other IDs count zero |
| cpucl_pmu_evt[*].enable | Control out | PMU counter enable | CLK-CLUSTER | Disabled counter holds value |
| cpucl_pmu_evt[*].scope | Control out | Per-hart / aggregate / cluster-global event scope | CLK-CLUSTER | Values 0–5 are defined; 6–7 are reserved; aggregate sums simultaneous per-hart event occurrences |
| cpucl_pmu_ctrl.snapshot | Control out / hardware clear | Snapshot request | CLK-CLUSTER | Hardware clears request after capture |
| cpucl_pmu_ctrl.snapshot_done | Status in | Snapshot completion | CLK-CLUSTER | Stays asserted until next request or software clear, per workbook |
| cpucl_pmu_count_lo[*] | Status in | Captured counter low word | CLK-CLUSTER | Read-only view of snapshot bank |
| cpucl_pmu_count_hi[*] | Status in | Captured counter high word | CLK-CLUSTER | Used only when PARA_PMU_COUNTER_W=64 |
| cpucl_irq_raw.ovf_* | Hardware set / software W1C | Per-counter overflow cause | CLK-CLUSTER | New hardware event wins over software clear |
| cpucl_irq_en.ovf_* | Control out | Per-counter overflow mask | CLK-CLUSTER | Enables contribution to o_int_pmu |
| cpucl_irq_inj.ovf_* | Control out | Verification/software event injection | CLK-CLUSTER | Disabled or access-protected in production policy |
| cpucl_irq_sts.ovf_* | Status in | Masked pending cause | CLK-CLUSTER | Aggregate interrupt is asserted if any bit is 1 |

Workbook field names and access types are the CSR source of truth. Event selector encodings are still provisional until each event is mapped to a real signal in the pinned CVA6/HPDcache/LLC revisions. Any status crossing a clock domain must be synchronized before reaching the CSR block.

### 11.4 AXI4-Lite access behavior

The selected CSR generator is `CSR_Generation.py` v3.4, commit `c40f319`. The approved `AXIL_QUEUED` sheet uses a synchronous 32-bit AXI4-Lite interface, one read queue entry, one write queue entry, and `WSTRB=HONOR`. Mapped accesses return `OKAY`; misaligned accesses return `SLVERR` without register side effects. Reserved or unmapped local offsets return `DECERR`; reads return zero and writes have no side effect. AXI responses remain stable until accepted. The CSR window and LLC service window are separate 4-KiB regions in the approved local map.

Generator CSR được chốt là `CSR_Generation.py` v3.4, commit `c40f319`. Sheet `AXIL_QUEUED` dùng AXI4-Lite đồng bộ 32-bit, một entry hàng đợi đọc, một entry ghi và `WSTRB=HONOR`. Địa chỉ có register trả `OKAY`; truy cập lệch alignment trả `SLVERR` và không đổi register. Offset reserved hoặc không ánh xạ trả `DECERR`; read trả zero và write không có side effect. AXI response giữ ổn định đến handshake. Cửa sổ CSR và LLC service là hai vùng local 4 KiB riêng theo map đã chốt.

The control decoder shall reserve separate local windows for the generated cluster CSR and axi_llc service target. The absolute SoC base address and exact LLC offsets are integration inputs. The LLC SPM control field shall be tied to disabled behavior or made inaccessible; no software write may switch the LLC into runtime SPM mode.

Decoder dành hai vùng local riêng cho CSR cụm và cổng dịch vụ axi_llc. Base address SoC và offset chính xác của LLC do tích hợp cung cấp. Field điều khiển SPM phải bị tie-off hoặc không truy cập được; software không được bật SPM runtime.

## 12. Error handling and recovery

| Error ID | Detection condition | Observable response/status | Interrupt | Clear/recovery | Reset behavior |
|---|---|---|---|---|---|
| ERR-001 | AXI/ACE Subordinate returns non-OKAY | Original response code reaches requester | Optional PMU event | Software/platform handles bus error | Outstanding reset policy is SoC-owned |
| ERR-002 | Misaligned CSR access | SLVERR; no CSR side effect | Optional PMU event | Correct address and retry | Clear response state |
| ERR-003 | Unmapped AXI4-Lite local window | DECERR; read data zero; no write | Optional PMU event | Correct address | Clear response state |
| ERR-004 | Partial CSR strobe in REJECT policy | SLVERR; no register change | Optional PMU event | Full-word write or HONOR configuration | Clear response state |
| ERR-005 | PMU counter overflow | Counter wraps modulo 2^W; sticky cause set | o_int_pmu if cause enabled | Software clears cause | Cause clears on reset |
| ERR-006 | LLC BIST failure | LLC status reports failure; memory path must not claim ready | Optional fault event | System recovery or reset; exact axi_llc status | Reset restarts BIST |
| ERR-007 | Unsupported ACE transaction or snoop | Adapter must not silently discard; response policy is DEP-002 | Optional fault event | Integration-defined response/recovery | Reset per ACE system contract |
| ERR-008 | AXI/ACE protocol checker violation | Verification failure; no defined functional recovery claim | No functional interrupt is specified for a verification-only finding | Correct source/integration | Reset does not legalize malformed traffic |
| ERR-009 | Owner or LLC memory writeback fails during a CBO | CMO aborts prepared L1 holders, preserves retryable dirty state, then raises a precise synchronous Store/AMO access fault before CBO retirement | Architectural exception; no separate PMU interrupt required | Trap handler owns recovery; instruction is not reissued internally | Reset follows cluster cache-state reset contract |
| ERR-010 | Internal probe ACK has a stale, duplicate, unknown, wrong-hart, wrong-line, or wrong-phase tag | Consume and discard the response without updating any context/cache/directory state; set the coherence-protocol diagnostic. CSR field mapping is an integration dependency until workbook update. | Diagnostic status; no requester grant or cache-state change | Investigate source/tag association; clear diagnostic through the finalized CSR contract | Reset clears diagnostic and transient response state |
| ERR-011 | Ordinary dirty eviction receives a writeback error | Preserve recoverable data and affected lock/context; report fault through CSR without fabricated success | Sticky `o_int_fault` | Reset; no automatic retry | Clears fault/transient state under the cache reset contract |

Error response mapping for unsupported ACE snoops is not complete until the adapter supports a fixed, protocol-valid subset. No retry or timeout behavior is implied where not specified.

Phản hồi lỗi ACE không được khóa cho tới khi adapter có tập snoop cố định và hợp lệ. Không ngầm định retry hoặc timeout nếu chưa quy định.

## 13. Performance, power, and area

No numeric FCLK, area, or power target is supplied. PPA signoff requires the target standard-cell library, SRAM views, PVT/RC corners, voltage, SDC, interface budgets, clock uncertainty, activity workload, and chosen CPU/LLC/PMU parameters. RTL synthesis alone does not prove timing closure.

Chưa có mục tiêu số cho FCLK, area hoặc power. Signoff cần standard-cell library, SRAM views, PVT/RC corner, điện áp, SDC, budget giao tiếp, clock uncertainty, workload activity và cấu hình CPU/LLC/PMU. RTL synthesis không chứng minh timing closure.

| Metric ID | Metric | Target / limit | Conditions | Measurement method | Hard / goal |
|---|---|---|---|---|---|
| PPA-001 | Maximum frequency | Open integration dependency DEP-007 | Library, PVT, constraints | STA after synthesis/place | Open |
| PPA-002 | Cell area | Open integration dependency DEP-007 | Four-hart and 256-KiB LLC baseline | Synthesis and physical report | Open |
| PPA-003 | Dynamic/leakage power | Open integration dependency DEP-007 | Defined activity, voltage, temperature | Power analysis with SAIF/VCD | Open |
| PERF-001 | AXI throughput and coherence scaling | No fixed numeric claim; report IPC/latency as defined in Section 10.2.2 | Hart count, cache state, LLC/AXI behavior, workload | Cycle-accurate simulation and later silicon/FPGA measurement | Characterize; no target yet |
| PERF-002 | PMU event counting | One increment per qualified event | Implemented event source and clock | Event-to-counter comparison | Hard functional behavior |
| PERF-003 | LLC capacity | 256 KiB default | 4×4096×16-byte geometry | Parameter calculation and macro check | Hard default |
| PERF-004 | Internal MESI overhead | Compare local hits, S-to-M upgrades, clean/dirty misses, and probe overlap; no numeric delta claimed | 2/4 harts and identical benchmark/build conditions | Per-hart instret/cycle counters, transaction trace, and stall/event breakdown | Measurement method is required; target open |
| PERF-005 | Coherence worst-case and forward progress | No finite max latency under unbounded ACK/AXI waits; characterize arbitration, same-set conflict, probe queue, slot saturation, dirty-owner B wait, and reset recovery | Controlled fairness assumptions; 2/4 harts; 8/16 slots | Event/transaction trace, per-hart IPC/CPI, wait-cycle histograms, directory-bank occupancy, slot occupancy, and line-lock duration | Characterization required; no numeric target |

## 14. RTL implementation contract

### 14.1 Required coding baseline

New VLSIT RTL shall follow VLSIT RTL Design Rule v2 and use one module per file with matching filename, structural top wrappers only, named connections, unsigned four-state logic, explicit combinational defaults, always_comb for combinational logic, always_ff for state, and the project naming prefixes. Generated CSR RTL must come from the selected AXI4-Lite workbook and generator version. Third-party CVA6/HPDcache/Culsans/axi_llc source is not rewritten under the local naming rule; imported source revisions and licenses are tracked as dependencies.

RTL VLSIT mới phải theo VLSIT RTL Design Rule v2: mỗi module một file trùng tên module, top chỉ chứa cấu trúc kết nối, connection có tên, logic unsigned bốn trạng thái, default rõ ràng, always_comb cho tổ hợp, always_ff cho tuần tự và đúng prefix. CSR được sinh từ workbook AXI4-Lite và generator đã chọn. RTL bên thứ ba không tự viết lại theo naming rule cục bộ; phải theo dõi revision/license.

### 14.2 RTL hierarchy

| Module | Responsibility | Parent / instance | Clock/reset domains | Interface |
|---|---|---|---|---|
| m_vlsit_riscv_cluster_axi_top | Structural AXI profile top | SoC wrapper | CLK-CLUSTER/RST-CLUSTER | AXI4+ATOP memory, AXI4 MMIO, AXI4-Lite |
| m_vlsit_riscv_cluster_ace_top | Future ACE profile top; deferred from current RTL phase | Future SoC wrapper | Future phase | ACE memory, AXI MMIO, AXI4-Lite |
| m_vlsit_riscv_cluster_core | Shared control, PMU, debug and address decode | Either top | CLK-CLUSTER/RST-CLUSTER | CSR, interrupt/debug |
| m_vlsit_riscv_axi_route | Routes one tile AXI request by shared-table AW/AR class; returns local DECERR when invalid | Cluster core, one per tile | CLK-CLUSTER/RST-CLUSTER | Memory path plus cache/uncached class sideband, MMIO path, local-error events |
| m_vlsit_riscv_cpu_tile | One core/cache tile | Cluster core/fabric; instances `u_vlsit_riscv_cpu_tile_0` through `_3`, with only indices below PARA_CPU_NUM present | CLK-CLUSTER/RST-CLUSTER | CVA6, HPDcache, ownership request/grant, tagged probe/status, `perf_event_o[21:0]`, AW/AR region class/error |
| m_vlsit_riscv_tile_coh_adapter | Adapts native cache request IDs and line traffic to CCU request/grant/probe channels | One per `m_vlsit_riscv_cpu_tile` | CLK-CLUSTER/RST-CLUSTER | D-cache request, ownership grant, tagged probe/status and owner writeback completion |
| m_vlsit_riscv_coh_tile_array | Instantiates one tile coherence adapter per active hart and joins them to the shared MESI fabric; exports per-tag locks and same-line refill queries | `m_vlsit_riscv_cluster_core` | CLK-CLUSTER/RST-CLUSTER | Per-hart ownership, tagged probe, busy-query, line-lock, and diagnostic vectors |
| m_vlsit_riscv_cache_line_locks | Per-tag local physical-line exclusion from accepted PREPARE through successful terminal ACK | One per tile coherence adapter | CLK-CLUSTER/RST-CLUSTER | PREPARE acquire, COMMIT/ABORT release, access/victim queries and diagnostic |
| m_vlsit_riscv_coh_fabric | Directory-based internal MESI CCU and request routing | Either top | CLK-CLUSTER/RST-CLUSTER | Tile requests, tagged probes, directory, LLC |
| m_vlsit_riscv_cmo_controller | Serializes per-line Zicbom CBO operations with CPU coherence; waits for L1/LLC maintenance status and returns completion/error to CVA6 retirement logic | Cluster core and coherence fabric | CLK-CLUSTER/RST-CLUSTER | Decoded CBO op, physical line, original effective address/PC, tagged maintenance status |
| m_vlsit_riscv_coh_txn_table | Allocates and tracks 2–16 independent coherence/maintenance line transactions; default 8 | m_vlsit_riscv_coh_fabric | CLK-CLUSTER/RST-CLUSTER | Requester/CMO source, line lock, tag, target MESI state, phase/ACK masks, persistent owner-writeback and LLC status |
| m_vlsit_riscv_coh_bank_arb | Four independent registered round-robin arbiters; each bank selects an eligible slot, consumes one request token exactly once, waits for sampled VALID-low before rearming, and holds the grant through backpressure | m_vlsit_riscv_coh_fabric | CLK-CLUSTER/RST-CLUSTER | Transaction-valid vector, bank index per slot, four grant-valid/slot lanes, four grant-ready bits |
| m_vlsit_riscv_sharer_directory | Tracks conservative per-line holder sets and serializes metadata updates | m_vlsit_riscv_coh_fabric | CLK-CLUSTER/RST-CLUSTER | Physical line lookup/update, holder bitmap |
| m_vlsit_riscv_probe_scheduler | Routes tagged probes to selected cache holders and associates replies | m_vlsit_riscv_coh_fabric | CLK-CLUSTER/RST-CLUSTER | Tagged probe request/response paths |
| m_vlsit_riscv_ace_proxy | Future external ACE snoop adapter; deferred | Future ACE top | Future phase | External ACE and local probes |
| m_vlsit_riscv_ace_probe_router | Future external ACE per-tile snoop fanout/response collection; deferred | m_vlsit_riscv_ace_proxy | Future phase | ACE proxy and tile probes |
| m_vlsit_riscv_pmu | Event selection, counters, snapshot, aggregate IRQ | Cluster core | CLK-CLUSTER/RST-CLUSTER | CSR/events |
| m_vlsit_pmu_hart_evt | Collects mapped CVA6/HPDcache events with hart identity | m_vlsit_riscv_pmu | CLK-CLUSTER/RST-CLUSTER | Per-hart CVA6 `[21:0]` and HPDcache `[15:0]` event taps |
| m_vlsit_pmu_cluster_evt | Collects directory/CCU/LLC/fabric events without hart attribution; CCU transaction taps are 3-bit 0–4 counts and stall/LLC taps are one-bit indicators | m_vlsit_riscv_pmu | CLK-CLUSTER/RST-CLUSTER | Cluster event taps |
| m_vlsit_pmu_event_select | Applies event ID and scope selection | m_vlsit_riscv_pmu | CLK-CLUSTER/RST-CLUSTER | Event vectors and per-counter selectors |
| m_vlsit_pmu_aggregate | Sums same-cycle per-hart occurrences for aggregate scope | m_vlsit_riscv_pmu | CLK-CLUSTER/RST-CLUSTER | Per-hart events, active-hart mask, summed counts |
| m_vlsit_pmu_counter_bank | Parameterized per-counter event selection and count state | m_vlsit_riscv_pmu | CLK-CLUSTER/RST-CLUSTER | Event sources, selector/scope, count and overflow |
| m_vlsit_pmu_snapshot | Atomic counter-bank snapshot | m_vlsit_riscv_pmu | CLK-CLUSTER/RST-CLUSTER | Snapshot command, live counts, snapshot values/status |
| m_vlsit_pmu_irq | Sticky PMU cause and aggregate level interrupt | m_vlsit_riscv_pmu | CLK-CLUSTER/RST-CLUSTER | Counter overflow, enable/clear, cause and interrupt |
| m_vlsit_riscv_axil_decode | Control target decode and response routing | Cluster core | CLK-CLUSTER/RST-CLUSTER | External AXI4-Lite |
| m_vlsit_axil_reg_bridge | Converts LLC service AXI4-Lite accesses to the pinned PULP RegBus request/response interface | AXI-Lite decode / `m_vlsit_axi_llc` | CLK-CLUSTER/RST-CLUSTER | AXI4-Lite subordinate-side request, RegBus-side request/response |
| m_vlsit_riscv_axi_mmio | Merges per-tile MMIO requests and extends IDs with hart identity | Cluster core / SoC peripheral path | CLK-CLUSTER/RST-CLUSTER | Tile AXI4 inputs to one MMIO AXI4 manager |
| m_vlsit_riscv_debug_router | Routes external Debug Module requests and per-hart debug status | Cluster core | CLK-CLUSTER/RST-CLUSTER | Debug request/status vectors |
| m_vlsit_axi_llc | Shared static LLC wrapper | Coherence fabric | CLK-CLUSTER/RST-CLUSTER | AXI4 data; AXI4-Lite service |
| m_vlsit_cpucl_csr | Generated cluster CSR register block | AXI-Lite decode | CLK-CLUSTER/RST-CLUSTER | AXI4-Lite, CSR fields |

The approved RTL plan includes one AXI structural top and its 2/4-hart variants. The ACE top and proxy rows are future scope, not modules to generate now. `m_vlsit_riscv_axi_route` is instantiated through the cluster core. Section 6.2 is the external-port baseline: shared runtime `i_boot_addr[63:0]`, 7-bit memory IDs, 6-bit MMIO IDs, and 6-bit memory AWATOP. CVXIF is disabled by the selected license-preserving local config copy with no cluster-boundary ports. Instance names for repeated tiles use zero-based explicit suffixes (`u_vlsit_riscv_cpu_tile_0` ... `_3`); only the first PARA_CPU_NUM instances are elaborated. The standalone CMO controller still has no CVA6-to-CCU/LLC endpoint integration; it shall use the existing CCU line lock and transaction-context table rather than create a parallel lock or tag namespace. Internal port mappings must remain traceable to the pinned source trees.

### 14.3 Source and implementation status

**Native cache pin / Pin cache native (2026-11-14).** CVA6 revision `742dc82a0c706e0a3bfb98b709fd3ee06d50d12a` records HPDcache gitlink `e8f072e117ed3282950d4d1e975f462b173f0de0`. Native cache modifications shall use the pristine `rtl/third_party/hpdcache_cva6_pinned` checkout at that revision. The separately downloaded `rtl/third_party/hpdcache` at `40d2897eda70644df2eb857efd9fa573eaacafab` is a reference checkout, not a proven compatible replacement. / Bản sửa cache native dùng checkout đúng gitlink CVA6; clone HPDcache riêng ở revision khác chỉ dùng tham khảo và chưa được chứng minh thay thế tương thích.

**Flush completion mapping / Ánh xạ completion flush (2026-11-14).** The modified flush engine retains a 2-bit allocation origin in its existing writeback directory: 00=native eviction, 01=local CMO, 10=coherence probe, 11=reserved. A matching non-atomic B response returns line, origin and error. It frees only that transport entry, including on error; it does not authorize clearing MESI M/dirty/tag state. An out-of-range ID, inactive ID or atomic-marked response is consumed and diagnosed without acknowledging or freeing another entry. Compare the full response ID before truncating to the directory index. Probe integration must arbitrate the native cache data-array port and preserve stable MESI state until COMMIT/ABORT; simply ORing a third request into the allocation mux is insufficient. / Flush engine lưu nguồn yêu cầu trong directory writeback hiện có, trả line/nguồn/lỗi khi B khớp. Giải phóng entry vận chuyển không cho phép xóa M/dirty/tag. Response sai được nhận và báo diagnostic nhưng không giải phóng nhầm entry. Tích hợp probe vẫn phải phân xử cổng array native và giữ MESI đến COMMIT/ABORT.

The status describes the planned RTL work, not a completed implementation. Upstream reuse is conditional on a pinned source revision, file-level license review, exact configuration, and interface compatibility. A VLSIT wrapper around an upstream module is classified `MODIFY` because that integration logic must be designed and verified locally.

Trạng thái dưới đây mô tả kế hoạch RTL, không khẳng định đã triển khai xong. Việc tái sử dụng RTL upstream cần chốt revision, kiểm tra license từng file, cấu hình và tính tương thích giao diện. Wrapper VLSIT quanh module upstream được xếp `MODIFY` vì logic tích hợp vẫn phải thiết kế và kiểm chứng.

| Status | Meaning | Nghĩa |
|---|---|---|
| `REUSE` | Reuse upstream RTL unchanged after pin/config/license checks. | Dùng RTL upstream nguyên trạng sau khi kiểm tra revision/cấu hình/license. |
| `REUSE*` | Preferred upstream reuse candidate; drop-in compatibility is not yet demonstrated. | Module upstream dự kiến tái sử dụng; chưa chứng minh có thể ghép trực tiếp. |
| `MODIFY` | Adapt upstream logic, write a wrapper, or bind ASIC memories; retain source provenance. | Điều chỉnh logic upstream, viết wrapper hoặc gắn SRAM ASIC; giữ truy vết nguồn. |
| `NEW` | Design new VLSIT-owned RTL because the required cluster behavior is not supplied by a compatible source. | Thiết kế RTL mới thuộc VLSIT vì chưa có nguồn tương thích đáp ứng chức năng cụm. |
| `GENERATED` | Generate RTL from the reviewed CSR workbook and pinned generator. | Sinh RTL từ workbook CSR đã duyệt và generator đã chốt. |
| `EXTERNAL` | Supplied by the SoC; the cluster only defines its boundary contract. | Do SoC cung cấp; cluster chỉ quy định hợp đồng giao diện. |

`REUSE` does not transfer ownership of third-party RTL. Keep original notices and comply with each file's license. The licensing table in the source repositories is not a substitute for a tapeout release audit.

`REUSE` không chuyển quyền sở hữu RTL bên thứ ba. Phải giữ thông báo bản quyền và tuân thủ license của từng file. Bảng license trong repository không thay thế việc kiểm tra release trước tapeout.

### 14.4 Block-by-block design definition

The seven diagrams in Section 5.2 and the entries below describe the same proposed level-2 structure. The module/instance names below are intended names. For upstream blocks, the implementation source name may differ by revision and shall be confirmed when the exact commit is pinned. `REUSE*` is not a drop-in promise. FSM-011 is a separate control-flow view of the CMO behavior in Section 10.2.3.

Bảy sơ đồ ở Mục 5.2 và các mục dưới đây mô tả cùng cấu trúc đề xuất cấp 2. Tên module/instance là tên dự kiến. Với khối upstream, phải xác nhận tên RTL theo revision cụ thể khi chốt commit. `REUSE*` không có nghĩa là ghép trực tiếp được.

#### 14.4.1 Structural tops and shared cluster control

##### `m_vlsit_riscv_cluster_axi_top`

- **Feature / Tính năng:** Fixed-port AXI-only cluster shell / Khung cluster AXI-only có port cố định.
- **Function / Chức năng:** Instantiates the shared cluster structure, routes AXI4 memory egress, non-coherent AXI4 MMIO, and AXI4-Lite control. It has no ACE snoop pins. / Ghép cấu trúc cluster dùng chung, định tuyến AXI4 memory, AXI4 MMIO không coherence và AXI4-Lite; không có cổng snoop ACE.
- **Plan / Phương án:** `NEW` structural RTL. Reuse subordinate IP through the integration modules below; do not put pure RTL logic in this top. / `NEW`, chỉ RTL cấu trúc. Dùng IP con qua các module tích hợp bên dưới; không đặt logic RTL thuần trong top.

##### `m_vlsit_riscv_cluster_ace_top`

- **Feature / Tính năng:** Separate fixed-port ACE cluster shell / Khung ACE riêng với port cố định.
- **Function / Chức năng:** Future top only. It would instantiate the shared cluster and external ACE proxy; it is excluded from the current AXI RTL phase. / Chỉ dành cho giai đoạn sau. Module này sẽ ghép cluster và ACE proxy bên ngoài; hiện không thuộc phạm vi RTL AXI.
- **Plan / Phương án:** `DEFERRED`; do not generate in this phase. / `DEFERRED`; không tạo trong giai đoạn này.

##### `m_vlsit_riscv_cluster_core`

- **Feature / Tính năng:** Shared cluster management / Điều khiển dùng chung của cluster.
- **Function / Chức năng:** Connects CPU tiles, coherence routing, AXI-Lite decode, PMU, debug routing, and common status/error paths. / Kết nối tile CPU, định tuyến coherence, giải mã AXI-Lite, PMU, debug và các đường trạng thái/lỗi chung.
- **Plan / Phương án:** `NEW` VLSIT integration RTL. Freeze its interfaces after source-port mapping and CSR review. / `NEW`, RTL tích hợp VLSIT. Chốt giao diện sau khi đối chiếu port nguồn và duyệt CSR.

#### 14.4.2 CPU tile (diagram 01)

##### `cva6` — OpenHW CVA6

- **Feature / Tính năng:** RV64 application-class processor / Bộ xử lý ứng dụng RV64.
- **Function / Chức năng:** Executes the selected `cv64a6_imafdc_sv39_hpdcache_wb` configuration and supplies native interrupt, debug, performance, and cache requester interfaces. / Chạy cấu hình `cv64a6_imafdc_sv39_hpdcache_wb`, cung cấp giao diện ngắt, debug, performance và requester cache.
- **Plan / Phương án:** `MODIFY` a license-preserving integration copy of [OpenHW CVA6](https://github.com/openhwfoundation/cva6). The processor pipeline, MMU, and I-cache submodules remain unchanged. The local copy of `core/include/cv64a6_imafdc_sv39_hpdcache_wb_config_pkg.sv` sets `CVA6ConfigCvxifEn=0`; retain its license/header and add a dated history entry describing this config delta. The copied `core/cva6.sv` routes D-cache ownership-request/grant, tagged probe, CMO request/completion/error, six-class interrupt, debug, and PMU event-tap signals. The copied `core/commit_stage.sv`, `core/store_unit.sv`, and `core/store_buffer.sv` keep a CBO at the retirement head, prevent younger retirement, and deliver a precise Store/AMO access fault only after CMO rollback completes. CVXIF native pins, if present in the pinned module signature, stay contained and inactive at this licensed source boundary; none are exposed at the cluster top. The copied `core/csr_regfile.sv` adds supervisor software/timer interrupt inputs. These external levels are ORed with the stored software-writable MIP.SSIP/STIP bits for CSR readback and interrupt evaluation; CSR read-modify-write updates only the stored software state, so an asserted external level is not latched when software accesses MIP/SIP. Gate SSIP with `RVS && SoftwareInterruptEn` and STIP with `RVS`. The copied `core/perf_counters.sv` must export source event taps for the cluster PMU without changing architectural counter behavior. Preserve every original license notice and add dated modification history naming Quan Nguyen and Codex - VLSI Technology page. Keep the pinned `rtl/third_party/cva6` tree unchanged. / `MODIFY` bản sao tích hợp CVA6 [OpenHW](https://github.com/openhwfoundation/cva6) có giữ license. Pipeline xử lý, MMU và I-cache con giữ nguyên. Bản sao `core/include/cv64a6_imafdc_sv39_hpdcache_wb_config_pkg.sv` đặt `CVA6ConfigCvxifEn=0`; giữ license/header và thêm history có ngày mô tả thay đổi cấu hình. Bản sao `core/cva6.sv` định tuyến ownership-request/grant D-cache, probe có tag, CMO request/completion/error, sáu nhóm interrupt, debug và PMU event tap. Bản sao `core/commit_stage.sv`, `core/store_unit.sv` và `core/store_buffer.sv` giữ CBO ở đầu hàng retirement, chặn lệnh trẻ hơn và chỉ phát Store/AMO access fault đồng bộ chính xác sau khi CMO rollback xong. Nếu signature source đã pin còn CVXIF pin native, giữ chúng bên trong biên source có license và tie inactive; không đưa ra top cluster. Bản sao `core/csr_regfile.sv` thêm input ngắt software/timer supervisor. Mức ngoài được OR với bit MIP.SSIP/STIP software-writable đã lưu để đọc CSR và đánh giá ngắt; CSR read-modify-write chỉ cập nhật trạng thái software đã lưu nên không chốt mức ngoài. Gate SSIP theo `RVS && SoftwareInterruptEn`, STIP theo `RVS`. Bản sao `core/perf_counters.sv` phải xuất event tap cho PMU cluster mà không đổi hành vi counter kiến trúc. Giữ mọi license gốc và thêm lịch sử sửa đổi có ngày, ghi Quan Nguyen và Codex - VLSI Technology page. Không sửa cây nguồn đã pin tại `rtl/third_party/cva6`.

##### `m_vlsit_riscv_cpu_tile`

- **Feature / Tính năng:** Flat-port CVA6 tile wrapper with shared-table PMA configuration / Wrapper tile CVA6 dùng port phẳng và cấu hình PMA từ bảng vùng dùng chung.
- **Function / Chức năng:** Supplies runtime boot/hart/interrupt/debug inputs, exports PMU and debug-mode status, maps the selected CVA6 AXI record to flat channels, derives CVA6 cached/non-idempotent PMA lists, and classifies each live AXI AW/AR burst using the same synthesis-time table. The tile exports region match, index, class, and local-error metadata beside AW/AR; the cluster router must consume that metadata and suppress external traffic on error. Class `00` populates `CachedRegion*`; class `10` populates `NonIdempotent*`; class `01` remains idempotent and uncached. AXI USER sidebands are tied low or discarded because the approved cluster boundary has no USER ports and the selected local config disables USER semantics. / Cấp boot/hart/interrupt/debug runtime, xuất PMU/debug-mode, ánh xạ AXI record CVA6 sang port phẳng, tạo cached/non-idempotent PMA list và phân loại từng burst AXI AW/AR bằng cùng bảng compile-time. Tile xuất match, index, class và metadata lỗi cục bộ bên cạnh AW/AR; router cluster phải dùng metadata này và chặn traffic ra ngoài khi lỗi. Class `00` vào `CachedRegion*`; class `10` vào `NonIdempotent*`; class `01` giữ idempotent/uncached. USER sideband AXI được buộc 0 hoặc bỏ vì biên cluster đã duyệt không có USER và config cục bộ tắt semantics USER.
- **Plan / Phương án:** `NEW` VLSIT wrapper. It calls the license-preserving local `build_config_with_addr_regions` copy and instantiates two shared-table decoders for AW and AR. The output classification is implemented; the core/router is still missing, so this does not yet create local DECERR responses or block external requests. Upstream CVA6 source remains in `rtl/third_party` unchanged. / `NEW` wrapper VLSIT. Wrapper gọi bản sao `build_config_with_addr_regions` có giữ license và dùng hai decoder theo cùng bảng cho AW/AR. Phân loại đầu ra đã có; core/router chưa có nên hiện chưa sinh DECERR cục bộ hoặc chặn request đi ra ngoài. Source CVA6 upstream trong `rtl/third_party` được giữ nguyên.

##### `cva6_hpdcache_subsystem`

- **Feature / Tính năng:** CVA6 cache-subsystem integration / Tích hợp subsystem cache CVA6.
- **Function / Chức năng:** Connects the CVA6 cache requesters to the instruction-cache path and HPDcache path. / Nối requester cache CVA6 tới đường instruction cache và HPDcache.
- **Plan / Phương án:** `MODIFY` `core/cache_subsystem/cva6_hpdcache_subsystem.sv` in the license-preserving copy. Split the cacheable D-cache request/refill path from I-cache and device traffic; connect D-cache ownership-request/grant and tagged probe/data-response paths to the cluster coherence fabric. Preserve the I-cache and architectural request/response behavior. / `MODIFY` `core/cache_subsystem/cva6_hpdcache_subsystem.sv` trong bản sao có giữ license. Tách request/refill D-cache cacheable khỏi I-cache và traffic thiết bị; nối ownership-request/grant và probe/data response có tag tới coherence fabric. Giữ nguyên I-cache và hành vi request/response kiến trúc.

##### `cva6_icache`

- **Feature / Tính năng:** Private instruction cache / Instruction cache riêng của từng hart.
- **Function / Chức năng:** Supplies cached instruction lines to its CVA6 tile. / Cấp các cache line lệnh cho tile CVA6 tương ứng.
- **Plan / Phương án:** `REUSE` upstream I-cache unchanged; it is not hardware-coherent. Use the existing local `FENCE.I` I-cache/fetch invalidation path only after the dirty D-cache walk has delivered required lines to LLC; preserve the software inter-hart notification contract. / `REUSE` I-cache upstream nguyên trạng; không có hardware coherence. Chỉ dùng luồng invalidate I-cache/fetch cục bộ của `FENCE.I` sau khi D-cache dirty walk đã chuyển các line cần thiết lên LLC; giữ hợp đồng phần mềm thông báo giữa các hart.

##### `cva6_hpdcache_wrapper`

- **Feature / Tính năng:** CVA6-to-HPDcache port/configuration bridge / Cầu nối port và cấu hình CVA6–HPDcache.
- **Function / Chức năng:** Binds CVA6 requester records and HPDcache command/response interfaces. / Ghép record requester CVA6 với giao diện command/response HPDcache.
- **Plan / Phương án:** `MODIFY` `core/cache_subsystem/cva6_hpdcache_wrapper.sv` in the licensed copy. Carry CPU request ID and fixed tile hart identity across misses/refills and probes; expose a separate permission request/grant interface and tagged probe interface. Same-line operations serialize. Different-line probe contexts may overlap only within verified HPDcache MSHR, tag/data-array and write-buffer capacity. The selected CVA6 configuration uses a 3-bit D-cache request ID and a 128-bit line. / `MODIFY` `core/cache_subsystem/cva6_hpdcache_wrapper.sv` trong bản sao có license. Truyền CPU request ID và hart ID cố định của tile qua miss/refill và probe; đưa ra giao diện xin/cấp quyền riêng cùng giao diện probe có tag. Thao tác cùng line phải tuần tự. Chỉ cho phép probe khác line chạy chồng lấp trong giới hạn MSHR, tag/data-array và write buffer đã xác minh. Cấu hình CVA6 đã chọn dùng D-cache request ID 3 bit và line 128 bit.

##### `cva6_hpdcache_if_adapter`

- **Feature / Tính năng:** CVA6 request mapping into HPDcache operations / Ánh xạ request CVA6 sang thao tác HPDcache.
- **Function / Chức năng:** Maps decoded CBO operations to HPDcache CMO requests in the pinned implementation. / Bản upstream ánh xạ CBO đã giải mã thành request CMO nội bộ HPDcache.
- **Plan / Phương án:** `MODIFY` the license-preserving copy to intercept legal CBO operations and route them to `m_vlsit_riscv_cmo_controller`; preserve the CVA6 CBIE-decoded operation and prevent a local CMO path from bypassing the directory. Keep the pristine source unchanged. / `MODIFY` bản sao có giữ license để chặn CBO hợp lệ và chuyển tới `m_vlsit_riscv_cmo_controller`; giữ operation theo CBIE sau giải mã và ngăn CMO local bỏ qua directory. Giữ nguyên source gốc.

##### `hpdcache` — OpenHW HPDcache

- **Feature / Tính năng:** Private write-back L1 data cache / Data cache L1 write-back riêng.
- **Function / Chức năng:** Handles data requests, miss tracking, write buffering, and cache-management operations for each hart. / Xử lý truy cập dữ liệu, theo dõi miss, write buffer và thao tác quản lý cache cho từng hart.
- **Plan / Phương án:** `MODIFY` license-preserving copies of [OpenHW HPDcache](https://github.com/openhwfoundation/cv-hpdcache); keep the pristine clone unchanged. The planned direct edit set is `hpdcache.sv` (ownership/probe ports, per-line MESI metadata, third flush source, separate completion routing), `hpdcache_ctrl.sv` (control-path wiring and permission checks), `hpdcache_ctrl_pe.sv` (permission-before-fill/upgrade and same-line exclusion), `hpdcache_memctrl.sv` (arbitrated tag/data-array access and tag-to-way resolution), `hpdcache_miss_handler.sv` (ownership before memory issue/refill), `hpdcache_mshr.sv` (per-miss ownership state and transaction-tag association), and `hpdcache_flush.sv` (origin-aware completion and B-error reporting). The local directory record is declared in `hpdcache.sv`; add one `exclusive` bit there to distinguish clean E from clean S. A dirty 128-bit line is read by the existing flush engine as two 64-bit words and written through the owner's AXI path; probe response carries status only. The owner keeps M and the line lock until COMMIT/ABORT. Shared tag/data RAM, flush-engine, and AXI resources mean a probe/writeback can stall CPU work; other addresses progress only when those resources permit. The FENCE.I path shall transfer dirty M-owner lines into the LLC through the CCU before local I-cache/fetch invalidation; verify its directory transitions and include any required licensed source copies before freezing the file list. On an L1-to-LLC B error, preserve the failed M line and directory holder, complete ABORT, then raise the cause-24 synchronous maintenance exception at the FENCE.I PC with the aligned physical line base in `mtval`/`stval`; the required behavior is in DEC-031, while CVA6 trap-path implementation and verification remain DEP-021. Do not claim Culsans compatibility; it uses a different cache implementation. / `MODIFY` các bản sao source [OpenHW HPDcache](https://github.com/openhwfoundation/cv-hpdcache) có giữ license; giữ nguyên clone gốc. Danh sách file dự kiến sửa trực tiếp gồm `hpdcache.sv` (port ownership/probe, MESI metadata, nguồn flush thứ ba, route completion riêng), `hpdcache_ctrl.sv` (nối điều khiển và kiểm tra quyền), `hpdcache_ctrl_pe.sv` (xin quyền trước refill/upgrade và khóa cùng line), `hpdcache_memctrl.sv` (phân xử truy cập tag/data array và tìm way theo tag), `hpdcache_miss_handler.sv` (xin quyền trước khi gửi request memory/refill), `hpdcache_mshr.sv` (lưu quyền từng miss và ghép tag transaction), và `hpdcache_flush.sv` (completion theo nguồn, báo lỗi B). Record directory cục bộ nằm trong `hpdcache.sv`; thêm bit `exclusive` để phân biệt E sạch với S sạch. Flush engine hiện đọc dirty line 128-bit thành hai word 64-bit và ghi qua AXI path của owner; probe response chỉ mang status. Owner giữ M và line lock tới COMMIT/ABORT. Tag/data RAM, flush engine và AXI dùng chung tài nguyên nên probe/writeback có thể stall CPU; địa chỉ khác chỉ chạy tiếp khi các tài nguyên đó cho phép. Đường FENCE.I phải chuyển line dirty từ M owner vào LLC qua CCU trước khi invalidate I-cache/fetch cục bộ; cần xác minh directory transition và bổ sung bản sao source có license nếu cần trước khi khóa file list. Nếu B L1-to-LLC lỗi, giữ M line và directory holder, hoàn tất ABORT rồi phát exception đồng bộ cause 24 tại PC FENCE.I với physical line base căn chỉnh trong `mtval`/`stval`; hành vi này nằm trong DEC-031, còn implementation/verification trap path của CVA6 thuộc DEP-021. Không khẳng định tương thích Culsans vì Culsans dùng cache khác.

##### `m_vlsit_riscv_tile_coh_adapter`

**Local locks (2026-11-14) / Khóa local.** The adapter now instantiates `m_vlsit_riscv_cache_line_locks`. An accepted cache-side PREPARE handshake acquires the matching tag/line lock, including same-edge access/victim exclusion. A same-tag/same-line PREPARE is idempotent; a different tag for a locked line or a different line for an occupied tag waits. A PREPARE error retains the lock. Only an accepted successful COMMIT/ABORT response with matching tag/line releases it; reset clears all locks. Invalid release responses are diagnosed without releasing another line. Acquisition and release of the same tag cannot handshake together. Native HPDcache must apply the access query at its physical-address decision/replay point and exclude a locked victim. These queries must not prevent an already admitted same-line refill from stabilizing. The native probe queue READY must not depend combinationally on a query that includes that same probe's handshake. This is a local exclusion mechanism, not the stable MESI-state store or array arbiter. / Adapter đã chứa khóa local theo tag/line. Khóa bắt đầu khi nhận PREPARE, giữ qua lỗi PREPARE và chỉ nhả sau ACK COMMIT/ABORT thành công, khớp tag/line. HPDcache phải dùng query tại điểm quyết định có địa chỉ vật lý/replay và loại victim đang khóa. Không được chặn refill đã được cấp quyền hoặc tạo vòng tổ hợp READY/query. Phần này chưa thay cho metadata MESI hoặc arbiter array.

**RTL boundary mapping (2026-11-14) / Ánh xạ biên RTL.** The standalone adapter has one elastic ownership-request entry and one elastic grant entry. Each entry adds one registered boundary without stalls and supports simultaneous dequeue/replacement. It preserves the native 3-bit request ID, 52-bit physical line and request kind; grants retain ID, line, MESI and error. `gnt` is the RTL abbreviation for grant. Probe request/response handshakes are transparent and carry tag, line, phase, target state, writeback enable and response status unchanged. Reset clears both entries and suppresses probe VALID/READY. The native cache must enforce the adapter's local lock queries; it continues to own probe queuing, refill stabilization, MESI changes and AXI writeback. / Adapter độc lập có một entry đàn hồi cho request xin quyền và một entry cho grant, mỗi chiều thêm một biên thanh ghi khi không stall và cho phép nhận mới cùng cạnh lấy entry cũ. Probe đi xuyên với đầy đủ metadata. Reset xóa entry và chặn bắt tay probe. HPDcache phải áp dụng query khóa local của adapter và vẫn phải thực hiện queue probe, chờ refill, đổi MESI cùng writeback AXI.

- **Feature / Tính năng:** Per-tile coherent-boundary adapter / Adapter coherence cho từng tile.
- **Function / Chức năng:** Translates the pinned CVA6/HPDcache memory-side request and response semantics into the local coherence-fabric contract. / Chuyển ngữ nghĩa request/response memory-side CVA6/HPDcache sang hợp đồng coherence fabric nội bộ.
- **Plan / Phương án:** `NEW` VLSIT RTL. Adapt source-specific request IDs/ordering to the local ACE-subset contract; same-line CPU requests wait behind probes, while unrelated lines remain eligible if local resources permit. Freeze exact fields after source-port mapping. / `NEW` RTL VLSIT. Ánh xạ ID/thứ tự đặc thù của nguồn vào hợp đồng ACE subset nội bộ; request CPU cùng line chờ probe, line khác được phép chạy nếu tài nguyên cho phép. Chốt field sau khi đối chiếu port nguồn.

#### 14.4.3 Internal coherence and non-coherent MMIO (diagram 02)

##### `m_vlsit_riscv_coh_fabric` / VLSIT MESI CCU

- **Feature / Tính năng:** Directory-based multi-hart MESI ownership and tagged probe service / Quản lý MESI nhiều hart bằng directory và probe có tag.
- **Function / Chức năng:** Allocates tagged line transactions, consults the non-inclusive sharer directory, runs PREPARE before data-dependent work, sends COMMIT only after prerequisites succeed, and sends ABORT for precommit errors. PREPARE, COMMIT, and ABORT have no ACK timeout; a missing ACK retains the transaction slot and line lock until reset. The CCU separates cacheable memory from device traffic. / Cấp transaction line có tag, tra directory sharer không inclusive, chạy PREPARE trước thao tác phụ thuộc dữ liệu, chỉ COMMIT khi điều kiện thành công và ABORT nếu lỗi trước commit. PREPARE, COMMIT và ABORT không có timeout ACK; thiếu ACK thì giữ transaction slot và line lock đến reset. CCU tách memory cacheable khỏi traffic thiết bị.
- **Plan / Phương án:** `NEW` VLSIT CCU. The user selected an independent directory, tagged concurrency, and two-phase probe/recovery on 2026-11-07. Culsans is architecture reference only; its PlanV CVA6 snoop ports do not match OpenHW HPDcache. Exact source port mapping remains a generation blocker. / `NEW` CCU VLSIT. Người dùng đã chọn directory độc lập, transaction có tag và probe hai pha. Culsans chỉ là tài liệu tham khảo; port snoop PlanV CVA6 không khớp OpenHW HPDcache. Ánh xạ port source chính xác vẫn chặn bước sinh RTL.

##### `m_vlsit_riscv_cmo_controller`

**RTL service mapping (2026-11-14) / Ánh xạ dịch vụ RTL.** One command is accepted at a time after per-hart arbitration. Encodings are `00=CLEAN`, `01=FLUSH`, `10=resolved true INVAL`; `11` and inactive hart indices are not accepted. The controller retains hart, original PC/effective address and physical line. `ccu_begin` uses VALID/READY to ask the fabric to allocate its existing shared context and prepare the holders; it carries the resolved op and writeback-enable policy. The fabric returns a held VALID/READY PREPARE result with context tag/error and keeps the context locked, including on an error. Successful PREPARE issues the matching per-line LLC maintenance; an error skips LLC service. The controller then sends `ccu_finish` with the same tag and commit=1 on success or commit=0 for ABORT. Its DONE input means all required acknowledgements and the directory terminal operation have completed and the CCU has safely released the context. Only afterward does `o_cmo_done` pulse for one cycle with the retained hart, PC, effective address and error. Completion on the same edge as a maintenance/finish request is accepted is supported. There is no timeout. CVA6 retirement, cache probe execution, LLC maintenance and the CCU service endpoints remain separate integration work. / Controller nhận một CBO mỗi lần, lưu metadata và dùng context CCU hiện có. Chỉ sau PREPARE thành công mới yêu cầu LLC; mọi lỗi đi ABORT và chờ CCU hoàn tất ACK cùng directory trước khi phát done một chu kỳ. Phải giữ CBO tại retirement đến done; nhận request không phải completion. Controller chưa tự thực hiện các endpoint CCU, cache và LLC.

- **Feature / Tính năng:** Per-line system-wide Zicbom maintenance and precise CBO completion / Bảo trì Zicbom từng line toàn hệ thống và hoàn tất CBO chính xác.
- **Function / Chức năng:** Accepts the CVA6-decoded CBO operation and translated physical line, uses the shared CCU line lock/context, prepares the recorded L1 holders, issues the selected LLC per-line CLEAN/FLUSH/INVAL operation, then commits or aborts. It returns success only after all required acknowledgements. A writeback error is returned to CVA6 only after ABORT acknowledgements; commit logic raises the synchronous fault before CBO retirement. It does not allocate a second transaction table or line lock. / Nhận CBO đã giải mã và địa chỉ line vật lý đã dịch từ CVA6, dùng line lock/context CCU hiện có, prepare các L1 holder, yêu cầu LLC CLEAN/FLUSH/INVAL theo line, sau đó commit hoặc abort. Chỉ báo thành công khi nhận đủ acknowledgement. Lỗi writeback chỉ trả CVA6 sau khi đủ ABORT acknowledgement; commit logic phát trap đồng bộ trước khi CBO nghỉ hưu. Khối không tạo transaction table hoặc line lock thứ hai.
- **Plan / Phương án:** `NEW` VLSIT RTL. Full port fields, operation encoding, context ownership, and exact source cut points remain in the RTL port-plan review gate. / RTL VLSIT `NEW`. Field port, mã operation, quyền sở hữu context và điểm nối source phải được chốt trong port plan trước khi sinh RTL.


##### `m_vlsit_riscv_coh_txn_table`

- **Feature / Tính năng:** Concurrent coherence transaction contexts / Ngữ cảnh giao dịch coherence đồng thời.
- **Cross-phase state contract / Hợp đồng trạng thái qua phase:** Preserve target MESI state, owner identity, writeback completion/error, and expected/received ACK masks through PREPARE, COMMIT, and ABORT. A phase transition must not clear information needed to validate a later response or choose the cache's target state. Release fields only after the full transaction is safely complete. / Giữ MESI đích, owner, trạng thái thành công/lỗi writeback và mask ACK cần nhận/đã nhận qua PREPARE, COMMIT, ABORT. Chuyển phase không được xóa dữ liệu cần để xác thực response sau hoặc chọn trạng thái cache đích. Chỉ giải phóng trường khi toàn transaction đã hoàn tất an toàn.
- **Function / Chức năng:** Stores source, requester ID, 52-bit physical line, transaction kind, current phase, expected/received per-hart ACK masks, phase error, and owner-writeback completion. It rejects duplicate active lines, allocates the lowest free slot, and reports phase completion only after every expected ACK. The fabric explicitly releases a slot when the whole transaction is safe to retire; this table does not track LLC completion or requester completion. / Lưu source, requester ID, physical line 52-bit, loại transaction, phase hiện tại, mask ACK cần nhận/đã nhận theo hart, lỗi phase và trạng thái writeback owner. Khối từ chối hai context cùng khóa một line, cấp slot trống có index thấp nhất và chỉ báo phase xong sau khi đủ ACK. Fabric chủ động release slot khi toàn transaction đã an toàn; table không theo dõi hoàn tất LLC hay requester.
- **Plan / Phương án:** `NEW` VLSIT RTL. `PARA_COH_TXN_NUM` defaults to 8 and accepts 2–16; tag width derives from that parameter. PREPARE/COMMIT/ABORT ACKs have no timeout. / `NEW` RTL VLSIT. `PARA_COH_TXN_NUM` mặc định 8, nhận 2–16; độ rộng tag suy ra từ parameter. ACK PREPARE/COMMIT/ABORT không có timeout.

##### `m_vlsit_riscv_coh_bank_arb`

- **Feature / Tính năng:** Four independent per-bank round-robin arbiters / Bốn bộ phân xử round-robin độc lập theo bank.
- **Token contract / Hợp đồng token:** Consume each accepted slot request once; do not re-grant that slot until VALID has been sampled low and later asserted for a new operation. Preserve grant slot identity through backpressure. This is a bank-arbiter contract, not a change to AXI VALID/READY semantics. / Nhận mỗi request slot đúng một lần; không cấp lại grant cho slot đến khi đã quan sát VALID thấp rồi VALID được bật lại cho thao tác mới. Giữ slot grant ổn định khi backpressure. Đây là hợp đồng của bank arbiter, không thay đổi ngữ nghĩa AXI VALID/READY.
- **Function / Chức năng:** Each bank scans only eligible transaction slots from its zero-reset priority pointer and registers one eligible grant. An ineligible request cannot occupy or hold the grant. A matching reservation-owner terminal update/cancel remains eligible and has an escape path past a blocked non-owner operation. The selected eligible slot stays stable while `i_gnt_ready` is low. On grant acceptance, the pointer advances to the slot after the accepted one. Different banks may grant in the same cycle; each bank accepts at most one operation per cycle. The arbiter does not own transaction state or set reservations. / Mỗi bank chỉ quét các transaction slot đủ điều kiện từ con trỏ reset về 0 rồi đăng ký một grant hợp lệ. Request không đủ điều kiện không được chiếm hoặc giữ grant. Update/cancel terminal của đúng chủ reservation vẫn đủ điều kiện và phải đi qua thao tác khác đang bị chặn. Slot hợp lệ được chọn giữ ổn định khi `i_gnt_ready` thấp. Khi grant được nhận, con trỏ chuyển sang slot kế tiếp. Các bank khác nhau có thể grant cùng chu kỳ; mỗi bank nhận tối đa một thao tác mỗi chu kỳ. Arbiter không sở hữu transaction state hoặc reservation set.
- **Plan / Phương án:** `NEW` VLSIT RTL, `PARA_COH_TXN_NUM=8` by default and 2–16 legal. The generated bank lanes are fixed at four. / RTL VLSIT `NEW`, `PARA_COH_TXN_NUM=8` mặc định, hợp lệ từ 2 đến 16. Số bank cố định là bốn.


##### `m_vlsit_riscv_sharer_directory`

- **Feature / Tính năng:** Per-line conservative D-cache holder tracking / Theo dõi bảo thủ cache holder theo line.
- **Function / Chức năng:** Tracks MESI state and D-cache holder bits independently from LLC residency; LLC eviction does not invalidate L1. Each of four indexed bank lanes accepts at most one eligible operation per cycle. A miss reserves its set by transaction tag until a matching committed update or pre-COMMIT cancel. Same-set operations from other tags remain ineligible, but they cannot occupy the arbiter grant or block a matching reservation-owner update/cancel. A matching cancel clears only the reservation; it does not change MESI/holder state. A full set returns its tree-PLRU victim and metadata for the CCU to invalidate/resolve before reuse. / Theo dõi MESI và holder D-cache độc lập với LLC; LLC eviction không invalidate L1. Mỗi bank trong bốn bank nhận tối đa một thao tác đủ điều kiện mỗi chu kỳ. Miss đặt reservation trên set theo transaction tag đến khi update commit hoặc cancel trước COMMIT. Thao tác cùng set từ tag khác vẫn không đủ điều kiện, nhưng không được chiếm grant hoặc chặn update/cancel của đúng chủ reservation. Cancel đúng chủ chỉ xóa reservation, không đổi MESI/holder. Set đầy trả victim tree-PLRU và metadata để CCU invalidate/xử lý trước khi tái sử dụng.


- **Plan / Phương án:** `NEW` VLSIT RTL. Four indexed bank lanes are provided; each accepts one eligible operation per cycle and requires `line[1:0]` to match its lane. Select among eligible transaction slots round-robin; do not register or hold an ineligible request. A matching reservation-owner terminal `UPDATE` or `CANCEL` shall bypass a blocked non-owner update; each bank still accepts at most one operation per cycle. Each 8-way set stores seven tree-PLRU bits initialized to zero (`0` selects left and `1` right during victim walk), chooses the lowest-index invalid way first, updates the PLRU path on an accepted hit lookup and on a committed state update, and reserves a missed set by tag until update/cancel. Other sets in the same bank may proceed while a set is reserved. The physical bank port is not held while waiting for probes or AXI responses. Geometry is 4,096/8,192 entries for 2/4 harts. Physical SRAM mapping and ECC remain SoC/library inputs. / `NEW` RTL VLSIT. Khối có bốn lane bank; mỗi lane nhận một thao tác đủ điều kiện mỗi chu kỳ và yêu cầu `line[1:0]` khớp số lane. Phân xử round-robin trên các transaction slot đủ điều kiện; không đăng ký/giữ request không đủ điều kiện. `UPDATE` hoặc `CANCEL` terminal của đúng chủ reservation phải đi qua update bị chặn của tag khác; mỗi bank vẫn chỉ nhận một thao tác mỗi chu kỳ. Mỗi set 8 way lưu bảy bit tree-PLRU khởi tạo bằng 0, ưu tiên way invalid index thấp nhất và cập nhật PLRU theo thao tác được nhận/commit. Set miss được reserve theo tag đến update/cancel. Set khác trong cùng bank có thể tiếp tục; cổng bank không được giữ khi đợi probe hoặc AXI response. Hình học 4.096/8.192 entry cho 2/4 hart. Ánh xạ SRAM vật lý và ECC phụ thuộc SoC/library.


##### `m_vlsit_riscv_probe_scheduler`

**PREPARE writeback policy / Chính sách ghi trả PREPARE (implementation mapping, 2026-11-14).** REQ-MEM-015 requires an explicit `wback_en` bit in addition to the target MESI state. The transaction table captures `i_alloc_wback_en` at allocation and exports `o_ctx_wback_en` by tag. The scheduler captures that bit with the same context's tag, line, phase and target state, holds `o_probe_req_wback_en` through request backpressure, and asserts it only for PREPARE. True INVAL uses zero; read sharing, unique-ownership invalidation, CLEAN, FLUSH and FENCE.I clean use one where dirty data must be preserved. COMMIT and ABORT use zero. This bit authorizes writeback of an M line; it does not force a clean line to write back or replace matching B-response completion. / Bổ sung bit `wback_en` gắn với context để phân biệt PREPARE của true INVAL với FLUSH khi cả hai cùng có MESI đích I. True INVAL dùng 0; thao tác cần bảo toàn dirty data dùng 1. Scheduler giữ bit ổn định cùng tag/line/phase qua backpressure và chỉ bật ở PREPARE. COMMIT/ABORT dùng 0. Bit này cho phép ghi trả line M, không ép ghi line sạch và không thay thế việc chờ B response khớp.

- **Feature / Tính năng:** Tagged targeted-probe issue and response association / Phát probe đích có tag và ghép response.
- **Context association / Ghép context:** Probe target state, owner identity, and phase status must come from the same active context selected by tag; do not sample an unassociated live target-state signal. / MESI đích của probe, owner và trạng thái phase phải lấy từ cùng active context được chọn bằng tag; không lấy từ tín hiệu MESI đích đang thay đổi nhưng không gắn với context.
- **Function / Chức năng:** Independently arbitrates eligible transaction slots for each hart, holds one probe request per hart through backpressure, and buffers responses for the transaction table. It accepts a transport-valid response when response-buffer space is available, then checks active tag, line, hart, and phase. Only a unique expected response becomes an ACK. A stale, duplicate, or mismatched response is consumed, discarded, and diagnosed without changing transaction state, so it cannot block a later valid response. The scheduler adds no response timeout or data payload. / Phân xử độc lập các slot đủ điều kiện cho từng hart, giữ một probe request mỗi hart qua backpressure và đệm response cho transaction table. Khi còn chỗ buffer, khối nhận response đúng giao thức trước rồi mới so tag, line, hart và phase. Chỉ response đúng và duy nhất mới thành ACK. Response cũ, trùng hoặc sai được nhận, bỏ và báo diagnostic mà không đổi transaction state, không chặn response đúng phía sau. Scheduler không thêm timeout hoặc payload dữ liệu.
- **Plan / Phương án:** `NEW` VLSIT RTL plus a separately modified, license-preserving HPDcache copy. Each D-cache services one probe at a time. PREPARE locks the line without changing stable MESI state; COMMIT applies the target state; ABORT releases the line with the old state intact. No phase has an ACK timeout; preserve the pristine upstream clone. Exact cache-side source-port mapping remains open. / `NEW` RTL VLSIT cùng bản sao HPDcache được sửa riêng và giữ license. Mỗi D-cache xử lý một probe tại một thời điểm. PREPARE khóa line nhưng không đổi MESI stable; COMMIT áp dụng state đích; ABORT nhả khóa và giữ state cũ. Không phase nào có timeout ACK; giữ nguyên clone upstream. Ánh xạ port phía cache còn mở.


##### `axi_mux` — PULP AXI

- **Feature / Tính năng:** AXI request arbitration / Phân xử request AXI.
- **Function / Chức năng:** Merges compatible cacheable AXI request sources while preserving response routing and IDs. / Ghép các nguồn request AXI cacheable tương thích và giữ định tuyến response/ID.
- **Plan / Phương án:** `REUSE*` candidate. Confirm number of inputs, ID width, ordering, and outstanding-transaction behavior; otherwise add a VLSIT wrapper or replace it. / `REUSE*` dự kiến. Kiểm tra số ngõ vào, độ rộng ID, ordering và giao dịch outstanding; nếu không phù hợp thì viết wrapper VLSIT hoặc thay thế.

##### `m_vlsit_riscv_addr_decode`

- **Feature / Tính năng:** Shared-table physical-address classification / Phân loại địa chỉ vật lý từ bảng dùng chung.
- **Function / Chức năng:** Validates a whole access against the synthesis-time table and returns class, entry index, table-valid status, and local access-error metadata. Invalid parameter combinations make the static `o_config_valid` result low and mark accesses as errors. CVA6 PMA lists are derived from this same table in the tile configuration adapter. / Kiểm tra toàn bộ access theo bảng compile-time và trả class, entry index, trạng thái bảng hợp lệ, metadata lỗi cục bộ. Cấu hình parameter sai làm `o_config_valid` tĩnh xuống thấp và đánh dấu access là lỗi. Danh sách PMA của CVA6 được tạo từ cùng bảng tại adapter cấu hình tile.
- **Plan / Phương án:** `NEW` VLSIT RTL. The decoder and per-tile AW/AR metadata are implemented as leaves. A standalone route leaf now consumes match/class/error metadata and returns local DECERR, but core integration and a hard build-time failure for an invalid table remain open. The recorded Verilator invalid-table probe did not fail elaboration. / `NEW` RTL VLSIT. Decoder và metadata AW/AR từng tile đã có dạng leaf. Route leaf độc lập đã dùng match/class/error và trả DECERR cục bộ, nhưng tích hợp core và hard-fail build khi bảng sai vẫn chưa có. Probe Verilator với bảng sai không làm elaboration thất bại.

##### `axi_demux` — PULP AXI

- **Feature / Tính năng:** AXI target routing / Định tuyến target AXI.
- **Function / Chức năng:** Sends decoded transactions to the selected target and associates returned responses. / Chuyển giao dịch đã giải mã tới target và ghép response trả về.
- **Plan / Phương án:** `REUSE*` candidate. Verify topology, ID tracking, and error response behavior against the fixed cluster interface. / `REUSE*` dự kiến. Kiểm tra topology, theo dõi ID và response lỗi với giao diện cluster cố định.

##### `m_vlsit_riscv_axi_route`

- **Feature / Tính năng:** Per-tile AXI4 routing from shared-table metadata / Định tuyến AXI4 từng tile bằng metadata bảng dùng chung.
- **Function / Chức năng:** Routes cacheable and normal-uncached requests to the memory target, retaining the region class on AW/AR for the LLC bypass decision. Routes MMIO requests to the external peripheral target. Unmapped, malformed, invalid-table, MMIO ATOP, and MMIO exclusive requests select the local PULP `axi_err_slv`, which returns DECERR. The unchanged PULP `axi_demux` retains target association for outstanding B/R responses. / Đưa cacheable và normal-uncached tới memory, giữ class trên AW/AR để LLC quyết định bypass. MMIO đi tới target ngoại vi. Request không khớp, sai định dạng, bảng sai, ATOP hoặc exclusive tới MMIO được chuyển tới `axi_err_slv` của PULP để trả DECERR. `axi_demux` PULP không sửa đổi giữ liên kết target cho response B/R đang chờ.
- **Plan / Phương án:** `NEW` VLSIT adapter around unmodified PULP cells. The leaf is linted but not yet instantiated because `m_vlsit_riscv_cluster_core` is missing. / Adapter VLSIT `NEW` quanh cell PULP giữ nguyên. Leaf đã lint nhưng chưa được instance do còn thiếu `m_vlsit_riscv_cluster_core`.

##### `m_vlsit_riscv_axi_mmio`

- **Feature / Tính năng:** Multi-hart MMIO AXI4 mux and ID extension / Mux AXI4 MMIO nhiều hart và mở rộng ID.
- **Function / Chức năng:** Merges the already-routed MMIO requests from active tiles, encodes hart identity in the output ID, and returns B/R responses to the matching tile. Address classification and local DECERR are handled by `m_vlsit_riscv_axi_route`. / Ghép request MMIO đã định tuyến từ các tile, mã hóa hart vào ID đầu ra và trả response B/R về tile tương ứng. Phân loại địa chỉ và DECERR cục bộ do `m_vlsit_riscv_axi_route` xử lý.
- **Plan / Phương án:** `NEW` VLSIT adapter around unmodified PULP `axi_mux`. Lint is recorded for 2 and 4 harts. / Adapter VLSIT `NEW` quanh `axi_mux` PULP giữ nguyên. Đã ghi nhận lint cho cấu hình 2 và 4 hart.

#### 14.4.4 Shared LLC (diagram 03)

##### `axi_llc_chan_splitter`

- **Feature / Tính năng:** AXI burst and descriptor splitting / Chia burst AXI thành descriptor.
- **Function / Chức năng:** Splits memory transactions into LLC line operations and merges data-channel work with flush/control descriptors. / Chia giao dịch memory thành thao tác theo line LLC và ghép công việc kênh dữ liệu với descriptor flush/điều khiển.
- **Plan / Phương án:** `REUSE*` from PULP `axi_llc`; pin source and confirm its fixed line geometry and AXI widths. / `REUSE*` từ PULP `axi_llc`; chốt nguồn và xác nhận geometry line/độ rộng AXI.

##### `axi_llc_burst_cutter`

- **Feature / Tính năng:** Burst-to-line descriptor generation / Tạo descriptor line từ burst.
- **Function / Chức năng:** Splits a multi-line AXI burst into per-line operations and tracks the remaining transfer. / Chia burst AXI qua nhiều line thành thao tác từng line và theo dõi phần giao dịch còn lại.
- **Plan / Phương án:** `REUSE*` as an internal PULP `axi_llc` submodule; confirm its exact hierarchy and boundary from the pinned source. / `REUSE*` như submodule nội bộ của PULP `axi_llc`; xác nhận hierarchy và biên giao diện theo nguồn đã chốt.

##### `axi_llc_hit_miss`

- **Feature / Tính năng:** LLC tag-result and miss control / Điều khiển kết quả tag và miss LLC.
- **Function / Chức năng:** Selects hit service or miss processing and coordinates line locks and ordering. / Chọn phục vụ hit hoặc xử lý miss, phối hợp khóa line và thứ tự giao dịch.
- **Plan / Phương án:** `MODIFY` a license-preserving source copy to accept the internal per-line CMO descriptor in the same line-exclusion/order domain as CPU traffic. Keep the pinned upstream clone unchanged. / `MODIFY` bản sao source có giữ license để nhận descriptor CMO từng line trong cùng miền khóa/thứ tự với traffic CPU; giữ nguyên clone upstream đã pin.

##### `axi_llc_lock_box_bloom`

- **Feature / Tính năng:** Same-line conflict exclusion / Ngăn xung đột cùng line.
- **Function / Chức năng:** Prevents concurrent descriptors from modifying the same cache line at the same time. / Ngăn descriptor đồng thời sửa cùng một cache line.
- **Plan / Phương án:** `REUSE*` as an internal PULP `axi_llc` submodule; validate behavior under backpressure and flush. / `REUSE*` như submodule nội bộ của PULP `axi_llc`; kiểm tra khi có backpressure và flush.

##### `axi_llc_miss_counters`

- **Feature / Tính năng:** Miss descriptor ordering / Sắp thứ tự descriptor miss.
- **Function / Chức năng:** Tracks outstanding misses and preserves the required order as misses are accepted and completed. / Theo dõi miss outstanding và giữ thứ tự cần thiết khi nhận/hoàn tất miss.
- **Plan / Phương án:** `REUSE*` as an internal PULP `axi_llc` submodule; check capacity against the cluster's outstanding limits. / `REUSE*` như submodule nội bộ của PULP `axi_llc`; đối chiếu dung lượng với giới hạn outstanding của cluster.

##### `axi_llc_tag_store`

- **Feature / Tính năng:** LLC tags, dirty metadata, and tag initialization / Tag LLC, metadata dirty và khởi tạo tag.
- **Function / Chức năng:** Looks up and updates tags and dirty state, including the documented tag-storage BIST path. / Tra cứu/cập nhật tag và dirty state, gồm đường BIST tag storage theo tài liệu nguồn.
- **Plan / Phương án:** `MODIFY` a separately copied, license-preserving PULP `axi_llc` source to add a per-line no-refill maintenance lookup and commit-gated clean/invalidate updates. Preserve the upstream header/license and add a dated modification history; keep `rtl/third_party/axi_llc` pristine. / `MODIFY` bản sao riêng có giữ license của PULP `axi_llc` để thêm tra cứu bảo trì từng line không refill và cập nhật clean/invalidate theo commit. Giữ header/license upstream, thêm history sửa đổi có ngày và giữ nguyên `rtl/third_party/axi_llc`.

##### `axi_llc_w_master`

- **Feature / Tính năng:** LLC dirty-line writeback and AXI B-response tracking / Ghi trả line dirty của LLC và theo dõi AXI B response.
- **Function / Chức năng:** Writes a dirty 16-byte line as two 64-bit AXI beats and waits for the matching B response. The per-line CMO path needs the response status to decide whether dirty/tag state may commit. / Ghi line dirty 16 byte thành hai beat AXI 64-bit và chờ B response tương ứng. Đường CMO từng line cần status response để quyết định có được commit dirty/tag state hay không.
- **Plan / Phương án:** `MODIFY` a license-preserving PULP `axi_llc` source copy to return the non-OKAY B status to the CMO descriptor owner and preserve valid/dirty/tag/data state on failure. Keep the upstream clone unchanged. / `MODIFY` bản sao PULP `axi_llc` có giữ license để trả B status lỗi cho chủ descriptor CMO và giữ valid/dirty/tag/data khi thất bại; giữ nguyên clone upstream.

##### `axi_llc_read_unit`

- **Feature / Tính năng:** LLC read-hit data path / Đường đọc hit của LLC.
- **Function / Chức năng:** Serves read hits from the configured cache ways and returns data to the AXI-side transaction. / Phục vụ đọc hit từ cache way và trả dữ liệu về giao dịch AXI.
- **Plan / Phương án:** `REUSE*` from PULP `axi_llc`; verify widths, strobes, bursts, and macro timing. / `REUSE*` từ PULP `axi_llc`; kiểm tra độ rộng, strobe, burst và timing macro.

##### `axi_llc_write_unit`

- **Feature / Tính năng:** LLC write-hit data path / Đường ghi hit của LLC.
- **Function / Chức năng:** Writes hit data and byte strobes into the selected cache way. / Ghi dữ liệu hit và byte strobe vào cache way được chọn.
- **Plan / Phương án:** `REUSE*` from PULP `axi_llc`; verify widths, strobes, bursts, and macro timing. / `REUSE*` từ PULP `axi_llc`; kiểm tra độ rộng, strobe, burst và timing macro.

##### `axi_llc_evict_unit`

- **Feature / Tính năng:** Dirty victim writeback / Ghi trả victim dirty.
- **Function / Chức năng:** Writes an evicted dirty cache line to the selected memory profile before its storage is reused. / Ghi line dirty bị thay thế về profile memory trước khi tái sử dụng chỗ lưu.
- **Plan / Phương án:** `REUSE*` from PULP `axi_llc`; ordering and ACE mapping require integration checks. / `REUSE*` từ PULP `axi_llc`; cần kiểm tra ordering và ánh xạ ACE.

##### `axi_llc_refill_unit`

- **Feature / Tính năng:** Cache-line refill / Nạp cache line.
- **Function / Chức năng:** Reads a missing line from the selected memory profile and installs it in the allocated cache way. / Đọc line còn thiếu từ profile memory và ghi vào cache way đã cấp.
- **Plan / Phương án:** `REUSE*` from PULP `axi_llc`; AXI-only profile is direct AXI, while ACE mapping remains an open adapter decision. / `REUSE*` từ PULP `axi_llc`; profile AXI dùng AXI, ánh xạ sang ACE vẫn cần chốt adapter.

##### LLC data-way storage and ASIC SRAM binding

- **Feature / Tính năng:** Static 256-KiB cache data storage / Storage dữ liệu cache tĩnh 256 KiB.
- **Function / Chức năng:** Stores cache-line data for the configured four-way, 4096-line, 16-byte baseline. / Lưu dữ liệu cache line theo cấu hình cơ sở bốn way, 4096 line, 16 byte.
- **Plan / Phương án:** `MODIFY` storage integration. Preserve [PULP `axi_llc`](https://github.com/pulp-platform/axi_llc) controller behavior while replacing/binding inferred or generic storage to the SoC SRAM macro, test ports, and timing model. / `MODIFY` tích hợp storage. Giữ hành vi controller [PULP `axi_llc`](https://github.com/pulp-platform/axi_llc), thay/gắn storage tổng quát với SRAM macro, cổng test và timing model của SoC.

##### `axi_llc_config wrapper`

- **Feature / Tính năng:** LLC BIST, flush, and status control / Điều khiển BIST, flush và trạng thái LLC.
- **Function / Chức năng:** Exposes the documented LLC service functions to software and reports completion/status. / Cung cấp chức năng dịch vụ LLC cho software và báo hoàn tất/trạng thái.
- **Plan / Phương án:** `MODIFY` wrapper/policy. Keep SPM disabled and route the service through the cluster AXI4-Lite decoder. / `MODIFY` wrapper/chính sách. Tắt SPM và định tuyến dịch vụ qua decoder AXI4-Lite của cluster.

##### `m_vlsit_axi_llc`

- **Feature / Tính năng:** Cluster LLC integration wrapper / Wrapper tích hợp LLC vào cluster.
- **Function / Chức năng:** Fixes geometry, data width, memory-profile connection, CSR service access, and ASIC storage binding around `axi_llc`. / Cố định geometry, data width, kết nối profile memory, dịch vụ CSR và gắn storage ASIC quanh `axi_llc`.
- **Plan / Phương án:** `NEW` VLSIT wrapper around a separately copied set of `MODIFY` PULP `axi_llc` modules. It routes CPU descriptors and per-line CMO descriptors into a shared same-line exclusion path and returns B/error status. Preserve all original licenses and modification history; do not edit the pristine `rtl/third_party/axi_llc` clone. / Wrapper VLSIT `NEW` quanh bản sao riêng các module PULP `axi_llc` loại `MODIFY`. Khối này ghép descriptor CPU và CMO từng line vào cùng đường khóa line, trả B/error status. Giữ license và history sửa đổi; không sửa clone nguyên bản trong `rtl/third_party/axi_llc`.

#### 14.4.5 AXI4-Lite control, CSR, and PMU (diagrams 04–05)

##### `axi_lite_demux` — PULP AXI

- **Feature / Tính năng:** AXI4-Lite target selection / Chọn target AXI4-Lite.
- **Function / Chức năng:** Routes the cluster control port to the CSR block or LLC service target. / Định tuyến cổng điều khiển cluster tới CSR hoặc dịch vụ LLC.
- **Plan / Phương án:** `REUSE*` candidate; verify address-window selection and response/error routing for the pinned version. / `REUSE*` dự kiến; kiểm tra chọn cửa sổ địa chỉ và định tuyến response/lỗi theo version đã chốt.

##### `m_vlsit_riscv_axil_decode`

- **Feature / Tính năng:** Cluster AXI4-Lite address map / Bản đồ địa chỉ AXI4-Lite của cluster.
- **Function / Chức năng:** Decodes the CSR and LLC service windows and returns defined responses for unmapped accesses. / Giải mã cửa sổ CSR/dịch vụ LLC và trả response quy định cho địa chỉ không ánh xạ.
- **Plan / Phương án:** `NEW` VLSIT RTL, unless the approved generator supplies this exact router. Freeze addresses and error policy with the CSR workbook. / `NEW` RTL VLSIT, trừ khi generator đã duyệt cung cấp đúng router này. Chốt địa chỉ và chính sách lỗi cùng workbook CSR.

##### `m_vlsit_axil_reg_bridge`

- **Feature / Tính năng:** AXI4-Lite to PULP RegBus conversion / Chuyển đổi AXI4-Lite sang PULP RegBus.
- **Function / Chức năng:** Adapts the LLC-service address window to the native `conf_req_i/conf_resp_o` interface of the pinned `axi_llc_reg_wrap`. It recognizes all offsets in the pinned LLC register map, collects independent AXI4-Lite AW and W handshakes, applies the four WSTRB lanes, and preserves response backpressure. Writes are allowed only to flush-address and commit registers; writes to SPM configuration or read-only status/configuration return local SLVERR, so software cannot enable runtime SPM. Reads return the mapped LLC registers; unknown aligned offsets return DECERR and misaligned accesses return SLVERR. PULP RegBus has no PROT field, so AXI PROT inputs are accepted but ignored. Upstream LLC RTL and register map stay unchanged. / Chuyển cửa sổ dịch vụ LLC sang giao diện native `conf_req_i/conf_resp_o` của `axi_llc_reg_wrap` đã pin. Bridge nhận diện đủ các offset trong register map LLC đã pin, nhận AW và W AXI4-Lite độc lập, áp dụng bốn lane WSTRB và giữ backpressure response. Chỉ cho phép ghi thanh ghi địa chỉ flush và commit; ghi cấu hình SPM hoặc thanh ghi chỉ đọc trả SLVERR nội bộ, ngăn software bật SPM runtime. Read trả các register đã ánh xạ; offset aligned không hợp lệ trả DECERR, truy cập không aligned trả SLVERR. PULP RegBus không có trường PROT nên bridge nhận nhưng bỏ qua AXI PROT. Không sửa RTL hoặc register map LLC upstream.
- **Plan / Phương án:** `NEW` VLSIT module. Preserve AXI4-Lite backpressure and response ordering. Final RegBus field widths and request/response timing must match the pinned `register_interface` types before RTL review; no latency bound is assumed. / Module VLSIT `NEW`. Giữ backpressure AXI4-Lite và thứ tự response. Chốt độ rộng field RegBus và timing request/response theo `register_interface` đã pin trước khi review RTL; không giả định giới hạn latency.

##### `m_vlsit_cpucl_csr`

- **Feature / Tính năng:** Software-visible cluster registers / Thanh ghi cluster cho software.
- **Function / Chức năng:** Implements reviewed PMU, control, status, and interrupt-cause fields on AXI4-Lite. / Triển khai trường PMU, điều khiển, trạng thái và nguyên nhân interrupt qua AXI4-Lite.
- **Plan / Phương án:** `GENERATED` from the `cpucl` workbook by the pinned CSR generator. The workbook, offsets, reset values, and event codes are the source of truth. / `GENERATED` từ workbook `cpucl` bằng CSR generator đã chốt. Workbook, offset, reset value và event code là nguồn chuẩn.

##### `m_vlsit_riscv_pmu`

- **Feature / Tính năng:** Configurable cluster performance monitor / Bộ giám sát hiệu năng cấu hình được.
- **Function / Chức năng:** Connects event sources, programmable counters, software snapshot, overflow causes, and one aggregate level interrupt. / Kết nối nguồn event, counter lập trình được, snapshot software, nguyên nhân overflow và một interrupt level tổng hợp.
- **Plan / Phương án:** `NEW` VLSIT RTL. Implement only event sources that are mapped to real pinned CVA6/cache/fabric signals. / `NEW` RTL VLSIT. Chỉ triển khai event được ánh xạ tới tín hiệu thật từ CVA6/cache/fabric đã chốt.

##### `m_vlsit_pmu_hart_evt`

- **Feature / Tính năng:** Per-hart event collection / Thu thập event từng hart.
- **Function / Chức năng:** Packs the modified CVA6 `perf_event_o[21:0]` (bit 0 is event ID `0x0001`) and HPDcache IDs `0x0100–0x010F` with zero-based hart identity. The licensed HPDcache wrapper exports its 16 native event indicators through the modified subsystem, CVA6, CPU tile, and tile array. The cluster core now connects these per-hart vectors and the CCU `0x0300–0x030B` taps to the PMU. Directed CCU/tile-array tests check selected counts, but CSR-level PMU integration remains unverified. Event `0x0306` uses the matching PREPARE `writeback_done` indication; reconcile its workbook label before freezing the event catalog. / Ghép `perf_event_o[21:0]` của CVA6 đã sửa (bit 0 là event ID `0x0001`) với các event HPDcache `0x0100–0x010F`, kèm hart index bắt đầu từ 0. Wrapper HPDcache có license xuất 16 indicator event gốc qua subsystem, CVA6, CPU tile và tile array đã sửa. Cluster core hiện nối vector từng hart và tap CCU `0x0300–0x030B` tới PMU. Test directed CCU/tile array kiểm tra một số tổng, nhưng tích hợp PMU ở mức CSR chưa được xác minh. Event `0x0306` dùng chỉ báo PREPARE khớp có `writeback_done`; cần hòa giải tên trong workbook trước khi khóa catalog.
- **Plan / Phương án:** `NEW` tap routing through the licensed CVA6/HPDcache copies and VLSIT wrappers is implemented. The cluster-core-to-PMU connection, LLC/CCU event taps, and configured CVA6+HPDcache lint closure remain integration work under DEP-008/011. / Đã triển khai định tuyến tap `NEW` qua các bản sao CVA6/HPDcache giữ license và wrapper VLSIT. Kết nối cluster core tới PMU, tap LLC/CCU và hoàn tất lint CVA6+HPDcache theo cấu hình vẫn là việc tích hợp thuộc DEP-008/011.

##### `m_vlsit_pmu_cluster_evt`

- **Feature / Tính năng:** Cluster-global event collection / Thu thập event toàn cluster.
- **Function / Chức năng:** Captures LLC IDs `0x0200–0x0217`/`0x0240–0x0243` and proposed VLSIT CCU IDs `0x0300–0x030B`. LLC `.active` fields are one-bit events; CCU transaction IDs `0x0300–0x0307` and `0x030B` use 3-bit occurrence counts (0–4), while stall IDs `0x0308–0x030A` remain one-bit cycle indicators. / Thu thập ID LLC `0x0200–0x0217`/`0x0240–0x0243` và ID CCU VLSIT `0x0300–0x030B`. Trường `.active` của LLC là event một bit; ID giao dịch CCU `0x0300–0x0307`, `0x030B` dùng số đếm 3-bit (0–4), còn ID stall `0x0308–0x030A` là indicator một bit theo chu kỳ.
- **Plan / Phương án:** `NEW`; CCU taps are VLSIT logic, while source wiring remains integration work under DEP-008/011. / `NEW`; tap CCU là logic VLSIT, việc nối nguồn còn thuộc DEP-008/011.

##### `m_vlsit_pmu_event_select`

- **Feature / Tính năng:** Event selector and scope filtering / Chọn event và lọc phạm vi.
- **Function / Chức năng:** Applies the approved scope values: 0–3 for hart, 4 for summed active-hart events, and 5 for cluster-global events. / Áp dụng scope đã duyệt: 0–3 chọn hart, 4 cộng event các hart đang chạy, 5 chọn event toàn cluster.
- **Plan / Phương án:** `NEW`; reserved scopes and unavailable events shall not increment counters. / `NEW`; scope reserved và event không khả dụng không được làm tăng counter.

##### `m_vlsit_pmu_aggregate`

- **Feature / Tính năng:** Same-cycle event multiplicity / Số lần event xảy ra đồng thời.
- **Function / Chức năng:** Sums qualifying occurrences across active harts; four simultaneous occurrences increment by four. / Cộng số lần event ở các hart đang chạy; bốn lần đồng thời làm counter tăng bốn.
- **Plan / Phương án:** `NEW`. Size the adder/selector path for the selected two- or four-hart build. / `NEW`. Tính kích thước đường cộng/chọn theo build hai hoặc bốn hart.

##### `m_vlsit_pmu_counter_bank`

- **Feature / Tính năng:** Programmable event counters / Counter event lập trình được.
- **Function / Chức năng:** Implements 1–32 counters, default 16, width 32 or 64 bits, with modulo wrap and per-counter selection/enable. / Có 1–32 counter, mặc định 16, rộng 32 hoặc 64 bit, wrap modulo và enable/chọn riêng.
- **Plan / Phương án:** `NEW`; connect software controls through generated CSR, not hard-coded register offsets. / `NEW`; nối điều khiển software qua CSR được sinh, không hard-code offset.

##### `m_vlsit_pmu_snapshot`

- **Feature / Tính năng:** Atomic multiword counter read / Đọc counter nhiều word nhất quán.
- **Function / Chức năng:** Captures all configured counter values on command so 32-bit AXI4-Lite software can read a stable 64-bit low/high pair. / Chụp các counter theo lệnh để software AXI4-Lite 32-bit đọc cặp low/high 64-bit nhất quán.
- **Plan / Phương án:** `NEW`; snapshot values remain stable until the next accepted snapshot or reset. / `NEW`; snapshot giữ nguyên đến lệnh snapshot tiếp theo hoặc reset.

##### `m_vlsit_pmu_irq`

- **Feature / Tính năng:** PMU overflow cause and interrupt / Nguyên nhân overflow và interrupt PMU.
- **Function / Chức năng:** Latches enabled causes and holds the single aggregate level interrupt until software clears causes. / Chốt cause được enable và giữ interrupt level tổng hợp đến khi software xóa cause.
- **Plan / Phương án:** `NEW`; verify set/clear priority and interrupt persistence with CSR semantics. / `NEW`; verify ưu tiên set/clear và duy trì interrupt theo ngữ nghĩa CSR.

#### 14.4.6 Per-hart debug routing (diagram 06)

##### `m_vlsit_riscv_debug_router`

- **Feature / Tính năng:** Multi-hart debug request/status routing / Định tuyến request/trạng thái debug nhiều hart.
- **Function / Chức năng:** Routes external Debug Module halt/resume/control to active harts and returns each hart's debug status. / Định tuyến halt/resume/điều khiển từ Debug Module ngoài tới hart đang dùng và trả trạng thái từng hart.
- **Plan / Phương án:** `NEW` VLSIT wrapper/logic. DTM and Debug Module remain external; map exact CVA6 native signals from the pinned revision. / `NEW` wrapper/logic VLSIT. DTM và Debug Module ở ngoài; đối chiếu tín hiệu CVA6 theo revision đã chốt.

##### `u_vlsit_riscv_cpu_tile_0` through `u_vlsit_riscv_cpu_tile_3`

- **Feature / Tính năng:** Zero-based replicated CPU-tile array / Mảng tile CPU lặp với chỉ số từ 0.
- **Function / Chức năng:** Instantiates indices `0..PARA_CPU_NUM-1`, exactly two or four identical tiles, and connects one debug lane per hart. / Tạo instance chỉ số `0..PARA_CPU_NUM-1`, đúng hai hoặc bốn tile giống nhau và nối một lane debug cho mỗi hart.
- **Plan / Phương án:** `NEW` structural generate wrapper. Instance names are explicitly suffixed with zero-based hart indices as required by the naming rule; CVA6 and HPDcache inside each tile follow the source-preserving modifications above. / `NEW`, wrapper generate cấu trúc. Tên instance có hậu tố chỉ số hart bắt đầu từ 0 theo naming rule; CVA6 và HPDcache trong tile theo phương án sửa source có giữ license ở trên.

#### 14.4.7 External ACE coherence adapter (diagram 07)

##### `m_vlsit_riscv_ace_proxy`

- **Feature / Tính năng:** External ACE transaction/snoop boundary / Biên giao dịch/snoop ACE bên ngoài.
- **Function / Chức năng:** Translates supported ACE external snoops and coherent transactions into local cache probes and returns the required response/data. / Chuyển snoop/giao dịch ACE được hỗ trợ thành probe cache nội bộ và trả response/data cần thiết.
- **Plan / Phương án:** `NEW` VLSIT RTL. The ACE subset, DVM/atomic policy, unsupported requests, ID/order limits, and LLC AXI mapping must close under DEP-002 before implementation. / `NEW` RTL VLSIT. Phải chốt subset ACE, DVM/atomic, request không hỗ trợ, giới hạn ID/order và ánh xạ AXI LLC theo DEP-002 trước khi code.

##### `m_vlsit_riscv_ace_probe_router`

- **Feature / Tính năng:** Per-tile snoop fanout and response collection / Phân phối snoop tới tile và thu response.
- **Function / Chức năng:** Sends a local probe to each active cache and combines clean/dirty responses and data for the ACE proxy. / Gửi probe nội bộ tới từng cache đang chạy và tổng hợp response/data clean/dirty cho ACE proxy.
- **Plan / Phương án:** `NEW`. Define duplicate/missing response handling and dirty-line ownership before RTL. / `NEW`. Chốt xử lý response thiếu/trùng và ownership dirty line trước khi viết RTL.

##### ACE use of `m_vlsit_riscv_coh_fabric`

- **Feature / Tính năng:** Reuse of local coherence state for external snoops / Dùng trạng thái coherence nội bộ cho snoop ngoài.
- **Function / Chức năng:** Supplies local line ownership and probe behavior to the ACE proxy; it is the same adapted coherence block described in Section 14.4.3. / Cung cấp ownership line và hành vi probe cho ACE proxy; đây là khối coherence đã điều chỉnh tại Mục 14.4.3.
- **Plan / Phương án:** `DEFERRED`. Future external ACE work may adapt the VLSIT MESI CCU after separate specification and port approval; no ACE proxy RTL is generated now. / `DEFERRED`. Giai đoạn ACE bên ngoài sau này có thể mở rộng CCU MESI VLSIT sau khi có đặc tả và duyệt port riêng; hiện không tạo RTL ACE proxy.

### 14.5 Synthesis assumptions

| Item | Value / source |
|---|---|
| Structural tops | Current: m_vlsit_riscv_cluster_axi_top only; ACE top deferred |
| Core source/config | OpenHW CVA6 package cv64a6_imafdc_sv39_hpdcache_wb |
| Coherence/cache source | Modified, license-preserving OpenHW HPDcache copy plus NEW VLSIT sharer directory, transaction table, probe scheduler, and MESI CCU; Culsans is architecture reference only; compatibility validation DEP-001 |
| CBO/FENCE.I maintenance | NEW VLSIT CMO controller for CBO; MODIFY CVA6 FENCE.I D-cache walk and CCU/HPDcache path to clean dirty lines into LLC, then invalidate local I-cache/fetch pipeline; CBO uses PULP LLC per-line memory service; failed FENCE.I writeback aborts with M/directory retained and raises the custom synchronous cause-24 maintenance exception after all ABORT ACKs |
| Directory / concurrency | 4-bank, 8-way non-inclusive directory; 4,096 entries at 2 harts, 8,192 at 4 harts; `PARA_COH_TXN_NUM` default 8, legal 2–16; one probe serviced per cache at a time |
| LLC source | PULP axi_llc, pinned revision required |
| Frontend | To be selected by project flow |
| Parameters/configuration | CFG-AXI-2/4, MESI D-cache, 256-KiB default LLC, PMU 16×64 |
| Memory macros | SRAM compiler views and geometry not yet supplied |
| Lint/synthesis constraints | VLSIT RTL rules plus SoC-owned library and tool configuration |

### 14.6 FSM design and documentation rule

Every stateful FSM in a `NEW` or `MODIFY` VLSIT-owned module shall have a unique FSM ID, a named state/transition definition, and an editable draw.io flow diagram. The diagram itself may be the state/transition record; add a separate table when a figure cannot show the full guard/action contract clearly. Use only the bundled VLSIT diagram library: entry 13 for states, entry 34 for decisions, entry 33 for start/terminal nodes, and entries 1–4 for transitions; entry 0 is for titles, transition notes, and unresolved-behavior notes. Preserve library provenance. The diagram or table shall identify reset state, state purpose, transition guard/event, action, accepted/returned transaction, backpressure behavior, and error/recovery path. Mark unspecified behavior as unresolved; do not invent cycle counts, state encodings, or protocol guarantees. Reused upstream modules are excluded unless locally modified. RTL state names and verification tests shall trace to the approved FSM ID. Assign stable transition IDs when the diagram is reviewed and frozen, then reference those IDs in tests. FSM V4 is the current review draft and adds FSM-011 for CBO maintenance; its topology is not yet approved for RTL generation.

Mỗi FSM có trạng thái trong module VLSIT `NEW` hoặc `MODIFY` phải có FSM ID duy nhất, định nghĩa state/transition và lưu đồ draw.io có thể chỉnh sửa. Hình có thể thay cho bảng state/transition; chỉ thêm bảng riêng khi hình không thể hiện rõ guard/action. Chỉ dùng thư viện VLSIT đi kèm: entry 13 cho state, entry 34 cho decision, entry 33 cho start/terminal và entry 1–4 cho transition; entry 0 dùng cho tiêu đề, ghi chú transition và hành vi chưa chốt. Phải giữ provenance của thư viện. Sơ đồ hoặc bảng phải nêu trạng thái reset, chức năng state, guard/event, action, giao dịch nhận/trả, backpressure và đường lỗi/khôi phục. Nội dung chưa quy định phải ghi là chưa chốt; không tự đặt số chu kỳ, mã hóa state hay cam kết protocol. FSM upstream tái sử dụng được loại trừ, trừ phần bị sửa. Tên state RTL và testcase phải truy vết về FSM ID đã duyệt. Gán transition ID ổn định sau khi duyệt sơ đồ và dùng ID đó trong testcase. FSM V4 là bản nháp xem xét hiện tại, thêm FSM-011 cho bảo trì CBO; cấu trúc luồng chưa được duyệt để sinh RTL.

## 15. Verification specification

### 15.1 Scope and strategy

Verification shall be independent of generated RTL. The golden sources are this specification, pinned RISC-V architectural specifications/models, AMBA protocol standards/checkers, and independently authored reference models. The generated RTL is the DUT only. Required levels: unit, protocol, multi-hart coherence, full cluster integration, formal properties, CDC/RDC, lint, synthesis/elaboration, and physical timing/power signoff.

Verification flow độc lập với RTL được sinh. Golden source là đặc tả này, RISC-V architectural spec/model đã pin, chuẩn/checker giao thức và reference model độc lập. RTL sinh ra chỉ là DUT. Các mức cần có: unit, protocol, coherence đa hart, tích hợp cluster, formal, CDC/RDC, lint, elaboration/synthesis và signoff physical.

### 15.2 Requirement-based test plan

| Test ID | Requirements | Scenario / stimulus | Expected result | Test type | Configuration |
|---|---|---|---|---|---|
| TEST-001 | REQ-SYS-001, REQ-SYS-002 | Elaborate two/four harts under selected CVA6 package | Correct active hart count and IDs | Elaboration | All four configs |
| TEST-002 | REQ-MEM-001, REQ-MEM-005 | MESI read-sharing, clean/dirty owner, E grant, and dirty-owner AXI writeback | Legal state transitions; all readers see latest data; LLC is current only after owner writeback B response and before M-to-S completes | Directed/random litmus and scoreboard | CFG-AXI-2/4 |
| TEST-003 | REQ-MEM-002, REQ-MEM-003 | Check LLC geometry and attempt SPM control | Capacity equals 256 KiB default; SPM stays disabled | Elaboration/CSR test | Both profiles |
| TEST-004 | REQ-MEM-004 | Reset, observe BIST, then flush dirty lines | No use before BIST ready; flush completes without data loss | Simulation | Both profiles |
| TEST-005 | REQ-IF-001, REQ-IF-007 | AXI4-Lite read/write, AW/W independent, WSTRB, unmapped/misaligned | Correct OKAY/SLVERR/DECERR and no side effects on errors | Protocol simulation | Both profiles |
| TEST-006 | REQ-IF-002, REQ-IF-005 | AXI MMIO bursts with backpressure, IDs, errors | Stable payload, correct response association | AXI checker/simulation | Both profiles |
| TEST-007 | REQ-IF-003 | External DMA access with and without software maintenance | AXI profile contract is honored; no false coherence claim | System test | CFG-AXI-2/4 |
| TEST-008 | REQ-IF-004 | Future external ACE read/write snoops to clean and dirty lines | Correct CR/CD response and latest data | Future ACE checker/system test | Deferred |
| TEST-009 | REQ-PMU-001, REQ-PMU-002 | Min/max counter count and 32/64-bit wrap | Correct parameter legality and modulo arithmetic | Directed/random | Both profiles |
| TEST-010 | REQ-PMU-003 | Snapshot while live counters continue incrementing | Captured low/high images remain stable and internally consistent | Scoreboard | Both profiles |
| TEST-011 | REQ-PMU-004 | Overflow, mask, clear, interrupt injection | Sticky cause and aggregate IRQ match CSR state | CSR/interrupt test | Both profiles |
| TEST-012 | REQ-DBG-001 | Halt/resume each active hart separately | Only requested hart enters/exits debug | Integration test | 2/4 harts |
| TEST-013 | REQ-IRQ-001 | Assert each interrupt vector and unused-hart bits | Correct hart receives level; absent hart ignored | Directed test | 2/4 harts |
| TEST-014 | REQ-RST-001, REQ-ERR-001 | Reset with outstanding reads/writes/snoop | Reset behavior agrees with system reset contract; no stale completion | Reset injection | Both profiles |
| TEST-015 | REQ-VER-001, REQ-VER-002 | Rebuild all configs from clean manifest and saved Make targets | Same tests/files/logs are reproducible | Flow audit | All configs |
| TEST-016 | REQ-IF-006 | Elaborate current AXI top at 2/4 harts and inspect its fixed port list | One AXI top; no runtime AXI/ACE profile mux | Elaboration audit | CFG-AXI-2/4 |
| TEST-017 | REQ-ERR-002 | Inject malformed internal address/control requests | No silent CSR/cache-state change; error status follows the approved interface policy | Negative simulation/assertions | Both profiles |
| TEST-018 | REQ-CLK-001 | Audit clock use at every cluster port and instantiated hart | No undeclared internal clock domain; external crossings use a separate SoC bridge | CDC/clock-domain lint | Both profiles |
| TEST-019 | REQ-MEM-001 | Exercise I/S/E/M transitions, including E-to-M local store and S-to-M ownership upgrade | No illegal state combination or duplicate M/E owner | Directed MESI scoreboard/formal | CFG-AXI-2/4 |
| TEST-020 | REQ-MEM-005 | Inject dirty-owner read sharing and dirty-owner write ownership transfer; stall AW/W/B and inject B error | Latest full 16-byte line is preserved; M-to-S completes only after successful owner B response; B error causes precommit ABORT with owner still M; write grant waits for peer invalidation and current LLC data | Directed/random simulation and assertions | CFG-AXI-2/4 |
| TEST-021 | REQ-MEM-006 | Race a probe with same-line miss/refill and issue a request to a different line | Same-line operation is serialized; accepted probe is answered once; unrelated request progresses when resources do not conflict | Stress simulation and assertions | CFG-AXI-2/4 |
| TEST-022 | REQ-MEM-007 | Hart writes executable memory; target hart receives platform notification and executes `FENCE.I` | Target hart fetches updated instruction after the software sequence; no I-cache hardware-snoop claim | ISA/software integration test | CFG-AXI-2/4 |
| TEST-023 | REQ-PMU-006 | Four active harts produce the selected event in the same cycle | Counter increment equals the sum of all four occurrences | Multi-hart event scoreboard | CFG-AXI-4 |
| TEST-024 | REQ-MEM-008, REQ-MEM-010 | Directory fill, stale-positive repair, LLC eviction with live private copies, and directory replacement with active holders | LLC eviction leaves L1/directory state intact; directory replacement invalidates all holders and preserves dirty data before reusing a way | Reference-model refinement, directed stress, and assertions | CFG-AXI-2/4 |
| TEST-025 | REQ-MEM-009, REQ-MEM-006, REQ-MEM-011 | Exercise 2/8/16 transaction slots, out-of-order tagged responses, queue saturation, cross-bank overlap, and same-bank conflict | Tags are not reused early; each response matches (tag, hart, line); bank conflicts serialize; different banks progress if other resources permit | Tagged scoreboard, randomized backpressure, and assertions | CFG-AXI-2/4 |
| TEST-026 | REQ-MEM-012 | Prepare read-sharing and write-ownership probes; delay owner AW/W/B and a PREPARE status response | Stable MESI states do not change during PREPARE; successful COMMIT waits for the matching owner B response and all PREPARE ACKs; B error triggers ABORT; line locks remain until COMMIT/ABORT acknowledgements | Two-phase protocol scoreboard and assertions | CFG-AXI-2/4 |
| TEST-027 | REQ-MEM-013 | Inject an LLC error before COMMIT; delay COMMIT/ABORT acknowledgements; reset an active transaction | Precommit ABORT preserves old stable states; lock remains until all acknowledgements; reset clears cache/directory valid state | Error injection, reset simulation, and assertions | CFG-AXI-2/4 |
| TEST-028 | REQ-IF-008 | Access both 4-KiB local windows, their boundaries, and reserved aligned offsets | CSR and LLC windows decode without overlap; reserved reads return zero/DECERR and writes have no side effect/DECERR | AXI4-Lite checker and CSR scoreboard | CFG-AXI-2/4 |
| TEST-029 | REQ-MEM-013, REQ-MEM-006 | Complete owner writeback and PREPARE for line X; withhold one of two COMMIT ACKs while a different line Y uses another free transaction slot; then assert reset | No timeout, directory update, requester grant, or lock/slot release for X before reset; Y may complete if resources do not conflict; reset clears cache/directory valid state and releases the context | Directed no-ACK hold, independent-line scoreboard, reset test, and assertions | CFG-AXI-2/4 |
| TEST-030 | REQ-MEM-013 | Withhold one targeted PREPARE ACK after another holder has ACKed; later reset | Stable MESI/directory unchanged; no COMMIT/grant; lock and slot remain allocated until reset | Directed no-ACK hold, independent-line scoreboard, reset test, and assertions | CFG-AXI-2/4 |
| TEST-031 | REQ-MEM-013 | Inject a pre-COMMIT error, ACK ABORT from one holder, withhold another ABORT ACK, then reset | A cache accepting ABORT releases its local lock and retains its old state; CCU lock/slot remain until every ABORT ACK or reset; directory/grant unchanged | Directed no-ACK hold, independent-line scoreboard, reset test, and assertions | CFG-AXI-2/4 |
| TEST-032 | REQ-SYS-003 | Hold `i_boot_addr` through reset release and start two/four harts | Every active CVA6 receives the same boot address; `mhartid` remains distinct | Elaboration and multi-hart startup test | CFG-AXI-2/4 |
| TEST-033 | REQ-MEM-014 | Exercise bank round-robin under sustained eligible contention; access all ways to check PLRU path updates, invalid-way preference, and locked-victim waiting | Eligible slots receive fair cyclic grants; PLRU selects the expected tree victim; invalid ways precede replacement; blocked victim does not block unrelated eligible work | Directed arbitration/replacement scoreboard and assertions | CFG-AXI-2/4 |
| TEST-034 | REQ-SYS-004 | Compare the local configuration copy to the pinned pristine file and elaborate with CVXIF disabled | Only the approved CVXIF enable field changes; upstream source remains intact; no CVXIF top ports exist and native pins remain inactive if present | Source-diff review and elaboration | CFG-AXI-2/4 |
| TEST-035 | REQ-PMU-007, REQ-PMU-008 | Program every catalog ID and compatible scope; include unknown/reserved IDs, absent-hart scopes, disabled SPM IDs, simultaneous per-hart events, held stall indicators, and 2–4 same-kind events across CCU banks in one cycle | Exact source map increments correctly; invalid/unavailable combinations count zero; aggregate sums per-hart indicators; CCU occurrence taps add 2–4 while stall taps add one per active cycle; LLC AXI transfers/descriptors count once per accepted source event, not by bytes | Source-based event scoreboard with pinned-source cross-check and a CCU count-bound assertion | CFG-AXI-2/4 |
| TEST-036 | REQ-IF-009 | Run cached LR/SC and AMO operations at the coherent L1 serialization point, including dirty remote owners and reservation invalidation; run uncached operations through the external AXI4+ATOP target and separately exercise a system bridge when the target fabric lacks ATOP | Cached atomics execute exactly once under unique CCU permission; competing same-line probes cannot interleave their read/write. Uncached AWATOP, ID and response association are preserved; a filter-only path is rejected | RISC-V atomic architectural model and AXI4+ATOP checker | CFG-AXI-2/4 |
| TEST-037 | REQ-IF-010 | Issue LLC service reads and writes; vary AXI4-Lite AW/W arrival order, WSTRB, and backpressure while delaying RegBus response | One RegBus request is formed from each accepted write; AXI response returns to the matching request without loss or duplication | AXI4-Lite/RegBus bridge scoreboard against pinned interface types | CFG-AXI-2/4 |
| TEST-038 | REQ-MEM-015 | Exercise CLEAN, FLUSH, and CBIE-decoded INVAL across L1/LLC hit/miss and I/S/E/M/dirty states; include a concurrent same-line CPU request and an ordered DMA observer | Correct operation reaches every required holder; no CMO refill; CMO holds the shared line lock; CLEAN/FLUSH make memory current; FLUSH/INVAL invalidate only at commit; true INVAL emits no writeback and may discard dirty copies; DMA observes the defined result | Independent CMO reference model and coherence scoreboard | CFG-AXI-2/4 |
| TEST-039 | REQ-MEM-016, REQ-MEM-017 | Inject owner-writeback and LLC-memory B errors for CLEAN, FLUSH, and INVAL-as-FLUSH; delay PREPARE/ABORT ACKs; also run true INVAL and assert no writeback; observe CVA6 retirement/trap state | No CBO or younger retirement before resolution; recoverable dirty data/directory remain valid after writeback error; after every required ABORT ACK, raise exception code 7 with original CBO PC in `mepc`/`sepc` and effective address in `mtval`/`stval`; true INVAL performs no B transaction | Error-injection simulation, retirement scoreboard and assertions | CFG-AXI-2/4 |
| TEST-040 | REQ-MEM-016 | Issue LLC per-line CLEAN/FLUSH/true-INVAL for resident clean/dirty lines and absent tags; stall AXI B and return non-OKAY responses on writeback-required operations | No refill on CMO miss; tag/dirty state changes only at commit; on writeback error valid/tag/dirty/data are preserved; true INVAL invalidates without issuing AXI writeback | LLC tag/data reference model, AXI response injection and assertions | CFG-AXI-2/4 |
| TEST-041 | REQ-MEM-007, REQ-MEM-018 | Prime local I-cache with old code, modify code leaving a dirty D-cache line, then execute `FENCE.I`; allow the L1-to-LLC transfer while withholding LLC-to-DRAM writeback | LLC accepts the latest line; D-cache owner/directory commit consistently; no LLC-to-DRAM write request is caused by FENCE.I; local I-cache/fetch pipeline invalidation precedes fence completion; the next fetch returns the new instruction | ISA self-modifying-code test, cache reference model, and AXI monitor | CFG-AXI-2/4 |
| TEST-042 | REQ-MEM-018 | Inject a non-OKAY B response on the dirty owner L1-to-LLC transfer during `FENCE.I` | Preserve dirty M owner and directory holder; complete all required ABORT ACKs before raising precise synchronous cause 24 at the FENCE.I PC with the aligned physical line base in `mtval`/`stval`; suppress FENCE.I and younger retirement and do not invalidate local I-cache/fetch state; verify handler correction and retry | AXI B-error injection, ABORT scoreboard, retirement/trap scoreboard, and cache-state assertions | CFG-AXI-2/4; DEC-031 |
| TEST-043 | REQ-IRQ-002 | Assert and deassert SSIP/STIP while independently setting/clearing software-writable MIP bits; include CSRRS/CSRRC accesses while an external level is asserted | Effective MIP/SIP and interrupt delivery reflect the ORed source; software state changes only from CSR writes; dropping the external level does not leave a sticky bit | Architectural CSR reference model, interrupt scoreboard, and CSR read-modify-write assertions | CFG-AXI-2/4 |
| TEST-044 | REQ-MEM-019 | Reproduce CC-01 exactly: T1 lookup-hit/update and T2 same-set miss/reservation; keep T1 update VALID until READY; then assert matching T2 cancel | T2 cancel handshakes despite blocked T1 update, clears only T2 reservation, and T1 update later handshakes; no directory/MESI corruption. Also confirm another eligible same-bank operation can be scheduled once the bank accepts it. | Directed reproduction, ready/valid scoreboard, reservation-owner assertions, and bounded liveness under continuous bank acceptance | CFG-AXI-2/4; `PARA_COH_TXN_NUM`=2/8/16 |
| TEST-045 | REQ-MEM-021 | Inject duplicate, stale, unknown-tag, wrong-phase, wrong-hart, and wrong-line probe ACKs ahead of a valid expected ACK | Invalid responses are accepted/discarded and diagnosed; no transaction/cache/directory state changes; the following valid ACK is accepted and completes only its matching transaction | Tagged response scoreboard, assertion, and diagnostic CSR check | CFG-AXI-2/4 |
| TEST-046 | REQ-MEM-019/020; PERF-001/004/005 | Stress a full 8-way set, same-bank request contention, one cache's full probe queue, all transaction slots occupied, dirty-owner writeback, and controlled AXI READY/B-response delays | Report maximum observed arbitration wait, slot occupancy, per-hart stalls/IPC, line-lock duration, and overlapping progress for a finite controlled environment; separately show that unbounded ACK/AXI stalls have no finite latency bound under DEC-018 | Independent reference model, trace counters, directed/random backpressure, and fairness assertions | CFG-AXI-2/4; controlled-response and unbounded-stall runs |
| TEST-047 | External AXI memory width profile (DEP-022) | Exercise the memory adapter at 32/64/128/256 bits, including ATOP, IDs, narrow/full transfers, burst limits, strobes, ordering, errors, and backpressure | Preserve the 16-byte internal coherence granule and AXI responses; unsupported burst/ATOP cases are rejected explicitly; standalone adapter evidence does not substitute for full LLC-to-SoC testing | Width-converter protocol checker and end-to-end AXI+ATOP model | Adapter leaf tests pass; integrated route pending |
| TEST-048 | REQ-MEM-014/022 | Hold a per-slot request valid through backpressure; accept its grant, delay VALID deassertion, then drop VALID and later present a new token from the same slot | No duplicate grant occurs for the old token; grant payload is stable while stalled; the slot rearms only after sampled VALID low; other eligible slots retain round-robin service | Directed bank-arbiter scoreboard, grant-count assertion, and slot-rearm coverage | CFG-AXI-2/4; `PARA_COH_TXN_NUM`=2/8/16 |
| TEST-049 | REQ-MEM-012/023 | Exercise M-owner PREPARE with successful B followed by COMMIT, and a separate B-error path followed by ABORT; vary target state and ACK order | Matching writeback status and target state survive phase transitions; COMMIT is gated by successful B; B error remains visible through ABORT; no wrong-tag/line response updates the context | Transaction-context reference model, AXI ID/response scoreboard, and phase-state assertions | CFG-AXI-2/4; reordered ACK and B-response runs |
| TEST-051 | REQ-IF-011 | Configure the default cacheable entry plus representative normal-uncached RAM and MMIO entries; probe each region through CVA6 PMA and router; test an unmapped address, a boundary-crossing burst, overlap/overflow parameters, and an MMIO atomic | PMA and router classify each byte range identically; cacheable uses CCU/LLC, normal-uncached uses LLC bypass without allocation, MMIO reaches only the MMIO AXI port, and unmapped/boundary/atomic-to-MMIO requests return local access errors without external requests. Invalid tables lower `o_config_valid`; the SoC build must reject that configuration because RTL does not guarantee an elaboration failure | Parameter/elaboration checks, independent address-table model, AXI monitors and access-fault scoreboard | CFG-AXI-2/4; 1 and 16 region entries |

### 15.3 Assertions and coverage

Additional normative test: **TEST-050 — REQ-ERR-003 / DEC-036.** Retire a store into a dirty cache line, trigger its ordinary eviction, and return a non-OKAY writeback response. Verify retained recoverable data and affected lock/context, sticky `o_int_fault`, associated CSR fault information, continued draining of previously issued AXI responses, and no automatic retry or fabricated success. Verify reset recovery and separately confirm that CBO/FENCE.I still follow their synchronous-fault contracts. / Cho store retire vào line dirty, gây eviction và trả lỗi writeback; kiểm tra dữ liệu/lock giữ lại, IRQ sticky, fault record CSR, nhận đủ response đã gửi, không tự retry/báo thành công, reset recovery và hành vi lỗi đồng bộ riêng của CBO/FENCE.I.

Required assertions include VALID/payload stability under stall; response only after request acceptance; AXI and internal-tag association; unique active transaction tags; no response update to a mismatched `(tag, hart, line)`; no duplicate completion or bank grant for one request token; a slot cannot be granted again until VALID has been sampled low; grant bank/slot stability under backpressure; owner-writeback status, target state, and error status persist across phases; COMMIT is impossible after a failed writeback; no M/E duplication; no dirty-owner bypass; no lost accepted probe; exactly one response per targeted cache for each phase; no stable MESI state change during PREPARE; no requester grant before all COMMIT acknowledgements and directory update; ABORT preserves the pre-transaction state; a probe-originated flush B response routes only to its matching probe and preserves its error; a successful PREPARE for M requires both owner W beats and the matching successful B response; no line-lock release before all phase responses and dirty-owner writeback/LLC obligations complete; while any required PREPARE, COMMIT, or ABORT ACK is missing, no timeout, directory update, requester grant, or slot release; directory-refinement safety; no same-line CPU completion while locked; 2/8/16 transaction parameter coverage; 2/4-hart directory geometry; same-bank serialization and cross-bank overlap; per-hart interrupt isolation; PMU correctness; snapshot stability; and aggregate IRQ equivalence to enabled sticky causes. Add liveness assertions under explicit fairness assumptions: an ineligible request never occupies a grant; a matching reservation-owner cancel/update is not blocked by another transaction's ineligible request; an accepted cancel clears exactly one matching reservation; every response channel can drain stale/duplicate ACKs; and every continuously eligible bank slot is selected within a full accepted-grant round. Coverage shall cross hart count × MESI request × initial state × owner/sharer count × LLC hit/miss × bank conflict × transaction occupancy × backpressure × reset timing × cancel/update race × stale-response class × duplicate-grant/rearm.

Coverage thresholds are not yet selected. Coverage reports must separate line, condition, toggle, functional, and protocol coverage and state unreachable points with justification.

### 15.4 Formal, CDC, and RDC

| Analysis | Scope | Assumptions / constraints | Evaluation method |
|---|---|---|---|
| Formal | AXI/AXIL handshake, response association, PMU snapshot/overflow, CSR decode, reset invariants | Protocol-compliant peer assumptions | Assertion proof and bounded checks |
| Coherence formal | MESI ownership/sharer rules, dirty-owner AXI writeback preservation, line-lock release, one response per probed cache, E/M exclusivity | Probe/flush-engine ownership and HPDcache transient-state assumptions from Section 10.2.1 | Invariants/refinement checks against an independent MESI/directory reference model |
| Liveness / deadlock formal | Directory reservation escape, eligible-slot fairness, probe response drain, and resource wait graph | Reset deasserted; clocks active; compliant stable VALID; caches eventually service probes; AXI eventually accepts requests and returns responses. Do not assume a bounded ACK/AXI latency. | Prove no internal wait cycle and no starvation under fairness; separately prove DEC-018 holds indefinitely without fabricating ACKs |
| CDC / RDC | All SoC crossings, reset release and interrupt/debug sources | Same clock at cluster ports or external bridges | CDC/RDC tool plus waiver review |
| Lint/elaboration | Four profiles and legal parameter endpoints | Pinned tools and third-party waivers | Reproducible Make targets |
| Synthesis | Both top profiles and LLC geometries | Target library/macro mapping | Synthesis reports, no unsupported construct |

## 16. DFT and testability

| Topic | Requirement / decision |
|---|---|
| Scan architecture | SoC DFT flow owns scan insertion and scan mode |
| Scan/test clocks and reset | Must be supplied by SoC DFT methodology |
| Memory test | LLC tag BIST follows axi_llc; L1/HPDcache SRAM test strategy depends on macro integration |
| Debug/test access | External RISC-V Debug Module remains outside cluster |
| Clock gating | Any integrated clock gating requires approved test-enable behavior |
| ATPG constraints | Library and test mode are integration dependencies |
| Test artifacts | Filelist, scan constraints, MBIST integration and reports are SoC-owned |

## 17. Physical design and timing integration

### 17.1 Timing constraints and budgets

The cluster has one declared synchronous clock domain. No executable SDC can be completed without period, waveform, latency, uncertainty, input/output delays, loads, transitions, PVT/RC views, and tool-specific object names. SoC integration shall provide these values before STA. No broad false paths or unreviewed multicycle exceptions are implied.

Cluster có một clock domain đồng bộ. Chưa thể hoàn thiện SDC chạy được nếu thiếu period, waveform, latency, uncertainty, input/output delay, load, transition, PVT/RC và object name theo tool. SoC phải cung cấp các giá trị này trước STA. Không ngầm định false-path rộng hoặc multicycle chưa review.

| Clock ID | Port / source object | Primary/generated and master | Period, waveform, phase / ratio | Latency / uncertainty / transition | Clock group / mode | Constraint source |
|---|---|---|---|---|---|---|
| CLK-CLUSTER | i_clk_cluster | Primary | Open integration dependency DEP-007 | Open integration dependency DEP-007 | Synchronous cluster | SoC SDC |
| Interface / port group | Direction | Reference clock | External min / max delay | Input transition / output load | IP timing budget | Mode / condition | Constraint source |
|---|---|---|---|---|---|---|---|
| AXI4 / ACE / AXI4-Lite | Input and output | CLK-CLUSTER | To be supplied by SoC | To be supplied by SoC | To be budgeted with fabric | CFG-AXI or CFG-ACE | SoC SDC |
| Exception ID | Type / SDC command | From | Through | To | Value and setup/hold/min/max meaning | Mode / condition | Technical rationale |
|---|---|---|---|---|---|---|---|
| EXC-001 | No exception defined in this draft | No path selected | No path selected | No path selected | No exception value approved | All modes | Add only after CDC/STA path review |

### 17.2 Physical assumptions

| Topic | Requirement / assumption |
|---|---|
| Hard/memory macros | L1/LLC SRAM macro selection and views are open integration dependencies |
| Floorplan | Tile/fabric/LLC placement and pin assignment are SoC-owned |
| Utilization/congestion | No target supplied |
| Power intent, clock/reset trees | SoC-owned; one logical cluster clock/reset boundary |
| High-fanout controls | Reset, snoop, and PMU enables require physical fanout review |
| Extraction/corners | PDK RC and PVT views must be supplied |
| Delivery form | Soft RTL, constraints, filelists, CSR workbook, verification collateral |

## 18. Security, safety, and reliability

| Topic | Requirement / rationale | Verification method / expected behavior |
|---|---|---|
| Security boundary and threat assumptions | SoC owns secure/non-secure address policy; AXI4-Lite PPROT handling must be configured explicitly | Access-control tests after policy decision |
| Access control / privilege | No APB/backdoor access to hart architectural CSRs; debug authorization is controlled by external DM/SoC | Integration review and debug authorization tests |
| Secure clearing / zeroization | No key material is stored. Secure clearing of cache, CSR, PMU snapshot, and debug state is not specified; SoC security policy is required. | Define the clearing boundary, then verify reset/secure-clear behavior; no sanitization claim is made yet |
| Information leakage / side channels | No side-channel resistance claim; caches and PMU expose performance behavior | Security review and software policy |
| ECC/parity and fault detection | ECC enablement depends on selected HPDcache/LLC macros and tool flow | Injected memory faults when ECC is selected |
| Safety goal / integrity level | No ISO 26262 or IEC 61508 safety claim | Safety certification is outside current scope |
| Diagnostics and recovery | PMU/LLC status and external debug support diagnosis; fatal coherence failure recovery needs system policy | Error injection and recovery review |

## 19. Requirement-to-verification traceability

| Requirement ID | RTL module/location | Test/property | Verification method / analysis | Configuration |
|---|---|---|---|---|
| REQ-SYS-001, REQ-SYS-002 | Top and CPU tile array | TEST-001 | Elaboration/config compare | All |
| REQ-SYS-003 | AXI top and CPU tile array | TEST-032 | Boot-address fanout and two/four-hart startup | CFG-AXI-2/4 |
| REQ-SYS-004 | License-preserving CVA6 configuration copy and CPU tile boundary | TEST-034 | Config delta, disabled CVXIF, no cluster ports, inactive source pins if present | CFG-AXI-2/4 |
| REQ-MEM-001 | MESI CCU and modified HPDcache | TEST-002, TEST-019 | MESI scoreboard/formal | CFG-AXI-2/4 |
| REQ-MEM-005 | MESI CCU and probe fanout | TEST-002, TEST-020 | Probe status and owner AXI writeback/B-response scoreboard | CFG-AXI-2/4 |
| REQ-MEM-006 | HPDcache probe control and CCU line locks | TEST-021, TEST-025 | Same-line race and independent-line progress | CFG-AXI-2/4 |
| REQ-MEM-008 | Sharer directory and HPDcache state updates | TEST-024 | Directory/reference-model refinement and no-false-negative assertions | CFG-AXI-2/4 |
| REQ-MEM-009, REQ-MEM-011 | Transaction table, probe scheduler, directory banks, and modified HPDcache | TEST-025 | Parameter, tag, queue, bank-conflict, and cross-bank assertions | CFG-AXI-2/4 |
| REQ-MEM-010 | Sharer directory | TEST-024 | Geometry and non-inclusive replacement/refinement checks | CFG-AXI-2/4 |
| REQ-MEM-012, REQ-MEM-013 | CCU, probe scheduler, modified HPDcache/flush controller | TEST-026, TEST-027, TEST-029, TEST-030, TEST-031 | Two-phase state/status and AXI writeback/B-response scoreboard, no-ACK hold in PREPARE/COMMIT/ABORT, independent-line progress, reset recovery, and assertions | CFG-AXI-2/4 |
| REQ-MEM-014 | `m_vlsit_riscv_coh_bank_arb` and sharer-directory banks | TEST-033, TEST-048 | Round-robin fairness, stable grant under backpressure, tree-PLRU state/victim checks, invalid-way selection, locked-victim and cross-bank progress | CFG-AXI-2/4 |
| REQ-MEM-015 | CMO controller, shared CCU context/line lock, HPDcache and LLC maintenance path | TEST-038 | CBO operation semantics, holder transitions, no-refill behavior, DMA visibility and same-line serialization | CFG-AXI-2/4 |
| REQ-MEM-016 | Modified `axi_llc` tag, maintenance and write-response path | TEST-039, TEST-040 | Per-line hit/miss service, B-error propagation, tag/data preservation and no premature commit | CFG-AXI-2/4 |
| REQ-MEM-017 | CVA6 CBO decode/store/commit path plus CMO controller | TEST-039 | Precise pre-retirement fault, no younger retirement, original PC/effective address, and post-ABORT exception delivery | CFG-AXI-2/4 |
| REQ-MEM-007 | I-cache/software coherence contract | TEST-022, TEST-041 | RISC-V per-hart executable-memory publication sequence | CFG-AXI-2/4 |
| REQ-MEM-018 | CVA6 FENCE.I controller, HPDcache owner writeback, CCU, trap path, and local I-cache/fetch invalidation | TEST-041, TEST-042 | Success: L1-to-LLC acceptance before local fetch sync and retirement; failure: ABORT ACKs before cause-24 trap, aligned physical line base in mtval/stval, M/directory retained; no LLC-to-DRAM request | CFG-AXI-2/4 |
| REQ-MEM-019 | Sharer directory bank arbitration and reservation owner escape | TEST-044 | CC-01 directed reproduction, cancel/update handshake, eligible-slot fairness and reservation assertions | CFG-AXI-2/4 |
| REQ-MEM-020 | CCU, sharer directory, HPDcache probe controller, AXI writeback path | TEST-046 | Resource wait-for graph, same-line refill/probe ordering, and independent resource ownership | CFG-AXI-2/4 |
| REQ-MEM-021 | Transaction table and probe-response receiver | TEST-045 | Stale/duplicate/mismatched ACK drain, no state mutation, subsequent valid ACK acceptance, diagnostic status | CFG-AXI-2/4 |
| REQ-MEM-022 | Bank arbiter and transaction request source | TEST-048 | Exactly-once token consumption, stable stalled grant, VALID-low rearm, no duplicate grant | CFG-AXI-2/4 |
| REQ-MEM-023 | Transaction table, probe scheduler, owner writeback response path | TEST-049 | Context/target-state/status retention across PREPARE/COMMIT/ABORT; matching B response gates commit | CFG-AXI-2/4 |
| PERF-005 / DEP-022 | External AXI memory width-converter wrapper | TEST-047 | Per-width AXI/ATOP functional tests and beat-count analysis; end-to-end integration remains open | Memory adapter leaf tested at 32/64/128/256; MMIO remains 64 |
| REQ-MEM-002, REQ-MEM-003 | LLC wrapper/decode | TEST-003 | Parameter calculation and CSR test | Both |
| REQ-MEM-004 | LLC wrapper | TEST-004 | BIST/flush simulation | Both |
| REQ-IF-001, REQ-IF-007 | AXI-Lite decoder and CSR | TEST-005 | AXI-Lite checker | Both |
| REQ-IF-008 | AXI4-Lite decoder, CSR and LLC service window | TEST-028 | Window and reserved-offset checks | CFG-AXI-2/4 |
| REQ-IF-002, REQ-IF-005 | AXI MMIO and memory paths | TEST-006 | AXI protocol checker | Both |
| REQ-IF-003 | AXI top | TEST-007 | DMA/cache-maintenance integration | CFG-AXI |
| REQ-IF-004 | Future ACE top and proxy | TEST-008 | Future ACE checker and snoop scoreboard | Deferred |
| REQ-IF-006 | Current AXI structural top | TEST-016 | Port-list and elaboration audit | CFG-AXI-2/4 |
| REQ-PMU-001, REQ-PMU-002 | PMU | TEST-009 | Boundary and wrap simulation | Both |
| REQ-PMU-003 | PMU snapshot bank | TEST-010 | Snapshot scoreboard | Both |
| REQ-PMU-004 | PMU/IRQ CSR | TEST-011 | Interrupt/CSR simulation | Both |
| REQ-PMU-005 | PMU selector scope logic | Scope portion of TEST-009 | Per-hart/aggregate/cluster event-source tests | CFG-AXI-2/4 |
| REQ-PMU-006 | PMU event aggregation | TEST-023 | Sum simultaneous event occurrences | CFG-AXI-4 |
| REQ-PMU-007, REQ-PMU-008 | PMU event tap, selector and counter path | TEST-035 | Full source-ID map, scope, zero-count cases and event multiplicity | CFG-AXI-2/4 |
| REQ-IF-009 | LLC AXI4+ATOP memory path and SoC atomic-service boundary | TEST-036 | End-to-end LR/SC and AMO atomicity; AWATOP/ID/response preservation | CFG-AXI-2/4 |
| REQ-IF-010 | AXI4-Lite-to-RegBus bridge | TEST-037 | AW/W decoupling, strobe, backpressure and response association | CFG-AXI-2/4 |
| REQ-IF-011 | Address-region parameter adapter, per-tile CVA6 PMA configuration, CPU address router, and LLC cache window | TEST-051 | PMA/router parity, all three region classes, LLC bypass/no-allocation, invalid-table rejection, boundary and local-error behavior | CFG-AXI-2/4 |
| REQ-DBG-001 | Debug adapter | TEST-012 | Hart-by-hart integration | 2/4 harts |
| REQ-IRQ-001 | CPU tile array | TEST-013 | Interrupt routing simulation | 2/4 harts |
| REQ-IRQ-002 | Modified CVA6 CSR read/interrupt view | TEST-043 | External/software MIP merge and non-sticky CSR read-modify-write | CFG-AXI-2/4 |
| REQ-RST-001, REQ-ERR-001 | Structural tops and fabric | TEST-014 | Reset/error injection | Both |
| REQ-CLK-001 | Cluster wrapper and all interface boundaries | TEST-018 | Clock-domain lint and CDC analysis | Both profiles |
| REQ-ERR-002 | AXI/MMIO decoders and coherence request validation | TEST-017 | Malformed address/control negative tests | Both profiles |
| REQ-PD-001 | Timing/physical integration package | REVIEW-001 | Review constraints and signoff reports for prohibited claims | Both profiles |
| REQ-VER-001, REQ-VER-002 | Verification repository | TEST-015 | Clean-build audit | All |

## 20. Assumptions, dependencies, and decisions

**DEC-036 — Confirmed by the designer, 2026-11-14; REQ-ERR-003, TEST-050.** Q2 selected asynchronous fault reporting for ordinary dirty-eviction writeback errors: preserve recoverable data and the affected line/context until reset, add sticky `o_int_fault` and CSR fault information, continue draining previously issued responses, and do not retry automatically. The alternative was a precise fault for the operation triggering eviction, which would extend normal store-retirement semantics. The selected option preserves the performance-oriented retirement model. CSR field layout, fault-source wiring and waveform documentation remain implementation/review work; this decision does not claim that the feature is implemented. / Người thiết kế chọn phương án fault bất đồng bộ cho eviction thông thường, thay cho mở rộng fault chính xác của store thông thường. Giữ dữ liệu/lock đến reset, thêm IRQ và CSR, tiếp tục nhận response đã gửi, không tự retry. Layout CSR, nối nguồn lỗi và waveform vẫn cần hoàn tất.

**DEC-037 — Confirmed by the designer, 2026-11-14; REQ-IF-011, TEST-051.** Use one synthesis-time source table for CVA6 PMA generation and router decoding. The PMA adapter maps class `00` into CVA6 cached-region fields, class `10` into non-idempotent-region fields, and leaves class `01` outside both lists so it remains idempotent and uncached. Keep CVA6's cacheable range as the default entry; integrations add normal-uncached and MMIO entries with no guessed SoC addresses. Example: with entry 0 `{base=0x80000000,size=0x40000000,type=CACHEABLE}`, entry 1 `{base=0x100000000,size=0x10000000,type=NORMAL_UNCACHED}`, and entry 2 `{base=0x40000000,size=0x10000000,type=MMIO}`, address `0x100000100` uses the LLC bypass memory path while `0x40000100` uses the MMIO manager; these latter ranges are illustrative only and are not defaults. Unmatched addresses return a local access error without external traffic. The table capacity is 16; CVA6's separate non-idempotent list can represent up to 16 MMIO entries, while this LLC configuration supports one cacheable window. SoC-specific entries and integration of the source table into each hart's PMA/router remain to be implemented and verified. / Người thiết kế chọn một bảng compile-time làm nguồn chung để tạo PMA CVA6 và decode router. Bộ chuyển đổi đưa class `00` vào cached-region của CVA6, class `10` vào non-idempotent-region; class `01` nằm ngoài cả hai danh sách để giữ thuộc tính idempotent/uncached. Giữ vùng cacheable CVA6 làm entry mặc định; SoC bổ sung normal-uncached/MMIO, không tự đoán địa chỉ. Ví dụ chỉ minh họa cách phân loại. Địa chỉ không khớp bị trả lỗi cục bộ, không phát AXI. Bảng có tối đa 16 entry; LLC hiện hỗ trợ một cửa sổ cacheable. Các vùng thật của SoC và tích hợp bảng vào PMA/router từng hart còn cần triển khai và kiểm chứng.

| ID | Type | Assumption / dependency / unresolved decision | Technical impact / version / configuration | Resolution / status |
|---|---|---|---|---|
| ASM-001 | Assumption | Use Linux-capable industrial edge gateway with packet filtering/encryption as representative application | Drives proposed 2/4-hart and 256-KiB LLC example values; no workload target supplied | Proposed for this draft |
| ASM-002 | Assumption | Four harts is the default synthesis profile; two harts remains supported | Changes replicated area and default test config | Proposed; user can change |
| ASM-003 | Assumption | AXI-only external DMA uses software cache maintenance; ACE profile is the only external-coherent option | Wrong integration can expose stale data | Required system contract |
| ASM-004 | Assumption | Six platform interrupt classes are level inputs synchronous at cluster boundary | Pin naming/CDC contract | Review with SoC interrupt controller |
| ASM-005 | Assumption | SoC provides synchronized reset deassertion to i_rst_n_cluster | Reset-release ownership | Review with reset controller |
| ASM-006 | Assumption | PARA_PMU_COUNTER_W defaults to 64; 32-bit mode is also supported | Default register map and snapshot sequence | Proposed from user-selected 32/64 choices |
| ASM-007 | Assumption | Cluster reset clears cache-coherence state and does not preserve dirty private-cache data; a warm-reset flow that must preserve memory contents shall quiesce and clean/flush first | Software/SoC must complete maintenance before reset | Explicit behavior in Section 10.2.1; verify reset and flush sequencing |
| DEC-001 | Decision | CSR naming prefix is cpucl | Workbook register and field names | User selected, 2026-11-06 |
| DEC-002 | Decision | PARA_PMU_COUNTER_NUM range 1–32, default 16 | PMU state and CSR bank | User selected, 2026-11-06 |
| DEC-003 | Decision | One aggregate level PMU interrupt with cause/status bits | One output pin; source identified through CSR | User selected, 2026-11-06 |
| DEC-004 | Decision | For 64-bit PMU, use a software-requested snapshot command before reading low/high words | Adds one CSR command/poll step; avoids torn reads and generator read-event limitation | User selected option A, 2026-11-06 |
| DEC-005 | Decision | Each PMU counter can select one hart, aggregate active harts, or a cluster-global event using scope values 0–5 | 0–3 select hart, 4 aggregate, 5 cluster-global, 6–7 reserved | User selected both modes and approved the encoding, 2026-11-06 |
| DEC-006 | Decision | Aggregate per-hart events sum occurrences in the same cycle | One event from each of four harts increments a counter by four | User approved sum semantics, 2026-11-06 |
| DEC-007 | Decision | Use MESI stable states for each private D-cache; E-to-M store is local, S-to-M requires invalidation, and M-to-S must make the LLC current before sharing completes | Avoids an ownership upgrade after a private read while retaining a clean shared state; transient implementation state is internal | User selected MESI, 2026-11-07 |
| DEC-008 | Decision (partly superseded) | Retain physical-line locking, serialize same-line miss/refill/probe conflicts, and allow unrelated-line progress when resources permit. Its initial broadcast-targeting and one-probe-per-cache baseline are superseded by DEC-013. | Dirty line is 16 bytes and uses two 64-bit beats; progress remains subject to bank/port/MSHR/CCU/LLC/AXI conflicts | Line-lock behavior retained; original broadcast/probe-depth assumptions superseded, 2026-11-07 |
| DEC-009 | Decision | Coherence covers D-cache only; software uses inter-hart notification and `FENCE.I` for executable-memory changes | No hardware I-cache probe path | User selected option A, 2026-11-06 |
| DEC-010 | Decision | Generate RTL for the AXI profile first; defer an external ACE top | Current delivered top has AXI4+ATOP memory and non-coherent external DMA contract | User selected AXI first, 2026-11-06 |
| DEC-011 | Decision | Cacheable D-cache misses/ownership traffic traverse CCU and shared LLC before AXI memory; non-cacheable MMIO bypasses cache/LLC allocation | External AXI DMA remains non-coherent and needs software/system cache maintenance | User selected CPU→LLC→AXI path, 2026-11-06 |
| DEC-013 | Decision | Use a conservative per-line sharer directory, targeted probes, unique internal transaction tags, and concurrent distinct-line contexts. | Replaces DEC-008 broadcast probes. Same-line serialization remains mandatory. | User selected, 2026-11-07 |
| DEC-014 | Decision | Use a 4-bank, 8-way non-inclusive sharer directory with `PARA_CPU_NUM × 2,048` entries: 4,096 for 2 harts and 8,192 for 4 harts. LLC eviction does not invalidate L1; replacing a live directory entry requires two-phase invalidation and dirty-data resolution. | Matches aggregate private D-cache capacity while avoiding LLC-inclusive capacity coupling. | User selected, 2026-11-07 |
| DEC-015 | Decision | `PARA_COH_TXN_NUM` defaults to 8, legal 2–16; slot index is the active tag; per-cache probe queue depth equals the parameter and each cache services one probe at a time. | Bounded tagged overlap and probe association. | User selected recommended configuration, 2026-11-07 |
| DEC-016 | Decision | Use two-phase PREPARE/COMMIT with ABORT before commit: PREPARE locks and reports stable state/status without changing stable MESI; an M owner writes the full line through its existing AXI path and PREPARE waits for B status (DEC-027); COMMIT applies the target state; directory update and requester grant wait for all commit acknowledgements; any precommit error aborts prepared targets and preserves their old stable states. | Prevents partial invalidation/downgrade from exposing an inconsistent requester grant. Post-COMMIT missing-ACK behavior is DEC-018. | User selected two-phase option, 2026-11-07; dirty-owner path selected 2026-11-07 |
| DEC-018 | Decision | PREPARE, COMMIT, and ABORT have no ACK timeout. On a missing ACK, retain the CCU line lock and transaction slot until all expected ACKs or cluster reset. During PREPARE wait, do not change stable MESI/directory, send COMMIT, or grant the requester. During ABORT wait, keep the directory unchanged and retain the CCU lock/slot; caches that accepted ABORT preserve old MESI and may release their local lock. During COMMIT wait, do not roll back, update the directory, or grant the requester. Other lines may progress only with independent slots/resources. Reset is the only recovery. | A missing phase ACK can block that line indefinitely, but no timeout or implicit response is invented. WF-015–WF-017 define the three cases. | User selected no timeout in all phases, 2026-11-07; REQ-MEM-013, TEST-029–031, WF-015–017 |
| DEC-017 | Decision | The cluster-local AXI4-Lite aperture uses a 4-KiB CSR window at offsets `0x0000–0x0FFF` and a 4-KiB LLC-service window at `0x1000–0x1FFF`; unassigned offsets are reserved. | Local map is fixed; absolute base is SoC-defined and 4-KiB aligned. Reserved reads return zero/DECERR; reserved writes return DECERR with no side effect. | User selected, 2026-11-07 |
| DEC-019 | Decision | `PARA_CPU_NUM` accepts 2 or 4 and defaults to 4 harts. | Performance-oriented default; synthesize two harts when area or power is the stronger constraint. | User selected, 2026-11-07; REQ-SYS-001 |
| DEC-020 | Decision | Use per-bank round-robin arbitration across eligible transaction slots; determine eligibility before arbitration and do not let an ineligible request occupy a grant. Initialize each arbiter pointer to slot 0 and advance after each accepted grant. Use 8-way tree-PLRU replacement with seven bits per set initialized to zero (`0` selects left, `1` right during victim walk); choose the lowest-index invalid way before replacement; update each path bit away from a committed accessed way. | Fairly rotates eligible grants and uses compact approximate-recency metadata. Victim resolution still waits for holder invalidation/dirty-data completion. | User selected, 2026-11-07; REQ-MEM-014/019, TEST-033/044 |
| DEC-021 | Decision | Add shared 64-bit runtime input `i_boot_addr`, fanned out to all active CVA6 harts. | SoC may release every hart at the same boot ROM entry; software uses `mhartid` for per-hart startup. | User selected, 2026-11-07; REQ-SYS-003, TEST-032 |
| DEC-022 | Decision | Disable CVXIF by setting `CVA6ConfigCvxifEn=0` in a separate license-preserving local copy of the selected CVA6 config. Keep the pinned upstream source/config unchanged and expose no cluster CVXIF ports. | Avoids an unconnected accelerator interface when no custom accelerator is defined; the config delta is explicit and reviewable. | User selected, 2026-11-07; REQ-SYS-004 |
| DEC-023 | Decision | Preserve the LLC's 6-bit AWATOP at the 7-bit-ID AXI memory boundary. The SoC shall use an ATOP-capable path or a real atomic-service bridge before any non-ATOP fabric; an `axi_atop_filter` is not a substitute. | Required for the selected CVA6 A-extension uncacheable LR/SC and AMO path; SoC-level atomic bridge remains outside this cluster RTL. | User selected AXI4+ATOP boundary, 2026-11-07; REQ-IF-009 |
| DEC-024 | Decision | Add a new VLSIT AXI4-Lite-to-PULP-RegBus service bridge for the LLC window; leave pinned `axi_llc_reg_wrap` unchanged. | Keeps one external AXI4-Lite control port and preserves upstream LLC source/license. | User selected, 2026-11-07; REQ-IF-010 |
| DEC-025 | Decision | Reserve stable PMU event-ID ranges by source: CVA6 `0x0001–0x0016`, HPDcache `0x0100–0x010F`, LLC AXI transfers `0x0200–0x0205`, LLC descriptors `0x0206–0x0217`, LLC storage requests `0x0240–0x0243`, and CCU `0x0300–0x030B`. Unknown, reserved, unavailable and disabled-SPM IDs count zero. | Workbook `Event_Map` contains the source-grounded catalog draft and allowed scopes. Individual event definitions and proposed CCU tap conditions remain for review. | User selected source groups/ranges, 2026-11-07; catalog details pending review; REQ-PMU-007/008 |
| DEC-026 | Decision | Use hybrid PMU multiplicity: per-hart indicators remain 0/1 and aggregate scope sums hart indicators; cluster-scope transaction/handshake events count actual occurrences, with CCU taps representing 0–4 occurrences in 3 bits; stall/full/conflict events count asserted cycles once. Each single-instance LLC `.active` field contributes 0/1 accepted event per cycle. | Preserves event multiplicity across concurrent directory banks without counting a sustained stall as repeated requests. The CCU 0–4 bound follows four-bank/four-hart concurrency and requires implementation assertions. | User selected hybrid by event type, 2026-11-07; REQ-PMU-008, TEST-035 |
| DEC-027 | Decision | A dirty M owner writes the 16-byte line to the LLC through its existing per-hart HPDcache AXI path during PREPARE. The owner keeps stable M and the line lock; it returns PREPARE completion only after the matching AXI B response. The probe response carries `(tag, hart, line, observed state, status, writeback_done)`, not line data. A B error fails PREPARE and triggers precommit ABORT; no directory update or requester grant occurs. COMMIT later changes the owner to S or I. | Preserves the approved seven-bit external memory ID and avoids a new CCU AXI source. PREPARE latency includes the owner writeback; modified HPDcache flush routing must keep the line and separate probe completion/error from normal flush/CMO responses until COMMIT/ABORT. | User selected Option A, 2026-11-07; REQ-MEM-012, TEST-020/026, WF-002, port plan §5.8 |
| DEC-028 | Decision | Route legal, CVA6-decoded Zicbom CBO operations through one VLSIT CMO controller using the existing CCU line lock and transaction context. CLEAN writes dirty L1 data to LLC then dirty LLC data to external memory while retaining valid copies; FLUSH performs the same clean then invalidates L1/LLC copies; true CBIE-decoded INVAL locks and invalidates L1/LLC copies at commit without writeback, while INVAL decoded as FLUSH follows FLUSH. Add per-line no-refill LLC maintenance, commit-gated state updates, and error propagation that preserves dirty data. | CLEAN/FLUSH provide system-wide visibility to non-coherent DMA. True INVAL may discard dirty data, so software must clean first when it must preserve those bytes. SoC/software must order or quiesce DMA to the target line during CMO. | User selected full-system CMO and LLC per-line support, 2026-11-07; REQ-MEM-015/016, FSM-011, port plan §5.9 |
| DEC-029 | Decision | Hold CBO at the CVA6 retirement head until CMO completion; on success retire once. For a writeback-required operation (CLEAN, FLUSH, or INVAL decoded as FLUSH) that receives an owner/LLC writeback error, preserve recoverable state, send ABORT and wait for all required ABORT ACKs, then raise a precise synchronous Store/AMO access-fault (exception code 7) before retirement with the original effective address and instruction PC. True INVAL does not issue writeback and has no writeback B-error path. No younger instruction retires while the CBO is pending. | Makes writeback failure visible and prevents partial invalidation or lost dirty data from being reported as success, while preserving true invalidate's discard semantics. | User selected precise synchronous fault, 2026-11-07; REQ-MEM-017, TEST-039, FSM-011, WF-018 |
| DEC-030 | Decision | Implement local `FENCE.I` with `DcacheFlushOnFenceI=1`: scan the executing hart's D-cache, transfer each dirty M line through the CCU/owner HPDcache AXI path to shared LLC, wait for successful LLC acceptance, and commit the owner M→E while keeping directory state consistent. Do not issue LLC-to-external-memory writeback solely for `FENCE.I`. After the scan, invalidate only the executing hart's I-cache and fetch pipeline, then complete the fence. Other harts require their own software-notified `FENCE.I`. | Meets local instruction-fetch visibility while avoiding unnecessary DRAM write traffic; failures are handled separately by DEC-031. | User selected Option A, 2026-11-08; REQ-MEM-007/018, REF-013, port plan §5.9 |
| DEC-031 | Decision | On a non-OKAY L1-to-LLC B response during FENCE.I, preserve the failed dirty line in M and retain its directory holder; send ABORT and wait indefinitely for every required ABORT ACK or reset. Keep FENCE.I at the retirement head and block younger retirement. After all ABORT ACKs, raise a precise synchronous custom maintenance exception (exception code 24 in `mcause`/`scause`) at the FENCE.I PC; set `mepc`/`sepc` to that PC and write the aligned physical line base to `mtval`/`stval` according to the selected trap privilege. Do not invalidate local I-cache/fetch state on this error. A handler may correct the write-path cause and return to the faulting PC to retry. | Gives software a precise failure point without losing dirty data or misusing the CBO Store/AMO access-fault code. Exception code 24 is within the RISC-V custom exception range; its line-address trap value and recovery contract are cluster-defined. | User selected cause-24 maintenance exception and WF-019, 2026-11-08; REQ-MEM-018, REF-014, TEST-042 |
| DEC-032 | Decision (v0.19 spec contract) | Directory bank arbitration filters eligibility before choosing a request. A blocked non-owner operation cannot occupy a grant or prevent a matching reservation-owner UPDATE/CANCEL. The owner terminal operation releases the set reservation; one directory operation per bank per cycle and round-robin fairness among eligible slots remain. | Resolves review finding CC-01 while preserving set-level serialization and the selected no-timeout ACK policy. RTL remains unchanged; user review and FSM draw.io update are pending. | Added by v0.19 spec update; REQ-MEM-019/020, TEST-044, WF-020 |
| DEC-033 | Decision (v0.19 spec contract) | Probe response channels drain stale, duplicate, unknown, and mismatched ACKs; only the first expected matching response updates a transaction. Invalid responses set a coherence-protocol diagnostic and cannot block a later valid ACK. | Resolves the head-of-line blocking risk in review finding CC-02. Exact CSR diagnostic field remains an integration dependency; RTL and workbook remain unchanged. | Added by v0.19 spec update; REQ-MEM-021, ERR-010, TEST-045 |
| DEC-034 | Decision (memory boundary implementation) | Keep the native CVA6/HPDcache/LLC path at 64-bit. Add `PARA_AXI_MEM_DATA_W` for the external memory port with legal values `{32,64,128,256}` through the PULP width converter; keep MMIO at 64-bit and AXI4-Lite at 32-bit. | Does not change cache-line size or native datapath. The width adapter leaf is linted and directed-tested at all four widths; LLC-to-SoC integration, full response/error coverage, and supported-burst signoff remain open. | Implemented as adapter leaf in RTL; HDS Section 8 and TEST-047 track remaining end-to-end validation |
| DEC-035 | Decision (v0.19 review contract) | Treat a per-slot bank request as a single operation token; suppress a consumed slot until VALID has been sampled low, and retain all phase-critical transaction fields/status until the context is safely released. | Closes the duplicate-grant and context-loss ambiguities in review finding CC-03; implementation and assertions remain unverified. | Added by v0.19 spec update; REQ-MEM-022/023, TEST-048/049 |
| DEP-001 | Dependency | Pin manifests identify upstream CVA6, HPDcache, Culsans, AXI, ACE, and axi_llc commits; prove selected filelist/license and source-port compatibility | Culsans pins a different PlanV CVA6/LLC while this design selects OpenHW CVA6/HPDcache | Source commits are recorded in `rtl/third_party/README.md`; compatibility and file-level release audit remain open |
| DEP-002 | Dependency | Map the defined internal ACE-subset outcomes to the exact pinned cache/CCU ports; external ACE transaction attributes, DVM, and external-agent policy belong to a future spec | Internal stable-state behavior is specified in Section 10.2.1; exact records/encodings still need source-level mapping | Internal behavior closed for planning; port mapping open; external ACE deferred |
| DEP-003 | Dependency | Arm IHI 0022H was read through official web PDF; no local converted standard exists | Clause-level audit and controlled copy are absent | User approved web-only source; recheck before signoff |
| DEP-004 | Dependency | Pin exact RISC-V ISA/debug spec revisions and the actual CVA6 extension configuration | Software compatibility and architectural tests | Open; pin with source commit |
| DEP-005 | Dependency | Choose global hart-ID allocation when multiple clusters exist | Current proposal uses local hart indices 0..N−1 | SoC integration input |
| DEP-006 | Dependency | Define external Debug Module clock/reset relation and authorization policy | CDC, access control and per-hart debug behavior | SoC integration input |
| DEP-007 | Dependency | Supply PDK/library, SRAM views, SDC, PVT/RC corners, voltage, clock and workload | Required for Fmax/area/power targets, timing budgets and macro fit | No numeric target supplied |
| DEP-008 | Dependency | Implement the cataloged PMU event wires, validate the workbook with CSR_Generation.py, and verify all source-to-counter paths against pinned revisions | Software-visible event availability and hardware update wiring | Event IDs and source mapping are selected in DEC-025; RTL integration and generated-workbook validation remain open |
| DEP-010 | Dependency | Complete waveform set WF-001 through WF-020; draw specified behavior and mark unresolved interface/timing gaps as pending | User approved the original 14 topics; DEC-018 adds the three phase-specific missing-ACK cases; DEC-029/031 add precise CBO/FENCE.I fault ordering; WF-020 illustrates CC-01 escape | WF-002 and WF-015–020 complete; other pending figures remain |
| DEP-011 | Dependency (ranges set by DEC-025) | Review the detailed Event_Map draft, freeze the exact source revisions, implement CCU event taps, and confirm each source's pulse/level semantics during RTL integration | A source-map correction, source revision drift, or missing event tap could invalidate software-visible measurements | Source groups and ranges are user-confirmed; detailed mapping review and implementation connectivity remain open |
| DEP-012 | Dependency | Review FSM V4, including FSM-011 CBO/CMO behavior; close source-port mappings, remaining transition guards and integration error paths before RTL freeze | V2/V3 coherence figures are historical; V4 is the current review draft | V4 library provenance and geometry checks pass; user review and source-level mapping remain open |
| DEP-013 | Dependency | Map the selected directory geometry to SRAM/memory implementation and finalize ECC/parity choice | Must preserve directory invariants and fit library macros | Logical organization/size/banking/replacement selected; physical mapping remains open |
| DEP-014 | Dependency | Audit the 2/8/16 transaction parameter endpoints against CVA6/HPDcache source capacities and define implementation arbitration details | Prevents over-advertising concurrency beyond the adapted cache resources | Slot/tag/queue limits selected; source compatibility remains open |
| DEP-015 | Dependency | Finalize and verify error paths for source-specific LLC/AXI responses and reset interruption | Must not expose partial coherence state | Precommit ABORT and no-timeout ACK waits in all phases are selected; source response mapping and fault-injection behavior remain to verify |
| DEP-016 | Dependency (closed by DEC-021) | Add shared `i_boot_addr[63:0]` and connect it to every active CVA6 `boot_addr_i` | CVA6 requires this runtime input | Contract selected; verify exact source sampling and fanout during integration |
| DEP-017 | Dependency (closed by DEC-022) | Disable CVXIF in a local configuration copy while retaining license/history and leaving upstream source pristine | Selected configuration enables CVXIF but the cluster has no accelerator interface | Contract selected; implement config copy and check native CVXIF pins are safely inactive |
| DEP-018 | Dependency (boundary selected by DEC-023) | Verify the SoC AXI4+ATOP target or separately supplied atomic-service bridge against every supported LR/SC and AMO encoding | The SoC fabric capability and bridge implementation are not part of the cluster RTL | Boundary contract selected; system atomic-service verification remains an integration dependency |
| DEP-019 | Dependency (bridge selected by DEC-024) | Complete the new AXI4-Lite-to-RegBus bridge port/timing map and verify against the pinned `register_interface` types | Exact RegBus request/response widths and handshake timing must match the pinned source | Architecture selected; bridge module port table and implementation verification remain open |
| DEP-020 | Dependency (architecture closed by DEC-027) | Freeze exact HPDcache probe/writeback ports; modify the flush engine for probe-origin tracking and B-error routing; verify owner AXI writeback, M-state retention, ABORT on B error, and COMMIT/ABORT lock release | Data path is selected, but pinned HPDcache flush completion is currently shared and lacks probe-specific status | No CCU AXI source or external ID-width change; implementation details remain in the reviewed RTL port plan |
| DEP-021 | Implemented; directed verification passed 2026-11-15 | Cause-24 provenance, M/S exception routing and delegation, physical line-base trap value, ABORT-before-trap, held retirement, I-cache completion and handler retry implemented in licensed copies | TEST-041/042 pass with real FENCE.I at 2/4 harts in M and delegated S mode; production TOP lint has 0 errors/warnings; evidence: `rtl/reports/fence_i/README.md` | Directed closure only: bare S mode, reduced simulation LLC; full OS/Sv39/concurrency and signoff remain separate |
| DEP-022 | Integration dependency (DEC-034) | Connect the tested external memory width adapter after the LLC and prove ATOP, IDs, transfer sizes, burst forms, strobes, ordering, and error responses end-to-end | Native LLC width is 64-bit; the adapter leaf accepts external width 32/64/128/256. MMIO remains 64-bit | Leaf lint/simulation complete; cluster integration and SoC-level protocol verification remain open |
| DEP-023 | Dependency (DEC-033) | Add the coherence-protocol diagnostic field and clear semantics to the CSR workbook; align the PMU/event map and error table | Necessary to make drained invalid ACKs software-visible without changing transaction state | Spec behavior defined; workbook/CSR RTL not updated |
| DEP-024 | Dependency (DEC-032/FSM-012) | Update the editable FSM draw.io source with the eligibility filter, owner-terminal escape, and set-reservation release transitions | Required before RTL approval under the project FSM documentation rule | Abstract transition table and WF-020 added; draw.io source update pending |
| DEP-025 | Dependency (DEC-035) | Implement and verify request-token rearm and phase-context retention in the bank arbiter, transaction table, and probe scheduler | Prevent duplicate grants and lost owner/target/error state across PREPARE/COMMIT/ABORT | Spec contract added; RTL and testbench remain unchanged |

## 21. Glossary

| Term / acronym | Definition |
|---|---|
| ACE | AXI Coherency Extensions; adds coherent transaction attributes and snoop channels to AXI |
| CBO / CMO | Cache-Block Operation / Cache-Management Operation. A CBO is the RISC-V instruction; CMO is the hardware maintenance operation it requests. / Lệnh Cache-Block Operation / thao tác Cache-Management Operation. CBO là lệnh RISC-V; CMO là thao tác phần cứng được yêu cầu. |
| Precise synchronous fault | Exception attributed to the faulting instruction before it retires, with its instruction PC and effective address retained in trap state. / Ngoại lệ đồng bộ gắn với lệnh gây lỗi trước khi lệnh nghỉ hưu, giữ PC lệnh và địa chỉ hiệu dụng trong trạng thái trap. |
| FSM | Finite-state machine; control logic represented as named states and guarded transitions. / Máy trạng thái hữu hạn; logic điều khiển được mô tả bằng state có tên và transition có điều kiện. |
| FSM guard | Boolean condition or handshake event that permits a transition. / Điều kiện logic hoặc sự kiện handshake cho phép chuyển state. |
| FSM transition | Directed change from one state to another, with its guard and action. / Chuyển có hướng giữa hai state, kèm điều kiện và hành động. |
| AXI4-Lite | Reduced AXI memory-mapped interface intended for control/status access |
| CVA6 | OpenHW 64-bit RISC-V application-class CPU core |
| Hart | One RISC-V hardware thread; here one CVA6 core per hart |
| HPDcache | OpenHW high-performance, multi-requester, out-of-order L1 data cache |
| LLC | Last-level cache shared behind the private L1 caches |
| Coherence | Protocol that keeps cached copies and ownership consistent among agents |
| Non-inclusive directory | Directory whose entries and capacity are managed independently from LLC residency; an LLC eviction does not invalidate an L1 holder. |
| Prepare / commit / abort | Two-phase coherence flow: prepare locks and reports a cache line without changing its stable MESI state; commit applies the requested state; abort releases the line with the previous state intact. |
| Directory bank | Independently arbitrated part of the sharer directory; same-bank conflicts serialize, while different banks can progress concurrently. |
| Round-robin arbitration | Fair cyclic selection among eligible request slots; after a grant, the priority pointer advances to the next slot. |
| Tree-PLRU | Seven-bit tree-based pseudo-least-recently-used policy for selecting one of eight directory ways; it approximates recency with less state than exact LRU. |
| Transaction context / tag | Slot that stores one active line transaction and its unique identifier; the tag is reused only after all associated responses drain. |
| Forward progress | An eligible operation eventually completes under stated fairness and environment-response assumptions; this is not a finite latency guarantee. / Thao tác đủ điều kiện cuối cùng hoàn tất khi thỏa giả định công bằng và phản hồi môi trường; đây không phải cam kết latency hữu hạn. |
| Head-of-line blocking | A blocked request at the front of an arbitration/response path prevents a later eligible request from being accepted. / Request bị chặn ở đầu đường phân xử/response làm request đủ điều kiện phía sau không được nhận. |
| Wait-for graph | Model of resources and transactions showing which owner is waiting for which resource/response; a cycle indicates possible deadlock. / Mô hình tài nguyên và transaction thể hiện chủ nào đang chờ tài nguyên/response nào; một vòng chờ báo nguy cơ deadlock. |
| AXI width converter | AXI adapter that changes data width while translating beats, strobes, IDs, responses, and supported burst forms. / Adapter AXI đổi độ rộng dữ liệu và chuyển đổi beat, strobe, ID, response cùng loại burst được hỗ trợ. |
| Reserved offset | Unassigned aligned address inside a defined local window; reads return zero with DECERR and writes have no side effect and return DECERR. |
| Snoop | Coherence request that asks a cache to inspect or change a line |
| SPM | Scratchpad memory mode; disabled in this design |
| PMU | Performance monitoring unit that counts selected hardware events |
| Snapshot | Captured counter image held stable while software reads multiple words |
| DTM / DMI / DM | Debug Transport Module / Debug Module Interface / Debug Module |
| BIST | Built-in self-test of memory or storage structures |
| PVT / RC | Process-voltage-temperature and interconnect resistance-capacitance analysis corners |
| Backpressure | Receiver deasserts READY, delaying a channel transfer while source holds VALID/payload |
| CCU | Coherence control unit; tracks/coordinates cache ownership and probes. / Khối điều khiển coherence; theo dõi và phối hợp ownership cache/probe. |
| MMIO | Memory-mapped input/output; peripheral access through an addressable bus. / Truy cập ngoại vi qua bus có ánh xạ địa chỉ. |
| AXI mux / demux | Multiplexer arbitrates request sources; demultiplexer routes transactions to targets. / Mux phân xử nguồn request; demux định tuyến giao dịch đến target. |
| LLC descriptor | Internal record describing one cache-line operation derived from a bus transaction. / Bản ghi nội bộ mô tả thao tác cache line được tách từ giao dịch bus. |
| Eviction / refill | Replacement writes a dirty victim out; refill reads the requested line in. / Eviction ghi victim dirty ra; refill nạp line được yêu cầu vào. |
| SRAM binding | Mapping a generic memory interface to a technology-specific compiled SRAM macro. / Ánh xạ giao diện memory tổng quát sang SRAM macro theo công nghệ. |
| REUSE / REUSE* / MODIFY / NEW / GENERATED | Implementation status defined in Section 14.3. / Trạng thái triển khai được định nghĩa tại Mục 14.3. |

## 22. References used to shape this template

1. Arm, AMBA AXI and ACE Protocol Specification, IHI 0022H, [official PDF](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/IHI0022H_amba_axi_protocol_spec.pdf?hash=6325311012DDADF238C35A6C0FD734E520754F82&la=en&revision=71bd7c57-2ed7-487b-bc3e-68c4ab56fa5f). AXI4-Lite Part B/B1; ACE Part D. User approved web-based use; not locally converted.
2. OpenHW, [CVA6 repository](https://github.com/openhwfoundation/cva6), selected configuration [cv64a6_imafdc_sv39_hpdcache_wb_config_pkg.sv](https://github.com/openhwfoundation/cva6/blob/master/core/include/cv64a6_imafdc_sv39_hpdcache_wb_config_pkg.sv). The file declares 64-bit AXI address/data, 4-bit AXI ID, 16-KiB four-way I-cache, 32-KiB eight-way D-cache, and 128-bit cache lines.
3. OpenHW, [HPDcache repository](https://github.com/openhwfoundation/cv-hpdcache) and [User Guide interface chapter](https://openhw-group-cv-hpdcache.readthedocs-hosted.com/interface.html). Static geometry includes line width = configured cacheline words × word width.
4. PULP, [Culsans repository](https://github.com/pulp-platform/culsans) and [current submodule manifest](https://github.com/pulp-platform/culsans/blob/master/.gitmodules). Culsans describes two-to-four CVA6 coherent integration and currently pins a PlanV CVA6 fork; this is not upstream HPDcache compatibility evidence.
5. PULP, [axi_llc architecture](https://github.com/pulp-platform/axi_llc/blob/master/doc/axi_llc.md). Static ways/lines/blocks determine cache geometry; BIST, flush, counters and SPM-related controls use a dedicated AXI4-Lite port.
6. PULP, [Culsans coherence paper](https://arxiv.org/abs/2407.19895). Reference evidence is limited to the reported design and evaluated configurations, not this proposed IP.
7. RISC-V International, [Debug Specification documentation](https://docs.riscv.org/reference/debug/).
8. [CSR_Generation.py v3.4 project README](https://github.com/nguyenquanicd/APB-CSR-Generator) and local baseline commit c40f319; the local approved v3.5 patch adds opt-in VLSIT formatting and keeps the default generator behavior unchanged. It supports AXI4-Lite 32-bit, queued transactions and `wo` fields with hardware clear.
9. VLSIT, [RTL generator project page](https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model) and the local VLSIT RTL Design Rule v2 file identified in Section 2.
10. OpenHW, [CVA6 CSR performance-counter documentation](https://github.com/openhwgroup/cva6/blob/master/docs/01_cva6_user/CSR_Performance_Counters.rst). Its event table is a candidate per-hart source; the selected configuration and exact RTL commit must be checked before adopting any event code.
11. PULP, [AXI SystemVerilog library](https://github.com/pulp-platform/axi). `axi_mux`, `axi_demux`, and `axi_lite_demux` are reuse candidates only; version, topology, IDs, and response behavior require compatibility checks.
12. PULP, [ACE interconnector](https://github.com/pulp-platform/ace) and [`ace_ccu_top` architecture](https://github.com/pulp-platform/ace/blob/master/doc/ace_ccu_top.md). This is a design reference/candidate, not a proven drop-in for the selected upstream CVA6/HPDcache cluster.
13. PULP, [AXI SystemVerilog width converter](https://github.com/pulp-platform/axi/tree/master/src), local files `axi_dw_converter.sv`, `axi_dw_upsizer.sv`, and `axi_dw_downsizer.sv`. The pinned source supports useful width-conversion cases but documents limits for FIXED/WRAP bursts; verify exact ATOP and response behavior before selecting an external width profile.


## DEC-030/031 implementation clarification — 2026-11-15

**EN:** The retained retirement command uses internal operation `3` for a FENCE.I dirty-line clean to LLC; standard CBO operations remain `0=CLEAN`, `1=FLUSH`, `2=INVAL`. The HPDcache walker submits one dirty physical line at a time. The CCU completes PREPARE and owner writeback, then COMMIT M→E or ABORT; this operation does not invoke LLC-to-DRAM maintenance. After a successful scan, retirement requests local I-cache invalidation and waits for its explicit completion ACK. The terminal retirement edge flushes the local fetch/decode pipeline; it does not repeat either cache walk. A failed scan requests no I-cache invalidation and raises cause 24 only after the last required ABORT ACK.

**VI:** Lệnh giữ tại retirement dùng operation nội bộ `3` cho FENCE.I clean dirty line lên LLC; CBO giữ mã `0=CLEAN`, `1=FLUSH`, `2=INVAL`. Walker gửi từng physical line dirty qua CCU. PREPARE chờ owner writeback, sau đó COMMIT M→E hoặc ABORT; không gọi maintenance ghi LLC xuống DRAM. Sau scan thành công, retirement yêu cầu invalidate I-cache và chờ ACK hoàn tất. Cạnh retire cuối flush fetch/decode cục bộ, không lặp lại cache walk. Nếu scan lỗi, không invalidate I-cache; cause 24 chỉ phát sau ACK ABORT cuối cùng.

**EN:** Upstream CVA6 also uses value 24 as its internal `DEBUG_REQUEST` pseudo-exception. The modified core therefore supplies explicit maintenance-fault provenance to the CSR/trap unit. A DEC-031 fault follows the normal architectural exception path and may be delegated through `medeleg[24]`; an ordinary debug request retains the upstream debug path. The aligned physical line base is delivered to `mtval` or `stval`. No exception-number remapping is applied at the external architectural boundary.

**VI:** CVA6 upstream cũng dùng số 24 cho pseudo-exception nội bộ `DEBUG_REQUEST`. Core sửa bổ sung tín hiệu phân biệt nguồn maintenance fault tại CSR/trap unit. Lỗi DEC-031 đi theo đường exception kiến trúc và có thể delegate qua `medeleg[24]`; debug request thông thường vẫn đi theo đường debug gốc. Physical line base đã căn chỉnh được ghi vào `mtval` hoặc `stval`; không đổi số cause ở giao diện kiến trúc.

**EN:** FENCE.I gates new CPU load/prefetch admission while older stores drain. CVA6 requester 0 (page-table walker), existing refill/response work and coherence probes remain able to progress subject to native array/queue arbitration. This prevents a circular wait between instruction translation, I-cache flush completion and retirement. These rules add no ACK timeout.

**VI:** Trong FENCE.I, chặn nhận CPU load/prefetch mới nhưng cho store cũ drain. Requester 0 của CVA6 (page-table walker), refill/response đang có và coherence probe vẫn được tiến hành theo arbitration tài nguyên. Nhờ đó tránh vòng chờ giữa dịch địa chỉ instruction, hoàn tất flush I-cache và retirement. Không thêm timeout cho ACK.

Directed evidence: [FENCE.I report](../../rtl/reports/fence_i/README.md), [WF-019 simulation comparison](../../rtl/verification/fence_i_end_to_end/waveforms_sim/waveform_compare.md). This checkpoint concerns TEST-041/042, not complete cluster signoff.


## Silent E→M owner refinement — 2026-11-15

**EN:** Directory E denotes exclusive permission held by the recorded unique owner; that owner's cache may silently transition E→M on a local store. A matching, expected PREPARE from that unique E owner may therefore report E or M. Shared S and recorded M retain their strict state checks; no other holder is allowed to claim the E→M refinement. Request tag, line, phase, expected-hart mask and duplicate-ACK checks remain active.

**VI:** E trong directory ghi quyền exclusive của owner duy nhất; cache owner có thể tự chuyển E→M khi store cục bộ. Vì vậy PREPARE đúng tag/line/phase từ owner E duy nhất được trả E hoặc M. Các state S/M khác vẫn kiểm tra chặt; không cho hart khác tự nhận refinement E→M.

**EN:** The CCU captures that owner before PREPARE as potentially dirty. A still-clean E response satisfies the no-data-needed condition; an actual M response must supply successful writeback completion when the operation requires writeback. Never infer a dirty writeback success from the directory's E label. The CCU retains each validated PREPARE state per context and holder, including on a writeback error. ABORT must return that retained actual state. COMMIT must return the transaction's selected target state. The snapshot is cleared on tag allocation; missing phase ACKs still have no timeout.

**VI:** CCU theo dõi owner này trước PREPARE như owner có thể dirty. E còn clean không cần truyền dữ liệu; M thực phải có writeback completion thành công nếu operation yêu cầu ghi trả. Không suy ra ghi dirty thành công chỉ từ nhãn E trong directory. CCU giữ state PREPARE hợp lệ theo context/holder, kể cả khi writeback lỗi; ABORT phải trả đúng state đã giữ, COMMIT phải trả target state. Snapshot xóa khi cấp tag mới; không thêm timeout ACK.

This clarifies REQ-MEM-001/012/017 and TEST-019 without adding a new coherence channel or pipeline stage. Evidence: `rtl/reports/e_to_m_fix/README.md`.


## A-02: coherent cached atomic execution / Atomic cacheable coherent (2026-11-15)

**DEC-038 — Confirmed by the designer, 2026-11-15; REQ-MEM-001, REQ-IF-009, TEST-036.** Cached AMO and LR/SC execute in L1; uncached operations retain the external AXI4+ATOP/exclusive service. This supersedes TEST-036's former requirement to send cached atomics to the external target. / Cached AMO và LR/SC thực hiện tại L1; uncached giữ dịch vụ AXI4+ATOP/exclusive ngoài. Quyết định thay yêu cầu TEST-036 cũ đưa cả cached atomic ra ngoài.

**Ownership and serialization / Quyền và tuần tự hóa.** Cached SC/AMO requires E/M permission; LR may read a stable S/E/M copy and requests shared permission on a miss. A write-atomic miss requests unique ownership, waits for required peer writeback and terminal ACKs, refills, then replays the original operation. For an S hit, retain the clean S copy while the upgrade waits for CCU permission; older probes may inspect or invalidate that copy. After grant, perform the preparatory refill and replay under same-line exclusion. This implementation uses refill traffic rather than an in-place upgrade. Preparatory refill never returns the atomic instruction's result. Hold exclusion from accepted permission through local response; do not hold it across LR to SC. Cached atomics are not sent to the external atomic target. / SC/AMO cần quyền E/M; LR đọc được S/E/M và miss xin quyền shared. Write-atomic miss xin quyền độc quyền, chờ writeback/ACK cần thiết, refill rồi replay. Với S hit, giữ bản S sạch khi chờ CCU; probe cũ được xử lý bản sao này. Sau grant, giữ exclusion cùng line qua refill, replay và response cục bộ. Refill chuẩn bị không trả kết quả lệnh atomic. Không giữ khóa từ LR đến SC và không gửi cached atomic tới target atomic ngoài.

**LR/SC reservation / Reservation LR/SC.** LR captures the addressed data and establishes the native doubleword reservation. A new LR replaces the previous reservation; every SC attempt consumes it. A matching coherent invalidation, local eviction/invalidation, conflicting local store, or cache access error clears it; read-sharing alone preserves it. Coherent invalidation is conservatively tracked at the 16-byte line granularity. SC rechecks the reservation after any ownership/refill wait, writes only on success, returns zero on success and nonzero on failure. No reservation permits a write without unique ownership. Reset clears reservations. / LR đọc dữ liệu và tạo reservation doubleword. LR mới thay reservation cũ; mỗi lần SC tiêu thụ reservation. Probe invalidate, eviction/invalidation, store cục bộ xung đột và lỗi cache hủy reservation; chia sẻ đọc giữ reservation. Invalidation coherence xét bảo thủ theo line 16 byte. Sau khi đợi quyền/refill, SC kiểm tra lại reservation: chỉ ghi khi thành công, trả 0 khi thành công và khác 0 khi thất bại. Reset xóa reservation.

**Ordering and errors / Thứ tự và lỗi.** Preserve the CVA6 retirement-side atomic admission and HPDcache fence/replay ordering for aq/rl; do not acknowledge an AMO on request/refill acceptance. Ownership/refill failure returns the architectural atomic access error without executing the local read-modify-write. The existing two-phase CCU rollback/error contract applies before permission is granted. / Giữ ordering admission tại retirement CVA6 và fence/replay HPDcache cho aq/rl; không ACK atomic chỉ vì đã nhận request/refill. Lỗi quyền/refill trả lỗi truy cập atomic, không cập nhật cục bộ.

**Example 1 / Ví dụ 1.** Hart 0 owns dirty X=10, LLC has an older value. Hart 1 executes AMOADD.D with operand 3: CCU transfers unique permission after obtaining X=10; hart 1 returns 10 and holds X=13 in M. DRAM need not be updated. / Hart 0 giữ X=10 dirty; hart 1 cộng atomic 3, trả 10 và giữ X=13 tại M; không cần cập nhật DRAM.

**Example 2 / Ví dụ 2.** Hart 0 executes LR.D X; hart 1 stores X before hart 0's SC.D. The intervening ownership probe cancels hart 0's reservation; SC returns failure and does not overwrite hart 1's data. / Store xen giữa từ hart khác hủy reservation; SC thất bại và không ghi đè.

**TEST-036 local extension.** At 2/4 harts, check every AMO arithmetic/logical operation in W/D forms, LR/SC success and reservation loss, sequential and contended ownership, dirty remote-owner transfer, exact return values and no lost updates. Run CBO/FENCE.I regressions and strict TOP lint after integration. External uncached atomic target verification remains a distinct test scope. / Kiểm tra W/D, LR/SC, chuyển owner dirty, tranh chấp và giá trị trả về ở 2/4 hart; chạy lại CBO/FENCE.I và lint TOP.

**Probe service ownership / Giữ quyền phục vụ probe.** A cache's single active probe service belongs to its PREPARE transaction until successful matching COMMIT/ABORT response. The scheduler may not dispatch another transaction's PREPARE to that cache between phases. A PREPARE error still requires the matching ABORT before releasing that service slot. This is distinct from the per-line lock and prevents round-robin phase interleaving from blocking terminal completion. / Cache giữ một transaction probe từ PREPARE tới response COMMIT/ABORT thành công. Không gửi PREPARE của transaction khác vào giữa; PREPARE lỗi vẫn phải chờ ABORT tương ứng. Quyền phục vụ này khác khóa line và ngăn phân xử round-robin chặn completion.

**Atomic refill-to-replay exclusion / Bảo vệ từ refill tới replay.** Once the requested permission is accepted for a pending cached atomic, retain same-line probe exclusion through refill, RTAB replay and terminal local response. Do not clear this exclusion merely when the MSHR completes. Before unique permission is granted, the pending atomic must still permit probes required by older owners/transactions. This prevents two contending harts from repeatedly stealing a freshly refilled line before either executes its atomic. / Sau khi nhận quyền đã yêu cầu cho atomic đang chờ, giữ chặn probe cùng line qua refill, replay và response cuối; không nhả ngay khi MSHR hoàn tất. Trước lúc được cấp quyền vẫn cho phép probe cần thiết tiến hành, tránh deadlock.

**Lock admission / Nhận khóa.** Allocate a cache line lock only on the cache-side PREPARE handshake after the busy query passes. Native exclusion vectors are registered; the query accounts for accepted Stage-0 accesses, active Stage-1 accesses, MSHR/refill activity and the atomic grant-to-response guard, so a PREPARE cannot race a same-edge admitted access. / Chỉ cấp khóa khi PREPARE thực sự bắt tay phía cache sau kiểm tra busy; vector khóa đưa vào pipeline là trạng thái đã chốt, tránh vòng tổ hợp busy/acquire.

**Atomic faults / Lỗi atomic.** Propagate the HPDcache atomic error bit with the matching response through the adapter to retirement. A failed LR raises Load access fault cause 5; a failed SC or other AMO raises Store/AMO access fault cause 7. Retain the original virtual address in the AMO scoreboard result until the late response; set mepc/sepc to the faulting instruction and mtval/stval to that VA. Do not retire that atomic or younger instructions, or write its destination register on failure. Permission errors are delivered only after the CCU's required ABORT acknowledgments. / Giữ bit lỗi cùng response tới retirement; LR lỗi cause 5, SC/AMO lỗi cause 7; giữ VA gốc để ghi trap CSR, không retire hoặc ghi thanh ghi đích khi lỗi.

**LLC refill failure / Refill LLC lỗi.** Aggregate non-OKAY RRESP over every beat of a cache-line refill and return that error in the completion descriptor. Reserve the target set from lookup allocation until refill completion and its deferred tag write. Install a valid tag only on successful refill (and successful dirty-victim writeback when required); invalidate a failed refill allocation so an error cannot be converted into a later successful cache hit. Failed dirty-victim B retains the original tag/data and its existing reset-recovery lock; do not start refill for that failed eviction. Unrelated sets continue through the pending table. / Gom lỗi RRESP của toàn burst; giữ reservation set tới khi refill và tag write hoàn tất. Chỉ cài tag hợp lệ khi refill thành công; refill lỗi phải invalidate allocation. B lỗi của dirty victim vẫn giữ tag/data gốc và khóa đến reset theo hợp đồng hiện có. Các set khác vẫn tiến hành qua pending table.

**Bank handshake association / Ghép handshake theo tag.** Only the context whose tag equals the selected directory lookup tag may leave DIR_REQ on a bank VALID/READY transfer. Other contexts targeting that same bank remain in DIR_REQ. Bank-level acceptance is not broadcast completion for every waiting context. / Chỉ context có tag được chọn mới chuyển DIR_REQ khi lookup bắt tay; các context khác cùng bank vẫn chờ.

**Probe writeback array arbitration / Phân xử array khi probe writeback.** Native flush allocation reads its first SRAM word on the allocation handshake. When a probe needs writeback, stop new CPU/replay/scrub admissions while allowing admitted Stage-1/2 work and refills to drain. Accept the probe flush allocation only when the controller is empty, the local AMO handler is idle and refill is not using the array. The native flush busy state then owns the remaining capture cycles. This prevents a load on another line from colliding with the first probe data read; it does not suppress a conflict assertion or discard an admitted load. / Khi probe cần writeback, chặn admission mới nhưng cho request đã nhận và refill hoàn tất; chỉ bắt tay flush khi array rảnh. Không bỏ assertion xung đột hoặc làm mất load đã nhận.

**Atomic interrupt/debug boundary / Biên interrupt và debug của atomic.** Once an atomic is issued, defer interrupt/debug exception entry until its terminal completion, while cache/probe/AXI machinery continues. A synchronous atomic access fault takes precedence at the terminal response. No ACK timeout is added. / Sau khi atomic đã phát đi, hoãn exception interrupt/debug tới completion; cache/probe/AXI vẫn chạy. Lỗi truy cập atomic có ưu tiên tại response cuối; không thêm timeout ACK.

**LR/SC forward progress / Tiến triển LR/SC.** LR does not acquire write ownership solely to read. Read-sharing transitions preserve reservations; invalidation/eviction or a conflicting store cancels them. A reservationless SC returns failure without acquiring ownership or allocating an MSHR. A valid-reservation S-to-M SC/AMO upgrade retains the clean S copy while waiting for CCU permission; matching probes may access that copy before grant. The upgrade's preparatory refill does not itself cancel the requester's reservation. Once grant is accepted, block same-line probes through refill/replay and local completion; SC rechecks its reservation after this wait. This allows competing constrained LR/SC retry loops to make progress without holding a line lock across LR to SC or adding a timeout/window parameter. Cache access errors clear reservations. / LR chỉ xin quyền đọc. Probe chia sẻ đọc giữ reservation; invalidate/eviction hoặc store xung đột hủy reservation. SC không còn reservation trả thất bại ngay, không tranh quyền. Upgrade S-to-M giữ bản S sạch và cho probe xử lý trước khi được cấp quyền; sau grant giữ exclusion tới completion và SC kiểm tra lại reservation. Không giữ khóa suốt LR→SC, không thêm timeout hoặc tham số cửa sổ ưu tiên. Lỗi truy cập cache xóa reservation.

**Simulation evidence / Bằng chứng mô phỏng.** The A-02 report separates real AMO contention, constrained LR/SC retry contention, refill access faults and dirty-owner writeback ABORT from CBO/FENCE.I regression results. [Report](../../rtl/reports/atomic_coherence/README.md). / Báo cáo tách riêng các ca AMO, LR/SC retry, access fault và ABORT owner khỏi regression CBO/FENCE.I.


**A-02 implementation evidence / Bằng chứng triển khai (2026-11-15).** Actual 2/4-hart CVA6 tests cover contended AMO, LR/SC retry and refill/dirty-owner errors; CBO/FENCE.I regressions and strict TOP lint pass. [Validation](../../rtl/reports/atomic_coherence/validation.md), [AMO samples](../../rtl/reports/atomic_coherence/waveforms/4h_success.svg), [LR/SC retry samples](../../rtl/reports/atomic_coherence/waveforms/4h_lrsc_contention.svg), [owner-error samples](../../rtl/reports/atomic_coherence/waveforms/4h_owner_fault.svg). The figures use nonuniform actual event times and selected vectors, not fixed-latency contracts or full internal waveforms. / Test CPU thật kiểm tra tranh chấp và lỗi ở 2/4 hart; hình là mẫu sự kiện thực có thời gian không đều, không quy định latency. A-03–A-06 remain open / vẫn còn các gap A-03–A-06.
