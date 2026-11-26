# FPU warning closure / Hoàn tất sửa warning FPU

> **Documentation status / Trạng thái tài liệu:** This page records the named run or focused suite; earlier missing-core, timeout or unconnected-CMO statements are historical. Use the current HDS and dated audit for cluster status. / Trang này ghi lại lần chạy hoặc suite riêng; nhận định thiếu core, timeout hoặc CMO chưa nối của mốc cũ là lịch sử. Dùng HDS hiện tại và audit có ngày để xác định trạng thái cluster.

[Current cluster HDS / HDS cluster hiện tại](../../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Recorded audit / Báo cáo đã lưu](../post_a06_cluster_audit/README.md) · [Tensor specification / Đặc tả tensor](../../../doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md)

2026-11-15. Production TOP: `m_vlsit_riscv_cluster_axi_top`.

**EN:** Both FPU `UNOPTFLAT` diagnostics are removed by changing the RTL dependency structure. No FPU warning is disabled or waived; no suppression option or pragma was added. No pipeline register, port, arithmetic operation or configured latency was changed. Pristine upstream files remain untouched; licensed copies keep their original notices and dated modification history.

**VI:** Đã sửa cả hai warning FPU `UNOPTFLAT` bằng cách thay cấu trúc dependency RTL. Không tắt hoặc waive warning FPU, không thêm tùy chọn hay pragma suppression. Không thêm thanh ghi pipeline, không đổi port, phép toán hoặc latency cấu hình. Nguồn upstream giữ nguyên; bản sao sửa giữ license và history.

## Changes / Thay đổi

| RTL file | Cause and correction / Nguyên nhân và cách sửa |
|---|---|
| [`fpu_wrap.sv`](../../../rtl/common/modified/cva6/core/fpu_wrap.sv) | The original combinational FSM wrote READY-dependent control together with VALID and held-payload selection. Separate state-only selection into its own combinational process, retaining the default/illegal-state behavior. / Tách chọn VALID/payload theo state khỏi control phụ thuộc READY; giữ hành vi default/state không hợp lệ. |
| [`fpnew_opgroup_block.sv`](../../../rtl/common/modified/cvfpu/src/fpnew_opgroup_block.sv) | Merged formats read one bit of the same packed READY vector they drove. Drive first and aliased formats from the merged slice's scalar READY. Parallel and disabled format behavior remains unchanged. / Các format merged lấy READY trực tiếp từ output scalar của slice, bỏ đọc ngược vector; giữ nguyên format parallel và disabled. |

## Verification / Kiểm chứng

| Check | Result |
|---|---|
| FENCE.I native model generation, 2/4 harts | 0 errors, 0 warnings; runner now fails on any reported warning |
| Production TOP lint, 2/4 harts | 0 errors, 0 warnings; no latch or multiple-driver diagnostic |
| Real FENCE.I | Eight M/S-mode success/error/retry tests PASS; cause 24 after ABORT ACK; successful I-cache completion and new-code execution |
| Independent legacy FPU differential test | 1,600 scalar FP32/FP64 transactions PASS; results, flags, tags, handshake and latency compared every cycle |
| Continuous mixed-group/format stress | 256 issue attempts: 241 accepted, 15 canceled by flush; 1,415 held cycles and 15 flushes while held; cycle comparison PASS |

**VI:** Tám ca instruction FENCE.I thật ở 2/4 hart, M/S-mode đều pass. Model mô phỏng và lint TOP đều không còn warning. Test FPU so sánh từng chu kỳ với reference gốc độc lập, có STALL và flush thực sự được kích hoạt.

