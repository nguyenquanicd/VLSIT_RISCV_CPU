# Isolated cluster verification package / Gói kiểm chứng cluster độc lập

The DUT is a hashed copy under `dut/source`; builds use only that copy. HDS and referenced protocol clauses define expected behavior. RTL hierarchy/state probes are implementation checks, not the golden model.

DUT là bản sao có hash trong `dut/source`; build chỉ dùng bản sao đó. HDS và các điều khoản protocol được viện dẫn định nghĩa hành vi mong đợi. Quan sát hierarchy/state RTL chỉ kiểm tra triển khai, không làm golden model.

## Prerequisites / Điều kiện cần

| Tool | Observed version | Purpose |
|---|---|---|
| Python | 3.12.10 | package helper, generators, runner |
| Verilator | 5.053 devel `v5.052-119-g014c9820d` | timed model, assertions, line/expression/toggle coverage |
| MSYS2 UCRT64 g++ | 16.2.0 | generated model and runtime compilation |

Exact executable paths and version transcripts are in `env/toolchain.json` and `docs/tool_versions/`. Coverage aggregation uses native `verilator_coverage_bin_dbg.exe`; the Perl launcher fails on this host with MSYS2 `NtCreateDirectoryObject` access denied. Questa 10.4c fails to start (`Illegal System DLL Relocation`), so Verilator expression coverage is used and is not called condition coverage. GNU Make is not usable in this Windows shell; the single `Makefile` remains the command index, with Python equivalents below.

Exact path executable dan log phiên bản nằm trong `env/toolchain.json` và `docs/tool_versions/`. Gộp coverage bằng `verilator_coverage_bin_dbg.exe`; Perl launcher lỗi do MSYS2 bị chặn `NtCreateDirectoryObject`. Questa 10.4c không khởi động (`Illegal System DLL Relocation`), nên dùng expression coverage của Verilator và không gọi đó là condition coverage. GNU Make chưa chạy được trong shell Windows; `Makefile` là mục lục lệnh duy nhất, kèm lệnh Python tương đương bên dưới.

## Structure / Cấu trúc

```text
sim/
  docs/       plan approval, HDS, tool logs, source/license provenance
  env/        replay/tool manifests, ordered filelist and hashes
  dut/source/ isolated copy of 464 active HDL files and include contents
  tests/      retained test sources and generated case matrix
  scripts/    cluster runner, component runner, package helper, generators and coverage checker
  runs/       unique retained build/simulation/log/receipt directories
  coverage/   campaign coverage outputs
  snapshots/  immutable replay inputs identified by SHA-256
  Makefile    sole command index
```

`env/source_order.json` retains source order and 12 production include directories, plus one package-only sentinel directory for inactive conditional includes. `UVM` and `PITON_ARIANE` are not defined by this Verilator run; their guarded includes are documented in `env/inactive_include_sentinels/README.md`. `docs/source_origin.json` maps copied HDL back to the G0 inventory and hashes; copied RTL license/copyright headers are unchanged. License provenance is indexed in `docs/source_docs/third_party/README.md`.

`env/source_order.json` giữ thứ tự source, 12 include directory production và một thư mục sentinel riêng cho include có điều kiện không bật. Verilator run này không định nghĩa `UVM` hay `PITON_ARIANE`; các include được giải thích tại `env/inactive_include_sentinels/README.md`. `docs/source_origin.json` ánh xạ HDL về inventory G0 và hash; header license/copyright của RTL không thay đổi. Thông tin license lưu tại `docs/source_docs/third_party/README.md`.

The component runner builds retained directed benches using only the sealed snapshot. It covers the address-region table, CMO controller and arbiter, CCU/fabric, directory/tile array, HPDcache probe engine, and tile line-lock adapter. These block-level checks supplement the planned HDS cluster tests; they do not replace independent architectural or protocol scoreboards.

Component runner build test directed chỉ từ snapshot đã seal. Bộ test bao gồm bảng vùng địa chỉ, CMO controller/arbiter, CCU/fabric, directory/tile array, HPDcache probe engine và tile line-lock adapter. Đây là kiểm tra bổ sung cấp block; không thay thế các test cluster theo HDS hoặc architectural/protocol scoreboard độc lập.

The sealed cluster CBO run `cluster_cmo_qualification_v1_002` executes real CVA6 CBO instructions at the production cluster TOP for two and four harts, with successful and injected AXI writeback-error paths. All four cases passed: H2 success/error in 724/603 cycles and H4 success/error in 944/701 cycles. It checks retirement/trap and memory visibility; it is a directed CPU test, not a complete independent HDS scoreboard.

