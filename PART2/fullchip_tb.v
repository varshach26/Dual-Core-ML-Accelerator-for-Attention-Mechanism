// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
//`define BITWIDTH_4_4_OR_8_8 
`define BITWIDTH4_8  
`timescale 1ns/1ps

module fullchip_tb;

parameter total_cycle = 8;   // how many streamed Q vectors will be processed
parameter bw = 4;            // Q & K vector bit precision
parameter bw_psum = 2*bw+4;  // partial sum bit precision
parameter bw_psum_tb = 3*bw+4;  // partial sum bit precision
parameter pr = 8;           // how many products added in each dot product 
parameter col = 8;           // how many dot product units are equipped

integer qk_file ; // file handler
integer qk_scan_file ; // file handler


integer  captured_data;
integer  weight [col*pr-1:0];
`define NULL 0


integer  Q[total_cycle-1:0][pr-1:0];

`ifdef BITWIDTH_4_4_OR_8_8 
  integer  K[col-1:0][pr-1:0];
  reg [bw_psum*col-1:0] temp16b;
  reg [bw_psum-1:0] temp5b;
`elsif BITWIDTH4_8
  integer  K[col/2-1:0][pr-1:0];
  reg [bw_psum_tb*col/2-1:0] temp16b;
  reg [bw_psum_tb-1:0] temp5b;
`endif

integer  result[total_cycle-1:0][col-1:0];
integer  sum[total_cycle-1:0];

integer i,j,k,t,p,q,s,u, m, row;

reg reset = 1;
reg clk = 0;
reg [pr*bw-1:0] mem_in; 
reg [2*bw-1:0] tempK [pr-1:0];
reg ofifo_rd = 0;
reg norm_div = 0;
reg norm_wr = 0;
reg [2:0] norm_in_sel = 0;
reg norm_reset = 0;
wire [23:0] inst; 
wire [16:0] inst; 
reg qmem_rd = 0;
reg qmem_wr = 0; 
reg kmem_rd = 0; 
reg kmem_wr = 0;
reg pmem_rd = 0; 
reg pmem_wr = 0; 
reg execute = 0;
reg load = 0;
reg [3:0] qkmem_add = 0;
reg [3:0] pmem_add = 0;
reg pmem_wr_post_norm;


assign inst[23] = pmem_wr_post_norm;
assign inst[22] = norm_reset;
assign inst[21:19] = norm_in_sel;
assign inst[18] = norm_div;
assign inst[17] = norm_wr;
assign inst[16] = ofifo_rd;
assign inst[15:12] = qkmem_add;
assign inst[11:8]  = pmem_add;
assign inst[7] = execute;
assign inst[6] = load;
assign inst[5] = qmem_rd;
assign inst[4] = qmem_wr;
assign inst[3] = kmem_rd;
assign inst[2] = kmem_wr;
assign inst[1] = pmem_rd;
assign inst[0] = pmem_wr;




fullchip #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) fullchip_instance (
      .reset(reset),
      .clk(clk), 
      .mem_in(mem_in), 
      .inst(inst)
);

always @(posedge clk) begin
	pmem_wr_post_norm <= norm_div;
end

initial begin 

  $dumpfile("fullchip_tb.vcd");
  $dumpvars(0,fullchip_tb);



///// Q data txt reading /////

$display("##### Q data txt reading #####");


`ifdef BITWIDTH_4_4_OR_8_8 
  qk_file = $fopen("qdata.txt", "r");
`elsif BITWIDTH4_8
  qk_file = $fopen("vdata.txt", "r");
