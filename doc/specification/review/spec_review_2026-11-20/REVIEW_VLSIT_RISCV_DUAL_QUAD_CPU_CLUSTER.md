# Specification review — VLSIT RISC-V Dual/Quad CPU Cluster / Đánh giá đặc tả — VLSIT RISC-V Dual/Quad CPU Cluster

| Field / Trường | Value / Giá trị |
|---|---|
| IP | VLSIT RISC-V Dual/Quad CPU Cluster |
| Specification reviewed | `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md` (revision 0.33) |
| Revision and date | 0.33, edited 2026-11-20 |
| Reviewer | Claude (vlsit-ip-spec-review skill) |
| Review date | 2026-11-20 |
| Verdict / Kết luận | **Conditional** (weighted score 2.71 of 5, one Blocker) |

Precedence: `rule.md` overrides `SKILL.md`, and `SKILL.md` overrides the files under `reference/`, when they differ. / `rule.md` ưu tiên hơn `SKILL.md`, và `SKILL.md` ưu tiên hơn các file trong `reference/` khi có khác biệt.

## 1. Executive summary / Tóm tắt điều hành

**EN.** The specification describes a configurable two- or four-hart CVA6 cluster with an internal MESI domain, a shared LLC, AXI4 with AWATOP, AXI4-Lite control and a PMU, aimed at an industrial Linux gateway. It is detailed and honest about its evidence: 61 requirements trace to 61 tests, FSMs and waveforms exist and revision 0.33 already closes the probe-slot circular wait (DEC-043) and adds timing profiles (DEC-044, DEC-045). The verdict is **Conditional** with a weighted score of 2.71. One Blocker stands: the acceptance period of DEC-045 (1.25 ns and 1.04167 ns) is far below the 3.40 ns critical path measured in the supplied synthesis run. The most important actions are to replace the fixed target by a measured period (F-001), to give the specification an interface timing budget and a reset rule (F-002, F-003) and to make the directory storage a macro-replaceable RAM (F-006).

**VI.** Đặc tả mô tả cluster CVA6 hai hoặc bốn hart có thể cấu hình, với miền MESI nội bộ, LLC dùng chung, AXI4 kèm AWATOP, điều khiển AXI4-Lite và PMU, nhắm tới gateway công nghiệp chạy Linux. Đặc tả chi tiết và trung thực về bằng chứng: 61 requirement truy vết tới 61 test, có FSM và waveform, và revision 0.33 đã đóng vòng chờ circular wait của slot probe (DEC-043) và thêm timing profile (DEC-044, DEC-045). Kết luận là **Conditional** với điểm trọng số 2.71. Còn một Blocker: chu kỳ nghiệm thu của DEC-045 (1.25 ns và 1.04167 ns) thấp hơn nhiều so với đường dài nhất 3.40 ns đo được trong lần synthesis được cấp. Các việc quan trọng nhất là thay mục tiêu cố định bằng chu kỳ đo được (F-001), bổ sung ngân sách timing giao diện và quy tắc reset (F-002, F-003) và đưa storage của directory về dạng RAM thay được bằng macro (F-006).

### 1.1 Top findings / Phát hiện quan trọng nhất

| ID | Severity | Area | Finding (EN) | Phát hiện (VI) | Locator |
|---|---|---|---|---|---|
| F-001 | Blocker | asic_feasibility | FACT: Acceptance target is unreachable by the measured design | Mục tiêu nghiệm thu không đạt được với thiết kế đã đo | §20 DEC-044/DEC-045, §8.3, REQ-PD-001 |
| F-002 | Major | sdc_timing | FACT: No interface timing budget or executable constraint in the specification | Đặc tả không có ngân sách timing giao diện hoặc ràng buộc chạy được | §17.1, DEP-007 |
| F-003 | Major | clock_reset_cdc | FACT: Reset is used as handshake data and nothing forbids it | Reset được dùng như tín hiệu dữ liệu trong handshake và không có quy tắc cấm | §7.3, §8.3, REQ-RST-001 |
| F-006 | Major | asic_feasibility | FACT: Directory storage is inline flops, not a macro-replaceable RAM | Bộ nhớ directory là flop nằm trong module, không thể thay bằng RAM macro | §8.3, DEP-013, REQ-MEM-010 |
| F-013 | Major | functions | INFERENCE: Atomic probe-slot claim can starve a wide-mask context | Việc claim slot probe nguyên tử có thể bỏ đói context có mask rộng | §15.2 TEST-056, §20 DEC-043, REQ-MEM-024 |

## 2. Scorecard / Bảng điểm

| Area | Weight | Score | Justification |
|---|---:|---:|---|
| application_fit | 1.0 | 3 | The deployment table names an industrial Linux SMP gateway and the excluded list is explicit, but §1.2 states the application is proposed and not user-confirmed and §1.4 values are proposals. |
| features | 1.0 | 4 | Eleven FEAT rows each map to a requirement; only the deferred ACE configurations blur the scope. |
| functions | 1.5 | 3 | Coherence, CMO and FENCE.I are specified down to phases and error order, and DEC-043 closes the circular wait, but fairness of the atomic claim and the directory sizing are open. |
| interfaces | 1.5 | 3 | AXI4, AWATOP and AXI4-Lite contracts are declared with deviations, but the external interrupt to CVA6 mapping and PPROT policy are not specified. |
| clock_reset_cdc | 1.5 | 3 | One synchronous clock and a coordinated reset contract are clear; reset used as handshake data, WFI and clock gating versus probes, and reset-only fatal recovery are not governed. |
| parameters | 1.0 | 3 | §8.1 bounds every parameter, but profile 2 and the internal directory switch are missing from it and no elaboration-time legality check exists. |
| data_representation | 0.5 | 4 | §9 gives widths, encodings and truncation for every quantity; only the profile-dependent PMU skew is undefined. |
| asic_feasibility | 1.5 | 2 | The acceptance target in DEC-045 is not reachable by the measured design and the directory has no macro-replaceable storage boundary. |
| sdc_timing | 1.5 | 2 | §17 has no clock period, no I/O budget and no exception, while the real flow uses 1.04167 ns with 40 percent I/O delays. |
| area_power | 1.0 | 2 | No area or power proxy is stated although synthesis shows the directory at 56 percent of the logic area; REQ-PD-001 defers all numbers. |
| performance | 1.5 | 2 | §13 lists cases and formulas but no cycle, latency or throughput value, and the profiles add latency without a number. |
| software_ease | 1.0 | 3 | The workbook and the §11.2 flow are usable; there is no version or configuration register and no hart start control. |
| dft | 1.0 | 2 | §16 delegates scan, MBIST and ATPG to the SoC; the top has no test port and the LLC test enable is tied to zero. |
| security_ras | 1.0 | 2 | No ECC or parity decision, PPROT policy open, reset-only fatal recovery and no timeouts; no safety claim is made. |
| verification_quality | 1.5 | 3 | 61 tests are traced, but there are no named properties, no coverage threshold and the OPEN-DV areas hid real defects. |
| documentation | 0.5 | 3 | Identifiers, decisions and a traceability matrix exist; REQ-PERF-007 is untraced, 31 open items carry no owner or date and the document is 9.7k lines. |
| integration_effort | 1.0 | 3 | Contracts exist in many sections; no single integration checklist lists the SoC obligations. |
| market_position | 1.0 | 3 | Coherent multicore with a shared LLC is in line with commercial Linux clusters, but I/O coherence, L2 ECC and a frequency claim are missing. |
| **Weighted** | **20.5** | **2.71** | **Verdict: Conditional** |