Run cluster CBO đã seal `cluster_cmo_qualification_v1_002` chạy lệnh CBO thật của CVA6 tại cluster TOP với 2/4 hart, gồm luồng thành công và lỗi AXI writeback. Cả bốn case pass: H2 success/error lần lượt 724/603 chu kỳ; H4 success/error 944/701 chu kỳ. Run kiểm tra retire/trap và khả năng quan sát memory; đây là test CPU directed, chưa phải HDS scoreboard độc lập đầy đủ.

## Environment variables / Biến môi trường

The replay helper creates an isolated environment from `env/replay_manifest.json`. It does not inherit arbitrary shell variables and uses no secrets.

Replay helper tạo environment riêng theo `env/replay_manifest.json`, không kế thừa biến shell tùy ý và không dùng secret.

| Variable | Purpose | Source |
|---|---|---|
| `PATH` | curated Python, Verilator and UCRT64 runtime lookup | `env/toolchain.json` |
| `VERILATOR_ROOT` | exact Verilator runtime root | `env/toolchain.json` |
| `VLSIT_BUILD_JOBS` | bounded compiler parallelism, 1 worker per reviewed resource budget | `env/toolchain.json` |
| `VLSIT_MIN_FREE_RAM_BYTES` | hard stop if available RAM falls below 1 GiB | approved `env/resource_budget.json` |
| `VLSIT_MAX_RAM_DROP_BYTES` | early stop if run-start available RAM drops by more than 1040 MiB | just below half the earlier 2.04 GiB drop |
| `VLSIT_RAM_POLL_INTERVAL_MS` | RAM/disk guard sample interval: 100 ms | approved guard configuration |
| `VLSIT_RAM_GUARD_MARGIN_BYTES` | require 128 MiB of headroom above the 1 GiB hard reserve | safe-start margin |
| `VLSIT_MIN_FREE_DISK_BYTES` | stop a tool command before free disk falls below 2 GiB | approved `env/resource_budget.json` |
| `VLSIT_BASELINE_ID`, `VLSIT_RUN_ID`, `VLSIT_SNAPSHOT`, `VLSIT_RUN_ROOT` | helper-managed run paths | helper |

## Commands / Lệnh chạy

Run from `verification/sim`. The root `Makefile` indexes plan validation, generation, filelist resolution, regular/quick seal, check, execute, replay and coverage summary. Use `make seal-quick` only for package edits after a recent successful full check. The exact helper commands are:

Chạy tại `verification/sim`. `Makefile` liệt kê validate plan, sinh case, resolve filelist, seal thường/nhanh, check, execute, replay và coverage summary. Chỉ dùng `make seal-quick` cho thay đổi package sau một lần full check thành công gần đây. Các lệnh helper chính xác:

The runner sets GCC `TMP`, `TEMP` and `TMPDIR` to a unique writable `runs/<run-id>/build/<configuration>/tmp` directory. The host's inherited Windows temp path is not used.

Runner đặt `TMP`, `TEMP`, `TMPDIR` của GCC vào thư mục riêng có quyền ghi `runs/<run-id>/build/<configuration>/tmp`, không dùng temp path Windows được kế thừa từ host.

```powershell
python scripts/vlsit_verify_plan.py check docs/00_plan/vplan.csv --spec-index docs/00_plan/requirements.txt --today 2026-11-16
python scripts/generators/generate_case_manifest.py --root .
python scripts/generators/resolve_filelists.py --root .
python scripts/vlsit_sim_workspace.py seal --root .
make seal-quick
python scripts/vlsit_sim_workspace.py check --root .
python scripts/vlsit_sim_workspace.py execute --root . --baseline BASELINE_ID --run-id initial_001
python scripts/vlsit_sim_workspace.py replay --root . --baseline BASELINE_ID --run-id replay_001 --reference-run initial_001
python scripts/component_runner.py run . BASELINE_ID component_qualification_001
python scripts/component_runner.py run . BASELINE_ID tile_array_4h_001 coh_tile_array_4h
python scripts/cluster_cmo_runner.py run . BASELINE_ID cluster_cmo_qualification_001
python scripts/coverage_source_summary.py --scope docs/00_plan/active_rtl_source_scope.json --merged runs/initial_001/coverage/attempt_001/merged.dat --json runs/initial_001/reports/coverage_source_union.json --markdown runs/initial_001/reports/coverage_source_union.md
```

