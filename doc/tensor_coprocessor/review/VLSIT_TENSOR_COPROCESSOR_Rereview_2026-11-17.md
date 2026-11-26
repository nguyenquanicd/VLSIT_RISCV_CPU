# Review lại Tensor Coprocessor: HDS đã cập nhật và phản biện phân tích lựa chọn kiến trúc

| Mục | Nội dung |
|---|---|
| Ngày | 2026-11-17 (lần hai, sau khi HDS và các tài liệu liên quan được cập nhật) |
| Đối tượng | [HDS](../VLSIT_TENSOR_COPROCESSOR_HDS.md) (1743 dòng, trước đó 1625), [instruction set](../TENSOR_COPROCESSOR_INSTRUCTION_SET.md), `tcop_regs.json`, `figures/ctrl_fsm.json`, [phân tích lựa chọn kiến trúc](VLSIT_TENSOR_COPROCESSOR_Architecture_Options_Analysis_2026-11-17.md), và [review lần một](VLSIT_TENSOR_COPROCESSOR_Review_2026-11-17.md) (nay đã có thêm TI-03, TS-04, TS-05 do người khác ghi) |
| Việc đã làm | Đọc các phần thay đổi của HDS (§9.1, §13, §20, DEC-016 đến DEC-029), đọc đầy đủ phân tích lựa chọn kiến trúc, so FSM và CSR với văn bản, **đọc source CVA6** (`commit_stage.sv`, `cvxif_fu.sv`, `cvxif_issue_register_commit_if_driver.sv`, `csr_regfile.sv`) để giải quyết các điểm tranh luận |
| Không làm | Chưa có RTL tensor để kiểm; không chạy lại các probe (không đổi) |
| Nhãn bằng chứng | **C** đọc code CVA6, **S** đọc spec, **E** ước tính, **V** đã chạy công cụ |

## 0. Kết luận ngắn

| Câu hỏi | Kết luận |
|---|---|
| Spec cập nhật có tốt hơn không? | **Có, rõ rệt.** Đã nhận các phát hiện nền tảng của review lần một: §13 nay có đoạn roofline đúng (tile 128 cho 8,2 TOPS, không phải 58 hay 64), FSM có `ERR_DRAIN`, workbook CSR đã bỏ `op_mode` và có bản ghi lỗi, có ma trận operation × precision (§9.1), tách top tensor riêng khỏi cluster (DEC-016). |
| Các phản bác trong phân tích lựa chọn có đứng vững không? | **Phần lớn có**, và tôi rút lại hoặc hạ mức một số đề xuất trước đó (mục 2). Nhưng có **ba điểm** tôi giữ hoặc nâng mức nhờ đọc source CVA6: lệnh tensor chặn retire của CVA6, độ trễ ngắt và debug bằng thời gian command (mục 3), và thiết kế fence/ack của OP-003 phức tạp hơn mức cần thiết (mục 4). |
| Có lỗi mới nào trong HDS cập nhật không? | Có vài điểm: cấu hình `CFG-64TOPS` vẫn ghi "full algorithm set" trong khi §9.1 cho thấy gần như mọi họ bị từ chối với INT8 (N-01), tổ hợp FP khuyến nghị nhưng throughput và timing FP chưa có (N-02), FSM vẫn tuần tự và chờ result handshake (N-03), OP-003 làm cả hart dừng ở issue (N-04). |
| Nên làm gì tiếp? | (1) Thêm yêu cầu giới hạn thời gian của một command (hoặc chế độ submit) để bảo vệ độ trễ ngắt. (2) Thay hoặc đơn giản hóa fence/ack OP-003. (3) Làm thí nghiệm timing PE trước freeze như đã đồng ý. (4) Đồng bộ lại `CFG-64TOPS` với §9.1. |

## 1. Những gì đã được cập nhật so với review lần một

