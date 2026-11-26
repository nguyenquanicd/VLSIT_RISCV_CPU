# Review hợp nhất — VLSIT RISC-V Dual/Quad CPU Cluster (2026-11-20)

| Mục | Nội dung |
|---|---|
| Ngày | 2026-11-20 |
| Đối tượng | TOP `m_vlsit_riscv_cluster_axi_top`, `rtl/non_coherence_cluster`, `rtl/common/vlsit`, HDS, audit post-A06 |
| Mục đích | Gộp mọi review về cluster 2/4 hart (thiết kế, RTL, timing) thành một tài liệu duy nhất; đối chiếu từng phát hiện với RTL hiện tại; thêm các phát hiện mới của lượt này |
| Phạm vi | Review thiết kế và RTL (mục 1 đến 6); phân tích timing synthesis GF55 và FPGA VP1902 (mục 2A, R-20 đến R-27) |
| Ngôn ngữ | Tiếng Việt, giữ thuật ngữ kỹ thuật tiếng Anh |
| Không làm | Không chạy simulation, lint hay công cụ synthesis trong lượt này; không đọc toàn bộ mã native (CVA6, HPDcache, `axi_llc`); không tự đo PPA (số timing lấy từ report trong hai file zip) |

## 0. Nguồn đã gộp

| File | Mốc | Cách xử lý |
|---|---|---|
| `VLSIT_RISCV_CPU_Cluster_Design_Review.md` (đã xóa sau khi gộp) | 2026-11-09, trên RTL cũ chưa có top | Giữ phát hiện còn đúng (hiệu năng, directory, debug, low-power, RB-01, PPROT); đánh dấu CC-01/02/03 đã đóng |
| `VLSIT_RISCV_CPU_Review_2026-11-16.md` (đã xóa sau khi gộp) | 2026-11-16, trên TOP đã tích hợp | Nguồn chính. Các phát hiện N-01 đến N-10 được giữ và đối chiếu lại |
| `VLSIT_RISCV_CPU_Project_Review_2026-11-11.md` (đã xóa sau khi gộp) | 2026-11-11, khi top chưa chạy được | Lỗi thời gần hết (top thiếu core, delta v0.19 chưa merge). Chỉ giữ phần còn đúng, xem mục 4 |
| `project_support/review/rtl_change_review.md`, `rtl_change_review_v019.md` | Plan V3, V4 | Là kế hoạch thay đổi RTL, không phải review thiết kế. Không gộp nội dung |
| `project_support/reports/post_a06_cluster_audit/README.md` | 2026-11-16 | Dùng làm đối chứng (B-01 đến B-05) |
| `doc/tensor_coprocessor/review/*` | 2026-11-17 | Ngoài phạm vi (tensor coprocessor, không phải cluster 2/4) |
| `dual_gf55_800.zip`, `vp1902.zip` | Chạy 2026-11-17 | Nguồn số liệu timing cho mục 2A (R-20 đến R-27) |
| `project_support/reports/timing_gf55_vp1902_20261120/TIMING_ANALYSIS.md` (đã xóa sau khi gộp) | 2026-11-20 | Gộp toàn bộ vào mục 2A |

Ba file review đã gộp (11-09, 11-11, 11-16) và báo cáo timing đã bị xóa khỏi vị trí làm việc. Bản gốc còn trong `project_support/doc_cleanup_20261116/before/doc/review/` (khác bản đã xóa ở một số liên kết do đổi đường dẫn). Hai file RTL change review và các review tensor được giữ nguyên.

Nhãn bằng chứng: **V** đã chạy công cụ hoặc mô phỏng; **C** suy ra từ đọc code; **S** từ đọc spec; **E** ước tính. Cột "Đọc lại" ghi ✔ nếu lượt này tôi đã đọc lại đúng dòng RTL, ○ nếu lấy từ review trước.

## 1. Bảng nhận xét tổng hợp

| ID | Mức | Chủ đề | Trạng thái | Bằng chứng | Đọc lại | Nguồn |
|---|---|---|---|---|---|---|
| R-01 | **Blocker** | Bridge LLC chuyển lệnh ghi bị cấm xuống LLC, trả 2 B response | Còn | V, C | ✔ | RB-01, N-02 |
| R-02 | **High** | Ngắt ngoài M/S bị đảo ở biên CVA6 | Còn | C | ✔ | N-01 |
| R-03 | **High** | RTL dùng tín hiệu trước khi khai báo, Questa và slang từ chối biên dịch | Còn | V, C | ✔ | N-03 |
| R-04 | **High** | Nguy cơ circular wait giữa các context CCU qua "phase owner" slot của từng hart | **Đã sửa; directed sim 4 hart pass; TOP/formal pending** | C, V | ✔ | DEC-043, TEST-056 |
| R-05 | **High** | `lzc.sv` có thông báo hạn chế sử dụng trong filelist production | Còn | S | ○ | B-01 |
| R-06 | Medium | Directory phủ 1:1 L1D, mảng flop, không báo clean eviction | Còn | S, C, E | ✔ | PF-06, PF-07, CC-04 |
| R-07 | Medium | Các điểm tuần tự hóa trong CCU và L1 | Còn | V, C, S | ✔ một phần | N-04, PF-05, PF-08 |
| R-08 | Medium | Miền lỗi chung: không timeout, một reset, hart debug/WFI phải còn trả lời probe | Còn | S | ○ | SYS-02, DB-02, LP-06 |
| R-09 | Medium | Cấu hình không được kiểm và không đọc được từ phần mềm | Còn, một phần mới | C | ✔ | N-07, B-02, mới |
| R-10 | Medium | Khoảng trống verification đa lõi | Còn | S | ○ | N-08, B-03, B-04 |
| R-11 | Medium | PMU: W1C bị phần cứng ghi đè, chưa kiểm chứng chức năng | Còn | C, S | ○ | CC-10, B-03 |
| R-12 | Medium | `PPROT` bị bỏ qua ở AXI4-Lite | Còn | C | ○ | RB-02 |
| R-13 | Medium | FSM probe engine gán `'x` cho trạng thái bất hợp pháp | Còn | C | ○ | N-05 |
| R-14 | Low | Lệnh CMO bất hợp pháp làm treo thay vì báo lỗi | Còn | C | ○ | N-06 |
| R-15 | Medium | Nền hiệu năng: CVA6 in-order, line 16 B, một cổng AXI 64-bit, DMA không coherent | Còn (chấp nhận trong HDS) | S, E | ○ | PF-01..04, SYS-03 |
| R-16 | Medium | Chi phí duy trì cache: FENCE.I, CBO theo line, không ECC | Còn (chấp nhận trong HDS) | S | ○ | CC-07..09 |
| R-17 | Medium | Low-power và debug ngoài phạm vi v1 | Còn | S | ○ | LP-01..11, DB-A..H |
| R-18 | Low | Tài liệu: HDS quá dài, đoạn cũ còn sót, comment và header sai | Còn | C, S | ✔ một phần | B-05, N-09, mới |
| R-19 | Low | Vệ sinh repo | Còn | C | ○ | N-09 |
| R-20 | **High** | Mục tiêu 960 MHz (T = 1,0417 ns, SS 125 °C) nhưng đường dài nhất 3,40 ns / 46 cell; WNS -2,47 ns, 312.168 endpoint vi phạm | Mới | R | ✔ | Mới (zip GF55) |
| R-21 | **High** | Chuỗi PMU/CSR overflow không có flop cắt; là endpoint xấu nhất ở cả ASIC và FPGA | Mới | R, C | ✔ | Mới; liên quan R-11 |
| R-22 | **High** | Sharer directory là mảng flop: 206.600 flop (74%), 2,82 mm² (56% diện tích), 43% endpoint đuôi. Chuyển sang RAM model thay được bằng macro là khả thi và sửa ít (mục 2A.4, F2a) | Mới (định lượng R-06) | R, C | ✔ | R-06; mục 2A.2 |
| R-23 | **High** | Biên AXI memory có đường tổ hợp vào-ra (`o_axi_mem_rready`, `i_axi_mem_bid` vào LSU/CCU); ngân sách in2out 0,208 ns | Mới | R | ○ | Mới |
| R-24 | Medium | Lõi CVA6 (FPU, issue, ex_stage, mult, LSU, PMP) cùng ở ~3,4 ns, nằm trong vòng lặp IPC | Mới | R | ○ | Mới |
| R-25 | Medium | Flow và SDC lạc quan: SRAM black-box, WLM 0, clock ideal, uncertainty 1%, I/O 40%, chỉ thư viện RVT | Mới | R | ○ | Mới |
| R-26 | Medium | FPGA VP1902: không BRAM/URAM (~940.000 FF là mảng nhớ), WNS -1,71 ns ở 100 MHz sau route, ~85 MHz tối đa | Mới | R | ○ | Mới (zip VP1902) |
| R-27 | Medium | `i_rst_n_cluster` dùng như tín hiệu dữ liệu trong logic handshake (`tile_coh_adapter`, `axi_route`, `cache_line_locks`, `cmo_controller`): thành start point in2reg/in2out (-2,16 và -0,60 ns) và gây fanout reset giữa logic dữ liệu (mục 2A.9, V-21, V-30) | Mới | R, C | ✔ | Mới (zip GF55) |

Thứ tự xử lý đề xuất: R-01, R-02, R-03 (sửa nhỏ, rủi ro cao) trước; R-04 đã có fix DEC-043 và directed test pass, nhưng cần thêm TOP lint 2/4 hart, formal wait-for proof và random coherence regression; R-21, R-22, R-23, R-25 (timing, không đổi IPC) song song; sau đó R-05, R-09, R-10; phần còn lại theo mục 5.

## 2. Phát hiện chi tiết

### R-01 (Blocker) — Bridge LLC ghi xuống LLC dù đã từ chối

- **Mô tả.** [m_vlsit_axil_reg_bridge.sv:234](../../../rtl/common/vlsit/control/m_vlsit_axil_reg_bridge.sv:234) chuyển `IDLE` sang `WR_REQ` khi `w_pick_wr & w_wr_addr_aligned & w_wr_addr_mapped`, không loại trừ `w_wr_addr_wr_denied`. Cùng lúc `w_wr_local_err` ([dòng 143](../../../rtl/common/vlsit/control/m_vlsit_axil_reg_bridge.sv:143)) coi địa chỉ bị cấm là lỗi cục bộ và sinh B response SLVERR.
- **Bằng chứng.** Review 11-16 chạy lại repro `reg_bridge_denied_write`: ghi vào `0x00` (`CFG_SPM_LOW`) và `0x40` (`VERSION_LOW`) cho 1 lệnh ghi RegBus và 2 B response (SLVERR rồi OKAY). Lượt này tôi đọc lại: điều kiện ở dòng 234 vẫn không có `~w_wr_addr_wr_denied`.
- **Hệ quả.** Bất kỳ master AXI4-Lite nào cũng ghi được thanh ghi SPM của LLC, trái REQ-MEM-003 và DEC-024. Một lệnh ghi nhận hai B response vi phạm AXI4-Lite. B response đầu báo từ chối trong khi lệnh ghi đã đến LLC.
- **Vì sao chưa bị bắt.** Audit xếp đường LLC service là "chỉ lint". Rule check và lint không có khả năng bắt lỗi chức năng này.
- **Đề xuất.** Thêm `& ~w_wr_addr_wr_denied` vào điều kiện chuyển trạng thái. Đổi repro thành regression và thêm test ở mức TOP: ghi vào offset cấm trả SLVERR, LLC không đổi cấu hình.

### R-02 (High) — Ngắt ngoài M/S bị đảo

- **Mô tả.** [m_vlsit_riscv_cpu_tile.sv:397](../../../rtl/common/vlsit/cpu/m_vlsit_riscv_cpu_tile.sv:397) nối `.irq_i({i_int_meip, i_int_seip})`. Trong [csr_regfile.sv:2117](../../../rtl/common/modified/cva6/core/csr_regfile.sv:2117), `mip_d[IRQ_M_EXT] = irq_i[0]`; `irq_i[1]` được OR vào SEIP (dòng 2721, 2784). Như vậy bit 0 là M-mode, bit 1 là S-mode.
- **Hệ quả.** `i_int_meip` của SoC đến CVA6 như ngắt external của S-mode, và `i_int_seip` đến như ngắt của M-mode. Với OpenSBI và Linux, ngắt thiết bị vào sai mức đặc quyền hoặc bị chặn. Bốn cổng `msip`, `mtip`, `ssip`, `stip` nối đúng.
- **Vì sao chưa bị bắt.** External IRQ/debug được audit ghi là chỉ lint.
- **Đề xuất.** Đảo thành `{i_int_seip, i_int_meip}`. Thêm test CPU thật: `mip.MEIP` lên khi `i_int_meip=1`, `mip.SEIP` lên khi `i_int_seip=1`, kèm delegation và WFI, ở cả 2 và 4 hart. Lỗi này nằm ở một dòng nhưng chỉ lộ khi chạy phần mềm có PLIC, nên cần quyết định chủ dự án (câu hỏi Q1, mục 6).

### R-03 (High) — Khai báo sau khi dùng

- **Mô tả.** Hai file lớn nhất khai báo tín hiệu sau khi dùng. Đã đọc lại:
  - [cluster_core.sv](../../../rtl/non_coherence_cluster/m_vlsit_riscv_cluster_core.sv): `w_llc_reg_req_*` dùng ở dòng 1000, khai báo ở 1198; `w_fault_set_event` dùng ở 1050, khai báo ở 1122; `w_cpucl_coh_fault` dùng ở 1057, khai báo ở 1114; `w_pmu_evt_*` dùng ở 1069, khai báo từ 1117.
  - [coh_fabric.sv](../../../rtl/common/vlsit/coherence/m_vlsit_riscv_coh_fabric.sv): `w_internal_pick_valid` dùng ở dòng 163, khai báo ở 342.
- **Bằng chứng.** Review 11-16 (V): Verilator dung thứ nên lint "sạch"; QuestaSim 10.4c báo 27 lỗi ở core và 15 lỗi ở fabric; `slang` báo 71 lỗi (70 lỗi dùng trước khai báo, 1 lỗi `cf_math_pkg::is_power_of_2` do trộn hai bản `common_cells`). Lượt này tôi không chạy lại các công cụ đó.
- **Hệ quả.** Mọi báo cáo "lint sạch" chỉ đúng với một front-end. Các luồng mô phỏng, synthesis, CDC, formal thương mại có thể từ chối RTL. Các module nhỏ vẫn biên dịch sạch nên đây là lỗi tổ chức file chứ không phải lỗi thiết kế.
- **Đề xuất.** Chuyển khai báo lên đầu file; thêm `slang` và Questa vào `scripts/run_cluster_top_lint.py` và `vlsit_rtl_check.py`; thống nhất một bản `common_cells`; phân loại lỗi trong bản sao CVA6, HPDcache, `axi_llc` thành "kế thừa upstream" và "do bản sửa của dự án".