Every attempt uses a unique run directory; failed logs and partial artifacts remain there. Do not clean `runs/`, `coverage/`, or `snapshots/` automatically.

Mỗi attempt có run directory riêng; log lỗi và artifact dở được giữ lại. Không tự dọn `runs/`, `coverage/` hoặc `snapshots/`.

`make components` runs the same component suite from the single Makefile. Set `COMPONENT_RUN_ID` to a new value for each run. After editing package inputs, seal a new baseline before running; the component runner rejects an existing run ID and reads RTL only from the selected snapshot.

`make components` chạy bộ component test qua Makefile duy nhất. Đặt `COMPONENT_RUN_ID` thành giá trị mới cho mỗi lần chạy. Sau khi sửa input package, hãy seal baseline mới; runner từ chối ID đã tồn tại và chỉ đọc RTL từ snapshot được chọn.

`make cluster-cbo` executes the CBO CPU cases in functional-only mode. Set `CLUSTER_CMO_RUN_ID` to a new value for each run; the runner validates the selected sealed snapshot before building. Use `python scripts/cluster_cmo_runner.py run . BASELINE_ID RUN_ID --coverage` only for a separate coverage campaign.

## Timing-profile CPU qualification / Kiểm chứng CPU cho timing profile

`make profile1-qualification` runs the production TOP with the compile-time `PARA_TIMING_PROFILE=1` on both 2-hart and 4-hart builds. It executes eight full-CPU cases: four real CVA6 CBO.CLEAN cases (2/4 harts × success/AXI B error) and four real CVA6 FENCE.I cases (2/4 harts × success/error; the 2-hart error case traps in S-mode and the 4-hart error case traps in M-mode). These cover five basic behavior variants: CBO success, CBO AXI error, FENCE.I success, FENCE.I M-mode error, and FENCE.I S-mode error. Each FENCE.I case also configures the cluster PMU through AXI4-Lite, requests a snapshot, and checks that the CPU-generated CCU request counter is nonzero. The tests exercise the registered per-hart AXI routes and the new PMU event/snapshot pipeline without changing CVA6 internals.

The target builds four timed TOP models and is resource intensive. It uses the approved RAM/disk guard and stops before build if its start-RAM or disk thresholds are not met. Run IDs are unique and retained; after the FENCE run and the CBO run the target seals a new package baseline so neither run is unregistered. Existing historical run evidence is not overwritten. The suite is planned but has not been executed on the current profile-1 RTL yet; only a run receipt and passing case logs count as completion.

`make profile1-qualification` chạy TOP production với `PARA_TIMING_PROFILE=1` ở compile-time cho cấu hình 2 và 4 hart. Bộ kiểm chứng chạy tám ca full-CPU: bốn ca CVA6 CBO.CLEAN thật (2/4 hart × thành công/lỗi AXI B) và bốn ca CVA6 FENCE.I thật (2/4 hart × thành công/lỗi; ca lỗi 2 hart trap ở S-mode, ca lỗi 4 hart trap ở M-mode). Các ca này bao phủ năm biến thể cơ bản: CBO thành công, CBO lỗi AXI, FENCE.I thành công, FENCE.I lỗi M-mode và FENCE.I lỗi S-mode. Mỗi ca FENCE.I còn cấu hình PMU cluster qua AXI4-Lite, yêu cầu snapshot và xác nhận bộ đếm CCU request do CPU tạo khác 0. Các ca đi qua AXI route có thanh ghi và pipeline event/snapshot PMU mới mà không sửa logic bên trong CVA6.

Target này build bốn model TOP timed nên cần nhiều tài nguyên. Nó dùng resource guard RAM/disk đã duyệt và dừng trước build nếu RAM hoặc dung lượng trống thấp hơn ngưỡng. Run ID riêng được giữ lại; sau run FENCE và CBO, target seal baseline package mới để đăng ký run. Không ghi đè bằng chứng lịch sử. Bộ test đã được chuẩn bị nhưng chưa chạy trên RTL profile 1 hiện tại; chỉ receipt và log ca pass mới được tính là hoàn thành.

When GNU Make is unavailable, run the equivalent sequence from this directory in PowerShell. Read the baseline again after each seal because each retained run produces a new package snapshot:

