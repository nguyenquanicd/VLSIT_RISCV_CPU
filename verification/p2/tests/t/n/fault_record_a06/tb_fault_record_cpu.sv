`timescale 1ns/1ps
module tb_fault_record_cpu #(parameter int HARTS=2, TRACE=1);
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
    .PARA_LLC_WAY_NUM(32'd4),.PARA_LLC_NO_LINES(32'd64)) dut (
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
  int LLC_MODE=0;
  initial void'($value$plusargs("LLC_MODE=%d",LLC_MODE));
  int INJECT_ERROR=0;
  logic memory_fault_injected=0;
  logic [63:0] write_start_addr=0, expected_llc_addr=0;
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
  int read_age=0;
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
      write_active<=0; read_active<=0; read_age<=0;
      i_axi_mem_bvalid<=0; i_axi_mem_bid<=0; i_axi_mem_bresp<=0;
      i_axi_mem_rvalid<=0; i_axi_mem_rid<=0; i_axi_mem_rdata<=0;
      i_axi_mem_rresp<=0; i_axi_mem_rlast<=0;
    end else begin
      if(read_active) read_age<=read_age+1;
      else read_age<=0;
      if(o_axi_mem_awvalid && i_axi_mem_awready) begin
        protocol_check(0,!write_active);
        protocol_check(1,o_axi_mem_awburst==1);
        protocol_check(2,o_axi_mem_awsize<=3);
        protocol_check(3,(o_axi_mem_awaddr & ((64'd1<<o_axi_mem_awsize)-1))==0);
        protocol_check(4,32'(o_axi_mem_awaddr[11:0])+((32'(o_axi_mem_awlen)+1)<<o_axi_mem_awsize)<=4096);
        protocol_check(5,o_axi_mem_awatop==0 && !o_axi_mem_awlock);
        write_active<=1; write_addr<=o_axi_mem_awaddr;write_start_addr<=o_axi_mem_awaddr;
        write_left<=o_axi_mem_awlen; write_size<=o_axi_mem_awsize; write_id<=o_axi_mem_awid;
      end
      if(o_axi_mem_wvalid && i_axi_mem_wready) begin
        protocol_check(6,write_active);
        protocol_check(7,o_axi_mem_wlast==(write_left==0));
        protocol_check(8,o_axi_mem_wstrb!=0);
        protocol_check(9,(o_axi_mem_wstrb & ~(8'hff << write_addr[2:0]))==0);
        for(int b=0;b<8;b++) if(o_axi_mem_wstrb[b]) memory[memory_index(write_addr)][b*8+:8]<=o_axi_mem_wdata[b*8+:8];
        if(write_left==0) begin
          write_active<=0; i_axi_mem_bvalid<=1; i_axi_mem_bid<=write_id;
          i_axi_mem_bresp <= (LLC_MODE!=0 && !memory_fault_injected) ? 2'(INJECT_ERROR) : 2'd0;
          if(LLC_MODE!=0 && !memory_fault_injected) begin memory_fault_injected<=1;expected_llc_addr<=write_start_addr;end
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
        read_left<=o_axi_mem_arlen; read_size<=o_axi_mem_arsize; read_id<=o_axi_mem_arid;
      end
      if(read_active && !i_axi_mem_rvalid && (read_addr[15:8]!=8'h93 || read_age>40)) begin
        i_axi_mem_rvalid<=1; i_axi_mem_rid<=read_id; i_axi_mem_rdata<=memory[memory_index(read_addr)];
        i_axi_mem_rresp<=2'b00; i_axi_mem_rlast<=(read_left==0);
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
    $stable({o_axi_mem_arid,o_axi_mem_araddr,o_axi_mem_arlen,o_axi_mem_arsize,o_axi_mem_arburst})) else $fatal(1,"AR stall changed: was valid=%b ready=%b id=%h addr=%h now valid=%b ready=%b id=%h addr=%h",$past(o_axi_mem_arvalid),$past(i_axi_mem_arready),$past(o_axi_mem_arid),$past(o_axi_mem_araddr),o_axi_mem_arvalid,i_axi_mem_arready,o_axi_mem_arid,o_axi_mem_araddr);
  initial begin
    if(!$value$plusargs("PROGRAM=%s",program_path)) $fatal(1,"PROGRAM image required");
    $readmemh(program_path,memory);
    if(!$value$plusargs("WAVE=%s",wave_path)) wave_path="atomic.vcd";
    wave_file=$fopen(wave_path,"w");
    if(wave_file==0) $fatal(1,"wave output unavailable");
    $fdisplay(wave_file,"$timescale 1ns $end\n$scope module atomic $end");
    $fdisplay(wave_file,"$var wire 4 a eviction_errors $end\n$var wire 4 b pending_evictions $end\n$var wire 4 c completed_misses $end\n$upscope $end\n$enddefinitions $end");
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
  `define CTRL(h) `HPD(h).hpdcache_ctrl_i
  `define RAM(h) `CTRL(h).hpdcache_memctrl_i
  logic [HARTS-1:0] error_seen='0, success_seen='0, pending_seen='0;
  int hold_checks[HARTS], error_age=0, phase=0;
  int refill_during_hold[HARTS];
  int reset_remaining=0;
  logic csr_checked=0;
  task automatic check_fault_csr;
    @(negedge i_clk_cluster);
    i_axil_araddr=32'h10;i_axil_arvalid=1;i_axil_rready=0;
    do @(posedge i_clk_cluster); while(!o_axil_arready);
    @(negedge i_clk_cluster);i_axil_arvalid=0;
    while(!o_axil_rvalid) @(negedge i_clk_cluster);
    if(o_axil_rresp!=0 || !o_axil_rdata[0]) $fatal(1,"missing fault diagnostic CSR");
    i_axil_rready=1;@(negedge i_clk_cluster);i_axil_rready=0;
  endtask
  task automatic try_clear_fault_csr;
    logic aw_done,w_done;
    aw_done=0;w_done=0;
    @(negedge i_clk_cluster);
    i_axil_awaddr=32'h10;i_axil_awvalid=1;
    i_axil_wdata=1;i_axil_wstrb=1;i_axil_wvalid=1;i_axil_bready=0;
    while(!aw_done || !w_done) begin
      @(posedge i_clk_cluster);
      if(o_axil_awready && i_axil_awvalid) aw_done=1;
      if(o_axil_wready && i_axil_wvalid) w_done=1;
      @(negedge i_clk_cluster);
      if(aw_done) i_axil_awvalid=0;
      if(w_done) i_axil_wvalid=0;
    end
    while(!o_axil_bvalid) @(negedge i_clk_cluster);
    if(o_axil_bresp!=0) $fatal(1,"W1C attempt response failed");
    i_axil_bready=1;@(negedge i_clk_cluster);i_axil_bready=0;
  endtask
  initial begin
    wait(LLC_MODE==0 && error_seen=='1);
    repeat(4) @(negedge i_clk_cluster);
    check_fault_csr();check_record(0);try_clear_fault_csr();check_fault_csr();check_record(0);check_native_hits(0);
    if(!o_int_fault) $fatal(1,"W1C incorrectly recovered fatal eviction");
    csr_checked=1;$display("CHECK fault CSR visible; W1C cannot clear fatal IRQ/context");
  end

  `define CORE dut.u_vlsit_riscv_cluster_core
  `define SHIM `CORE.u_vlsit_axi_llc
  logic record_reset_checked=0;
  int axil_hit[20];
  logic prev_rstall=0,prev_bstall=0;logic [33:0] rhold;logic [1:0] bhold;
  task automatic axil_chk(input int id,input bit ante,input bit okay);
    if(ante) begin axil_hit[id]++;if(!okay) $fatal(1,"AXIL-IHI0022 check %0d",id);end
  endtask
  always @(posedge i_clk_cluster) begin
    if(i_rst_n_cluster) begin
      axil_chk(0,i_axil_arvalid,!$isunknown(i_axil_araddr));
      axil_chk(1,i_axil_arvalid && o_axil_arready,i_axil_araddr[1:0]==0);
      axil_chk(2,o_axil_rvalid,o_axil_rresp inside {0,2,3});
      axil_chk(3,o_axil_rvalid && i_axil_rready,!$isunknown(o_axil_rdata));
      axil_chk(4,i_axil_awvalid,!$isunknown(i_axil_awaddr));
      axil_chk(5,i_axil_awvalid && o_axil_awready,i_axil_awaddr[1:0]==0);
      axil_chk(6,i_axil_wvalid,!$isunknown(i_axil_wdata));
      axil_chk(7,i_axil_wvalid && o_axil_wready,!$isunknown(i_axil_wstrb));
      axil_chk(8,o_axil_bvalid,o_axil_bresp inside {0,2,3});
      axil_chk(9,o_axil_bvalid && i_axil_bready,o_axil_bresp==0);
      axil_chk(10,prev_rstall,o_axil_rvalid && {o_axil_rresp,o_axil_rdata}==rhold);
      axil_chk(11,prev_bstall,o_axil_bvalid && o_axil_bresp==bhold);
      axil_chk(12,i_axil_arvalid,i_axil_arprot==0);
      axil_chk(13,i_axil_awvalid,i_axil_awprot==0);
      axil_chk(14,o_axil_rvalid,!$isunknown(o_axil_rresp));
      axil_chk(15,o_axil_bvalid,!$isunknown(o_axil_bresp));
      axil_chk(16,i_axil_wvalid && i_axil_wstrb==0,i_axil_wdata==0);
      axil_chk(17,i_axil_wvalid && i_axil_wstrb==1,i_axil_wdata==1);
      axil_chk(18,i_axil_arvalid && i_axil_araddr>=32'h4000,i_axil_araddr<32'h5000);
      axil_chk(19,i_axil_awvalid && i_axil_awaddr>=32'h4000,i_axil_awaddr<32'h5000);
    end
    prev_rstall=i_rst_n_cluster && o_axil_rvalid && !i_axil_rready;rhold={o_axil_rresp,o_axil_rdata};
    prev_bstall=i_rst_n_cluster && o_axil_bvalid && !i_axil_bready;bhold=o_axil_bresp;
  end
  task automatic read_word(input logic [31:0] address,output logic [31:0] value,input logic [1:0] response=0);
    @(negedge i_clk_cluster);i_axil_araddr=address;i_axil_arvalid=1;i_axil_rready=0;
    do @(posedge i_clk_cluster);while(!o_axil_arready);
    @(negedge i_clk_cluster);i_axil_arvalid=0;
    while(!o_axil_rvalid) @(negedge i_clk_cluster);
    repeat(3) @(negedge i_clk_cluster);
    if(o_axil_rresp!==response) $fatal(1,"AXIL response addr=%h got=%h expected=%h",address,o_axil_rresp,response);
    value=o_axil_rdata;i_axil_rready=1;@(negedge i_clk_cluster);i_axil_rready=0;
  endtask
  task automatic write_ro(input logic [31:0] address,input logic [31:0] value,input logic [3:0] strobe);
    bit aw,w;aw=0;w=0;
    @(negedge i_clk_cluster);i_axil_awaddr=address;i_axil_awvalid=1;i_axil_wdata=value;i_axil_wstrb=strobe;i_axil_wvalid=1;i_axil_bready=0;
    while(!aw || !w) begin
      @(posedge i_clk_cluster);if(i_axil_awvalid && o_axil_awready)aw=1;if(i_axil_wvalid && o_axil_wready)w=1;
      @(negedge i_clk_cluster);if(aw)i_axil_awvalid=0;if(w)i_axil_wvalid=0;
    end
    while(!o_axil_bvalid) @(negedge i_clk_cluster);
    repeat(3) @(negedge i_clk_cluster);
    if(o_axil_bresp!=0) $fatal(1,"RO write policy changed");
    i_axil_bready=1;@(negedge i_clk_cluster);i_axil_bready=0;
  endtask
  task automatic check_record(input bit llc);
    logic [31:0] s,inf,low,high;logic [63:0] expected_addr;logic [31:0] expected_info;
    expected_addr=llc?expected_llc_addr:`SHIM.first_error_addr;
    expected_info=llc?32'((INJECT_ERROR<<4)|2):32'((int'(`SHIM.first_error_hart)<<8)|(INJECT_ERROR<<4)|1);
    read_word('h4000,s);read_word('h4004,inf);read_word('h4008,low);read_word('h400c,high);
    if(s!==(llc?32'h15:32'h1f) || inf!==expected_info || {high,low}!==expected_addr)
      $fatal(1,"record mismatch source_llc=%b sts=%h info=%h/%h addr=%h/%h",llc,s,inf,expected_info,{high,low},expected_addr);
    write_ro('h4000,1,1);write_ro('h4008,0,0);
    read_word('h4008,low);read_word('h400c,high);
    if({high,low}!==expected_addr) $fatal(1,"RO/zero-WSTRB changed record");
    read_word('h4080,s,3);if(s!=0)$fatal(1,"reserved fault word not zero");
    $display("CHECK TEST-054 source_llc=%0d addr=%h info=%h exact_BRESP=%0d",llc,expected_addr,expected_info,INJECT_ERROR);
  endtask
  task automatic check_record_reset;
    logic [31:0] value;
    for(int k=0;k<4;k++) begin read_word(32'h4000+32'(k*4),value);if(value!=0)$fatal(1,"record not reset");end
    record_reset_checked=1;
  endtask
  task automatic check_native_hits(input bit require_memory);
    for(int k=0;k<20;k++) begin
      if(`SHIM.hit[k]==0 || (require_memory && protocol_hits[k]==0)) $fatal(1,"native/memory AXI assertion %0d inactive before reset",k);
      $display("AXI-native-before-reset ASSERT %0d hits=%0d",k,`SHIM.hit[k]);
      $display("AXI-memory-before-reset ASSERT %0d hits=%0d",k,protocol_hits[k]);
    end
  endtask
  task automatic check_axil_hits;
    for(int k=0;k<20;k++) begin
      if(axil_hit[k]==0)$fatal(1,"AXIL assertion %0d inactive",k);
      $display("AXIL-IHI0022 ASSERT %0d hits=%0d",k,axil_hit[k]);
    end
  endtask
  initial begin
    if(LLC_MODE==0) begin
      wait(phase==2);repeat(3) @(negedge i_clk_cluster);check_record_reset();
    end else begin
      wait(i_rst_n_cluster && o_int_fault);repeat(5) @(negedge i_clk_cluster);
      check_record(1);check_fault_csr();try_clear_fault_csr();check_record(1);
      repeat(40) @(negedge i_clk_cluster);
      if(!o_int_fault)$fatal(1,"fatal LLC state cleared without reset");
      check_native_hits(1);phase=1;reset_remaining=8;wait(!i_rst_n_cluster);wait(i_rst_n_cluster);
      check_record_reset();if(o_int_fault)$fatal(1,"LLC IRQ not reset");check_axil_hits();
      $display("PASS: real CPU LLC fault record harts=%0d B=%0d cycles=%0d",HARTS,INJECT_ERROR,cycles);
      $fclose(wave_file);$finish;
    end
  end
  for(genvar g=0;g<HARTS;g++) begin:gen_ack_proof
    always @(posedge i_clk_cluster) if(i_rst_n_cluster && `CORE.w_l1_evict_fault_event[g]) begin
      if(!`CORE.w_route_bvalid[g] || !`CORE.w_tile_axi_bready[g] || `CORE.w_route_bresp[g]!=2'(INJECT_ERROR))
        $fatal(1,"native flush ACK not correlated to accepted raw B response");
    end
  end

  for(genvar h=0;h<HARTS;h++) begin:gen_monitor
    logic [63:0] pc,result,expected;
    logic check_valid;
    logic [7:0] victim_way;
    logic [$bits(`RAM(h).gen_dir_sram[0].dir_sram.gen_sram.i_sram.mem[0])-1:0] tags[8], saved_tags[8];
    logic [63:0] data[8][2], saved_data[8][2];
    logic [51:0] victim_line, miss_line;
    assign pc=`CPU(h).commit_instr_id_commit[0].pc;
    assign result=`CPU(h).commit_stage_i.wdata_o[0];
    for(genvar w=0;w<8;w++) begin:gen_way
      assign tags[w]=`RAM(h).gen_dir_sram[w].dir_sram.gen_sram.i_sram.mem[32+h];
      for(genvar j=0;j<2;j++) begin:gen_word
        assign data[w][j]=`RAM(h).gen_data_sram_row[w/2].gen_data_sram_col[0].data_sram.gen_sram.ram_i.mem[2*(32+h)+j][w%2];
      end
    end
    function automatic logic [64:0] expected_result(input logic [63:0] check_pc);
      logic check_valid;
      logic [63:0] expected;
      check_valid=0;expected=0;
      case(check_pc)
        `include "program_checks.svh"
        default: begin end
      endcase
      return {check_valid,expected};
    endfunction
    always @(negedge i_clk_cluster) begin
      if(!i_rst_n_cluster) begin
        passed[h]=0;pending_seen[h]=0; error_seen[h]=0;success_seen[h]=0;checked[h]=0;hold_checks[h]=0;refill_during_hold[h]=0;
      end else if(LLC_MODE==0) begin
        if(`CPU(h).csr_regfile_i.mcause_q!=0) $fatal(1,"unexpected precise trap for retired store/ordinary eviction");
        // Both native commit ports may retire ordinary loads in one cycle.
        for(int slot=0;slot<2;slot++) begin
          logic [63:0] retire_pc,retire_data;
          logic [64:0] oracle;
          retire_pc=`CPU(h).commit_instr_id_commit[slot].pc;
          retire_data=`CPU(h).commit_stage_i.wdata_o[slot];
          oracle=expected_result(retire_pc);
          if(`CPU(h).commit_ack_commit_id[slot]) begin
            if(oracle[64]) begin
              if(retire_data!==oracle[63:0]) $fatal(1,"initial dirty data mismatch h=%0d pc=%h got=%h exp=%h",h,retire_pc,retire_data,oracle[63:0]);
              checked[h]++;
            end
            if(retire_pc==OLDER_PC && retire_data!=64'h55+64'(h)) $fatal(1,"older refill result corrupted");
            if(retire_pc==DONE_PC)passed[h]=1;
            if(retire_pc==EVICT_PC) begin
              if(INJECT_ERROR!=0 && phase==0) $fatal(1,"failed replacement retired");
              if(retire_data!=64'h999+64'(h)) $fatal(1,"replacement result mismatch");
              success_seen[h]=1;
            end
          end
        end
        if(`CTRL(h).ordinary_flush_sent_q && !pending_seen[h]) begin
          if(checked[h]!=16) $fatal(1,"eviction was not preceded by all real dirty stores/loads h=%0d checks=%0d",h,checked[h]);
          pending_seen[h]=1;victim_way=`CTRL(h).st2_flush_alloc_way_q;
          victim_line=`CTRL(h).st2_flush_alloc_nline_q;miss_line=`CTRL(h).st2_mshr_alloc_nline_o;
          for(int w=0;w<8;w++) begin
            saved_tags[w]=tags[w];
            for(int j=0;j<2;j++) saved_data[w][j]=data[w][j];
            if(victim_way[w]) begin
              if(!tags[w][$bits(tags[w])-1] || !tags[w][$bits(tags[w])-3]) $fatal(1,"victim not resident dirty");
              for(int j=0;j<2;j++)
                if(data[w][j]!==((64'd256*(64'(j)+64'd1)+64'(h)*64'd16)+((64'(victim_line)<<4)-64'h80000200-64'(h*16))/64'd4096))
                  $fatal(1,"native SRAM victim content wrong h=%0d word=%0d got=%h",h,j,data[w][j]);
            end
          end
        end
        if(pending_seen[h] && `CTRL(h).ordinary_flush_hold) begin
          hold_checks[h]++;
          if(`HPD(h).refill_core_rsp_valid) refill_during_hold[h]++;
          if(`HPD(h).miss_mshr_alloc || `HPD(h).miss_mshr_alloc_cs) $fatal(1,"replacement allocated MSHR before successful B");
          if(`CTRL(h).st2_flush_alloc_nline_q!=victim_line || `CTRL(h).st2_mshr_alloc_nline_o!=miss_line) $fatal(1,"pending eviction metadata changed");
          for(int w=0;w<8;w++) if(victim_way[w]) begin
            if(tags[w]!==saved_tags[w]) $fatal(1,"dirty victim tag changed before B success");
            for(int j=0;j<2;j++) if(data[w][j]!==saved_data[w][j]) $fatal(1,"dirty SRAM data destroyed");
          end
          if(error_seen[h] && `HPD(h).ctrl_flush_alloc) $fatal(1,"automatic eviction retry after B error");
          if(error_seen[h] && !`HPD(h).flush_empty) $fatal(1,"failed B transport not drained");
        end
        if(`CTRL(h).ordinary_flush_failed_q) begin error_seen[h]=1; end
      end
    end
  end
  // Drive BFM phase changes away from the sampling edge; retain all AXI assertions.
  always @(negedge i_clk_cluster) begin
    if(i_rst_n_cluster) begin
      cycles++;
      $fdisplay(wave_file,"#%0d\nb%04b a\nb%04b b\nb%04b c",$time,4'(error_seen),4'(pending_seen),4'(success_seen));
      if(error_seen=='1 && phase==0) begin
        error_age++;
        if(!o_int_fault) $fatal(1,"missing sticky asynchronous fault");
        if(error_age==512) begin
          if(!csr_checked) $fatal(1,"fault CSR/W1C checks did not complete");
          for(int h=0;h<HARTS;h++) if(hold_checks[h]<128 || refill_during_hold[h]==0) $fatal(1,"insufficient retained-data checks");
          $display("CHECK retained dirty tag/data/context for 512 cycles; native B drained; no retry or precise trap");
          phase=1; reset_remaining=8;
        end
      end
      if(success_seen=='1 && passed=='1) begin
        if(!record_reset_checked) $fatal(1,"record reset was not checked");
        if(o_int_fault) $fatal(1,"fault did not clear at reset/success");
        for(int h=0;h<HARTS;h++) if(hold_checks[h]<24 || refill_during_hold[h]==0) $fatal(1,"delayed B retention not exercised");
        check_axil_hits();
        $display("PASS: real ordinary L1 eviction harts=%0d B=%0d reset_recovery=%0d cycles=%0d",HARTS,INJECT_ERROR,phase,cycles);
        $display("CHECK TEST-050 assertions passed; AXI activation counts follow");
        for(int k=0;k<20;k++) begin
          if(protocol_hits[k]==0)$fatal(1,"external AXI assertion %0d inactive",k);
          $display("AXI-IHI0022 external check=%0d hits=%0d",k,protocol_hits[k]);
        end
        $fclose(wave_file);$finish;
      end
      if(cycles>12000) $fatal(1,"L1 eviction watchdog checks=%0d pending=%b error=%b success=%b",checked[0],pending_seen,error_seen,success_seen);
    end
  end
  // Only the public reset input changes for recovery. No internal DUT assignment.
  always @(negedge i_clk_cluster) begin
    if(reset_remaining>0) begin i_rst_n_cluster=0;reset_remaining--; end
    else if(phase==1 && !i_rst_n_cluster) begin i_rst_n_cluster=1;phase=2; end
  end
endmodule
