# Third-party sources / Nguồn third-party

Pinned upstream snapshots support reuse, local modification and interface comparison. The selected CVA6/HPDcache baseline and dependencies are recorded in [source provenance](../../doc/specification/references/THIRD_PARTY_SOURCES.md).

Các snapshot upstream được pin để tái sử dụng, sửa cục bộ hoặc đối chiếu giao tiếp. Revision được chọn cho CVA6/HPDcache và dependency nằm trong tài liệu nguồn gốc mã.

| Repository / Nguồn | Revision | License / Giấy phép |
|---|---|---|
| [OpenHW CVA6](https://github.com/openhwfoundation/cva6) | `742dc82a0c706e0a3bfb98b709fd3ee06d50d12a` | Solderpad Hardware License 0.51; individual RTL files may declare another applicable license. |
| [OpenHW HPDcache](https://github.com/openhwfoundation/cv-hpdcache) | `40d2897eda70644df2eb857efd9fa573eaacafab` | Solderpad Hardware License 2.1; retain each file's SPDX/header notices. |
| [PULP Culsans](https://github.com/pulp-platform/culsans) | `a3d741600d03bba2f21b795eda4f6faf7124a152` | Solderpad Hardware License 0.51. Its `.gitmodules` points to the PlanV CVA6 and LLC forks. |
| [PlanV CVA6 pinned by Culsans](https://github.com/planvtech/cva6) | `338d4c1e8df55363a57ac3e936ffc6ce86e7e016` | Solderpad Hardware License 0.51; cloned for interface comparison, not selected as the RTL baseline. |
| [PULP AXI, cluster-shared snapshot](https://github.com/pulp-platform/axi) | `d436bd4936ba1c49cd87521df54580c5159114d3` | Solderpad Hardware License 0.51. |
| [PULP AXI, axi_llc lockfile snapshot](https://github.com/pulp-platform/axi) | `a8c53cee2520d328d390c507c88818e8ac144c8c` | Solderpad Hardware License 0.51; standalone checkout at `axi_llc_locked/axi`. |
| [PULP common_cells, axi_llc lockfile snapshot](https://github.com/pulp-platform/common_cells) | `9ca8a7655f741e7dd5736669a20a301325194c28` | Solderpad Hardware License 0.51; standalone checkout at `axi_llc_locked/common_cells`. |
| [PULP AXI LLC](https://github.com/pulp-platform/axi_llc) | `31059c4be62985f81bc46138f09e442d996aa3f3` | Solderpad Hardware License 0.51. |
| [PULP ACE](https://github.com/pulp-platform/ace) | `f919f5cabf41961321bf37327ab4eb726dfdbd0c` | Solderpad Hardware License 0.51. |
| [PULP register_interface](https://github.com/pulp-platform/register_interface) | `d6e1d4cdaab7870f4faf3f88a1c788eaf5ac129d` | Solderpad Hardware License 0.51. Transitive dependency of `axi_llc`; cloned from its lockfile. |
| [PULP tech_cells_generic](https://github.com/pulp-platform/tech_cells_generic) | `7968dd6e6180df2c644636bc6d2908a49f2190cf` | Solderpad Hardware License 0.51. Transitive dependency of `axi_llc`; provides generic SRAM cells. |
| [PULP common_verification](https://github.com/pulp-platform/common_verification) | `fb1885f48ea46164a10568aeff51884389f67ae3` | Solderpad Hardware License 0.51. Transitive dependency of `axi_llc` and its support libraries. |
| [PULP APB](https://github.com/pulp-platform/apb) | `77ddf073f194d44b9119949d2421be59789e69ae` | Solderpad Hardware License 0.51. Transitive dependency of `register_interface`. |

## Source layout and status / Cấu trúc source và trạng thái

- [Pristine RTL / RTL nguyên bản](../../rtl/common/third_party/) · [Licensed modifications / Bản sửa giữ license](../../rtl/common/modified/) · [New VLSIT RTL / RTL VLSIT mới](../../rtl/common/vlsit/).
- [LLC dependency lockfile / Lockfile dependency LLC](../../scripts/third_party/axi_llc/Bender.lock) · [Preserved license files / File license được giữ](../licenses/third_party/).
- [Current cluster HDS / HDS cluster hiện tại](../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) · [Recorded implementation audit / Audit triển khai đã lưu](../reports/post_a06_cluster_audit/README.md).

The production AXI hierarchy now connects the CPU tiles, CCU, LLC and per-line maintenance path. Earlier compile-only counts and statements that the LLC wrapper is unconnected describe prior checkpoints; they do not describe the current hierarchy. Recorded directed evidence does not establish full functional or ASIC signoff.

Hierarchy AXI production đã nối CPU tile, CCU, LLC và maintenance theo line. Số liệu compile riêng và nhận định wrapper LLC chưa nối thuộc mốc cũ. Bằng chứng directed đã lưu chưa xác nhận kiểm chứng đầy đủ hoặc signoff ASIC.

Retain original copyright, SPDX and license notices in reused RTL. Modified copies keep those notices and add change history; new VLSIT RTL follows the project coding rules. The PlanV CVA6 snapshot is for comparison and is not the selected upstream baseline.

Giữ copyright, SPDX và license gốc trong RTL tái sử dụng. Bản sửa giữ thông báo gốc và thêm history; RTL VLSIT mới theo coding rule dự án. Snapshot PlanV CVA6 dùng đối chiếu, không phải baseline upstream đã chọn.

Some upstream README references require assets absent from the retained snapshot or a documentation-site renderer. [Known reference gaps / Danh sách tham chiếu còn thiếu](../documentation_audit_20261116/preserved_references.json) records each source and target; no replacement from another revision is implied.

Một số tham chiếu README upstream cần asset không có trong snapshot lưu hoặc cần bộ dựng website tài liệu. Danh sách trên ghi file nguồn và đích; không thay bằng file của revision khác.