| Phát hiện của tôi | Trạng thái trong HDS và tài liệu mới | Đánh giá |
|---|---|---|
| TP-01 (trần 8,2 TOPS, không phải 58 hay 64) | §13 có đoạn mới: "T=128 là khoảng 8,2 TOPS", kèm các điểm T=64 đến 1024 và dung lượng SRAM | **Đã nhận đúng.** Còn thiếu: PPA-004 vẫn ghi "64 TOPS per IP" là mục tiêu người dùng chọn |
| TP-02 (số array theo băng thông) | DEC-018: phân biệt `B_peak` và `B_eff`; "chưa giới hạn array count bằng `B_eff` chưa đo" | Hợp lý về nguyên tắc; nhưng không có điểm cân bằng nào được nêu |
| TP-03 (INT4) | Phân tích lựa chọn §5: hoãn, đo trước, W4A8 trước FP8 | Chấp nhận, xem 2.4 |
| TT-01 (vòng tích lũy) | Phân tích lựa chọn §8: "rủi ro cần đo", làm thí nghiệm PE với thư viện thật trước RTL freeze | Chấp nhận, xem 2.5 |
| TT-04 đến TT-06 (thêm cut, số tầng, skid) | Giữ năm cut đã chọn (DEC-001), nêu thêm rằng nếu đường tới hạn nằm ngoài các cut thì cần quyết định kiến trúc mới | Chấp nhận có điều kiện, xem 2.5 |
| TT-07 (tách clock) | Giữ một `CLK-CORE`; mở lại khi có STA | Chấp nhận, xem 2.6 |
| TI-01 (CV-X-IF vs cluster) | DEC-016: top tensor riêng có CVA6 bật CV-X-IF, giữ cluster nguyên trạng | **Đã giải quyết ở mức quyết định** |
| TL-02 (FSM lỗi thời) | FSM có `ERR_DRAIN` từ `DECODE`, `FETCH`, `COMPUTE`, `POST` | **Đã sửa phần lỗi.** Phần tuần tự (`WRITEBACK → IDLE : result handshake`) còn nguyên (N-03) |
| TS-04 (CSR lỗi thời) | `tcop_regs.json` v1.1: bỏ `op_mode`, thêm `tcop_err_sts`, `_hartid`, `_xif_id`, `_addr_lo/hi`, `_axi_id`, `_detail`, `scalar_ack` | **Đã sửa** |
| UT-02 (một command sở hữu mọi array) | Giữ cho bản đầu (DEC-006) | Chấp nhận, xem 2.2 |
| UT-03, UT-04 (retire, prefetch) | Phân tích lựa chọn §2, §7: giữ ABI hiện tại; coi lập luận retire là giả thuyết; không đọc descriptor trước commit | **Tranh luận chính**, xem mục 3 |
| UT-09 (bộ đếm hiệu năng) | PPA-006: "không yêu cầu counter trên IP"; chọn A (trace và PMU hệ thống) | Xem 2.7 |
| TL-01 (mục tiêu latency) | PPA-005, 006, 008 vẫn TBD | **Chưa đổi** |
| Phát hiện lần một về §9 số học INT8/FP | §9.1 và DEC-017 | **Đã nhận** |

## 2. Phản biện các điểm trong phân tích lựa chọn kiến trúc

### 2.1 Cách đặt vấn đề (đồng ý, và thêm một yêu cầu)

Tài liệu đó nói đúng rằng nhiều đề xuất của tôi đảo quyết định người dùng đã chốt (DEC-001: năm cut, vòng tích lũy cố định; một clock; CV-X-IF theo lệnh). Tôi chấp nhận cách tiếp cận "đề xuất kèm điều kiện kích hoạt" và hạ các mục §9 của review lần một từ "redline" xuống "lựa chọn có trigger". Điều tôi giữ: mỗi lựa chọn phải có **trigger đo được**, không chỉ "khi cần". Mục 5 đề xuất bộ trigger.

### 2.2 Nhóm array độc lập (đồng ý một phần, hạ ưu tiên)

Lập luận đúng: decode bị giới hạn bởi băng thông, nên chia array chỉ chia nhỏ cùng một nguồn băng thông. Tôi rút lại việc xem nhóm array là đòn bẩy chính cho decode (§8.3 mục 3 của review lần một).

