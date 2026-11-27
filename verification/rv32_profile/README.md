# verification/rv32_profile — Cluster testbench (32-bit and 64-bit) / Testbench cluster (32-bit và 64-bit)

Directed testbench for the cluster TOP with real CVA6 instructions. Written for the 32-bit cluster; with `--xlen 64` the same testbench and programs run on the 64-bit cluster. Expected values come from an independent Python oracle, never from the RTL.

Testbench directed cho TOP cluster, chạy lệnh CVA6 thật. Viết cho cluster 32-bit; với `--xlen 64` cùng testbench và chương trình chạy trên cluster 64-bit. Giá trị mong đợi lấy từ oracle Python độc lập, không lấy từ RTL.

## Files / Các file

| File | Function / Chức năng |
|---|---|
| `run.py` | Build (Verilator + g++) and run testcases / Build và chạy testcase |
| `tests.py` | TC-01 to TC-10 programs and expected results; exact binary32 rounding model for FPU checks / Chương trình và kết quả mong đợi; mô hình làm tròn binary32 chính xác |
| `asm_rv32.py` | RV32 encoder (I, M, A, F, B, Zcb, Zicond, Zicbom, CSR); zero-extends DRAM addresses in 64-bit mode / Bộ mã hóa lệnh RV32 |
| `tb/tb_rv32_cluster.sv` | TOP testbench: AXI memory and MMIO models, 48 counted assertions (AXI4 rules, fabric checks SVA-104/105), signature checker, watchdog / Testbench TOP, mô hình bộ nhớ, 48 assertion |
| `tb/tb_faults.svh` | Controlled faults for fault qualification (`+FAULT=n`, 32-bit build) / Lỗi cố ý để chứng minh test bắt được lỗi |
| `tb/tb_experiments_rv64.svh` | Simulation-only root-cause experiments (`+EXPERIMENT=n`, 64-bit build) / Thí nghiệm tìm nguyên nhân, chỉ trong mô phỏng |
| `sva/` | SVA-101 to SVA-103 bound into the RV32 tile / SVA gắn vào tile RV32 |
| `TEST_PLAN.md`, `REPORT.md`, `FAULTS.md`, `REVIEW_LEDGER.md` | Plan, results and root-cause analyses, fault plan, engineer review ledger / Kế hoạch, kết quả, phân tích, sổ review |

## Testcases / Testcase

| TC | Scope / Nội dung |
|---|---|
| TC-01 | Boot, hart identity, `misa`, RV64-only encodings trap / Khởi động, ID hart, lệnh chỉ có ở RV64 phải trap |
| TC-02 | RV32 integer, M, B, Zcb, Zicond, 64-bit counters / Số nguyên, bộ đếm 64-bit |
| TC-03 | F single precision, divide/sqrt corner cases with flags, D rejected / FPU single, cờ, D bị từ chối |
| TC-04, TC-05 | Cached sharing, dirty-owner transfer / Chia sẻ dữ liệu cache, chuyển owner dirty |
| TC-06 | LR.W/SC.W and AMO.W across harts / Atomic giữa các hart |
| TC-07 | CBO.CLEAN/FLUSH/INVAL and FENCE.I while other harts contend (TEST-064) / CBO và FENCE.I khi các hart khác tranh chấp |
| TC-08 | Sv32, S/U modes, page faults / Bộ nhớ ảo Sv32 |
| TC-09, TC-10 | MMIO order and protocol; boot address upper half / Thứ tự MMIO; nửa cao địa chỉ boot |

## Commands / Lệnh

```powershell
python run.py build --harts 4                 # 32-bit, 4 harts
python run.py run TC-01 TC-07 --harts 4
python run.py build --harts 4 --xlen 64       # 64-bit cluster
python run.py run TC-07 --harts 4 --xlen 64
python run.py run TC-07 --harts 4 --xlen 64 --base-64   # pre-fix RTL, reproduces the old hang
```

Options / Tùy chọn: `--profile 0/1/2`, `--fault n`, `--timeout cycles`, `--tag name`. Environment / Biến môi trường: `TC07_PART` (harts in the TC-07 barrier), `VLSIT_TB_TRACE_DEPTH` (deep waveform build), `VLSIT_TB_EXPERIMENT`, `VLSIT_TB_FILELIST`.

## Notes / Lưu ý

- Status: TC-01 to TC-10 PASS with 2 and 4 harts on the 32-bit cluster; TC-04 to 07, 09, 10 PASS on the 64-bit cluster. Not done: TC-11 (PMU), TC-12 (profiles 1/2), constrained-random test. / Chưa làm: TC-11, TC-12, test ngẫu nhiên.
- TC-01, 02, 03, 08 are RV32-specific and are not run in 64-bit mode. / Các TC này chỉ dành cho RV32.
- `build/`, `runs/`, waveforms (`*.vcd`), `*.log` and `trace_hart_*.dasm` are tool outputs and are ignored by Git; rerun to regenerate. / Output của tool, không commit.
- Tools: Verilator 5.053 and MSYS2 g++ at the paths set in `run.py` (`C:/Users/PC/Tools/...`); edit them on another machine. Verilator is 2-state, so X propagation is not checked. / Verilator 2 trạng thái, không kiểm X.
- Do not run several builds in parallel on a loaded machine: compilation can run out of memory. Use `--jobs 3`. / Tránh build song song để không hết bộ nhớ.
