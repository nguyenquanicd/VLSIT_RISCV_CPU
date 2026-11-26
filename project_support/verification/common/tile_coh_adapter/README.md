# Tile Coherence Adapter Test

> **Documentation status / Trạng thái tài liệu:** This page records the named run or focused suite; earlier missing-core, timeout or unconnected-CMO statements are historical. Use the current HDS and dated audit for cluster status. / Trang này ghi lại lần chạy hoặc suite riêng; nhận định thiếu core, timeout hoặc CMO chưa nối của mốc cũ là lịch sử. Dùng HDS hiện tại và audit có ngày để xác định trạng thái cluster.

[Current cluster HDS / HDS cluster hiện tại](../../../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Recorded audit / Báo cáo đã lưu](../../../reports/post_a06_cluster_audit/README.md) · [Tensor specification / Đặc tả tensor](../../../../doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md)

This directed test exercises the elastic ownership request/grant channels and the PREPARE-to-terminal-response lock boundary of `m_vlsit_riscv_tile_coh_adapter`. It checks stable payloads during backpressure, a same-line busy-query stall, valid-qualified access/victim line observations, independent locks for two tags, rejection of a second tag aliasing a locked line, failed COMMIT retention, and per-tag ABORT/COMMIT release.

The test does not instantiate CVA6 or HPDcache arrays. It verifies the adapter contract only; it does not prove permission-before-refill or end-to-end coherence.

Run from this directory with `make lint` and `make sim`. `make sim` calls `build_and_run.ps1`, which invokes Verilator and compiles the generated C++ directly. This avoids depending on a separately installed GNU Make runtime for Verilator's generated build file. The default build directory is `C:/HQuan/.test_tmp/riscv_tile_coh_adapter`.

Latest result: lint passed with no diagnostics; simulation passed at 191 ns, including an invalid-line observation that must not alias a held lock. The simulation checks the adapter contract only.

## Kiểm thử adapter coherence tile

Test directed này kiểm tra kênh request/grant có đệm và phần khóa dòng từ PREPARE đến phản hồi kết thúc của `m_vlsit_riscv_tile_coh_adapter`. Test kiểm tra payload ổn định khi backpressure, stall do query cùng dòng, quan sát access/victim có valid, hai tag giữ hai line độc lập, từ chối tag khác xin line đã khóa, giữ khóa khi COMMIT lỗi và nhả đúng từng khóa sau ABORT/COMMIT.

Test không instantiate CVA6 hoặc mảng HPDcache. Nó chỉ kiểm tra hợp đồng adapter, chưa chứng minh permission-before-refill hay coherence toàn hệ thống.

Chạy `make lint` và `make sim` trong thư mục này. Lệnh `make sim` gọi `build_and_run.ps1`, dùng Verilator rồi biên dịch C++ sinh ra trực tiếp. Cách này không phụ thuộc runtime GNU Make riêng để xử lý build file do Verilator tạo. Thư mục build mặc định là `C:/HQuan/.test_tmp/riscv_tile_coh_adapter`.

Kết quả mới nhất: lint pass, không có diagnostic; mô phỏng pass tại 191 ns, gồm trường hợp địa chỉ không valid không được alias khóa đang giữ. Mô phỏng chỉ kiểm tra hợp đồng của adapter.
