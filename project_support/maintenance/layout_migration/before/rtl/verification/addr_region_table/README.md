# Address-region table test

## English

This directed Verilator test checks the compile-time table consumed by address classification and then used by the tile AXI router. It covers cacheable, normal-uncached, MMIO, unmapped, access-boundary, zero-length, MMIO atomic, and overlapping-table cases.

Run from the repository root:

```powershell
python scripts\sim_addr_region_table.py
```

The runner performs Verilator lint, builds the testbench, and runs the simulation. Logs and `result.json` are written to `rtl/reports/addr_region_table/`.

This is a leaf test of the region classifier. It does not instantiate CVA6 PMA generation or `m_vlsit_riscv_axi_route`; end-to-end proof that PMA and router use identical table parameters remains part of cluster integration.

## Tiếng Việt

Test directed bằng Verilator kiểm tra bảng vùng địa chỉ cấu hình trước synthesis, được dùng để phân loại địa chỉ và cung cấp metadata cho AXI router của tile. Test bao gồm cacheable, normal-uncached, MMIO, unmapped, truy cập cắt ranh giới, độ dài bằng 0, atomic vào MMIO và bảng vùng bị chồng lấn.

Chạy từ thư mục gốc repository:

```powershell
python scripts\sim_addr_region_table.py
```

Runner chạy lint Verilator, build testbench và mô phỏng. Log cùng `result.json` nằm trong `rtl/reports/addr_region_table/`.

Đây là test riêng của address classifier. Test chưa instantiate quá trình tạo PMA trong CVA6 hoặc `m_vlsit_riscv_axi_route`; cần tích hợp cluster để chứng minh PMA và router nhận cùng một bộ parameter.
