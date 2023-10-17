module part2Board(KEY, SW, LEDR, HEX0, HEX1, HEX4, HEX3);
	input [1:0] KEY;
	input [9:0] SW ;
	output [7:0] LEDR;
	output [6:0] HEX0, HEX1, HEX4, HEX3;

	wire [7:0] mainOut;
	wire reset;
	assign reset = ~KEY[0];
	part2 main(KEY[1], reset, SW[3:0], SW[9:8], mainOut);
	assign LEDR[7:0] = mainOut;


	hex H0(SW[3:0], HEX0);
	hex H1({2'b00,SW[9:8]}, HEX1);
	hex H4(mainOut[7:4], HEX4);
	hex H3(mainOut[3:0], HEX3);
endmodule





module part2(Clock, Reset_b, Data, Function, ALUout);
	input Clock, Reset_b;
	input [3:0] Data;
	input [1:0] Function;
	output reg [7:0] ALUout;

	wire [7:0] preALUout, ALUout_wire;
	wire [3:0] A_ALUin;
	
	ALU U1(A_ALUin, ALUout[3:0], Function, preALUout);
	Reg8 R1(Clock, Reset_b, preALUout, ALUout_wire);
	mux2to1 MUX(ALUout[7:4], Data, Function, A_ALUin);
	
	always @(*) begin
		ALUout = ALUout_wire;
	end
	
endmodule

module ALU(A, B, f, out); //works :)
	input [3:0] A,B;
	input [1:0] f;
	output reg [7:0] out;

	wire [3:0] B;
	
	
	always @(*) begin
		case(f)
			2'b00: out =  A + B;

			2'b01: out = A * B;

			2'b10: out = B<<A;

			2'b11: out = {A,B};

			default: out = 8'b00000000;
		endcase
	end
endmodule


module Reg8(clk, reset_b, d, q);//works
	input wire clk;
	input wire reset_b;
	input wire [7:0] d;
	output reg [7:0] q;


	always@ ( posedge clk )
		begin
		if (reset_b) q <= 8'b00000000 ;
		else q <= d ;
	end
endmodule

module mux2to1(Reg_in, Data_in, Function, Out);
	input [3:0] Reg_in, Data_in;
	input [1:0] Function;
	output reg [3:0] Out;

	always @(*) begin
		case(Function)
		2'b11: Out = Reg_in;
		default: Out = Data_in;
		endcase
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

