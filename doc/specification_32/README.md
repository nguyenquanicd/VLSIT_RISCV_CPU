# Đặc tả cluster CPU RISC-V 32-bit 2/4 core / RV32 cluster specification

Bản 32-bit (RV32) của cluster 2/4 core. Kiến trúc, coherence MESI, giao diện và bản đồ CSR giữ nguyên như bản 64-bit; chỉ đổi cấu hình core CVA6 và thêm bộ chuyển độ rộng trong CPU tile.

The RV32 profile of the dual/quad cluster. Architecture, MESI coherence, interfaces and CSR map are those of the 64-bit cluster; only the CVA6 configuration and the CPU tile adapter change.

| Tài liệu / Document | Nội dung / Content |
|---|---|
| [VLSIT_RISCV32_DUAL_QUAD_CPU_CLUSTER_HDS.md](VLSIT_RISCV32_DUAL_QUAD_CPU_CLUSTER_HDS.md) | Đặc tả (tiếng Anh): yêu cầu, cấu hình CVA6 đầy đủ từng field (mục 8.2), độ rộng suy ra (mục 8.3), thay đổi RTL (mục 14), kế hoạch verify (mục 15) |
| [figures/m_vlsit_riscv_cpu_tile_rv32.svg](figures/m_vlsit_riscv_cpu_tile_rv32.svg) | Sơ đồ CPU tile RV32 / RV32 tile diagram |
| [Đặc tả 64-bit gốc / Base 64-bit HDS](../specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) | Chuẩn cho mọi phần không đổi / Normative for everything unchanged |

## Cấu hình tóm tắt / Configuration summary

| Tham số / Field | 64-bit | RV32 |
|---|---|---|
| XLEN / VLEN | 64 / 64 | **32 / 32** |
| PLEN, bộ nhớ ảo / virtual memory | 56, Sv39 | 34, Sv32 (tự suy ra / derived) |
| RVD | 1 | **0** (F only, ABI ilp32f) |
| AxiUserWidth | 64 (= XLEN) | 64 (**ghim / pinned**) |
| AXI address / data / ID | 64 / 64 / 4 | 64 / 64 / 4 (không đổi / unchanged) |
| Cache, TLB, PMP, RVA, RVS, RVU, MMU, ZKN, PerfCounterEn | như bản 64-bit / as 64-bit | không đổi / unchanged |

| Bộ chia/căn FPU / FPU divide-sqrt | C910 64-bit | C910 64-bit, toán hạng FP32 được NaN-box bằng bit 1 (**DEC-106**, mục 14.5) |

## Sửa bộ chia FPU (DEC-106, 2026-11-26) / FPU divider fix

- **Lỗi:** TC-03 cho FDIV.S và FSQRT.S trả về NaN chuẩn `7FC00000` ở mọi phép.
- **Nguyên nhân:** khi FLEN=32, wrapper `fpnew_divsqrt_th_64_multi` mở rộng toán hạng FP32 lên 64 bit bằng **bit 0**. Bộ chia C910 theo quy tắc NaN-boxing của RISC-V: giá trị single chỉ hợp lệ khi bit 63:32 toàn 1 (`ct_vfdsu_prepare.v:330-331, 370-377`). Vì vậy mọi toán hạng bị coi là NaN. Bản 64-bit không bị vì ở đó WIDTH=64 nên không có đoạn mở rộng.
- **Cách sửa:** sửa trong bản sao `rtl/rv32_profile/cvfpu/fpnew_divsqrt_th_64_multi.sv` (chỉ bản RV32 dùng), đổi phần mở rộng sang **bit 1** ở 2 đầu vào toán hạng. File gốc của bản 64-bit không đổi.
- **Vì sao chọn cách này:** đây đúng là dạng toán hạng mà bộ chia yêu cầu. Thay đổi không thêm logic, thanh ghi hay độ trễ, giữ nguyên bộ chia như bản 64-bit, và không ảnh hưởng bản 64-bit.
- **Các phương án đã loại:** bộ chia TH32 (khác unit, phải làm lại timing và verify) và RVD=1 (đảo ngược DEC-102, tốn diện tích).
- **Kết quả:** TC-01 đến TC-10 PASS với 2 hart. TC-03 PASS với 4 hart. Lỗi cố ý số 7 bị phát hiện.

**Failure:** TC-03 returned the canonical NaN for every FDIV.S/FSQRT.S. **Root cause:** with FLEN=32 the operands reached the C910 divider zero-extended, but the unit requires bits 63:32 all ones (NaN boxing). **Fix:** extend with ones in an RV32-only copy of the wrapper. **Why:** it is the unit's input contract, adds no logic, keeps the 64-bit build unchanged. Details: HDS Section 14.5.

## Sửa deadlock của cluster dùng chung (DEC-107/108, 2026-11-27) / Shared-cluster deadlock fixes

TC-07 với 4 hart treo trên cả bản RV32 lẫn bản 64-bit. Nguyên nhân là ba lỗi trong phần cluster dùng chung, không phải do bản RV32. Cả ba đã được sửa và merge vào `rtl/common/`, và filelist RV32 dùng trực tiếp các file này (chi tiết ở mục 14.7 của spec 64-bit).

1. **`hpdcache.sv` / `hpdcache_ctrl.sv`:** AMO chỉ nhận quyền atomic sau grant E/M. Lý do: khi chỉ có S, AMO vẫn phải xin quyền unique, mà yêu cầu đó chờ sau chính probe nó đang chặn.
2. **`hpdcache_rtab.sv`:** fence giữ mức 1 khi còn entry AMO, uncached hoặc CMO. Lý do: một lệnh load cùng dòng chen vào sau AMO làm AMO không bao giờ rời hàng đợi.
3. **`m_vlsit_riscv_coh_fabric.sv`:** context chỉ rời DIR_UPDATE/DIR_CANCEL khi handshake mang đúng tag. Lý do: một handshake hoàn tất cả hai context, context thứ hai mất update directory và để lại reservation làm FENCE.I bị chặn.

Three shared-cluster defects caused the 4-hart TC-07 hang on both profiles; all three are fixed and merged into `rtl/common/` (REF-001 Section 14.7).

Trạng thái: bản nháp 0.4. RTL ở `rtl/rv32_profile/`, dùng các file cluster đã sửa trong `rtl/common/` (DEC-046/047 của spec 64-bit). Lint sạch. Mô phỏng directed: TC-01 đến TC-10 PASS với cả 2 và 4 hart. / Status: draft 0.4; RTL in `rtl/rv32_profile/` using the fixed shared files in `rtl/common/` (REF-001 DEC-046/047); lint clean; TC-01 to TC-10 PASS with 2 and 4 harts.
