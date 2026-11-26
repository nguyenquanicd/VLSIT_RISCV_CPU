/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-14
 * Description  : MESI ownership fabric joining transaction, directory, and probe blocks.
 * Specification: REQ-MEM-001, REQ-MEM-005, REQ-MEM-006, REQ-MEM-009, REQ-MEM-012..014
 * Change History:
 * 2026-11-20 - Modified by Quan Nguyen and Codex - VLSI Technology page:
 *              Move module-scope signal declarations ahead of first use for
 *              stricter SystemVerilog front-end compatibility (R-03).
 * 2026-11-15 - Modified by Quan Nguyen and Codex - VLSI Technology page:
 *              A-05: reserve one victim context credit, bind child allocation
 *              to the selected parent, cancel/retry victim-line conflicts
 *              before waiting (REQ-MEM-009/010/014/019; TEST-053).
 * 2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *              Size dynamic hart-vector indices to the configured hart count
 *              so the two-hart profile does not truncate 2-bit selectors.
 * 2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *              Implement tagged cache permission flow and safe directory replacement.
 * 2026-11-14 - Quan Nguyen and Codex - VLSI Technology page:
 *              Preserve failed PREPARE/writeback status through ABORT and return
 *              an error grant to the CPU requester; propagate victim-child failure.
 * Rule note    : DEC-028 true CBO.INVAL is handled by the maintenance integration.
 * History      : Quan Nguyen and Codex - VLSI Technology page.
 *                DEC-045: Add optional cluster boundary timing profile support.
 */
