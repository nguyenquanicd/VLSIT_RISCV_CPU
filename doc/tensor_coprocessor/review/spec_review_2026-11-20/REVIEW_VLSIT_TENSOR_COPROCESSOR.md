# Specification review — VLSIT Tensor Coprocessor / Đánh giá đặc tả — VLSIT Tensor Coprocessor

| Field / Trường | Value / Giá trị |
|---|---|
| IP | VLSIT Tensor Coprocessor |
| Specification reviewed | `doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md` |
| Revision and date | version field 0.1 (file edited 2026-11-20) |
| Reviewer | Claude (vlsit-ip-spec-review skill) |
| Review date | 2026-11-20 |
| Verdict / Kết luận | **Conditional** (weighted score 2.95 of 5, one Blocker) |

Precedence: `rule.md` overrides `SKILL.md`, and `SKILL.md` overrides the files under `reference/`, when they differ. / `rule.md` ưu tiên hơn `SKILL.md`, và `SKILL.md` ưu tiên hơn các file trong `reference/` khi có khác biệt.

## 1. Executive summary / Tóm tắt điều hành

**EN.** The specification defines a CV-X-IF tensor coprocessor for transformer inference: GEMM, exact and linear attention, softmax, layer normalization, 2:4 sparse GEMM and greedy-token argmax, with AXI4 DMA to banked SRAM and an optional APB4 CSR block. It is unusually complete for a pre-RTL document: 62 requirements trace to 50 tests and 35 properties, numeric contracts are fixed per operation and most findings of the 2026-11-17 reviews are closed. The verdict is **Conditional** with a weighted score of 2.95. One Blocker stands: the commit frontier that the IP relies on needs a CVA6 change that the specification itself lists as an unmapped P0 item (F-001). The most important actions are to map and specify that host change, to base the 2 GHz and 64 TOPS goals on a chosen technology, a processing-element experiment and a sustained-throughput target (F-002, F-003), and to supply the numeric latency targets (F-004).

**VI.** Đặc tả định nghĩa coprocessor tensor CV-X-IF cho suy luận transformer: GEMM, attention exact và linear, softmax, layer normalization, GEMM sparse 2:4 và argmax chọn token, với DMA AXI4 tới SRAM chia bank và khối CSR APB4 tùy chọn. Đặc tả đầy đủ bất thường so với tài liệu trước RTL: 62 requirement truy vết tới 50 test và 35 property, hợp đồng số học cố định theo operation và phần lớn phát hiện của các review ngày 2026-11-17 đã đóng. Kết luận là **Conditional** với điểm trọng số 2.95. Còn một Blocker: frontier commit mà IP dựa vào cần thay đổi CVA6 mà chính đặc tả liệt kê là mục P0 chưa ánh xạ (F-001). Các việc quan trọng nhất là ánh xạ và đặc tả thay đổi host đó, đặt mục tiêu 2 GHz và 64 TOPS trên công nghệ đã chọn, thí nghiệm processing element và mục tiêu thông lượng duy trì (F-002, F-003), và cung cấp mục tiêu latency dạng số (F-004).

### 1.1 Top findings / Phát hiện quan trọng nhất

| ID | Severity | Area | Finding (EN) | Phát hiện (VI) | Locator |
|---|---|---|---|---|---|
| F-001 | Blocker | integration_effort | FACT: The host commit frontier the IP depends on has no mapped CVA6 implementation | Frontier commit của host mà IP phụ thuộc chưa có hiện thực CVA6 được ánh xạ | §20.1 RV-017, §3.1 REQ-IF-006, REQ-IF-007 |
| F-002 | Major | asic_feasibility | INFERENCE: The 2 GHz goal has no technology basis and shares the host clock | Mục tiêu 2 GHz không có cơ sở công nghệ và dùng chung clock với host | §13 PPA-001, §7.1, §1.2 |
| F-003 | Major | performance | FACT: 64 TOPS peak has no sustained target and the first memory path is one 256-bit AXI port | Đỉnh 64 TOPS không có mục tiêu duy trì và đường nhớ đầu tiên là một cổng AXI 256 bit | §13 PPA-004, PPA-007, §6.1.1 |
| F-004 | Major | performance | FACT: Latency and tokens-per-second targets are still TBD | Mục tiêu latency và token mỗi giây vẫn là TBD | §20.1 RV-002, §13 PPA-005, PPA-006, PPA-010 |
| F-011 | Major | clock_reset_cdc | INFERENCE: The OP-003 zero-result fence stalls every hart across an asynchronous round trip | Fence kết quả bằng 0 của OP-003 làm dừng mọi hart qua một vòng không đồng bộ | §3.1 REQ-ERR-004, §7.2 CDC-005, CDC-006 |

## 2. Scorecard / Bảng điểm

| Area | Weight | Score | Justification |
|---|---:|---:|---|
| application_fit | 1.0 | 3 | The product context is an on-device LLM and vision-transformer edge SoC with named workloads, but §1.2 leaves target shapes and the accuracy and latency envelope open and the 64 TOPS headline is far above Arm's published edge NPU range. |
| features | 1.0 | 4 | Nine FEAT rows map to requirements and three configurations (CFG-BASE, CFG-FULL, CFG-64TOPS) tie features to interfaces; only the analytical-only status of CFG-64TOPS weakens it. |
| functions | 1.5 | 4 | Each operation has a numeric contract down to rounding order (DEC-053 to DEC-070); only Minor points remain: the occupancy of the fused batch-one projection (3.125 percent in RV-016) is unmeasured and one active command owns all arrays. |
| interfaces | 1.5 | 3 | CV-X-IF, AXI4 DMA, APB4 and IF-006 SRAM banks are defined, but the normative CV-X-IF revision is a development release and the packed-port assumption ASM-002 is open. |
| clock_reset_cdc | 1.5 | 3 | Two clock domains, eight numbered crossings and a quiesce-and-drain reset sequence are specified; the OP-003 zero-result fence adds a core to APB to software round trip to a global issue stall. |
| parameters | 1.0 | 4 | Every operation has finite elaboration-time caps with checked arithmetic and illegal combinations are rejected; the port list and AXI sizing are still candidates. |
| data_representation | 0.5 | 4 | INT8, BF16, FP16 and FP32 behaviour, accumulator bounds, requantization and rounding order are fixed per operation. |
| asic_feasibility | 1.5 | 2 | The 2 GHz point has no technology, library or experiment behind it and shares the clock with the CVA6 host; MAC-array structure gives a large flop proxy. |
| sdc_timing | 1.5 | 2 | §17.1 gives clock names and exceptions, but every interface budget is integrator-supplied or TBD, including the AXI data path. |
| area_power | 1.0 | 2 | PPA-002 and PPA-003 are qualitative and the power goal conflicts with a no-clock-gating rule. |
| performance | 1.5 | 2 | Peak TOPS and roofline arithmetic are given, but latency, tokens per second and sustained utilization targets are TBD and the first AXI path is one 256-bit port. |
| software_ease | 1.0 | 4 | Fixed 64-byte-header descriptors with versioned schemas, a generator for the layout constants and a first-error CSR record give a workable driver model. |
| dft | 1.0 | 3 | Scan, MBIST and wrapper hooks are stated, but the no-ICG decision removes the usual power lever and ATPG constraints are left to the DFT team. |
| security_ras | 1.0 | 3 | S/M-mode gating, a fixed DMA aperture and a first-error record are specified; recovery from a missing response is a full SoC reset, ECC is optional and multi-tenant isolation is open. |
| verification_quality | 1.5 | 4 | 62 requirements trace to 50 tests and 35 properties with a stated reproducible-seed strategy; coverage thresholds are absent and no RTL exists yet. |
| documentation | 0.5 | 3 | Identifiers and decisions are stable, but the version field is still 0.1, there is no revision history and the document is about 4,400 very long lines. |
| integration_effort | 1.0 | 1 | The safe-commit frontier needs host CVA6 changes that the specification itself lists as an unmapped P0 item. |
| market_position | 1.0 | 3 | A CV-X-IF systolic coprocessor is a recognized pattern (Gemmini over RoCC, Arm Ethos-U85 on an AXI/CHI-class interface); the PPA claim has no evidence against them. |
| **Weighted** | **20.5** | **2.95** | **Verdict: Conditional** |

