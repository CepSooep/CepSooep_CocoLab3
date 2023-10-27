module part3 #(parameter CLOCK_FREQUENCY=50000000)(
    input wire ClockIn,
    input wire Reset,
    input wire Start,
    input wire [2:0] Letter,
    output wire DotDashOut,
    output wire NewBitOut
);
    reg [12:0]letterHolder;
    reg shift;
    reg bitChange;
    wire [12:0]letterReader;
    wire halfClock;

    RateDivider cockSpliter(ClockIn, Reset, //put speed selection for 0.5 seconds//, halfClock);
    shiftReg shifter(letterHolder, Reset, letterReader, Start);
    
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

    assign DotDashOut = letterReader[12];

endmodule
                 
module shiftReg(Pword, halfSecClock, reset_n, Q, shift);
// shift register that takes 12 bits into it and passes it to the 0 bit at every positive edge of the clock, //
//it is also reset with reset and is parrallel loaded at the clock posedge
// should only run with a 1 second period clock. ie a pulse for 0.5 seconds and off for 0.5 seconds.
    input [12:0] Pword;
    input halfSecClock, reset_n, shift_n;
    output reg [12:0] Q;
    always @(posedge halfSecClock) begin
            if(!reset_n)
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

module RateDivider #(parameter CLOCK_FREQUENCY = 50000000) (input ClockIn, input Reset, input [1:0] Speed, output Enable);
    
    reg [($clog2(4*CLOCK_FREQUENCY)-1):0] N; //#of clock cycles per pulse
    reg [($clog2(4*CLOCK_FREQUENCY)-1):0] Nholder;
	 reg [($clog2(4*CLOCK_FREQUENCY)-1):0] Nprev;
    parameter MAXN = (4*CLOCK_FREQUENCY);
    wire [($clog2(4*CLOCK_FREQUENCY)-1):0] tempStorage0,tempStorage1, tempStorage2, tempStorage3;
    assign tempStorage0 = 1;
    assign tempStorage1 = CLOCK_FREQUENCY;
    assign tempStorage2 = CLOCK_FREQUENCY*2;
    assign tempStorage3 = CLOCK_FREQUENCY*4;
	
    reg [$clog2(MAXN):0] counter; //reg is max sized right now

    always @(*) begin
        if(Speed == 2'b00)
            N <= tempStorage0;
        else if(Speed == 2'b01)
           N <= tempStorage1;
        else if(Speed == 2'b10)
            N <= tempStorage2;
        else if(Speed == 2'b11)
            N <= tempStorage3;
    end
	
always @(posedge ClockIn) begin
        
	
	if(Nholder == 1&& ~Reset) begin//enable always high
		counter <= {($clog2(MAXN)+1){1'b0}};

	end
	else if(Reset) begin
            	counter <= {{($clog2(MAXN)){1'b1}}}; 
		//all ones, even the leftmost bits that we dont care about

	end
	else if(~Reset&&((Nholder == 1 &&counter[0] == 0)||
	(Nholder == CLOCK_FREQUENCY&&counter[$clog2(CLOCK_FREQUENCY)] == 0)||
	(Nholder == CLOCK_FREQUENCY*2 &&counter[$clog2(CLOCK_FREQUENCY*2)] == 0)||
	(Nholder == CLOCK_FREQUENCY*4 && counter[$clog2(CLOCK_FREQUENCY*4)] == 0))) begin
		counter <= {{($clog2(MAXN)+1){1'b1}}}; 
	
	end
	else if((Nprev == 1 &&counter[0] == 0)||
	(Nprev == CLOCK_FREQUENCY&&counter[$clog2(CLOCK_FREQUENCY)] == 0)||
	(Nprev == CLOCK_FREQUENCY*2 &&counter[$clog2(CLOCK_FREQUENCY*2)] == 0)||
	(Nprev == CLOCK_FREQUENCY*4 && counter[$clog2(CLOCK_FREQUENCY*4)] == 0)) begin
		counter <= {($clog2(MAXN)+1){1'b1}};
		
	end
        
	else
            counter <= counter - 1;

end


always @(*) begin
		if(Reset) begin
			Nholder <= N;
			Nprev <= N;
		end
		else if((Nholder == 1 &&counter[0] == 0)||
	(Nholder == CLOCK_FREQUENCY&&counter[$clog2(CLOCK_FREQUENCY)] == 0)||
	(Nholder == CLOCK_FREQUENCY*2 &&counter[$clog2(CLOCK_FREQUENCY*2)] == 0)||
	(Nholder == CLOCK_FREQUENCY*4 && counter[$clog2(CLOCK_FREQUENCY*4)] == 0)) begin
			Nholder <= N;
			Nprev <= N;
		end

	end
	
	
    assign Enable = ((Nholder == 1 &&counter[$clog2(1)] == 0)||
	(Nholder == CLOCK_FREQUENCY&&counter[$clog2(CLOCK_FREQUENCY)] == 0)||
	(Nholder == CLOCK_FREQUENCY*2 &&counter[$clog2(CLOCK_FREQUENCY*2)] == 0)||
	(Nholder == CLOCK_FREQUENCY*4 && counter[$clog2(CLOCK_FREQUENCY*4)] == 0))
	?ClockIn:0;  
endmodule
	

                
