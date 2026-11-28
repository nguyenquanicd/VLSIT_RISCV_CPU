# rv32_dual (VLSIT RISC-V RV32 cluster, CFG-RV32-2) simulation environment / Môi trường simulation

This package preserves replay inputs. / Gói này lưu đầu vào để chạy lại.

Terminology / Thuật ngữ: Design Under Test (DUT), testbench (TB), Bus Functional
Model (BFM), Register-Transfer Level (RTL).

## Prerequisites / Điều kiện cần

Current status (2026-11-28): gates G0 and G1 approved (`docs/00_plan/signoff.md`). The environment of plan 5.2/5.3
(`env/`, `tb/tb_top.sv`), the generators (`scripts/generators/`), 34 testcase sources (`tests/`, the 4 fully blocked tests are not
written) and the testlist exist. Only Verilator **lint-only** has been run on verification sources (against stubs generated
from the REF-001 port tables). No build and no simulation: free disk is below the approved 2 GiB stop threshold, and every CPU
simulation is now bound to the REF-001 rev 0.40 14.4.20 region parameters (Q-G3-01 answered); only the disk threshold blocks a first build.
Hiện trạng (2026-11-28): đã duyệt G0, G1. Đã có môi trường (env/, tb/), generator, 34 testcase và testlist. Mới chạy
Verilator lint-only trên mã kiểm chứng. Bảng vùng địa chỉ đã gắn theo REF-001 rev 0.40 mục 14.4.20 (Q-G3-01 đã trả lời); chỉ còn chờ đủ dung lượng ổ đĩa để build.

| Tool | Version | Status / Trạng thái |
|---|---|---|
| Python | 3.12 (`python --version`), standard library only | used / đã dùng |
| Verilator | 5.053 (`C:/Users/PC/Tools/oss-cad-suite/bin/verilator_bin.exe`, `VERILATOR_ROOT=C:/Users/PC/Tools/oss-cad-suite/share/verilator`) | lint-only used; build/simulation not run |
| Icarus Verilog | installed version to be recorded at first use | planned (BFM self-tests) |
| SymbiYosys + Boolector/Bitwuzla | to be recorded at first use | planned (component formal) |
| RISC-V GCC toolchain | not used; replaced by `models/asm_rv32` (RISK-04, G1) | n/a |

EN: List the simulator, compiler, model language/runtime, libraries, licenses and
version-query commands. Distinguish observed versions from required but unavailable
tools. Explain how to provision external dependencies without storing credentials.

VI: Liệt kê simulator, compiler, runtime, thư viện, license và lệnh kiểm phiên bản.
Phân biệt phiên bản đã đo với tool chưa có; hướng dẫn cấp dependency và credential
qua kênh phù hợp, không ghi giá trị bí mật trong gói.

## Structure / Cấu trúc

```text
sim/
  docs/       plans, contracts, approvals, reports and this environment's instructions
  env/        interface/BFM/checker code, variables, filelists, locks and tool settings
  tb/         simulation top and integration harness
  dut/        preserved DUT baseline and includes
  models/     used reference-model sources and build instructions
  tests/      test cases, sequences, data/vectors and regression lists
  scripts/    actual project build/run/replay entrypoints
  runs/       separate retained directory for every run, including failed runs
  coverage/   merged campaign coverage and exclusions
  snapshots/  immutable, hash-identified replay input baselines
```

## Environment variables / Biến môi trường

Python parts need none. Lint uses VERILATOR_ROOT (and optionally VERILATOR_BIN). / Phần Python không cần biến; lint dùng VERILATOR_ROOT.

| Name / Tên | Purpose / Mục đích | Required / Bắt buộc | Effective value or source / Giá trị hoặc nguồn | Secret / Bí mật |
|---|---|---|---|---|
| VERILATOR_ROOT | Verilator data directory for lint | lint only | C:/Users/PC/Tools/oss-cad-suite/share/verilator (default in scripts/lint_env.sh) | no |
| VERILATOR_BIN | Verilator executable override | optional | C:/Users/PC/Tools/oss-cad-suite/bin/verilator_bin.exe | no |

EN: Include relevant PATH/library/model/seed variables, overrides and setup order.
Record the effective non-secret values in env/replay_manifest.json. For secrets,
record only the variable name, purpose and provisioning instructions. Never copy
license keys, passwords, access tokens or an entire uncontrolled environment dump.

