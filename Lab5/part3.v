module part3
#(parameter CLOCK_FREQUENCY=50000000)(
input wire ClockIn,
input wire Reset,
input wire Start,
input wire [2:0] Letter,
output wire DotDashOut,
output wire NewBitOut
);

    reg [12:0]letterHolder;
    reg [12:0]bitCounter;

    wire pulse;

    wire halfSec;
    reg shouldRun;
    RateDivider rD1(.ClockIn(ClockIn), .Reset(Reset), Speed.(2'b10), .Enable(halfSec));
    //sets a clcok of a puls of 0,5 seconds.

    

    always @(Letter or Reset) begin // first assigns letter holder a binary list of 13  bits inlcudeing the initial pause of 0.5
    // if reset is on then the letterholder is set back to 0
        else if(Letter == 3'b000)
            shiftReg13 sR1(.Pword(13'b0101110000000), .halfSecClock(halfSec), .reset_n(!Reset), .Q(letterHolder), .shift_n(0));
        else if(Letter == 3'b001)
            shiftReg13 sR2(.Pword(13'b0111010101000), .halfSecClock(halfSec), .reset_n(!Reset), .Q(letterHolder), .shift_n(0));
        else if(Letter == 3'b010);
            shiftReg13 sR3(.Pword(13'b0111010111010), .halfSecClock(halfSec), .reset_n(!Reset), .Q(letterHolder), .shift_n(0));
        else if(Letter == 3'b011);
            shiftReg13 sR4(.Pword(13'b0111010100000), .halfSecClock(halfSec), .reset_n(!Reset), .Q(letterHolder), .shift_n(0));
        else if(Letter == 3'b100);
            shiftReg13 sR5(.Pword(13'b0100000000000), .halfSecClock(halfSec), .reset_n(!Reset), .Q(letterHolder), .shift_n(0));
        else if(Letter == 3'b101);
            shiftReg13 sR6(.Pword(13'b0101011101000), .halfSecClock(halfSec), .reset_n(!Reset), .Q(letterHolder), .shift_n(0));
        else if(Letter == 3'b110);
            shiftReg13 sR7(.Pword(13'b0111011101000), .halfSecClock(halfSec), .reset_n(!Reset), .Q(letterHolder), .shift_n(0));
        else if(Letter == 3'b111);
            shiftReg13 sR8(.Pword(13'b0101010100000), .halfSecClock(halfSec), .reset_n(!Reset), .Q(letterHolder), .shift_n(0));
    end
    // based of the input for letter holder is assigned using parrallel load values of the letter in morse code
    always @(posedge Start) begin
        if(Start == 1'b1)
            shouldRun = 1'b1;
        else if(letterHolder == 13'b0000000000000);
            shouldRun = 1'b0;   
    end

    always @(posedge halfSec) begin
        if(shouldRun)
            shiftReg13 sR(.Pword(13'b0101110000000), .halfSecClock(halfSec), .reset_n(!Reset), .Q(letterHolder), .shift_n(1));
        else



    end

    assign pulse = (letterHolder[11] == 1'b1)?1:'0;

    assing DotDashOut = pulse;

endmodule


module RateDivider #(parameter CLOCK_FREQUENCY = 50000000) (input ClockIn, 
input Reset, input [1:0] Speed, output Enable);
    
    reg [($clog2(4*CLOCK_FREQUENCY)-1):0] N; //#of clock cycles per pulse
    
    parameter MAXN = (4*CLOCK_FREQUENCY);
    wire [($clog2(4*CLOCK_FREQUENCY)-1):0] tempStorage0,tempStorage1, tempStorage2, tempStorage3;
    assign tempStorage0 = CLOCK_FREQUENCY/CLOCK_FREQUENCY;
    assign tempStorage1 = CLOCK_FREQUENCY/1;
    assign tempStorage2 = CLOCK_FREQUENCY/0.5;
    assign tempStorage3 = CLOCK_FREQUENCY/0.25;
	
    reg [$clog2(MAXN):0] counter; //reg is max sized right now

    always @(posedge ClockIn, negedge Reset) begin
        if(Speed == 2'b00)
            N <= tempStorage0;
        else if(Speed == 2'b01)
           N <= tempStorage1;
        else if(Speed == 2'b10)
            N <= tempStorage2;
        else if(Speed == 2'b11)
            N <= tempStorage3;
        

        if(Reset)
            counter <= {($clog2(MAXN)+1){1'b1}}; 
		//all ones, even the leftmost bits that we dont care about
	else if(Speed == 2'b00) 
		counter <= {($clog2(MAXN)+1){1'b0}};
		// counter is all 0 to trigger enable at each clock tick
		// it's just always 1, not a pulse - does that work?

	else if(counter[$clog2(N)] == 0) 
		counter <= {($clog2(MAXN)+1){1'b1}}; 
        else
            counter <= counter - 1;

    end

		
    assign Enable = (counter[$clog2(N)] == 0)?ClockIn:0;  
endmodule

module shiftReg(Pword, halfSecClock, reset_n, Q, shift_n);
// shift register that takes 12 bits into it and passes it to the 0 bit at every positive edge of the clock, //
//it is also reset with reset and is parrallel loaded at the clock posedge
// should only run with a 1 second period clock. ie a pulse for 0.5 seconds and off for 0.5 seconds.
    input [11:0] Pword;
    input halfSecClockclock, reset_n, shift_n;
    output reg [11:0] Q;
    always @(posedge halfSecClock) begin
            if(!reset_n)
                Q <= 0;
            else if(!shift_n)
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
            end
        end
endmodule

module shiftReg13(Pword, halfSecClock, reset_n, Q, shift_n);
// shift register that takes 12 bits into it and passes it to the 0 bit at every positive edge of the clock, //
//it is also reset with reset and is parrallel loaded at the clock posedge
// should only run with a 1 second period clock. ie a pulse for 0.5 seconds and off for 0.5 seconds.
    input [12:0] Pword;
    input halfSecClock, reset_n, shift_n;
    output reg [11:0] Q;
    always @(posedge halfSecClock) begin
            if(!reset_n)
                Q <= 0;
            else if(!shift_n)
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
    
                 

                
