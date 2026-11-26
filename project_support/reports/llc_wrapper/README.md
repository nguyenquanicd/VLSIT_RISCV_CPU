# LLC wrapper compile check / Kiểm tra biên dịch wrapper LLC

> **Documentation status / Trạng thái tài liệu:** This page records the named run or focused suite; earlier missing-core, timeout or unconnected-CMO statements are historical. Use the current HDS and dated audit for cluster status. / Trang này ghi lại lần chạy hoặc suite riêng; nhận định thiếu core, timeout hoặc CMO chưa nối của mốc cũ là lịch sử. Dùng HDS hiện tại và audit có ngày để xác định trạng thái cluster.

[Current cluster HDS / HDS cluster hiện tại](../../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Recorded audit / Báo cáo đã lưu](../post_a06_cluster_audit/README.md) · [Tensor specification / Đặc tả tensor](../../../doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md)

## Scope / Phạm vi

The filelist uses the lockfile-pinned PULP dependencies and elaborates `m_vlsit_axi_llc` with the upstream LLC. It checks source compatibility and packed-port widths. It does not simulate cache behavior, verify per-line CMO, or prove cluster integration. / Filelist dùng các dependency PULP đúng revision trong lockfile và elaborate `m_vlsit_axi_llc` cùng LLC upstream. Kiểm tra này xác nhận tương thích source và độ rộng packed-port; không mô phỏng hành vi cache, CMO từng line hay tích hợp cluster.

## Run / Chạy

Run from the project root:

```powershell
C:\Tools\oss-cad-suite\bin\verilator_bin.exe --lint-only --timing --timescale 1ns/1ps -Wno-fatal -Wno-TIMESCALEMOD --top-module m_vlsit_axi_llc -f rtl/common/filelists/llc_wrapper/filelist.f
```

## Result / Kết quả

On 2026-11-15, Verilator 5.053 elaborated 223 dependency files plus the wrapper: 0 errors and 70 upstream warnings. The wrapper has no Verilator warning. The VLSIT checker reports 0 errors and one intentional HIE-02 warning because the wrapper contains packed-port conversion and the LLC instance. Logs are in `llc_wrapper_lint.log`; source revisions are listed in `project_support/third_party/README.md`. / Ngày 2026-11-15, Verilator 5.053 elaborate 223 file dependency cộng wrapper: 0 lỗi và 70 cảnh báo upstream. Wrapper không có cảnh báo Verilator. VLSIT checker báo 0 lỗi và một cảnh báo HIE-02 có chủ ý vì wrapper vừa chuyển packed-port vừa chứa instance LLC. Log ở `llc_wrapper_lint.log`; revision source nằm trong `project_support/third_party/README.md`.
