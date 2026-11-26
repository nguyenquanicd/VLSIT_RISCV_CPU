# Review chuyên sâu spec Tensor Coprocessor: hiệu năng, latency, timing và mục tiêu TOPS

| Mục | Nội dung |
|---|---|
| Ngày review | 2026-11-17 |
| Đối tượng | [VLSIT_TENSOR_COPROCESSOR_HDS.md](../VLSIT_TENSOR_COPROCESSOR_HDS.md), [TENSOR_COPROCESSOR_INSTRUCTION_SET.md](../TENSOR_COPROCESSOR_INSTRUCTION_SET.md), FSM, block diagram và waveform trong `figures/`, đối chiếu với spec cluster `doc/specification` |
| Trọng tâm | Mục tiêu 64 TOPS, hiệu năng thực (throughput), latency, khả năng chèn pipeline để xử lý timing violation |
| Giới hạn bằng chứng | IP này **chưa có RTL**, nên kết luận về timing và latency ở mức spec/mô hình. Không có thư viện công nghệ nên không có số ps hay mm² thật. Nhận định về hành vi retire/commit cụ thể của CVA6 cần kiểm RTL tích hợp, không suy ra chỉ từ CV-X-IF. |
| Công cụ đã chạy | `roofline.py` (số học), `utilization.py` (mô hình sử dụng), `run_depth_probe.sh` (Yosys/ABC, độ sâu logic PE); follow-up đã kiểm tra bản CV-X-IF local và workbook CSR |
| Ngôn ngữ | Tiếng Việt, giữ thuật ngữ kỹ thuật tiếng Anh |

> **Erratum 2026-11-17 (review lại):** UT-04 được rút lại đối với host CVA6, vì CVA6 gửi commit cùng lúc issue và không bao giờ kill; UT-03 được chỉnh (queue sâu dùng được nếu phần mềm dựng sẵn descriptor, nhưng độ trễ ngắt và debug bằng thời gian command). Một số đề xuất §9 bị hạ thành lựa chọn có điều kiện kích hoạt. Chi tiết và phản biện: [VLSIT_TENSOR_COPROCESSOR_Rereview_2026-11-17.md](VLSIT_TENSOR_COPROCESSOR_Rereview_2026-11-17.md).

## Đối chiếu với HDS hiện tại

| Điểm review | Phản biện và nội dung đã cập nhật | Bằng chứng còn cần |
|---|---|---|
| TP-01/02, UT-01. Đỉnh INT8 và SRAM | Giữ 64 TOPS là đỉnh mục tiêu của IP. Con số 4,5 MiB trong mô hình tile vuông là một điểm minh họa bỏ qua traffic output. Trong ví dụ hữu hạn M=1.024, N=K=4.096 của HDS, một nhóm 8×8 có cùng 4.608 KiB nhưng trần theo lưu lượng chỉ 58,25 TOPS. Nhóm 8×11 cần 6.240 KiB và có trần 65,54 TOPS ở 64 GB/s giả định, gần như không còn dư cho overhead. | Lịch tile, cổng SRAM, số lần nạp lại và băng thông cấp thực tế. So sánh thông lượng đo được với trần đúng cấu hình. |
| TT-01…07. Pipeline và clock | HDS giữ năm điểm cắt build độc lập và vòng feedback cố định. Carry-save INT8 và xen kẽ FP32 là phương án thiết kế cần đo; số mức cổng trong probe chỉ dùng so sánh tương đối. Build đầu dùng CLK-CORE chung với CVA6. Với 16 mảng 32×32, 64 TOPS đỉnh cần ít nhất 1,953125 GHz trên top tích hợp. | Chọn PDK, SRAM macro và cấu hình cắt. Chạy STA setup/hold hai chiều IF-001, kiểm tra II, độ trễ cuối lệnh và đối chiếu số học giữa các cấu hình. |
| TL-01…05, TP-03. Prefill và decode | HDS tách peak, mức sử dụng mảng, TTFT, inter-token latency và token/s của batch 1/4. Fused ARGMAX giảm ghi/đọc logits nhưng vẫn phải đọc trọng số projection. DEC-039 giữ cả percentile và hard bound có điều kiện. | Model/workload đích, ngưỡng KPI, trace và cam kết phục vụ SRAM, AXI, result-ready, host frontier. Các ước tính trước đây không xác lập KPI phát hành. |
| TI-01/03, UT-03/04. Host và đổi mode lúc chạy | Chọn top CVA6 riêng, issue/register split=0, non-kill commit sau khi lệnh cũ đã hết khả năng fault, và kill theo tuổi scoreboard. Nạp descriptor N+1 sau commit, giữ mode của từng command, và có thử nghiệm phân bổ credit AXI. HDS chỉ ra các điểm nối khả dĩ trong CVA6 hiện có. | RTL top mới, bằng chứng không truy cập DMA trước commit, precise retirement/interrupt/debug, và trace overlap khi nhiều lệnh tranh bus. |
| DEC-010/021/075. Scalar và đường lỗi | Giữ result theo opcode, fence OP-003 đối với zero, và dùng một hart đặc quyền riêng cho lỗi mode 2 thông thường. Hart lưu bản ghi trước W1C và tiếp tục phục vụ khi submitter chờ. | ID hart, đường APB, binding/journal và đo cận W1C. Kiểm tra debug dừng nhóm, rd=x0, reuse ID và khả năng tiến triển khi journal đầy. |
| DEC-022/028/029/074. DMA và reset | HDS xác định burst ghi đã bắt đầu ngay khi đưa AWVALID hoặc WVALID lên. Phải hoàn tất cả hai kênh và B trong drain. RLAST trễ không giải phóng ID. Timeout dẫn đến reset toàn SoC. | RTL/fabric fault injection, ngưỡng watchdog và bằng chứng reset không để phản hồi từ lần chạy cũ lọt vào epoch mới. |
| RV-007/013. ISA và tài liệu kiểm chứng | Companion ISA có chín operation, hai schema ARGMAX theo build, descriptor byte-exact, datapath và behavior. Bộ kiểm tra đối chiếu CSR workbook, nguồn 17 waveform, hằng số ABI và liên kết yêu cầu–test. | Đối chiếu với RTL/driver thật, waveform tích hợp và kết quả chất lượng model cho từng cặp operation/precision. |

Các đề xuất trong phần review lịch sử được giữ để giải thích trade-off. Mục §7 của bản review có các phương án khảo sát chưa được chọn, gồm clock tensor riêng, cut theo số tầng, command ring, INT4 và performance-counter CSR. Dùng các quyết định trong HDS hiện tại để xác định phạm vi phát hành. [HDS hiện tại](../VLSIT_TENSOR_COPROCESSOR_HDS.md) · [ISA companion](../TENSOR_COPROCESSOR_INSTRUCTION_SET.md)

### Kiểm tra gói đặc tả hiện tại

| Phạm vi | Bằng chứng đã kiểm tra | Bằng chứng cần cho cấu hình phát hành |
|---|---|---|
| Điểm cắt và hiệu năng | HDS §8.1 có năm tham số độc lập, lịch so sánh cấu hình và tiêu chí chọn theo thời gian thực. §13 tách 64 TOPS INT8 lý tưởng, prefill, decode và cận latency có điều kiện. | Tần số, số chu kỳ, dung lượng/cổng SRAM và tải AXI đã xác nhận trên top tích hợp. |
| Tập lệnh và thuật toán | ISA có hành vi, datapath và layout cho OP-001 đến OP-009. Mười schema bao gồm hai biến thể OP-004. C và SystemVerilog đối chiếu hằng ABI từ cùng bản đồ. Các vector số học kiểm tra những trường hợp đã nêu trong bộ kiểm tra. | Bit-accuracy các cặp lệnh–precision phát hành, tập mẫu model, tiêu chí chất lượng và workload thực. |
| Đầu nối, thanh ghi và waveform | Đã mở nguồn SVG của 17 waveform, kiểm tra WaveJSON và thứ tự bắt tay. Hai sơ đồ có nguồn draw.io. Workbook mở được và dữ liệu map khớp mô hình thanh ghi. | Trace CVA6/AXI/APB để xác nhận safe commit, drain, W1C, reset và xử lý lỗi trên phần cứng. |
| Truy vết | Kiểm tra cấu trúc HDS đạt 22 mục. Bộ kiểm tra đối chiếu 61 yêu cầu và 154 liên kết test, 43 vector số học, ABI C và 318 hằng/lookup SystemVerilog. | Bằng chứng chạy các test triển khai và báo cáo timing cho đúng profile phát hành. |

Lệnh tái lập kiểm tra ABI: `python scripts/check_tensor_spec.py --cc gcc --verilator <đường dẫn Verilator>`. Đối chiếu cuối xác nhận đủ DEC-001–075, đúng năm điểm cắt pipeline, đủ OP-001–009 và cả 14 nhãn đầu nối/đường nội bộ trong chú giải sơ đồ. Các mục review về host đã có điểm nối nguồn CVA6 và kịch bản kiểm tra cho cổng đặc quyền, bắt tay split=0, safe commit/kill nhiều hart và writeback khi lệnh bị từ chối. HDS ghi các ứng viên bring-up và điều kiện phải chứng minh cho build phát hành. Repository chưa có RTL tensor tích hợp để đo Fmax, throughput hoặc latency. [HDS](../VLSIT_TENSOR_COPROCESSOR_HDS.md) · [ISA](../TENSOR_COPROCESSOR_INSTRUCTION_SET.md) · [Sơ đồ và waveform](../figures/README.md)

## 0. Kết luận ngắn

| Câu hỏi | Kết luận |
|---|---|
| Con số 64 TOPS có đúng không? | **Số học đúng** (16 array × 32×32 × 2 GHz × 2 phép/MAC = 65.536 TOPS). Đây là đỉnh lý tưởng do người dùng chọn. Với candidate một cổng AXI 256-bit (64 GB/s), tile 128 và SRAM 128 KiB, mô hình hữu hạn tile cho trần khoảng **8,2 TOPS (12,5% đỉnh)**; các kích thước này chưa phải cấu hình phát hành. Mô hình tile vuông bỏ qua traffic output cho điểm **4,5 MiB** gần đỉnh (TP-01). Lịch hữu hạn trong HDS còn phải tính output và các lượt đọc lại. |
| Decode có đạt latency không? | Với giả định INT8 và 70% của 64 GB/s, mô hình Llama-3.2-3B cần khoảng **72 ms/token** chỉ cho lượt đọc trọng số. Bản HDS được review khi đó ghi `<50 ms/token` nhưng chưa nêu đủ model/memory assumptions; sau phân tích, con số đó được hạ về ví dụ sơ bộ và target phát hành theo latency/tokens/s được để mở trong DEC-018. Đây là roofline, không phải benchmark thực. |
| Cơ chế chèn pipeline có đủ để đạt 2 GHz không? | **Chưa.** Vòng tích lũy carry-propagate "cố định" sâu hơn cả bộ nhân (48 so với 29 mức cổng), nên 5 cut nhị phân chỉ đưa tần số tối đa từ 1,0× lên khoảng 1,27×. Muốn 2 GHz cần tích lũy carry-save (vòng chỉ 4 mức) và thêm cut ở nhiều chỗ spec chưa nêu (TT-01 đến TT-06). |
| Latency có được cam kết không? | **Không có con số nào** (PPA-005, 006, 008 đều TBD). Đồng thời spec quá thận trọng về latency do chèn pipeline: vài chục chu kỳ ở 2 GHz là vài chục ns, nhỏ hơn nhiều so với latency DRAM (TL-04). |
| OP-003 có thể nhận ra lỗi rõ ràng không? | **Đã chốt ở mức ABI/spec:** giữ rd=0 và CSR, thêm global hardware fence. DEC-057 cũng chốt SUM/MAX, cap 1,048,576 phần tử, INT8 exact signed-32 sum, FP32 fixed balanced sum tree/rounding, scalar bit encoding, NaN/Inf/signed-zero rules. Driver đặc quyền khóa submit trên tất cả hart, đợi busy=0 và dọn lỗi cũ; phần cứng chỉ nhận OP-003 tại ranh giới sạch rồi backpressure mọi hart. Fence làm các tensor command khác phải đợi trong toàn bộ thời gian OP-003 chạy và đến result handshake; nếu kết quả bằng 0, còn chờ thêm CSR/W1C/ack round-trip trước khi mở. err_valid=0 nghĩa là zero hợp lệ; err_valid=1 là lỗi của chính lệnh OP-003. Descriptor body offsets/schema size đã đóng ở DEC-065; RTL/driver/CDC verification vẫn phải hoàn tất. |
| Lỗi DMA có thể để lại output dở dang hoặc response sau reset không? | Có. Người dùng đã chọn invalid toàn bộ output command lỗi và IF-004 quiesce/drain trước ordinary functional reset, đồng thời từ chối local abort/isolation. Nếu watchdog phát hiện thiếu `R/B` response, recovery duy nhất là reset toàn SoC; command CV-X-IF đang dở bị bỏ và không có tensor result/status. Firewall-denied `SLVERR` và downstream `SLVERR/DECERR` có response vẫn theo error-completion bình thường. DEC-028 đã đóng handshake; watchdog threshold/owner, reset coverage/release, reset-cause capture và software restart vẫn là tích hợp SoC theo DEC-029. |
| Issue/register và commit có cùng ý nghĩa không? | Không. `X_ISSUE_REGISTER_SPLIT=0` chỉ ghép issue/register để chụp operand/pointer. Người dùng đã chọn DEC-033/034: CVA6 vẫn accept/capture sớm, nhưng per-hart tracker chỉ phát non-kill commit sau khi mọi lệnh cũ không phải CV-X-IF có trạng thái `fault_resolved` hoàn chỉnh; `scoreboard_entry_t.valid` một mình không đủ vì CSR/commit-stage và các nguồn flush khác có thể đến sau. Tracker được đi qua tensor cũ đã non-kill-commit dù result còn pending, để giữ overlap N/N+1. Branch/LSU/CSR/fence/trap phải được đưa vào proof; kill suffix theo scoreboard age, không so sánh ID vòng như số. Sau commit, không được kill/làm mất command. Người dùng đã chọn DEC-035 A: latch interrupt/debug theo hart, ngừng issue/commit lệnh trẻ hơn, drain/retire các command đã authorized rồi mới vào handler; hart khác vẫn hoạt động. Event được giữ đến khi các command đã authorized retire; maximum backlog/shape và worst-case entry latency cần chốt theo DEC-018. Driver hiện tại vẫn commit ngay issue-ready nên không được dùng nguyên trạng; source mapping, host RTL và verification vẫn là P0. |
| DMA có kiểm tra privilege của lệnh CPU không? | CV-X-IF không mang privilege mode, ASID hoặc process ID. Người dùng đã chọn S/M-only gate tại CVA6 trước CV-X-IF: U-mode bị illegal-instruction trap (cause 2), không tạo issue/side effect (DEC-027/REQ-SEC-001). Đã chọn U-mode gọi S-mode driver (DEC-030): driver xác minh ownership/range và tạo descriptor kernel-owned trong aperture; firewall vẫn giới hạn DMA. S-mode code vẫn là trust domain. DEC-031 chọn BASE/LIMIT cố định theo SoC build; actual values, read/write permissions và CSR access cần tích hợp. DEC-032 đã đóng dựa trên Arm IHI 0022H Issue H: firewall từ chối burst bằng `SLVERR` đúng khung AXI4; actual aperture constants và placement vẫn phải sign-off. |
| Có thể prefetch descriptor trước commit không? | Người dùng đã chọn DEC-026 A: chỉ prefetch sau khi lệnh queued được accept, đã capture đủ source register và có matching non-kill commit. Descriptor của N+1 vẫn có thể đọc chồng lên compute N nếu buffer/arbitration cho phép; lệnh uncommitted/killed không tạo descriptor request hay fault. TEST-022/COV-005 bao phủ điều kiện này. |
| “Cluster hiện tại” là cluster nào và tensor nối được chưa? | Đó là VLSIT RISC-V Dual/Quad CPU Cluster: top `m_vlsit_riscv_cluster_axi_top`, 2/4 hart CVA6. REQ-SYS-004/DEC-022 đặt `CVA6ConfigCvxifEn=0` và không xuất CV-X-IF, nên tensor không thể nhận lệnh từ top đó. Người dùng đã chọn tạo top tensor riêng với CV-X-IF-enabled CVA6 và giữ cluster hiện tại nguyên trạng (DEC-016). Cấu hình CVA6, số hart/endpoint và routing cụ thể vẫn cần tích hợp. |
| Mảng tensor có rảnh không? | **Theo mô hình decode batch-một đã nêu, phần lớn MAC không được cấp đủ dữ liệu.** Cần 512 MAC/byte DRAM để lấp cấu hình đã giả định; decode batch-một đạt trần khoảng 0,2% nếu chỉ đọc trọng số INT8 từ DRAM. Đây là giới hạn của giả định memory-bound, không chứng minh mọi workload đều có utilization thấp. Tăng array count không tự khắc phục thiếu bandwidth; batch/reuse, compression, SRAM/cache residency và scheduling có lợi tùy workload (§8). |
| Precision trong command được mã hóa thế nào? | Người dùng chọn DEC-017 A: funct3 chọn một precision cho toàn command. Với INT8 OP-001/OP-008, DEC-036/037/038 chốt miền addend, bound accumulator và `PARA_MAX_K=16,384`; DEC-053/054 chốt output INT8 per-channel Q31 multiplier/signed-exponent, product rộng `PARA_ACCUM_W+32`, nearest-even và saturation. Hệ số lỗi trả `TC_ERR_REQUANT_COEFF` trước tensor-data DMA. DEC-055 chốt activation-after-requantization cho INT8 fused GEMM. DEC-056 đóng OP-002: sáu mode runtime, broadcast chỉ cho bias chiều cuối, INT8 Q16.16/Q31 và saturation, FP32 trung gian với rounding từng node, GELU_TANH/SILU có sai số tuyệt đối tối đa 2^-10 trong [-10,10] và luật NaN/Inf. DEC-061 bổ sung ngoại lệ duy nhất cho precision command-wide: recurrent state OP-009 là FP32 dù Q/K/V/output là BF16/FP16. Generated descriptor headers, độ chính xác model của LUT/quantization/linear attention, vector width và PPA/Fmax vẫn cần sign-off; target model cũng phải nằm trong cap K. |
| Sửa spec thế nào? | Các sửa chữa được chấp nhận đã được đưa vào HDS: mô hình roofline có điều kiện, operation/precision qualification, FSM error-drain, CSR first-error map và waveform WF-011…WF-017. DEC-040 chọn header descriptor 64 byte little-endian; DEC-059/060 đóng toán học OP-006/007; DEC-061 đóng OP-009; DEC-062 chốt metadata nibble và packed-weight order OP-008; DEC-063 chọn kiểm tra metadata theo từng tile trước khi đọc numeric operands; với OP-008, kiểm tra vector hệ số requantization và metadata tile đầu có thể overlap, nhưng cả hai phải hợp lệ trước khi đọc operand số học. DEC-064 chốt first-build M/N<=16,384, products<=2^35, output tiles<=4,096, input/output logical spans<=64 MiB cho OP-001/008. DEC-065 đã đóng body byte offsets/schema sizes; generated driver headers, kích thước staging/prefetch, model qualification và PPA/service signoff còn mở. Ring, clock tensor riêng, carry-save bắt buộc, thay đổi pipeline ABI, counters và yêu cầu utilization cố định chưa được chọn. |
| Nên làm gì trước? | Giữ 64 TOPS là đỉnh GEMM/prefill lý tưởng, không phải decode target. Người dùng chọn baseline DEC-018: hidden 2,048/4,096; sequence/context 128/2,048; batch 1 và batch 4 (bốn prompt/stream độc lập được schedule cùng nhau). Đây là điểm benchmark, không phải giới hạn shape chung. OP-004 đã chốt `vocab_length<=65,536` cho cả standalone/fused (`PARA_MAX_ARGMAX_VOCAB`) và fused `input_width<=4,096` (`PARA_MAX_ARGMAX_INPUT`). Ở input width tối đa đã chọn, fused cần 268M MAC nhưng phải đọc 256 MiB INT8 hoặc 512 MiB BF16/FP16 weights; tại AXI ứng viên 64 GB/s, sàn truyền lý tưởng là 4,2/8,4 ms, lớn hơn sàn tính toán 8,4 µs ở 64 TOPS. Đây là roofline, không phải latency đo được; fused giảm traffic logits nhưng không loại bỏ traffic đọc ma trận projection. OP-005 đã chốt `Lq/Lkv<=2,048`, aggregate Q/K và V width 4,096, head-count 64, batch 4, và per-head V width 128. DEC-044 gói batch trong một descriptor; DEC-046 schedule theo bounded waves; DEC-045 giữ active `m/l/o` state trong SRAM suốt vòng K/V; DEC-047 chọn DMA-managed tile SRAM. DEC-048/049 chốt build-static tile/context sizing và cap `Dv<=128`; giá trị tile/context, dung lượng SRAM và PPA còn là sign-off. Ở `Lq=2,048`, tối đa 131.072 hàng softmax mỗi sample; nếu giữ tất cả cùng lúc thì `m/l` cần 1 MiB, còn `o` thêm tối đa 32 MiB/sample. Ở các cap sequence/width, batch 1 cần tối đa 34,36B MAC (~1,07 ms lý tưởng ở 64 TOPS); batch 4 khoảng 4,3 ms trước khi tính memory. Các giá trị này không phải latency đo. DEC-057/059/060/061 đã chốt cap của OP-003/006/007/009; DEC-064/067 đã chốt cap OP-001/008 và OP-002. Cần chốt backlog, `result_ready`, SRAM stalls, memory/AXI service và fairness trước khi chứng minh hard bound. User đã chọn report cả service-level TTFT/inter-token/tokens/s lẫn CV-X-IF command timestamps. Build đầu dùng `PARA_MAX_K=16,384` (DEC-038). DEC-039 đòi percentile KPI và hard upper bound có điều kiện theo SoC service guarantee. Missing AXI response dẫn tới full-SoC reset; không hứa interrupt entry cho fatal path. Trước RTL freeze cần hiện thực/xác minh host top, S/M gate, SoC watchdog/reset contract, firewall, quiesce, và đo timing với library/STA thật. Ring, clock riêng, carry-save, INT4/FP8 và on-IP counter vẫn là lựa chọn có điều kiện, chưa được duyệt. |