VI: Nêu biến PATH/thư viện/model/seed liên quan, giá trị override và thứ tự setup.
Lưu giá trị thực không bí mật trong manifest. Với secret chỉ ghi tên, mục đích và
cách cấp; không chép license key, mật khẩu, token hay toàn bộ environment tùy tiện.

## Commands / Lệnh chạy

Working directory / Thư mục làm việc: `verification/rv32_dual`.

```sh
python --version
# qualification of every Python model/checker (writes docs/01_qualification/, refuses to overwrite without --force)
python scripts/run_model_qualification.py --force
# pre-build region-table check (Q-G0-09); exit 0 = accepted
python models/chk_region_table.py models/configs/region_table_campaign.json
# assemble an RV32 program
python models/asm_rv32/asm_rv32.py <source.S> --base 0x80000000 -o <out.memh> --symbols <out.sym>
# environment components from the REF-001 port tables (stubs, port list, debug ROM); --check = verify, --force = rewrite
python scripts/generators/gen_env.py --check
# testcase programs + expected-value records for every tests/t_*.py (R-276); --check = verify determinism
python scripts/generators/gen_prog.py --check
# Verilator lint-only of tb_top, BFMs, monitors, SVA, checkers and formal harnesses (no build output)
bash scripts/lint_env.sh
# qualification of the Python scoreboards, coverage collector and evaluator on synthetic logs
python scripts/run_env_qualification.py --force
# after a simulation run (not possible yet): evaluate every planned check of one run, then merge coverage
python scripts/evaluate_run.py runs/<run_id>
python env/coverage/cov_collect.py docs/00_plan/vplan.csv runs/<run_id> [runs/<run_id2> ...]
```

Expected last lines / Dòng cuối mong đợi: model qualification `OVERALL: PASS (10 suites)`; environment qualification
`OVERALL: PASS (6 suites)`; generators `CHECK: ... identical`; lint `# overall exit=0`. Recorded outputs:
`docs/01_qualification/run_output.txt`, `docs/02_env/run_output.txt`, `docs/02_env/generators_check.txt`, `docs/02_env/lint_env.log`.
Simulation build/run commands are documented in `env/README.md` and `tests/testlist.yaml` but cannot run yet (disk below threshold).

EN: For each command provide the working directory, exact argument list, variables,
tool/version, seed, timeout, exit code, log and expected outputs. Commands below
must invoke the retained project runner/build files, not code that existed only
in a chat or temporary folder. Keep version output and failed-run logs too.

VI: Mỗi lệnh cần có thư mục làm việc, đầy đủ tham số, biến, tool/version, seed,
timeout, exit code, log và đầu ra mong đợi. Dùng runner/build file đã lưu, không
phụ thuộc đoạn code chỉ có trong chat hay thư mục tạm. Giữ cả log phiên bản và lỗi.

Package integrity / Kiểm tra gói (does not run simulation / không chạy simulator):

```sh
python scripts/vlsit_sim_workspace.py seal --root .
python scripts/vlsit_sim_workspace.py check --root .
```

A new selected baseline uses seal --force; existing snapshots remain retained.
Dùng seal --force khi chọn baseline mới; các snapshot cũ vẫn được giữ.

## Replay / Chạy lại

Not applicable yet: no simulation run exists; `cold_replay` stays `not_run`. / Chưa áp dụng: chưa có run simulation.

EN: State the snapshot ID and actual command to rebuild in a fresh run directory,
with the same retained testbench/models/data/configuration and a documented tool
baseline. Use check --root . --baseline BASELINE_ID to validate an older snapshot
without requiring the current editable workspace to match it. Compare outcomes
and coverage, and save new receipts/logs. Record not_run if tools are unavailable.

VI: Nêu snapshot ID và lệnh rebuild ở run directory mới với cùng testbench/model/
data/cấu hình đã lưu và tool baseline rõ ràng. Kiểm snapshot cũ bằng --baseline;
không ép workspace đang chỉnh sửa phải trùng bản cũ. So sánh kết quả và coverage,
lưu receipt/log mới; ghi not_run nếu chưa có tool để chạy.

