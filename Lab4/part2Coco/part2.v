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


