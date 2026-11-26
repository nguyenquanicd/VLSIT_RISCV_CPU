# Review specification và RTL — VLSIT RISC-V Dual/Quad CPU Cluster (2026-11-16)

| Mục | Nội dung |
|---|---|
| Ngày review | 2026-11-16 |
| Đối tượng | HDS 0.29, RTL `rtl/common/vlsit`, `rtl/non_coherence_cluster` (TOP `m_vlsit_riscv_cluster_axi_top`), bản sao có sửa trong `rtl/common/modified`, `verification/`, `doc/reports` |
| Nền | Review trước: [VLSIT_RISCV_CPU_Cluster_Design_Review.md](VLSIT_RISCV_CPU_Cluster_Design_Review.md) (2026-11-09, trên cây RTL cũ chưa có top). Tài liệu này chỉ nêu phần đã đổi, phần mới và trạng thái các phát hiện cũ |
| Không làm | Không chạy lại 58 ca CPU (cần chuỗi công cụ riêng); không đọc toàn bộ mã native (CVA6, HPDcache, `axi_llc`); không đo PPA |
| Ngôn ngữ | Tiếng Việt, giữ thuật ngữ kỹ thuật tiếng Anh |

## 0. Kết luận ngắn

| Câu hỏi | Kết luận |
|---|---|
| Dự án đã tiến bộ so với 2026-11-09 chưa? | **Có, rất nhiều.** Đã có TOP tích hợp CVA6, HPDcache, CCU, LLC, CSR, PMU; đã sửa đúng ba lỗi coherence tôi nêu (CC-01, CC-02, CC-03); có 58 ca CPU thật; audit nội bộ sau A-06 trung thực về phần còn lỗ hổng. |
| Có lỗi chặn nào còn lại không? | **Có hai.** (1) Bridge LLC (RB-01) vẫn chuyển lệnh ghi bị cấm xuống LLC và trả hai B response; lỗi này nằm trong đường dịch vụ LLC mà audit gọi là "chỉ lint". (2) Ngắt ngoài bị **đảo** giữa M-mode và S-mode ở biên CVA6 (N-01). |
| RTL có dùng được với công cụ ngoài Verilator không? | **Chưa.** Hai file lớn nhất của dự án (`m_vlsit_riscv_cluster_core.sv`, `m_vlsit_riscv_coh_fabric.sv`) khai báo tín hiệu sau khi dùng. QuestaSim 10.4c và `slang` đều từ chối biên dịch; Verilator chấp nhận nên mọi báo cáo "lint sạch" hiện chỉ đúng với một front-end (N-03). |
| Đã high performance chưa? | **Chưa**, các nhận định cũ về lõi in-order, line 16 B, cổng AXI 64-bit vẫn đúng. Tích hợp thật còn thêm các nút thắt mới: mỗi hart chỉ phục vụ một transaction đích tại một thời điểm, khóa cả set directory cho mọi lookup, một controller CMO dùng chung, dirty eviction làm L1 tạm dừng đến khi có B (N-04). |
| Low-power và debug? | **Không đổi** so với review trước: mọi hạng mục LP-01 đến LP-09 và DB-A đến DB-H vẫn mở (mục 4). |
| Cần làm gì trước? | Sửa RB-01 (một điều kiện), đảo lại `irq_i`, chuyển khai báo lên đầu file rồi kiểm tra bằng ít nhất hai front-end, sau đó mới đóng các đường "chỉ lint" (PMU, LLC service, IRQ/debug) bằng test chức năng như audit đề ra. |

## 1. Phương pháp và mức bằng chứng

| Nhãn | Ý nghĩa |
|---|---|
| **V** | Đã chạy công cụ hoặc mô phỏng và quan sát kết quả |
| **C** | Suy ra từ đọc code, chưa chạy |
| **S** | Suy ra từ đọc spec hoặc tài liệu |
| **E** | Ước tính của người review |

Đã chạy lần này:

