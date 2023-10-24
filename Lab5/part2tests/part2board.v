module part2board (CLOCK_50, SW[9], SW[1:0], HEX0);
	input CLOCK_50;
	input [9:0] SW;
	output [6:0] HEX0;

	wire [3:0]hexWire;
	part2 MAIN(.ClockIn(CLOCK_50), .Reset(SW[9]), .Speed(SW[1:0]), .CounterValue(hexWire));
	hex H0(hexWire, HEX0);
endmodule

module part2 #(parameter CLOCK_FREQUENCY = 500)(input ClockIn, input Reset, input [1:0] Speed, output [3:0] CounterValue);
	wire EnableDC;
	RateDivider RD(.ClockIn(ClockIn), .Reset(Reset), .Speed(Speed), .Enable(EnableDC));
	DisplayCounter CD(.Clock(ClockIn), .Reset(Reset), .EnableDC(EnableDC), .CounterValue(CounterValue));
endmodule

module DisplayCounter (input Clock,input Reset,input EnableDC,output [3:0] CounterValue);
	 //4bit
	reg [3:0] CounterRegOut;
	
	always @(posedge Clock) begin
		if(Reset) CounterRegOut <= 4'b0000;
		else if(EnableDC) CounterRegOut <= CounterRegOut + 1;
		else CounterRegOut <= CounterRegOut;
	end
	assign CounterValue = CounterRegOut;
endmodule
module RateDivider #(parameter CLOCK_FREQUENCY = 500) (input ClockIn, input Reset, input [1:0] Speed, output Enable);
    
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
        if(Reset) begin
            	counter <= {{($clog2(MAXN)){1'b1}}}; 
		//all ones, even the leftmost bits that we dont care about
		Nholder <= N;
		Nprev = N;
	end
	
	else if(Nholder == 1) begin//enable always high
		counter <= {($clog2(MAXN)+1){1'b1}};
		Nholder <= N;
		Nprev <= N;
	end

	else if((Nholder == 1 &&counter[0] == 0)||
	(Nholder == CLOCK_FREQUENCY&&counter[$clog2(CLOCK_FREQUENCY)] == 0)||
	(Nholder == CLOCK_FREQUENCY*2 &&counter[$clog2(CLOCK_FREQUENCY*2)] == 0)||
	(Nholder == CLOCK_FREQUENCY*4 && counter[$clog2(CLOCK_FREQUENCY*4)] == 0)) begin
		counter <= {{($clog2(MAXN)+1){1'b1}}}; 
		Nholder <= N;
		Nprev <= N;
	end
	else if((Nprev == 1 &&counter[0] == 0)||
	(Nprev == CLOCK_FREQUENCY&&counter[$clog2(CLOCK_FREQUENCY)] == 0)||
	(Nprev == CLOCK_FREQUENCY*2 &&counter[$clog2(CLOCK_FREQUENCY*2)] == 0)||
	(Nprev == CLOCK_FREQUENCY*4 && counter[$clog2(CLOCK_FREQUENCY*4)] == 0)) begin
		counter <= {($clog2(MAXN)+1){1'b1}};
		Nholder <= N;
		Nprev <= N;
	end
        
	else
            counter <= counter - 1;

end
    assign Enable = ((Nholder == 1 &&counter[$clog2(1)] == 1)||
	(Nholder == CLOCK_FREQUENCY&&counter[$clog2(CLOCK_FREQUENCY)] == 0)||
	(Nholder == CLOCK_FREQUENCY*2 &&counter[$clog2(CLOCK_FREQUENCY*2)] == 0)||
	(Nholder == CLOCK_FREQUENCY*4 && counter[$clog2(CLOCK_FREQUENCY*4)] == 0))
	?ClockIn:0;  
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
