// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
//`define BITWIDTH_4_4_OR_8_8 
`define BITWIDTH4_8  
module core (clk, sum_out, mem_in, out, inst, reset);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 16;

output [bw_psum+3:0] sum_out;
output [bw_psum*col-1:0] out;
input  [pr*bw-1:0] mem_in;
input  clk;
input  [16:0] inst; 
input  reset;

wire  [pr*bw-1:0] mac_in;
wire  [pr*bw-1:0] kmem_out;
wire  [pr*bw-1:0] qmem_out;

`ifdef BITWIDTH_4_4_OR_8_8
wire  [bw_psum*col-1:0] pmem_in;
wire   [bw_psum*col-1:0] pmem_out;
`elsif BITWIDTH4_8
wire  [16*col/2-1:0] pmem_in;
wire   [16*col/2-1:0] pmem_out;
`endif

wire  [bw_psum*col-1:0] fifo_out;
wire  [bw_psum*col-1:0] sfp_out;
wire  [bw_psum*col-1:0] array_out;
wire  [col-1:0] fifo_wr;
wire  ofifo_rd;
wire [3:0] qkmem_add;
wire [3:0] pmem_add;

wire  qmem_rd;
wire  qmem_wr; 
wire  kmem_rd;
wire  kmem_wr; 
wire  pmem_rd;
wire  pmem_wr; 

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

`ifdef BITWIDTH_4_4_OR_8_8 
assign pmem_in = fifo_out;
`elsif BITWIDTH4_8
assign pmem_in[1*16-1:16*0] = (fifo_out[2*bw_psum-1:bw_psum*1] << 4) + {{(4){fifo_out[1*bw_psum-1]}},fifo_out[1*bw_psum-1:bw_psum*0]};
assign pmem_in[2*16-1:16*1] = (fifo_out[4*bw_psum-1:bw_psum*3] << 4) + {{(4){fifo_out[3*bw_psum-1]}},fifo_out[3*bw_psum-1:bw_psum*2]};
assign pmem_in[3*16-1:16*2] = (fifo_out[6*bw_psum-1:bw_psum*5] << 4) + {{(4){fifo_out[5*bw_psum-1]}},fifo_out[5*bw_psum-1:bw_psum*4]};
assign pmem_in[4*16-1:16*3] = (fifo_out[8*bw_psum-1:bw_psum*7] << 4) + {{(4){fifo_out[7*bw_psum-1]}},fifo_out[7*bw_psum-1:bw_psum*6]};
`endif

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

`ifdef BITWIDTH_4_4_OR_8_8
sram_w16 #(.sram_bit(col*bw_psum)) psum_mem_instance (
`elsif BITWIDTH4_8
sram_w16 #(.sram_bit(16*col/2)) psum_mem_instance (
`endif
        .CLK(clk),
        .D(pmem_in),
        .Q(pmem_out),
        .CEN(!(pmem_rd||pmem_wr)),
        .WEN(!pmem_wr), 
        .A(pmem_add)
);



  //////////// For printing purpose ////////////
  always @(posedge clk) begin
      if(pmem_wr)
         $display("Memory write to PSUM mem add %x %x ", pmem_add, pmem_in); 
  end



endmodule