| Việc | Kết quả |
|---|---|
| Chạy lại 4 bản tái hiện của review trước trên RTL hiện tại (Verilator) | 2 đóng, 1 còn, 1 cập nhật số đo (mục 2) |
| `slang` (front-end SystemVerilog nghiêm ngặt) trên TOP, 2 hart, cùng filelist với lint của dự án | 71 lỗi: 70 "identifier used before its declaration" và 1 thiếu hàm trong package |
| QuestaSim 10.4c `vlog` trên từng file của dự án | `cluster_core` 27 lỗi, `coh_fabric` 15 lỗi; 8 module nhỏ (directory, bảng transaction, scheduler, arbiter, bridge, decode, fault record, PMU) biên dịch sạch |
| `vlsit_rtl_check.py` trên `rtl/common/vlsit` và `rtl/non_coherence_cluster` | PASS: 0 ERROR; cảnh báo NAM-08 và HIE-02 |
| `vlsit_spec_tool.py check` trên HDS | 1 lỗi: 120 dòng tiếng Việt (HDS cố ý song ngữ, quyết định đã ghi); 22 mục đủ |
| Đọc code | `coh_fabric` (phần FSM/alloc/ACK), `sharer_directory`, `coh_txn_table`, `probe_scheduler`, `cmo_controller`, `fault_record`, `addr_decode`, `axil_decode`, `axil_reg_bridge`, tile, core (phần PMU/CSR/fault), `axi_dw_adapter`, các bản sao CVA6 |

Chưa kiểm: toàn bộ `hpd_probe_engine` và `tile_coh_adapter`, `axi_route`, `axi_mmio`, `axi_mem_mux`, `cache_line_locks`, các thay đổi trong HPDcache và `axi_llc` (đọc ở mức sơ lược hoặc không đọc).

## 2. Trạng thái các phát hiện của review 2026-11-09

| ID | Nội dung | Trạng thái hiện tại | Bằng chứng |
|---|---|---|---|
| CC-01 | Deadlock directory (hit không có reservation, miss có) | **Đã đóng** | V: mọi lookup (cả hit) giờ đặt reservation, UPDATE/CANCEL của chủ reservation được ưu tiên thoát, các thao tác khác trên set không đủ điều kiện cho tới khi chủ kết thúc. TB mới `repro/dir_deadlock` PASS |
| CC-02 | ACK trùng hoặc không khớp không bao giờ được rút | **Đã đóng** | V: `o_ack_ready` luôn bằng 1; ACK trùng được rút và phát `o_coh_proto_diag_event` (`repro/txn_probe_rate`) |
| CC-03 | Lệch hợp đồng: thiếu `target_state`, arbiter cấp trùng | **Đã đóng** | V: bảng transaction nay có `target_state`, `wback_en`, owner; arbiter cấp một lần cho mọi độ trễ hạ request (`repro/bank_arb_dup_grant` PASS) |
| RB-01 | Bridge LLC ghi xuống LLC dù đã trả SLVERR, hai B response | **Còn nguyên** | V: `repro/reg_bridge_denied_write` kết quả `RESULT: FAIL`; file không đổi so với bản đã vá thử |
| RB-02 | `PPROT` bị bỏ qua | **Còn** | C: `awprot`/`arprot` chỉ chuyển tiếp, CSR sinh ra và bridge không dùng |
| CC-10 | W1C bị phần cứng ghi đè trong PMU IRQ | **Còn**, audit đã nhận là B-03 | C |
| PF-05 | Tốc độ probe | **Số đo mới** (xem N-04): 12 chu kỳ mỗi transaction (PREPARE rồi COMMIT) tới một hart, 6 mỗi pha, cache lý tưởng | V |
| PF-06, PF-07, CC-04 | Directory 1:1 với L1, mảng flop, không báo clean eviction | **Còn** (RTL directory vẫn là mảng flop, 8 way, 8192 entry cho 4 hart) | C |
| CC-07, CC-08, CC-09 | FENCE.I quét cả D-cache, CBO theo từng line 16 B, không ECC | **Còn** (HDS 0.29 ghi rõ chấp nhận) | S |
| LP-01 đến LP-09 | Low-power | **Còn** (spec ghi "ngoài phạm vi") | S |
| DB-A đến DB-H | Debug | **Còn**: top vẫn chỉ có `i_hart_debug_req`, `o_hart_debug_mode` | C |

