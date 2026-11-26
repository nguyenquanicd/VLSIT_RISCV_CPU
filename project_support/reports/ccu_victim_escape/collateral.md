# Deliverables / Hồ sơ bàn giao

- Production RTL: `rtl/common/vlsit/coherence/m_vlsit_riscv_coh_fabric.sv` only. Original preserved under `before/rtl/vlsit/`; [fabric.diff](../../../verification/non_coherence_cluster/reports/ccu_victim_escape/fabric.diff) records the exact edit.
- Specification: `doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md`, updated REQ-MEM-009/014, TEST-053, traceability, concrete examples and conditional performance limits.
- Verification: `verification/non_coherence_cluster/ccu_victim_escape/`, with independent RV64 image encoder, four actual image/listing pairs, CPU and focused benches, unchanged native wrapper copy, verification-only fault shim, runners and strict evidence collector.
- Replay: existing `verification/non_coherence_cluster/cmo_end_to_end/Makefile`, `victim-regression` target. No second Makefile is introduced.
- Reports: this folder stores baseline snapshots, plan, rule checks, manual review, diff, source/model/verification fingerprints, native model/build/simulation logs, mutation results and sampled CPU VCD evidence.
- Project status/review: root and RTL README, `rtl_change_review.md`, and `project_support/reports/cluster_completeness_audit/README.md` are updated after the complete validation gate succeeds.

VI: Chỉ một file RTL production thay đổi. Spec có yêu cầu/test/ví dụ và giới hạn hiệu năng. Testbench, chương trình và log lưu đầy đủ; dùng Makefile chung để chạy lại. Bản gốc và hash được giữ để đối chiếu. Không sửa header hoặc source RTL reuse theo license.
