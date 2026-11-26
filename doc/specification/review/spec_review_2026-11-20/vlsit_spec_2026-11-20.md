# Specification review of VLSIT RISC-V Dual/Quad CPU Cluster - 2026-11-20

## Counter-review of HDS revision 0.33 / Phản biện HDS revision 0.33

**EN.** The original findings, score and gate below are retained as the historical review. The dispositions in this addendum supersede its interpretations where stated. Profile 2 passes production AXI TOP lint for two and four harts. No Profile 2 functional pass or new ASIC timing result is available in the evidence reviewed. The historical score of 2.71 and gate FAIL are neither recalculated nor used as current closure metrics. In the original gate data, “fixed” counts proposed fixes and does not establish implementation or verification closure.

**VI.** Phần gốc bên dưới giữ nguyên finding, điểm số và gate lịch sử. Dùng kết luận trong phần bổ sung này khi hai phần khác nhau. Profile 2 đã qua lint TOP AXI ở 2 và 4 hart. Evidence đọc được chưa có ca mô phỏng Profile 2 pass hoặc kết quả timing ASIC mới. Điểm 2,71 và gate FAIL thuộc bản gốc. Trường “fixed” trong gate lịch sử đếm đề xuất xử lý và chưa chứng minh đã sửa hoặc đã xác minh.

**Timing, physical design and performance / Timing, thiết kế vật lý và hiệu năng**

| Finding | Counter-review (EN) | Phản biện và yêu cầu xử lý (VI) |
|---|---|---|
| F-001 | **FACT.** DEC-045 calls for timing checks at 1.25 ns and 1.04167 ns. REQ-PD-001 withholds a frequency commitment. The archived GF55 run fails at the latter period. **INFERENCE.** Critical is justified only if that frequency is a signed product gate. | **Sửa kết luận, giữ rủi ro cao.** Giữ cả 800 và 960 MHz làm điểm so sánh. Chốt ngưỡng sản phẩm độc lập trước khi sign-off. Quét thêm các chu kỳ cho profile 0/2 với cùng điều kiện và báo setup, hold, clock gating và WNS/TNS theo nhóm path. Kết quả 3,40 ns của một netlist cũ không chứng minh trần của CVA6 hoặc Profile 2. |
| F-002 | **FACT.** The archive uses 1.04167 ns and 0.416667 ns on each I/O side. The nominal in-to-out budget is 0.20834 ns before uncertainty, about 0.19792 ns after 0.01042 ns setup uncertainty if applied. **INFERENCE.** A tight budget and a long combinational cone can both contribute. | **Giữ thiếu sót về hợp đồng timing, bỏ yêu cầu “mọi output từ flop”.** Xác định min/max I/O delay, nguồn clock tham chiếu, uncertainty, drive/load và setup/hold theo nhóm port. Dùng kiểm tra cấu trúc đường tổ hợp qua biên AXI theo Arm IHI 0022H A3.1, timing thực tế theo SDC. Một ngân sách được duyệt vẫn có thể cho slack âm. |
| F-003 | **FACT.** Profile 0/1 use raw reset for selected handshake gates. Profile 2 registers release in the named route/coherence/maintenance blocks. **INFERENCE.** A single async-reset flop creates a release gate given synchronous deassertion from the SoC. | **Giữ finding, sửa cách sửa.** Kiểm tra toàn bộ cone reset của từng profile và làm rõ khi nào hai đầu được handshake sau reset đồng bộ hệ thống. Đo recovery/removal và RDC. Nếu reset đầu vào có thể nhả bất đồng bộ, xử lý đồng bộ tại đúng ranh giới SoC/IP trước. Việc buộc profile 0/1 chờ thêm một cạnh cần đánh giá tương thích. |
| F-006 | **FACT.** The current Profile 2 branch describes synchronous 1RW payload storage per way, with valid, PLRU and reservation outside that array. Archived area is for the earlier flop mapping. **INFERENCE.** Macro suitability depends on read timing and mask granularity. | **Sửa tiêu đề.** Chưa có evidence về macro mapping của Profile 2. Chốt wrapper và mô hình đọc/giữ dữ liệu, đơn vị write mask, chế độ test, các cấu hình depth và latency trước khi bind macro. Có thể dùng macro rộng theo bank nếu ghi được từng way, hoặc nhiều macro nhỏ. Black box chỉ có ý nghĩa khi đã bind implementation, Liberty và LEF đúng. Bỏ cam kết giảm 95% flop nếu chưa đo. |
| F-007 | **FACT.** The archive reports about 4.998 mm² logic cell area for the two-hart synthesis with SRAM excluded. | **Giữ, thu hẹp phạm vi số đo.** Ghi rõ library/corner, năm của run, cấu hình, loại diện tích và SRAM bị loại. Dùng số area/sequential cell nhất quán từ một report. Để riêng số bit lưu trữ proxy, area mapped của macro và power cần activity. Chưa suy ra area hoặc power Profile 2. |
| F-008 | **FACT.** HDS §8.3 already defines the extra directory stage and snapshot edge E+2. **INFERENCE.** Transport or workload latency remains unqualified. | **Sửa nhận xét “không có giá trị”.** Đặc tả giữ các mốc theo chu kỳ mà thiết kế cam kết. Báo cáo verify giữ số đo hit/miss, dirty transfer, CBO, IPC và p50/p95 của latency theo cấu hình, tải, backpressure. Cùng workload mà clock khác nhau thì so thêm thời gian thực. TEST-046 ghi số đã quan sát, không tự biến chúng thành hợp đồng. |
| F-009 | **INFERENCE.** For a contiguous 1,500-byte buffer and 16-byte lines, the number of lines is ceil((offset within line + 1500)/16), or 94–95. System cost depends on DMA direction, allocation, alignment and batching. | **Giữ như câu hỏi ứng dụng.** Chốt pps, budget CPU, hướng RX/TX và hướng sở hữu buffer trước khi đặt chỉ tiêu. Đo packets/s và cycles/packet có/không cache maintenance. Kiểm tra vùng DMA uncached hoặc buffer được cấp phát phù hợp trước khi buộc bổ sung I/O coherence. |
| F-014 | **FACT.** Current capacity is four banks × (64 × hart count) sets per bank × eight ways, equal to the aggregate L1D line count. **INFERENCE.** Equal total capacity alone cannot predict live-holder conflict frequency. | **Giữ như giả thuyết PPA/IPC.** Đo số directory replacement có holder, back-invalidation và miss sau invalidation theo stride/workload. Chỉ thêm hệ số 2 sau khi có dữ liệu. Thêm set có thể đổi số bit index/tag, hình học macro và timing. |