Evidence: [FPU comparison log](../../../verification/non_coherence_cluster/reports/fpu_warning_fix/wrap/simulation.log), [2-hart model](../../../verification/non_coherence_cluster/reports/fence_i_end_to_end/model_2h.log), [4-hart model](../../../verification/non_coherence_cluster/reports/fence_i_end_to_end/model_4h.log), [2-hart TOP lint](../../../lint/non_coherence_cluster/full_integration/top_lint_2h_20261115_165846.log), [4-hart TOP lint](../../../lint/non_coherence_cluster/full_integration/top_lint_4h_20261115_165846.log), [eight FENCE.I result records](../../../verification/non_coherence_cluster/reports/fence_i_end_to_end/results.json), [WF-019 VCD/JSON/SVG](../../verification/non_coherence_cluster/fence_i_end_to_end/waveforms_sim/waveform_compare.md).

## Replay / Chạy lại

```powershell
cd C:\HQuan\102_MyGithub\VLSIT_RISCV_CPU\rtl\verification\cmo_end_to_end
make fpu-warning-regression
```

The [single Makefile](../../../verification/non_coherence_cluster/cmo_end_to_end/Makefile) runs the FPU preservation check and full FENCE.I replay. [Runner details](../../verification/non_coherence_cluster/fpu_warning_fix/README.md). `run.py --harts 2 --model-only` in the FENCE.I test directory permits fast model-diagnostic checks without compiling C++. Each normal rebuild uses a fresh generated-source directory.

Makefile trên chạy kiểm tra bảo toàn FPU và toàn bộ regression FENCE.I. Tùy chọn `--model-only` chỉ tạo và kiểm tra model; build bình thường luôn dùng thư mục generated source mới.

## Source accounting / Danh sách nguồn

- `rtl/common/modified/cva6/core/fpu_wrap.sv`: 18 changed lines / 576 baseline lines.
- `rtl/common/modified/cvfpu/src/fpnew_opgroup_block.sv`: 11 changed lines / 256 baseline lines.

[Before snapshots](../../../verification/non_coherence_cluster/reports/fpu_warning_fix/before), [current source hashes](../../../verification/non_coherence_cluster/reports/fpu_warning_fix/changed_rtl.json). Other changed files: source override registry and generated filelists, FPU differential testbench, dedicated replay wrapper, FENCE.I runner, shared Makefile and READMEs. The generated CSR was not edited.

Snapshot trước sửa và hash nguồn hiện tại được lưu tại các liên kết trên. Các cập nhật khác gồm registry/filelist, testbench so sánh, runner, Makefile và README. Không sửa CSR generated.

## Rules and scope / Rule và phạm vi

R-001/R-014: native production-model diagnostics, full TOP lint and actual simulation evidence. R-008/R-018: authorized incremental fix with before snapshots and file accounting. R-003/R-011/R-016: native licensed coding style retained per user instruction; these upstream files are not restyled as VLSIT modules. R-023/R-048: existing specification-grounded FENCE.I cases rerun; differential FPU tests supplement them and explicitly check behavior preservation. R-047: directed checks only; no code coverage target or percentage was inferred. R-039/R-040: generated CSR unchanged.

EN: The untouched legacy reference still contains its original dependency structure and can report diagnostics during the comparison build. Those diagnostics are not production-model warnings; both native CPU models and TOP lint are checked separately. Prior CBO model logs with the old FPU diagnostics are retained under `before/` as historical evidence. Existing global tool options were not extended with FPU suppression. The FPU comparison is not an independent IEEE-754 reference or an ISA compliance campaign. FENCE.I test scope remains one dirty code line per hart, bare S-mode, reduced simulation LLC; full OS/Sv39, random coherence, synthesis, STA and PPA are outside this run.

VI: Reference gốc giữ dependency cũ nên build so sánh có thể còn diagnostic của reference; hai model CPU và lint TOP production được kiểm tra riêng. Log CBO cũ trong `before/` chỉ là bằng chứng lịch sử. Không thêm suppression FPU vào tùy chọn tool. Test tương đương chưa phải kiểm chứng IEEE-754 độc lập hoặc chiến dịch ISA compliance. Phạm vi FENCE.I vẫn là một code line dirty mỗi hart, S-mode bare và LLC mô phỏng giảm dung lượng; chưa signoff OS/Sv39, coherence ngẫu nhiên, synthesis, STA hay PPA.
