# RISC-V Core Selection for a Dual-/Quad-Core ASIC Cluster
# Báo cáo lựa chọn RISC-V core cho ASIC cluster dual/quad-core

**Project / Dự án:** VLSIT RISC-V CPU  
**Research date / Ngày nghiên cứu:** 2026-11-06  
**Scope / Phạm vi:** Consolidated repository, architecture, performance, ASIC integration and license review for selecting a RISC-V core for a configurable 2- or 4-core cluster.

## Executive summary / Tóm tắt điều hành

This report consolidates the existing dual-core and quad-core analyses with a focused review of high-performance RISC-V cores and their licenses. Repository documentation and published research were reviewed. No candidate repository was cloned or built for this report; no RTL elaboration, simulation, synthesis, STA or PPA measurement was performed locally.

**Recommendation:** Use CVA6 plus HPDcache and an ACE-based coherence unit such as Culsans as the primary practical candidate for a 2/4-core design-space study. Keep the released CVA6 configuration as the reproducible baseline. Evaluate CVA6S+ only after identifying and freezing its exact source revision and confirming compatibility with the selected cache/coherence integration. Use BlackParrot as a multicore/silicon-history comparator. Use XiangShan Nanhu as a high-performance dual-core reference. Keep OpenC910 and BOOM as high-performance alternatives whose system integration and source-generation requirements need more work.

No universal performance-per-watt winner can be established from the available results. Cross-project numbers use different workloads, configurations, process nodes, cache systems and measurement methods. Select the core only after defining the workload, ISA/OS target, area limit, power budget and performance deadline.

**Khuyến nghị:** Dùng CVA6 cùng HPDcache và một khối coherence dùng ACE như Culsans làm ứng viên chính để khảo sát thiết kế 2/4 core. Giữ cấu hình CVA6 đã phát hành làm baseline có thể tái tạo. Chỉ đưa CVA6S+ vào spec sau khi chốt repository/commit và xác nhận tương thích với cache/coherence đã chọn. Dùng BlackParrot làm đối chứng về tích hợp đa lõi và lịch sử silicon; dùng XiangShan Nanhu làm tham chiếu hiệu năng dual-core. OpenC910 và BOOM là các phương án hiệu năng cao nhưng cần nhiều công sức tích hợp hoặc quản lý generator hơn.

Chưa có cơ sở để kết luận core nào luôn tiết kiệm năng lượng nhất. Kết quả giữa các dự án khác workload, cấu hình, công nghệ chế tạo, cache và cách đo. Trước khi khóa core trong spec, cần xác định workload, ISA/OS, giới hạn diện tích, công suất và thời hạn đáp ứng.

## 1. Selection criteria / Tiêu chí lựa chọn

A useful cluster comparison must separate four questions:

1. **Core performance:** issue width, branch prediction, execution latency and ability to keep memory operations outstanding.
2. **Cluster readiness:** whether private caches, coherence, atomics, interrupts and interconnect already form a usable multicore system.
3. **ASIC readiness:** synthesizable RTL, repeatable generator flow, SRAM mapping, constraints and physical-design evidence.
4. **Product fit:** workload, operating system, throughput, latency, area, power, debug and licensing.

CoreMark/MHz, peak frequency or core count alone does not determine application performance or energy. The useful metric is completed work per joule under an area limit and deadline.

**Các yếu tố cần tách riêng khi so sánh:**

1. **Hiệu năng core:** issue width, branch prediction, độ trễ thực thi và khả năng duy trì nhiều yêu cầu bộ nhớ outstanding.
2. **Mức sẵn sàng của cluster:** cache riêng, coherence, atomic, interrupt và interconnect đã tạo thành hệ thống đa lõi dùng được hay chưa.
3. **Mức sẵn sàng ASIC:** RTL tổng hợp được, generator tái tạo được, SRAM mapping, timing constraints và bằng chứng physical design.
4. **Mức phù hợp sản phẩm:** workload, hệ điều hành, throughput, latency, area, power, debug và license.

CoreMark/MHz, tần số cực đại hoặc số core riêng lẻ không dự đoán được hiệu năng ứng dụng hay năng lượng. Chỉ số hữu ích là lượng công việc hoàn thành trên mỗi joule, dưới giới hạn diện tích và thời gian.

## 2. Candidate comparison / So sánh ứng viên

