# Review và phản biện chuyên sâu — VLSIT RISC-V Dual/Quad CPU Cluster

> **Ngày review:** 2026-11-11
> **Đối tượng:** toàn dự án `C:\HQuan\102_MyGithub\VLSIT_RISCV_CPU` (HDS v0.19, Plan V3/V4, RTL `rtl/common/vlsit`, delta `rtl_v019_delta`, workbook CSR, logs, repro)
> **Phương pháp:** đọc toàn bộ spec + tài liệu; **thẩm định trực tiếp bằng tool** — chạy lại 4 repro trên cây chính, chạy Verilator lên top, chạy `vlsit_spec_tool.py check`, so hash MD5 cây chính ↔ baseline ↔ candidate, đọc trọn 6 module RTL trọng điểm.

## 0. Kết luận ngắn

| Câu hỏi | Kết luận | Căn cứ |
|---|---|---|
| Spec v0.19 có "đóng" CC-01/02/03 không? | Có — **trên giấy**. DEC-032/033/035, REQ-MEM-019/021/022, TEST-044/045/048/049 đầy đủ. | HDS §10.2, §19, §20 |
| RTL chính đã có các fix đó chưa? | **Chưa.** Cây chính = baseline đúng byte (MD5 trùng khớp cả 4 module). | Bảng hash Phụ lục A |
| Top cluster chạy được chưa? | **Không.** `m_vlsit_riscv_cluster_axi_top.sv` instantiate module không tồn tại; Verilator `MODMISSING` exit 1. | Repro 2026-11-11 |
| 4 bug đã mô phỏng trong review 2026-11-09 còn không? | **Còn cả 4** — chạy lại repro ngày 2026-11-11, cả 4 tái hiện, gồm RB-01 (Blocker) chưa được vá ở **bất kỳ** cây nào. | Phụ lục A |
| Spec pass tool check chuẩn chưa? | **Không** — `vlsit_spec_tool.py check` FAIL 2 lỗi (WF-020 thiếu ảnh; 285 dòng tiếng Việt). | Phụ lục A |
| Quy trình/license/traceability tốt không? | **Tốt, nổi bật** so với dự án cùng cỡ — nhưng đang có nứt vỡ giữa "trạng thái tài liệu" và "trạng thái cây RTL". | §2, §6 |

**Nhận định tổng:** đây là một dự án có kỷ luật quy trình tốt (spec-first, traceability, license, repro trung thực), nhưng đang ở trạng thái **ba cây RTL lệch nhau ba mốc thời gian**: (1) cây chính chứa bug đã biết từ 2026-11-09, (2) bản vá v0.19 cách ly trong `rtl_v019_delta/` chưa merge, (3) top sinh ngày 2026-11-09 **không chạy được** và **không tài liệu nào thừa nhận sự tồn tại của nó**. Chuỗi lint/log đã bắt đầu phình to artifact trùng lặp. Đây là thời điểm cần một bước "đóng băng và đồng bộ" trước khi viết thêm RTL mới.

## 1. Điểm mạnh (kèm bằng chứng)

1. **Traceability dày đặc và nhất quán.** Mục 19 HDS ánh xạ mọi REQ → module → TEST → phương pháp → cấu hình; 49 TEST ID; DEC-001…035 và DEP-001…025 đều có ngày duyệt và nguồn. TEST-044/045/048 thậm chí được thiết kế đúng hình dạng các bug đã mô phỏng (reproduce CC-01 "exactly", duplicate-grant, drain ACK).
2. **Văn hóa review trung thực hiếm thấy.** Review nội bộ 2026-11-09 không chỉ nêu CC-01…CC-10/PF/SYS/RB mà **viết sẵn 4 testbench tái hiện + run.sh**, dùng nhãn bằng chứng và mức độ. Đã chạy lại cả 4 ngày 2026-11-11 — tất cả vẫn tái hiện đúng mô tả (Phụ lục A). Repro README còn chỉ định cách biến thành regression sau khi fix — đúng thực hành.
3. **Kỷ luật cách ly bản vá v0.19.** `rtl_v019_delta/` không đụng cây gốc: snapshot baseline/candidate riêng, change-metric 234 added / 23 deleted (0,11%), CSR regenerate bằng generator (không hand-edit), FSM V5 là bản copy giữ V4 nguyên vẹn, workbook gốc không đổi. Đây là cách làm đúng khi spec mới ra chưa được duyệt merge.
4. **Quản lý third-party và license nghiêm ngặt.** 7 repo pin commit đầy đủ (`doc/third_party/README.md`), `lint/common/modified/UPSTREAM_SOURCE_BASELINE_SHA256.csv` (2.049 dòng) cho phép audit mọi sửa đổi; các bản sao CVA6 modified giữ header và có history entry; README modified thẳng thắn khai giới hạn (CVFPU submodule thiếu → không lint trọn CVA6).
5. **Tự giác khai báo phần chưa làm.** Mọi tài liệu đều ghi rõ "no simulation/synthesis/STA/PPA", "diagnostic chưa nối CSR vì thiếu top", "WF pending". Không thấy claim vượt bằng chứng ở phần mô phỏng/PPA.
6. **Lint per-module có filelist riêng** (`filelist_*.f`) và log thực sự tồn tại, chạy bằng Verilator 5.053 thật (có walltime/allocated bytes) — không phải log giả. Arbiter elaborate được cả 3 cấu hình slot 5/8/16 (3 log riêng).

