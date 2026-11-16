`timescale 1ns/1ps
module tb_atomic_end_to_end #(parameter int HARTS=2, TRACE=1);
  logic  i_clk_cluster;
  logic  i_rst_n_cluster;
  logic [63:0] i_boot_addr;
  logic [3:0] i_int_msip;
  logic [3:0] i_int_mtip;
  logic [3:0] i_int_meip;
  logic [3:0] i_int_ssip;
  logic [3:0] i_int_stip;
  logic [3:0] i_int_seip;
  logic [3:0] i_hart_debug_req;
  logic [3:0] o_hart_debug_mode;
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
  int INJECT_ERROR=0;
  initial void'($value$plusargs("INJECT_ERROR=%d",INJECT_ERROR));
  `include "program_constants.svh"
  logic [63:0] memory [0:8191];
  logic write_active=0, read_active=0;
  logic [63:0] write_addr, read_addr;
  logic [7:0] write_left, read_left;
  logic [2:0] write_size, read_size;
  logic [6:0] write_id, read_id;
  logic [HARTS-1:0] passed='0;
  logic [HARTS*8-1:0] shared_seen='0;
  int atomic_count[HARTS], checked[HARTS], retired[HARTS];
  int protocol_hits[20];
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
    if(addr<64'h80000000 || addr>=64'h80010000) $fatal(1,"memory address outside BFM %h",addr);
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
        read_left<=o_axi_mem_arlen; read_size<=o_axi_mem_arsize; read_id<=o_axi_mem_arid;
      end
      if(read_active && !i_axi_mem_rvalid) begin
        i_axi_mem_rvalid<=1; i_axi_mem_rid<=read_id; i_axi_mem_rdata<=memory[memory_index(read_addr)];
        i_axi_mem_rresp<=((INJECT_ERROR!=0 && INJECT_ERROR!=3 && read_addr>=64'h80003000) ? 2'b10:2'b00); i_axi_mem_rlast<=(read_left==0);
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
    if(!$value$plusargs("WAVE=%s",wave_path)) wave_path="atomic.vcd";
    wave_file=$fopen(wave_path,"w");
    if(wave_file==0) $fatal(1,"wave output unavailable");
    $fdisplay(wave_file,"$timescale 1ns $end\n$scope module atomic $end");
    $fdisplay(wave_file,"$var wire 4 a atomic_response_ack $end\n$var wire 4 b probe_valid $end\n$var wire 4 c probe_ready $end\n$upscope $end\n$enddefinitions $end");
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
  logic [3:0] atomic_retire;
  for(genvar h=0;h<HARTS;h++) begin : gen_monitor
    logic [63:0] pc, result;
    logic check_valid;
    logic [63:0] expected;
    assign pc=dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_instr_id_commit[0].pc;
    assign result=dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_stage_i.wdata_o[0];
    assign atomic_retire[h]=dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.amo_resp.ack;
    always_comb begin
      check_valid=0; expected=0;
      case(pc)
        `include "program_checks.svh"
        default: begin end
      endcase
    end
    always @(posedge i_clk_cluster) begin
      if(!i_rst_n_cluster) begin atomic_count[h]=0; checked[h]=0; retired[h]=0; end
      else begin
        if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.csr_regfile_i.mcause_q!=0) begin
          if(INJECT_ERROR==0 || dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.csr_regfile_i.mcause_q!=64'(INJECT_ERROR==2 ? 5:7) ||
             dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.csr_regfile_i.mepc_q!=(INJECT_ERROR==3 ? OWNER_FAULT_PC:64'h80000030) ||
             dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.csr_regfile_i.mtval_q!=(INJECT_ERROR==3 ? 64'h80001000:64'h80003000+64'(h*64)))
            $fatal(1,"atomic trap mismatch h=%0d cause=%h pc=%h VA=%h",h,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.csr_regfile_i.mcause_q,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.csr_regfile_i.mepc_q,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.csr_regfile_i.mtval_q);
          passed[h]=1;
        end
        if(INJECT_ERROR!=0 && (INJECT_ERROR!=3 || h!=0) && dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_ack_commit_id[0] && pc>=(INJECT_ERROR==3 ? OWNER_FAULT_PC:64'h80000030) && pc<64'h80000700)
          $fatal(1,"failed atomic/younger instruction retired");
        if(INJECT_ERROR!=0 && dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.amo_error && dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.amo_resp.ack && dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_stage_i.we_gpr_o!='0)
          $fatal(1,"atomic fault wrote a destination register");
        if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_ack_commit_id[0]) begin
          retired[h]++;
          if(TRACE!=0 && retired[h]<25) $display("RET h=%0d pc=%h result=%h",h,pc,result);
          if(INJECT_ERROR==0 && pc==SHARED_PC) begin
            if(result<10 || result>=64'(10+HARTS*8)) $fatal(1,"shared AMO stale result h=%0d value=%h",h,result);
            if(shared_seen[int'(result-10)]) $fatal(1,"AMO duplicated old value %0d",result);
            shared_seen[int'(result-10)]=1;
            atomic_count[h]++;
          end
          if(INJECT_ERROR==0 && check_valid) begin
            if(result!==expected) $fatal(1,"architectural result mismatch h=%0d pc=%h got=%h expected=%h",h,pc,result,expected);
            checked[h]++;
          end
          if(INJECT_ERROR==0 && pc==DONE_PC) passed[h]=1;
          if(INJECT_ERROR==3 && h==0 && pc==OWNER_READ_PC) begin
            if(result!=41) $fatal(1,"ABORT lost dirty owner data");
            owner_reads++; passed[h]=1;
          end;
        end
        if(INJECT_ERROR==3 && dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_probe_rsp_valid_o && dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_probe_rsp_ready_i && dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_probe_rsp_phase_o==2) begin
          if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_probe_rsp_state_o!=3 || dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_probe_rsp_err_o) $fatal(1,"ABORT did not retain dirty M owner");
          abort_acks++;
        end
        if(INJECT_ERROR==3 && dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_own_gnt_valid_i && dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_own_gnt_ready_o && dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_own_gnt_err_i) begin
          error_grants++;
          if(error_grants>abort_acks) $fatal(1,"atomic error grant preceded ABORT ACK");
        end
        if(cycles<3000 && dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_probe_req_valid_i && dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_probe_req_ready_o)
          $display("PROBE h=%0d tag=%0d line=%h phase=%0d target=%0d regtag=%0d regline=%h regtarget=%0d state=%0d err=%b fsm=%0d",h,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_probe_req_tag_i,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_probe_req_nline_i,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_probe_req_phase_i,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_probe_req_target_state_i,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.u_vlsit_riscv_hpd_probe_engine.reg_probe_tag,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.u_vlsit_riscv_hpd_probe_engine.reg_probe_nline,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.u_vlsit_riscv_hpd_probe_engine.reg_probe_target_state,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.u_vlsit_riscv_hpd_probe_engine.reg_probe_state,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.u_vlsit_riscv_hpd_probe_engine.reg_probe_err,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.u_vlsit_riscv_hpd_probe_engine.reg_fsm_probe_current_state);
        if(cycles<3000 && dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_probe_rsp_valid_o && dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_probe_rsp_ready_i)
          $display("PROBE_RSP h=%0d tag=%0d phase=%0d state=%0d err=%b",h,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_probe_rsp_tag_o,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_probe_rsp_phase_o,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_probe_rsp_state_o,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_probe_rsp_err_o);
        if(cycles==18000) begin
          $display("DEBUG h=%0d own=%b/%b gnt=%b/%b probe=%b/%b phase=%d line=%h busy=%b mshr=%b pipe=%b UC=%d atomic=%b st1=%b rtab=%b lock=%h",h,
            dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_own_req_valid_o,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_own_req_ready_i,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_own_gnt_valid_i,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_own_gnt_ready_o,
            dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_probe_req_valid_i,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_probe_req_ready_o,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_probe_req_phase_i,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_probe_req_nline_i,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_probe_line_busy_o,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_probe_mshr_busy,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_probe_pipeline_busy,
            dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.hpdcache_uc_i.uc_fsm_q,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.uc_local_atomic_busy,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.hpdcache_ctrl_i.st1_req_valid_q,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.rtab_empty,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.coh_line_lock_valid_i);
          $display("DEBUG h=%0d st1line=%h hit=%b M=%b E=%b replay=%b MSHRempty=%b ctrlEmpty=%b probeFSM=%d flushEmpty=%b",h,
            dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.hpdcache_ctrl_i.st1_req_nline,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.hpdcache_ctrl_i.st1_dir_hit,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.hpdcache_ctrl_i.st1_dir_hit_dirty,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.hpdcache_ctrl_i.st1_dir_hit_exclusive,
            dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.hpdcache_ctrl_i.st1_req_is_amo,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.miss_mshr_empty,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.ctrl_empty,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.u_vlsit_riscv_hpd_probe_engine.reg_fsm_probe_current_state,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.gen_cache_hpd.i_cache_subsystem.i_dcache.i_hpdcache.flush_empty);
        end
        if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.w_tile_probe_rsp_valid[h] && dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.w_tile_probe_rsp_ready[h] && dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.w_tile_probe_rsp_phase[h]==0 && dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.w_tile_probe_rsp_state[h]==3) dirty_transfers++;
      end
    end
  end
  if(HARTS==2) assign atomic_retire[3:2]=0;
  always @(negedge i_clk_cluster) begin
    if(i_rst_n_cluster) begin
      cycles++;
      if(cycles==18000) begin
        for(int k=0;k<8;k++) $display("CCU slot=%0d valid=%b state=%0d line=%h phase=%0d active=%b exp=%b ack=%b err=%b",k,
          dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.u_vlsit_riscv_coh_tile_array.u_vlsit_riscv_coh_fabric.w_ctx_valid[k],dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.u_vlsit_riscv_coh_tile_array.u_vlsit_riscv_coh_fabric.reg_fsm_ctx_current_state[k],dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.u_vlsit_riscv_coh_tile_array.u_vlsit_riscv_coh_fabric.w_ctx_pa_line[k],dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.u_vlsit_riscv_coh_tile_array.u_vlsit_riscv_coh_fabric.w_ctx_phase[k],dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.u_vlsit_riscv_coh_tile_array.u_vlsit_riscv_coh_fabric.w_ctx_phase_active[k],dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.u_vlsit_riscv_coh_tile_array.u_vlsit_riscv_coh_fabric.w_ctx_ack_expected[k],dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.u_vlsit_riscv_coh_tile_array.u_vlsit_riscv_coh_fabric.w_ctx_ack_received[k],dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.u_vlsit_riscv_coh_tile_array.u_vlsit_riscv_coh_fabric.w_ctx_txn_err[k]);
        $display("CMO begin=%b ready=%b prep=%b finish=%b done=%b LLCmaint=%b ready=%b done=%b",
          dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_begin_valid,dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_begin_ready,dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_prepare_valid,dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_finish_valid,dut.u_vlsit_riscv_cluster_core.w_cmo_done,dut.u_vlsit_riscv_cluster_core.w_maint_valid,dut.u_vlsit_riscv_cluster_core.w_maint_ready,dut.u_vlsit_riscv_cluster_core.w_maint_done);
      end

      $fdisplay(wave_file,"#%0d\nb%04b a\nb%04b b\nb%04b c",$time,atomic_retire,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.w_tile_probe_rsp_valid,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.w_tile_probe_rsp_ready);
      if(passed=='1 && INJECT_ERROR!=0) begin
        if(INJECT_ERROR==3 && (abort_acks!=HARTS-1 || error_grants!=HARTS-1 || owner_reads==0)) $fatal(1,"missing owner ABORT/error grant evidence");
        $display("CHECK ABORT_ACK=%0d error_grants=%0d owner_reads=%0d",abort_acks,error_grants,owner_reads);
        $display("PASS: real atomic access-fault harts=%0d case=%0d cycles=%0d",HARTS,INJECT_ERROR,cycles);
        $fclose(wave_file); $finish;
      end
      else if(passed=='1) begin
        if(shared_seen!='1 || memory['h1000/8]!=64'(10+HARTS*8)) $fatal(1,"shared counter/lost update final=%0d",memory['h1000/8]);
        if(dirty_transfers==0) $fatal(1,"dirty remote owner never exercised");
        for(int h=0;h<HARTS;h++) begin
          if(atomic_count[h]!=8 || checked[h]!=(EXPECTED_CHECKS-(h==0 ? 0:3))) $fatal(1,"missing architectural checks h=%0d got=%0d expected=%0d",h,checked[h],EXPECTED_CHECKS-(h==0 ? 0:3));
          $display("CHECK hart=%0d shared_AMO=%0d architectural_values=%0d",h,atomic_count[h],checked[h]);
        end
        for(int k=0;k<20;k++) begin
          if(protocol_hits[k]==0) $fatal(1,"AXI assertion %0d never exercised",k);
          $display("AXI_CHECK %0d hits=%0d",k,protocol_hits[k]);
        end
        $display("PASS: real cached AMO/LR-SC harts=%0d cycles=%0d dirty_owner_transfers=%0d",HARTS,cycles,dirty_transfers);
        $fclose(wave_file); $finish;
      end
      if(cycles>20000) begin
        for(int h=0;h<HARTS;h++) $display("WATCHDOG h=%0d retired=%0d shared=%0d checks=%0d done=%b",h,retired[h],atomic_count[h],checked[h],passed[h]);
        $fatal(1,"atomic end-to-end watchdog");
      end
    end
  end
endmodule