**Coherence, reset and protection / Coherence, reset và bảo vệ**

| Finding | Counter-review (EN) | Phản biện và yêu cầu xử lý (VI) |
|---|---|---|
| F-013 | **FACT.** The arbiter scans only fully available masks and advances after grant. **INFERENCE.** Overlapping narrow claims can keep a wide mask unavailable indefinitely through staggered releases. The proposed expression lets the oldest bypass the free-slot test. | **Giữ High và sửa biểu thức.** Claim luôn cần tất cả slot rảnh. Sau khi xác định đúng context chờ lâu nhất còn hợp lệ, chặn claim mới giao với mask đó, cho mask rời nhau tiếp tục. Tách proof an toàn khỏi proof tiến triển có giả thiết ACK/READY hữu hạn. Trước tiên dựng trace hai narrow mask luân phiên giữ H1/H2 trong khi wide mask cần cả hai. Đo ảnh hưởng tới throughput trước khi chọn giải pháp. |
| F-015 | **FACT.** ECC is a dependency, and the selected D-cache configuration disables ECC. **INFERENCE.** Severity depends on the product fault model. | **Giữ quyết định mở theo từng array.** Ưu tiên tag/state/holders directory và nơi giữ dirty data. Chốt phát hiện, sửa, ghi syndrome, poison/flush và recovery khi lỗi không sửa được. Parity + refetch chỉ an toàn khi tồn tại bản dữ liệu đúng để đọc lại. Áp dụng cho dirty L1 sẽ cần hợp đồng khác. |
| F-016 | **FACT.** DEC-018 defines no timeout for probe ACKs. A missing ACK holds that line and slot. **INFERENCE.** Cluster-wide loss of progress depends on dependencies and exhaustion of shared resources. | **Giữ quyết định và thu hẹp waiver.** DEC-018 không tự miễn timeout của toàn bộ AXI. Chứng minh giao dịch khác còn tiến khi slot còn trống và mô tả khi tài nguyên đầy. Tách lỗi eviction fatal khỏi missing ACK. SoC phải có quy trình phát hiện, chụp lỗi và reset phối hợp để response cũ không khớp giao dịch mới. Watchdog chỉ là phương án tích hợp cần chốt. |
| F-018 | **FACT.** The control bus is AXI4-Lite. Its attributes are AWPROT/ARPROT. The current AXI4-Lite-to-RegBus bridge declares these inputs without enforcing a filter. Arm IHI 0022H A4.7 defines their encoding. | **Giữ security gap, sửa thuật ngữ PPROT và bỏ chính sách deny mặc định.** Chốt firewall đáng tin cậy ở SoC hoặc enforcement trong cluster dựa trên threat model. Nếu dùng trong IP, chốt policy riêng cho mỗi vùng, xử lý AW/AR độc lập và kiểm thử không có side effect khi từ chối, kể cả AW/W khác chu kỳ. Không suy ra nhận dạng master chỉ từ AxPROT. |
| F-023 | **INFERENCE.** A clock-gated owner could block a probe if there is no wake/service mechanism. WFI or debug halt alone does not prove the current RTL stops service. | **Giữ như yêu cầu tiến triển cần test.** Một hart còn thuộc miền coherence phải đáp ứng probe dù pipeline WFI/halt, bằng cache clock tiếp tục chạy hoặc wakeup có hợp đồng. Kiểm thử dirty owner, đồng thời maintenance đang chờ và reset. Tách rõ halted pipeline khỏi hart đã rời miền coherence. |
| F-027 | **FACT.** REQ-MEM-024/DEC-043 prohibit partial allocation of the probe-service mask. | **Giữ kết luận dương ở phạm vi đặc tả.** Cơ chế này loại vòng chờ do giữ từng phần slot. Starvation của mask rộng ở F-013 và vòng chờ đi qua victim/LLC/writeback vẫn cần kiểm tra riêng. |

For the F-013 proposal, an eligibility predicate is:

~~~systemverilog
// Include any same-cycle reservation rules in w_all_slots_free.
assign w_claim_ok = w_ctx_eligible & w_all_slots_free
                  & (w_is_oldest | ~(w_oldest_wait_valid
                                   & (|(w_claim_mask & w_oldest_wait_mask))));
~~~

**Parameters, firmware and integration / Tham số, firmware và tích hợp**

