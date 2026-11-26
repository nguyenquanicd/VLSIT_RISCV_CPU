`timescale 1ns/1ps
module tb_llc_flush_tag #(parameter int NORMAL_EVICT=0, WRITE_ERROR=0);
  localparam axi_llc_pkg::llc_cfg_t CFG = '{SetAssociativity:1, NumLines:2,
    NumBlocks:2, BlockSize:64, TagLength:59, IndexLength:1,
    BlockOffsetLength:1, ByteOffsetLength:3, SPMLength:32};
  typedef logic [0:0] way_t;
  typedef struct packed {
    axi_llc_pkg::tag_mode_e mode;
    way_t indicator;
    logic [0:0] index;
    logic [58:0] tag;
    logic dirty;
    logic [1:0] maint_op;
  } request_t;
  typedef struct packed {
    way_t indicator;
    logic hit, evict;
    logic [58:0] evict_tag;
  } response_t;
  logic clk=0,rst=0,iv=0,ir,ov,orr=0,commit,bist;
  way_t bist_res;
  request_t req;
  response_t rsp;
  typedef struct packed {
    logic evict, flush, maint;
    logic [1:0] maint_op;
    logic [0:0] way_ind;
    logic [63:0] a_x_addr;
  } desc_t;
  typedef struct packed {
    axi_llc_pkg::cache_unit_e cache_unit;
    logic [0:0] way_ind, line_addr, blk_offset;
    logic we;
    logic [63:0] data;
    logic [7:0] strb;
  } way_req_t;
  typedef struct packed { logic [63:0] data; } way_rsp_t;
  typedef struct packed { logic [63:0] data; logic [7:0] strb; logic last; } w_t;
  typedef struct packed { logic [1:0] resp; } b_t;
  localparam axi_llc_pkg::llc_axi_cfg_t AXI_CFG = '{SlvPortIdWidth:1,AddrWidthFull:64,DataWidthFull:64};
  desc_t desc;
  way_req_t way_req;
  way_rsp_t way_rsp;
  w_t w;
  b_t b;
  logic flush_mode=0, dr, wv, bv=0, br, way_valid, way_rsp_valid=0;
  logic unused_desc_valid, way_rsp_ready, wb_commit, wb_fault, wb_error;
  logic [58:0] req_tag=59'h123;
  logic req_index=0;
  desc_t unused_desc;
  int beats=0;
  assign desc='{evict:rsp.evict,flush:!1'(NORMAL_EVICT),maint:1'b0,maint_op:2'b0,way_ind:1'b1,a_x_addr:64'h2460};
  assign way_rsp.data=64'h1234_5678_9abc_def0;
  always_ff @(posedge clk) begin
    if (!rst) begin way_rsp_valid<=0; beats<=0; end
    else begin
      if (way_rsp_ready) way_rsp_valid<=way_valid;
      if(wv) begin
        if(w.data!==64'h1234_5678_9abc_def0) $fatal(1,"writeback data mismatch");
        if(w.last !== 1'(beats%2)) $fatal(1,"incorrect writeback WLAST");
        beats<=beats+1;
      end
    end
  end
  axi_llc_w_master #(.Cfg(CFG),.AxiCfg(AXI_CFG),.desc_t(desc_t),
    .way_inp_t(way_req_t),.way_oup_t(way_rsp_t),.w_chan_t(w_t),.b_chan_t(b_t)) writer (
    .clk_i(clk),.rst_ni(rst),.test_i(1'b0),.desc_i(desc),
    .desc_valid_i(ov && flush_mode && orr),.desc_ready_o(dr),
    .desc_o(unused_desc),.desc_valid_o(unused_desc_valid),.desc_ready_i(1'b1),
    .w_chan_mst_o(w),.w_chan_valid_o(wv),.w_chan_ready_i(1'b1),
    .b_chan_mst_i(b),.b_chan_valid_i(bv),.b_chan_ready_o(br),
    .way_inp_o(way_req),.way_inp_valid_o(way_valid),.way_inp_ready_i(way_rsp_ready),
    .way_out_i(way_rsp),.way_out_valid_i(way_rsp_valid),.way_out_ready_o(way_rsp_ready),
    .maint_wb_done_o(),.maint_wb_error_o(),
    .wb_commit_o(wb_commit), .wb_fault_o(wb_fault), .wb_error_o(wb_error),
    .flush_desc_recv_o(commit));
  logic refill_done=0;
  logic [CFG.IndexLength-1:0] refill_index=0;
  always #5 clk=~clk;
  axi_llc_tag_store #(.Cfg(CFG),.way_ind_t(way_t),
    .store_req_t(request_t),.store_res_t(response_t)) dut (
    .clk_i(clk),.rst_ni(rst),.test_i(1'b0),.flush_commit_i(commit),.wb_commit_i(wb_commit),.wb_error_i(wb_error),
    .refill_done_i(refill_done),.refill_error_i(1'b0),
    .refill_way_i(1'b1),.refill_index_i(refill_index),.maint_wb_done_i(1'b0),.maint_wb_error_i(1'b0),
    .maint_done_o(),.maint_error_o(),
    .spm_lock_i(1'b0),.flushed_i(1'b0),.req_i(req),.valid_i(iv),
    .ready_o(ir),.res_o(rsp),.valid_o(ov),.ready_i(orr),
    .bist_res_o(bist_res),.bist_valid_o(bist));
  task automatic send(input axi_llc_pkg::tag_mode_e mode,input logic dirty);
    @(negedge clk); req='{mode:mode,indicator:1'b1,index:req_index,tag:req_tag,dirty:dirty,maint_op:2'b0}; iv=1;
    do @(posedge clk); while(!ir);
    @(negedge clk); iv=0;
  endtask
  task automatic receive(input logic expected_hit,input logic expected_evict);
    while(!ov) @(negedge clk);
    if(rsp.hit!==expected_hit || rsp.evict!==expected_evict)
      $fatal(1,"Unexpected lookup/flush result hit=%b evict=%b",rsp.hit,rsp.evict);
    orr=1;
    @(posedge clk); @(negedge clk); orr=0;
  endtask
  task automatic refill(input int idx);
    @(negedge clk); refill_index=CFG.IndexLength'(idx); refill_done=1;
    @(posedge clk); @(negedge clk); refill_done=0;
    repeat(3) @(negedge clk);
  endtask
  initial begin
    req='0;
    repeat(2) @(negedge clk); rst=1;
    send(axi_llc_pkg::Bist,0);
    wait(bist); @(negedge clk);
    send(axi_llc_pkg::Lookup,1);
    receive(0,0); refill(0);
    if (NORMAL_EVICT!=0) begin
      flush_mode=1; req_tag=59'h456;
      send(axi_llc_pkg::Lookup,0); receive(0,1);
      wait(beats==2);
      // A lookup to another set must finish before the first B response.
      req_index=1; req_tag=59'h789;
      send(axi_llc_pkg::Lookup,0); receive(0,0);
      // Complete this independent clean refill while dirty-victim B is pending.
      refill(1);
      req_index=0; req_tag=59'h456;
      repeat(8) begin
        @(negedge clk);
        if((dut.ram_we!=0 && dut.ram_index==0) || !(|dut.pending_valid_q))
          $fatal(1,"normal eviction overwrote dirty victim before B");
      end
      b.resp=(WRITE_ERROR!=0) ? 2'b10 : 2'b00; bv=1;
      do @(posedge clk); while(!br);
      @(negedge clk); bv=0;
      if (WRITE_ERROR!=0) begin
        repeat(8) begin
          @(negedge clk);
          if(dut.ram_we!=0 || wb_commit || unused_desc_valid || !(|dut.pending_valid_q) || !wb_fault)
            $fatal(1,"failed normal eviction released victim/refill");
        end
        $display("PASS: normal eviction SLVERR preserves victim tag and blocks refill");
      end else begin
        repeat(4) begin
          @(negedge clk);
          if((dut.ram_we!=0 && dut.ram_index==0) || !(|dut.pending_valid_q))
            $fatal(1,"B success installed tag before refill completion");
        end
        refill(0); flush_mode=0;
        send(axi_llc_pkg::Lookup,0); receive(1,0);
        $display("PASS: normal eviction commits replacement tag only after OKAY B and refill completion");
      end
      $finish;
    end
    flush_mode=1;
    send(axi_llc_pkg::Flush,0);
    receive(0,1);
    wait(beats==2);
    // Before successful writeback, no tag write or second request is allowed.
    repeat(8) begin
      @(negedge clk);
      if(dut.ram_we!==1'b0 || ir!==1'b0)
        $fatal(1,"dirty tag released before writeback commit");
    end
    b.resp=2'b00; bv=1;
    do @(posedge clk); while(!br);
    @(negedge clk); bv=0;
    #1; if(!commit || dut.ram_we!==1'b1) $fatal(1,"successful B did not commit tag invalidation");
    @(posedge clk); @(negedge clk); flush_mode=0;
    send(axi_llc_pkg::Lookup,0);
    receive(0,0); refill(0);
    send(axi_llc_pkg::Lookup,1); receive(1,0);
    flush_mode=1;
    send(axi_llc_pkg::Flush,0); receive(0,1);
    wait(beats==4);
    @(negedge clk); b.resp=2'b10; bv=1;
    do @(posedge clk); while(!br);
    @(negedge clk); bv=0;
    repeat(8) begin
      @(negedge clk);
      if(commit || dut.ram_we!=0 || ir || !dut.flush_wait_q)
        $fatal(1,"failed B released or overwrote dirty tag");
    end
    $display("PASS: native LLC tag/writeback path, delayed OKAY commit and SLVERR preservation");
    $finish;
  end
  initial begin
    #100000; $fatal(1,"test timeout");
  end
endmodule