Điều tôi giữ, và đây là điểm khác biệt: đòn bẩy thực sự là **gộp nhiều hàng vào một lần đọc trọng số** (batch, speculative, nhóm query GQA, chunk prefill cộng token decode). Lúc đó M tăng mà không tăng byte trọng số, nên utilization tăng tỷ lệ với M (M/512 ở INT8, 64 GB/s). Phân tích lựa chọn không nêu ABI hỗ trợ M nhỏ đến vừa. Đề xuất giữ lại: descriptor GEMM cho phép M từ 1 đến 16 chạy hiệu quả (vector-dot hoặc cột nhóm) và cho phép gộp nhiều chuỗi vào cùng một command. Việc này không cần nhóm array.

### 2.3 Ring và doorbell (đồng ý giữ A, kèm điều kiện)

Giữ CV-X-IF theo lệnh là hợp lý. Nhưng khẳng định của tôi về "queue sâu vô dụng" cần chỉnh theo source CVA6 (mục 3): queue sâu **dùng được** nếu phần mềm dựng sẵn và clean các descriptor trước, rồi phát liên tiếp tối đa khoảng 7 lệnh. Ring không cần thiết để đạt throughput; vấn đề thực sự là độ trễ ngắt, xem mục 3.

### 2.4 INT4 và FP8 (đồng ý)

Phân tích đúng ở hai điểm: FP8 không giảm byte so với INT8, và `funct3=011` không nên đặt trước. Tôi rút lại đề xuất "`3'b011 = W4A8`" (§9.5 lần một). Giữ lại một điểm: nếu KPI chính là decode batch-một, W4A8 là đòn bẩy duy nhất tăng tokens/s gấp đôi, nên nó phải được quyết định **trước ABI freeze** (không phải sau), vì chọn sau sẽ buộc ABI phiên bản mới cho mọi phần mềm.

### 2.5 Vòng tích lũy và các cut (đồng ý, với một đòi hỏi)

Phân tích đúng rằng probe Yosys chỉ xếp hạng tương đối, không cho GHz. Tôi đồng ý bỏ cụm "bắt buộc carry-save" và thay bằng thí nghiệm PE. Hai điều cần ghi trong HDS để thí nghiệm đó có hiệu lực:

1. **Cổng quyết định:** "Nếu PE tham chiếu ba biến thể (carry-propagate, carry-save, hai bank) với thư viện thật không đạt `f_array` mục tiêu, một DEC mới phải chọn kiến trúc tích lũy trước RTL freeze." Hiện văn bản chỉ nói "khuyến nghị thêm timing experiment", chưa có cổng.
2. **Kết hợp tham số:** tổ hợp `PARA_ACCUM_W=48` hoặc `64` với `f_array > 1 GHz` phải bị từ chối ở elaboration cho đến khi thí nghiệm cho thấy khả thi (vòng 64 bit sâu 80 mức so với 48 của 32 bit trong probe).

### 2.6 Clock (đồng ý, nêu rõ điều kiện đổi quyết định)

Chấp nhận giữ `CLK-CORE`. Tôi cũng chấp nhận rằng ước lượng 1,09 GHz của CVA6 trong bài báo CVA6S+ là của biến thể khác. Hai điều cần ghi trong HDS: (a) trigger đổi sang miền clock riêng là "STA của PE hoặc SRAM đạt mục tiêu nhưng đường CVA6/CV-X-IF không đạt"; (b) khi chọn top tensor riêng (DEC-016), tần số CVA6 trong top đó là một lựa chọn thiết kế chứ không phải ràng buộc hệ thống, vì không còn cluster 2/4 hart.

### 2.7 Bộ đếm hiệu năng (đồng ý một phần)

Chọn A (trace và PMU hệ thống) ở bản đầu chấp nhận được cho mô phỏng. Nhưng PMU của CVA6 không thấy stall bên trong IP, và PPA-006 lại đặt thước đo "array utilization" mà không có nguồn đo trên silicon. Đề xuất thỏa hiệp: ngay bản đầu có **bốn bộ đếm** (`cmd_cycles`, `array_busy_cycles`, `dma_rd_busy_cycles`, `dma_wr_busy_cycles`), mỗi bộ 48 bit có snapshot. Chi phí: khoảng 200 flip-flop và 4 đến 8 thanh ghi CSR, bé hơn nhiều so với rủi ro không đo được utilization trên silicon. Counter theo nhóm và nguyên nhân stall chi tiết để sau.

### 2.8 Đọc descriptor trước commit (rút lại, và có thêm dữ kiện)