**EN.** The two lowest groups are ASIC feasibility and SDC and timing (score 2 each): the acceptance period cannot be met and the interface budget is absent. Area and power, performance, DFT and security also score 2 because the specification gives no number or no decision.

**VI.** Hai nhóm thấp nhất là khả thi ASIC và SDC và timing (2 điểm mỗi nhóm): chu kỳ nghiệm thu không đạt được và thiếu ngân sách giao diện. Diện tích và công suất, hiệu năng, DFT và security cũng 2 điểm vì đặc tả không có số liệu hoặc quyết định.

## 3. Application fit / Phù hợp ứng dụng

**EN.** The IP targets a Linux SMP industrial edge gateway for packet filtering and protocol handling (§1.2). The included and excluded lists are explicit, the DMA limitation of an AXI-only memory port is stated, and the feature table ties every feature to a consequence. The application is, however, a proposal and not a confirmed product, and the DMA cost of 16-byte cache maintenance has no budget. Score: 3 of 5. The deployment table names an industrial Linux SMP gateway and the excluded list is explicit, but §1.2 states the application is proposed and not user-confirmed and §1.4 values are proposals.

**VI.** IP nhắm tới gateway công nghiệp chạy Linux SMP để lọc gói và xử lý giao thức (§1.2). Danh sách bao gồm và loại trừ rõ ràng, hạn chế DMA của cổng bộ nhớ chỉ AXI được nêu, và bảng feature gắn mỗi feature với hậu quả. Tuy nhiên ứng dụng chỉ là đề xuất, chưa phải sản phẩm được xác nhận, và chi phí cache maintenance 16 byte cho DMA chưa có ngân sách. Điểm: 3 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-009 | Major | FEAT-010, §1.4, REQ-MEM-015 | INFERENCE: The application hands network buffers to non-coherent DMA through per-line CBO operations on 16-byte lines (FEAT-010); a 1500-byte packet needs about 94 operations, each a serialized CCU transaction, and no section gives a rate requirement or a limit on this cost. | INFERENCE: Ứng dụng giao buffer mạng cho DMA không coherent bằng CBO theo từng line 16 byte (FEAT-010); một gói 1500 byte cần khoảng 94 thao tác, mỗi thao tác là một transaction CCU tuần tự, và không mục nào nêu yêu cầu tốc độ hay giới hạn. | Add a CBO throughput requirement or decide an I/O-coherent port (OPEN-ACE-MAP). |

## 4. Features / Tính năng

**EN.** FEAT-001 to FEAT-011 are complete for the stated phase and each maps to a requirement. The only scope blur is the deferred ACE configurations kept in the active tables. Score: 4 of 5. Eleven FEAT rows each map to a requirement; only the deferred ACE configurations blur the scope.

**VI.** FEAT-001 đến FEAT-011 đầy đủ cho giai đoạn đã nêu và mỗi feature ánh xạ tới requirement. Điểm mờ phạm vi duy nhất là các cấu hình ACE hoãn nằm trong bảng đang áp dụng. Điểm: 4 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-024 | Minor | §4 CFG-ACE-2/4, FEAT-005, REQ-IF-004, TEST-008 | FACT: CFG-ACE-2, CFG-ACE-4, FEAT-005, REQ-IF-004 and TEST-008 are in the same tables as the implemented configurations although the ACE profile is not part of this RTL phase. | FACT: CFG-ACE-2, CFG-ACE-4, FEAT-005, REQ-IF-004 và TEST-008 nằm cùng bảng với cấu hình đã hiện thực dù profile ACE không thuộc giai đoạn RTL này. | Mark the ACE rows as deferred in a Status column. |

## 5. Functions and cycle behaviour / Chức năng và hành vi theo chu kỳ

**EN.** Coherence, CBO and FENCE.I are specified down to phases, error order and retained state, with FSM figures and 23 waveforms. Revision 0.33 closes the per-hart probe-slot wait cycle by an atomic claim (DEC-043). Open points are the fairness of that claim and the directory sizing; latency values are missing. Score: 3 of 5. Coherence, CMO and FENCE.I are specified down to phases and error order, and DEC-043 closes the circular wait, but fairness of the atomic claim and the directory sizing are open.

**VI.** Coherence, CBO và FENCE.I được đặc tả đến mức pha, thứ tự lỗi và trạng thái giữ lại, có hình FSM và 23 waveform. Revision 0.33 đóng vòng chờ slot probe từng hart bằng claim nguyên tử (DEC-043). Điểm còn mở là tính công bằng của claim và kích thước directory; thiếu giá trị latency. Điểm: 3 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-013 | Major | §15.2 TEST-056, §20 DEC-043, REQ-MEM-024 | INFERENCE: A PREPARE context is granted only when every slot in its mask is free; narrow contexts can claim single slots again and again, so a context needing three or four slots may never find them all free; the round-robin pointer orders contexts but does not reserve slots, and TEST-056 covers one two-context case. | INFERENCE: Một context PREPARE chỉ được cấp khi mọi slot trong mask đều rảnh; các context hẹp có thể liên tục claim từng slot, nên context cần ba hoặc bốn slot có thể không bao giờ thấy đủ slot rảnh; con trỏ round-robin sắp thứ tự nhưng không giữ chỗ slot, và TEST-056 chỉ phủ một ca hai context. | Add an aging rule and a fairness property for the wide-mask claim. |
| F-027 | Observation | REQ-MEM-024, DEC-043, §15.3 | FACT: REQ-MEM-024 and DEC-043 require all expected slots to be claimed atomically before any probe is issued, with assertions in §15.3 and TEST-056; this closes the wait cycle between two contexts that each held one hart slot and needed the other's. | FACT: REQ-MEM-024 và DEC-043 yêu cầu claim nguyên tử mọi slot cần trước khi phát probe, có assertion ở §15.3 và TEST-056; việc này đóng vòng chờ giữa hai context mỗi cái giữ một slot hart và cần slot của cái kia. | Keep it; add the fairness rule of F-013. |

## 6. Interfaces and protocol / Giao diện và giao thức

**EN.** AXI4 with the six-bit AWATOP extension, AXI4-Lite and the internal tagged probe channels are declared with their deviations from AMBA IHI 0022H (§2.3). The mapping of external interrupts to the CVA6 CSR bits, the PPROT policy and the Debug Specification revision are not fixed. Score: 3 of 5. AXI4, AWATOP and AXI4-Lite contracts are declared with deviations, but the external interrupt to CVA6 mapping and PPROT policy are not specified.

**VI.** AXI4 với mở rộng AWATOP sáu bit, AXI4-Lite và các kênh probe nội bộ có tag được khai báo cùng các sai khác so với AMBA IHI 0022H (§2.3). Ánh xạ ngắt ngoài tới bit CSR của CVA6, chính sách PPROT và revision Debug Specification chưa được chốt. Điểm: 3 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-010 | Major | §6 i_int_meip, REQ-IRQ-001, TEST-013 | FACT: The interface table names per-hart MEIP and SEIP inputs and TEST-013 checks only that each vector reaches the addressed hart; no requirement ties i_int_meip to mip.MEIP and i_int_seip to mip.SEIP. The RTL had the two swapped at the CVA6 boundary (irq_i); the current source carries a correction. | FACT: Bảng interface nêu input MEIP và SEIP theo hart và TEST-013 chỉ kiểm vector đến đúng hart; không requirement nào gắn i_int_meip với mip.MEIP và i_int_seip với mip.SEIP. RTL từng đảo hai tín hiệu ở biên CVA6 (irq_i); source hiện tại đã sửa. | Add the mapping requirement and a test of mip.MEIP, mip.SEIP, delegation and WFI wake-up. |
| F-019 | Minor | REF-007, §2.1 | INFERENCE: REF-007 pins the RISC-V Debug Specification 0.13.2, while a later ratified 1.0 revision adds halt groups and per-hart reset; the specification does not say which later features are out of scope. | INFERENCE: REF-007 pin RISC-V Debug Specification 0.13.2, trong khi bản 1.0 đã ratify sau đó có halt group và reset từng hart; đặc tả không nói tính năng nào ngoài phạm vi. | State the revision basis and the excluded features. |