## Follow-up analysis — 2026-11-19

DEC-043 đã chốt giới hạn 64 attention heads. Phân tích tiếp theo cho thấy cần tách **tổng trạng thái toán học** khỏi **SRAM phải giữ đồng thời**: ở `H=64`, `Lq=2,048`, aggregate V width 4,096, FP32 `m/l/o` là 33 MiB mỗi sample (132 MiB ở batch 4) nếu giữ mọi query row. Không nên suy ra đây là dung lượng SRAM bắt buộc; tile scheduling có thể giữ một số query/head blocks rồi chạy các block còn lại theo wave. Với ví dụ `Tq=32`, `Tk=128`, head width 64, BF16 Q/K/V và FP32 score, mỗi work group cần khoảng 94,464 byte cho Q, ping-pong K/V, score/probability staging và `m/l/o`; 16 nhóm đồng thời cần khoảng 1.44 MiB trước các buffer khác. Do đó điểm 128 KiB trong bảng GEMM chỉ là budget cho luồng GEMM ví dụ, không phải ngân sách đầy đủ cho attention.

**DEC-045 đã chọn chính sách state:** giữ `m/l/o` của mỗi query/head tile đang chạy trong SRAM local suốt vòng K/V; Q/K/V lớn được DMA từ DRAM vào ping-pong SRAM, còn tile khác chạy ở wave sau. Cách này giảm traffic state qua AXI và giữ latency thấp, nhưng mức song song bị giới hạn bởi SRAM chứa được bao nhiêu context. Bạn yêu cầu build có cấu hình để cân bằng hiệu năng/latency với dung lượng SRAM; DEC-048 đã chọn tham số tĩnh cho `PARA_ATTN_TILE_Q`, `PARA_ATTN_TILE_KV`, `PARA_ATTN_MAX_ACTIVE_CONTEXTS` và dung lượng SRAM suy ra từ macro; build bị từ chối nếu thiếu SRAM. DEC-049 đã chốt cap per-head V-width=128. Ở giới hạn hiện tại, giữ mọi query row cần 33 MiB/sample hoặc 132 MiB cho batch 4, nhưng chính sách đã chọn chỉ giữ state các context đang hoạt động, không bắt buộc toàn bộ state đó ở SRAM. DEC-047 chọn DMA-managed tile SRAM: descriptor chứa tensor base/shape/stride, hardware address generator phát burst, phần mềm không gửi từng tile riêng. DEC-044 chọn một descriptor OP-005 cho batch-4; DEC-046 chọn wave có số sample thực tế bị giới hạn bởi cả `PARA_ATTN_MAX_ACTIVE_SAMPLES` lẫn `PARA_ATTN_MAX_ACTIVE_CONTEXTS`; mỗi sample hoạt động có ít nhất một context. Giá trị release vẫn chờ signoff SRAM/PPA. Batching không tự giảm Q/K/V bytes vì mỗi prompt thường có tensor riêng, và một lỗi làm toàn bộ output command batch invalid theo DEC-022. Các kích thước Tq/Tk nêu trên vẫn chỉ là ví dụ.

**DEC-047 đã chọn:** dùng DMA-managed tile SRAM, không dùng transparent tagged cache trong bản đầu. Descriptor cung cấp tensor base/shape/stride; address generator/scheduler tính địa chỉ tile, phát AXI burst, lấp ping-pong banks và ghi output. Cách này hợp với truy cập tensor có thứ tự, cho phép overlap compute với tile kế tiếp và latency dễ phân tích hơn; đổi lại phần cứng không tự dò tag/evict để giữ dữ liệu, nên reuse ngoài SRAM phải được xử lý qua lịch/tile hoặc command kế tiếp. Driver quản lý ownership và cache maintenance của CPU do AXI non-coherent. Còn phải chốt tile/burst granularity, SRAM capacity/banks/ports và AXI limits/service trước hard-latency signoff.

**DEC-048 đã chọn phương án tham số build tĩnh:** dùng `PARA_ATTN_TILE_Q`, `PARA_ATTN_TILE_KV`, `PARA_ATTN_MAX_ACTIVE_CONTEXTS` và `PARA_MEM_SRAM_BYTES` được suy ra từ cấu hình SRAM macro; build/signoff tính state `m/l/o` cộng operand/score/metadata/output buffers rồi từ chối cấu hình nếu SRAM không đủ. Số sample chạy cùng wave bị chặn bởi cả sample cap và context cap. Các giá trị/default và SRAM macro vẫn phải chốt. Cách này làm tài nguyên và latency dễ dự đoán; tăng tile/context có thể cải thiện occupancy nhưng tăng SRAM, còn giảm chúng tiết kiệm SRAM nhưng tạo thêm wave/control overhead.

**DEC-049 đã chốt cap V-width mỗi head:** `PARA_MAX_ATTN_V_HEAD_WIDTH=128`, bên cạnh aggregate cap 4,096. Các layout 32×128 và 64×64 vẫn hợp lệ; một head rộng hơn trả `TC_ERR_SHAPE` trước khi đọc tensor. Với `Tq=32`, state FP32 `m/l/o` tối đa 16.25 KiB cho một context. Feature tiling/replay được hoãn vì phải giữ thêm state hoặc lặp traffic/tính QK, làm tăng latency và độ phức tạp điều khiển. Đây là trade-off cho bản đầu; cap sequence, precision, SRAM macro và service của AXI vẫn cần sign-off PPA/hệ thống.
**DEC-050 đã chốt quy ước tensor reference trong descriptor:** mỗi tensor có địa chỉ DMA vật lý 64-bit riêng, extent 32-bit theo phần tử, stride 64-bit theo byte, little-endian và một span vật lý liên tục. Hardware và driver dùng chung công thức byte-span có kiểm tra tràn; shape/layout sai trả TC_ERR_SHAPE, địa chỉ/tràn số/misalignment trả TC_ERR_ADDRESS, còn firewall từ chối aperture qua lỗi AXI. Bản đầu không có SG/IOVA nên driver phải từ chối hoặc staging buffer không liên tục. DEC-065 đã chốt offset/schema/rank, pitch và alias theo từng operation. DEC-066 đã chốt quy tắc căn chỉnh build-static; giá trị PARA_DMA_ALIGN_BYTES vẫn lấy từ AXI/cache của SoC. Descriptor và state record OP-009 tiếp tục căn theo 64 byte trở lên. BASE/LIMIT thực tế của SoC và driver-generated definitions vẫn cần hoàn tất trước integration signoff.
**DEC-051 đã chốt quy tắc layout:** mỗi operation chỉ cho stride của một chiều liên tục bằng kích thước phần tử; các chiều khác chỉ được padding hàng/batch theo pitch hợp lệ, không chồng phần tử: schema khai báo thứ tự chiều trong bộ nhớ từ nhanh nhất đến chậm nhất; stride chiều nhanh nhất bằng kích thước phần tử, mỗi stride chiều ngoài phải ít nhất bằng extent của chiều trước nhân stride chiều trước, có kiểm tra tràn. Transpose phải được operation khai báo; stride tùy ý và broadcast stride 0 bị cấm trừ khi submode nêu rõ. Output không được tự overlap; alias input/output chỉ được phép khi operation nói rõ. Phần cứng vẫn có byte-stride fields; pitch, transpose và alias rules đã được đóng trong DEC-050/051/052/065. DEC-066 đã chọn alignment build-static; giá trị và constants tương ứng vẫn phải lấy từ cấu hình AXI/cache của SoC.
**DEC-052 đã chốt GEMM orientation:** OP-001 giữ M/N/K theo phép nhân logic A[M,K]×B[K,N]=C[M,N] và hỗ trợ độc lập hai cờ transpose_A/B. Cả bốn tổ hợp đều chạy trực tiếp từ layout row-major tương ứng; A/B phải có chiều trong cùng liên tục, pitch hàng có thể padding nhưng không overlap. Output C luôn row-major, không hỗ trợ transpose. Cách này tránh copy weight/input giữa các tổ hợp thường gặp và giữ burst liên tục; đổi lại thêm chọn đường address/operand và kiểm đủ bốn trường hợp. Byte offsets của các cờ, first-build M/N/work/tile/span caps đã được DEC-064 chọn; byte offsets được đóng tại DEC-065; precision-specific numeric/epilogue qualification vẫn còn mở.
**DEC-053/054 đã chốt chuyển đổi output GEMM INT8:** scale activation dùng chung; weight scale theo output channel; mỗi channel có record 8 byte gồm multiplier Q31 unsigned đã chuẩn hóa, exponent signed và ba byte reserved-zero. Phần cứng tính accumulator×multiplier trong `PARA_ACCUM_W+32` bit, shift phải `31-e`, round nearest-even đối xứng và saturate INT8. Toàn bộ vector được validate trước numeric operand reads; lỗi nội dung trả `TC_ERR_REQUANT_COEFF`. Với OP-008, lượt validate này có thể overlap metadata tile đầu nhưng cả hai phải xong trước numeric fetch. Metadata cần 8N byte cho lượt validate và có thể được cache hoặc đọc lại theo tile cho epilogue. DEC-055 đã chốt activation sau requantization. DEC-056 đã chốt standalone OP-002: mode/activation IDs, integer and FP datapaths, Q16.16 scaling, fixed rounding/saturation order, function equations, error envelope and non-finite behavior. Còn mở: generated descriptor definitions, model accuracy for quantized tables/scales, vector width and PPA/Fmax signoff; roofline INT8 uses INT8 output traffic.

## 0.1 Ranh giới giữa quyết định đã chọn và đề xuất trong bản review

Tài liệu review này là phân tích kỹ thuật, không tự thay thế quyết định của chủ dự án. Các mục gợi ý trong §9 và §10 là phương án để cân nhắc; chỉ những điểm đã được người dùng chọn mới trở thành yêu cầu của HDS. Sau khi đối chiếu với các quyết định đã có, các điểm sau được giữ làm chuẩn:

- Giữ **64 TOPS là đỉnh INT8 lý tưởng** cho một IP nhiều array; `PARA_ARRAY_COUNT` là tham số build. Sửa HDS để tách rõ đỉnh lý tưởng với throughput duy trì và điều kiện roofline; không đổi target thành số TOPS suy ra từ một buffer candidate.
- Giữ command ABI CV-X-IF theo từng lệnh: `custom-0`, `funct7` là operation ID, `funct3` là precision, descriptor mang shape/stride/address/submode. Ring/doorbell, `TC_SUBMIT/TC_SYNC` chưa được chấp nhận.
- Giữ 5 pipeline boundary đã chọn; không thêm cut ở accumulator feedback/PE forwarding, không đổi từ từng boundary on/off sang số tầng tùy ý nếu chưa có timing/STA evidence.
- Giữ AXI4 non-coherent + banked SRAM và một clock datapath `CLK-CORE` cùng APB domain bất đồng bộ. ACE, clock tensor riêng, array groups, INT4 và hardware counters là lựa chọn kiến trúc cần phân tích, chưa là yêu cầu phát hành.
- Sửa FSM để phản ánh drain lỗi và vòng xử lý tile; không bắt buộc tách thành ba controller độc lập khi bản đầu vẫn có một command active sở hữu các array.
- Các bảng sizing/latency trong review là mô hình có giả định. Chúng hỗ trợ chọn workload và vùng thiết kế; không chứng minh timing, throughput thực hoặc chất lượng mô hình.

### Làm rõ UT-06: hai tỷ lệ causal tile khác nhau

Với tile score `t=128` và `S` chia hết cho `t`, bỏ qua các tile chỉ chứa điểm tương lai làm số tile được lập lịch còn $(n+1)/2$, với $n=S/t$. Tỷ lệ **số tile** so với lịch hình vuông đầy đủ là $(n+1)/(2n)$: 62,5% khi `S=512`, 53,125% khi `S=2048`. Đây không phải tỷ lệ MAC hữu ích.

