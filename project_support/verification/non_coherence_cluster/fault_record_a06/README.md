# Fault record tests / Kiểm thử fault record

> **Documentation status / Trạng thái tài liệu:** This page records the named run or focused suite; earlier missing-core, timeout or unconnected-CMO statements are historical. Use the current HDS and dated audit for cluster status. / Trang này ghi lại lần chạy hoặc suite riêng; nhận định thiếu core, timeout hoặc CMO chưa nối của mốc cũ là lịch sử. Dùng HDS hiện tại và audit có ngày để xác định trạng thái cluster.

[Current cluster HDS / HDS cluster hiện tại](../../../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Recorded audit / Báo cáo đã lưu](../../../reports/post_a06_cluster_audit/README.md) · [Tensor specification / Đặc tả tensor](../../../../doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md)

`tb_fault_record.sv`: independent packed-word oracle for DEC-039/040, all active harts, SLVERR/DECERR, high addresses, simultaneous/later events, hold/multiple/reset. Sampled VCD records real outputs two nanoseconds after rising edges.

`tb_fault_map.sv`: independent endpoint cookies check six 4-KiB groups, untruncated CSR offsets, translated LLC offsets, upper aperture boundary, maximum legal/invalid base and 20 activated AXI4-Lite properties.

`tb_fault_record_cpu.sv`: native 2/4 CVA6 harts and production cluster TOP. RV64 programs create ordinary dirty L1/LLC evictions. Errors enter via the verification-only AXI endpoint/memory BFM. The external AXI4-Lite master reads actual generated CSR and checks exact first-fatal words, RO protection, reserved words, W1C independence and reset. There are 20 required checks at each native AXI, memory AXI and AXI4-Lite boundary. L1 recovery includes genuine CBO cleans for external write-channel activation. `--reverse` buffers the initial independent-ID B responses and delivers the highest hart first, proving nonzero hart identity while preserving per-ID order and payload stability.

VI: Unit dùng golden độc lập; CPU test chạy lệnh thật qua cache/CCU/LLC và đọc CSR từ cổng ngoài. Fault chỉ đến từ AXI, không force state hoặc giả completion. Cần đủ assertion activation. Reverse kiểm tra record của hart 1/3, không suy ra hart LLC từ một writer không xác định.

All commands are in the existing [Makefile](../../../../verification/non_coherence_cluster/cmo_end_to_end/Makefile):

```sh
make fault-regression
```

`run_regression.py` replays the full A-03/A-04/A-05/AMO/CBO/FENCE.I baseline, then five fault-record scenarios per hart count. CPU `--run-only` requires an exact production/bench/image fingerprint. `generate_cluster_fault_csr.py` verifies generated provenance by default and regenerates only when explicitly requested. [Reports and scope](../../../reports/fault_record_a06/README.md). Build artifacts stay under `C:/HQuan/.test_tmp`; checked-in source/images/logs permit replay.

VI: Makefile chung chứa cả lệnh sinh/kiểm tra CSR và regression. Chỉ tái dùng CPU binary khi hash khớp; generated RTL không sửa tay. Chưa đo code coverage.
