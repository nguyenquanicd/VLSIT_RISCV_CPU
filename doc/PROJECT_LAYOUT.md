# Project layout / Cấu trúc dự án

```text
VLSIT_RISCV_CPU/
├── rtl/
│   ├── non_coherence_cluster/   AXI TOP, core, width adapter, filelists
│   ├── coherence_cluster/       ACE profile reserved; not implemented
│   └── common/
│       ├── third_party/         Unchanged upstream RTL / RTL upstream nguyên bản
│       ├── modified/            Licensed local changes / Bản sửa giữ license
│       ├── vlsit/               New/generated RTL / RTL mới hoặc sinh tự động
│       │   ├── address_map/
│       │   ├── cache/
│       │   ├── coherence/
│       │   ├── control/
│       │   ├── cpu/
│       │   ├── csr/RTL/
│       │   ├── debug/
│       │   ├── diagnostics/
│       │   ├── interconnect/
│       │   ├── maintenance/
│       │   └── pmu/
│       └── filelists/
├── lint/                       Lint/rule logs and configuration / Log và cấu hình lint
├── verification/               Testbenches, programs, models, logs, VCD / Mô phỏng
│   ├── non_coherence_cluster/
│   ├── coherence_cluster/
│   ├── common/
│   └── work/
├── doc/                        Two specifications and supporting design files / Hai bộ đặc tả
│   ├── specification/          2/4-hart cluster: HDS, CSR, architecture, figures, references
│   └── tensor_coprocessor/     Tensor HDS, CSR, figures and CV-X-IF reference
├── project_support/            Implementation reports, history, vendor docs, licenses / Tài liệu hỗ trợ
└── scripts/                    Build, lint, generation and audit tools / Công cụ
```

The AXI folder name describes the **external** memory interface. Internal coherent D-caches, directory and CCU remain enabled. The ACE folder has only a status filelist; there is no implemented ACE TOP. Shared modules remain in `common` for future reuse.

Tên thư mục AXI mô tả giao tiếp **bên ngoài**. Coherence D-cache nội bộ, directory và CCU vẫn được giữ. Thư mục ACE chỉ có filelist ghi trạng thái, chưa có TOP ACE. Source dùng chung được đặt trong `common` để tái sử dụng.

## Source and evidence / Source và bằng chứng

- `rtl` contains RTL, include files and filelists only. Upstream headers and modified-source history are unchanged. Licenses are preserved in [project_support/licenses/third_party](../project_support/licenses/third_party); repository metadata is under `project_support/provenance/third_party`.
- `lint` and `verification` separate common checks from profile-specific checks. Simulation builds go under `verification/*/build`; results go under `verification/*/reports`.
- Documentation for tests lives under `project_support/verification`; validation reports live under `project_support/reports`. The root README is the navigation entry point.
- Historical raw logs and JSON keep their original run identities. [Migration manifest](../project_support/maintenance/layout_migration/manifest.json) records old/new paths and archived tooling identities. `scripts/project_layout.py` resolves those identities without claiming a new CPU regression. Rebuild models before running simulations in the new layout; unrelated external caches were not deleted.

- `rtl` chỉ chứa RTL, include và filelist. Header upstream và history sửa source được giữ nguyên; license và metadata repository được lưu trong `project_support`.
- Log lint nằm trong `lint`; testbench, chương trình, build và kết quả mô phỏng nằm trong `verification`, tách theo profile hoặc phần dùng chung.
- Tài liệu test nằm trong `project_support/verification`; báo cáo kiểm chứng nằm trong `project_support/reports`. README gốc dùng để điều hướng.
- Log và JSON lịch sử giữ nguyên thông tin lần chạy. Manifest ghi lại đường dẫn cũ/mới và hash công cụ. Cần build lại model khi chạy tại cấu trúc mới; không xóa cache ngoài dự án.

## Run from project root / Chạy từ thư mục gốc

```powershell
python scripts/run_cluster_top_lint.py --hart-count 2
python scripts/run_cluster_top_lint.py --hart-count 4
python verification/non_coherence_cluster/fault_record_a06/run_unit.py --harts 2 --report-dir verification/non_coherence_cluster/reports/layout_smoke
python scripts/reorganize_cluster_layout.py check
```

The integrated regression command list remains in [the Makefile](../verification/non_coherence_cluster/cmo_end_to_end/Makefile). Production entry filelist: [AXI filelist](../rtl/non_coherence_cluster/filelist.f). Filelists currently contain absolute project paths; regenerate paths after relocating the entire repository to another machine.

Danh sách lệnh regression tích hợp nằm trong Makefile trên. Filelist production thuộc profile AXI. Filelist hiện dùng đường dẫn tuyệt đối; cần cập nhật khi chuyển toàn bộ repository sang máy hoặc vị trí khác.

TOP: [m_vlsit_riscv_cluster_axi_top.sv](../rtl/non_coherence_cluster/m_vlsit_riscv_cluster_axi_top.sv), `PARA_CPU_NUM=2` or `4` (default `4`).

TOP hỗ trợ 2 hoặc 4 hart, mặc định 4. Việc sắp xếp thư mục không thay đổi chức năng RTL.

Documentation cleanup preserves file content in [project_support](../project_support/README.md); its [manifest](../project_support/doc_cleanup_20261116/manifest.json) records every original/new path and SHA-256. Only specification material stays under `doc`.

Nội dung chuyển khỏi `doc` được giữ ở `project_support`; manifest ghi đường dẫn cũ/mới và SHA-256 để tra cứu hoặc khôi phục. `doc` chỉ giữ hai bộ đặc tả và tài liệu thiết kế liên quan.