| Core / project | Core and cluster characteristics / Đặc điểm core và cluster | ASIC and integration evidence / Bằng chứng ASIC và tích hợp | License and modify/tapeout meaning / License và quyền sửa/tapeout |
|---|---|---|---|
| **CVA6 + HPDcache + Culsans** | CVA6 is a 6-stage, single-issue, in-order SystemVerilog core. HPDcache supports multiple outstanding requests and configurable write-through/write-back behavior. Culsans is an ACE-based coherent unit documented for 2–4 CVA6 CPUs. CVA6S+ is a dual-issue research variant. / CVA6 là core SystemVerilog 6 stage, single-issue, in-order. HPDcache hỗ trợ nhiều request outstanding và cấu hình write-through/write-back. Culsans là khối coherence ACE được mô tả cho 2–4 CVA6. CVA6S+ là biến thể dual-issue trong nghiên cứu. | Most directly aligned with a 2/4-core ACE cluster. A 2026 study reports a synthesized dual-core CVA6S+ cluster in GF12; this is not evidence that a 4-core version has equivalent PPA or has taped out. / Khớp trực tiếp nhất với cluster ACE 2/4 core. Nghiên cứu năm 2026 báo cáo tổng hợp cluster CVA6S+ dual-core trên GF12; điều này không chứng minh PPA tương đương cho 4 core hay đã tape-out. | Mixed, file-level licenses: CVA6 has SHL-0.51 at repository level, while some files use Apache-2.0 WITH SHL-2.1; HPDcache uses SHL-2.1; Culsans uses SHL-0.51. These permissive hardware licenses allow modification and manufacturing subject to their conditions. Audit the exact commit, files and submodules. / License hỗn hợp theo từng file: CVA6 có SHL-0.51 ở repository, một số file dùng Apache-2.0 WITH SHL-2.1; HPDcache dùng SHL-2.1; Culsans dùng SHL-0.51. Các license hardware permissive này cho phép sửa đổi và chế tạo theo điều kiện tương ứng. Cần kiểm tra đúng commit, file và submodule. |
| **BlackParrot** | RV64, in-order, single-issue core with private coherent L1 caches. The multicore system uses BedRock interfaces and a race-free MESI coherence system. / Core RV64, in-order, single-issue, có L1 coherent riêng. Hệ thống đa lõi dùng giao diện BedRock và coherence MESI. | Repository reports 12 nm quad-core tapeout, further dual-core tapeouts, v2.1 released in 2025 and scaling to 16+ coherent cores. Strong multicore implementation evidence; lower single-thread execution width than OoO/dual-issue candidates. BedRock requires an adapter for an AXI-facing system. / Repository báo cáo tapeout quad-core 12 nm, các tapeout dual-core, bản v2.1 năm 2025 và khả năng mở rộng 16+ core coherent. Bằng chứng tích hợp đa lõi tốt; độ rộng thực thi đơn luồng thấp hơn các core OoO/dual-issue. BedRock cần adapter khi ghép với hệ thống AXI. | BSD-3-Clause for the main repository. Permits use and modification; retain notices, license conditions and disclaimer when distributing. It has no explicit patent grant. / Repository chính dùng BSD-3-Clause. Cho phép dùng và sửa; khi phân phối phải giữ notice, điều kiện license và disclaimer. Không có patent grant tường minh. |
| **XiangShan Nanhu** | High-performance core project implemented with Chisel. Nanhu documentation describes single-/dual-core configurations, private L1/L2 and shared L3, plus AXI memory, DMA and peripheral ports. / Dự án core hiệu năng cao, dùng Chisel. Tài liệu Nanhu mô tả cấu hình một/dual-core, L1/L2 riêng, L3 chung và các cổng AXI memory, DMA, peripheral. | Official docs describe Nanhu targeting 2 GHz at 14 nm and report tapeout. The documented integration is dual-core; do not assume a ready 4-core configuration. Pin stable source/generator revisions before using it as a baseline. / Tài liệu chính thức nêu mục tiêu Nanhu 2 GHz ở 14 nm và báo cáo tapeout. Tích hợp được mô tả là dual-core; không nên giả định có sẵn cấu hình 4 core. Cần pin phiên bản source/generator ổn định. | Mulan PSL v2. Permits use, modification and distribution and grants limited patent rights to covered contributor claims. The patent grant does not automatically cover arbitrary modifications or combinations. / Mulan PSL v2. Cho phép dùng, sửa đổi và phân phối; patent grant giới hạn ở claim thuộc contributor và phạm vi license. Patent grant không tự bao phủ mọi sửa đổi hoặc tổ hợp. |
| **OpenC910** | 12-stage, 3-issue, out-of-order RV64 core. The public repository contains Verilog RTL, simulation collateral, user/integration manuals and implementation scripts. / Core RV64 12 stage, 3-issue, out-of-order. Repository công khai có RTL Verilog, môi trường simulation, tài liệu tích hợp và script implementation. | Strong core-performance candidate, but the public core/system interfaces include project-specific extensions and need adaptation for the selected coherent fabric. It is not a drop-in 2/4-core coherent cluster. / Ứng viên hiệu năng core cao, nhưng giao diện có phần mở rộng riêng và cần chuyển đổi để dùng coherent fabric đã chọn. Đây không phải cluster coherent 2/4 core có thể lắp ghép trực tiếp. | Apache-2.0 for the main repository. Permits modification and use; distribution requires the license, retained notices, prominent change notices and applicable NOTICE attributions. Patent rights are limited to claims contributors can grant. / Repository chính dùng Apache-2.0. Cho phép sửa và sử dụng; khi phân phối phải kèm license, giữ notice, ghi rõ thay đổi và giữ attribution trong NOTICE nếu có. Patent grant chỉ áp dụng trong phạm vi claim contributor có thể cấp. |
| **BOOM / Chipyard** | Parameterizable out-of-order core generated with Chisel. BOOM is not a standalone system; Chipyard provides the supported SoC integration and ASIC flow infrastructure. / Core out-of-order có parameter, được tạo bằng Chisel. BOOM không phải hệ thống độc lập; Chipyard cung cấp hạ tầng tích hợp SoC và flow ASIC. | Good performance/generator research candidate. Requires a controlled generator/toolchain setup and system-level integration. / Ứng viên tốt để nghiên cứu hiệu năng/generator. Cần quản lý generator/toolchain chặt chẽ và tích hợp cấp hệ thống. | Multiple licenses: BOOM repository lists BSD-3-Clause and includes LICENSE.SiFive under Apache-2.0. Identify the applicable license by file and audit Chipyard/dependencies. / Nhiều license: repository BOOM có BSD-3-Clause và file LICENSE.SiFive theo Apache-2.0. Cần xác định license theo file và rà soát Chipyard/dependency. |
| **Rocket Chip** | In-order Rocket core and a configurable TileLink SoC generator. Chipyard documents an explicit four-Rocket configuration. Useful as a lower-complexity baseline, not the highest per-core performance option. / Core Rocket in-order và SoC generator TileLink cấu hình được. Chipyard có cấu hình bốn Rocket cụ thể. Hữu ích làm baseline ít phức tạp hơn, không phải lựa chọn hiệu năng mỗi core cao nhất. | Strong generator-based multicore starting point, but TileLink-to-AXI integration and chosen coherence topology must be pinned. / Khởi đầu đa lõi dựa trên generator tốt; cần pin TileLink-to-AXI và topology coherence. | License not audited file-by-file in this report. Review the selected Rocket Chip/Chipyard revision and its dependencies before product use. / Báo cáo này chưa rà soát license từng file. Cần kiểm tra đúng bản Rocket Chip/Chipyard và dependency trước khi sử dụng sản phẩm. |
| **OpenPiton + Ariane/CVA6** | Tiled coherent platform reference with a distributed memory hierarchy. Useful for studying scalable coherence and memory-system organization. / Nền tảng tiled coherent tham khảo, có memory hierarchy phân tán. Hữu ích để nghiên cứu coherence và tổ chức memory system có khả năng mở rộng. | More hierarchy and routing than may be necessary for a small 2/4-core cluster. / Có thể có nhiều tầng hierarchy và routing hơn mức cần thiết cho cluster nhỏ 2/4 core. | Not audited file-by-file in this report; review the exact repository and submodules. / Chưa rà soát license từng file; cần kiểm tra repository và submodule cụ thể. |
| **PULP cluster / CV32E40P** | Banked TCDM scratchpad, DMA and event-based mechanisms suit regular DSP/data-parallel workloads. It is not a direct drop-in coherent Linux SMP replacement. / Scratchpad TCDM nhiều bank, DMA và event phù hợp workload DSP/data-parallel đều đặn. Không thay trực tiếp cho Linux SMP coherent. | Software manages data placement; bank conflicts and DMA arbitration determine delivered bandwidth. / Phần mềm quản lý vị trí dữ liệu; bank conflict và arbitration DMA quyết định bandwidth thực. | Not audited file-by-file in this report; licenses vary across PULP components. / Chưa rà soát license từng file; các component PULP có thể khác license. |