Hai phát hiện của review trước nay được dự án ghi nhận chính thức: audit sau A-06 nêu lại PMU W1C (B-03) và nút thắt tiến triển (B-04).

## 3. Phát hiện mới

### N-01 (High, C): ngắt ngoài M/S bị đảo ở biên CVA6

`m_vlsit_riscv_cpu_tile.sv:397` nối `.irq_i({i_int_meip, i_int_seip})`. Với `irq_i` hai bit, bit 1 là `i_int_meip`, bit 0 là `i_int_seip`. Trong `csr_regfile.sv` của CVA6, `mip_d[riscv::IRQ_M_EXT] = irq_i[0]` và `irq_i[1]` được OR vào `SEIP` (đọc CSR và đánh thức WFI). Bộ `ariane_testharness.sv` của Culsans (đã ghim trong repo) làm ngược lại: `meip = irqs[i][0]`, `seip = irqs[i][1]`, truyền `irqs[i]` vào `irq_i`.

Kết quả: tín hiệu `i_int_meip` của SoC (từ PLIC context M-mode) đến CVA6 như ngắt external của **S-mode**, và `i_int_seip` đến như ngắt external của **M-mode**. Với Linux và OpenSBI, ngắt thiết bị sẽ vào sai mức đặc quyền hoặc bị chặn. Các cổng khác (`msip`, `mtip`, `ssip`, `stip`) nối đúng.

Lỗi không bị test bắt vì audit ghi "External per-hart interrupts / debug" là chỉ lint.

Sửa: `.irq_i({i_int_seip, i_int_meip})`. Thêm test CPU thật: xác nhận `mip.MEIP` lên khi `i_int_meip=1` và `mip.SEIP` lên khi `i_int_seip=1`, kèm delegation.

### N-02 (Blocker, V): RB-01 còn trong đường dịch vụ LLC của TOP

`m_vlsit_axil_reg_bridge.sv` không đổi. Chạy lại `repro/reg_bridge_denied_write` trên đường dẫn mới: lệnh ghi vào `0x00` (`CFG_SPM_LOW`) và `0x40` (`VERSION_LOW`) vẫn gây 1 lệnh ghi RegBus và 2 B response (SLVERR rồi OKAY). TOP nối bridge này vào dịch vụ LLC (`u_vlsit_axil_reg_bridge` trong `cluster_core`), nên bảo vệ "SPM bị cấm" (REQ-MEM-003) bị bỏ qua bởi bất kỳ master AXI4-Lite nào. Audit xếp mục này vào "Native service behavior is lint-only", nên lỗi chưa bị chạm tới.

Sửa (đã thử trên bản sao ở lượt trước, vẫn áp dụng được): thêm `& ~w_wr_addr_wr_denied` vào điều kiện chuyển `IDLE` sang `WR_REQ`.

### N-03 (High, V): RTL không biên dịch được trên front-end nghiêm ngặt

| Công cụ | Kết quả |
|---|---|
| Verilator (lint của dự án) | 0 lỗi, 0 cảnh báo |
| `slang` trên TOP 2 hart | 71 lỗi. 70 lỗi `used before its declaration`: `cluster_core` 34, `coh_fabric` 16, `axi_llc_tag_store` 6, `cva6.sv` 3, `commit_stage.sv` 3, `store_unit.sv` 2, `axi_demux_simple.sv` 2, `axi_llc_top.sv` 2, `hpdcache_ctrl.sv` 1. 1 lỗi: `cf_math_pkg::is_power_of_2` không có trong package được biên dịch |
| QuestaSim 10.4c `vlog` | `cluster_core`: 27 lỗi (`Undefined variable: 'w_cpucl_coh_fault'` ở dòng 1057, và các lỗi `already declared in this scope` do tạo net ngầm). `coh_fabric`: 15 lỗi (`Undefined variable: 'w_internal_pick_valid'` ở dòng 163 và nhiều biến khác) |

