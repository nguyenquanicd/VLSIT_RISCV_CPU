// Logic-depth probes for a tensor-array PE. Data registers carry no reset (as a retiming-friendly pipeline would).
// pe_v1: multiply and accumulate in one stage (no PARA_PIPELINE_MUL_EN cut)
module pe_v1 (input wire clk, input wire signed [7:0] a, input wire signed [7:0] b, output reg signed [31:0] acc);
  always @(posedge clk) acc <= acc + a * b;
endmodule

// pe_v2: product registered, then 32-bit carry-propagate accumulate (PARA_PIPELINE_MUL_EN=1)
module pe_v2 (input wire clk, input wire signed [7:0] a, input wire signed [7:0] b, output reg signed [31:0] acc);
  reg signed [15:0] p;
  always @(posedge clk) begin
    p   <= a * b;
    acc <= acc + p;
  end
endmodule

// pe_v3: product registered, accumulator kept in carry-save form (3:2 compressor in the loop); CPA only at drain
module pe_v3 (input wire clk, input wire signed [7:0] a, input wire signed [7:0] b,
              output reg [31:0] s, output reg [31:0] c);
  reg signed [15:0] p;
  wire [31:0] pe = {{16{p[15]}}, p};
  wire [31:0] sum  = s ^ c ^ pe;
  wire [31:0] cout = ((s & c) | (s & pe) | (c & pe)) << 1;
  always @(posedge clk) begin
    p <= a * b;
    s <= sum;
    c <= cout;
  end
endmodule

// pe_v4: 2:4 sparse paired lane: 4:1 activation select, two multipliers, product adder, then accumulate, one stage
module pe_v4 (input wire clk, input wire [31:0] act4, input wire [1:0] sel0, input wire [1:0] sel1,
              input wire signed [7:0] w0, input wire signed [7:0] w1, output reg signed [31:0] acc);
  wire signed [7:0] x0 = act4[sel0*8 +: 8];
  wire signed [7:0] x1 = act4[sel1*8 +: 8];
  always @(posedge clk) acc <= acc + x0 * w0 + x1 * w1;
endmodule

// pe_v5: sparse paired lane with a cut after the gather and a cut after the product adder (two extra stages)
module pe_v5 (input wire clk, input wire [31:0] act4, input wire [1:0] sel0, input wire [1:0] sel1,
              input wire signed [7:0] w0, input wire signed [7:0] w1, output reg signed [31:0] acc);
  reg signed [7:0] x0, x1, w0q, w1q;
  reg signed [16:0] psum;
  always @(posedge clk) begin
    x0 <= act4[sel0*8 +: 8];
    x1 <= act4[sel1*8 +: 8];
    w0q <= w0; w1q <= w1;
    psum <= x0 * w0q + x1 * w1q;
    acc <= acc + psum;
  end
endmodule

// Isolated DEC-007/062 candidate: both profiles preserve the same 17-bit
// paired sum. The only difference is the allowed multiplier-output cut.
module pe_sparse_contract #(
  parameter MUL_CUT = 1'b0
) (
  input wire clk,
  input wire [31:0] act4,
  input wire [1:0] sel0, sel1,
  input wire signed [7:0] w0, w1,
  output reg signed [31:0] acc
);
  wire signed [7:0] x0 = act4[sel0*8 +: 8];
  wire signed [7:0] x1 = act4[sel1*8 +: 8];
  wire signed [15:0] prod0 = x0 * w0;
  wire signed [15:0] prod1 = x1 * w1;
  wire signed [16:0] pair_sum =
      $signed({prod0[15], prod0}) + $signed({prod1[15], prod1});
  wire signed [16:0] accumulator_input;

  generate
    if (MUL_CUT) begin : gen_cut
      reg signed [16:0] partial_q;
      always @(posedge clk) partial_q <= pair_sum;
      assign accumulator_input = partial_q;
    end else begin : gen_bypass
      assign accumulator_input = pair_sum;
    end
  endgenerate
  always @(posedge clk)
    acc <= acc + $signed({{15{accumulator_input[16]}}, accumulator_input});
endmodule

// fp32_add_loop: single-cycle FP32 add in the accumulator loop (the BF16/FP16 mode with FP32 accumulate)
module fp32_add_loop (input wire clk, input wire [31:0] prod, output reg [31:0] acc);
  // Unpack
  wire        sa = acc[31], sb = prod[31];
  wire [7:0]  ea = acc[30:23], eb = prod[30:23];
  wire [23:0] ma = {|ea, acc[22:0]}, mb = {|eb, prod[22:0]};
  wire        agt = (ea > eb) | ((ea == eb) & (ma >= mb));
  wire [7:0]  el = agt ? ea : eb;
  wire [7:0]  d  = agt ? ea - eb : eb - ea;
  wire [23:0] ml = agt ? ma : mb;
  wire [23:0] ms0 = agt ? mb : ma;
  wire [26:0] ms = {ms0, 3'b0} >> (d > 8'd26 ? 5'd26 : d[4:0]);
  wire        sl = agt ? sa : sb;
  wire        sub = sa ^ sb;
  wire [27:0] sum = sub ? ({1'b0, ml, 3'b0} - {1'b0, ms}) : ({1'b0, ml, 3'b0} + {1'b0, ms});
  // Normalise (leading-zero count and shift) and round
  reg [4:0] lz;
  integer i;
  always @* begin
    lz = 5'd27;
    for (i = 0; i < 28; i = i + 1) if (sum[i]) lz = 5'd27 - i[4:0];
  end
  wire [27:0] nsum = sum << lz;
  wire [7:0]  en = el + 8'd1 - {3'b0, lz};
  wire [23:0] mr = nsum[26:3] + {23'b0, nsum[2] & (nsum[3] | nsum[1] | nsum[0])};
  always @(posedge clk) acc <= {sl, en, mr[22:0]};
endmodule