**EN.** The two lowest areas are integration effort (score 1, the Blocker) and ASIC feasibility, SDC and timing, area and power and performance (score 2 each): the host change is unmapped and the 2 GHz and 64 TOPS goals have no technology, budget or sustained-throughput basis.

**VI.** Hai vùng thấp nhất là công sức tích hợp (1 điểm, là Blocker) và khả thi ASIC, SDC và timing, diện tích và công suất, hiệu năng (2 điểm mỗi vùng): thay đổi host chưa được ánh xạ và mục tiêu 2 GHz và 64 TOPS không có cơ sở công nghệ, ngân sách hay thông lượng duy trì.

## 3. Application fit / Phù hợp ứng dụng

**EN.** The IP serves transformer inference on an edge SoC (LLM decode and prefill, vision transformers), with the CVA6 host issuing custom instructions over CV-X-IF and a separate AXI4 DMA to banked SRAM. Included and excluded scope is explicit. The target shapes, accuracy and latency envelope are open and the sizing headline is 64 TOPS. Score: 3 of 5. The product context is an on-device LLM and vision-transformer edge SoC with named workloads, but §1.2 leaves target shapes and the accuracy and latency envelope open and the 64 TOPS headline is far above Arm's published edge NPU range.

**VI.** IP phục vụ suy luận transformer trên edge SoC (decode và prefill LLM, vision transformer), host CVA6 phát lệnh custom qua CV-X-IF và DMA AXI4 riêng tới SRAM chia bank. Phạm vi bao gồm và loại trừ rõ ràng. Target shape, độ chính xác và envelope latency còn mở và headline định cỡ là 64 TOPS. Điểm: 3 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-019 | Major | §1.2, §1.4 FEAT-002, FEAT-006 | INFERENCE: §1.2 says target shapes and the accuracy and latency envelope remain open, yet FEAT-002 and FEAT-006 size the IP at 65.536 TOPS and up to 2.048 TB/s on-chip injection; Arm's edge NPU Ethos-U85 is published at 128 to 2048 MACs per cycle, 256 GOPS to 4 TOPS at 1 GHz with transformer support, so the stated target is 16 times larger than that edge class. | INFERENCE: §1.2 nói target shape và envelope độ chính xác và latency còn mở, nhưng FEAT-002 và FEAT-006 định cỡ IP ở 65,536 TOPS và tới 2,048 TB/s cấp on-chip; NPU edge Ethos-U85 của Arm được công bố 128 đến 2048 MAC mỗi chu kỳ, 256 GOPS đến 4 TOPS ở 1 GHz có hỗ trợ transformer, nên mục tiêu nêu ra lớn gấp 16 lần lớp edge đó. | Tie the array count to a named model and an SoC power and area budget. |

## 4. Features / Tính năng

**EN.** FEAT-001 to FEAT-009 each map to requirements, and CFG-BASE, CFG-FULL and CFG-64TOPS tie features to interfaces and sizes. CFG-64TOPS is labelled analytical only. Score: 4 of 5. Nine FEAT rows map to requirements and three configurations (CFG-BASE, CFG-FULL, CFG-64TOPS) tie features to interfaces; only the analytical-only status of CFG-64TOPS weakens it.

**VI.** FEAT-001 đến FEAT-009 đều ánh xạ tới requirement, và CFG-BASE, CFG-FULL, CFG-64TOPS gắn feature với interface và kích thước. CFG-64TOPS được ghi là chỉ phân tích. Điểm: 4 trên 5.

No finding in this chapter; the score reflects the evidence in the specification. / Chương này không có phát hiện; điểm phản ánh bằng chứng trong đặc tả.

## 5. Functions and cycle behaviour / Chức năng và hành vi theo chu kỳ

**EN.** Operations OP-001 to OP-009 (GEMM, element-wise, reduce, argmax, exact attention, softmax, layer norm, 2:4 sparse GEMM, linear attention) have descriptor schemas and a numeric contract down to rounding order. The occupancy of the fused projection for decode and the single-active-command scheduler remain open points. Score: 4 of 5. Each operation has a numeric contract down to rounding order (DEC-053 to DEC-070); only Minor points remain: the occupancy of the fused batch-one projection (3.125 percent in RV-016) is unmeasured and one active command owns all arrays.