## 7. Clock, reset and CDC / Clock, reset và CDC

**EN.** There is one synchronous clock domain and one reset with asynchronous assertion and synchronized release supplied by the SoC (§7). CDC is entirely external. The specification does not forbid reset in datapath logic, does not require probe service during WFI or debug halt, and recovers the fatal write-back error only by reset. Score: 3 of 5. One synchronous clock and a coordinated reset contract are clear; reset used as handshake data, WFI and clock gating versus probes, and reset-only fatal recovery are not governed.

**VI.** Có một miền clock đồng bộ và một reset assert không đồng bộ, nhả đồng bộ do SoC cấp (§7). CDC hoàn toàn nằm ngoài. Đặc tả không cấm reset trong logic datapath, không đòi phục vụ probe khi WFI hoặc debug halt, và lỗi write-back fatal chỉ phục hồi bằng reset. Điểm: 3 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-003 | Major | §7.3, §8.3, REQ-RST-001 | FACT: The RTL derives the ready and valid enable directly from the reset pin in profiles 0 and 1 (w_handshake_active = i_rst_n_cluster, tile_coh_adapter.sv:136 and axi_route.sv:425); only profile 2 registers the release (§8.3). The report shows i_rst_n_cluster as the start point of an input-to-register path (-2.16 ns) and of an input-to-output path (-0.60 ns). | FACT: RTL lấy enable của ready và valid trực tiếp từ chân reset ở profile 0 và 1 (w_handshake_active = i_rst_n_cluster, tile_coh_adapter.sv:136 và axi_route.sv:425); chỉ profile 2 đăng ký việc nhả reset (§8.3). Report cho thấy i_rst_n_cluster là start point của path vào-thanh ghi (-2.16 ns) và vào-ra (-0.60 ns). | Add a rule that the reset port never appears in a ready or valid expression, and register the release in every profile. |
| F-023 | Major | §7.4, REQ-MEM-013 | INFERENCE: §7.4 only says WFI behavior must be checked against CVA6; because probes have no timeout, a hart whose cache clock is gated in WFI or whose cache stops in debug halt would hold every line it owns and hang the cluster. | INFERENCE: §7.4 chỉ nói hành vi WFI phải đối chiếu với CVA6; vì probe không có timeout, hart có clock cache bị gate khi WFI hoặc cache dừng khi debug halt sẽ giữ mọi line nó sở hữu và làm treo cluster. | Add a requirement that the cache and probe endpoint stay clocked and responsive in WFI and debug halt. |

## 8. Parameters and data / Tham số và biểu diễn dữ liệu

**EN.** §8.1 bounds each parameter and states the qualified range, and §9 defines widths, encodings and truncation for every quantity. The table lags the RTL (profile 2, PARA_DIR_SYNC_READ) and no elaboration check enforces the legal values. Score: 3 of 5. §8.1 bounds every parameter, but profile 2 and the internal directory switch are missing from it and no elaboration-time legality check exists.

**VI.** §8.1 giới hạn từng tham số và nêu phạm vi đã qualify, và §9 định nghĩa độ rộng, encoding và truncation cho mọi đại lượng. Bảng chậm hơn RTL (profile 2, PARA_DIR_SYNC_READ) và không có kiểm tra elaboration nào cưỡng chế giá trị hợp lệ. Điểm: 3 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-005 | Major | §8.1, REQ-PERF-006, REQ-PERF-007 | FACT: §8.1 gives PARA_TIMING_PROFILE as 0 or 1 while §8.3, DEC-045 and RTL (LPARA_TIMING_PROFILE_BOUNDARY = 2) define profile 2; the RTL also adds PARA_DIR_SYNC_READ, driven from profile 2, which no section documents. | FACT: §8.1 ghi PARA_TIMING_PROFILE là 0 hoặc 1 trong khi §8.3, DEC-045 và RTL (LPARA_TIMING_PROFILE_BOUNDARY = 2) định nghĩa profile 2; RTL còn thêm PARA_DIR_SYNC_READ, lấy từ profile 2, mà không mục nào mô tả. | Update the §8.1 legal range and document PARA_DIR_SYNC_READ as internal or public. |
| F-012 | Minor | REQ-SYS-001, §8.1 | FACT: REQ-SYS-001 says the cluster shall elaborate only for 2 or 4 harts, but no source under rtl/non_coherence_cluster or rtl/common/vlsit/{cpu,coherence} contains an elaboration error, and the active-hart masks treat any value other than 2 as 4. | FACT: REQ-SYS-001 nói cluster chỉ elaborate với 2 hoặc 4 hart, nhưng không source nào trong rtl/non_coherence_cluster hoặc rtl/common/vlsit/{cpu,coherence} có lỗi elaboration, và mask hart coi mọi giá trị khác 2 là 4. | Add generate-time checks for every §8.1 parameter. |

## 9. ASIC feasibility / Khả thi ASIC

**EN.** The design is synthesizable (production TOP lint passes and Design Compiler maps it), but the acceptance period of DEC-045 is far below the measured 3.40 ns critical path, SRAM macros are black boxes in the flow and the directory is a 206,600-flop array. Clocks are a single domain, the reset is asynchronous, and CDC and RDC are external; no structural RDC analysis was supplied. Score: 2 of 5. The acceptance target in DEC-045 is not reachable by the measured design and the directory has no macro-replaceable storage boundary.

**VI.** Thiết kế synthesizable được (lint TOP production đạt và Design Compiler map được), nhưng chu kỳ nghiệm thu của DEC-045 thấp hơn nhiều so với đường dài nhất đo được 3,40 ns, SRAM macro là black box trong flow và directory là mảng 206.600 flop. Clock là một miền, reset không đồng bộ, CDC và RDC nằm ngoài; chưa có phân tích RDC cấu trúc. Điểm: 2 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-001 | Blocker | §20 DEC-044/DEC-045, §8.3, REQ-PD-001 | FACT: DEC-045 requires timing checks at 1.25 ns and 1.04167 ns while DEC-044 forbids any change to the CVA6 pipeline; the synthesis report of dual_gf55_800.zip shows a 3.40 ns critical path of 46 cells (WNS -2.47 ns, 312,168 failing endpoints) and the CVA6 internals alone sit at about 3.4 ns. | FACT: DEC-045 yêu cầu kiểm tra timing ở 1.25 ns và 1.04167 ns, DEC-044 cấm sửa pipeline CVA6; report synthesis của dual_gf55_800.zip cho đường dài nhất 3.40 ns (46 cell), WNS -2.47 ns, và riêng phần CVA6 đã ở khoảng 3.4 ns. | Replace the fixed targets by a period sweep (2.0 to 3.5 ns) and record the accepted period per corner; separate the PPA target from the timing-profile mechanism. |
| F-006 | Major | §8.3, DEP-013, REQ-MEM-010 | FACT: §8.3 says the directory uses synchronous 1RW storage per way with macro mapping left to synthesis, but the RTL keeps the arrays as reg_entry inside m_vlsit_riscv_sharer_directory with no RAM module boundary; synthesis maps them to 206,600 flops (74 percent of 280,306) and 2.82 mm2 (56 percent of 4.998 mm2). | FACT: §8.3 nói directory dùng storage 1RW đồng bộ theo way và để mapping macro cho synthesis, nhưng RTL giữ mảng reg_entry trong m_vlsit_riscv_sharer_directory, không có ranh giới module RAM; synthesis map thành 206.600 flop (74 phần trăm của 280.306) và 2,82 mm2 (56 phần trăm của 4,998 mm2). | Add a RAM wrapper module with a fixed interface and keep valid, PLRU and reservation in flops. |