Trong các tile còn được chạy, số cặp causal hữu ích (kể cả đường chéo) chia cho tổng ô của các tile đó là `(S+1)/(S+t)`, xấp xỉ 80,2% và 94,2% ở hai ví dụ trên. Nếu chạy cả tile tương lai, tỷ lệ MAC hữu ích so với toàn bộ lịch hình vuông xấp xỉ 50% (`(S+1)/(2S)`). Các tỷ lệ này đo công việc/ô tile, **không tự động bằng PE busy utilization**: PE có thể vẫn bận tính ô bị mask. Hàm `causal_waste()` trong `project_support/review/tensor_probes/utilization.py` nay in riêng cả ba chỉ số.

## 1. Phương pháp và mức bằng chứng

| Nhãn | Ý nghĩa |
|---|---|
| **V** | Đã chạy công cụ và quan sát kết quả |
| **S** | Suy ra từ đọc spec |
| **E** | Ước tính của người review, kèm giả định nêu rõ |

Đã làm:
- Đọc đầy đủ §1 đến §3, §5.3, §6, §8, §9, §10.2, §10.3, §13, §17, §20 của HDS và phần liên quan của tài liệu tập lệnh.
- Tính roofline, thời gian decode, hiệu suất fill/drain, tốc độ điểm số attention (`roofline.py`).
- Tổng hợp bằng Yosys và ABC các biến thể PE (nhân, tích lũy, sparse, FP32) để so độ sâu logic (`run_depth_probe.sh`). Độ sâu tính theo mức cổng 2 đầu vào, **chỉ dùng để so sánh tương đối**, không đổi được ra ps.

Không có RTL tensor để kiểm. Follow-up đã đối chiếu CV-X-IF local và CSR workbook/JSON; điều này không thay thế việc kiểm tra đường tích hợp CVA6 thực tế.

## 2. Mục tiêu TOPS và throughput

### 2.1 Kiểm tra số học (đúng)

| Đại lượng | Công thức | Giá trị |
|---|---|---|
| Đỉnh dense INT8 | 2 × 16 × 32 × 32 × 2 GHz | 65.536 TOPS |
| Tốc độ nạp toán hạng vào mảng | 16 × (32 + 32) byte × 2 GHz | 2,048 TB/s |
| Cổng DMA ứng viên | 256 bit × 2 GHz | 64 GB/s mỗi chiều |

### TP-01 (Blocker, V): trần thực tế thấp hơn đỉnh 8 lần với chính cấu hình spec chọn

Mô hình: tile đầu ra T×T giữ trong accumulator INT32, chuỗi K được stream, toán hạng INT8. Mỗi byte nạp vào cho T phép tính, nên cường độ số học AI = T phép/byte. Bảng dưới là kết quả `roofline.py` (một cổng 64 GB/s):

| Tile T | AI (phép/byte) | SRAM cần (KiB) | TOPS đạt tối đa | % đỉnh | GB/s để đạt đỉnh |
|---:|---:|---:|---:|---:|---:|
| 64 | 64 | 48 | 4,10 | 6,2% | 1024 |
| **128** | 128 | **128** | **8,19** | **12,5%** | 512 |
| 256 | 256 | 384 | 16,38 | 25% | 256 |
| 512 | 512 | 1280 | 32,77 | 50% | 128 |
| 1024 | 1024 | 4608 | 65,54 | 100% | 64 |

Điểm sizing đầu tiên của spec (§6.1: tile 128, 128 KiB) nằm đúng ở dòng in đậm: **8,2 TOPS**. Ví dụ prefill của §13 (M=1024, N=K=4096) ước tính memory roof khoảng 87 TOPS bằng giả định "mỗi toán hạng được đọc một lần"; 87 TOPS chỉ là memory roof và vượt compute ceiling 65.536 TOPS nên không phải throughput đạt được. Điều đó cần giữ nguyên ma trận A (4 MB) hoặc một tile rất lớn trên chip. Với tile 128 thì lưu lượng là 272 MB thay vì 25,2 MB, AI còn 126 phép/byte và trần là **8,1 TOPS**. Quy luật I/O của phép nhân ma trận (Hong và Kung) cho thấy AI chỉ tăng theo căn bậc hai của dung lượng SRAM: tăng SRAM 4 lần mới tăng AI 2 lần, nên hai điểm dung lượng 128 KiB và 4.608 KiB trong bảng cách nhau 36 lần. Kết quả phụ thuộc lịch tái sử dụng, traffic output và điều kiện phục vụ DRAM của từng workload.

Spec đã tự thừa nhận điều này ở §6.1 ("không claim 64 TOPS"), nhưng §13 cần phân biệt memory roof 87 TOPS với compute ceiling 65.536 TOPS, và PPA-004 vẫn gọi 64 TOPS là mục tiêu.

**Đề xuất:** thay mục tiêu "64 TOPS đỉnh" bằng bộ ba (đỉnh, TOPS duy trì ở các hình dạng tham chiếu với băng thông và SRAM đã nêu, tokens/s theo mô hình); bổ sung bảng roofline này vào §13.

### TP-02 (High, V, E): ba tài nguyên không cân bằng

Spec cho phép `PARA_ARRAY_COUNT` đến 128 trong khi băng thông và SRAM do tham số khác quyết định. Các điểm thiết kế cân bằng (đỉnh bằng trần roofline) có thể dùng làm điểm khởi đầu:

| Điểm | Array 32×32 | Đỉnh | Băng thông | Tile | SRAM đệm | TOPS đạt |
|---|---:|---:|---:|---:|---:|---:|
| A | 4 | 16,4 | 64 GB/s (một cổng) | 256 | 384 KiB | 16,4 |
| B | 8 | 32,8 | 128 GB/s (hai cổng hoặc 512-bit) | 256 | 384 KiB | 32,8 |
| C | 16 | 65,5 | 256 GB/s | 256 | 384 KiB | 65,5 |
| C' | 16 | 65,5 | 128 GB/s | 512 | 1,25 MiB | 65,5 |

Điểm A đạt hiệu suất 100% đỉnh với một cổng AXI và SRAM 384 KiB, trong khi cấu hình 16 array hiện tại chỉ đạt 12,5% đỉnh. Nếu mục tiêu sản phẩm là Llama cỡ 1B với TTFT khoảng 100 ms ở S=512 (cần 12,7 TOPS duy trì, E), điểm A đã đủ. Thêm array mà không thêm băng thông và SRAM chỉ tăng diện tích và công suất.

Băng thông 64 GB/s cũng chưa chắc có thật: cổng DMA này là manager thứ hai trên interconnect hệ thống, dùng chung DRAM với cụm CPU (§6.1). Con số 64 GB/s là trần của cổng, không phải của bộ nhớ.

### TP-03 (High, V, S): decode bị giới hạn bởi băng thông, và thiếu INT4

Với decode batch-một, mỗi tham số trọng số được đọc một lần cho 2 phép tính. Thời gian token bằng kích thước trọng số chia băng thông:

| Mô hình (INT8) | 100% băng thông | 70% băng thông | Mục tiêu spec |
|---|---:|---:|---|
| Llama-3.2-1B (1,24 GB) | 19,4 ms | 27,7 ms | < 50 ms/token (FEAT-001) |
| Llama-3.2-3B (3,21 GB) | 50,2 ms | **71,7 ms** | < 50 ms/token |
| Lớp 8B (8,03 GB) | 125,5 ms | 179,2 ms | — |

Thời gian mảng làm việc cho một token của mô hình 1B ở đỉnh chỉ là khoảng 0,04 ms, tức mảng MAC rảnh hơn 99%. Vì vậy:
- Mục tiêu "< 50 ms/token" cho Llama-3B mâu thuẫn với cổng 64 GB/s ngay cả khi không có mất mát nào.
- Spec chỉ có INT8, BF16 và FP16. LLM edge thường dùng trọng số 4 bit (INT4 hoặc FP4) để giảm một nửa lưu lượng; INT4 đưa 3B xuống 35,8 ms ở 70% băng thông. Spec không có INT4 hay FP8 (không tìm thấy từ khóa nào trong HDS).
- Điều này làm mảng 64 TOPS gần như vô dụng cho pha decode, pha mà người dùng cảm nhận. Spec đã tách metric decode khỏi TOPS (DEC-003), nhưng không đặt mục tiêu tokens/s nào.

### TP-04 (Medium, V): hiệu suất fill/drain và accumulator chưa được định nghĩa

REQ-PERF-001 nói "một MAC mỗi chu kỳ mỗi PE sau khi fill". Với mảng 32×32 output-stationary, một tile mất K + 62 chu kỳ nếu không chồng lấn fill/drain của tile kế tiếp:

| K của tile | 32 | 64 | 128 | 256 | 512 | 1024 | 4096 |
|---|---:|---:|---:|---:|---:|---:|---:|
| Hiệu suất | 34% | 51% | 67% | 81% | 89% | 94% | 98,5% |

Đạt gần 100% với K=128 cần accumulator hai bank (một bank cho tile đang tính, một bank cho tile đang drain). Chi phí flip-flop: 128 KiB cho 16 array, gấp đôi mức 64 KiB của một bank (mục MEM-002 hiện chỉ ghi `PARA_MAC_COL × PARA_ACCUM_W`). Spec không nêu có chồng lấn hay không, nên "một MAC/chu kỳ" không kiểm chứng được. Cần phát biểu lại: một MAC/chu kỳ ở trạng thái ổn định với hai bank accumulator và nêu rõ tốc độ drain (128 byte/chu kỳ/array để drain tile trong 32 chu kỳ).

### TP-05 (Medium, V, S): tốc độ phi tuyến chưa được cỡ

RV-012 đã nhận ra vấn đề nhưng chưa có số. Với exact attention, head dimension d, mỗi điểm số cần d MAC, nên ở đỉnh mảng sinh ra 16384/d điểm số mỗi chu kỳ: 128 điểm/chu kỳ với d=128, 256 điểm/chu kỳ với d=64. Mỗi điểm cần một phép exp và một phép cộng vào tổng, cộng thêm reciprocal theo hàng. Một `m_reduce` dùng chung nhiều lane piecewise-polynomial không đáp ứng; cần khoảng 128 đến 256 lane exp song song hoặc chấp nhận mảng chạy dưới 10% đỉnh khi attention. Spec chưa có `PARA_EXP_LANES`, lane count của reduction, hay mục tiêu service rate (PPA-008 là TBD).

### TP-06 (Medium, S): định nghĩa TOPS và `PARA_ARRAY_COUNT`

- 2:4 sparse với hai lane nhân mỗi PE cho "2 × số MAC mỗi chu kỳ" (PPA-009); spec đã cấm báo cáo đó như TOPS dense, tốt. Cần thêm quy ước báo cáo: TOPS đỉnh dense, TOPS duy trì trên shape tham chiếu, TOPS/W, TOPS/mm², và quy ước một phép nhân và một phép cộng bằng hai phép.
- `PARA_ARRAY_COUNT` hợp lệ đến 128 (§8) nhưng cấu hình cân bằng chỉ có ý nghĩa đến vài chục (TP-02). Nên giới hạn giá trị hợp lệ theo băng thông và SRAM đã chứng minh.

### TP-07 (Medium, E): diện tích và công suất (ước tính thô)

Giả định: nút công nghệ tiên tiến (7 nm hoặc nhỏ hơn); những con số dưới đây chỉ cho bậc độ lớn.

| Mục | Ước tính | Căn cứ |
|---|---|---|
| Flip-flop trong PE | khoảng 72 bit mỗi PE, tổng 1,2 Mbit | 8+8 bit toán hạng, 32 bit accumulator, khoảng 24 bit pipeline và điều khiển |
| Accumulator | 64 KiB (một bank), 128 KiB (hai bank), 128 KiB (carry-save) | `roofline.py` mục G |
| Công suất động của mảng | vài W đến vài chục W | 16384 MAC × 2 GHz × năng lượng mỗi MAC; spec **không có** mục tiêu công suất |
| Clock gating | **Không có** | §7.1 "no internal gating", §16 "no ICG" |

Với pha decode mảng rảnh hơn 99% nhưng toàn bộ cây clock và các flip-flop vẫn chạy, đây là công suất lãng phí lớn. Spec còn nói IP dùng chung miền nguồn với core và "không yêu cầu" power intent (§7.4), dù ngữ cảnh sản phẩm là SoC edge (§1.2). Đề xuất thêm clock gating theo array và operand isolation (kèm chân `test_en` cho ICG, §16) và đặt mục tiêu TOPS/W.

## 3. Latency

### TL-01 (High, S): không có mục tiêu số cho latency

PPA-005 (first-result và tile-completion), PPA-006 (decode), PPA-008 (phi tuyến), REQ-PERF-002 đều là "TBD" hoặc "shall report". Mô tả IP là "high-throughput, low-latency" nhưng chỉ có một con số, 64 TOPS. Đề xuất đặt mục tiêu theo mô hình chuẩn (đề xuất để chủ dự án xác nhận):

| Chỉ số | Cách tính | Gợi ý mục tiêu (cần xác nhận) |
|---|---|---|
| Tokens/s decode Llama-3.2-1B INT8 | băng thông hiệu dụng / 1,24 GB | ≥ 36 tok/s ở 70% của 64 GB/s |
| TTFT prefill S=512, 1B | 1,27 TOP / TOPS duy trì | ≤ 100 ms cần ≥ 12,7 TOPS duy trì |
| First-result latency của một GEMV 2048×2048 (4 MB trọng số) | 4 MB / băng thông | khoảng 65 µs ở 100% (bị chi phối bởi bộ nhớ) |
| Accept-to-result của lệnh nhỏ (softmax một hàng, argmax) | descriptor + dữ liệu + tính | vài µs, bị chi phối bởi latency AXI |

### TL-02 (High, S): FSM điều khiển là tuần tự và lỗi thời so với văn bản

FSM trong §10.1 là `IDLE → DECODE → FETCH → COMPUTE → POST → WRITEBACK → IDLE`, và `WRITEBACK` chỉ về `IDLE` khi `result_ready`. Hệ quả:
- Lệnh kế tiếp không bắt đầu FETCH trước khi lệnh trước **được host nhận kết quả**, nên latency chấp nhận kết quả của CVA6 nằm trực tiếp trên đường tới hạn của decode.
- Spec yêu cầu hàng đợi và prefetch descriptor kế tiếp (§10.2.1), nhưng FSM không có trạng thái nào cho chồng lấn FETCH, COMPUTE, WRITEBACK, và DEC-006 xác nhận "cross-command overlap" chưa có trong bản đầu.
- `ERROR` chỉ vào được từ `DECODE` (illegal op). Văn bản (DEC-012, REQ-ERR-001) yêu cầu lỗi AXI, NaN, descriptor xảy ra trong FETCH và COMPUTE, dừng tile mới, drain, rồi mới hoàn tất. FSM không có đường này, nên hình đã **lỗi thời** so với văn bản.

Đề xuất: tách bộ điều khiển thành ba máy độc lập (descriptor/DMA, tính, writeback/kết quả) nối bằng hàng đợi, kèm FIFO kết quả để `result_ready` không chặn tính; sửa FSM theo DEC-012.

### TL-03 (Medium, S, E): chi phí lệnh trên đường dữ liệu không coherent

Descriptor và dữ liệu được DMA đọc không qua cache. Phần mềm phải clean/invalidate (§6.1). Với cụm CVA6 của repo (line 16 byte, một controller CMO tuần tự, xem review cluster), một descriptor 128 byte cần 8 lệnh `cbo.clean`, mỗi lệnh đi qua CCU và LLC; một vector 8 KiB cần 512 lệnh. Với khoảng 200 lệnh mỗi token ở decode, phần này là chi phí CPU đáng kể và không được tính trong mục tiêu latency nào. Spec nên định nghĩa descriptor trong vùng non-cacheable hoặc đường ghi qua, và cần cổng ACE-Lite nếu muốn bỏ CMO (cluster đã hoãn ACE).

### TL-04 (Medium, E): pipeline cut ít tốn latency hơn spec lo ngại

§13 viết "pipeline chèn có thể làm xấu latency batch-một". Ở 2 GHz mỗi tầng thêm 0,5 ns. Một lệnh decode có latency bị chi phối bởi AXI (hàng trăm ns tới µs) và thời gian đọc trọng số (hàng chục µs đến ms). Thêm 10 tầng pipeline là 5 ns, dưới 1% của một GEMV nhỏ. Do đó spec nên thiên về **nhiều tầng hơn** và coi giới hạn tần số là ràng buộc chính, chỉ giữ đường latency ngắn cho vòng phản hồi (accumulator, argmax merge) và cho handshake CV-X-IF.

### TL-05 (Low, S): overhead mỗi lệnh

Bubble giữa hai lệnh (drain mảng, handshake kết quả, descriptor, DRAM đầu tiên) khoảng 0,3 µs (E). Với khoảng 200 lệnh mỗi token, tổng là khoảng 60 µs, dưới 0,3% của 20 ms. Không phải nút thắt cho mô hình cỡ Llama, nhưng quan trọng hơn với mô hình nhỏ hoặc ViT với nhiều lệnh nhỏ.

## 4. Timing closure và khả năng chèn pipeline

### 4.1 Những gì spec cung cấp

