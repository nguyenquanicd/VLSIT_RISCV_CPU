# Full-hierarchy behavior closure / Chốt hành vi toàn hierarchy

Status: both decisions below are closed. Q1 is recorded as HDS DEC-037 and Q2 as DEC-036. This file records selected behavior and remaining implementation work; it is not a full-RTL completion or lint-pass report. / Trạng thái: hai quyết định dưới đây đã được chốt. Q1 được ghi trong HDS DEC-037, Q2 trong DEC-036. File ghi lại hành vi đã chọn và phần triển khai còn thiếu; đây không phải báo cáo hoàn tất RTL hay lint pass.

## 1. Shared address table for PMA and routing / Bảng địa chỉ chung cho PMA và định tuyến

Selected contract (DEC-037): one synthesis-time parameter table is the source for both per-hart CVA6 PMA generation and the cluster AXI router. The default entry preserves the selected CVA6 cacheable range `0x80000000..0xBFFFFFFF`. Integrators may add normal-uncached and MMIO entries; no boot-ROM or peripheral address is inferred from executable permission. The table has up to 16 entries. Class `00` is cacheable, `01` is normal uncached, `10` is MMIO, and `11` is reserved. Cacheable traffic uses the CCU/LLC memory route; normal-uncached traffic bypasses LLC allocation to the memory route; MMIO uses the MMIO route. Unmatched, malformed, and unsupported MMIO atomic/exclusive transactions return a local access error without issuing an external request. Parameter-table validity must be checked by the SoC build because the decoder's `o_config_valid` does not guarantee an elaboration-time failure.

Quyết định đã chọn (DEC-037): một bảng parameter compile-time là nguồn chung để tạo PMA cho từng hart CVA6 và định tuyến AXI của cluster. Entry mặc định giữ vùng cacheable CVA6 `0x80000000..0xBFFFFFFF`. Tích hợp SoC có thể thêm vùng normal-uncached và MMIO; không suy ra boot ROM hay địa chỉ ngoại vi từ quyền execute. Bảng có tối đa 16 entry. Class `00` là cacheable, `01` là normal-uncached, `10` là MMIO, `11` dành riêng. Cacheable đi qua CCU/LLC đến memory; normal-uncached bypass cấp phát LLC nhưng vẫn đi memory; MMIO đi cổng MMIO. Địa chỉ không khớp, transaction sai hoặc atomic/exclusive MMIO không hỗ trợ được trả lỗi cục bộ, không phát request ra ngoài. SoC build phải kiểm tra tính hợp lệ bảng vì `o_config_valid` không bảo đảm lỗi elaboration.

## 2. Ordinary dirty-eviction failure / Lỗi eviction dirty thông thường

Selected contract (DEC-036): a late ordinary dirty-writeback failure raises sticky `o_int_fault` and retains a CSR fault record; issued AXI responses still drain. Recovery is reset. The design does not fabricate success, retry automatically, or convert an already retired store into a synchronous exception. The protected victim/writeback retention and CSR fault-record path are not yet implemented, so this behavior is a selected requirement, not a verified implementation.

Quyết định đã chọn (DEC-036): lỗi writeback dirty phát hiện muộn tạo `o_int_fault` sticky và lưu fault record trong CSR; response AXI đã phát vẫn phải được drain. Khôi phục bằng reset. Thiết kế không báo thành công giả, không tự retry và không biến store đã retire thành exception đồng bộ. Vùng lưu victim/writeback được bảo vệ và đường CSR fault record chưa được triển khai; đây là yêu cầu đã chốt, chưa phải hành vi đã kiểm chứng.

## 3. Current integration boundary / Ranh giới tích hợp hiện tại

The address decoder, per-tile PMA adapter, and AXI route leaf exist, but the route is not connected through the missing `m_vlsit_riscv_cluster_core`. The TOP filelist therefore cannot elaborate the cluster. Current evidence and known blockers are listed in `README.md` in this report directory.

Bộ giải mã địa chỉ, adapter PMA từng tile và leaf định tuyến AXI đã có, nhưng chưa nối qua `m_vlsit_riscv_cluster_core` còn thiếu. Filelist TOP chưa thể elaborate cluster. Bằng chứng hiện có và blocker được ghi trong `README.md` cùng thư mục report.
