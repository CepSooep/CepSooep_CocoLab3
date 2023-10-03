module part1(a, b, c_in, s, c_out);
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


//a -> SW 7-4
//b -> SW 3-0
//cin -> SW 8
// S -> LED 3-0
// cout -> LED 9

module part1test(SW, LEDR);
	input [8:0] SW;
	output [9:0] LEDR;

	wire [3:0] a, b, s;
	assign a = SW[7:4];
	assign b = SW[3:0];
	assign s = LEDR[3:0];
	
	part1 U1(a, b, SW[8], s, LEDR[9]);
endmodule

