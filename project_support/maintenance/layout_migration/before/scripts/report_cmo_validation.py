"""Summarize completed real-instruction runs and production TOP lint evidence."""
from pathlib import Path
import collections
import hashlib
import json
import re

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'rtl/reports/cmo_end_to_end'
rows = []
for harts in (2, 4):
    for error in (0, 1):
        stem = f'{harts}h_error{error}'
        path = OUT / f'simulation_{stem}.log'
        text = path.read_text(encoding='utf-8')
        match = re.search(rf'PASS: real CVA6 CBO.*harts={harts} error={error} cycles=(\d+)', text)
        assert match and len(re.findall(r'^CHECK hart=', text, re.M)) == harts, path
        assert (OUT / f'service_{stem}.vcd').stat().st_size > 1000
        rows.append(f'| {harts} | {"SLVERR → ABORT → cause 7" if error else "CLEAN / FLUSH / INVAL → retire"} | PASS | {match[1]} | [log](simulation_{stem}.log), [VCD](service_{stem}.vcd) |')

lint_rows = []
diagnostics = []
for harts in (2, 4):
    path = max((ROOT/'rtl/reports/full_integration').glob(f'top_lint_{harts}h_*.log'), key=lambda p:p.stat().st_mtime)
    text = path.read_text(encoding='utf-8')
    assert '%Error' not in text and 'Walltime' in text, path
    counts = collections.Counter(re.findall(r'%Warning-([A-Z0-9_]+)', text))
    assert sum(counts.values()) == 0, path
    lint_rows.append(f'| {harts} | 0 | {sum(counts.values())} | 0 | 0 | [{path.name}](../full_integration/{path.name}) |')
    for line in text.splitlines():
        if line.startswith('%Warning'):
            diagnostics.append(f'{harts}h OPEN: {line}')
(OUT/'lint_warning_disposition.txt').write_text(
    'Final production TOP lint: zero warning and error diagnostics at 2 and 4 harts.\n'
    'No new diagnostic suppression or waiver was added.\n\n'+'\n'.join(diagnostics)+'\n', encoding='utf-8')

hashes = {}
for folder in ('rtl/vlsit', 'rtl/modified'):
    for path in sorted((ROOT/folder).rglob('*.sv')):
        hashes[path.relative_to(ROOT).as_posix()] = hashlib.sha256(path.read_bytes()).hexdigest()
(OUT/'source_hashes.json').write_text(json.dumps(hashes,indent=2)+'\n',encoding='utf-8')

