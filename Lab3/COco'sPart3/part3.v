module part3(A, B, Function, ALUout);
	parameter N = 4;
	parameter NN = 2*N;
	
	input [N-1:0] A, B;
	input [1:0] Function;
	output reg [NN-1:0] ALUout;

	always@(*)
	begin
		case(Function) //4to1mux
		2'b00: ALUout = A + B; //watch for digit number!!!!
		2'b01: ALUout = (|A) | (|B);
		2'b10: ALUout = (&A) & (&B);
		2'b11: ALUout = {A,B};
		default: ALUout = 8'b00000000;
		endcase
	end
endmodule

module part3tester (A, B, KEY, LEDR);
	input [5:0] A, B;
	input [1:0] KEY;
	output [11:0] LEDR;

	part3 #(6) u0(A, B, KEY, LEDR);
endmodule