Nguyên nhân: các tín hiệu được dùng trước khi khai báo. Ví dụ `cluster_core` dùng `w_llc_reg_req_valid` ở dòng 1000 nhưng khai báo ở dòng 1198; `coh_fabric` dùng `w_internal_pick_valid` và `reg_fsm_ctx_current_state` ở dòng 163 đến 173 nhưng khai báo sau đó. IEEE 1800 yêu cầu khai báo trước khi dùng; Verilator dung thứ, nên lint của dự án và rule check đều không thấy.

Hệ quả: các công cụ ASIC (mô phỏng, synthesis, CDC, formal) thường dùng front-end nghiêm ngặt, nên chưa thể coi RTL là sẵn sàng cho luồng sản xuất. Các module nhỏ vẫn sạch, nên đây là lỗi tổ chức file chứ không phải lỗi thiết kế.

Lỗi trong các bản sao CVA6, HPDcache, `axi_llc` cần phân loại: một phần có thể kế thừa từ upstream (cần so với bản gốc), phần còn lại do bản sửa của dự án gây ra.

Về `is_power_of_2`: filelist trộn hai bản `common_cells`. `ring_buffer.sv` (từ `axi_llc_locked`) dùng hàm có ở bản mới, trong khi `cf_math_pkg.sv` được biên dịch là bản cũ trong vendor của CVA6. Verilator không thấy vì macro `ASSERT_INIT` không được mở rộng; công cụ khác sẽ báo.

Đề xuất: (1) sắp xếp lại khai báo ở `cluster_core` và `coh_fabric`; (2) thêm `slang` và một công cụ thương mại vào `scripts/run_cluster_top_lint.py` và vào `vlsit_rtl_check.py`; (3) thống nhất một bản `common_cells`.

### N-04 (Medium, S, C, V): các giới hạn đồng thời trong CCU và L1

| Giới hạn | Bằng chứng | Hệ quả |
|---|---|---|
| Mỗi hart làm đích chỉ cho một transaction tại một thời điểm, từ PREPARE đến pha cuối | Đọc `probe_scheduler`: `reg_phase_owner_valid` buộc hart vào một context cho đến khi pha cuối xong. Đo (V): 4 transaction (PREPARE rồi COMMIT) tới một hart mất 48 chu kỳ khi cache phản hồi sau 1 chu kỳ, tức 12 chu kỳ mỗi transaction, 6 mỗi pha. 4 pha PREPARE tới 4 hart khác nhau xong sau 9 chu kỳ (`repro/txn_probe_rate`) | Một hart là chủ của nhiều line đang được truy cập (producer) phục vụ chúng nối tiếp. 8 context không có nghĩa là 8 transaction chạy song song |
| Mọi lookup (cả hit) đặt reservation cho cả set cho đến khi UPDATE hoặc CANCEL | Đọc `sharer_directory` | Mọi transaction cùng set directory (4 bank × 64·số hart set) bị tuần tự hóa từ lookup đến commit, gồm cả thời gian PREPARE, writeback của owner và COMMIT. Đây là cái giá của việc đóng CC-01 |
| Gốc có hai context rảnh mới được nhận (`w_root_alloc_en`) | `coh_fabric`, REQ-MEM-009 "tối đa N-1 gốc" | Với `PARA_COH_TXN_NUM=2` chỉ một transaction CPU/CMO chạy tại một thời điểm trong toàn cluster. Giá trị 2 vẫn được khai báo hợp lệ |
| Một controller CMO dùng chung | `cmo_controller`: một lệnh tại một thời điểm, phải qua PREPARE, LLC, FINISH | CBO của mọi hart tuần tự hóa (xem SYS-03 và 94 lệnh CBO cho một gói 1500 B ở review trước) |
| Dirty replacement làm controller L1 tạm dừng đến khi có B | `doc/reports/l1_eviction_retention` (A-03 "Pause new controller admission/replay") và HDS mục 13 | Thêm một vòng B (L1 đến LLC) vào mỗi lần thay line dirty: giảm throughput ghi |
| B lỗi (SLVERR/DECERR) làm controller cache đứng đến reset | HDS mục 12 | Một lỗi bộ nhớ thoáng qua đóng băng hart đó; theo quyết định đã duyệt nhưng là rủi ro vận hành |