## 3. Published performance and implementation evidence / Bằng chứng hiệu năng và triển khai đã công bố

- **CVA6S+ core/cache study, 2025:** reports 43.5% performance improvement over scalar CVA6, 10.9% over CVA6S, 9.30% area overhead over scalar CVA6, and 74.1% higher bandwidth than the legacy cache subsystem in the reported study. These are configuration-specific results. [Paper](https://arxiv.org/abs/2505.03762)
- **CVA6S+ coherent dual-core cluster, 2026:** reports geometric-mean SPLASH-3 speedup of 1.75× over single core and 1.21× over a prior scalar-CVA6/cache cluster; synthesis in GF12 reports a 35 kGE coherent unit, about 1.5% of cluster area. This is dual-core synthesis evidence, not proof of a four-core tapeout or a universal power result. [Conference abstract](https://cfp.riscv-europe.org/eu-summit-2026/talk/R7MK7D/)
- **Culsans, 2024:** reports results for a dual-core snoop-based coherence unit and comparison against an OpenPiton configuration. Cache and system differences mean the result does not isolate coherence protocol alone. [Paper](https://arxiv.org/abs/2407.19895)
- **XiangShan Nanhu:** official project material describes a 2 GHz at 14 nm target and a tapeout. This target/result is process- and implementation-specific, not a frequency guarantee for another PDK. [Integration overview](https://docs.xiangshan.cc/zh-cn/dev/integration/overview/), [project history](https://docs.xiangshan.cc/zh-cn/dev/)
- **BlackParrot:** project documentation reports quad-core 12 nm silicon and multiple other tapeouts. This is valuable implementation evidence, not a PPA comparison against the other cores. [Repository](https://github.com/black-parrot/black-parrot)
- **Controlled core comparison, 2025:** reports same-methodology 22 nm comparisons, including improvements for CVA6S+ and a larger performance/area tradeoff for modified C910. It is core-level evidence and must not be interpreted as multicore scaling data. [Study](https://arxiv.org/abs/2505.24363)

No common-basis dual/quad-core power ranking was found. Area percentages, clock targets and benchmark speedups from unrelated studies must not be combined into a single ranking.

**Bằng chứng đã công bố:**

- **Nghiên cứu CVA6S+/cache năm 2025:** báo cáo cải thiện hiệu năng 43,5% so với CVA6 scalar, 10,9% so với CVA6S, overhead diện tích 9,30% so với CVA6 scalar và bandwidth cao hơn 74,1% so với cache subsystem cũ trong nghiên cứu đó. Kết quả phụ thuộc cấu hình. [Bài nghiên cứu](https://arxiv.org/abs/2505.03762)
- **Cluster coherent CVA6S+ dual-core năm 2026:** báo cáo geometric-mean speedup SPLASH-3 1,75× so với single-core và 1,21× so với cluster CVA6 scalar/cache trước đó; synthesis GF12 ghi nhận coherent unit 35 kGE, khoảng 1,5% diện tích cluster. Đây là bằng chứng synthesis dual-core, không chứng minh tapeout 4-core hay kết quả power phổ quát. [Tóm tắt hội nghị](https://cfp.riscv-europe.org/eu-summit-2026/talk/R7MK7D/)
- **Culsans, 2024:** công bố kết quả của khối coherence snoop dual-core so với một cấu hình OpenPiton. Khác biệt cache và hệ thống khiến không thể quy toàn bộ chênh lệch cho protocol coherence. [Bài nghiên cứu](https://arxiv.org/abs/2407.19895)
- **XiangShan Nanhu:** tài liệu chính thức mô tả mục tiêu 2 GHz ở 14 nm và việc tapeout. Đây là kết quả/mục tiêu phụ thuộc PDK, không đảm bảo tần số trên công nghệ khác. [Tổng quan tích hợp](https://docs.xiangshan.cc/zh-cn/dev/integration/overview/), [lịch sử dự án](https://docs.xiangshan.cc/zh-cn/dev/)
- **BlackParrot:** tài liệu dự án báo cáo silicon quad-core 12 nm và các tapeout khác. Đây là bằng chứng triển khai, không phải so sánh PPA với các core khác. [Repository](https://github.com/black-parrot/black-parrot)
- **So sánh core có cùng phương pháp năm 2025:** báo cáo so sánh 22 nm, gồm cải thiện CVA6S+ và tradeoff hiệu năng/diện tích lớn hơn của C910 đã sửa đổi. Đây là kết quả cấp core, không phải dữ liệu scaling đa lõi. [Nghiên cứu](https://arxiv.org/abs/2505.24363)

Chưa tìm thấy bảng xếp hạng power dual/quad-core trên cùng điều kiện. Không gộp phần trăm diện tích, tần số mục tiêu và benchmark speedup từ các nghiên cứu khác nhau thành một thứ hạng chung.

## 4. Dual-core and quad-core architecture choices / Lựa chọn kiến trúc dual-core và quad-core

### Dual-core coherent SMP

A reasonable general-purpose baseline is two CPU tiles, each with private L1I and coherent L1D, connected to a short coherence unit and a memory system. A shared L2 is optional: it may reduce DRAM traffic and duplicated data, but adds latency, leakage and area. Measure designs both with and without it.

DMA must participate in the coherence domain or follow an explicit clean/invalidate and ownership protocol. A normal AXI crossbar does not make private caches coherent. CPU-to-CPU coherence also does not by itself establish I/O coherence or RISC-V memory consistency compliance.

**Dual-core coherent SMP:** baseline hợp lý gồm hai CPU tile, mỗi tile có L1I riêng và L1D coherent, kết nối tới khối coherence ngắn và memory system. L2 dùng chung là tùy chọn: có thể giảm traffic DRAM và dữ liệu trùng nhưng làm tăng latency, leakage và diện tích. Cần đo cả cấu hình có và không có L2.

DMA phải tham gia domain coherence hoặc tuân thủ quy trình clean/invalidate và ownership được định nghĩa rõ. AXI crossbar thông thường không làm cache riêng trở thành coherent. Coherence CPU-CPU cũng không tự chứng minh I/O coherence hay tuân thủ consistency của RISC-V.

### Quad-core topology alternatives

| Topology / Cấu trúc | Benefit to evaluate / Lợi ích cần đo | Main cost / Chi phí chính |
|---|---|---|
| **One coherent four-core cluster / Một cluster coherent bốn core** | Shared memory and direct cache-line exchange; simpler SMP view. / Bộ nhớ chung, trao đổi cache line trực tiếp; mô hình SMP đơn giản hơn. | More snoop/coherence traffic, contention and shared-resource pressure. / Tăng traffic coherence, tranh chấp và tải lên tài nguyên chung. |
| **Two dual-core clusters / Hai cluster dual-core** | Local coherence domains; possible paired clock/power control. / Domain coherence cục bộ; có thể điều khiển clock/power theo cặp. | Requires a coherent link between clusters for a single SMP system; AXI alone is insufficient. / Nếu muốn SMP chung phải có coherence giữa hai cluster; AXI đơn thuần không đủ. |
| **Four cores with scratchpad and DMA / Bốn core với scratchpad và DMA** | Predictable data access for regular DSP/streaming workloads; software-controlled data movement. / Truy cập dữ liệu dự đoán được cho DSP/streaming; phần mềm điều khiển di chuyển dữ liệu. | Software ownership, bank conflicts, DMA arbitration; not a drop-in Linux coherent system. / Phần mềm quản lý ownership, bank conflict, arbitration DMA; không thay trực tiếp hệ thống Linux coherent. |

Moving from two to four cores increases potential pairwise interactions from 1 to 6 and can add up to three other CPU endpoints to a broadcast probe, depending on protocol and snoop filtering. These are topology counts, not predictions of runtime traffic. Memory bandwidth, miss queues, cache-line sharing and synchronization may limit scaling before core execution does.

**Các phương án quad-core:** một cluster coherent duy nhất đơn giản hóa mô hình chia sẻ nhưng tăng tranh chấp; hai cluster dual-core cần coherence liên cluster nếu muốn cùng chạy SMP; scratchpad phù hợp kernel đều nhưng yêu cầu phần mềm quản lý dữ liệu. Từ 2 lên 4 core, số cặp tương tác tiềm năng tăng từ 1 lên 6; probe broadcast có thể tới ba CPU khác tùy protocol và snoop filter. Đây là số đếm topology, không phải dự đoán traffic chạy thực tế. Bandwidth, miss queue, chia sẻ cache line và đồng bộ có thể giới hạn scaling trước khi giới hạn thực thi core.

## 5. Performance and low-power implications / Ảnh hưởng tới hiệu năng và low-power

### Performance

- Increase useful instruction throughput and memory-level parallelism together. A wider core is ineffective if its cache, MSHRs, refill queues or fabric serialize requests.
- Banked SRAM and multiple outstanding memory transactions can raise throughput, but address mapping and conflict rates matter.
- Reduce false sharing and lock contention. Cache-to-cache transfer can avoid DRAM trips when the coherence implementation supports it.
- Prefetching can help regular workloads but increase switching and bandwidth use when inaccurate.
- A shared L2/LLC is a design choice, not a universal requirement.

### Hiệu năng

- Tăng throughput lệnh hữu ích cùng với memory-level parallelism. Core rộng hơn không giúp nếu cache, MSHR, refill queue hoặc fabric tuần tự hóa request.
- SRAM nhiều bank và nhiều transaction outstanding có thể tăng throughput, nhưng phụ thuộc address mapping và xung đột bank.
- Giảm false sharing và tranh chấp khóa. Truyền cache-to-cache có thể tránh truy cập DRAM nếu coherence hỗ trợ.
- Prefetch có thể có lợi với workload đều nhưng tăng switching và bandwidth khi dự đoán sai.
- L2/LLC dùng chung là một lựa chọn thiết kế, không phải yêu cầu bắt buộc cho mọi cluster.

### Low power

- Prioritize clock gating, operand isolation and SRAM enables for inactive blocks.
- Use interrupt/event-driven wake where supported; include the cost of task migration, cache refill and wake-up.
- Core parking is not the same as power gating. Deep power gating requires quiesce, outstanding-transaction drain, dirty-cache handling, isolation/retention, reset/wake sequencing and power-aware verification.
- A sleeping pipeline may still own dirty data. Keep the snoop/cache controller responsive, support wake-on-probe, or clean/evict before entering a deeper sleep state.
- Begin with a common clock/voltage domain and per-core clock control; add multiple DVFS domains only if measured benefit justifies CDC and verification cost.

### Low-power

- Ưu tiên clock gating, operand isolation và SRAM enable cho khối không hoạt động.
- Dùng interrupt/event để đánh thức core khi được hỗ trợ; tính chi phí migrate task, cache refill và wake-up.
- Core parking khác power gating. Power gating sâu cần quiesce, drain transaction, xử lý dirty cache, isolation/retention, trình tự reset/wake và kiểm chứng power-aware.
- Pipeline đã ngủ vẫn có thể sở hữu dữ liệu dirty. Cần giữ snoop/cache controller phản hồi, hỗ trợ wake-on-probe hoặc clean/evict trước khi ngủ sâu.
- Bắt đầu với miền clock/voltage chung và điều khiển clock từng core; chỉ thêm nhiều miền DVFS nếu lợi ích đo được bù được chi phí CDC và verification.

## 6. Quantitative models / Mô hình định lượng

For a workload with parallel fraction p and N cores, ideal speedup is:

**S(N) = 1 / ((1 − p) + p/N)**

Efficiency is S(N)/N. Energy is the integral of system power over time; for nearly constant average power, **E ≈ Pavg × T**.

With p = 90%, ideal speedup is 1.82× for two cores and 3.08× for four. The ideal gain going from two to four is about 1.69×, before memory contention, synchronization and operating-system overhead.

Hypothetical example:

- Two cores: 160 mW for 6 ms = 0.96 mJ.
- Four cores: 270 mW for 3.8 ms = 1.026 mJ.
- Runtime improves, while energy rises by about 6.9%.

If four cores each need 2 GB/s payload from DRAM and transfer efficiency is 70%, raw bandwidth needs about 11.43 GB/s. A 128-bit data path at 500 MHz has an 8 GB/s ideal peak before protocol overhead, so it cannot meet that assumed demand.

These are calculations, not measurements of the candidate cores.

Với tỷ lệ song song p và N core, speedup lý tưởng là:

**S(N) = 1 / ((1 − p) + p/N)**

Efficiency bằng S(N)/N. Năng lượng bằng tích phân công suất hệ thống theo thời gian; nếu công suất trung bình gần cố định thì **E ≈ Pavg × T**.

Với p = 90%, speedup lý tưởng là 1,82× cho hai core và 3,08× cho bốn core. Mức tăng lý tưởng khi từ hai lên bốn core khoảng 1,69×, chưa tính tranh chấp bộ nhớ, đồng bộ và overhead hệ điều hành.

Ví dụ giả định:

- Hai core: 160 mW trong 6 ms = 0,96 mJ.
- Bốn core: 270 mW trong 3,8 ms = 1,026 mJ.
- Thời gian chạy giảm nhưng năng lượng tăng khoảng 6,9%.

Nếu mỗi core cần payload 2 GB/s từ DRAM, tổng raw bandwidth cần khoảng 11,43 GB/s khi hiệu suất truyền 70%. Đường dữ liệu 128 bit ở 500 MHz có peak lý tưởng 8 GB/s trước overhead protocol nên không đủ cho giả định này.

Đây là phép tính minh họa, không phải phép đo các core ứng viên.

## 7. License meanings and tapeout / Ý nghĩa license và tapeout

| License / License | Plain-language meaning / Ý nghĩa dễ hiểu | Modify and tapeout / Sửa đổi và tapeout |
|---|---|---|
| **Apache-2.0** | Permissive copyright license with a limited contributor patent grant. If distributing the work/derivative, include the license, retain applicable notices, mark modified files and reproduce NOTICE attributions when present. / License copyright permissive, có patent grant giới hạn từ contributor. Khi phân phối cần kèm license, giữ notice phù hợp, ghi file đã sửa và giữ attribution từ NOTICE nếu có. | **Yes, in principle.** Patent grant includes make/have made/use/sell for covered claims. It does not grant unrelated patent or trademark rights. / **Có, về nguyên tắc.** Patent grant gồm quyền chế tạo/đặt chế tạo/sử dụng/bán trong phạm vi claim được cấp; không cấp quyền patent hoặc trademark không liên quan. |
| **BSD-3-Clause** | Permits use and modification; retain copyright/license/disclaimer in source and reproduce notices for binary distribution; no endorsement using contributor names. No express patent grant. / Cho phép dùng và sửa; giữ copyright/license/disclaimer trong source và thông báo khi phân phối binary; không dùng tên contributor để quảng bá. Không có patent grant tường minh. | **Yes for copyright permissions, in principle.** Review patent exposure separately because this license has no express patent clause. / **Có theo quyền copyright, về nguyên tắc.** Cần xem xét patent riêng vì license không có điều khoản patent tường minh. |
| **Mulan PSL v2** | Permits use, modification and distribution with copyright and limited patent grants. Patent grant is bounded; it does not cover every later modification/combination. The license has Chinese and English texts; its terms specify Chinese prevails if they diverge. / Cho phép dùng, sửa và phân phối, có copyright và patent grant giới hạn. Patent grant không bao phủ mọi sửa đổi/tổ hợp về sau. License có bản Trung và Anh; nếu khác nhau thì bản Trung có hiệu lực ưu tiên. | **Yes, in principle**, subject to its conditions and the patent-scope limitation. / **Có, về nguyên tắc**, theo điều kiện license và giới hạn phạm vi patent grant. |
| **Solderpad Hardware License 2.1** | Hardware-oriented license wrapping Apache-2.0. It explicitly defines manufacture and instantiation and allows the licensee to elect Apache-2.0 instead. / License cho hardware, dựa trên Apache-2.0; định nghĩa rõ quyền manufacture và instantiate, cho phép licensee chọn áp dụng Apache-2.0. | **Yes, in principle.** Follow SHL-2.1 or the permitted Apache-2.0 option and preserve required notices. / **Có, về nguyên tắc.** Tuân thủ SHL-2.1 hoặc lựa chọn Apache-2.0 được cho phép, đồng thời giữ notice cần thiết. |
| **Solderpad Hardware License 0.51** | Older hardware license. It covers instantiation and semiconductor topographies, grants a limited patent license to make/have made/use/sell, and permits the licensee to treat the work as Apache-2.0. / Phiên bản license hardware cũ. Có đề cập instantiate và semiconductor topography, patent grant giới hạn make/have made/use/sell, cho phép licensee chọn coi tác phẩm theo Apache-2.0. | **Yes, in principle.** Check the exact file notice and preserve the license/change/attribution conditions on distribution. / **Có, về nguyên tắc.** Kiểm tra notice của file cụ thể, giữ license/change/attribution khi phân phối. |

The table is a reading of the published licenses, not a file-level legal clearance. For any selected implementation, freeze the commit, enumerate RTL and submodules, preserve required notices and check license and patent scope for all included dependencies. The candidate core license does not automatically cover its firmware, testbench, generator dependencies, SRAM macros or third-party IP.

Bảng trên diễn giải license đã công bố, không thay thế việc kiểm tra license từng file. Với implementation được chọn, cần pin commit, liệt kê RTL/submodule, giữ notice và kiểm tra license/patent của dependency. License của core không tự bao phủ firmware, testbench, generator dependency, SRAM macro hay IP bên thứ ba.

## 8. Recommendation before writing the specification / Khuyến nghị trước khi viết spec

### Primary candidate / Ứng viên chính

Evaluate **CVA6 + HPDcache + Culsans/ACE** first for one configurable two-/four-core coherent architecture. Use the released CVA6 configuration as the reproducible baseline. Add CVA6S+ as a performance variant only when its precise RTL revision, cache connection, coherence compatibility, debug/PMU behavior and multi-core configuration are pinned and verified.

Khảo sát **CVA6 + HPDcache + Culsans/ACE** trước cho kiến trúc coherent cấu hình hai/bốn core. Dùng cấu hình CVA6 đã phát hành làm baseline có thể tái tạo. Chỉ thêm CVA6S+ làm biến thể hiệu năng sau khi đã pin và xác nhận revision RTL, kết nối cache, tương thích coherence, debug/PMU và cấu hình đa lõi.

### Comparators / Đối chứng

- **BlackParrot:** multicore and silicon-history comparison; test BedRock-to-AXI cost and single-thread performance.
- **XiangShan Nanhu:** high-performance dual-core reference; assess the cost of extending the intended system to four cores.
- **OpenC910:** peak OoO core-performance comparison; measure interface and coherence integration cost.
- **BOOM:** configurable OoO generator comparison; pin Chipyard and generated RTL revisions.
- **Rocket Chip:** lower-complexity in-order quad-core control point.

- **BlackParrot:** đối chứng về đa lõi và lịch sử silicon; đo chi phí BedRock-to-AXI và hiệu năng đơn luồng.
- **XiangShan Nanhu:** tham chiếu dual-core hiệu năng cao; đánh giá chi phí mở rộng hệ thống lên bốn core.
- **OpenC910:** đối chứng hiệu năng core OoO; đo chi phí tích hợp interface/coherence.
- **BOOM:** đối chứng generator OoO cấu hình được; pin Chipyard và revision RTL sinh ra.
- **Rocket Chip:** điểm đối chứng quad-core in-order ít phức tạp hơn.

### Specification inputs to resolve / Các đầu vào cần khóa trong spec

1. Required ISA and privilege extensions; Linux/SMP, RTOS or bare-metal workload.
2. Single-thread latency versus aggregate throughput and energy-per-task priority.
3. Whether 2 and 4 cores must be supported by one static configuration parameter and identical tile interface.
4. Coherence protocol and domain, atomic support, memory ordering and DMA visibility.
5. Cache sizes/ways/line size, MSHR capacity, shared LLC choice and SRAM macros.
6. AXI data/address/ID widths, outstanding transactions, bandwidth and memory-controller limits.
7. Per-hart debug, interrupt routing, PMU counters/event muxes and cluster snapshot behavior.
8. Clock/reset/voltage domains, clock gating, sleep/wake, quiesce and optional power gating.
9. Target process/library/corner, area/power limits and timing constraints.
10. Exact repository commits, generator/tool versions, submodule manifests and license inventory.

1. ISA/privilege extension cần dùng; workload Linux/SMP, RTOS hay bare-metal.
2. Ưu tiên latency đơn luồng hay throughput tổng và năng lượng/tác vụ.
3. 2 và 4 core có phải cùng được hỗ trợ bằng parameter cấu hình tĩnh và giao diện tile thống nhất.
4. Protocol/domain coherence, atomic, memory ordering và DMA visibility.
5. Kích thước/way/line cache, MSHR, lựa chọn LLC và SRAM macro.
6. AXI data/address/ID width, transaction outstanding, bandwidth và giới hạn memory controller.
7. Debug từng hart, định tuyến interrupt, PMU/event mux và snapshot cluster.
8. Clock/reset/voltage domain, clock gating, sleep/wake, quiesce và power gating tùy chọn.
9. Process/library/corner, giới hạn area/power và timing constraint.
10. Commit repository, phiên bản generator/tool, manifest submodule và license inventory.

## 9. Evidence boundary / Ranh giới bằng chứng

This report is source-based. No local build, elaboration, test, simulation, synthesis, STA or PPA run was performed. A published tapeout or synthesis result is evidence for that project's stated configuration and process; it is not proof that another configuration will build, meet timing, satisfy power, or be legally cleared.

The earlier [dual-core analysis](RISC_V_Dual_Core_High_Performance_Low_Power_Analysis.md) and [quad-core analysis](RISC_V_Quad_Core_High_Performance_Low_Power_Analysis.md) contain additional architecture and low-power detail. This consolidated report brings their selection-relevant findings into one decision document; the other files are retained as supporting analyses.

Báo cáo dựa trên source/document công khai. Không chạy build, elaboration, test, simulation, synthesis, STA hay PPA trong dự án này. Tapeout hoặc kết quả synthesis đã công bố chỉ là bằng chứng cho cấu hình và công nghệ được nêu; không chứng minh cấu hình khác sẽ build được, đạt timing/power hoặc đã được rà soát license đầy đủ.

Các báo cáo dual-core và quad-core trước đó trong thư mục còn có phân tích kiến trúc và low-power bổ sung. Báo cáo tổng hợp này đưa các kết luận cần cho việc chọn core vào một tài liệu quyết định; các file kia được giữ làm tài liệu phân tích bổ trợ.

## Primary sources / Nguồn chính

### Core repositories and architecture documents / Repository và tài liệu kiến trúc

- [OpenHW CVA6](https://github.com/openhwfoundation/cva6) — [architecture and integration docs](https://docs.openhwgroup.org/projects/cva6-user-manual/).
- [CVA6 High-Performance Dcache](https://github.com/openhwfoundation/cv-hpdcache).
- [Culsans ACE coherence unit](https://github.com/pulp-platform/culsans).
- [BlackParrot repository](https://github.com/black-parrot/black-parrot) — [microarchitecture guide](https://github.com/black-parrot/black-parrot/blob/master/docs/microarchitecture_guide.md), [interface specification](https://github.com/black-parrot/black-parrot/blob/master/docs/interface_specification.md).
- [XiangShan repository](https://github.com/OpenXiangShan/XiangShan) — [Nanhu integration overview](https://docs.xiangshan.cc/zh-cn/dev/integration/overview/).
- [OpenC910 repository](https://github.com/XUANTIE-RV/openc910).
- [BOOM repository](https://github.com/riscv-boom/riscv-boom) — [BOOM documentation](https://docs.boom-core.org/en/latest/index.html).
- [Chipyard](https://github.com/ucb-bar/chipyard) — [Rocket configuration docs](https://chipyard.readthedocs.io/en/stable/generators/rocket-chip/).

### Papers and implementation evidence / Bài nghiên cứu và bằng chứng triển khai

- [Culsans snoop-based coherence study, 2024](https://arxiv.org/abs/2407.19895).
- [CVA6S+ high-throughput core/cache study, 2025](https://arxiv.org/abs/2505.03762).
- [CVA6S+ coherent cluster, RISC-V Summit Europe 2026](https://cfp.riscv-europe.org/eu-summit-2026/talk/R7MK7D/).
- [Open-source RISC-V core performance/energy comparison, 2025](https://arxiv.org/abs/2505.24363).

### License texts / Văn bản license

- [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0.html).
- [BSD-3-Clause](https://opensource.org/license/bsd-3-clause).
- [Mulan PSL v2](https://spdx.org/licenses/MulanPSL-2.0.html).
- [Solderpad Hardware License 2.1](https://solderpad.org/licenses/SHL-2.1/).
- [Solderpad Hardware License 0.51](https://solderpad.org/licenses/SHL-0.51/).