**VI.** Các operation OP-001 đến OP-009 (GEMM, element-wise, reduce, argmax, exact attention, softmax, layer norm, sparse GEMM 2:4, linear attention) có schema descriptor và hợp đồng số học đến thứ tự rounding. Occupancy của phép chiếu fused cho decode và scheduler một lệnh đang chạy vẫn là điểm còn mở. Điểm: 4 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-009 | Minor | §20.1 RV-016, §10 line 1572, DEC-073, REQ-FUNC-010 | FACT: A matrix-vector and small-M dataflow profile exists (REQ-FUNC-010, §10 line 1972), but RV-016 (Critical) notes that a 1 by K by K by V projection on a 32-row output-stationary mapping occupies one PE row (3.125 percent) and DEC-073 leaves the build tile geometry and latency evidence open, so the occupancy of the fused OP-004 build is not defined. | FACT: Đã có profile dataflow matrix-vector và small-M (REQ-FUNC-010, §10 dòng 1972), nhưng RV-016 (Critical) nêu phép chiếu 1 x K nhân K x V trên mapping output-stationary 32 hàng chỉ dùng một hàng PE (3,125 phần trăm) và DEC-073 để mở hình học tile và bằng chứng latency của bản build, nên occupancy của build OP-004 fused chưa được xác định. | Characterize the fused dataflow (direct, split-K or vector lanes) and state its occupancy before the ABI freeze. |
| F-010 | Minor | §20.2 DEC-006, §20.1 RV-003 | INFERENCE: The first release schedules one active command across all arrays and hands over at completion; row softmax, layer normalization and argmax are limited by exp, reciprocal and reduction lanes (PPA-008) while the MAC arrays are idle. | INFERENCE: Bản đầu lập lịch một lệnh đang chạy trên mọi array và chuyển tại thời điểm hoàn tất; row softmax, layer normalization và argmax bị giới hạn bởi lane exp, reciprocal và reduction (PPA-008) trong khi array MAC rảnh. | Report utilization per operation and decide when cross-command overlap is required. |
| F-022 | Observation | §13, §20.2 DEC-016, REQ-IF-007, PPA-010 | FACT: The roofline now separates 8.2 TOPS at T=128 from the 64 TOPS goal, the control FSM has ERR_DRAIN, the CSR record holds hart, ID and status, DEC-016 separates the tensor top from the cluster, and REQ-IF-007 and PPA-010 give an interrupt and debug handler-entry bound. | FACT: Roofline nay tách 8,2 TOPS ở T=128 khỏi mục tiêu 64 TOPS, FSM điều khiển có ERR_DRAIN, bản ghi CSR chứa hart, ID và status, DEC-016 tách top tensor khỏi cluster, và REQ-IF-007 cùng PPA-010 đưa ra ràng buộc handler-entry cho ngắt và debug. | Keep these and track the open items of F-001, F-004 and F-009. |

## 6. Interfaces and protocol / Giao diện và giao thức

**EN.** The interfaces are CV-X-IF (coupled issue and register, non-kill commit), AXI4 for tensor data, APB4 for the optional CSR block and IF-006 SRAM banks. The CV-X-IF memory interfaces are correctly not used. The protocol authority is a development release and the packed port list is still an assumption. Score: 3 of 5. CV-X-IF, AXI4 DMA, APB4 and IF-006 SRAM banks are defined, but the normative CV-X-IF revision is a development release and the packed-port assumption ASM-002 is open.

**VI.** Các interface gồm CV-X-IF (issue và register ghép, commit không kill), AXI4 cho dữ liệu tensor, APB4 cho khối CSR tùy chọn và bank SRAM IF-006. Các interface bộ nhớ của CV-X-IF được đúng là không dùng. Chuẩn giao thức là bản development và port list dạng packed vẫn là giả định. Điểm: 3 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-008 | Major | §2.1 REF-001, §2.3, §6 IF-001 | FACT: REF-001 names the Core-V eXtension interface Release v1.0.1-dev.0 (Development, 2024-05-23) as the protocol authority, while the locally converted reference is the v1.0.0 document (file vlsit_cvxif_openhw_core_v_xif_v1_0_0.md); the two can differ in clause numbers and behavior. | FACT: REF-001 gọi Core-V eXtension interface Release v1.0.1-dev.0 (Development, 2024-05-23) là chuẩn giao thức, trong khi bản chuyển đổi cục bộ là tài liệu v1.0.0 (file vlsit_cvxif_openhw_core_v_xif_v1_0_0.md); hai bản có thể khác số clause và hành vi. | Pin the ratified v1.0.0 or record the exact development commit and the differences. |

## 7. Clock, reset and CDC / Clock, reset và CDC

**EN.** There are two domains (CLK-CORE and the asynchronous CLK-APB) with eight numbered crossings (CDC-001 to CDC-008) and a quiesce-and-drain functional reset. Recovery from a missing response is a full SoC reset. The OP-003 fence adds a software round trip through APB. Score: 3 of 5. Two clock domains, eight numbered crossings and a quiesce-and-drain reset sequence are specified; the OP-003 zero-result fence adds a core to APB to software round trip to a global issue stall.

**VI.** Có hai miền (CLK-CORE và CLK-APB không đồng bộ) với tám crossing đánh số (CDC-001 đến CDC-008) và reset chức năng kiểu quiesce và drain. Phục hồi khi thiếu response là reset toàn SoC. Fence OP-003 thêm một vòng phần mềm qua APB. Điểm: 3 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-011 | Major | §3.1 REQ-ERR-004, §7.2 CDC-005, CDC-006 | INFERENCE: REQ-ERR-004 holds a global all-hart issue stall for an OP-003 result of zero until software reads and clears the error record and writes scalar_ack through APB (CDC-005, CDC-006); zero is a common result (a sum of zeros, a max after ReLU), so the slow path is frequent and a software error could hold the stall. | INFERENCE: REQ-ERR-004 giữ stall issue toàn bộ hart khi kết quả OP-003 bằng 0 cho đến khi phần mềm đọc và xóa error record và ghi scalar_ack qua APB (CDC-005, CDC-006); 0 là kết quả phổ biến (tổng các số 0, max sau ReLU), nên đường chậm xảy ra thường xuyên và lỗi phần mềm có thể giữ stall. | Measure the zero-result frequency and consider returning an error flag in the result instead. |

## 8. Parameters and data / Tham số và biểu diễn dữ liệu

**EN.** Every operation has finite elaboration-time caps (for example PARA_MAX_K of 16,384 for the first build) and checked arithmetic, illegal parameter combinations are rejected and the numeric formats, accumulator bounds and rounding order are fixed per operation (§9). Score: 4 of 5. Every operation has finite elaboration-time caps with checked arithmetic and illegal combinations are rejected; the port list and AXI sizing are still candidates.

**VI.** Mỗi operation có cap hữu hạn lúc elaboration (ví dụ PARA_MAX_K bằng 16.384 cho bản đầu) và phép tính có kiểm tra, tổ hợp tham số không hợp lệ bị từ chối và định dạng số, giới hạn accumulator và thứ tự rounding được cố định theo operation (§9). Điểm: 4 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-021 | Minor | §20.2 ASM-002, §6.2, §3.1 REQ-PARAM-004 | FACT: ASM-002 (packed CV-X-IF payload ports) is open, PPA-007 gives a 256-bit, 16-read, 8-write candidate and §17.1.2 marks IF-003 sizing TBD, so the top-level module boundary is not frozen even though the parameter caps are. | FACT: ASM-002 (port payload CV-X-IF dạng packed) còn mở, PPA-007 đưa ứng viên 256 bit, 16 read, 8 write và §17.1.2 đánh dấu kích thước IF-003 là TBD, nên ranh giới module top chưa được chốt dù các cap tham số đã chốt. | Freeze the port list and the AXI data-path sizing together. |

## 9. ASIC feasibility / Khả thi ASIC

**EN.** No technology or library is selected. The MAC array is a large flop and multiplier structure, the clock is shared with CVA6 and the 2 GHz point has no experiment. No structural CDC or RDC report was supplied and no RTL exists to synthesize. Score: 2 of 5. The 2 GHz point has no technology, library or experiment behind it and shares the clock with the CVA6 host; MAC-array structure gives a large flop proxy.