## 2. Phát hiện P1 — Blocker (cây chính không dùng được làm baseline entregable)

### P1-1 · Top cluster không elaborate — module core không tồn tại

- `rtl/non_coherence_cluster/m_vlsit_riscv_cluster_axi_top.sv` (277 dòng, ngày 2026-11-09) instantiate `m_vlsit_riscv_cluster_core` tại **dòng 163**; không file nào trong toàn cây (đã loại `third_party`) định nghĩa module này.
- Chạy trực tiếp: `verilator_bin.exe --lint-only --top-module m_vlsit_riscv_cluster_axi_top` → `%Error-MODMISSING ...:163 ... Cannot find file containing module: 'm_vlsit_riscv_cluster_core'`, exit 1.
- Hệ quả dây chuyền: HDS §1.1 (**dòng 60** "The current delivery has one structural AXI top") và §14.5 ("Structural tops: Current: m_vlsit_riscv_cluster_axi_top only") là claim **không có bằng chứng chạy được**; REQ-IF-006/TEST-016 ("Elaborate current AXI top at 2/4 harts") **chưa từng pass** và hiện tại không thể pass. Không có lint log nào cho top trong `rtl/common/vlsit` (log chỉ có cho 5 khối leaf + bridge/decode/PMU/router).
- Ghi chú công bằng: top là shell cấu trúc đúng thiết kế Plan V3 §4 (mọi implementation nằm trong core). Nhưng sinh shell khi core chưa tồn tại tạo ra file RTL "chết" — và không tài liệu nào ghi nhận nó.

### P1-2 · Mâu thuẫn tài liệu ba chiều về top

Cùng một thời điểm, ba nguồn nói ba điều:

1. **File tồn tại**: `rtl/non_coherence_cluster/m_vlsit_riscv_cluster_axi_top.sv` + `scripts/gen_cluster_axi_top.py` (sinh từ HDS §6.2).
2. **README (EN+VI) và `doc/rtl_layout/vlsit/README.md`**: "các khối chưa được ghép vào top cluster" — không biết top tồn tại.
3. **`rtl_change_review_v019.md` §1/§9 và `rtl_v019_delta/reports/implementation_report.md` (TOP status)**: "no RTL top module is present in the current source tree" — mâu thuẫn trực tiếp, vì các văn bản này mang mốc trước 2026-11-09 nhưng không có bản cập nhật nào sau khi top xuất hiện.

Điểm mâu thuẫn nội tại trong chính HDS v0.19: front matter ghi "**no RTL changed**" nhưng §1.1/§14.5 claim "current delivery has one structural AXI top". Hoặc (a) spec viết trước khi top tồn tại → §1.1 sai tại thời điểm viết, hoặc (b) spec cập nhật sau khi top sinh → "no RTL changed" sai. Cả hai nhánh đều là một lỗi trạng thái cần sửa.

### P1-3 · Bản vá v0.19 (REQ-MEM-019/021/022) chưa merge — cây chính vẫn deadlock

Bằng chứng MD5 (chính = baseline = chưa vá; candidate/delta = đã vá):

