# HPDcache Probe Engine Testbench

> **Documentation status / Trạng thái tài liệu:** This page records the named run or focused suite; earlier missing-core, timeout or unconnected-CMO statements are historical. Use the current HDS and dated audit for cluster status. / Trang này ghi lại lần chạy hoặc suite riêng; nhận định thiếu core, timeout hoặc CMO chưa nối của mốc cũ là lịch sử. Dùng HDS hiện tại và audit có ngày để xác định trạng thái cluster.

[Current cluster HDS / HDS cluster hiện tại](../../../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Recorded audit / Báo cáo đã lưu](../../../reports/post_a06_cluster_audit/README.md) · [Tensor specification / Đặc tả tensor](../../../../doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md)

This directed testbench verifies `m_vlsit_riscv_hpd_probe_engine` at its directory, flush, update, and tagged-response interfaces. It covers an absent-line invalidation, clean E-to-S commit, rejection of a COMMIT with a mismatched target followed by a valid ABORT, dirty M writeback and commit, failed-writeback ABORT recovery, and true invalidation without writeback. Probe responses, flush requests, and directory updates are checked for stability under backpressure.

The test models the directory, flush engine, and state-update sink. It does not instantiate HPDcache arrays or CVA6 and does not prove cluster-level coherence or AXI writeback behavior.

Run from this directory:

```sh
make lint
make sim
```

The simulation build enables Verilator's parallel C++ compilation mode so the generated makefile does not require the optional Python-based source includer. The default build output is under `C:/HQuan/.test_tmp/riscv_hpd_probe_engine`.

## Testbench HPDcache Probe Engine

Testbench directed này kiểm tra `m_vlsit_riscv_hpd_probe_engine` qua các giao diện directory, flush, update và tagged response. Các ca gồm invalidate line không tồn tại, commit E-to-S, từ chối COMMIT có target không khớp rồi ABORT hợp lệ, writeback và commit line M dirty, ABORT sau writeback lỗi, và invalidate thật không writeback. Test kiểm tra response probe, request flush và cập nhật directory ổn định khi bị backpressure.

Testbench mô hình hóa directory, flush engine và bộ nhận cập nhật state. Test không instantiate mảng HPDcache hoặc CVA6, nên không chứng minh coherence cấp cluster hay hành vi writeback AXI.

Chạy trong thư mục này bằng `make lint` và `make sim`.
