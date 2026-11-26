# Isolated cluster verification package / Gói kiểm chứng cluster độc lập

This folder stores a reproducible verification environment for the AXI RISC-V cluster. The DUT is copied into `dut/source`; compilation and simulation must use that copy only. The HDS and protocol clauses are the behavioral golden sources. RTL hierarchy/state probes are implementation checks, never expected-value models.

Thư mục này lưu môi trường kiểm chứng có thể chạy lại cho cluster RISC-V AXI. DUT được sao chép vào `dut/source`; build và simulation chỉ dùng bản sao này. HDS và điều khoản protocol là nguồn chuẩn hành vi. Quan sát hierarchy/state RTL chỉ dùng để kiểm tra triển khai, không làm mô hình kết quả mong đợi.

## Prerequisites / Điều kiện cần

Qualified local setup observed on 2026-11-16:

| Tool | Observed version | Purpose |
|---|---|---|
| Python | 3.12.10 | package, generator, and run controller |
| Verilator | 5.053 devel `v5.052-119-g014c9820d` | SystemVerilog model, assertions, line/expression/toggle coverage |
| MSYS2 UCRT64 g++ | 16.2.0 | compile the generated timed C++ model |

The retained paths and version transcripts are in `env/toolchain.json` and `docs/tool_versions/`. Verilator 5.053 is a development build, so it is pinned by exact executable and version transcript. Questa 10.4c was not usable on this host (`Illegal System DLL Relocation`); expression coverage from Verilator is not called condition coverage. The current Windows environment has no working `make`; `Makefile` remains the single command index, and each target has an equivalent Python command below.

Thiết lập đã đo ngày 2026-11-16:

| Công cụ | Phiên bản | Mục đích |
|---|---|---|
| Python | 3.12.10 | quản lý gói, sinh dữ liệu và điều khiển run |
| Verilator | 5.053 devel `v5.052-119-g014c9820d` | model SystemVerilog, assertion và coverage line/expression/toggle |
| MSYS2 UCRT64 g++ | 16.2.0 | biên dịch model C++ có timing |

Đường dẫn và log phiên bản được giữ tại `env/toolchain.json` và `docs/tool_versions/`. Verilator là bản phát triển, được khóa bằng executable và log phiên bản. Questa 10.4c không chạy được trên máy này (`Illegal System DLL Relocation`); expression coverage của Verilator không được gọi là condition coverage. Windows hiện tại không có `make` hoạt động; `Makefile` là mục lục lệnh duy nhất và từng target có lệnh Python tương đương bên dưới.

## Structure / Cấu trúc

```text
sim/
  docs/       approved plan, HDS, source/license provenance, tool logs
  env/        isolated tool config, flattened source order, replay/dependency manifests
  dut/source/ hashed copy of active RTL and include directories
  tests/      copied tests, input matrix, generated qualification case manifest
  scripts/    runner, package helper, generators and checkers
  runs/       unique retained run directories and receipts
  coverage/   per-run raw coverage outputs and later merged reports
  snapshots/  immutable SHA-256 replay baselines
  Makefile    one command index for plan, build, simulation, coverage, replay
```

`env/source_order.json` records the original filelist order: 464 HDL files and 7 include directories. `docs/source_origin.json` and the active-source inventory record each copied file's original relative path, SHA-256, classification, and pristine baseline relationship. Copyright and SPDX headers remain unchanged in copied RTL; repository provenance and license notes are retained under `docs/source_docs/third_party/`.

`env/source_order.json` giữ thứ tự filelist gốc: 464 file HDL và 7 include directory. `docs/source_origin.json` cùng danh mục source ghi đường dẫn gốc tương đối, SHA-256, phân loại và quan hệ với baseline sạch cho từng file. Header copyright/SPDX của RTL được giữ nguyên; thông tin repository và license lưu trong `docs/source_docs/third_party/`.

## Environment variables / Biến môi trường

The replay helper creates an isolated environment from `env/replay_manifest.json`; it does not inherit the interactive shell's full environment. No secrets are used.

Replay helper tạo môi trường riêng theo `env/replay_manifest.json`, không kế thừa toàn bộ shell tương tác. Không dùng secret.

| Name | Purpose | Value source | Secret |
|---|---|---|---|
| `VERILATOR_ROOT` | installed Verilator runtime root | `env/toolchain.json` | No |
| `PATH` | DLL/runtime search for UCRT64, Verilator and Python | curated paths in `env/toolchain.json` | No |
| `VLSIT_BUILD_JOBS` | parallel C++ compile workers | fixed value `2` in manifest | No |
| `VLSIT_BASELINE_ID`, `VLSIT_RUN_ID`, `VLSIT_SNAPSHOT`, `VLSIT_RUN_ROOT` | helper-managed run identity and paths | helper only | No |

## Commands / Lệnh chạy

Run from `verification/sim`. All test/build/simulation commands are indexed in `Makefile`. The package helper commands below are the exact commands the Makefile calls.

Chạy tại `verification/sim`. Mọi lệnh test/build/simulation được liệt kê trong `Makefile`. Các lệnh helper bên dưới là lệnh chính xác mà Makefile gọi.

