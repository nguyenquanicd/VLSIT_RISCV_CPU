module mul8 (input wire clk, input wire signed [7:0] a, input wire signed [7:0] b, output reg signed [15:0] p);
  always @(posedge clk) p <= a * b;
endmodule
module acc32 (input wire clk, input wire signed [15:0] p, output reg signed [31:0] acc);
  always @(posedge clk) acc <= acc + {{16{p[15]}}, p};
endmodule
module csa32 (input wire clk, input wire signed [15:0] p, output reg [31:0] s, output reg [31:0] c);
  wire [31:0] pe = {{16{p[15]}}, p};
  always @(posedge clk) begin s <= s ^ c ^ pe; c <= ((s & c) | (s & pe) | (c & pe)) << 1; end
endmodule
module gather (input wire clk, input wire [31:0] act4, input wire [1:0] sel, output reg [7:0] x);
  always @(posedge clk) x <= act4[sel*8 +: 8];
endmodule
module acc64 (input wire clk, input wire signed [15:0] p, output reg signed [63:0] acc);
  always @(posedge clk) acc <= acc + {{48{p[15]}}, p};
endmodule
