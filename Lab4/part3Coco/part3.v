//reset is active if 1
module part3(clock, reset, ParallelLoadn, RotateRight, ASRight, Data_IN, Q);
	input clock, reset, ParallelLoadn, RotateRight, ASRight;
	input [3:0] Data_IN;
	output [3:0] Q;
	
	reg mux3out, clk3;
	wire mux3out_wire, clk3_wire;
	
	//sub modules
	subMod subMod0(.clock(clock), .reset(reset), .LoadLeft(RotateRight), 
		.loadn(ParallelLoadn), .D(Data_IN[0]), .Q(Q[0]), .left(Q[1]), .right(Q[3]));

	subMod subMod1(.clock(clock), .reset(reset), .LoadLeft(RotateRight),
		.loadn(ParallelLoadn), .D(Data_IN[1]), .Q(Q[1]), .left(Q[2]), .right(Q[0]));

	subMod subMod2(.clock(clock), .reset(reset), .LoadLeft(RotateRight),
		.loadn(ParallelLoadn), .D(Data_IN[2]), .Q(Q[2]), .left(Q[3]), .right(Q[1]));

	subMod subMod3(.clock(clk3), .reset(reset), .LoadLeft(RotateRight),
		.loadn(ParallelLoadn), .D(Data_IN[3]), .Q(Q[3]), .left(mux3out), .right(Q[2]));

	//mux3
	always @(*) begin 
		if(ASRight) mux3out = Q[3];
		else mux3out = Q[0];

		if(ASRight & RotateRight & ~ParallelLoadn) clk3 = 1'b0;
		else clk3 = clock;	
	end
	assign mux3out_wire = mux3out;
	assign clk3_wire = clk3;
endmodule

//for demo
module part3board(KEY, SW, HEX0, HEX4, LEDR);
	input [1:0] KEY;
	input [9:0] SW;
	output [6:0] HEX0, HEX4;
	output [3:0] LEDR;

	part3 U1(KEY[0], KEY[1], SW[9], SW[8], SW[7], SW[3:0], LEDR[3:0]);
	hex H0(SW[3:0], HEX0);
	hex H4(LEDR[3:0], HEX4);
endmodule	
	

module subMod(left, LoadLeft, D, loadn, Q, right, reset, clock);
	input left, right, loadn, D, reset, clock, LoadLeft;
	output Q;
	
	reg reg0, reg1;
	DffP DFF1(clock, reset, reg1, Q);
	
	always @(*) begin //mux1
		if (~LoadLeft) reg0 = right;
		else reg0 = left;
	end

	always @(*) begin //mux2
		if(loadn) reg1 = reg0;
		else reg1 = D;
	end
endmodule


module DffP(clk, reset_b, d, q); //active high reset
	input wire clk;
	input wire reset_b;
	input wire  d;
	output reg  q;


	always@ ( posedge clk )
		begin
		if (reset_b) q <= 1'b0 ;
		else q <= d ;
	end
endmodule

module hex_decoder(c, display);
	input [3:0] c;
	output [6:0] display;
	
	wire c0, c1, c2, c3; //for the ease of typing (they are not wires)
	assign c0 = c[0];
	assign c1 = c[1];
	assign c2 = c[2];
	assign c3 = c[3];

	wire [6:0] inverted; //I messed up, everything is inverted

	assign inverted[0] = ~c2&~c0 | ~c3&c2&c0 | c2&c1 | c3&~c2&~c1 | c3&~c0 | ~c3&c1;
	assign inverted[1] = ~c3&~c1&~c0 | ~c2&~c1 | ~c2&~c0 | ~c3&c1&c0 | c3&~c1&c0;
	assign inverted[2] = ~c2&~c1 | ~c2&c0 | ~c1&c0 | ~c3&c2 | c3&~c2;
	assign inverted[3] = ~c3&~c2&~c0 | ~c2&c1&c0 | c2&~c1&c0 | c2&c1&~c0 | c3&~c1;
	assign inverted[4] = ~c2&~c0 | c1&~c0 | c3&c1 |c3&c2;
	assign inverted[5] = ~c1&~c0 | ~c3&c2&~c1 | c2&~c0 | c3&~c2 | c3&c1;
	assign inverted[6] = ~c2&c1 | c1&~c0 | ~c3&c2&~c1 | c3&~c2 | c3&c0;
	
	assign display = ~inverted;

endmodule

//*********for testing*************************************
module hex(SW, HEX);
	input [3:0] SW;
	output [6:0] HEX;
	hex_decoder H1(SW, HEX);	
endmodule