| Module | Cây chính = baseline | Delta v0.19 | Δ dòng |
|---|---|---|---|
| `m_vlsit_riscv_sharer_directory.sv` | `DE06A6A8` | `8F0F3D0B` | 337 → 434 |
| `m_vlsit_riscv_coh_txn_table.sv` | `2B44DDD1` | `493B9872` | 226 → 311 |
| `m_vlsit_riscv_probe_scheduler.sv` | `FB8AC333` | `32B49A3C` | 186 → 195 |
| `m_vlsit_riscv_coh_bank_arb.sv` | `D6EC0DE2` | `E6F26132` | 102 → 118 |

Đã đọc code và **chạy lại repro trên cây chính ngày 2026-11-11**:

- **CC-01 (deadlock directory)**: `p_com_dir_ready` (dòng 216–219) dùng `casez` ưu tiên update; `w_update_set_busy` (dòng 163–165) chặn update của T1 bởi reservation của T2 trên cùng set, trong khi chính nhánh casez đó làm `o_cancel_ready=0` — T2 không thể nhả reservation. Repro: *"after 20 cycles: update_ready=0 cancel_ready=0 → DEADLOCK"*.
- **CC-02 (ACK drain)**: `p_com_coh_ack_match` (txn_table dòng 137–151) chỉ set `o_ack_ready` khi ACK khớp tag/phase/hart — ACK trùng/stale bị kẹt vĩnh viễn ở đầu lane. Repro: *"DUP-ACK ... ready=0 after 10 cycles (0 means it is never consumed)"*; probe_scheduler dòng 133–137 cũng chỉ nhận response khớp `reg_active_*`.
- **CC-03 (duplicate grant)**: bank_arb `p_com_pick` (dòng 61–76) chọn slot theo `i_req_valid` tức thời, không có cơ chế disarm-till-VALID-low. Repro: drop delay 1–2 chu kỳ → *"grants for ONE request = 2"*.
- **PF-05 (hiệu năng probe)**: repro đo *"4 PREPARE probes ... 21 cycles → 5 cycles/probe"*; *"COMMIT to 3 harts ... 4 cycles"*.

Lưu ý: các fix trong delta **chỉ được lint, chưa được mô phỏng** (implementation_report tự khai "No simulation, testbench ... was run under Plan V4"). 4 repro sẵn có chính là regression cho các fix này nhưng chưa được chạy trên candidate.

### P1-4 · RB-01 — Blocker của bridge, chưa được vá ở bất kỳ đâu

- Code: `m_vlsit_axil_reg_bridge.sv` dòng **143–144** định nghĩa `w_wr_local_err` bao gồm `w_wr_addr_wr_denied`, nhưng điều kiện vào `ENUM_ST_WR_REQ` ở dòng **234** chỉ có `aligned & mapped` — **thiếu `~w_wr_addr_wr_denied`**. Hệ quả: write bị cấm vẫn được drive ra RegBus (`o_reg_req_valid=1`, `reg_req_wr=1`, addr = thanh ghi SPM), đồng thời sinh B response SLVERR cục bộ (dòng 309–317); khi LLC trả response, một B response thứ hai xuất hiện (dòng 318–322).
- Repro ngày 2026-11-11: write `CFG_SPM_LOW (0x00)` → *"RegBus WRITE addr=0x0"*, *"B response resp=2"*, *"B response resp=0"* — **2 B response cho 1 write** (vi phạm AXI: một write chỉ được 1 B) và **write đến được thanh ghi SPM của LLC** — phá vỡ hợp đồng HDS §14.4.5 ("software cannot enable runtime SPM") và DEC-024.
- Hash: bridge `main = baseline = candidate = 0A176B04` — **candidate v0.19 cũng không vá lỗi này** (delta không chứa file bridge). Lỗi này đã được review nội bộ xếp Blocker ngày 2026-11-09, fix là 1 dòng, nhưng 2 ngày sau vẫn nguyên vẹn ở cả ba cây.

## 3. Phát hiện P2 — Cần xử lý trước khi coi v0.19 là "đóng"

