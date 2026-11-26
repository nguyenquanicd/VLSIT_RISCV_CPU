# Native HPDcache flush change / Thay đổi flush HPDcache native

Run `python scripts/lint_hpdcache_flush.py` from the project root. This compiles the modified flush engine with the actual pinned HPDcache package, native request/response types, configuration constructor and common submodules. The harness uses a 128-bit line and a 64-bit memory path. It is elaboration/lint collateral, with no stimulus or blackbox. / Chạy lệnh trên để lint bản sửa với package, kiểu native và module con thực; line 128-bit, memory 64-bit. Harness chỉ phục vụ elaborate/lint, không có stimulus hoặc blackbox.

`source.json` records upstream revision and original/modified hashes. The original license/header is retained and a dated history names Quan Nguyen and Codex - VLSI Technology page. The upstream checkout is pristine. `rtl/modified/hpdcache/LICENSE` is copied unchanged. / Manifest lưu revision/hash; giữ nguyên license/header và thêm history đúng tác giả.

Implemented: retain allocation origin until the matching B; return non-OKAY status; check full response ID before indexing; consume/diagnose inactive, out-of-range or atomic-marked responses without releasing an unrelated entry. Matching success or failure retires the flush transport entry. / Đã lưu nguồn yêu cầu đến B, báo lỗi và kiểm tra ID đầy đủ; response không hợp lệ không làm mất entry khác.

The cache/probe owner must still preserve dirty data and MESI state across errors and COMMIT/ABORT. This patch does not implement MESI, line locking, array arbitration, the third allocation-source connection, or precise CVA6 retirement. Select exactly one `hpdcache_flush` definition in an integration filelist, and connect every added port before using this derivative with the native top. / Phần chủ cache/probe vẫn phải giữ dirty/MESI khi lỗi. Chưa hoàn tất MESI, khóa line, phân xử array, nối nguồn thứ ba hoặc retirement. Filelist tích hợp chỉ được chọn một định nghĩa flush và phải nối đủ port mới.

No simulation or full-cluster lint pass is claimed. See `lint_result.json`, `lint.log` and the standard source `filelist.f`. / Chưa mô phỏng hoặc lint thành công toàn cluster; xem kết quả và lệnh thực trong các file log.