**VI.** Chưa chọn công nghệ hay library. Array MAC là cấu trúc flop và multiplier lớn, clock dùng chung với CVA6 và điểm 2 GHz không có thí nghiệm. Chưa có báo cáo CDC hay RDC cấu trúc và chưa có RTL để synthesis. Điểm: 2 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-002 | Major | §13 PPA-001, §7.1, §1.2 | INFERENCE: PPA-001 sets at least 1 GHz and a 2 GHz characterization point for CFG-64TOPS at an SS corner, while §1.2 selects no technology; the tensor datapath shares CLK-CORE with the CVA6 host (§7.1). The related cluster synthesis (ARM sc12 55LPx RVT, ss 1.08 V 125 C) measured a 3.40 ns CVA6 critical path, and a published GF22 FDX synthesis reports about 1.09 GHz at 0.72 V and -40 C, so the host alone bounds the clock. | INFERENCE: PPA-001 đặt tối thiểu 1 GHz và điểm khảo sát 2 GHz cho CFG-64TOPS ở corner SS, trong khi §1.2 chưa chọn công nghệ; datapath tensor dùng chung CLK-CORE với host CVA6 (§7.1). Synthesis cluster liên quan (ARM sc12 55LPx RVT, ss 1,08 V 125 C) đo đường dài nhất CVA6 là 3,40 ns, và một synthesis GF22 FDX đã công bố báo khoảng 1,09 GHz ở 0,72 V và -40 C, nên riêng host đã giới hạn clock. | Choose the technology and corner, and gate the accumulator-loop architecture on a processing-element experiment. |

## 10. SDC and timing / SDC và timing

**EN.** §17.1 names CLK-CORE and CLK-APB, two exceptions for the asynchronous control and payload crossings, and a rule to keep payload checks active. Periods, interface budgets and the AXI data path are left to the integrator or TBD. Score: 2 of 5. §17.1 gives clock names and exceptions, but every interface budget is integrator-supplied or TBD, including the AXI data path.

**VI.** §17.1 nêu CLK-CORE và CLK-APB, hai exception cho crossing điều khiển và payload không đồng bộ, và quy tắc giữ các kiểm tra payload. Period, ngân sách interface và đường dữ liệu AXI để cho integrator hoặc TBD. Điểm: 2 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-007 | Major | §17.1.2, §17.1.1 | FACT: §17.1.2 lists CV-X-IF and APB budgets as 'integrator' and the IF-003 tensor-data path as burst and width TBD with SDC after port sizing; CLK-CORE has no period or uncertainty. | FACT: §17.1.2 liệt kê ngân sách CV-X-IF và APB là 'integrator' và đường dữ liệu tensor IF-003 là burst và độ rộng TBD với SDC sau khi chốt kích thước port; CLK-CORE không có period hay uncertainty. | State a port-group budget as a percent of the period and the register-output rule. |

## 11. Area and power / Diện tích và công suất

**EN.** Area scales with array count, array size, precision and special-function units, and power is datapath-active only, without numbers. A structural proxy gives at least 524,288 accumulator flops for the 64 TOPS point. Score: 2 of 5. PPA-002 and PPA-003 are qualitative and the power goal conflicts with a no-clock-gating rule.

**VI.** Diện tích tỷ lệ với số array, kích thước array, độ chính xác và khối hàm đặc biệt, và công suất là chỉ datapath active, không có số. Proxy cấu trúc cho ít nhất 524.288 flop accumulator ở điểm 64 TOPS. Điểm: 2 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-005 | Major | §13 PPA-002, PPA-003 | INFERENCE: PPA-002 and PPA-003 are qualitative. As a structural proxy, 16 arrays of 32 by 32 PEs hold 16,384 accumulators of 32 bits, so at least 524,288 accumulator flops; using the 10.56 um2 average sequential cell of the supplied ARM sc12 55LPx RVT synthesis this is about 5.5 mm2 before multipliers, operand registers and SRAM (proxy, not a mapped number for this design). | INFERENCE: PPA-002 và PPA-003 chỉ định tính. Theo proxy cấu trúc, 16 array 32 x 32 PE có 16.384 accumulator 32 bit, tức ít nhất 524.288 flop accumulator; dùng sequential cell trung bình 10,56 um2 của synthesis ARM sc12 55LPx RVT đã cấp thì khoảng 5,5 mm2 chưa tính multiplier, thanh ghi operand và SRAM (proxy, không phải số mapped của thiết kế này). | Add a structural area table and a power estimation method with assumptions. |

## 12. Performance and throughput / Hiệu năng và thông lượng

**EN.** The specification gives peak arithmetic (65.536 TOPS ideal), a roofline with tile arithmetic intensity and worked exp-lane sizing, and a measurement method for percentiles and conditional bounds. Latency, tokens per second and sustained utilization targets are TBD. Score: 2 of 5. Peak TOPS and roofline arithmetic are given, but latency, tokens per second and sustained utilization targets are TBD and the first AXI path is one 256-bit port.

**VI.** Đặc tả đưa ra tính toán đỉnh (65,536 TOPS lý tưởng), roofline với arithmetic intensity theo tile và ví dụ định cỡ lane exp, và phương pháp đo percentile và cận có điều kiện. Mục tiêu latency, token mỗi giây và utilization duy trì là TBD. Điểm: 2 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-003 | Major | §13 PPA-004, PPA-007, §6.1.1 | FACT: PPA-004 states an ideal peak of 65.536 TOPS (16 arrays of 32 by 32 at 2 GHz) and FEAT-006 says it needs up to 2.048 TB/s of on-chip operand injection; PPA-007 gives the first target as one 256-bit AXI port with minimum SoC bandwidth, SRAM and arbitration left to sign-off, and §6.1.1 says the port does not sustain 64 TOPS for every workload. | FACT: PPA-004 nêu đỉnh lý tưởng 65,536 TOPS (16 array 32 x 32 ở 2 GHz) và FEAT-006 nói cần tới 2,048 TB/s cấp operand on-chip; PPA-007 đặt mục tiêu đầu tiên là một cổng AXI 256 bit với băng thông SoC tối thiểu, SRAM và arbitration để lại cho sign-off, và §6.1.1 nói cổng này không duy trì 64 TOPS cho mọi workload. | Add a sustained-throughput requirement per workload and the bandwidth it implies. |
| F-004 | Major | §20.1 RV-002, §13 PPA-005, PPA-006, PPA-010 | FACT: RV-002 (Critical) says numeric latency targets remain TBD and its follow-up asks the team to supply them; PPA-005, PPA-006 and PPA-010 only define what to report, and the earlier 50 ms per token figure is called a preliminary example. | FACT: RV-002 (Critical) nói mục tiêu latency dạng số vẫn TBD và follow-up yêu cầu team cung cấp; PPA-005, PPA-006 và PPA-010 chỉ định nghĩa cần báo cáo gì, và con số 50 ms mỗi token trước đây được gọi là ví dụ sơ bộ. | Set numeric TTFT, inter-token and handler-entry targets for a named model. |

