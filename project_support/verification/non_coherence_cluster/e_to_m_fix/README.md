# Silent E→M regression / Regression E→M cục bộ

> **Documentation status / Trạng thái tài liệu:** This page records the named run or focused suite; earlier missing-core, timeout or unconnected-CMO statements are historical. Use the current HDS and dated audit for cluster status. / Trang này ghi lại lần chạy hoặc suite riêng; nhận định thiếu core, timeout hoặc CMO chưa nối của mốc cũ là lịch sử. Dùng HDS hiện tại và audit có ngày để xác định trạng thái cluster.

[Current cluster HDS / HDS cluster hiện tại](../../../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Recorded audit / Báo cáo đã lưu](../../../reports/post_a06_cluster_audit/README.md) · [Tensor specification / Đặc tả tensor](../../../../doc/tensor_coprocessor/VLSIT_TENSOR_COPROCESSOR_HDS.md)

EN: Tests the legal local-store transition when the directory still records exclusive E permission. The CCU must accept M only from the unique recorded E owner, wait for dirty writeback, retain actual PREPARE state for ABORT, and retain strict tag/line/phase/holder/state checks. The unit test includes the original clean-E/MESI/PMU scenarios, successful E→M sharing, missing-writeback rejection, B-error ABORT retaining M, retry and invalid E→S rejection. Unit configuration is four harts; real CPU tests cover both 2 and 4.

VI: Kiểm tra store cục bộ làm cache chuyển E→M trong khi directory vẫn ghi quyền E. CCU chỉ chấp nhận refinement từ owner E duy nhất, chờ dirty writeback và giữ state PREPARE thực cho ABORT. Vẫn kiểm tra tag/line/phase/holder/state. Test unit có cả clean E, E→M sharing, từ chối thiếu writeback, lỗi B→ABORT giữ M, retry và từ chối E→S không hợp lệ. Unit dùng bốn hart; test CPU thật dùng cả 2/4 hart.

```powershell
cd C:\HQuan\102_MyGithub\VLSIT_RISCV_CPU\rtl\verification\cmo_end_to_end
make e-to-m-regression
```

The shared Makefile runs the unit checks, LOAD→STORE→CBO success/error at 2/4 harts, baseline CBO, eight real FENCE.I cases, production TOP lint and waveform collection. Code coverage was not requested. Sources and logs are retained under `verification/non_coherence_cluster/reports/e_to_m_fix`, `cluster_completeness_audit`, `cmo_end_to_end` and `fence_i_end_to_end`.

Makefile dùng chung chạy unit, LOAD→STORE→CBO thành công/lỗi ở 2/4 hart, CBO gốc, tám ca FENCE.I thật, lint TOP và thu waveform. Không đo code coverage. Source và log lưu trong các thư mục báo cáo tương ứng.
