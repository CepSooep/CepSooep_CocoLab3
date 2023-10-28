module part3 #(parameter CLOCK_FREQUENCY=500)(
    input wire ClockIn,
    input wire Reset,
    input wire Start,
    input wire [2:0] Letter,
    output wire DotDashOut,
    output wire NewBitfOut
);
    reg [12:0]letterHolder;
    reg shift;
    reg bitChange;
    wire [12:0]letterReader;
    wire [12:0]newBitStore;
    wire halfClock;
    wire NewBitPeriodic; //pulses every 0.25s

    RateDivider cockSpliter(ClockIn, Reset, 2'b01, halfClock);
    shiftReg shifter(letterHolder, halfClock, Reset, letterReader, Start);
    
    always@(Letter)begin
        if(Letter == 3'b000)
            letterHolder = 13'b0101110000000;
        else if(Letter == 3'b001)
            letterHolder = 13'b0111010101000;
        else if(Letter == 3'b010)
            letterHolder = 13'b0111010111010;
        else if(Letter == 3'b011)
            letterHolder = 13'b0111010100000;
        else if(Letter == 3'b100)
            letterHolder = 13'b0100000000000;
        else if(Letter == 3'b101)
            letterHolder = 13'b0101011101000;
        else if(Letter == 3'b110)
            letterHolder = 13'b0111011101000;
        else if(Letter == 3'b111)
            letterHolder = 13'b0101010100000;
    end
    
    RateDivider newBitSpitter(ClockIn, Reset, 2'b10, NewBitPeriodic); 
    //idk if reset supposed to work in same way as cockSpliter
    //output pulses every 0.25s


    assign DotDashOut = letterReader[12];

endmodule
                 
module shiftReg(Pword, halfSecClock, reset_n, Q, shift);
// shift register that takes 12 bits into it and passes it to the 0 bit at every positive edge of the clock, //
//it is also reset with reset and is parrallel loaded at the clock posedge
// should only run with a 1 second period clock. ie a pulse for 0.5 seconds and off for 0.5 seconds.
    input [12:0] Pword;
    input halfSecClock, reset_n, shift;
    output reg [12:0] Q;
    always @(posedge halfSecClock) begin
            if(reset_n)
                Q <= 0;
            else if(shift)
                Q <= Pword;
            else begin
                Q[0] <= 1'b0;
                Q[1] <= Q[0];
                Q[2] <= Q[1];
                Q[3] <= Q[2];
                Q[4] <= Q[3];
                Q[5] <= Q[4];
                Q[6] <= Q[5];
                Q[7] <= Q[6];
                Q[8] <= Q[7];
                Q[9] <= Q[8];
                Q[10] <= Q[9];
                Q[11] <= Q[10];
                Q[12] <= Q[11];
            end
        end
endmodule



module RateDivider #(parameter CLOCK_FREQUENCY = 500) (input ClockIn, input Reset, input [1:0] Speed, output Enable);

    parameter MAXN = (4*CLOCK_FREQUENCY);
	
    reg [$clog2(MAXN):0] counter; //reg is max sized right now

  
reg [($clog2(4*CLOCK_FREQUENCY)-1):0] c;

always @(*) begin //unused
	if (Speed == 2'b00) c <= 1/CLOCK_FREQUENCY;
	if (Speed == 2'b01) c <= 1/2;
	if (Speed == 2'b10) c <= 2;
	if (Speed == 2'b11) c <= 4;
end
wire [$clog2(MAXN):0] cnew;
assign cnew = (speed == 2b'01)?CLOCK_FREQUENCY/2-1 : CLOCK_FREQUENCY/4;
//if speed == 01, tick every 0.5s
//if speed != 01, tick every 0.25s



always @(posedge ClockIn) begin
        if(Reset) begin
            	counter <= {cnew};//c is reg 
		
	
	end


	else if(counter == 0)
		counter <= {cnew}; 
        
	else
            counter <= counter - 1;

end
    assign Enable = (counter != 0)?0:1;  
endmodule
                