Các điểm này không phải lỗi mà là hệ quả của lựa chọn "đúng trước, nhanh sau". Cần đưa vào mô hình hiệu năng trước khi hứa số liệu throughput.

### N-05 (Medium, C): FSM probe engine gán X cho trạng thái không hợp lệ

`m_vlsit_riscv_hpd_probe_engine.sv` (khoảng dòng 150 và 189) dùng `casez` với nhánh `default` gán `'x` cho `o_probe_req_ready`, `o_probe_rsp_valid`, `o_lookup_valid`, `o_flush_valid`, `o_state_update_valid`. `vlsit_rtl_check.py` báo INFO COM-04. Trong tổng hợp, tool được phép chọn giá trị, có thể làm `flush_valid` hoặc `probe_rsp_valid` lên trong trạng thái bất hợp pháp (sau lỗi mềm hoặc nhiễu reset); ở nhánh next-state, trạng thái bất hợp pháp giữ nguyên (không có đường về `IDLE`). Đề xuất: nhánh `default` đặt các output valid về 0 và next-state về `IDLE`.

### N-06 (Low, C): lệnh CMO bất hợp pháp làm treo thay vì báo lỗi

`m_vlsit_riscv_cmo_controller.sv`: `o_cmo_ready = w_cmd_legal & i_rst_n_cluster` ở trạng thái `IDLE`. Lệnh có op dự phòng hoặc hart không hoạt động không bao giờ được nhận, bên gửi chờ vô hạn. Với decoder hiện tại tình huống này không xảy ra, nhưng nên có đường trả lỗi chứ không treo.

### N-07 (Medium, S): tham số được khai báo hợp lệ nhưng chưa được kiểm chứng

Đồng ý với audit B-02 và bảng mục 8.1 của HDS:

| Tham số | Vấn đề |
|---|---|
| `PARA_LLC_BLOCK_NUM > 2` | Địa chỉ bảo trì CCU dùng line 16 B cố định; line LLC lớn hơn chưa có hợp đồng (audit B-02). Nên khóa về 2 trong profile được hỗ trợ |
| `PARA_AXI_MEM_DATA_W` = 32, 128, 256 | Chỉ test lá; CPU thật chỉ chạy 64-bit. Bộ `axi_dw_converter` của PULP có xử lý ATOP có R response, nhưng việc tách một AMO 8 byte thành 2 beat trên bus 32-bit chưa được kiểm chứng đầu-cuối |
| `PARA_COH_TXN_NUM=2` | Chỉ một gốc (xem N-04) |
| `PARA_PMU_COUNTER_NUM`, `_W` khác mặc định | Chưa có test phần mềm |

### N-08 (Medium, S): kiểm chứng định hướng chưa bắt được lỗi tích hợp

58 ca CPU thật là bằng chứng mạnh cho cache, CBO, FENCE.I, atomic và fault record. Nhưng hai lỗi mới (N-01, N-02) đều nằm ngay trên các đường mà audit liệt kê là "chỉ lint". Ngoài ra: chưa có scoreboard độc lập cho dữ liệu chia sẻ, chưa đo coverage, chưa có formal, mọi sim dùng một công cụ (Verilator). Máy hiện có QuestaSim nhưng không được dùng (N-03). Đề xuất khớp với audit: đóng các đường chỉ-lint trước, thêm random coherence kèm scoreboard, thêm front-end thứ hai vào mọi lần biên dịch.

### N-09 (Low): vệ sinh repo và tài liệu