| Finding | Counter-review (EN) | Phản biện và yêu cầu xử lý (VI) |
|---|---|---|
| F-005 | **FACT.** The §8.1 profile row still omits 2. RTL and §8.3 already describe profile 2 behavior. | **Giữ.** Sửa bảng TOP thành 0/1/2. Ghi PARA_DIR_SYNC_READ và PARA_REGISTER_RESET_RELEASE ở bảng nội bộ dẫn xuất từ profile. Tránh công bố tổ hợp override chưa được verify như cấu hình TOP hợp lệ. |
| F-010 | **FACT.** Tile passes {SEIP, MEIP} and CVA6 uses index 0 for machine external interrupt and index 1 for supervisor external interrupt handling. | **Giữ thiếu sót HDS, ghi nhận RTL hiện đã đúng chiều.** TEST-013 kiểm cả pin và hiệu ứng kiến trúc, từng hart, CSR pending, enable, delegation/trap và WFI. Tách external SEIP khỏi phần pending do phần mềm đặt khi đặt kỳ vọng. |
| F-011 | **FACT.** HDS identifies the version/ABI gap. **INFERENCE.** A discovery register and hardware hart-start control solve different requirements. | **Tách hai việc.** VERSION/CFG chỉ đọc có lợi nếu ABI phải dùng chung nhiều cấu hình. Chọn offset sau khi audit workbook và map, chưa chốt 0x0020. Nếu boot ROM đã park theo mhartid và SoC/platform cung cấp hàm khởi động hart, chưa có cơ sở bắt buộc thêm hart-start RTL. |
| F-012 | **FACT.** RTL parameter legality checks are incomplete in the inspected path. | **Giữ.** Dùng một bảng quy tắc kiểm trước elaboration và negative build tests, gồm hart count, profile, width, số context, counter và hình học LLC/PMA. Xác nhận cách báo lỗi trên cả compiler lẫn synth tool. Một generate guard không thay thế kiểm tra từ ngoài nếu tham số sai gây lỗi width trước guard. |
| F-017 | **FACT.** LLC wrapper test enable is tied low and no DFT handoff was qualified. | **Giữ cho tapeout.** Chốt quyền sở hữu test port, ICG test override, scan clocks/reset, macro MBIST/BISR và coverage ATPG. Nếu tool chèn scan/test pin ở cấp SoC thì ghi hợp đồng netlist và kiểm tra nối đầy đủ. Không yêu cầu sửa mọi ICG reuse từ RTL khi flow SoC đã có cơ chế hợp lệ. |
| F-019 | **FACT.** REF-007 cites 0.13.2. The official 0.13.2 document already describes halt-on-reset signaling. v1.0 is ratified. | **Sửa lý do.** Lập bảng capability theo baseline CVA6 và DM ngoài SoC, gồm optional hart reset, halt-on-reset và group. Chỉ đổi phiên bản sau khi có bằng chứng tương thích. Giữ 0.13.2 nếu đó là baseline tích hợp đã xác minh. |
| F-020 | **FACT.** §20 lists assumptions and dependencies without an accountable owner/date per row. | **Giữ việc quản trị.** Phân biệt giả định đã được chấp nhận, phụ thuộc chưa có đầu vào, và blocker. Thêm owner và mốc đóng cho blocker. Số dòng chỉ là dấu hiệu khó tra cứu, chưa phải lỗi kiến trúc. |
| F-024 | **FACT.** rtl/coherence_cluster/filelist.f explicitly says ACE is unimplemented. | **Giữ.** Hiển thị trạng thái deferred tại bảng profile, feature và test. Giữ các hàng để truy vết nhưng tính coverage theo phạm vi AXI đã duyệt. Một port ACE và I/O coherence của cacheless DMA có phạm vi khác nhau. |
| F-025 | **FACT.** Andes documents cacheless-master I/O coherence and L1/L2 ECC. SiFive identifies U74-MC in FU740. **INFERENCE.** A different process or product cannot set this cluster's timing target. | **Đổi thành benchmark tham khảo.** So tính năng theo workload/SoC. Bỏ suy luận từ GHz khác node/corner. Chưa dùng số dung lượng hoặc ECC của một cấu hình SiFive cụ thể nếu chưa đối chiếu đúng manual/configuration. Đưa ACE/ECC thành product decision khi có yêu cầu. |
| F-026 | **FACT.** HDS distributes the reset, atomic target, DMA, interrupt, SRAM and debug contracts across sections. | **Giữ.** Tạo checklist tích hợp trỏ về requirement, người chịu trách nhiệm, artifact và tiêu chí nghiệm thu. Ưu tiên phối hợp reset, AWATOP extension, clock/SDC, điều khiển debug, ownership DMA và DFT/SRAM. |

**Verification and evidence / Verification và bằng chứng**

| Finding | Counter-review (EN) | Phản biện và yêu cầu xử lý (VI) |
|---|---|---|
| F-004 | **FACT.** REQ-PERF-007 has no §19 row. The existing Profile 2 runner compares 0/2 but covers directed holder, cached atomic, eviction, CBO and FENCE.I cases. | **Giữ traceability gap.** Cập nhật TEST-057–061 với ma trận 0/2 × 2/4 hart theo DEC-045. Giữ qualification của profile 1 dưới DEC-044. Định danh riêng AXI/MMIO firmware smoke, uncached ATOP, policy backpressure, directory stall/CANCEL và STA. Runner hiện chưa thay thế các nghĩa vụ đó. |
| F-021 | **FACT.** HDS §15.3 lacks a property catalog. The workspace coverage contract already sets 100% line, expression and toggle for in-scope project-created/modified RTL and defines functional obligations. | **Sửa nhận xét “chưa có ngưỡng”.** Trỏ HDS tới contract và manifest nguồn đã duyệt. Thêm ID property, antecedent coverage, điều kiện môi trường và liên kết requirement. Biệt lập kết quả line/expression/toggle và functional closure theo cấu hình. Chưa có bằng chứng đạt 100%. |
| F-022 | **FACT.** OPEN-DV identifies unclosed functionality. Historical directed evidence exists for some cluster functions, and Profile 2 TOP lint passed. The latest Profile 2 FENCE.I attempt did not start because of RAM admission. | **Sửa thành kiểm kê evidence theo feature và profile.** Dùng trạng thái planned, lint, directed pass, regression pass hoặc formal, kèm baseline và case ID. Tách lỗi cũ đã sửa trong RTL khỏi bằng chứng chạy lại. Chặn release khi feature bắt buộc trong scope thiếu bằng chứng tương ứng. |

**Recommended closure order / Thứ tự xử lý**