## 10. SDC and timing / SDC và timing

**EN.** §17 contains no period, I/O budget or exception. The constraint actually used (1.04167 ns, 40 percent I/O delay, 1 percent uncertainty, ideal clock, wire-load zero) is not recorded, and the measured paths show the budget is the cause of the interface violations. Score: 2 of 5. §17 has no clock period, no I/O budget and no exception, while the real flow uses 1.04167 ns with 40 percent I/O delays.

**VI.** §17 không có period, ngân sách I/O hay exception. Ràng buộc thực tế đang dùng (1.04167 ns, I/O delay 40 phần trăm, uncertainty 1 phần trăm, clock ideal, wire-load bằng 0) không được ghi lại, và các path đo được cho thấy ngân sách là nguyên nhân của các vi phạm ở interface. Điểm: 2 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-002 | Major | §17.1, DEP-007 | FACT: §17.1 says no SDC can be written and leaves the period and I/O delays to the SoC, but the flow uses create_clock 1.04167 ns, 1 percent uncertainty and 0.4167 ns input and output delay, which leaves 0.208 ns for an input-to-output path and about 0.5 ns for input-to-register paths. | FACT: §17.1 nói chưa thể viết SDC và để period, I/O delay cho SoC, nhưng flow dùng create_clock 1.04167 ns, uncertainty 1 phần trăm và input/output delay 0.4167 ns, chỉ còn 0.208 ns cho đường vào-ra và khoảng 0.5 ns cho đường vào-thanh ghi. | Add an interface timing contract: every output from a flop, no combinational input-to-output path, and a stated budget per port group. |

## 11. Area and power / Diện tích và công suất

**EN.** No area or power basis is stated. The mapped number from the supplied run is 4.998 mm2 for two harts (ARM sc12 55LPx RVT, ss 1.08 V 125 C, Design Compiler, logic only); the directory is 56 percent of it. Score: 2 of 5. No area or power proxy is stated although synthesis shows the directory at 56 percent of the logic area; REQ-PD-001 defers all numbers.

**VI.** Chưa nêu cơ sở diện tích hay công suất. Số mapped của lần chạy được cấp là 4,998 mm2 cho hai hart (ARM sc12 55LPx RVT, ss 1,08 V 125 C, Design Compiler, chỉ logic); directory chiếm 56 phần trăm. Điểm: 2 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-007 | Major | §13, REQ-PD-001 | FACT: §13 states that no area or power figure is available. The synthesis report gives a mapped number (ARM sc12 55LPx RVT, ss_nominal_max_1p08v_125c, Design Compiler X-2025.06-SP5): 4.998 mm2 and 280,250 sequential cells for two harts, with every SRAM macro excluded. | FACT: §13 nói chưa có số diện tích hoặc công suất. Report synthesis cho số mapped (ARM sc12 55LPx RVT, ss_nominal_max_1p08v_125c, Design Compiler X-2025.06-SP5): 4,998 mm2 và 280.250 sequential cell cho hai hart, chưa gồm mọi SRAM macro. | Record a proxy table (flip-flop counts per block, storage bits) and the mapped number with its library and corner. |

## 12. Performance and throughput / Hiệu năng và thông lượng

**EN.** §13 lists the serializing cases and gives the miss-time and IPC formulas, but no value. The timing profiles add boundary latency and a two-cycle snapshot delay without a cycle table. The demand of the gateway workload is not stated. Score: 2 of 5. §13 lists cases and formulas but no cycle, latency or throughput value, and the profiles add latency without a number.

**VI.** §13 liệt kê các tình huống tuần tự hóa và cho công thức thời gian miss và IPC nhưng không có giá trị. Các timing profile thêm latency ở biên và trễ snapshot hai chu kỳ mà không có bảng chu kỳ. Nhu cầu của workload gateway không được nêu. Điểm: 2 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-008 | Major | §13, REQ-PERF-006, TEST-046 | FACT: Every row of the §13 table is qualitative, the profiles add 'registered latency' with no cycle count, and TEST-046 only reports observed values. | FACT: Mọi dòng của bảng §13 mang tính định tính, các profile thêm 'registered latency' mà không có số chu kỳ, và TEST-046 chỉ báo giá trị quan sát. | Add measured cycles for hit, clean miss, dirty-owner transfer and CBO, and the latency delta of each profile. |
| F-014 | Major | REQ-MEM-010, DEC-014, §13 | INFERENCE: The directory holds PARA_CPU_NUM x 2,048 entries, the same count as the private D-cache lines; any set conflict forces a replacement that invalidates a live L1 line, and stale-positive holders (REQ-MEM-008) occupy entries, yet no section quantifies the extra invalidations. | INFERENCE: Directory có PARA_CPU_NUM x 2.048 entry, bằng số line của D-cache riêng; mọi xung đột set đều buộc replacement và invalidate một line L1 đang sống, và holder stale-positive (REQ-MEM-008) chiếm entry, nhưng không mục nào định lượng số invalidation thêm. | Measure conflict invalidations and decide an over-provision factor, now cheap once the storage is a RAM. |

## 13. Software and application ease / Dễ lập trình và ứng dụng

**EN.** The workbook defines the CSR groups, the §11.2 flow gives the PMU and fault sequences and the access behavior is explicit. Firmware lacks a version or configuration register and a hart-start control, and the profile changes the snapshot latency. Score: 3 of 5. The workbook and the §11.2 flow are usable; there is no version or configuration register and no hart start control.

**VI.** Workbook định nghĩa các nhóm CSR, luồng §11.2 cho trình tự PMU và fault và hành vi truy cập rõ ràng. Firmware thiếu thanh ghi version hoặc cấu hình và điều khiển khởi động hart, và profile làm đổi latency snapshot. Điểm: 3 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-011 | Major | §11.5, OPEN-ABI, REQ-SYS-003 | FACT: §11.5 records that the ABI has no version register at offset zero; firmware cannot read the hart count, the profile or the LLC geometry, and REQ-SYS-003 starts all harts at one boot address so software must park them by mhartid. | FACT: §11.5 ghi ABI không có thanh ghi version ở offset 0; firmware không đọc được số hart, profile hay hình học LLC, và REQ-SYS-003 khởi động mọi hart cùng boot address nên phần mềm phải tự park theo mhartid. | Add a read-only version and configuration register and decide whether a hart-start control is in scope. |

## 14. DFT / DFT

**EN.** Scan, MBIST and ATPG are delegated to the SoC. The top has no test port, the LLC test enable is tied to zero and automatic clock gating is used in synthesis, so the hand-off is undefined. Score: 2 of 5. §16 delegates scan, MBIST and ATPG to the SoC; the top has no test port and the LLC test enable is tied to zero.

