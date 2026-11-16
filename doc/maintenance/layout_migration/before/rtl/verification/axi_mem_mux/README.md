# AXI4+ATOP memory mux test

## English

This directed Verilator test checks the four-source memory mux for both 2-hart and 4-hart configurations. It verifies hart-index ID extension, AWATOP preservation, write payload, B response routing, AR ID/address, R response routing, and masking of inactive hart slots.

Run from the repository root:

```powershell
python scripts\sim_axi_mem_mux.py
```

The runner lints both hart-count profiles and runs both simulations with the pinned PULP AXI mux and common-cell dependencies. Results and dependency hashes are under `rtl/reports/axi_mem_mux/`.

This tests the mux only. The mux is not yet connected to the LLC or cluster core; the LLC memory egress and full TOP remain incomplete.

## Tiếng Việt

Test directed Verilator kiểm tra mux memory bốn nguồn ở cấu hình 2 và 4 hart. Test xác minh ID có gắn chỉ số hart, giữ AWATOP, payload ghi, định tuyến B response, ID/địa chỉ AR, định tuyến R response và chặn cổng của hart không hoạt động.

Chạy từ thư mục gốc repository:

```powershell
python scripts\sim_axi_mem_mux.py
```

Runner lint cả hai cấu hình và mô phỏng với PULP AXI mux cùng common-cell dependencies đã pin. Kết quả và hash dependency nằm trong `rtl/reports/axi_mem_mux/`.

Test chỉ bao phủ mux. Mux chưa nối với LLC hoặc cluster core; memory egress qua LLC và TOP vẫn chưa hoàn thiện.
