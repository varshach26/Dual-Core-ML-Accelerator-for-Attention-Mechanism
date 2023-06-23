// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_16in (out, a, b, clk, reset);

parameter bw = 8;
parameter bw_psum = 2*bw+6;
parameter pr = 64; // parallel factor: number of inputs = 64

output [bw_psum-1:0] out;
input  [pr*bw-1:0] a;
input  [pr*bw-1:0] b;
input              clk;
input              reset;


reg		[2*bw-1:0]	product0	;
reg		[2*bw-1:0]	product1	;
reg		[2*bw-1:0]	product2	;
reg		[2*bw-1:0]	product3	;
reg		[2*bw-1:0]	product4	;
reg		[2*bw-1:0]	product5	;
reg		[2*bw-1:0]	product6	;
reg		[2*bw-1:0]	product7	;
// reg		[2*bw-1:0]	product8	;
// reg     	[2*bw-1:0]	product9	;
// reg		[2*bw-1:0]	product10	;
// reg		[2*bw-1:0]	product11	;
// reg		[2*bw-1:0]	product12	;
// reg		[2*bw-1:0]	product13	;
// reg		[2*bw-1:0]	product14	;
// reg		[2*bw-1:0]	product15	;


genvar i;

always @ (posedge clk) begin
   if (reset) begin
	product0	<=     0;	
	product1	<=     0;
	product2	<=     0;	
	product3	<=     0;	
	product4	<=     0;	
	product5	<=     0;	
	product6	<=     0;	
	product7	<=     0;	
//	product8	<=     0;	
//	product9	<=     0;	
//	product10	<=     0;	
//	product11	<=     0;	
//	product12	<=     0;	
//	product13	<=     0;	
//	product14	<=     0;	
//	product15	<=     0;	
   end
   else begin
	product0	<=	{{(bw){a[bw*	1	-1]}},	a[bw*	1	-1:bw*	0	]}	*	{{(bw){b[bw*	1	-1]}},	b[bw*	1	-1:	bw*	0	]};
	product1	<=	{{(bw){a[bw*	2	-1]}},	a[bw*	2	-1:bw*	1	]}	*	{{(bw){b[bw*	2	-1]}},	b[bw*	2	-1:	bw*	1	]};
	product2	<=	{{(bw){a[bw*	3	-1]}},	a[bw*	3	-1:bw*	2	]}	*	{{(bw){b[bw*	3	-1]}},	b[bw*	3	-1:	bw*	2	]};
	product3	<=	{{(bw){a[bw*	4	-1]}},	a[bw*	4	-1:bw*	3	]}	*	{{(bw){b[bw*	4	-1]}},	b[bw*	4	-1:	bw*	3	]};
	product4	<=	{{(bw){a[bw*	5	-1]}},	a[bw*	5	-1:bw*	4	]}	*	{{(bw){b[bw*	5	-1]}},	b[bw*	5	-1:	bw*	4	]};
	product5	<=	{{(bw){a[bw*	6	-1]}},	a[bw*	6	-1:bw*	5	]}	*	{{(bw){b[bw*	6	-1]}},	b[bw*	6	-1:	bw*	5	]};
	product6	<=	{{(bw){a[bw*	7	-1]}},	a[bw*	7	-1:bw*	6	]}	*	{{(bw){b[bw*	7	-1]}},	b[bw*	7	-1:	bw*	6	]};
	product7	<=	{{(bw){a[bw*	8	-1]}},	a[bw*	8	-1:bw*	7	]}	*	{{(bw){b[bw*	8	-1]}},	b[bw*	8	-1:	bw*	7	]};
// 	product8	<=	{{(bw){a[bw*	9	-1]}},	a[bw*	9	-1:bw*	8	]}	*	{{(bw){b[bw*	9	-1]}},	b[bw*	9	-1:	bw*	8	]};
// 	product9	<=	{{(bw){a[bw*	10	-1]}},	a[bw*	10	-1:bw*	9	]}	*	{{(bw){b[bw*	10	-1]}},	b[bw*	10	-1:	bw*	9	]};
// 	product10	<=	{{(bw){a[bw*	11	-1]}},	a[bw*	11	-1:bw*	10	]}	*	{{(bw){b[bw*	11	-1]}},	b[bw*	11	-1:	bw*	10	]};
// 	product11	<=	{{(bw){a[bw*	12	-1]}},	a[bw*	12	-1:bw*	11	]}	*	{{(bw){b[bw*	12	-1]}},	b[bw*	12	-1:	bw*	11	]};
// 	product12	<=	{{(bw){a[bw*	13	-1]}},	a[bw*	13	-1:bw*	12	]}	*	{{(bw){b[bw*	13	-1]}},	b[bw*	13	-1:	bw*	12	]};
// 	product13	<=	{{(bw){a[bw*	14	-1]}},	a[bw*	14	-1:bw*	13	]}	*	{{(bw){b[bw*	14	-1]}},	b[bw*	14	-1:	bw*	13	]};
// 	product14	<=	{{(bw){a[bw*	15	-1]}},	a[bw*	15	-1:bw*	14	]}	*	{{(bw){b[bw*	15	-1]}},	b[bw*	15	-1:	bw*	14	]};
// 	product15	<=	{{(bw){a[bw*	16	-1]}},	a[bw*	16	-1:bw*	15	]}	*	{{(bw){b[bw*	16	-1]}},	b[bw*	16	-1:	bw*	15	]};
   end
end


assign out = 
                {{(4){product0[2*bw-1]}},product0	}
	+	{{(4){product1[2*bw-1]}},product1	}
	+	{{(4){product2[2*bw-1]}},product2	}
	+	{{(4){product3[2*bw-1]}},product3	}
	+	{{(4){product4[2*bw-1]}},product4	}
	+	{{(4){product5[2*bw-1]}},product5	}
	+	{{(4){product6[2*bw-1]}},product6	}
	+	{{(4){product7[2*bw-1]}},product7	};
//	+	{{(4){product8[2*bw-1]}},product8	}
//	+	{{(4){product9[2*bw-1]}},product9	}
//	+	{{(4){product10[2*bw-1]}},product10	}
//	+	{{(4){product11[2*bw-1]}},product11	}
//	+	{{(4){product12[2*bw-1]}},product12	}
//	+	{{(4){product13[2*bw-1]}},product13	}
//	+	{{(4){product14[2*bw-1]}},product14	}
//	+	{{(4){product15[2*bw-1]}},product15	};



endmodule
