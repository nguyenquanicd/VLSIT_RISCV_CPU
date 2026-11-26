# Review và phản biện thiết kế VLSIT RISC-V Dual/Quad CPU Cluster

> **Cập nhật 2026-11-16:** tài liệu này mô tả cây RTL ngày 2026-11-09. Trạng thái hiện tại của các phát hiện (CC-01, CC-02, CC-03 đã đóng; RB-01 còn) và các phát hiện mới nằm ở [VLSIT_RISCV_CPU_Review_2026-11-16.md](VLSIT_RISCV_CPU_Review_2026-11-16.md).

| Mục | Nội dung |
|---|---|
| Ngày review | 2026-11-09 |
| Đối tượng | Spec `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md` (v0.18), CSR workbook, RTL mới trong `rtl/common/vlsit/`, bản sao CVA6 trong `rtl/common/modified/` |
| Không thuộc phạm vi | Mã upstream trong `rtl/common/third_party` (chỉ đọc cấu hình CVA6 và vài điểm để đối chiếu) |
| Câu hỏi | Hiệu năng và throughput; hỗ trợ dual/quad core cho hệ thống đòi hỏi cao; quản lý cache; debug; cơ chế low-power; đề xuất cải tiến; review RTL chuyên sâu theo module (Phụ lục B) |
| Ngôn ngữ | Tiếng Việt, giữ nguyên thuật ngữ kỹ thuật tiếng Anh |

## 0. Kết luận ngắn

| Câu hỏi | Kết luận | Căn cứ chính |
|---|---|---|
| Đã high performance chưa? | **Chưa**, và cấu hình đã chọn không thuộc lớp high-performance. | CVA6 in-order single-issue; line 16 B; một cổng AXI 64-bit; đường miss dài; spec không có mục tiêu hiệu năng (PERF-001 "no target") |
| Hỗ trợ dual/quad tốt chưa? | **Chưa.** Tham số hóa 2/4 hart có, nhưng thiếu lập luận tiến triển (deadlock/livelock), không có timeout, atomics chưa rõ, DMA không coherent. | Mục 4 |
| Quản lý cache có lỗ hổng không? | **Có.** Một lỗi chặn đã mô phỏng (deadlock directory), cộng nhiều lỗ hổng về hợp đồng giao diện, kích thước directory, ECC. | Mục 5 |
| Debug có lỗ hổng không? | **Có.** Chỉ có `debug_req` và `debug_mode`; thiếu reset từng hart, halt group, trạng thái CCU, trace. | Mục 6 |
| Low-power đã được review? | **Spec gần như không có cơ chế low-power.** Các ý của tài liệu phân tích (core parking, wake-on-probe, reset một core) không được đưa vào HDS. | Mục 7 |

**Review RTL chuyên sâu (Phụ lục B) tìm thêm một lỗi chặn mới, đã mô phỏng:** bridge AXI4-Lite sang RegBus của LLC vẫn chuyển lệnh ghi xuống LLC dù đã trả SLVERR cho thanh ghi bị cấm, kể cả `CFG_SPM_LOW`, và trả hai B response cho một lệnh ghi (RB-01). Toàn bộ RTL mới chưa có testbench hay assertion nào; chỉ có lint và rule check, cả hai đều đạt nhưng không bắt được các lỗi chức năng này (TB-01).

Mức độ trưởng thành: RTL mới chỉ gồm các khối rời. Chưa có CCU/fabric, tile coherence adapter, CMO controller, wrapper LLC, top cluster; HPDcache chưa được sửa để có probe port. Mọi nhận xét về tích hợp trong tài liệu này là nhận xét về spec và hợp đồng giao diện, không phải kết quả mô phỏng cluster.

## 1. Phương pháp và mức bằng chứng

Mỗi phát hiện mang một nhãn bằng chứng:

| Nhãn | Ý nghĩa |
|---|---|
| **V** | Đã chạy mô phỏng (Verilator) và quan sát được hành vi |
| **C** | Suy ra từ đọc code RTL, chưa mô phỏng |
| **S** | Suy ra từ đọc spec/workbook |
| **E** | Ước tính của người review, kèm công thức |
| **R** | Từ tìm kiếm web (nguồn ở mục 11; nhiều nguồn là bài viết/blog, cần kiểm lại với tài liệu gốc trước khi dựa vào) |

Đã làm lại ở lượt review chuyên sâu: chạy rule check (`vlsit_rtl_check.py`: 0 ERROR, 1 WARN HIE-02 của CSR sinh ra, PASS) và Verilator `-Wall` cho 6 khối (0 cảnh báo, riêng bridge LLC có 2 cảnh báo `PROT` không dùng). Các bản tái hiện nằm trong `doc/review/repro/` (xem `repro/README.md`).

Chưa làm: đọc toàn bộ `third_party`; chạy mô phỏng cluster (không có top); đo PPA (không có library).

Mức độ nghiêm trọng: **Blocker** (sai chức năng hoặc deadlock), **High** (rủi ro lớn về đúng đắn hoặc hiệu năng), **Medium**, **Low**.

## 2. Trạng thái thực tế

| Thành phần | Trạng thái | Ghi chú |
|---|---|---|
| PMU (event select, counter bank, snapshot, IRQ) | Có RTL | Lint đạt theo README |
| AXI4-Lite decode, bridge AXI4-Lite sang RegBus | Có RTL | |
| Debug router | Có RTL, chỉ là dây nối | `rtl/common/vlsit/debug/m_vlsit_riscv_debug_router.sv` |
| Coherence transaction table | Có RTL | Chưa tích hợp |
| Sharer directory (4 bank × 8 way) | Có RTL, dạng mảng flop | Có lỗi CC-01 |
| Bank arbiter, probe scheduler | Có RTL | Hợp đồng giao diện chưa đầy đủ (CC-03) |
| CCU / coherence fabric | **Chưa có** | |
| Tile coherence adapter, CMO controller, device classifier | **Chưa có** | |
| HPDcache có probe port và MESI | **Chưa có** | `rtl/common/modified` chỉ có 4 file CVA6 |
| CBO/FENCE.I trap path trong commit của CVA6 | **Chưa có** | Chỉ có spec (DEP-021) |
| Wrapper LLC, AXI top | **Chưa có** | |
| Mô phỏng cluster, synthesis, STA, PPA | **Chưa có** | |

## 3. Hiệu năng và throughput

### 3.1 Core: CVA6 in-order, single-issue (PF-01, High, S)

Cấu hình trong `rtl/common/modified/cva6/core/include/cv64a6_imafdc_sv39_hpdcache_wb_config_pkg.sv`:

| Tham số | Giá trị | Nhận xét |
|---|---:|---|
| `SuperscalarEn` | 0 | Single-issue. Spec cũng nói `NrCommitPorts=2` không phải dual-issue |
| `NrScoreboardEntries` | 8 | Cửa sổ lệnh nhỏ |
| `BTBEntries` / `BHTEntries` | 32 / 128 | Dự đoán nhánh yếu cho code giao thức và lọc gói |
| `RASDepth` | 2 | Gọi hàm lồng nhau sâu sẽ miss |
| I-cache | 16 KiB, 4-way | |
| D-cache | 32 KiB, 8-way, line 128 bit | |

Bài báo CVA6S+ (nguồn [R1]) báo cáo cho cấu hình RV32 trên GF22: CVA6 2,83 CoreMark/MHz, CVA6S 3,41, CVA6S+ 3,69; với HPDcache CVA6 đạt khoảng 1090 MHz; CVA6S+ tăng IPC khoảng 43,5% (Embench) với phí diện tích khoảng 9,3%. Một nghiên cứu khác báo cáo +34,4% IPC. Đây là số cho RV32; cấu hình RV64 của cluster này không có số tương đương. Nghĩa là: đổi sang CVA6S+ là đường nâng cấp rẻ nhất về diện tích, còn nếu yêu cầu thật sự là OoO thì phải chọn core khác (tài liệu `RISC_V_Core_Selection_Dual_Quad_Cluster_Report.md` đã liệt kê XiangShan, BOOM, OpenC910).

