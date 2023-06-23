// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module norm (clk, in, out, div, wr, o_full, reset, o_ready);

  parameter bw = 4;
  parameter width = 1;

  input  clk;
  input  wr;
  input  div;
  input  reset;
  input  [bw-1:0] in;
  output reg [2*bw-1:0] out;
  output o_full;
  output o_ready;
 

  wire [bw-1:0] fifo_out;
  wire empty;
  wire full;
  wire [2*bw-1:0] div_out;
  reg  [2*bw-1:0] sum_q;
  assign div_out = {fifo_out, 8'b00000000} / sum_q;

  wire [bw-1:0] abs_conversion;
  assign abs_conversion = (in[bw-1] == 1) ? (~in) + 1 : in;

  fifo_top #(.bw(bw), .width(width)) fifo_top_instance (
	 .clk(clk),
	 .rd(div), //Add the correct variable / value in the bracket
	 .wr(wr),
	 .in(abs_conversion),
	 .out(fifo_out),
         .reset(reset)
  );

  always @ (posedge clk) begin
   if (reset) begin
      sum_q <= 0;
   end
   else begin
      if (wr) 
        sum_q <= sum_q + abs_conversion;
      else if (div) 
        out <= div_out;
   end
  end

endmodule