## Results and limitations / Kết quả và giới hạn

- Model/checker qualification: `docs/01_qualification/summary.md`; environment checker qualification: `docs/02_env/summary.md`
  (machine results; review pending).
- Lint-only of verification sources: clean (`docs/02_env/lint_env.log`). Compilation, simulation, formal runs, coverage closure,
  cold replay: **not run**. Waveforms of the ten R-283 tests: not captured (no run).
- Region table bound from REF-001 rev 0.40 14.4.20 (Q-G3-01 answered). Still blocked: 4 tests not written (Q-G0-04, Q-G0-05/DEP-DV-01);
  SVA-101/104/105 (Q-G0-13); static runners `scripts/static/*.py` of the elaboration/lint tests are not written (they need the RTL
  in the execution phase).
- Limitations: KAT expected values and models share one AI author (correlated-error notes in each `build_manifest.json`);
  the LLC service window is not modelled (Q-G0-04); no human review yet (R-231, R-284).
- Kết quả qualification ở `docs/01_qualification/summary.md`; compile, simulation, closure, replay: **chưa chạy**.

EN: Link the verification report, run directories, package baseline and source-bound
closure result. State compilation, simulation, closure and cold-replay status
separately. Package-integrity success does not establish any of those outcomes.

VI: Link verification report, run directory, package baseline và closure result.
Nêu riêng compile, simulation, closure và cold replay. Gói toàn vẹn không tự chứng
minh các bước này đã đạt.

## Resource budget and usage / Ngân sách và mức dùng tài nguyên

EN: Link `env/resource_budget.json` and summarize the reviewed RAM headroom,
simulation concurrency, disk stop threshold and waveform policy. Link each run's
`resource_usage.json` with measured peak RAM, free disk before/after, output size,
waveform scope/status and any compression round-trip hashes. Mark unavailable
measurements as `not_measured` with a reason. Stop starting new jobs before a disk
threshold is crossed; preserve existing runs/evidence. Do not claim resource limits
were enforced when the available tools only report estimates.

VI: Link `env/resource_budget.json`, nêu RAM dự phòng, số job đồng thời, ngưỡng dừng
theo dung lượng ổ đĩa và chính sách waveform đã review. Link `resource_usage.json`
của mỗi run với peak RAM, dung lượng trống trước/sau, kích thước output, trạng thái/
phạm vi waveform và hash kiểm tra giải nén nếu có. Đánh dấu `not_measured` cùng lý
do khi không đo được. Dừng khởi chạy run mới trước khi chạm ngưỡng ổ đĩa; giữ các
run/evidence hiện có. Không tuyên bố đã enforce nếu tool chỉ đưa ra ước lượng.

## Troubleshooting / Xử lý lỗi

- `refusing to overwrite ...`: the runner protects existing records; rerun with `--force` only when a new record is intended.
- `ASM ERROR: line N: ...`: the assembler rejects out-of-range immediates, unknown or RV64/D mnemonics; use `.word` for negative-test encodings.
- `NotImplementedError: LLC service window not modelled (Q-G0-04)`: expected until the LLC register table is in REF-001 Section 11.
- Thông báo `refusing to overwrite`: dùng `--force` khi thật sự muốn ghi bản mới; `ASM ERROR`: sửa immediate/mnemonic.

EN: Explain missing tools/variables/libraries, failed commands, timeouts and replay
mismatches. Preserve all evidence; do not clean environments/testbenches/runs as
an automatic final step. Describe explicit user-controlled cache cleanup separately.

VI: Hướng dẫn xử lý thiếu tool/biến/thư viện, lệnh lỗi, timeout và lệch replay.
Giữ evidence; không tự xóa môi trường/testbench/run sau khi báo cáo. Nếu cần dọn
cache, phải mô tả thao tác riêng do người dùng chủ động chọn.

## Dependency discovery and retention / Dependency và lưu giữ

Python parts depend only on the standard library and on `doc/specification/VLSIT_RISCV_CPU_Cluster_CSR.xlsx` (read by `chk_csr_model` and
`chk_pmu_model`; its SHA-256 is in their `build_manifest.json`). `env/build_inputs.json` is not updated by this step (no HDL build inputs yet).
Phần Python chỉ dùng thư viện chuẩn và workbook CSR; `env/build_inputs.json` chưa cập nhật vì chưa có đầu vào build HDL.