### R-04 (High, mới, C) — Nguy cơ circular wait giữa các context CCU

> Phát hiện ban đầu được suy ra từ đọc RTL và chưa có mô phỏng. DEC-043 đã thêm atomic all-target claim; TEST-056 chạy directed 4-hart probe-scheduler test và pass với Verilator 5.053. TOP lint 2/4 hart, formal wait-for proof, và random coherence regression chưa chạy trong lượt sửa này.

- **Cơ chế.**
  1. [probe_scheduler.sv:135-137](../../../rtl/common/vlsit/coherence/m_vlsit_riscv_probe_scheduler.sv:135) chỉ cho một context chiếm "phase owner" slot của mỗi hart; slot được giữ từ PREPARE đến COMMIT hoặc ABORT thành công ([dòng 208-221](../../../rtl/common/vlsit/coherence/m_vlsit_riscv_probe_scheduler.sv:208)).
  2. [coh_fabric.sv:647-651](../../../rtl/common/vlsit/coherence/m_vlsit_riscv_coh_fabric.sv:647) bắt đầu PREPARE cho tất cả holder cùng lúc (`w_phase_expected = reg_ctx_probe_holders`).
  3. Mỗi hart tự chọn context theo con trỏ round-robin riêng (`reg_rr_ptr`).
  4. COMMIT không thể bắt đầu khi PREPARE chưa nhận đủ ACK: [coh_txn_table.sv:170-181](../../../rtl/common/vlsit/coherence/m_vlsit_riscv_coh_txn_table.sv:170) chỉ cho bắt đầu pha khi `~reg_ctx_phase_active`.
- **Kịch bản (4 hart).** Hai line A và B cùng ở trạng thái S, holder là H2 và H3. H0 ghi A (context X), H1 ghi B (context Y), hai context chạy đồng thời vì khác line. H2 chọn X, H3 chọn Y. X chờ H3 (đang bị Y giữ), Y chờ H2 (đang bị X giữ). Không ai nhả. Điều kiện chỉ cần H2 và H3 bận lệch nhau lúc hai context xuất hiện, hoặc `reg_rr_ptr` của hai hart khác nhau (xảy ra sau bất kỳ lưu lượng bất đối xứng nào).
- **Với 2 hart.** Context thường chỉ có 1 target nên không tạo vòng. Vòng cần hai context mỗi cái có 2 target: context eviction của directory (CCU probe cả hai hart) cộng một CMO, hoặc hai context eviction từ hai parent khác nhau. Khả năng thấp hơn nhưng không loại trừ.
- **Vì sao tài liệu chưa nêu.** Bảng wait-for graph ở [HDS mục 10.2.4](../VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) không liệt kê tài nguyên "phase owner của hart", nhưng cam kết "không có internal resource wait cycle". HDS mục 10.5.6 chỉ nói test full-context "không chứng minh mọi wait-for cycle vắng mặt". Review 11-16 (N-04) ghi nhận slot này chỉ như giới hạn hiệu năng, chưa xét khả năng deadlock.
- **Đính chính so với gợi ý trước trong chat.** Tôi từng gợi ý "thứ tự ưu tiên context toàn cục thay cho RR từng hart". Gợi ý đó **không đủ**: nếu Y nhận H3 từ trước khi X xuất hiện thì slot đã bị giữ, ưu tiên tĩnh không thu hồi được và vòng vẫn hình thành.
- **Khắc phục đã triển khai (DEC-043).** Probe scheduler dùng một round-robin arbiter cấp claim cho toàn context. Trước PREPARE, arbiter kiểm tra toàn bộ expected-hart mask; nếu bất kỳ slot nào bận thì không ghi owner tag lên hart nào. Nếu đủ slot, cùng một cạnh clock ghi cùng tag cho tất cả hart đích. Scheduler chỉ phát PREPARE khi hart đã giữ slot đúng tag; owner được giữ đến response COMMIT/ABORT thành công. Các claim có target mask rời nhau vẫn có thể chạy đồng thời sau các lượt claim liên tiếp.
- **Kiểm chứng đã chạy.** `tb_probe_phase_owner.sv` làm lệch round-robin H3 bằng một giao dịch warm-up, sau đó chạy hai context cùng mask `{H2,H3}`. Test xác nhận H2/H3 nhận cùng tag, context còn lại chờ không giữ slot một phần, transaction thứ hai hoàn tất sau COMMIT của transaction thắng, và các mask rời nhau vẫn phát request chồng lấn. Verilator 5.053 báo PASS ở 920 ns.
- **Giới hạn evidence.** Chưa chạy TOP lint 2/4 hart, formal wait-for proof hoặc random coherence regression. Vì vậy test xác nhận luồng directed của fix, chưa phải chứng minh toàn không gian trạng thái.

### R-05 (High) — `lzc.sv` có thông báo hạn chế sử dụng

Audit B-01: filelist production của CVA6 ([cva6_modified_cache.Flist](../../../rtl/common/filelists/cva6_flush_path/cva6_modified_cache.Flist), dòng 122) dùng `lzc.sv` có header hạn chế dùng lại và phân phối khi chưa có phép bằng văn bản. License cấp repo không giải quyết thông báo cấp file. Đây là điểm chặn phát hành và tapeout. Cần ghi nhận quyền sử dụng hoặc thay bằng cài đặt tương thích có license rõ, rồi kiểm chứng mọi độ rộng và chế độ đang dùng. Lượt này chưa đọc lại file; không kết luận về pháp lý.

### R-06 (Medium) — Directory phủ 1:1 L1D

- **Số liệu.** Số entry là `PARA_CPU_NUM × 2048` (REQ-MEM-010, DEC-014): 4096 cho 2 hart, 8192 cho 4 hart. Đúng bằng tổng số line D-cache (32 KiB / 16 B mỗi hart). Hình học trong [sharer_directory.sv](../../../rtl/common/vlsit/coherence/m_vlsit_riscv_sharer_directory.sv): 4 bank × 8 way × `64×PARA_CPU_NUM` set.
- **Hệ quả.**
  - Directory không có dư dung lượng; chỉ cần conflict lệch set là phải back-invalidate line L1 còn sống (kể cả line private không chia sẻ). Review 11-09 lưu ý bank và set của directory trùng set của L1D, nên trường hợp xấu là 32 line L1D tranh nhau 8 way.
  - Holder "stale-positive" (conservative) chiếm thêm entry.
  - Dung lượng: ~51 bit mỗi entry (E) cho khoảng 418 kbit tức ~52 KB ở quad, so với 128 KiB dữ liệu L1D (~40% overhead). Với 2 hart là ~26 KB so với 64 KiB.
  - RTL hiện là mảng flop; muốn thực tế phải chuyển SRAM macro, thêm FSM khởi tạo valid và ECC.
- **Timing và diện tích thực.** Báo cáo synthesis GF55 cho thấy directory chiếm 206.600 flop và 2,82 mm² (56% diện tích) và 43% endpoint đuôi; chi tiết và hướng sửa ở R-22 và mục 2A.
- **Đề xuất.** Đo hiệu năng với directory dư 2× và associativity 16; thêm clean-eviction notification; hoặc cân nhắc line 64 B (cũng giảm số entry). Với 2 hart có thể cân nhắc probe broadcast.

### R-07 (Medium) — Các điểm tuần tự hóa

| Giới hạn | Bằng chứng | Hệ quả |
|---|---|---|
| Mỗi hart chỉ là đích của một context tại một thời điểm, từ PREPARE đến pha cuối | `probe_scheduler` (đã đọc lại). Đo 11-16 (V): 12 chu kỳ mỗi transaction tới một hart (6 mỗi pha) với cache lý tưởng | Hart giữ nhiều line "nóng" phục vụ nối tiếp; 8 context không có nghĩa là 8 transaction song song. Liên quan trực tiếp R-04 |
| Mọi lookup đặt reservation cả set đến UPDATE hoặc CANCEL | `sharer_directory`, review 11-16 | Mọi transaction cùng set directory bị tuần tự hóa, gồm cả thời gian writeback của owner. Đây là giá của việc đóng CC-01 |
| Chỉ nhận gốc khi còn đủ context rảnh (N-1 gốc) | `coh_fabric`, REQ-MEM-009 | `PARA_COH_TXN_NUM=2` chỉ cho một transaction CPU/CMO toàn cluster |
| Một controller CMO dùng chung | `cmo_controller`; `cmo_arbiter` | CBO của mọi hart tuần tự hóa; gói 1500 B cần ~94 lệnh CBO |
| Dirty replacement tạm dừng controller L1 đến khi có B | A-03, HDS mục 13 | Thêm một vòng B mỗi lần thay line dirty |
| Directory một bank xử lý một thao tác mỗi chu kỳ | HDS 10.2.4 | Bốn bank không bảo đảm bốn grant mỗi chu kỳ |

Hệ quả chung: thêm hart không tăng throughput tương ứng khi dữ liệu nóng nằm ở một hart hoặc một set. Đây là hệ quả của lựa chọn "đúng trước, nhanh sau"; cần đưa vào mô hình hiệu năng trước khi cam kết số liệu.

### R-08 (Medium) — Miền lỗi chung và điều kiện để hart còn trả lời probe

- **Chia sẻ tài nguyên toàn cluster.** Context CCU (8 mặc định, tối đa 16) không có quota theo hart. ACK, PREPARE, COMMIT, ABORT không có timeout (DEC-018). Một ACK hoặc B response không bao giờ đến giữ slot và line lock vô hạn; khi hết context, mọi miss và CMO mới dừng toàn cluster.
- **Phục hồi.** Chỉ có một reset cluster, không có reset theo hart. Lỗi ordinary eviction làm controller cache của hart đó đứng đến reset (theo quyết định đã duyệt). Reset xóa dirty data nên không phải đường phục hồi an toàn khi đang chạy.
- **Điều kiện tích hợp chưa ghi rõ.** Probe cần cache của hart đích còn clock và còn phục vụ khi hart halt (debug) hoặc WFI. Review 11-09 (DB-02, LP-06) nêu HDS chưa quy định. Hiện toàn cluster dùng một `i_clk_cluster` nên chưa phát sinh, nhưng nếu SoC gate clock tile thì cluster treo.
- **Đề xuất.** Ghi điều kiện này vào integration contract; thêm watchdog theo transaction (có đường báo lỗi thay cho "chờ vô hạn") và CSR chẩn đoán CCU (số slot đang dùng, tuổi lớn nhất, tag, line, pha của transaction cũ nhất); cân nhắc quota context theo hart.

### R-09 (Medium) — Cấu hình không được kiểm và không đọc được từ phần mềm

- **Không có guard khi elaborate (mới, đã đọc lại).** `PARA_CPU_NUM` không có `$error`. Giá trị 1 hoặc 3: `w_active_hart` được gán 4'b1111 (mọi giá trị khác 2 coi như 4) ở [cluster_core.sv:293](../../../rtl/non_coherence_cluster/m_vlsit_riscv_cluster_core.sv:293), [axi_mem_mux.sv:236](../../../rtl/common/vlsit/interconnect/m_vlsit_riscv_axi_mem_mux.sv:236) và `axi_mmio.sv:232`, trong khi tile array chỉ tạo tile `< PARA_CPU_NUM`. Kết quả không nhất quán thay vì lỗi rõ ràng. Tương tự cho `PARA_COH_TXN_NUM` và tham số LLC. Địa chỉ base AXI4-Lite sai chỉ làm mọi truy cập trả DECERR im lặng (RB-02 kèm theo).
- **Tham số hợp lệ nhưng chưa được hỗ trợ** (N-07, B-02): `PARA_LLC_BLOCK_NUM > 2` (maintenance dùng line 16 B cố định), `PARA_AXI_MEM_DATA_W` = 32/128/256 (chỉ test lá), `PARA_COH_TXN_NUM=2`, PMU khác mặc định. Nên khóa về giá trị đã verify.
- **Phần mềm không phát hiện được cấu hình (mới, đã grep CSR).** CSR [m_vlsit_cpucl_csr.sv](../../../rtl/common/vlsit/csr/RTL/m_vlsit_cpucl_csr.sv) chỉ có PMU, IRQ, `cpucl_coh` và fault. Không có thanh ghi version, số hart, `PARA_COH_TXN_NUM` hay hình học LLC. Firmware không biết đang chạy 2 hay 4 hart. Chỉ có một `i_boot_addr` chung và mọi hart khởi động cùng lúc, nên phần mềm phải dừng hart phụ theo `mhartid`.
- **Đề xuất.** Thêm `$error` guard cho các tham số; thêm thanh ghi RO "cluster config/version"; ghi rõ profile được hỗ trợ trong HDS.

### R-10 (Medium) — Khoảng trống verification đa lõi

- 58 ca CPU thật (A-06 10, A-05 8, A-04 8, A-03 6, atomic 10, CBO 8, FENCE.I 8) đều là directed, mạnh cho cache, CBO, FENCE.I, atomic và fault record, nhưng:
  - chưa có scoreboard dữ liệu chia sẻ độc lập, chưa có litmus test memory ordering, chưa có random 4 hart;
  - chưa có formal cho unique writer, no false-negative holder, no loss of dirty data, tag association;
  - đường "chỉ lint": PMU, native LLC service (BIST, flush), external IRQ/debug/WFI, MMIO và normal-uncached, uncached ATOP, width adapter 32/128/256 ở TOP;
  - R-01 và R-02 đều nằm trên các đường này, nên là bằng chứng thực tế cho rủi ro;
  - mọi simulation chỉ dùng Verilator (R-03), chưa đo coverage.
- Đề xuất theo audit: đóng các đường chỉ-lint trước, sau đó random coherence kèm scoreboard và assertion, rồi ma trận cấu hình (2/4 hart × bus 32/64/128/256 × context 2/8/16 × PMU).

### R-11 (Medium) — PMU

PMU IRQ nạp lại `raw` bằng giá trị cũ OR bit mới, và CSR sinh ra cho phần cứng ưu tiên khi cùng chu kỳ (CC-10, B-03): lệnh W1C trùng chu kỳ với một counter tràn bị mất, ngắt vẫn treo. Không có xóa hay đóng băng counter. Quan trọng hơn: PMU là nguồn đo IPC và băng thông, nên mọi nhận định hiệu năng chưa đáng tin cho đến khi PMU được kiểm chứng chức năng. Đề xuất: sửa ưu tiên W1C, thêm clear/freeze, test đồng thời tràn và W1C, snapshot qua phần mềm thật.