Năm cut nhị phân (`PARA_PIPELINE_INPUT_EN`, `_MUL_EN`, `_EPILOGUE_EN`, `_POST_EN`, `_MEM_EN`), mỗi cái chèn đúng một tầng; **không có** cut cho PE forwarding và vòng phản hồi accumulator (cố định). Giá trị mặc định toàn IP còn TBD; CFG-64TOPS ghi cả năm bằng 1 như một profile timing-oriented candidate, chưa có STA chứng minh. Thiết kế "bypass là kết nối hằng số lúc generate, không có mux lúc chạy" là đúng và nên giữ.

### TT-01 (Blocker cho 2 GHz, V): vòng tích lũy là đường sâu nhất, và nó "cố định"

`run_depth_probe.sh` (Yosys và ABC, mức cổng 2 đầu vào, so sánh tương đối):

| Cấu trúc | Độ sâu | Ghi chú |
|---|---:|---|
| Nhân INT8 đứng riêng | 29 | |
| Vòng accumulator 32 bit carry-propagate | **48** | sâu hơn bộ nhân |
| Vòng accumulator 64 bit (`PARA_ACCUM_W=64`) | **80** | giá trị hợp lệ theo §8 |
| Vòng accumulator carry-save (3:2 compressor) | **4** | |
| `pe_v1`: nhân và tích lũy cùng một tầng | 61 | không dùng cut MUL |
| `pe_v2`: thanh ghi tích (cut MUL), tích lũy carry-propagate | 48 | cut MUL giảm 21% |
| `pe_v3`: thanh ghi tích, tích lũy carry-save | 29 | bị giới hạn bởi bộ nhân |

Nếu `pe_v1` vừa đủ ở tần số f0 thì `pe_v2` đạt khoảng 1,27 f0 và `pe_v3` khoảng 2,1 f0 (61/48 và 61/29). Nghĩa là: cut `MUL` của spec chỉ mua khoảng 27% tần số; **vòng accumulator cố định chặn phần còn lại**. Để tới 2 GHz cần:

1. Tích lũy ở dạng carry-save hoặc redundant (hai thanh ghi sum và carry cho mỗi PE), chuyển về dạng nhị phân bằng một bộ cộng pipeline dùng chung theo cột khi drain. Chi phí: +64 KiB flip-flop và khoảng +16% cell trong thí nghiệm trên (726 so với 625 cell).
2. Hoặc chạy hai tổng riêng xen kẽ (interleave) cho các output khác nhau, để vòng có thể có hai tầng. Cách này cần K-split hoặc hai output mỗi PE.

Spec nói rõ "vòng accumulator không chỉnh được" và "tránh rủi ro throughput này" (§8.1). Nên sửa thành "vòng accumulator được hiện thực dạng carry-save" và coi đó là yêu cầu.

`PARA_ACCUM_W` = 48 hoặc 64 (hợp lệ theo §8) làm vòng sâu 80 mức, không thể đạt 2 GHz nếu không có carry-save. Đây là tổ hợp tham số hợp lệ nhưng không thể ký timing.

### TT-02 (High, V): lane sparse ghép đôi cần nhiều cut hơn một

| Cấu trúc | Độ sâu |
|---|---:|
| `pe_v4`: gather 4:1, hai bộ nhân, cộng tích, tích lũy, một tầng | 70 |
| `pe_v5`: cut sau gather và cut sau bộ cộng tích | 49 |

Đường sparse dài hơn dense (70 so với 61). Spec chỉ có **một** cut "multiplier hoặc paired-product-combine" dùng chung. Cần ít nhất ba điểm cut độc lập: sau chọn activation, sau bộ nhân (carry-save), sau bộ cộng tích.

### TT-03 (High, V): tích lũy FP32 không thể một chu kỳ ở 2 GHz

Vòng cộng FP32 (căn lề, cộng, đếm số 0 đầu, chuẩn hóa, làm tròn) có độ sâu 114 trong hiện thực chưa tối ưu, gấp 2,4 lần vòng INT32. Bản tối ưu thật có thể tốt hơn nhưng vẫn cần ít nhất hai đến ba tầng, tức II bằng 2 đến 3 nếu một output chỉ có một accumulator. Spec cho BF16 và FP16 với "accumulate FP32" (§9) nhưng REQ-PERF-001 chỉ cam kết INT8 và nói throughput FP "báo cáo riêng". Để có một MAC/chu kỳ ở FP cần: accumulator xen kẽ nhiều output, hoặc FP MAC kiểu chuẩn hóa trễ, hoặc accumulator cố định (kiểu Kulisch hẹp) với căn lề một lần. Hiện spec không chọn.

### TT-04 (High, S): các đường dài còn thiếu cut

Danh sách các đường có khả năng vi phạm timing ở 2 GHz (E) và độ phủ của spec:

| Đường | Vì sao dài | Số tầng có thể cần (E) | Tham số hiện có | Khoảng trống |
|---|---|---|---|---|
| Phân phối điều khiển (mode, precision, valid) đến 16384 PE | fan-out lớn | cây đệm 4 đến 6 tầng | Không | Cần tham số cây phân phối và pipeline điều khiển theo hàng |
| Mạng nạp SRAM tới array (1 KiB/chu kỳ, 16 array, lưới 4×4) | dây dài giữa các array | 1 đến 3 tầng theo khoảng cách | `PARA_PIPELINE_MEM_EN` (một tầng, ở phía phản hồi bộ nhớ) | Không có cut cho mạng nạp |
| Đọc SRAM macro | thời gian truy cập macro ở 2 GHz | 2 đến 3 tầng | MEM-001 giả định độ trễ đọc 1 | Giả định không thực tế ở 2 GHz |
| Gather activation cho sparse | mux và dây | 1 | Không | Xem TT-02 |
| Cây reduction (max, sum, argmax merge) qua 16 array | cây rộng | 1 tầng mỗi 1 đến 2 mức | Không | Cần cut mỗi mức cây |
| Cây exp, rsqrt, reciprocal | đa thức nhiều bước | đã "pipelined" | Số tầng chưa nêu | Cần số tầng và độ chính xác |
| Handshake CV-X-IF | `issue_ready` và `register_ready` tổ hợp từ giải mã lệnh | 0 (phải trong cùng chu kỳ) | Không | Đường vào tới ra qua biên IP, xem TI-01 |
| Đường drain accumulator tới epilogue | chuyển carry-save về nhị phân | 1 đến 2 | `PARA_PIPELINE_EPILOGUE_EN` | Một tầng có thể chưa đủ |

### TT-05 (High, S): chưa có cơ chế điều khiển dòng cho các tầng được chèn

Spec nói mỗi tầng giữ dữ liệu, chế độ, tọa độ, ID cùng nhau và "backpressure không được làm rơi hoặc nhân đôi tile", nhưng không nêu **cơ chế**. Nếu dùng valid/ready thuần, tín hiệu ready chạy ngược qua mọi tầng thành một đường tổ hợp dài, rồi fan-out đến 16K PE: chính là đường tới hạn mà việc chèn tầng định giải quyết. Đề xuất:
- Mảng systolic **không có stall nội bộ**: chạy tự do, lượng dữ liệu đầu vào được đệm ở phía trước và điều khiển bằng credit tại biên mảng. Một tầng là một thanh ghi valid-và-dữ liệu, không có ready.
- Ở những chỗ cần backpressure (DMA, epilogue, kết quả) dùng tầng skid buffer hai chỗ có ready được đăng ký, tách đường ready khỏi đường dữ liệu. Chi phí cho mạng nạp: khoảng 8192 flip-flop mỗi tầng, nhân hai nếu skid (E).
- Một module pipeline dùng chung (`m_pipe_stage`) được tham số hóa theo số tầng, thay cho từng cut tùy biến.

### TT-06 (Medium, S): tham số nhị phân và ma trận kiểm chứng

- 0/1 chỉ cho đúng một tầng; ở 2 GHz nhiều chỗ cần 2 đến 3 (TT-04). Đề xuất `PARA_PIPE_*_STAGES` là số nguyên 0 đến N cho từng nhóm đường (operand, nhân, gather, nạp mạng, SRAM đọc, cây reduction, epilogue, kết quả).
- Spec đếm 4096 tổ hợp thô (§8.1) và đề nghị chỉ phát hành những cấu hình đã qua STA. Giải pháp bền hơn: thiết kế latency-insensitive (mọi tầng là phần tử đàn hồi), dùng một mô hình tham chiếu có độ trễ tùy ý và kiểm tra scoreboard theo giá trị, không theo chu kỳ; formal chỉ kiểm từng loại tầng (skid, credit), không kiểm 4096 tổ hợp.
- Thanh ghi dữ liệu của pipeline nên **không reset** (chỉ reset valid) để giảm diện tích và tải reset; cần kiểm tra REF-003 (VLSIT RTL Design Rules v2) về reset cho flip-flop dữ liệu và ghi quy tắc này vào spec.

### TT-07 (High, S): clock dùng chung với CVA6

CLK-CORE là clock của core CVA6, "danh định 1 đến 2 GHz" (§7.1), một miền duy nhất cho CV-X-IF, mảng và AXI. CFG-64TOPS đặt 2 GHz là "ràng buộc hệ thống". Nhưng CVA6 là lõi in-order; bài báo CVA6S+ (arXiv:2505.03762) báo cáo khoảng 1,09 GHz cho CVA6 với HPDcache ở GF22 (cấu hình RV32, số liệu của họ, không phải của repo này). Ép cả cụm CPU lên 2 GHz sẽ làm timing core khó hơn mà không làm mảng tensor nhanh hơn. Đề xuất tách miền clock mảng tensor khỏi miền CV-X-IF:
- Hàng đợi lệnh (`m_cvxif_adapter`) là điểm cắt tự nhiên (FIFO bất đồng bộ hoặc tỷ lệ clock 1:2 đồng bộ).
- Chi phí: vài chu kỳ đồng bộ trên đường lệnh và kết quả, không đáng kể so với TL-04.
- Lợi ích: CVA6 và CV-X-IF chạy ở tần số vốn có của chúng; mảng chạy ở 2 GHz với đủ pipeline; clock gating theo miền dễ hơn.

### TT-08 (Medium, S): SRAM

MEM-001 giả định đọc 1 chu kỳ, cổng đơn, rộng 32 bit (§10.5), không khớp nhu cầu 1 KiB mỗi chu kỳ. Nếu mỗi macro có cổng đọc 256 bit ở xung nhịp core thì cần ít nhất 32 cổng đọc chỉ cho đường A/B (`roofline.py` mục H), chưa kể ghi và drain. Cần: đọc pipeline 2 đến 3 tầng, bố trí banked theo array, xác định xung đột bank, hoặc dùng register file hoặc latch array cho các buffer nhỏ.

### TT-09 (Medium, S): §17 chỉ là khung

Mục 17 chỉ có chỗ giữ chỗ (SDC của integrator, "MAC-array bounded"). Thiếu ngân sách timing theo tầng, thư viện và corner mục tiêu, uncertainty, chiến lược phân cấp (harden một array rồi nhân bản theo abutment), CTS cho 16K PE, sửa hold cho chuỗi thanh ghi dịch của mảng systolic, đường scan (scan chain qua 16K PE), IR drop và mật độ công suất. Đây là lý do việc "resolve timing violation" hiện chưa có quy trình. Nên thêm bảng ngân sách theo tầng (gồm độ sâu mục tiêu, tầng đặt cut) và quy định hardening ở mức array.

## 5. Tích hợp và đồng bộ với cluster

### TI-01 (High, S): cluster hiện tắt CV-X-IF

Spec cluster (REQ-SYS-004, TEST-034) yêu cầu bản cấu hình CVA6 đặt `CVA6ConfigCvxifEn=0` và "cluster không phơi cổng CV-X-IF". Spec tensor gắn vào CVA6 qua CV-X-IF và tham chiếu cluster 2/4 hart làm ngữ cảnh sản phẩm (REF-002). Hiện chưa có đường nối:
- Phải bật lại CV-X-IF trong bản copy CVA6 và đưa ra một CV-X-IF cho mỗi hart.
- IP tensor có một giao diện CV-X-IF duy nhất (`hartid` chỉ là một trường dữ liệu) nên cần bộ trọng tài và định tuyến kết quả theo hart, bảo toàn thứ tự theo từng hart, và bảo đảm không deadlock khi hàng đợi đầy (CV-X-IF yêu cầu đảm bảo tiến triển).
- Quy tắc commit và kill theo từng hart cần được trình bày cho trường hợp nhiều hart cùng gửi lệnh.
- `o_xif_issue_ready` và `o_xif_register_ready` "tổ hợp từ việc chấp nhận" (§6.2): đường giải mã lệnh của host sang chấp nhận của IP nằm trong cùng chu kỳ ở biên IP, cần được ngân sách hóa (TT-04).

### TI-02 (Medium, S): kênh DRAM dùng chung

Cổng DMA là manager thứ hai trên interconnect hệ thống. Băng thông thật là phần còn lại sau CPU, màn hình, ISP; QoS (`AxQOS` "TBD" §6.2) cần để giữ decode đạt mục tiêu. Nên đặt băng thông tối thiểu bảo đảm cho IP trong spec, không phải trần của cổng.

### TI-03 (Critical, V/S): host commit có thể đánh dấu lệnh speculative là đã committed

CV-X-IF REF-001 §5.5.8 định nghĩa non-kill commit là lời bảo đảm của CPU rằng lệnh được nêu và mọi lệnh trước nó sẽ không còn bị hủy, kể cả do misprediction hoặc exception của lệnh trước. REF-001 cũng nói lệnh được accept trên issue vẫn có thể speculative. User chọn split=0 chỉ cho phép ghép issue/register handshake; nó không đổi nghĩa commit.

Trong repo, `cvxif_issue_register_commit_if_driver.sv:57–64` phát `commit_valid_o = issue_valid_o && issue_ready_i` và buộc `commit_kill=0`; instance được gắn trong `issue_read_operands.sv:236–255`, tức issue path, không phải commit stage. Comment của driver thừa nhận giả định “speculation in execute is not possible” chưa được xác minh. Do đó, cùng chu kỳ nhận command cũng có thể thông báo với accelerator rằng command không thể bị hủy, trong khi CVA6 vẫn có cơ chế flush/cancel theo branch và exception.

Tình huống kiểm chứng bắt buộc: một lệnh load cũ còn chờ phản hồi; lệnh tensor trẻ hơn được accept. Nếu load cũ sau đó báo exception, host phải kill lệnh tensor trước khi commit an toàn; accelerator không được tạo descriptor/tensor DMA, output write, hoặc result. Người dùng đã chọn phương án A cho DEC-033 và fault-resolved frontier cho DEC-034: giữ acceptance/capture sớm, nhưng chỉ phát non-kill commit khi mọi lệnh cũ không phải CV-X-IF đã hết khả năng exception/redirect; tracker được đi qua lệnh tensor cũ đã non-kill-commit dù result còn pending. Proof phải kết hợp scoreboard kết quả/exception, branch resolution, LSU translation/protection/access faults, CSR/commit-stage exceptions và fence/controller flush; `scoreboard_entry_t.valid` không đủ. Interrupt/debug là sự kiện toàn cục: trap arbiter phải ưu tiên sự kiện đã chọn trước hoặc cùng chu kỳ authorization; sau authorization, command không bị kill/mất result. DEC-035 đã chọn A: latch event, dừng issue/authorization lệnh trẻ hơn trên hart đó, drain/retire các command authorized rồi mới vào handler; không chặn hart khác. DEC-033/034/035 đã chọn về frontier và ngắt; source mapping, sửa host driver, verification và worst-case interrupt latency vẫn là P0/DEC-018; không dùng driver issue-time hiện tại nguyên trạng trong tensor top.

## 6. Số học và chất lượng spec

### TS-01 (Medium, S): bản 64 TOPS là INT8 thuần nhưng bật mọi họ thuật toán

CFG-64TOPS trước đây ghép `PARA_DATA_PREC=0` (chỉ INT8) với `PARA_ALGORITHM_MASK=0x7F`, khiến một số họ attention/softmax/layer norm không có precision pair hợp lệ. Bản review đã sửa profile này thành `PARA_DATA_PREC=1`: đỉnh 65.536 TOPS vẫn được tính từ INT8, còn BF16/FP16 datapaths hiện diện cho các họ cần FP. Điều đó chưa đóng numeric contract: §9.1 vẫn yêu cầu ít nhất một pair release-qualified cho mỗi family trước khi all-family profile được phép elaboration. DEC-053/054 đã chốt semantics và encoding requantization INT8: scale activation chung, weight scale theo output channel, Q31 multiplier/signed exponent, nearest-even và saturate [-128,127]. DEC-055 đã chốt activation order INT8/FP32. Các điểm số học đó nay đã được đóng trong DEC-056/059/060: BF16/FP16 output rounding, FP32 intermediates, exp/rsqrt/reciprocal bounds, và fixed Welford order. Còn phải sign-off độ chính xác mô hình, PPA/Fmax và bộ nhớ; CFG-64TOPS vẫn chỉ là candidate vì chưa có RTL, synthesis hay STA evidence. CFG-64TOPS hiện chỉ là candidate; chưa có RTL, synthesis hay STA evidence.

### TS-02 (Medium, S): giá trị mặc định cut là TBD

§8 để default toàn IP của năm `PARA_PIPELINE_*_EN` là "TBD"; CFG-64TOPS đặt chúng bằng 1 như candidate, còn CFG-BASE bypass. Đây không phải timing signoff: cần STA trên từng build/profile và bảng ghi pipeline cuts đã qua equivalence/timing với clock, latency, II, area, power và utilization đo được.