EN: Link env/build_inputs.json, its transitive compiler/runtime inputs, discovery
method, unresolved items and reviewer. List all cataloged baseline/run IDs and
whole-package backup location. Keep root build files, merged coverage, failed runs
and all snapshots. Schema 1 migration must preserve the original package/evidence.

VI: Link env/build_inputs.json, toàn bộ đầu vào compiler/runtime liên quan, cách
thu thập, điểm chưa rõ và người review. Liệt kê baseline/run trong catalog và nơi
sao lưu toàn gói. Giữ build file ở root, coverage tổng hợp, run lỗi và mọi snapshot.
Giữ nguyên gói/evidence cũ khi chuyển schema 1.

EN: The manifest cold_replay field stays not_run; actual outcomes are generated
per-run receipts. After sealing a reviewed dependency closure, execute a reference
and replay into another new directory. Specify exact case/configuration/seed and
observable scope; link the actual runner adapter and qualification evidence.

VI: Trường cold_replay trong manifest giữ not_run; kết quả thực tế nằm trong receipt
từng run. Sau khi seal đầu vào đã review, chạy run tham chiếu và replay ở thư mục
mới khác. Nêu đúng phạm vi case/cấu hình/seed/observable; link adapter và qualification.

```sh
python scripts/vlsit_sim_workspace.py execute --root . --baseline BASELINE_ID --run-id original_001
python scripts/vlsit_sim_workspace.py replay --root . --baseline BASELINE_ID --run-id replay_001 --reference-run original_001
```

EN: execute/replay actually launch retained commands with isolated variables. They
require fresh build/result artifacts, checked completed cases, matching measured
versions and exact normalized outcomes. init/seal/check alone never establish replay.
Do not infer full campaign/coverage closure from a scoped replay. Document unavailable
tools or unqualified producers as limitations, not successful reproduction.

VI: execute/replay thực sự gọi lệnh đã lưu với biến cách ly. Cần build/result mới,
case hoàn tất có phép kiểm, phiên bản tool đo thực tế khớp và kết quả chuẩn hóa khớp.
Chỉ init/seal/check không chứng minh đã replay. Không suy diễn toàn campaign/coverage
đã đóng từ replay có giới hạn. Báo tool thiếu/producer chưa qualification là giới hạn.

## Reusable generators / Script sinh có thể tái sử dụng

- `scripts/generators/gen_env.py`: environment-component generator (REF-001 6.2 port list -> `tb/generated/` stub, port connections,
  signals; REF-001 14.4 -> formal component stubs; Q-G0-07 debug ROM -> `env/generated/`); manifest `env/generated/generation_manifest.json`.
- `scripts/generators/gen_prog.py` + `rv32d_lib.py`: testcase generator; reads `tests/t_*.py` (R-281 header + `build(p)`), writes
  `tests/generated/<test>/` (program, memh, symbols, expected checks, BFM rules, AXI4-Lite script, dump ranges, plusargs) and
  `tests/generated/generation_manifest.json` (input/output SHA-256, command).
- Both are deterministic, refuse to overwrite changed outputs without `--force`, and support `--check`. Generated files need the
  normal engineer review before execution (R-231, R-284).
- Sinh môi trường và testcase có tính tất định, không ghi đè nếu không có --force, hỗ trợ --check; đầu ra cần kỹ sư review.

EN: Link scripts/generators, generator templates/configuration, generation manifest
and retained generated files. Document the command, working directory, input hashes,
requirement/scenario IDs, output paths/hashes, version and review status for both
testcase generation and applicable environment-component generation. State how to
run a clean-copy regeneration or check/diff. Explain overwrite protection and how
generated tests/components are reviewed and qualified before execution.

VI: Link scripts/generators, template/cấu hình, generation manifest và file đã sinh.
Ghi lệnh, thư mục chạy, hash đầu vào, requirement/scenario ID, đường dẫn/hash đầu ra,
phiên bản và trạng thái review cho cả sinh testcase lẫn component môi trường phù hợp.
Nêu cách sinh lại trên bản sao sạch hoặc check/diff, cách chặn ghi đè và quy trình
review/qualification đầu ra trước khi chạy.