### 3.2 Line 16 byte ở mọi cấp (PF-02, High, S, E)

L1, LLC và directory đều dùng line 16 B (hai beat 64-bit). Hệ quả:

| Ảnh hưởng | Giải thích |
|---|---|
| Số giao dịch coherence | Streaming 64 B cần 4 giao dịch qua directory, bảng transaction và LLC thay vì 1 |
| Burst AXI | Burst 2 beat khó dùng hiệu quả với DRAM |
| Chi phí metadata directory | Mỗi entry khoảng 51 bit (tag 42 + holders 4 + owner 2 + state 2 + valid 1) cho 128 bit dữ liệu được theo dõi (E) |
| Tag LLC | 16.384 line, mỗi line ít nhất khoảng 40 bit tag cộng valid/dirty: khoảng 80 đến 100 KiB tag cho 256 KiB dữ liệu (E) |
| Năng lượng | Nhiều lần truy cập tag/directory hơn trên mỗi byte di chuyển |
| CBO | Một gói 1500 B cần khoảng 94 lệnh CBO (1500/16), mỗi lệnh là một giao dịch CCU cộng clean LLC |

Line 64 B là chuẩn của hầu hết cluster ứng dụng. HPDcache hỗ trợ line rộng hơn (tham số tĩnh), nên đây là thay đổi cấu hình chứ không phải thiết kế lại.

### 3.3 Băng thông bộ nhớ (PF-03, High, S, E)

Spec cố định một cổng AXI memory 64-bit và một cổng MMIO 64-bit. Chính report chọn core của repo (`RISC_V_Core_Selection_Dual_Quad_Cluster_Report.md`, mục băng thông) tính: 4 core mỗi core cần 2 GB/s payload với hiệu suất truyền 70% thì cần khoảng 11,43 GB/s raw, và kết luận bus 128-bit ở 500 MHz (8 GB/s đỉnh lý thuyết) không đáp ứng. Cổng 64-bit đã chọn có đỉnh lý thuyết bằng một nửa ở cùng tần số (4 GB/s ở 500 MHz, 8 GB/s ở 1 GHz). Spec chưa có bất kỳ tính toán băng thông nào để biện minh cho độ rộng này.

### 3.4 Đường miss dài (PF-04, High, S, C, E)

Theo §10.2.1 và §5.3, một miss đi qua các bước nối tiếp:

| Bước | Có holder | Không có holder |
|---|---|---|
| Cấp transaction slot, khóa line | Có | Có |
| Lookup directory (kết quả được đăng ký) | Có | Có |
| PREPARE tới từng holder; owner M phải writeback đủ 16 B và chờ B response | Có | Bỏ qua (không probe) |
| COMMIT tới từng holder, chờ mọi ACK | Có | Bỏ qua |
| Cập nhật directory, cấp quyền | Có | Có |
| Requester refill từ LLC (miss LLC thì ra AXI) | Có | Có |

Đo trên mô phỏng từng khối (`repro/txn_probe_rate`, cache lý tưởng phản hồi sau 1 chu kỳ): một pha PREPARE hoặc COMMIT tới 3 hart song song mất 4 chu kỳ từ lúc bắt đầu pha đến `phase_done`. Một transaction có holder có hai pha như vậy (khoảng 8 chu kỳ), cộng cấp slot, lookup và cập nhật directory (ước tính vài chu kỳ), cộng thời gian phục vụ probe thật của cache (writeback của owner M nằm trong pha PREPARE) và refill. Số đo này chỉ là cận dưới của phần điều khiển, vì cache thật chậm hơn mô hình lý tưởng. Spec đã đúng khi bỏ pha probe nếu không có holder, nhưng vẫn nối tiếp lookup, cập nhật, cấp quyền rồi mới refill.

### 3.5 Probe pipeline nối tiếp theo từng hart (PF-05, High, C)

`m_vlsit_riscv_probe_scheduler.sv` chỉ cho một probe đang xử lý trên mỗi hart (`reg_req_valid`, `reg_probe_active`, `reg_ack_valid` phải cùng rảnh mới chọn probe tiếp theo). Hệ quả:

| Hệ quả | Giải thích |
|---|---|
| Tối thiểu 5 chu kỳ mỗi probe mỗi hart | Đo: 4 probe PREPARE liên tiếp tới một hart (cache lý tưởng) hoàn tất sau 21 chu kỳ, tức 5 chu kỳ mỗi probe (V, `repro/txn_probe_rate`) |
| Head-of-line blocking | Owner đang writeback M-line (chờ B response của LLC/AXI) không phục vụ được probe khác của hart đó, dù thuộc line khác |
| Một ACK lane mỗi hart | Bảng transaction nhận tối đa một ACK mỗi hart mỗi chu kỳ |
| 8 slot cho 4 hart | Chỉ 2 transaction mỗi hart nếu phân bổ đều |

### 3.6 Directory quá nhỏ và không báo clean eviction (PF-06 / CC-04, High, S, E)

| Sự kiện | Số liệu |
|---|---|
| Entry directory (4 hart) | 8192 (4 bank × 256 set × 8 way) |
| Tổng line L1D của 4 hart | 4 × 32 KiB / 16 B = 8192 |
| Tỷ lệ phủ | 1:1 (nghiên cứu về sparse directory/snoop filter nói chung cần over-provisioning, nguồn [R2]) |
| Associativity directory | 8 |
| Tổng associativity L1D của 4 hart | 4 × 8 = 32 |

Vì bank = PA[5:4] và set = PA[13:6] (4 hart), mọi line cùng một set directory cũng nằm trong cùng một set L1D của mỗi hart (cùng PA[13:4]). Trong trường hợp xấu, 32 line L1D (4 hart × 8 way) tranh nhau 8 way của directory. Khi directory thay entry, mọi holder được ghi nhận phải bị invalidate (REQ-MEM-010) kể cả line còn sống trong L1, kể cả dữ liệu private không chia sẻ. Một patent trong kết quả tìm kiếm khẳng định back-invalidation gây khoảng 20% miss (đây là tuyên bố của patent, chưa kiểm chứng độc lập, nguồn [R2]).

Thêm nữa, spec chỉ nêu việc xóa holder bit khi Dirty M eviction hoặc clean-invalidate tường minh (§10.2.1). Nếu clean eviction (S/E) là im lặng, directory sẽ đầy entry "ma"; mỗi miss mới sẽ kèm thay victim và probe tới holder không còn giữ line.

**Đề xuất:** directory phủ tối thiểu 2× tổng L1D, associativity không thấp hơn 16; hoặc thêm eviction notification cho clean line; hoặc dùng cấu trúc chịu conflict tốt hơn (cuckoo directory) [R2]; cho cấu hình 2 hart, cân nhắc probe broadcast kiểu Culsans để bỏ hẳn directory.

### 3.7 Directory ở dạng mảng flop (PF-07 / CC-05, High, C, E)

`m_vlsit_riscv_sharer_directory.sv` khai báo `reg_dir_tag`, `reg_dir_holders`, `reg_dir_owner`, `reg_dir_state`, `reg_dir_valid` dưới dạng mảng flop, kèm so sánh 8-way tổ hợp. Với 4 hart: 8192 entry × khoảng 51 bit khoảng 418 kbit, cộng 1024 set × 7 bit PLRU (E). Nếu tổng hợp thành flop thì diện tích và reset fan-out không thực tế; phải chuyển sang SRAM macro, và khi đó cấu trúc đổi: độ trễ đọc 1 chu kỳ trở lên, không có reset (cần FSM khởi tạo valid sau reset), cần ECC/parity. Spec chưa có trạng thái "directory initializing" (chỉ có chờ BIST của LLC) và DEP-013 vẫn mở.