### R-12 (Medium) — `PPROT`

`m_vlsit_riscv_axil_decode.sv` chuyển `awprot`/`arprot` nhưng CSR và bridge không dùng. Mọi master có thể xóa LLC, đổi cấu hình PMU hoặc chạy BIST. HDS mục 18 nêu "PPROT handling must be configured explicitly" nhưng chưa có quyết định. Đề xuất: chỉ cho truy cập privileged/secure vào cấu hình LLC và PMU, trả SLVERR nếu vi phạm.

### R-13 (Medium) — FSM probe engine gán `'x`

`m_vlsit_riscv_hpd_probe_engine.sv` (khoảng dòng 150 và 189) dùng `casez` với `default` gán `'x` cho các output valid; ở next-state, trạng thái bất hợp pháp giữ nguyên, không có đường về `IDLE`. Tổng hợp có thể chọn giá trị làm `flush_valid` hoặc `probe_rsp_valid` lên. Đề xuất: `default` đặt valid về 0 và next-state về `IDLE`. Lượt này không đọc lại file.

### R-14 (Low) — CMO bất hợp pháp làm treo

`cmo_controller`: `o_cmo_ready = w_cmd_legal & i_rst_n_cluster` ở `IDLE`; lệnh với op dự phòng hoặc hart không hoạt động không bao giờ được nhận, bên gửi chờ vô hạn. Với decoder hiện tại không xảy ra. Nên có đường trả lỗi.

### R-15 (Medium) — Nền hiệu năng và hệ thống

| Điểm | Chi tiết |
|---|---|
| Core | CVA6 in-order, single-issue; scoreboard 8; BTB 32, BHT 128; RAS 2 (PF-01). CVA6S+ cho +34% đến +43% IPC (RV32, nguồn ngoài, chưa kiểm lại) |
| Line 16 B ở mọi cấp | Nhiều giao dịch coherence và metadata directory trên mỗi byte; burst AXI 2 beat; 1500 B cần ~94 CBO (PF-02) |
| Băng thông | Một cổng AXI 64-bit và một cổng MMIO 64-bit chung cho 2 hoặc 4 hart; spec chưa có tính toán băng thông (PF-03) |
| Đường miss | Cấp context, lookup, PREPARE, writeback owner, COMMIT, cập nhật directory, refill nối tiếp (PF-04) |
| DMA | Không coherent, không ACE (hoãn); phải dùng CBO hoặc vùng uncached (SYS-03). Chỉ một vùng cacheable (region 0, lũy thừa của 2); LLC cached range lấy từ region 0, đã được `addr_decode` kiểm tra |
| I-cache | Không snoop; mỗi hart tự thực hiện FENCE.I |
| Atomics | Cached AMO và LR/SC thực thi ở L1 có CCU bảo vệ (10 ca CPU). Uncached ATOP chỉ có đường truyền, chưa verify. Đây là phần của SYS-01 đã thu hẹp lại |
| 2 hart | RTL vẫn instantiate 4 `axi_route` và `axi_mux` 4 cổng; synthesis cắt nhưng RTL không phản ánh cấu hình dual |

Mục tiêu hiệu năng cụ thể (IPC, GB/s, độ trễ) vẫn chưa có (HDS: "no target"). Đề xuất theo thứ tự lợi ích trên chi phí: kiểm chứng PMU và đo IPC trên workload thật; giảm tuần tự hóa (reservation theo way, nhiều target mỗi hart nếu cache hỗ trợ); không chặn L1 đến B của dirty replacement khi không lỗi; đánh giá line 64 B và bus rộng hơn; nâng core nếu yêu cầu thực sự là high-performance.

### R-16 (Medium) — Chi phí duy trì cache

`DcacheFlushOnFenceI=1` buộc FENCE.I quét 2048 line (tối đa 4096 beat W cộng 2048 B response); CBO chỉ theo từng line 16 B, không có theo dải hay flush-all, chưa có Zicboz; không ECC cho L1 (`DcacheEccEnable=0`), LLC và directory, trong khi Event_Map vẫn định nghĩa event ECC. HDS chấp nhận các điểm này; vẫn cần quyết định cho ứng dụng đòi hỏi độ tin cậy.

### R-17 (Medium) — Low-power và debug

Không đổi từ review 11-09 (spec ghi ngoài phạm vi v1):

- **Low-power.** Không có `o_hart_wfi`, `o_hart_quiet`, `o_cluster_idle`; WFI chỉ dừng pipeline; không có quy trình hart rời hoặc vào miền coherence; không có SRAM sleep; clock gating chưa chỉ định; chưa có hợp đồng DVFS và UPF. Điểm tốt: directory thay broadcast giúp giảm lưu lượng snoop khi tăng hart.
- **Debug.** Chỉ có `i_hart_debug_req` và `o_hart_debug_mode` (router chỉ là dây nối). Thiếu reset từng hart, `resethaltreq`, `havereset`, halt/resume group, trace, CSR chẩn đoán CCU; System Bus Access của DM không thấy dữ liệu dirty trong cache nếu không có chính sách CBO.
- Hai điểm này quyết định cluster có đạt yêu cầu "high-performance, low-power, debug được" ban đầu không; xếp ưu tiên thấp theo phạm vi HDS nhưng cần chủ dự án xác nhận (Q5).

### R-18 (Low) — Tài liệu

| Điểm | Chi tiết |
|---|---|
| HDS quá dài | ~9.700 dòng trên đĩa (review 11-16 ghi 9.163 dòng); mục 14 chiếm khoảng 7.500 dòng hợp đồng component. Khó review, dễ lệch RTL; cần bản tóm tắt và công cụ so khớp port và tham số |
| Đoạn cũ còn sót | Audit B-05: một số DEP và header RTL còn nói thiếu tính năng đã có (ví dụ header wrapper LLC) |
| Comment sai trong core (mới, đã đọc lại) | [cluster_core.sv:335-336](../../../rtl/non_coherence_cluster/m_vlsit_riscv_cluster_core.sv:335) nói handshake CMO "chưa nối"; thực tế đã nối qua `u_vlsit_riscv_cmo_arbiter` và controller |
| Header TOP mâu thuẫn (mới, đã đọc lại) | [cluster_axi_top.sv:41](../../../rtl/non_coherence_cluster/m_vlsit_riscv_cluster_axi_top.sv:41) ghi "4-KiB CSR and LLC windows"; change history cùng file ghi aperture 24-KiB |
| Rule check spec | `vlsit_spec_tool.py check` FAIL 1 lỗi: dòng tiếng Việt (R-005). HDS cố ý song ngữ, quyết định đã ghi; cần waiver chính thức để không FAIL âm thầm |
| Cảnh báo rule RTL | NAM-08 (`cnt`, `err`, `arb`), HIE-02 (adapter có chủ đích) |
| Traceability | Nên có cột "RTL status" và "bằng chứng đã chạy" cạnh mỗi REQ để tránh hiểu nhầm spec-first thành đã verify |

### R-19 (Low) — Vệ sinh repo

- Git chỉ có một commit khởi tạo cho ~7.600 file; lịch sử thay đổi chỉ nằm trong comment "Change History".
- Working tree hiện đang dở dang: `git status` cho thấy hàng trăm file `doc/` bị xóa hoặc chuyển sang `project_support`; file review này nằm ở `doc/specification/review/` (chưa được theo dõi).
- Artifact sinh ra bị theo dõi: ~79 file `.vcd`, mã C++ do Verilator sinh, file `.pyc`.
- Bản sao trùng lặp: `scripts/third_party`, `verification/common/third_party` lặp `rtl/common/third_party`.
- Filelist dùng đường dẫn tuyệt đối; cần sinh lại khi chuyển máy.
- `coh_fabric.sv` chèn khối "Change History" giữa file, khó đọc.

## 2A. Phân tích timing GF55 800 MHz (Design Compiler) và VP1902 (Vivado), 2 hart

Danh sách start point, end point nguyên văn của từng violation và đường RTL tương ứng nằm ở mục 2A.9.

| Mục | Nội dung |
|---|---|
| Đối tượng | `m_vlsit_riscv_cluster_axi_top`, `PARA_CPU_NUM=2` |
| Nguồn số liệu | `dual_gf55_800.zip` (synthesis DC X-2025.06-SP5, ARM sc12 55LPx RVT, chạy 2026-11-17); `vp1902.zip` (Vivado 2025.1, OOC, 100 MHz và 400 MHz) |
| Đã đọc | qor, area, clocks, check_timing, `qor_timing_summary_max` (10.000 endpoint), `synth_timing_{reg2reg,in2reg,reg2out,in2out}` (mỗi nhóm 2.000 path), `synth_timing_violate` (200 path), SDC, `dc_main.tcl`, `blackbox.tcl`, `qor_reference` (diện tích theo module); `post_synth/post_route_timing_summary` (40 path mỗi file), utilization theo hierarchy |
| Không đọc | `synth_power.rpt`, `.sdf`, `.ddc`, netlist `.sv`, `check_design` |
| Nhãn bằng chứng | **R** số đo trực tiếp trong report; **C** suy ra từ đọc RTL; **E** ước tính của tôi, chưa đo |
| Phương pháp | Parse bằng script riêng (không chỉnh RTL, không chạy lại công cụ). Số liệu "họ path" lấy từ 805 path đầy đủ và 10.000 endpoint, không phải toàn bộ 312.168 path vi phạm |

### 2A.0 Kết luận ngắn

| # | Kết luận | Bằng chứng |
|---|---|---|
| 1 | **Mục tiêu 800 MHz thực chất là 960 MHz (T = 1,0417 ns) ở corner SS 1,08 V 125 °C, nhưng đường dài nhất của thiết kế là 3,40 ns (46 cell).** WNS -2,47 ns, TNS -193.700 ns, 312.168 endpoint vi phạm. Lõi CVA6 (FPU, issue, ex_stage, mult) cũng nằm ở ~3,4 ns, nên không thể đạt 1,04 ns chỉ bằng sửa vài khối | R: qor.rpt, SDC dòng 9 |
| 2 | **Phần lớn đỉnh nhọn nằm ngoài vòng lặp IPC của CPU**: PMU và CSR overflow, directory CCU, biên AXI. Có thể pipeline mà không đổi IPC | R: mục 2A.2 |
| 3 | **Sharer directory là mảng flop: 206.600 flop (74% flop toàn thiết kế), 2,82 mm² (56% diện tích 5,0 mm²).** Đây cũng là họ chiếm 43% trong 10.000 endpoint xấu nhất. Chuyển sang SRAM giảm diện tích lớn nhất và sửa timing cùng lúc | R: qor_reference; C: `m_vlsit_riscv_sharer_directory.sv` |
| 4 | **Cùng một endpoint xấu nhất ở cả ASIC và FPGA**: cone ghi `irq_raw_overflow` của CSR (PMU overflow). ASIC: ICG enable `cpucl_csr clk_gate irq_raw_overflow`, -2,47 ns. FPGA 100 MHz: `CE` của `reg_irq_raw_overflow`, -1,71 ns, 29 mức LUT | R |
| 5 | **Báo cáo hiện tại lạc quan**: SRAM bị black-box (53 instance, nhóm reg2mem/mem2reg rỗng), wire-load bằng 0, clock ideal, `uncertainty` 1%. FPGA cho thấy route cộng thêm ~31% (8,35 ns lên 10,92 ns) | R |
| 6 | **Không thể "sửa hết mà không giảm hiệu năng" nếu giữ 960 MHz.** Việc có thể làm không đổi IPC là loại bỏ đỉnh nhọn (mục 2A.4) và sửa ràng buộc (mục 2A.5), sau đó chạy quét tần số để biết điểm gối thật. Nếu vẫn bắt buộc 800 MHz ở SS 125 °C thì cần cắt pipeline CVA6 (mất IPC) hoặc đổi công nghệ/lõi | E, mục 2A.6 |

### 2A.1 Thiết lập flow và ràng buộc (ảnh hưởng đến cách đọc kết quả)

| Mục | Giá trị | Nhận xét |
|---|---|---|
| Clock | `create_clock -period 1.04167` (960 MHz); uncertainty setup 0,0104 ns (1%), hold 0,0021 ns | R. Tên "800" gợi ý mục tiêu 800 MHz cộng 20% margin; uncertainty 1% quá nhỏ cho P&R thật |
| I/O | `set_input_delay` và `set_output_delay` đều 0,4167 ns (40% chu kỳ) trên 310 input, 607 output | R. Ngân sách còn lại: reg2out 0,625 ns; in2reg ≈0,5 ns; **in2out chỉ 0,208 ns** |
| Corner | `ss_nominal_max_1p08v_125c`, chỉ thư viện RVT (`sc12_base_rvt`) | R. Không có LVT/HVT nên không đổi Vt để tăng tốc |
| Chế độ | Wire-load mode "top", WLM "Zero": **không có trễ dây**; clock ideal (`CT Buf/Inv = 0`) | R |
| Lệnh compile | `compile_ultra -gate_clock -retime -no_seq_output_inversion`, `set_critical_range 0.5`, autoungroup và boundary-opt bật, không dùng `-spg` | R: runtime.log. **Retime đã bật**, nên "bật retime" không còn là đòn bẩy |
| SRAM | `tc_sram`, `hpdcache_sram_1rw`, `hpdcache_sram_wbyteenable_1rw` là black-box (53 unresolved reference) | R: blackbox.rpt. Diện tích và timing chỉ gồm logic; `synth_timing_reg2mem/mem2reg` chỉ 800 byte (rỗng) |
| Port không có clock | 66 input (`i_boot_addr[63:0]`, `i_hart_debug_req`) bị `set_input_delay` không `-clock`; hai nhóm này đã `set_false_path` | R: vô hại |
| Max fanout | 191 net vi phạm, mỗi net 22/20 | R: không đáng kể |

### 2A.2 Họ path vi phạm (GF55)

#### 2A.2.1 Thống kê

| Chỉ số | Giá trị |
|---|---|
| WNS / TNS / số endpoint vi phạm | -2,47 ns / -193.700 ns / 312.168 |
| Vi phạm trung bình | 0,62 ns (TNS chia số endpoint) |
| 10.000 endpoint xấu nhất | từ -2,47 đến -2,05 ns, tức đều có arrival ≥ 3,05 ns |
| Sequential cell / tổng leaf cell | 280.250 / 947.709 |
| Mức logic đường tới hạn | 46 |