| Điểm | Chi tiết |
|---|---|
| Lịch sử git | Một commit duy nhất (`Initialize RISC-V CPU cluster repository`) cho 7610 file; truy vết thay đổi chỉ nằm trong comment "Change History" của từng file và trong `doc/` |
| Artifact sinh ra bị theo dõi | 79 file `.vcd`, mã C++ do Verilator sinh (ví dụ `Vtb_cmo_ccu___024root__0__Slow.cpp`, hơn 1 MB mỗi file) |
| Bản sao trùng lặp | `scripts/third_party` (1074 file) và `verification/common/third_party` lặp lại cây `rtl/common/third_party` (ví dụ `uvm_fu_tb.ai` nằm ở hai nơi) |
| Comment lịch sử trong code | `coh_fabric.sv` chèn các khối "Change History" ở giữa file (sau `timescale`, trước `module`), khó đọc |
| HDS | 9163 dòng; mục 14 chiếm khoảng 7500 dòng hợp đồng component. Khó review và dễ lệch với RTL; audit B-05 đã ghi một số đoạn cũ nói sai trạng thái |
| `vlsit_spec_tool.py check` | FAIL vì 120 dòng tiếng Việt; đây là quyết định song ngữ đã ghi ở §2.2 của HDS (ghi đè R-005) |
| Cảnh báo NAM-08 | `PARA_PMU_COUNTER_NUM`, `w_cmo_error`, `u_vlsit_riscv_cmo_arbiter` dùng từ đầy đủ thay cho `cnt`, `err`, `arb` |

### N-10: các điểm đã kiểm và đúng

| Điểm | Cách kiểm |
|---|---|
| Directory: hình học 4 bank × 8 way, tree-PLRU, ưu tiên update/cancel của chủ reservation, chẩn đoán khi UPDATE và CANCEL đồng thời | Đọc code; TB mới |
| Bảng transaction: cấp slot, khóa line, ACK khớp tag/phase/hart, chốt owner trước PREPARE, chặn COMMIT sau lỗi đã giữ lại | Đọc code; TB mới |
| `fault_record`: lỗi đầu tiên được giữ đến reset, `multiple` đặt đúng, ưu tiên hart thấp rồi LLC, `hart_valid=0` cho LLC | Đọc code |
| `addr_decode`: kiểm bảng vùng tĩnh (căn 16 B, không chồng, vùng cacheable duy nhất ở chỉ số 0, lũy thừa của 2), kiểm truy cập vượt vùng, ATOP vào MMIO bị từ chối | Đọc code |
| Chỉ có một vùng cacheable mặc định `0x80000000–0xBFFFFFFF`; mọi địa chỉ khác trả lỗi truy cập cho đến khi tích hợp SoC thêm vùng MMIO | Đọc code; HDS mục 8 |
| Bản sao CVA6: ngắt S-mode, event tap PMU khớp mô tả | Lượt trước |
| Rule check | Chạy lại |

## 4. Các hạng mục chưa đổi từ review trước

Các phát hiện sau vẫn đúng trên RTL hiện tại; nội dung chi tiết nằm ở review 2026-11-09:

| Nhóm | ID | Tóm tắt |
|---|---|---|
| Hiệu năng | PF-01 đến PF-04 | CVA6 in-order, line 16 B, cổng AXI 64-bit đơn, đường miss dài |
| Directory | PF-06, PF-07, CC-04 | Phủ 1:1 L1D, associativity 8, mảng flop, chưa báo clean eviction, chưa SRAM/ECC |
| Hệ thống | SYS-03 | DMA không coherent, không ACE-Lite |
| Cache | CC-07, CC-08, CC-09 | FENCE.I tốn kém, CBO theo line, chưa ECC |
| Low-power | LP-01 đến LP-09 | Không có tín hiệu WFI/quiet/idle, không park hart, không ngủ SRAM |
| Debug | DB-A đến DB-H | Không reset từng hart, không halt group, không CSR chẩn đoán CCU, không trace |
| Bảo mật | RB-02 | `PPROT` không được kiểm |

Spec và audit ghi nhận đa số mục này là "ngoài phạm vi v1" hoặc "chờ SoC", không phải sót. Tôi vẫn xếp chúng ở mục "chưa giải quyết" vì chúng quyết định liệu thiết kế có đạt yêu cầu "high-performance, low-power, debug được" ban đầu hay không.

## 5. Về hiệu năng và dual/quad

Đánh giá cập nhật:

