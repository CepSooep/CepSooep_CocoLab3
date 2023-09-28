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



