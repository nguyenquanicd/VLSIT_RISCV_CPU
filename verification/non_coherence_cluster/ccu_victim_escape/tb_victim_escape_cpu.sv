`timescale 1ns/1ps
module tb_victim_escape_cpu #(parameter int HARTS=2, TRACE=1, SLOTS=2);
  logic  i_clk_cluster;
  logic  i_rst_n_cluster;
  logic [63:0] i_boot_addr;
  logic [HARTS-1:0] i_int_msip;
  logic [HARTS-1:0] i_int_mtip;
  logic [HARTS-1:0] i_int_meip;
  logic [HARTS-1:0] i_int_ssip;
  logic [HARTS-1:0] i_int_stip;
  logic [HARTS-1:0] i_int_seip;
  logic [HARTS-1:0] i_hart_debug_req;
  logic [HARTS-1:0] o_hart_debug_mode;
  logic  o_int_pmu;
  logic  o_int_fault;
  logic [31:0] i_axil_awaddr;
  logic [2:0] i_axil_awprot;
  logic  i_axil_awvalid;
  logic  o_axil_awready;
  logic [31:0] i_axil_wdata;
  logic [3:0] i_axil_wstrb;
  logic  i_axil_wvalid;
  logic  o_axil_wready;
  logic [1:0] o_axil_bresp;
  logic  o_axil_bvalid;
  logic  i_axil_bready;
  logic [31:0] i_axil_araddr;
  logic [2:0] i_axil_arprot;
  logic  i_axil_arvalid;
  logic  o_axil_arready;
  logic [31:0] o_axil_rdata;
  logic [1:0] o_axil_rresp;
  logic  o_axil_rvalid;
  logic  i_axil_rready;
  logic [5:0] o_axi_mmio_awid;
  logic [63:0] o_axi_mmio_awaddr;
  logic [7:0] o_axi_mmio_awlen;
  logic [2:0] o_axi_mmio_awsize;
  logic [1:0] o_axi_mmio_awburst;
  logic  o_axi_mmio_awlock;
  logic [3:0] o_axi_mmio_awcache;
  logic [2:0] o_axi_mmio_awprot;
  logic [3:0] o_axi_mmio_awqos;
  logic [3:0] o_axi_mmio_awregion;
  logic  o_axi_mmio_awvalid;
  logic  i_axi_mmio_awready;
  logic [63:0] o_axi_mmio_wdata;
  logic [7:0] o_axi_mmio_wstrb;
  logic  o_axi_mmio_wlast;
  logic  o_axi_mmio_wvalid;
  logic  i_axi_mmio_wready;
  logic [5:0] i_axi_mmio_bid;
  logic [1:0] i_axi_mmio_bresp;
  logic  i_axi_mmio_bvalid;
  logic  o_axi_mmio_bready;
  logic [5:0] o_axi_mmio_arid;
  logic [63:0] o_axi_mmio_araddr;
  logic [7:0] o_axi_mmio_arlen;
  logic [2:0] o_axi_mmio_arsize;
  logic [1:0] o_axi_mmio_arburst;
  logic  o_axi_mmio_arlock;
  logic [3:0] o_axi_mmio_arcache;
  logic [2:0] o_axi_mmio_arprot;
  logic [3:0] o_axi_mmio_arqos;
  logic [3:0] o_axi_mmio_arregion;
  logic  o_axi_mmio_arvalid;
  logic  i_axi_mmio_arready;
  logic [5:0] i_axi_mmio_rid;
  logic [63:0] i_axi_mmio_rdata;
  logic [1:0] i_axi_mmio_rresp;
  logic  i_axi_mmio_rlast;
  logic  i_axi_mmio_rvalid;
  logic  o_axi_mmio_rready;
  logic [6:0] o_axi_mem_awid;
  logic [5:0] o_axi_mem_awatop;
  logic [63:0] o_axi_mem_awaddr;
  logic [7:0] o_axi_mem_awlen;
  logic [2:0] o_axi_mem_awsize;
  logic [1:0] o_axi_mem_awburst;
  logic  o_axi_mem_awlock;
  logic [3:0] o_axi_mem_awcache;
  logic [2:0] o_axi_mem_awprot;
  logic [3:0] o_axi_mem_awqos;
  logic [3:0] o_axi_mem_awregion;
  logic  o_axi_mem_awvalid;
  logic  i_axi_mem_awready;
  logic [64-1:0] o_axi_mem_wdata;
  logic [64/8-1:0] o_axi_mem_wstrb;
  logic  o_axi_mem_wlast;
  logic  o_axi_mem_wvalid;
  logic  i_axi_mem_wready;
  logic [6:0] i_axi_mem_bid;
  logic [1:0] i_axi_mem_bresp;
  logic  i_axi_mem_bvalid;
  logic  o_axi_mem_bready;
  logic [6:0] o_axi_mem_arid;
  logic [63:0] o_axi_mem_araddr;
  logic [7:0] o_axi_mem_arlen;
  logic [2:0] o_axi_mem_arsize;
  logic [1:0] o_axi_mem_arburst;
  logic  o_axi_mem_arlock;
  logic [3:0] o_axi_mem_arcache;
  logic [2:0] o_axi_mem_arprot;
  logic [3:0] o_axi_mem_arqos;
  logic [3:0] o_axi_mem_arregion;
  logic  o_axi_mem_arvalid;
  logic  i_axi_mem_arready;
  logic [6:0] i_axi_mem_rid;
  logic [64-1:0] i_axi_mem_rdata;
  logic [1:0] i_axi_mem_rresp;
  logic  i_axi_mem_rlast;
  logic  i_axi_mem_rvalid;
  logic  o_axi_mem_rready;
  m_vlsit_riscv_cluster_axi_top #(.PARA_CPU_NUM(32'(HARTS)),
    .PARA_COH_TXN_NUM(32'(SLOTS)),.PARA_LLC_WAY_NUM(32'd4),.PARA_LLC_NO_LINES(32'd64)) dut (
    .i_clk_cluster(i_clk_cluster),
    .i_rst_n_cluster(i_rst_n_cluster),
    .i_boot_addr(i_boot_addr),
    .i_int_msip(i_int_msip),
    .i_int_mtip(i_int_mtip),
    .i_int_meip(i_int_meip),
    .i_int_ssip(i_int_ssip),
    .i_int_stip(i_int_stip),
    .i_int_seip(i_int_seip),
    .i_hart_debug_req(i_hart_debug_req),
    .o_hart_debug_mode(o_hart_debug_mode),
    .o_int_pmu(o_int_pmu),
    .o_int_fault(o_int_fault),
    .i_axil_awaddr(i_axil_awaddr),
    .i_axil_awprot(i_axil_awprot),
    .i_axil_awvalid(i_axil_awvalid),
    .o_axil_awready(o_axil_awready),
    .i_axil_wdata(i_axil_wdata),
    .i_axil_wstrb(i_axil_wstrb),
    .i_axil_wvalid(i_axil_wvalid),
    .o_axil_wready(o_axil_wready),
    .o_axil_bresp(o_axil_bresp),
    .o_axil_bvalid(o_axil_bvalid),
    .i_axil_bready(i_axil_bready),
    .i_axil_araddr(i_axil_araddr),
    .i_axil_arprot(i_axil_arprot),
    .i_axil_arvalid(i_axil_arvalid),
    .o_axil_arready(o_axil_arready),
    .o_axil_rdata(o_axil_rdata),
    .o_axil_rresp(o_axil_rresp),
    .o_axil_rvalid(o_axil_rvalid),
    .i_axil_rready(i_axil_rready),
    .o_axi_mmio_awid(o_axi_mmio_awid),
    .o_axi_mmio_awaddr(o_axi_mmio_awaddr),
    .o_axi_mmio_awlen(o_axi_mmio_awlen),
    .o_axi_mmio_awsize(o_axi_mmio_awsize),
    .o_axi_mmio_awburst(o_axi_mmio_awburst),
    .o_axi_mmio_awlock(o_axi_mmio_awlock),
    .o_axi_mmio_awcache(o_axi_mmio_awcache),
    .o_axi_mmio_awprot(o_axi_mmio_awprot),
    .o_axi_mmio_awqos(o_axi_mmio_awqos),
    .o_axi_mmio_awregion(o_axi_mmio_awregion),
    .o_axi_mmio_awvalid(o_axi_mmio_awvalid),
    .i_axi_mmio_awready(i_axi_mmio_awready),
    .o_axi_mmio_wdata(o_axi_mmio_wdata),
    .o_axi_mmio_wstrb(o_axi_mmio_wstrb),
    .o_axi_mmio_wlast(o_axi_mmio_wlast),
    .o_axi_mmio_wvalid(o_axi_mmio_wvalid),
    .i_axi_mmio_wready(i_axi_mmio_wready),
    .i_axi_mmio_bid(i_axi_mmio_bid),
    .i_axi_mmio_bresp(i_axi_mmio_bresp),
    .i_axi_mmio_bvalid(i_axi_mmio_bvalid),
    .o_axi_mmio_bready(o_axi_mmio_bready),
    .o_axi_mmio_arid(o_axi_mmio_arid),
    .o_axi_mmio_araddr(o_axi_mmio_araddr),
    .o_axi_mmio_arlen(o_axi_mmio_arlen),
    .o_axi_mmio_arsize(o_axi_mmio_arsize),
    .o_axi_mmio_arburst(o_axi_mmio_arburst),
    .o_axi_mmio_arlock(o_axi_mmio_arlock),
    .o_axi_mmio_arcache(o_axi_mmio_arcache),
    .o_axi_mmio_arprot(o_axi_mmio_arprot),
    .o_axi_mmio_arqos(o_axi_mmio_arqos),
    .o_axi_mmio_arregion(o_axi_mmio_arregion),
    .o_axi_mmio_arvalid(o_axi_mmio_arvalid),
    .i_axi_mmio_arready(i_axi_mmio_arready),
    .i_axi_mmio_rid(i_axi_mmio_rid),
    .i_axi_mmio_rdata(i_axi_mmio_rdata),
    .i_axi_mmio_rresp(i_axi_mmio_rresp),
    .i_axi_mmio_rlast(i_axi_mmio_rlast),
    .i_axi_mmio_rvalid(i_axi_mmio_rvalid),
    .o_axi_mmio_rready(o_axi_mmio_rready),
    .o_axi_mem_awid(o_axi_mem_awid),
    .o_axi_mem_awatop(o_axi_mem_awatop),
    .o_axi_mem_awaddr(o_axi_mem_awaddr),
    .o_axi_mem_awlen(o_axi_mem_awlen),
    .o_axi_mem_awsize(o_axi_mem_awsize),
    .o_axi_mem_awburst(o_axi_mem_awburst),
    .o_axi_mem_awlock(o_axi_mem_awlock),
    .o_axi_mem_awcache(o_axi_mem_awcache),
    .o_axi_mem_awprot(o_axi_mem_awprot),
    .o_axi_mem_awqos(o_axi_mem_awqos),
    .o_axi_mem_awregion(o_axi_mem_awregion),
    .o_axi_mem_awvalid(o_axi_mem_awvalid),
    .i_axi_mem_awready(i_axi_mem_awready),
    .o_axi_mem_wdata(o_axi_mem_wdata),
    .o_axi_mem_wstrb(o_axi_mem_wstrb),
    .o_axi_mem_wlast(o_axi_mem_wlast),
    .o_axi_mem_wvalid(o_axi_mem_wvalid),
    .i_axi_mem_wready(i_axi_mem_wready),
    .i_axi_mem_bid(i_axi_mem_bid),
    .i_axi_mem_bresp(i_axi_mem_bresp),
    .i_axi_mem_bvalid(i_axi_mem_bvalid),
    .o_axi_mem_bready(o_axi_mem_bready),
    .o_axi_mem_arid(o_axi_mem_arid),
    .o_axi_mem_araddr(o_axi_mem_araddr),
    .o_axi_mem_arlen(o_axi_mem_arlen),
    .o_axi_mem_arsize(o_axi_mem_arsize),
    .o_axi_mem_arburst(o_axi_mem_arburst),
    .o_axi_mem_arlock(o_axi_mem_arlock),
    .o_axi_mem_arcache(o_axi_mem_arcache),
    .o_axi_mem_arprot(o_axi_mem_arprot),
    .o_axi_mem_arqos(o_axi_mem_arqos),
    .o_axi_mem_arregion(o_axi_mem_arregion),
    .o_axi_mem_arvalid(o_axi_mem_arvalid),
    .i_axi_mem_arready(i_axi_mem_arready),
    .i_axi_mem_rid(i_axi_mem_rid),
    .i_axi_mem_rdata(i_axi_mem_rdata),
    .i_axi_mem_rresp(i_axi_mem_rresp),
    .i_axi_mem_rlast(i_axi_mem_rlast),
    .i_axi_mem_rvalid(i_axi_mem_rvalid),
    .o_axi_mem_rready(o_axi_mem_rready)
  );
  int CASE_ID=0;
  initial void'($value$plusargs("CASE_ID=%d",CASE_ID));
  int INJECT_ERROR=0;
  initial void'($value$plusargs("INJECT_ERROR=%d",INJECT_ERROR));
  `include "program_constants.svh"
  logic [63:0] memory [0:32767];
  logic write_active=0, read_active=0;
  logic [63:0] write_addr, read_addr;
  logic [7:0] write_left, read_left;
  logic [2:0] write_size, read_size;
  logic [6:0] write_id, read_id;
  logic [HARTS-1:0] passed='0;
  logic [HARTS*8-1:0] shared_seen='0;
  int atomic_count[HARTS], checked[HARTS], retired[HARTS];
  int protocol_hits[20];
  logic read_injected=0, read_fault=0;
  int cycles=0, dirty_transfers=0, probe_waits=0, abort_acks=0, error_grants=0;
  int owner_reads=0;
  int wave_file;
  string wave_path, program_path;
  task automatic protocol_check(input int id, input logic ok);
    protocol_hits[id]++;
    if(!ok) $fatal(1,"AXI protocol assertion %0d failed",id);
  endtask
  assign i_axi_mem_awready = !write_active && !i_axi_mem_bvalid && cycles%4==0;
  assign i_axi_mem_wready = write_active && cycles%4==1;
  assign i_axi_mem_arready = !read_active && !i_axi_mem_rvalid && cycles%4==2;
  always #5 i_clk_cluster=~i_clk_cluster;
  function automatic int memory_index(input logic [63:0] addr);
    if(addr<64'h80000000 || addr>=64'h80040000) $fatal(1,"memory address outside BFM %h",addr);
    return int'((addr-64'h80000000)>>3);
  endfunction
  always_ff @(posedge i_clk_cluster) begin
    if(!i_rst_n_cluster) begin
      write_active<=0; read_active<=0;
      i_axi_mem_bvalid<=0; i_axi_mem_bid<=0; i_axi_mem_bresp<=0;
      i_axi_mem_rvalid<=0; i_axi_mem_rid<=0; i_axi_mem_rdata<=0;
      i_axi_mem_rresp<=0; i_axi_mem_rlast<=0;
    end else begin
      if(o_axi_mem_awvalid && i_axi_mem_awready) begin
        protocol_check(0,!write_active);
        protocol_check(1,o_axi_mem_awburst==1);
        protocol_check(2,o_axi_mem_awsize<=3);
        protocol_check(3,(o_axi_mem_awaddr & ((64'd1<<o_axi_mem_awsize)-1))==0);
        protocol_check(4,32'(o_axi_mem_awaddr[11:0])+((32'(o_axi_mem_awlen)+1)<<o_axi_mem_awsize)<=4096);
        protocol_check(5,o_axi_mem_awatop==0 && !o_axi_mem_awlock);
        write_active<=1; write_addr<=o_axi_mem_awaddr;
        write_left<=o_axi_mem_awlen; write_size<=o_axi_mem_awsize; write_id<=o_axi_mem_awid;
      end
      if(o_axi_mem_wvalid && i_axi_mem_wready) begin
        protocol_check(6,write_active);
        protocol_check(7,o_axi_mem_wlast==(write_left==0));
        protocol_check(8,o_axi_mem_wstrb!=0);
        protocol_check(9,(o_axi_mem_wstrb & ~(8'hff << write_addr[2:0]))==0);
        for(int b=0;b<8;b++) if(o_axi_mem_wstrb[b]) memory[memory_index(write_addr)][b*8+:8]<=o_axi_mem_wdata[b*8+:8];
        if(write_left==0) begin
          write_active<=0; i_axi_mem_bvalid<=1; i_axi_mem_bid<=write_id; i_axi_mem_bresp<=0;
        end else begin write_left<=write_left-1'b1; write_addr<=write_addr+(64'd1<<write_size); end
      end
      if(i_axi_mem_bvalid && o_axi_mem_bready) begin
        protocol_check(10,!write_active);
        protocol_check(11,i_axi_mem_bid==write_id);
        i_axi_mem_bvalid<=0;
      end
      if(o_axi_mem_arvalid && i_axi_mem_arready) begin
        protocol_check(12,!read_active);
        protocol_check(13,o_axi_mem_arburst==1);
        protocol_check(14,o_axi_mem_arsize<=3);
        protocol_check(15,(o_axi_mem_araddr & ((64'd1<<o_axi_mem_arsize)-1))==0);
        protocol_check(16,32'(o_axi_mem_araddr[11:0])+((32'(o_axi_mem_arlen)+1)<<o_axi_mem_arsize)<=4096);
        protocol_check(17,!o_axi_mem_arlock);
        read_active<=1; read_addr<=o_axi_mem_araddr;
        read_fault<=INJECT_ERROR!=0 && !read_injected && o_axi_mem_araddr==64'h80001000;
        if(INJECT_ERROR!=0 && !read_injected && o_axi_mem_araddr==64'h80001000) read_injected<=1;
        read_left<=o_axi_mem_arlen; read_size<=o_axi_mem_arsize; read_id<=o_axi_mem_arid;
      end
      if(read_active && !i_axi_mem_rvalid) begin
        i_axi_mem_rvalid<=1; i_axi_mem_rid<=read_id; i_axi_mem_rdata<=memory[memory_index(read_addr)];
        i_axi_mem_rresp<=read_fault ? 2'b10:2'b00; i_axi_mem_rlast<=(read_left==0);
      end
      if(i_axi_mem_rvalid && o_axi_mem_rready) begin
        protocol_check(18,read_active && i_axi_mem_rid==read_id);
        protocol_check(19,i_axi_mem_rlast==(read_left==0));
        i_axi_mem_rvalid<=0;
        if(read_left==0) read_active<=0;
        else begin read_left<=read_left-1'b1; read_addr<=read_addr+(64'd1<<read_size); end
      end
    end
  end
  // AXI4 channel payloads remain stable under injected downstream stalls.
  assert property (@(posedge i_clk_cluster) disable iff(!i_rst_n_cluster)
    o_axi_mem_awvalid && !i_axi_mem_awready |=> o_axi_mem_awvalid &&
    $stable({o_axi_mem_awid,o_axi_mem_awaddr,o_axi_mem_awlen,o_axi_mem_awsize,o_axi_mem_awburst,o_axi_mem_awatop}));
  assert property (@(posedge i_clk_cluster) disable iff(!i_rst_n_cluster)
    o_axi_mem_wvalid && !i_axi_mem_wready |=> o_axi_mem_wvalid && $stable({o_axi_mem_wdata,o_axi_mem_wstrb,o_axi_mem_wlast}));
  assert property (@(posedge i_clk_cluster) disable iff(!i_rst_n_cluster)
    o_axi_mem_arvalid && !i_axi_mem_arready |=> o_axi_mem_arvalid &&
    $stable({o_axi_mem_arid,o_axi_mem_araddr,o_axi_mem_arlen,o_axi_mem_arsize,o_axi_mem_arburst}));
  initial begin
    if(!$value$plusargs("PROGRAM=%s",program_path)) $fatal(1,"PROGRAM image required");
    $readmemh(program_path,memory);
    memory['he00/8]=64'(HARTS);
    if(!$value$plusargs("WAVE=%s",wave_path)) wave_path="atomic.vcd";
    wave_file=$fopen(wave_path,"w");
    if(wave_file==0) $fatal(1,"wave output unavailable");
    $fdisplay(wave_file,"$timescale 1ns $end\n$scope module atomic $end");
    $fdisplay(wave_file,"$var wire 4 a absent_prepare_harts $end\n$var wire 4 b harts_done $end\n$var wire 4 c peer_amo_seen $end\n$upscope $end\n$enddefinitions $end");
    i_boot_addr='0;
    i_int_msip='0;
    i_int_mtip='0;
    i_int_meip='0;
    i_int_ssip='0;
    i_int_stip='0;
    i_int_seip='0;
    i_hart_debug_req='0;
    i_axil_awaddr='0;
    i_axil_awprot='0;
    i_axil_awvalid='0;
    i_axil_wdata='0;
    i_axil_wstrb='0;
    i_axil_wvalid='0;
    i_axil_bready='0;
    i_axil_araddr='0;
    i_axil_arprot='0;
    i_axil_arvalid='0;
    i_axil_rready='0;
    i_axi_mmio_awready='0;
    i_axi_mmio_wready='0;
    i_axi_mmio_bid='0;
    i_axi_mmio_bresp='0;
    i_axi_mmio_bvalid='0;
    i_axi_mmio_arready='0;
    i_axi_mmio_rid='0;
    i_axi_mmio_rdata='0;
    i_axi_mmio_rresp='0;
    i_axi_mmio_rlast='0;
    i_axi_mmio_rvalid='0;
    i_boot_addr=64'h8000_0000;
    i_clk_cluster=0; i_rst_n_cluster=0;
    repeat(8) @(negedge i_clk_cluster);
    i_rst_n_cluster=1;
  end

  `define CPU(h) dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6
  `define HPD(h) `CPU(h).gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache
  `define FAB dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.u_vlsit_riscv_coh_tile_array.u_vlsit_riscv_coh_fabric
  int child_allocations=0,full_table_cycles=0,root_credit_stalls=0;
  int retry_cancel_cycles=0;
  always @(posedge i_clk_cluster) if(i_rst_n_cluster) begin
    if(`FAB.w_alloc_valid && `FAB.w_alloc_ready && `FAB.w_internal_pick_valid) child_allocations++;
    if($countones(`FAB.w_ctx_valid)==SLOTS) full_table_cycles++;
    if((|`FAB.i_req_valid) && !(|`FAB.o_req_ready) && $countones(`FAB.w_ctx_valid)>=SLOTS-1) root_credit_stalls++;
    if(`FAB.w_alloc_valid && `FAB.w_alloc_ready && !`FAB.w_internal_pick_valid && $countones(`FAB.w_ctx_valid)>=SLOTS-1)
      $fatal(1,"root consumed the victim escape credit");
    for(int s=0;s<SLOTS;s++) if(`FAB.reg_fsm_ctx_current_state[s]==5'd18) retry_cancel_cycles++;
  end
  logic [HARTS-2:0] old_values='0;
  int absent_prepare=0,absent_commit=0,dirty_evictions=0,pruned_updates=0;
  logic fault_seen=0;
  logic [3:0] absent_prepare_harts='0;
  for(genvar h=0;h<HARTS;h++) begin:gen_monitor
    function automatic logic [64:0] oracle(input logic [63:0] pc);
      logic check_valid;logic [63:0] expected;
      check_valid=0;expected=0;
      case(pc)
        `include "program_checks.svh"
        default: begin end
      endcase
      return {check_valid,expected};
    endfunction
    always @(posedge i_clk_cluster) begin
      if(!i_rst_n_cluster) begin checked[h]=0;atomic_count[h]=0;passed[h]=0; end
      else begin
        if(`CPU(h).csr_regfile_i.mcause_q!=0) begin
          if(h!=0 || INJECT_ERROR==0 || `CPU(h).csr_regfile_i.mcause_q!=64'(INJECT_ERROR==2 ? 5:7) ||
             `CPU(h).csr_regfile_i.mepc_q!=FAULT_PC || `CPU(h).csr_regfile_i.mtval_q!=64'h80001000)
            $fatal(1,"unexpected trap h=%0d",h);
          fault_seen=1;
        end
        if(INJECT_ERROR!=0 && h==0 && `CPU(h).amo_error && `CPU(h).amo_resp.ack && `CPU(h).commit_stage_i.we_gpr_o!='0)
          $fatal(1,"failed refill atomic wrote a GPR");
        for(int slot=0;slot<2;slot++) begin
          logic [63:0] pc,value;logic [64:0] expect_value;
          pc=`CPU(h).commit_instr_id_commit[slot].pc;value=`CPU(h).commit_stage_i.wdata_o[slot];expect_value=oracle(pc);
          if(`CPU(h).commit_ack_commit_id[slot]) begin
            if(INJECT_ERROR!=0 && h==0 && pc==FAULT_PC) $fatal(1,"faulting refill atomic retired");
            if(expect_value[64]) begin
              if(value!==expect_value[63:0]) $fatal(1,"stale/lost data h=%0d pc=%h got=%h expected=%h",h,pc,value,expect_value[63:0]);
              checked[h]++;
            end
            if(pc==AMO_PC) begin
              if(h==0 || value<256 || value>=(64'd256+64'(HARTS)-64'd1)) $fatal(1,"peer AMO old value range");
              if(old_values[int'(value-256)]) $fatal(1,"peer AMO lost update");
              old_values[int'(value-256)]=1;atomic_count[h]++;
            end
            if(pc==DONE_PC) passed[h]=1;
          end
        end
        if(`HPD(h).flush_ack_valid_o && `HPD(h).flush_ack_origin_o==0) begin
          if(`HPD(h).flush_ack_error_o) $fatal(1,"unexpected ordinary eviction error");
          dirty_evictions++;
        end
        if(`HPD(h).coh_probe_rsp_valid_o && `HPD(h).coh_probe_rsp_ready_i && !`HPD(h).coh_probe_rsp_err_o && `HPD(h).coh_probe_rsp_state_o==0) begin
          if(`HPD(h).coh_probe_rsp_phase_o==0) begin absent_prepare++;absent_prepare_harts[h]=1;end
          if(`HPD(h).coh_probe_rsp_phase_o==1) absent_commit++;
        end
      end
    end
  end
  // Every successful publication must exclude caches proved absent in PREPARE.
  always @(posedge i_clk_cluster) begin
    if(i_rst_n_cluster) begin
      for(int bank=0;bank<4;bank++) begin
        if(`FAB.w_dir_update_valid[bank] && `FAB.w_dir_update_ready[bank]) begin
          for(int h=0;h<HARTS;h++) begin
            if(`FAB.reg_ctx_prepared_valid[`FAB.w_dir_update_tag[bank]][h] &&
               `FAB.reg_ctx_prepared_state[`FAB.w_dir_update_tag[bank]][h]==0) begin
              if(`FAB.w_dir_update_holders[bank][h]) $fatal(1,"published phantom holder");
              pruned_updates++;
            end
          end
        end
      end
    end
  end
  always @(negedge i_clk_cluster) begin
    if(i_rst_n_cluster) begin
      cycles++;
      $fdisplay(wave_file,"#%0d\nb%04b a\nb%04b b\nb%04b c",$time,absent_prepare_harts,4'(passed),4'(old_values));
      if(passed=='1) begin
        if(memory['h1000/8]!==64'd256+64'(HARTS)-64'd1) $fatal(1,"CBO did not publish the final shared counter to memory");
        if(o_int_fault || old_values!='1) $fatal(1,"lost atomic update or false diagnostic");
        if(child_allocations==0 || full_table_cycles==0 || root_credit_stalls==0) $fatal(1,"victim/full-table/root-credit assertions inactive");
        if(CASE_ID==0 && dirty_evictions==0) $fatal(1,"dirty L1 eviction not exercised");
        if(INJECT_ERROR!=0 && !fault_seen) $fatal(1,"missing precise refill fault");
        for(int h=0;h<HARTS;h++) begin
          if(checked[h]!=(h==0 ? (INJECT_ERROR==0 ? 36:18):18)) $fatal(1,"missing architectural checks h=%0d count=%0d",h,checked[h]);
          if(h!=0 && atomic_count[h]!=1) $fatal(1,"missing peer AMO");
        end
        for(int k=0;k<20;k++) begin
          if(protocol_hits[k]==0) $fatal(1,"external AXI check %0d never exercised",k);
          $display("AXI-IHI0022 external ASSERT %0d hits=%0d",k,protocol_hits[k]);
        end
        $display("CHECK absent_PREPARE=%0d COMMIT_I_responses=%0d pruned_updates=%0d dirty_evictions=%0d",absent_prepare,absent_commit,pruned_updates,dirty_evictions);
        $display("PASS: real victim escape harts=%0d case=%0d cycles=%0d",HARTS,CASE_ID,cycles);
        $display("CHECK slots=%0d children=%0d full_table_cycles=%0d root_credit_stalls=%0d retry_cancel_cycles=%0d",SLOTS,child_allocations,full_table_cycles,root_credit_stalls,retry_cancel_cycles);
        $fclose(wave_file);$finish;
      end
      if(cycles>25000) begin
        for(int h=0;h<HARTS;h++) $display("WATCH h=%0d checked=%0d done=%b",h,checked[h],passed[h]);
        $fatal(1,"victim lifecycle watchdog");
      end
    end
  end
endmodule
