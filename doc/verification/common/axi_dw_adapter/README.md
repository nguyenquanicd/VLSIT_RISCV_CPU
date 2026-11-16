# AXI data-width adapter test / Kiểm thử adapter đổi độ rộng AXI

## English

This directed Verilator test checks `m_vlsit_riscv_axi_dw_adapter`, which converts the LLC's fixed 64-bit AXI4+ATOP port to a synthesis-time external width of 32, 64, 128, or 256 bits. It wraps the pinned PULP `axi_dw_converter`; upstream files and license notices remain unchanged.

Run from the repository root:

```powershell
python scripts/sim_axi_dw_adapter.py
```

Lint and simulation pass for all four widths. The test checks the 64-to-32 two-beat write conversion, wide-bus WDATA/WSTRB placement, AW/AR address/size/length behavior, AWATOP preservation, and B/R ID and SLVERR propagation. Read payload reconstruction is checked for all widths, including two-beat 32-bit input and 128/256-bit wide responses. The 128/256-bit data checks use an aligned 64-bit transfer within one wide beat; they do not check multiple narrow transfers coalesced into one wide beat. This is a leaf test and does not establish LLC-to-SoC integration.

The reused PULP converter fully supports INCR bursts. It passes FIXED bursts unchanged when upsizing and only supports single-beat FIXED when downsizing. WRAP is unsupported and returns SLVERR, except for the converter's tolerated single-beat upsize case. Integrators must constrain LLC traffic to supported burst forms.

Rule report: `doc/reports/axi_dw_adapter/rule_report.md`. Per-width lint and simulation logs: `verification/common/reports/axi_dw_adapter/`. The structural TOP instantiates this adapter; LLC and cluster-core integration remain open.

## Tiếng Việt

Test directed bằng Verilator kiểm tra `m_vlsit_riscv_axi_dw_adapter`, chuyển cổng AXI4+ATOP 64-bit cố định của LLC sang bus ngoài 32, 64, 128 hoặc 256 bit tại thời điểm tổng hợp. Module bọc PULP `axi_dw_converter` đã pin; source upstream và thông báo license được giữ nguyên.

Chạy từ thư mục gốc repository:

```powershell
python scripts/sim_axi_dw_adapter.py
```

Lint và mô phỏng pass ở cả bốn độ rộng. Test kiểm tra ghi 64→32 thành hai beat, vị trí WDATA/WSTRB trên bus rộng, địa chỉ/size/length AW/AR, giữ AWATOP, ID B/R và truyền SLVERR. Test kiểm tra khôi phục payload đọc ở cả bốn độ rộng, gồm hai beat 32-bit và response rộng 128/256-bit. Với 128/256-bit, dữ liệu là một transfer 64-bit căn hàng trong một beat rộng; chưa kiểm tra gộp nhiều transfer hẹp thành một beat rộng. Đây là test leaf, chưa xác nhận tích hợp từ LLC tới SoC.

PULP converter hỗ trợ đầy đủ burst INCR. Khi upsize, FIXED được giữ nguyên; khi downsize, FIXED chỉ hỗ trợ một beat. WRAP không được hỗ trợ và trả SLVERR, ngoại trừ trường hợp upsize một beat mà converter cho phép. Tích hợp cần giới hạn burst LLC theo dạng được hỗ trợ.

Rule report: `doc/reports/axi_dw_adapter/rule_report.md`. Log lint/mô phỏng từng độ rộng: `verification/common/reports/axi_dw_adapter/`. TOP cấu trúc đã instantiate adapter; tích hợp LLC và cluster core vẫn còn mở.