## 13. Software and application ease / Dễ lập trình và ứng dụng

**EN.** A driver builds a descriptor with a 64-byte header (magic TCOP, schema 1.0) and a fixed per-operation body, issues one custom-0 instruction and reads a first-error CSR record; the layout constants are generated from descriptor_layout.json. Cache maintenance and the global submission lock are driver duties. Score: 4 of 5. Fixed 64-byte-header descriptors with versioned schemas, a generator for the layout constants and a first-error CSR record give a workable driver model.

**VI.** Driver dựng descriptor có header 64 byte (magic TCOP, schema 1.0) và body cố định theo operation, phát một lệnh custom-0 và đọc bản ghi lỗi đầu tiên trong CSR; hằng số layout được sinh từ descriptor_layout.json. Cache maintenance và khóa submit toàn cục là việc của driver. Điểm: 4 trên 5.

No finding in this chapter; the score reflects the evidence in the specification. / Chương này không có phát hiện; điểm phản ánh bằng chứng trong đặc tả.

## 14. DFT / DFT

**EN.** Scan insertion without latches, a test reset override, MBIST for MEM-001 SRAM and wrapper hooks are stated; ATPG constraints belong to the DFT team. The no-clock-gating rule removes the standard idle-power lever. Score: 3 of 5. Scan, MBIST and wrapper hooks are stated, but the no-ICG decision removes the usual power lever and ATPG constraints are left to the DFT team.

**VI.** Đã nêu scan insertion không có latch, test reset override, MBIST cho SRAM MEM-001 và hook wrapper; ràng buộc ATPG thuộc team DFT. Quy tắc không clock gating bỏ đi đòn bẩy công suất rảnh thông thường. Điểm: 3 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-006 | Major | §16, §7.1, §13 PPA-003 | FACT: §7.1 and §16 state there is no internal clock gating and the clock-gating test enable is N/A, while PPA-003 sets the power goal as datapath-active only; an array of 16,384 MACs that is idle between commands would still toggle its clock tree. | FACT: §7.1 và §16 nêu không có clock gating bên trong và test enable cho clock gating là N/A, trong khi PPA-003 đặt mục tiêu công suất là chỉ datapath active; array 16.384 MAC không hoạt động giữa các lệnh vẫn toggle cây clock. | Allow approved ICG cells with a test-enable port or require operand isolation, and align PPA-003. |

## 15. Security and RAS / An toàn và độ tin cậy

**EN.** Tensor instructions are gated to S and M mode by the host, DMA is bounded by a fixed BASE and LIMIT aperture, and the first command error is retained in a CSR record. ECC is optional, multi-tenant isolation is open and a missing response requires a full SoC reset. Score: 3 of 5. S/M-mode gating, a fixed DMA aperture and a first-error record are specified; recovery from a missing response is a full SoC reset, ECC is optional and multi-tenant isolation is open.

**VI.** Lệnh tensor chỉ cho S và M mode do host kiểm, DMA bị giới hạn bởi aperture BASE và LIMIT cố định, và lỗi lệnh đầu tiên được giữ trong bản ghi CSR. ECC là tùy chọn, cô lập đa tenant còn mở và thiếu response cần reset toàn SoC. Điểm: 3 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-012 | Major | §20.1 RV-022, §20.2 DEC-029, REQ-RESET-002 | FACT: AXI4 has no cancel for an accepted transaction; the user rejected tensor-local abort and DEC-029 selects full SoC reset after a watchdog timeout, with the host waiting on a pending result in the meantime. | FACT: AXI4 không có hủy cho transaction đã nhận; người dùng đã bác tensor-local abort và DEC-029 chọn reset toàn SoC sau timeout của watchdog, trong lúc đó host chờ result đang treo. | Keep the approved decision and require a SoC watchdog and interrupt path. |
| F-013 | Minor | §18, §20.2 DEC-025 | FACT: §18 lists 'optional parity on MEM-001' with simulation as the check and no ECC requirement for the banks that hold weights, accumulators or recurrent state, and no error-injection requirement for them. | FACT: §18 liệt kê 'parity tùy chọn trên MEM-001' với simulation là cách kiểm và không có yêu cầu ECC cho các bank giữ weight, accumulator hay trạng thái recurrent, cũng không có yêu cầu error-injection. | Decide the protection level per memory. |
| F-014 | Minor | §18, §20.2 DEC-025, REQ-SEC-002, REQ-SEC-003 | FACT: The DMA firewall is an immutable BASE and LIMIT aperture and the spec states it does not isolate S-mode code or two U-mode clients; §18 marks information leakage open for multi-tenant operation and a single global CSR record exposes physical error addresses. | FACT: Firewall DMA là aperture BASE và LIMIT bất biến và spec nêu nó không cô lập mã S-mode hay hai client U-mode; §18 đánh dấu rò rỉ thông tin là mở cho vận hành đa tenant và một CSR record toàn cục lộ địa chỉ vật lý khi lỗi. | State single-tenant as the supported scope or specify per-client isolation. |

## 16. Verification quality / Chất lượng kiểm chứng

**EN.** 62 requirements trace to 50 tests and 35 properties, with independent reference models, reproducible seeds and per-configuration targets. There are no coverage thresholds and no RTL exists, so nothing has run. Score: 4 of 5. 62 requirements trace to 50 tests and 35 properties with a stated reproducible-seed strategy; coverage thresholds are absent and no RTL exists yet.

**VI.** 62 requirement truy vết tới 50 test và 35 property, có model tham chiếu độc lập, seed tái lập và mục tiêu theo cấu hình. Chưa có ngưỡng coverage và chưa có RTL nên chưa gì được chạy. Điểm: 4 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-015 | Minor | §15.3, §15.2 | FACT: The specification has 35 properties (for example SVA-001) and cover points but no section sets a line, toggle, functional or assertion-coverage threshold. | FACT: Đặc tả có 35 property (ví dụ SVA-001) và cover point nhưng không mục nào đặt ngưỡng coverage line, toggle, functional hoặc assertion. | Set coverage thresholds per release configuration. |
| F-016 | Observation | §4 CFG-BASE, CFG-FULL, CFG-64TOPS | FACT: The configuration table states 'Planned; simulation/lint have not run because tensor RTL is absent' for CFG-BASE and 'Analytical only' for CFG-64TOPS, so the 76 decisions and 62 requirements have not been exercised. | FACT: Bảng cấu hình ghi 'Planned; simulation/lint have not run because tensor RTL is absent' cho CFG-BASE và 'Analytical only' cho CFG-64TOPS, nên 76 decision và 62 requirement chưa được thử nghiệm. | Record this as the status of the review. |

## 17. Documentation and traceability / Tài liệu và truy vết

**EN.** Requirement, decision, test and property identifiers are stable and every operation has a companion instruction-set document. The version field is 0.1, the file is long and prior reviews are not re-baselined. Score: 3 of 5. Identifiers and decisions are stable, but the version field is still 0.1, there is no revision history and the document is about 4,400 very long lines.