`endif

  for (q=0; q<total_cycle; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
	    // Why is pr=16? Should we change it to 8?
	    // total_cycle = 8 => This means that only 8 lines from q_data are
	    // read
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          Q[q][j] = captured_data;
          //$display("%d\n", K[q][j]);
    end
  end

  //// To get rid of first 3 lines in data file ////
  //qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  //qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  //qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  //qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);


/////////////////////////////////




  for (q=0; q<2; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
  end




///// K data txt reading /////

$display("##### K data txt reading #####");

  for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
  end
  reset = 0;

`ifdef BITWIDTH_4_4_OR_8_8 
  qk_file = $fopen("kdata.txt", "r");

  for (q=0; q<col; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
	  //
          K[q][j] = captured_data;
          //$display("##### %d %d %d\n", q,j,K[q][j]);
    end
  end
`elsif BITWIDTH4_8
  qk_file = $fopen("ndata.txt", "r");

  for (q=0; q<col/2; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
	  //
          K[q][j] = captured_data;
          //$display("##### %d %d %d\n", q,j,K[q][j]);
    end
  end
/////////////////////////////////
`endif

  //// To get rid of first 4 lines in data file ////
  //qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  //qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  //qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  //qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);











/////////////// Estimated result printing /////////////////


$display("##### Estimated multiplication result #####");

`ifdef BITWIDTH_4_4_OR_8_8

  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col; q=q+1) begin
       result[t][q] = 0;
     end
  end

  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col; q=q+1) begin
         for (k=0; k<pr; k=k+1) begin
            result[t][q] = result[t][q] + Q[t][k] * K[q][k];
            //if (t==0) $display("##### %d %d %d %d %d %h %d %h\n", t,q,k,Q[t][k],K[q][k],K[q][k],result[t][q],result[t][q]);
         end

         temp5b = result[t][q];
         temp16b = {temp16b[(bw_psum*col)-bw_psum-1:0], temp5b};
     end

     //$display("%d %d %d %d %d %d %d %d", result[t][0], result[t][1], result[t][2], result[t][3], result[t][4], result[t][5], result[t][6], result[t][7]);
     //$display("%4h %4h %4h %4h %4h %4h %4h %4h", result[t][0], result[t][1], result[t][2], result[t][3], result[t][4], result[t][5], result[t][6], result[t][7]);
     $display("prd @cycle%2d: %40h", t, temp16b);
  end

`elsif BITWIDTH4_8

  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col/2; q=q+1) begin
       result[t][q] = 0;
     end
  end

  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col/2; q=q+1) begin
         for (k=0; k<pr; k=k+1) begin
            result[t][q] = result[t][q] + Q[t][k] * K[q][k];
            //if (t==0) $display("##### %d %d %d %d %d %h %d %h\n", t,q,k,Q[t][k],K[q][k],K[q][k],result[t][q],result[t][q]);
         end

         temp5b = result[t][q];
         temp16b = {temp16b[(bw_psum_tb*col/2)-bw_psum_tb-1:0], temp5b};
     end

     //$display("%4h %4h %4h %4h", result[t][0], result[t][1], result[t][2], result[t][3]);
     //$display("prd @cycle%2d: %40h", t, temp16b);
     $display("prd @cycle%2d: %16h", t, temp16b);
  end

`endif

//////////////////////////////////////////////

///// Qmem writing  /////
//
// Add `define here
// eg. temp0[7:0] = Q[q][0]
// mem_in[3:0] = temp0[3:0];
// mem_in[7:4] = temp0[7:4];
// temp1[7:0] = Q[q][1];
// mem_in[11:8] = temp1[3:0];
// mem_in[15:12] = temp1[7:4];
//



$display("##### Qmem writing  #####");

  for (q=0; q<total_cycle; q=q+1) begin

    #0.5 clk = 1'b0;  
    qmem_wr = 1;  if (q>0) qkmem_add = qkmem_add + 1; 
    
    mem_in[1*bw-1:0*bw] = Q[q][0];
    mem_in[2*bw-1:1*bw] = Q[q][1];
    mem_in[3*bw-1:2*bw] = Q[q][2];
    mem_in[4*bw-1:3*bw] = Q[q][3];
    mem_in[5*bw-1:4*bw] = Q[q][4];
    mem_in[6*bw-1:5*bw] = Q[q][5];
    mem_in[7*bw-1:6*bw] = Q[q][6];
    mem_in[8*bw-1:7*bw] = Q[q][7];

    #0.5 clk = 1'b1;  

  end


  #0.5 clk = 1'b0;  
  qmem_wr = 0; 
  qkmem_add = 0;
  #0.5 clk = 1'b1;  
