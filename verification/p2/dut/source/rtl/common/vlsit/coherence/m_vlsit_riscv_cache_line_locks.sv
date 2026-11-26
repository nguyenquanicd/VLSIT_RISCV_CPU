/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-14
 * Description  : Per-tag local cache line locks spanning PREPARE to terminal ACK.
 * Specification: REQ-MEM-006/009/012; no timeout, and no lock-table eviction.
 * Contract     : Per-tag lock vectors gate/replay CPU accesses and victim use.
 *                Already admitted refills must drain independently of these outputs.
 * History      : Quan Nguyen and Codex - VLSI Technology page.
 *                DEC-045: Add optional cluster boundary timing profile support.
 */
// 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
// DEC-038/A-02: separate registered native lock vectors from admission bypass.
`timescale 1ns/1ps

module m_vlsit_riscv_cache_line_locks #(
  // Parameter Description: maximum concurrent CCU probe contexts at this cache.
  // Parameter values: 2 through 16; default is 8.
  // Parameter unit: contexts.
  parameter logic [31:0] PARA_COH_TXN_NUM = 32'd8,
  // Parameter Description: register the release of handshake gates.
  // Parameter values: 0 = legacy, 1 = registered; default is 0.
  // Parameter unit: mode
  parameter logic [31:0] PARA_REGISTER_RESET_RELEASE = 32'd0,
  localparam logic [31:0] LPARA_COH_TAG_W = (PARA_COH_TXN_NUM > 32'd1)
                                           ? 32'($clog2(PARA_COH_TXN_NUM)) : 32'd1
) (
  // Clock and reset
  input  wire                               i_clk_cluster,
  input  wire                               i_rst_n_cluster,

  // PREPARE admission reserves a physical line before native probe execution
  input  wire                               i_acquire_valid,
  output logic                              o_acquire_ready,
  input  wire  [LPARA_COH_TAG_W-1:0]        i_acquire_tag,
  input  wire  [51:0]                       i_acquire_pa_line,

  // Accepted successful COMMIT/ABORT acknowledgement releases its matching lock
  input  wire                               i_release_valid,
  input  wire  [LPARA_COH_TAG_W-1:0]        i_release_tag,
  input  wire  [51:0]                       i_release_pa_line,
  output logic                              o_diag_event,

  // Valid-qualified cache admission and replacement observation queries.
  input  wire                               i_access_valid,
  input  wire  [51:0]                       i_access_pa_line,
  output logic                              o_access_locked,
  input  wire                               i_victim_valid,
  input  wire  [51:0]                       i_victim_pa_line,
  output logic                              o_victim_locked,
  output logic [PARA_COH_TXN_NUM-1:0]       o_line_lock_valid,
  output logic [PARA_COH_TXN_NUM-1:0][51:0] o_line_lock_pa_line
);

  logic w_handshake_active;

  // Clear immediately on reset and admit handshakes after the first active edge.
  if (PARA_REGISTER_RESET_RELEASE == 32'd1) begin : gen_reset_release
    logic reg_handshake_active;
    always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_reset_release
      if (!i_rst_n_cluster)
        reg_handshake_active <= 1'b0;
      else
        reg_handshake_active <= 1'b1;
    end
    assign w_handshake_active = reg_handshake_active;
  end else begin : gen_reset_direct
    assign w_handshake_active = i_rst_n_cluster;
  end

  logic [PARA_COH_TXN_NUM-1:0] reg_lock_valid;
  logic [PARA_COH_TXN_NUM-1:0][51:0] reg_lock_pa_line;
  logic w_acquire_tag_legal;
  logic w_acquire_slot_ready;
  logic w_acquire_conflict;
  logic w_acquire_take;
  logic w_release_match;

  // Reject an aliased tag or a second tag for the same locked line.
  always_comb begin : p_com_lock_admission
    w_acquire_tag_legal = (32'(i_acquire_tag) < PARA_COH_TXN_NUM);
    w_acquire_slot_ready = 1'b0;
    w_acquire_conflict = 1'b0;
    w_release_match = 1'b0;
    if (w_acquire_tag_legal)
      w_acquire_slot_ready = ~reg_lock_valid[i_acquire_tag]
                             | (reg_lock_pa_line[i_acquire_tag] == i_acquire_pa_line);
    if (32'(i_release_tag) < PARA_COH_TXN_NUM)
      w_release_match = reg_lock_valid[i_release_tag]
                         & (reg_lock_pa_line[i_release_tag] == i_release_pa_line);
    for (int slot_idx = 0; slot_idx < PARA_COH_TXN_NUM; slot_idx++) begin
      if (reg_lock_valid[slot_idx]
          & (reg_lock_pa_line[slot_idx] == i_acquire_pa_line)
          & (32'(i_acquire_tag) != 32'(slot_idx)))
        w_acquire_conflict = 1'b1;
    end
    o_acquire_ready = w_handshake_active & w_acquire_tag_legal
                       & w_acquire_slot_ready & ~w_acquire_conflict
                       & ~(i_release_valid & (i_release_tag == i_acquire_tag));
    o_diag_event = w_handshake_active
                    & ((i_release_valid & ~w_release_match)
                       | (i_acquire_valid & ~w_acquire_tag_legal));
  end

  // A repeated PREPARE for the same tag and line is idempotent.
  assign w_acquire_take = i_acquire_valid & o_acquire_ready;

  // Include an accepted incoming PREPARE to block a same-edge new CPU access/victim.
  always_comb begin : p_com_lock_queries
    o_access_locked = w_acquire_take & i_access_valid
                      & (i_access_pa_line == i_acquire_pa_line);
    o_victim_locked = w_acquire_take & i_victim_valid
                      & (i_victim_pa_line == i_acquire_pa_line);
    for (int slot_idx = 0; slot_idx < PARA_COH_TXN_NUM; slot_idx++) begin
      if (reg_lock_valid[slot_idx]) begin
        o_access_locked = o_access_locked
                          | (i_access_valid & (reg_lock_pa_line[slot_idx] == i_access_pa_line));
        o_victim_locked = o_victim_locked
                          | (i_victim_valid & (reg_lock_pa_line[slot_idx] == i_victim_pa_line));
      end
    end
  end

  // Native pipeline admission is checked before PREPARE acceptance. Publish
  // registered locks to that pipeline; feeding same-edge acquisition back into
  // its admission query would form a combinational busy/acquire dependency.
  assign o_line_lock_valid = reg_lock_valid;
  assign o_line_lock_pa_line = reg_lock_pa_line;

  // Failed PREPARE does not release a lock; only a matching terminal ACK or reset does.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_line_locks
    if (!i_rst_n_cluster) begin
      reg_lock_valid <= '0;
      reg_lock_pa_line <= '0;
    end else begin
      if (w_acquire_take) begin
        reg_lock_valid[i_acquire_tag] <= 1'b1;
        reg_lock_pa_line[i_acquire_tag] <= i_acquire_pa_line;
      end
      if (i_release_valid & w_release_match)
        reg_lock_valid[i_release_tag] <= 1'b0;
    end
  end

endmodule