// 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
// REQ-MEM-001/012/017: qualify silent E-to-M at the unique owner, retain
// PREPARE state for ABORT, and require completed dirty-owner writeback.
// 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
// DEC-038/A-02: only the selected tag may consume a directory lookup handshake.
// 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
// DEC-013/A-04: validate absent-holder I, prune only committed holders,
// and preserve actual PREPARE state for terminal ACK validation.
`timescale 1ns/1ps

// 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
// Size maintenance source comparisons to the native three-bit context field.
// 2026-11-15 - Quan Nguyen and Codex - VLSI Technology page:
// DEC-030/031: retain FENCE.I through coherent clean completion and precise fault.
// Change: Add private-owner M-to-E FENCE transition while preserving unrelated/shared holders.
module m_vlsit_riscv_coh_fabric #(
  // Parameter Description: number of active CPU hart request and probe lanes.
  // Parameter values: 2 or 4; default is 4.
  // Parameter unit: harts.
  parameter logic [31:0] PARA_CPU_NUM = 32'd4,
  // Parameter Description: enable the internal CMO service interface.
  // Parameter values: 0 or 1; default 0 until service integration.
  // Parameter unit: none.
  parameter logic [31:0] PARA_CMO_EN = 32'd0,
  // Parameter Description: number of independent tagged ownership contexts.
  // Parameter values: 2 through 16; default is 8.
  // Parameter unit: contexts.
  parameter logic [31:0] PARA_COH_TXN_NUM = 32'd8,
  // Parameter Description: use synchronous directory storage.
  // Parameter values: 0 = legacy, 1 = synchronous; default is 0.
  // Parameter unit: mode
  parameter logic [31:0] PARA_DIR_SYNC_READ = 32'd0,
  localparam logic [31:0] LPARA_COH_TAG_W = (PARA_COH_TXN_NUM > 32'd1)
                                           ? 32'($clog2(PARA_COH_TXN_NUM)) : 32'd1,
  localparam logic [31:0] LPARA_COH_SLOT_W = (PARA_COH_TXN_NUM > 32'd1)
                                            ? 32'($clog2(PARA_COH_TXN_NUM)) : 32'd1,
  localparam logic [31:0] LPARA_CPU_IDX_W = (PARA_CPU_NUM > 32'd1)
                                            ? 32'($clog2(PARA_CPU_NUM)) : 32'd1,
  localparam logic [31:0] LPARA_MESI_I = 32'd0,
  localparam logic [31:0] LPARA_MESI_S = 32'd1,
  localparam logic [31:0] LPARA_MESI_E = 32'd2,
  localparam logic [31:0] LPARA_MESI_M = 32'd3,
  localparam logic [31:0] LPARA_REQ_SHARED = 32'd0,
  localparam logic [31:0] LPARA_REQ_EXCLUSIVE = 32'd1,
  localparam logic [31:0] LPARA_REQ_EVICT = 32'd7,
  localparam logic [31:0] LPARA_PHASE_PREPARE = 32'd0,
  localparam logic [31:0] LPARA_PHASE_COMMIT = 32'd1,
  localparam logic [31:0] LPARA_PHASE_ABORT = 32'd2,
  localparam logic [31:0] LPARA_SRC_CPU = 32'd0,
  localparam logic [31:0] LPARA_SRC_CMO = 32'd1,
  localparam logic [31:0] LPARA_REQ_CMO = 32'd2,
  localparam logic [31:0] LPARA_CMO_FENCE = 32'd3,
  localparam logic [31:0] LPARA_CMO_OP_COUNT = 32'd4,
  localparam logic [31:0] LPARA_SRC_EVICT = 32'd7
) (
  // Clock and reset
  input  wire                                          i_clk_cluster,
  input  wire                                          i_rst_n_cluster,

  // Shared CMO controller service; contexts and locks remain in this fabric.
  input  wire                                          i_ccu_begin_valid,
  output logic                                         o_ccu_begin_ready,
  input  wire  [1:0]                                   i_ccu_begin_op,
  input  wire  [51:0]                                  i_ccu_begin_pa_line,
  input  wire  [1:0]                                   i_ccu_begin_hart,
  input  wire                                          i_ccu_begin_wback_en,
  output logic                                         o_ccu_prepare_valid,
  input  wire                                          i_ccu_prepare_ready,
  output logic [LPARA_COH_TAG_W-1:0]                   o_ccu_prepare_tag,
  output logic                                         o_ccu_prepare_err,
  input  wire                                          i_ccu_finish_valid,
  output logic                                         o_ccu_finish_ready,
  input  wire  [LPARA_COH_TAG_W-1:0]                   i_ccu_finish_tag,
  input  wire                                          i_ccu_finish_commit,
  output logic                                         o_ccu_finish_done,

  // Per-hart ownership request and grant
  input  wire  [PARA_CPU_NUM-1:0]                      i_req_valid,
  output logic [PARA_CPU_NUM-1:0]                      o_req_ready,
  input  wire  [PARA_CPU_NUM-1:0][2:0]                 i_req_id,
  input  wire  [PARA_CPU_NUM-1:0][51:0]                i_req_pa_line,
  input  wire  [PARA_CPU_NUM-1:0][1:0]                 i_req_kind,
  output logic [PARA_CPU_NUM-1:0]                      o_gnt_valid,
  input  wire  [PARA_CPU_NUM-1:0]                      i_gnt_ready,
  output logic [PARA_CPU_NUM-1:0][2:0]                 o_gnt_req_id,
  output logic [PARA_CPU_NUM-1:0][51:0]                o_gnt_pa_line,
  output logic [PARA_CPU_NUM-1:0][1:0]                 o_gnt_state,
  output logic [PARA_CPU_NUM-1:0]                      o_gnt_err,

  // Tagged per-hart PREPARE, COMMIT, and ABORT probe channels
  output logic [PARA_CPU_NUM-1:0]                      o_probe_req_valid,
  input  wire  [PARA_CPU_NUM-1:0]                      i_probe_req_ready,
  output logic [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0] o_probe_req_tag,
  output logic [PARA_CPU_NUM-1:0][51:0]                o_probe_req_pa_line,
  output logic [PARA_CPU_NUM-1:0][1:0]                 o_probe_req_phase,
  output logic [PARA_CPU_NUM-1:0][1:0]                 o_probe_req_target_state,
  output logic [PARA_CPU_NUM-1:0]                      o_probe_req_wback_en,
  input  wire  [PARA_CPU_NUM-1:0]                      i_probe_rsp_valid,
  output logic [PARA_CPU_NUM-1:0]                      o_probe_rsp_ready,
  input  wire  [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0] i_probe_rsp_tag,
  input  wire  [PARA_CPU_NUM-1:0][51:0]                i_probe_rsp_pa_line,
  input  wire  [PARA_CPU_NUM-1:0][1:0]                 i_probe_rsp_phase,
  input  wire  [PARA_CPU_NUM-1:0][1:0]                 i_probe_rsp_state,
  input  wire  [PARA_CPU_NUM-1:0]                      i_probe_rsp_err,
  input  wire  [PARA_CPU_NUM-1:0]                      i_probe_rsp_wback_done,
  input  wire                                          i_same_line_lock_stall,

  // Diagnostic and PMU events
  output logic                                         o_coh_proto_diag_event,
  output logic [2:0]                                   o_dir_lookup_count,
  output logic [2:0]                                   o_dir_update_count,
  output logic [11:0][2:0]                             o_ccu_evt_count
);

  // Each context runs one MESI transaction or one internal victim-invalidation transaction.
  typedef enum logic [4:0] {
    ENUM_ST_IDLE = 5'b00000,
    ENUM_ST_DIR_REQ = 5'b00001,
    ENUM_ST_DIR_WAIT = 5'b00010,
    ENUM_ST_EVICT_ALLOC = 5'b00011,
    ENUM_ST_EVICT_WAIT = 5'b00100,
    ENUM_ST_OWNER = 5'b00101,
    ENUM_ST_PREP_START = 5'b00110,
    ENUM_ST_PREP_WAIT = 5'b00111,
    ENUM_ST_COMMIT_START = 5'b01000,
    ENUM_ST_COMMIT_WAIT = 5'b01001,
    ENUM_ST_ABORT_START = 5'b01010,
    ENUM_ST_ABORT_WAIT = 5'b01011,
    ENUM_ST_DIR_UPDATE = 5'b01100,
    ENUM_ST_DIR_CANCEL = 5'b01101,
    ENUM_ST_GNT = 5'b01110,
    ENUM_ST_GNT_WAIT = 5'b01111,
    ENUM_ST_CMO_PREPARED = 5'd16,
    ENUM_ST_CMO_FINISH = 5'd17,
    ENUM_ST_RETRY_CANCEL = 5'd18
  } coh_state_type_def;

  // Context storage keeps target/victim metadata through probe backpressure and replacement.
  coh_state_type_def reg_fsm_ctx_current_state [PARA_COH_TXN_NUM-1:0];
  coh_state_type_def w_fsm_ctx_nxt_state [PARA_COH_TXN_NUM-1:0];
  logic [PARA_COH_TXN_NUM-1:0] reg_ctx_is_victim;
  logic [PARA_COH_TXN_NUM-1:0] reg_ctx_dir_reserved;
  logic [PARA_COH_TXN_NUM-1:0] reg_ctx_victim_valid;
  logic [PARA_COH_TXN_NUM-1:0][1:0] reg_ctx_hart;
  logic [PARA_COH_TXN_NUM-1:0][1:0] reg_ctx_gnt_state;
  logic [PARA_COH_TXN_NUM-1:0][2:0] reg_ctx_dir_way;
  logic [PARA_COH_TXN_NUM-1:0][PARA_CPU_NUM-1:0] reg_ctx_probe_holders;
  logic [PARA_COH_TXN_NUM-1:0][PARA_CPU_NUM-1:0] reg_ctx_new_holders;
  logic [PARA_COH_TXN_NUM-1:0][1:0] reg_ctx_old_owner;
  logic [PARA_COH_TXN_NUM-1:0][1:0] reg_ctx_new_owner;
  logic [PARA_COH_TXN_NUM-1:0][1:0] reg_ctx_old_state;
  logic [PARA_COH_TXN_NUM-1:0][51:0] reg_ctx_victim_line;
  logic [PARA_COH_TXN_NUM-1:0][PARA_CPU_NUM-1:0] reg_ctx_victim_holders;
  logic [PARA_COH_TXN_NUM-1:0][1:0] reg_ctx_victim_owner;
  logic [PARA_COH_TXN_NUM-1:0][1:0] reg_ctx_victim_state;
  logic [PARA_COH_TXN_NUM-1:0][LPARA_COH_TAG_W-1:0] reg_ctx_parent_tag;
  logic [PARA_COH_TXN_NUM-1:0] reg_ctx_gnt_err;
  logic [PARA_COH_TXN_NUM-1:0] reg_ctx_gnt_accepted;

  // Transaction-table interface
  logic w_alloc_valid;
  logic w_alloc_ready;
  logic w_table_alloc_ready;
  logic w_free_seen;
  logic w_root_alloc_en;
  logic [PARA_COH_TXN_NUM-1:0] w_victim_line_busy;
  logic [2:0] w_alloc_src;
  logic [2:0] w_alloc_req_id;
  logic [51:0] w_alloc_pa_line;
  logic [1:0] w_alloc_kind;
  logic [1:0] w_alloc_target_state;
  logic w_alloc_wback_en;
  logic [LPARA_COH_TAG_W-1:0] w_alloc_tag;
  logic w_release_valid;
  logic [LPARA_COH_TAG_W-1:0] w_release_tag;
  logic w_release_ready;
  logic w_phase_start_valid;
  logic [LPARA_COH_TAG_W-1:0] w_phase_start_tag;
  logic [1:0] w_phase_start_phase;
  logic [PARA_CPU_NUM-1:0] w_phase_expected;
  logic w_phase_start_ready;
  logic w_owner_capture_valid;
  logic [LPARA_COH_TAG_W-1:0] w_owner_capture_tag;
  logic w_owner_capture_present;
  logic [1:0] w_owner_capture_hart;
  logic w_owner_capture_ready;
  logic [PARA_COH_TXN_NUM-1:0] w_ctx_valid;
  logic [PARA_COH_TXN_NUM-1:0][2:0] w_ctx_src;
  logic [PARA_COH_TXN_NUM-1:0][2:0] w_ctx_req_id;
  logic [PARA_COH_TXN_NUM-1:0][51:0] w_ctx_pa_line;
  logic [PARA_COH_TXN_NUM-1:0][1:0] w_ctx_kind;
  logic [PARA_COH_TXN_NUM-1:0][1:0] w_ctx_phase;
  logic [PARA_COH_TXN_NUM-1:0][PARA_CPU_NUM-1:0] w_ctx_ack_expected;
  logic [PARA_COH_TXN_NUM-1:0][PARA_CPU_NUM-1:0] w_ctx_ack_received;
  logic [PARA_COH_TXN_NUM-1:0] w_ctx_phase_active;
  logic [PARA_COH_TXN_NUM-1:0] w_ctx_phase_done;
  logic [PARA_COH_TXN_NUM-1:0] w_ctx_phase_err;
  logic [PARA_COH_TXN_NUM-1:0] w_ctx_owner_wback_done;
  logic [PARA_COH_TXN_NUM-1:0][1:0] w_ctx_target_state;
  logic [PARA_COH_TXN_NUM-1:0] w_ctx_wback_en;
  logic [PARA_COH_TXN_NUM-1:0] w_ctx_txn_err;
  logic [PARA_COH_TXN_NUM-1:0] w_ctx_owner_wback_err;
  logic [PARA_COH_TXN_NUM-1:0] w_ctx_owner_known;
  logic [PARA_COH_TXN_NUM-1:0] w_ctx_owner_present;
  logic [PARA_COH_TXN_NUM-1:0][1:0] w_ctx_owner_hart;
  logic [PARA_CPU_NUM-1:0] w_ack_valid;
  logic [PARA_CPU_NUM-1:0] w_ack_ready;
  logic [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0] w_ack_tag;
  logic [PARA_CPU_NUM-1:0][1:0] w_ack_phase;
  logic [PARA_CPU_NUM-1:0] w_ack_err;
  logic [PARA_CPU_NUM-1:0] w_ack_sched_err;
  logic [PARA_CPU_NUM-1:0][1:0] w_ack_state;
  logic w_ack_state_diag;
  logic [PARA_CPU_NUM-1:0] w_ack_wback_done;
  logic [PARA_CPU_NUM-1:0] w_ack_eligible;
  logic [PARA_CPU_NUM-1:0] w_ack_prepare_state_valid;
  logic [PARA_CPU_NUM-1:0] w_ack_writeback_complete;
  logic [PARA_COH_TXN_NUM-1:0][PARA_CPU_NUM-1:0] reg_ctx_prepared_valid;
  logic [PARA_COH_TXN_NUM-1:0][PARA_CPU_NUM-1:0][1:0] reg_ctx_prepared_state;
  logic [PARA_CPU_NUM-1:0] w_probe_diag;
  logic w_table_diag;

  // Directory and bank-scheduler interfaces
  logic [PARA_COH_TXN_NUM-1:0] w_bank_req_valid;
  logic [PARA_COH_TXN_NUM-1:0][1:0] w_bank_req_bank;
  logic [3:0] w_bank_gnt_valid;
  logic [3:0][LPARA_COH_SLOT_W-1:0] w_bank_gnt_slot;
  logic [3:0] w_bank_gnt_ready;
  logic [3:0] w_dir_lookup_valid;
  logic [3:0] w_dir_lookup_ready;
  logic [3:0][51:0] w_dir_lookup_line;
  logic [3:0][LPARA_COH_TAG_W-1:0] w_dir_lookup_tag;
  logic [3:0] w_dir_lookup_rsp_valid;
  logic [3:0] w_dir_lookup_rsp_ready;
  logic [3:0] w_dir_lookup_hit;
  logic [3:0][LPARA_COH_TAG_W-1:0] w_dir_lookup_rsp_tag;
  logic [3:0][2:0] w_dir_lookup_way;
  logic [3:0] w_dir_victim_valid;
  logic [3:0][51:0] w_dir_victim_line;
  logic [3:0][PARA_CPU_NUM-1:0] w_dir_lookup_holders;
  logic [3:0][1:0] w_dir_lookup_owner;
  logic [3:0][1:0] w_dir_lookup_state;
  logic [3:0] w_dir_update_valid;
  logic [3:0] w_dir_update_ready;
  logic [3:0][LPARA_COH_TAG_W-1:0] w_dir_update_tag;
  logic [3:0][51:0] w_dir_update_line;
  logic [3:0][2:0] w_dir_update_way;
  logic [3:0][PARA_CPU_NUM-1:0] w_dir_update_holders;
  logic [3:0][1:0] w_dir_update_owner;
  logic [3:0][1:0] w_dir_update_state;
  logic [3:0] w_dir_cancel_valid;
  logic [3:0] w_dir_cancel_ready;
  logic [3:0][LPARA_COH_TAG_W-1:0] w_dir_cancel_tag;
  logic [3:0][51:0] w_dir_cancel_line;
  logic [3:0] w_dir_diag;
  logic w_bank_conflict_stall;

  // Per-hart grant holding registers preserve VALID payload under backpressure.
  logic [PARA_CPU_NUM-1:0] reg_gnt_valid;
  logic [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0] reg_gnt_tag;
  logic [PARA_CPU_NUM-1:0][2:0] reg_gnt_req_id;
  logic [PARA_CPU_NUM-1:0][51:0] reg_gnt_line;
  logic [PARA_CPU_NUM-1:0][1:0] reg_gnt_state;
  logic [PARA_CPU_NUM-1:0] reg_gnt_err;
  logic [PARA_CPU_NUM-1:0] w_gnt_load;
  logic [PARA_CPU_NUM-1:0][LPARA_COH_TAG_W-1:0] w_gnt_load_tag;
  logic [PARA_CPU_NUM-1:0] w_gnt_hs;

  // Operation selection signals
  logic w_req_pick_valid;
  logic [1:0] w_req_pick_hart;
  logic [1:0] reg_req_rr_hart;
  logic [31:0] w_req_scan_hart;
  logic w_internal_pick_valid;
  logic [LPARA_COH_TAG_W-1:0] w_internal_parent_tag;
  logic [PARA_COH_TXN_NUM-1:0] w_lookup_rsp_hs;
  logic [3:0] w_lookup_rsp_accept;
  logic [PARA_COH_TXN_NUM-1:0] w_release_hs;
  logic w_phase_start_hs;
  logic w_owner_capture_hs;
  logic [3:0] w_update_pick_valid;
  logic [3:0] w_cancel_pick_valid;
  logic [3:0] w_update_hs;
  logic [3:0] w_cancel_hs;
  logic w_req_kind_valid;
  logic w_lookup_diag_event;

  logic reg_cmo_active;
  logic [LPARA_COH_TAG_W-1:0] reg_cmo_tag;
  logic [PARA_COH_TXN_NUM-1:0] reg_ctx_cmo_dir_hit;
  logic w_cmo_alloc_pick;
  // Select one maintenance context after victim service.
  assign w_cmo_alloc_pick = (PARA_CMO_EN != 0) && i_ccu_begin_valid
                            && !reg_cmo_active && !w_internal_pick_valid
                            && (32'(i_ccu_begin_op) < LPARA_CMO_OP_COUNT)
                            && (32'(i_ccu_begin_hart) < PARA_CPU_NUM);
  // Accept only legal requests while the shared service is free.
  assign o_ccu_begin_ready = (PARA_CMO_EN != 0) && !reg_cmo_active
                             && !w_internal_pick_valid && w_alloc_ready
                             && (32'(i_ccu_begin_op) < LPARA_CMO_OP_COUNT)
                             && (32'(i_ccu_begin_hart) < PARA_CPU_NUM);
  // Hold PREPARE completion until the controller accepts it.
  assign o_ccu_prepare_valid = reg_cmo_active &&
      (reg_fsm_ctx_current_state[reg_cmo_tag] == ENUM_ST_CMO_PREPARED);
  // Return the retained transaction identity and status.
  assign o_ccu_prepare_tag = reg_cmo_tag;
  assign o_ccu_prepare_err = reg_ctx_gnt_err[reg_cmo_tag];
  // Match terminal commands to the retained prepared transaction.
  assign o_ccu_finish_ready = reg_cmo_active &&
      (reg_fsm_ctx_current_state[reg_cmo_tag] == ENUM_ST_CMO_FINISH)
      && (i_ccu_finish_tag == reg_cmo_tag);
  // Complete only after the native context and lock are released.
  assign o_ccu_finish_done = reg_cmo_active &&
      (reg_fsm_ctx_current_state[reg_cmo_tag] == ENUM_ST_GNT)
      && w_release_hs[reg_cmo_tag];
  // Retain maintenance ownership and directory-hit metadata through terminal ACKs.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_cmo_service
    if (!i_rst_n_cluster) begin
      reg_cmo_active <= 1'b0;
      reg_cmo_tag <= '0;
      reg_ctx_cmo_dir_hit <= '0;
    end else begin
      if (w_cmo_alloc_pick && w_alloc_ready) begin
        reg_cmo_active <= 1'b1;
        reg_cmo_tag <= w_alloc_tag;
        reg_ctx_cmo_dir_hit[w_alloc_tag] <= 1'b0;
      end
      for (int bank_idx=0;bank_idx<4;bank_idx++)
        if (w_lookup_rsp_accept[bank_idx] &&
            w_ctx_src[w_dir_lookup_rsp_tag[bank_idx]] == 3'(LPARA_SRC_CMO))
          reg_ctx_cmo_dir_hit[w_dir_lookup_rsp_tag[bank_idx]] <= w_dir_lookup_hit[bank_idx];
      if (reg_cmo_active && w_release_hs[reg_cmo_tag])
        reg_cmo_active <= 1'b0;
    end
  end

  // Reserve the last free context for a non-recursive victim child. Root
  // backpressure must never gate phase completion, native writeback or release.
  assign w_alloc_ready = w_table_alloc_ready & (w_internal_pick_valid | w_root_alloc_en);
  // Detect two free entries and victim-line locks without depending on READY.
  always_comb begin : p_com_alloc_capacity
    w_free_seen = 1'b0;
    w_root_alloc_en = 1'b0;
    w_victim_line_busy = '0;
    for (int slot_idx = 0; slot_idx < PARA_COH_TXN_NUM; slot_idx++) begin
      if (~w_ctx_valid[slot_idx]) begin
        if (w_free_seen)
          w_root_alloc_en = 1'b1;
        w_free_seen = 1'b1;
      end
      for (int other_idx = 0; other_idx < PARA_COH_TXN_NUM; other_idx++) begin
        if ((slot_idx != other_idx) & w_ctx_valid[other_idx]
            & (reg_ctx_victim_line[slot_idx] == w_ctx_pa_line[other_idx]))
          w_victim_line_busy[slot_idx] = 1'b1;
      end
    end
  end

  // Static source encodings and directory state values are fixed by the HDS.
  // Request arbitration accepts one hart request per cycle; internal victim work has priority.
  always_comb begin : p_com_req_pick
    w_req_pick_valid = 1'b0;
    w_req_pick_hart = '0;
    w_internal_pick_valid = 1'b0;
    w_internal_parent_tag = '0;
    for (int slot_idx = 0; slot_idx < PARA_COH_TXN_NUM; slot_idx++) begin
      if ((reg_fsm_ctx_current_state[slot_idx] == ENUM_ST_EVICT_ALLOC)
          & ~w_victim_line_busy[slot_idx] & ~w_internal_pick_valid) begin
        w_internal_pick_valid = 1'b1;
        w_internal_parent_tag = LPARA_COH_TAG_W'(slot_idx);
      end
    end
    w_req_scan_hart = '0;
    for (int offset_idx = 0; offset_idx < PARA_CPU_NUM; offset_idx++) begin
      w_req_scan_hart = 32'(reg_req_rr_hart) + 32'(offset_idx);
      if (w_req_scan_hart >= PARA_CPU_NUM)
        w_req_scan_hart = w_req_scan_hart - PARA_CPU_NUM;
      if (i_req_valid[w_req_scan_hart] & ~w_req_pick_valid & ~w_internal_pick_valid) begin
        w_req_pick_valid = 1'b1;
        w_req_pick_hart = 2'(w_req_scan_hart);
      end
    end
  end

  // Assert ready only for the selected request when a transaction slot is free.
  always_comb begin : p_com_req_ready
    o_req_ready = '0;
    w_req_kind_valid = 1'b0;
    if (w_req_pick_valid & w_alloc_ready & ~w_cmo_alloc_pick) begin
      o_req_ready[LPARA_CPU_IDX_W'(w_req_pick_hart)] = 1'b1;
      w_req_kind_valid = (i_req_kind[LPARA_CPU_IDX_W'(w_req_pick_hart)]
                           == 2'(LPARA_REQ_SHARED))
                        | (i_req_kind[LPARA_CPU_IDX_W'(w_req_pick_hart)]
                           == 2'(LPARA_REQ_EXCLUSIVE));
    end
  end

  // Allocate either a CPU permission context or a child context for directory-victim holders.
  always_comb begin : p_com_alloc
    w_alloc_valid = 1'b0;
    w_alloc_src = 3'(LPARA_SRC_CPU);
    w_alloc_req_id = '0;
    w_alloc_pa_line = '0;
    w_alloc_kind = 2'(LPARA_REQ_SHARED);
    w_alloc_target_state = 2'(LPARA_MESI_S);
    w_alloc_wback_en = 1'b1;
    casez ({w_internal_pick_valid, w_cmo_alloc_pick, w_req_pick_valid})
      3'b1??: begin
      w_alloc_valid = 1'b1;
      w_alloc_src = 3'(LPARA_SRC_EVICT);
      w_alloc_pa_line = reg_ctx_victim_line[w_internal_parent_tag];
      w_alloc_kind = 2'(LPARA_REQ_EVICT);
      w_alloc_target_state = 2'(LPARA_MESI_I);
      end
      3'b01?: begin
      w_alloc_valid = w_root_alloc_en;
      w_alloc_src = 3'(LPARA_SRC_CMO);
      w_alloc_pa_line = i_ccu_begin_pa_line;
      w_alloc_kind = 2'(LPARA_REQ_CMO);
      w_alloc_target_state = (32'(i_ccu_begin_op) == LPARA_CMO_FENCE) ? 2'(LPARA_MESI_E)
                           : (i_ccu_begin_op == 2'd0) ? 2'(LPARA_MESI_S) : 2'(LPARA_MESI_I);
      w_alloc_wback_en = i_ccu_begin_wback_en;
      end
      3'b001: begin
      w_alloc_valid = w_root_alloc_en;
      w_alloc_req_id = i_req_id[LPARA_CPU_IDX_W'(w_req_pick_hart)];
      w_alloc_pa_line = i_req_pa_line[LPARA_CPU_IDX_W'(w_req_pick_hart)];
      w_alloc_kind = i_req_kind[LPARA_CPU_IDX_W'(w_req_pick_hart)];
      if (i_req_kind[LPARA_CPU_IDX_W'(w_req_pick_hart)] == 2'(LPARA_REQ_EXCLUSIVE))
        w_alloc_target_state = 2'(LPARA_MESI_I);
      end
      default: begin end
    endcase
  end

  // One bank grant starts a directory lookup; the directory owns set reservation and replacement.
  always_comb begin : p_com_dir_req
    w_bank_req_valid = '0;
    w_bank_req_bank = '0;
    w_bank_gnt_ready = '0;
    w_dir_lookup_valid = '0;
    w_dir_lookup_line = '0;
    w_dir_lookup_tag = '0;
    for (int slot_idx = 0; slot_idx < PARA_COH_TXN_NUM; slot_idx++) begin
      w_bank_req_valid[slot_idx] = (reg_fsm_ctx_current_state[slot_idx] == ENUM_ST_DIR_REQ);
      w_bank_req_bank[slot_idx] = w_ctx_pa_line[slot_idx][1:0];
    end
    for (int bank_idx = 0; bank_idx < 4; bank_idx++) begin
      if (w_bank_gnt_valid[bank_idx]
          & (32'(w_bank_gnt_slot[bank_idx]) < PARA_COH_TXN_NUM)
          & (reg_fsm_ctx_current_state[w_bank_gnt_slot[bank_idx]] == ENUM_ST_DIR_REQ)) begin
        w_dir_lookup_valid[bank_idx] = 1'b1;
        w_dir_lookup_line[bank_idx] = w_ctx_pa_line[w_bank_gnt_slot[bank_idx]];
        w_dir_lookup_tag[bank_idx] = w_bank_gnt_slot[bank_idx];
        w_bank_gnt_ready[bank_idx] = w_dir_lookup_ready[bank_idx];
      end
    end
  end

  // Directory update/cancel arbiters choose one waiting context per bank and hold its request.
  always_comb begin : p_com_dir_term
    w_dir_update_valid = '0;
    w_dir_update_tag = '0;
    w_dir_update_line = '0;
    w_dir_update_way = '0;
    w_dir_update_holders = '0;
    w_dir_update_owner = '0;
    w_dir_update_state = '0;
    w_dir_cancel_valid = '0;
    w_dir_cancel_tag = '0;
    w_dir_cancel_line = '0;
    w_update_pick_valid = '0;
    w_cancel_pick_valid = '0;
    for (int slot_idx = 0; slot_idx < PARA_COH_TXN_NUM; slot_idx++) begin
      for (int bank_idx = 0; bank_idx < 4; bank_idx++) begin
        if ((reg_fsm_ctx_current_state[slot_idx] == ENUM_ST_DIR_UPDATE)
            & (w_ctx_pa_line[slot_idx][1:0] == 2'(bank_idx))
            & ~w_update_pick_valid[bank_idx]) begin
          w_update_pick_valid[bank_idx] = 1'b1;
          w_dir_update_valid[bank_idx] = 1'b1;
          w_dir_update_tag[bank_idx] = LPARA_COH_TAG_W'(slot_idx);
          w_dir_update_line[bank_idx] = w_ctx_pa_line[slot_idx];
          w_dir_update_way[bank_idx] = reg_ctx_dir_way[slot_idx];
          w_dir_update_holders[bank_idx] = reg_ctx_new_holders[slot_idx];
          w_dir_update_owner[bank_idx] = (|reg_ctx_new_holders[slot_idx])
                                         ? reg_ctx_new_owner[slot_idx] : '0;
          w_dir_update_state[bank_idx] = (|reg_ctx_new_holders[slot_idx])
                                         ? reg_ctx_gnt_state[slot_idx] : 2'(LPARA_MESI_I);
        end
        if (((reg_fsm_ctx_current_state[slot_idx] == ENUM_ST_DIR_CANCEL)
             | (reg_fsm_ctx_current_state[slot_idx] == ENUM_ST_RETRY_CANCEL))
            & reg_ctx_dir_reserved[slot_idx]
            & (w_ctx_pa_line[slot_idx][1:0] == 2'(bank_idx))
            & ~w_cancel_pick_valid[bank_idx]) begin
          w_cancel_pick_valid[bank_idx] = 1'b1;
          w_dir_cancel_valid[bank_idx] = 1'b1;
          w_dir_cancel_tag[bank_idx] = LPARA_COH_TAG_W'(slot_idx);
          w_dir_cancel_line[bank_idx] = w_ctx_pa_line[slot_idx];
        end
      end
    end
  end

  // Owner metadata is captured before PREPARE so M-owner writeback is matched to this tag.
  always_comb begin : p_com_owner
    w_owner_capture_valid = 1'b0;
    w_owner_capture_tag = '0;
    w_owner_capture_present = 1'b0;
    w_owner_capture_hart = '0;
    for (int slot_idx = 0; slot_idx < PARA_COH_TXN_NUM; slot_idx++) begin
      if ((reg_fsm_ctx_current_state[slot_idx] == ENUM_ST_OWNER)
          & ~w_ctx_owner_known[slot_idx] & ~w_owner_capture_valid) begin
        w_owner_capture_valid = 1'b1;
        w_owner_capture_tag = LPARA_COH_TAG_W'(slot_idx);
        w_owner_capture_hart = reg_ctx_old_owner[slot_idx];
        if (((reg_ctx_old_state[slot_idx] == 2'(LPARA_MESI_M))
             | (reg_ctx_old_state[slot_idx] == 2'(LPARA_MESI_E)))
            & (32'(reg_ctx_old_owner[slot_idx]) < PARA_CPU_NUM)) begin
          w_owner_capture_present = reg_ctx_probe_holders[slot_idx]
                                    [LPARA_CPU_IDX_W'(reg_ctx_old_owner[slot_idx])];
        end
      end
    end
  end

  // E is exclusive permission: the unique owner may silently have become M.
  // Validate actual PREPARE state and remember it even on a writeback error,
  // so ABORT checks the locked cache's real state rather than stale E metadata.
  always_comb begin : p_com_ack_state
    w_ack_err = w_ack_sched_err;
    w_ack_state_diag = 1'b0;
    w_ack_eligible = '0;
    w_ack_prepare_state_valid = '0;
    w_ack_writeback_complete = w_ack_wback_done;
    for (int hart_idx = 0; hart_idx < PARA_CPU_NUM; hart_idx++) begin
      if (32'(w_ack_tag[hart_idx]) < PARA_COH_TXN_NUM) begin
        w_ack_eligible[hart_idx] = w_ack_valid[hart_idx] & w_ack_ready[hart_idx]
          & w_ctx_valid[w_ack_tag[hart_idx]] & w_ctx_phase_active[w_ack_tag[hart_idx]]
          & (w_ctx_phase[w_ack_tag[hart_idx]] == w_ack_phase[hart_idx])
          & w_ctx_ack_expected[w_ack_tag[hart_idx]][hart_idx]
          & ~w_ctx_ack_received[w_ack_tag[hart_idx]][hart_idx];
        if (w_ack_eligible[hart_idx]) begin
          w_ack_prepare_state_valid[hart_idx] =
            (w_ack_state[hart_idx] == reg_ctx_old_state[w_ack_tag[hart_idx]]);
          if ((reg_ctx_old_state[w_ack_tag[hart_idx]] == 2'(LPARA_MESI_E))
              & (reg_ctx_old_owner[w_ack_tag[hart_idx]] == 2'(hart_idx))
              & (reg_ctx_probe_holders[w_ack_tag[hart_idx]] == (PARA_CPU_NUM'(1) << hart_idx)))
            w_ack_prepare_state_valid[hart_idx] =
              (w_ack_state[hart_idx] == 2'(LPARA_MESI_E))
              | (w_ack_state[hart_idx] == 2'(LPARA_MESI_M));
          // DEC-013/A-04: successful eviction or failed refill may leave a
          // conservative directory bit after the cache has become absent.
          if (w_ack_state[hart_idx] == 2'(LPARA_MESI_I))
            w_ack_prepare_state_valid[hart_idx] = 1'b1;
          case (w_ack_phase[hart_idx])
            2'(LPARA_PHASE_PREPARE): begin
              if (~w_ack_prepare_state_valid[hart_idx]
                  | (w_ctx_owner_present[w_ack_tag[hart_idx]]
                     & (w_ctx_owner_hart[w_ack_tag[hart_idx]] != 2'(hart_idx)))) begin
                w_ack_err[hart_idx] = 1'b1;
                w_ack_state_diag = 1'b1;
              end
              // Clean E or proven-absent I needs no data transfer. Actual M
              // must supply the transport completion bit; never fabricate it.
              if (w_ack_prepare_state_valid[hart_idx] & ~w_ack_sched_err[hart_idx]
                  & ((w_ack_state[hart_idx] == 2'(LPARA_MESI_E))
                     | (w_ack_state[hart_idx] == 2'(LPARA_MESI_I))))
                w_ack_writeback_complete[hart_idx] = 1'b1;
            end
            2'(LPARA_PHASE_ABORT): begin
              if (w_ack_state[hart_idx] !=
                  (reg_ctx_prepared_valid[w_ack_tag[hart_idx]][hart_idx]
                   ? reg_ctx_prepared_state[w_ack_tag[hart_idx]][hart_idx]
                   : reg_ctx_old_state[w_ack_tag[hart_idx]])) begin
                w_ack_err[hart_idx] = 1'b1;
                w_ack_state_diag = 1'b1;
              end
            end
            2'(LPARA_PHASE_COMMIT): begin
              if (w_ack_state[hart_idx] !=
                  ((reg_ctx_prepared_valid[w_ack_tag[hart_idx]][hart_idx]
                    & (reg_ctx_prepared_state[w_ack_tag[hart_idx]][hart_idx] == 2'(LPARA_MESI_I)))
                   ? 2'(LPARA_MESI_I) : w_ctx_target_state[w_ack_tag[hart_idx]])) begin
                w_ack_err[hart_idx] = 1'b1;
                w_ack_state_diag = 1'b1;
              end
            end
            default: begin
              w_ack_err[hart_idx] = 1'b1;
              w_ack_state_diag = 1'b1;
            end
          endcase
        end
      end
    end
  end

  // Per-holder locked-state snapshots are private to one tag lifetime.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_prepared_state
    if (~i_rst_n_cluster) begin
      reg_ctx_prepared_valid <= '0;
      reg_ctx_prepared_state <= '0;
    end else begin
      if (w_alloc_valid & w_alloc_ready) begin
        reg_ctx_prepared_valid[w_alloc_tag] <= '0;
        reg_ctx_prepared_state[w_alloc_tag] <= '0;
      end
      for (int hart_idx = 0; hart_idx < PARA_CPU_NUM; hart_idx++) begin
        if (w_ack_eligible[hart_idx]
            & (w_ack_phase[hart_idx] == 2'(LPARA_PHASE_PREPARE))
            & w_ack_prepare_state_valid[hart_idx]) begin
          reg_ctx_prepared_valid[w_ack_tag[hart_idx]][hart_idx] <= 1'b1;
          reg_ctx_prepared_state[w_ack_tag[hart_idx]][hart_idx] <= w_ack_state[hart_idx];
        end
      end
    end
  end

  // Start at most one table phase per cycle; each context still progresses independently.
  always_comb begin : p_com_phase
    w_phase_start_valid = 1'b0;
    w_phase_start_tag = '0;
    w_phase_start_phase = 2'(LPARA_PHASE_PREPARE);
    w_phase_expected = '0;
    for (int slot_idx = 0; slot_idx < PARA_COH_TXN_NUM; slot_idx++) begin
      if (~w_phase_start_valid) begin
        case (reg_fsm_ctx_current_state[slot_idx])
          ENUM_ST_PREP_START: begin
            w_phase_start_valid = 1'b1;
            w_phase_start_tag = LPARA_COH_TAG_W'(slot_idx);
            w_phase_start_phase = 2'(LPARA_PHASE_PREPARE);
            w_phase_expected = reg_ctx_probe_holders[slot_idx];
          end
          ENUM_ST_COMMIT_START: begin
            w_phase_start_valid = 1'b1;
            w_phase_start_tag = LPARA_COH_TAG_W'(slot_idx);
            w_phase_start_phase = 2'(LPARA_PHASE_COMMIT);
            w_phase_expected = reg_ctx_probe_holders[slot_idx];
          end
          ENUM_ST_ABORT_START: begin
            w_phase_start_valid = 1'b1;
            w_phase_start_tag = LPARA_COH_TAG_W'(slot_idx);
            w_phase_start_phase = 2'(LPARA_PHASE_ABORT);
            w_phase_expected = reg_ctx_probe_holders[slot_idx];
          end
          default: begin
          end
        endcase
      end
    end
  end

  // Grant arbitration selects one completed request per hart into a stable response register.
  always_comb begin : p_com_gnt
    w_gnt_load = '0;
    w_gnt_load_tag = '0;
    w_gnt_hs = reg_gnt_valid & i_gnt_ready;
    o_gnt_valid = reg_gnt_valid;
    o_gnt_req_id = reg_gnt_req_id;
    o_gnt_pa_line = reg_gnt_line;
    o_gnt_state = reg_gnt_state;
    o_gnt_err = reg_gnt_err;
    for (int hart_idx = 0; hart_idx < PARA_CPU_NUM; hart_idx++) begin
      if (~reg_gnt_valid[hart_idx]) begin
        for (int slot_idx = 0; slot_idx < PARA_COH_TXN_NUM; slot_idx++) begin
          if ((reg_fsm_ctx_current_state[slot_idx] == ENUM_ST_GNT)
              & ~reg_ctx_is_victim[slot_idx]
              & (w_ctx_src[slot_idx] == 3'(LPARA_SRC_CPU))
              & (reg_ctx_hart[slot_idx] == 2'(hart_idx))
              & ~w_gnt_load[hart_idx]
              ) begin
            w_gnt_load[hart_idx] = 1'b1;
            w_gnt_load_tag[hart_idx] = LPARA_COH_TAG_W'(slot_idx);
          end
        end
      end
    end
  end

  // Consume matching directory lookup responses and phase ACKs with stable tags.
  always_comb begin : p_com_rsp
    w_lookup_rsp_hs = '0;
    w_lookup_rsp_accept = '0;
    w_dir_lookup_rsp_ready = '1;
    w_lookup_diag_event = 1'b0;
    for (int bank_idx = 0; bank_idx < 4; bank_idx++) begin
      if (w_dir_lookup_rsp_valid[bank_idx]) begin
        if (32'(w_dir_lookup_rsp_tag[bank_idx]) < PARA_COH_TXN_NUM) begin
          if ((reg_fsm_ctx_current_state[w_dir_lookup_rsp_tag[bank_idx]] == ENUM_ST_DIR_WAIT)
              & (w_ctx_pa_line[w_dir_lookup_rsp_tag[bank_idx]][1:0] == 2'(bank_idx))) begin
            w_lookup_rsp_hs[w_dir_lookup_rsp_tag[bank_idx]] = 1'b1;
            w_lookup_rsp_accept[bank_idx] = 1'b1;
          end else begin
            w_lookup_diag_event = 1'b1;
          end
        end else begin
          w_lookup_diag_event = 1'b1;
        end
      end
    end
  end

  // Protect the implemented directory geometry and connect the four architectural leaf blocks.
  m_vlsit_riscv_coh_txn_table #(
    .PARA_COH_TXN_NUM(PARA_COH_TXN_NUM),
    .PARA_CPU_NUM(PARA_CPU_NUM)
  ) u_vlsit_riscv_coh_txn_table (
    .i_clk_cluster(i_clk_cluster),
    .i_rst_n_cluster(i_rst_n_cluster),
    .i_alloc_valid(w_alloc_valid),
    .o_alloc_ready(w_table_alloc_ready),
    .i_alloc_src(w_alloc_src),
    .i_alloc_req_id(w_alloc_req_id),
    .i_alloc_pa_line(w_alloc_pa_line),
    .i_alloc_kind(w_alloc_kind),
    .i_alloc_target_state(w_alloc_target_state),
    .i_alloc_wback_en(w_alloc_wback_en),
    .o_alloc_tag(w_alloc_tag),
    .i_release_valid(w_release_valid),
    .i_release_tag(w_release_tag),
    .o_release_ready(w_release_ready),
    .i_phase_start_valid(w_phase_start_valid),
    .i_phase_start_tag(w_phase_start_tag),
    .i_phase_start(w_phase_start_phase),
    .i_phase_expected(w_phase_expected),
    .o_phase_start_ready(w_phase_start_ready),
    .i_owner_capture_valid(w_owner_capture_valid),
    .o_owner_capture_ready(w_owner_capture_ready),
    .i_owner_capture_tag(w_owner_capture_tag),
    .i_owner_capture_present(w_owner_capture_present),
    .i_owner_capture_hart(w_owner_capture_hart),
    .i_ack_valid(w_ack_valid),
    .o_ack_ready(w_ack_ready),
    .i_ack_tag(w_ack_tag),
    .i_ack_phase(w_ack_phase),
    .i_ack_err(w_ack_err),
    .i_ack_wback_done(w_ack_writeback_complete),
    .o_ctx_valid(w_ctx_valid),
    .o_ctx_src(w_ctx_src),
    .o_ctx_req_id(w_ctx_req_id),
    .o_ctx_pa_line(w_ctx_pa_line),
    .o_ctx_kind(w_ctx_kind),
    .o_ctx_phase(w_ctx_phase),
    .o_ctx_ack_expected(w_ctx_ack_expected),
    .o_ctx_ack_received(w_ctx_ack_received),
    .o_ctx_phase_active(w_ctx_phase_active),
    .o_ctx_phase_done(w_ctx_phase_done),
    .o_ctx_phase_err(w_ctx_phase_err),
    .o_ctx_owner_wback_done(w_ctx_owner_wback_done),
    .o_ctx_target_state(w_ctx_target_state),
    .o_ctx_wback_en(w_ctx_wback_en),
    .o_ctx_owner_known(w_ctx_owner_known),
    .o_ctx_owner_present(w_ctx_owner_present),
    .o_ctx_owner_hart(w_ctx_owner_hart),
    .o_ctx_txn_err(w_ctx_txn_err),
    .o_ctx_owner_wback_err(w_ctx_owner_wback_err),
    .o_coh_proto_diag_event(w_table_diag)
  );

  m_vlsit_riscv_coh_bank_arb #(
    .PARA_COH_TXN_NUM(PARA_COH_TXN_NUM)
  ) u_vlsit_riscv_coh_bank_arb (
    .i_clk_cluster(i_clk_cluster),
    .i_rst_n_cluster(i_rst_n_cluster),
    .i_req_valid(w_bank_req_valid),
    .i_req_bank(w_bank_req_bank),
    .i_gnt_ready(w_bank_gnt_ready),
    .o_gnt_valid(w_bank_gnt_valid),
    .o_gnt_slot(w_bank_gnt_slot),
    .o_bank_conflict_stall(w_bank_conflict_stall)
  );

  m_vlsit_riscv_sharer_directory #(
    .PARA_DIR_SYNC_READ(PARA_DIR_SYNC_READ),
    .PARA_CPU_NUM(PARA_CPU_NUM),
    .PARA_COH_TXN_NUM(PARA_COH_TXN_NUM)
  ) u_vlsit_riscv_sharer_directory (
    .i_clk_cluster(i_clk_cluster),
    .i_rst_n_cluster(i_rst_n_cluster),
    .i_lookup_valid(w_dir_lookup_valid),
    .o_lookup_ready(w_dir_lookup_ready),
    .i_lookup_pa_line(w_dir_lookup_line),
    .i_lookup_tag(w_dir_lookup_tag),
    .o_lookup_rsp_valid(w_dir_lookup_rsp_valid),
    .i_lookup_rsp_ready(w_dir_lookup_rsp_ready),
    .o_lookup_hit(w_dir_lookup_hit),
    .o_lookup_rsp_tag(w_dir_lookup_rsp_tag),
    .o_lookup_way(w_dir_lookup_way),
    .o_lookup_victim_valid(w_dir_victim_valid),
    .o_lookup_victim_pa_line(w_dir_victim_line),
    .o_lookup_holders(w_dir_lookup_holders),
    .o_lookup_owner(w_dir_lookup_owner),
    .o_lookup_state(w_dir_lookup_state),
    .i_update_valid(w_dir_update_valid),
    .o_update_ready(w_dir_update_ready),
    .i_update_tag(w_dir_update_tag),
    .i_update_pa_line(w_dir_update_line),
    .i_update_way(w_dir_update_way),
    .i_update_holders(w_dir_update_holders),
    .i_update_owner(w_dir_update_owner),
    .i_update_state(w_dir_update_state),
    .i_cancel_valid(w_dir_cancel_valid),
    .o_cancel_ready(w_dir_cancel_ready),
    .i_cancel_tag(w_dir_cancel_tag),
    .i_cancel_pa_line(w_dir_cancel_line),
    .o_dir_lookup_count(o_dir_lookup_count),
    .o_dir_update_count(o_dir_update_count),
    .o_coh_proto_diag_event(w_dir_diag)
  );

  m_vlsit_riscv_probe_scheduler #(
    .PARA_CPU_NUM(PARA_CPU_NUM),
    .PARA_COH_TXN_NUM(PARA_COH_TXN_NUM)
  ) u_vlsit_riscv_probe_scheduler (
    .i_clk_cluster(i_clk_cluster),
    .i_rst_n_cluster(i_rst_n_cluster),
    .i_ctx_valid(w_ctx_valid),
    .i_ctx_pa_line(w_ctx_pa_line),
    .i_ctx_phase(w_ctx_phase),
    .i_ctx_ack_expected(w_ctx_ack_expected),
    .i_ctx_ack_received(w_ctx_ack_received),
    .i_ctx_phase_active(w_ctx_phase_active),
    .i_ctx_target_state(w_ctx_target_state),
    .i_ctx_wback_en(w_ctx_wback_en),
    .o_probe_req_valid(o_probe_req_valid),
    .i_probe_req_ready(i_probe_req_ready),
    .o_probe_req_tag(o_probe_req_tag),
    .o_probe_req_pa_line(o_probe_req_pa_line),
    .o_probe_req_phase(o_probe_req_phase),
    .o_probe_req_target_state(o_probe_req_target_state),
    .o_probe_req_wback_en(o_probe_req_wback_en),
    .i_probe_rsp_valid(i_probe_rsp_valid),
    .o_probe_rsp_ready(o_probe_rsp_ready),
    .i_probe_rsp_tag(i_probe_rsp_tag),
    .i_probe_rsp_pa_line(i_probe_rsp_pa_line),
    .i_probe_rsp_phase(i_probe_rsp_phase),
    .i_probe_rsp_state(i_probe_rsp_state),
    .i_probe_rsp_err(i_probe_rsp_err),
    .i_probe_rsp_wback_done(i_probe_rsp_wback_done),
    .o_ack_valid(w_ack_valid),
    .i_ack_ready(w_ack_ready),
    .o_ack_tag(w_ack_tag),
    .o_ack_phase(w_ack_phase),
    .o_ack_state(w_ack_state),
    .o_ack_err(w_ack_sched_err),
    .o_ack_wback_done(w_ack_wback_done),
    .o_coh_proto_diag_event(w_probe_diag)
  );

  // Drive context releases and remember metadata returned by directory lookups and grants.
  always_comb begin : p_com_release
    w_release_valid = 1'b0;
    w_release_tag = '0;
    for (int slot_idx = 0; slot_idx < PARA_COH_TXN_NUM; slot_idx++) begin
      if (((reg_fsm_ctx_current_state[slot_idx] == ENUM_ST_GNT_WAIT)
          & ~reg_ctx_is_victim[slot_idx]
          & (w_ctx_src[slot_idx] == 3'(LPARA_SRC_CPU))
          & (reg_ctx_gnt_accepted[slot_idx]
             | (w_gnt_hs[LPARA_CPU_IDX_W'(reg_ctx_hart[slot_idx])]
                & (reg_gnt_tag[LPARA_CPU_IDX_W'(reg_ctx_hart[slot_idx])]
                   == LPARA_COH_TAG_W'(slot_idx)))))
          | ((w_ctx_src[slot_idx] == 3'(LPARA_SRC_CMO))
                   && (reg_fsm_ctx_current_state[slot_idx] == ENUM_ST_GNT))
          | (reg_ctx_is_victim[slot_idx]
                   & (w_ctx_src[slot_idx] == 3'(LPARA_SRC_EVICT))
                   & ((reg_fsm_ctx_current_state[slot_idx] == ENUM_ST_COMMIT_WAIT)
                      | (reg_fsm_ctx_current_state[slot_idx] == ENUM_ST_ABORT_WAIT)
                      | (reg_fsm_ctx_current_state[slot_idx] == ENUM_ST_GNT_WAIT))
                   & w_ctx_phase_done[slot_idx]
                   & ~w_ctx_phase_err[slot_idx])) begin
        w_release_valid = 1'b1;
        w_release_tag = LPARA_COH_TAG_W'(slot_idx);
      end
    end
  end

  // Keep the release-ready dependency out of the tag-selection process.
  always_comb begin : p_com_release_hs
    w_release_hs = '0;
    for (int slot_idx = 0; slot_idx < PARA_COH_TXN_NUM; slot_idx++) begin
      if (w_release_valid & w_release_ready
          & (w_release_tag == LPARA_COH_TAG_W'(slot_idx)))
        w_release_hs[slot_idx] = 1'b1;
    end
  end

  // Select phase and directory handshakes for next-state control.
  always_comb begin : p_com_hs
    w_phase_start_hs = w_phase_start_valid & w_phase_start_ready;
    w_owner_capture_hs = w_owner_capture_valid & w_owner_capture_ready;
    w_update_hs = w_dir_update_valid & w_dir_update_ready;
    w_cancel_hs = w_dir_cancel_valid & w_dir_cancel_ready;
  end

  // Export CCU Event_Map order: 0300 request, 0301/0302 lookup hit/miss,
  // 0303/0304/0305 PREPARE/COMMIT/ABORT ACK, 0306 successful owner writeback
  // indication, 0307 accepted grant, 0308/0309/030A stall cycles, 030B replacement.
  // 0306 observes PREPARE ACK plus writeback_done; no line payload enters the CCU.
  always_comb begin : p_com_ccu_evt_count
    o_ccu_evt_count = '0;
    for (int hart_idx = 0; hart_idx < PARA_CPU_NUM; hart_idx++) begin
      if (i_req_valid[hart_idx] & o_req_ready[hart_idx])
        o_ccu_evt_count[0] = o_ccu_evt_count[0] + 3'd1;
      if (w_ack_valid[hart_idx] & w_ack_ready[hart_idx] & ~w_ack_sched_err[hart_idx]) begin
        case (w_ack_phase[hart_idx])
          2'(LPARA_PHASE_PREPARE): o_ccu_evt_count[3] = o_ccu_evt_count[3] + 3'd1;
          2'(LPARA_PHASE_COMMIT):  o_ccu_evt_count[4] = o_ccu_evt_count[4] + 3'd1;
          2'(LPARA_PHASE_ABORT):   o_ccu_evt_count[5] = o_ccu_evt_count[5] + 3'd1;
          default: begin
          end
        endcase
        if ((w_ack_phase[hart_idx] == 2'(LPARA_PHASE_PREPARE))
            & w_ack_wback_done[hart_idx])
          o_ccu_evt_count[6] = o_ccu_evt_count[6] + 3'd1;
      end
      if (w_gnt_hs[hart_idx])
        o_ccu_evt_count[7] = o_ccu_evt_count[7] + 3'd1;
    end
    for (int bank_idx = 0; bank_idx < 4; bank_idx++) begin
      if (w_lookup_rsp_accept[bank_idx]) begin
        if (w_dir_lookup_hit[bank_idx])
          o_ccu_evt_count[1] = o_ccu_evt_count[1] + 3'd1;
        else
          o_ccu_evt_count[2] = o_ccu_evt_count[2] + 3'd1;
      end
      if (w_update_hs[bank_idx]
          & (32'(w_dir_update_tag[bank_idx]) < PARA_COH_TXN_NUM)
          & reg_ctx_victim_valid[w_dir_update_tag[bank_idx]])
        o_ccu_evt_count[11] = o_ccu_evt_count[11] + 3'd1;
    end
    o_ccu_evt_count[8] = {2'b00,
      (w_req_pick_valid & ~w_alloc_ready & ~w_internal_pick_valid)};
    o_ccu_evt_count[9] = {2'b00, i_same_line_lock_stall};
    o_ccu_evt_count[10] = {2'b00, w_bank_conflict_stall};
  end

  // Compute all context state transitions from handshakes; unused encodings recover to IDLE.
  always_comb begin : p_com_fsm_nxt
    w_fsm_ctx_nxt_state[0] = ENUM_ST_IDLE;
    for (int slot_idx = 0; slot_idx < PARA_COH_TXN_NUM; slot_idx++) begin
      w_fsm_ctx_nxt_state[slot_idx] = reg_fsm_ctx_current_state[slot_idx];
      case (reg_fsm_ctx_current_state[slot_idx])
        ENUM_ST_IDLE: begin
        end
        ENUM_ST_DIR_REQ: begin
          if (w_dir_lookup_valid[w_ctx_pa_line[slot_idx][1:0]]
              & w_dir_lookup_ready[w_ctx_pa_line[slot_idx][1:0]]
              & (w_dir_lookup_tag[w_ctx_pa_line[slot_idx][1:0]]
                 == LPARA_COH_TAG_W'(slot_idx)))
            w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_DIR_WAIT;
        end
        ENUM_ST_DIR_WAIT: begin
          if (w_lookup_rsp_hs[slot_idx]) begin
            if (w_ctx_src[slot_idx] == 3'(LPARA_SRC_CMO))
              w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_OWNER;
            else if (~w_dir_lookup_hit[w_ctx_pa_line[slot_idx][1:0]]
                & w_dir_victim_valid[w_ctx_pa_line[slot_idx][1:0]]
                & (|w_dir_lookup_holders[w_ctx_pa_line[slot_idx][1:0]]))
              w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_EVICT_ALLOC;
            else
              w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_OWNER;
          end
        end
        ENUM_ST_EVICT_ALLOC: begin
          if (w_victim_line_busy[slot_idx])
            w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_RETRY_CANCEL;
          else if (w_alloc_valid & w_alloc_ready & w_internal_pick_valid
                   & (w_internal_parent_tag == LPARA_COH_TAG_W'(slot_idx)))
            w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_EVICT_WAIT;
        end
        ENUM_ST_RETRY_CANCEL: begin
          if (w_cancel_hs[w_ctx_pa_line[slot_idx][1:0]]
              & (w_dir_cancel_tag[w_ctx_pa_line[slot_idx][1:0]]
                 == LPARA_COH_TAG_W'(slot_idx)))
            w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_DIR_REQ;
        end
        ENUM_ST_EVICT_WAIT: begin
        end
        ENUM_ST_OWNER: begin
          if (w_owner_capture_hs & (w_owner_capture_tag == LPARA_COH_TAG_W'(slot_idx)))
            w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_PREP_START;
        end
        ENUM_ST_PREP_START: begin
          if (w_phase_start_hs & (w_phase_start_phase == 2'(LPARA_PHASE_PREPARE))
              & (w_phase_start_tag == LPARA_COH_TAG_W'(slot_idx)))
            w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_PREP_WAIT;
        end
        ENUM_ST_PREP_WAIT: begin
          if (w_ctx_phase_done[slot_idx]) begin
            if (w_ctx_src[slot_idx] == 3'(LPARA_SRC_CMO))
              w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_CMO_PREPARED;
            else if (w_ctx_phase_err[slot_idx] | w_ctx_txn_err[slot_idx]
                | w_ctx_owner_wback_err[slot_idx]
                | (w_ctx_owner_present[slot_idx] & w_ctx_wback_en[slot_idx]
                   & ~w_ctx_owner_wback_done[slot_idx]))
              w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_ABORT_START;
            else
              w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_COMMIT_START;
          end
        end
        ENUM_ST_COMMIT_START: begin
          if (w_phase_start_hs & (w_phase_start_phase == 2'(LPARA_PHASE_COMMIT))
              & (w_phase_start_tag == LPARA_COH_TAG_W'(slot_idx)))
            w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_COMMIT_WAIT;
        end
        ENUM_ST_COMMIT_WAIT: begin
          if (w_ctx_phase_done[slot_idx] & ~w_ctx_phase_err[slot_idx]) begin
            if (reg_ctx_is_victim[slot_idx])
              w_fsm_ctx_nxt_state[slot_idx] = w_release_hs[slot_idx]
                                             ? ENUM_ST_IDLE : ENUM_ST_GNT_WAIT;
            else if ((w_ctx_src[slot_idx] == 3'(LPARA_SRC_CMO)) && !reg_ctx_cmo_dir_hit[slot_idx])
              w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_DIR_CANCEL;
            else
              w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_DIR_UPDATE;
          end
        end
        ENUM_ST_ABORT_START: begin
          if (w_phase_start_hs & (w_phase_start_phase == 2'(LPARA_PHASE_ABORT))
              & (w_phase_start_tag == LPARA_COH_TAG_W'(slot_idx)))
            w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_ABORT_WAIT;
        end
        ENUM_ST_ABORT_WAIT: begin
          if (w_ctx_phase_done[slot_idx] & ~w_ctx_phase_err[slot_idx]) begin
            if (reg_ctx_is_victim[slot_idx])
              w_fsm_ctx_nxt_state[slot_idx] = w_release_hs[slot_idx]
                                             ? ENUM_ST_IDLE : ENUM_ST_GNT_WAIT;
            else if (reg_ctx_dir_reserved[slot_idx])
              w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_DIR_CANCEL;
            else
              w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_GNT;
          end
        end
        ENUM_ST_DIR_UPDATE: begin
          if (w_update_hs[w_ctx_pa_line[slot_idx][1:0]])
            w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_GNT;
        end
        ENUM_ST_DIR_CANCEL: begin
          if (~reg_ctx_dir_reserved[slot_idx]
              | w_cancel_hs[w_ctx_pa_line[slot_idx][1:0]])
            w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_GNT;
        end
        ENUM_ST_CMO_PREPARED: begin
          if (i_ccu_prepare_ready)
            w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_CMO_FINISH;
        end
        ENUM_ST_CMO_FINISH: begin
          if (i_ccu_finish_valid && o_ccu_finish_ready) begin
            if (i_ccu_finish_commit && !reg_ctx_gnt_err[slot_idx])
              w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_COMMIT_START;
            else
              w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_ABORT_START;
          end
        end
        ENUM_ST_GNT: begin
          if (w_ctx_src[slot_idx] == 3'(LPARA_SRC_CMO)) begin
            if (w_release_hs[slot_idx])
              w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_IDLE;
          end else if (w_gnt_load[LPARA_CPU_IDX_W'(reg_ctx_hart[slot_idx])]
                       & (w_gnt_load_tag[LPARA_CPU_IDX_W'(reg_ctx_hart[slot_idx])]
                          == LPARA_COH_TAG_W'(slot_idx)))
            w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_GNT_WAIT;
        end
        ENUM_ST_GNT_WAIT: begin
          if (w_release_hs[slot_idx])
            w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_IDLE;
        end
        default: begin
          w_fsm_ctx_nxt_state[slot_idx] = ENUM_ST_IDLE;
        end
      endcase
    end
    if (w_alloc_valid & w_alloc_ready) begin
      if (w_internal_pick_valid)
        w_fsm_ctx_nxt_state[w_alloc_tag] = ENUM_ST_OWNER;
      else if (w_cmo_alloc_pick || w_req_kind_valid)
        w_fsm_ctx_nxt_state[w_alloc_tag] = ENUM_ST_DIR_REQ;
      else
        w_fsm_ctx_nxt_state[w_alloc_tag] = ENUM_ST_GNT;
    end
    for (int slot_idx = 0; slot_idx < PARA_COH_TXN_NUM; slot_idx++) begin
      if (reg_fsm_ctx_current_state[slot_idx] == ENUM_ST_COMMIT_WAIT
          & w_ctx_phase_done[slot_idx] & ~w_ctx_phase_err[slot_idx]
          & reg_ctx_is_victim[slot_idx])
        w_fsm_ctx_nxt_state[reg_ctx_parent_tag[slot_idx]] = ENUM_ST_DIR_UPDATE;
      if (reg_fsm_ctx_current_state[slot_idx] == ENUM_ST_ABORT_WAIT
          & w_ctx_phase_done[slot_idx] & ~w_ctx_phase_err[slot_idx]
          & reg_ctx_is_victim[slot_idx])
        w_fsm_ctx_nxt_state[reg_ctx_parent_tag[slot_idx]] = ENUM_ST_DIR_CANCEL;
    end
  end

  // FSM state registers are isolated from payload and grant storage.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_fsm_ctx
    if (!i_rst_n_cluster) begin
      for (int slot_idx = 0; slot_idx < PARA_COH_TXN_NUM; slot_idx++)
        reg_fsm_ctx_current_state[slot_idx] <= ENUM_ST_IDLE;
    end else begin
      reg_fsm_ctx_current_state <= w_fsm_ctx_nxt_state;
    end
  end

  // Round-robin pointer gives each continuously requesting hart a service turn.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_req_rr
    if (!i_rst_n_cluster) begin
      reg_req_rr_hart <= '0;
    end else if (w_req_pick_valid & w_alloc_ready & ~w_internal_pick_valid) begin
      if (reg_req_rr_hart == 2'(PARA_CPU_NUM - 32'd1))
        reg_req_rr_hart <= '0;
      else
        reg_req_rr_hart <= 2'(reg_req_rr_hart + 2'd1);
    end
  end

  // Store allocation payload, lookup results, child links, and derived MESI updates.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_ctx_data
    if (!i_rst_n_cluster) begin
      reg_ctx_is_victim <= '0;
      reg_ctx_dir_reserved <= '0;
      reg_ctx_victim_valid <= '0;
      reg_ctx_hart <= '0;
      reg_ctx_gnt_accepted <= '0;
      reg_ctx_gnt_state <= '0;
      reg_ctx_dir_way <= '0;
      reg_ctx_probe_holders <= '0;
      reg_ctx_new_holders <= '0;
      reg_ctx_old_owner <= '0;
      reg_ctx_new_owner <= '0;
      reg_ctx_old_state <= '0;
      reg_ctx_victim_line <= '0;
      reg_ctx_victim_holders <= '0;
      reg_ctx_victim_owner <= '0;
      reg_ctx_victim_state <= '0;
      reg_ctx_parent_tag <= '0;
      reg_ctx_gnt_err <= '0;
    end else begin
      if (w_alloc_valid & w_alloc_ready) begin
        reg_ctx_is_victim[w_alloc_tag] <= w_internal_pick_valid;
        reg_ctx_dir_reserved[w_alloc_tag] <= 1'b0;
        reg_ctx_victim_valid[w_alloc_tag] <= 1'b0;
        reg_ctx_hart[w_alloc_tag] <= w_internal_pick_valid ? '0
            : w_cmo_alloc_pick ? i_ccu_begin_hart : w_req_pick_hart;
        reg_ctx_gnt_accepted[w_alloc_tag] <= 1'b0;
        reg_ctx_gnt_state[w_alloc_tag] <= w_alloc_target_state;
        reg_ctx_dir_way[w_alloc_tag] <= '0;
        reg_ctx_probe_holders[w_alloc_tag] <= '0;
        reg_ctx_new_holders[w_alloc_tag] <= '0;
        reg_ctx_old_owner[w_alloc_tag] <= '0;
        reg_ctx_new_owner[w_alloc_tag] <= '0;
        reg_ctx_old_state[w_alloc_tag] <= w_alloc_target_state;
        reg_ctx_victim_line[w_alloc_tag] <= '0;
        reg_ctx_victim_holders[w_alloc_tag] <= '0;
        reg_ctx_victim_owner[w_alloc_tag] <= '0;
        reg_ctx_victim_state[w_alloc_tag] <= 2'(LPARA_MESI_I);
        reg_ctx_parent_tag[w_alloc_tag] <= w_internal_parent_tag;
        reg_ctx_gnt_err[w_alloc_tag] <= ~w_req_kind_valid & ~w_internal_pick_valid & ~w_cmo_alloc_pick;
        if (w_internal_pick_valid) begin
          reg_ctx_probe_holders[w_alloc_tag] <= reg_ctx_victim_holders[w_internal_parent_tag];
          reg_ctx_old_owner[w_alloc_tag] <= reg_ctx_victim_owner[w_internal_parent_tag];
          reg_ctx_old_state[w_alloc_tag] <= reg_ctx_victim_state[w_internal_parent_tag];
        end
      end
      for (int bank_idx = 0; bank_idx < 4; bank_idx++) begin
        if (w_lookup_rsp_accept[bank_idx]) begin
          reg_ctx_dir_reserved[w_dir_lookup_rsp_tag[bank_idx]] <= 1'b1;
          reg_ctx_victim_valid[w_dir_lookup_rsp_tag[bank_idx]] <=
            ~w_dir_lookup_hit[bank_idx] & w_dir_victim_valid[bank_idx];
          reg_ctx_dir_way[w_dir_lookup_rsp_tag[bank_idx]] <= w_dir_lookup_way[bank_idx];
          reg_ctx_old_owner[w_dir_lookup_rsp_tag[bank_idx]] <= w_dir_lookup_owner[bank_idx];
          reg_ctx_old_state[w_dir_lookup_rsp_tag[bank_idx]] <= w_dir_lookup_state[bank_idx];
          if (~w_dir_lookup_hit[bank_idx] & w_dir_victim_valid[bank_idx]) begin
            reg_ctx_victim_line[w_dir_lookup_rsp_tag[bank_idx]] <= w_dir_victim_line[bank_idx];
            reg_ctx_victim_holders[w_dir_lookup_rsp_tag[bank_idx]] <= w_dir_lookup_holders[bank_idx];
            reg_ctx_victim_owner[w_dir_lookup_rsp_tag[bank_idx]] <= w_dir_lookup_owner[bank_idx];
            reg_ctx_victim_state[w_dir_lookup_rsp_tag[bank_idx]] <= w_dir_lookup_state[bank_idx];
          end
          if (w_ctx_src[w_dir_lookup_rsp_tag[bank_idx]] == 3'(LPARA_SRC_CMO)) begin
            reg_ctx_victim_valid[w_dir_lookup_rsp_tag[bank_idx]] <= 1'b0;
            reg_ctx_probe_holders[w_dir_lookup_rsp_tag[bank_idx]] <=
              w_dir_lookup_hit[bank_idx] ? w_dir_lookup_holders[bank_idx] : '0;
            reg_ctx_old_owner[w_dir_lookup_rsp_tag[bank_idx]] <=
              w_dir_lookup_hit[bank_idx] ? w_dir_lookup_owner[bank_idx] : '0;
            reg_ctx_old_state[w_dir_lookup_rsp_tag[bank_idx]] <=
              w_dir_lookup_hit[bank_idx] ? w_dir_lookup_state[bank_idx] : 2'(LPARA_MESI_I);
            reg_ctx_new_holders[w_dir_lookup_rsp_tag[bank_idx]] <=
              (w_ctx_target_state[w_dir_lookup_rsp_tag[bank_idx]] != 2'(LPARA_MESI_I))
              && w_dir_lookup_hit[bank_idx] ? w_dir_lookup_holders[bank_idx] : '0;
            reg_ctx_new_owner[w_dir_lookup_rsp_tag[bank_idx]] <= '0;
            if (w_ctx_target_state[w_dir_lookup_rsp_tag[bank_idx]] == 2'(LPARA_MESI_E)) begin
              reg_ctx_new_owner[w_dir_lookup_rsp_tag[bank_idx]] <= w_dir_lookup_owner[bank_idx];
              if (w_dir_lookup_holders[bank_idx] !=
                  (PARA_CPU_NUM'(1) << reg_ctx_hart[w_dir_lookup_rsp_tag[bank_idx]])) begin
                reg_ctx_probe_holders[w_dir_lookup_rsp_tag[bank_idx]] <= '0;
                reg_ctx_gnt_state[w_dir_lookup_rsp_tag[bank_idx]] <= w_dir_lookup_state[bank_idx];
              end
            end
          end else if (w_ctx_kind[w_dir_lookup_rsp_tag[bank_idx]] == 2'(LPARA_REQ_SHARED)) begin
            if (w_dir_lookup_hit[bank_idx]
                & w_dir_lookup_holders[bank_idx]
                  [LPARA_CPU_IDX_W'(reg_ctx_hart[w_dir_lookup_rsp_tag[bank_idx]])]
                & ~(|(w_dir_lookup_holders[bank_idx]
                      & ~(PARA_CPU_NUM'(1) << reg_ctx_hart[w_dir_lookup_rsp_tag[bank_idx]])))) begin
              reg_ctx_probe_holders[w_dir_lookup_rsp_tag[bank_idx]] <= '0;
              reg_ctx_gnt_state[w_dir_lookup_rsp_tag[bank_idx]] <= w_dir_lookup_state[bank_idx];
              reg_ctx_new_holders[w_dir_lookup_rsp_tag[bank_idx]] <= w_dir_lookup_holders[bank_idx];
              reg_ctx_new_owner[w_dir_lookup_rsp_tag[bank_idx]] <= w_dir_lookup_owner[bank_idx];
            end else if (w_dir_lookup_hit[bank_idx]
                         & (|(w_dir_lookup_holders[bank_idx]
                              & ~(PARA_CPU_NUM'(1) << reg_ctx_hart[w_dir_lookup_rsp_tag[bank_idx]])))) begin
              reg_ctx_probe_holders[w_dir_lookup_rsp_tag[bank_idx]] <= w_dir_lookup_holders[bank_idx]
                & ~(PARA_CPU_NUM'(1) << reg_ctx_hart[w_dir_lookup_rsp_tag[bank_idx]]);
              reg_ctx_gnt_state[w_dir_lookup_rsp_tag[bank_idx]] <= 2'(LPARA_MESI_S);
              reg_ctx_new_holders[w_dir_lookup_rsp_tag[bank_idx]] <= w_dir_lookup_holders[bank_idx]
                | (PARA_CPU_NUM'(1) << reg_ctx_hart[w_dir_lookup_rsp_tag[bank_idx]]);
              reg_ctx_new_owner[w_dir_lookup_rsp_tag[bank_idx]] <= '0;
            end else begin
              reg_ctx_probe_holders[w_dir_lookup_rsp_tag[bank_idx]] <= '0;
              reg_ctx_gnt_state[w_dir_lookup_rsp_tag[bank_idx]] <= 2'(LPARA_MESI_E);
              reg_ctx_new_holders[w_dir_lookup_rsp_tag[bank_idx]] <=
                PARA_CPU_NUM'(1) << reg_ctx_hart[w_dir_lookup_rsp_tag[bank_idx]];
              reg_ctx_new_owner[w_dir_lookup_rsp_tag[bank_idx]] <= reg_ctx_hart[w_dir_lookup_rsp_tag[bank_idx]];
            end
          end else begin
            reg_ctx_probe_holders[w_dir_lookup_rsp_tag[bank_idx]] <= w_dir_lookup_hit[bank_idx]
              ? (w_dir_lookup_holders[bank_idx]
                 & ~(PARA_CPU_NUM'(1) << reg_ctx_hart[w_dir_lookup_rsp_tag[bank_idx]])) : '0;
            reg_ctx_gnt_state[w_dir_lookup_rsp_tag[bank_idx]] <= 2'(LPARA_MESI_M);
            reg_ctx_new_holders[w_dir_lookup_rsp_tag[bank_idx]] <=
              PARA_CPU_NUM'(1) << reg_ctx_hart[w_dir_lookup_rsp_tag[bank_idx]];
            reg_ctx_new_owner[w_dir_lookup_rsp_tag[bank_idx]] <= reg_ctx_hart[w_dir_lookup_rsp_tag[bank_idx]];
          end
        end
      end
      // A victim conflict cancels only this parent's reservation, then lookup
      // retries with fresh metadata; no cache state has been changed yet.
      for (int bank_idx = 0; bank_idx < 4; bank_idx++) begin
        if (w_cancel_hs[bank_idx])
          reg_ctx_dir_reserved[w_dir_cancel_tag[bank_idx]] <= 1'b0;
      end
      // Prune only the transaction's candidate; ABORT never publishes it.
      for (int hart_idx = 0; hart_idx < PARA_CPU_NUM; hart_idx++) begin
        if (w_ack_eligible[hart_idx]
            & (w_ack_phase[hart_idx] == 2'(LPARA_PHASE_PREPARE))
            & w_ack_prepare_state_valid[hart_idx] & ~w_ack_err[hart_idx]
            & (w_ack_state[hart_idx] == 2'(LPARA_MESI_I)))
          reg_ctx_new_holders[w_ack_tag[hart_idx]][hart_idx] <= 1'b0;
      end
      for (int slot_idx = 0; slot_idx < PARA_COH_TXN_NUM; slot_idx++) begin
        if (~reg_ctx_is_victim[slot_idx]
            & (reg_fsm_ctx_current_state[slot_idx] == ENUM_ST_PREP_WAIT)
            & w_ctx_phase_done[slot_idx]
            & (w_ctx_phase_err[slot_idx] | w_ctx_txn_err[slot_idx]
               | w_ctx_owner_wback_err[slot_idx]
               | (w_ctx_owner_present[slot_idx] & w_ctx_wback_en[slot_idx]
                  & ~w_ctx_owner_wback_done[slot_idx]))) begin
          reg_ctx_gnt_err[slot_idx] <= 1'b1;
        end
        if (w_release_hs[slot_idx]) begin
          reg_ctx_gnt_accepted[slot_idx] <= 1'b0;
        end else if (~reg_ctx_is_victim[slot_idx]
                     & w_gnt_hs[LPARA_CPU_IDX_W'(reg_ctx_hart[slot_idx])]
                     & (reg_gnt_tag[LPARA_CPU_IDX_W'(reg_ctx_hart[slot_idx])]
                        == LPARA_COH_TAG_W'(slot_idx))) begin
          reg_ctx_gnt_accepted[slot_idx] <= 1'b1;
        end
        if ((reg_fsm_ctx_current_state[slot_idx] == ENUM_ST_EVICT_ALLOC)
            & w_alloc_valid & w_alloc_ready & w_internal_pick_valid
            & (w_internal_parent_tag == LPARA_COH_TAG_W'(slot_idx))) begin
          reg_ctx_parent_tag[w_alloc_tag] <= LPARA_COH_TAG_W'(slot_idx);
        end
        if (reg_ctx_is_victim[slot_idx]
            & (reg_fsm_ctx_current_state[slot_idx] == ENUM_ST_ABORT_WAIT)
            & w_ctx_phase_done[slot_idx] & ~w_ctx_phase_err[slot_idx])
          reg_ctx_gnt_err[reg_ctx_parent_tag[slot_idx]] <= 1'b1;
      end
    end
  end

  // Grant register payload is copied from its completed context and held until the tile accepts it.
  always_ff @(posedge i_clk_cluster, negedge i_rst_n_cluster) begin : p_ff_gnts
    if (!i_rst_n_cluster) begin
      reg_gnt_valid <= '0;
      reg_gnt_tag <= '0;
      reg_gnt_req_id <= '0;
      reg_gnt_line <= '0;
      reg_gnt_state <= '0;
      reg_gnt_err <= '0;
    end else begin
      for (int hart_idx = 0; hart_idx < PARA_CPU_NUM; hart_idx++) begin
        if (w_gnt_hs[hart_idx]) begin
          reg_gnt_valid[hart_idx] <= 1'b0;
        end else if (~reg_gnt_valid[hart_idx] & w_gnt_load[hart_idx]) begin
          reg_gnt_valid[hart_idx] <= 1'b1;
          reg_gnt_tag[hart_idx] <= w_gnt_load_tag[hart_idx];
          reg_gnt_req_id[hart_idx] <= w_ctx_req_id[w_gnt_load_tag[hart_idx]];
          reg_gnt_line[hart_idx] <= w_ctx_pa_line[w_gnt_load_tag[hart_idx]];
          reg_gnt_state[hart_idx] <= reg_ctx_gnt_state[w_gnt_load_tag[hart_idx]];
          reg_gnt_err[hart_idx] <= reg_ctx_gnt_err[w_gnt_load_tag[hart_idx]]
                                     | w_ctx_txn_err[w_gnt_load_tag[hart_idx]];
        end
      end
    end
  end

  // Register only each FSM's current state in its dedicated sequential process.
  // The process above is the sole state owner; payload registers are isolated separately.
  assign o_coh_proto_diag_event = w_table_diag | (|w_dir_diag)
                                | (|w_probe_diag) | w_lookup_diag_event | w_ack_state_diag;

endmodule
