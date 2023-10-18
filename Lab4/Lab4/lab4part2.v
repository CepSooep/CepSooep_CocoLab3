module four_bit_register (input [7:0] dIn, input clk, input reset, output reg[7:0] qOut); 
    wire [7:0] d;
    wire clkW;
    assign d = dIn; 

    always@ (posedge clk) begin
        if (reset)
            qOut <= 8'b00000000;
        else   
            qOut <= dIn;
    end
endmodule

module part2 (Clock, Reset_b, Data, Function, ALUout);

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
            3: q = {Data, ALUout[3:0]};
            default: q = 8'b00000000;
        endcase
    end

    four_bit_register reg1(.dIn(q), .clk(Clock), .reset(Reset_b), .qOut(ALUout));

endmodule