### 3.8 Reservation khóa cả set (PF-08 / CC-06, Medium, C, S)

Một lookup miss đặt `reg_dir_resv_valid` cho cả set cho đến khi update hoặc cancel cùng tag. Trong thời gian đó mọi lookup cùng set bị chặn, kể cả hit vào line khác. Spec ghi rõ hành vi này (§14.4.3). Thời gian giữ reservation bao gồm toàn bộ PREPARE, writeback của owner, COMMIT, nên với miss có holder M, set bị khóa hàng chục đến hàng trăm chu kỳ. Đây còn là điều kiện gây deadlock CC-01.

## 4. Hỗ trợ dual/quad core

### 4.1 Khả năng mở rộng 2 so với 4 hart

| Tài nguyên | Dual | Quad | Nhận xét |
|---|---|---|---|
| Directory | 4096 entry, 128 set/bank | 8192 entry, 256 set/bank | Tỷ lệ phủ L1D không đổi (1:1), không cải thiện khi tăng hart |
| Transaction slot | 8 | 8 | Quad có 2 slot/hart |
| ACK lane / probe lane | 1 mỗi hart | 1 mỗi hart | Chấp nhận được về mặt cấu trúc |
| Cổng bộ nhớ | 1 × 64-bit | 1 × 64-bit | Quad chia chung một cổng |
| LLC | 256 KiB, 4-way | 256 KiB, 4-way | Chia chung cho 4 hart |
| Cổng MMIO | 1 | 1 | Mọi truy cập thiết bị của 4 hart chung một đường |

### 4.2 Atomics (SYS-01, High, S)

Spec mô tả LR/SC và AMO ở hai chỗ có vẻ không nhất quán:

| Nơi | Nội dung |
|---|---|
| §10.2.1 | "AMO hit in S": giữ khóa line cùng trong lúc cập nhật AMO trong L1 (đường AMO cacheable, cần trạng thái M) |
| DEC-023, REQ-IF-009 | AWATOP của LLC phải ra ngoài; AMO/LR/SC dùng đường "uncacheable" của A-extension |

Spec chưa nói: khi nào AMO đi đường cacheable, khi nào đi đường LLC/ATOP; reservation của LR bị hủy thế nào khi nhận probe COMMIT(I) hoặc khi line bị thay; SC có đảm bảo tiến triển (không livelock) dưới tranh chấp bốn hart không; hiệu năng spinlock (Linux SMP dùng rất nhiều) nếu mỗi AMO phải ra tới LLC.

### 4.3 Không có lập luận chống deadlock, livelock, starvation (SYS-02, High, S)

Từ khóa deadlock, livelock, starvation, forward progress không xuất hiện trong spec. Hợp đồng "không có timeout cho PREPARE/COMMIT/ABORT, chỉ reset cluster mới hồi phục" (REQ-MEM-013, DEC-018) biến mọi lỗi thiết kế hoặc mọi hart treo thành treo vĩnh viễn một line. Điều này đặc biệt rủi ro vì cluster chỉ có một reset chung (mục 6.2 và 7).

### 4.4 DMA và agent ngoài không coherent (SYS-03, High, S, E)

Profile hiện tại chỉ có AXI, không snoop agent ngoài; DMA phải dùng CBO bằng phần mềm. Với line 16 B, một gói 1500 B tốn khoảng 94 lệnh CBO, mỗi lệnh qua CCU, LLC và có thể ra DRAM. Đây là nút cổ chai lớn cho ứng dụng gateway đã nêu trong spec. ACE-Lite (một chiều) cho phép master DMA không có cache mà vẫn thấy dữ liệu mới nhất trong cache CPU và làm mất hiệu lực bản sao cũ, nên có thể bỏ phần lớn phần mềm duy trì cache [R6]. ACE đầy đủ đã được hoãn; ACE-Lite hoặc cổng I/O coherent là phương án nhỏ hơn nhiều.

## 5. Quản lý cache: các phát hiện

### CC-01 (Blocker, V): deadlock trong sharer directory

**Hiện tượng.** Một transaction đã lookup hit (T1) chưa kịp update; transaction khác (T2) lookup miss cùng set và đặt reservation. Update của T1 bị `w_update_set_busy` chặn (tag khác với reservation). Khối `casez ({i_update_valid, i_cancel_valid})` ưu tiên update, nên khi `i_update_valid` còn cao thì cancel và lookup cũng không ready. T2 chỉ nhả reservation được qua update hoặc cancel của chính nó trên cùng cổng bank, nên cả hai chờ nhau.

**Tái hiện (mô phỏng Verilator):**

| Bước | Hành động | Kết quả |
|---|---|---|
| 1 | Cài line A (set 5, bank 0, way 0) bằng một update | OK |
| 2 | T1 lookup A | hit=1, không có reservation |
| 3 | T2 lookup B (cùng set, khác tag) | hit=0, reservation đặt cho set 5 |
| 4 | T1 update A | `update_ready=0` |
| 5 | T2 cancel khi T1 update còn giữ valid | `cancel_ready=0 update_ready=0 lookup_ready=0` |
| 6 | Chờ 20 chu kỳ | vẫn `update_ready=0 cancel_ready=0` (DEADLOCK) |

Chạy lại bằng `sh doc/review/repro/dir_deadlock/run.sh` (cần Verilator và g++ như `APB-DEC-Generator/tests/run_cov.sh`; tham số đường dẫn qua biến môi trường, xem `repro/README.md`).

**Điều kiện.** Giả định CCU giữ `i_update_valid` ổn định đến khi có ready (REQ-IF-005 yêu cầu payload ổn định khi valid cao và ready thấp). Nếu CCU có thể thu hồi valid thì không deadlock ở mức giao diện, nhưng như vậy vi phạm quy tắc valid/ready. Tình huống xảy ra với lưu lượng thông thường: hai hart đụng hai line khác nhau trong cùng một set directory, một hit, một miss.

**Sửa gợi ý (chọn một):**
- Reservation theo way thay vì theo set; update của một hit (way khác victim) không bị chặn.
- Cho update của transaction đã có way hợp lệ đi qua dù set bị đặt reservation bởi tag khác.
- Tách cổng cancel/update riêng, hoặc cho cancel ưu tiên hơn update đang bị chặn.
- Mỗi transaction slot có cổng update riêng tới bank (tốn mux).
Thêm assertion: không bao giờ có `i_update_valid` giữ hơn N chu kỳ mà không có ready.

### CC-02 (High, V): ACK hoặc probe response không khớp sẽ không bao giờ được rút

`m_vlsit_riscv_coh_txn_table.sv` chỉ đặt `o_ack_ready[hart]` khi tag, phase, hart đều khớp với context đang chờ. `m_vlsit_riscv_probe_scheduler.sv` chỉ đặt `o_probe_rsp_ready` khi tag, line, phase khớp với probe đang chờ. Một ACK/response lạ (ví dụ ACK trùng, mà spec cho phép vì "COMMIT lặp lại cùng tag là idempotent") sẽ ở đầu kênh và chặn mọi ACK sau của hart đó. Spec nói response sai tag "không được cập nhật trạng thái" nhưng không nói nó được xử lý thế nào. Đã mô phỏng (`repro/txn_probe_rate`): một ACK trùng tag và phase sau khi pha đã xong giữ `o_ack_ready=0` sau 10 chu kỳ, không bao giờ được nhận.

**Sửa gợi ý:** luôn nhận ACK, gạt bỏ nếu không khớp, đồng thời đặt cờ lỗi dính (sticky error) hiển thị qua CSR và một PMU event; thêm assertion.

### CC-03 (High, V/C): lệch hợp đồng giữa các khối đã viết

