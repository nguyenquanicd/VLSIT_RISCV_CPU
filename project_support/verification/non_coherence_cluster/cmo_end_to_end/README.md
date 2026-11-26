# Real CBO instruction tests / Test instruction CBO thật

> **Documentation status / Trạng thái tài liệu:** This page records the named run or focused suite; earlier missing-core, timeout or unconnected-CMO statements are historical. Use the current HDS and dated audit for cluster status. / Trang này ghi lại lần chạy hoặc suite riêng; nhận định thiếu core, timeout hoặc CMO chưa nối của mốc cũ là lịch sử. Dùng HDS hiện tại và audit có ngày để xác định trạng thái cluster.

[Current cluster HDS / HDS cluster hiện tại](../../../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Recorded audit / Báo cáo đã lưu](../../../reports/post_a06_cluster_audit/README.md) · [Tensor specification / Đặc tả tensor](../../../../doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md)

The bench boots production CVA6 harts and executes stores followed by CLEAN, FLUSH and INVAL. External AXI memory can return SLVERR to test precise CBO traps. No internal DUT completion is mocked.

Testbench khởi động CVA6 production, chạy store và ba CBO; memory AXI trả SLVERR tùy chọn để kiểm tra trap chính xác. Không giả lập completion nội bộ DUT.

Run `make focused`, then `make all` here. The [Makefile](../../../../verification/non_coherence_cluster/cmo_end_to_end/Makefile) includes tests and lint for 2/4 harts. Python and tool paths are recorded in [the results report](../../../reports/cmo_end_to_end/README.md).

Chạy các lệnh trên tại thư mục này. Báo cáo lưu kết quả, log, VCD, cấu hình tool và giới hạn kiểm chứng.
