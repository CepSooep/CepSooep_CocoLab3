module part1(input Clock, input Enable, input Reset, output [7:0] CounterValue);
    reg [7:0] enableWire;
    reg [7:0] counter;
    always@ ( posedge Clock ) begin
        T_FlipFlop tiff1(Clock, Enable, Reset, counter[0]);
        enableWire[0] <= enable & CounterValue[0];

        T_FlipFlop tiff1(Clock, enableWire[0], Reset, counter[1]);
        enableWire[1] <= enableWire[0] & CounterValue[1];

        T_FlipFlop tiff1(Clock, enableWire[1], Reset, counter[2]);
        enableWire[2] <= enableWire[1] & CounterValue[2];

        T_FlipFlop tiff1(Clock, enableWire[2], Reset, counter[3]);
        enableWire[3] <= enableWire[2] & CounterValue[3];

        T_FlipFlop tiff1(Clock, enableWire[3], Reset, counter[4]);
        enableWire[4] <= enableWire[3] & CounterValue[4];

        T_FlipFlop tiff1(Clock, enableWire[4], Reset, counter[5]);
        enableWire[5] <= enableWire[4] & CounterValue[5];

        T_FlipFlop tiff1(Clock, enableWire[5], Reset, counter[6]);
        enableWire[6] <= enableWire[5] & CounterValue[6];

        T_FlipFlop tiff1(Clock, enableWire[6], Reset, counter[7]);
        enableWire[7] <= enableWire[6] & CounterValue[7];
    end
    assign CounterValue = counter;

endmodule

module D_flip_flop (
    input wire clk ,
    input wire reset_b ,
    input wire d ,
    output reg q
    ) ;
    always@ ( posedge clk )
    begin
        if ( reset_b ) q <= 1 ’ b0 ;
        else q <= d ;
    end
endmodule


module T_FlipFlop(input Clock, input Enable, input Reset, output CounterValue);
    reg t_output;
    reg t_input;

    always@ ( posedge clk )
    begin
        t_input <= t_output ^ Enable;
        D_flip_flop DFF1(.clk(Clock), .reset_b(Reset), .d(t_input), .q(t_output));
    end
    assign CounterValue = t_output;
endmodule