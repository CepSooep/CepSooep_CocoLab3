module part3(clock, reset, ParallelLoadn, RotateRight, ASRight, Data_IN, Q);
    input clock, reset, ParrallelLoadn, RotateRight, ASRight;
    input [3:0] Data_IN;
    output [3:0] Q;

    wire [3:0] qWire;
    reg [3:0] qReg;
    assign wire rotateLeft = ~RotateRight;
    wire [3:0] choosenQ;

    wire [3:0] givenD;

    always@ (posedge clock, or posedge reset) begin
        if(reset)
            qReg <= 0;
        else if (ParallelLoadn)
            qReg <= Data_IN;
        else begin
            if (rotateLeft) begin
                qReg[3] <= Q[2];
                qReg[2] <= Q[1];
                qReg[1] <= Q[0];
                qReg[0] <= Q[3];
            end
            else begin
                qReg[3] <= Q[0];
                qReg[2] <= Q[3];
                qReg[1] <= Q[2];
                qReg[0] <= Q[1];
            end
        end
    end

    assign Q = qReg;
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

module part3board(KEY, SW, HEX0, HEX4, LEDR);
	input [1:0] KEY;
	input [9:0] SW;
	output [6:0] HEX0, HEX4;
	output [3:0] LEDR;

	part3 U1(KEY[0], KEY[1], SW[9], SW[8], SW[7], SW[3:0], LEDR[3:0]);
	hex H0(SW[3:0], HEX0);
	hex H4(LEDR[3:0], HEX4);
endmodule	


            
                




    
