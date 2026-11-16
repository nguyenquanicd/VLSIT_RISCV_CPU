# Deliverables / Các file bàn giao

| Artifact / Tài liệu | Purpose / Mục đích |
|---|---|
| [13 production RTL files](changed_files.md) | New fault-record leaf, integration, address decoder, generated CSR and licensed modified LLC / Leaf record, tích hợp, decoder, CSR sinh tự động và LLC sửa giữ license |
| [Specification](../../specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md) | Revision 0.28, DEC-039/040, register semantics and limits / Đặc tả, hợp đồng record và giới hạn |
| [Canonical CSR workbook](../../specification/VLSIT_RISCV_CPU_Cluster_CSR.xlsx) | 4-KiB register groups and RO first-fault words / Map nhóm 4 KiB và record chỉ đọc |
| [Generation provenance](../../../verification/non_coherence_cluster/reports/fault_record_a06/csr_generation.json) | Workbook, generator and byte-exact output hashes / Hash workbook, generator và output |
| [Verification sources](../../verification/non_coherence_cluster/fault_record_a06/README.md) | CPU, record, decoder, mutation and independent evidence checks / Test CPU, unit, mutation và đối chiếu độc lập |
| [Single replay Makefile](../../../verification/non_coherence_cluster/cmo_end_to_end/Makefile) | `make fault-regression`; includes the required baseline and final lint / Chạy lại regression và lint |
| [Validation](validation.md), [results](../../../verification/non_coherence_cluster/reports/fault_record_a06/results.json) | 98 PASS evidence entries, including 58 real CPU cases / 98 mục PASS, gồm 58 ca CPU thật |
| [Measured waveform](waveform_compare.md) | Actual record-unit samples and interpretation / Mẫu unit thực và giải thích |
| [Manual review](manual_review.md) | Source association, license, rule notices, scope / Liên kết transaction, license, lưu ý rule và phạm vi |
| [Comment-only proof](../../../verification/non_coherence_cluster/reports/fault_record_a06/comment_only_cleanup.json) | Exact compiled snapshots and two final comment insertions / Source đã compile và hai đoạn comment thêm sau mô phỏng |

The generator repository was not edited. Pristine reuse files retain their original contents. Local LLC changes preserve upstream copyright/SPDX and record Quan Nguyen and Codex — VLSI Technology page history. Generated RTL is copied byte-for-byte from the documented generator output.

Không sửa repository generator hoặc RTL reuse nguyên bản. LLC sửa giữ copyright/SPDX và ghi history; RTL CSR khớp nguyên byte với output generator. Chưa đo code coverage hoặc thực hiện signoff ASIC.