Phân tích lập luận rằng đọc trước commit có rủi ro (MMIO, bị kill, lỗi bus của lệnh đã kill). Tôi rút lại UT-04. Đọc source CVA6 cho thấy vấn đề **không tồn tại với CVA6**: `cvxif_issue_register_commit_if_driver.sv` có chú thích "Always commit since speculation in execute is not possible" và `commit_valid_o = issue_valid_o && issue_ready_i`, `commit_kill = 1'b0`. Tức **CVA6 gửi commit đồng thời với issue và không bao giờ kill**. Hệ quả:
- Với host CVA6, "đợi commit" không tốn thêm chu kỳ nào; DMA đọc descriptor được ngay sau khi nhận đủ operand.
- Logic kill, commit-before-register, register reorder của DEC-024 là cần cho tổng quát CV-X-IF nhưng **không được thực thi bởi CVA6**. Verification với CVA6 thật không bao giờ chạm các nhánh đó; cần driver CV-X-IF tổng hợp để phủ.

Khuyến nghị: ghi vào HDS "với host CVA6, commit đi cùng issue" để tránh ước lượng chi phí chờ commit không có thật.

## 3. Giải quyết tranh luận về retire, ngắt và debug (đọc source CVA6)

Phân tích lựa chọn viết rằng lập luận retire của tôi "là giả thuyết về đường retire cụ thể của CVA6". Tôi đã đọc source để kết luận.

| Sự kiện | Bằng chứng (C) |
|---|---|
| Lệnh offload hoàn tất trong scoreboard khi coprocessor trả result | `cvxif_fu.sv:61`: `x_valid_o = x_illegal_i \|\| result_valid_i` |
| Chỉ lệnh ở đầu scoreboard mới retire | `commit_stage.sv`: mọi quyết định `commit_ack_o[0]`, `commit_lsu_o` dựa trên `commit_instr_i[0]` (lệnh cũ nhất) |
| Store chỉ vào store buffer khi commit | `commit_stage.sv`: `commit_instr_i[0].fu == STORE` rồi `commit_lsu_o = 1` |
| Ngắt gắn vào lệnh được decode, được nhận khi lệnh đó retire | `id_stage.sv` và `decoder.sv` nhận `irq_ctrl_i` và `irq_i`; ngắt đi cùng lệnh trẻ hơn và chỉ thành trap khi lệnh đó lên đầu scoreboard (suy ra từ cấu trúc, chưa mô phỏng) |
| Yêu cầu halt của debug chặn commit tiếp theo | `commit_stage.sv`: `if (commit_instr_i[0].valid && !halt_i)` |

Kết luận: khi một lệnh tensor là lệnh cũ nhất và chưa trả result, **CVA6 không retire lệnh nào sau nó**. Hệ quả:

1. **Store descriptor của lệnh kế tiếp chưa commit** nên DMA chưa thấy. Queue sâu chỉ có ích nếu phần mềm dựng và clean mọi descriptor **trước** lệnh tensor đầu tiên, rồi phát liên tiếp; scoreboard 8 mục giới hạn khoảng 7 lệnh trẻ hơn. Đây **không** cần ring, chỉ cần kỷ luật phần mềm. Tôi chỉnh UT-03 theo hướng này.
2. **Độ trễ ngắt bằng thời gian còn lại của command.** Một GEMM 1024×4096×4096 ở trần 8,2 TOPS mất khoảng 4,2 ms; LM head 128 K × 2048 INT8 (262 MB) ở 64 GB/s mất 4,1 ms (E). Trong thời gian đó CPU không nhận được ngắt. Cho hệ thống thời gian thực (tick 1 ms) đây là lỗi.
3. **Debug không halt được hart** trong lúc command chạy, vì halt chặn commit lệnh sau nhưng lệnh tensor ở đầu vẫn chưa hoàn tất.
4. DEC-029 (reset toàn SoC khi thiếu response AXI) làm tình huống xấu hơn: CPU đang chờ result và không thể phục vụ watchdog nếu watchdog là ngắt hart đó.

Spec không có yêu cầu nào về ngắt hay debug trong lúc có lệnh tensor đang chạy (không có từ khóa "interrupt latency" hay halt ngoài ngữ cảnh error). Đề xuất (chọn một, không đổi ABI đã chọn):

