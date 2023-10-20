module toggleff( clk, reset_p, T, Q);
	input clk, reset_p, T;
	output reg Q;
	
	always @ (posedge clk) begin
		if (reset_p)
			Q <= 1'b0;
		else if (~T)
			Q <= Q;
		else 
			Q <= ~Q;
	end
endmodule

module part1 (
input Clock,
input Enable,
input Reset,
output [7:0] CounterValue);

toggleff T0(Clock, Reset, Enable, CounterValue[0]);
toggleff T1(Clock, Reset, &CounterValue[0]&Enable, CounterValue[1]);
toggleff T2(Clock, Reset, &CounterValue[1:0]&Enable, CounterValue[2]);
toggleff T3(Clock, Reset, &CounterValue[2:0]&Enable, CounterValue[3]);
toggleff T4(Clock, Reset, &CounterValue[3:0]&Enable, CounterValue[4]);
toggleff T5(Clock, Reset, &CounterValue[4:0]&Enable, CounterValue[5]);
toggleff T6(Clock, Reset, &CounterValue[5:0]&Enable, CounterValue[6]);
toggleff T7(Clock, Reset, &CounterValue[6:0]&Enable, CounterValue[7]);

endmodule

module part1board(KEY, SW, LEDR, HEX1, HEX0);
	input KEY;
	input [1:0] SW;
	output [7:0] LEDR;
	output [6:0] HEX1, HEX0;

	part1 U1(.Clock(KEY), .Enable(SW[0]), .Reset(SW[1]), .CounterValue(LEDR));
	hex H0(LEDR[3:0], HEX0);
	hex H1(LEDR[7:4], HEX1);
endmodule;




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
