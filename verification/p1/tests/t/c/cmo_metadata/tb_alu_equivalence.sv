`timescale 1ns/1ps
module tb_alu_equivalence;
  import ariane_pkg::*;
  logic[1:0] finished=0;
  function automatic config_pkg::cva6_cfg_t make_cfg(input int width_bits);
    config_pkg::cva6_cfg_t cfg=build_config_pkg::build_config(cva6_config_pkg::cva6_cfg);
    cfg.XLEN=width_bits;cfg.IS_XLEN32=(width_bits==32);cfg.IS_XLEN64=(width_bits==64);
    cfg.RVB=1;cfg.ZKN=1;cfg.RVZiCond=1;
    return cfg;
  endfunction
  for(genvar k=0;k<2;k++) begin : gen_width
    localparam int WIDTH=(k==0)?32:64;
    localparam config_pkg::cva6_cfg_t CFG=make_cfg(WIDTH);
    typedef struct packed {logic[WIDTH-1:0] operand_a,operand_b;fu_op operation;} data_t;
    data_t data;
    logic[1:0][WIDTH-1:0] result;
    logic[1:0] branch_result;
    alu #(.CVA6Cfg(CFG),.fu_data_t(data_t)) dut (
      .clk_i(1'b0),.rst_ni(1'b1),.fu_data_i(data),.fu_data_cpop_i(data),.result_o(result[0]),.alu_branch_res_o(branch_result[0]));
    alu_lint_baseline #(.CVA6Cfg(CFG),.fu_data_t(data_t)) reference_dut (
      .clk_i(1'b0),.rst_ni(1'b1),.fu_data_i(data),.fu_data_cpop_i(data),.result_o(result[1]),.alu_branch_res_o(branch_result[1]));
    initial begin
      data='0;
      for(int trial=0;trial<100000;trial++) begin
        data.operation=fu_op'(trial);
        data.operand_a=WIDTH'({$urandom,$urandom});data.operand_b=WIDTH'({$urandom,$urandom});
        if(trial%4==0)data.operand_b=WIDTH'(trial%WIDTH);
        #1;
        if({result[0],branch_result[0]}!=={result[1],branch_result[1]})
          $fatal(1,"ALU width=%0d op=%0d changed old=%h new=%h",WIDTH,data.operation,result[1],result[0]);
      end
      finished[k]=1;
    end
  end
  initial begin wait(&finished);$display("PASS: 200000 ALU differential cases, 32/64-bit, bitmanip/crypto/conditional operations");$finish;end
endmodule
