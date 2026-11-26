`timescale 1ns/1ps
module tb_cmo_retirement;
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
  exception_t irq, fault;
  amo_resp_t atomic_rsp='0;
  logic atomic_error=0, atomic_active=0;
  fu_op atomic_ops[6]='{AMO_LRW,AMO_LRD,AMO_SCW,AMO_SCD,AMO_ADDW,AMO_ADDD};
  logic clk=0,rst=0,halt=0,no_store=0;
  logic ready=0,done=0,error=0,valid,active,pop;
  logic ic_done=0,ic_req;
  logic [CFG.NrCommitPorts-1:0] ack;
  logic [1:0] op;
  logic [CFG.PLEN-5:0] line_addr;
  logic [63:0] va,pc;
  logic [63:0] source_va=64'hffff_ffff_8000_1237;
  always #5 clk=~clk;
  commit_stage #(.CVA6Cfg(CFG),.ExternalCmo(1'b1),
    .exception_t(exception_t),.scoreboard_entry_t(entry_t)) dut (
    .dirty_fp_state_o(),
    .commit_macro_ack_o(),
    .waddr_o(),
    .wdata_o(),
    .we_gpr_o(),
    .we_fpr_o(),
    .pc_o(),
    .csr_op_o(),
    .csr_wdata_o(),
    .csr_write_fflags_o(),
    .commit_tran_id_o(),
    .amo_valid_commit_o(),
    .commit_csr_o(),
    .fence_i_o(),
    .fence_o(),
    .flush_commit_o(),
    .sfence_vma_o(),
    .hfence_vvma_o(),
    .hfence_gvma_o(),
    .clk_i(clk),.rst_ni(rst),.halt_i(halt),.flush_dcache_i(1'b0),
    .single_step_i(1'b0),.commit_instr_i(entry),.commit_drop_i('0),
    .commit_ack_o(ack),.amo_resp_i(atomic_rsp),.amo_error_i(atomic_error),.amo_active_i(atomic_active),.csr_rdata_i('0),
    .csr_exception_i(irq),.exception_o(fault),.commit_lsu_o(pop),
    .commit_lsu_ready_i(1'b1),.no_st_pending_i(no_store),
    .shared_tlb_flush_busy_i(1'b0),.sdtrig_commit_icount_valid_i(1'b0),
    .sdtrig_commit_icount_nr_instr_i('0),.sdtrig_commit_action_i('0),
    .sdtrig_commit_std_exception_valid_i(1'b0),
    .cmo_entry_valid_i(1'b1),.cmo_entry_op_i(8'(CBO_CLEAN)),
    .cmo_entry_paddr_i(56'h8000_1237),.cmo_entry_vaddr_i(source_va),
    .cmo_valid_o(valid),.cmo_ready_i(ready),.cmo_op_o(op),
    .cmo_pa_line_o(line_addr),.cmo_vaddr_o(va),.cmo_pc_o(pc),
    .cmo_done_i(done),.cmo_error_i(error),.cmo_fault_paddr_i(56'h8000_1200),.fence_sync_o(),.fence_icache_req_o(ic_req),.fence_icache_done_i(ic_done),.cmo_active_o(active));
  task automatic start_cbo;
    @(negedge clk);
    entry='0; irq='0;
    entry[0].valid=1; entry[0].fu=STORE; entry[0].op=CBO_CLEAN;
    entry[0].pc=64'h8000_0100;
    entry[1].valid=1; entry[1].fu=ALU; entry[1].op=ADD;
  endtask
  task automatic check_held;
    #1;
    if(ack!='0 || pop || fault.valid)
      $fatal(1,"CBO/younger retirement or trap before terminal completion");
  endtask
  initial begin
    entry='0; irq='0;
    repeat(2) @(negedge clk); rst=1;
    start_cbo();
    repeat(3) begin @(posedge clk); check_held(); if(valid) $fatal(1,"older store not drained"); end
    @(negedge clk); no_store=1;
    wait(valid); #1;
    if(op!=0 || line_addr!=52'h8000_123 || va!=source_va || pc!=64'h8000_0100)
      $fatal(1,"command metadata mismatch");
    // Once the local command is buffered, pending interrupts cannot preempt it.
    @(negedge clk); irq.valid=1; irq.cause=64'h8000_0000_0000_000b;
    source_va=64'h5555;
    repeat(3) begin
      @(posedge clk); check_held();
      if(!valid || va!=64'hffff_ffff_8000_1237) $fatal(1,"VALID/payload not held under stall");
    end
    @(negedge clk); ready=1;
    @(posedge clk); #1; ready=0;
    repeat(3) begin @(posedge clk); check_held(); if(valid) $fatal(1,"duplicate command"); end
    @(negedge clk); done=1;
    @(posedge clk); #1; done=0;
    if(ack!==2'b01 || !pop || fault.valid) $fatal(1,"success not retired exactly once");
    @(posedge clk); #1; entry='0;
    @(negedge clk); irq='0;
    start_cbo();
    wait(valid); @(negedge clk); ready=1;
    @(posedge clk); #1; ready=0;
    @(negedge clk); halt=1; done=1; error=1;
    @(posedge clk); #1; done=0;
    repeat(3) begin @(posedge clk); check_held(); end
    @(negedge clk); halt=0;
    #1;
    if(!fault.valid || fault.cause!=7 || fault.tval!=64'h5555 || ack!='0 || pop)
      $fatal(1,"precise CBO fault or halt completion retention failed");
    @(posedge clk); #1; entry='0;
    @(negedge clk);
    if(active) $fatal(1,"terminal context not released");
    // DEC-031: FENCE.I has no store-buffer entry; completion carries PA.
    @(negedge clk); entry='0; irq='0;
    entry[0].valid=1; entry[0].op=FENCE_I; entry[0].fu=CSR;
    entry[0].pc=64'h8000_0240;
    entry[1].valid=1; entry[1].op=ADD; entry[1].fu=ALU;
    wait(valid); #1; if(op!=3) $fatal(1,"FENCE.I command selector");
    @(negedge clk); ready=1; irq.valid=1; irq.cause=64'h800000000000000b;
    @(posedge clk); #1; ready=0;
    repeat(5) begin @(posedge clk); check_held(); end
    @(negedge clk); done=1; error=1;
    @(posedge clk); #1; done=0;
    if(!fault.valid || fault.cause!=24 || fault.tval!=64'h80001200 || ack!='0 || pop)
      $fatal(1,"FENCE.I precise cause 24 / aligned PA / retirement hold");
    @(posedge clk); #1; entry='0; irq='0;
    @(negedge clk); entry='0; irq='0; error=0;
    entry[0].valid=1; entry[0].op=FENCE_I; entry[0].fu=CSR;
    wait(valid); @(negedge clk); ready=1;
    @(posedge clk); #1; ready=0;
    @(negedge clk); done=1;
    @(posedge clk); #1; done=0;
    if(!ic_req || ack!='0 || fault.valid) $fatal(1,"missing I-cache invalidation after clean");
    repeat(3) begin @(posedge clk); check_held(); end
    @(negedge clk); ic_done=1;
    @(posedge clk); #1; ic_done=0;
    if(ack!=2'b01 || pop || fault.valid) $fatal(1,"FENCE.I did not retire after I-cache ACK");
    @(posedge clk); #1; entry='0;
    // DEC-038: an outstanding atomic defers IRQ, then a terminal failure
    // traps with its original VA without retiring or updating either GPR port.
    @(negedge clk); rst=0; entry='0; irq='0;
    @(negedge clk); rst=1;
    for(int k=0;k<6;k++) begin
      @(negedge clk); entry='0; entry[0].valid=1; entry[0].fu=STORE;
      entry[0].op=atomic_ops[k]; entry[0].pc=64'h80000600;
      entry[0].result=64'hffff_ffff_80003000;
      entry[0].rd=5; entry[1].valid=1; entry[1].fu=ALU; entry[1].op=ADD;
      atomic_active=1; atomic_rsp='0; atomic_error=0;
      irq.valid=1; irq.cause=64'h8000000000000007;
      #1; if(fault.valid || ack!='0 || dut.we_gpr_o!='0)
        $fatal(1,"atomic wait was preempted or retired by IRQ");
      @(negedge clk); atomic_rsp.ack=1; atomic_error=1;
      #1; if(!fault.valid || fault.cause!=64'(k<2 ? 5:7) ||
              fault.tval!=64'hffff_ffff_80003000 || ack!='0 || dut.we_gpr_o!='0)
        $fatal(1,"atomic precise fault/IRQ priority/retirement mismatch");
      @(negedge clk); atomic_active=0; atomic_rsp='0; atomic_error=0; irq='0; entry='0;
    end
    $display("PASS: LR.W/D, SC.W/D, AMO.W/D precise access faults and atomic IRQ deferral");
    $display("PASS: native CVA6 retirement CBO hold, payload, interrupt deferral, success and precise error");
    $finish;
  end
  initial begin #10000; $fatal(1,"retirement watchdog"); end
endmodule
