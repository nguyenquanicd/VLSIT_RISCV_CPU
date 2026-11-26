module tb_store_buffer_cmo_metadata #(parameter int EXTERNAL_CMO=0);
  import ariane_pkg::*;

  typedef struct packed {
    logic [3:0] address_index;
    logic [3:0] address_tag;
    logic [31:0] data_wdata;
    logic [0:0] data_wuser;
    logic data_req;
    logic data_we;
    logic [3:0] data_be;
    logic [1:0] data_size;
    logic [1:0] data_id;
    logic kill_req;
    logic tag_valid;
    cbo_t cbo_op;
  } test_dcache_req_i_type_def;

  typedef struct packed {
    logic data_gnt;
    logic data_rvalid;
    logic [1:0] data_rid;
    logic [31:0] data_rdata;
    logic [0:0] data_ruser;
    logic data_error;
  } test_dcache_req_o_type_def;

  logic clk_i = 1'b0;
  logic rst_ni = 1'b0;
  logic flush_i = 1'b0;
  logic stall_st_pending_i = 1'b0;
  logic [11:0] page_offset_i = '0;
  logic commit_i = 1'b0;
  logic valid_i = 1'b0;
  logic valid_without_flush_i = 1'b0;
  logic [31:0] paddr_i = '0;
  logic [31:0] vaddr_i = '0;
  logic [31:0] data_i = '0;
  logic [3:0] be_i = '0;
  logic [1:0] data_size_i = '0;
  cbo_t cbo_op_i = CBO_NONE;
  test_dcache_req_o_type_def req_port_i = '0;
  test_dcache_req_i_type_def req_port_o;
  logic no_st_pending_o;
  logic store_buffer_empty_o;
  logic page_offset_matches_o;
  logic commit_ready_o;
  logic ready_o;
  logic [31:0] rvfi_mem_paddr_o;
  logic cmo_entry_valid_o;
  cbo_t cmo_entry_op_o;
  logic [31:0] cmo_entry_paddr_o;
  logic [31:0] cmo_entry_vaddr_o;

  always #5 clk_i = ~clk_i;

  store_buffer #(
    .ExternalCmo(1'(EXTERNAL_CMO)),
    .CVA6Cfg(config_pkg::cva6_cfg_empty),
    .dcache_req_i_t(test_dcache_req_i_type_def),
    .dcache_req_o_t(test_dcache_req_o_type_def),
    .cbo_t(cbo_t)
  ) dut (
    .clk_i,
    .rst_ni,
    .flush_i,
    .stall_st_pending_i,
    .no_st_pending_o,
    .store_buffer_empty_o,
    .page_offset_i,
    .page_offset_matches_o,
    .commit_i,
    .commit_ready_o,
    .ready_o,
    .valid_i,
    .valid_without_flush_i,
    .paddr_i,
    .vaddr_i,
    .rvfi_mem_paddr_o,
    .data_i,
    .be_i,
    .data_size_i,
    .cbo_op_i,
    .cmo_entry_valid_o,
    .cmo_entry_op_o,
    .cmo_entry_paddr_o,
    .cmo_entry_vaddr_o,
    .req_port_i,
    .req_port_o
  );

  task automatic push_entry(input logic [31:0] paddr, input logic [31:0] vaddr,
                            input cbo_t op);
    @(negedge clk_i);
    valid_i = 1'b1;
    valid_without_flush_i = 1'b1;
    paddr_i = paddr;
    vaddr_i = vaddr;
    cbo_op_i = op;
    data_i = 32'h5a5a_a5a5;
    be_i = 4'hf;
    @(posedge clk_i);
    #1;
    valid_i = 1'b0;
    valid_without_flush_i = 1'b0;
    cbo_op_i = CBO_NONE;
  endtask

  initial begin
    repeat (2) @(posedge clk_i);
    #1 rst_ni = 1'b1;

    push_entry(32'h8000_1010, 32'h4000_1010, CBO_NONE);
    if (cmo_entry_valid_o !== 1'b0)
      $fatal(1, "ordinary store was incorrectly exposed as a CMO entry");

    push_entry(32'h8000_2020, 32'h4000_2020, CBO_CLEAN);
    if (cmo_entry_valid_o !== 1'b0)
      $fatal(1, "CBO bypassed an older speculative store");

    @(negedge clk_i);
    commit_i = 1'b1;
    @(posedge clk_i);
    #1 commit_i = 1'b0;
    if (cmo_entry_valid_o !== 1'b1
        || cmo_entry_op_o !== CBO_CLEAN
        || cmo_entry_paddr_o !== 32'h8000_2020
        || cmo_entry_vaddr_o !== 32'h4000_2020)
      $fatal(1, "head CBO metadata does not match the queued PA/VA/op");

    repeat (3) begin
      @(posedge clk_i);
      #1;
      if (!cmo_entry_valid_o || cmo_entry_paddr_o !== 32'h8000_2020
          || cmo_entry_vaddr_o !== 32'h4000_2020 || cmo_entry_op_o !== CBO_CLEAN)
        $fatal(1, "head CBO metadata changed without dequeue");
    end

    if (EXTERNAL_CMO) begin
      // A successful external CBO consumes the speculative entry without issuing
      // another local cache operation, even on a terminal debug pipeline flush.
      @(negedge clk_i); commit_i=1; flush_i=1;
      @(posedge clk_i); #1; commit_i=0; flush_i=0;
      if(cmo_entry_valid_o || dut.commit_status_cnt_q!=1)
        $fatal(1,"external CBO duplicated in local commit queue");
      push_entry(32'h8000_3030,32'h4000_3030,CBO_INVAL);
      if(!cmo_entry_valid_o || cmo_entry_vaddr_o!=32'h4000_3030)
        $fatal(1,"commit-plus-flush corrupted speculative queue pointers");
    end
    @(negedge clk_i);
    flush_i = 1'b1;
    @(posedge clk_i);
    #1 flush_i = 1'b0;
    if (cmo_entry_valid_o !== 1'b0)
      $fatal(1, "flush did not clear speculative CBO metadata");

    $display("PASS: store-buffer CMO metadata capture, ordering, stability, and flush");
    $finish;
  end
endmodule