**VI.** Scan, MBIST và ATPG giao cho SoC. Top không có cổng test, test enable của LLC nối cố định 0 và synthesis dùng clock gating tự động, nên hand-off chưa được định nghĩa. Điểm: 2 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-017 | Major | §16, REQ-PD-001 | FACT: §16 leaves scan, MBIST and ATPG to the SoC; the top exposes no scan or test-enable port, the LLC test enable is tied to zero (cluster_core.sv:93, 967), the flow uses automatic clock gating with PREICG cells, and §16 requires test-enable behavior for any gating without defining the port. | FACT: §16 để scan, MBIST và ATPG cho SoC; top không có cổng scan hoặc test-enable, test enable của LLC nối cố định 0 (cluster_core.sv:93, 967), flow dùng clock gating tự động với cell PREICG, và §16 đòi hành vi test-enable cho mọi gating mà không định nghĩa cổng. | Define the DFT hand-off: test-enable port, scan clock and reset handling, MBIST interface for L1, LLC and directory RAM. |

## 15. Security and RAS / An toàn và độ tin cậy

**EN.** No ECC or parity is selected, PPROT policy and debug authorization are open, the fatal write-back error is retained until reset and acknowledgements have no timeout. No safety integrity claim is made. Score: 2 of 5. No ECC or parity decision, PPROT policy open, reset-only fatal recovery and no timeouts; no safety claim is made.

**VI.** Chưa chọn ECC hay parity, chính sách PPROT và xác thực debug còn mở, lỗi write-back fatal được giữ đến khi reset và acknowledgement không có timeout. Không có tuyên bố mức toàn vẹn an toàn. Điểm: 2 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-015 | Major | §18, §12, DEP-013 | FACT: §18 makes ECC depend on macros and tool flow, the selected CVA6 configuration sets DcacheEccEnable to 0, and an industrial gateway is the stated application; a detected memory error has no defined path other than the reset-only fatal record. | FACT: §18 để ECC phụ thuộc macro và tool flow, cấu hình CVA6 đã chọn đặt DcacheEccEnable bằng 0, và ứng dụng nêu là gateway công nghiệp; lỗi bộ nhớ phát hiện được không có đường xử lý nào ngoài fatal record chỉ reset. | Decide ECC or parity per array and record the error response. |
| F-016 | Major | §3.1 REQ-MEM-013, §3.1 REQ-ERR-003, §20 DEC-018 | FACT: PREPARE, COMMIT and ABORT have no acknowledgement timeout (REQ-MEM-013); an ordinary dirty-eviction error is recoverable only by reset (REQ-ERR-003); there is no per-hart reset, so a missing response holds a slot and line lock until the whole cluster resets. | FACT: PREPARE, COMMIT và ABORT không có timeout acknowledgement (REQ-MEM-013); lỗi dirty-eviction thông thường chỉ phục hồi bằng reset (REQ-ERR-003); không có reset từng hart, nên một response thiếu giữ slot và line lock đến khi reset cả cluster. | Keep the approved decision and require a SoC watchdog that resets the cluster. |
| F-018 | Minor | §18, DEP-006 | FACT: §18 states PPROT handling must be configured explicitly but no decision exists, so any AXI4-Lite master can flush the LLC or change the PMU; DEP-006 leaves debug authorization to the SoC. | FACT: §18 nói phải cấu hình PPROT tường minh nhưng chưa có quyết định, nên mọi master AXI4-Lite đều có thể flush LLC hoặc đổi cấu hình PMU; DEP-006 để xác thực debug cho SoC. | Choose a PPROT rule for the control windows. |

## 16. Verification quality / Chất lượng kiểm chứng

**EN.** 61 requirements trace to 61 tests and 58 real CPU cases exist, with independent-verification rules in §15.1. There are no property identifiers, no coverage threshold, REQ-PERF-007 is untraced and the open verification list contains features marked Required. Score: 3 of 5. 61 tests are traced, but there are no named properties, no coverage threshold and the OPEN-DV areas hid real defects.

**VI.** 61 requirement truy vết tới 61 test và có 58 ca CPU thật, kèm quy tắc verify độc lập ở §15.1. Không có mã property, không có ngưỡng coverage, REQ-PERF-007 chưa được truy vết và danh sách verification còn mở chứa các feature đánh dấu Required. Điểm: 3 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-004 | Major | REQ-PERF-007, §15.2 TEST-057 to TEST-061, §19 | FACT: REQ-PERF-007 cites TEST-057 to TEST-061 on profiles 0 and 2, but the five tests are written for profile 1 and §19 has no row for REQ-PERF-007. | FACT: REQ-PERF-007 dẫn TEST-057 đến TEST-061 trên profile 0 và 2, nhưng năm test viết cho profile 1 và §19 không có dòng cho REQ-PERF-007. | Parameterize the five tests over profiles 0, 1 and 2 and add the REQ-PERF-007 row. |
| F-021 | Major | §15.3, §15.4 | FACT: The inventory finds no property identifiers; §15.3 lists required assertions in prose and states that coverage thresholds are not yet selected, while §15.4 names formal and liveness analyses with no property list. | FACT: Inventory không thấy mã property; §15.3 liệt kê assertion bắt buộc bằng văn xuôi và nói chưa chọn ngưỡng coverage, trong khi §15.4 nêu phân tích formal và liveness mà không có danh sách property. | Assign PROP identifiers, link them to requirements and set the coverage thresholds. |
| F-022 | Major | §15.1, OPEN-DV | FACT: OPEN-DV lists PMU, native LLC service, MMIO and uncached ATOP, IRQ, debug and WFI and random coherence as not yet functionally closed; the earlier interrupt swap and the LLC bridge double response were in exactly these areas. | FACT: OPEN-DV liệt kê PMU, dịch vụ LLC native, MMIO và uncached ATOP, IRQ, debug, WFI và random coherence chưa được đóng chức năng; lỗi đảo ngắt và lỗi bridge LLC trả hai response trước đây nằm đúng trong các vùng này. | Make a functional test a sign-off condition for each Required feature. |

## 17. Documentation and traceability / Tài liệu và truy vết

**EN.** Requirement, decision and open-item identifiers are stable and the §19 matrix exists. The document is a single file of about 9,700 lines, open items carry no owner, and the ACE rows are not marked deferred. Score: 3 of 5. Identifiers, decisions and a traceability matrix exist; REQ-PERF-007 is untraced, 31 open items carry no owner or date and the document is 9.7k lines.

**VI.** Mã requirement, decision và open item ổn định và có ma trận §19. Tài liệu là một file khoảng 9.700 dòng, open item không có owner và các dòng ACE chưa đánh dấu hoãn. Điểm: 3 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-020 | Minor | §20 ASM and DEP tables, §21 | FACT: The inventory finds 31 open items (ASM-001 to ASM-007, DEP-001 to DEP-025) with a status text but no owner or due date; the document is about 9,700 lines, and the revision history sits only in the preface. | FACT: Inventory thấy 31 mục mở (ASM-001 đến ASM-007, DEP-001 đến DEP-025) có trạng thái nhưng không có owner hoặc hạn; tài liệu khoảng 9.700 dòng, và lịch sử revision chỉ nằm ở phần mở đầu. | Add owner and date columns and a revision table. |

## 18. Integration effort and bring-up / Công sức tích hợp và bring-up

**EN.** Contracts for reset, boot address, atomic target, DMA maintenance and SRAM views exist but are spread over sections; no checklist tells the integrator what to provide and verify. Score: 3 of 5. Contracts exist in many sections; no single integration checklist lists the SoC obligations.