text = '''# External CMO integration / Tích hợp external CMO

Production TOP: `m_vlsit_riscv_cluster_axi_top`, source [m_vlsit_riscv_cluster_axi_top.sv](../../vlsit/m_vlsit_riscv_cluster_axi_top.sv).

External CMO is enabled in the production core. Real CVA6 instructions traverse retirement → shared arbiter/controller → shared CCU context/line lock → native LLC maintenance → CCU COMMIT/ABORT ACK → CPU retire/trap. The test does not force DUT signals or inject internal completion pulses.

Core production đã bật external CMO. Instruction CVA6 thật đi qua retirement → arbiter/controller → context/lock CCU → LLC native → ACK COMMIT/ABORT → retire/trap. Test không force tín hiệu DUT hoặc giả lập completion nội bộ.

## Results / Kết quả

| Harts | Case / Trường hợp | Result | Cycles from reset release | Evidence |
|---|---|---|---|---|
'''+ '\n'.join(rows)+'''

Each hart stores `49 + hart_id` at `0x80001000 + 64 × hart_id`, then executes CLEAN, FLUSH and INVAL. The observer checks external-memory data at every CBO retirement. With injected memory writeback SLVERR, CLEAN never retires; each hart traps with `mcause=7`, `mepc=0x8000002c`, and `mtval` equal to its original effective address. Service monitors require PREPARE → LLC completion → terminal COMMIT/ABORT ACK before CPU completion, and count every hart's service/abort.

Mỗi hart ghi dữ liệu riêng rồi chạy ba CBO. Observer kiểm tra bộ nhớ ngoài ngay tại mỗi lần retire. Khi writeback trả SLVERR, CLEAN không retire; từng hart trap đúng cause, PC và VA gốc. Monitor kiểm tra thứ tự service và đếm completion/ABORT của từng hart.

| TOP harts | Error diagnostics | Warning diagnostics | LATCH | MULTIDRIVEN | Log |
|---|---|---|---|---|---|
'''+ '\n'.join(lint_rows)+'''

Native lint invocations returned exit 0 with **zero warnings**, including `UNOPTFLAT`, width/range, latch and multiple-driver diagnostics. Existing tool arguments were retained; no new warning suppression or waiver was added. The runner now fails if any warning returns. See [lint status](lint_warning_disposition.txt) and [cleanup details](../lint_cleanup/README.md). This is RTL lint evidence, not timing, formal or tapeout signoff.

Lint hoàn tất với exit 0 và không còn warning; runner hiện trả lỗi nếu warning xuất hiện lại. Không thêm suppression hoặc waiver. Kết quả chưa thay thế STA, formal hoặc signoff tapeout.

## RTL changes / Thay đổi RTL

- CVA6/EX/LSU/store buffer: retain original VA/PA/op/PC; consume an externally completed CBO once; block younger retirement; hold completion during halt; defer interrupt/debug entry while owned; generate the precise terminal fault.
- HPDcache wrapper: retirement's store-empty condition also requires empty replay/MSHR and idle CPU pipeline. This fixes CLEAN racing a retired store whose refill/replay had not yet updated the cache. Native cache-internal write-buffer-empty remains separate to avoid a drain dependency cycle.
- Core, tile arrays and CMO arbiter: enable external CMO, retain ownership, and connect real CCU/LLC endpoints.
- CCU fabric: use native tagged contexts and locks, retain PREPARE until accepted, preserve status and directory ownership through ABORT, and release only after required terminal ACKs.
- LLC: per-line native tag/data/writeback service; commit clean/invalidate metadata only on success; preserve dirty data on error. Normal eviction retains its four-entry pending table and unrelated-set concurrency.
- Lint cleanup: license-preserving CVA6 MMU/TLB/FIFO copies default temporary combinational values; LLC `id_queue` declares its existing empty net; inactive tile tie-offs no longer index beyond active-hart vectors.

Các thay đổi giữ metadata và quyền sở hữu transaction đến completion; chờ store thật sự drain khỏi cache; nối service native; lỗi writeback đi qua ABORT trước trap. Bản reuse trong `rtl/third_party` được giữ nguyên; bản sửa nằm trong `rtl/modified` với license và history.

## Reproduce / Chạy lại

Run from `rtl/verification/cmo_end_to_end`:

```text
make focused
make all
```

The [single Makefile](../../verification/cmo_end_to_end/Makefile) contains focused checks, success/error runs for 2/4 harts and TOP lint commands. `run.py` uses native Verilator code generation and direct g++ compilation, avoiding the local MSYS make runtime failure. Model objects stay under `C:/HQuan/.test_tmp/cmo_cpu_2h` and `cmo_cpu_4h`; committed evidence stays here.

Makefile chứa lệnh test khối, test đầu-cuối và lint. Build tạm ở `.test_tmp`; log và VCD lưu riêng khỏi source RTL.

Tools: Verilator 5.053 devel `v5.052-119-g014c9820d (mod)`, installed in `C:/Users/PC/Tools/oss-cad-suite`; g++ from `C:/Users/PC/Tools/msys64/ucrt64/bin`. The newer installed Verilator stalls during parameter elaboration; runners select the working version. [source_hashes.json](source_hashes.json) records the delivered modified/VLSIT source hashes.

## Scope and rule evidence / Phạm vi và bằng chứng rule

The instruction tests instantiate the real production hierarchy with a reduced legal LLC geometry (4 ways × 64 lines × 16 bytes = 4 KiB), 64-bit memory AXI and a 64-KiB behavioral memory. Production TOP lint uses default 256-KiB LLC. Tests run in M-mode without address translation; per-hart data lines are distinct. These directed checks do not prove all sharing races, every bus width, virtual-memory faults, all backpressure patterns or full AXI4/ATOP compliance. Full protocol assertion coverage, the entire HDS waveform matrix, synthesis/PPA, formal proof and signoff remain outside these results. Code coverage was not requested.

Test instruction dùng LLC 4 KiB để giảm thời gian mô phỏng; lint dùng LLC mặc định 256 KiB. Test chạy M-mode, địa chỉ riêng từng hart. Chưa chứng minh toàn bộ race coherence, mọi bus width, MMU, backpressure hoặc AXI4/ATOP. Không đo code coverage theo lựa chọn directed checks đã duyệt.

R-012: [rule_check.txt](rule_check.txt), 36 VLSIT modules, 0 errors, 22 warnings, 2 informational notices. HIE-02 warnings identify functional adapters, not the structural cluster TOP; NAM-08 warnings retain approved public names and matching instance names. COM-04 information marks existing full-case don't-care defaults. Licensed modified upstream sources retain their native coding conventions per the user's instruction; they are linted in the complete hierarchy.

R-001/R-014/R-016: results and limits are explicit above. R-008: approved plan V4 and later approved CBO policy A. R-009: pristine third-party sources retained. R-010/R-022: verification sources remain separate. R-023: architectural CBO behavior and HDS maintenance contracts form expected results; hierarchy references only observe service/retirement and architectural CSRs. R-024/R-025: this focused instruction bench is not a complete per-protocol assertion suite. R-033: sampled service VCDs are saved; a complete HDS waveform comparison is not claimed. R-047: directed checks only. [manual_rules.txt](manual_rules.txt) lists the checker/manual boundary; a full tapeout checklist is not claimed.
'''
(OUT/'README.md').write_text(text,encoding='utf-8')
print('Verified four instruction logs and two hierarchy lint logs; wrote',OUT/'README.md')
