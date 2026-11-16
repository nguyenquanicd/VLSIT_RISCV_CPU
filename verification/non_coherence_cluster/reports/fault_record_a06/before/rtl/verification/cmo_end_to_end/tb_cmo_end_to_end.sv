`timescale 1ns/1ps
module tb_cmo_end_to_end #(parameter int HARTS=2, TRACE=1);
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
  bit LOAD_FIRST;
  bit INJECT_ERROR;
  initial begin if (!$value$plusargs("INJECT_ERROR=%d",INJECT_ERROR)) INJECT_ERROR=0; end
  logic [63:0] memory [0:8191];
  logic write_active=0,read_active=0,write_fail=0;
  logic [63:0] write_addr,read_addr;
  logic [7:0] write_left,read_left;
  logic [2:0] write_size,read_size;
  logic [6:0] write_id,read_id;
  logic [HARTS-1:0] passed='0;
  int retired_count[HARTS];
  int cbo_count[HARTS];
  int cycles=0;
  int service_phase=0, service_hart=0;
  int completed[HARTS], aborted[HARTS];
  int wave_file;
  string wave_path;
  initial begin
    if (!$value$plusargs("WAVE=%s",wave_path)) wave_path="cmo_service.vcd";
    wave_file=$fopen(wave_path,"w");
    if(wave_file==0) $fatal(1,"cannot open service waveform");
    $fdisplay(wave_file,"$timescale 1ns $end\n$scope module cmo_service $end");
    $fdisplay(wave_file,"$var wire 1 a begin_valid $end\n$var wire 1 b begin_ready $end");
    $fdisplay(wave_file,"$var wire 1 c prepare_valid $end\n$var wire 1 d prepare_ready $end");
    $fdisplay(wave_file,"$var wire 1 e maint_valid $end\n$var wire 1 f maint_ready $end");
    $fdisplay(wave_file,"$var wire 1 g maint_done $end\n$var wire 1 h maint_error $end");
    $fdisplay(wave_file,"$var wire 1 i finish_valid $end\n$var wire 1 j finish_ready $end");
    $fdisplay(wave_file,"$var wire 1 k finish_commit $end\n$var wire 1 l finish_done $end");
    $fdisplay(wave_file,"$var wire 1 m cmo_done $end\n$var wire 1 n cmo_error $end");
    $fdisplay(wave_file,"$var wire 2 o hart $end\n$upscope $end\n$enddefinitions $end");
    for(int h=0;h<HARTS;h++) begin completed[h]=0; aborted[h]=0; end
  end
  // REQ-MEM-014: terminal retirement follows PREPARE, LLC and COMMIT/ABORT ACK.
  always @(posedge i_clk_cluster) begin
    if(i_rst_n_cluster) begin
      $fdisplay(wave_file,"#%0d",$time);
      $fdisplay(wave_file,"%ba\n%bb\n%bc\n%bd\n%be\n%bf\n%bg\n%bh\n%bi\n%bj\n%bk\n%bl\n%bm\n%bn\nb%02b o",
        dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_begin_valid,
        dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_begin_ready,
        dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_prepare_valid,
        dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_prepare_ready,
        dut.u_vlsit_riscv_cluster_core.w_maint_valid,
        dut.u_vlsit_riscv_cluster_core.w_maint_ready,
        dut.u_vlsit_riscv_cluster_core.w_maint_done,
        dut.u_vlsit_riscv_cluster_core.w_maint_error,
        dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_finish_valid,
        dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_finish_ready,
        dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_finish_commit,
        dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_finish_done,
        dut.u_vlsit_riscv_cluster_core.w_cmo_done,
        dut.u_vlsit_riscv_cluster_core.w_cmo_error,
        dut.u_vlsit_riscv_cluster_core.w_cmo_hart);
      if(dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_begin_valid && dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_begin_ready) begin
        if(service_phase!=0) $fatal(1,"overlapping shared CMO service");
        service_hart=int'(dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_begin_hart);
        service_phase=1;
      end
      if(dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_prepare_valid && dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_prepare_ready) begin
        if(service_phase!=1) $fatal(1,"PREPARE without begin");
        service_phase=2;
      end
      if(dut.u_vlsit_riscv_cluster_core.w_maint_valid && dut.u_vlsit_riscv_cluster_core.w_maint_ready) begin
        if(service_phase!=2) $fatal(1,"LLC before PREPARE completion");
        service_phase=3;
      end
      if(dut.u_vlsit_riscv_cluster_core.w_maint_done) begin
        if(service_phase!=3) $fatal(1,"unexpected LLC completion");
        service_phase=4;
      end
      if(dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_finish_valid && dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_finish_ready) begin
        if(service_phase!=4) $fatal(1,"terminal command before LLC completion");
        if(dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_finish_commit == 1'(INJECT_ERROR))
          $fatal(1,"incorrect COMMIT/ABORT decision");
        service_phase=5;
      end
      if(dut.u_vlsit_riscv_cluster_core.w_cmo_ccu_finish_done) begin
        if(service_phase!=5) $fatal(1,"unexpected terminal ACK");
        service_phase=6;
      end
      if(dut.u_vlsit_riscv_cluster_core.w_cmo_done) begin
        if(service_phase!=6) $fatal(1,"CPU completion before terminal CCU ACK");
        completed[service_hart]++;
        if(dut.u_vlsit_riscv_cluster_core.w_cmo_error) aborted[service_hart]++;
        service_phase=0;
      end
    end
  end
  assign i_axi_mem_awready = !write_active && !i_axi_mem_bvalid;
  assign i_axi_mem_wready = write_active;
  assign i_axi_mem_arready = !read_active && !i_axi_mem_rvalid;
  always #5 i_clk_cluster=~i_clk_cluster;
  function automatic int memory_index(input logic [63:0] addr);
    if(addr<64'h8000_0000 || addr>=64'h8001_0000) $fatal(1,"memory address out of model range %h",addr);
    return int'((addr-64'h8000_0000)>>3);
  endfunction
  always_ff @(posedge i_clk_cluster) begin
    if(!i_rst_n_cluster) begin
      write_active<=0; read_active<=0;
      i_axi_mem_bvalid<=0; i_axi_mem_bid<=0; i_axi_mem_bresp<=0;
      i_axi_mem_rvalid<=0; i_axi_mem_rid<=0; i_axi_mem_rdata<=0;
      i_axi_mem_rresp<=0; i_axi_mem_rlast<=0;
    end else begin
      if(o_axi_mem_awvalid && i_axi_mem_awready) begin
        if(o_axi_mem_awatop!=0 || o_axi_mem_awburst!=1 || o_axi_mem_awsize>3)
          $fatal(1,"unexpected write protocol in CBO test");
        write_active<=1; write_addr<=o_axi_mem_awaddr;
        write_left<=o_axi_mem_awlen; write_size<=o_axi_mem_awsize;
        write_id<=o_axi_mem_awid;
        write_fail<=1'(INJECT_ERROR) && o_axi_mem_awaddr>=64'h8000_1000
                     && o_axi_mem_awaddr<64'h8000_1100;
      end
      if(o_axi_mem_wvalid && i_axi_mem_wready) begin
        if(o_axi_mem_wlast !== (write_left==0)) $fatal(1,"write last mismatch");
        if(!write_fail)
          for(int byte_idx=0;byte_idx<8;byte_idx++)
            if(o_axi_mem_wstrb[byte_idx])
              memory[memory_index(write_addr)][byte_idx*8+:8]<=o_axi_mem_wdata[byte_idx*8+:8];
        if(write_left==0) begin
          write_active<=0; i_axi_mem_bvalid<=1;
          i_axi_mem_bid<=write_id; i_axi_mem_bresp<=write_fail ? 2'b10:2'b00;
        end else begin write_left<=write_left-1'b1; write_addr<=write_addr+(64'd1<<write_size); end
      end
      if(i_axi_mem_bvalid && o_axi_mem_bready) i_axi_mem_bvalid<=0;
      if(o_axi_mem_arvalid && i_axi_mem_arready) begin
        if(o_axi_mem_arburst!=1 || o_axi_mem_arsize>3) $fatal(1,"unexpected read protocol");
        read_active<=1; read_addr<=o_axi_mem_araddr;
        read_left<=o_axi_mem_arlen; read_size<=o_axi_mem_arsize; read_id<=o_axi_mem_arid;
      end
      if(read_active && !i_axi_mem_rvalid) begin
        i_axi_mem_rvalid<=1; i_axi_mem_rid<=read_id;
        i_axi_mem_rdata<=memory[memory_index(read_addr)]; i_axi_mem_rresp<=0;
        i_axi_mem_rlast<=(read_left==0);
      end
      if(i_axi_mem_rvalid && o_axi_mem_rready) begin
        i_axi_mem_rvalid<=0;
        if(read_left==0) read_active<=0;
        else begin read_left<=read_left-1'b1; read_addr<=read_addr+(64'd1<<read_size); end
      end
    end
  end
  initial begin
    if(!$value$plusargs("LOAD_FIRST=%d",LOAD_FIRST)) LOAD_FIRST=0;
    for(int idx=0;idx<8192;idx++) memory[idx]='0;
    memory[0][0+:32]=32'h00000297;
    memory[0][32+:32]=32'h20028293;
    memory[1][0+:32]=32'h30529073;
    memory[1][32+:32]=32'hf1402573;
    memory[2][0+:32]=32'h800015b7;
    memory[2][32+:32]=32'h02059593;
    memory[3][0+:32]=32'h0205d593;
    memory[3][32+:32]=32'h00651613;
    memory[4][0+:32]=32'h00c585b3;
    memory[4][32+:32]=LOAD_FIRST ? 32'h0005b683:32'h03150693;
    memory[5][0+:32]=32'h00d5b023;
    memory[5][32+:32]=32'h0015a00f;
    memory[6][0+:32]=32'h0025a00f;
    memory[6][32+:32]=32'h0005a00f;
    memory[7][0+:32]=32'h0000006f;
    memory[64][0+:32]=32'h34202373;
    memory[64][32+:32]=32'h341023f3;
    memory[65][0+:32]=32'h34302e73;
    memory[65][32+:32]=32'h0000006f;
    if(LOAD_FIRST) for(int h=0;h<HARTS;h++) memory[(32'h1000+h*64)>>3]=64'(49+h);
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
  for(genvar h=0;h<HARTS;h++) begin : gen_hart_monitor
    always @(posedge i_clk_cluster) begin
      if(!i_rst_n_cluster) begin cbo_count[h]=0; retired_count[h]=0; passed[h]=0; end
      else begin
        if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_ack_commit_id[0]) begin
          retired_count[h]++;
          if((TRACE!=0) && retired_count[h]<30) $display("hart %0d pc=%h op=%0d",h,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_instr_id_commit[0].pc,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_instr_id_commit[0].op);
          if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.commit_instr_id_commit[0].op inside {ariane_pkg::CBO_CLEAN,ariane_pkg::CBO_FLUSH,ariane_pkg::CBO_INVAL}) begin
            if(INJECT_ERROR) $fatal(1,"CBO retired despite failing memory writeback");
            cbo_count[h]++;
            if(memory[(32'h1000+h*64)>>3] !== 64'(49+h))
              $fatal(1,"CBO retired before its preceding store became DMA-visible");
            if(cbo_count[h]==3) begin
              if(memory[(32'h1000+h*64)>>3] !== 64'(49+h)) $fatal(1,"CBO did not make data visible to DMA observer");
              passed[h]=1;
            end
          end
        end
        if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.csr_regfile_i.mcause_q!=0) begin
          if(!INJECT_ERROR || dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.csr_regfile_i.mcause_q!=7)
            $fatal(1,"unexpected architectural trap hart=%0d cause=%h pc=%h",h,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.csr_regfile_i.mcause_q,dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.csr_regfile_i.mepc_q);
          if(dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.csr_regfile_i.mepc_q!=64'h8000_002c ||
             dut.u_vlsit_riscv_cluster_core.u_vlsit_riscv_cpu_tile_array.gen_tile[h].gen_active_tile.u_vlsit_riscv_cpu_tile.u_dont_touch_cva6.csr_regfile_i.mtval_q!=64'h8000_1000+64'(h*64))
            $fatal(1,"incorrect architectural CBO trap PC/VA");
          passed[h]=1;
        end
      end
    end
  end
  always @(negedge i_clk_cluster) begin
    if(i_rst_n_cluster) begin
      if((TRACE!=0) && o_axi_mem_awvalid && i_axi_mem_awready)
        $display("MEM AW addr=%h error_case=%b",o_axi_mem_awaddr,INJECT_ERROR);
      if((TRACE!=0) && i_axi_mem_bvalid && o_axi_mem_bready)
        $display("MEM B resp=%b",i_axi_mem_bresp);
      if((TRACE!=0) && dut.u_vlsit_riscv_cluster_core.w_maint_valid && dut.u_vlsit_riscv_cluster_core.w_maint_ready)
        $display("LLC MAINT op=%0d line=%h",dut.u_vlsit_riscv_cluster_core.w_maint_op,dut.u_vlsit_riscv_cluster_core.w_maint_pa_line);
      if((TRACE!=0) && dut.u_vlsit_riscv_cluster_core.w_maint_done)
        $display("LLC MAINT DONE err=%b",dut.u_vlsit_riscv_cluster_core.w_maint_error);
      cycles++;
      if(passed=='1) begin
        for(int h=0;h<HARTS;h++) begin
          if(completed[h]!=(INJECT_ERROR ? 1:3) || aborted[h]!=(INJECT_ERROR ? 1:0))
            $fatal(1,"missing native service completion hart=%0d",h);
          $display("CHECK hart=%0d retired_CBO=%0d completed_service=%0d aborted=%0d",h,cbo_count[h],completed[h],aborted[h]);
        end
        $fclose(wave_file);
        $display("PASS: real CVA6 CBO through arbiter/CCU/LLC; harts=%0d error=%0d cycles=%0d",HARTS,INJECT_ERROR,cycles);
        $finish;
      end
      if(cycles>50000) begin
        for(int k=0;k<HARTS;k++) $display("hart %0d retired=%0d CBO=%0d passed=%b",k,retired_count[k],cbo_count[k],passed[k]);
        $fatal(1,"CBO end-to-end watchdog");
      end
    end
  end
endmodule