1. **Spec không pass rule-check chuẩn của chính quy trình VLSIT.** `vlsit_spec_tool.py check` → `FAIL: 2 error(s)`: (a) **R-024**: mục 10.3 WF-020 không có ảnh trong Figure cell — thực tế thư mục waveforms có đủ `.svg` cho WF-001…WF-019 nhưng **WF-020 chỉ có `.json`/`.html`, thiếu `.svg`**; (b) **R-005**: 285 dòng chứa tiếng Việt (spec song ngữ là chủ ý của dự án, nhưng tool coi là lỗi — cần waiver chính thức hoặc tách bản dịch, không nên để FAIL âm thầm). Lưu ý: các văn bản trong repo nói "scan 0 BLOCK 0 INFO" dùng **gap-scan khác** (`spec_gap_scan.log`) — dễ khiến người đọc hiểu lầm là spec đã pass mọi kiểm tra.
2. **CSR `cpucl_coh` (0x0010, DEC-033/DEP-023) chưa vào cây chính.** CSR sinh chính: 589 dòng, không có `cpucl_coh` (kiểm tra trực tiếp: False); bản delta: 618 dòng, có. Workbook gốc cũng chưa có. Ba diagnostic của delta (`i_hw_we_cpucl_coh_fault`…) vì thế chưa có chỗ nối — đúng như delta tự khai (thiếu top).
3. **`m_vlsit_riscv_axi_mmio` lint fail và không được khai báo ở đâu.** `lint/common/legacy_vlsit/m_vlsit_riscv_axi_mmio_lint.log` exit 1 (`Cannot find include file: common_cells/assertions.svh` — thiếu include path khi lint kèm `axi_mux`). README liệt kê các khối lint đạt nhưng không nói khối này fail; người đọc phải tự mò log.
4. **Claim "CSR generator regression 27/27" không có artifact trong cây chính.** Chuỗi tìm kiếm toàn repo chỉ ra dòng văn bản trong `rtl_change_review.md:276`; log duy nhất liên quan là `rtl_v019_delta/reports/csr_generation.log` (bản delta, không phải regression 27/27). Claim đúng/sai chưa kết luận được — nhưng **không tái kiểm chứng được từ repo** là lỗi khả năng audit (auditability).
5. **Traceability mục 19 hiện "đẹp hơn thực tế"**: REQ-MEM-019/021/022 trỏ TEST-044/045/048 như thể đã có đối tượng để test, trong khi hành vi đó chỉ tồn tại trong delta chưa merge. Spec-first là đúng quy trình, nhưng bảng traceability nên có cột "RTL status: baseline/delta/absent" để không gây hiểu nhầm.
6. **`scripts/gen_cluster_axi_top.py` hard-code ngày "2026-11-09"** trong header output (không lấy ngày hệ thống) — mọi lần regenerate sẽ ghi sai ngày; script cũng không kiểm tra module `m_vlsit_riscv_cluster_core` tồn tại trước khi sinh shell.
7. **Artifact lint trùng lặp và sót lỗi cũ**: `rtl/common/vlsit` chứa ~35 log `_final/_latest/_latest_2` chồng nhau; riêng bridge có log `_latest` còn sót lỗi syntax từng tồn tại (`Can't find definition of variable: 'reg_req_write'`, exit 1) — dễ khiến ai đó đọc nhầm log và kết luận bridge đang hỏng. Nên giữ 1 log canonical mỗi khối, đưa phần còn lại vào `reports/` hoặc xoá.

## 4. Phát hiện P3 — Vệ sinh repo

- `doc/specification/figures/waveforms/` lẫn **rác browser profile** (chrome/edge files) — cần xoá khỏi cây giao dịch.
- WF-001, WF-005–WF-012, WF-014 (10/20 waveform) vẫn là "pending status card" (svg 0.8 KB placeholder) — đúng khai báo DEP-010 nhưng cần theo dõi.
- Dự án **không phải git repo** — mọi "diff/md5" như đợt review này phải tự dựng; khuyến nghị init git (hoặc thêm vào repo GitHub của user) ngay, đặc biệt trước khi merge delta.
- `doc/csr/generated/Debug/debug.json` là rác build của generator.

## 5. Đối chiếu claim README ↔ bằng chứng