```powershell
python scripts/generators/resolve_filelists.py --root .
python scripts/generators/generate_case_manifest.py --root .
python scripts/vlsit_verify_plan.py check docs/00_plan/vplan.csv --spec-index docs/00_plan/requirements.txt --today 2026-11-16
python scripts/vlsit_sim_workspace.py seal --root .
python scripts/vlsit_sim_workspace.py check --root .
python scripts/vlsit_sim_workspace.py execute --root . --baseline BASELINE_ID --run-id initial_001
python scripts/vlsit_sim_workspace.py replay --root . --baseline BASELINE_ID --run-id replay_001 --reference-run initial_001
```

Build outputs, logs, waveforms, coverage files, result JSON and receipts are retained in a unique `runs/<run-id>/` directory. A failed run remains available for diagnosis; use a new run ID for every attempt. Never point the runner at `rtl/` or an old output directory.

Build, log, waveform, coverage, result JSON và receipt được lưu trong `runs/<run-id>/`. Run lỗi được giữ để phân tích; mỗi lần thử dùng run ID mới. Không trỏ runner vào `rtl/` hoặc thư mục output cũ.

## Replay / Chạy lại

`seal` creates a content-addressed snapshot after input and result-producer review. `execute` builds in a fresh directory using only the frozen snapshot. `replay` repeats the same commands in another fresh directory and requires exact normalized result equality and matching measured tool versions. The manifest's `cold_replay` remains `not_run`; actual results are stored in helper-generated receipts.

`seal` tạo snapshot theo hash sau khi review input và bộ tạo kết quả. `execute` build ở thư mục mới, chỉ dùng snapshot đã khóa. `replay` chạy lại lệnh trong thư mục mới khác và yêu cầu kết quả chuẩn hóa khớp tuyệt đối, phiên bản tool đo được phải khớp. `cold_replay` trong manifest giữ `not_run`; kết quả thật nằm trong receipt do helper tạo.

## Results and limitations / Kết quả và giới hạn

G0 is approved. The four-case FENCE.I HDS smoke set is the first runner qualification: 2/4 harts × successful/failed dirty-line transfer. It checks architectural retirement or trap, maintenance ordering, waveform output, and 20 exercised AXI protocol assertions. This initial set is not the 97-row full-HDS campaign and cannot establish the approved 100% line, expression, and toggle coverage targets. Full HDS qualification requires implementing the remaining plan rows, running the width/parameter matrix, then merging and reviewing all active VLSIT/new/generated and modified-source coverage.

G0 đã được duyệt. Bộ smoke FENCE.I bốn case dùng để qualification runner đầu tiên: 2/4 hart × ghi line thành công/lỗi. Nó kiểm retirement hoặc trap kiến trúc, thứ tự maintenance, waveform và 20 AXI protocol assertion đã được kích hoạt. Bộ này chưa phải campaign HDS đủ 97 dòng, không thể chứng minh mục tiêu coverage line, expression và toggle 100%. Qualification đầy đủ cần triển khai các dòng plan còn lại, chạy ma trận width/parameter, sau đó merge và review coverage của toàn bộ source VLSIT mới/generated và source đã sửa.

## Troubleshooting / Xử lý lỗi

- Verilator model warnings are treated as a failed compile; they are not waived.
- A failed compiler or simulator command retains its exact argv, cwd, log, and partial outputs in its run folder.
- `make` is not installed/usable in the current shell. Run the equivalent Python command above or provision GNU Make; no command is silently skipped.
- If a tool version changes, preserve old snapshots/runs, update `env/toolchain.json` and version logs, review inputs, then seal a new baseline.
- Do not delete `runs/`, `coverage/`, or `snapshots/` as cleanup.

- Warning của Verilator làm compile thất bại; không waive warning.
- Lệnh compiler/simulator lỗi sẽ giữ argv, cwd, log và output dở trong run riêng.
- `make` hiện không khả dụng trong shell. Dùng lệnh Python tương đương ở trên hoặc cài GNU Make; không có lệnh nào bị bỏ qua âm thầm.
- Khi đổi phiên bản tool, giữ snapshot/run cũ, cập nhật `env/toolchain.json` và version log, review input rồi seal baseline mới.
- Không xóa `runs/`, `coverage/` hoặc `snapshots/` để dọn dữ liệu.

## Dependency review and generators / Review dependency và generator

`env/build_inputs.json` enumerates every retained replay input; external tool installations and exact versions are listed separately in `env/replay_manifest.json`. The dependency set was checked against the G0 active-source hash inventory, filelist order and all literal HDL includes. `scripts/generators/generation_manifest.json` records the testcase-matrix generator and timed C++ simulation-entrypoint generator. Both generators refuse to overwrite existing outputs unless explicitly given `--force`; output/input hashes are retained.

`env/build_inputs.json` liệt kê mọi input replay được giữ; tool cài ngoài và phiên bản cụ thể được khai báo riêng trong `env/replay_manifest.json`. Dependency set được đối chiếu với hash inventory G0, thứ tự filelist và mọi HDL include tĩnh. `scripts/generators/generation_manifest.json` ghi generator ma trận testcase và generator C++ simulation entrypoint có timing. Generator từ chối ghi đè output nếu không có `--force`; hash input/output được lưu.