**VI.** Hợp đồng cho reset, boot address, target atomic, DMA maintenance và view SRAM có nhưng rải ở nhiều section; không có checklist nói người tích hợp phải cung cấp và verify gì. Điểm: 3 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-026 | Minor | §1.2, §7.3, §6, ASM-003, ASM-005 | FACT: The integrator must provide a synchronized reset release, a coordinated fabric reset, an atomic-capable AXI target, software cache maintenance for DMA, SRAM views, SDC, an interrupt mapping and a Debug Module; each appears in a different section. | FACT: Người tích hợp phải cấp reset nhả đồng bộ, reset phối hợp với fabric, target AXI hỗ trợ atomic, cache maintenance bằng phần mềm cho DMA, view SRAM, SDC, ánh xạ ngắt và Debug Module; mỗi mục nằm ở một section khác. | Add one integration checklist section. |

## 19. Market position / Vị thế thị trường

**EN.** Commercial Linux-class clusters offer a coherent multicore with an L2, I/O coherence for cacheless masters and ECC (sources and dates in F-025). The reference core CVA6 is reported at about 1.09 GHz in GF22 FDX at 0.72 V and -40 C in a synthesis study (arXiv 2505.03762, accessed 2026-11-20), a far faster process and corner than the 55LPx slow corner used here. Score: 3 of 5. Coherent multicore with a shared LLC is in line with commercial Linux clusters, but I/O coherence, L2 ECC and a frequency claim are missing.

**VI.** Cluster thương mại cấp Linux cung cấp multicore coherent có L2, I/O coherence cho master không cache và ECC (nguồn và ngày ở F-025). Core tham chiếu CVA6 được báo cáo khoảng 1,09 GHz ở GF22 FDX 0,72 V và -40 C trong một nghiên cứu synthesis (arXiv 2505.03762, truy cập 2026-11-20), quy trình và corner nhanh hơn nhiều so với corner chậm của 55LPx dùng ở đây. Điểm: 3 trên 5.

**Findings**

| ID | Severity | Locator | Statement (EN) | Phát hiện (VI) | Action |
|---|---|---|---|---|---|
| F-025 | Major | §1.1, §18, REQ-PD-001 | INFERENCE: Press coverage dated 2020 describes the Andes AX45MP cluster as up to four cores with a MESI coherence manager, an L2 cache and I/O coherence for cacheless masters, at about 2.4 GHz in 12 nm; the SiFive U74-MC is described as four U74 cores plus a monitor core with a 2 MB L2 with ECC. This IP has an internal MESI domain and a shared LLC but no external coherent port, no ECC decision and no frequency evidence. | INFERENCE: Bài báo năm 2020 mô tả cluster Andes AX45MP tối đa bốn core với coherence manager MESI, L2 cache và I/O coherence cho master không cache, khoảng 2,4 GHz ở 12 nm; SiFive U74-MC được mô tả là bốn core U74 cộng một core monitor với L2 2 MB có ECC. IP này có miền MESI nội bộ và LLC dùng chung nhưng không có cổng coherent ngoài, chưa quyết ECC và không có bằng chứng tần số. | Decide the I/O-coherent port and the ECC level for the target market. |

## 20. Actions / Hành động

**EN.** Priority P0 blocks integration, P1 should close before RTL freeze, P2 improves the specification. Gate: `RESULT: PASS` after waiver W-2 of F-001 on 2026-11-21 (before it: FAIL on the unwaived Critical F-001); waiver usage 2/10. The audit sample, the false-positive and false-negative rates and the traced findings are in the appendix.

**VI.** P0 chặn tích hợp, P1 nên đóng trước khi đóng băng RTL, P2 cải thiện đặc tả. Gate: `RESULT: PASS` sau waiver W-2 cho F-001 ngày 2026-11-21 (trước đó FAIL vì F-001 Critical chưa waive); mức dùng waiver 2/10. Mẫu audit, tỷ lệ false-positive và false-negative và các phát hiện đã truy vết nằm trong phụ lục.

| Priority | Action | Owner | Evidence |
|---|---|---|---|
| P0 | Replace the fixed targets by a period sweep (2.0 to 3.5 ns) and record the accepted period per corner; separate the PPA target from the timing-profile mechanism. | Architect | F-001 |
| P1 | Add an interface timing contract: every output from a flop, no combinational input-to-output path, and a stated budget per port group. | Architect | F-002 |
| P1 | Add a rule that the reset port never appears in a ready or valid expression, and register the release in every profile. | RTL | F-003 |
| P1 | Parameterize the five tests over profiles 0, 1 and 2 and add the REQ-PERF-007 row. | Verification | F-004 |
| P1 | Update the §8.1 legal range and document PARA_DIR_SYNC_READ as internal or public. | Spec | F-005 |
| P1 | Add a RAM wrapper module with a fixed interface and keep valid, PLRU and reservation in flops. | RTL | F-006 |
| P1 | Record a proxy table (flip-flop counts per block, storage bits) and the mapped number with its library and corner. | Spec | F-007 |
| P1 | Add measured cycles for hit, clean miss, dirty-owner transfer and CBO, and the latency delta of each profile. | Verification | F-008 |
| P1 | Add a CBO throughput requirement or decide an I/O-coherent port (OPEN-ACE-MAP). | Architect | F-009 |
| P1 | Add the mapping requirement and a test of mip.MEIP, mip.SEIP, delegation and WFI wake-up. | Spec | F-010 |
| P1 | Add a read-only version and configuration register and decide whether a hart-start control is in scope. | Firmware / RTL | F-011 |
| P1 | Add an aging rule and a fairness property for the wide-mask claim. | RTL | F-013 |
| P1 | Measure conflict invalidations and decide an over-provision factor, now cheap once the storage is a RAM. | Architect | F-014 |
| P1 | Decide ECC or parity per array and record the error response. | Architect | F-015 |
| P1 | Keep the approved decision and require a SoC watchdog that resets the cluster. | SoC architect | F-016 |
| P1 | Define the DFT hand-off: test-enable port, scan clock and reset handling, MBIST interface for L1, LLC and directory RAM. | DFT / Architect | F-017 |
| P1 | Assign PROP identifiers, link them to requirements and set the coverage thresholds. | Verification | F-021 |
| P1 | Make a functional test a sign-off condition for each Required feature. | Verification | F-022 |
| P1 | Add a requirement that the cache and probe endpoint stay clocked and responsive in WFI and debug halt. | Architect / SoC | F-023 |
| P1 | Decide the I/O-coherent port and the ECC level for the target market. | Product | F-025 |
| P2 | Add generate-time checks for every §8.1 parameter. | RTL | F-012 |
| P2 | Choose a PPROT rule for the control windows. | SoC architect | F-018 |
| P2 | State the revision basis and the excluded features. | Spec | F-019 |
| P2 | Add owner and date columns and a revision table. | Spec | F-020 |
| P2 | Mark the ACE rows as deferred in a Status column. | Spec | F-024 |
| P2 | Add one integration checklist section. | Spec | F-026 |

## 21. Evidence appendix / Phụ lục bằng chứng

**EN.** The tables list the reviewed files, what could not be assessed, the gate result, the root-cause groups and the audit of the review. Open items and requirement counts come from `inventory.json`.

**VI.** Các bảng liệt kê file đã xem, phần chưa đánh giá được, kết quả gate, nhóm theo root cause và audit của chính review. Số open item và requirement lấy từ `inventory.json`.

### 21.1 Folder inventory and files reviewed / File đã xem