| Khối | Vấn đề |
|---|---|
| `probe_scheduler` | Có input `i_ctx_target_state` nhưng `txn_table` không có trường nào cung cấp (`o_ctx_kind` có, target state thì không) |
| `bank_arb` | Chỉ loại trừ slot vừa được nhận trong đúng chu kỳ nhận grant. **Đã mô phỏng (`repro/bank_arb_dup_grant`):** nếu bên dùng hạ `i_req_valid[slot]` đúng tại cạnh nhận thì một request được grant 1 lần; nếu hạ trễ một chu kỳ thì cùng một request được grant 2 lần. Hợp đồng này chưa được ghi trong spec |
| `txn_table` | `reg_ctx_owner_wback_done` bị xóa khi bắt đầu pha mới, nên trạng thái writeback của PREPARE không còn trong COMMIT trừ khi bên dùng đã chốt nó |
| `bank_arb` | Grant đã đăng ký không được kiểm lại `i_req_valid` / `i_req_bank` khi còn giữ chờ ready |

### CC-04, CC-05, CC-06
Xem mục 3.6, 3.7, 3.8.

### CC-07 (High, S): FENCE.I rất đắt, I-cache không coherent

`DcacheFlushOnFenceI=1` buộc mỗi FENCE.I quét cả D-cache 32 KiB (2048 line), mỗi line M là một giao dịch CCU ghi về LLC. Linux dùng FENCE.I thường xuyên (exec, mmap executable, nạp module, và FENCE.I từ xa qua IPI cho từng hart), nên chi phí tỷ lệ với kích thước D-cache chứ không với lượng code bị sửa. Đề xuất: giữ I-cache nằm ngoài miền coherence như hiện tại nhưng bổ sung bộ lọc "dirty-line count" (nếu D-cache không có line M thì FENCE.I chỉ cần invalidate I-cache), hoặc FENCE.I theo dải nếu phần mềm hỗ trợ; xét I-cache theo dõi qua probe.

### CC-08 (Medium, S): CBO và DMA

CBO chỉ có ở mức một line (16 B). Thiếu thao tác theo dải hoặc "flush all" nhanh cho bộ đệm DMA lớn (xem 4.4). Zicboz (cbo.zero) và Zicbop (prefetch) là các extension khác của CBO đã được ratify (theo [R7]; trạng thái ratify cần kiểm lại với tài liệu RISC-V). CVA6 cấu hình ở đây chỉ bật Zicbom (`RVZiCbom=1`); `cbo.zero` giúp Linux xóa trang nhanh mà không phải đọc line về (tránh một lần refill mỗi line).

### CC-09 (Medium, S): ECC và parity

`DcacheEccEnable=0`, `DcacheEccScrubberEnable=0`, nhưng Event_Map vẫn định nghĩa các event lỗi ECC của HPDcache (0x0102 đến 0x0106), tức PMU đếm những thứ không bao giờ xảy ra. LLC và directory chưa có ECC; DEP-013 mở. Với SRAM tổng cộng vài trăm KiB (L1 4×(32+16) KiB, LLC 256 KiB, directory khoảng 52 KB) không có bảo vệ là lỗ hổng độ tin cậy, đặc biệt cho ứng dụng công nghiệp mà spec tự đề ra.

### CC-10 (Low, C): PMU và CSR

| Điểm | Chi tiết |
|---|---|
| Ghi đè W1C | `m_vlsit_pmu_irq.sv` nạp lại `irq_raw` bằng giá trị cũ OR bit mới khi có tràn; CSR sinh ra đặt phần cứng ưu tiên (`w_irq_raw_overflow_nxt`: "hardware update wins", đã đọc code). Vậy một lệnh W1C trùng chu kỳ với bất kỳ tràn counter nào bị mất hoàn toàn và ngắt vẫn treo. Chưa mô phỏng |
| Không có xóa counter | `pmu_ctrl` chỉ có `snapshot_req`; không có xóa hoặc đóng băng counter; phần mềm phải đọc hiệu |
| Không có trạng thái CCU | CSR workbook chỉ có PMU; không có thanh ghi về độ đầy bảng transaction, lỗi ACK, B-error, tuổi transaction (xem mục 6) |

## 6. Debug

### 6.1 Hiện trạng

Giao diện debug của cluster chỉ có `i_hart_debug_req[3:0]` và `o_hart_debug_mode[3:0]`; `m_vlsit_riscv_debug_router` chỉ nối dây. Debug Module và DTM nằm ngoài.

### 6.2 So với Debug Spec (REF-007 của chính dự án)

| Tính năng (Debug Spec) | Có trong cluster? | Hệ quả |
|---|---|---|
| `hartreset` (reset hart đã chọn) | Không (chỉ có reset cluster) | Hart treo, ví dụ kẹt trong CBO/FENCE.I trap, chỉ hồi phục bằng reset cả cluster, mất mọi dữ liệu dirty |
| `ndmreset` và `resethaltreq` (dừng ngay sau reset) | Không | Không debug được đoạn boot sớm của từng hart |
| Trạng thái `havereset`, `unavail` | Không | Debugger không phân biệt được hart đang reset hay treo |
| Halt group, resume group, external trigger (v1.0, tùy chọn) [R5] | Không | Dừng đồng bộ cả 4 hart khi debug SMP phải dừng từng hart một, trạng thái bộ nhớ bị lệch trong lúc dừng |
| Trace | Không xuất `rvfi` hay trace | Không có lịch sử thực thi, khó tái hiện lỗi race coherence |
| Trạng thái CCU | Không có CSR | Thiết kế chờ vô hạn (không timeout) nhưng không thể nhìn thấy transaction nào đang treo, line nào, pha nào |

### 6.3 Tương tác debug với coherence (DB-02, High, S)

| Vấn đề | Giải thích |
|---|---|
| Hart halt phải còn trả lời probe | Spec không nói hart ở debug mode còn phục vụ probe không. Nếu không, mọi line mà hart đó giữ sẽ khóa vĩnh viễn (không timeout) |
| System Bus Access (SBA) của DM | Đi qua fabric của SoC, không thấy dữ liệu dirty trong L1 hoặc LLC. Debugger đọc sai, ghi không làm mất hiệu lực bản sao trong cache. Cần quy định chính sách (CBO tự động trước/sau SBA hoặc SBA qua một cổng coherent) |
| Debug wake | Hart ở WFI hoặc bị clock-gate phải được đánh thức bởi `i_hart_debug_req` (cần xác nhận với CVA6 và AON logic của SoC) |

### 6.4 Đề xuất debug

| ID | Đề xuất | Chi phí |
|---|---|---|
| DB-A | Thêm `i_hart_reset_n[3:0]` riêng, kèm quy trình "rời miền coherence" (xem 7.3) | Trung bình |
| DB-B | Thêm `i_hart_resethaltreq`, `o_hart_havereset` | Thấp |
| DB-C | Thêm halt/resume group: `o_hart_halted`, `i_hart_halt_trigger` qua một crossbar nhỏ | Thấp |
| DB-D | CSR chẩn đoán CCU: số slot đang dùng, tuổi lớn nhất, tag/line/pha của transaction cũ nhất, cờ lỗi dính (ACK lạ, B-error, tag không khớp) | Thấp |
| DB-E | Watchdog theo transaction (cấu hình được), có đường báo lỗi thay vì chờ vô hạn | Trung bình |
| DB-F | Xuất tín hiệu trace (`rvfi` hoặc nhánh/đã retire) ra cổng | Trung bình |
| DB-G | PMU: xóa/đóng băng counter, đóng băng khi halt | Thấp |
| DB-H | Quy định hart halt vẫn trả lời probe; SBA phải coherent hoặc có quy trình CBO | Thấp (spec) |

## 7. Review cơ chế low-power

### 7.1 Spec nói gì

