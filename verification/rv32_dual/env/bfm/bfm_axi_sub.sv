// -----------------------------------------------------------------------------
// AI-GENERATED (Claude Opus 5.5, 2026-11-28) - candidate artifact (R-117, R-231).
// bfm_axi_sub: project-local AXI4 subordinate BFM (plan 5.2 bfm_axi_mem / bfm_axi_mmio).
// Sources: AMBA AXI IHI 0022H A3.2 (handshake), A3.4 (INCR/WRAP/FIXED bursts),
// A6 (per-ID ordering, cross-ID reordering), A7.2 (exclusive access, EXOKAY);
// AMBA 5 E1.1 (AWATOP AtomicStore/Load/Swap/Compare, little-endian); REF-001
// rev 0.39 Section 6.2 (port widths), REQ-RST-001/DEC-041 (reset drops all
// outstanding work, backing memory kept), Section 10.4 (unbounded backpressure).
// Testbench MMIO control window per env/README.md (Q-G0-03 region 1, Q-G0-07).
// Not a qualified VIP (R-262). No RTL used. Human review pending.
// -----------------------------------------------------------------------------
// Plusargs (PFX = "MEM" or "MMIO"):
//   +<PFX>_IMAGE=<memh>   +<PFX>_ROM=<memh>   +<PFX>_ERR=<rules>   +<PFX>_DUMP=<ranges>
//   +<PFX>_RDY=<0..100>   +<PFX>_LAT=<max cycles>   +<PFX>_REORDER=<0|1>   +SEED=<n>
//   +<PFX>_LOG=<ndjson>   (BFM decision log: error injections, holds, drops)
// Rule file lines: "ERR B|R <addr_lo> <addr_hi> <nth> <count> <resp>"  (hex addresses)
//                  "HOLD R|B <addr_lo> <addr_hi> <cycles>"
// Dump file lines: "<addr_lo> <addr_hi>" (hex; 8-byte words written as NDJSON 'mem')
/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off UNUSEDPARAM */
/* verilator lint_off BLKSEQ */  // testbench counters and queues use blocking updates on purpose
module bfm_axi_sub #(
  parameter int    IDW     = 7,
  parameter bit    ATOMICS = 1'b1,
  parameter bit    CTRL    = 1'b0,
  parameter string PFX     = "MEM",
  parameter int    HARTS   = 2
) (
  input  logic            clk,
  input  logic            rst_n,
  // AW
  input  logic [IDW-1:0]  awid,   input logic [63:0] awaddr, input logic [7:0] awlen, input logic [2:0] awsize,
  input  logic [1:0]      awburst, input logic awlock, input logic [5:0] awatop, input logic awvalid,
  output logic            awready,
  // W
  input  logic [63:0]     wdata,  input logic [7:0] wstrb, input logic wlast, input logic wvalid,
  output logic            wready,
  // B
  output logic [IDW-1:0]  bid,    output logic [1:0] bresp, output logic bvalid, input logic bready,
  // AR
  input  logic [IDW-1:0]  arid,   input logic [63:0] araddr, input logic [7:0] arlen, input logic [2:0] arsize,
  input  logic [1:0]      arburst, input logic arlock, input logic arvalid,
  output logic            arready,
  // R
  output logic [IDW-1:0]  rid,    output logic [63:0] rdata, output logic [1:0] rresp, output logic rlast,
  output logic            rvalid, input logic rready,
  // testbench control outputs (CTRL=1 only)
  output logic [HARTS-1:0]        tohost_done,
  output logic [HARTS-1:0][31:0]  tohost_code,
  output logic [HARTS-1:0][5:0]   irq_level,     // {seip,stip,ssip,meip,mtip,msip} per hart
  output logic [HARTS-1:0]        dbg_req,
  output logic [31:0]             ckpt,
  input  logic [31:0]             ext_status    // CTRL: read at 0x600 (e.g. AXI4-Lite operations completed)
);
  localparam logic [1:0] OKAY = 2'b00, EXOKAY = 2'b01, SLVERR = 2'b10, DECERR = 2'b11;
  localparam logic [63:0] CTRL_BASE = 64'h1000_0000;

  typedef struct packed { logic [IDW-1:0] id; logic [63:0] addr; logic [7:0] len; logic [2:0] size;
                          logic [1:0] burst; logic lock; logic [5:0] atop; } req_t;
  typedef struct packed { logic [IDW-1:0] id; logic [63:0] data; logic [1:0] resp; logic last;
                          longint unsigned due; logic [63:0] addr; } rsp_t;

  logic [63:0] mem [logic [60:0]];          // 8-byte words, sparse
  req_t  aw_q[$], ar_q[$];
  logic [63:0] wd_q[$];
  logic [7:0]  ws_q[$];
  rsp_t  b_q[$], r_q[$];
  // exclusive monitor (A7.2): one reservation per ID
  logic [63:0] excl_addr [logic [IDW-1:0]];
  // rules
  int unsigned n_rules;
  logic        r_is_err [32]; logic r_chan_b [32];
  logic [63:0] r_lo [32], r_hi [32];
  int unsigned r_nth [32], r_cnt [32], r_seen [32], r_cycles [32];
  logic [1:0]  r_resp [32];
  int unsigned rdy_pct, lat_max, reorder, seed;
  longint unsigned cyc;
  int logf;
  logic [31:0] lfsr;
  logic [HARTS-1:0][31:0] resume_flag, halted_flag, dbgexc_flag;

  function automatic logic [31:0] rnd();
    lfsr = {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
    return lfsr;
  endfunction

  function automatic longint unsigned jitter();
    return (lat_max == 0) ? 64'd0 : (64'(rnd()) % (64'(lat_max) + 64'd1));
  endfunction

  function automatic logic [63:0] rd64(logic [63:0] a);
    logic [60:0] k = a[63:3];
    return mem.exists(k) ? mem[k] : 64'h0;
  endfunction

  task automatic wr64(logic [63:0] a, logic [63:0] d, logic [7:0] s);
    logic [60:0] k = a[63:3];
    logic [63:0] o = mem.exists(k) ? mem[k] : 64'h0;
    for (int i = 0; i < 8; i++) if (s[i]) o[8*i +: 8] = d[8*i +: 8];
    mem[k] = o;
  endtask

  function automatic logic [63:0] beat_addr(req_t q, int b);
    logic [63:0] nb = 64'(1) << q.size;
    logic [63:0] a  = (q.addr >> q.size) << q.size;
    if (q.burst == 2'b00) return (b == 0) ? q.addr : a;                  // FIXED
    if (q.burst == 2'b10) begin                                            // WRAP
      logic [63:0] tot = nb * (64'(q.len) + 1);
      logic [63:0] base = (q.addr / tot) * tot;
      return base + ((q.addr - base + nb * 64'(b)) % tot);
    end
    return (b == 0) ? q.addr : a + nb * 64'(b);                            // INCR
  endfunction

  // rule lookup: every matching error rule counts the occurrence, then the first rule whose
  // [nth, nth+count) window contains its occurrence number fires; hold rules match by address only
  function automatic int match_rule(bit is_err, bit chan_b, logic [63:0] a);
    automatic int pick = -1;
    for (int i = 0; i < int'(n_rules); i++) begin
      if (r_is_err[i] == is_err && r_chan_b[i] == chan_b && a >= r_lo[i] && a <= r_hi[i]) begin
        if (!is_err) return i;
        r_seen[i]++;
        if (pick < 0 && r_seen[i] >= r_nth[i] && r_seen[i] < r_nth[i] + r_cnt[i]) pick = i;
      end
    end
    return pick;
  endfunction

  task automatic load_memh(string f);
    int fd, c; logic [63:0] word_addr; logic [31:0] w; string line;
    fd = $fopen(f, "r");
    if (fd == 0) begin $display("%s BFM: cannot open image %s", PFX, f); $fatal(1); end
    word_addr = 0;
    while (!$feof(fd)) begin
      c = $fgets(line, fd);
      if (c <= 0) continue;
      if (line.substr(0, 0) == "@") begin
        void'($sscanf(line, "@%h", word_addr));
      end else if ($sscanf(line, "%h", w) == 1) begin
        wr64(word_addr << 2, {32'h0, w} << (32 * int'(word_addr[0])), word_addr[0] ? 8'hF0 : 8'h0F);
        word_addr++;
      end
    end
    $fclose(fd);
  endtask

  task automatic load_rules(string f);
    int fd, c; string line, kind, ch; logic [63:0] lo, hi; int unsigned a1, a2, a3;
    fd = $fopen(f, "r");
    if (fd == 0) begin $display("%s BFM: cannot open rules %s", PFX, f); $fatal(1); end
    while (!$feof(fd) && n_rules < 32) begin
      c = $fgets(line, fd);
      if (c <= 0) continue;
      if ($sscanf(line, "%s %s %h %h %d %d %d", kind, ch, lo, hi, a1, a2, a3) >= 5) begin
        r_is_err[n_rules] = (kind == "ERR");
        r_chan_b[n_rules] = (ch == "B");
        r_lo[n_rules] = lo; r_hi[n_rules] = hi;
        r_nth[n_rules] = a1; r_cnt[n_rules] = a2; r_resp[n_rules] = 2'(a3);
        r_cycles[n_rules] = a1; r_seen[n_rules] = 0;
        n_rules++;
      end
    end
    $fclose(fd);
  endtask

  initial begin
    string f;
    n_rules = 0; rdy_pct = 100; lat_max = 0; reorder = 0; seed = 1; cyc = 0; logf = 0;
    resume_flag = '0; halted_flag = '0; dbgexc_flag = '0;
    void'($value$plusargs("SEED=%d", seed));
    lfsr = 32'h1234_5678 ^ seed ^ ((PFX == "MEM") ? 32'h0 : 32'h9E37_79B9);
    if ($value$plusargs({PFX, "_RDY=%d"}, rdy_pct)) ;
    if ($value$plusargs({PFX, "_LAT=%d"}, lat_max)) ;
    if ($value$plusargs({PFX, "_REORDER=%d"}, reorder)) ;
    if ($value$plusargs({PFX, "_IMAGE=%s"}, f)) load_memh(f);
    if ($value$plusargs({PFX, "_ROM=%s"}, f)) load_memh(f);
    if ($value$plusargs({PFX, "_ERR=%s"}, f)) load_rules(f);
    if ($value$plusargs({PFX, "_LOG=%s"}, f)) logf = $fopen(f, "w");
  end

  function automatic logic [63:0] atomic_result(logic [5:0] atop, logic [63:0] old, logic [63:0] d, int nbytes,
                                                output logic [63:0] ret);
    logic [63:0] m = (nbytes == 8) ? 64'hFFFF_FFFF_FFFF_FFFF : ((64'(1) << (8 * nbytes)) - 1);
    logic signed [63:0] so, sd;
    logic [63:0] o = old & m, x = d & m;
    so = (nbytes == 4) ? 64'(signed'(o[31:0])) : signed'(o);
    sd = (nbytes == 4) ? 64'(signed'(x[31:0])) : signed'(x);
    ret = o;
    if (atop == 6'b110000) return x;                                   // AtomicSwap
    if (atop == 6'b110001) begin                                       // AtomicCompare: compare half, swap half
      logic [63:0] cmpv, swpv; int h = nbytes / 2;
      logic [63:0] hm = (64'(1) << (8 * h)) - 1;
      cmpv = x & hm; swpv = (x >> (8 * h)) & hm;
      ret = o & hm;
      return ((o & hm) == cmpv) ? ((o & ~hm) | swpv) : o;
    end
    case (atop[2:0])
      3'b000: return (o + x) & m;                                      // ADD
      3'b001: return o & ~x;                                           // CLR
      3'b010: return o ^ x;                                            // EOR
      3'b011: return o | x;                                            // SET
      3'b100: return (so > sd) ? o : x;                                // SMAX
      3'b101: return (so < sd) ? o : x;                                // SMIN
      3'b110: return (o > x) ? o : x;                                  // UMAX
      default: return (o < x) ? o : x;                                 // UMIN
    endcase
  endfunction

  function automatic logic is_ctrl(logic [63:0] a);
    return CTRL && a >= CTRL_BASE && a < CTRL_BASE + 64'h1000;
  endfunction

  task automatic ctrl_write(logic [63:0] a, logic [63:0] d, logic [7:0] s);
    logic [31:0] v = a[2] ? d[63:32] : d[31:0];
    logic [11:0] off = a[11:0];
    if (off < 12'h100) begin
      int h = int'(off[11:3]);
      if (h < HARTS) begin tohost_done[h] <= 1'b1; tohost_code[h] <= v; end
    end else if (off == 12'h100) begin
      irq_level[v[8]][v[2:0]] <= v[16];
    end else if (off == 12'h104) begin
      dbg_req <= v[HARTS-1:0];
    end else if (off == 12'h200) begin
      ckpt <= v;
    end else if (off >= 12'h300 && off < 12'h300 + 12'(4 * HARTS)) resume_flag[(off - 12'h300) >> 2] <= v;
    else if (off >= 12'h400 && off < 12'h400 + 12'(4 * HARTS)) halted_flag[(off - 12'h400) >> 2] <= v;
    else if (off >= 12'h500 && off < 12'h500 + 12'(4 * HARTS)) dbgexc_flag[(off - 12'h500) >> 2] <= v;
    wr64(a, d, s);                                                     // also visible as plain RAM
  endtask

  function automatic logic [63:0] ctrl_read(logic [63:0] a);
    logic [11:0] off = a[11:0];
    logic [31:0] v = 32'h0;
    if (off >= 12'h300 && off < 12'h300 + 12'(4 * HARTS)) v = resume_flag[(off - 12'h300) >> 2];
    else if (off >= 12'h400 && off < 12'h400 + 12'(4 * HARTS)) v = halted_flag[(off - 12'h400) >> 2];
    else if (off >= 12'h500 && off < 12'h500 + 12'(4 * HARTS)) v = dbgexc_flag[(off - 12'h500) >> 2];
    else if (off == 12'h600) v = ext_status;
    else return rd64(a);
    return {v, v};
  endfunction

  // ---------------------------------------------------------------- datapath
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      // DEC-041 / REQ-RST-001: drop every outstanding transaction; keep backing memory
      if (logf != 0 && (aw_q.size() + ar_q.size() + b_q.size() + r_q.size()) != 0)
        $fwrite(logf, "{\"type\":\"bfm\",\"port\":\"%s\",\"event\":\"reset_drop\",\"aw\":%0d,\"ar\":%0d,\"b\":%0d,\"r\":%0d,\"cycle\":%0d}\n",
                PFX, aw_q.size(), ar_q.size(), b_q.size(), r_q.size(), cyc);
      aw_q.delete(); ar_q.delete(); wd_q.delete(); ws_q.delete(); b_q.delete(); r_q.delete(); excl_addr.delete();
      awready <= 1'b0; wready <= 1'b0; arready <= 1'b0; bvalid <= 1'b0; rvalid <= 1'b0;
      bid <= '0; bresp <= '0; rid <= '0; rdata <= '0; rresp <= '0; rlast <= 1'b0;
      if (CTRL) begin tohost_done <= '0; tohost_code <= '0; irq_level <= '0; dbg_req <= '0; ckpt <= '0; end
    end else begin
      cyc <= cyc + 1;
      // accept requests (A3.2: transfer on VALID && READY)
      if (awvalid && awready) aw_q.push_back('{awid, awaddr, awlen, awsize, awburst, awlock, awatop});
      if (wvalid && wready) begin wd_q.push_back(wdata); ws_q.push_back(wstrb); end
      if (arvalid && arready) ar_q.push_back('{arid, araddr, arlen, arsize, arburst, arlock, 6'd0});
      awready <= (aw_q.size() < 8)  && ((rnd() % 100) < rdy_pct);
      wready  <= (wd_q.size() < 64) && ((rnd() % 100) < rdy_pct);
      arready <= (ar_q.size() < 8)  && ((rnd() % 100) < rdy_pct);
      // complete one write when all its W beats are present
      if (aw_q.size() > 0 && wd_q.size() >= int'(aw_q[0].len) + 1) begin
        automatic req_t q = aw_q.pop_front();
        automatic logic [1:0] resp = OKAY; automatic int ei, hi; automatic logic [63:0] ret, nv; automatic longint unsigned due;
        ei = match_rule(1'b1, 1'b1, q.addr);
        hi = match_rule(1'b0, 1'b1, q.addr);
        due = cyc + jitter();
        if (hi >= 0) due = cyc + 64'(r_cycles[hi]);
        if (ei >= 0) resp = r_resp[ei];
        else if (q.lock) begin                                          // A7.2 exclusive write
          resp = (excl_addr.exists(q.id) && excl_addr[q.id] == q.addr) ? EXOKAY : OKAY;
          if (excl_addr.exists(q.id)) excl_addr.delete(q.id);
        end
        for (int b = 0; b <= int'(q.len); b++) begin
          automatic logic [63:0] d = wd_q.pop_front(); automatic logic [7:0] s = ws_q.pop_front(); automatic logic [63:0] a = beat_addr(q, b);
          if (ei >= 0 || (q.lock && resp != EXOKAY)) continue;           // error or failed exclusive: no update
          if (ATOMICS && q.atop != 6'd0) begin
            automatic int nb = 1 << q.size;
            automatic int sh = int'(a[2:0]);
            automatic logic [63:0] old = rd64(a) >> (8 * sh);
            nv = atomic_result(q.atop, old, d >> (8 * sh), nb, ret);
            wr64(a, nv << (8 * sh), s);
            if (q.atop[5:4] != 2'b01) r_q.push_back('{q.id, ret << (8 * sh), OKAY, 1'b1, due, a});
          end else if (is_ctrl(a)) ctrl_write(a, d, s);
          else wr64(a, d, s);
          foreach (excl_addr[k]) if (excl_addr[k][63:3] == a[63:3] && k != q.id) excl_addr.delete(k);
        end
        if (ei >= 0 && logf != 0)
          $fwrite(logf, "{\"type\":\"bfm\",\"port\":\"%s\",\"event\":\"err_b\",\"id\":%0d,\"addr\":\"0x%0h\",\"resp\":%0d,\"cycle\":%0d}\n", PFX, q.id, q.addr, resp, cyc);
        b_q.push_back('{q.id, 64'h0, resp, 1'b1, due, q.addr});
      end
      // complete one read request into R beats
      if (ar_q.size() > 0) begin
        automatic req_t q = ar_q.pop_front();
        automatic int ei = match_rule(1'b1, 1'b0, q.addr);
        automatic int hi = match_rule(1'b0, 1'b0, q.addr);
        automatic longint unsigned due = cyc + jitter();
        if (hi >= 0) begin
          due = cyc + 64'(r_cycles[hi]);
          if (logf != 0) $fwrite(logf, "{\"type\":\"bfm\",\"port\":\"%s\",\"event\":\"hold_r\",\"id\":%0d,\"addr\":\"0x%0h\",\"cycles\":%0d,\"cycle\":%0d}\n", PFX, q.id, q.addr, r_cycles[hi], cyc);
        end
        if (q.lock) excl_addr[q.id] = q.addr;
        for (int b = 0; b <= int'(q.len); b++) begin
          automatic logic [63:0] a = beat_addr(q, b);
          automatic logic [1:0] rs = (ei >= 0) ? r_resp[ei] : (q.lock ? EXOKAY : OKAY);
          r_q.push_back('{q.id, (ei >= 0) ? 64'h0 : (is_ctrl(a) ? ctrl_read(a) : rd64(a)), rs, b == int'(q.len), due, a});
        end
        if (ei >= 0 && logf != 0)
          $fwrite(logf, "{\"type\":\"bfm\",\"port\":\"%s\",\"event\":\"err_r\",\"id\":%0d,\"addr\":\"0x%0h\",\"resp\":%0d,\"cycle\":%0d}\n", PFX, q.id, q.addr, r_resp[ei], cyc);
      end
      // B channel: oldest eligible entry; per-ID order kept (A6)
      if (!bvalid || bready) begin
        automatic int pick = -1;
        for (int i = 0; i < b_q.size() && pick < 0; i++) begin
          automatic bit older_same_id = 1'b0;
          for (int j = 0; j < i; j++) if (b_q[j].id == b_q[i].id) older_same_id = 1'b1;
          if (!older_same_id && b_q[i].due <= cyc && (reorder != 0 || i == 0) && ((rnd() % 100) < rdy_pct || b_q[i].due + 64 < cyc)) pick = i;
        end
        if (pick >= 0) begin
          automatic rsp_t e = b_q[pick]; b_q.delete(pick);
          bid <= e.id; bresp <= e.resp; bvalid <= 1'b1;
        end else bvalid <= 1'b0;
      end
      // R channel: beats of one burst stay contiguous for simplicity; per-ID order kept
      if (!rvalid || rready) begin
        automatic int pick = -1;
        for (int i = 0; i < r_q.size() && pick < 0; i++) begin
          automatic bit older_same_id = 1'b0;
          for (int j = 0; j < i; j++) if (r_q[j].id == r_q[i].id) older_same_id = 1'b1;
          if (!older_same_id && r_q[i].due <= cyc && (reorder != 0 || i == 0)) pick = i;
        end
        if (pick >= 0) begin
          automatic rsp_t e = r_q[pick]; r_q.delete(pick);
          rid <= e.id; rdata <= e.data; rresp <= e.resp; rlast <= e.last; rvalid <= 1'b1;
        end else rvalid <= 1'b0;
      end
    end
  end

  // final memory dump of requested ranges (NDJSON 'mem')
  final begin
    automatic string f; automatic int fd, dfd, c; automatic string line; automatic logic [63:0] lo, hi;
    if ($value$plusargs({PFX, "_DUMP=%s"}, f)) begin
      automatic string outf = "mem_dump.ndjson";
      void'($value$plusargs({PFX, "_DUMP_OUT=%s"}, outf));
      fd = $fopen(f, "r"); dfd = $fopen(outf, "w");
      while (fd != 0 && !$feof(fd)) begin
        c = $fgets(line, fd);
        if (c > 0 && $sscanf(line, "%h %h", lo, hi) == 2)
          foreach (mem[k]) if ({k, 3'b000} >= lo && {k, 3'b000} <= hi)
            $fwrite(dfd, "{\"type\":\"mem\",\"port\":\"%s\",\"addr\":\"0x%0h\",\"size\":8,\"data\":\"0x%016h\"}\n", PFX, {k, 3'b000}, mem[k]);
      end
      if (fd != 0) $fclose(fd);
      $fclose(dfd);
    end
    if (logf != 0) $fclose(logf);
  end
endmodule
/* verilator lint_on BLKSEQ */
/* verilator lint_on UNUSEDPARAM */
/* verilator lint_on UNUSEDSIGNAL */
