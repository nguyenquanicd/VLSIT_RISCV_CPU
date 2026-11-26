# Phân tích sâu các lựa chọn kiến trúc Tensor Coprocessor

| Thuộc tính | Giá trị |
|---|---|
| Ngày | 2026-11-17 |
| Mục đích | Phân tích ưu/nhược và điều kiện chọn các đề xuất mở rộng trong bản review; không tự thay đổi quyết định người dùng đã chốt |
| Tài liệu chuẩn | [HDS](../VLSIT_TENSOR_COPROCESSOR_HDS.md), [Instruction Set](../TENSOR_COPROCESSOR_INSTRUCTION_SET.md), [Review](VLSIT_TENSOR_COPROCESSOR_Review_2026-11-17.md) |

> Đây là phân tích lựa chọn, không phải yêu cầu RTL. Những quyết định đã chọn — CV-X-IF per-command descriptor ABI, `custom-0`/`funct7`/`funct3`, AXI4 non-coherent + banked SRAM, 5 pipeline boundaries, một clock datapath `CLK-CORE`, result theo opcode, và `PARA_ARRAY_COUNT` là tham số build — vẫn có hiệu lực. Các phương án dưới đây chỉ được đưa vào HDS như yêu cầu sau khi có quyết định và dữ liệu đủ chứng minh.

## 1. Câu hỏi thiết kế

Mục tiêu “hiệu năng cao, latency thấp” có nhiều nút thắt khác nhau. **Prefill** thường có ma trận lớn và nhiều hàng dùng chung trọng số nên có thể khai thác nhiều PE; **decode batch-một** thường đọc một lượng trọng số lớn để tạo một token nên bị giới hạn bởi băng thông/trọng số trong cache. Một thay đổi có thể cải thiện TOPS prefill nhưng làm tăng thời gian chờ đầu tiên, độ phức tạp phần mềm hoặc diện tích. Vì vậy, so sánh phải dùng cùng workload, cùng `B_dma`, capacity SRAM, tần số, precision, cache policy, và định nghĩa latency.

Các số 64 TOPS, 64 GB/s, 128 KiB, 2 GHz trong HDS là các điểm phân tích/ứng viên; chúng chưa phải kết quả đo. Phân tích này không biến tỷ lệ utilization 85/90%, tần số 2 GHz hay một số counter thành tiêu chí phát hành.

## 2. Command ABI: lệnh hoàn tất trực tiếp hay submit bất đồng bộ

| Phương án | Behavior | Ưu điểm | Chi phí/rủi ro |
|---|---|---|---|
| **A. CV-X-IF per-command, descriptor pointer (đã chọn)** | Mỗi lệnh custom xác định operation/precision; `rs1`/`rs2` đưa con trỏ descriptor theo XLEN; accelerator trả một result khi command hoàn tất | ABI ngắn; software/runtime nhìn thấy command nào chưa hoàn tất; dễ giữ result class theo opcode; không có token/doorbell mới; phù hợp latency thấp cho lệnh nhỏ | Command dài có một CV-X-IF transaction tồn tại đến completion; queue depth và khả năng host phát lệnh trẻ hơn phụ thuộc tích hợp CVA6; descriptor phải có sẵn/được clean trước khi DMA đọc |
| **B. Ring descriptor + doorbell + `TC_SUBMIT/TC_SYNC`** | Phần mềm ghi nhiều descriptor, gửi doorbell/submit ngắn; hardware tự đọc ring. `TC_SUBMIT` trả lúc nhận; `TC_SYNC` chờ token/fence | Tách thời gian thực thi tensor khỏi thời gian sống của lệnh CPU; amortize dispatch/doorbell; dễ thể hiện graph/layer đã dựng sẵn; có thể giảm khoảng trống giữa command ngắn | ABI lớn hơn: ring base/size, producer/consumer index, wrap, token dependency, cancellation, timeout, memory-ordering, fairness, error association và overflow. `TC_SUBMIT` không còn đại diện cho completion phép tính; software phải đồng bộ đúng trước khi dùng output. Ring là non-coherent nên cần cache ownership, và một doorbell CSR có thể không phù hợp nếu command-control đã chọn CV-X-IF |
| **C. Doorbell CSR-only** | CPU ghi descriptor/ring address và start qua APB | Dễ quan sát bằng driver/bring-up; không giữ CV-X-IF result transaction | APB thêm round-trip và không mang result class theo instruction; phải tạo completion interrupt/polling, token/queue semantics; đi ngược lựa chọn “mọi command vào qua CV-X-IF” và DEC-011 |

**Đánh giá.** A giữ latency contract đơn giản và completion gắn đúng với instruction; nó phù hợp với command ABI đã chọn. B có thể tăng thông lượng host khi *đã chứng minh* dispatch/retire là nút thắt, nhưng queue sâu không tự tăng memory bandwidth, không tạo dữ liệu phụ thuộc, và không khắc phục array idle do batch-một. Phân tích review cho rằng các store descriptor trẻ chưa commit khi lệnh tensor trước còn chạy là một giả thuyết về đường retire cụ thể của CVA6, không phải kết luận từ CV-X-IF spec. Cần kiểm RTL/integration trace trước khi dùng giả thuyết đó để thay ABI.

**Khuyến nghị:** giữ A ở bản đầu. Tối ưu trước bằng buffer/descriptor prefetch *trong các command đã được commit* và đo khe hở giữa command. Chỉ mở RFC cho B nếu trace cho thấy host dispatch hoặc lifetime của result transaction làm giảm throughput đáng kể. Nếu mở B, giữ A cho các lệnh nhỏ/latency thấp và định nghĩa token/error ordering đầy đủ trước khi thêm opcode.

**DEC-021 đã được chốt ở mức kiến trúc:** OP-003 giữ ABI rd=0 + CSR, với global hardware fence và tcop_ctrl.scalar_ack. Driver lấy global submission lock, đợi accelerator idle và dọn lỗi cũ; phần cứng chỉ nhận OP-003 ở clean boundary rồi chặn tất cả hart bằng issue backpressure. Fence chặn các tensor command khác trong suốt thời gian OP-003 chạy đến result handshake. Nonzero result nhả fence ở handshake; zero result giữ busy/fence thêm trong lúc phần mềm kiểm tra err_valid, W1C-clear lỗi nếu có, gửi scalar_ack và đợi busy=0. Khi fence còn giữ, err_valid chỉ có thể thuộc OP-003 nên zero-success và error-zero không nhập nhằng. Lợi ích là giữ result ABI và không tốn CSR round-trip cho kết quả khác zero; chi phí là serialization toàn cục trong mỗi OP-003 và APB/CDC stall bổ sung khi giá trị bằng zero. Còn phải hiện thực và kiểm chứng CDC, multi-hart, kill và quiesce trước RTL sign-off.

## 3. Array scheduling: một command sở hữu mọi array hay chia nhóm độc lập

| Phương án | Ưu điểm | Chi phí/rủi ro | Khi phù hợp |
|---|---|---|---|
| **A. Một command active dùng toàn bộ array (đã chọn cho bản đầu)** | Một context điều khiển; dễ đảm bảo accumulation, thứ tự tile và result; command GEMM/prefill lớn có tổng số PE lớn; không cần fairness giữa command | GEMV/decode nhỏ có thể chỉ sử dụng một phần mảng; operation phi MAC làm mảng rảnh; command kế tiếp phải đợi ownership kết thúc | Bản đầu, workload lớn/đơn luồng, hoặc chưa có số liệu concurrency |
| **B. Chia array thành G group độc lập** | Có thể dành một nhóm nhỏ cho decode/GEMV và nhóm khác cho prefill/independent request; giảm head-of-line giữa workload độc lập; có cơ hội khai thác song song khi có nhiều request | Mỗi nhóm cần command context, descriptor/operand buffer, accumulator, error state, scheduler/fairness, AXI QoS và completion routing riêng. Số array mỗi nhóm phải tương thích tile/dataflow. Nếu một `err_valid` toàn IP làm pause mọi nhóm, lỗi của một nhóm vẫn có thể chặn nhóm khác. Chia nhóm không tạo thêm băng thông DRAM: hai nhóm có thể chỉ tranh chấp một cổng DMA và SRAM banks | Multi-user serving, concurrent independent sequences, hoặc kết hợp decode với prefill khi có băng thông và buffer đủ |
| **C. Chia sẻ mọi PE theo chu kỳ giữa command** | Có thể khai thác idle holes nhỏ | Crossbar, context switch và accumulator isolation phức tạp; dễ làm timing, power, và verification xấu hơn; khó giữ systolic dataflow liên tục | Không khuyến nghị nếu chưa có RTL/physical evidence |