**VI.** Mã requirement, decision, test và property ổn định và mỗi operation có tài liệu instruction-set đi kèm. Trường version là 0.1, file dài và các review trước chưa được đối chiếu lại. Điểm: 3 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-017 | Minor | front matter line 6, §20.1 | FACT: The front matter still says version 0.1 and no revision history exists although the document grew to 76 decisions; §20.1 embeds a review-findings table (RV-001 to RV-022) in the normative text, and the file has about 4,400 lines averaging more than 200 characters. | FACT: Front matter vẫn ghi version 0.1 và không có lịch sử revision dù tài liệu đã lên 76 decision; §20.1 nhúng bảng phát hiện review (RV-001 đến RV-022) trong văn bản chuẩn, và file có khoảng 4.400 dòng, trung bình hơn 200 ký tự mỗi dòng. | Add a revision table and move the review table to a separate file. |
| F-018 | Minor | README.md Review row, doc/tensor_coprocessor/review | FACT: The README links the 2026-11-17 review and the architecture-options analysis but not the re-review, and the 2026-11-17 re-review cites an HDS of 1,743 lines while the file now has 4,356 lines; the status of each earlier finding is not recorded in the specification. | FACT: README liên kết review 2026-11-17 và phân tích lựa chọn kiến trúc nhưng không liên kết re-review, và re-review 2026-11-17 dẫn HDS 1.743 dòng trong khi file nay có 4.356 dòng; trạng thái từng phát hiện trước đó không được ghi trong đặc tả. | Link the re-review and record a status per earlier finding. |

## 18. Integration effort and bring-up / Công sức tích hợp và bring-up

**EN.** The integrator needs a modified CVA6 (safe commit frontier, kill, interrupt latch), a DMA firewall with fixed BASE and LIMIT, an SRAM macro binding for IF-006, a watchdog and the cache-maintenance driver. The host-side change is not mapped to signals yet. Score: 1 of 5. The safe-commit frontier needs host CVA6 changes that the specification itself lists as an unmapped P0 item.

**VI.** Người tích hợp cần CVA6 đã sửa (frontier commit an toàn, kill, latch ngắt), firewall DMA với BASE và LIMIT cố định, binding macro SRAM cho IF-006, watchdog và driver cache-maintenance. Thay đổi phía host chưa được ánh xạ tới tín hiệu. Điểm: 1 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-001 | Blocker | §20.1 RV-017, §3.1 REQ-IF-006, REQ-IF-007 | FACT: REQ-IF-006 and REQ-IF-007 require a per-hart, age-ordered fault-resolved commit frontier and a kill rule; RV-017 states the signal mapping and host RTL remain P0, and the pinned CVA6 driver emits commit from issue-valid and ready with commit_kill tied to zero, so DMA could start before an older load or branch fault. | FACT: REQ-IF-006 và REQ-IF-007 yêu cầu frontier commit theo tuổi, đã giải quyết fault, và quy tắc kill cho từng hart; RV-017 nêu ánh xạ tín hiệu và RTL host vẫn là P0, và driver CVA6 đã pin phát commit từ issue-valid và ready với commit_kill nối 0, nên DMA có thể bắt đầu trước khi load hoặc branch cũ hơn gây fault. | Specify the CVA6 change as a requirement with its signal map before RTL start. |

## 19. Market position / Vị thế thị trường

**EN.** Arm's Ethos-U85 is a configurable edge NPU with transformer support and Gemmini is an open systolic generator on RoCC; this IP differs by using CV-X-IF with a fixed-schema descriptor ABI and a broad operation set. Sources and dates are listed in the appendix. Score: 3 of 5. A CV-X-IF systolic coprocessor is a recognized pattern (Gemmini over RoCC, Arm Ethos-U85 on an AXI/CHI-class interface); the PPA claim has no evidence against them.

**VI.** Ethos-U85 của Arm là NPU edge cấu hình được có hỗ trợ transformer và Gemmini là generator systolic mã nguồn mở trên RoCC; IP này khác ở chỗ dùng CV-X-IF với ABI descriptor schema cố định và tập operation rộng. Nguồn và ngày nằm ở phụ lục. Điểm: 3 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-020 | Major | §1.4, §13 PPA-004, PPA-006 | INFERENCE: Arm states the Ethos-U85 reaches 4 TOPS in silicon in a 2048-MAC configuration; the open Gemmini generator offers a 16 by 16 systolic array of 512 ops per cycle over RoCC and a configuration study estimates 41.49 percent of peak for one workload. This specification gives peak only, with no sustained, area or power evidence to place it against them. | INFERENCE: Arm nêu Ethos-U85 đạt 4 TOPS trên silicon ở cấu hình 2048 MAC; generator mã nguồn mở Gemmini có array systolic 16 x 16 (512 ops mỗi chu kỳ) qua RoCC và một nghiên cứu cấu hình ước tính 41,49 phần trăm đỉnh cho một workload. Đặc tả này chỉ nêu đỉnh, không có bằng chứng duy trì, diện tích hay công suất để đặt cạnh chúng. | Add a comparison row set with sustained utilization and area per TOPS once available. |

## 20. Actions / Hành động

**EN.** Priority P0 blocks integration, P1 should close before RTL freeze, P2 improves the specification. Gate: `RESULT: PASS` after waiver W-2 of F-001 on 2026-11-21 (before it: FAIL on the unwaived Critical F-001); waiver usage 2/10. The audit sample, the false-positive and false-negative rates and the traced findings are in the appendix.

**VI.** P0 chặn tích hợp, P1 nên đóng trước khi đóng băng RTL, P2 cải thiện đặc tả. Gate: `RESULT: PASS` sau waiver W-2 cho F-001 ngày 2026-11-21 (trước đó FAIL vì F-001 Critical chưa waive); mức dùng waiver 2/10. Mẫu audit, tỷ lệ false-positive và false-negative và các phát hiện đã truy vết nằm trong phụ lục.

