// -----------------------------------------------------------------------------
// AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate artifact (R-117, R-231).
// Formal property checker for t_rv32d_fv_addr_decode. Port contract: REF-001
// rev 0.39 Section 14.4.13 (m_vlsit_riscv_addr_decode); semantics REQ-IF-011,
// 14.4.13 text (full-window compare, boundary-crossing error, MMIO atomic error,
// fail closed), campaign table of question_log Q-G0-03, REQ-XL-011 (Q-G0-09).
// The campaign table and class encoding (00 cacheable, 01 normal uncached, 10 MMIO)
// follow REF-001 rev 0.40 Section 14.4.20 (Q-G3-01 answered); the table is bound in
// fv_tops.sv with the 14.4.20 parameter names (assumption recorded there).
// -----------------------------------------------------------------------------
module fv_addr_decode_props (
  input logic [63:0] i_phys_addr, input logic [11:0] i_access_bytes, input logic i_atomic,
  input logic o_config_valid, input logic o_region_match, input logic [3:0] o_region_idx,
  input logic [1:0] o_region_type, input logic o_access_err
);
  localparam int NREG = 5;
  localparam logic [63:0] BASE [NREG] = '{64'h8000_0000, 64'h1000_0000, 64'h0000_0000, 64'h4000_0000, 64'h3_C000_0000};
  localparam logic [63:0] SIZE [NREG] = '{64'h4000_0000, 64'h1000_0000, 64'h0000_1000, 64'h1000_0000, 64'h4000_0000};
  localparam logic [1:0]  CLS  [NREG] = '{2'b00, 2'b10, 2'b10, 2'b01, 2'b01};
  logic [64:0] last;
  int hit;
  always @* begin
    assume (i_access_bytes != 12'd0 && i_access_bytes <= 12'd64);
    last = {1'b0, i_phys_addr} + 65'(i_access_bytes) - 65'd1;
    hit = -1;
    for (int r = 0; r < NREG; r++) if (i_phys_addr >= BASE[r] && i_phys_addr < BASE[r] + SIZE[r]) hit = r;
    a_dec_config_valid: assert (o_config_valid);
    if (hit < 0) begin
      a_dec_unmapped: assert (!o_region_match && o_access_err);
    end else begin
      if (last >= {1'b0, BASE[hit] + SIZE[hit]}) a_dec_cross_err: assert (o_access_err);
      else if (i_atomic && CLS[hit] == 2'b10) a_dec_mmio_atomic: assert (o_access_err);
      else begin
        a_dec_class: assert (o_region_match && !o_access_err && o_region_idx == 4'(hit) && o_region_type == CLS[hit]);
        if (hit == 4) a_dec_top_line: assert (!o_access_err);    // region 4 ends exactly at 2^34 (REQ-XL-011)
      end
    end
    c_dec_each_class: cover (o_region_match && o_region_type == 2'b01);
    c_dec_top_line: cover (hit == 4 && last == 65'h3_FFFF_FFFF);
  end
endmodule