`PARA_ARRAY_COUNT` chọn số array được tạo trong build nhưng không tự có nghĩa accelerator đã hỗ trợ G groups. Để thêm `PARA_ARRAY_GROUP_COUNT`, phải xác định quy tắc partition (ví dụ chia đều hay cấu hình số PE/group), context per group, tối thiểu group size, cách phân phối array lẻ, ownership của SRAM, fairness và cách cô lập lỗi. Cần model ít nhất hai loại lệnh đồng thời: decode `M=1` và prefill GEMM; đo array busy, DMA stall, SRAM bank conflict, latency của cả hai, và tổng thông lượng. Tổng TOPS cộng dồn không đủ nếu một workload làm workload kia trễ quá mức.

**Khuyến nghị:** giữ A cho bản đầu. Trước khi group hóa, tối ưu rõ `M=1` bằng đường GEMV/vector-dot, giữ trọng số/cache/buffer gần MAC, và đo băng thông thực. B chỉ đáng thêm khi có nhiều workload độc lập *và* DMA/SRAM còn headroom; nếu memory-bound, chia array có thể chỉ chia nhỏ cùng một nguồn bandwidth.

## 4. Clock datapath riêng hay dùng chung CLK-CORE

| Phương án | Ưu điểm | Chi phí/rủi ro |
|---|---|---|
| **A. Một `CLK-CORE` cho CV-X-IF, DMA và datapath (đã chọn)** | Không có CDC command/result nội bộ; reset đơn giản; giao dịch CV-X-IF/AXI dễ kiểm tra; không thêm latency qua FIFO | Tần số mảng bị giới hạn bởi clock domain/floorplan hệ thống; clock tree và switching power của array lớn; điều chỉnh DVFS độc lập khó |
| **B. `CLK-TENSOR` riêng, CV-X-IF/command front-end ở `CLK-CORE`** | Có thể chọn tần số/voltage của array độc lập; tách đường timing CVA6 khỏi PE mesh; clock-gate/DVFS theo miền | Cần async FIFO hoặc CDC được chứng minh cho command, descriptor ownership, result, status/error, reset/flush, kill/cancel, busy/interrupt; xác định AXI clock domain và crossings sang memory fabric. FIFO adds latency và state. Khi reset một domain, phải giữ không mất/nhân đôi command đang in flight |
| **C. Clock synchronous ratio-derived** | Nếu clocks cùng PLL và phase relation được xác định, timing constraint có thể đơn giản hơn async CDC; hỗ trợ core chậm hơn tensor | Vẫn cần xử lý rate mismatch bằng FIFO/elastic buffer; generated-clock constraints và reset sequencing vẫn phải sign-off |

**Phân tích tác động.** Tách clock có lợi nếu STA chứng minh CVA6 clock/floorplan giới hạn tensor path, hoặc sản phẩm cần DVFS/clock gating riêng. Nó không tự làm tăng hiệu suất khi DMA hoặc SRAM là nút thắt; core-side issue queue vẫn chỉ tiếp nhận theo tốc độ CV-X-IF clock. Một clock nhanh hơn cũng làm tăng yêu cầu feed nội bộ và dynamic power. Vài chu kỳ async FIFO có thể nhỏ hơn DRAM latency nhưng vẫn phải tính trong first-result latency của operation nhỏ.

**Khuyến nghị:** giữ A cho bản đầu và tạo timing groups rõ trong SDC khi có RTL. Chỉ chuyển sang B/C sau khi có clock plan, STA cho PE+SRAM+DMA, power budget và CDC plan cụ thể; không quyết định chỉ từ một ước lượng công bố của một biến thể CVA6/PDK khác.

## 5. INT4 hoặc FP8: phân tích sâu cho câu hỏi mục 4 của review

Hai hướng này giải quyết các điểm nghẽn khác nhau. **W4A8** chủ yếu giảm số byte trọng số so với INT8; **FP8** chủ yếu giảm dung lượng so với FP16/BF16 và giữ kiểu số dấu phẩy động. FP8 không tự giảm byte so với INT8 vì cả hai đều dùng một byte mỗi phần tử.

### 5.1 So sánh nhanh

| Lựa chọn | Weight bytes so với INT8 | Operand/độ chính xác | Hợp với | Chi phí lớn nhất |
|---|---:|---|---|---|
| **INT8 × INT8 (baseline hiện tại)** | 1.0× | Số nguyên đã lượng tử hóa; scale tùy mô hình | Compute đơn giản, mô hình INT8 sẵn có | Decode phải đọc toàn bộ trọng số 8-bit |
| **W4A8 (INT4 weight × INT8 activation)** | Xấp xỉ 0.5×, chưa tính scale/metadata | Trọng số signed INT4; activation INT8; thường cần scale theo nhóm | Batch-one decode bị giới hạn bởi đọc trọng số và có checkpoint 4-bit đạt chất lượng | Unpack, scale/group reduction, quantization error, ABI có hai precision khác nhau |
| **FP8 × FP8** | 1.0× so với INT8; xấp xỉ 0.5× so với FP16/BF16 | Phần cứng số thực 8-bit; các biến thể exponent/mantissa có dải động và độ chính xác khác nhau | Workload đang dùng FP16/BF16 nhưng muốn giảm byte và tăng mật độ toán | Chọn format, scaling, conversion, NaN/Inf/subnormal và rounding contract |
| **FP8 weight × BF16/FP16 activation** | 0.5× so với FP16/BF16 weights | Hai operand khác format; thường tích lũy rộng hơn | Trọng số chiếm traffic chính nhưng activation cần giữ độ chính xác | Datapath mixed-format, scale, accumulator/error analysis |

Với giả định lý tưởng 3.21 GB trọng số INT8 và băng thông hữu dụng 44.8 GB/s, chỉ riêng thời gian đọc trọng số xấp xỉ `3.21/44.8 = 71.7 ms/token`. W4A8 giảm phần byte trọng số còn một nửa nên trần lý tưởng cho phần đọc đó là khoảng 35.8 ms/token. FP8 chỉ cho cùng hệ số giảm này nếu baseline đang lưu trọng số hai byte (FP16/BF16); nếu baseline là INT8, FP8 không làm giảm byte trọng số. Đây là **trần mô hình**, chưa tính KV-cache, activation, metadata, scale, cache hit/miss, arbitration, compute hoặc launch overhead.

### 5.2 Datapath W4A8 cần làm gì

1. Đọc các nibble 4-bit đã pack; xác định nibble thấp/cao theo thứ tự byte được quy định trong descriptor.
2. Sign-extend mỗi weight INT4 sang miền tích đủ rộng trước phép nhân với activation INT8. Tích signed cần ít nhất 12 bit để biểu diễn toàn miền `[-8,7] × [-128,127]`.
3. Tách K reduction thành nhóm có chung scale. Cộng tích số nguyên trong từng nhóm; đổi scale ở ranh giới nhóm và cộng vào accumulator rộng hơn. Không được cộng thẳng các nhóm nếu scale khác nhau mà không có phép quy đổi đã định nghĩa.
4. Nạp scale cùng tile, bảo đảm scale tới trước khi nhóm tương ứng cần dùng; thiếu băng thông scale hoặc sai alignment sẽ làm lợi ích giảm.
5. Định nghĩa rounding, saturation/overflow, zero-point, tail group, padding, và hành vi nibble alignment. Phương án tiết kiệm logic ban đầu là symmetric quantization (`zero-point=0`) và một scale cho mỗi group, nhưng đây vẫn là đề xuất chưa được chốt.

W4A8 dùng 4-bit weight nhưng không nhất thiết làm MAC count tăng gấp đôi. Nếu multiplier INT4×INT8 không được đóng gói thành nhiều phép nhân trong lane hiện có, compute throughput có thể giữ nguyên trong khi memory traffic giảm. Nếu muốn hai hay nhiều INT4 MAC trên một lane INT8, phải thêm định nghĩa packing, activation reuse, product accumulation, sign handling và kiểm chứng timing; lợi ích đó không được tính vào con số giảm byte ở trên.

### 5.3 Datapath FP8 cần làm gì

