// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fifo_top (clk, in, out, rd, wr, o_full, reset, o_ready);

  parameter bw = 4;
  parameter width = 1;

  input  clk;
  input  wr;
  input  rd;
  input  reset;
  input  [width*bw-1:0] in;
  output [width*bw-1:0] out;
  output o_full;
  output o_ready;

  wire [width-1:0] empty;
  wire [width-1:0] full;
  
  genvar i;

  assign o_ready = !full ;
  assign o_full  = full ;


      fifo_depth64 #(.bw(bw)) fifo_instance (
	 .rd_clk(clk),
	 .wr_clk(clk),
	 .rd(rd),
	 .wr(wr),
         .o_empty(empty),
         .o_full(full),
	 .in(in),
	 .out(out),
         .reset(reset));


endmodule