///////////////////////////////////////////





///// Kmem writing  /////
`ifdef BITWIDTH_4_4_OR_8_8

$display("##### Kmem writing #####");

  for (q=0; q<col; q=q+1) begin

    #0.5 clk = 1'b0;  
    kmem_wr = 1; if (q>0) qkmem_add = qkmem_add + 1; 
    
    mem_in[1*bw-1:0*bw] = K[q][0];
    mem_in[2*bw-1:1*bw] = K[q][1];
    mem_in[3*bw-1:2*bw] = K[q][2];
    mem_in[4*bw-1:3*bw] = K[q][3];
    mem_in[5*bw-1:4*bw] = K[q][4];
    mem_in[6*bw-1:5*bw] = K[q][5];
    mem_in[7*bw-1:6*bw] = K[q][6];
    mem_in[8*bw-1:7*bw] = K[q][7];

    #0.5 clk = 1'b1;  

  end

  #0.5 clk = 1'b0;  
  kmem_wr = 0;  
  qkmem_add = 0;
  #0.5 clk = 1'b1;  
///////////////////////////////////////////

`elsif BITWIDTH4_8

///// Kmem writing  /////

$display("##### Kmem writing #####");

  for (q=0; q<col/2; q=q+1) begin

    #0.5 clk = 1'b0;  
    kmem_wr = 1; if (q>0) qkmem_add = qkmem_add + 1; 
    
    tempK[0] = K[q][0];
    tempK[1] = K[q][1];
    tempK[2] = K[q][2];
    tempK[3] = K[q][3];
    tempK[4] = K[q][4];
    tempK[5] = K[q][5];
    tempK[6] = K[q][6];
    tempK[7] = K[q][7];

    mem_in[1*bw-1:0*bw] = tempK[0][7:4]; 
    mem_in[2*bw-1:1*bw] = tempK[1][7:4]; 
    mem_in[3*bw-1:2*bw] = tempK[2][7:4]; 
    mem_in[4*bw-1:3*bw] = tempK[3][7:4];
    mem_in[5*bw-1:4*bw] = tempK[4][7:4]; 
    mem_in[6*bw-1:5*bw] = tempK[5][7:4]; 
    mem_in[7*bw-1:6*bw] = tempK[6][7:4]; 
    mem_in[8*bw-1:7*bw] = tempK[7][7:4]; 

    #0.5 clk = 1'b1; 
    #0.5 clk = 1'b0; qkmem_add = qkmem_add + 1;

    mem_in[1*bw-1:0*bw] = tempK[0][3:0]; 
    mem_in[2*bw-1:1*bw] = tempK[1][3:0]; 
    mem_in[3*bw-1:2*bw] = tempK[2][3:0]; 
    mem_in[4*bw-1:3*bw] = tempK[3][3:0];
    mem_in[5*bw-1:4*bw] = tempK[4][3:0]; 
    mem_in[6*bw-1:5*bw] = tempK[5][3:0]; 
    mem_in[7*bw-1:6*bw] = tempK[6][3:0]; 
    mem_in[8*bw-1:7*bw] = tempK[7][3:0]; 

    #0.5 clk = 1'b1;  

  end

  #0.5 clk = 1'b0;  
  kmem_wr = 0;  
  qkmem_add = 0;
  #0.5 clk = 1'b1;  
///////////////////////////////////////////