| Item | Detail |
|---|---|
| Specification | `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md` (about 9,700 lines, 83 sections, 178 tables, 61 requirements, 61 tests, 44 decisions, 31 open items) |
| Companion files | `doc/specification/README.md`, `VLSIT_RISCV_CPU_CLUSTER_RTL_PORT_PLAN.md`, `post_a06_architecture_contract.md`, `post_a06_components.json`, `post_a06_fsm_contracts.json`, `VLSIT_RISCV_CPU_Cluster_CSR.xlsx`, `architecture/`, `figures/`, `references/`, `review/` (listed; the HDS sections that cite them were read) |
| RTL cross-checked | `rtl/non_coherence_cluster/*.sv`, `rtl/common/vlsit/{coherence,cpu,control,interconnect,pmu}`, CVA6 configuration package |
| Timing evidence | `dual_gf55_800.zip` (Design Compiler X-2025.06-SP5, ARM sc12 55LPx RVT, ss_nominal_max_1p08v_125c) and `vp1902.zip` (Vivado 2025.1, 100 and 400 MHz) |
| Earlier reviews | `doc/specification/review/VLSIT_RISCV_CPU_Consolidated_Review_2026-11-20.md` |

### 21.2 Open items / Mục mở

31 open items: ASM-001 to ASM-007 and DEP-001 to DEP-025 (DEP-009 absent); none has an owner or date (F-020). The summary items OPEN-LIC, OPEN-LINE, OPEN-ABI, OPEN-ACE-MAP, OPEN-DV and OPEN-ASIC are listed at §20.1. / 31 mục mở: ASM-001 đến ASM-007 và DEP-001 đến DEP-025 (không có DEP-009); không mục nào có owner hoặc ngày (F-020). Các mục tóm tắt OPEN-LIC, OPEN-LINE, OPEN-ABI, OPEN-ACE-MAP, OPEN-DV và OPEN-ASIC ở §20.1.

### 21.3 Not assessed / Chưa đánh giá

- Structural RDC and CDC: no reset-domain or CDC tool report was supplied; the specification declares one clock domain. / Chưa có báo cáo CDC hoặc RDC.
- Post-route ASIC timing and SRAM macro timing: the synthesis run is wire-load zero with every SRAM black-boxed. / Timing ASIC sau P&R và timing SRAM macro: synthesis dùng wire-load 0 và SRAM là black box.
- Power: `synth_power.rpt` was not read. / Chưa đọc `synth_power.rpt`.
- Functional behavior: no simulation or lint was run in this review; RTL statements come from reading the source. / Không chạy simulation hoặc lint trong review này.
- Figures, waveforms and the CSR workbook content were not opened; the HDS text that describes them was read. / Chưa mở hình, waveform và nội dung workbook CSR.
- Market comparison uses web results and no vendor datasheet; competitor area and power were not obtained. / So sánh thị trường dùng kết quả web, không có datasheet.

### 21.4 Gate and waivers / Gate và waiver

`RESULT: PASS` from `vlsit_review_gate.py metrics` (re-run 2026-11-21 with W-2); findings 27; waiver usage 2/10; unwaived Critical 0; 100% of findings traced; closure rate 0.92. Waiver W-1: F-016 (owner SoC architect; invalidation: no SoC watchdog or system reset path for the cluster, or a field availability target). Waiver W-2: F-001 (owner Architect; invalidation: the accepted-period sweep of HDS Section 8.3 exists and shows the planning period of PD-01 is not met, or a product frequency target is signed). Granted by the project owner on 2026-11-21; the finding stays open as OPEN-TIMING-TARGET and the waiver is not evidence that timing closes.

### 21.5 Root-cause groups / Nhóm root cause

| Group | Findings | Count |
|---|---|---|
| DFT hand-off | F-017 | 1 |
| coherence liveness | F-013, F-027 | 2 |
| directory storage and sizing | F-006, F-007, F-014 | 3 |
| documentation | F-020, F-024, F-026 | 3 |
| interrupt and ABI contract | F-010, F-011, F-019 | 3 |
| parameter legality | F-012 | 1 |
| profile specification drift | F-004, F-005 | 2 |
| reliability | F-015, F-016, F-018, F-023, F-025 | 5 |
| reset used as data | F-003 | 1 |
| timing target vs architecture | F-001, F-002 | 2 |
| unquantified performance | F-008, F-009 | 2 |
| verification evidence | F-021, F-022 | 2 |

Tracing depth (R-022): all 27 findings were traced to a file and line; no group has more than ten members, so none was aggregated without a trace. / Độ sâu truy vết (R-022): cả 27 phát hiện đều được truy tới file và dòng; không nhóm nào quá mười phần tử nên không có nhóm nào bị gộp mà không truy vết.

### 21.6 Review of the review / Audit của review

| Finding | Judgement | Basis |
|---|---|---|
| audit F-009 | tp | Searched the HDS for a CBO rate, packet rate or throughput requirement and found none; 1500 / 16 = 93.75 lines, labelled INFERENCE in the finding. |
| audit F-003 | tp | tile_coh_adapter.sv:136 and axi_route.sv:425 assign the handshake enable from i_rst_n_cluster in the direct branch; cluster_core.sv:292 enables the registered release only for profile 2; the in2reg (-2.16 ns) and in2out (-0.60 ns) paths are in the synthesis report. |
| audit F-010 | tp | TEST-013 only asserts per-hart routing and the interface table has no CSR mapping; cpu_tile.sv:27 records the corrected MEIP/SEIP ordering, which confirms the earlier defect. |

False-positive rate 0 of 3 (0%); false-negative rate 0 of 3 (0%); no missed finding was found in the sampled areas. / Tỷ lệ false-positive 0 of 3 (0%); false-negative 0 of 3 (0%); no missed finding was found in the sampled areas.

### 21.7 Sources / Nguồn

| Statement | Source | Date accessed |
|---|---|---|
| Andes AX45MP: up to four cores, MESI coherence manager, I/O coherence, about 2.4 GHz at 12 nm | https://www.cnx-software.com/2020/12/08/andes-adds-l2-cache-multi-core-support-to-linux-capable-risc-v-cores/ (press, 2020) | 2026-11-20 |
| SiFive U74-MC: four U74 cores plus a monitor core, 2 MB L2 with ECC, coherent | https://design-reuse.com/sip/u74-mc-multicore-four-u74-cores-and-one-s76-core-ip-48548 | 2026-11-20 |
| CVA6 with HPDcache about 1090 MHz in GF22 FDX, worst case 0.72 V and -40 C, synthesis estimate; 2.83 CoreMark/MHz | https://arxiv.org/html/2505.03762v2 | 2026-11-20 |
| AMBA AXI protocol, IHI 0022H | cited by the specification (REF-001); clause numbers not re-read | not re-read |

### 21.8 Status of F-001 after the P0 edit / Trạng thái F-001 sau khi sửa P0

EN: On 2026-11-20 the specification (`VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md`: REQ-PD-001, TEST-055, DEC-045, §8.3, OPEN-TIMING-TARGET) was edited so that 1.25 ns and 1.04167 ns are STA evaluation points, not acceptance targets, and the accepted period must come from a 2.0 to 3.5 ns sweep with named corner, SRAM models, I/O model and per-group worst path. The profile mechanism is reported separately from PPA claims. FACT: the text is in the specification. FACT: no sweep has been run, no accepted period exists, and the edit is labelled proposed pending architect approval, because DEC-045 was user approved. INFERENCE: the Blocker would be closed on the wording side, but the timing risk itself remains until the sweep and a decision on CVA6 internals exist. The gate result is not changed by this note.