| Phương án | Nội dung | Chi phí |
|---|---|---|
| **R1. Giới hạn thời gian command ở driver** | Driver chia GEMM lớn thành chunk có thời gian ≤ 100 µs (cùng mô hình bộ nhớ); phát tối đa 7 lệnh dựng sẵn | Mỗi chunk thêm khoảng 1 µs CPU (E), tức khoảng 1% ở 100 µs; không đổi phần cứng |
| **R2. Yêu cầu phần cứng bảo đảm thời gian tối đa mỗi command** | HDS đặt `T_cmd_max` (ví dụ 100 µs) như hợp đồng; descriptor hợp lệ vượt ngưỡng bị từ chối (`TC_ERR_SHAPE`) | Thêm kiểm tra ở validator; driver bắt buộc chia |
| **R3. Chế độ `TC_SUBMIT` và `TC_SYNC`** | Trả result ngay khi nhận; `TC_SYNC` chờ | ABI mới (đã so sánh ở phân tích lựa chọn §2 B) |

R1 và R2 giữ nguyên ABI đã chọn và giải quyết ngắt và debug; tôi đề xuất R2 vì biến một thói quen driver thành hợp đồng kiểm chứng được (test: ngắt phản hồi trong ≤ `T_cmd_max` kể từ lúc assert). R3 chỉ khi có số liệu cho thấy R1 hoặc R2 không đủ.

## 4. OP-003: fence và ack có phức tạp quá mức cần thiết

DEC-021 (phân tích lựa chọn §10.7): OP-003 trả scalar trong `rd`; lỗi cũng trả zero; phần mềm lấy khóa toàn cục, đợi idle, dọn lỗi cũ; phần cứng chỉ nhận OP-003 ở clean boundary và chặn mọi hart bằng `issue_ready=0` cho tới result handshake; nếu result bằng zero thì giữ fence cho đến khi phần mềm đọc `err_valid`, W1C và ghi `scalar_ack` qua APB bất đồng bộ.

Vấn đề:

1. **Zero là kết quả phổ biến.** Tổng của vector có thể bằng 0, và **max** của một vector sau ReLU bằng 0 rất thường. Nghĩa là nhánh chậm (đợi APB, CDC, phần mềm) không phải ngoại lệ mà là nhánh thường gặp.
2. **Chặn issue là chặn cả hart.** CVA6 issue theo thứ tự: một lệnh tensor bị backpressure ở `issue_ready=0` chặn **mọi lệnh sau nó** của hart đó, không chỉ lệnh tensor. Fence kéo dài thêm vài trăm ns đến µs (đường APB bất đồng bộ cộng phần mềm) làm đóng băng các hart khác.
3. **Rủi ro deadlock do phần mềm.** Hart giữ khóa cần phát `scalar_ack` (một store sau lệnh OP-003). Nếu bất kỳ đường nào khiến một lệnh tensor khác của chính hart đó đã xếp trước store đó (ví dụ trong handler), store không bao giờ được issue. Phần cứng admission không cứu được vì nó chỉ ngăn phát lệnh mới, không ngăn deadlock đã hình thành. Chỉ reset toàn SoC mới gỡ.
4. Chi phí kiểm chứng đã nằm trong TEST-025, SVA-009, COV-006 (các tổ hợp zero-success, error-zero, ack ngoài cửa sổ, kill, reset).

**Phương án thay thế đề xuất (không đổi ý định "scalar trong rd, lỗi qua CSR"):** nhúng cờ hợp lệ vào chính result.
- Host RV64 (`X_RFW_WIDTH=64`): kết quả REDUCE chỉ cần 32 bit (tổng INT32 hoặc FP32), nên trả `rd = {status[31:0], value[31:0]}`; `status=0` là thành công. Một lệnh, không fence, không APB, không khóa toàn cục.
- Host RV32: dùng `X_DUALWRITE` (`rd` và `rd+1`) nếu host hỗ trợ, hoặc chấp nhận fence/ack riêng cho RV32.
- CSR vẫn giữ bản ghi lỗi chi tiết như hiện nay.
Cái giá: hợp đồng ABI khác nhau giữa RV32 và RV64, và phần mềm RV64 phải tách hai nửa; đổi lại loại bỏ điểm tuần tự hóa toàn accelerator và một lớp deadlock. Nên đưa vào danh sách phương án của DEC-021 trước khi RTL freeze.

