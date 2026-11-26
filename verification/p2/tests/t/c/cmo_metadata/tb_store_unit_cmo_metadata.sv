module tb_store_unit_cmo_metadata;
  import ariane_pkg::*;
  typedef logic [7:0] cbo_t;
  localparam config_pkg::cva6_cfg_t CFG = build_config_pkg::build_config(cva6_config_pkg::cva6_cfg);
  typedef struct packed {
    logic [11:0] address_index;
    logic [43:0] address_tag;
    logic [63:0] data_wdata;
    logic [0:0] data_wuser;
    logic data_req;
    logic data_we;
    logic [7:0] data_be;
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
    logic [63:0] data_rdata;
    logic [0:0] data_ruser;
    logic data_error;
  } test_dcache_req_o_type_def;


  typedef struct packed {
    logic valid;
    logic [CFG.XLEN-1:0] cause, tval;
  } exception_type_def;
  typedef struct packed {
    logic [CFG.VLEN-1:0] vaddr;
    logic [63:0] data;
    logic [7:0] be;
    fu_op operation;
    logic [CFG.TRANS_ID_BITS-1:0] trans_id;
    logic hs_ld_st_inst, hlvx_inst;
    logic [31:0] tinst;
  } ctrl_type_def;
  logic clk_i=0, rst_ni=0, valid_i=0;
  ctrl_type_def ctrl='0;
  exception_type_def ex='0;
  test_dcache_req_o_type_def rsp='0;
  test_dcache_req_i_type_def req;
  logic cmo_valid;
  logic [7:0] cmo_op;
  logic [CFG.PLEN-1:0] cmo_pa;
  logic [CFG.VLEN-1:0] cmo_va;
  logic [CFG.PLEN-1:0] pa='0;
  always #5 clk_i=~clk_i;
  store_unit #(.CVA6Cfg(CFG), .dcache_req_i_t(test_dcache_req_i_type_def),
    .dcache_req_o_t(test_dcache_req_o_type_def), .exception_t(exception_type_def),
    .lsu_ctrl_t(ctrl_type_def), .cbo_t(logic [7:0])) dut (
    .clk_i, .rst_ni, .flush_i(1'b0), .stall_st_pending_i(1'b0),
    .valid_i, .lsu_ctrl_i(ctrl), .commit_i(1'b0), .amo_valid_commit_i(1'b0),
    .mbe_i(1'b0), .paddr_i(pa), .ex_i(ex), .dtlb_hit_i(1'b1),
    .page_offset_i(12'b0), .amo_resp_i('0), .req_port_i(rsp), .req_port_o(req),
    .sdtrig_store_stall_i(1'b0), .sdtrig_store_action_i(64'b0),
    .cmo_entry_valid_o(cmo_valid), .cmo_entry_op_o(cmo_op),
    .cmo_entry_paddr_o(cmo_pa), .cmo_entry_vaddr_o(cmo_va));
  initial begin
    repeat(2) @(posedge clk_i);
    @(negedge clk_i); rst_ni=1; valid_i=1;
    ctrl.vaddr=64'h4000_1230; ctrl.operation=CBO_CLEAN;
    @(negedge clk_i);
    // The input now names a younger instruction while the old CBO is queued.
    ctrl.vaddr=64'h5000_4560; ctrl.operation=CBO_FLUSH;
    pa=56'h8000_1230;
    @(posedge clk_i); #1;
    if (!cmo_valid || cmo_op!=CBO_CLEAN || cmo_va!=64'h4000_1230 || cmo_pa!=56'h8000_1230)
      $fatal(1,"CBO metadata captured a younger instruction VA/op");
    valid_i=0;
    @(posedge clk_i); #1;
    if (cmo_va!=64'h4000_1230) $fatal(1,"oldest CBO metadata changed");
    $display("PASS: store-unit back-to-back CBO VA/op/PA alignment");
    $finish;
  end
endmodule