| Nơi | Nội dung |
|---|---|
| §1.1 (Excluded) | Không có power gating, retention, DVFS |
| §7.4 | Không có power gating, retention, isolation, DVFS trong v1. Có thể dùng clock gating sau khi có methodology. "WFI/power-state behavior must be checked against the pinned CVA6 integration." Power intent do SoC sở hữu |
| §7.1 | Một clock cluster; gating chỉ bằng ICG do SoC duyệt; không nằm trong CSR chức năng |
| §13, REQ-PD-001 | Không tuyên bố giới hạn công suất cho đến khi có library, PVT, SDC, workload |
| DEC-019 | Mặc định 4 hart (hướng hiệu năng); chọn 2 hart khi công suất là ràng buộc mạnh hơn |

### 7.2 Phản biện

Tài liệu phân tích của chính repo (`RISC_V_Quad_Core_High_Performance_Low_Power_Analysis.md`, mục 10 và checklist) đưa ra các hạng mục low-power: core parking với quy trình quiesce, wake-on-probe, reset một core, DVFS miền dùng chung trước, đánh giá năng lượng trên mỗi tác vụ. **Không hạng mục nào trong số đó được chuyển thành yêu cầu hoặc cổng tín hiệu trong HDS.** Kết quả: low-power là "trách nhiệm của SoC" nhưng cluster không đưa ra cổng nào để SoC thực hiện được.

| ID | Mức | Bằng chứng | Phát hiện |
|---|---|---|---|
| LP-01 | High | S, C | **Không có tín hiệu trạng thái ngủ ra ngoài.** CVA6 có `wfi_q` (`csr_regfile.sv`) và `halt_csr_o` nội bộ nhưng `cva6.sv` không xuất, và cluster không có `o_hart_wfi`, `o_hart_idle`, `o_cluster_idle`. SoC không biết khi nào gate clock hay hạ tần số |
| LP-02 | High | S, C | **WFI chỉ dừng pipeline, không tắt clock.** Cây clock, cache và các mảng vẫn chạy; tiết kiệm chỉ ở phần chuyển mạch của pipeline. Spec để "kiểm tra sau" |
| LP-03 | High | S | **Không có quy trình hart rời/vào miền coherence.** Linux CPU hotplug (SBI HSM `hart_stop`/`hart_suspend`) và mọi kiểu power-down cần: flush L1D, xóa holder bit của hart trong directory, ngừng nhận probe. Directory không có thao tác "xóa mọi holder của hart X"; không có `i_hart_coh_enable`. Nếu sau này thêm power gating, thiết kế coherence phải đổi |
| LP-04 | High | S | **Không có chế độ ngủ cho SRAM.** L1, LLC, directory không có light-sleep/retention/shutdown. DSU của Arm cho thấy đây là cơ chế chính: tắt một phần hoặc phần lớn L3 và snoop filter khi không cần [R3] |
| LP-05 | Medium | S | **Clock gating không được chỉ định.** Chưa có chính sách ICG cho directory theo bank, PMU, bảng transaction, từng tile. Không có yêu cầu `test_en` cho ICG (chỉ §16 nhắc) |
| LP-06 | Medium | S | **Wake-on-probe/wake-on-interrupt/wake-on-debug chưa định nghĩa.** Nếu SoC gate clock một hart (hoặc cache của nó) thì probe không được trả lời và line bị khóa vĩnh viễn (không timeout). Phải quy định: hoặc cache luôn được cấp clock, hoặc có tín hiệu wake từ CCU |
| LP-07 | Medium | S | **Không có tín hiệu DVFS/ranh giới clock.** Một clock chung cho AXI, AXI-Lite và hart; DVFS buộc đổi tần số cả cluster và mọi bridge CDC ngoài. Không có hợp đồng xử lý thay đổi tần số khi còn giao dịch |
| LP-08 | Medium | C, E | **Mẫu truy cập tiêu tốn năng lượng.** Line 16 B làm nhiều lần truy cập tag, directory, LLC hơn trên mỗi byte; lookup directory đọc cả 8 way song song; probe scheduler quét tổ hợp mọi slot mỗi chu kỳ. Chưa có biện pháp (đọc tuần tự, dự đoán way) |
| LP-09 | Medium | S | **Không có UPF/power-intent cho ranh giới cluster.** Chưa nêu supply net, isolation, lớp always-on (ngắt, debug req), thứ tự reset khi bật nguồn |
| LP-10 | Low | C | **PMU:** counter dùng enable (tốt) nhưng không có clock gating; 16 counter 64-bit cộng snapshot luôn có clock |
| LP-11 | Info | S | **Điểm tốt:** dùng directory thay vì broadcast probe giúp giảm lưu lượng và năng lượng snoop khi số hart tăng; DEC-019 cho phép build 2 hart |

### 7.3 Đề xuất low-power

**A. Cổng tín hiệu tối thiểu cho SoC power controller**

| Cổng | Hướng | Ý nghĩa |
|---|---|---|
| `o_hart_wfi[3:0]` | ra | Hart đang ở WFI |
| `o_hart_quiet[3:0]` | ra | Hart không còn giao dịch AXI hoặc probe đang chờ (an toàn để gate clock lõi) |
| `o_cluster_idle` | ra | Cả bốn hart `quiet`, bảng transaction rỗng, LLC rảnh |
| `i_hart_clk_en[3:0]` hoặc ICG nội bộ do `i_hart_gate_req[3:0]` điều khiển | vào | Gate clock lõi, giữ clock cho phần cache phục vụ probe |
| `i_hart_coh_enable[3:0]` | vào | Hart tham gia miền coherence; bằng 0 thì directory không probe hart đó |

**B. Quy trình hart rời miền coherence (park)**

| Bước | Hành động | Điều kiện hoàn tất |
|---|---|---|
| 1 | Phần mềm dừng lập lịch cho hart, thực thi quét D-cache (flush) | Mọi line M đã ghi về LLC |
| 2 | CCU nhận lệnh "rời" cho hart X; directory xóa bit holder của X ở mọi entry (quét hoặc theo từng probe invalidate) | Directory không còn tham chiếu X |
| 3 | Hạ `i_hart_coh_enable[X]`; từ đây không probe X | Bảng transaction không còn ACK chờ X |
| 4 | SoC có thể gate clock hoặc tắt nguồn X | `o_hart_quiet[X]=1` |
| 5 | Vào lại: invalidate toàn bộ L1D/L1I, đặt lại `i_hart_coh_enable[X]` | |

**C. Chế độ SRAM:** thêm ngõ `sleep_req`/`sleep_ack` cho LLC, directory và L1 (light sleep trước, retention nếu macro hỗ trợ). Cần bước flush trước khi retention-off với directory (mất trạng thái holder). Có thể tham khảo mô hình tắt từng phần L3 theo tải của DSU [R3].

**D. Clock gating:** ICG theo bank directory, theo tile, và cho PMU; mọi ICG có chân `test_en` (tuân thủ §16).

**E. DVFS:** nêu rõ hợp đồng đổi tần số (quiesce, `o_cluster_idle` làm điều kiện), vì mọi ngoại vi đồng bộ cùng clock.

**F. Xác minh low-power:** mô phỏng có UPF (isolation, retention, chuỗi bật/tắt), kịch bản hart park/resume khi các hart khác vẫn truy cập cùng line, wake do probe, wake do debug request; đo năng lượng trên mỗi tác vụ như tài liệu phân tích đề ra.

## 8. Nghiên cứu: kỹ thuật tăng hiệu năng cho cluster dual/quad

Bảng dưới liệt kê các kỹ thuật, mức áp dụng cho thiết kế này và nguồn. Các con số là từ nguồn, không phải kết quả đo của dự án này.