| Priority | Action | Owner | Evidence |
|---|---|---|---|
| P0 | Specify the CVA6 change as a requirement with its signal map before RTL start. | CVA6 integration | F-001 |
| P1 | Choose the technology and corner, and gate the accumulator-loop architecture on a processing-element experiment. | Architect | F-002 |
| P1 | Add a sustained-throughput requirement per workload and the bandwidth it implies. | Architect | F-003 |
| P1 | Set numeric TTFT, inter-token and handler-entry targets for a named model. | Architect / Product | F-004 |
| P1 | Add a structural area table and a power estimation method with assumptions. | Spec | F-005 |
| P1 | Allow approved ICG cells with a test-enable port or require operand isolation, and align PPA-003. | Architect / DFT | F-006 |
| P1 | State a port-group budget as a percent of the period and the register-output rule. | Architect | F-007 |
| P1 | Pin the ratified v1.0.0 or record the exact development commit and the differences. | Spec | F-008 |
| P1 | Measure the zero-result frequency and consider returning an error flag in the result instead. | Architect | F-011 |
| P1 | Keep the approved decision and require a SoC watchdog and interrupt path. | SoC architect | F-012 |
| P1 | Tie the array count to a named model and an SoC power and area budget. | Product / Architect | F-019 |
| P1 | Add a comparison row set with sustained utilization and area per TOPS once available. | Product | F-020 |
| P2 | Characterize the fused dataflow (direct, split-K or vector lanes) and state its occupancy before the ABI freeze. | Architect | F-009 |
| P2 | Report utilization per operation and decide when cross-command overlap is required. | Architect | F-010 |
| P2 | Decide the protection level per memory. | Architect | F-013 |
| P2 | State single-tenant as the supported scope or specify per-client isolation. | Security / Architect | F-014 |
| P2 | Set coverage thresholds per release configuration. | Verification | F-015 |
| P2 | Add a revision table and move the review table to a separate file. | Spec | F-017 |
| P2 | Link the re-review and record a status per earlier finding. | Spec | F-018 |
| P2 | Freeze the port list and the AXI data-path sizing together. | Architect | F-021 |

## 21. Evidence appendix / Phụ lục bằng chứng

**EN.** The tables list the reviewed files, what could not be assessed, the gate result, the root-cause groups and the audit of the review. Open items and requirement counts come from `inventory.json`.

**VI.** Các bảng liệt kê file đã xem, phần chưa đánh giá được, kết quả gate, nhóm theo root cause và audit của chính review. Số open item và requirement lấy từ `inventory.json`.

### 21.1 Folder inventory and files reviewed / File đã xem

| Item | Detail |
|---|---|
| Specification | `doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md` (4,356 lines, 69 sections, 98 tables, 62 requirements, 50 tests, 35 properties, 76 decisions, 7 open items) |
| Companion files | `TENSOR_COPROCESSOR_INSTRUCTION_SET.md` (478 lines, referenced and sampled), `TENSOR_COPROCESSOR_CSR.xlsx` and `tcop_regs.json` (listed, not opened), `descriptor_layout.json` (listed), `figures/` (listed), `README.md` (read), `reference/` (listed) |
| Earlier reviews read | `review/VLSIT_TENSOR_COPROCESSOR_Rereview_2026-11-17.md` (first 120 lines), the other two files in `review/` (listed only) |
| Related evidence | `rtl/common/third_party/cva6/core/cvxif_issue_register_commit_if_driver.sv` (commit driver), the cluster synthesis report summarized in `doc/specification/review/VLSIT_RISCV_CPU_Consolidated_Review_2026-11-20.md` |

### 21.2 Open items / Mục mở

7 open items: ASM-001 to ASM-004 and DEP-001 to DEP-003; ASM-002 (packed CV-X-IF ports) is open and ASM-001 is partially resolved. The spec also carries a review table (RV-001 to RV-022) in §20.1 whose Critical rows RV-001, RV-002, RV-012 and RV-016 still ask for numeric targets or measurements. / 7 mục mở: ASM-001 đến ASM-004 và DEP-001 đến DEP-003; ASM-002 (port CV-X-IF dạng packed) còn mở và ASM-001 mới giải quyết một phần. Spec còn mang bảng review (RV-001 đến RV-022) ở §20.1, trong đó các dòng Critical RV-001, RV-002, RV-012 và RV-016 vẫn yêu cầu mục tiêu hoặc phép đo dạng số.

### 21.3 Not assessed / Chưa đánh giá

- Structural CDC and RDC: no tool report exists and no RTL exists. / Chưa có báo cáo CDC hoặc RDC và chưa có RTL.
- ASIC timing, area and power: no technology, library, SDC or synthesis run exists for this IP; the area figure is a proxy. / Chưa có công nghệ, library, SDC hay synthesis cho IP này; số diện tích là proxy.
- Numeric contracts (DEC-053 to DEC-070), descriptor byte maps and the instruction-set companion were sampled, not re-derived; no reference-model run was made. / Hợp đồng số học, byte map descriptor và tài liệu instruction-set được đọc mẫu, không tính lại; không chạy model tham chiếu.
- The CSR workbook, figures and waveforms were not opened. / Chưa mở workbook CSR, hình và waveform.
- Market comparison uses vendor pages, a paper and a repository, not datasheets; competitor area and power were not obtained. / So sánh thị trường dùng trang vendor, một paper và một repository, không có datasheet.
- No simulation or lint was run in this review. / Không chạy simulation hoặc lint trong review này.

### 21.4 Gate and waivers / Gate và waiver

`RESULT: PASS` from `vlsit_review_gate.py metrics` (re-run 2026-11-21 with W-2); findings 22; waiver usage 2/10; unwaived Critical 0; 100% of findings traced; closure rate 0.90. Waiver W-1: F-012 (owner SoC architect; invalidation: the SoC has no watchdog or full-reset path, or a product availability target forbids chip-wide reset). Waiver W-2: F-001 (owner Architect; invalidation: the modified CVA6 host RTL and the TEST-029 and TEST-030 evidence exist and show the HFC-1..HFC-9 contract holds, or the HFC contract is rejected). Granted by the project owner on 2026-11-21; the finding stays open (RV-017) and the waiver is not evidence that the host frontier works.

### 21.5 Root-cause groups / Nhóm root cause

| Group | Findings | Count |
|---|---|---|
| OP-003 fence | F-011 | 1 |
| area and power basis | F-005, F-006 | 2 |
| decode utilization | F-009, F-010 | 2 |
| documentation | F-017, F-018, F-022 | 3 |
| frequency and technology basis | F-002, F-007, F-021 | 3 |
| host integration | F-001 | 1 |
| recovery policy | F-012 | 1 |
| reliability | F-013, F-014 | 2 |
| standards and references | F-008 | 1 |
| unquantified performance | F-003, F-004, F-019, F-020 | 4 |
| verification evidence | F-015, F-016 | 2 |

Tracing depth (R-022): all 22 findings were traced to a file and line; no group has more than ten members, so none was aggregated without a trace. / Độ sâu truy vết (R-022): cả 22 phát hiện đều được truy tới file và dòng; không nhóm nào quá mười phần tử nên không có nhóm nào bị gộp mà không truy vết.

### 21.6 Review of the review / Audit của review

| Finding | Judgement | Basis |
|---|---|---|
| audit F-009 | tp after correction | The first draft said the decode mapping was unresolved and rated it Major; reading REQ-FUNC-010 and the matrix-vector profile at HDS line 1972 showed a small-M profile exists, so the finding was reworded to the unmeasured fused OP-004 occupancy (RV-016, DEC-073 open) and lowered to Minor. |
| audit F-003 | tp after correction | PPA-007, §6.1.1 line 794 and RV-001 confirm the one 256-bit AXI port and the absent sustained target; the 2.048 TB/s figure belongs to FEAT-006 (line 73), not PPA-004, and the citation was corrected. |
| audit F-010 | tp | DEC-006 and RV-003 state that the first release schedules one active command across all arrays and defers cross-command overlap; the idle-MAC consequence during exp, reciprocal and reduction work is labelled INFERENCE. |