Gần như mọi flop đều vi phạm, nhưng vi phạm **trung bình chỉ 0,62 ns**, trong khi đuôi dài đến 2,47 ns. Ước tính (E): 10.000 endpoint đuôi (≈3% số endpoint vi phạm) chiếm khoảng 12% TNS, phần lớn endpoint còn lại có arrival khoảng 1,6 ns. Do `critical_range = 0,5` và WNS lớn, DC chỉ tối ưu cửa sổ -2,47 đến -1,97 ns, nên số 3,4 ns của từng khối là giá trị "DC dừng", chưa phải trần vật lý của khối đó.

#### 2A.2.2 Phân bố 10.000 endpoint xấu nhất theo khối

| Khối | Số endpoint | Worst slack (ns) | Thuộc vòng lặp IPC? |
|---|---:|---:|---|
| `sharer_directory` (CCU) | 4.319 | -2,42 | Không (đường chậm của coherence) |
| CVA6 issue/scoreboard | 1.552 | -2,42 | **Có** |
| PMU counter bank | 1.040 | -2,46 | Không |
| FPU (fpnew) | 919 | -2,41 | Chỉ với mã dùng FP |
| CVA6 ex_stage | 912 | -2,41 | **Có** |
| mult/div | 418 | -2,40 | Có (mult), div đa chu kỳ |
| frontend | 290 | -2,44 | **Có** |
| LLC | 196 | -2,37 | Không (đường miss) |
| id_stage | 138 | -2,36 | Có |
| D-cache/HPDcache, tile_coh_adapter, coh_fabric, hpd_probe, icache, commit | ≈160 | -2,2 đến -2,4 | Một phần |

#### 2A.2.3 Theo nhóm path (các nhóm `group_path` của flow)

| Nhóm | Path vi phạm báo cáo | Họ chính | Worst |
|---|---:|---|---:|
| `clk_cluster` (mọi path kết thúc ở ICG enable) | 200 | 160 `COHFAB` FSM tới directory; 16 CSR/PMP tới scoreboard; 13+ LSU tới PMU | -2,47 |
| `reg2reg` | 2.000 | 616 LSU tới PMU; 487 FPU tới FPU; 319 I-cache tới PMU; 206 issue tới issue; 93 issue tới ex_stage; 60 issue tới mult | -2,46 |
| `in2reg` | 2.000 | **1.024 `i_axi_mem_bid[6]` tới PMU**; 729 tới LSU; 157 `i_axi_mem_rvalid` tới LLC | -2,41 |
| `reg2out` | 359 | LLC / `axi_mem_mux` tới `o_axi_mem_rready` (và `o_axi_mem_wdata`) | -2,39 |
| `in2out` | 5 | `i_axi_mem_rid[6]` tới `o_axi_mem_rready` (arrival 2,72 ns, ngân sách 0,208 ns) | -2,11 |

#### 2A.2.4 Phân tích chi tiết các họ chính

##### H1 — Chuỗi PMU/CSR overflow (xấu nhất toàn thiết kế)