1. Chọn chính xác format cho từng operand, ví dụ họ format có mantissa nhiều hơn để giữ chính xác hay exponent nhiều hơn để giữ dải động; tên “FP8” chung chưa đủ làm ABI.
2. Định nghĩa scale: tensor-wise, channel-wise, hoặc group-wise; scale tĩnh trong tensor hay được truyền trong descriptor; xử lý khi scale thay đổi giữa các tile.
3. Chuyển/giải mã operand, phát hiện các lớp số đặc biệt theo format, nhân và tích lũy ở định dạng đã chọn (thường rộng hơn FP8), rồi round đúng một số lần được quy định.
4. Quy định dấu, exponent, mantissa, bias, rounding mode, subnormal/flush-to-zero, NaN/Inf, overflow/underflow, và conversion sang output. Nếu accumulator là FP32, phải sizing adder/reduction và lane service-rate tương ứng; FP8 multiplier không làm phần reduction FP32 miễn phí.

FP8 có thể phù hợp hơn INT4 khi checkpoint và huấn luyện/quantization flow vốn tối ưu cho số thực thấp bit hoặc khi dải động của integer quantization gây giảm chất lượng. Nhưng FP8 không mặc nhiên chính xác hơn: kết quả phụ thuộc format, scale, layer, checkpoint và dữ liệu. Việc so sánh phải dùng model-level metric trên prompt/dataset đại diện, không chỉ sai số RMS của tensor.

### 5.4 Ảnh hưởng đến ISA, descriptor và phần mềm

ABI hiện tại chọn **một `precision_id` cho operation** qua `funct3`: `000=INT8`, `001=BF16`, `010=FP16`; `011`–`111` đang reserved. W4A8 có hai kiểu operand khác nhau, nên không thể mô tả rõ bằng precision chung hiện tại. FP8 cũng cần xác định format subtype, scaling, và role mỗi operand. Đưa mã mới vào `funct3` mà không có version/submode rõ sẽ khiến assembler, driver và hardware diễn giải cùng descriptor khác nhau.

Trước khi thêm một trong hai, cần thiết kế extension có capability bit và versioned descriptor fields cho: format từng operand, packing/order, scale pointer/shape, group size, accumulator/output format, rounding, và alignment. Chỉ chấp nhận opcode/precision/schema đã release-qualified trong HDS matrix; mọi tổ hợp khác tiếp tục bị từ chối ngay tại issue. Không dùng `PARA_DATA_PREC=1` để ngầm bật các format mới.

Phần mềm cũng phải chọn checkpoint phù hợp, kiểm tra capability/version, chuyển hoặc nạp trọng số theo packing/scale, clean cache trước DMA, và dispatch fallback khi IP build không hỗ trợ format đó. Với serving nhiều model, cần tính chi phí giữ song song các bản INT8/W4A8/FP8 trong DRAM hoặc thời gian chuyển format.

### 5.5 Tiêu chí chọn và khuyến nghị

| Bằng chứng workload/model | Hướng ưu tiên để thử | Lý do |
|---|---|---|
| Decode batch-một bị giới hạn bởi đọc weight; checkpoint 4-bit đạt quality budget | Thử W4A8 trước | Giảm xấp xỉ một nửa byte weight so với INT8; giá trị phụ thuộc trực tiếp vào tỷ lệ thời gian đọc weight |
| Workload chủ yếu FP16/BF16 và memory footprint hoặc DRAM bandwidth là giới hạn | Thử FP8 | Có thể giảm weight bytes gần một nửa so với 16-bit; không lợi về bytes so với INT8 |
| Đã bị giới hạn bởi MAC/array utilization hoặc DMA đã dư băng thông | Chưa ưu tiên giảm precision | Ít byte hơn có thể không giảm latency; unpack/scale/conversion còn có thể giảm Fmax |
| Chưa có model/checkpoint và quality target đại diện | Chưa chọn format | Không có cơ sở kết luận numerical error chấp nhận được |

**Khuyến nghị cho bản hiện tại:** giữ INT8/BF16/FP16 và ABI đã chọn; không bật W4A8 hoặc FP8 bằng parameter trong bản này. Đầu tiên đo bytes/token, cache behavior, DMA stall và thời gian compute trên workload decode mục tiêu. Nếu bottleneck là DRAM và có checkpoint quantized đã đạt quality, làm prototype W4A8; nếu model đang dựa vào FP16/BF16 và cần giữ số thực nhưng giảm footprint, đánh giá FP8. Chỉ đưa lựa chọn thắng vào ABI version mới, kèm operation/precision matrix, reference model và model-quality budget. Không đặt trước `funct3=011` cho bất kỳ format nào.

## 6. Performance counters: phần cứng hay trace/PMU

| Phương án | Lợi ích | Chi phí |
|---|---|---|
| **A. Simulation trace + system PMU/external counters (hiện tại)** | Không thêm datapath/CSR logic; có thể thu chi tiết stall reason trong simulation; không phải đồng bộ hàng chục counters qua APB | Silicon observability thấp hơn; PMU host có thể không phân biệt stall nội bộ nếu IP không xuất event |
| **B. Bộ counter nhỏ trong IP** | Sau khi workload thực, có thể định vị array busy, DMA read/write busy, command cycles và stall cause; hữu ích tuning field | CSR map, counter width/overflow, snapshot atomically, clear semantics, clock crossing, read coherency, privacy, area/power và test thêm. Một counter bận không tự giải thích vì sao throughput thấp |
| **C. Counter mỗi array/group + mọi stall cause** | Phân tích phân bố load/fairness sâu | State/CSR lớn; snapshot nhiều word và CDC phức tạp; taxonomy stall có thể đổi theo RTL; chưa có group architecture |

**Khuyến nghị:** đầu tiên ghi event từ testbench/reference model và dùng SoC PMU/trace. Khi RTL/profile đã ổn định, chọn ít counter có câu hỏi rõ: `cmd_cycles`, `array_busy_cycles`, `dma_rd_busy_cycles`, `dma_wr_busy_cycles`, và một hay vài nguyên nhân stall quan trọng. Counter nên có latch/snapshot để tránh đọc word thấp/cao ở hai thời điểm khác nhau. Không thêm counter per-group trước khi group được chọn.

## 7. Prefetch trước commit

Đọc descriptor/operand trước commit có thể che latency, nhưng ranh giới không chỉ là “đọc không làm thay đổi dữ liệu”. CPU có thể đặt descriptor ở vùng MMIO, buffer còn đang ghi, hoặc mapping có side effect; lệnh sau đó còn có thể bị kill. CV-X-IF yêu cầu kết quả chỉ sau commit và nếu lệnh bị kill thì accelerator không được để lại thay đổi kiến trúc quan sát được. Với DMA memory read, IP cũng cần đảm bảo không tiêu thụ dữ liệu từ command bị kill và không phát output write.

**Khuyến nghị:** hiện tại bắt đầu DMA sau commit như HDS đang mô tả. Prefetch các tile tiếp theo của command đã commit là tối ưu an toàn hơn; có thể chồng read-next-tile với compute khi double-buffer/state đã có. Nếu sau này muốn speculative descriptor read, giới hạn vùng descriptor an toàn, thêm kill/flush protocol và chứng minh request không tạo side effect trước khi ghi requirement.

## 8. Accumulator timing: carry-propagate, carry-save, hay nhiều bank

| Phương án | Throughput/timing | Area/complexity | Numerical behavior |
|---|---|---|---|
| **A. Carry-propagate accumulator mỗi PE (HDS baseline hiện còn cần sign-off)** | Mỗi MAC cần feedback qua adder hoàn chỉnh; có thể là critical path khi accumulator rộng, nhưng chỉ có kết quả vật lý sau library STA | Một accumulator/PE, logic cộng gọn hơn; dễ quan sát giá trị nhị phân | Dễ giữ phép cộng modulo với `PARA_ACCUM_W` |
| **B. Carry-save/redundant accumulator** | Feedback loop ngắn hơn về mặt logic; carry-propagate được dời ra drain/epilogue, có tiềm năng tăng Fmax | Thêm state (thường sum+carry), chuyển đổi cuối tile, yêu cầu định nghĩa drain/exception và pipeline cuts liên quan | Cần chứng minh bit-exactness so với modulo arithmetic, kể cả overflow/truncation; sparse paired sum cũng phải đi đúng compressor path |
| **C. Hai accumulator banks / interleaving** | Có thể che latency adder nếu luân phiên các output/context độc lập; không làm một recurrence đơn lẻ ngắn hơn | Tăng state khoảng theo số bank; cần schedule/K-split hoặc mapping output riêng, mux chọn bank, merge cuối | K-split/merge có thể đổi thứ tự cộng và rounding; phải định nghĩa deterministic result |