VI: Ngày 2026-11-20 đặc tả (`VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md`: REQ-PD-001, TEST-055, DEC-045, §8.3, OPEN-TIMING-TARGET) được sửa để 1,25 ns và 1,04167 ns là điểm đánh giá STA, không phải mục tiêu nghiệm thu; chu kỳ được chấp nhận phải lấy từ quét 2,0 đến 3,5 ns kèm corner, model SRAM, model I/O và path xấu nhất của từng nhóm. Cơ chế profile được báo cáo tách khỏi tuyên bố PPA. FACT: nội dung đã nằm trong đặc tả. FACT: chưa chạy sweep, chưa có chu kỳ được chấp nhận, và bản sửa ghi là đề xuất chờ architect duyệt vì DEC-045 do người dùng duyệt. INFERENCE: Blocker được đóng ở phần câu chữ, nhưng rủi ro timing vẫn còn cho tới khi có sweep và quyết định về phần lõi CVA6. Kết quả gate không đổi theo ghi chú này.

### 21.9 Status of the P1 findings after the P1 edit / Trạng thái các phát hiện P1 sau khi sửa P1

EN: On 2026-11-20 the specification (`VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md`) was edited for the P1 actions. Every new text is labelled proposed, pending architect approval. FACT: no RTL, simulation or synthesis was run for this edit. F-004, F-005 and F-010 were already closed by the current text (tests TEST-057 to TEST-061 list profiles 0, 1 and 2, the REQ-PERF-007 traceability row exists, §8.1 lists profile 2 and the internal parameters, REQ-IRQ-003 and TEST-013 map MEIP and SEIP), so no change was needed. F-002 (REQ-PD-002, §17.1), F-003 (REQ-PD-003), F-006 (REQ-MEM-025), F-016 (REQ-RST-002), F-021 (PROP-001 to PROP-014), F-022 (sign-off rule in §15.1), F-023 (§7.4 now cites REQ-CLK-002 and TEST-062) and the measurement parts of F-007, F-008, F-014 (§13, TEST-046) have new text. F-009, F-011, F-013, F-014, F-015, F-017 and F-025 are product or design decisions, so they stay open as OPEN-CBO-RATE, OPEN-ABI, OPEN-PROBE-FAIR, OPEN-DIR-CONFLICT, OPEN-ECC and OPEN-DFT with proposed content. The new requirements describe behavior that profiles 0 and 1 do not yet have, and no RTL implements REQ-MEM-025, so the findings close only when the RTL and the evidence exist. The gate result is unchanged.

VI: Ngày 2026-11-20 đặc tả được sửa theo các action P1; mọi nội dung mới ghi là đề xuất chờ architect duyệt. FACT: không chạy RTL, mô phỏng hay synthesis cho bản sửa này. F-004, F-005, F-010 đã được văn bản hiện tại đóng sẵn (TEST-057 đến TEST-061 liệt kê profile 0, 1, 2; có hàng truy vết REQ-PERF-007; §8.1 có profile 2 và tham số nội bộ; REQ-IRQ-003 và TEST-013 ánh xạ MEIP, SEIP) nên không cần sửa. F-002, F-003, F-006, F-016, F-021, F-022, F-023 và phần đo của F-007, F-008, F-014 có nội dung mới. F-009, F-011, F-013, F-014, F-015, F-017, F-025 là quyết định sản phẩm hoặc thiết kế nên vẫn mở dưới dạng OPEN-CBO-RATE, OPEN-ABI, OPEN-PROBE-FAIR, OPEN-DIR-CONFLICT, OPEN-ECC, OPEN-DFT kèm nội dung đề xuất. Các requirement mới mô tả hành vi mà profile 0 và 1 chưa có, và chưa có RTL cho REQ-MEM-025, nên các phát hiện chỉ đóng khi có RTL và bằng chứng. Kết quả gate không đổi.

### 21.10 Defaults for the open decisions and figure changes / Mặc định cho các quyết định còn mở và thay đổi sơ đồ

EN: The specification now holds a default for each decision that the P1 edit left open: HDS §20.7, PD-01 to PD-10 (planning period 3.5 ns, evaluation I/O delay, registered reset release in every profile, ECC and parity per array, DFT hand-off, CBO rate, unchanged ABI, aging limit, directory growth rule, watchdog timeout). FACT: each default is derived from numbers already in the specification or the synthesis evidence, and each states what replaces it. A default is not an architect approval, so the open items stay listed with a pointer to the default, and the findings close only when RTL and evidence exist. The diagrams were also reworked: 58 one-box diagrams were removed, six internal functional diagrams were added, and the cluster core diagram shows 17 wire-derived connections. Four malformed table regions of the HDS were repaired (TEST-057 to TEST-061 lacked the configuration cell; two back-to-back tables were separated). The remaining checker error is the bilingual text, a recorded user choice that overrides rule R-005.

VI: Đặc tả giờ có mặc định cho từng quyết định mà bản sửa P1 còn để mở: HDS §20.7, PD-01 đến PD-10 (chu kỳ kế hoạch 3,5 ns, I/O delay đánh giá, nhả reset qua flop ở mọi profile, ECC và parity theo từng mảng, bàn giao DFT, tốc độ CBO, giữ nguyên ABI, giới hạn aging, quy tắc mở rộng directory, timeout watchdog). FACT: mỗi mặc định suy ra từ số liệu đã có trong đặc tả hoặc bằng chứng synthesis và nêu rõ cái gì sẽ thay thế nó. Mặc định không phải phê duyệt của architect nên các mục mở vẫn được liệt kê kèm con trỏ tới mặc định, và phát hiện chỉ đóng khi có RTL và bằng chứng. Sơ đồ cũng được làm lại: bỏ 58 sơ đồ một khối, thêm sáu sơ đồ chức năng nội bộ, sơ đồ cluster core có 17 kết nối suy từ dây. Bốn vùng bảng lỗi của HDS đã sửa (TEST-057 đến TEST-061 thiếu ô cấu hình; hai bảng dính nhau được tách). Lỗi checker còn lại là văn bản song ngữ, lựa chọn đã ghi của người dùng, ghi đè quy tắc R-005.


### 21.11 Owner decisions of 2026-11-21 / Quyết định của chủ dự án ngày 2026-11-21

EN: The project owner decided two things. First, the defaults PD-01 to PD-10 (and the requirements REQ-PD-002, REQ-PD-003, REQ-MEM-025 and REQ-RST-002 that they cite) are working decisions, so their labels changed from proposed to decided. Second, the cluster HDS is now English only: the Vietnamese paragraphs moved to the companion file `VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS_vi.md`, and the specification checker reports no error (rule R-005 is met). FACT: no RTL, simulation or synthesis result changed. A decided default is still not a measured result, so findings F-001 to F-009, F-011, F-013 to F-017 and F-025 stay open until RTL and evidence exist, and the gate result is unchanged.

VI: Chủ dự án quyết định hai việc. Một là các mặc định PD-01 đến PD-10 (cùng các requirement REQ-PD-002, REQ-PD-003, REQ-MEM-025, REQ-RST-002 mà chúng dẫn tới) là quyết định làm việc, nên nhãn đổi từ đề xuất sang đã chốt. Hai là HDS cluster nay chỉ có tiếng Anh: các đoạn tiếng Việt chuyển sang file `VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS_vi.md`, và checker đặc tả không báo lỗi (đáp ứng quy tắc R-005). FACT: không có kết quả RTL, mô phỏng hay synthesis nào thay đổi. Mặc định đã chốt vẫn không phải số đo, nên các phát hiện F-001 đến F-009, F-011, F-013 đến F-017 và F-025 vẫn mở đến khi có RTL và bằng chứng; kết quả gate không đổi.
