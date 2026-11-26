`timescale 1ns/1ps
module tb_fpu_wrap_equivalence;
  import ariane_pkg::*;
  localparam config_pkg::cva6_cfg_t CFG=build_config_pkg::build_config(cva6_config_pkg::cva6_cfg);
  typedef struct packed {
    logic[63:0] cause,tval;
    logic[CFG.GPLEN-1:0] tval2;
    logic[31:0] tinst;
    logic gva,valid,timing;
  } exception_t;
  typedef struct packed {
    logic[63:0] operand_a,operand_b,imm;
    logic[CFG.TRANS_ID_BITS-1:0] trans_id;
    fu_t fu;
    fu_op operation;
  } fu_data_t;
  logic clk=0,rst=0,valid=0,flush=0;
  fu_data_t data;
  logic[1:0] fmt;
  logic[2:0] rm;
  logic[1:0] ready,outvalid,early;
  logic[1:0][63:0] result;
  logic[1:0][CFG.TRANS_ID_BITS-1:0] tag;
  exception_t exception[2];
  int cycles=0,received=0,current_trial=0;
  int held_cycles=0,flush_while_held=0,burst_accepted=0;
  always #5 clk=~clk;
  `define CONNECT(K) .clk_i(clk),.rst_ni(rst),.flush_i(flush),.fpu_valid_i(valid), \
    .fpu_ready_o(ready[K]),.fu_data_i(data),.fpu_fmt_i(fmt),.fpu_rm_i(rm), \
    .fpu_frm_i(3'b000),.fpu_prec_i(7'd0),.fpu_trans_id_o(tag[K]), \
    .result_o(result[K]),.fpu_valid_o(outvalid[K]),.fpu_exception_o(exception[K]),.fpu_early_valid_o(early[K])
  fpu_wrap #(.CVA6Cfg(CFG),.exception_t(exception_t),.fu_data_t(fu_data_t)) dut (`CONNECT(0));
  fpu_wrap_lint_baseline #(.CVA6Cfg(CFG),.exception_t(exception_t),.fu_data_t(fu_data_t)) reference_dut (`CONNECT(1));
  `undef CONNECT
  always @(posedge clk) if(rst) begin
    if(ready[0]!==ready[1] || outvalid[0]!==outvalid[1] || early[0]!==early[1])
      $fatal(1,"FPU wrapper latency/handshake mismatch cycle=%0d",cycles);
    if(outvalid[0]) begin
      if({result[0],tag[0],exception[0]}!=={result[1],tag[1],exception[1]})
        $fatal(1,"FPU wrapper result/status mismatch cycle=%0d op=%0d fmt=%0d old=%h new=%h",cycles,data.operation,fmt,result[1],result[0]);
      received++;
    end
    if(dut.state_q == 1'b1) begin
      held_cycles++;
      if(flush) flush_while_held++;
    end
    cycles++;
    if(cycles>500000) $fatal(1,"FPU wrapper watchdog trial=%0d received=%0d op=%0d fmt=%0d ready=%b outvalid=%b",current_trial,received,data.operation,fmt,ready,outvalid);
  end
  initial begin
    data='0;fmt=0;rm=0;
    repeat(4) @(negedge clk);rst=1;
    for(int trial=0;trial<1600;trial++) begin
      current_trial=trial;
      @(negedge clk);data='0;data.fu=FPU;data.trans_id=CFG.TRANS_ID_BITS'(trial);
      data.operand_a={$urandom,$urandom};data.operand_b={$urandom,$urandom};data.imm={$urandom,$urandom};
      fmt=2'((trial/16)%2);rm=3'($urandom_range(0,4));
      if(fmt==0) begin data.operand_a[63:32]='1;data.operand_b[63:32]='1;data.imm[63:32]='1;end
      case(trial%16)
        0:data.operation=FADD;
        1:data.operation=FSUB;
        2:data.operation=FMUL;
        3:data.operation=FDIV;
        4:data.operation=FSQRT;
        5:data.operation=FMADD;
        6:data.operation=FMSUB;
        7:data.operation=FNMSUB;
        8:data.operation=FNMADD;
        9:begin data.operation=FMIN_MAX;rm=3'($urandom_range(0,1));end
        10:begin data.operation=FSGNJ;rm=3'($urandom_range(0,2));end
        11:begin data.operation=FCMP;rm=3'($urandom_range(0,2));end
        // FCLASS has funct3=001. Bit 2 would select the disabled FP16ALT extension.
        12:begin data.operation=FCLASS;rm=3'b001;end
        13:begin data.operation=FCVT_F2I;data.imm=64'($urandom_range(0,3));end
        14:begin data.operation=FCVT_I2F;data.imm=64'($urandom_range(0,3));end
        15:begin data.operation=FCVT_F2F;data.imm=64'($urandom_range(0,1));end
      endcase
      valid=1;
      do begin @(posedge clk);end while(!ready[0]);
      @(negedge clk);valid=0;
      wait(received==trial+1);
      if(trial<16) $display("wrapper completed trial=%0d op=%0d fmt=%0d",trial,data.operation,fmt);
    end
    @(negedge clk);
    // Back-to-back DIV requests force READY->STALL and hold selection.
    // Mixed groups/formats exercise shared-slice readiness and simultaneous results.
    for(int trial=0;trial<256;trial++) begin
      int waited;
      bit canceled;
      @(negedge clk); flush=0; data='0; data.fu=FPU;
      data.trans_id=CFG.TRANS_ID_BITS'(trial); fmt=2'(trial%2); rm=0;
      data.operand_a=fmt==0 ? 64'hffffffff_40e00000:64'h401c000000000000;
      data.operand_b=fmt==0 ? 64'hffffffff_40400000:64'h4008000000000000;
      data.imm=64'd0;
      case(trial%8)
        0,1,2,3:data.operation=FDIV;
        4:data.operation=FADD;
        5:data.operation=FMUL;
        6:data.operation=FCVT_F2I;
        7:data.operation=FSQRT;
      endcase
      valid=1; waited=0; canceled=0;
      do begin
        @(posedge clk);
        if(ready[0]) begin burst_accepted++; break; end
        waited++;
        // Periodically cancel a blocked request using the actual wrapper flush port.
        if(trial%16==1 && waited==3) begin
          @(negedge clk);flush=1;
          @(posedge clk);
          @(negedge clk);flush=0;valid=0;canceled=1;break;
        end
        if(waited>500) $fatal(1,"FPU burst request stalled indefinitely");
      end while(!ready[0]);
      @(negedge clk);valid=0;
    end
    repeat(200) @(negedge clk);
    if(held_cycles==0 || flush_while_held==0 || burst_accepted==0)
      $fatal(1,"FPU STALL/flush/burst tests were not exercised");
    $display("CHECK FPU held_cycles=%0d flush_while_held=%0d burst_accepted=%0d",held_cycles,flush_while_held,burst_accepted);
    $display("PASS: 1600 full FPU wrapper transactions, independent legacy package, result/status/tag/latency");$finish;
  end
endmodule
