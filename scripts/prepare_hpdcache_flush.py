"""Create a license-preserving flush-engine copy from the CVA6 cache pin."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]
PIN = 'e8f072e117ed3282950d4d1e975f462b173f0de0'
UP = ROOT / 'rtl/common/third_party/hpdcache_cva6_pinned'
OUT = ROOT / 'rtl/common/modified/hpdcache/rtl/src/hpdcache_flush.sv'


def change(text, old, new):
    if text.count(old) != 1:
        raise RuntimeError('Non-unique source cut point: ' + old)
    return text.replace(old, new)


def main():
    if OUT.exists():
        raise RuntimeError('Modified source already exists; inspect before regenerating')
    rev = subprocess.check_output(['git', '-C', str(UP), 'rev-parse', 'HEAD'], text=True).strip()
    if rev != PIN:
        raise RuntimeError('Wrong upstream cache revision: ' + rev)
    original = (UP / 'rtl/src/hpdcache_flush.sv').read_bytes()
    text = original.decode('utf-8').replace('\r\n', '\n')
    text = change(text, ' *  History       :',
        ' *  History       :\n'
        ' *  2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:\n'
        ' *    Preserve allocation origin through writeback completion; report B errors.\n'
        ' *    Consume/diagnose responses not matching a live non-atomic flush ID.\n'
        ' *    REQ-MEM-012/015/018: the cache owner must retain M until COMMIT/ABORT.\n'
        ' *    This engine releases transport entries on matching B, including B errors;\n'
        ' *    it does not change MESI or authorize dirty/tag state destruction.')
    text = change(text, '    input  hpdcache_way_vector_t  flush_alloc_way_i,',
        '    input  hpdcache_way_vector_t  flush_alloc_way_i,\n'
        '    // Origin: 00 native eviction, 01 CMO, 10 coherence probe; 11 reserved.\n'
        '    input  logic [1:0]            flush_alloc_origin_i,')
    text = change(text, '    output hpdcache_nline_t       flush_ack_nline_o,',
        '    output hpdcache_nline_t       flush_ack_nline_o,\n'
        '    output logic [1:0]            flush_ack_origin_o,\n'
        '    output logic                  flush_ack_error_o,\n'
        '    output logic                  flush_rsp_invalid_o,')
    text = change(text, '        hpdcache_nline_t nline;',
        '        hpdcache_nline_t nline;\n        logic [1:0] origin;')
    text = change(text, '    localparam int unsigned FlushMaxEntries = 2 ** FlushIndexWidth;',
        '    localparam int unsigned FlushMaxEntries = 2 ** FlushIndexWidth;\n'
        '    localparam int unsigned FlushRespCompareWidth =\n'
        '        ($bits(hpdcache_mem_id_t) > 32) ? $bits(hpdcache_mem_id_t) : 32;')
    text = change(text, '    logic                       flush_ack;',
        '    logic                       flush_ack;\n    logic                       flush_rsp_match;')
    text = change(text, '    assign flush_ack = mem_resp_write_valid_i;',
        '    // Check the complete response ID before indexing the flush directory.\n'
        '    // Truncating first would alias an invalid high ID onto a live entry.\n'
        '    always_comb begin : flush_response_match_comb\n'
        "        flush_rsp_match = 1'b0;\n"
        '        if (FlushRespCompareWidth\'($unsigned(mem_resp_write_i.mem_resp_w_id))\n'
        '            < FlushRespCompareWidth\'(FlushEntries)) begin\n'
        '            flush_rsp_match = flush_dir_valid_q[flush_dir_ack_ptr]\n'
        '                            & ~mem_resp_write_i.mem_resp_w_is_atomic;\n'
        '        end\n'
        '    end\n'
        '    assign flush_ack = mem_resp_write_valid_i & flush_rsp_match;\n'
        '    assign flush_rsp_invalid_o = mem_resp_write_valid_i & ~flush_rsp_match;')
    text = change(text, '    assign flush_ack_nline_o = flush_dir_q[flush_dir_ack_ptr].nline;',
        "    assign flush_ack_nline_o = flush_ack ? flush_dir_q[flush_dir_ack_ptr].nline : '0;\n"
        "    assign flush_ack_origin_o = flush_ack ? flush_dir_q[flush_dir_ack_ptr].origin : '0;\n"
        '    assign flush_ack_error_o = flush_ack\n'
        '                             & (mem_resp_write_i.mem_resp_w_error != HPDCACHE_MEM_RESP_OK);')
    text = change(text, '                    nline: flush_alloc_nline_i',
        '                    nline: flush_alloc_nline_i,\n                    origin: flush_alloc_origin_i')
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(text, encoding='utf-8', newline='\n')
    # Keep the full upstream license set beside the licensed derivative, without edits.
    for license_file in UP.glob('LICENSE*'):
        if license_file.is_file():
            shutil.copy2(license_file, OUT.parents[2] / license_file.name)
    report = ROOT / 'verification/common/reports/hpdcache_flush'
    report.mkdir(parents=True, exist_ok=True)
    manifest = dict(upstream_revision=rev, original_sha256=hashlib.sha256(original).hexdigest(),
                    modified_sha256=hashlib.sha256(OUT.read_bytes()).hexdigest())
    (report / 'source.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')

    # A typed elaboration harness uses the real upstream package/config constructor.
    # It contains no stimulus, assertions, expected-result model, or blackboxes.
    lint_source = (UP / 'rtl/lint/hpdcache_lint.sv').read_text(encoding='utf-8')
    config = re.search(r"localparam hpdcache_pkg::hpdcache_user_cfg_t HPDcacheUserCfg = '\{.*?\n  \}",
                       lint_source, re.S).group(0).replace('HPDCACHE_NREQUESTERS', '1')
    for field, value in dict(paWidth=56, sets=256, clWords=2, accessWords=1,
                             reqTransIdWidth=3, memIdWidth=4, memDataWidth=64).items():
        config = re.sub(r'\b' + field + r':\s*\d+', field + ': ' + str(value), config)
    license_header = lint_source[:lint_source.index('`include')]
    params = config + ''',
  localparam hpdcache_cfg_t HPDcacheCfg = hpdcacheBuildConfig(HPDcacheUserCfg),
  localparam type hpdcache_nline_t = logic [HPDcacheCfg.nlineWidth-1:0],
  localparam type hpdcache_set_t = logic [HPDcacheCfg.setWidth-1:0],
  localparam type hpdcache_word_t = logic [HPDcacheCfg.clWordIdxWidth-1:0],
  localparam type hpdcache_way_vector_t = logic [HPDcacheCfg.u.ways-1:0],
  localparam type hpdcache_access_data_t = logic [HPDcacheCfg.accessWidth-1:0],
  localparam type hpdcache_mem_id_t = logic [HPDcacheCfg.u.memIdWidth-1:0],
  localparam type hpdcache_mem_data_t = logic [HPDcacheCfg.u.memDataWidth-1:0],
  localparam type mem_addr_t = logic [HPDcacheCfg.u.memAddrWidth-1:0],
  localparam type mem_be_t = logic [HPDcacheCfg.u.memDataWidth/8-1:0],
  localparam type hpdcache_mem_req_t = `HPDCACHE_DECL_MEM_REQ_T(mem_addr_t, hpdcache_mem_id_t),
  localparam type hpdcache_mem_req_w_t = `HPDCACHE_DECL_MEM_REQ_W_T(hpdcache_mem_data_t, mem_be_t),
  localparam type hpdcache_mem_resp_w_t = `HPDCACHE_DECL_MEM_RESP_W_T(hpdcache_mem_id_t)
'''
    ports = text[text.index('(\n    input  logic                  clk_i,'):text.index('\n);') + 3]
    names = re.findall(r'^\s*(?:input|output)\s+.*?\s+(\w+)\s*,?\s*$', ports, re.M)
    types = ['hpdcache_nline_t', 'hpdcache_set_t', 'hpdcache_word_t', 'hpdcache_way_vector_t',
             'hpdcache_access_data_t', 'hpdcache_mem_id_t', 'hpdcache_mem_data_t',
             'hpdcache_mem_req_t', 'hpdcache_mem_req_w_t', 'hpdcache_mem_resp_w_t']
    harness = license_header + '// 2026-11-14: Quan Nguyen and Codex - VLSI Technology page:\n'
    harness += '// Derived typed flush-only lint boundary; upstream license preserved.\n'
    harness += '`include "hpdcache_typedef.svh"\nmodule hpdcache_flush_lint import hpdcache_pkg::*; #(\n'
    harness += params + ')\n' + ports + '\n  hpdcache_flush #(\n    .HPDcacheCfg(HPDcacheCfg),\n'
    harness += ',\n'.join('    .' + name + '(' + name + ')' for name in types)
    harness += '\n  ) u_flush (\n' + ',\n'.join('    .' + name + '(' + name + ')' for name in names)
    harness += '\n  );\nendmodule\n'
    (report / 'hpdcache_flush_lint.sv').write_text(harness, encoding='utf-8', newline='\n')
    print(OUT)


if __name__ == '__main__':
    main()