| Kỹ thuật | Nội dung | Áp dụng cho thiết kế này | Nguồn / bằng chứng |
|---|---|---|---|
| Nâng core lên superscalar (CVA6S+) | Dual-issue, tối ưu cache; cùng họ CVA6 | Thay core, tăng IPC khoảng 34% đến 43% (RV32), phí diện tích khoảng 6% đến 9% | [R1] |
| Cache L1 non-blocking nhiều request (HPDcache đã có) | Nhiều MSHR, nhiều request song song | Đã chọn; chi tiết MSHR và prefetcher chưa được spec hóa | [R8] |
| Prefetch (HPDcache stride prefetcher qua CSR) | Cần phần mềm cấu hình luồng truy cập | Chưa nhắc trong HDS; cân nhắc prefetcher phần cứng tự động | [R8] |
| Line 64 B | Giảm 4× số giao dịch coherence cho truy cập tuần tự | Đổi tham số HPDcache và LLC; xem 3.2 | Thực hành phổ biến, spec này hiện là 16 B |
| Cache-to-cache transfer (DCT) và memory prefetch song song (DMT) | Bỏ home node khỏi đường dữ liệu khi có thể, đọc LLC/bộ nhớ song song với snoop | Hiện tại: owner M ghi về LLC rồi requester refill từ LLC (2 chặng). Cho phép owner trả dữ liệu trực tiếp hoặc LLC đọc song song cắt latency miss | [R4] |
| MOESI hoặc MESIF (Owned/Forward) | Owned cho phép chia sẻ dữ liệu dirty mà không ghi về bộ nhớ trước; Forward chọn một sharer trả lời | Hiện chỉ có MESI nên mỗi read miss vào line M phải ghi LLC. MOESI bỏ writeback này nhưng đổi invariant (owner phải ghi về khi bị thay) | [R9] |
| Snoop filter/directory đủ phủ | Over-provision, associativity cao, cuckoo | Sửa 3.6; không dưới 1,5× tổng L1 theo ví dụ tham khảo (Intel, nguồn thứ cấp) | [R2] |
| ACE-Lite / cổng I/O coherent | DMA không cần CBO từng line | Hoãn ACE; ACE-Lite rẻ hơn nhiều | [R6] |
| Cache stashing / ACP | Thiết bị đẩy dữ liệu thẳng vào cache | Cho gateway xử lý gói, giảm miss đầu tiên | [R6] |
| LLC nhiều slice và băng thông bộ nhớ rộng hơn | DSU chia L3 thành slice, mỗi slice một phần snoop filter | LLC đơn một cổng 64-bit là điểm nghẽn; chia slice theo bit địa chỉ, cổng AXI 128 hoặc 256 bit | [R3] |
| QoS / phân vùng cache và băng thông | Hạn chế một hart làm đói các hart khác | Chưa có QoS; CBQRI là khung RISC-V (chưa xác nhận trạng thái ratify từ kết quả tìm kiếm) | cần kiểm lại với tài liệu RISC-V |
| Zicboz (`cbo.zero`) | Xóa line không cần đọc | Giảm refill khi xóa trang | [R7] |
| Pipeline hóa CCU | Nhiều probe song song mỗi hart, hàng đợi probe thật, tách writeback khỏi lane probe | Sửa 3.5 | Thiết kế nội bộ |
| Fast path cho miss không có holder | Cấp quyền E và refill song song với cập nhật directory | Hiện cập nhật rồi mới cấp quyền | Thiết kế nội bộ |
| Giảm xung đột directory | Reservation theo way, nhiều cổng update | Sửa CC-01 và 3.8 | Thiết kế nội bộ |

## 9. Backlog đề xuất theo ưu tiên

| Ưu tiên | ID | Việc cần làm | Tiêu chí hoàn tất |
|---|---|---|---|
| P0 | RB-01 | Sửa bridge LLC: thêm `& ~w_wr_addr_wr_denied` vào điều kiện chuyển sang `WR_REQ` (đã thử trên bản sao: không còn ghi xuống LLC, chỉ một B response SLVERR) | `repro/reg_bridge_denied_write` cho 0 RegBus write và 1 B với thanh ghi bị cấm |
| P0 | TB-01 | Tạo testbench và assertion cho mọi khối RTL mới (bridge, decode, directory, bảng transaction, arbiter, scheduler, PMU), đưa vào regression | Mỗi khối có test tự kiểm; script chạy được; các repro hiện có thành test đạt |
| P0 | CC-01 | Sửa deadlock directory | `repro/dir_deadlock` kết thúc với tiến triển; thêm test ngẫu nhiên nhiều transaction cùng set |
| P0 | CC-02 | Rút và đánh dấu ACK/response lạ | Không có kênh nào bị chặn bởi ACK lạ; cờ lỗi dính hiện qua CSR |
| P0 | CC-03 | Viết hợp đồng giao diện và assertion cho `txn_table`, `probe_scheduler`, `bank_arb`, directory | Bảng port khớp; SVA cho valid/ready ổn định, một ACK mỗi probe |
| P0 | SYS-01, SYS-02 | Chốt ngữ nghĩa AMO/LR/SC và lập luận không deadlock/livelock | Mục mới trong HDS; kiểm chứng formal hoặc mô hình tham chiếu |
| P0 | DB-E | Watchdog và đường lỗi thay cho "chờ vô hạn" | Spec REQ mới; test ACK mất |
| P1 | PF-02, PF-03 | Đánh giá line 64 B và độ rộng AXI 128/256-bit | Phân tích băng thông có số liệu, đối chiếu với report chọn core |
| P1 | PF-06, PF-07 | Kích thước directory, associativity, clean-eviction notification, wrapper SRAM, ECC | Mô hình hiệu năng và diện tích; spec DEP-013 đóng |
| P1 | PF-04, PF-05 | Rút ngắn đường miss (DCT/DMT, MOESI, fast path) và probe pipeline | Mô hình chu kỳ có số liệu trước và sau |
| P1 | LP-01 đến LP-06 | Cổng power cho SoC, quy trình park/resume, wake-on-probe, ICG | Mục §7.4 viết lại; test park/resume |
| P1 | DB-A đến DB-D | Reset từng hart, halt group, CSR chẩn đoán CCU | Trường CSR mới trong workbook |
| P2 | SYS-03 | ACE-Lite hoặc cổng I/O coherent cho DMA | Spec profile mới |
| P2 | CC-07, CC-08 | FENCE.I rẻ hơn; CBO theo dải; Zicboz | Đo chi phí FENCE.I |
| P2 | CC-09 | ECC/parity cho L1, LLC, directory | Cấu hình ECC trong HPDcache; test chèn lỗi |
| P2 | LP-04, LP-08 | SRAM sleep, đọc tag tuần tự | Số liệu năng lượng |
| P3 | DB-F, DB-G | Trace, PMU freeze/clear | |
| P3 | CC-10 | Sửa nạp lại `irq_raw` để giữ W1C của phần mềm (hoặc ưu tiên phần mềm cho bit đang xóa) | Test mô phỏng W1C đồng thời với tràn |

## 10. Câu hỏi cần chủ dự án quyết định

1. Mục tiêu hiệu năng cụ thể là gì (CoreMark/MHz, DMIPS, GB/s, độ trễ gói, mô tả workload)? Không có con số này thì mọi lựa chọn trong mục 3 và 8 không thể biện minh.
2. Có chấp nhận giữ CVA6 in-order, hay chuyển sang CVA6S+ hoặc core OoO?
3. Có giữ line 16 B không, hay chuyển sang 64 B?
4. Yêu cầu low-power thật sự là gì: chỉ giảm công suất động, hay cần park từng hart, retention SRAM, DVFS?
5. DMA của ứng dụng có thể dùng CBO bằng phần mềm không, hay cần cổng I/O coherent?
6. Có đồng ý thay hợp đồng "không timeout" bằng watchdog và đường lỗi không?

## 11. Nguồn tham khảo

Các nguồn dưới đây là kết quả tìm kiếm web ngày 2026-11-09; nhiều mục là bài viết hoặc patent, không phải tài liệu chuẩn. Cần kiểm lại với tài liệu gốc trước khi dùng làm căn cứ thiết kế.

