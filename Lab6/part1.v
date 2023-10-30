module part1board(KEY, SW, LEDR, HEX0);
    input [0:0]KEY;
    input [1:0] SW;
    output [9:0]LEDR;
    output [6:0] HEX0;

    part1 HEHE(.Clock(KEY[0]), .Reset(~KEY[0]), .w[SW[1]), .z(LEDR[9]), .CurState(LEDR[3:0]));
    hex H0(LEDR[3:0], HEX0);
    // to reset: press





module part1 (
input Clock ,
input Reset ,
input w ,
output z ,
output [3:0] CurState
) ;
    reg [3:0] y_Q , Y_D ;
    localparam A =4'd0 , B =4'd1 , C =4'd2 , D =4'd3 , E =4'd4 , F =4'd5 ,
    G =4'd6 ;
// State table
    always@ (*) begin
        case ( y_Q )
            A : begin
                if (! w ) Y_D = A ;
                else Y_D = B ;
            end
            B : begin
                if(! w ) Y_D = A ;
                else Y_D = C
            end
            C : begin
                if(!w) Y_D = E;
                else Y_D = D;
            end
            D : begin
                if(!w) Y_D = E;
                else Y_D = F;
            end
            E : begin
                if(!w) Y_D = A;
                else Y_D = G;
            end
            F : begin 
                if(!w) Y_D = E;
                else Y_D = F;
            end
            G : begin
                if(!w) Y_D = A;
                else Y_D = C; 
            end
            default : Y_D = A;
        endcase
    end // state_table
// State Registers
    always @ ( posedge Clock ) begin
        if ( Reset == 1 ’ b1 )
            y_Q <= A;
        else
            y_Q <= Y_D ;
        end // state flip flops
    assign z = (( y_Q == F ) | ( y_Q == G ) ) ; // Output logic
    assign CurState = y_Q ;
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
