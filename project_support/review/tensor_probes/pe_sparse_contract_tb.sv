`timescale 1ns/1ps

module pe_sparse_contract_tb;
  reg clk = 1'b0;
  always #5 clk = ~clk;

  reg [31:0] act4;
  reg [1:0] sel0, sel1;
  reg signed [7:0] w0, w1;
  wire signed [31:0] bypass_acc, cut_acc;
  integer reference_acc = 0;
  integer checked_steps = 0;

  pe_sparse_contract #(.MUL_CUT(0)) bypass (
    .clk(clk), .act4(act4), .sel0(sel0), .sel1(sel1),
    .w0(w0), .w1(w1), .acc(bypass_acc)
  );
  pe_sparse_contract #(.MUL_CUT(1)) cut (
    .clk(clk), .act4(act4), .sel0(sel0), .sel1(sel1),
    .w0(w0), .w1(w1), .acc(cut_acc)
  );

  task drive_and_check(
    input [31:0] activations,
    input [1:0] p0, p1,
    input signed [7:0] weight0, weight1
  );
    integer a0, a1, b0, b1;
    integer previous;
    begin
      @(negedge clk);
      act4 = activations;
      sel0 = p0;
      sel1 = p1;
      w0 = weight0;
      w1 = weight1;
      a0 = $signed(activations[p0*8 +: 8]);
      a1 = $signed(activations[p1*8 +: 8]);
      b0 = weight0;
      b1 = weight1;
      previous = reference_acc;
      reference_acc = reference_acc + a0*b0 + a1*b1;

      @(posedge clk);
      #1;
      if (bypass_acc !== reference_acc || cut_acc !== previous)
        $fatal(1, "step %0d bypass=%0d expected=%0d cut=%0d previous=%0d",
               checked_steps, bypass_acc, reference_acc, cut_acc, previous);
      checked_steps = checked_steps + 1;
    end
  endtask

  integer a, b, left, right;
  reg [31:0] sequence_seed = 32'h2cae524f;
  initial begin
    // The isolated probe has no reset interface. Start all three histories
    // from zero after the first clock and before the first modeled update.
    @(posedge clk);
    #1;
    bypass.acc = 0;
    cut.acc = 0;
    cut.gen_cut.partial_q = 0;

    drive_and_check(32'h80808080, 0, 1, -128, -128);
    if (bypass_acc !== 32768)
      $fatal(1, "pair maximum must fit without sign reversal");
    drive_and_check(32'h80808080, 0, 1, 127, 127);

    for (a = -128; a < 128; a = a + 1)
      for (b = -128; b < 128; b = b + 1)
        drive_and_check({24'h0, a[7:0]}, 0, 1, b[7:0], 0);

    for (left = 0; left < 4; left = left + 1)
      for (right = left + 1; right < 4; right = right + 1)
        repeat (1024) begin
          sequence_seed = sequence_seed * 32'd1664525 + 32'd1013904223;
          drive_and_check(sequence_seed, left[1:0], right[1:0],
                          sequence_seed[15:8], sequence_seed[31:24]);
        end

    drive_and_check(0, 0, 1, 0, 0);
    $display("PASS: %0d sparse updates with one-cycle cut equivalence", checked_steps);
    $finish;
  end
endmodule