Yosys/ABC depth probe trong review chỉ dùng cell logic đơn giản để so tương đối. Các số như 48/80 levels hoặc mức cải thiện Fmax không cho ra ps, không thay thế synthesis với thư viện, parasitic, CTS, SDC, placement, IR-drop và actual SRAM interface. Do đó kết quả đủ để xác định carry loop là **rủi ro cần đo**, không đủ để bắt buộc carry-save hay khẳng định đạt 2 GHz.

**Khuyến nghị:** giữ yêu cầu pipeline cuts hiện có, nhưng thêm timing experiment ở mức PE trước khi RTL freeze. So sánh cùng interface ba biến thể A/B/C bằng target library; đo clock period, area, dynamic power, latency, throughput và bit-exactness. Nếu A không đạt target clock trong library thật, chốt B hoặc C bằng DEC mới và cập nhật `PARA_ACCUM_W`, reset/init, tile-drain latency và waveform trước RTL implementation.

## 9. Kết luận theo giai đoạn

| Giai đoạn | Làm gì | Vì sao |
|---|---|---|
| **Spec hiện tại** | Giữ lựa chọn đã chốt; sửa consistency giữa HDS/FSM/CSR; nêu operation/precision matrix và error record; giữ 64 TOPS là peak ideal và `B_dma`/SRAM là TBD | Bảo vệ ABI và hành vi đã được xác nhận, đồng thời không biến mô hình thành cam kết thực |
| **Trước RTL freeze** | Chốt workload prefill/decode, memory bandwidth guarantee, SRAM capacity/bank/ports, descriptor fields, operation/precision legality, integration top per hart; chạy timing/area probe PE+SRAM với target library | Đây là dữ liệu đầu vào để biết array count, pipeline configuration, accumulator và nonlinear lane count có cân bằng không |
| **Sau baseline RTL/trace** | Thêm double-buffer overlap trong command đã commit nếu bandwidth/buffer cho phép; profile host gaps; cân nhắc ring, group, counters theo bottleneck đã đo | Mỗi tính năng mở rộng có chi phí xác minh, CDC, fairness và software ABI; chỉ chọn khi có số liệu chứng minh lợi ích |
| **ABI/model extension** | Đánh giá W4A8/INT4 nếu batch-one decode là KPI chính; dùng model quantized và accuracy tests; phát hành versioned ABI extension | Có thể giảm bytes/token đáng kể nhưng thay đổi numerical/packing contract |

### Recommendation để ghi vào bản hiện tại

1. Không thay command ABI, host protocol, clock domain, precision codes, hoặc scheduler ownership đã chọn.
2. Dùng review để sửa lỗi nhất quán và chỉ rõ vùng chưa có bằng chứng: bandwidth/tiling, FSM error-drain, CSR CDC, precision matrix và integration với cluster.
3. Chốt profile workload và `B_dma` trước khi chọn số array phát hành; `PARA_ARRAY_COUNT` là parameter nhưng mọi cấu hình phải có SRAM/bandwidth/timing sign-off tương ứng.
4. Để ring, independent array groups, tensor clock, INT4 và hardware counters thành các option có trigger cụ thể, không phải yêu cầu mặc định.

## 10. Phân tích các điểm còn mở trong HDS

Các đề xuất dưới đây giúp thu hẹp quyết định nhưng không tự thay đổi lựa chọn đã chốt. Bảng HDS §20 vẫn là trạng thái chuẩn; nội dung gắn nhãn “khuyến nghị” cần được duyệt trước RTL/interface freeze hoặc được ghi rõ là ngoài phạm vi release.

### 10.1 DEC-016 — Chọn top tích hợp có CV-X-IF

Cluster 2/4 hart được chọn trong tài liệu hệ thống đặt `CVA6ConfigCvxifEn=0` và không xuất CV-X-IF ra top. Đây là quyết định riêng đã chốt cho cluster; tensor HDS yêu cầu CV-X-IF nên không thể tuyên bố IP nối trực tiếp vào cluster hiện tại. Người dùng đã chọn DEC-016 phương án tạo một top tensor riêng có CV-X-IF-enabled CVA6 nối tới tensor, đồng thời giữ cluster hiện tại nguyên trạng. Tên top, CVA6 source/configuration và số hart vẫn chưa chốt. Một số CVA6 config khác trong repository bật CV-X-IF không đồng nghĩa chúng đã được tích hợp hoặc sign-off thành top tensor.

Lựa chọn DEC-016 là tạo top/config CV-X-IF-capable riêng và giữ cluster HDS hiện tại. Nếu sau này cần gắn tensor trực tiếp vào cluster 2/4 hart, phải mở lại quyết định cluster về CV-X-IF và hoàn thành port plan; không chỉ đổi một parameter.

Với nhiều hart, mỗi CVA6 có thể phát lệnh vào một scheduler chung qua router/arbiter hoặc có endpoint riêng. Khi gom vào một scheduler, command scoreboard phải dùng khóa `(hartid, xif_id)`, vì ID chỉ có nghĩa trong context của hart. Router giữ đúng hart/ID qua issue, register operands, commit/kill và result; commit/kill của hart này không được xóa command của hart khác. Cần quy định fairness, giới hạn outstanding mỗi hart và error attribution. Một command active sở hữu mọi array đơn giản cho bản đầu nhưng gây head-of-line delay giữa harts; throughput đa người dùng không thể suy ra chỉ từ `PARA_ARRAY_COUNT`.

**Quyết định đã chốt:** giữ nguyên cluster không-CV-X-IF và tạo top tensor riêng với CV-X-IF-enabled CVA6. Số hart, endpoint count, routing và verification plan vẫn cần chốt trước khi tuyên bố SoC integration signoff.

### 10.2 DEC-017 — Chốt operation × precision × numeric contract

`PARA_DATA_PREC=1` chỉ tạo datapath INT8/BF16/FP16; nó không thay thế bảng chuẩn tắc định nghĩa format mỗi operand, accumulator/intermediate, output, rounding, scale, saturation, NaN/Inf và sai số cho phép. Hiện §9.1 còn nhiều ô `open`, trong khi `PARA_ALGORITHM_MASK=0x7F` là candidate bật toàn bộ family. Mỗi family đang bật cần có ít nhất một cặp operation/precision release-qualified nằm trong build; nếu không, build phải bị từ chối thay vì quảng bá một mode mà mọi command đều bị issue-reject.

Bảng sau là ứng viên để làm ma trận release đầu, không phải lựa chọn đã duyệt:

| Operation | Cặp precision nên đánh giá đầu tiên | Phải chốt trước qualification |
|---|---|---|
| OP-001 dense GEMM | INT8; BF16/FP16 nếu `PARA_DATA_PREC=1` | A/B signedness và storage, `PARA_ACCUM_W`/FP32 accumulator, overflow, initial C, bias/scale, rounding lúc store |
| OP-002 elementwise/epilogue | INT8 cho add/bias/requant cơ bản; BF16/FP16 cho real-valued path | Output format, fusion order, scale/zero-point, clamp, activation function/coefficient/error |
| OP-003 REDUCE | INT8 và BF16/FP16 nếu model/reference dùng cùng kiểu | Sum width/overflow, max comparison domain, NaN/Inf, rounding, CSR attribution DEC-021 |
| OP-004 ARGMAX | INT8 và BF16/FP16 theo compare rules đã có | Signedness/scale của INT8 logits, descriptor schema, tie/sentinel/non-finite behavior |
| OP-005 exact attention | BF16/FP16 với FP32 online-softmax state là ứng viên dễ định nghĩa | Q/K/V storage, dot accumulator, score scale/mask, max/sum precision, exp/reciprocal error, output rounding |
| OP-006 softmax | BF16/FP16 với reduction state rộng hơn | Row/tile limits, mask, subtract-max, exp/reciprocal coefficients, finite range và error budget |
| OP-007 layer norm | BF16/FP16 với Welford/affine state rộng hơn | Epsilon format/value, population variance, merge order, gamma/beta format, rounding/tolerance |
| OP-008 sparse 2:4 GEMM | INT8 paired-MAC là ứng viên đầu | Metadata bit order, group packing, invalid code, activation gather bandwidth, dense/sparse equivalence |
| OP-009 causal linear attention | BF16/FP16 là ứng viên đầu; INT8 sau khi có fixed-point state design | Feature map, `S/z` state format/range, rescaling, persistence, overflow và model quality |

