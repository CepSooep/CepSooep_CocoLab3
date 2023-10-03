//part2 lab3

module part1(a, b, c_in, s, c_out); //ripple carry adder 4-bit
	input [3:0] a, b;
	input c_in;
	output [3:0] s;
	output c_out;
	
	wire c1, c2, c3;
	
	assign s[0] = c_in ^ (a[0]^b[0]);
	assign s[1] = c1 ^ (a[1]^b[1]);
	assign s[2] = c2 ^ (a[2]^b[2]);
	assign s[3] = c3 ^ (a[3]^b[3]);
	
	assign c1 = a[0]&b[0] | c_in&b[0] | c_in&a[0];
	assign c2 = a[1]&b[1] | c1&b[1] | c1&a[1];
	assign c3 = a[2]&b[2] | c2&b[2] | c2&a[2];
	assign c_out = a[3]&b[3] | c3&b[3] | c3&a[3];
	
endmodule

module redOR(a, b, or_out);
	input [3:0] a, b;
	output [7:0] or_out;
	
	assign or_out = (|a) | (|b);
endmodule

module redAND(a, b, and_out);
	input [3:0] a, b;
	output [7:0] and_out;

	assign and_out = (&a) & (&b);
endmodule

module concatenate(a, b, con_out);
	input [3:0] a, b;
	output [7:0] con_out;

	assign con_out = {a, b};
endmodule

module coutAdder(cout, s, addOut);
	input cout;
	input [3:0] s;
	output [7:0] addOut;

	assign addOut = {{3'b000, cout}, s}; 
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
module hex(SW, HEX0);
	input [3:0] SW;
	output [6:0] HEX0;
	hex_decoder H1(SW, HEX0);	
endmodule


module part2(A, B, Function, ALUout);
	input [3:0] A, B;
	input [1:0] Function;
	output reg [7:0] ALUout;
	
	wire c_out;
	wire [3:0] s;
	wire [7:0] f0;
	wire [7:0] f1;
	wire [7:0] f2;
	wire [7:0] f3;

	part1 RCA(A, B, 0, s, c_out);
	redOR U1(A, B, f1);
	redAND U2(A, B, f2);
	concatenate U3(A, B, f3);
	coutAdder U4(c_out, s, f0);
	 
	always@(*)
	begin
		case(Function) //4to1mux
		2'b00: ALUout = f0;
		2'b01: ALUout = f1;
		2'b10: ALUout = f2;
		2'b11: ALUout = f3;
		default: ALUout = 8'b00000000;
		endcase
	end
endmodule

module part2test(SW, LEDR, KEY);
	input [9:0] SW;
	input [1:0] KEY;
	output [7:0] LEDR;

	wire [3:0] a, b;
	wire [1:0] f;
	wire [7:0] out;

	assign a = SW[7:4];
	assign b = SW[3:0];
	assign f = ~KEY[1:0]; //when a not pressed = 0
	assign out = LEDR[7:0];
	
	wire [3:0] w1;
	wire [3:0] w2;
	wire [3:0] w3;
	wire [3:0] w4;

	assign w1 = a;
	assign w2 = b;
	assign w3 = LEDR[3:0];
	assign w4 = LEDR[7:4];

	hex H2(w1, HEX2);
	hex H0(w2, HEX0);
	hex H3(w3, HEX3);
	hex H4(w4, HEX4);
	
	part2 U2(a, b, f, out);
endmodule

	