## 5. Bộ trigger đề xuất cho các lựa chọn đã hoãn

| Lựa chọn hoãn | Trigger đo được để mở lại |
|---|---|
| Ring, `TC_SUBMIT` | Trace cho thấy khe hở host giữa hai command > 5% thời gian ở workload đại diện, sau khi áp dụng R1 hoặc R2 |
| Nhóm array độc lập | Có ≥ 2 workload độc lập đồng thời **và** DMA còn headroom ≥ 30% khi chạy đơn |
| Tách clock tensor | STA của PE và SRAM đạt `f_array` nhưng đường CV-X-IF hoặc CVA6 không đạt; hoặc yêu cầu DVFS riêng |
| W4A8 | KPI chính là tokens/s decode và checkpoint 4-bit đạt ngân sách chất lượng; phải quyết **trước ABI freeze** |
| Carry-save hoặc hai bank accumulator | PE tham chiếu carry-propagate không đạt `f_array` với thư viện thật |
| Bộ đếm theo nhóm, chi tiết stall | Sau khi có nhóm array |

## 6. Điểm mới trong HDS cập nhật

### N-01 (High, S): `CFG-64TOPS` và `CFG-FULL` quảng bá mọi họ thuật toán, nhưng §9.1 từ chối gần hết với INT8

§4 và §8.1 ghi `CFG-64TOPS` "Full algorithm capability set" với `PARA_DATA_PREC=0` (INT8 thuần). §9.1 viết: một cặp ở trạng thái "Open" thì "build shall not advertise it and issue shall reject it". Ở cột INT8, các hàng OP-002, 003, 005, 006, 007, 009 đều "Open". Kết quả: cấu hình 64 TOPS hiện **chỉ có OP-001 (nhưng chưa qualified về overflow, làm tròn), OP-004 và OP-008** chạy được, phần còn lại bị từ chối tại issue. Tên "full algorithm capability set" gây hiểu nhầm. DEC-017 đã nhận ra vấn đề; cần cập nhật bảng cấu hình tương ứng (hoặc hạ mô tả, hoặc đóng ô INT8 trước).

### N-02 (High, S): khuyến nghị bật BF16 và FP16 nhưng throughput và timing FP chưa có

Phân tích lựa chọn §10.2 khuyến nghị: nếu yêu cầu là đủ các họ Transformer thì build đầy đủ nên có BF16 và FP16. Nhưng REQ-PERF-001 chỉ cam kết INT8; throughput FP "báo cáo riêng" và vòng tích lũy FP32 không thể một chu kỳ ở tần số mục tiêu (TT-03 của review lần một: độ sâu 114 so với 48). Nếu build FP là bắt buộc thì đỉnh TOPS của nó, hiệu suất tích lũy FP (interleave hoặc kiểu Kulisch) và diện tích gấp 2 đến 4 lần phải đi cùng khuyến nghị. Không có điều đó, `PARA_DATA_PREC=1` là lời hứa chức năng không có hợp đồng hiệu năng.

### N-03 (Medium, S): FSM vẫn tuần tự và chờ result handshake

FSM mới đã đúng về lỗi (`ERR_DRAIN`), nhưng `WRITEBACK → IDLE : result handshake` và `ERROR → IDLE : error result handshake` còn nguyên: lệnh kế tiếp chưa bắt đầu trước khi host nhận result. Với CVA6 (mục 3) host chỉ nhận result khi lệnh đó ở đầu scoreboard, nên result của lệnh n+1 sẽ chờ lệnh n; điều này làm bubble giữa các command phụ thuộc vào trạng thái pipeline của CPU. Đề xuất nhỏ, không đổi kiến trúc: thêm FIFO kết quả sâu 1 đến 2 mục để `WRITEBACK` trả quyền điều khiển ngay khi result vào FIFO. Chi phí vài chục flip-flop.

### N-04 (Medium, S, C): OP-003 chặn issue của mọi hart (xem mục 4)

### N-05 (Low): lỗi định dạng và nhất quán