```powershell
$baseline = (Get-Content env/workspace_manifest.json | ConvertFrom-Json).baseline_id
python scripts/vlsit_sim_workspace.py execute --root . --baseline $baseline --run-id timing_profile1_full_cpu_001
python scripts/vlsit_sim_workspace.py seal --root . --force
$baseline = (Get-Content env/workspace_manifest.json | ConvertFrom-Json).baseline_id
python scripts/cluster_cmo_runner.py run . $baseline timing_profile1_cbo_001
python scripts/vlsit_sim_workspace.py seal --root . --force
```

Khi không có GNU Make, chạy chuỗi lệnh tương đương trong PowerShell tại thư mục này. Đọc lại baseline sau mỗi lần seal vì mỗi run được giữ lại tạo snapshot package mới:

```powershell
$baseline = (Get-Content env/workspace_manifest.json | ConvertFrom-Json).baseline_id
python scripts/vlsit_sim_workspace.py execute --root . --baseline $baseline --run-id timing_profile1_full_cpu_001
python scripts/vlsit_sim_workspace.py seal --root . --force
$baseline = (Get-Content env/workspace_manifest.json | ConvertFrom-Json).baseline_id
python scripts/cluster_cmo_runner.py run . $baseline timing_profile1_cbo_001
python scripts/vlsit_sim_workspace.py seal --root . --force
```

## Memory-limited verification / Kiểm chứng giới hạn RAM

The full CPU TOP functional lane keeps assertions and all production sources, but omits line/expression/toggle instrumentation and does not write passing-run waveforms. Its low-memory experiment uses Verilator `-O0 -fno-inline` to disable model optimizations and module inlining; this can make simulation slower and must be checked for sufficient memory before elaboration completes. RTL behavior and assertions remain enabled. Its result explicitly says coverage was not collected. Run the component coverage lane separately; pass case IDs after the run ID to compile only selected directed benches. A large case can therefore run alone without rebuilding the rest of the suite.

Lane chức năng ở TOP giữ assertions và toàn bộ production source, nhưng bỏ instrument line/expression/toggle và không ghi waveform cho case pass. Thử nghiệm giảm RAM dùng Verilator `-O0 -fno-inline` để tắt tối ưu mô hình và module inlining; mô phỏng có thể chậm hơn và phải đo xem elaboration có đủ RAM hay không. RTL behavior và assertions vẫn được giữ. Kết quả ghi rõ coverage chưa được đo. Chạy riêng lane coverage cấp component; thêm case ID sau run ID để chỉ build test được chọn. Case lớn có thể chạy riêng mà không build lại cả suite.

The optional full-TOP coverage mode is separate (`project_runner.py compile-coverage` / `simulate-coverage`). Its generated Verilator control file excludes only source files outside the reviewed coverage scope; the active target remains all 119 VLSIT/new/generated and modified-copy RTL files. It is guarded by the same RAM-drop and disk limits. Do not interpret a stopped build as coverage evidence.

Chế độ coverage tùy chọn cho full TOP được chạy riêng (`project_runner.py compile-coverage` / `simulate-coverage`). File điều khiển Verilator chỉ loại các source nằm ngoài phạm vi coverage đã duyệt; phạm vi đích vẫn gồm đủ 119 file RTL mới/generated và bản modified. Chế độ này chịu cùng giới hạn mức giảm RAM và disk. Build bị dừng không được tính là bằng chứng coverage.

Each runner writes `runs/<run-id>/resource_usage.json`, including per-command RAM samples, the run-start available-RAM baseline, the minimum, the measured maximum drop, and the active thresholds. A tool starts only when available RAM is at least 2.14 GiB: 1 GiB hard reserve + 128 MiB guard margin + 1040 MiB run-drop budget. The guard samples every 100 ms and stops at the earlier of a 1040 MiB decrease from run start, the reserve-plus-margin threshold, or 2 GiB free disk. C++ translation units are compiled serially; a guard stop aborts the current build without launching queued compiler jobs. `execute` checks only the selected sealed snapshot and the new run receipt; the full retained-history audit remains available through `check` and regular `seal`. For a package-only edit after a recent successful full `check`, `seal --quick` verifies the selected old snapshot and the newly written snapshot, rehashes runs newer than the selected baseline, and reuses the prior audit for older run contents. Use regular `check` before handoff; do not use quick seal to bypass a known or suspected run-history change. This avoids rehashing all historical runs before every simulation or small helper update. Keep one run active at a time.
During TOP builds, each generated C++ file is removed after successful compilation; after linking, generated headers, object files and temporary directories are removed. The executable, ordered filelist, compile summaries and per-command logs remain, and the build can be reconstructed from the sealed RTL and recorded commands.