- **Đường dẫn** (ASIC, path #1, 46 cell, 3,40 ns): flop `itlb_tags_q` của LSU, qua ITLB compare, qua I-cache tag, vào tín hiệu `miss_o` (event tap), qua `m_vlsit_pmu_event_select` (mux theo `event_id`/`scope` của 16 counter), cộng 3-bit vào bộ đếm 64-bit trong `m_vlsit_pmu_counter_bank`, lấy carry-out thành `ovf`, qua `m_vlsit_pmu_irq` (`o_irq_raw_we` là OR của 16 `ovf`) tới ICG enable của `reg_irq_raw_overflow` trong `m_vlsit_cpucl_csr`.
- **Họ đồng dạng.** In2reg: `i_axi_mem_bid[6]` tới counter (qua sự kiện LLC). CCU: `COHFAB` tới counter (qua `o_ccu_evt_count`). FPGA 100 MHz: `reg_fsm_ctx_current_state` (CCU) tới `reg_irq_raw_overflow/CE`, 29 mức LUT, 10,92 ns. FPGA 400 MHz: `icache vaddr_q` tới cùng `CE`, 33 mức, 11,1 ns.
- **Cơ chế (C).** Sự kiện PMU là tổ hợp từ logic sâu của CPU, LLC, CCU (ví dụ `o_ccu_evt_count` đếm handshake của `coh_fabric`, [coh_fabric.sv:912-945](../../../rtl/common/vlsit/coherence/m_vlsit_riscv_coh_fabric.sv:912)). Các sự kiện đi thẳng qua `aggregate` (cộng), `event_select` (mux 16 × 38+ nguồn), bộ cộng 64-bit và OR-reduction 16 carry, **không có thanh ghi ở giữa**. Khối này không nằm trong đường dữ liệu chức năng của CPU.
- **Hệ quả.** Vì không có flop cắt, chu kỳ của PMU bằng cộng dồn của logic nguồn sự kiện (sâu nhất của cluster) với cộng-chọn-cộng của PMU.

##### H2 — Sharer directory và CCU fabric

- **Đường dẫn.** `reg_fsm_ctx_current_state` của `coh_fabric`, qua phân xử bank (`bank_arb`) và `o_lookup_ready` của directory, rồi ra enable của `reg_dir_plru`, `reg_dir_state` và các mảng khác (160 path ICG và 47 path reg2reg trong 2.000 path).
- **Cơ chế (C).** [sharer_directory.sv](../../../rtl/common/vlsit/coherence/m_vlsit_riscv_sharer_directory.sv) đọc mảng flop `reg_dir_tag/holders/owner/state/valid[4][SET][8]` bằng mux theo set (128 set mỗi bank ở 2 hart), so sánh 8 tag song song, chọn hit/victim, đọc holders/owner/state theo way, tất cả trong **một chu kỳ**. Đầu ra `o_lookup_ready` còn phụ thuộc `w_lookup_set_busy` (đọc mảng reservation theo set), nên cùng cone đi tiếp vào enable của chính mảng đó.
- **Quy mô.** 4.096 entry × ~50 bit = 206.600 flop (qor_reference: `m_vlsit_riscv_sharer_directory` 2.820.987 µm², trong đó flop 2.097.281 µm²). `coh_fabric` (chứa directory) là 2.910.960 µm² trên 4.998.071 µm² toàn thiết kế.
- **FPGA.** 211.838 FF và 75.670 LUT (post-synth), cùng ~729.000 FF cho SRAM của hai HPDcache, **không BRAM/URAM**. 77.661 control set (14,7%) do mỗi entry flop có CE riêng.

##### H3 — Biên AXI memory (combinational xuyên cluster)

- `o_axi_mem_rready` là hàm tổ hợp của `i_axi_mem_rid/rvalid` và trạng thái FIFO `r_switch` của LLC, qua ~40 cell (reg2out 3,0 ns; in2out 2,72 ns). Chuỗi đi qua `axi_mem_mux`, `axi_llc` (demux theo ID), `axi_dw_converter` ([axi_dw_adapter.sv](../../../rtl/non_coherence_cluster/m_vlsit_riscv_axi_dw_adapter.sv)) và `axi_route`.
- `i_axi_mem_bid[6]` tới LSU/D-cache/CCU (729 + 30 + 9 path): phản hồi B/R từ ngoài đi **tổ hợp** vào bên trong tile. Ngân sách in2reg chỉ ≈0,5 ns sau input delay.
- Mô hình I/O 40% và đường tổ hợp vào-ra làm các path này không thể đóng ở bất kỳ chu kỳ nào dưới ~3 ns.

##### H4 — Lõi CVA6 (issue, scoreboard, FPU, mult, LSU, PMP)

- **FPU→FPU** (487 trong 2.000 reg2reg): `fpnew` với `PipeRegs` FP32/FP64 = 2/3 (`LAT_COMP_FP32=2`, `LAT_COMP_FP64=3`), `LAT_DIVSQRT=2`, `PipeConfig: DISTRIBUTED`.
- **Issue/scoreboard/ex_stage/mult:** 206 + 93 + 60 + 38 path. CVA6 single-issue với scoreboard 8 entry; đây là các vòng bypass, wake-up, hazard.
- **CSR/PMP tới scoreboard ICG** (16 path): `pmpaddr_q` (8 PMP entry) qua so sánh địa chỉ rồi tới exception, enable của `mem_q` trong scoreboard.
- **LSU/ITLB:** ITLB 16 entry so sánh tag song song rồi tới `icache_areq` (path #1 đi qua đây trước khi vào PMU).
- Các khối này đều ở ~3,4 ns trong lần chạy này. Đây là vòng lặp IPC (bypass, AGU→TLB→tag D-cache), nên **không thể cắt thêm pipeline mà không mất IPC**.

##### H5 — Vi phạm ở mức thấp hơn

LLC (`reg2out` tới `o_axi_mem_wdata`: -1,74 ns), `i_dcache` tới `axi_mmio` (-0,68 ns, 73 path), `rst_n` tới `o_axi_mem_wvalid` (-0,60 ns, in2out). Đều là biên I/O, cùng cách sửa với H3.

### 2A.3 Kết quả FPGA VP1902 (2 hart, OOC)

| Chỉ số | 100 MHz post-synth | 100 MHz post-route | 400 MHz post-synth | 400 MHz post-route |
|---|---:|---:|---:|---:|
| WNS (ns) | +1,130 | **-1,708** | -6,381 | -9,145 |
| TNS (ns) | 0 | -309.858 | -6.436.382 | -16.232.066 |
| Endpoint vi phạm | 0 | 616.530 | 2.223.106 | 2.904.959 |
| Đường dữ liệu dài nhất (ns) | 8,35 | 10,92 | ≈8,9 (T − WNS, suy ra) | 11,11 |
| Mức logic | 37 | 29 | không đọc | 33 |
| Tỷ lệ trễ route | 67% | 77% | không đọc | 73% |

| Quan sát | Chi tiết |
|---|---|
| Đường tới hạn cho cả hai tần số | Cùng một đường dài ~8,4 ns (synth) và ~10,9 đến 11,1 ns (route). **Tần số tối đa ≈ 113 MHz sau synth, ≈ 85 MHz sau route** (tính từ T − WNS) với cấu hình này. 400 MHz (2,5 ns) cách xa ~4,5 lần, nên không có ý nghĩa làm bài kiểm tra "board clock limit" |
| Họ path xấu nhất | `coh_fabric FSM` hoặc `icache vaddr_q` tới `cpucl_csr reg_irq_raw_overflow/CE` (cùng H1); `issue_stage csr_valid_q` tới `fu_data operand_a` (20 mức, route 85%); `scoreboard commit_pointer` hoặc LLC `i_b_mux lock_q` tới `hpdcache data_sram` (18 đến 19 mức, route 85%) |
| Nguyên nhân gốc về diện tích | **Không có BRAM/URAM**: ~729.000 FF trong SRAM của HPDcache (mỗi tile 4 hàng × 65.664 FF), 211.838 FF directory, 91.136 LUTRAM cho LLC. Toàn bộ nằm trong SLR0 (SLICE 55,7%, LUT 33%), 77.661 control set |
| Hold | Đạt (WHS +0,013 đến +0,032 ns) |
| Ràng buộc | 355 input và 436 output không có delay (OOC); không ảnh hưởng kết luận setup |

README của VP1902 đã chỉ ra đúng các điểm cần RTL team xác nhận (mô hình SRAM cho FPGA, latency đọc, trễ directory, đường overflow). Kết quả FPGA xác nhận H1 và vấn đề flop-array độc lập với ASIC.

### 2A.4 Đề xuất sửa — không đổi IPC (hoặc đổi không đáng kể)

Phân loại theo tác động đến hiệu năng: **A** không ảnh hưởng thực thi lệnh; **B** thêm vài chu kỳ vào đường chậm (miss, phản hồi); **C** ảnh hưởng IPC chỉ với một loại workload.

| ID | Sửa | Loại | Họ giải quyết | Ước lượng tác động (E) |
|---|---|---|---|---|
| F1 | Pipeline chuỗi PMU/CSR overflow | A | H1 | Đường này từ ~3,4 ns xuống ≤ ~1,2 ns; chiếm ~10% endpoint đuôi và cả hai đường xấu nhất ở ASIC/FPGA |
| F2 | Chuyển directory sang SRAM, pipeline 2 tầng | B | H2 | −2,5 mm² (−50% diện tích), −206.000 flop; đường chậm nhất của CCU xuống ≲ 1,5 ns |
| F3 | Register slice cho biên AXI mem/MMIO; `rready` từ flop | B | H3 | Bỏ đường in2out/in2reg ~2,7 ns; cộng 1 đến 2 chu kỳ mỗi chiều cho đường ra bộ nhớ |
| F4 | Sửa ràng buộc và flow (mục 2A.5) | A | tất cả | Cho số đo thật, không đổi RTL |
| F5 | Quét tần số trước khi tối ưu tiếp | A | H4 | Xác định trần thật của CVA6 |
| F6 | FPU: thêm 1 tầng pipe cho FP64 ADDMUL/DIVSQRT (tùy chọn) | C | H4 (FPU) | Chỉ ảnh hưởng mã FP phụ thuộc; mã số nguyên không đổi |
| F7 | FPGA: ánh xạ SRAM (HPDcache, I-cache, directory) vào BRAM/URAM | A | FPGA H1, H2 | −~940.000 FF; bỏ phần lớn trễ route 77% |

#### F1. Pipeline PMU/CSR overflow (A)

Sửa trong [pmu/](../../../rtl/common/vlsit/pmu/) và nối ở [cluster_core.sv](../../../rtl/non_coherence_cluster/m_vlsit_riscv_cluster_core.sv):

1. **Đăng ký các tap sự kiện tại đầu vào `m_vlsit_riscv_pmu`** (`i_cva6_evt`, `i_hpdcache_evt`, `i_llc_evt`, `i_ccu_evt_count`): ≈ 2×(22+16) + 28 + 36 = 140 flop. Cắt toàn bộ cone sự kiện của CPU/LLC/CCU khỏi PMU.
2. **Đăng ký sau `aggregate` và `event_select`:** 16 counter × 3 bit = 48 flop. Cắt tiếp mux 16×38+ và phép cộng.
3. **Tách bộ cộng 64-bit thành 4 đoạn 16-bit với carry đăng ký:** `[15:0] + evt`, carry flop sang `[31:16]`, rồi `[47:32]`, `[63:48]`. Mỗi đoạn ≤ 16 bit (~10 mức). Đoạn trên trễ tối đa 3 chu kỳ so với đoạn dưới.
4. **Đăng ký `ovf` và `o_irq_raw_we`** trước khi vào CSR; thay OR-reduction 16 đầu vào bằng cây có flop ở giữa.
5. **Snapshot:** giữ nguyên handshake `snapshot_req`/`done` nhưng chờ 3 đến 4 chu kỳ cho carry ổn định trước khi chốt (snapshot đã là thao tác đa chu kỳ qua phần mềm).

Ảnh hưởng: không đổi hành vi CPU. Giá trị bộ đếm lệch hằng số ~2 đến 4 chu kỳ so với sự kiện thật, cần ghi vào HDS (mục PMU, 10.5.7) và workbook CSR. Cần test lại: snapshot đồng thời tràn, W1C đồng thời tràn (xem R-11), 32/64-bit. Sửa kèm lỗi W1C bị phần cứng ghi đè vì cùng chạm `pmu_irq`.

#### F2. Sharer directory sang SRAM (B)

Sửa trong [sharer_directory.sv](../../../rtl/common/vlsit/coherence/m_vlsit_riscv_sharer_directory.sv):

1. **Lưu trữ:** mỗi bank một SRAM rộng 8 way × ~50 bit (tag, holders, owner, state, valid), nhiều entry theo số set (128 ở 2 hart, 256 ở 4 hart), có way-write-enable. Chỉ cần 4 macro mỗi cấu hình. PLRU (7 bit), `resv_valid` và `resv_tag` mỗi set (≈ 6.000 flop) giữ ở flop vì cần đọc tổ hợp cho điều kiện eligible.
2. **Pipeline 2 tầng:** tầng 0 arbiter chọn thao tác theo `resv` (flop) và phát địa chỉ đọc; tầng 1 SRAM trả dữ liệu, so sánh 8 tag, chọn hit/victim và đăng ký phản hồi (`reg_lookup_*` đã sẵn là thanh ghi, chỉ cần dời một tầng).
3. **Tách `o_lookup_ready` khỏi mảng dữ liệu:** `ready` chỉ phụ thuộc `valid`, `resv` và `rsp_slot_ready`; không đọc `tag`/`way`.
4. **Race:** lookup và update cùng set đã bị chặn bởi reservation theo tag; update của chủ reservation xóa reservation cùng chu kỳ, lookup tiếp theo thấy dữ liệu mới (SRAM ghi trước đọc sau ở các chu kỳ khác nhau).
5. **Khởi tạo:** SRAM không có reset, cần FSM xóa `valid` sau reset (128/256 chu kỳ), giữ `cluster_ready` thấp trong thời gian này; HDS đã ghi "DEP-013" mở cho điểm này.

Ảnh hưởng: mọi L1 miss đi qua lookup directory, nên đường miss cộng 2 chu kỳ (E). Với tỷ lệ miss L1 ví dụ 10 MPKI và miss penalty ≥ 30 chu kỳ, đó là ~20 chu kỳ mỗi 1.000 lệnh, ~1 đến 2% CPI; không ảnh hưởng đường L1-hit. Có thể bù lại bằng cách phát đọc LLC/refill song song với lookup directory (cache-to-cache và memory prefetch song song, đề xuất đã nêu ở review 11-09), nhưng đây là thay đổi lớn hơn, nên đo trước.

Ước tính diện tích (E): 213 kbit SRAM macro 55LPx ≈ 0,2 đến 0,4 mm² thay cho 2,82 mm² flop. Cần số macro thật của nhà cung cấp. Tác động R-06 (directory 1:1 với L1D) được giải quyết một phần khi dung lượng SRAM rẻ: có thể tăng lên 2× entry mà vẫn nhỏ hơn bản flop.

#### F2a. Đánh giá khả thi: directory dùng RAM model thay thế được bằng RAM macro

**Kết luận: khả thi, sửa ít.** Thay đổi nằm gần như hoàn toàn trong `m_vlsit_riscv_sharer_directory.sv` (456 dòng) cộng một wrapper RAM mới. Cổng của module giữ nguyên. Bằng chứng: C (đã đọc `sharer_directory`, `coh_fabric` và 3 testbench), chưa mô phỏng.

**Vì sao phù hợp với RAM macro:**

1. **Mỗi bank chỉ làm một thao tác mỗi chu kỳ** (lookup, update hoặc cancel, do arbiter chọn). Mỗi bank cần đúng một RAM 1 cổng đọc/ghi.
2. **`coh_fabric` không phụ thuộc latency lookup.** FSM chờ ở `ENUM_ST_DIR_WAIT` đến khi phản hồi hợp lệ khớp tag context ([coh_fabric.sv:970](../../../rtl/common/vlsit/coherence/m_vlsit_riscv_coh_fabric.sv:970)). Thêm 1 chu kỳ không cần đổi fabric.
3. **Không có xung đột đọc-ghi cùng set.** Reservation theo tag chặn mọi thao tác khác vào set đó cho đến khi chủ giải phóng.
4. **Luồng black-box SRAM đã có sẵn.** `blackbox.tcl` giữ danh sách leaf như `hpdcache_sram_1rw`; chỉ cần thêm tên wrapper mới vào danh sách và để model hành vi ngoài filelist synthesis.

**Phân chia lưu trữ đề xuất:**

| Phần | Nơi lưu |
|---|---|
| `tag`, `holders`, `owner`, `state` (~49 bit × 8 way) | RAM: 4 bank × 1 RAM 1RW, ghi theo mặt nạ way |
| `valid` (8 bit/set), PLRU (7 bit/set), `resv_valid`, `resv_tag` | Giữ ở flop |

`valid` ở flop nghĩa là RAM không cần reset và không cần FSM khởi tạo; phần tìm way trống và điều kiện eligible không đọc RAM. Flop còn lại khoảng 10.000, giảm từ 206.600 (E, ~95%).

**Pipeline lookup:** chu kỳ t cấp địa chỉ đọc và đặt reservation như hiện nay; chu kỳ t+1 lấy dữ liệu RAM, so 8 tag, chọn hit/victim, cập nhật PLRU rồi nạp `reg_lookup_*`. Phản hồi hợp lệ sớm nhất ở t+2, tức **+1 chu kỳ** so với hiện tại. Bank chỉ nhận lookup mới khi không còn lookup đang bay, nên tốc độ lookup mỗi bank là 1 lần mỗi 2 chu kỳ; update và cancel không bị ảnh hưởng.

**Khối lượng sửa (E):**

| Việc | Quy mô |
|---|---|
| `sharer_directory.sv`: bỏ 4 mảng flop, đọc/ghi qua RAM, thêm tầng lookup trung gian | ~120 đến 150 dòng đổi |
| Wrapper mới `m_vlsit_riscv_dir_sram` (1RW: `cs/we/addr/wdata/wmask/rdata`) kèm model hành vi | ~50 dòng |
| Filelist (model chỉ cho simulation) và danh sách black-box của `blackbox.tcl` | vài dòng |
| 3 testbench đọc trực tiếp `reg_dir_*` (`tb_m_vlsit_riscv_coh_fabric`, `tb_coh_bank_tag`, `tb_holder_fabric`); phần lớn chỉ in debug bank 0 set 0 | sửa nhỏ |

**Điểm cần lưu ý:**

- **Hình dạng macro.** 128 (dual) hoặc 256 (quad) × ~392 bit rất rộng. Việc chia lát bit hay chia theo way là việc nội bộ của wrapper; chọn theo macro compiler thực tế của GF55.
- **Timing sau RAM.** clk→Q của macro cộng so sánh 8 tag có thể không đủ ở chu kỳ ngắn; nên đặt latency đọc thành tham số (1 hoặc 2 tầng).
- **Đường ghi RAM.** `we` suy ra từ handshake update (tổ hợp từ arbiter), có thể thành đường tới hạn; cần kiểm lại sau synthesis.
- **Mô phỏng.** Model RAM cần khởi tạo về 0 chỉ khi simulation để tránh X lan sang các nhánh không dùng dữ liệu; các nhánh hit/victim đã được bảo vệ bởi `valid`.
- **Verification.** Cần test song song so sánh với bản cũ (so nội dung phản hồi, bỏ qua latency), test backpressure phản hồi và đường victim, rồi chạy lại A-04, A-05 và test coherence ngẫu nhiên (R-04).

Đề xuất thực hiện: viết wrapper và module mới, giữ bản cũ để so sánh song song trước khi thay thế.

#### F3. Biên AXI (B)

1. Thêm `axi_cut`/spill register (full-throughput, 2 entry) trên R và B response ngay tại cổng vào của cluster (sau `m_vlsit_riscv_axi_dw_adapter`), và trên AR/AW/W ở cổng ra. `rready`, `bready` ra ngoài lấy từ flop (trạng thái đầy/rỗng của slice), không phụ thuộc `rid/rvalid`.
2. Áp dụng tương tự cho `o_axi_mmio_*` và AXI4-Lite nếu SoC không có sẵn slice.
3. Với DC: với đường in2out, sau khi có slice không còn path tổ hợp vào-ra; ngân sách I/O 40% sẽ đủ.

Ảnh hưởng: +1 chu kỳ mỗi chiều (request, response) trên đường tới LLC/DRAM; throughput giữ nguyên với slice 2 entry. Với miss LLC (≥ ~100 chu kỳ), +2 đến 3 chu kỳ là ≲ 3% trên mã bị chặn bởi bộ nhớ ngoài (E).

#### F4. Ràng buộc và flow (A)

| Việc | Lý do |
|---|---|
| Thêm model timing cho SRAM (đưa `.lib/.db` macro vào link) | Bỏ black-box, để `reg2mem`/`mem2reg` có số thật. Đường D-cache/I-cache hit sẽ nhận clk→Q và setup của macro, thường 1 đến 1,8 ns ở SS (E); đây là **đường IPC**, không cắt được, nên cần chọn macro đủ nhanh hoặc chia bank |
| Chuyển sang DC Topographical hoặc `-spg` với floorplan, hoặc ít nhất dùng WLM thực | WLM = 0 làm thiết kế lạc quan. FPGA cho thấy trễ route chiếm 67% đến 77% đường dài nhất (cộng ~31%) |
| Tăng `set_clock_uncertainty` setup lên 5 đến 8% chu kỳ; thêm `set_clock_latency`/skew | 1% quá lạc quan so với P&R |
| Đặt I/O delay theo chuẩn SoC (20 đến 30% cho AXI nếu SoC register-slice cả hai phía) | 40% + 40% chỉ để lại 0,208 ns cho in2out |
| Thêm thư viện LVT (nếu PDK có) cho nhóm path kiểm soát | Tăng tốc 10 đến 20% không đổi RTL, đổi lấy leakage |
| Giảm `set_max_fanout 20` thành giới hạn thực tế hoặc loại các net báo 22/20 | 191 net vi phạm 22/20 là nhiễu |
| Tăng `critical_range` hoặc chạy nhiều pass theo từng khối | Với `critical_range 0,5` và WNS 2,5 ns, DC chỉ làm việc trên phần đuôi, bỏ qua phần lớn path vi phạm 0,6 ns |

#### F5. Quét tần số trước khi sửa tiếp (A)

Chạy cùng flow với T = 2,0; 2,5; 3,0; 3,5 ns (500, 400, 333, 286 MHz) sau F1 đến F4, để DC tối ưu theo từng khối thay vì dừng ở cửa sổ -2,47 đến -1,97. Từ kết quả:

- Nếu khối X đóng ở 3,0 ns mà thất bại ở 2,0 ns thì X là khối giới hạn thật; xử lý X bằng sizing/Vt hoặc, chỉ khi cần, bằng pipeline có tính toán IPC.
- Dùng cùng danh sách họ path ở mục 2.3 làm checklist hồi quy.

#### F6. FPU (C, tùy chọn)

`LAT_COMP_FP64 = 3`, `LAT_DIVSQRT = 2`. Thêm một tầng pipeline cho FP64 ADDMUL tăng latency lệnh FP phụ thuộc thêm 1 chu kỳ; mã số nguyên không đổi. Chỉ thực hiện nếu F5 cho thấy FPU là khối giới hạn sau khi các khối khác đã đóng. DC `-retime` đã bật nên cần sửa ở `PipeRegs` (`rtl/common/modified/cva6/core/fpu_wrap.sv`) chứ không phải chỉ cờ synthesis.

#### F7. FPGA (A)

1. Cho `hpdcache_sram_1rw`, `hpdcache_sram_wbyteenable_1rw`, `tc_sram` và mảng directory (sau F2) một mô hình **đồng bộ, đọc 1 chu kỳ, không reset trên mảng nhớ** để Vivado suy ra BRAM/URAM (`ram_style`). Mỗi tile có 4 hàng data × 65.664 FF hiện bị tổng hợp thành flop.
2. Xác nhận với RTL team: độ trễ đọc, byte-enable, read-during-write (câu hỏi đã nêu trong README VP1902).
3. Sau thay đổi, cắt ~940.000 FF (729.000 HPDcache + 211.838 directory) và 77.661 control set, trong khi design vẫn nằm trong SLR0.
4. Đường dẫn mới gồm đọc BRAM: nên bật `DOB_REG`/output register khi cần.

### 2A.5 Ước tính kết quả sau từng bước (E, cần xác nhận bằng chạy lại)

| Bước | Thay đổi | WNS kỳ vọng ở 1,04 ns | Ghi chú |
|---|---|---|---|
| Hiện tại | — | -2,47 ns (T_min ≈ 3,5 ns) | R |
| F1 + F3 | Bỏ PMU, bỏ đường in2out/in2reg | ≈ -2,4 | Các họ H1 và H3 biến mất nhưng FPU/issue/ex_stage/mult/directory vẫn ~3,4 ns; WNS gần như không đổi vì chúng cùng "gối" |
| + F2 | Directory sang SRAM | ≈ -2,4 đến -2,2 | Bỏ họ 43% endpoint đuôi và 56% diện tích; kéo theo số endpoint vi phạm giảm mạnh |
| + F4/F5 | Số đo thật + quét tần số | T_min ≈ 2,5 đến 3,5 ns ở SS 125 °C sau P&R thực | Dựa trên bản chất vòng lặp CVA6; cần chạy mới xác nhận |

Nghĩa là: **WNS tại 1,04 ns không đổi nhiều sau F1 đến F3 vì lõi CVA6 cũng ở ~3,4 ns**, nhưng F1 đến F3 vẫn bắt buộc vì (a) giảm TNS và số endpoint vi phạm (đa số nằm ở PMU, directory, biên), (b) giải phóng 56% diện tích, (c) là điều kiện để các lần chạy sau nhìn thấy trần thật của CVA6.

### 2A.6 Về mục tiêu 800/960 MHz và "không giảm hiệu năng"

Hiệu năng ≈ IPC × f. Với CVA6 single-issue, các vòng IPC gồm bypass ALU, wake-up scoreboard, AGU→TLB→tag D-cache, dự đoán nhánh. Chúng đang ở ~3,0 đến 3,4 ns ở SS 125 °C, WLM 0, chưa tính SRAM, chưa tính route.

| Phương án | Tác động IPC | Tác động f | Nhận xét |
|---|---|---|---|
| **A. Giữ kiến trúc, đặt mục tiêu theo trần thật** (F1 đến F5) | 0 đến −2% (F2, F3) | Chốt tại điểm gối do F5 xác định | Phương án duy nhất bảo toàn IPC. Có thể là 300 đến 350 MHz ở SS 125 °C trong công nghệ này (E, cần đo) |
| B. Cắt pipeline CVA6 (thêm tầng ở fetch, issue, LSU, bypass) | −10 đến −30% (E) | +30 đến 60% (E) | Trái yêu cầu "không giảm hiệu năng", rủi ro verification lớn |
| C. Đổi công nghệ (ví dụ node nhanh hơn 55LP) hoặc đổi corner đặt mục tiêu (TT thay SS) | 0 | ×2 đến ×3 | Cần quyết định kinh doanh; CVA6 báo cáo ~1,09 GHz trên GF22 (review ngày 2026-11-09, nguồn arXiv chưa kiểm lại) |
| D. Lõi khác có pipeline sâu hơn | Tùy lõi | Tùy lõi | Ngoài phạm vi |

Không có cách RTL nào **giữ cả IPC và đạt 960 MHz** ở SS 125 °C trên 55LPx RVT: 46 mức logic của đường dài nhất và ~1,6 ns của endpoint điển hình cho thấy ngay cả phần "bình thường" của thiết kế vượt chu kỳ 1,04 ns.

### 2A.7 Thứ tự thực hiện đề xuất

| Thứ tự | Việc | Tiêu chí hoàn tất |
|---|---|---|
| 1 | F4: SDC (I/O, uncertainty), model SRAM, DC-T/`-spg` | Lần chạy mới có reg2mem/mem2reg; số đo gần P&R |
| 2 | F1: pipeline PMU/CSR + cập nhật HDS/CSR + test PMU (đang chỉ lint) | Không còn họ H1 trong danh sách 200 path xấu nhất |
| 3 | F3: register slice biên AXI | Không còn path in2out; in2reg ≤ 0,5 ns |
| 4 | F2: directory SRAM + test lại A-04, A-05, random coherence và R-04  | Diện tích giảm; họ H2 biến mất; không đổi hành vi coherence |
| 5 | F5: quét T = 2,0; 2,5; 3,0; 3,5 ns | Có bảng "khối nào đóng ở T nào" |
| 6 | Quyết định mục tiêu f theo mục 2A.6; F6 nếu cần; F7 song song cho FPGA | Mục tiêu f ghi vào HDS mục 13 (PERF) |

### 2A.8 Hạn chế của phân tích này

- Số liệu ASIC là post-synthesis, WLM 0, clock ideal, SRAM black-box; chưa có P&R.
- Chưa tái hiện các đường tới hạn bằng simulation; họ H1 và H2 được xác nhận bằng đọc RTL tương ứng, các con số IPC/diện tích ở mục 2A.4 và 2A.5 là ước tính.
- Chỉ phân tích `PARA_CPU_NUM=2`; cấu hình 4 hart có directory gấp đôi (≈412.000 flop) nên H2 sẽ nặng hơn.
- Chưa phân tích power và hold (hold 0 vi phạm ở DC; FPGA hold đạt).
- Chưa đo tỷ lệ miss L1 thực của workload; mức −1 đến −2% IPC của F2 chỉ là tính theo ví dụ 10 MPKI.

### 2A.9 Start point, end point chính xác và đường RTL tương ứng

Nguồn: `synth_timing_violate.rpt` (200 path xấu nhất), `synth_timing_{reg2reg,in2reg,reg2out,in2out}.rpt` (path xấu nhất của từng họ trong 2.000 path mỗi nhóm) và `post_{synth,route}_timing_summary.rpt` của VP1902. Tên đúng như trong report; chỉ rút gọn các tiền tố lặp lại. Số liệu slack / arrival (ns) ở T = 1,0417 ns (ASIC), 10,0 ns hoặc 2,5 ns (FPGA). Mọi giá trị trong bảng start/end là **R** (đọc từ report); cột RTL là **C** (đọc RTL, chưa mô phỏng).

**Tiền tố ASIC (DC đã flatten, ngăn cách bằng `_`):**

| Rút gọn | Tên đầy đủ trong report |
|---|---|
| `CORE_` | `u_vlsit_riscv_cluster_core_` |
| `T0_`, `T1_` | `CORE_u_vlsit_riscv_cpu_tile_array_gen_tile_0__gen_active_tile_u_vlsit_riscv_cpu_tile_u_dont_touch_cva6_` (và `gen_tile_1_`) = lõi CVA6 hart 0, hart 1 |
| `FAB_` | `CORE_u_vlsit_riscv_cpu_tile_array_u_vlsit_riscv_coh_tile_array_u_vlsit_riscv_coh_fabric` |
| `LLC_` | `CORE_u_vlsit_axi_llc_u_dont_touch_axi_llc_reg_wrap_i_axi_llc_top_raw_` |
| `PMUCNT_` | `CORE_u_vlsit_riscv_pmu_u_vlsit_pmu_cnt_bank_` |
| `FMA0` | `ex_stage_i_fpu_gen_fpu_i_fpu_gen_i_fpnew_bulk_gen_operation_groups_0__i_opgroup_block_gen_parallel_slices_0__active_format_i_fmt_slice_gen_num_lanes_0__active_lane_lane_instance_i_fma` |

`R_nnn` là thanh ghi do `compile_ultra -retime` tạo, không có tên trong RTL; cone logic của nó trùng với họ nêu ở cột RTL.

#### A. Danh sách violation ASIC (GF55)

| ID | Nhóm; slack / arrival | Startpoint | Endpoint |
|---|---|---|---|
| V-01 | clk_cluster (ICG enable); -2,4733 / 3,3998 | `T1_ex_stage_i_lsu_i/gen_mmu_i_cva6_mmu_i_itlb_tags_q_reg_10__vpn__2__3_` | `CORE_u_vlsit_cpucl_csr_clk_gate_reg_irq_raw_overflow_reg_0/latch` |
| V-02 | reg2reg; -2,4621 / 3,4584 | như V-01 | `R_310` |
| V-03 | reg2reg; -2,4604 / 3,4497 | như V-01 | `PMUCNT_reg_pmu_cnt_val_reg_15__17_` |
| V-04 | clk_cluster (ICG); -2,4612 / 3,2889 | như V-01 | `T1_gen_perf_counter_perf_counters_i_clk_gate_generic_counter_q_reg_3__0/latch` |
| V-05 | reg2reg; -2,4510 / 3,4405 | `T1_gen_cache_hpd_i_cache_subsystem_i_cva6_icache/vaddr_q_reg_12_` | `PMUCNT_reg_pmu_cnt_val_reg_10__18_` |
| V-06 | reg2reg; -2,4278 / 3,4316 | `T0_csr_regfile_i/pmpaddr_q_reg_3__37_` | `PMUCNT_reg_pmu_cnt_val_reg_5__16_` |
| V-07 | reg2reg; -2,4379 / 3,4426 | như V-01 | `T1_i_frontend/npc_q_reg_11_` |
| V-08 | reg2reg; -2,4157 / 3,4155 | `FAB_/reg_fsm_ctx_current_state_reg_5__0_` | `FAB_/u_vlsit_riscv_sharer_directory/reg_lookup_victim_pa_line_reg_3__10_` |
| V-09 | clk_cluster (ICG); -2,3309 / 3,1589 | `FAB_/reg_fsm_ctx_current_state_reg_4__1_` | `FAB_/u_vlsit_riscv_sharer_directory/clk_gate_reg_dir_state_reg_2__115__0_/latch` |
| V-10 | clk_cluster (ICG); -2,3940 / 3,3024 | `T1_csr_regfile_i/pmpaddr_q_reg_3__47_` | `T1_issue_stage_i_i_scoreboard/clk_gate_mem_q_reg_1__sbe__rd__0/latch` |
| V-11 | reg2reg; -2,3953 / 3,3909 | như V-10 | `T1_issue_stage_i_i_scoreboard/mem_q_reg_6__sbe__rd__4_` |
| V-12 | reg2reg; -2,4157 / 3,4066 | `T0_issue_stage_i_i_issue_read_operands_branch_valid_q_reg_0_` | `T0_issue_stage_i_i_issue_read_operands_fu_data_q_reg_0__imm__31_` |
| V-13 | reg2reg; -2,4145 / 3,4186 | `T1_issue_stage_i_i_issue_read_operands_branch_valid_q_reg_0_` | `T1_ex_stage_i_vaddr_to_be_flushed_reg_6_` |
| V-14 | reg2reg; -2,3955 / 3,3852 | `T1_issue_stage_i_i_issue_read_operands_mult_valid_q_reg_0_` | `T1_ex_stage_i_i_mult_i_multiplier/mult_result_q_reg_89_` |
| V-15 | reg2reg; -2,4088 / 3,4023 | `T0_FMA0/inp_pipe_operands_q_reg_1__0__13_` | `T0_FMA0/mid_pipe_sum_q_reg_1__35_` |
| V-16 | in2reg; -2,4119 / 3,4013 | `i_axi_mem_bid[6]` | `PMUCNT_reg_pmu_cnt_val_reg_0__10_` |
| V-17 | in2reg; -2,4132 / 3,4260 | `i_axi_mem_bid[6]` | `R_317` |
| V-18 | in2reg; -2,2292 / 3,2183 | `i_axi_mem_bid[6]` | `T1_ex_stage_i_lsu_i/i_store_unit_store_buffer_i/commit_status_cnt_q_reg_2_` |
| V-19 | in2reg; -2,1854 / 3,1797 | `i_axi_mem_bid[6]` | `T1_gen_cache_hpd_i_cache_subsystem_i_dcache_i_hpdcache_hpdcache_ctrl_i_hpdcache_memctrl_i/dir_req_set_q_reg_0_` |
| V-20 | in2reg; -2,2213 / 3,2284 | `i_axi_mem_rvalid` | `LLC_i_hit_miss_unit/desc_q_reg_a_x_addr__13_` |
| V-21 | in2reg; -2,1595 / 3,1556 | `i_rst_n_cluster` | `FAB_/R_281` |
| V-22 | reg2out; -2,3874 / 3,0020 | `LLC_i_llc_ways_i_r_switch_fifo_status_cnt_q_reg_0_` | `o_axi_mem_rready` |
| V-23 | reg2out; -2,1417 / 2,7563 | `LLC_i_llc_ways_i_r_switch_fifo_status_cnt_q_reg_2_` | `o_axi_mmio_rready` |
| V-24 | reg2out; -1,6346 / 2,2492 | `T0_gen_cache_hpd_i_cache_subsystem_i_dcache_i_hpdcache_hpdcache_mem_req_write_arbiter_i_req_gnt_fifo_i_gen_fifo_rptr_q_reg_0_` | `o_axi_mem_wdata[12]` |
| V-25 | reg2out; -1,4488 / 2,0633 | `CORE_u_vlsit_riscv_axi_mem_mux_u_dont_touch_axi_mux_gen_mux_i_ar_spill_reg_spill_register_flushable_i_gen_spill_reg_b_full_q_reg` | `o_axi_mem_araddr[55]` |
| V-26 | reg2out; -1,2038 / 1,8183 | `CORE_gen_axi_route_0__u_vlsit_riscv_axi_route_u_dont_touch_axi_demux_i_aw_spill_reg_spill_register_flushable_i_gen_spill_reg_b_full_q_reg` | `o_axi_mem_wvalid` |
| V-27 | in2out; -2,1073 / 2,7218 | `i_axi_mem_rid[6]` | `o_axi_mem_rready` |
| V-28 | in2out; -1,8626 / 2,4772 | `i_axi_mem_rid[6]` | `o_axi_mmio_rready` |
| V-29 | in2out; -0,7974 / 1,4120 | `i_axi_mmio_bid[4]` | `o_axi_mem_bready` |
| V-30 | in2out; -0,6036 | `i_rst_n_cluster` | `o_axi_mem_wvalid` |

Arrival của path in2reg, reg2out, in2out đã gồm `input_delay` hoặc `output_delay` 0,4167 ns.

#### B. Đường RTL tương ứng (ASIC)

| ID | Điểm đầu trong RTL | Đoạn giữa (net có tên trong report) và vị trí RTL | Điểm cuối trong RTL |
|---|---|---|---|
| V-01, V-02, V-03, V-04, V-07 | `tags_q[10].vpn[2]` của ITLB: `cva6_tlb.sv:77`; so sánh `vpn_match`: `cva6_tlb.sv:147`. ITLB có 16 entry (`InstrTlbEntries=16`, `cv64a6_imafdc_sv39_hpdcache_wb_config_pkg.sv:194`) | Net `lsu_i/icache_areq_o[218]`, `icache_areq_o[1]`: đường địa chỉ fetch qua `cva6_mmu.sv:385-386` rồi PMP ở `load_store_unit.sv:254, 305-306`. Net `cva6_icache/miss_o`: `cva6_icache.sv:312` (`miss_o = ~paddr_is_nc`). V-07 thay phần sau bằng net `cva6_icache/dreq_o[365]`, vào `frontend.sv:108` | V-01: `reg_irq_raw_overflow` trong `m_vlsit_cpucl_csr.sv:224`, enable từ `i_hw_we_irq_raw_overflow` (dòng 121, 492) nối ở `cluster_core.sv:1180` ← `o_irq_raw_we` ở `m_vlsit_pmu_irq.sv:27`. V-03: `reg_pmu_cnt_val[15][17]` (`m_vlsit_pmu_counter_bank.sv:35`), giá trị mới `w_pmu_cnt_sum` (dòng 43). V-04: `generic_counter_q[3]` (`perf_counters.sv:72, 175-185`). Đường sự kiện: `perf_counters.sv:112` (`perf_event_o[0] = l1_icache_miss_i`), ra `cpu_tile.sv:406`, vào PMU qua `cluster_core.sv:1066` |
| V-05 | `vaddr_q` của I-cache: `cva6_icache.sv:89, 158` | Net `cva6_icache/areq_o[12]`, `lsu_i/icache_areq_o[233]`, `icache_areq_o[1]`, `cva6_icache/miss_o` (như trên) | `reg_pmu_cnt_val[10][18]` |
| V-06 | `pmpaddr_q[3][37]`: `csr_regfile.sv:362`, xuất ra `pmpaddr_o` ở `csr_regfile.sv:404` (net `csr_regfile_i/pmpaddr_o[199]`) | Net `T0_icache_areq_ex_cache[0]` rồi `cva6_icache/miss_o`: PMP của địa chỉ fetch (`pmp_data_if.sv:106`, instance `i_pmp_if`) tham gia quyết định `miss_o` | `reg_pmu_cnt_val[5][16]` |
| V-08, V-09 | FSM context CCU: `reg_fsm_ctx_current_state[5]` và `[4]` (`coh_fabric.sv:161`) | Net `w_dir_lookup_line[159]`, `[106]` (`coh_fabric.sv:253`; gán ở `p_com_dir_req`, `coh_fabric.sv:456-477`: `w_dir_lookup_line = w_ctx_pa_line[w_bank_gnt_slot]`) rồi đọc mảng directory theo set | V-08: `reg_lookup_victim_pa_line[3][10]` (`sharer_directory.sv:102`, nạp ở 405 từ `w_lookup_victim_pa_line` dòng 241). V-09: ICG của `reg_dir_state[2][115][0]`, ghi ở `sharer_directory.sv:439` |
| V-10, V-11 | `pmpaddr_q[3][47]` hart 1: `csr_regfile.sv:362, 404` (net `csr_regfile_i/pmpaddr_o[209]`) | Net `ex_stage_i_lsu_i/store_valid_o` (`load_store_unit.sv:84, 678`: kết quả store cùng exception), net `issue_stage_i_issue_ack_iro_sb_0_` (`scoreboard.sv:74`, `issue_ack_i`) | `mem_q[6].sbe.rd[4]` và ICG của `mem_q[1]` (`scoreboard.sv:106`) |
| V-12, V-13 | `branch_valid_q[0]`: `issue_read_operands.sv:173` | Net `resolved_branch[74]`; ALU: `alu.sv:87, 93, 103` (net `alu_i/operand_a_cpop[55]`, datapath `DP_OP_620J13_122_35`), `alu_i/result_o[6]` (`alu.sv:41`); chọn kết quả có cả khối AES: net `ex_stage_i_aes_gen_aes_i/result_o[31]`, `ex_stage.sv:324, 429-430`; net `wbdata_ex_id[n]`, `rs1_forwarding_id_ex[6]` (đường bypass) | V-12: `fu_data_q[0].imm[31]` (`issue_read_operands.sv:158`, giá trị mới `fu_data_n`). V-13: `vaddr_to_be_flushed[6]` (`ex_stage.sv:308`) |
| V-14 | `mult_valid_q[0]`: `issue_read_operands.sv:166` | Net `mult_valid_id_ex_0_`, `ex_stage_i_mult_data[103]` | `mult_result_q[89]` (`multiplier.sv:82`, giá trị mới ở 115) |
| V-15 | `inp_pipe_operands_q[1][0][13]`: `fpnew_fma.sv:114` | Net `exponent_difference[6]` (`fpnew_fma.sv:294`), `sum[35]` (`fpnew_fma.sv:383, 396`) | `mid_pipe_sum_q[1][35]` (`fpnew_fma.sv:426`) |
| V-16, V-17 | Cổng `i_axi_mem_bid` (`cluster_axi_top.sv:180`) | Chuỗi tổ hợp qua `m_vlsit_riscv_axi_dw_adapter` và `axi_llc` (mux B của bypass, `axi_demux_simple.sv:275`) tới sự kiện LLC/CCU; report chỉ có net `PMUCNT_w_pmu_cnt_sum[9]` | `reg_pmu_cnt_val[0][10]` (V-16); `R_317` (V-17) |
| V-18 | Cổng `i_axi_mem_bid` | Qua `axi_route` vào tile: net `T1_dcache_req_ports_cache_ex[72]` | `commit_status_cnt_q[2]` (`store_buffer.sv:93, 188-189`) |
| V-19 | Cổng `i_axi_mem_bid` | Net `hpdcache_ctrl_i_st0_req_cachedir_read` (`hpdcache_ctrl.sv:439, 729`), `memctrl_i/dir_probe_lookup_ready_o` (`hpdcache_memctrl.sv:110, 569`), `memctrl_i/dir_addr[0]` | `dir_req_set_q[0]` (`hpdcache_memctrl.sv:335`) |
| V-20 | Cổng `i_axi_mem_rvalid` (`cluster_axi_top.sv:200`) | Net `LLC_i_llc_ways_way_inp_valid[0]`, `i_data_way/inp_ready_o`, `LLC_hit_ready` (`axi_llc_top.sv:371, 762`), `hit_miss_unit/store_req[5]`, `i_tag_store/ready_o`, `desc_d[38]` | `desc_q.a_x_addr[13]` (`axi_llc_hit_miss.sv:169`) |
| V-21 | Cổng `i_rst_n_cluster` | Reset dùng như tín hiệu dữ liệu: `o_gnt_ready = i_rst_n_cluster & (~reg_gnt_valid | i_cache_gnt_ready)` (`tile_coh_adapter.sv:153`), net `coh_tile_array/w_fabric_gnt_ready[1]` (`coh_tile_array.sv:109, 168, 241`) | `R_281` trong `coh_fabric` (đường gnt) |
| V-22, V-23 | `status_cnt_q` của FIFO `i_r_switch_fifo` trong `axi_llc_ways.sv:167` (net `i_r_switch_fifo_n[4]`, `[2]`) | Qua `m_vlsit_axi_llc` (`cluster_core.sv:999`) và `m_vlsit_riscv_axi_dw_adapter.sv` | Cổng `o_axi_mem_rready` (`cluster_axi_top.sv:201`). V-23 ra `o_axi_mmio_rready`: phụ thuộc chéo giữa R của MMIO và trạng thái FIFO của LLC, cần xác nhận qua `m_vlsit_riscv_axi_route.sv:530` |
| V-24 | `req_gnt_fifo` `rptr_q[0]` của `hpdcache_mem_req_write_arbiter` (`hpdcache_mem_req_write_arbiter.sv`) | Net `o_axi_mmio_wdata[12]` xuất hiện trên đường (wdata của tile đi chung tới nhánh MMIO và mem) | Cổng `o_axi_mem_wdata[12]` (`cluster_axi_top.sv:175`) |
| V-25 | `b_full_q` của `i_ar_spill_reg` trong `axi_mux` của `m_vlsit_riscv_axi_mem_mux.sv:292` (`spill_register_flushable.sv`) | Qua LLC (so khớp vùng cached/bypass) và adapter | Cổng `o_axi_mem_araddr[55]` (`cluster_axi_top.sv:185`) |
| V-26 | `b_full_q` của `i_aw_spill_reg` trong `axi_demux` của `m_vlsit_riscv_axi_route.sv:407-420` | Qua mux và LLC | Cổng `o_axi_mem_wvalid` (`cluster_axi_top.sv:178`) |
| V-27, V-28 | Cổng `i_axi_mem_rid` (`cluster_axi_top.sv:196`) | Đường tổ hợp vào-ra: `i_axi_mem_rid` → `m_vlsit_riscv_axi_dw_adapter.sv:108, 170` → LLC → `o_axi_mem_rready` (V-28: `o_axi_mmio_rready`) | Cổng `o_axi_mem_rready`, `o_axi_mmio_rready` |
| V-29 | Cổng `i_axi_mmio_bid` | Kênh B của MMIO và mem gộp ở tile: `m_vlsit_riscv_axi_route.sv:489` (`o_mem_bready`) và `:530` (`o_mmio_bready`) cùng chọn từ một `axi_demux` | Cổng `o_axi_mem_bready` (`cluster_axi_top.sv:183`) |
| V-30 | Cổng `i_rst_n_cluster` | `(i_awvalid & i_rst_n_cluster)`, `(i_bready & i_rst_n_cluster)` (`m_vlsit_riscv_axi_route.sv:395-397`) | Cổng `o_axi_mem_wvalid` |

#### C. Violation FPGA (VP1902, Vivado)

| ID | Run; slack | Startpoint | Endpoint | Mức logic; data path |
|---|---|---|---|---|
| F-01 | 100 MHz post-route; -1,708 | `u_vlsit_riscv_cluster_core/u_vlsit_riscv_cpu_tile_array/u_vlsit_riscv_coh_tile_array/u_vlsit_riscv_coh_fabric/reg_fsm_ctx_current_state_reg[4][0]/C` | `u_vlsit_riscv_cluster_core/u_vlsit_cpucl_csr/reg_irq_raw_overflow_reg[14]_bret__4/CE` | 29; 10,924 ns |
| F-02 | 100 MHz post-synth; +1,130 | `.../u_vlsit_riscv_coh_fabric/reg_fsm_ctx_current_state_reg[1][2]_fret/C` | `.../u_vlsit_cpucl_csr/reg_irq_raw_overflow_reg[0]_bret/CE` | 37; 8,345 ns |
| F-03 | 100 MHz post-route; -1,644 | `.../gen_tile[0].gen_active_tile.u_vlsit_riscv_cpu_tile/u_dont_touch_cva6/issue_stage_i/i_issue_read_operands/csr_valid_q_reg[0]/C` | `.../u_dont_touch_cva6/issue_stage_i/i_issue_read_operands/fu_data_q_reg[0][operand_a][4]/D` | 20; 11,377 ns |
| F-04 | 100 MHz post-route; -1,559 | `.../gen_tile[1].gen_active_tile.u_vlsit_riscv_cpu_tile/u_dont_touch_cva6/issue_stage_i/i_scoreboard/commit_pointer_q_reg[0][0]/C` | `.../gen_tile[1]...u_dont_touch_cva6/gen_cache_hpd.i_cache_subsystem/i_dcache/i_hpdcache/hpdcache_ctrl_i/hpdcache_memctrl_i/gen_data_sram_row[2].gen_data_sram_col[0].data_sram/gen_sram.ram_i/mem_reg[460][0][17]/CE` | 19; 10,892 ns |
| F-05 | 100 MHz post-route; -1,555 | `u_vlsit_riscv_cluster_core/u_vlsit_axi_llc/u_dont_touch_axi_llc_reg_wrap/i_axi_llc_top_raw/i_axi_bypass_demux/i_demux_simple/i_b_mux/gen_arbiter.gen_int_rr.gen_lock.lock_q_reg/C` | `.../gen_tile[1]...hpdcache_memctrl_i/gen_data_sram_row[0].gen_data_sram_col[0].data_sram/gen_sram.ram_i/mem_reg[101][1][48]/CE` | 18; 11,224 ns |
| F-06 | 400 MHz post-route; -9,145 | `.../gen_tile[1].gen_active_tile.u_vlsit_riscv_cpu_tile/u_dont_touch_cva6/gen_cache_hpd.i_cache_subsystem/i_cva6_icache/vaddr_q_reg[20]/C` | `u_vlsit_riscv_cluster_core/u_vlsit_cpucl_csr/reg_irq_raw_overflow_reg[4]_bret__0/CE` | 33; 11,105 ns |

#### D. Đường RTL tương ứng (FPGA)

| ID | Đường dẫn RTL (net có tên trong report và vị trí) |
|---|---|
| F-01, F-02 | `reg_fsm_ctx_current_state` (`coh_fabric.sv:161`) → arbiter bank và directory: net `u_vlsit_riscv_coh_bank_arb/w_dir_lookup_ready[1]` (`coh_bank_arb.sv:32`), `u_vlsit_riscv_sharer_directory/reg_lookup_rsp_valid[3]`, `reg_dir_op_rr_ptr[3][1]`, `reg_dir_plru[..]`, `reg_dir_resv_valid[3][125]` (`sharer_directory.sv`, `p_com_dir_ready`) → `w_lookup_rsp_accept` (`coh_fabric.sv:714`) → `o_ccu_evt_count[1]/[2]` (`coh_fabric.sv:943, 945`) → PMU (`cluster_core.sv:1068`) → carry của `m_vlsit_pmu_counter_bank.sv:43` → `o_irq_raw_we` (`m_vlsit_pmu_irq.sv:27`) → `cluster_core.sv:1180` → CE của `reg_irq_raw_overflow` (`m_vlsit_cpucl_csr.sv:224, 492`) |
| F-03 | `csr_valid_q` (`issue_read_operands.sv:172`) → net `ex_stage_i/p_0_in` và các mux `mem_q[n][sbe][result]` của scoreboard (bypass kết quả) → `fu_data_q[0].operand_a[4]` (`issue_read_operands.sv:158`) |
| F-04 | `commit_pointer_q[0]` (`scoreboard.sv:120, 144`) → net `i_scoreboard/cmo_op_q`, `store_buffer_i/amo_valid_commit`, `i_amo_buffer/i_amo_fifo/st1_req_q[req][op][3]` (`store_buffer.sv`), `i_load_unit/fence_req_valid[3]` → `hpdcache_rtab_i/pop_arb_i/arb_req[sid][0]` → `dir_sram/wait_q` → CE của mảng flop `hpdcache_sram_wbyteenable_1rw` (`hpdcache_memctrl.sv`, mảng `gen_data_sram_row[2]`) |
| F-05 | `i_b_mux` `lock_q` trong LLC (`axi_demux_simple.sv:275`) → `m_vlsit_riscv_axi_route.sv:407-420` (`axi_demux` `i_b_mux`: net `req_q`, `rr_q`, `flush_dir_valid_q`) → hpdcache `gen_flush.flush_i` (`hpdcache.sv:1256`, net `reg_cpucl_coh_fault_i_6`) → `dir_sram/flush_check_hit_20` → `hpdcache_rtab_i/st1_rtab_pop_try_ptr_q` → CE của `gen_data_sram_row[0]` |
| F-06 | `vaddr_q[20]` (`cva6_icache.sv:89, 158`) → ITLB `vpn_match[8]`, `lu_hit` (`cva6_tlb.sv:147`) → `csr_regfile_i/cl_tag_q`, `icache_areq_ex_cache[fetch_paddr][5]` → PMP `lsu_i/i_pmp_data_if/i_pmp_if` (`pmp_data_if.sv:106`) → `miss_o` → PMU như F-01 → CE của `reg_irq_raw_overflow[4]` |

#### E. Nhận xét từ việc truy vết

1. **Họ H1 được xác nhận từ nhiều điểm đầu khác nhau.** V-01 đến V-07, V-16, F-01, F-02 và F-06 đều kết thúc ở `reg_irq_raw_overflow` hoặc `reg_pmu_cnt_val` (RTL: `m_vlsit_cpucl_csr.sv:224`, `m_vlsit_pmu_counter_bank.sv:35`). Điểm đầu thay đổi (ITLB, I-cache, PMP, FSM CCU, cổng AXI B) vì PMU nhận mọi sự kiện dưới dạng tổ hợp.
2. **Đường ITLB → I-cache → frontend là vòng fetch thật.** V-07 (`..itlb.. → T1_i_frontend/npc_q`) tra ITLB, tag I-cache rồi tính PC kế tiếp. Khác V-01 đến V-06 (kết thúc ở PMU), đường này không cắt được bằng pipeline mà không đổi IPC.
3. **Mới: `i_rst_n_cluster` được dùng như tín hiệu dữ liệu trong logic tổ hợp** (V-21, V-30): `m_vlsit_riscv_tile_coh_adapter.sv:138, 146, 153, 162-163, 171, 178-179`, `m_vlsit_riscv_cache_line_locks.sv:77`, `m_vlsit_riscv_axi_route.sv:395-397` và `o_cmo_ready` trong `m_vlsit_riscv_cmo_controller.sv`. Reset vào đường handshake nên (a) trở thành start point in2reg và in2out với ngân sách ≈0,5 ns và 0,208 ns, (b) tạo fanout reset lớn giữa logic dữ liệu, (c) làm phức tạp review RDC. Cách sửa không ảnh hưởng IPC: bỏ `& i_rst_n_cluster` khỏi `ready/valid` (các thanh ghi bên trong đã được reset không đồng bộ nên `valid` đều về 0), hoặc dùng một cờ `reg_rst_done` đã đăng ký.
4. **Mới: phụ thuộc chéo giữa kênh mem và MMIO** (V-23, V-28, V-29): `i_axi_mmio_bid` ảnh hưởng `o_axi_mem_bready`, FIFO `r_switch` của LLC ảnh hưởng `o_axi_mmio_rready`. Nguyên nhân khả dĩ là kênh B và R của hai nhánh gộp về một cổng phản hồi của tile trong `m_vlsit_riscv_axi_route.sv`. Cần xác nhận trong RTL trước khi chốt cách sửa; slice ở biên (F3) vẫn gỡ được cả hai.
5. **Một số điểm cuối là thanh ghi `R_nnn` do retime** (V-02, V-17, V-21): không truy được về tên RTL, chỉ biết cone đầu vào.
6. **Giới hạn truy vết.** Report DC đã flatten, phần giữa của nhiều path chỉ có tên cell `Unnnn`; tôi chỉ nêu các net có tên tín hiệu RTL. Sự kiện PMU cụ thể sau V-16 (sự kiện LLC/CCU từ phản hồi B) và đường nội bộ của `i_axi_mem_rid` cần mở netlist (`.sv` 146 MB trong zip), chưa làm.

## 3. Điểm đã kiểm và đúng

| Điểm | Cách kiểm |
|---|---|
| Cấu trúc 2/4 hart: tile không dùng tie-off yên lặng (`gen_inactive_tile`), mem mux và MMIO mux che hart không hoạt động | Đọc lại [cpu_tile_array.sv](../../../rtl/common/vlsit/cpu/m_vlsit_riscv_cpu_tile_array.sv) và mux |
| ACK luôn được rút (`o_ack_ready='1`), chỉ ACK khớp tag/phase/hart mới cập nhật context; ACK lạ phát `o_coh_proto_diag_event` | Đọc lại `coh_txn_table` (CC-02 đã đóng) |
| Directory: 4 bank × 8 way, tree-PLRU, UPDATE/CANCEL của chủ reservation được ưu tiên thoát | Review 11-16 (V qua repro `dir_deadlock`); CC-01 đã đóng |
| Bảng vùng địa chỉ: căn 16 B, không chồng, đúng một vùng cacheable ở chỉ số 0, lũy thừa của 2, ATOP vào MMIO bị từ chối | Đọc lại [addr_decode.sv](../../../rtl/common/vlsit/address_map/m_vlsit_riscv_addr_decode.sv) |
| `fault_record`: lỗi đầu tiên giữ đến reset, `multiple`, ưu tiên hart thấp rồi LLC, `hart_valid=0` cho LLC | Review 11-16 (C) |
| CSR có `cpucl_coh` tại 0x0010 (mục P2-2 của review 11-11 đã đóng) | Đọc lại `m_vlsit_cpucl_csr.sv` |
| Kỷ luật quy trình: traceability REQ/TEST/DEC/DEP, quản lý license và pin commit third-party, tài liệu trung thực về phần chưa verify | Review 11-11, 11-16, audit |

## 4. Trạng thái các phát hiện cũ

| ID cũ | Nội dung | Trạng thái hiện tại | Ghi chú |
|---|---|---|---|
| CC-01 | Deadlock directory | **Đã đóng** | Review 11-16 (V): repro PASS |
| CC-02 | ACK trùng không được rút | **Đã đóng** | Đã đọc lại `o_ack_ready='1` |
| CC-03 | Lệch hợp đồng, grant trùng | **Đã đóng** | Repro PASS |
| RB-01 | Bridge ghi lệnh bị cấm | **Còn** | R-01 |
| RB-02 | `PPROT` | Còn | R-12 |
| CC-10 | W1C PMU | Còn | R-11 |
| PF-05 | Tốc độ probe | Còn, có số đo mới 12 chu kỳ mỗi transaction | R-07 |
| PF-06, PF-07, CC-04 | Directory 1:1, mảng flop, clean eviction | Còn | R-06 |
| PF-01..04, SYS-03 | Nền hiệu năng, DMA | Còn | R-15 |
| CC-07..09 | FENCE.I, CBO, ECC | Còn | R-16 |
| LP-01..11, DB-A..H | Low-power, debug | Còn | R-17 |
| P1-1 (11-11) | Top không elaborate vì thiếu core | **Đã đóng** | Top và core nay tồn tại; lint 2/4 hart không lỗi theo audit |
| P1-3 (11-11) | Delta v0.19 chưa merge | **Đã đóng** | Đã merge; CC-01..03 đã đóng |
| P1-2 (11-11) | Tài liệu mâu thuẫn về sự tồn tại của top | **Đã đóng**, còn vài đoạn cũ | R-18 |
| P2-2 (11-11) | CSR `cpucl_coh` chưa merge | **Đã đóng** | Mục 3 |
| P2-1 (11-11) | Spec tool FAIL do WF-020 và dòng tiếng Việt | Một phần | Còn lỗi R-005 (bilingual), R-18 |
| P2-3, P2-4, P2-7, P3 (11-11) | Lint `axi_mmio`, log CSR 27/27, log trùng, rác repo | Chưa kiểm lại | R-19 ghi phần còn thấy |

## 5. Backlog đề xuất

| Ưu tiên | ID | Việc cần làm | Tiêu chí hoàn tất |
|---|---|---|---|
| P0 | R-01 | Thêm `& ~w_wr_addr_wr_denied`; test mức TOP | Repro PASS; SLVERR cho thanh ghi cấm, không có RegBus write |
| P0 | R-02 | Đảo `irq_i`; test CPU thật cho MEIP/SEIP/delegation/WFI | Đạt ở 2 và 4 hart |
| P0 | R-03 | Sắp lại khai báo; thêm slang và Questa vào lint | slang 0 lỗi; Questa biên dịch được |
| P0 | R-04 | Implement DEC-043 atomic all-target claim; directed 4-hart scheduler simulation passes; add TOP 2/4 lint, formal proof, and random regression | No split owner tags in the directed cross-claim case; no full wait-for signoff yet |
| P0 | R-05 | Giải quyết thông báo hạn chế của `lzc.sv` | Ghi nhận quyền hoặc thay thế có kiểm chứng |
| P1 | R-09 | `$error` guard tham số; thanh ghi RO config/version; khóa tham số chưa hỗ trợ | HDS ghi profile hỗ trợ; firmware đọc được cấu hình |
| P1 | R-10, R-11 | Đóng đường chỉ-lint (PMU, LLC service, IRQ/debug, MMIO, ATOP); random coherence kèm scoreboard | Test đạt; có báo cáo coverage |
| P1 | R-06, R-07 | Mô hình hóa directory và tuần tự hóa; đo trước khi chọn giải pháp | Số đo trên workload chia sẻ |
| P1 | R-08 | Ghi điều kiện hart phải còn trả lời probe; watchdog; CSR chẩn đoán CCU | REQ mới; test ACK mất |
| P1 | R-12, R-13 | Quy tắc PPROT; `default` an toàn cho FSM probe engine | Không còn `'x` ở output valid |
| P2 | R-14, R-18 | Đường lỗi CMO; dọn comment, header, tài liệu cũ; waiver R-005 | Tài liệu khớp RTL |
| P2 | R-15..R-17 | Quyết định mục tiêu hiệu năng, low-power, debug cho v1 | Ghi vào HDS |
| P0 | R-25 | Thêm model timing SRAM, dùng DC-T hoặc `-spg`, nâng uncertainty, chỉnh I/O delay (mục 2A.4, F4) | Lần chạy mới có reg2mem/mem2reg và số đo gần P&R |
| P0 | R-21 | Pipeline PMU/CSR overflow (F1), cập nhật HDS/CSR và test PMU | Không còn họ H1 trong 200 path xấu nhất |
| P1 | R-23 | Register slice cho biên AXI (F3) | Không còn path in2out; in2reg ≤ 0,5 ns |
| P1 | R-22 | Directory sang RAM model thay được bằng macro (F2, F2a): wrapper `m_vlsit_riscv_dir_sram`, `valid`/PLRU/`resv` giữ ở flop, +1 chu kỳ lookup; test song song với bản cũ, A-04, A-05, random coherence, R-04 | Diện tích giảm, họ H2 biến mất, hành vi coherence không đổi |
| P1 | R-20, R-24 | Quét tần số T = 2,0; 2,5; 3,0; 3,5 ns (F5); chốt mục tiêu f theo mục 2A.6 | Bảng "khối nào đóng ở T nào"; mục tiêu f ghi vào HDS mục 13 |
| P1 | R-27 | Bỏ `& i_rst_n_cluster` khỏi `ready/valid` (dùng reset không đồng bộ bên trong hoặc cờ `reg_rst_done` đã đăng ký); xác nhận phụ thuộc chéo mem/MMIO ở `axi_route` (V-23, V-28, V-29) | Không còn start point `i_rst_n_cluster` trong path in2reg/in2out |
| P2 | R-26 | FPGA: ánh xạ SRAM sang BRAM/URAM (F7) | FF giảm ~940.000; WNS 100 MHz ≥ 0 sau route |
| P2 | R-24 | FPU thêm 1 tầng pipeline FP64 (F6), chỉ nếu F5 cho thấy FPU giới hạn | IPC mã số nguyên không đổi |
| P3 | R-19 | Dọn repo (artifact, bản sao trùng), tách lịch sử | Repo nhỏ hơn, lịch sử rõ |

## 6. Câu hỏi cần chủ dự án quyết định

1. Có coi việc đảo `irq_i` (R-02) là sửa lỗi chứ không phải đổi spec?
2. RTL phải biên dịch được trên công cụ nào (VCS, Questa, Xcelium, Design Compiler, Spyglass)? Từ đó quyết định front-end trong lint (R-03).
3. Có chấp nhận cơ chế claim nguyên tử cho PREPARE (R-04), đổi lấy việc context chờ claim thay vì chiếm một phần slot?
4. Có chấp nhận giới hạn `PARA_COH_TXN_NUM >= 3` để tránh trường hợp một transaction toàn cluster (R-07, R-09)?
5. Low-power và debug: giữ ngoài phạm vi v1, hay đưa các cổng tối thiểu (`o_hart_wfi`, `o_hart_quiet`, reset từng hart) vào v1 (R-17)?
6. Mục tiêu hiệu năng cụ thể (CoreMark/MHz, GB/s, độ trễ gói) và có giữ line 16 B hay chuyển 64 B (R-06, R-15)?
7. Tần số mục tiêu: giữ 800/960 MHz ở SS 125 °C trên 55LPx (đòi hỏi cắt pipeline CVA6, mất IPC), đổi công nghệ hoặc corner, hay chấp nhận tần số theo kết quả quét F5 để bảo toàn IPC (R-20, mục 2A.6)?
8. Có chấp nhận cộng 2 đến 3 chu kỳ vào đường L1 miss và đường ra bộ nhớ (F2, F3) và đổi bộ đếm PMU lệch 2 đến 4 chu kỳ (F1) để đổi lấy timing (R-21 đến R-23)?

## Phụ lục A. Việc đã làm trong lượt này

| Việc | Chi tiết |
|---|---|
| Tìm review hiện có | `git ls-files` và `find` các file review/audit; xác định 2 review cluster hiện hành, 1 review lịch sử, 2 file RTL change review, 2 review tensor (ngoài phạm vi) |
| Đọc nội dung | Đọc trọn: review 11-16, review 11-09 (gồm Phụ lục B), review 11-11, audit post-A06, README review; đọc đầu hai file RTL change review |
| Đối chiếu RTL | Đọc lại: `cluster_axi_top`, `cluster_core`, `cpu_tile_array`, `cpu_tile` (phần IRQ), `csr_regfile` (CVA6 đã sửa), `axil_reg_bridge`, `probe_scheduler`, `coh_txn_table`, `coh_fabric` (phần phase, owner, alloc, khai báo), `sharer_directory` (tham số), `axi_mem_mux`, `addr_decode`, CSR offset |
| Đọc timing | Giải nén có chọn lọc `dual_gf55_800.zip` (qor, area, clocks, check_timing, SDC, flow script, `qor_timing_summary_max` 10.000 endpoint, `synth_timing_*` 2.000 path mỗi nhóm, `synth_timing_violate` 200 path, `qor_reference`) và `vp1902.zip` (timing summary và utilization 100/400 MHz, post-synth/post-route); parse bằng script riêng. Chưa đọc `synth_power`, `.sdf`, `.ddc`, netlist, `check_design` |
| Không làm | Không chạy Verilator, Questa, slang, `vlsit_rtl_check.py`, DC hay Vivado, không chạy test nào; kết quả "V" lấy từ review 11-16, kết quả "R" lấy từ report trong zip |
| Đánh giá khả thi | Directory dùng RAM model (mục 2A.4, F2a): đọc `sharer_directory`, `coh_fabric` (FSM chờ phản hồi theo tag), 3 testbench truy cập `reg_dir_*`, model SRAM hiện có của HPDcache và `blackbox.tcl` |
| Truy vết start/end point | Tách từng họ path trong `synth_timing_violate`, `synth_timing_*` và `post_*_timing_summary`, lấy tên startpoint/endpoint nguyên văn và net có tên tín hiệu, rồi đối chiếu số dòng RTL bằng grep (mục 2A.9) |
| Phát hiện mới | R-04 (circular wait), phần mới của R-09 (không guard `PARA_CPU_NUM`, không CSR cấu hình), phần mới của R-18 (comment và header sai), R-20 đến R-27 (timing) |