| Điểm | Chi tiết |
|---|---|
| Văn bản literal | Phân tích lựa chọn dòng 237 còn chuỗi `\n### 10.8` hiển thị nguyên văn, mục 10.8 không thành tiêu đề |
| §13 PPA-004 | Vẫn ghi "User-selected ideal peak target: 64 TOPS per IP" dù đoạn bên dưới nói T=128 cho 8,2 TOPS. Nên đưa câu "đỉnh lý thuyết, không phải kết quả đạt được" vào chính hàng PPA-004 |
| Cổng đo | PPA-006 không yêu cầu counter, nhưng thước đo "array utilization" của chính nó cần nguồn đo |
| Tham số mặc định | Năm `PARA_PIPELINE_*_EN` vẫn "TBD" (đã được nêu: sẽ chốt theo thư viện) |

## 7. Danh sách việc đề xuất (cập nhật)

| Ưu tiên | Việc | Tiêu chí hoàn tất |
|---|---|---|
| P0 | Thêm yêu cầu về độ trễ ngắt và debug khi có lệnh tensor đang chạy (R1 hoặc R2 ở mục 3) | REQ mới và test: ngắt phản hồi trong `T_cmd_max` |
| P0 | Đánh giá lại fence/ack OP-003 so với phương án đóng gói trạng thái vào result (mục 4) | DEC-021 ghi cả hai phương án với ưu nhược |
| P0 | Đồng bộ `CFG-64TOPS` và `CFG-FULL` với §9.1 (N-01); gắn đỉnh TOPS FP và throughput FP khi bật BF16/FP16 (N-02) | Bảng cấu hình khớp ma trận qualified |
| P1 | Thêm cổng quyết định cho thí nghiệm PE (mục 2.5) và loại tổ hợp `PARA_ACCUM_W>32` ở `f_array>1 GHz` đến khi có kết quả | DEC mới và kiểm tra elaboration |
| P1 | FIFO result để tách `WRITEBACK` khỏi result handshake (N-03) | FSM và test result backpressure |
| P1 | ABI hỗ trợ M nhỏ đến vừa và gộp nhiều chuỗi vào một command (mục 2.2) | Descriptor có trường batch |
| P1 | Bốn bộ đếm tối thiểu (mục 2.7) | Thanh ghi CSR và test snapshot |
| P2 | Ghi "host CVA6 gửi commit cùng issue, không kill" vào HDS; thêm driver CV-X-IF tổng hợp để phủ kill (mục 2.8) | Mục hướng dẫn tích hợp và test kill |
| P2 | Quyết định W4A8 trước ABI freeze nếu decode là KPI chính (mục 2.4) | DEC mới |
| P3 | Sửa các điểm N-05 | Tài liệu sạch |

## 8. Câu hỏi cho chủ dự án

1. Hệ thống có yêu cầu thời gian thực nào (độ trễ ngắt tối đa, watchdog bằng ngắt, debug halt) cần bảo đảm khi một lệnh tensor đang chạy? Câu trả lời quyết định R1, R2 hay R3 (mục 3).
2. Có chấp nhận ABI kết quả khác nhau giữa RV32 và RV64 cho OP-003 (mục 4) để bỏ fence/ack không?
3. Bản FP (BF16, FP16) có bắt buộc trong release đầu không? Nếu có, mục tiêu đỉnh TOPS FP là bao nhiêu?
4. KPI chính của sản phẩm là decode batch-một hay prefill? Câu trả lời quyết định có đưa W4A8 vào trước ABI freeze không.

## Phụ lục. Dẫn chứng từ source CVA6

| Tệp | Nội dung |
|---|---|
| `rtl/common/third_party/cva6/core/cvxif_issue_register_commit_if_driver.sv` | "Always commit since speculation in execute in not possible", `commit_valid_o = issue_valid_o && issue_ready_i`, `commit_kill = 1'b0` |
| `rtl/common/third_party/cva6/core/cvxif_fu.sv` | `x_valid_o = x_illegal_i \|\| result_valid_i` |
| `rtl/common/third_party/cva6/core/commit_stage.sv` | Commit chỉ lệnh `commit_instr_i[0]`; `commit_lsu_o` cho store ở đầu; không commit khi `halt_i` |
