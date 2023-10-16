module part2Board(KEY, SW, LEDR, HEX0, HEX1, HEX4, HEX5);
	input [1:0] KEY;
	input [9:0] SW ;
	output [7:0] LEDR;
	output [6:0] HEX0, HEX1, HEX4, HEX5;

	wire [7:0] mainOut;
	part2 main(KEY[1], ~KEY[0], SW[3:0], SW[9:8], mainOut);
	assign LEDR[7:0] = mainOut;


	hex H0(SW[3:0], HEX0);
	hex H1({0,SW[9:8]}, HEX1);
	hex H4(mainOut[7:4], HEX4);
	hex H3(mainOut[3:0], HEX3);
endmodule

module D_flip_flop (input wire clk, input wire reset_b, input wire d, output reg q) ;
    always@ ( posedge clk )
    begin
        if ( reset_b ) 
            q <= 1'b0;
        else 
            q <= d ;
    end
endmodule

module four_bit_register (input [7:0] dIn, input clk, input reset, output [7:0] qOut); 
    wire [7:0] d;
    wire clkW;
    wire resetW;

    assign d = dIn; 
    assign clkW = clk;
    assign resetW = reset;

    D_flip_flop flip1(clkW, resetW, d[0], qOut[0]);
    D_flip_flop flip2(clkW, resetW, d[1], qOut[1]);
    D_flip_flop flip3(clkW, resetW, d[2], qOut[2]);
    D_flip_flop flip4(clkW, resetW, d[3], qOut[3]);
    D_flip_flop flip5(clkW, resetW, d[4], qOut[4]);
    D_flip_flop flip6(clkW, resetW, d[5], qOut[5]);
    D_flip_flop flip7(clkW, resetW, d[6], qOut[6]);
    D_flip_flop flip8(clkW, resetW, d[7], qOut[7]);

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

module hex(SW, HEX);
	input [3:0] SW;
	output [6:0] HEX;
	hex_decoder H1(SW, HEX);	
endmodule

module part2(Clock, Reset_b, Data, Function, ALUout);

    input [3:0] Data;
    input Clock;
    input Reset_b;
    input [1:0] Function;
    output [7:0] ALUout;

    reg [7:0] q;

    always @(*)
    begin
        case (Function)
            0: q = Data + ALUout[3:0];
            1: q = Data * ALUout[3:0]; 
            2: q = ALUout << Data;  
            3: ;
        endcase
    end

    four_bit_register reg1(.dIn(q), .Clock(Clock), .Reset(Reset_b), .qOut(ALUout));

endmodule