`funct3` chọn một precision chung cho command, không mô tả riêng weight, activation, state và output. Mixed formats phải khai báo trong descriptor mà không để descriptor đổi result class/family. INT8 softmax/layer norm/linear attention có thể triển khai bằng fixed-point, nhưng phải định nghĩa Q-format, guard bits, overflow, scale và sai số; nhãn “INT8 support” là chưa đủ.

**Khuyến nghị:** trước hết hoàn tất một release matrix có ít nhất một cặp legal cho từng family mà build bật. Nếu yêu cầu sản phẩm là đủ các family Transformer, build đầy đủ nên có BF16/FP16 datapath; INT8 được qualified cho các family có numeric contract. Đừng ép mọi operation chạy INT8 để giữ `PARA_DATA_PREC=0`. Chỉ sau khi có matrix mới chốt precision default, mask default và tổ hợp parameter hợp lệ.

### 10.3 DEC-018 — Hiệu năng phát hành phải gắn với workload và memory contract

`B_dma=64 GB/s` suy ra từ 256-bit × 2 GHz là băng thông port lý thuyết, không phải băng thông tensor bảo đảm khi tranh chấp CPU/LLC, refresh DRAM, arbitration, turnaround và output traffic. HDS cần phân biệt `B_peak` với `B_eff` đo được/được bảo đảm trên top cuối. Cùng một `PARA_ARRAY_COUNT` có thể khác biệt lớn khi data nằm ở DRAM, LLC, SRAM hoặc được tái sử dụng giữa batch rows.

Với output tile INT8 `T×T` và K-stream, trần HDS trước overhead là `P_sust ≤ min(P_peak, B_eff × T)` operations/s. Ở `B_eff=64 GB/s`, `T=128` cho khoảng 8,2 TOPS; `T=512` cho khoảng 32,8 TOPS và đòi buffer lớn hơn. 64 TOPS compute không buộc DRAM đạt cùng con số; local banking, reuse và injection phải khớp lượng data đã nạp. Với decode cần tính cả weight và KV-cache: `ITL ≥ (W_bytes + KV_bytes + other_bytes)/B_eff`, rồi cộng compute, host, reduction và contention.

Benchmark contract cần tách: (1) prefill với model/precision, `(batch, sequence, hidden, heads)`, tile, cache state, bandwidth đọc/ghi, SRAM và tile latency; (2) decode với checkpoint/quantization, batch/users, KV length, GQA/MQA, weight residency, TTFT, inter-token p50/p95/p99 và tokens/s; (3) tải SoC đại diện, QoS/fairness và contention. `<50 ms/token` trong draft cũ thiếu workload/memory context; mô hình 3B INT8 ở 70% của 64 GB/s cho khoảng 71,7 ms chỉ để đọc weight 3,21 GB, chưa tính KV-cache và không phải benchmark end-to-end.

**Khuyến nghị:** giữ các con số hiện tại làm roofline/sizing reference; chưa giới hạn array count bằng `B_eff` chưa đo. Mỗi release result phải ghi cấu hình array, clock, tile/SRAM và điều kiện memory/test tương ứng.

### 10.4 DEC-001 — Pipeline boundary có tham số nhưng chỉ giải quyết đường cắt được chọn

Năm cut đã chọn tạo 32 bitvector bypass/register lúc elaboration. Giá trị phải ổn định trong cả build; đổi cut runtime sẽ đổi state, alignment/flush và timing, không phải một runtime mode. Chỉ những bitvector đã synthesize/STA/CDC/verify mới được phát hành; không cần sign-off mọi raw combination nếu chỉ phát hành một tập cấu hình.

Timing study nên đo riêng: PE INT8 multiplier→accumulator ở cả ba `PARA_ACCUM_W`; paired sparse gather/product path; FP32 feedback/reduction; memory response→buffer; exp/reciprocal/rsqrt service và output backpressure. Yosys/ABC unit depth chỉ xếp hạng rủi ro, không xác nhận GHz. Nếu critical path nằm trong accumulator feedback hay PE forwarding, năm cut đã chọn không cắt được đúng đường đó; khi đó cần quyết định kiến trúc mới thay vì bật một cut không liên quan. Stage vẫn giữ `II=1` chỉ khi valid/ready/skid/credit behavior nhất quán và có buffer/backpressure phù hợp.

**Khuyến nghị:** giữ năm cut hiện tại, không chuyển sang số tầng tùy ý; chốt một số build profile có bitvector rõ và STA thật. Default tiếp tục TBD cho đến khi chọn target library, corner và f_array.

### 10.5 DEC-004 — DMA, non-coherence và lỗi ghi output

AXI DMA là manager thứ hai; cluster CPU memory top không tự cung cấp DMA ingress. SoC cần AXI interconnect/arbiter với ID mapping, outstanding limits, QoS/fairness và đúng đường DRAM. Descriptor dùng DMA-visible physical/IOVA, không dùng CPU virtual address; nếu có IOMMU thì map/permission/fault thuộc SoC contract. Nếu không có, driver phải pin/map buffer, kiểm bounds/alignment và chỉ cấp vùng DMA được phép.

Cache ownership cần nói rõ hơn “cache maintenance”: inputs/descriptors do CPU ghi phải clean đến điểm nhìn thấy của DMA trước issue; CPU không đọc output khi DMA đang ghi; dirty CPU lines cũ phải được xử lý để không ghi đè output; sau completion phải invalidate trước CPU read. Cần đối chiếu CBO operations trong CVA6 profile và điểm hoàn tất (LLC hay DRAM).

AXI write error có thể xảy ra sau khi vài output beat/tile đã ghi; không thể mặc nhiên rollback DRAM. Người dùng đã chọn DEC-022: toàn bộ output của một command bị xem là invalid nếu command lỗi sau acceptance; không có rollback hoặc tile-valid bitmap. Phần cứng dừng tile chưa khởi chạy, hoàn tất và drain mọi write đã nhận cùng `B` response, rồi mới báo lỗi. Chỉ báo thành công sau khi tất cả write bắt buộc thành công. Driver bỏ/reinitialize destination và chạy lại toàn command; buffer phải cache-line aligned, độc quyền accelerator trong lúc chạy, rồi được invalidate trước CPU read vì DMA không coherent.

Người dùng chọn DEC-023 quiesce/drain trước ordinary functional reset, sau đó bác bỏ local abort/isolation trong tensor IP. Nếu required AXI response không về trước SoC watchdog timeout, lựa chọn đã chốt là reset toàn SoC—không phải local hay tensor+fabric-only reset—và không phát tensor timeout result. Full reset phải bao trùm CPU harts, tensor IP, AXI interconnect và on-SoC transaction agents có thể giữ/trả request; reset release không được để stale response khớp với command mới. Watchdog threshold/owner, reset coverage/release, reset-cause capture và software restart còn mở tại DEC-029. Ordinary functional reset vẫn quiesce/drain theo DEC-028. Địa chỉ vật lý, firewall window, burst/arbitration, cùng cache-maintenance point vẫn cần tích hợp cụ thể.

### 10.6 DEC-020 — Detail CSR ổn định, không dùng làm control ABI

`tcop_err_sts.code` là lỗi ABI ổn định; `tcop_err_detail.detail` chỉ chẩn đoán. Giữ `0=unavailable`, và driver không nên quyết định fallback dựa trên detail. Mỗi status cần subcode enum riêng; nếu detail có index phải nêu rõ đơn vị byte offset/element/lane/tile. Address và AXI ID đã có register riêng nên không lặp chúng trong detail.

Chỉ lưu detail khi datapath giữ đúng vị trí lỗi tới error-drain: descriptor field offset, sparse group index, hoặc numeric token/element index. Chốt reset, N/A, index width, truncation và versioning; mở rộng detail không được đổi status 32-bit.

### 10.7 DEC-021 — Giữ OP-003 rd=0 mà không nhầm lỗi

Người dùng chọn giữ OP-003 scalar result trong rd; lỗi sau acceptance cũng trả zero và CSR giữ mã lỗi chi tiết. Vì zero hợp lệ, hardware và driver cùng tạo hợp đồng attribution rõ:

1. **Trước issue:** privileged driver lấy một global submission lock dùng chung giữa các hart, đợi tcop_sts.busy=0, đọc err_valid; nếu còn lỗi cũ thì đọc toàn bộ record, W1C-clear và đợi clear sang CLK-CORE. Lock ngăn submitter khác gây starvation trong bước này.
2. **Admission:** hardware độc lập chỉ accept OP-003 khi không còn CV-X-IF command/operand/commit contexts, command đang chạy/queued, result transaction, AXI outstanding hay err_valid. Nếu chưa sạch, mọi endpoint giữ issue_ready=0; đây là backpressure, không phải illegal-instruction reject. Global arbiter nhận OP-003 duy nhất tại clean boundary và cùng handshake bật fence cho toàn bộ hart.
3. **While running:** các lệnh tensor mới ở mọi hart bị backpressure. Kill trước non-kill commit hủy lệnh/fence mà không phát result. Fence tồn tại qua result backpressure.
4. **Result nonzero:** failure payload của OP-003 luôn zero, nên giá trị khác zero là success; fence nhả ở CV-X-IF result handshake.
5. **Result zero:** result transaction vẫn write rd=0, nhưng busy và fence giữ mức 1. Software đọc err_valid: 0 xác nhận valid zero; 1 là lỗi của chính lệnh đang fence. Nếu có lỗi thì đọc toàn bộ first-error record rồi W1C-clear. Sau đó software ghi tcop_ctrl.scalar_ack=1. Hardware đợi W1C clear được đồng bộ, chỉ tiêu thụ ack khi scalar_check_pending đang tồn tại, rồi nhả fence. Ack ngoài cửa sổ pending bị bỏ, không thể mở một lệnh tương lai. Software đợi busy=0 rồi nhả lock.

**Lợi ích:** không đổi ABI scalar đã chọn; lỗi có thể được phân biệt dù CV-X-IF không có error bit; lệnh khác từ harts khác không thể ghi đè first-error record trong lúc kiểm tra; kết quả khác zero không cần APB round-trip.

**Chi phí/rủi ro:** mọi OP-003 đều chặn issue tensor của các hart khác từ lúc được nhận đến result handshake, nên đây là điểm tuần tự hóa toàn accelerator trong lúc reduce chạy. Nếu kết quả bằng zero, APB/CDC check và ack kéo dài stall sau result handshake cho đến khi software xử lý xong. Driver phải dùng cùng global lock trên mọi hart; mọi đường submit tensor phải được quản lý. Hardware admission check vẫn bắt buộc để bảo vệ khi lỗi phần mềm hoặc có submitter ngoài driver. CSR map thêm bit write-only scalar_ack ở tcop_ctrl[1] và map minor version lên 1.1. Functional reset/quiesce phải chờ fence release. Các hạng mục còn lại là triển khai/verification: simultaneous multi-hart issue, clean-boundary conditions, zero-success/error-zero, result backpressure, ack/W1C order, stale ack, kill, reset/quiesce. TEST-025, SVA-009, COV-006 ghi hợp đồng kiểm chứng.

Đổi OP-003 sang status-result và ghi scalar qua IF-003 sẽ đơn giản hóa phân biệt lỗi, nhưng thay ABI đã chọn và thêm memory traffic. Vì vậy giữ phương án fence/ack cho release đầu tiên.
\n### 10.8 DEC-022/023/029 — Output sau lỗi và reset khi DMA outstanding

Người dùng đã chốt policy ở mức kiến trúc: lỗi sau acceptance làm toàn bộ output của command invalid; không rollback hoặc tile-valid bitmap. Trước normal core reset phải ngừng admission và drain transaction. Người dùng sau đó bác bỏ local abort/isolation cho tensor IP. Các policy này đã trở thành REQ-ERR-003/REQ-RESET-002.

Nếu `R/B` không về, local timeout/reset không hủy request AXI đã được accept. Tensor không trả `TC_ERR_AXI_TIMEOUT`, không xóa ID và không tiếp tục dùng buffer. Người dùng đã chọn reset toàn SoC là recovery duy nhất khi watchdog hết hạn: reset CPU harts, tensor, AXI interconnect và on-SoC transaction agents giữ request; không trả result cho lệnh CV-X-IF đang dở, và output bị invalid. `SLVERR/DECERR` là response đã về nên vẫn được xử lý như command error bình thường, sau khi drain. Threshold/owner của watchdog, reset coverage/release, reset-cause capture và software restart vẫn cần SoC integration detail. DEC-028 còn mở quiesce request/ack cho ordinary functional reset.

### 10.9 DEC-002 — Descriptor là memory ABI, không chỉ là “con trỏ shape”

Con trỏ 64-bit ghép từ `rs1/rs2` giải quyết cách truyền địa chỉ lệnh, nhưng descriptor còn cần layout bền vững giữa RV32/RV64 và các bản phần mềm. Trước RTL freeze cần khóa: byte order, alignment, `version`, `byte_length`, reserved-bit behavior, field offsets, signedness, dimensions/strides/leading dimension, tensor addresses, storage formats/scales, tiling hints, submode/mask metadata và workspace/state pointers. Một descriptor chung nên có header ổn định và phần operation-specific; operation ID vẫn lấy từ instruction để result-class/family không bị descriptor ghi đè.

Validator cần kiểm overflow khi tính `base + stride × dimension`, bounds của address range, descriptor alignment, tensor address alignment/tail policy, và aliasing giữa input/output/state. Nếu overlap không được hỗ trợ thì phải reject trước khi phát write request. Version lạ hoặc `byte_length` ngắn/dài bất hợp lệ cần status cố định mà không đọc vượt khỏi buffer; trường reserved phải có quy tắc zero/reject rõ. Data path không được bắt đầu trước commit theo quyết định prefetch hiện tại; sau commit có thể fetch descriptor và prefetch tile của command đó.

**Khuyến nghị:** giữ header fixed-width với `version/length/flags` và address/shape fields có offset cố định, descriptor byte layout độc lập XLEN. Dùng operation-specific extension area có `byte_length` để mở rộng có kiểm soát; không gán trường mới vào reserved bit mà không tăng version. Chưa đề xuất con số byte cho header/descriptor cho đến khi từng operation đóng field set và max tensor rank.

### 10.10 DEC-006 — Queue depth, ordering và tiến triển đa hart

`PARA_CMD_QUEUE_DEPTH=2` có nghĩa active + một queued command; nó có thể che một phần khoảng host/descriptor preparation nhưng không tăng bandwidth hay giảm latency của command active. Tăng depth tiêu thụ state cho descriptor metadata, hart/ID scoreboard, commit/kill, result class, partial error flags và outstanding AXI associations. Result phải trả đúng CV-X-IF ID; command khác hart không được ghi đè context trùng ID.

Một active command sở hữu tất cả arrays giúp thứ tự đơn giản nhưng command decode nhỏ có thể chờ prefill lớn. Nếu đổi sang cross-command groups, phải thêm per-group state, fairness, AXI QoS, buffer partitioning và error isolation; đó là một kiến trúc mới, không phải chỉ tăng queue depth. Khi queue đầy, phải giữ CV-X-IF issue backpressure ổn định đến lúc có chỗ; không nhận lệnh rồi làm mất register/commit metadata.

**Khuyến nghị:** phát hành depth nhỏ đã sign-off, một command active, FIFO acceptance order; chọn round-robin/age policy chỉ khi multi-hart target được chốt. Tăng depth sau trace host gaps; không lấy queue depth làm bằng chứng cải thiện array utilization.

### 10.11 DEC-007 — Paired sparse lanes: throughput tính cả metadata và activation gather

Nhóm 4 weight có đúng 2 vị trí khác zero có `C(4,2)=6` pattern, do đó 3 bit metadata đủ mã hóa sáu cặp và hai code còn lại phải bị từ chối. Với INT8, nếu metadata pack liên tục thì mỗi 4 dense bytes trở thành 2 payload bytes + 3/8 byte metadata = 2.375 byte, tương ứng tiết kiệm tối đa khoảng 40.6% weight storage; nếu pad metadata thành một byte cho mỗi nhóm thì chỉ còn 25%. Vì vậy “2:4 = giảm một nửa DRAM traffic” là sai nếu bỏ metadata, tail và scale.

Paired MAC có thể tính hai nonzero product mỗi step, nhưng cần đọc hai activation theo metadata position. Nếu dense injection mỗi array là 32 byte/cycle, trường hợp đơn giản có thể cần đến 64 byte/cycle/array để giữ hai lane bận; activation reuse/broadcast/gather architecture khác có thể giảm yêu cầu. Cần đo cả metadata read, activation gather, payload decode, alignment/tail và product-adder timing. Sparse speedup end-to-end bị chặn bởi min(compute speedup, weight-byte reduction, activation-feed rate, metadata service, unstructured tile occupancy).