`endif


  for (q=0; q<2; q=q+1) begin
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;   
  end




/////  K data loading  /////
$display("##### K data loading to processor #####");

  for (q=0; q<col+1; q=q+1) begin
    #0.5 clk = 1'b0;  
    load = 1; 
    if (q==1) kmem_rd = 1;
    if (q>1) begin
       qkmem_add = qkmem_add + 1;
    end

    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;  
  kmem_rd = 0; qkmem_add = 0;
  #0.5 clk = 1'b1;  

  #0.5 clk = 1'b0;  
  load = 0; 
  #0.5 clk = 1'b1;  

///////////////////////////////////////////

 for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
 end





///// execution  /////
$display("##### execute #####");

  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk = 1'b0;  
    execute = 1; 
    qmem_rd = 1;

    if (q>0) begin
       qkmem_add = qkmem_add + 1;
    end

    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;  
  qmem_rd = 0; qkmem_add = 0; execute = 0;
  #0.5 clk = 1'b1;  


///////////////////////////////////////////

 for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
 end




////////////// output fifo rd and wb to psum mem ///////////////////

$display("##### move ofifo to pmem #####");

  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk = 1'b0;  
    ofifo_rd = 1; 
    pmem_wr = 1; 

    if (q>0) begin
       pmem_add = pmem_add + 1;
    end

    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;  
  pmem_wr = 0; pmem_add = 0; ofifo_rd = 0;
  #0.5 clk = 1'b1;  

///////////////////////////////////////////

///////////////////////////////////////////////////////
//1. Read pmem - one row at a time
//2. Compute Normalized values - One row at a time
//3. Write back to pmem
///////////////////////////////////////////////////////

$display("##### read from pmem for normalization / Write back after Normalization");
  norm_wr = 0;
  norm_in_sel = 0;
 
  //Reset NORM module 
  #0.5 clk = 1'b0; norm_reset = 1;
  #0.5 clk = 1'b1; 
  #0.5 clk = 1'b0; norm_reset = 0; 
  #0.5 clk = 1'b1;  
  
  //Reading and normalizing one by one
  for (row=0; row<total_cycle; row=row+1) begin //Confirm the variables for 8x8, 4x8 so on..
	`ifdef BITWIDTH_4_4_8_8
  	for (q=0; q<col+1; q=q+1) begin
	`elsif BITWIDTH4_8
  	for (q=0; q<col/2+1; q=q+1) begin
	`endif
    		#0.5 clk = 1'b0;  
    		pmem_rd = 1; 

    		if (q>0) begin
       			pmem_add = row;
       			norm_in_sel = q-1;
       			norm_wr = 1;
    		end
    		#0.5 clk = 1'b1;  
  	end

  	#0.5 clk = 1'b0;  
  	norm_wr = 0; norm_in_sel = 0;
  	#0.5 clk = 1'b1;  
	
	//Division within Norm
  	for (q=0; q<total_cycle+1; q=q+1) begin
    		#0.5 clk = 1'b0;  
    		norm_div = 1; 
    		#0.5 clk = 1'b1;  
  	end

	//pmem Write back
    	#0.5 clk = 1'b0;
    	pmem_add = row + 8; //Confirm where to write back once parameterized
    	pmem_wr = 1;
    	#0.5 clk = 1'b1;  
  
    	#0.5 clk = 1'b0;
    	pmem_add = row + 8; //Confirm where to write back once parameterized
    	pmem_wr = 0;
    	#0.5 clk = 1'b1;  

  	#0.5 clk = 1'b0;  
  	norm_div = 0; pmem_add = 0;
  	#0.5 clk = 1'b1;  

	//Norm reset
  	#0.5 clk = 1'b0; norm_reset = 1;
  	#0.5 clk = 1'b1; 
 	#0.5 clk = 1'b0; norm_reset = 0; 
  	#0.5 clk = 1'b1;  
  	#0.5 clk = 1'b0;

  end


  #0.5 clk = 1'b0;  
  pmem_rd = 0; pmem_add = 0;
  #0.5 clk = 1'b1;  

//////////////////////////////





  #10 $finish;


end

endmodule