| Claim trong README | Thẩm định |
|---|---|
| Rule check đạt cho RTL VLSIT hiện có | Đúng cho 5 khối leaf theo log `_final`; **nhưng rule-check spec HDS lại FAIL** (P2-1) — claim áp cho RTL, không áp cho spec |
| Verilator lint đạt PMU, debug router, decode, txn table, directory, scheduler, arbiter | **Đúng** — log `_final` exit 0 cho từng khối; arbiter txn5/8/16 có log riêng pass |
| Arbiter elaborate 5/8/16 slot | Đúng (3 log) |
| 2 cổng PROT cố ý chưa dùng (CSR/bridge) | Đúng — `m_vlsit_axil_reg_bridge_lint_final.log` 2 warning `i_axil_awprot/i_axil_arprot` |
| CSR có 1 cảnh báo HIE-02 | Đúng theo delta `rtl_rule_report`; cây chính không có báo cáo rule riêng cho CSR |
| CSR generator regression 27/27 | **Không có log trong cây chính** (P2-4) |
| Event tap CVA6 lint độc lập với stub | Đúng (`cva6_perfcounter_stub_lint.log`), có WIDTHEXPAND tại `perf_counters.sv:191` cần lưu ý |
| Không lint được CVA6 (thiếu CVFPU) | Đúng, khai báo trung thực |
| "Các khối chưa ghép vào top cluster" | **Sai** — top tồn tại (nhưng không chạy được) (P1-1/P1-2) |
| Mô phỏng cluster/synthesis/STA/PPA chưa hoàn tất | Đúng, trung thực |

## 6. Quan hệ với review nội bộ 2026-11-09 (không lặp lại)

Review nội bộ đã phủ CC-01…CC-10, PF-01…08, SYS/RB/TB/CV/LP/DB cho **v0.18 baseline**. Đợt review này bổ sung những gì **mới phát sinh sau đó**: top shell chết + mâu thuẫn tài liệu (P1-1/2), trạng thái "delta chưa merge" chứng minh bằng hash + repro chạy lại (P1-3), RB-01 vẫn không được vá kể cả trong candidate (P1-4), spec tool FAIL (P2-1), CSR `cpucl_coh` chưa merge (P2-2), audit các claim README/log (P2-3/4/7). Các finding của review nội bộ **vẫn còn giá trị nguyên vẹn** vì cây chính không đổi.

## 7. Hành động ưu tiên

**P0 — trước khi viết bất kỳ RTL mới nào:**

1. Quyết định merge `rtl_v019_delta` vào `rtl/common/vlsit` (theo Plan V4 đã duyệt), rồi **chạy 4 repro trên cây đã vá để biến chúng thành regression** (repro README đã chỉ sẵn cách đổi `$fatal`). Hiện fix chỉ được lint, chưa được mô phỏng.
2. Vá RB-01 trong bridge (thêm `& ~w_wr_addr_wr_denied` vào điều kiện dòng 234 và không dispatch denied write ra RegBus), kèm repro `reg_bridge_denied_write` đổi thành regression.
3. Sinh hoặc stub `m_vlsit_riscv_cluster_core` (ít nhất skeleton đủ elaborate) để TEST-016 chạy được — hoặc tạm thời rút top ra khỏi cây chính và cập nhật HDS §1.1/§14.5 thành "planned top".
4. Đồng bộ tài liệu: README (EN+VI), `doc/rtl_layout/vlsit/README.md`, `rtl_change_review_v019.md` §9, HDS front matter ("no RTL changed") — phản ánh đúng sự tồn tại/trạng thái của top.

**P1:**

5. Xuất `.svg` cho WF-020 (đã có json/html — chỉ thiếu bước render) để đóng R-024; quyết định chính thức về R-005 (waiver song ngữ).
6. Đưa workbook `cpucl_coh` vào bản chính + regenerate CSR chính; nối 3 diagnostic khi có top.
7. Sửa lint `m_vlsit_axi_mmio` (include path `common_cells/assertions.svh`) hoặc khai báo rõ trạng thái fail trong README.
8. Init git repo + dọn ~35 log trùng, rác browser profile, `Debug/debug.json`; sửa `gen_cluster_axi_top.py` lấy ngày hệ thống và kiểm tra module core tồn tại.

**P2:**

9. Thêm cột "RTL status" vào bảng traceability mục 19 (baseline/delta/absent).
10. Lưu log regression CSR 27/27 vào repo để claim tái kiểm chứng được.

## Phụ lục A — Bằng chứng tool (chạy ngày 2026-11-11)

<details>
<summary>Nhấn để mở log đầy đủ</summary>