**Khuyến nghị:** định nghĩa mã `0..5` thành sáu cặp index theo thứ tự rõ, `6..7` invalid; chọn packing/byte order và tail rule; benchmark checkpoint 2:4 thực. PPA-009 nên giữ “hai nonzero MAC/lane” là compute ceiling và không hứa 2× model speedup.

### 10.12 DEC-008/009 — Linear-state footprint và nonlinear lane service rate

Với feature dimension `F` và value dimension `D_v`, state causal linear attention thường có một ma trận `S[F,D_v]` và vector normalizer `z[F]` cho mỗi head. Nếu state dùng FP32, footprint/head là `4(FD_v+F)` bytes; ví dụ `F=D_v=64` cần khoảng 16.25 KiB/head, trước alignment/metadata. Với 32 heads, một layer có khoảng 520 KiB state. State đọc/ghi mỗi token có thể trở thành băng thông đáng kể nếu không resident gần compute; vì vậy DEC-008 phải chốt F, head count, layer persistence, reset/init, state address/workspace và model-quality budget trước khi xem OP-009 là rẻ.

Special-function rate cũng có thể giới hạn exact attention. Ở 16×32×32 arrays, 2 GHz và full ideal dense peak, 16384 MAC/cycle có thể tạo khoảng `16384/d` score/cycle nếu mỗi score dùng `d` MAC: xấp xỉ 128 score/cycle khi `d=128`, 256 khi `d=64`. Nếu tất cả điểm đi vào online softmax, exp/max/sum/normalization phải có service rate tương ứng để không làm array stall; một vài lane exp có thể đủ cho mục tiêu utilization thấp hơn, nhưng số lanes cần gắn với target PPA-008, không suy từ một multiplier đơn lẻ. Welford count/mean/M2, merge tree, reciprocal/rsqrt và affine output cũng phải có throughput cùng đơn vị rows/cycle.

**Khuyến nghị:** đóng state dimensions và placement/traffic trước cho OP-009; đo service rate nonlinear ở các precision/build profiles đã qualification. Không nhân lane count theo full peak nếu workload target thấp hơn; cũng không phát hành với một `m_reduce` chưa sizing trong khi tuyên bố array chạy liên tục.

### 10.13 DEC-024 — Chọn coupled issue/register; host commit proof còn mở

REF-001 §§5.5.7–5.5.8, 5.6 định nghĩa hai profile issue/register. Người dùng đã chọn `X_ISSUE_REGISTER_SPLIT=0` cho tensor top (DEC-024): issue và register transaction bắt buộc ghép cùng nhịp. Descriptor pointer chỉ được chụp khi `issue_valid`, `register_valid`, ready handshake và mọi `rs_valid` lane được yêu cầu đều hợp lệ. Cấu hình này bỏ register-packet reordering và không cần operand-reorder scoreboard; nó vẫn cần command context theo `(hartid,id)` cho result identity và commit/kill semantics.

Trong profile này, adapter dùng chung `issue_ready` và `register_ready`; thiếu operand lane hoặc command slot thì cả hai giữ ở mức không-ready và không được cấp context. Khi handshake xảy ra, RV32 chụp `rs1/rs2`, RV64 chụp `rs1`. Descriptor/tensor DMA vẫn phải chờ matching non-kill commit theo REF-001. Các quy tắc này không cho phép suy luận rằng `rs1/rs2` luôn hợp lệ chỉ vì issue hợp lệ.

**Rủi ro Critical còn mở (DEC-033):** driver ở `rtl/common/third_party/cva6/core/cvxif_issue_register_commit_if_driver.sv` ghép `register_valid_o=issue_valid_o`, phát `commit_valid_o=issue_valid_o && issue_ready_i` và luôn đặt `commit_kill=0`. Comment trong driver dựa vào giả định issue đã non-speculative ở execute nhưng đánh dấu TODO xác minh. Nếu instruction còn có thể bị branch flush/exception kill sau đó, tensor có thể đã phát DMA/write output cho instruction bị hủy. Trước sign-off phải chứng minh tại core tích hợp rằng mọi tensor issue đã qua điểm killable cuối; nếu không, sửa host commit/kill integration. Không được coi cùng chu kỳ `commit_valid` là bằng chứng về tính non-speculative khi chưa có kiểm chứng.

**Khuyến nghị đã áp dụng:** giữ `X_ISSUE_REGISTER_SPLIT=0` cho release profile hiện tại vì nó khớp CVA6 driver trong repo và giảm state/latency đầu lệnh. Hãy kiểm tra coupled-ready, `rs_valid` stall, queue-full, pointer capture, multi-hart ID isolation và no-early-DMA; waveform register reorder/commit-before-register không thuộc profile này. Chỉ mở split=1 khi có host CVA6 đã hỗ trợ thật và verification riêng cho profile đó.

### 10.14 DEC-025 — Quyền truy cập DMA không đi theo privilege của instruction

HDS §1.2 và §18 trước đó ghi rằng mode M/S/U được truyền qua issue request. REF-001 §5.5.6 định nghĩa issue request gồm `instr`, `hartid`, `id`; không có privilege mode, ASID hay process ID. `hartid` phân biệt hart nhưng không phân biệt hai tiến trình hoặc address space dùng chung một hart. Với AXI master riêng và địa chỉ DMA vật lý 64-bit, CPU PMP/MMU không tự động chặn accelerator. Các bit `ARPROT/AWPROT` chưa được định nghĩa và tự chúng không thay thế policy cấp quyền cho từng buffer.

Rủi ro thực tế là descriptor lỗi hoặc phần mềm không tin cậy có thể khiến DMA đọc/ghi vùng không thuộc tensor, kể cả dữ liệu của hệ điều hành/hart khác; đây là vấn đề an toàn bộ nhớ dù workload không mã hóa dữ liệu. Descriptor, input, output và recurrent state đều phải nằm trong miền được cấp quyền. Cần quy định quyền đọc/ghi khác nhau, vùng địa chỉ cho phép, overflow khi tính span, alias giữa input/output/state, reset/flush và cách trả access fault. Các CSR chứa địa chỉ lỗi cũng cần quyền đọc/clear phù hợp; SRAM, ping-pong buffer và recurrent state cần zeroize trước khi đổi chủ nếu nhiều miền tin cậy dùng chung. Với non-coherent DMA, quyền truy cập không giải quyết cache ownership: vẫn cần ownership, cache-line alignment, clean/invalidate và fence.

Người dùng đã chọn DEC-025 + DEC-030: driver S-mode là trust boundary cho ứng dụng U-mode; U chỉ gửi operation request, opaque buffer handles/offsets và metadata hợp lệ. Driver kiểm tra owner/permission, tính span có overflow-check, alias, alignment và aperture, rồi tạo descriptor kernel-owned, DMA-visible. Vì ABI hiện chưa định nghĩa scatter-gather, mỗi range phải map thành một span vật lý liên tục hoặc driver staging vào buffer liên tục; lệnh S-mode dùng descriptor này sau cache clean/fence. Buffer được giữ ownership/pin đến khi AXI drain và CV-X-IF result retire; output lỗi bị invalid. U-mode không đọc CSR chứa địa chỉ lỗi. AXI firewall vẫn giới hạn toàn cục; nó không phân tách S-mode code hoặc tự thực hiện ownership check theo process. DEC-031 đã chọn aperture BASE/LIMIT cố định theo SoC build, driver dùng cùng platform constants. Actual BASE/LIMIT và read/write permissions, exact descriptor layout và API theo OS còn cần chốt. DEC-032 còn mở vì local `reference/md_doc/` chưa có nguồn AXI4 chuẩn hóa để chốt chính xác error-response behavior của firewall.

### 10.15 DEC-026 — Prefetch descriptor sau khi commit đã được chọn

Người dùng đã chọn DEC-026 A: descriptor của command queued chỉ được đọc sau khi command đã được accept, source lanes cần thiết đã được capture và matching non-kill commit đã được xác nhận. Khi N đang compute và N+1 đã qua điều kiện này, controller có thể prefetch descriptor N+1 để che một phần khoảng đọc; khả năng overlap còn phụ thuộc descriptor buffer, AXI arbitration và SRAM bandwidth, nên đây không phải latency guarantee.

