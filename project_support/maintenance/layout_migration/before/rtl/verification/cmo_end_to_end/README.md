# Real CBO instruction tests / Test instruction CBO thật

The bench boots production CVA6 harts and executes stores followed by CLEAN, FLUSH and INVAL. External AXI memory can return SLVERR to test precise CBO traps. No internal DUT completion is mocked.

Testbench khởi động CVA6 production, chạy store và ba CBO; memory AXI trả SLVERR tùy chọn để kiểm tra trap chính xác. Không giả lập completion nội bộ DUT.

Run `make focused`, then `make all` here. The [Makefile](Makefile) includes tests and lint for 2/4 harts. Python and tool paths are recorded in [the results report](../../reports/cmo_end_to_end/README.md).

Chạy các lệnh trên tại thư mục này. Báo cáo lưu kết quả, log, VCD, cấu hình tool và giới hạn kiểm chứng.
