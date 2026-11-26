# Shared address-table AXI route test

> **Documentation status / Trạng thái tài liệu:** This page records the named run or focused suite; earlier missing-core, timeout or unconnected-CMO statements are historical. Use the current HDS and dated audit for cluster status. / Trang này ghi lại lần chạy hoặc suite riêng; nhận định thiếu core, timeout hoặc CMO chưa nối của mốc cũ là lịch sử. Dùng HDS hiện tại và audit có ngày để xác định trạng thái cluster.

[Current cluster HDS / HDS cluster hiện tại](../../../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Recorded audit / Báo cáo đã lưu](../../../reports/post_a06_cluster_audit/README.md) · [Tensor specification / Đặc tả tensor](../../../../doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md)

## English

This directed simulation connects `m_vlsit_riscv_addr_decode` to `m_vlsit_riscv_axi_route`. It checks that AW and AR traffic classified as cacheable or normal-uncached selects the memory path, while MMIO selects the peripheral path. It also checks the normal-uncached route-class sideband.

Run from the repository root:

```powershell
python scripts\sim_axi_region_route.py
```

The runner also executes the route-leaf lint matrix at `MaxTrans=1, 8, 32`. The simulation tests route selection under downstream backpressure; it does not cover local DECERR completion, full burst protocol behavior, or integration through the cluster core.

## Tiếng Việt

Mô phỏng directed nối `m_vlsit_riscv_addr_decode` với `m_vlsit_riscv_axi_route`. Test xác minh AW/AR được phân loại cacheable hoặc normal-uncached đi tới memory path; MMIO đi tới peripheral path. Test cũng kiểm tra sideband route-class của normal-uncached.

Chạy từ thư mục gốc repository:

```powershell
python scripts\sim_axi_region_route.py
```

Runner chạy thêm lint route leaf tại `MaxTrans=1, 8, 32`. Mô phỏng kiểm tra lựa chọn route khi downstream bị backpressure; chưa bao gồm hoàn tất local DECERR, đầy đủ burst protocol hoặc tích hợp qua cluster core.
