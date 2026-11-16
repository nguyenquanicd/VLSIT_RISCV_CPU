# HPDcache ownership and refill test

## English

This directed simulation instantiates the configured, modified HPDcache, including its cache directory/data arrays and miss handler. It covers:

1. A cold cacheable load requests shared ownership. Refill `AR` remains blocked until the matching line/ID grant arrives; the test then checks the refill ID and cache-line alignment.
2. A store to the clean Shared write-back line invalidates and replays. The replay requests exclusive ownership, and its refill remains blocked until the matching `M` grant.

Run from the repository root:

```powershell
python scripts\sim_modified_hpdcache_ownership.py
```

The runner checks configured HPDcache lint and testbench lint, then builds and runs the test with Verilator. It invokes the C++ compiler directly, so GNU make is not required. The test harness disables ECC and ECC scrubbing, matching the existing query-lint configuration.

Result: **PASS** with Verilator 5.053 on 2026-11-14. Lint reports 0 errors and 131 warnings for the configured HPDcache. Logs (`tb_lint.log`, `verilator.log`, `compile.log`, `simulation.log`, `result.json`) and a copy of the testbench source are in `verification/common/reports/hpdcache_ownership_sim/`.

This is a cache-level directed test, not a CVA6, CCU, LLC, or cluster regression. It does not yet test denied/mismatched grants, concurrent misses, probe races, dirty-owner writeback, or end-to-end coherence.

## Tiếng Việt

Mô phỏng directed này instantiate HPDcache đã cấu hình và sửa đổi, gồm mảng directory/data và miss handler. Test bao gồm:

1. Load cacheable khi cache lạnh xin quyền shared. Refill `AR` bị chặn đến khi grant khớp line/ID; sau đó test kiểm tra ID refill và địa chỉ căn theo cache line.
2. Store lên line write-back Shared sạch thực hiện invalidate rồi replay. Replay xin quyền exclusive; refill tiếp tục bị chặn đến khi nhận grant `M` khớp.

Chạy từ thư mục gốc repository:

```powershell
python scripts\sim_modified_hpdcache_ownership.py
```

Script chạy lint HPDcache cấu hình và lint testbench, sau đó build và mô phỏng bằng Verilator. Script gọi trực tiếp C++ compiler nên không cần GNU make. Harness tắt ECC và ECC scrub giống cấu hình query-lint hiện tại.

Kết quả: **PASS** với Verilator 5.053 ngày 2026-11-14. Lint HPDcache cấu hình có 0 lỗi và 131 cảnh báo. Log (`tb_lint.log`, `verilator.log`, `compile.log`, `simulation.log`, `result.json`) và bản sao source testbench nằm ở `verification/common/reports/hpdcache_ownership_sim/`.

Đây là test directed ở mức cache, chưa phải regression CVA6, CCU, LLC hay cluster. Test chưa bao gồm grant bị từ chối/sai, miss đồng thời, race probe, writeback owner dirty hoặc coherence đầu-cuối.
