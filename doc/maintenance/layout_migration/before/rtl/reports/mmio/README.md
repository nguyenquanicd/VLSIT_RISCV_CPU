# MMIO integration evidence / Bằng chứng tích hợp MMIO

Run from the project root / Chạy từ thư mục gốc:

```powershell
python scripts/lint_cluster_mmio.py
```

The script compiles the real PULP AXI mux, ID prepend, and Common Cells dependency closure for `PARA_CPU_NUM=2` and `4`. It saves commands, full lint output, compile filelist, and source SHA-256 values. This is lint evidence, not simulation or functional verification. / Script lint wrapper cùng các source PULP thực cho 2 và 4 hart, lưu lệnh, log, filelist và SHA-256. Đây là bằng chứng lint; chưa phải mô phỏng hoặc kiểm chứng chức năng.

Common Cells is checked out at `db42769334b4589b4b3fc671b34513bdb98be565`, matching `rtl/third_party/axi/Bender.lock`. Its original files and license headers are preserved. CVFPU was also cloned separately at `3eb6afeab2cb33f7d8689222955d0171aeb3a801`, matching the selected CVA6 gitlink; full CVA6 lint has not been run in this continuation. / Common Cells đúng revision trong lockfile AXI; CVFPU đúng gitlink CVA6. Giữ nguyên source/license upstream. Chưa chạy lint toàn CVA6 trong lần tiếp tục này.

Both MMIO configurations have zero lint errors and 25 warnings: unused upstream signals/parameters, empty upstream connections, missing upstream timescales, the second module name in `axi_mux.sv`, an upstream assertion width, and reset use in upstream assertions. Inspect the full logs before signoff. The VLSIT mechanical rule check has zero errors and one intentional HIE-02 warning for the functional wrapper.

Cả hai cấu hình MMIO có 0 lỗi lint và 25 cảnh báo liên quan source upstream hoặc reset dùng trong assertion upstream. Xem đầy đủ log trước signoff. Rule check VLSIT có 0 lỗi và một cảnh báo HIE-02 có giải thích trong header.

The old CVA6-vendored `common_cells/src/lzc.sv` contains a restrictive reuse/redistribution notice. It is excluded from this MMIO source set. This does not resolve the license review of the complete CVA6 dependency tree. / File `lzc.sv` cũ trong vendor CVA6 có thông báo hạn chế reuse/phân phối; không dùng file đó trong source set MMIO. Vẫn cần rà soát license toàn bộ dependency CVA6.

The cluster top is currently a structural shell. Missing implementation includes cluster core/tile integration, MESI HPDcache modifications, the CCU fabric, CMO retirement/error propagation, and LLC per-line maintenance. Do not use the shell as a complete CPU cluster. / TOP hiện là khung structural. Còn thiếu tích hợp core/tile, sửa HPDcache MESI, CCU fabric, CMO/retirement/error và maintenance LLC từng line; chưa phải cluster hoàn chỉnh.
