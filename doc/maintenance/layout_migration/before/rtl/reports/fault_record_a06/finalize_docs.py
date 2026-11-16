"""Finalize A-06 documentation after successful native validation."""
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[3]
OUT = Path(__file__).resolve().parent

def update(name, transform):
    path = ROOT / name
    before = OUT / 'before' / 'final_documentation' / name
    if not before.exists():
        before.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, before)
    text = path.read_text(encoding='utf-8')
    path.write_text(transform(text), encoding='utf-8')

en = ('A-06 is implemented and verified: first fatal L1/LLC record is retained until reset; '
      'later faults set multiple. L1 identifies the exact hart; LLC uses hart_valid=0. '
      '58 real CPU cases PASS, including ten A-06 scenarios and AMO/LR-SC/CBO/FENCE.I regression; '
      'production TOP lint at 2/4 harts has zero errors and warnings. '
      'Firmware must use the 4-KiB group map: fault 0x4000–0x400C, LLC 0x5000 (24-KiB aperture). '
      'Directed validation does not establish global coherence, OS or ASIC signoff.')
vi = ('A-06 đã triển khai và kiểm chứng: giữ record fatal L1/LLC đầu tiên đến reset; '
      'lỗi sau đặt multiple. L1 ghi đúng hart; LLC dùng hart_valid=0. '
      '58 ca CPU thật PASS, gồm mười ca A-06 và regression AMO/LR-SC/CBO/FENCE.I; '
      'lint TOP 2/4 hart không lỗi hoặc warning. Firmware phải dùng map cách 4 KiB: '
      'fault 0x4000–0x400C, LLC 0x5000, aperture 24 KiB. '
      'Chưa phải signoff coherence toàn cục, OS hoặc ASIC.')

update('README.md', lambda t: t.replace(
    'Detailed fault-record A-06 remains open; see [cluster audit](rtl/reports/cluster_completeness_audit/README.md).',
    en + ' [A-06 evidence and replay](rtl/reports/fault_record_a06/README.md).').replace(
    '[Fault record chi tiết A-06](rtl/reports/cluster_completeness_audit/README.md) vẫn còn.',
    vi + ' [Báo cáo A-06](rtl/reports/fault_record_a06/README.md).'))

update('rtl/README.md', lambda t: t.replace(
    'including remaining warnings and validation limits.', 'for historical results; current zero-warning lint and limits are in the A-06 report below.')
    .replace('fault record A-06 vẫn còn.', 'fault record A-06 đã hoàn tất ở mục dưới.')
    .replace('A-06 còn mở.', 'A-06 đã hoàn tất ở mục dưới.')
    .replace('Detailed fault record A-06 remains open.', 'A-06 evidence is recorded below.')
    .replace('Fault record chi tiết A-06 còn mở.', 'A-06 đã có bằng chứng ở mục dưới.')
    + '\n## A-06 — First-fatal record / Bản ghi fatal đầu tiên\n\n' + en
    + '\n\n' + vi + '\n\n[Validation, source hashes and replay / Kiểm chứng, hash và chạy lại](reports/fault_record_a06/README.md).\n')

update('rtl_change_review.md', lambda t: t + '\n## A-06 completion / Hoàn tất A-06 — 2026-11-16\n\n'
       + en + '\n\n' + vi + '\n\n[Changed production RTL and hashes](rtl/reports/fault_record_a06/changed_files.md); '
       '[implementation, workbook provenance and limitations](rtl/reports/fault_record_a06/README.md). '
       'Earlier open-item statements are historical. Generated CSR was regenerated from the canonical workbook; '
       'the generator and pristine upstream RTL were not edited. Modified LLC sources preserve license headers and add change history.\n')

def audit(t):
    start = t.index('### A-06 — Fault record detail')
    end = t.index('## Remaining work order', start)
    t = t[:start] + '### A-06 — Fault record detail / Nội dung fault record\n\n' + en + '\n\n' + vi + '\n\n[Evidence, register map and limits](../fault_record_a06/README.md).\n\n' + t[end:]
    t = t.replace('complete detailed asynchronous fault records (A-06) and extend', 'A-06 directed fault-record validation is complete; extend')
    t = t.replace('finish diagnostic record A-06 and reserved/WSTRB/BIST/flush/reset tests.', 'extend beyond the A-06 RO/reserved/WSTRB/reset tests to broad BIST/flush/PMU/debug qualification.')
    pos = t.index('\n')
    return t[:pos] + '\n\n**Latest / Mới nhất (2026-11-16):** A-06 completed; [98 evidence entries, 58 CPU cases and limits](../fault_record_a06/README.md). Older findings below are historical unless explicitly updated. / A-06 đã hoàn tất; các gap cũ bên dưới cần đọc theo mốc lịch sử.\n' + t[pos:]
update('rtl/reports/cluster_completeness_audit/README.md', audit)

for directory in ('atomic_coherence', 'l1_eviction_retention', 'directory_holder_lifecycle', 'ccu_victim_escape'):
    def historical(t):
        pos = t.index('\n')
        return t[:pos] + '\n\n**Follow-up / Cập nhật 2026-11-16:** [A-06 and full directed regression](../fault_record_a06/README.md) now pass. Source hashes and open-item statements in this older report describe its original checkpoint. / A-06 và regression đã PASS; hash và gap trong báo cáo cũ phản ánh mốc kiểm tra ban đầu.\n' + t[pos:]
    update(f'rtl/reports/{directory}/README.md', historical)

