`timescale 1ns/1ps

module tb_victim_escape #(parameter int SLOTS=2);
  localparam int unsigned PARA_CPU_NUM = 4;
  localparam int unsigned PARA_COH_TXN_NUM = SLOTS;
  localparam int unsigned LPARA_TAG_W = $clog2(PARA_COH_TXN_NUM);
  localparam logic [1:0] LPARA_MESI_I = 2'd0;
  localparam logic [1:0] LPARA_MESI_S = 2'd1;
  localparam logic [1:0] LPARA_MESI_E = 2'd2;
  localparam logic [1:0] LPARA_MESI_M = 2'd3;
  localparam logic [1:0] LPARA_REQ_SHARED = 2'd0;
  localparam logic [1:0] LPARA_REQ_EXCLUSIVE = 2'd1;
  localparam logic [1:0] LPARA_PHASE_PREPARE = 2'd0;
  localparam logic [1:0] LPARA_PHASE_COMMIT = 2'd1;
  localparam logic [1:0] LPARA_PHASE_ABORT = 2'd2;

  logic i_clk_cluster;
  logic i_rst_n_cluster;
  logic [PARA_CPU_NUM-1:0] i_req_valid;
  logic [PARA_CPU_NUM-1:0] o_req_ready;
  logic [PARA_CPU_NUM-1:0][2:0] i_req_id;
  logic [PARA_CPU_NUM-1:0][51:0] i_req_pa_line;
  logic [PARA_CPU_NUM-1:0][1:0] i_req_kind;
  logic [PARA_CPU_NUM-1:0] o_gnt_valid;
  logic [PARA_CPU_NUM-1:0] i_gnt_ready;
  logic [PARA_CPU_NUM-1:0][2:0] o_gnt_req_id;
  logic [PARA_CPU_NUM-1:0][51:0] o_gnt_pa_line;
  logic [PARA_CPU_NUM-1:0][1:0] o_gnt_state;
  logic [PARA_CPU_NUM-1:0] o_gnt_err;
  logic [PARA_CPU_NUM-1:0] o_probe_req_valid;
  logic [PARA_CPU_NUM-1:0] i_probe_req_ready;
  logic [PARA_CPU_NUM-1:0][LPARA_TAG_W-1:0] o_probe_req_tag;
  logic [PARA_CPU_NUM-1:0][51:0] o_probe_req_pa_line;
  logic [PARA_CPU_NUM-1:0][1:0] o_probe_req_phase;
  logic [PARA_CPU_NUM-1:0][1:0] o_probe_req_target_state;
  logic [PARA_CPU_NUM-1:0] o_probe_req_wback_en;
  logic [PARA_CPU_NUM-1:0] i_probe_rsp_valid;
  logic [PARA_CPU_NUM-1:0] o_probe_rsp_ready;
  logic [PARA_CPU_NUM-1:0][LPARA_TAG_W-1:0] i_probe_rsp_tag;
  logic [PARA_CPU_NUM-1:0][51:0] i_probe_rsp_pa_line;
  logic [PARA_CPU_NUM-1:0][1:0] i_probe_rsp_phase;
  logic [PARA_CPU_NUM-1:0][1:0] i_probe_rsp_state;
  logic [PARA_CPU_NUM-1:0] i_probe_rsp_err;
  logic [PARA_CPU_NUM-1:0] i_probe_rsp_wback_done;
  logic i_same_line_lock_stall;
  logic [11:0][2:0] o_ccu_evt_count;
  logic o_coh_proto_diag_event;
  logic [2:0] o_dir_lookup_count;
  logic [2:0] o_dir_update_count;

  logic cmo_begin=0,cmo_begin_ready,cmo_prepare,cmo_prepare_ready=0,cmo_err;
  logic [51:0] cmo_line=0;
  logic [LPARA_TAG_W-1:0] cmo_tag,cmo_finish_tag=0;
  logic cmo_finish=0,cmo_finish_ready,cmo_finish_done;
  int diag_hits=0;
  always @(posedge i_clk_cluster) if(o_coh_proto_diag_event) diag_hits++;

  m_vlsit_riscv_coh_fabric #(
    .PARA_CMO_EN(32'd1),
    .PARA_CPU_NUM(32'(PARA_CPU_NUM)),
    .PARA_COH_TXN_NUM(32'(PARA_COH_TXN_NUM))
  ) u_vlsit_riscv_coh_fabric (
    .i_ccu_begin_valid(cmo_begin),
    .o_ccu_begin_ready(cmo_begin_ready),
    .i_ccu_begin_op('0),
    .i_ccu_begin_pa_line(cmo_line),
    .i_ccu_begin_hart(2'd1),
    .i_ccu_begin_wback_en(1'b1),
    .o_ccu_prepare_valid(cmo_prepare),
    .i_ccu_prepare_ready(cmo_prepare_ready),
    .o_ccu_prepare_tag(cmo_tag),
    .o_ccu_prepare_err(cmo_err),
    .i_ccu_finish_valid(cmo_finish),
    .o_ccu_finish_ready(cmo_finish_ready),
    .i_ccu_finish_tag(cmo_finish_tag),
    .i_ccu_finish_commit(1'b1),
    .o_ccu_finish_done(cmo_finish_done),

    .i_clk_cluster(i_clk_cluster),
    .i_rst_n_cluster(i_rst_n_cluster),
    .i_req_valid(i_req_valid),
    .o_req_ready(o_req_ready),
    .i_req_id(i_req_id),
    .i_req_pa_line(i_req_pa_line),
    .i_req_kind(i_req_kind),
    .o_gnt_valid(o_gnt_valid),
    .i_gnt_ready(i_gnt_ready),
    .o_gnt_req_id(o_gnt_req_id),
    .o_gnt_pa_line(o_gnt_pa_line),
    .o_gnt_state(o_gnt_state),
    .o_gnt_err(o_gnt_err),
    .o_probe_req_valid(o_probe_req_valid),
    .i_probe_req_ready(i_probe_req_ready),
    .o_probe_req_tag(o_probe_req_tag),
    .o_probe_req_pa_line(o_probe_req_pa_line),
    .o_probe_req_phase(o_probe_req_phase),
    .o_probe_req_target_state(o_probe_req_target_state),
    .o_probe_req_wback_en(o_probe_req_wback_en),
    .i_probe_rsp_valid(i_probe_rsp_valid),
    .o_probe_rsp_ready(o_probe_rsp_ready),
    .i_probe_rsp_tag(i_probe_rsp_tag),
    .i_probe_rsp_pa_line(i_probe_rsp_pa_line),
    .i_probe_rsp_phase(i_probe_rsp_phase),
    .i_probe_rsp_state(i_probe_rsp_state),
    .i_probe_rsp_err(i_probe_rsp_err),
    .i_probe_rsp_wback_done(i_probe_rsp_wback_done),
    .i_same_line_lock_stall(i_same_line_lock_stall),
    .o_coh_proto_diag_event(o_coh_proto_diag_event),
    .o_dir_lookup_count(o_dir_lookup_count),
    .o_dir_update_count(o_dir_update_count),
    .o_ccu_evt_count(o_ccu_evt_count)
  );


  // TEST-053, REQ-MEM-009/010/012/013/014/019. Cache BFM has independent
  // resident MESI state. PREPARE does not mutate it; terminal COMMIT does.
  `define FAB u_vlsit_riscv_coh_fabric
  logic service_enable=1, inject_error=0;
  logic [1:0] cache_state [4][65536];
  int grant_count=0, error_count=0, child_count=0, cancel_count=0;
  int full_hits=0, root_guard_hits=0, parent_match_hits=0, retry_hits=0;
  int victim_prepare_hits=0, victim_commit_hits=0, victim_abort_hits=0;
  int tag_uses [SLOTS];
  int req_sequence [4];
  logic [3:0][7:0] outstanding='0;
  int expected_line [4][8];
  logic [3:0] rsp_pending='0;
  logic [3:0][LPARA_TAG_W-1:0] rsp_tag;
  logic [3:0][51:0] rsp_line;
  logic [3:0][1:0] rsp_phase,rsp_state;
  logic [3:0] rsp_err,rsp_wb;
  int cycles=0;
  initial i_clk_cluster=0;
  always #5 i_clk_cluster=~i_clk_cluster;
  initial begin #500000;
    $display("WATCH grants=%0d child=%0d errors=%0d retry=%0d",grant_count,child_count,error_count,retry_hits);
    for(int s=0;s<SLOTS;s++) $display("slot %0d valid=%b state=%0d line=%h victim=%h busy=%b parent=%0d",s,`FAB.w_ctx_valid[s],`FAB.reg_fsm_ctx_current_state[s],`FAB.w_ctx_pa_line[s],`FAB.reg_ctx_victim_line[s],`FAB.w_victim_line_busy[s],`FAB.reg_ctx_parent_tag[s]);
    $fatal(1,"TEST-053 bounded BFM progress watchdog"); end

  // Responses are held until accepted. Data-independent BFM writeback status
  // models a finite successful/error completion; real AXI data is checked by CPU tests.
  always @(negedge i_clk_cluster) begin
    i_probe_req_ready = {4{service_enable}} & ~rsp_pending;
    i_probe_rsp_valid=rsp_pending;
    i_probe_rsp_tag=rsp_tag;i_probe_rsp_pa_line=rsp_line;
    i_probe_rsp_phase=rsp_phase;i_probe_rsp_state=rsp_state;
    i_probe_rsp_err=rsp_err;i_probe_rsp_wback_done=rsp_wb;
  end
  always @(posedge i_clk_cluster) if(i_rst_n_cluster) begin
    cycles++;
    if(o_coh_proto_diag_event) $fatal(1,"unexpected protocol diagnostic");
    if($countones(`FAB.w_ctx_valid)==SLOTS) full_hits++;
    if(!$isunknown(`FAB.w_ctx_valid) && $countones(`FAB.w_ctx_valid)>=SLOTS-1) begin
      root_guard_hits++;
      if((|o_req_ready) || (cmo_begin && cmo_begin_ready)) $fatal(1,"root consumed escape credit");
    end
    if(`FAB.w_alloc_valid && `FAB.w_alloc_ready) begin
      tag_uses[`FAB.w_alloc_tag]++;
      if(`FAB.w_internal_pick_valid) begin
        child_count++;
        for(int s=0;s<SLOTS;s++) if(`FAB.reg_fsm_ctx_current_state[s]==5'd3) begin
          parent_match_hits++;
          if(s!=int'(`FAB.w_internal_parent_tag) && `FAB.w_fsm_ctx_nxt_state[s]==5'd4)
            $fatal(1,"unselected parent entered child wait");
        end
      end
    end
    for(int s=0;s<SLOTS;s++) if(`FAB.reg_fsm_ctx_current_state[s]==5'd18) retry_hits++;
    cancel_count+=$countones(`FAB.w_cancel_hs);
    for(int h=0;h<4;h++) begin
      if(o_gnt_valid[h] && i_gnt_ready[h]) begin
        if(!outstanding[h][o_gnt_req_id[h]] || o_gnt_pa_line[h]!==52'(expected_line[h][o_gnt_req_id[h]]))
          $fatal(1,"grant ID/line does not match a live request");
        outstanding[h][o_gnt_req_id[h]]=0;
        grant_count++;
        if(o_gnt_err[h]) error_count++;
        else cache_state[h][int'(o_gnt_pa_line[h])]=o_gnt_state[h];
      end
      if(i_probe_rsp_valid[h] && o_probe_rsp_ready[h]) rsp_pending[h]=0;
      if(o_probe_req_valid[h] && i_probe_req_ready[h]) begin
        rsp_pending[h]=1;rsp_tag[h]=o_probe_req_tag[h];rsp_line[h]=o_probe_req_pa_line[h];
        rsp_phase[h]=o_probe_req_phase[h];rsp_err[h]=0;rsp_wb[h]=0;
        rsp_state[h]=cache_state[h][int'(o_probe_req_pa_line[h])];
        case(o_probe_req_phase[h])
          2'd0: begin
            victim_prepare_hits++;
            if(rsp_state[h]==2'd3 && o_probe_req_wback_en[h]) begin
              rsp_err[h]=inject_error;rsp_wb[h]=~inject_error;
            end
          end
          2'd1: begin
            victim_commit_hits++;
            if(rsp_state[h]!=0) begin
              rsp_state[h]=o_probe_req_target_state[h];
              cache_state[h][int'(o_probe_req_pa_line[h])]=rsp_state[h];
            end
          end
          2'd2: victim_abort_hits++;
          default: $fatal(1,"invalid phase");
        endcase
      end
    end
  end

  task automatic send_req(input int hart,input int line,input bit exclusive=1);
    @(negedge i_clk_cluster);
    i_req_valid[hart]=1;i_req_pa_line[hart]=52'(line);i_req_kind[hart]=exclusive?2'd1:2'd0;
    i_req_id[hart]=3'(req_sequence[hart]);
    if(outstanding[hart][i_req_id[hart]]) $fatal(1,"BFM reused active request id");
    outstanding[hart][i_req_id[hart]]=1;
    expected_line[hart][i_req_id[hart]]=line;req_sequence[hart]++;
    do @(posedge i_clk_cluster); while(!o_req_ready[hart]);
    @(negedge i_clk_cluster);i_req_valid[hart]=0;
  endtask
  task automatic drain(input int target);
    i_gnt_ready='1;
    while(grant_count<target) @(negedge i_clk_cluster);
    repeat(10) @(negedge i_clk_cluster);
    if(|`FAB.w_ctx_valid) $fatal(1,"context/line lock leaked after completion");
  endtask
  task automatic seed_set(input int setbase);
    for(int w=0;w<8;w++) begin
      send_req(0,setbase+w*1024);
      drain(grant_count+1);
    end
  endtask
  initial begin
    int before_grants,before_errors,before_child,before_retry;
    i_rst_n_cluster=0;i_req_valid=0;i_req_id=0;i_req_pa_line=0;i_req_kind=0;
    i_gnt_ready='1;i_same_line_lock_stall=0;
    for(int h=0;h<4;h++) begin req_sequence[h]=0;for(int a=0;a<65536;a++) cache_state[h][a]=0;end
    for(int s=0;s<SLOTS;s++) tag_uses[s]=0;
    repeat(4) @(negedge i_clk_cluster);i_rst_n_cluster=1;
    seed_set(0);seed_set(1);seed_set(4);$display("STAGE seeded grants=%0d",grant_count);

    // Exhaust ordinary root credits without a child. Neither a held CPU
    // request nor a maintenance request may consume the escape entry.
    before_grants=grant_count;i_gnt_ready=0;
    for(int k=0;k<SLOTS-1;k++) send_req(k%4,300+k);
    repeat(20) @(negedge i_clk_cluster);
    i_req_valid[2]=1;i_req_pa_line[2]=52'd21000;i_req_kind[2]=1;
    cmo_begin=1;cmo_line=52'd21001;
    repeat(12) begin @(negedge i_clk_cluster);if(o_req_ready[2] || cmo_begin_ready) $fatal(1,"escape credit consumed by root at N-1");end
    i_req_valid[2]=0;cmo_begin=0;drain(before_grants+SLOTS-1);

    // Fill N-1 roots while their grants cannot drain; a replacement parent
    // must still allocate its victim into the last physical context.
    before_grants=grant_count;before_child=child_count;
    i_gnt_ready=0;service_enable=0;
    for(int k=0;k<SLOTS-2;k++) send_req(k%4,100+k);
    send_req(1,8192);
    while($countones(`FAB.w_ctx_valid)<SLOTS) @(negedge i_clk_cluster);
    if(child_count!=before_child+1) $fatal(1,"last context not used by victim child");
    // New CPU and CMO roots must both remain backpressured at saturation.
    i_req_valid[2]=1;i_req_pa_line[2]=52'd20000;i_req_kind[2]=1;cmo_begin=1;cmo_line=52'd20001;
    repeat(12) begin @(negedge i_clk_cluster);if(o_req_ready[2] || cmo_begin_ready) $fatal(1,"full table admitted root");end
    i_req_valid[2]=0;cmo_begin=0;service_enable=1;
    drain(before_grants+SLOTS-1);$display("STAGE capacity drained");

    // Two parents in different sets of the same bank plus another bank;
    // stop probes so the parents coexist before terminal service is enabled.
    if(SLOTS>2) begin
      logic [3:0] accepted;
      before_grants=grant_count;before_child=child_count;
      service_enable=0;i_gnt_ready=0;
      for(int k=0;k<SLOTS-4;k++) send_req(k%4,240+k);
      @(negedge i_clk_cluster);
      for(int h=1;h<4;h++) begin
        i_req_id[h]=3'(req_sequence[h]);outstanding[h][i_req_id[h]]=1;
        i_req_pa_line[h]=h==1?52'd9216:(h==2?52'd8196:52'd8193);
        expected_line[h][i_req_id[h]]=int'(i_req_pa_line[h]);req_sequence[h]++;
        i_req_kind[h]=2'd1;i_req_valid[h]=1;
      end
      while(|i_req_valid) begin
        @(posedge i_clk_cluster);accepted=i_req_valid & o_req_ready;
        @(negedge i_clk_cluster);i_req_valid &= ~accepted;
      end
      repeat(25) @(negedge i_clk_cluster);
      if($countones(`FAB.w_ctx_valid)!=SLOTS || child_count!=before_child+1)
        $fatal(1,"multiple-parent saturation not reached");
      service_enable=1;drain(before_grants+SLOTS-1);$display("STAGE multiple parents drained");
      if(child_count!=before_child+3 || parent_match_hits<=child_count)
        $fatal(1,"multiple waiting parents not independently allocated");
    end

    // A real victim PREPARE error must ABORT and error only its parent,
    // retain old state and leave capacity reusable on retry.
    before_grants=grant_count;before_errors=error_count;before_child=child_count;
    inject_error=1;send_req(2,16384);drain(before_grants+1);inject_error=0;
    if(error_count!=before_errors+1 || child_count!=before_child+1)
      $fatal(1,"victim error did not reach its parent exactly once");
    before_grants=grant_count;send_req(2,16384);drain(before_grants+1);

    // Lock every possible victim with real outstanding root grants. The
    // replacement must cancel/relookup rather than reserve that set forever.
    // N=16 permits eight locked candidates plus the replacement root.
    if(SLOTS==16) begin
      seed_set(8);$display("STAGE conflict seeded");
      before_grants=grant_count;before_retry=retry_hits;i_gnt_ready=0;
      for(int w=0;w<8;w++) send_req(0,8+w*1024);
      repeat(40) @(negedge i_clk_cluster);
      send_req(1,8200);
      repeat(40) @(negedge i_clk_cluster);
      if(retry_hits==before_retry || cancel_count==0) $fatal(1,"victim line conflict not cancelled");
      drain(before_grants+9);
    end

    // Repeated replacement and tag reuse with finite backpressure.
    for(int k=0;k<24;k++) begin
      before_grants=grant_count;send_req(k%4,17408+k*1024);drain(before_grants+1);
    end
    if((full_hits==0) || (root_guard_hits==0) || (parent_match_hits==0) || (victim_prepare_hits==0) ||
       (victim_commit_hits==0) || (victim_abort_hits==0)) $fatal(1,"inactive required escape/phase assertion");
    if(tag_uses[0]<3) $fatal(1,"tag reuse not exercised");
    $display("PASS: TEST-053 slots=%0d grants=%0d children=%0d errors=%0d full=%0d root_guard=%0d parent=%0d PREPARE=%0d COMMIT=%0d ABORT=%0d retry=%0d cancels=%0d cycles=%0d",
      SLOTS,grant_count,child_count,error_count,full_hits,root_guard_hits,parent_match_hits,
      victim_prepare_hits,victim_commit_hits,victim_abort_hits,retry_hits,cancel_count,cycles);
    $finish;
  end
endmodule