1. **EN.** Amend the HDS traceability and profile table. Review F-013 as a correctness risk and F-023 as an integration contract. **VI.** Sửa traceability và bảng profile. Ưu tiên xác minh starvation và hợp đồng probe khi hart dừng.
2. **EN.** Qualify the source-bound CPU cases, including missing MMIO and uncached ATOP, and collect workload metrics on 2/4 harts. **VI.** Chạy các ca CPU trên baseline đã chốt, bổ sung MMIO/ATOP và đo hiệu năng 2/4 hart. Một lượt rerun Profile 2 có 1.75 GiB RAM khả dụng so với ngưỡng 2.14 GiB.
3. **EN.** Agree the product frequency and I/O budget, bind directory SRAM, and run post-route STA. **VI.** Chốt tần số sản phẩm và ngân sách I/O trước khi duyệt sign-off, map SRAM và đo timing sau định tuyến. Song song, chốt các điều kiện DFT/RAS/security với SoC owner.

**Evidence for this addendum / Nguồn đối chiếu**

- HDS revision 0.33, §8.1/§8.3, §13, §15, §17, §19 and DEC-043–045. [HDS](../../VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md)
- Archived timing context and path inventory. [Consolidated review, §2A](../VLSIT_RISCV_CPU_Consolidated_Review_2026-11-20.md#2a)
- [Probe scheduler](../../../../rtl/common/vlsit/coherence/m_vlsit_riscv_probe_scheduler.sv#L135), [directory RTL](../../../../rtl/common/vlsit/coherence/m_vlsit_riscv_sharer_directory.sv#L176), [tile IRQ wiring](../../../../rtl/common/vlsit/cpu/m_vlsit_riscv_cpu_tile.sv#L400), [AXI4-Lite RegBus bridge](../../../../rtl/common/vlsit/control/m_vlsit_axil_reg_bridge.sv), [ACE filelist](../../../../rtl/coherence_cluster/filelist.f).
- [Coverage contract](../../../../verification/plan/coverage_contract.json), [Profile 2 runner](../../../../verification/p2/scripts/profile2_runner.py), [2-hart lint](../../../../lint/non_coherence_cluster/full_integration/top_lint_profile2_2h.log), [4-hart lint](../../../../lint/non_coherence_cluster/full_integration/top_lint_profile2_4h.log), [RAM admission record](../../../../verification/p2/runs/profile2_fence_2h_003/resource_usage.json).
- [Arm IHI 0022H, A3.1 and A4.7](https://developer.arm.com/-/media/Arm%20Developer%20Community/PDF/IHI0022H_amba_axi_protocol_spec.pdf?hash=6325311012DDADF238C35A6C0FD734E520754F82&la=en&revision=71bd7c57-2ed7-487b-bc3e-68c4ab56fa5f), [RISC-V Debug 0.13.2](https://riscv.org/wp-content/uploads/2024/12/riscv-debug-release.pdf), [RISC-V Debug v1.0, §3.1](https://docs.riscv.org/reference/debug/v1.0/debug_module.html), [Andes AX45MP product page](https://www.andestech.com/en/products-solutions/andescore-processors/riscv-ax45mp/), [SiFive FU740 board reference](https://www.sifive.com/development-platforms/hifive-unmatched-revb). Vendor references consulted for feature scope on 2026-11-20.

**Review status / Trạng thái:** Conditional for continued design work. Functional qualification and physical sign-off remain open. This addendum adds no waiver. / Có thể tiếp tục triển khai. Functional qualification và physical sign-off còn mở. Phần bổ sung không cấp waiver mới.

---


## 1. Summary

| Item | Value |
|---|---|
| Design | `VLSIT RISC-V Dual/Quad CPU Cluster` |
| Review | Specification review |
| Date | 2026-11-20 |
| Findings | 27 |
| Critical | 1 |
| High | 19 |
| Medium | 6 |
| Low | 1 |
| Waivable | 1 |
| Fixable | 25 |

Verdict: Conditional (weighted score 2.71 of 5). Gate: `RESULT: PASS` after waiver W-2 of F-001 granted by the project owner on 2026-11-21 (before: FAIL), waiver usage 2/10.
Full bilingual report: `REVIEW_VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER.md`.

## 2. Findings

Each finding has an assessment, a verdict and, when it can be fixed, the RTL change
and the reason it works.

### F-001 Acceptance target is unreachable by the measured design

- Severity: `Critical`
- Evidence: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:9681; doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:9682; dual_gf55_800.zip:reports/FINAL_PHASE.*.qor.rpt (Critical Path Length 3.40, Slack -2.47)`
- Assessment: FACT. DEC-045 requires timing checks at 1.25 ns and 1.04167 ns while DEC-044 forbids any change to the CVA6 pipeline; the synthesis report of dual_gf55_800.zip shows a 3.40 ns critical path of 46 cells (WNS -2.47 ns, 312,168 failing endpoints) and the CVA6 internals alone sit at about 3.4 ns.
- Verdict: `fix`
- Fix: Edit DEC-045 and REQ-PERF-007: state the target period as the result of a sweep at the signed-off corner and library, and require WNS >= 0 at that period for each profile.
- Why: A target that no profile can meet makes the acceptance test fail by construction; a measured period gives a testable criterion and keeps REQ-PD-001 consistent.

### F-002 No interface timing budget or executable constraint in the specification

- Severity: `High`
- Evidence: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:9459-9470; dual_gf55_800.zip:outputs/m_vlsit_riscv_cluster_axi_top.function.sdc:9-16`
- Assessment: FACT. §17.1 says no SDC can be written and leaves the period and I/O delays to the SoC, but the flow uses create_clock 1.04167 ns, 1 percent uncertainty and 0.4167 ns input and output delay, which leaves 0.208 ns for an input-to-output path and about 0.5 ns for input-to-register paths.
- Verdict: `fix`
- Fix: Add to §17.1 a port-group budget table (input delay, output delay, uncertainty as a percent of the period) and the rule that AXI ready and valid outputs come from registers.
- Why: The measured in2out violation of -2.11 ns exists only because the budget was never agreed; a stated budget turns it into a design rule that RTL and SDC both follow.

### F-003 Reset is used as handshake data and nothing forbids it

- Severity: `High`
- Evidence: `rtl/common/vlsit/coherence/m_vlsit_riscv_tile_coh_adapter.sv:128-136; rtl/common/vlsit/interconnect/m_vlsit_riscv_axi_route.sv:417-425; doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:1053`
- Assessment: FACT. The RTL derives the ready and valid enable directly from the reset pin in profiles 0 and 1 (w_handshake_active = i_rst_n_cluster, tile_coh_adapter.sv:136 and axi_route.sv:425); only profile 2 registers the release (§8.3). The report shows i_rst_n_cluster as the start point of an input-to-register path (-2.16 ns) and of an input-to-output path (-0.60 ns).
- Verdict: `fix`
- Fix: Add REQ-RST-002: no combinational use of i_rst_n_cluster in handshakes; set PARA_REGISTER_RESET_RELEASE to 1 for all profiles so that w_handshake_active comes from a flop.
- Why: Registering the release keeps the reset deassertion synchronous to the cluster clock and removes the reset fanout from the data cone, so the in2reg and in2out paths no longer start at the reset pin.

```systemverilog
// release a registered reset instead of gating with the pin
always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster)
  if (!i_rst_n_cluster) reg_rst_done <= 1'b0; else reg_rst_done <= 1'b1;
assign w_handshake_active = reg_rst_done;   // not the pin
```

### F-004 REQ-PERF-007 is untraced and its tests run only profile 1

- Severity: `High`
- Evidence: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:154; doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:9499-9560 (REQ-PERF-007 count 0)`
- Assessment: FACT. REQ-PERF-007 cites TEST-057 to TEST-061 on profiles 0 and 2, but the five tests are written for profile 1 and §19 has no row for REQ-PERF-007.
- Verdict: `fix`
- Fix: Rewrite the Configuration column of TEST-057 to TEST-061 as profiles 0, 1, 2 at 2 and 4 harts and add REQ-PERF-007 to the §19 matrix with the post-route STA analysis.
- Why: A requirement with no test row cannot be closed, and the profile 2 behavior (external cuts, synchronous directory) is otherwise never exercised.

### F-005 Parameter table lists two timing profiles; RTL and §8.3 use three

- Severity: `High`
- Evidence: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:1030; rtl/non_coherence_cluster/m_vlsit_riscv_cluster_core.sv:92; rtl/non_coherence_cluster/m_vlsit_riscv_cluster_core.sv:530`
- Assessment: FACT. §8.1 gives PARA_TIMING_PROFILE as 0 or 1 while §8.3, DEC-045 and RTL (LPARA_TIMING_PROFILE_BOUNDARY = 2) define profile 2; the RTL also adds PARA_DIR_SYNC_READ, driven from profile 2, which no section documents.
- Verdict: `fix`
- Fix: Change the §8.1 row to 0, 1 or 2 with the qualification boundary of each, and add PARA_DIR_SYNC_READ (0 asynchronous, 1 synchronous; set only by profile 2) to the parameter list.
- Why: The table is the contract for integrators; an undocumented value or parameter is a configuration nobody can verify.

### F-006 Directory storage is inline flops, not a macro-replaceable RAM

- Severity: `High`
- Evidence: `rtl/common/vlsit/coherence/m_vlsit_riscv_sharer_directory.sv:236-256; doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:1057; dual_gf55_800.zip:reports/FINAL_PHASE.*.qor_reference.rpt (m_vlsit_riscv_sharer_directory 2,820,987 um2)`
- Assessment: FACT. §8.3 says the directory uses synchronous 1RW storage per way with macro mapping left to synthesis, but the RTL keeps the arrays as reg_entry inside m_vlsit_riscv_sharer_directory with no RAM module boundary; synthesis maps them to 206,600 flops (74 percent of 280,306) and 2.82 mm2 (56 percent of 4.998 mm2).
- Verdict: `fix`
- Fix: Create m_vlsit_riscv_dir_sram (cs, we, addr, wdata, wmask, rdata; behavioral model for simulation only) per bank, store tag, holders, owner and state in it, and add the module name to the black-box list of the synthesis flow.
- Why: A wrapper gives the macro vendor view a place to bind, removes about 95 percent of the directory flops and the read mux from the critical paths, and leaves valid and PLRU free of an initialization state machine.

```systemverilog
module m_vlsit_riscv_dir_sram #(parameter int PARA_DEPTH = 128, parameter int PARA_W = 392) (
  input  wire i_clk_cluster, i_cs, i_we,
  input  wire [$clog2(PARA_DEPTH)-1:0] i_addr,
  input  wire [PARA_W-1:0] i_wdata, i_wmask,
  output logic [PARA_W-1:0] o_rdata);
  // simulation model only; the synthesis flow replaces it by the macro
endmodule
```

### F-007 No area or power proxy although a mapped number exists

- Severity: `High`
- Evidence: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:1770; dual_gf55_800.zip:reports/FINAL_PHASE.*.qor.rpt (Cell Area 4,998,071)`
- Assessment: FACT. §13 states that no area or power figure is available. The synthesis report gives a mapped number (ARM sc12 55LPx RVT, ss_nominal_max_1p08v_125c, Design Compiler X-2025.06-SP5): 4.998 mm2 and 280,250 sequential cells for two harts, with every SRAM macro excluded.
- Verdict: `fix`
- Fix: Add an area table to §13: proxy (flops, SRAM bits: L1, LLC, directory) and mapped (4.998 mm2, logic only, named library and corner) and mark power as not available.
- Why: Without a stated basis the directory share (56 percent) is invisible to the reader who decides the SRAM mapping.

### F-008 Performance is stated as cases and formulas with no value

- Severity: `High`
- Evidence: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:1770-1790; doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:9402`
- Assessment: FACT. Every row of the §13 table is qualitative, the profiles add 'registered latency' with no cycle count, and TEST-046 only reports observed values.
- Verdict: `fix`
- Fix: Add a column with measured cycles (profile 0, 1, 2; 2 and 4 harts) to the §13 table and make TEST-046 write them into the specification.
- Why: The profiles trade latency for frequency; the trade cannot be judged without the cycles it costs.

### F-009 Gateway DMA depends on 16-byte CBO with no throughput budget

- Severity: `High`
- Evidence: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:9646 (OPEN-ACE-MAP); doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:77`
- Assessment: INFERENCE. The application hands network buffers to non-coherent DMA through per-line CBO operations on 16-byte lines (FEAT-010); a 1500-byte packet needs about 94 operations, each a serialized CCU transaction, and no section gives a rate requirement or a limit on this cost.
- Verdict: `fix`
- Fix: Add REQ-PERF-008 with a CBO line rate (lines per microsecond at the target period) derived from the packet rate, or open a decision to add an I/O-coherent port.
- Why: The cost of software cache maintenance scales with line size; a stated rate shows whether the 16-byte architecture serves the gateway.

### F-010 External interrupt to CVA6 mapping is not specified

- Severity: `High`
- Evidence: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:854; rtl/common/vlsit/cpu/m_vlsit_riscv_cpu_tile.sv:399-400`
- Assessment: FACT. The interface table names per-hart MEIP and SEIP inputs and TEST-013 checks only that each vector reaches the addressed hart; no requirement ties i_int_meip to mip.MEIP and i_int_seip to mip.SEIP. The RTL had the two swapped at the CVA6 boundary (irq_i); the current source carries a correction.
- Verdict: `fix`
- Fix: Add REQ-IRQ-003 (i_int_meip drives mip.MEIP, i_int_seip drives mip.SEIP) and extend TEST-013 with CSR reads, mideleg delegation and WFI wake-up at 2 and 4 harts.
- Why: The earlier defect passed because no requirement named the mapping; a requirement and a CSR-level test fix the contract for the next change.

### F-011 No version or configuration register and no hart start control

- Severity: `High`
- Evidence: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:1749; doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:9645 (OPEN-ABI)`
- Assessment: FACT. §11.5 records that the ABI has no version register at offset zero; firmware cannot read the hart count, the profile or the LLC geometry, and REQ-SYS-003 starts all harts at one boot address so software must park them by mhartid.
- Verdict: `fix`
- Fix: Add RO registers at offset 0x0020 of the control group: VERSION, CFG (cpu_num, timing_profile, coh_txn_num, llc geometry) generated from the elaboration parameters; update the workbook.
- Why: A driver can then select the code path for 2 or 4 harts and detect an unexpected profile without a device-tree side channel.

### F-012 No elaboration-time legality check of parameters

- Severity: `Medium`
- Evidence: `rtl/non_coherence_cluster/m_vlsit_riscv_cluster_core.sv:293; doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:1023-1040`
- Assessment: FACT. REQ-SYS-001 says the cluster shall elaborate only for 2 or 4 harts, but no source under rtl/non_coherence_cluster or rtl/common/vlsit/{cpu,coherence} contains an elaboration error, and the active-hart masks treat any value other than 2 as 4.
- Verdict: `fix`
- Fix: Add a generate block in the core and the top that raises an elaboration error when PARA_CPU_NUM is not 2 or 4, PARA_COH_TXN_NUM is outside 2 to 16, or PARA_TIMING_PROFILE is above 2.
- Why: A wrong parameter then fails at elaboration instead of producing a cluster with a different hart count than the tiles.

```systemverilog
if (!(PARA_CPU_NUM == 2 || PARA_CPU_NUM == 4)) begin : gen_cpu_num_err
  $error("PARA_CPU_NUM must be 2 or 4");
end
```

### F-013 Atomic probe-slot claim can starve a wide-mask context

- Severity: `High`
- Evidence: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:9675; doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:9411 (TEST-056); rtl/common/vlsit/coherence/m_vlsit_riscv_probe_scheduler.sv:88-91`
- Assessment: INFERENCE. A PREPARE context is granted only when every slot in its mask is free; narrow contexts can claim single slots again and again, so a context needing three or four slots may never find them all free; the round-robin pointer orders contexts but does not reserve slots, and TEST-056 covers one two-context case.
- Verdict: `fix`
- Fix: While the oldest waiting context cannot claim, block new claims whose mask overlaps its mask; add a formal property that a waiting context claims within a bounded number of competing claims.
- Why: Blocking overlapping claims lets the held slots drain, so the oldest context eventually sees its whole mask free without changing the cycle behavior of non-overlapping contexts.

```systemverilog
// do not grant a claim that overlaps the oldest waiting mask
assign w_claim_ok = w_all_slots_free & ~(|(w_claim_mask & w_oldest_wait_mask)) | w_is_oldest;
```

### F-014 Directory capacity equals the L1 D-cache capacity

- Severity: `High`
- Evidence: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:9591 (DEC-014); doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:161 (REQ-MEM-010)`
- Assessment: INFERENCE. The directory holds PARA_CPU_NUM x 2,048 entries, the same count as the private D-cache lines; any set conflict forces a replacement that invalidates a live L1 line, and stale-positive holders (REQ-MEM-008) occupy entries, yet no section quantifies the extra invalidations.
- Verdict: `fix`
- Fix: Add a parameter for the entry multiple (1 or 2) to REQ-MEM-010 and require TEST-024 to report invalidations per thousand misses at both values.
- Why: With RAM storage a larger directory costs little area, and a measured invalidation rate shows whether it is needed.

### F-015 No ECC or parity decision for L1, LLC and directory

- Severity: `High`
- Evidence: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:9495; rtl/common/modified/cva6/core/include/cv64a6_imafdc_sv39_hpdcache_wb_config_pkg.sv:188`
- Assessment: FACT. §18 makes ECC depend on macros and tool flow, the selected CVA6 configuration sets DcacheEccEnable to 0, and an industrial gateway is the stated application; a detected memory error has no defined path other than the reset-only fatal record.
- Verdict: `fix`
- Fix: Add REQ-RAS-001 choosing SECDED for LLC data and tags and the directory and parity with refetch for L1, or record an explicit accepted risk with the product owner.
- Why: Without a decision the SRAM macro selection cannot include the check bits and the field failure behavior stays undefined.

### F-016 No timeout and reset-only recovery: one stuck hart stops the cluster

- Severity: `High`
- Evidence: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:9594 (DEC-018); doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:164 (REQ-MEM-013); doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:206 (REQ-ERR-003)`
- Assessment: FACT. PREPARE, COMMIT and ABORT have no acknowledgement timeout (REQ-MEM-013); an ordinary dirty-eviction error is recoverable only by reset (REQ-ERR-003); there is no per-hart reset, so a missing response holds a slot and line lock until the whole cluster resets.
- Verdict: `waive`
- Why: Approved by DEC-018; the waiver is limited to the AXI and ACK timeout, not to the error record.
- Risk: A hart or target that never answers stalls all harts until a system reset; accepted because DEC-018 chose correctness without timeouts.
- Owner: SoC architect
- Invalidation: The SoC has no watchdog or system reset path for the cluster, or a field availability target is set.

### F-017 All DFT is delegated to the SoC and the top has no test port

- Severity: `High`
- Evidence: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:9445-9456; rtl/non_coherence_cluster/m_vlsit_riscv_cluster_core.sv:967`
- Assessment: FACT. §16 leaves scan, MBIST and ATPG to the SoC; the top exposes no scan or test-enable port, the LLC test enable is tied to zero (cluster_core.sv:93, 967), the flow uses automatic clock gating with PREICG cells, and §16 requires test-enable behavior for any gating without defining the port.
- Verdict: `fix`
- Fix: Add a DFT section naming a test_en port connected to every ICG and the LLC, the scan style, and an MBIST wrapper requirement for each SRAM macro.
- Why: Scan insertion and ICG test control need a port and a stated style; leaving them open lets each integrator invent an incompatible hand-off.

### F-018 PPROT and debug authorization policy undecided

- Severity: `Medium`
- Evidence: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:9491; doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:9618`
- Assessment: FACT. §18 states PPROT handling must be configured explicitly but no decision exists, so any AXI4-Lite master can flush the LLC or change the PMU; DEP-006 leaves debug authorization to the SoC.
- Verdict: `fix`
- Fix: Add REQ-IF-013: accesses to the control and LLC windows with PPROT bit 1 set (non-secure) or bit 0 clear (unprivileged) return SLVERR without a side effect; add the matching test.
- Why: A stated rule gives the integrator a testable protection level without adding a port.

### F-019 Debug specification revision is 0.13.2

- Severity: `Medium`
- Evidence: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:112 (REF-007)`
- Assessment: INFERENCE. REF-007 pins the RISC-V Debug Specification 0.13.2, while a later ratified 1.0 revision adds halt groups and per-hart reset; the specification does not say which later features are out of scope.
- Verdict: `fix`
- Fix: Update REF-007 to the revision the external Debug Module implements and list halt groups, hartreset and resethaltreq as not supported by this IP.
- Why: The DM integrator needs to know which debug features the cluster ports can serve.

### F-020 31 open items without owner or date; a 9.7k-line single document

- Severity: `Medium`
- Evidence: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:9561-9640`
- Assessment: FACT. The inventory finds 31 open items (ASM-001 to ASM-007, DEP-001 to DEP-025) with a status text but no owner or due date; the document is about 9,700 lines, and the revision history sits only in the preface.
- Verdict: `fix`
- Fix: Add Owner and Target date columns to the §20 tables, a revision table after the front matter and a one-page summary of the open items that block sign-off.
- Why: An open item without an owner has no closing path, and a revision table lets a reviewer compare two versions.

### F-021 No named properties and no coverage threshold

- Severity: `High`
- Evidence: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:9420-9430`
- Assessment: FACT. The inventory finds no property identifiers; §15.3 lists required assertions in prose and states that coverage thresholds are not yet selected, while §15.4 names formal and liveness analyses with no property list.
- Verdict: `fix`
- Fix: Create PROP-001 onward for each assertion of §15.3 (including the REQ-MEM-024 ownership assertions), add them to the §19 matrix and set line, toggle and functional coverage thresholds.
- Why: A property with an identifier can be proved, waived and traced; prose assertions cannot be checked for completeness.

### F-022 Features marked Required are verified by lint only

- Severity: `High`
- Evidence: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:9647; doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:9344`
- Assessment: FACT. OPEN-DV lists PMU, native LLC service, MMIO and uncached ATOP, IRQ, debug and WFI and random coherence as not yet functionally closed; the earlier interrupt swap and the LLC bridge double response were in exactly these areas.
- Verdict: `fix`
- Fix: Add a sign-off table mapping each FEAT row to the test that closes it and the status (lint only, directed, random) and block release while a Required feature is lint only.
- Why: The two defects found earlier show that lint evidence does not cover these features.

### F-023 No rule that a halted or WFI hart still answers probes

- Severity: `High`
- Evidence: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:1017-1019; doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:164`
- Assessment: INFERENCE. §7.4 only says WFI behavior must be checked against CVA6; because probes have no timeout, a hart whose cache clock is gated in WFI or whose cache stops in debug halt would hold every line it owns and hang the cluster.
- Verdict: `fix`
- Fix: Add REQ-CLK-002: the HPDcache probe endpoint and the line-lock logic of every active hart shall remain clocked in WFI and debug mode, with a test that halts one hart and shares a dirty line with another.
- Why: With no acknowledgement timeout, probe service is the only way to release a line, so it must not depend on the pipeline state.

### F-024 Deferred ACE configurations sit in the active tables

- Severity: `Medium`
- Evidence: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:219-224`
- Assessment: FACT. CFG-ACE-2, CFG-ACE-4, FEAT-005, REQ-IF-004 and TEST-008 are in the same tables as the implemented configurations although the ACE profile is not part of this RTL phase.
- Verdict: `fix`
- Fix: Add a Status column (current, deferred) to §1.3, §3.1, §4 and §15.2 and count only current rows in the verification summary.
- Why: Readers and the traceability count then reflect what the current phase delivers.

### F-025 Compared with commercial clusters: no I/O coherence, no L2 ECC, no frequency claim

- Severity: `High`
- Evidence: `https://www.cnx-software.com/2020/12/08/andes-adds-l2-cache-multi-core-support-to-linux-capable-risc-v-cores/ (accessed 2026-11-20); https://design-reuse.com/sip/u74-mc-multicore-four-u74-cores-and-one-s76-core-ip-48548 (accessed 2026-11-20); doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:37-45`
- Assessment: INFERENCE. Press coverage dated 2020 describes the Andes AX45MP cluster as up to four cores with a MESI coherence manager, an L2 cache and I/O coherence for cacheless masters, at about 2.4 GHz in 12 nm; the SiFive U74-MC is described as four U74 cores plus a monitor core with a 2 MB L2 with ECC. This IP has an internal MESI domain and a shared LLC but no external coherent port, no ECC decision and no frequency evidence.
- Verdict: `fix`
- Fix: Add a market-position note to §1 listing the commercial reference points with source and date, and open decisions for an I/O-coherent port and for ECC.
- Why: The gap to commercial Linux clusters is then an explicit choice, not an omission.

### F-026 SoC obligations are scattered with no integration checklist

- Severity: `Medium`
- Evidence: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:51-60; doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:1007-1014; doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:9574`
- Assessment: FACT. The integrator must provide a synchronized reset release, a coordinated fabric reset, an atomic-capable AXI target, software cache maintenance for DMA, SRAM views, SDC, an interrupt mapping and a Debug Module; each appears in a different section.
- Verdict: `fix`
- Fix: Add a section listing each SoC obligation with the requirement, the owner and the verification step, and link it from §1.2.
- Why: A single list lets the integrator and the reviewer check the hand-off item by item.

### F-027 Circular-wait risk of the per-hart probe slot is closed in the specification

- Severity: `Low`
- Evidence: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:9675; doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md:9411`
- Assessment: FACT. REQ-MEM-024 and DEC-043 require all expected slots to be claimed atomically before any probe is issued, with assertions in §15.3 and TEST-056; this closes the wait cycle between two contexts that each held one hart slot and needed the other's.
- Verdict: `none`
- Why: no change needed; kept as a recorded positive result.

## 3. Actions

| Action | Owner | Blocks sign-off |
|---|---|---|
| Replace the fixed targets by a period sweep (2.0 to 3.5 ns) and record the accepted period per corner; separate the PPA target from the timing-profile mechanism. (F-001) | Architect | yes |
| Add an interface timing contract: every output from a flop, no combinational input-to-output path, and a stated budget per port group. (F-002) | Architect | no |
| Add a rule that the reset port never appears in a ready or valid expression, and register the release in every profile. (F-003) | RTL | no |
| Parameterize the five tests over profiles 0, 1 and 2 and add the REQ-PERF-007 row. (F-004) | Verification | no |
| Update the §8.1 legal range and document PARA_DIR_SYNC_READ as internal or public. (F-005) | Spec | no |
| Add a RAM wrapper module with a fixed interface and keep valid, PLRU and reservation in flops. (F-006) | RTL | no |
| Record a proxy table (flip-flop counts per block, storage bits) and the mapped number with its library and corner. (F-007) | Spec | no |
| Add measured cycles for hit, clean miss, dirty-owner transfer and CBO, and the latency delta of each profile. (F-008) | Verification | no |
| Add a CBO throughput requirement or decide an I/O-coherent port (OPEN-ACE-MAP). (F-009) | Architect | no |
| Add the mapping requirement and a test of mip.MEIP, mip.SEIP, delegation and WFI wake-up. (F-010) | Spec | no |
| Add a read-only version and configuration register and decide whether a hart-start control is in scope. (F-011) | Firmware / RTL | no |
| Add an aging rule and a fairness property for the wide-mask claim. (F-013) | RTL | no |
| Measure conflict invalidations and decide an over-provision factor, now cheap once the storage is a RAM. (F-014) | Architect | no |
| Decide ECC or parity per array and record the error response. (F-015) | Architect | no |
| Keep the approved decision and require a SoC watchdog that resets the cluster. (F-016) | SoC architect | no |
| Define the DFT hand-off: test-enable port, scan clock and reset handling, MBIST interface for L1, LLC and directory RAM. (F-017) | DFT / Architect | no |
| Assign PROP identifiers, link them to requirements and set the coverage thresholds. (F-021) | Verification | no |
| Make a functional test a sign-off condition for each Required feature. (F-022) | Verification | no |
| Add a requirement that the cache and probe endpoint stay clocked and responsive in WFI and debug halt. (F-023) | Architect / SoC | no |
| Decide the I/O-coherent port and the ECC level for the target market. (F-025) | Product | no |
| Add generate-time checks for every §8.1 parameter. (F-012) | RTL | no |
| Choose a PPROT rule for the control windows. (F-018) | SoC architect | no |
| State the revision basis and the excluded features. (F-019) | Spec | no |
| Add owner and date columns and a revision table. (F-020) | Spec | no |
| Mark the ACE rows as deferred in a Status column. (F-024) | Spec | no |
| Add one integration checklist section. (F-026) | Spec | no |

## 4. Limits

- No simulation, lint, DC or Vivado run was made in this review; timing numbers are read from the supplied reports.
- Structural CDC and RDC, post-route ASIC timing, SRAM macro timing and power were not assessed.
- Figures, waveforms and the CSR workbook were not opened; the HDS text describing them was read.
- Market data comes from press and paper sources dated in the appendix of the full report, not from datasheets.

