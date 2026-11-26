`timescale 1ns/1ps
module tb_fpnew_fma_equivalence;
  logic clk=0,rst=0;
  logic[1:0] finished=0;
  always #5 clk=~clk;
  initial begin repeat(4) @(negedge clk);rst=1;wait(&finished);$display("PASS: fma 20000 differential FP32/FP64 cycles");$finish;end
  begin : gen_case_0
    logic [95:0] operands;
    logic [2:0] boxed;
    logic modifier,mask,valid,flush,ready;
    logic[7:0] tag;
    logic[3:0] aux;
    fpnew_pkg::operation_e op;
    fpnew_pkg::roundmode_e rnd;
    fpnew_pkg::fp_format_e src_fmt,dst_fmt;
    fpnew_pkg::int_format_e int_fmt;
    logic[1:0][31:0] result;
    fpnew_pkg::status_t status[2];
    logic[1:0] ext,outmask,outvalid,inready,busy,early,isclass;
    logic[1:0][7:0] outtag;
    logic[1:0][3:0] outaux;
    fpnew_pkg::classmask_e classmask[2];
    fpnew_fma #(.FpFormat(fpnew_pkg::FP32),.NumPipeRegs(2),.PipeConfig(fpnew_pkg::DISTRIBUTED),.TagType(logic[7:0]),.AuxType(logic[3:0])) m0 (.clk_i(clk),.rst_ni(rst),.operands_i(operands),.is_boxed_i(boxed),.rnd_mode_i(rnd),.op_i(op),.op_mod_i(modifier),.tag_i(tag),.mask_i(mask),.aux_i(aux),.in_valid_i(valid),.flush_i(flush),.out_ready_i(ready),.reg_ena_i(2'b00),.result_o(result[0]),.status_o(status[0]),.extension_bit_o(ext[0]),.tag_o(outtag[0]),.mask_o(outmask[0]),.aux_o(outaux[0]),.out_valid_o(outvalid[0]),.in_ready_o(inready[0]),.busy_o(busy[0]),.early_out_valid_o(early[0]));
    fpnew_fma_lint_baseline #(.FpFormat(fpnew_pkg_lint_baseline::FP32),.NumPipeRegs(2),.PipeConfig(fpnew_pkg_lint_baseline::DISTRIBUTED),.TagType(logic[7:0]),.AuxType(logic[3:0])) m1 (.clk_i(clk),.rst_ni(rst),.operands_i(operands),.is_boxed_i(boxed),.rnd_mode_i(fpnew_pkg_lint_baseline::roundmode_e'(rnd)),.op_i(fpnew_pkg_lint_baseline::operation_e'(op)),.op_mod_i(modifier),.tag_i(tag),.mask_i(mask),.aux_i(aux),.in_valid_i(valid),.flush_i(flush),.out_ready_i(ready),.reg_ena_i(2'b00),.result_o(result[1]),.status_o(status[1]),.extension_bit_o(ext[1]),.tag_o(outtag[1]),.mask_o(outmask[1]),.aux_o(outaux[1]),.out_valid_o(outvalid[1]),.in_ready_o(inready[1]),.busy_o(busy[1]),.early_out_valid_o(early[1]));
    initial begin
      operands='0;boxed='1;modifier=0;mask=1;valid=0;flush=0;ready=0;
      tag=0;aux=0;op=fpnew_pkg::FMADD;rnd=fpnew_pkg::RNE;
      src_fmt=fpnew_pkg::FP32;dst_fmt=fpnew_pkg::FP64;int_fmt=fpnew_pkg::INT32;
      wait(rst);
      for(int trial=0;trial<10000;trial++) begin
        @(negedge clk);
        for(int b=0;b<$bits(operands);b++) operands[b]=1'($urandom);
        if(trial%8==0) operands='0;
        if(trial%8==1) operands='1;
        modifier=1'($urandom);mask=1'($urandom);valid=1'($urandom);
        flush=($urandom_range(0,40)==0);ready=1'($urandom);
        tag=8'($urandom);aux=4'($urandom);
        case($urandom_range(0,4))
        0:op=fpnew_pkg::FMADD;
        1:op=fpnew_pkg::FNMSUB;
        2:op=fpnew_pkg::ADD;
        3:op=fpnew_pkg::MUL;
        4:op=fpnew_pkg::ADDS;
        endcase
        rnd=fpnew_pkg::roundmode_e'($urandom_range(0,4));
        if(op==fpnew_pkg::MINMAX) rnd=fpnew_pkg::roundmode_e'($urandom_range(0,1));
        if(op==fpnew_pkg::CMP) rnd=fpnew_pkg::roundmode_e'($urandom_range(0,2));
        if(op==fpnew_pkg::SGNJ) rnd=fpnew_pkg::roundmode_e'($urandom_range(0,3));
        src_fmt=$urandom_range(0,1) ? fpnew_pkg::FP32:fpnew_pkg::FP64;
        dst_fmt=$urandom_range(0,1) ? fpnew_pkg::FP32:fpnew_pkg::FP64;
        int_fmt=fpnew_pkg::int_format_e'($urandom_range(0,3));
        #1;
        if({inready[0],outvalid[0],busy[0],early[0]}!=={inready[1],outvalid[1],busy[1],early[1]})
          $fatal(1,"fma FP32 handshake changed trial=%0d",trial);
        if(outvalid[0] && {result[0],status[0],ext[0],outtag[0],outmask[0],outaux[0]}!=={result[1],status[1],ext[1],outtag[1],outmask[1],outaux[1]})
          $fatal(1,"fma FP32 result/status changed trial=%0d old=%h new=%h",trial,result[1],result[0]);
      end
      finished[0]=1;
    end
  end
  begin : gen_case_1
    logic [191:0] operands;
    logic [2:0] boxed;
    logic modifier,mask,valid,flush,ready;
    logic[7:0] tag;
    logic[3:0] aux;
    fpnew_pkg::operation_e op;
    fpnew_pkg::roundmode_e rnd;
    fpnew_pkg::fp_format_e src_fmt,dst_fmt;
    fpnew_pkg::int_format_e int_fmt;
    logic[1:0][63:0] result;
    fpnew_pkg::status_t status[2];
    logic[1:0] ext,outmask,outvalid,inready,busy,early,isclass;
    logic[1:0][7:0] outtag;
    logic[1:0][3:0] outaux;
    fpnew_pkg::classmask_e classmask[2];
    fpnew_fma #(.FpFormat(fpnew_pkg::FP64),.NumPipeRegs(2),.PipeConfig(fpnew_pkg::DISTRIBUTED),.TagType(logic[7:0]),.AuxType(logic[3:0])) m0 (.clk_i(clk),.rst_ni(rst),.operands_i(operands),.is_boxed_i(boxed),.rnd_mode_i(rnd),.op_i(op),.op_mod_i(modifier),.tag_i(tag),.mask_i(mask),.aux_i(aux),.in_valid_i(valid),.flush_i(flush),.out_ready_i(ready),.reg_ena_i(2'b00),.result_o(result[0]),.status_o(status[0]),.extension_bit_o(ext[0]),.tag_o(outtag[0]),.mask_o(outmask[0]),.aux_o(outaux[0]),.out_valid_o(outvalid[0]),.in_ready_o(inready[0]),.busy_o(busy[0]),.early_out_valid_o(early[0]));
    fpnew_fma_lint_baseline #(.FpFormat(fpnew_pkg_lint_baseline::FP64),.NumPipeRegs(2),.PipeConfig(fpnew_pkg_lint_baseline::DISTRIBUTED),.TagType(logic[7:0]),.AuxType(logic[3:0])) m1 (.clk_i(clk),.rst_ni(rst),.operands_i(operands),.is_boxed_i(boxed),.rnd_mode_i(fpnew_pkg_lint_baseline::roundmode_e'(rnd)),.op_i(fpnew_pkg_lint_baseline::operation_e'(op)),.op_mod_i(modifier),.tag_i(tag),.mask_i(mask),.aux_i(aux),.in_valid_i(valid),.flush_i(flush),.out_ready_i(ready),.reg_ena_i(2'b00),.result_o(result[1]),.status_o(status[1]),.extension_bit_o(ext[1]),.tag_o(outtag[1]),.mask_o(outmask[1]),.aux_o(outaux[1]),.out_valid_o(outvalid[1]),.in_ready_o(inready[1]),.busy_o(busy[1]),.early_out_valid_o(early[1]));
    initial begin
      operands='0;boxed='1;modifier=0;mask=1;valid=0;flush=0;ready=0;
      tag=0;aux=0;op=fpnew_pkg::FMADD;rnd=fpnew_pkg::RNE;
      src_fmt=fpnew_pkg::FP32;dst_fmt=fpnew_pkg::FP64;int_fmt=fpnew_pkg::INT32;
      wait(rst);
      for(int trial=0;trial<10000;trial++) begin
        @(negedge clk);
        for(int b=0;b<$bits(operands);b++) operands[b]=1'($urandom);
        if(trial%8==0) operands='0;
        if(trial%8==1) operands='1;
        modifier=1'($urandom);mask=1'($urandom);valid=1'($urandom);
        flush=($urandom_range(0,40)==0);ready=1'($urandom);
        tag=8'($urandom);aux=4'($urandom);
        case($urandom_range(0,4))
        0:op=fpnew_pkg::FMADD;
        1:op=fpnew_pkg::FNMSUB;
        2:op=fpnew_pkg::ADD;
        3:op=fpnew_pkg::MUL;
        4:op=fpnew_pkg::ADDS;
        endcase
        rnd=fpnew_pkg::roundmode_e'($urandom_range(0,4));
        if(op==fpnew_pkg::MINMAX) rnd=fpnew_pkg::roundmode_e'($urandom_range(0,1));
        if(op==fpnew_pkg::CMP) rnd=fpnew_pkg::roundmode_e'($urandom_range(0,2));
        if(op==fpnew_pkg::SGNJ) rnd=fpnew_pkg::roundmode_e'($urandom_range(0,3));
        src_fmt=$urandom_range(0,1) ? fpnew_pkg::FP32:fpnew_pkg::FP64;
        dst_fmt=$urandom_range(0,1) ? fpnew_pkg::FP32:fpnew_pkg::FP64;
        int_fmt=fpnew_pkg::int_format_e'($urandom_range(0,3));
        #1;
        if({inready[0],outvalid[0],busy[0],early[0]}!=={inready[1],outvalid[1],busy[1],early[1]})
          $fatal(1,"fma FP64 handshake changed trial=%0d",trial);
        if(outvalid[0] && {result[0],status[0],ext[0],outtag[0],outmask[0],outaux[0]}!=={result[1],status[1],ext[1],outtag[1],outmask[1],outaux[1]})
          $fatal(1,"fma FP64 result/status changed trial=%0d old=%h new=%h",trial,result[1],result[0]);
      end
      finished[1]=1;
    end
  end
endmodule
