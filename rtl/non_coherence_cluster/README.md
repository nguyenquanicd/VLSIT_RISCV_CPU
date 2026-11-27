# rtl/non_coherence_cluster — Cluster AXI TOP / TOP cluster AXI

The current product TOP: a 2/4-hart CVA6 cluster with MESI-coherent D-caches inside the cluster and plain (non-coherent) AXI4 toward the SoC. "Non-coherence" refers to the external interface: no agent outside the cluster is snooped. Both cluster versions (64-bit and 32-bit) use this TOP.

TOP sản phẩm hiện tại: cluster CVA6 2/4 hart, D-cache có coherence MESI bên trong cluster, giao tiếp AXI4 thường (không coherence) ra SoC. "Non-coherence" nói về giao tiếp bên ngoài: không snoop agent nào ngoài cluster. Cả hai phiên bản 64-bit và 32-bit dùng chung TOP này.

## Source / Mã nguồn

| File | Function / Chức năng |
|---|---|
| `m_vlsit_riscv_cluster_axi_top.sv` | Structural AXI TOP: AXI4-Lite control, AXI4 memory with PULP AWATOP, AXI4 MMIO, per-hart IRQ/debug. Parameters `PARA_CPU_NUM` (2/4, default 4), `PARA_TIMING_PROFILE` (0/1/2), address-region table. / TOP cấu trúc, chứa các tham số chính |
| `m_vlsit_riscv_cluster_core.sv` | Integrates CPU tiles, coherence fabric, AXI routing, shared LLC, CSR and PMU. / Tích hợp tile CPU, fabric coherence, định tuyến AXI, LLC, CSR, PMU |
| `m_vlsit_riscv_axi_dw_adapter.sv` | Converts the 64-bit LLC AXI port to the configured memory-bus width. / Đổi độ rộng bus bộ nhớ |
| `m_vlsit_riscv_axi_soc_wrap.sv` | Optional SoC adapter for fixed four-slot IRQ/debug wiring. / Adapter SoC tùy chọn |

## Filelists

| Filelist | Use / Dùng cho |
|---|---|
| `filelist.f` | Full 64-bit cluster: CVA6 + HPDcache (`rtl/common/filelists/cva6_flush_path/`), LLC, VLSIT cluster RTL. TOP `m_vlsit_riscv_cluster_axi_top` |
| `filelist_soc_wrapper.f` | `filelist.f` plus the SoC wrapper (paths relative to the repository root) |
| `filelists/full_integration/` | Parts chained by `filelist.f` (`filelist_vlsit_cluster.f`, `filelist_llc_unique.f`, CSR, address region) |
| `filelists/cluster_top_lint/` | Lint-only TOP set |

The 32-bit version uses the same TOP through `rtl/rv32_profile/filelist_rv32.f`.

## Notes / Lưu ý

- Most filelists use absolute paths (`C:/HQuan/102_MyGithub/VLSIT_RISCV_CPU/...`) so that tools can run from any folder. On another machine or checkout path, rewrite the prefix first. / Hầu hết filelist dùng đường dẫn tuyệt đối; đổi tiền tố khi chuyển máy hoặc thư mục.
- Specification: [Cluster HDS](../../doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) (port list Section 6.2, parameters Section 8).
- `PARA_CPU_NUM` and `PARA_TIMING_PROFILE` are elaboration-time choices; there is no run-time profile switch. / Chọn lúc elaboration, không đổi lúc chạy.
- Status: lint clean, directed simulation PASS, no synthesis/STA signoff. See the [root README](../../README.md#project-status--trạng-thái-dự-án).