def spec(t):
    t = t.replace('version: "0.27"', 'version: "0.28"', 1)
    t = t.replace('status: "Draft - external CMO integrated; directed CPU instruction and TOP lint evidence in rtl/reports/cmo_end_to_end; broader verification remains open"',
                  'status: "Draft - A-06 implemented; 58 directed CPU cases and 2/4-hart TOP lint pass; broader qualification remains open"', 1)
    marker = '# Đặc tả cụm CPU RISC-V cấu hình 2/4 lõi VLSIT\n'
    t = t.replace(marker, marker + '\n**Revision 0.28 checkpoint — 2026-11-16:** ' + en
                  + ' [Evidence](../../rtl/reports/fault_record_a06/README.md).\n\n' + vi + '\n', 1)
    # Earlier revision notes remain available without being mistaken for current status.
    t = t.replace('**Revision 0.27 RTL integration status:**', '**Historical revision 0.27 RTL integration status (superseded):**')
    t = t.replace('**Trạng thái tích hợp RTL bản 0.27:**', '**Lịch sử tích hợp RTL bản 0.27 (đã được thay thế):**')
    t += ('\n### A-06 measured evidence / Bằng chứng đo từ mô phỏng\n\n'
          + en + '\n\n' + vi
          + '\n\n![A-06 measured first-fault hold, later event and reset](../../rtl/reports/fault_record_a06/waveforms/first_fault_4h.svg)\n\n'
          'TEST-054 record-unit samples show actual post-clock values, not an AXI latency contract. '
          'This measured trace has no WF plan number; WF-022 remains the separate directory-cancel diagram. '
          '[Trace interpretation and CPU evidence](../../rtl/reports/fault_record_a06/waveform_compare.md). '
          '/ Hình lấy mẫu thực từ unit record, không quy định latency AXI; không thay số WF-022 của sơ đồ directory.\n')
    return t
update('doc/specification/VLSIT_RISCV_DUAL_QUAD_CPU_CLUSTER_HDS.md', spec)

update('rtl/reports/fault_record_a06/README.md', lambda t: t.replace(
    'Final validation is in progress. [Validation](validation.md) and [machine-readable results](results.json) are authoritative only after the evidence collector returns PASS. / Đang chốt kiểm chứng; chỉ công nhận hoàn tất khi collector trả PASS.',
    '**Completed / Hoàn tất (2026-11-16):** 98 evidence entries PASS, including 58 real CPU cases and production TOP lint at 2/4 harts with zero errors and warnings. / 98 mục bằng chứng PASS, gồm 58 ca CPU thật và lint TOP 2/4 hart không lỗi hoặc warning. '
    '[Validation](validation.md), [results and source identities](results.json), [13 changed/new production RTL files](changed_files.md), [manual rule review](manual_review.md), [measured waveform](waveform_compare.md).'))

(OUT / 'waveform_compare.md').write_text('''# Measured waveform / Waveform đo từ mô phỏng

![First-fault hold and reset](waveforms/first_fault_4h.svg)

The trace comes from the four-hart record unit's actual VCD, sampled 2 ns after rising edges at 7, 17, …, 117 ns. It demonstrates first-event capture, unchanged payload when another fatal event sets multiple, and clearing at reset. The trace is a unit-level register check, not an AXI timing diagram or CPU latency bound. Source [VCD](unit/service_4h_error0.vcd), [WaveJSON](waveforms/first_fault_4h.json).

Hình lấy từ VCD thực của unit record bốn hart, sau cạnh clock 2 ns tại 7, 17, …, 117 ns. Hình kiểm tra capture lỗi đầu, giữ payload khi lỗi sau đặt multiple và xóa khi reset. Đây là kiểm tra thanh ghi ở cấp unit, không quy định latency AXI hoặc CPU.

Independent CPU tests verify address/hart/BRESP against the injected AXI transaction. Ten A-06 CPU cases include both SLVERR and DECERR, L1/LLC origin, reset recovery, and cross-ID response ordering where hart 1 (two harts) or hart 3 (four harts) fails first. [Native logs and full regression](validation.md). Each A-06 CPU case requires 20 native AXI, 20 external AXI and 20 AXI4-Lite checks to activate and pass.

Test CPU độc lập đối chiếu địa chỉ/hart/BRESP với transaction AXI được tiêm lỗi. Mười ca A-06 gồm hai mã lỗi, hai nguồn, reset recovery và đảo thứ tự response giữa ID để hart 1 hoặc hart 3 lỗi trước. Mỗi ca bắt buộc kích hoạt và PASS 20 kiểm tra ở từng giao diện native AXI, AXI ngoài và AXI4-Lite. Chưa đo code coverage.
''', encoding='utf-8')

collector = ROOT / 'rtl/verification/fault_record_a06/collect_evidence.py'
text = collector.read_text(encoding='utf-8').replace('WF-022 / TEST-054: first fault, later event, reset', 'A-06 / TEST-054 measured first fault, later event, reset')
collector.write_text(text, encoding='utf-8')