| Câu hỏi | Nhận định |
|---|---|
| High performance? | **Chưa**, và hiện chưa có số đo nào chứng minh ngược lại (HDS mục 13: không có mục tiêu IPC, tần số, công suất). Lõi CVA6 single-issue, line 16 B, bus 64-bit vẫn là các giới hạn chính. |
| Throughput nhiều hart? | Số đo mới (N-04) cho thấy tuần tự hóa theo hart đích, theo set directory, theo controller CMO và theo dirty replacement. Thêm hart không tăng throughput tương ứng khi hot data nằm ở một hart hoặc một set. |
| Ổn định cho 2/4 hart? | Được test cả hai cấu hình trên 58 ca và lint TOP cả hai. Chưa có test ngẫu nhiên nhiều hart. |
| Có thể đo hiệu năng chưa? | **Chưa tin cậy được:** audit nói PMU chưa được kiểm chứng chức năng (B-03), mà PMU là nguồn đo IPC và băng thông. |

Đề xuất bổ sung cho hiệu năng, theo thứ tự lợi ích trên chi phí (chi tiết kỹ thuật tham khảo ở mục 8 của review trước):

1. Kiểm chứng PMU và đo IPC, băng thông, số chu kỳ mỗi transaction trên workload thật trước khi tối ưu.
2. Giảm tuần tự hóa: reservation theo way thay vì theo set cho lookup hit; cho phép một hart làm đích của nhiều PREPARE khi cache hỗ trợ; probe queue trong cache.
3. Không chặn controller L1 đến B của dirty replacement khi writeback không lỗi (giữ dữ liệu trong write buffer, chỉ giữ cứng khi cần phục hồi lỗi).
4. Line 64 B; bus bộ nhớ rộng hơn; hai controller CMO hoặc CBO theo dải.
5. Nâng lõi (CVA6S+) nếu yêu cầu thực sự là high-performance.

## 6. Về spec (HDS 0.29)

| Điểm | Nhận định |
|---|---|
| Điểm mạnh | Truy vết REQ, TEST, DEC, DEP dày và nhất quán; tách rõ yêu cầu, hiện thực RTL và bằng chứng; nêu trung thực phần chưa kiểm chứng (mục 8.1 và 13); các điều kiện của chính sách "không timeout" được nêu rõ |
| Quy mô | 9163 dòng; mục 14 liệt kê hợp đồng 35 component mới và 84 module sửa. Cần một bản tóm tắt ngắn cho người mới và công cụ kiểm tra tự động lệch giữa spec và RTL (port, tham số) |
| Trạng thái cũ còn sót | Audit B-05: một số điểm DEP và header RTL nói thiếu tính năng đã có |
| Yêu cầu còn thiếu | Không có yêu cầu về tính tương thích với nhiều công cụ (N-03), về hợp đồng hạ `req_valid` của CCU cho `bank_arb`, về thứ tự ưu tiên thoát của directory (đã có REQ-MEM-019 nhưng chưa có assertion), về đảo/mapping ngắt M/S (chỉ nêu "level per hart") |
| Tham số hợp lệ nhưng không được hỗ trợ | Xem N-07; nên đổi thành "legal" chỉ cho giá trị đã verify |
| Giấy phép | Audit B-01: `lzc.sv` trong filelist production có thông báo hạn chế dùng lại; cần xử lý trước khi phát hành. Tôi đồng ý đây là điểm chặn phát hành |

## 7. Backlog đề xuất