False-positive rate 0 of 3 after correction (1 of 3 initially over-rated: F-009 severity); false-negative rate 0 of 3 (0%); no missed finding was found in the sampled areas. / Tỷ lệ false-positive 0 of 3 after correction (1 of 3 initially over-rated: F-009 severity); false-negative 0 of 3 (0%); no missed finding was found in the sampled areas.

### 21.7 Sources / Nguồn

| Statement | Source | Date accessed |
|---|---|---|
| Arm Ethos-U85: 128 to 2048 MACs, 256 GOPS to 4 TOPS at 1 GHz, native transformer support, 4 TOPS in silicon at 2048 MACs | https://newsroom.arm.com/blog/ethos-u85 | 2026-11-20 |
| Gemmini: RISC-V RoCC systolic array generator with banked scratchpad and DMA; 16 by 16 array of 512 ops per cycle peak; 41.49 percent of peak for one workload | https://github.com/ucb-bar/gemmini ; https://arxiv.org/pdf/2511.10397 | 2026-11-20 |
| CVA6 with HPDcache about 1090 MHz in GF22 FDX, worst case 0.72 V and -40 C, synthesis estimate | https://arxiv.org/html/2505.03762v2 | 2026-11-20 |
| OpenHW CV-X-IF v1.0.0 and v1.0.1-dev.0 | cited by the specification (REF-001); clause numbers not re-read | not re-read |

### 21.8 Status of F-001 after the P0 edit / Trạng thái F-001 sau khi sửa P0

EN: On 2026-11-20 the specification (`VLSIT_TENSOR_COPROCESSOR_HDS.md` §5.3.1, HFC-1..HFC-9, REQ-IF-006, RV-017) gained a signal-level host frontier contract built from the checked-in CVA6 sources (scoreboard slot equals CV-X-IF ID, per-class final-OK sources, squash boundary, registered authorization, driver ports, missing port-1 retirement ID). FACT: the text exists and cites source lines. FACT: no host RTL, simulation or designer approval exists. The finding stays open: its severity and the gate result `FAIL` are not changed by this edit, and the contract is labelled proposed. It would close only after the modified host RTL and the TEST-029/030 evidence exist.

VI: Ngày 2026-11-20 đặc tả (`VLSIT_TENSOR_COPROCESSOR_HDS.md` §5.3.1, HFC-1..HFC-9, REQ-IF-006, RV-017) được bổ sung hợp đồng tín hiệu cho host frontier, dựng từ source CVA6 đã checked-in (slot scoreboard chính là CV-X-IF ID, nguồn final-OK theo từng lớp lệnh, ranh giới squash, authorization lấy từ flop, cổng driver, thiếu ID retire của port 1). FACT: nội dung đã có và trích dẫn dòng source. FACT: chưa có RTL host, mô phỏng hay phê duyệt của designer. Phát hiện vẫn mở: mức độ và kết quả gate `FAIL` không đổi, hợp đồng ghi rõ là đề xuất. Chỉ đóng khi có RTL host đã sửa và bằng chứng TEST-029/030.

### 21.9 Defaults for the open decisions and figure changes / Mặc định cho các quyết định còn mở và thay đổi sơ đồ

EN: The specification now holds a default for each P1 item that needs a decision: HDS §20.3, TD-01 to TD-11 (evaluation corner and a 3.5 ns planning period with the 9.4 TOPS ideal peak that follows, a roofline definition of sustained throughput, latency as multiples of the roofline bound, an area proxy and power method, clock gating with a test enable, port budgets, the v1.0.0 CV-X-IF pin, zero-result measurement, watchdog timeout, CFG-BASE first, utilization-based comparison). FACT: each default is derived from numbers in the specification or the cluster evidence, and each states what replaces it. INFERENCE: the 9.4 TOPS figure is arithmetic at the planning period, not a measurement. A default is not an architect approval, so F-002 to F-008, F-011, F-012, F-019 and F-020 stay open until measured data and sign-off exist; the gate result is unchanged. Section 5.2.1 adds two lower-level diagrams (the adapter and the memory path), and three table regions that had a missing or extra cell were repaired (OP-001 and OP-008 rows of the datapath table; OP-006, OP-007 and OP-009 rows of the operation table).

VI: Đặc tả giờ có mặc định cho từng mục P1 cần quyết định: HDS §20.3, TD-01 đến TD-11 (corner đánh giá và chu kỳ kế hoạch 3,5 ns kèm đỉnh lý tưởng 9,4 TOPS suy ra, định nghĩa throughput duy trì theo roofline, latency theo bội số của cận roofline, proxy diện tích và phương pháp công suất, clock gating có test enable, ngân sách cổng, ghim CV-X-IF v1.0.0, đo tần suất kết quả bằng 0, timeout watchdog, CFG-BASE trước, so sánh theo mức dùng thực). FACT: mỗi mặc định suy ra từ số liệu trong đặc tả hoặc bằng chứng cluster và nêu cái sẽ thay thế nó. INFERENCE: con số 9,4 TOPS là phép tính ở chu kỳ kế hoạch, không phải số đo. Mặc định không phải phê duyệt của architect nên F-002 đến F-008, F-011, F-012, F-019, F-020 vẫn mở đến khi có số đo và chữ ký; kết quả gate không đổi. Mục 5.2.1 thêm hai sơ đồ mức thấp (adapter và đường bộ nhớ), và các vùng bảng thiếu hoặc thừa ô đã sửa (hàng OP-001 và OP-008 của bảng datapath; hàng OP-006, OP-007, OP-009 của bảng operation).


### 21.10 Owner decision of 2026-11-21 / Quyết định của chủ dự án ngày 2026-11-21

EN: The project owner decided that the defaults TD-01 to TD-11 are working decisions of the project, so their label changed from default to decided. The host frontier contract HFC-1..HFC-9 keeps its proposed status because the decision did not cover it. FACT: no RTL, simulation or synthesis result changed. A decided default is not a measured result, so the findings that depend on numbers (F-002 to F-008, F-011, F-012, F-019, F-020) stay open and the gate result is unchanged.

VI: Chủ dự án quyết định các mặc định TD-01 đến TD-11 là quyết định làm việc của dự án, nên nhãn đổi từ mặc định sang đã chốt. Hợp đồng host frontier HFC-1..HFC-9 giữ trạng thái đề xuất vì quyết định này không bao gồm nó. FACT: không có kết quả RTL, mô phỏng hay synthesis nào thay đổi. Mặc định đã chốt không phải số đo nên các phát hiện phụ thuộc số liệu (F-002 đến F-008, F-011, F-012, F-019, F-020) vẫn mở và kết quả gate không đổi.