Mỗi runner ghi `runs/<run-id>/resource_usage.json`, gồm mẫu RAM từng lệnh, mốc RAM khả dụng lúc bắt đầu, mức thấp nhất, mức giảm RAM lớn nhất đã đo và các ngưỡng đang áp dụng. Chỉ khởi chạy tool khi RAM khả dụng ít nhất 2,14 GiB: dự trữ cứng 1 GiB + margin guard 128 MiB + ngân sách giảm 1040 MiB. Guard lấy mẫu mỗi 100 ms và dừng khi chạm ngưỡng nào đến trước: RAM giảm 1040 MiB so với lúc bắt đầu, ngưỡng dự trữ cộng margin, hoặc disk còn trống 2 GiB. C++ translation unit được biên dịch tuần tự; khi guard dừng, build hiện tại bị hủy và không khởi chạy tác vụ compiler đang chờ. `execute` chỉ kiểm tra snapshot đã seal được chọn và receipt của run mới; audit toàn bộ lịch sử vẫn thực hiện bằng `check` hoặc `seal` thông thường. Nếu chỉ sửa package sau một lần `check` đầy đủ thành công gần đây, `seal --quick` kiểm tra snapshot đang chọn và snapshot mới, hash lại các run mới hơn snapshot được chọn, và dùng lại audit trước đó cho nội dung run cũ hơn. Hãy dùng `check` thông thường trước khi bàn giao; không dùng quick seal để bỏ qua thay đổi lịch sử run đã biết hoặc nghi ngờ. Cách này tránh hash lại toàn bộ run cũ trước mỗi simulation hoặc cập nhật helper nhỏ. Chỉ chạy một run tại một thời điểm.
Khi build TOP, mỗi file C++ sinh ra được xóa sau khi compile thành công; sau khi link, các header, object file và thư mục tạm sinh tự động được xóa. Executable, filelist thứ tự nguồn, compile summary và log từng lệnh vẫn được giữ; có thể tái tạo build từ RTL đã seal và các lệnh đã ghi.

The first RAM-optimized TOP pilot (`ram_optimized_fence_001`) is retained as a failed build. It produced no simulation result. Pilot `002` failed its RAM admission guard; `004` stopped during serial C++ compilation; `005` stopped before run creation; `006` and `007` stopped at their RAM caps; `008` failed RAM admission; `009`, `010`, and `011` stopped during H2 Verilator elaboration. Pilot `013` used `-O0 -fno-inline` but stopped on the 2 GiB disk floor during H2 Verilator generation. Pilot `014` reached a 1,093,677,056-byte RAM drop (about 3 MiB above cap) and stopped. Pilot `015` added `-fno-inline-funcs`, but Verilator reported nine IMPURE errors because existing functions/tasks reference external variables when not inlined. Pilot `016` used output splits 500/125, passed Verilator and compiled 699 C++ objects, then stopped at a 1,123,381,248-byte drop (about 31 MiB above cap). Pilot `017` added `-fno-inline-cfuncs`, compiled 122 objects, then stopped on `Vtb_fence_i_end_to_end___024root__153__Slow.cpp` at a 1,091,416,064-byte drop (about 0.86 MiB above cap). Pilot `018` lowered C++ function split to 64 but stopped during Verilator at a 1,093,267,456-byte drop (about 2.6 MiB above cap). None reached functional simulation. The next trial keeps `-fno-inline-cfuncs` and output split 500, with function split 100 as a compromise between Verilator peak and C++ translation-unit size. RTL/assertions and the 1040 MiB cap, 1 GiB hard RAM reserve, 128 MiB margin and 2 GiB disk floor remain unchanged. A complete passing run is still required.