### TS-03 (Low): các điểm khác

| Điểm | Chi tiết |
|---|---|
| Kích thước | HDS có nhiều đoạn dài một dòng; khó review và dễ lệch giữa văn bản, hình và bảng (xem TL-02) |
| Waveform | WF-011 đến WF-015 đã được xác nhận và có lịch chu kỳ minh họa; lịch không phải latency contract |
| FSM | Hình `ctrl_fsm` đã cập nhật để thể hiện vòng tile và error-drain; cần đối chiếu RTL sau khi có implementation |
| Tốt | Phân tách rõ yêu cầu, quyết định (DEC), rủi ro (RV-001 đến RV-016); RV-001, RV-002, RV-012, RV-016 đã nêu đúng các vấn đề lớn; nhiều chi tiết ABI (opcode, descriptor) rõ ràng |

### TS-04 (Đã giải quyết ở spec; verification còn):

DEC-021 đã chốt global scalar fence. Driver giữ global submission lock, đợi busy=0 và clear lỗi cũ; hardware kiểm tra command/result/AXI/error boundary sạch rồi đồng thời nhận OP-003 và chặn issue mọi hart bằng backpressure. Fence chặn lệnh tensor khác trong toàn bộ thời gian OP-003 chạy đến result handshake. Lệnh trả khác 0 nhả fence ở result handshake; lệnh trả 0 giữ busy/fence thêm đến khi software đọc err_valid, đọc/W1C-clear record nếu có, ghi scalar_ack và đợi busy=0. Nhờ vậy CSR attribution không còn dựa vào transaction ID; err_valid không thể bị lệnh trẻ hơn ghi đè. Còn phải hiện thực và kiểm chứng đa hart, kill, result backpressure, W1C/ack CDC, stale ack và quiesce (TEST-025/SVA-009/COV-006).

### TS-05 (Đã chốt kiến trúc; verification còn): CV-X-IF không mang privilege

CV-X-IF issue packet có `instr`, `hartid`, `id`, nhưng không có privilege, ASID hoặc PID. Vì tensor DMA là AXI manager riêng, CPU PMP/MMU không tự động bảo vệ địa chỉ descriptor/tensor. Đã chốt DEC-027: tại CVA6, chỉ S/M được issue các operation ID tensor; U-mode bị trap illegal instruction cause 2 trước CV-X-IF, không tạo request hay side effect. Theo DEC-030, ứng dụng U-mode gọi S-mode driver bằng operation request và opaque buffer handles/offsets; driver xác minh ownership, kích thước, stride, span, alias, physical contiguity và aperture bounds, rồi tạo descriptor DMA-visible do kernel quản lý. Driver giữ ownership và cache-maintenance contract đến khi DMA/result hoàn tất; U-mode không đọc CSR chứa địa chỉ lỗi. Không thêm sideband vào CV-X-IF. DEC-031 đã chọn aperture cố định theo SoC build; phần còn lại là xác minh gate/driver, đối chiếu BASE/LIMIT giữa firewall và driver, chốt giá trị/permissions và CSR mapping; descriptor body layout đã cố định theo DEC-065. Driver/OS là trusted computing base; firewall không cô lập S-mode kernel code. DEC-032 đã chốt response `SLVERR`/framing dựa trên Arm IHI 0022H; firewall placement, aperture values/permissions và end-to-end verification vẫn là tích hợp SoC.

## 7. Đề xuất và backlog

| Ưu tiên | ID | Việc cần làm | Tiêu chí hoàn tất |
|---|---|---|---|
| P0 | TP-01, TP-02 | Giữ 64 TOPS là peak GEMM/prefill lý tưởng; bổ sung throughput duy trì tại shape tham chiếu, băng thông/SRAM và decode latency/tokens/s | §13 tách peak khỏi measured/sustained target; `PARA_ARRAY_COUNT` được đánh giá với roofline và workload đã chọn |
| P0 | TT-01 | Bắt buộc tích lũy carry-save (hoặc chứng minh vòng tích lũy đạt chu kỳ mục tiêu); loại bỏ tổ hợp `PARA_ACCUM_W` 48 và 64 ở 2 GHz khi không có carry-save | Bảng độ sâu theo tầng; PE tham chiếu qua synthesis với thư viện thật |
| P0 | TT-03 | Chọn kiến trúc tích lũy FP (xen kẽ hoặc chuẩn hóa trễ hoặc cố định) và phát biểu throughput FP | REQ-PERF-001 mở rộng cho BF16 và FP16 hoặc nêu rõ II |
| P0 | UT-01, 8.4 | Chọn số array theo `băng thông × M_ref` và khối lượng chính; ghi vào §8 và §13 | Bảng cỡ phần cứng và M_ref trong spec |
| P1 | UT-02, UT-03, UT-04 | Đo host issue gaps, descriptor/tile prefetch và double-buffer scheduling trong ABI CV-X-IF đã chọn; command ring/doorbell/`TC_SUBMIT` chưa được chấp nhận | Mô hình chỉ đề xuất batching/prefetch nếu giữ commit/kill, error attribution và memory-safety contract |
| P0 | TT-07 | Tách miền clock mảng khỏi CV-X-IF | §7.1 và §7.2 có miền mới và CDC |
| P0 | DEC-016 / TI-01 | Triển khai top tensor riêng đã chọn, chứa CV-X-IF-enabled CVA6 nối tới tensor; giữ nguyên `m_vlsit_riscv_cluster_axi_top` | Chốt CVA6 source/config, số hart/endpoint, issue/register/commit/kill routing với split=0, arbitration/queue progress, reset và memory interconnect; xác minh command reachability end-to-end |
| P0 | REQ-ERR-004 / DEC-021 | Hiện thực và sign-off global fence, clean-boundary admission, CSR scalar_ack và driver lock của OP-003 | Valid-zero/error-zero phân biệt được trong mọi interleaving đa hart; kiểm thử TEST-025, SVA-009, COV-006 qua CDC/kill/quiesce |
| P0 | DEC-024 | Hiện thực profile issue/register ghép `X_ISSUE_REGISTER_SPLIT=0`; chụp descriptor pointer chỉ khi các `rs_valid` cần thiết và ready handshake cùng thỏa | RV32/RV64 source-mask, missing/partial `rs_valid`, queue-full backpressure, pointer capture đúng một lần và no-early-DMA được kiểm thử; không test register reorder ở release profile |
| P0 | DEC-033 | Implement per-hart irrevocability frontier in CVA6: delay non-kill commit until the command and every still-killable older instruction are safe; do not wait for the current tensor result, and allow the frontier to pass older tensor commands already non-kill committed so N+1 can overlap N. Send a kill boundary on squash and prohibit issue-cycle non-kill commit in this profile | Core-level test with older delayed-load exception, branch mispredict/flush, accepted/rejected issue, N+1 prefetch overlap, queue pressure and multi-hart proves no DMA/result/output side effect before safe commit and no kill after commit; host driver TODO closed by RTL/test evidence |
| P0 | DEC-025 detail / DEC-030/031/032 | Triển khai firewall aperture và response contract đã chọn; hiện thực/xác minh CVA6 gate và S-mode driver theo REQ-SEC-001/002; firewall không bảo vệ khỏi S-mode kernel code độc hại | U-mode trap + driver validation/no-side-effect được xác minh; BASE/LIMIT constants được đồng nhất giữa SoC firewall và driver; actual aperture values/permissions/fault/CSR/zeroization, firewall placement, and end-to-end `SLVERR` framing remain integration signoff |
| P0 | DEC-028 | Hiện thực và xác minh IF-004 đã chốt: reset controller giữ host/fabric hoạt động, chờ `o_quiesce_ack`, rồi mới reset tensor; đồng bộ level nếu khác clock | Functional reset chỉ xóa command/ID state sau mọi result, OP-003 scalar ack, và AXI response drain; không local abort/isolation |
| P0 | DEC-029 | Tích hợp timeout recovery đã chọn: full SoC reset duy nhất khi watchdog bắt missing `R/B`; chốt threshold/owner, reset coverage/release, reset-cause capture và software restart | Mọi hart, tensor và on-SoC transaction state được reset; lệnh CV-X-IF đang chạy không trả result; output dở invalid; không có local abort/isolation/timeout status |
| P1 | DEC-026 | Hiện thực committed-only descriptor prefetch trong khi command trước đang compute | TEST-022/COV-005 chứng minh không có request trước register capture/non-kill commit, có overlap khi tài nguyên cho phép, và fault của queued command giữ đúng `(hartid,id)` |
| P1 | TT-04, TT-05, TT-06 | Thay 5 cut nhị phân bằng các nhóm cut nguyên (số tầng), cơ chế credit và skid, module pipeline dùng chung | §8 có tham số mới; mô tả giao thức giữa các tầng |
| P1 | UT-05, UT-06, UT-07 | Nhóm array độc lập, split-K và split-N, bỏ qua tile che hoàn toàn, nonlinear song song với MAC | REQ-UTIL-003, 005 đạt trong mô hình |
| P1 | UT-08, UT-09 | Nhân đôi băng thông nạp cho sparse hoặc ghi rõ không tăng tốc; bộ đếm hiệu năng và CSR | REQ-UTIL-004, 006 |
| P1 | TT-02 | Thêm cut cho gather và bộ cộng tích của sparse | Bảng đường và cut |
| P1 | TL-01, TL-02 | Đặt mục tiêu số cho latency và tokens/s; tách FSM thành ba máy, FIFO kết quả, sửa đường lỗi theo DEC-012 | PPA-005, 006, 008 có số; FSM mới khớp văn bản |
| P1 | TP-03 | Thêm INT4 (hoặc FP8) cho trọng số, kèm requantization | Mục §9 và REQ mới |
| P1 | TP-05 | Cỡ số lane exp và reduction theo tốc độ điểm số của mảng | Bảng lane và service rate (PPA-008) |
| P2 | TT-08, TT-09 | Cỡ SRAM và đọc pipeline; viết §17 thật (ngân sách tầng, hardening, CTS, hold, scan) | Ngân sách timing có số |
| P2 | TP-07 | Clock gating theo array, operand isolation, mục tiêu TOPS/W | Mục §7.4 và §13 |
| P2 | TL-03 | Định nghĩa bộ nhớ descriptor non-cacheable hoặc ACE-Lite | Hợp đồng bộ nhớ trong spec |
| P3 | TS-01, TS-02 | Làm rõ số học INT8 cho phi tuyến; điền mặc định cut | Bảng cấu hình tham chiếu |

## 8. Sử dụng phần cứng: tại sao mảng tensor sẽ rảnh, và phải làm gì

Đây là phần review sâu về việc để mảng tính toán không rảnh phần lớn thời gian. Số liệu nằm trong `project_support/review/tensor_probes/utilization.py` (Phụ lục A). Nhãn bằng chứng như §1.

### 8.1 Gốc rễ: tỷ lệ 512 MAC trên mỗi byte (UT-01, Blocker, V)

Đỉnh của mảng là 32,77 TMAC/s, còn cổng DMA chỉ cấp 64 GB/s. Để mọi PE bận, mỗi byte trọng số đọc từ DRAM phải được dùng cho **512 phép MAC**. Với trọng số INT8, một byte trọng số được dùng M lần khi có M hàng (token hoặc batch) dùng chung, nên:

| M (hàng dùng chung trọng số) | Hiệu suất MAC tối đa, INT8 | INT4 | Tình huống |
|---:|---:|---:|---|
| 1 | 0,20% | 0,39% | decode batch-một |
| 4 | 0,78% | 1,56% | verify 4 token nháp (speculative) |
| 8 | 1,56% | 3,12% | batch nhỏ, nhóm query GQA |
| 64 | 12,5% | 25% | chunk prefill ngắn |
| 256 | 50% | 100% | |
| 512 | 100% | 100% | prefill 512 token (và cần SRAM lớn, TP-01) |

Hệ quả:
- **Tăng số array không làm mảng bận hơn** trong decode, vì lượng dữ liệu đến chỉ đủ nuôi khoảng 32 MAC mỗi chu kỳ (32 B/chu kỳ ở 64 GB/s, 2 GHz), tức một hàng của một array trong 16384 PE.
- Với một phiên chat (prompt 512 token, sinh 256 token, mô hình 1,24 tỷ tham số INT8, 70% hiệu suất DRAM): prefill 155 ms, decode 7,09 s. **Hiệu suất MAC trung bình cả phiên là 0,40% của 65,5 TOPS.** Prefill chỉ chiếm 2,1% thời gian; 97,9% còn lại mảng chạy ở khoảng 0,14% đỉnh.
- Ngay cả nếu prefill đạt compute peak lý tưởng 65.536 TOPS, trung bình chỉ lên 0,41%.

Vì vậy "không để mảng rảnh" không thể giải bằng lập lịch đơn thuần; phải kết hợp **đúng kích thước** phần cứng với **tăng tái sử dụng** và **đo đúng thước đo**. Đòn bẩy theo thứ tự hiệu quả:

| # | Đòn bẩy | Tác dụng lên utilization | Chi phí |
|---|---|---|---|
| 1 | Chọn số array theo `băng thông × M_ref` thay vì theo đỉnh mong muốn | Bằng 100% ở M_ref thiết kế (xem 8.4) | Giảm diện tích và công suất |
| 2 | Tăng M hiệu dụng: batch nhiều chuỗi, speculative decoding, nhóm query GQA, nhiều luồng đồng thời | M tăng 4 đến 16 lần, utilization tăng cùng tỷ lệ | Phần mềm runtime và ABI hỗ trợ M nhỏ đến vừa |
| 3 | Giảm byte mỗi MAC: trọng số INT4 hoặc FP8, 2:4 sparse, KV-cache INT8 | Gấp đôi utilization ở cùng băng thông, và giảm thời gian token | Thêm định dạng và dequantize trong DMA |
| 4 | Chạy đồng thời prefill (nhiều tái sử dụng) với decode (nhiều băng thông) trên các nhóm array khác nhau | Lấp phần tính toán rảnh bằng công việc khác | Nhóm array độc lập, QoS DMA (8.3) |
| 5 | Tắt clock hoặc nguồn phần không dùng | Không tăng utilization nhưng loại bỏ lãng phí công suất | Clock gating theo nhóm array |

### 8.2 Các nguyên nhân cấu trúc trong spec

**UT-02 (High, S): chỉ một command sở hữu toàn bộ array, và FSM tuần tự.** §5.4 và §10.4: "một command sở hữu mọi array đến khi hoàn tất; chồng lấn command và FETCH/COMPUTE/WRITEBACK là tối ưu hóa tùy chọn (DEC-006)". Cụ thể:
- Phần đuôi của command (tile cuối chạy ít hơn số array, drain accumulator, ghi kết quả) làm các array rảnh trong khi command kế tiếp đã xếp hàng.
- DMA không chạy trước sang command kế tiếp. Trong decode, DMA mới là tài nguyên khan hiếm, nên mỗi khe hở giữa hai command là băng thông mất vĩnh viễn.
- Trọng số không phụ thuộc dữ liệu; chỉ activation mới phụ thuộc kết quả của command trước. Spec không tách hai loại nạp.

**UT-03 (High, S): ngữ nghĩa kết quả của CV-X-IF và commit theo thứ tự của CVA6 khiến hàng đợi sâu gần như vô dụng.** Spec yêu cầu mỗi lệnh trả đúng một kết quả **sau khi toàn bộ B response ghi đã nhận** (§6.3). CVA6 retire theo thứ tự, và store chỉ hiển thị sau khi các lệnh cũ hơn retire. Do đó:
- Trong khi một lệnh tensor dài còn đang chạy (có thể hàng trăm µs), các lệnh store của descriptor kế tiếp **chưa commit**, nên DMA chưa thể đọc descriptor mới.
- Scoreboard CVA6 chỉ 8 mục (`NrScoreboardEntries=8`), nên tối đa khoảng 7 lệnh trẻ hơn đang chờ.
- Hệ quả: nếu phần mềm xây descriptor từng lệnh rồi mới phát hành (cách tự nhiên), hàng đợi sâu 2 đến 4 không được dùng; arrays chờ CPU. Mô hình (A: 1 µs CPU mỗi lệnh gồm store descriptor, 8 `cbo.clean` và result): lệnh dài 1 µs đạt 50%, 4 µs đạt 80%, 10 µs đạt 91%. Muốn đạt 100% phải **dựng sẵn cả danh sách descriptor và clean một lần**, rồi phát hành liên tiếp.
- Lệnh dưới khoảng 1 µs (tương đương 66 MOP ở đỉnh, lớn hơn một GEMM 256³ là 34 MOP) không thể giữ mảng bận ở bất kỳ độ sâu hàng đợi nào.

**UT-04 (High, S): spec không cho phép đọc descriptor trước commit.** §5.3 bước 3 bắt đầu nạp "sau khi lệnh được commit và không bị kill", và không nêu rằng descriptor có thể được đọc sớm hơn. Việc đọc descriptor là đọc thuần, không có tác dụng phụ; có thể đọc ngay sau issue và hủy nếu lệnh bị kill. Chờ commit thêm vài chục chu kỳ CPU và một vòng DRAM cho mỗi lệnh.

