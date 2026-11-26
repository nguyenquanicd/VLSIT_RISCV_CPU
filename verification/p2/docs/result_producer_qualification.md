# Result producer qualification / Qualification bộ tạo kết quả

## Qualified scope / Phạm vi đã qualification

The retained producer is `scripts/project_runner.py`, with `scripts/coverage_source_summary.py` for the source-scoped union. Qualification applies only to the four initial FENCE.I cases in `tests/generated/initial_case_manifest.json`; it does not mean that the full HDS plan or the 100% code-coverage target is closed.

Producer được lưu là `scripts/project_runner.py`, kết hợp `scripts/coverage_source_summary.py` để tính coverage union theo source. Qualification chỉ áp dụng cho bốn case FENCE.I đầu tiên trong `tests/generated/initial_case_manifest.json`; không đồng nghĩa đã đóng toàn bộ HDS hoặc mục tiêu coverage 100%.

## Preflight evidence / Evidence preflight

The direct isolated preflight is retained at `runs/preflight_g0_005/`. It compiled both hart configurations and ran the copied DUT, HDS-derived expected checks, 20 AXI protocol counters, event waveforms, and Verilator line/expression/toggle collection. One early attempt failed to open a waveform because its parent folder was absent; a later attempt used a unique attempt directory and passed. The failure log and artifacts remain preserved.

Preflight cô lập được giữ tại `runs/preflight_g0_005/`. Run đã biên dịch cả hai cấu hình hart và chạy DUT đã sao chép, kiểm tra mong đợi theo HDS, 20 AXI protocol counter, waveform sự kiện và thu coverage line/expression/toggle của Verilator. Một lần thử đầu lỗi do thiếu thư mục cha của waveform; lần thử sau dùng attempt directory riêng và đạt. Log lỗi cùng artifact được giữ lại.

| Case | Outcome | Cycles | AXI assertion hits |
|---|---|---:|---:|
| `H2_FENCEI_SUCCESS` | PASS | 938 | 1,066 across 20 IDs |
| `H2_FENCEI_AXI_ERROR` | PASS | 1,020 | 1,118 across 20 IDs |
| `H4_FENCEI_SUCCESS` | PASS | 1,015 | 1,310 across 20 IDs |
| `H4_FENCEI_AXI_ERROR` | PASS | 1,163 | 1,414 across 20 IDs |

Each case has 20 distinct protocol assertion IDs with nonzero hits, an architectural retirement/trap check, a nonempty VCD, and a nonempty native coverage file. The checked summary is `runs/preflight_g0_005/reports/result.json`; the actual per-case logs, waveforms and raw coverage are retained beside it.

Mỗi case có đủ 20 protocol assertion ID riêng biệt với hit khác 0, kiểm retirement/trap kiến trúc, VCD không rỗng và coverage file bản địa không rỗng. Bảng kết quả là `runs/preflight_g0_005/reports/result.json`; log từng case, waveform và raw coverage được giữ cạnh đó.

## Coverage observed / Coverage đo được

Verilator summary across the four preflight cases: line 49.1% (3,042/6,192), expression 48.5% (13,834/28,524), toggle 16.2% (142,835/881,314). The required 119-source union is lower/higher by metric as reported here: line 57.3754% (3,349/5,837), expression 46.2251% (4,739/10,252), toggle 15.7803% (55,647/352,636). 109 of 119 target files were instrumented; 10 have no recorded points. The detailed per-source report is `runs/preflight_g0_005/coverage/attempt_001/source_union.md`.

Summary Verilator trên bốn case preflight: line 49.1% (3.042/6.192), expression 48.5% (13.834/28.524), toggle 16.2% (142.835/881.314). Union của 119 source mục tiêu: line 57.3754% (3.349/5.837), expression 46.2251% (4.739/10.252), toggle 15.7803% (55.647/352.636). Có instrument 109/119 file mục tiêu; 10 file chưa có point. Báo cáo theo từng source ở `runs/preflight_g0_005/coverage/attempt_001/source_union.md`.

These are preliminary measurements and are far below the approved 100% thresholds. Expression is not condition coverage. The full qualification campaign must add requirement-directed, width/parameter, random, reset, error, protocol and architecture tests, then report the union by configuration without averaging.

Đây là số đo sơ bộ, thấp hơn nhiều so với ngưỡng 100% đã duyệt. Expression không phải condition coverage. Campaign đầy đủ cần bổ sung test theo yêu cầu, width/parameter, random, reset, lỗi, protocol và kiến trúc; sau đó báo union theo cấu hình, không lấy trung bình.

## Diagnostics and limits / Diagnostic và giới hạn

Verilator emitted 83 visible UNOPTFLAT warnings at 2 harts and 82 at 4 harts; there were zero Verilator errors. `--Wno-fatal` allowed functional model generation but did not disable or waive any warning. This is not a clean lint result. Questa 10.4c was unavailable, and no formal, mutation, width-matrix or full-HDS campaign has run yet.

Verilator phát 83 warning UNOPTFLAT được giữ nguyên ở 2 hart và 82 ở 4 hart; không có lỗi Verilator. `--Wno-fatal` cho phép tạo model để chạy chức năng nhưng không tắt hoặc waive warning. Đây không phải kết quả lint sạch. Questa 10.4c không khả dụng; chưa chạy formal, mutation, ma trận width hoặc campaign HDS đầy đủ.

## Sealed execution and cold replay / Execution đã seal và cold replay

Baseline `c63915dda7ebe05d498225a19df115bf3576c556ccf9e0411279864075cc57ce` completed the helper `execute` run `qualification_v1_initial_002` and cold replay `qualification_v1_replay_001`. The helper reported `EXECUTION_COMPLETED: CHECKED` and `REPLAY_EXECUTED: MATCH`. Both runs passed all four declared cases and their normalized results, waveforms, per-case coverage hashes, and tool versions matched.

Baseline `c63915dda7ebe05d498225a19df115bf3576c556ccf9e0411279864075cc57ce` hoàn tất helper `execute` run `qualification_v1_initial_002` và cold replay `qualification_v1_replay_001`. Helper trả `EXECUTION_COMPLETED: CHECKED` và `REPLAY_EXECUTED: MATCH`. Cả hai run pass bốn case đã khai báo; normalized result, waveform, hash coverage từng case và tool version khớp nhau.

This is a reproducible G0 FENCE.I smoke qualification only. It does not close the 97-row HDS plan, 100% line/expression/toggle goals, 8-way width matrix, PMU/CSR/LLC service/MMIO/IRQ/debug tests, constrained-random, formal or mutation obligations. Verilator reported 83 `UNOPTFLAT` warnings at two harts and 82 at four harts; zero Verilator errors. The warning set remains open, and this is not clean lint. Source-union coverage is line 57.3754%, expression 46.2251%, toggle 15.7803% across the 119-source target, with 10 files uninstrumented.

Đây chỉ là qualification smoke FENCE.I G0 có thể tái lập. Kết quả chưa đóng plan HDS 97 dòng, mục tiêu 100% line/expression/toggle, ma trận width 8 cấu hình, test PMU/CSR/LLC service/MMIO/IRQ/debug, constrained-random, formal hay mutation. Verilator có 83 warning `UNOPTFLAT` ở hai hart và 82 ở bốn hart; không có Verilator error. Warning còn mở và đây không phải lint sạch. Coverage union theo source là line 57.3754%, expression 46.2251%, toggle 15.7803% trên 119 source mục tiêu; 10 file chưa được instrument.