Đọc descriptor trước commit bị cấm. Nếu command sau đó bị kill, một speculative AXI read vẫn có thể lộ traffic hoặc phát sinh bus fault cho một command không còn hợp lệ; cần thêm kill cancellation, response suppression và fault attribution. Lợi ích thường nhỏ vì descriptor chỉ vài beat, trong khi committed-only prefetch vẫn cho phép overlap an toàn với compute của command trước. Prefetch response/error phải được tag theo queued command `(hartid,id)` để không quy lỗi cho command đang active. TEST-022/COV-005 xác minh không có pre-commit request, overlap khi tài nguyên cho phép, và attribution đúng.

### 10.16 DEC-022/023 — Đầu ra lỗi và reset khi transaction chưa kết thúc

DEC-022/023 đã được người dùng chọn và được chuẩn hóa thành REQ-ERR-003/REQ-RESET-002. Với output tensor, error sau acceptance làm **toàn bộ destination invalid**; không có rollback, shadow commit hay validity bitmap theo tile. Hardware dừng công việc chưa phát, drain các write đã nhận và `B` response, sau đó hoàn tất lỗi. Software bỏ/reinitialize cả destination và retry nguyên command. Hợp đồng này giảm state/area và giữ semantics dễ hiểu, nhưng cho phép memory chứa partial output; software tuyệt đối không được đọc nó như output hợp lệ.

Trước ordinary functional reset, host phải quiesce và drain mọi command/result/AXI response đã nhận. Người dùng đã bác bỏ abort/isolation logic riêng cho tensor. Nếu `R/B` không về và watchdog hết hạn, recovery đã chốt là reset toàn SoC; local reset/release không an toàn vì request accepted có thể còn hiệu lực. Reset phải bao trùm các hart, tensor và các transaction agent nội bộ liên quan, rồi chỉ release khi stale response không thể khớp transaction mới. Lệnh CV-X-IF đang chạy bị bỏ, không phải command completion; output bị invalid. DEC-028 còn mở phần ordinary quiesce/reset sequencing. DEC-029 đã chốt hành động reset, còn threshold/owner, reset-domain coverage/release, reset-cause và software restart cần SoC chốt.

### 10.17 DEC-016 — Host CPU cluster và đường lệnh

“Cluster hiện tại” là tài liệu [VLSIT RISC-V Dual/Quad CPU Cluster HDS](../../specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md), một cấu hình CPU CVA6 2/4 hart có top `m_vlsit_riscv_cluster_axi_top`. Theo REQ-SYS-004 và DEC-022 của tài liệu đó, `CVA6ConfigCvxifEn=0` và top không xuất CV-X-IF accelerator ports. Đây là cluster CPU đang có trong repo; nó **không** phải một cụm tensor core và hiện chưa thể issue lệnh tensor trực tiếp.

Ba hướng đã được so sánh cho DEC-016 (phương án 2 đã được người dùng chọn):

1. **Bật CV-X-IF trong cluster đó:** gần nhất với mục tiêu CPU-issued tensor instruction, nhưng phải sửa cluster contract, đưa CV-X-IF ra boundary cho từng hart hoặc xử lý arbitration, giữ đúng `(hartid,id)`/commit/kill, rồi tích hợp `X_ISSUE_REGISTER_SPLIT` và reset sequencing. Đây là tích hợp sâu và cần kiểm tra license-preserving CVA6 config, decoder/test generator, deadlock/backpressure cho từng hart.
2. **Tạo top/wrapper tensor-host riêng dựa trên một CVA6 có CV-X-IF:** giữ cluster hiện tại ổn định, nhưng chưa tự động giải quyết multi-hart routing; wrapper vẫn phải chốt số endpoint, shared accelerator arbitration và route commit/kill. Hợp cho prototype/tích hợp từng bước nếu top hiện tại không nên sửa.
3. **Tạm dùng single-hart CVA6-CV-X-IF top để bring-up, sau đó mở rộng multi-hart:** ít biến số ban đầu nhất để xác minh ISA adapter/DMA, nhưng không chứng minh được fairness/ordering/hart-ID behavior của bản 2/4-hart cuối.

Khuyến nghị kỹ thuật là dùng wrapper host riêng làm ranh giới tensor trước, ban đầu nối một hart để bring-up rồi thiết kế wrapper mở rộng N hart; chỉ bật lại CV-X-IF trong cluster chính khi đã chốt API cổng per-hart/arbitration và verification plan. Người dùng đã chọn chiến lược top riêng; hướng single-hart bring-up vẫn chỉ là một bước triển khai được khuyến nghị, chưa phải quyết định về số hart cuối cùng. Số endpoint, split/coupled register mode, hart routing, issue-age/kill logic và queue-full progress vẫn phải chốt. Chính sách privilege DEC-027 đã chọn S/M-only; gate thực tế trong CVA6 và trap/no-side-effect behavior cần verification. Không nên mô tả accelerator là “kết nối được cluster hiện tại” cho tới khi các chi tiết đó được triển khai và xác minh.

### 10.18 DEC-027/028 — Hai ranh giới tích hợp còn thiếu

DEC-027 là quyền **phát lệnh**, khác với DEC-025 là quyền DMA truy cập memory. CVA6 chỉ cho S/M issue tensor command; U-mode bị trap trước CV-X-IF. Theo DEC-030, U-mode gọi driver S-mode; driver nhận handle/offset và tensor metadata, xác thực buffer, tạo descriptor kernel-owned, issue lệnh thay mặt ứng dụng và giữ ownership/cache contract đến completion. Không nhận physical pointer hoặc descriptor do user kiểm soát. Cách này tránh thêm IOMMU/PASID nhưng đưa driver, OS memory manager và cache-maintenance code vào trusted computing base; firewall giới hạn aperture chứ không cô lập S-mode. Cách cấu hình aperture đã chốt là fixed SoC build (DEC-031); cần hoàn tất actual BASE/LIMIT/permissions, descriptor ABI, CSR access và zeroization theo DEC-025. DEC-032 yêu cầu chốt nguồn/revision AXI4 trước khi freeze response behavior cho các burst bị firewall từ chối.

DEC-028 là giao thức **quiesce/reset** cho ordinary functional reset giữa tensor IP và SoC. Nếu không có CSR mode 2, software cũng không thể dựa vào `busy` register để sequencing. Candidate IF-004 chỉ có reset-control sideband: reset controller phát `quiesce_req` vào tensor IP; IP trả `quiesce_ack` khi không còn command/result state hay outstanding AXI ID. Functional reset chỉ theo sau ack. Không có `dma_abort_req/ack`, isolation gate, hay fabric cancellation logic trong tensor IP. Timeout do thiếu `R/B` response không chờ quiesce ack mà kích hoạt full SoC reset theo DEC-029. Cần chốt CDC và ordinary quiesce timing; watchdog/reset coverage/release được xử lý ở DEC-029.

### 10.19 DEC-029 — Lệnh được accept nhưng AXI không trả response

Đây là lỗ hổng liveness/error ABI độc lập với ordinary reset sequencing. CV-X-IF đã accept một instruction thì software bình thường cần completion/result để retire; nhưng `RVALID`/`BVALID` có thể không đến nếu fabric bị lỗi. AXI4 không định nghĩa tín hiệu requester dùng để hủy transaction sau khi `AR/AW` handshake đã xảy ra. Người dùng bác bỏ abort/isolation riêng. Quyết định: nếu SoC watchdog xác định request đã timeout, coi đây là lỗi nghiêm trọng và reset toàn SoC. Reset bao trùm các hart, tensor, interconnect và transaction agents nội bộ có thể còn giữ request; tensor không tự phát `TC_ERR_AXI_TIMEOUT`, không trả result, không nhả/reuse ID. Các response lỗi đã nhận như `SLVERR/DECERR` vẫn theo command error path bình thường.

Lựa chọn đã rõ: không có `dma_abort_req/ack`, timeout-completion path, hoặc isolation gate trong tensor IP; missing-response timeout dẫn đến full SoC reset duy nhất. DEC-029 đã chốt hành động reset, nhưng còn mở watchdog threshold/owner, reset-domain coverage/release, reset-cause capture và software restart sau khi SoC khởi động lại. Ordinary functional reset vẫn dùng quiesce/drain DEC-028. Output của command bị gián đoạn invalid theo DEC-022. Đây là đánh đổi rõ: logic/ports/verification trong accelerator giảm, nhưng reset có thể ảnh hưởng mọi hart và traffic khác, và command đang chạy bị mất.