**UT-05 (High, V): lượng tử hóa theo hình dạng.** Với array 32×32 và 16 array, hiệu suất do đệm và cân bằng tile:

| M | N | K | Hiệu suất |
|---:|---:|---:|---:|
| 1 | 2048 | 2048 | 3,1% (chỉ một hàng PE hoạt động) |
| 8 | 2048 | 2048 | 25% |
| 100 | 2048 | 8192 | 78% |
| 197 (ViT) | 768 | 768 | 84% |
| 512, 1024 | bội của 32 | | 100% |

Hai cách khắc phục: cho phép phân hoạch mảng theo hàng (nhóm 8 hoặc 16 hàng chạy command riêng) và hỗ trợ split-K hoặc split-N để mọi array có việc ở đuôi.

**UT-06 (Medium, S/A): attention nhân quả có hai loại lãng phí cần tách.** Với tile `t=128`, bỏ qua tile chỉ chứa điểm tương lai làm tỷ lệ số tile được lập lịch còn 62,5% ở `S=512` và 53,125% ở `S=2048`. Trong các tile còn chạy, tỷ lệ MAC causal hữu ích lần lượt khoảng 80,2% và 94,2%; nếu tính cả tile tương lai, tỷ lệ hữu ích so với lịch hình vuông gần 50%. Đây là tỷ lệ ô/MAC hữu ích trong mô hình tile, không phải PE busy utilization. HDS nên yêu cầu bỏ qua tile bị che hoàn toàn và đo PE busy riêng.

**UT-07 (Medium, S): các pha phi MAC làm mảng rảnh.** DEC-056/059/060 đã đóng phép tính của OP-002/006/007, nhưng first-release scheduler vẫn chạy một command active; softmax/LN/epilogue có thể để MAC array rảnh. Exact attention có overlap tile nội bộ nhưng mức exp-lane cần thiết còn phụ thuộc tile/context và PPA. Cần đo occupancy, function-unit throughput và hàng đợi trên workload; chỉ thêm concurrent MAC/nonlinear scheduling hoặc multi-command interleave nếu số đo chứng minh lợi ích đủ bù context, arbitration, SRAM và verification.

**UT-08 (Medium, S/A): chế độ sparse 2:4 có thể cần thêm băng thông nạp activation, tùy mapping.** Nếu paired-lane tiến K qua bốn vị trí mỗi chu kỳ, hai selector có thể cần gather hai activation khác nhau từ nhóm bốn; nhu cầu feed có thể tăng từ 32 lên 64 B/chu kỳ/array trong mapping bảo thủ. Với nibble metadata đã chốt, mỗi nhóm INT8 dùng 2 byte payload + 0,5 byte metadata, so với 4 byte dense; giảm weight bytes 37,5% trên lý thuyết trước activation/output traffic. DEC-063 kiểm tra metadata từng tile rồi mới đọc numeric operands của tile đó, vì vậy không cần quét toàn metadata hoặc giữ toàn bộ metadata trong SRAM. Overlap tile tiếp theo với compute hiện tại còn phụ thuộc số buffer và bandwidth. Con số 2,0 TB/s cho 16 array vẫn là trần nội bộ giả định, chưa phải đo đạc. PPA-009 đo selected-product rate, không khẳng định mọi payload khác zero; tăng tốc đầu-cuối chỉ có khi metadata/activation feed đạt service rate tương ứng. Cần traffic model và benchmark trước khi chốt băng thông.

**UT-09 (Medium, S): không có counter nội IP.** CSR hiện có 10 thanh ghi để quản lý và lưu error diagnostics, nhưng không có performance counters. HDS PPA-006 cho phép dùng cycle-accurate simulation, trace hoặc system PMU và không yêu cầu counter trong IP (DEC-019). Đây là giới hạn observability cho silicon, không còn là mâu thuẫn yêu cầu; chỉ thêm counter nếu profiling chứng minh thiếu event cần thiết.

**UT-10 (Low, V): DMA đủ chiều sâu ở mức ứng viên.** 16 read × 2 KiB = 32 KiB trong bay cho phép 64 GB/s đến latency 400 ns; ở 800 ns (DRAM tranh chấp) cần 50 KiB, nên thiếu. Cần chọn `PARA_MEM_RD_OUTSTANDING` theo latency xấu nhất của SoC.

### 8.3 Kiến trúc đề xuất để giữ phần cứng bận

Mục tiêu: **tách việc nạp dữ liệu khỏi việc tính** để DMA (tài nguyên khan hiếm) luôn bận, còn mảng bận ở mức tái sử dụng cho phép.

```text
  Host (CVA6)                     Tensor IP (đề xuất)
  ring/doorbell  ───────►  m_cmd_fetch   (descriptor prefetch sớm, kiểm tra phụ thuộc)
  (hoặc CV-X-IF)                │ hàng đợi lệnh sâu (>= 8)
                                ▼
                         m_dma_ahead  (nạp trọng số chạy trước PARA_DMA_RUNAHEAD lệnh;
                                        nạp activation khi token phụ thuộc đã sẵn sàng)
                                │
                  ┌─────────────┼─────────────┐
                  ▼             ▼             ▼
            nhóm array 0   nhóm array 1   ...  (mỗi nhóm có ngữ cảnh lệnh riêng)
                  │             │
                  └──────┬──────┘
                         ▼
                  m_nonlinear (exp, rsqrt, reduce) chạy song song với MAC tile kế
                         ▼
                  m_wb (ghi, chờ B, trả kết quả, thứ tự theo hart)
```

Các thành phần:

1. **Command ring có doorbell.** Phần mềm dựng mảng descriptor (đồ thị của một lớp hoặc một token) trong bộ nhớ, clean một lần, rồi ghi một doorbell (một lệnh CV-X-IF hoặc ghi CSR). Phần cứng đọc descriptor liên tục. CV-X-IF vẫn dùng cho lệnh nhỏ latency thấp và cho `submit` (trả kết quả ngay khi chấp nhận) và `sync` (chờ hoàn tất), nhờ đó CPU không bị chặn retire bởi lệnh dài (UT-03).
2. **Token phụ thuộc.** Mỗi descriptor mang `wait_token` và `signal_token`. Trọng số, hằng số và KV cũ được nạp trước không cần chờ; chỉ activation chờ token của command sản xuất. Đây là điều kiện cần để DMA chạy trước qua biên command (UT-02).
3. **Nhóm array độc lập (`PARA_ARRAY_GROUPS`).** 16 array chia G nhóm, mỗi nhóm một ngữ cảnh lệnh. Phần mềm hoặc bộ lập lịch gán lệnh vào nhóm rảnh: decode vào nhóm nhỏ (một array), chunk prefill vào các nhóm còn lại. Đây là cách duy nhất dùng mảng vào việc khác trong lúc decode bị chặn bởi băng thông.
4. **QoS DMA.** Decode (nhạy latency) có ưu tiên cao hơn prefill; prefill dùng phần băng thông còn lại. `AxQOS` hiện là "TBD" (§6.2); cần chính sách và ngân sách token mỗi chu kỳ.
5. **Accumulator hai bank** và tile biên linh hoạt (split-K, split-N), bỏ qua tile che hoàn toàn (UT-05, UT-06, TP-04).
6. **Nonlinear song song với MAC.** `PARA_EXP_LANES` cỡ theo tốc độ điểm số (TP-05) và đệm giữa MAC và nonlinear đủ sâu để không dừng lẫn nhau.
7. **Hỗ trợ chuẩn bị M nhỏ.** ABI cho phép M từ 1 đến 16 hiệu quả: chế độ vector-dot cho M=1 (32 hoặc 64 PE mỗi cột dùng hết băng thông), gộp nhiều chuỗi vào một descriptor, mặt nạ cây cho speculative decoding.
8. **Giảm byte.** Thêm trọng số INT4 (nhóm cấu hình funct3 mới) với scale theo nhóm, dequantize trong đường nạp; KV-cache INT8.
9. **Công suất tỷ lệ với việc làm.** Clock gating theo nhóm array và operand isolation; DVFS miền mảng khi decode.

### 8.4 Chọn kích thước phần cứng theo mục tiêu sử dụng

Quy tắc: `PEAK_MAC/s ≈ băng thông × M_ref` (M_ref là số hàng dùng chung trọng số trong khối lượng công việc chính). Với 64 GB/s, 2 GHz:

| M_ref thiết kế | MAC cần mỗi chu kỳ | Số array 32×32 | Đỉnh TOPS |
|---:|---:|---:|---:|
| 1 | 32 | 0,03 (một hàng PE) | 0,13 |
| 8 | 256 | 0,25 | 1,0 |
| 64 | 2048 | 2 | 8,2 |
| 128 | 4096 | 4 | 16,4 |
| 512 | 16384 | 16 | 65,5 |

Cấu hình 16 array chỉ cân bằng nếu khối lượng chính có M_ref ≥ 512 **và** SRAM lớn (TP-01). Với sản phẩm chat edge (decode chiếm hơn 97% thời gian), phần cứng đúng cỡ là 2 đến 4 array cộng nhiều băng thông và trọng số INT4; 16 array chỉ có lý do nếu chạy song song nhiều luồng (phục vụ nhiều người dùng hoặc mô hình thị giác).

### 8.5 Thước đo và mục tiêu (đề xuất)

Không dùng "MAC utilization" làm chỉ số duy nhất, vì decode luôn thấp. Dùng bốn chỉ số, đo bằng bộ đếm phần cứng (UT-09):

| Chỉ số | Định nghĩa | Mục tiêu đề xuất |
|---|---|---|
| Hiệu suất băng thông DMA (decode) | byte hữu ích / (băng thông cấu hình × thời gian) | ≥ 85% |
| Hiệu suất roofline | TOPS đạt / min(đỉnh, băng thông × AI) | ≥ 85% |
| Array bận (prefill, K ≥ 1024, M và N bội của tile) | chu kỳ có PE tính / chu kỳ command | ≥ 90% |
| Khe hở giữa hai command liên tiếp | chu kỳ DMA đọc rảnh giữa hai command | ≤ 64 chu kỳ |

Phân loại chu kỳ rảnh (để bộ đếm biết nguyên nhân): chờ toán hạng, chờ descriptor, chờ phụ thuộc, drain accumulator, chờ phi tuyến, chờ kết quả được nhận, tạm dừng vì sticky error, không có việc.

## 9. Đề xuất sửa spec (redline)

Các đoạn dưới là **nội dung đề xuất cho HDS bằng tiếng Anh** (spec viết bằng tiếng Anh theo R-005), kèm vị trí sửa. Giá trị trong ngoặc là đề xuất cần chủ dự án xác nhận. Phần nào đã quyết định (DEC-xxx) được giữ nguyên trừ khi nêu.

### 9.1 Mục tiêu hiệu năng (§1.4 FEAT-002, §13 PPA-004 đến PPA-008)

| Vị trí | Sửa |
|---|---|
| §13 PPA-004 | Replace "User-selected ideal peak target: 64 TOPS per IP" with: "PPA-004 Dense peak arithmetic ceiling. `P_peak = 2 × PARA_ARRAY_COUNT × PARA_MAC_ROW × PARA_MAC_COL × f_array`. This value is a ceiling, not a product target." |
| §13 new PPA-004a | "Sustained dense INT8 GEMM throughput shall be reported for (M,N,K) = (1024,4096,4096) and (512,2048,2048) at the configured DMA bandwidth `B_dma` and local buffer capacity `S_buf`; the target is at least 85% of `min(P_peak, B_dma × 2·Mt·Nt/(Mt+Nt))` for the released tile `Mt×Nt`." |
| §13 new PPA-004b | "Decode throughput shall be reported as tokens/s for named models (Llama-3.2-1B and 3B INT8 and INT4 weights) at the configured `B_dma`; the target is at least 85% of `B_dma / weight_bytes`." |
| §13 new table | Add the roofline table of TP-01 and the reuse table of 8.1 as the normative explanation of the gap between `P_peak` and sustained throughput. |
| §1.4 FEAT-002 | Delete "16 arrays at 2 GHz yield an ideal 65.536 TOPS" as a product statement; keep it as an example of the formula with a pointer to PPA-004a. |
| §13 PPA-005/006/008 | Replace "TBD" by the latency budget of TL-01 (target values to be confirmed). |

### 9.2 Phân cấp pipeline và timing (§8, §8.1, §17)

Thay năm tham số nhị phân bằng các nhóm số tầng và hai lựa chọn kiến trúc:

| Parameter (proposed) | Legal | Default for `f_array ≥ 1.5 GHz` | Purpose |
|---|---|---|---|
| `PARA_ACC_STYLE` | 0 carry-propagate, 1 carry-save | 1 | Accumulator loop form (TT-01); 0 only allowed for `PARA_ACCUM_W=32` and `f_array ≤ 1 GHz` |
| `PARA_PIPE_OPERAND_STAGES` | 0 to 3 | 1 | Operand capture / format conversion |
| `PARA_PIPE_MUL_STAGES` | 1 to 3 | 2 | Multiplier and product-combine stages before the accumulator |
| `PARA_PIPE_GATHER_STAGES` | 0 to 2 | 1 | 2:4 activation gather (only with sparse family) |
| `PARA_PIPE_DIST_STAGES` | 0 to 4 | 3 | Control and operand distribution tree to the PE array |
| `PARA_PIPE_INJ_STAGES` | 1 to 4 | 2 | SRAM-bank to array injection network |
| `PARA_SRAM_RD_LATENCY` | 1 to 4 | 2 | SRAM read pipeline (replaces the fixed value 1 in MEM-001) |
| `PARA_PIPE_REDUCE_LEVEL_STAGES` | 0 to 2 | 1 | Registers per level of max, sum and argmax merge trees |
| `PARA_PIPE_EPILOGUE_STAGES` | 0 to 3 | 2 | Accumulator drain, carry-save to binary conversion, epilogue |
| `PARA_PIPE_POST_STAGES` | 0 to 3 | 1 | Post-processing to write path |
| `PARA_PIPE_MEM_STAGES` | 0 to 3 | 1 | Memory response to operand buffer |

Add to §8.1: "Every pipeline stage shall be an instance of one elastic stage module with registered ready (skid) where back-pressure is needed. Inside a systolic array no stage shall receive back-pressure: the array runs free and flow control is applied by credits at the array boundary. Data registers are not reset; valid bits are. A combinational ready path shall not cross more than two stages." Also add: "The release matrix lists the parameter combinations that pass STA at `f_array`; unlisted combinations are illegal."

Add to §17.1 a timing budget table, with the unit-gate probe as a proxy until a library is chosen:

| Stage | Content | Budget (unit gates, Yosys probe) | Probe value |
|---|---|---:|---:|
| PE multiply | INT8 multiplier into carry-save | 30 | 29 |
| PE accumulate | 3:2 compressor loop | 8 | 4 |
| Column drain | carry-save to binary add, pipelined | 30 per stage | 48 for a 32-bit adder, so 2 stages |
| Sparse gather | 4:1 select | 8 | 2 |
| Sparse product add | two products | 30 | to be measured |

### 9.3 Clock (§7.1, §7.2)

"Add `CLK-TENSOR` (`i_clk_tensor`) for the array, local buffers and DMA. `CLK-CORE` clocks CV-X-IF and the command queue input. The command queue is the clock-domain crossing: an asynchronous FIFO, or a synchronous 1:N ratio when both clocks derive from one PLL. `CDC-003` CV-X-IF command and result across `CLK-CORE` and `CLK-TENSOR`. The area of one extra synchronizer is negligible compared with the latency of any tensor command."

### 9.4 Điều khiển và FSM (§5.4, §10.1, §10.4)

Replace the single control FSM of §10.1 with three decoupled engines (each with its own state diagram):

| Engine | States | Notes |
|---|---|---|
| `m_cmd_fetch` | IDLE, DESC_REQ, DESC_WAIT, VALIDATE, DEP_WAIT, ISSUE, ERR_DRAIN | Starts descriptor read at issue (before commit); kills on `commit_kill`; waits only on `wait_token` |
| `m_exec` (one per array group) | IDLE, LOAD_CTX, RUN_TILE, FLUSH_ACC, SIGNAL, ERR_DRAIN | Accumulators have two banks; next tile starts while previous drains |
| `m_wb` | IDLE, WRITE, WAIT_B, RESULT, ERR_DRAIN | Result FIFO decouples `result_ready` from execution |

`ERR_DRAIN` is reachable from every state per DEC-012: stop issuing unstarted tiles, drain accepted work, select status, then complete. Replace "WRITEBACK to IDLE on result_ready" with "WRITEBACK enqueues the result and returns to IDLE".

In §5.4 replace "one active command owns all arrays" by: "The scheduler assigns each command to an array group. Groups execute independent commands. Commands from one hart complete in acceptance order; commands in different groups may overlap."

### 9.5 Giao diện lệnh (§6, §10.2.1)

