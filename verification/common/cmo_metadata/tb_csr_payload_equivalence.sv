`timescale 1ns/1ps
module tb_csr_payload_equivalence;
  import ariane_pkg::*;
  localparam config_pkg::cva6_cfg_t CFG = build_config_pkg::build_config(cva6_config_pkg::cva6_cfg);
  typedef struct packed {
    logic [63:0] cause, tval;
    logic [CFG.GPLEN-1:0] tval2;
    logic [31:0] tinst;
    logic gva, valid, timing;
  } exception_t;
  typedef struct packed {
    logic [63:0] pc, result;
    logic [CFG.TRANS_ID_BITS-1:0] trans_id;
    fu_t fu;
    fu_op op;
    logic [4:0] rd;
    logic valid, vfp, is_macro_instr, is_last_macro_instr;
    exception_t ex;
  } entry_t;
  entry_t [CFG.NrCommitPorts-1:0] entry;
  exception_t irq;
  logic clk=0,rst=0,halt,flush,step,stores,lsu_ready;
  logic [CFG.NrCommitPorts-1:0] drop;
  logic [1:0][CFG.NrCommitPorts-1:0] ack;
  logic [1:0] csr_commit,fflags;
  logic [1:0][63:0] data;
  fu_op csr_op[2];
  always #5 clk=~clk;
  `define CONNECT(K) .clk_i(clk),.rst_ni(rst),.halt_i(halt),.flush_dcache_i(flush), \
    .single_step_i(step),.commit_instr_i(entry),.commit_drop_i(drop),.commit_ack_o(ack[K]), \
    .amo_resp_i('0),.csr_rdata_i('0),.csr_exception_i(irq),.csr_wdata_o(data[K]), \
    .csr_op_o(csr_op[K]),.commit_csr_o(csr_commit[K]),.csr_write_fflags_o(fflags[K]), \
    .commit_lsu_ready_i(lsu_ready),.no_st_pending_i(stores),.shared_tlb_flush_busy_i(1'b0), \
    .sdtrig_commit_icount_valid_i(1'b0),.sdtrig_commit_icount_nr_instr_i('0), \
    .sdtrig_commit_action_i('0),.sdtrig_commit_std_exception_valid_i(1'b0), \
    .cmo_entry_valid_i(1'b0),.cmo_entry_op_i('0),.cmo_entry_paddr_i('0), \
    .cmo_entry_vaddr_i('0),.cmo_ready_i(1'b0),.cmo_done_i(1'b0),.cmo_error_i(1'b0)
  commit_stage #(.CVA6Cfg(CFG),.ExternalCmo(1'b0),.exception_t(exception_t),.scoreboard_entry_t(entry_t)) dut (.amo_error_i(1'b0),.amo_active_i(1'b0),`CONNECT(0));
  commit_stage_lint_baseline #(.CVA6Cfg(CFG),.ExternalCmo(1'b0),.exception_t(exception_t),.scoreboard_entry_t(entry_t)) reference_dut (`CONNECT(1));
  `undef CONNECT
  initial begin
    entry='0;irq='0;halt=0;flush=0;step=0;stores=0;lsu_ready=0;drop='0;
    repeat(3) @(negedge clk);rst=1;
    for(int trial=0;trial<20000;trial++) begin
      @(negedge clk);
      halt=1'($urandom);flush=1'($urandom);step=1'($urandom);
      stores=1'($urandom);lsu_ready=1'($urandom);drop=2'($urandom);
      irq='0;irq.valid=1'($urandom);
      for(int h=0;h<2;h++) begin
        entry[h]='0;entry[h].valid=1'($urandom);entry[h].ex.valid=1'($urandom);
        entry[h].ex.cause=64'($urandom);entry[h].result={$urandom,$urandom};
        case($urandom_range(0,6))
          0: begin entry[h].fu=CSR;entry[h].op=CSR_WRITE;end
          1: begin entry[h].fu=FPU;entry[h].op=FADD;end
          2: begin entry[h].fu=STORE;entry[h].op=SD;end
          3: begin entry[h].fu=ALU;entry[h].op=ADD;end
          4: begin entry[h].fu=LOAD;entry[h].op=LD;end
          5: begin entry[h].fu=CSR;entry[h].op=CSR_SET;end
          6: begin entry[h].fu=CSR;entry[h].op=CSR_CLEAR;end
        endcase
      end
      #1;
      if(ack[0]!==ack[1] || csr_commit[0]!==csr_commit[1] || fflags[0]!==fflags[1] || csr_op[0]!==csr_op[1])
        $fatal(1,"retirement/CSR control changed trial=%0d",trial);
      if((csr_commit[0] || fflags[0]) && data[0]!==data[1])
        $fatal(1,"observable CSR payload changed trial=%0d",trial);
    end
    $display("PASS: 20000 retirement/CSR payload differential cycles");$finish;
  end
endmodule