| Ưu tiên | ID | Việc cần làm | Tiêu chí hoàn tất |
|---|---|---|---|
| P0 | N-02 | Sửa bridge LLC (`& ~w_wr_addr_wr_denied`), thêm test ghi SPM/read-only qua AXI4-Lite thật | `repro/reg_bridge_denied_write` ra PASS; test ở mức TOP: ghi vào `0x5000` + offset cấm trả SLVERR, không đổi cấu hình LLC |
| P0 | N-01 | Đảo `irq_i` thành `{i_int_seip, i_int_meip}`; test CPU thật cho MEIP, SEIP, delegation, WFI | Test đạt ở 2 và 4 hart |
| P0 | N-03 | Khai báo trước khi dùng ở `cluster_core`, `coh_fabric` và các bản sao có sửa; thêm `slang` (và Questa nếu có license) vào script lint và rule check; thống nhất `common_cells` | `slang` 0 lỗi ở 2 và 4 hart; Questa biên dịch được |
| P0 | B-01 (audit) | Xử lý thông báo hạn chế của `lzc.sv` | Ghi nhận quyền sử dụng hoặc thay thế có kiểm chứng |
| P1 | N-05 | Nhánh `default` an toàn cho FSM probe engine | Không còn `'x` trong output valid |
| P1 | RB-02 | Quy tắc `PPROT` cho CSR và dịch vụ LLC | Truy cập không đặc quyền bị từ chối |
| P1 | CC-10, B-03 | Sửa W1C của PMU IRQ; test chức năng PMU/CSR; đóng đường LLC service (BIST, flush) | Test đồng thời tràn và W1C; BIST/flush thật |
| P1 | N-08 | Random coherence với scoreboard dữ liệu độc lập; thêm front-end thứ hai vào mọi build | Báo cáo coverage; không hang trong giới hạn phản hồi |
| P1 | N-04 | Mô hình hóa tuần tự hóa (hart đích, set directory, CMO, dirty replacement); cân nhắc giảm | Số đo trước và sau trên workload chia sẻ |
| P2 | N-06, N-07 | Đường lỗi cho CMO bất hợp pháp; khóa tham số chưa hỗ trợ | HDS mục 8 ghi giá trị hỗ trợ |
| P2 | LP-01..LP-09, DB-A..DB-H | Low-power và debug (đề xuất ở review trước) | Spec REQ mới và RTL |
| P3 | N-09 | Dọn repo (artifact sinh ra, bản sao trùng), tách lịch sử | Repo nhỏ hơn, lịch sử rõ |

## 8. Câu hỏi cần chủ dự án quyết định

1. Có chấp nhận đảo lại `irq_i` ngay (N-01) và coi đây là sửa lỗi chứ không phải đổi spec?
2. Mục tiêu công cụ: RTL phải biên dịch được trên công cụ nào (VCS, Questa, Xcelium, Design Compiler, Spyglass, Verilator)? Từ đó quyết định front-end cần chạy trong lint.
3. Có chấp nhận giới hạn `PARA_COH_TXN_NUM >= 3` để tránh trường hợp một transaction trong toàn cluster?
4. Có muốn giảm tuần tự hóa (N-04) bây giờ, hay giữ "đúng trước" cho tới khi có số đo PMU đáng tin?
5. Low-power và debug: giữ ngoài phạm vi v1 như HDS, hay đưa các cổng tối thiểu (`o_hart_wfi`, `o_hart_quiet`, reset từng hart) vào v1?

## Phụ lục A. Bản tái hiện trong `repro/`

| Case | Kết quả hiện tại | Ý nghĩa |
|---|---|---|
| `dir_deadlock` | `RESULT: PASS` | CC-01 không còn tái hiện |
| `bank_arb_dup_grant` | `RESULT: PASS` | CC-03 không còn |
| `txn_probe_rate` | `TXN-RATE ... 12 cycles per transaction`; `DUP-ACK ... o_ack_ready=1` | Số đo mới; CC-02 đã đóng |
| `reg_bridge_denied_write` | `RESULT: FAIL (RB-01 present)` | Lỗi còn; test này sẽ thành regression sau khi sửa |

Chạy: `sh doc/review/repro/<case>/run.sh` (cần Verilator và g++, xem `repro/README.md`).

## Phụ lục B. Lệnh đã dùng cho N-03

```sh
# slang (TOP, 2 hart, cùng filelist với scripts/run_cluster_top_lint.py)
slang --top m_vlsit_riscv_cluster_axi_top -G PARA_CPU_NUM=2 <các -I include> \
  -f rtl/common/filelists/cva6_flush_path/cva6_modified_cache.Flist \
  -f rtl/non_coherence_cluster/filelists/full_integration/filelist_llc_unique.f \
  -f rtl/non_coherence_cluster/filelists/full_integration/filelist_vlsit_cluster.f --timescale 1ns/1ps

# QuestaSim, từng file
vlog -sv -work work rtl/non_coherence_cluster/m_vlsit_riscv_cluster_core.sv
vlog -sv -work work rtl/common/vlsit/coherence/m_vlsit_riscv_coh_fabric.sv
```
