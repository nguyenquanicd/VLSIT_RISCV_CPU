/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen (user)
 * AI Flow      : VLSIT RTL Generator AI Automation Flow
 * AI Flow Page : https://github.com/nguyenquanicd/VLSIT_RTL_Generator_AI_Model
 * Date         : 2026-11-14
 * Description  : Classifies a physical access using the shared PMA/router region table.
 * Decision     : DEC-037
 */
`timescale 1ns/1ps

module m_vlsit_riscv_addr_decode #(
  // Parameter Description: number of active regions in the shared table.
  // Parameter values: 1 through 16; default contains only the CVA6 cacheable window.
  // Parameter unit: regions.
  parameter logic [31:0] PARA_ADDR_REGION_NUM = 32'd1,
  // Parameter Description: low 32 bits of the 64-bit base address for each region.
  // Parameter values: active bases are 16-byte aligned and below 2^56.
  // Parameter unit: bytes.
  parameter logic [31:0] PARA_ADDR_REGION_BASE_LO [0:15] = '{default:32'd0, 0:32'h8000_0000},
  // Parameter Description: high 32 bits of the 64-bit base address for each region.
  // Parameter values: active bases are 16-byte aligned and below 2^56.
  // Parameter unit: bytes.
  parameter logic [31:0] PARA_ADDR_REGION_BASE_HI [0:15] = '{default:32'd0},
  // Parameter Description: low 32 bits of the 64-bit length for each region.
  // Parameter values: active lengths are non-zero 16-byte multiples.
  // Parameter unit: bytes.
  parameter logic [31:0] PARA_ADDR_REGION_SIZE_LO [0:15] = '{default:32'd0, 0:32'h4000_0000},
  // Parameter Description: high 32 bits of the 64-bit length for each region.
  // Parameter values: active lengths are 16-byte multiples.
  // Parameter unit: bytes.
  parameter logic [31:0] PARA_ADDR_REGION_SIZE_HI [0:15] = '{default:32'd0},
  // Parameter Description: region class word; only bits [1:0] encode the address class.
  // Parameter values: 0 cacheable, 1 normal uncached, 2 MMIO; upper bits and 3 are reserved.
  // Parameter unit: none.
  parameter logic [31:0] PARA_ADDR_REGION_TYPE [0:15] = '{default:32'd0},
  localparam logic [31:0] LPARA_ADDR_REGION_MAX = 32'd16,
  localparam logic [31:0] LPARA_REGION_CACHEABLE = 32'd0,
  localparam logic [31:0] LPARA_REGION_NORMAL_UNCACHED = 32'd1,
  localparam logic [31:0] LPARA_REGION_MMIO = 32'd2,
  localparam logic [31:0] LPARA_REGION_INVALID = 32'd3
) (
  // Address request attributes
  input  wire  [63:0] i_phys_addr,
  input  wire  [11:0] i_access_bytes,
  input  wire         i_atomic,

  // Region classification result
  output logic        o_config_valid,
  output logic        o_region_match,
  output logic [3:0]  o_region_idx,
  output logic [1:0]  o_region_type,
  output logic        o_access_err
);

  logic [8:0] w_decode_result;

  // Validate the static region table before using its comparisons.
  function automatic logic f_region_table_valid;
    logic [63:0] v_base_i;
    logic [63:0] v_size_i;
    logic [63:0] v_base_j;
    logic [63:0] v_size_j;
    logic [64:0] v_end_i;
    logic [64:0] v_end_j;
    logic [31:0] v_cacheable_count;
    logic        v_valid;
    begin
      v_base_i = '0;
      v_size_i = '0;
      v_base_j = '0;
      v_size_j = '0;
      v_end_i = '0;
      v_end_j = '0;
      v_cacheable_count = '0;
      v_valid = 1'b1;

      if ((PARA_ADDR_REGION_NUM == 32'd0) || (PARA_ADDR_REGION_NUM > LPARA_ADDR_REGION_MAX))
        v_valid = 1'b0;

      for (int unsigned v_i = 0; v_i < LPARA_ADDR_REGION_MAX; v_i++) begin
        if (v_i < PARA_ADDR_REGION_NUM) begin
          v_base_i = {PARA_ADDR_REGION_BASE_HI[v_i], PARA_ADDR_REGION_BASE_LO[v_i]};
          v_size_i = {PARA_ADDR_REGION_SIZE_HI[v_i], PARA_ADDR_REGION_SIZE_LO[v_i]};
          v_end_i = {1'b0, v_base_i} + {1'b0, v_size_i};

          if ((v_base_i[63:56] != 8'd0) || (v_size_i == 64'd0) ||
              (v_base_i[3:0] != 4'd0) || (v_size_i[3:0] != 4'd0) ||
              (v_end_i > 65'h0100_0000_0000_0000) ||
              (PARA_ADDR_REGION_TYPE[v_i][31:2] != 30'd0) ||
              (PARA_ADDR_REGION_TYPE[v_i][1:0] == LPARA_REGION_INVALID[1:0]))
            v_valid = 1'b0;

          case (PARA_ADDR_REGION_TYPE[v_i][1:0])
            LPARA_REGION_CACHEABLE[1:0]: begin
              v_cacheable_count = v_cacheable_count + 32'd1;
              if ((v_i != 0) || ((v_size_i & (v_size_i - 64'd1)) != 64'd0) ||
                  ((v_base_i & (v_size_i - 64'd1)) != 64'd0))
                v_valid = 1'b0;
            end
            LPARA_REGION_NORMAL_UNCACHED[1:0]: begin
            end
            LPARA_REGION_MMIO[1:0]: begin
            end
            default: v_valid = 1'b0;
          endcase

          for (int unsigned v_j = 0; v_j < LPARA_ADDR_REGION_MAX; v_j++) begin
            if ((v_j > v_i) && (v_j < PARA_ADDR_REGION_NUM)) begin
              v_base_j = {PARA_ADDR_REGION_BASE_HI[v_j], PARA_ADDR_REGION_BASE_LO[v_j]};
              v_size_j = {PARA_ADDR_REGION_SIZE_HI[v_j], PARA_ADDR_REGION_SIZE_LO[v_j]};
              v_end_j = {1'b0, v_base_j} + {1'b0, v_size_j};
              if (({1'b0, v_base_i} < v_end_j) && ({1'b0, v_base_j} < v_end_i))
                v_valid = 1'b0;
            end
          end
        end
      end

      if (v_cacheable_count != 32'd1)
        v_valid = 1'b0;

      return v_valid;
    end
  endfunction

  // Decode one physical access against the statically validated table.
  function automatic logic [8:0] f_decode_addr_region(
    input logic [63:0] i_func_addr,
    input logic [11:0] i_func_bytes,
    input logic        i_func_atomic
  );
    logic [8:0] v_result;
    logic        v_region_found;
    logic        v_access_err;
    logic [3:0]  v_region_idx;
    logic [1:0]  v_region_type;
    logic        v_config_valid;
    logic [64:0] v_addr_start;
    logic [64:0] v_access_end;
    logic [64:0] v_region_end;
    logic [64:0] v_current_region_end;
    logic [63:0] v_region_base;
    logic [63:0] v_region_size;
    begin
      v_result = '0;
      v_access_err = 1'b1;
      v_region_idx = 4'd0;
      v_region_type = LPARA_REGION_INVALID[1:0];
      v_config_valid = 1'b0;
      v_region_found = 1'b0;
      v_addr_start = {1'b0, i_func_addr};
      v_access_end = {1'b0, i_func_addr} + {53'd0, i_func_bytes};
      v_region_end = '0;
      v_current_region_end = '0;
      v_region_base = '0;
      v_region_size = '0;
      v_config_valid = f_region_table_valid();

      for (int unsigned v_region = 0; v_region < LPARA_ADDR_REGION_MAX; v_region++) begin
        if ((v_config_valid == 1'b1) && (v_region < PARA_ADDR_REGION_NUM)) begin
          v_region_base = {PARA_ADDR_REGION_BASE_HI[v_region], PARA_ADDR_REGION_BASE_LO[v_region]};
          v_region_size = {PARA_ADDR_REGION_SIZE_HI[v_region], PARA_ADDR_REGION_SIZE_LO[v_region]};
          v_current_region_end = {1'b0, v_region_base} + {1'b0, v_region_size};

          if ((v_addr_start >= {1'b0, v_region_base}) &&
              (v_addr_start < v_current_region_end)) begin
            v_region_found = 1'b1;
            v_region_end = v_current_region_end;
            v_region_idx = 4'(v_region);
            v_region_type = PARA_ADDR_REGION_TYPE[v_region][1:0];
          end
        end
      end

      if (v_region_found && (i_func_addr[63:56] == 8'd0) &&
          (i_func_bytes != 12'd0) && (v_access_end <= v_region_end) &&
          !((i_func_atomic == 1'b1) &&
            (v_region_type == LPARA_REGION_MMIO[1:0])))
        v_access_err = 1'b0;

      v_result = {v_config_valid, v_region_found, v_region_idx, v_region_type, v_access_err};

      return v_result;
    end
  endfunction

  // Drive all outputs from the pure address-classification function.
  always_comb begin : p_com_addr_region_decode
    w_decode_result = f_decode_addr_region(i_phys_addr, i_access_bytes, i_atomic);
    o_config_valid = w_decode_result[8];
    o_region_match = w_decode_result[7];
    o_region_idx = w_decode_result[6:3];
    o_region_type = w_decode_result[2:1];
    o_access_err = w_decode_result[0];
  end

endmodule
