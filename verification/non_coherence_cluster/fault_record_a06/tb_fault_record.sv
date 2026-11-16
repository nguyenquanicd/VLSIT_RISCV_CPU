`timescale 1ns/1ps
// DEC-039/040, REQ-ERR-003, TEST-054: independent packed-word oracle.
module tb_fault_record #(parameter int HARTS=4);
 logic clk=0,rst=0; always #5 clk=~clk;
 logic [3:0] valid=0;logic [3:0][55:0] addr='0;logic [3:0][1:0] resp='0;
 logic lv=0;logic [55:0] la=0;logic [1:0] lr=0;
 logic [31:0] sts,info,lo,hi;int checks=0;
 m_vlsit_riscv_fault_record #(.PARA_CPU_NUM(32'(HARTS))) dut(
 .i_clk_cluster(clk),.i_rst_n_cluster(rst),.i_l1_fault_valid(valid),.i_l1_fault_addr(addr),.i_l1_fault_resp(resp),
 .i_llc_fault_valid(lv),.i_llc_fault_addr(la),.i_llc_fault_resp(lr),.o_fault_sts(sts),.o_fault_info(info),.o_fault_addr_lo(lo),.o_fault_addr_hi(hi));
 int wave_file;string wave_path;
 initial begin
  if(!$value$plusargs("WAVE=%s",wave_path))wave_path="fault_record.vcd";
  wave_file=$fopen(wave_path,"w");if(wave_file==0)$fatal(1,"cannot open unit waveform");
  $fdisplay(wave_file,"$timescale 1ns $end\n$scope module fault_record $end\n$var wire 4 a l1_event $end\n$var wire 1 b llc_event $end\n$var wire 32 c record_sts $end\n$var wire 32 d record_info $end\n$var wire 64 e record_addr $end\n$var wire 1 f reset_n $end\n$upscope $end\n$enddefinitions $end");
 end
 always @(posedge clk)begin
  #2;$fdisplay(wave_file,"#%0d\nb%04b a\nb%01b b\nb%032b c\nb%032b d\nb%064b e\nb%01b f",$time,valid,lv,sts,info,{hi,lo},rst);
 end
 final $fclose(wave_file);
 task automatic tick; @(posedge clk);#1;endtask
 task automatic reset; @(negedge clk);rst=0;valid=0;lv=0;tick();@(negedge clk);rst=1;endtask
 task automatic check(input logic [31:0] s,input logic [31:0] i,input logic [55:0] a);
  checks++;if(sts!==s || info!==i || {hi,lo}!=={8'b0,a}) $fatal(1,"fault oracle s=%h/%h i=%h/%h a=%h/%h",sts,s,info,i,{hi,lo},a);
 endtask
 initial begin
  for(int h=0;h<HARTS;h++) for(int b=2;b<=3;b++) begin
   reset();check(0,0,0);valid=4'(1<<h);addr[h]=56'h12345680001230+56'(h*16);resp[h]=2'(b);tick();
   check('h1d,32'((h<<8)|(b<<4)|1),addr[h]);@(negedge clk);valid=0;
   repeat(7) begin tick();check('h1d,32'((h<<8)|(b<<4)|1),addr[h]);end
   @(negedge clk);lv=1;la=56'hfedcba80008000;lr=3;tick();check('h1f,32'((h<<8)|(b<<4)|1),addr[h]);
  end
  for(int b=2;b<=3;b++) begin
   reset();lv=1;la=56'hfedcba80008000;lr=2'(b);tick();check('h15,32'((b<<4)|2),la);
   @(negedge clk);lv=0;valid=1;addr[0]=56'h80004000;resp[0]=2;tick();check('h17,32'((b<<4)|2),la);
  end
  reset();valid='1;lv=1;la=56'h80008000;lr=3;
  for(int h=0;h<4;h++) begin addr[h]=56'h80001000+56'(h*16);resp[h]=2;end
  tick();check('h1f,'h21,56'h80001000);
  reset();if(HARTS==2) begin valid=4'b1100;tick();check(0,0,0);end
  reset();check(0,0,0);$display("PASS: TEST-054 first fatal/priority/multiple/reset/raw response/high address harts=%0d checks=%0d",HARTS,checks);$finish;
 end
 initial begin #10000;$fatal(1,"fault unit watchdog");end
endmodule