```
# 1) Verilator lint top (cwd rtl/common/vlsit):
%Error-MODMISSING: m_vlsit_riscv_cluster_axi_top.sv:163:3:
  Cannot find file containing module: 'm_vlsit_riscv_cluster_core'
%Error: Exiting due to 1 error(s)   [exit code 1]

# 2) MD5 (chính / baseline / candidate) — xem bảng P1-3, P1-4:
m_vlsit_riscv_sharer_directory.sv  main=DE06A6A8 baseline=DE06A6A8 candidate=8F0F3D0B delta-rtl=8F0F3D0B
m_vlsit_riscv_coh_txn_table.sv     main=2B44DDD1 baseline=2B44DDD1 candidate=493B9872 delta-rtl=493B9872
m_vlsit_riscv_probe_scheduler.sv   main=FB8AC333 baseline=FB8AC333 candidate=32B49A3C delta-rtl=32B49A3C
m_vlsit_riscv_coh_bank_arb.sv      main=D6EC0DE2 baseline=D6EC0DE2 candidate=E6F26132 delta-rtl=E6F26132
m_vlsit_axil_reg_bridge.sv         main=0A176B04 baseline=0A176B04 candidate=0A176B04 delta-rtl=MISSING
m_vlsit_riscv_axil_decode.sv       main=3A840381 baseline=3A840381 candidate=3A840381 delta-rtl=MISSING
m_vlsit_riscv_debug_router.sv      main=1403F73E baseline=1403F73E candidate=1403F73E delta-rtl=MISSING

# 3) vlsit_spec_tool.py check HDS v0.19:
ERROR: section 10.3: WF-020 has no image in the Figure cell (rule R-024)
ERROR: 285 line(s) contain Vietnamese letters; the specification is written in English (rule R-005); first lines of the text outside code blocks: [15, 19, 23, 27, 66]
FAIL: 2 error(s), 22 section(s)   [exit code 1]

# 4) Repro dir_deadlock (CC-01):
T1 lookup A: hit=1 rsp_valid=1
T2 lookup B: hit=0 (miss reserves set 5)
T1 update A: update_ready=0 (expected 0)
T2 cancel while T1 update held: cancel_ready=0 update_ready=0 lookup_ready=0
after 20 cycles: update_ready=0 cancel_ready=0 -> DEADLOCK

# 5) Repro reg_bridge_denied_write (RB-01):
--- write to CFG_SPM_LOW (0x00): must be rejected (SPM disabled)
  RegBus WRITE addr=0x0 data=0xdead0000
  B response resp=2
  B response resp=0
write 0x0: RegBus writes=1, B responses=2
--- write to VERSION_LOW (0x40, read-only)
  RegBus WRITE addr=0x40 data=0xdead0000
  B response resp=2
  B response resp=0
write 0x40: RegBus writes=1, B responses=2
--- write to CFG_FLUSH_LOW (0x08, allowed)
  RegBus WRITE addr=0x8 data=0xdead0000
  B response resp=0
write 0x8: RegBus writes=1, B responses=1
--- write to unmapped 0x4C
  B response resp=3
write 0x4c: RegBus writes=0, B responses=1
--- write misaligned 0x09
  B response resp=2
write 0x9: RegBus writes=0, B responses=1

# 6) Repro bank_arb_dup_grant (CC-03):
drop delay 0 cycle: grants=1   |   delay 1 cycle: grants=2   |   delay 2 cycles: grants=2

# 7) Repro txn_probe_rate (PF-05/CC-02):
4 PREPARE probes to ONE hart (ideal 1-cycle cache) complete in 21 cycles -> 5 cycles/probe
COMMIT to 3 harts in parallel, ideal cache: 4 cycles
DUP-ACK: duplicate ack ... ready=0 after 10 cycles (never consumed)

# 8) CSR chính: 589 dòng, cpucl_coh = False
#    CSR delta: 618 dòng, cpucl_coh = True
# 9) WF-020: chỉ có .json + .html trong figures/waveforms (WF-001..019 đều có .svg)
# 10) m_vlsit_riscv_axi_mmio_lint.log: exit 1 (thiếu include common_cells/assertions.svh)
```

</details>

---

*Môi trường thẩm định: Verilator 5.053 (`C:\Tools\oss-cad-suite\bin\verilator_bin.exe`), Git Bash + MSYS2 ucrt64 g++, Python 3.12 (`vlsit_spec_tool.py`). Review này chỉ ghi nhận và phản biện — không sửa bất kỳ file nào của dự án.*