- [R1] CVA6S+: A Superscalar RISC-V Core with High-Throughput Memory Architecture — <https://arxiv.org/abs/2505.03762> (PDF: <https://arxiv.org/pdf/2505.03762>); mô hình hiệu năng CVA6 superscalar: <https://arxiv.org/html/2505.24363v1>
- [R2] Snoop filter, sparse directory, back-invalidation: patent <https://patents.google.com/patent/US8015365>; luận án <https://zaguan.unizar.es/record/6812/files/TESIS-2012-003.pdf>; thảo luận Intel (nguồn thứ cấp) <https://community.intel.com/t5/Software-Tuning-Performance/Directory-Structure-in-Skylake-Server-CPUs/m-p/1605063>
- [R3] Arm DSU-110 và chế độ nguồn: <https://fuse.wikichip.org/?p=5270>; DSU-120: <https://at-web1.www.anandtech.com/show/18871/arm-unveils-armv92-mobile-architecture-cortex-x4-a720-and-a520-64bit-exclusive/5>; DynamIQ: <https://www.anandtech.com/show/11441/dynamiq-and-arms-new-cpus-cortex-a75-a55/2>
- [R4] AMBA CHI, DCT/DMT: <https://www.design-reuse.com/article/61649-harnessing-the-power-of-amba-chi-the-protocol-powering-modern-cpu-clusters/>; gem5 CHI: <https://m5sim.org/documentation/general_docs/ruby/CHI>
- [R5] RISC-V Debug Specification 1.0 (halt group, hartreset, resethaltreq): <https://docs.riscv.org/reference/debug/v1.0/debug_module.html>; crossbar cross-trigger của AMD: <https://docs.amd.com/r/en-US/pg428-mdm-v/Cross-Trigger-Programming>
- [R6] ACE-Lite, I/O coherency, ACP: <https://docs.amd.com/r/en-US/am011-versal-acap-trm/I/O-Coherency>; <https://arxiv.org/pdf/1908.01261>; <https://community.arm.com/developer/ip-products/processors/f/cortex-a-forum/46579/io-coherency-and-shareability>
- [R7] Zicboz/Zicbop/Zicbom (qua QEMU): <https://qemu.googlesource.com/qemu/+/a939c500793ae7672defe5e3dc83220576a7b202>
- [R8] HPDcache và CVA6: <https://dumas.ccsd.cnrs.fr/DSCIN/hal-04600058v1>; FetchFlare prefetcher: <https://www.recercat.cat/handle/2117/456260>
- [R9] MOESI, MESIF: <https://en.wikipedia.org/wiki/MOESI_protocol>; <https://en.wikipedia.org/wiki/MESIF_protocol>

## Phụ lục A. Tệp liên quan

| Tệp | Vai trò |
|---|---|
| `doc/review/repro/README.md` | Hướng dẫn chạy các bản tái hiện |
| `doc/review/repro/run_tb.sh` | Trình chạy Verilator dùng chung |
| `doc/review/repro/dir_deadlock/` | Tái hiện CC-01 |
| `doc/review/repro/reg_bridge_denied_write/` | Tái hiện RB-01 |
| `doc/review/repro/txn_probe_rate/` | Đo tốc độ probe, độ trễ pha, ACK trùng (PF-05, CC-02) |
| `doc/review/repro/bank_arb_dup_grant/` | Tái hiện grant lặp (CC-03) |
| `rtl/common/vlsit/coherence/m_vlsit_riscv_sharer_directory.sv` | Directory (CC-01, CC-04, CC-05, CC-06) |
| `rtl/common/vlsit/coherence/m_vlsit_riscv_coh_txn_table.sv` | Bảng transaction (CC-02, CC-03) |
| `rtl/common/vlsit/coherence/m_vlsit_riscv_probe_scheduler.sv` | Probe scheduler (PF-05, CC-02, CC-03) |
| `rtl/common/vlsit/coherence/m_vlsit_riscv_coh_bank_arb.sv` | Bank arbiter (CC-03) |
| `rtl/common/vlsit/debug/m_vlsit_riscv_debug_router.sv` | Debug router (mục 6) |
| `rtl/common/vlsit/pmu/m_vlsit_pmu_irq.sv` | PMU IRQ (CC-10) |
| `rtl/common/vlsit/control/m_vlsit_axil_reg_bridge.sv` | Bridge LLC (RB-01) |
| `rtl/common/vlsit/control/m_vlsit_riscv_axil_decode.sv` | Decode AXI4-Lite (RB-02) |
| `rtl/common/modified/cva6/core/csr_regfile.sv` | Ngắt S-mode (CV-01) |

## Phụ lục B. Review RTL chuyên sâu theo module

### B.1 Phương pháp

| Bước | Nội dung |
|---|---|
| 1 | Đọc từng dòng 12 file RTL VLSIT mới và 3 file CVA6 đã sửa (so với bản gốc bằng `diff`); đọc phần CSR sinh ra liên quan |
| 2 | Đối chiếu từng khối với yêu cầu REQ, hợp đồng giao diện trong `rtl_change_review.md` §11.3 và các khối kề nhau |
| 3 | Với mỗi nghi ngờ về hành vi, viết testbench nhỏ cho khối đó và chạy Verilator (4 bản tái hiện trong `repro/`) |
| 4 | Chạy lại rule check và lint `-Wall` để kiểm tra các khẳng định trong README |

### B.2 Kết quả theo module

| Module | Kết luận | Phát hiện |
|---|---|---|
| `m_vlsit_axil_reg_bridge` | **Có lỗi chặn** | RB-01 |
| `m_vlsit_riscv_axil_decode` | Đúng về giao thức, thiếu kiểm soát truy cập | RB-02 |
| `m_vlsit_riscv_sharer_directory` | **Có lỗi chặn**; PLRU và hình học đúng | CC-01, CC-04 đến CC-06 |
| `m_vlsit_riscv_coh_txn_table` | Đúng về cấp phát và pha; kênh ACK dễ treo | CC-02, CC-03 |
| `m_vlsit_riscv_probe_scheduler` | Đúng về chức năng; chậm; thiếu trường `target_state` từ bảng | PF-05, CC-02, CC-03 |
| `m_vlsit_riscv_coh_bank_arb` | Đúng nếu bên dùng hạ request đúng cạnh nhận | CC-03 |
| `m_vlsit_riscv_pmu` và 6 khối con | Ánh xạ event đúng; có điểm W1C | CC-10 |
| `m_vlsit_riscv_debug_router` | Chỉ là dây nối | Mục 6 |
| `cva6` đã sửa (3 file) | Đúng ý định đã ghi; một điểm lệch chuẩn ngầm | CV-01 |
| `m_vlsit_cpucl_csr` (sinh ra) | Công cụ sinh; hardware thắng W1C | CC-10 |

### B.3 RB-01 (Blocker, V): bridge LLC chuyển lệnh ghi bị cấm xuống LLC và trả hai B response

**Cơ chế.** Trong `m_vlsit_axil_reg_bridge.sv`, khối `p_com_axil_reg_fsm` chuyển từ `IDLE` sang `WR_REQ` khi `w_pick_wr & w_wr_addr_aligned & w_wr_addr_mapped` (khoảng dòng 234). Điều kiện này không loại trừ `w_wr_addr_wr_denied`. Trong khi đó `w_wr_local_err` (dòng 144) coi địa chỉ bị cấm là lỗi cục bộ và đặt `reg_bvalid` với SLVERR ngay chu kỳ dispatch. Cả hai đường cùng xảy ra với một thanh ghi bị cấm: lệnh ghi vẫn được đẩy xuống LLC, và hai B response được trả về.

**Kết quả mô phỏng** (`repro/reg_bridge_denied_write`, RegBus model luôn ready):

