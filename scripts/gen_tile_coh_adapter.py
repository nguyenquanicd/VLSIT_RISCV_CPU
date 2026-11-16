"""Generate the approved tile ownership/probe boundary without upstream edits."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'rtl/common/vlsit/coherence/m_vlsit_riscv_tile_coh_adapter.sv'


def main():
    if OUT.exists():
        raise RuntimeError('Output already exists; review edits before regeneration')
    req = [('id', '[2:0]'), ('pa_line', '[51:0]'), ('kind', '[1:0]')]
    gnt = [('id', '[2:0]'), ('pa_line', '[51:0]'), ('state', '[1:0]'), ('err', '')]
    probe = [('tag', '[LPARA_COH_TAG_W-1:0]'), ('pa_line', '[51:0]'),
             ('phase', '[1:0]'), ('target_state', '[1:0]'), ('wback_en', '')]
    response = [('tag', '[LPARA_COH_TAG_W-1:0]'), ('pa_line', '[51:0]'),
                ('phase', '[1:0]'), ('state', '[1:0]'), ('err', ''), ('wback_done', '')]
    groups = [('Clock and reset', [('input', '', 'i_clk_cluster'), ('input', '', 'i_rst_n_cluster')])]
    groups.append(('Native access/victim exclusion queries; admitted refills must drain', [
        ('input', '[51:0]', 'i_cache_access_pa_line'),
        ('output', '', 'o_cache_access_locked'),
        ('input', '[51:0]', 'i_cache_victim_pa_line'),
        ('output', '', 'o_cache_victim_locked'),
        ('output', '', 'o_lock_diag_event'),
    ]))
    for label, src, dst, fields in [
        ('Cache ownership request; one elastic entry', 'cache_req', 'req', req),
        ('Fabric permission gnt; one elastic entry', 'gnt', 'cache_gnt', gnt),
        ('Tagged probe request; transparent handshake', 'probe_req', 'cache_probe_req', probe),
        ('Tagged probe response; transparent handshake', 'cache_probe_rsp', 'probe_rsp', response),
    ]:
        rows = [('input', '', 'i_' + src + '_valid'), ('output', '', 'o_' + src + '_ready')]
        rows += [('input', width, 'i_' + src + '_' + name) for name, width in fields]
        rows += [('output', '', 'o_' + dst + '_valid'), ('input', '', 'i_' + dst + '_ready')]
        rows += [('output', width, 'o_' + dst + '_' + name) for name, width in fields]
        groups.append((label, rows))
    lines = ['/*', ' * Project      : VLSIT RISC-V CPU Cluster',
             ' * Author       : Quan Nguyen (user)',
             ' * AI Flow      : VLSIT RTL Generator AI Automation Flow',
             ' * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model',
             ' * Date         : 2026-11-14',
             ' * Description  : Elastic ownership/gnt boundary and transparent tagged probes.',
             ' * Specification: REQ-MEM-006/009/012/015; approved Plan V3 tile boundary.',
             ' * Contract     : Native HPDcache must apply access/victim exclusion queries.',
             ' *                Already admitted refills must drain independently of locks.',
             ' * Change History:',
             ' * 2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:',
             ' *              Acquire tagged line locks on PREPARE admission; release only',
             ' *              on accepted successful COMMIT/ABORT responses.',
             ' * Rule note    : HIE-02: functional adapter combines transport RTL and lock instance.',
             ' */', '`timescale 1ns/1ps', '',
             'module m_vlsit_riscv_tile_coh_adapter #(',
             '  // Parameter Description: number of CCU contexts sizing the internal probe tag.',
             '  // Parameter values: 2 through 16; default is 8.',
             '  // Parameter unit: contexts.',
             "  parameter logic [31:0] PARA_COH_TXN_NUM = 32'd8,",
             "  localparam logic [31:0] LPARA_COH_TAG_W = (PARA_COH_TXN_NUM > 32'd1)",
             "                                           ? 32'($clog2(PARA_COH_TXN_NUM)) : 32'd1,",
             "  localparam logic [31:0] LPARA_PHASE_PREPARE = 32'd0,",
             "  localparam logic [31:0] LPARA_PHASE_COMMIT = 32'd1,",
             "  localparam logic [31:0] LPARA_PHASE_ABORT = 32'd2", ') (']
    max_width = max(len(width) for _, rows in groups for _, width, _ in rows)
    for label, rows in groups:
        lines += ['  // ' + label]
        for direction, width, name in rows:
            dtype = 'wire' if direction == 'input' else 'logic'
            lines.append(f'  {direction:<6} {dtype:<5} {width:<{max_width}} {name},')
        lines.append('')
    lines[-2] = lines[-2].rstrip(',')
    lines += [');', '', '  // Elastic payloads hold their fields while their consumer is stalled.']
    for prefix, fields in [('req', req), ('gnt', gnt)]:
        lines.append(f'  logic reg_{prefix}_valid;')
        lines += [f'  logic {width + " " if width else ""}reg_{prefix}_{name};' for name, width in fields]
    lines += ['  logic w_lock_acquire_ready;', '  logic w_lock_acquire_valid;',
              '  logic w_lock_release_valid;', '  logic w_probe_req_allow;', '',
              '  // Admit PREPARE only when the local tag/line lock can be reserved.',
              "  assign w_probe_req_allow = (32'(i_probe_req_phase) != LPARA_PHASE_PREPARE)",
              '                             | w_lock_acquire_ready;',
              '  // Reserve a line only on the actual cache-side PREPARE handshake.',
              '  assign w_lock_acquire_valid = i_probe_req_valid & i_cache_probe_req_ready',
              "                                 & (32'(i_probe_req_phase) == LPARA_PHASE_PREPARE)",
              '                                 & i_rst_n_cluster;',
              '  // Retain the lock across PREPARE errors and terminal-response backpressure.',
              '  assign w_lock_release_valid = i_cache_probe_rsp_valid & o_cache_probe_rsp_ready',
              '                                 & ~i_cache_probe_rsp_err',
              "                                 & ((32'(i_cache_probe_rsp_phase) == LPARA_PHASE_COMMIT)",
              "                                    | (32'(i_cache_probe_rsp_phase) == LPARA_PHASE_ABORT));"]
    for prefix, src, dst, fields in [('req', 'cache_req', 'req', req), ('gnt', 'gnt', 'cache_gnt', gnt)]:
        lines += ['', f'  // Replace a consumed {prefix} entry on the same edge for one transfer per cycle.',
                  f'  assign o_{src}_ready = i_rst_n_cluster & (~reg_{prefix}_valid | i_{dst}_ready);',
                  f'  assign o_{dst}_valid = reg_{prefix}_valid;']
        lines += [f'  assign o_{dst}_{name} = reg_{prefix}_{name};' for name, _ in fields]
    for src, dst, fields in [('probe_req', 'cache_probe_req', probe), ('cache_probe_rsp', 'probe_rsp', response)]:
        gate = ' & w_probe_req_allow' if src == 'probe_req' else ''
        lines += ['', '  // Preserve probe identity and phase; endpoint storage owns backpressure.',
                  f'  assign o_{dst}_valid = i_{src}_valid & i_rst_n_cluster{gate};',
                  f'  assign o_{src}_ready = i_{dst}_ready & i_rst_n_cluster{gate};']
        lines += [f'  assign o_{dst}_{name} = i_{src}_{name};' for name, _ in fields]
    for prefix, src, fields in [('req', 'cache_req', req), ('gnt', 'gnt', gnt)]:
        lines += ['', f'  // Store the {prefix} payload only on its source handshake.',
                  f'  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_{prefix}_entry',
                  '    if (!i_rst_n_cluster) begin', f"      reg_{prefix}_valid <= 1'b0;"]
        lines += [f"      reg_{prefix}_{name} <= '0;" for name, _ in fields]
        lines += [f'    end else if (o_{src}_ready) begin',
                  f'      reg_{prefix}_valid <= i_{src}_valid;', f'      if (i_{src}_valid) begin']
        lines += [f'        reg_{prefix}_{name} <= i_{src}_{name};' for name, _ in fields]
        lines += ['      end', '    end', '  end']
    lines += ['', '  // One local lock record per CCU tag; no timeout or forced replacement.',
              '  m_vlsit_riscv_cache_line_locks #(',
              '    .PARA_COH_TXN_NUM(PARA_COH_TXN_NUM)',
              '  ) u_vlsit_riscv_cache_line_locks (',
              '    .i_clk_cluster(i_clk_cluster),',
              '    .i_rst_n_cluster(i_rst_n_cluster),',
              '    .i_acquire_valid(w_lock_acquire_valid),',
              '    .o_acquire_ready(w_lock_acquire_ready),',
              '    .i_acquire_tag(i_probe_req_tag),',
              '    .i_acquire_pa_line(i_probe_req_pa_line),',
              '    .i_release_valid(w_lock_release_valid),',
              '    .i_release_tag(i_cache_probe_rsp_tag),',
              '    .i_release_pa_line(i_cache_probe_rsp_pa_line),',
              '    .o_diag_event(o_lock_diag_event),',
              '    .i_access_pa_line(i_cache_access_pa_line),',
              '    .o_access_locked(o_cache_access_locked),',
              '    .i_victim_pa_line(i_cache_victim_pa_line),',
              '    .o_victim_locked(o_cache_victim_locked)',
              '  );', '', 'endmodule', '']
    OUT.write_text('\n'.join(lines), encoding='utf-8', newline='\n')
    print(OUT)


if __name__ == '__main__':
    main()
