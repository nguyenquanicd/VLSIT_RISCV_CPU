module leaf(input logic a,output logic b); assign b=~a; endmodule
module tb; bit a; wire b; leaf u(a,b); initial begin a=0; #1; assert(b); $display("PASS hierarchy tool probe"); $finish; end endmodule