| Item | Proposed text |
|---|---|
| Submit and sync | "Add operation IDs `TC_SUBMIT` (accepts a descriptor ring head, returns at acceptance) and `TC_SYNC` (returns when the identified token is signaled). A tensor operation submitted with `TC_SUBMIT` shall not hold CV-X-IF retirement." |
| Ring and doorbell | "A command ring of descriptors in non-coherent memory, advanced by a doorbell. Each descriptor carries `wait_token`, `signal_token` and `qos`." |
| Early descriptor read | "`m_cmd_fetch` may read the descriptor after issue acceptance and before commit. If the instruction is killed, the fetched descriptor is discarded and no state changes." |
| Result semantics | Keep REQ-FUNC-001 for compatibility, with the new operations as the performance path. |
| INT4 weights | Không áp dụng trực tiếp redline gán `funct3=011`: selector này hiện đang reserved theo DEC-013 và W4A8 là mixed precision, không biểu diễn đúng bằng precision chung. Chỉ cân nhắc extension có version sau khi benchmark; xem [Architecture Options Analysis §5](VLSIT_TENSOR_COPROCESSOR_Architecture_Options_Analysis_2026-11-17.md). |

### 9.6 Yêu cầu mới (§3)

| ID | Proposed requirement |
|---|---|
| REQ-UTIL-001 | During decode (`M ≤ 8`) the tensor DMA shall sustain at least 85% of `B_dma` averaged over one layer, independently of `PARA_ARRAY_COUNT`. |
| REQ-UTIL-002 | Between consecutive queued commands, the DMA read channel shall not be idle for more than 64 core cycles when the next command's weights have no `wait_token`. |
| REQ-UTIL-003 | During a dense GEMM with `K ≥ 1024` and `M`, `N` multiples of the tile, array busy cycles shall be at least 90% of command cycles. |
| REQ-UTIL-004 | The IP shall provide cycle counters per array group (busy, and idle by cause: operand, descriptor, dependency, drain, nonlinear, result back-pressure, host pause) and DMA read and write busy counters, readable through the CSR. |
| REQ-UTIL-005 | The scheduler shall skip score tiles that are fully masked by a causal mask. |
| REQ-UTIL-006 | Sparse 2:4 mode shall state the activation injection bandwidth it requires; if it exceeds the dense injection bandwidth the build shall provide it or declare the sparse speed-up as 1.0. |
| REQ-TIME-001 | The accumulator loop shall be implemented in the form selected by `PARA_ACC_STYLE`; a build with `PARA_ACC_STYLE=0` and `PARA_ACCUM_W>32` shall be rejected at elaboration for `f_array>1 GHz`. |
| REQ-TIME-002 | A pipeline cut shall be implemented only through the shared elastic stage module; array-internal stages shall have no ready. |
| REQ-TIME-003 | Every released parameter combination shall pass STA at the stated `f_array` and corner; the release matrix is part of the delivery. |
| REQ-LAT-001 | First-result and tile-completion latency and tokens/s targets of PPA-005/006 shall be stated for the released configurations (values to be confirmed, TL-01). |

### 9.7 CSR (§11, workbook `TENSOR_COPROCESSOR_CSR.xlsx`)

CSR mismatch đã được sửa trong các artifact được duy trì: `tcop_regs.json` và `TENSOR_COPROCESSOR_CSR.xlsx`. Map mới không còn global `op_mode`/`tcop_cfg`; nó có status lỗi đầu tiên, hart ID, CV-X-IF ID, địa chỉ DMA, AXI ID và diagnostic detail. Workbook được sinh từ JSON; cả hai đã được validate đồng bộ.

Performance counters vẫn được cố ý để ngoài IP theo DEC-019. Đề xuất cũ thêm counters được hoãn đến khi profiling chứng minh thiếu event cần thiết. CSR map đã bổ sung `tcop_ctrl.scalar_ack` ở bit [1], tăng minor version lên 1.1; DEC-021 đã chọn fence/ack, còn DEC-020 đã chốt `tcop_err_detail.detail=0` cho release 1. Fence, CDC và driver sequencing vẫn cần RTL/system sign-off.

### 9.8 Kiểm chứng (§15)

| Test | Mục đích |
|---|---|
| TEST-UTIL-1 | Chạy decode giả lập với DMA bound; đo hiệu suất băng thông ≥ 85% (REQ-UTIL-001) |
| TEST-UTIL-2 | Hai command liên tiếp, command thứ hai có trọng số độc lập; khe hở DMA ≤ 64 chu kỳ (REQ-UTIL-002) |
| TEST-UTIL-3 | Prefill GEMM K=4096; array bận ≥ 90% (REQ-UTIL-003) |
| TEST-UTIL-4 | Attention nhân quả S=512 và 2048; số tile thực hiện bằng số tile không che (REQ-UTIL-005) |
| TEST-TIME-1 | Mọi tổ hợp trong release matrix qua STA; mô hình tham chiếu độ trễ tùy ý so khớp giá trị |
| TEST-TIME-2 | Property formal cho tầng elastic (không mất, không nhân đôi, đường ready không tổ hợp qua hơn hai tầng) |

## 10. Câu hỏi cần chủ dự án quyết định

1. Mục tiêu sản phẩm là gì: TOPS đỉnh, TTFT, tokens/s của mô hình nào, ở băng thông DRAM bao nhiêu? Câu trả lời chọn điểm A, B hay C ở TP-02.
2. Chấp nhận miền clock riêng cho mảng tensor (TT-07), hay giữ một miền và hạ mục tiêu xuống tần số của CVA6?
3. Chấp nhận tích lũy carry-save (thêm 64 KiB flip-flop, khoảng 16% diện tích PE theo thí nghiệm) để đạt 2 GHz?
4. Có thêm INT4 hoặc FP8 cho trọng số không? Phân tích so sánh đã bổ sung ở [Architecture Options Analysis §5](VLSIT_TENSOR_COPROCESSOR_Architecture_Options_Analysis_2026-11-17.md); khuyến nghị giữ ABI hiện tại và chỉ chọn extension sau khi benchmark decode cùng checkpoint/quality budget.
5. IP này gắn vào cụm nào, với CV-X-IF ra sao (TI-01)?
6. Có đặt mục tiêu công suất hoặc TOPS/W và clock gating theo array không?
7. Khối lượng công việc chính là gì (chat decode batch-một, nhiều người dùng, thị giác)? Câu trả lời quyết định M_ref và số array theo bảng 8.4.
8. Chấp nhận mô hình lệnh mới (ring, doorbell, `TC_SUBMIT`, `TC_SYNC`) bên cạnh lệnh CV-X-IF hiện có không?
9. Có thêm trọng số INT4 (W4A8) không?

## Phụ lục A. Lệnh tái hiện

```sh
python project_support/review/tensor_probes/roofline.py
python project_support/review/tensor_probes/utilization.py
sh project_support/review/tensor_probes/run_depth_probe.sh
```

`run_depth_probe.sh` cần Yosys (OSS CAD Suite); kết quả ngày review:

| Module | Độ sâu | Số cell |
|---|---:|---:|
| `pe_v1` (nhân và tích lũy một tầng) | 61 | 884 |
| `pe_v2` (cut MUL) | 48 | 625 |
| `pe_v3` (cut MUL, carry-save) | 29 | 726 |
| `pe_v4` (sparse một tầng) | 70 | 1568 |
| `pe_v5` (sparse hai cut) | 49 | 1262 |
| `fp32_add_loop` | 114 | 1087 |
| `mul8` | 29 | 423 |
| `acc32` | 48 | 201 |
| `acc64` | 80 | 424 |
| `csa32` | 4 | 285 |
| `gather` | 2 | 32 |

Độ sâu đo bằng `ltp` sau ABC với bộ cổng AND, NAND, OR, NOR, XOR, XNOR, ANDNOT, ORNOT, MUX; không có thư viện và không có delay thật, nên chỉ so sánh tương đối. Bộ cộng và bộ nhân dùng ánh xạ mặc định của Yosys, chưa phải cấu trúc tối ưu của một thư viện thương mại, nên con số tuyệt đối có thể thấp hơn trong thực tế nhưng thứ tự giữa các biến thể vẫn là cảnh báo đúng hướng.


**DEC-057 đã đóng contract số học OP-003:** một vector SUM/MAX, cap đầu tiên 1,048,576; INT8 SUM exact signed-32 trên raw values, BF16/FP16 SUM qua FP32 fixed tree theo index với nearest-even; scalar được mã hóa trực tiếp trong `rd`. NaN đầu vào hoặc do `+Inf + -Inf` là `TC_ERR_NUMERIC_NAN`, `rd=0`; infinities khác được giữ theo IEEE, và MAX chọn +0 trên -0. Global fence đã có từ DEC-021 nên zero hợp lệ vẫn phân biệt được lỗi qua CSR. Còn mở: generated driver constants, cap/hard latency signoff, silicon/driver/CDC evidence; body offsets/schema size đã cố định ở DEC-065.


**DEC-058 đã đóng số học OP-005 exact attention:** Q/K/V BF16/FP16 widen sang FP32, QK dùng FMA theo thứ tự feature cố định, online softmax giữ m/l/o FP32 và cập nhật theo tile key tăng dần. Chỉ hỗ trợ mask NONE, causal có `query_position_start`, hoặc ma trận boolean byte shared-head; additive/sliding-window mask để sau. Exp và reciprocal có ngưỡng sai số rõ, mask rỗng trả `TC_ERR_NO_VALID_ATTENTION_ROW`, NaN/Inf có mã riêng, mọi lỗi invalid toàn bộ output. DEC-065 đã đóng byte offsets/schema; sai số mô hình được chấp nhận, tile/SRAM/PPA và memory-service signoff còn mở.

**DEC-059/060 đã đóng OP-006/007:** softmax chốt BF16/FP16, mask NONE/BOOL, fixed max/sum tree, exp/reciprocal bounds, lỗi hàng rỗng và cap 65,536 hàng/chiều cùng 16,777,216 phần tử. LayerNorm chốt Welford fixed tree, population variance, epsilon [2^-24,1], affine tùy chọn, rsqrt bound và cùng tổng cap. HDS/ISA giờ mô tả trạng thái số học và lỗi; target-model tolerance, SRAM/function-unit PPA và timing vẫn là sign-off gates.

**DEC-061 đã đóng thuật toán OP-009 ở mức phần cứng-phần mềm:** `feature_map_id=0` là ELU+1, Q/K/V/output BF16/FP16, state S/z FP32; token được cập nhật vào state trước khi tính context nên recurrence bao gồm chính token hiện tại. RESET tạo state zero; CONTINUE kiểm tra header TLAS/version/shape/precision/count; state cũ và state mới dùng buffer riêng để lỗi giữ nguyên checkpoint trước. Đã chốt caps batch 4, sequence 65,536, heads 64, mỗi head R/Dv 128, tổng width 4,096, state 16,777,216 phần tử và work 17,179,869,184 MAC-equivalent terms. Denominator dưới 2^-126 có lỗi riêng; NaN/Inf và state metadata lỗi có status riêng. Cách này tránh random-basis hardware của FAVOR+ và cho recurrence xác định, nhưng chỉ tương thích với model được train/validate cho ELU+1. State DRAM vẫn là rủi ro decode: ví dụ 32 heads × R=64 × Dv=128 tạo khoảng 1.01 MiB state mỗi sample; state-in + state-out có sàn truyền khoảng 33 µs ở 64 GB/s, trước tranh chấp AXI. Schema byte offsets đã được đóng ở DEC-065; context concurrency, latency/traffic và ngưỡng chất lượng từng model vẫn cần sign-off.

**DEC-062 đã chốt format sparse 2:4:** mỗi nhóm K có nibble với hai chỉ số 2-bit `p0<p1`; chỉ sáu mã 0x4/0x8/0x9/0xC/0xD/0xE hợp lệ. Nhóm được đánh chỉ số `q=g*N+n`; metadata low/high nibble theo q, weights lưu `[g][n][slot]` và slot tương ứng vị trí tăng dần. Zero payload được chấp nhận, hardware vẫn chạy slot đó. Mỗi nhóm dùng 2 byte INT8 values + 0,5 byte metadata, tức giảm 37,5% weight bytes trên lý thuyết so với dense, chưa tính traffic khác.
**DEC-063 đã chọn validate theo tile:** full descriptor spans được kiểm tra trước; accumulator bound dùng K/2 được tính trước numeric data. Mỗi metadata tile phải hợp lệ trước khi tile đó đọc activation/weight và tính. Tile lỗi về sau có thể theo sau partial writes của tile trước; toàn output vẫn invalid, được drain và báo lỗi sau ưu tiên DEC-012, driver bỏ cả buffer. Tile metadata kế tiếp có thể được nạp/kiểm tra trong lúc tile hiện tại tính; staging size và overlap service còn cần chốt. Cách này bỏ full metadata pre-scan/reread hoặc SRAM cache toàn bộ, giảm startup và traffic.

**DEC-064 đã chốt giới hạn lệnh GEMM đầu tiên:** M/N tối đa 16.384, product terms tối đa 2^35, M×N output tiles tối đa 4.096, logical read/write span mỗi loại tối đa 64 MiB; K vẫn tối đa 16.384. Product cap tương ứng sàn tính toán lý tưởng khoảng 1.074 ms cho dense ở 64 TOPS; đây không phải command latency. Các span là logical references, không tính lần đọc lại tile; SoC/PPA phải tính traffic thực theo tile schedule trước khi đưa ra hard bound. Lệnh prefill lớn có thể chia theo M/N, không chia K; lỗi một chunk làm software bỏ toàn bộ output logic và chạy lại transaction.



**DEC-065 — ABI descriptor body đã đóng:** release 1 dùng schema kích thước cố định theo operation, config 64B và `TREF64` gồm base, span, bốn extent 32-bit, bốn stride byte 64-bit. Kích thước chính xác: OP-001 832B, OP-002 640B, OP-003 192B, OP-004 192B standalone/384B fused, OP-005 448B, OP-006 320B, OP-007 384B, OP-008 896B, OP-009 512B; `schema_bytes` bao gồm header và max là 896B. Descriptor validation, reserved-zero, mode/shape/address errors và thứ tự trước numeric DMA được ghi từng offset trong ISA companion §10.

**Phản biện fused INT8 ARGMAX:** so sánh accumulator thô sai khi scale weight thay đổi theo vocabulary channel. DEC-065 yêu cầu coefficient Q31/exponent theo channel và comparator fixed-point có chuẩn hóa wide, không làm tròn score về INT8 trước khi chọn token. INT8 fused bias bị cấm release 1 vì chưa có quy tắc scale tương thích; BF16/FP16 vẫn hỗ trợ bias. Đổi lại, fused INT8 cần đọc/kiểm tra thêm coefficient vector và comparator lớn hơn; driver/model manifest phải nhất quán về scale.

**DEC-067 chọn C theo xác nhận của người dùng.** Spec dùng cap riêng theo mode và kiểm tra độc lập tổng span đầu vào/đầu ra. Đề xuất build đầu: 33.554.432 phần tử cho ADD/BIAS_ADD/RESIDUAL_ADD/SCALE/ACT_ONLY, 16.777.216 cho SwiGLU, 128 MiB đọc và 64 MiB ghi. Tính span đã khai báo gồm padding, X và RHS hoặc bias cho đọc, Y cho ghi. Kiểm tra trước DMA. Batch 4 BF16/FP16 tại điểm prefill lớn nhất của HDS có thể chạy ADD trong một command với layout compact, còn SwiGLU chia hai command batch 2. Nếu padding làm vượt byte cap, driver chia nhỏ hơn và chỉ công bố kết quả khi toàn bộ chunk thành công. Các cap tính theo cấp phát. Số beat AXI và throughput vector thực tế vẫn cần đo.

**Rà soát DEC-065/066 về DMA:** Phân biệt số byte dữ liệu và span cấp phát. Ví dụ build căn 64 byte, 65 hệ số REQUANT8 dùng 520 byte dữ liệu, stride record 8 byte và span cấp phát tối thiểu 576 byte. Với OP-009, khi payload state 8 byte, mỗi TLAS record có 64 byte header và bước 128 byte. Batch 2 cần đủ 200 byte tới cuối payload cuối, đặt trong span cấp phát tối thiểu 256 byte. DMA giữ nguyên padding khi ghi. Layout sai báo TC_ERR_SHAPE. Span thiếu hoặc pitch đúng layout nhưng sai alignment báo TC_ERR_ADDRESS. Firewall từ chối được báo qua lỗi AXI.

**DEC-048, so sánh nạp Q/K ở head rộng 4.096:** Với tile 32 query × 128 K/V, lát 128 feature và Dv=128, ước tính SRAM logic mỗi context là 2.424,25 KiB khi giữ toàn bộ Q/K, 440,25 KiB khi giữ Q và chia lát K, và 200,25 KiB khi chia lát cả Q/K. Ở context 2.048 token, phương án cuối đọc lại Q cho 16 tile K/V, làm payload Q/K/V tăng từ 16,75 lên 20,50 MiB mỗi query tile. Ưu tiên đo phương án giữ Q và chia lát K cho prefill. Cần đếm burst thực và đo riêng decode một query trước khi chọn cấu hình build.

**DEC-039, điều kiện cam kết latency:** HDS bổ sung cách tính từ safe commit, hàng đợi dùng chung, lịch DMA/compute, backpressure đến handler entry. Cần đặc biệt kiểm tra mode 2. Nếu N lỗi và N+1 đã được authorize, N+1 có thể phải chờ W1C trong khi CPU chờ N+1 retire để vào handler. Nếu chỉ handler đó xóa W1C, hai bên có thể chờ nhau dù AXI trả lời đúng hạn. Cam kết latency handler khi có lỗi cần chứng minh đường xử lý CSR hoạt động độc lập với handler đang bị hoãn và có thời gian phản hồi hữu hạn.

