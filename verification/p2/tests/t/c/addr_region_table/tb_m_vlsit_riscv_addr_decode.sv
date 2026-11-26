`timescale 1ns/1ps

/*
 * Project      : VLSIT RISC-V CPU Cluster
 * Author       : Quan Nguyen and Codex - VLSI Technology page
 * Description  : Directed checks for the shared parameterized PMA/router region table.
 */
module tb_m_vlsit_riscv_addr_decode;

  localparam logic [31:0] LPARA_TEST_REGION_NUM = 32'd3;
  localparam logic [31:0] LPARA_TEST_BASE_LO [0:15] = '{
    default:32'd0,
    0:32'h8000_0000,
    1:32'h4000_0000,
    2:32'h6000_0000
  };
  localparam logic [31:0] LPARA_TEST_BASE_HI [0:15] = '{default:32'd0};
  localparam logic [31:0] LPARA_TEST_SIZE_LO [0:15] = '{
    default:32'd0,
    0:32'h4000_0000,
    1:32'h1000_0000,
    2:32'h1000_0000
  };
  localparam logic [31:0] LPARA_TEST_SIZE_HI [0:15] = '{default:32'd0};
  localparam logic [31:0] LPARA_TEST_TYPE [0:15] = '{
    default:32'd0,
    0:32'd0,
    1:32'd1,
    2:32'd2
  };

  localparam logic [31:0] LPARA_OVERLAP_BASE_LO [0:15] = '{
    default:32'd0,
    0:32'h8000_0000,
    1:32'h9000_0000
  };
  localparam logic [31:0] LPARA_OVERLAP_SIZE_LO [0:15] = '{
    default:32'd0,
    0:32'h4000_0000,
    1:32'h1000_0000
  };
  localparam logic [31:0] LPARA_OVERLAP_TYPE [0:15] = '{
    default:32'd0,
    0:32'd0,
    1:32'd1
  };

  logic [63:0] w_phys_addr;
  logic [11:0] w_access_bytes;
  logic        w_atomic;
  logic        w_config_valid;
  logic        w_region_match;
  logic [3:0]  w_region_idx;
  logic [1:0]  w_region_type;
  logic        w_access_err;
  logic        w_overlap_config_valid;
  logic        w_overlap_region_match;
  logic [3:0]  w_overlap_region_idx;
  logic [1:0]  w_overlap_region_type;
  logic        w_overlap_access_err;

  // Three legal regions share the same parameter format used by PMA and AXI routing.
  m_vlsit_riscv_addr_decode #(
    .PARA_ADDR_REGION_NUM(LPARA_TEST_REGION_NUM),
    .PARA_ADDR_REGION_BASE_LO(LPARA_TEST_BASE_LO),
    .PARA_ADDR_REGION_BASE_HI(LPARA_TEST_BASE_HI),
    .PARA_ADDR_REGION_SIZE_LO(LPARA_TEST_SIZE_LO),
    .PARA_ADDR_REGION_SIZE_HI(LPARA_TEST_SIZE_HI),
    .PARA_ADDR_REGION_TYPE(LPARA_TEST_TYPE)
  ) u_vlsit_riscv_addr_decode (
    .i_phys_addr(w_phys_addr),
    .i_access_bytes(w_access_bytes),
    .i_atomic(w_atomic),
    .o_config_valid(w_config_valid),
    .o_region_match(w_region_match),
    .o_region_idx(w_region_idx),
    .o_region_type(w_region_type),
    .o_access_err(w_access_err)
  );

  // Deliberately overlapping regions must invalidate the entire static table.
  m_vlsit_riscv_addr_decode #(
    .PARA_ADDR_REGION_NUM(32'd2),
    .PARA_ADDR_REGION_BASE_LO(LPARA_OVERLAP_BASE_LO),
    .PARA_ADDR_REGION_BASE_HI(LPARA_TEST_BASE_HI),
    .PARA_ADDR_REGION_SIZE_LO(LPARA_OVERLAP_SIZE_LO),
    .PARA_ADDR_REGION_SIZE_HI(LPARA_TEST_SIZE_HI),
    .PARA_ADDR_REGION_TYPE(LPARA_OVERLAP_TYPE)
  ) u_vlsit_riscv_addr_decode_overlap (
    .i_phys_addr(w_phys_addr),
    .i_access_bytes(w_access_bytes),
    .i_atomic(w_atomic),
    .o_config_valid(w_overlap_config_valid),
    .o_region_match(w_overlap_region_match),
    .o_region_idx(w_overlap_region_idx),
    .o_region_type(w_overlap_region_type),
    .o_access_err(w_overlap_access_err)
  );

  // Fail immediately with the case label when an address-table contract is violated.
  task automatic check_result(
    input logic        i_exp_match,
    input logic [3:0]  i_exp_idx,
    input logic [1:0]  i_exp_type,
    input logic        i_exp_err,
    input string       i_case_name
  );
    begin
      #1;
      if ((w_config_valid !== 1'b1) ||
          (w_region_match !== i_exp_match) ||
          (w_region_idx !== i_exp_idx) ||
          (w_region_type !== i_exp_type) ||
          (w_access_err !== i_exp_err)) begin
        $error("FAIL %s: cfg=%b match=%b idx=%0d type=%0d err=%b",
               i_case_name, w_config_valid, w_region_match, w_region_idx,
               w_region_type, w_access_err);
        $fatal(1);
      end
    end
  endtask

  initial begin
    w_phys_addr = 64'd0;
    w_access_bytes = 12'd0;
    w_atomic = 1'b0;

    w_phys_addr = 64'h0000_0000_8000_0000;
    w_access_bytes = 12'd8;
    check_result(1'b1, 4'd0, 2'd0, 1'b0, "cacheable region base");

    w_phys_addr = 64'h0000_0000_BFFF_FFF0;
    w_access_bytes = 12'd16;
    check_result(1'b1, 4'd0, 2'd0, 1'b0, "cacheable last aligned beat");

    w_phys_addr = 64'h0000_0000_BFFF_FFF8;
    w_access_bytes = 12'd16;
    check_result(1'b1, 4'd0, 2'd0, 1'b1, "access crossing region end");

    w_phys_addr = 64'h0000_0000_4000_0010;
    w_access_bytes = 12'd4;
    check_result(1'b1, 4'd1, 2'd1, 1'b0, "normal uncached region");

    w_phys_addr = 64'h0000_0000_6000_0000;
    w_access_bytes = 12'd4;
    check_result(1'b1, 4'd2, 2'd2, 1'b0, "MMIO region");

    w_atomic = 1'b1;
    check_result(1'b1, 4'd2, 2'd2, 1'b1, "atomic access to MMIO");
    w_atomic = 1'b0;

    w_phys_addr = 64'h0000_0000_5000_0000;
    w_access_bytes = 12'd4;
    check_result(1'b0, 4'd0, 2'd3, 1'b1, "unmapped address");

    w_phys_addr = 64'h0000_0000_8000_0000;
    w_access_bytes = 12'd0;
    check_result(1'b1, 4'd0, 2'd0, 1'b1, "zero-byte access");

    #1;
    if ((w_overlap_config_valid !== 1'b0) ||
        (w_overlap_region_match !== 1'b0) ||
        (w_overlap_region_idx !== 4'd0) ||
        (w_overlap_region_type !== 2'd3) ||
        (w_overlap_access_err !== 1'b1)) begin
      $error("FAIL overlapping region table was not rejected");
      $fatal(1);
    end

    $display("PASS: region table classes, access boundaries, atomic policy, and invalid overlap");
    $finish;
  end

endmodule
