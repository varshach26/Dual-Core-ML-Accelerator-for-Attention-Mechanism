// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module core (clk, sum_out, mem_in, out, inst, reset);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 16;

output [bw_psum+3:0] sum_out;
output [bw_psum*col-1:0] out;
wire   [bw_psum*col-1:0] pmem_out;
input  [pr*bw-1:0] mem_in;
input  clk;
input  [23:0] inst; 
input  reset;

wire  [pr*bw-1:0] mac_in;
wire  [pr*bw-1:0] kmem_out;
wire  [pr*bw-1:0] qmem_out;
wire  [bw_psum*col-1:0] pmem_in;
wire  [bw_psum*col-1:0] fifo_out;
wire  [bw_psum*col-1:0] sfp_out;
wire  [bw_psum*col-1:0] array_out;
wire  [col-1:0] fifo_wr;
wire  ofifo_rd;
wire [3:0] qkmem_add;
wire [3:0] pmem_add;

wire [bw_psum-1:0] norm_out;


wire  qmem_rd;
wire  qmem_wr; 
wire  kmem_rd;
wire  kmem_wr; 
wire  pmem_rd;
wire  pmem_wr; 
wire  norm_div;
wire  norm_wr;

wire [bw_psum-1:0] pmem_out_sel0;
wire [bw_psum-1:0] pmem_out_sel1;
wire [bw_psum-1:0] pmem_out_sel2;
wire [bw_psum-1:0] pmem_out_sel3;
wire [bw_psum-1:0] pmem_out_sel4;
wire [bw_psum-1:0] pmem_out_sel5;
wire [bw_psum-1:0] pmem_out_sel6;

assign norm_div = inst[18];
assign norm_wr  = inst[17];
assign ofifo_rd = inst[16];
assign qkmem_add = inst[15:12];
assign pmem_add = inst[11:8];

assign qmem_rd = inst[5];
assign qmem_wr = inst[4];
assign kmem_rd = inst[3];
assign kmem_wr = inst[2];
assign pmem_rd = inst[1];
assign pmem_wr = inst[0];

assign mac_in  = inst[6] ? kmem_out : qmem_out;
assign pmem_in = norm_div ? concatenator : fifo_out;

assign pmem_out_sel0 = inst[19] ? pmem_out[(bw_psum * 2)-1 -: bw_psum] : pmem_out[(bw_psum * 1)-1 -: bw_psum];
assign pmem_out_sel1 = inst[19] ? pmem_out[(bw_psum * 4)-1 -: bw_psum] : pmem_out[(bw_psum * 3)-1 -: bw_psum];
assign pmem_out_sel2 = inst[19] ? pmem_out[(bw_psum * 6)-1 -: bw_psum] : pmem_out[(bw_psum * 5)-1 -: bw_psum];
assign pmem_out_sel3 = inst[19] ? pmem_out[(bw_psum * 8)-1 -: bw_psum] : pmem_out[(bw_psum * 7)-1 -: bw_psum];

assign pmem_out_sel4 = inst[20] ? pmem_out_sel1 : pmem_out_sel0;
assign pmem_out_sel5 = inst[20] ? pmem_out_sel3 : pmem_out_sel2;

assign pmem_out_sel6 = inst[21] ? pmem_out_sel5 : pmem_out_sel4;


reg [col*bw_psum-1:0] concatenator;

always @(posedge clk) begin
	concatenator[(bw_psum * 1)-1 -: bw_psum] <= concatenator[(bw_psum * 2)-1 -: bw_psum];
	concatenator[(bw_psum * 2)-1 -: bw_psum] <= concatenator[(bw_psum * 3)-1 -: bw_psum];
	concatenator[(bw_psum * 3)-1 -: bw_psum] <= concatenator[(bw_psum * 4)-1 -: bw_psum];
	concatenator[(bw_psum * 4)-1 -: bw_psum] <= concatenator[(bw_psum * 5)-1 -: bw_psum];
	concatenator[(bw_psum * 5)-1 -: bw_psum] <= concatenator[(bw_psum * 6)-1 -: bw_psum];
	concatenator[(bw_psum * 6)-1 -: bw_psum] <= concatenator[(bw_psum * 7)-1 -: bw_psum];
	concatenator[(bw_psum * 7)-1 -: bw_psum] <= concatenator[(bw_psum * 8)-1 -: bw_psum];
	concatenator[(bw_psum * 8)-1 -: bw_psum] <= norm_out;
end

mac_array #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) mac_array_instance (
        .in(mac_in), 
        .clk(clk), 
        .reset(reset), 
        .inst(inst[7:6]),     
        .fifo_wr(fifo_wr),     
	.out(array_out)
);

ofifo #(.bw(bw_psum), .col(col))  ofifo_inst (
        .reset(reset),
        .clk(clk),
        .in(array_out),
        .wr(fifo_wr),
        .rd(ofifo_rd),
        .o_valid(fifo_valid),
        .out(fifo_out)
);


sram_w16 #(.sram_bit(pr*bw)) qmem_instance (
        .CLK(clk),
        .D(mem_in),
        .Q(qmem_out),
        .CEN(!(qmem_rd||qmem_wr)),
        .WEN(!qmem_wr), 
        .A(qkmem_add)
);

sram_w16 #(.sram_bit(pr*bw)) kmem_instance (
        .CLK(clk),
        .D(mem_in),
        .Q(kmem_out),
        .CEN(!(kmem_rd||kmem_wr)),
        .WEN(!kmem_wr), 
        .A(qkmem_add)
);

sram_w16 #(.sram_bit(col*bw_psum)) psum_mem_instance (
        .CLK(clk),
        .D(pmem_in),
        .Q(pmem_out),
        .CEN(!(pmem_rd||pmem_wr)),
        .WEN(!pmem_wr), 
        .A(pmem_add)
);

norm #(.bw(bw_psum)) norm_instance (
        .clk(clk),
        .in(pmem_out_sel6), 
        .out(norm_out), 
        .div(norm_div),
        .wr(norm_wr), 
        .reset(inst[22]) 
);


  //////////// For printing purpose ////////////
  always @(posedge clk) begin
      if(pmem_wr)
         $display("Memory write to PSUM mem add %x %x ", pmem_add, pmem_in); 
  end



endmodule
