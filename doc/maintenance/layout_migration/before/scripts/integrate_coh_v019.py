"""Apply the approved v0.19 leaves and explicit PREPARE writeback policy once."""
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[1]
DST = ROOT / 'rtl/vlsit'
SRC = ROOT / 'rtl_v019_delta/rtl/vlsit'
BASE = ROOT / 'rtl/reports/full_integration/baseline'
NAMES = ['m_vlsit_riscv_coh_txn_table', 'm_vlsit_riscv_probe_scheduler',
         'm_vlsit_riscv_coh_bank_arb', 'm_vlsit_riscv_sharer_directory']


def replace(text, before, after):
    if text.count(before) != 1:
        raise RuntimeError('Source mapping is not unique: ' + before)
    return text.replace(before, after)


def main():
    if BASE.exists():
        raise RuntimeError('Baseline exists; inspect current sources before repeating migration')
    texts = {name: (SRC / (name + '.sv')).read_text(encoding='utf-8') for name in NAMES}
    name = NAMES[0]
    text = texts[name]
    for before, after in [
        ('  input  wire  [1:0]                                    i_alloc_target_state,',
         '  input  wire  [1:0]                                    i_alloc_target_state,\n'
         '  input  wire                                           i_alloc_wback_en,'),
        ('  output logic [PARA_COH_TXN_NUM-1:0][1:0]              o_ctx_target_state,',
         '  output logic [PARA_COH_TXN_NUM-1:0][1:0]              o_ctx_target_state,\n'
         '  output logic [PARA_COH_TXN_NUM-1:0]                   o_ctx_wback_en,'),
        ('  logic [PARA_COH_TXN_NUM-1:0][1:0] reg_ctx_target_state;',
         '  logic [PARA_COH_TXN_NUM-1:0][1:0] reg_ctx_target_state;\n'
         '  logic [PARA_COH_TXN_NUM-1:0] reg_ctx_wback_en;'),
        ('  assign o_ctx_target_state = reg_ctx_target_state;',
         '  assign o_ctx_target_state = reg_ctx_target_state;\n'
         '  assign o_ctx_wback_en = reg_ctx_wback_en;'),
        ("      reg_ctx_target_state <= '0;", "      reg_ctx_target_state <= '0;\n      reg_ctx_wback_en <= '0;"),
        ('          reg_ctx_target_state[slot_idx] <= i_alloc_target_state;',
         '          reg_ctx_target_state[slot_idx] <= i_alloc_target_state;\n'
         '          reg_ctx_wback_en[slot_idx] <= i_alloc_wback_en;'),
    ]:
        text = replace(text, before, after)
    texts[name] = text
    name = NAMES[1]
    text = texts[name]
    for before, after in [
        ('  input  wire  [PARA_COH_TXN_NUM-1:0][1:0]              i_ctx_target_state,',
         '  input  wire  [PARA_COH_TXN_NUM-1:0][1:0]              i_ctx_target_state,\n'
         '  input  wire  [PARA_COH_TXN_NUM-1:0]                   i_ctx_wback_en,'),
        ('  output logic [PARA_CPU_NUM-1:0][1:0]                  o_probe_req_target_state,',
         '  output logic [PARA_CPU_NUM-1:0][1:0]                  o_probe_req_target_state,\n'
         '  output logic [PARA_CPU_NUM-1:0]                       o_probe_req_wback_en,'),
        ('  logic [PARA_CPU_NUM-1:0][1:0] reg_req_target_state;',
         '  logic [PARA_CPU_NUM-1:0][1:0] reg_req_target_state;\n'
         '  logic [PARA_CPU_NUM-1:0] reg_req_wback_en;'),
        ('  assign o_probe_req_target_state = reg_req_target_state;',
         '  assign o_probe_req_target_state = reg_req_target_state;\n'
         '  assign o_probe_req_wback_en = reg_req_wback_en;'),
        ("      reg_req_target_state <= '0;", "      reg_req_target_state <= '0;\n      reg_req_wback_en <= '0;"),
        ('          reg_req_target_state[hart_idx] <= i_ctx_target_state[w_pick_tag[hart_idx]];',
         '          reg_req_target_state[hart_idx] <= i_ctx_target_state[w_pick_tag[hart_idx]];\n'
         '          reg_req_wback_en[hart_idx] <= i_ctx_wback_en[w_pick_tag[hart_idx]]\n'
         "                                         & (i_ctx_phase[w_pick_tag[hart_idx]] == 2'd0);"),
    ]:
        text = replace(text, before, after)
    texts[name] = text
    BASE.mkdir(parents=True)
    for name, text in texts.items():
        path = DST / (name + '.sv')
        shutil.copy2(path, BASE / path.name)
        if name in NAMES[:2]:
            text = replace(text, ' * Change History:',
                ' * Change History:\n'
                ' * 2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:\n'
                ' *              Retain/forward explicit PREPARE writeback enable;\n'
                ' *              true INVAL disables writeback (REQ-MEM-015, DEC-028).')
        path.write_text(text, encoding='utf-8', newline='\n')
        print('Integrated ' + path.name)


if __name__ == '__main__':
    main()