**So sánh cách gỡ phụ thuộc W1C:** ưu tiên khảo sát một tác nhân đặc quyền có thể đọc, lưu bản ghi lỗi và xóa W1C trong lúc hart phát lệnh đang chờ. Cách này giữ overlap prefetch. Nếu top chỉ có một hart và thiếu đường phục vụ độc lập, có thể cân nhắc giới hạn một lệnh đã authorize trên toàn accelerator. Khi đó không còn N+1 đã authorize mắc kẹt sau N lỗi, nhưng mất prefetch descriptor của N+1 trong lúc N chạy. OP-003 giữ handshake riêng. Xóa bản ghi lỗi trước khi owner kiểm tra giá trị zero có thể làm software hiểu nhầm lỗi thành kết quả hợp lệ.

**Chi tiết phương án W1C độc lập:** hartid/id chỉ xác định lệnh khi mapping còn sống. HDS đề xuất nối bản ghi với handle ổn định do host cung cấp và dành một chỗ lưu lỗi trước safe commit. Nếu lỗi cũ chưa được owner lấy, slot vẫn phải được giữ. Nhờ đó agent có chỗ lưu mọi lỗi của các lệnh đã authorize và không phụ thuộc vào owner đang chờ handler. CVA6 top và driver cần cung cấp mapping, quy tắc tái sử dụng ID và đường truy xuất bản ghi. OP-003 giữ W1C/ACK do owner thực hiện.

**DEC-068 chốt đường FP của OP-001:** cộng dồn bằng FP32 FMA theo thứ tự K, giữ accumulator qua ranh giới tile, cộng initial C/bias/residual theo thứ tự rồi đổi format đúng một lần. BF16/FP16 giữ activation NONE theo ISA và dùng OP-002 nếu cần activation. RTL có thể xen kẽ nhiều ô output độc lập để che latency vòng feedback. Cần xác minh rounding/subnormal, mã lỗi và initiation interval trên từng build.

**DEC-069 cho fused ARGMAX FP:** chốt phép chiếu theo thứ tự feature, mỗi bước FP32 FMA làm tròn nearest-even, cộng model bias cuối cùng rồi so sánh trực tiếp FP32. +0 và -0 bằng nhau khi chọn index, +Inf vẫn là điểm hợp lệ, -Inf bị loại và NaN báo lỗi theo OP-004. Đồng thời sửa các dòng HDS cũ về INT8 fused để thống nhất với DEC-065. Ví dụ accumulator 100 với scale 0,5 cho điểm 50, thấp hơn accumulator 80 với scale 1 cho điểm 80. So sánh raw accumulator sẽ chọn sai token.

**RV-012: sizing exp và đường P×V của OP-005.** Phép tính DEC-058 yêu cầu tích P×V làm tròn FP32 trước khi cộng theo cây chỉ số key. HDS bổ sung số phép tính theo tile, cách suy ra tốc độ cấp dữ liệu cho exp/tree và cách tính độ sâu queue theo burst. Ở ví dụ 32×128, Dqk=Dv=128, có tối đa 4.128 lần exp/tile. Nếu mỗi context bắt đầu một tile mỗi 1.024 cycle, 16 context cần trung bình 64,5 đầu vào exp/cycle. Cần đo interval thật, throughput tree và cổng SRAM trước khi chọn số lane.

**RV-012, datapath P×V:** đề xuất giữ một tổng tạm FP32 cho mỗi tầng cây và xử lý một nhóm ô output tại một thời điểm. Với tile 32×128 và Dv=128, lưu toàn bộ tích cần 2 MiB. Giữ bảy mức tổng tạm cho 64 ô đang tính cần 1,75 KiB, chưa gồm buffer probability/V, tầng pipeline và tag. Điểm đánh đổi là phải đọc lại probability/V trong SRAM cho các nhóm sau. HDS bổ sung ví dụ cho thấy cây cân bằng và cộng tuần tự có thể ra kết quả khác nhau.

**DEC-070 làm rõ softmax và attention:** hàng query mới có cờ chưa gặp key hợp lệ. Tile bị mask hết giữ nguyên state, tile hợp lệ đầu tiên dùng alpha=+0, và hàng chưa gặp key sau toàn bộ vòng K/V báo lỗi. Nếu hai điểm đều hữu hạn nhưng phép trừ đã trừ max bị tràn âm, exp cho +0 theo luật cutoff. Ví dụ hai logit BF16 hữu hạn ở gần hai cực cho [1,0] khi xếp điểm lớn trước. Chỉ áp dụng ngoại lệ cho phép trừ này.

**Sizing Welford OP-007:** ở nhánh đầy đủ, hai nhánh con có số phần tử bằng nhau nên hệ số r=0,5 và f=A/2 là chính xác. Mỗi tầng chỉ có tối đa một nút lệch kích thước vì padding nằm cuối hàng. Có thể tính trước hệ số của nút đó theo D rồi dùng lại cho mọi hàng trong cùng command. Vẫn phải giữ đúng phép chia variance và các điểm làm tròn FP32. Một hàng 65.536 phần tử BF16/FP16 cần 128 KiB. Hai bank cần 256 KiB, hoặc có thể đọc lại hàng qua DMA sau khi tính thống kê để giảm SRAM với chi phí thêm một lượt đọc.

**Sizing softmax OP-006:** hàng BF16/FP16 dài tối đa 65.536 với mask BOOL có thể dùng 392 KiB nếu giữ logits, bit mask và exp FP32, hoặc 136 KiB nếu giữ logits và tính exp lại. Nếu đọc lại logits/mask từ DRAM, ba lượt đọc thay một lượt làm tăng tối đa 384 KiB payload mỗi hàng. Đề xuất đo trước phương án giữ hàng và tính exp lại. Tất cả lịch đều giữ đúng cây tính mẫu số và error contract.

**Sizing metadata OP-008:** xác định byte đọc theo khoảng nibble của từng nhóm K và chỉ kiểm tra nibble thuộc tile. Byte có thể chứa nibble của tile kế bên. Hai slot luân phiên cho phép tile hiện tại tính trong lúc tile tiếp theo được kiểm tra, nhưng chỉ slot đã hợp lệ cùng vector requant đã kiểm tra xong mới mở đường đọc activation/weight. Ví dụ Ktile=128 và Ntile=32 cần tối đa 544 byte selector mỗi slot, chưa tính lưu tag, căn SRAM và beat AXI.

**OP-009, lưu state và checkpoint:** đồng bộ HDS theo layout ISA [batch,head,sequence,feature]. Mỗi head nạp state một lần và giữ qua mọi token trong command. Driver chỉ đổi handle khi lệnh thành công và DMA ghi đã hoàn tất. Ở H=32/R=64/Dv=128, một CONTINUE decode cần khoảng 2,11 MB chỉ để đọc và ghi checkpoint, tương đương khoảng 33 microsecond ở 64 GB/s giả định. Nếu cùng command xử lý 128 token đã có sẵn, traffic checkpoint còn khoảng 16,1 KiB/token. Đây là payload logic, chưa tính burst hoặc traffic Q/K/V.

**RV-016, mapping fused ARGMAX:** chia dải vocabulary thành các nhóm channel liền kề, mỗi channel giữ accumulator riêng và tính đúng thứ tự K. Có thể xen các channel độc lập để che FMA latency. Ở vocab 65.536 và K=4.096, 16 array dùng một hàng 32 lane mỗi array ở 2 GHz có sàn tính INT8 khoảng 262 µs, còn đọc 256 MiB weight ở 64 GB/s mất khoảng 4,19 ms. Đề xuất đo mapping này trước. Số liệu thật phải có burst, mức tái sử dụng weight và stall của đường winner.

**DEC-001, pipeline contract:** cả năm cut dùng tham số elaboration. Tín hiệu owner, tile, mask và lỗi đi cùng payload khi stall. Cut sau multiplier của OP-001/004 FP phải giữ tích chưa làm tròn hoặc state bên trong FMA để kết quả giữ đúng hợp đồng. Đề xuất khảo sát build bypass hết, từng cut đơn lẻ và bật cả năm trên cùng cấu hình bộ nhớ/workload, rồi chọn tổ hợp từ số liệu STA, II và latency thực.

**DEC-033/034, đối chiếu tín hiệu CVA6:** HDS đã nối các điểm source issue, writeback/exception, branch cancel, LSU, CSR và flush với điều kiện safe frontier cần có. Full flush xóa scoreboard, nên DEC-035 phải can thiệp trước lúc phát flush để giữ lệnh đã authorize. Giá trị valid của scoreboard không đủ để xác nhận rằng mọi nguồn lỗi đã kết thúc. Top mới cần chứng minh từng lớp lệnh, gồm trường hợp N+1 được authorize khi N đang chạy và trường hợp lỗi load cũ kill N+1 mà không phát DMA.

**DEC-028/029, quiesce và watchdog:** khi quiesce, chặn nhận lệnh mới. Lệnh đã authorize tiếp tục DMA để hoàn tất, còn lệnh đã nhận nhưng chưa authorize được host xử lý commit/kill. Nếu chặn luôn mọi DMA, một lệnh đang đợi phát burst ghi có thể làm quiesce treo. Watchdog R tính sau AR và giữa các beat, còn B chỉ tính sau khi AW và toàn bộ W đã được nhận. Response đã valid nhưng ready thấp được tính là backpressure cục bộ. Thiếu response quá giới hạn SoC vẫn dẫn tới reset toàn SoC.

**DEC-071 chốt ưu tiên lỗi descriptor:** kiểm tra từng pha header/body trước khi cho phép DMA số học. Header hỏng format đồng thời sai variant trả lỗi format. Body sai mode đồng thời sai field chỉ áp dụng cho mode hợp lệ trả lỗi mode, vì chưa xác định được cách áp dụng field đó. Địa chỉ hoặc alias sai của một vùng cấp phát được báo trước khi vùng đó có thể đóng góp vào tổng byte cap. Nếu đọc header/body gặp lỗi AXI, dùng mã AXI theo DEC-012 và bỏ dữ liệu lỗi.

**DEC-026, buffer prefetch descriptor:** đề xuất một slot cho lệnh kế tiếp, tối đa 896 byte, hoặc hai bank raw tổng 1.792 byte nếu lệnh đang chạy còn cần descriptor thô. Prefetch chỉ mở sau safe commit của đúng lệnh. Nếu N+1 lỗi khi N còn tính, giữ lỗi theo context N+1 và chỉ báo khi đến lượt. Nếu N cũng lỗi, báo lỗi N trước, chờ W1C mode 2 rồi mới tiếp tục trả lỗi N+1. Các response đã được AXI chấp nhận vẫn phải drain theo đúng chủ sở hữu.

**DEC-072, chống race CSR/result:** nếu core trả rd=0 trước khi err_valid đi qua CDC, driver có thể nhầm OP-003 lỗi thành kết quả 0 hợp lệ. HDS yêu cầu APB nhận đủ bản ghi và báo lại core trước khi phát result_valid ở mode 2. OP-003 trả 0 cũng phải đợi busy đã thấy được qua APB. Tính độ trễ publish này riêng với W1C/scalar_ack sau result.

**DMA ownership và phụ thuộc lệnh:** HDS bổ sung trình tự bàn giao buffer từ CPU sang DMA, từ DMA về CPU và giữa hai command. Với chuỗi phụ thuộc, driver phải thấy producer thành công và dữ liệu ghi đã visible trước khi authorize consumer. Nếu producer lỗi, chỉ xóa W1C có thể làm lệnh trẻ chạy lại trên output invalid. ABI hiện không có dependency token, nên driver phải quản lý quan hệ này. Các lệnh độc lập vẫn có thể overlap descriptor.

**Ví dụ kiểm tra ABI:** ISA §10.5 bổ sung một descriptor OP-003 có con trỏ DMA vượt 32 bit để đối chiếu mã lệnh RV32/RV64 và một descriptor OP-009 B=1/H=2/T=1 để phân biệt đúng thứ tự các chiều. Bảng minh họa cả span xin cấp phát và số byte thực sự có payload.

**DEC-004, sizing DMA outstanding:** 16 read ID với burst 2 KiB cho cửa sổ 32 KiB. Muốn đạt 64 GB/s với burst đầy, mỗi credit đọc phải được trả trong trung bình tối đa 512 ns. Nếu thời gian trung bình là 800 ns, sàn sizing này cho trần khoảng 40,96 GB/s. Đo tới beat R cuối hoặc B, không dừng ở beat đầu. HDS cũng chốt nguyên tắc giữ chỗ SRAM trước AR và giữ ID tới khi response kết thúc.

**DEC-004/064, reuse GEMM prefill:** ở INT8 M=1.024/N=K=4.096, block 128×128×128, ước tính payload A/B/output lần lượt là 260 MiB nếu mỗi block tự đọc A/B, 196 MiB nếu hai block M dùng chung lát B, và 148 MiB nếu giữ nguyên một panel B qua mọi block M. Đề xuất đo phương án hai block trước. Phương án này thêm 64 KiB accumulator mỗi nhóm xử lý và tránh 64 MiB payload B trong ví dụ. Các lượt đọc lại là traffic thực, không làm thay đổi cap span của descriptor.

**Cấu hình bring-up và điều kiện release:** sửa điều kiện cũ khiến build cần chứng cứ đã qualify mới được elaboration, trong khi phải elaboration mới chạy được xác minh. CFG-FULL bring-up đề xuất một array 16×16, queue hai slot, CSR mode 2 và bypass năm cut để làm mốc. Hai biến thể ARGMAX vẫn build riêng. OP-005 bắt đầu với tile 16 query × 64 K/V, một context và lát K rộng 128. Build phát hành chỉ nhận các cặp operation/precision đã qualify và vẫn cần SRAM thật, STA, test protocol và benchmark.

**DEC-004/006, bank SRAM và broadcast:** ở lưới 4×4 array, 1.024 byte/chu kỳ đi tới các PE nhưng có thể chỉ cần đọc 256 byte/chu kỳ từ SRAM nếu chia sẻ A theo hàng array và B theo cột array. Với cổng 256 bit, ứng viên cần 8 lần đọc đồng thời thay vì 32 khi không chia sẻ. Hai slot Kt=128 cần 64 KiB operand logic. Cần đo cùng pha, backpressure từng đích, cổng ghi DMA và timing fanout trước khi chọn macro.

**OP-008 paired MAC feed:** hai tích INT8 cực đại có tổng +32.768 nên adder và cut phải giữ ít nhất 17 bit signed. Với 16 array theo lưới 4×4, mỗi bước sparse cần 512 byte activation ứng viên, 256 byte weight nén và 64 byte selector nếu phân phối broadcast lý tưởng. Dù weight ngoài DRAM giảm, đường SRAM/gather vẫn phải được đo riêng trước khi cam kết II=1.

**Probe OP-008 với đúng một multiplier cut.** Probe pe_sparse_contract dùng cùng activation gather, hai multiplier 8×8, tổng cặp 17 bit signed và accumulator 32 bit. Chỉ đổi MUL_CUT. Yosys 0.69+274 (7513f8df8), ABC với tập cổng như probe trước, cho kết quả:

| Cấu hình probe | Độ sâu cổng | Cell sau mapping |
|---|---:|---:|
| MUL_CUT=0 | 70 | 1.562 |
| MUL_CUT=1 | 48 | 1.224 |

Chạy trong thư mục project_support/review/tensor_probes với Yosys/ABC trong PATH và thư mục temp đơn giản. Đổi giá trị CUT thành 0 hoặc 1:

```text
yosys -p "read_verilog -sv pe_variants.sv; chparam -set MUL_CUT CUT pe_sparse_contract; hierarchy -top pe_sparse_contract; proc; flatten; opt; synth -top pe_sparse_contract -flatten; abc -g AND,NAND,OR,NOR,XOR,XNOR,ANDNOT,ORNOT,MUX; opt_clean; ltp -noff; stat"
```

Probe không có reset, handshake, SRAM hoặc interconnect. Đây chỉ là độ sâu logic sau mapping cổng cơ bản. Dùng để ưu tiên khảo sát cut, rồi đo STA và chu kỳ trên build thật. Không suy ra Fmax hay diện tích vật lý từ bảng này.

**Đối chiếu số học probe sparse bằng Icarus Verilog.** Testbench pe_sparse_contract_tb.sv so datapath bypass với phép tính tích lũy độc lập ở mỗi chu kỳ và so build có cut với kết quả tham chiếu trước đó một chu kỳ. Kết quả PASS 71.683 lần cập nhật, gồm 65.536 tổ hợp tích một lane, 6.144 bước hai lane phủ sáu cặp selector, hai bước biên +32.768/-32.512 và một bước xả. Testbench khởi tạo nội bộ probe vì mô hình cô lập không có reset. Bằng chứng này chỉ áp dụng cho đường số học no-stall của PE probe. Kiểm tra giao thức, drain, reset và timing của IP vẫn cần bằng chứng riêng.

Chạy trong project_support/review/tensor_probes:

```text
iverilog -g2012 -s pe_sparse_contract_tb -o sparse_probe.vvp pe_variants.sv pe_sparse_contract_tb.sv
vvp sparse_probe.vvp
```