Pilot TOP tối ưu RAM đầu tiên (`ram_optimized_fence_001`) được giữ lại với trạng thái build thất bại, không có kết quả mô phỏng. Pilot `002` không qua guard RAM; `004` dừng khi compile C++ tuần tự; `005` dừng trước khi tạo run; `006` và `007` dừng ở ngưỡng RAM; `008` không qua preflight RAM; `009`, `010` và `011` dừng trong elaboration Verilator H2. Pilot `013` chạm sàn disk 2 GiB; `014` đạt mức giảm 1.093.677.056 byte (cao hơn cap khoảng 3 MiB) rồi dừng. Pilot `015` có 9 lỗi IMPURE do function/task tham chiếu biến ngoài khi không inline. Pilot `016` dùng split 500/125, qua Verilator và compile 699 object C++ rồi dừng ở mức giảm 1.123.381.248 byte (cao hơn cap khoảng 31 MiB). Pilot `017` thêm `-fno-inline-cfuncs`, compile 122 object rồi dừng tại `Vtb_fence_i_end_to_end___024root__153__Slow.cpp`, mức giảm 1.091.416.064 byte (cao hơn cap khoảng 0,86 MiB). Pilot `018` giảm function split xuống 64 nhưng Verilator dừng ở mức giảm 1.093.267.456 byte (cao hơn cap khoảng 2,6 MiB). Chưa run nào trong nhóm này tới mô phỏng chức năng. Lần thử tiếp theo giữ `-fno-inline-cfuncs`, output split 500 và chọn function split 100 để cân bằng peak Verilator và kích thước translation unit C++. RTL/assertions, cap 1040 MiB, dự trữ RAM cứng 1 GiB, margin 128 MiB và sàn disk 2 GiB giữ nguyên. Cần run hoàn chỉnh có receipt pass.

`make cluster-cbo` chạy các case CBO cấp CPU. Đặt `CLUSTER_CMO_RUN_ID` thành giá trị mới mỗi lần chạy; runner kiểm tra snapshot đã seal trước khi build.

## Replay / Chạy lại

`seal` snapshots reviewed inputs. `execute` builds and simulates in a fresh run directory from that frozen snapshot. `replay` repeats the retained commands in another fresh directory and compares exact normalized results and observed tool versions. The manifest keeps `cold_replay: not_run`; only helper receipts record measured replay status.

`seal` snapshot input đã review. `execute` build/simulate ở run directory mới từ snapshot bất biến. `replay` lặp lại lệnh trong directory mới khác, so sánh kết quả chuẩn hóa và phiên bản tool. Manifest giữ `cold_replay: not_run`; receipt của helper mới ghi trạng thái replay thực đo.

## Results and limitations / Kết quả và giới hạn

This is a clean, profile-1 qualification package created from the current reviewed inputs. Historical simulations and reports remain in the sibling verification/sim package and were not copied or altered. The sibling package's catalog references a missing historical snapshot, so this package starts a separate evidence history rather than rewriting that catalog. Profile-1 full-CPU tests are prepared but not run yet. A pass requires fresh 2-hart and 4-hart TOP logs for the CBO and FENCE.I cases, including the PMU scoreboard. Coverage, lint, full HDS closure and timing signoff remain open.

Đây là package kiểm chứng profile 1 mới, được tạo từ các input hiện tại đã review. Mô phỏng và báo cáo lịch sử vẫn nằm nguyên trong package anh em verification/sim, không được sao chép hay sửa đổi. Catalog package cũ tham chiếu một snapshot lịch sử bị thiếu, nên package này bắt đầu lịch sử bằng chứng riêng thay vì viết lại catalog đó. Các bài full-CPU profile 1 đã chuẩn bị nhưng chưa chạy. Để pass cần log TOP mới cho 2 và 4 hart đối với CBO và FENCE.I, gồm cả scoreboard PMU. Coverage, lint, closure HDS đầy đủ và signoff timing vẫn còn mở.

## Dependencies and generators / Dependency và generator

`env/build_inputs.json` lists retained replay inputs; exact external tool builds are separate dependencies. `scripts/generators/generation_manifest.json` records the testcase-matrix generator and C++ timed simulation-entrypoint generator with input/output hashes. Generators refuse overwrite unless `--force` is explicit.

`env/build_inputs.json` liệt kê input replay được giữ; tool cài ngoài được khai báo riêng. `scripts/generators/generation_manifest.json` lưu generator ma trận testcase và C++ timing entrypoint cùng hash input/output. Generator từ chối ghi đè nếu không nêu `--force`.

## Troubleshooting / Xử lý lỗi

If `seal` or `check` fails, preserve the existing run artifacts, correct the package input identified by the helper, and seal a new baseline. Do not edit a sealed snapshot or reuse a run ID. If a simulator warning or assertion fails, retain its log and classify it against the HDS before changing RTL or the testbench.

Nếu `seal` hoặc `check` lỗi, giữ nguyên artifact run hiện có, sửa input package mà helper chỉ ra rồi seal baseline mới. Không sửa snapshot đã seal hoặc dùng lại run ID. Nếu simulator báo warning hoặc assertion fail, giữ log và đối chiếu HDS trước khi sửa RTL hay testbench.