| Lệnh ghi AXI4-Lite | Ghi xuống RegBus | B response | Đúng/Sai |
|---|---|---|---|
| `0x00` (`CFG_SPM_LOW`, bị cấm) | 1 lần, dữ liệu `0xDEAD0000` | SLVERR (2) rồi OKAY (0): **2 B** | Sai |
| `0x40` (`VERSION_LOW`, chỉ đọc) | 1 lần | SLVERR rồi OKAY: **2 B** | Sai |
| `0x08` (`CFG_FLUSH_LOW`, cho phép) | 1 lần | OKAY: 1 B | Đúng |
| `0x4C` (không ánh xạ) | 0 | DECERR: 1 B | Đúng |
| `0x09` (không căn lề) | 0 | SLVERR: 1 B | Đúng |

**Hệ quả:**

| Hệ quả | Giải thích |
|---|---|
| Mất bảo vệ SPM (REQ-MEM-003, REQ-IF-010) | Một master AXI4-Lite ghi `CFG_SPM_LOW`/`HIGH` thì giá trị đến thanh ghi cấu hình của LLC; nếu LLC áp dụng khi ghi `COMMIT_CFG` (bridge cho phép) như thiết kế `axi_llc` (cần kiểm lại với source đã pin), dung lượng cache của LLC đổi lúc chạy và dữ liệu cache có thể hỏng |
| Vi phạm AXI4-Lite | Hai B response cho một AW/W. Master hoặc interconnect có theo dõi giao dịch sẽ báo lỗi hoặc treo |
| B response nói dối | Response đầu tiên báo SLVERR (từ chối) trong khi lệnh ghi thực tế đã đến LLC; response thứ hai báo OKAY |

**Sửa (đã thử trên bản sao, không sửa file trong repo):** thêm `& ~w_wr_addr_wr_denied` vào điều kiện chuyển sang `WR_REQ`. Chạy lại cùng testbench: lệnh ghi vào `0x00` và `0x40` cho 0 RegBus write và 1 B (SLVERR); các trường hợp khác không đổi.

**Vì sao các kiểm tra hiện có không bắt được:** rule check và lint chỉ kiểm cú pháp và quy tắc, không có testbench (TB-01).

### B.4 RB-02 (Medium, C, S): AXI4-Lite decode không kiểm soát truy cập

| Điểm | Chi tiết |
|---|---|
| `PPROT` bị bỏ qua | `m_vlsit_riscv_axil_decode.sv` chuyển `awprot`/`arprot` nhưng CSR sinh ra và bridge không dùng (2 cảnh báo lint). Mọi master, kể cả non-secure hoặc unprivileged, có thể xóa LLC (`CFG_FLUSH`), đổi cấu hình PMU hoặc chạy BIST. Spec §18 nói "PPROT handling must be configured explicitly" nhưng chưa có quyết định |
| Tham số base không được kiểm | `PARA_AXIL_BASE_ADDR` sai (không căn 4 KiB hoặc vượt giới hạn) làm `w_axil_base_valid=0` và mọi truy cập trả DECERR một cách im lặng; không có kiểm tra khi elaborate |
| Thứ tự kiểm lỗi | Địa chỉ không căn lề được kiểm trước vùng ánh xạ, nên địa chỉ không căn lề trong vùng không ánh xạ trả SLVERR (REQ-IF-007 chỉ nói "aligned unmapped" trả DECERR nên khớp) |

Đề xuất: thêm quy tắc PPROT (ví dụ chỉ cho phép truy cập privileged và secure vào cấu hình LLC và PMU, trả SLVERR nếu vi phạm); thêm kiểm tra elaborate cho base.

### B.5 TB-01 (High, V): không có testbench hay assertion cho RTL mới

Đã tìm trong repo (ngoài `third_party`): không có testbench, không Makefile, không SVA nào cho 12 file RTL mới; `rtl/common/vlsit` chỉ có khoảng 35 file log lint và báo cáo rule. Lint `-Wall` cho 6 khối cho 0 cảnh báo (riêng bridge có 2 cảnh báo `PROT` không dùng) và rule check đạt, nhưng RB-01, CC-01, CC-02 và grant lặp đều không bị lint hay rule check bắt. Spec đã liệt kê kế hoạch kiểm chứng (TEST-xxx, formal) nhưng chưa có gì chạy được. Đề xuất ở mục 9.

### B.6 CV-01 (Low, S, C): ngắt supervisor của CVA6

Các bản sao `csr_regfile.sv`, `perf_counters.sv`, `cva6.sv` khớp với phần mô tả trong `doc/rtl_layout/modified/README.md` (đã đối chiếu bằng `diff`).

| Điểm | Chi tiết |
|---|---|
| OR mức ngoài vào `mip` | `mip_effective = mip_q OR mip_ext_pending` (SSIP, STIP) dùng cho phát hiện ngắt, đánh thức WFI và đọc CSR. Phần mềm vẫn ghi được `mip_q`, và đọc-sửa-ghi không chốt mức ngoài vào `mip_q` (đúng ý định). Lưu ý: bản gốc CVA6 chỉ OR tín hiệu ngoài cho SEIP (đúng chuẩn RISC-V); OR cho SSIP/STIP là quyết định của dự án (REQ-IRQ-002). Phần mềm không thể xóa SSIP/STIP khi mức ngoài còn cao; cần ghi rõ trong hướng dẫn tích hợp OpenSBI |
| Điểm đọc `sip` | Có mask `mideleg`; nhánh `RVH` có xử lý riêng. Cấu hình này không bật H nên nhánh đó chưa được thực thi |
| Event tap | 22 bit khớp thứ tự 0x0001 đến 0x0016 và dùng đúng biểu thức của bộ chọn native; tap lấy trước lọc `mcountinhibit` |
| WFI | CVA6 dừng pipeline bằng `halt_csr_o` nội bộ, không xuất ra cluster (xem LP-01) |

### B.7 Các điểm đã kiểm và đúng

| Điểm | Cách kiểm |
|---|---|
| Hình học directory: 4 bank × (64·số hart) set × 8 way; 8192 entry cho 4 hart, 4096 cho 2 hart; bank chọn bằng `line[1:0]` = PA[5:4] | Đọc code, đối chiếu REQ-MEM-010/011 |
| Tree-PLRU: chỉ số nút, cập nhật "trỏ ra xa", đi cây tìm victim, chọn way invalid thấp nhất trước | Đọc code, đối chiếu REQ-MEM-014 |
| Bảng transaction: cấp slot thấp nhất rảnh, không cho hai context cùng line, ACK chỉ nhận khi khớp tag/phase/hart, pha xong khi đủ ACK; các nhánh `casez` loại trừ nhau | Đọc code |
| Probe scheduler: không phát lại probe cho hart đã trả lời; đồng bộ cập nhật `received` với `ack` cùng cạnh | Đọc code; mô phỏng tích hợp với bảng transaction |
| Bộ chọn event PMU: ánh xạ CVA6 (0x01–0x16), HPDcache (0x00–0x0F), LLC (0x00–0x17 và 0x40–0x43), CCU (0x00–0x0B) đúng chỉ số; ID/scope không hợp lệ trả 0 | Đọc code, đối chiếu workbook |
| AXI4-Lite decode: AW/W độc lập, một giao dịch mỗi hướng, valid giữ đến khi nhận, B/R chỉ trả từ target đã chọn, DECERR/SLVERR đúng thứ tự | Đọc code |
| Rule check và lint như README nêu | Chạy lại |

### B.8 Dọn dẹp repo (Low)

`rtl/common/vlsit` chứa khoảng 35 file log lint và báo cáo rule với hậu tố `_final`, `_latest`, `_latest_2` (nên giữ một báo cáo mới nhất hoặc đưa vào thư mục `reports/` không theo dõi). Thư mục `.artifact_work/` ở gốc chứa ảnh trung gian.
