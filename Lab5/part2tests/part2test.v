module part2board (CLOCK_50, SW[9], SW[1:0], HEX0);
	input CLOCK_50;
	input [9:0] SW;
	output [6:0] HEX0;

	wire [3:0]hexWire;
	part2 MAIN(.ClockIn(CLOCK_50), .Reset(SW[9]), .Speed(SW[1:0]), .CounterValue(hexWire));
	hex H0(hexWire, HEX0);
endmodule

module part2 #(parameter CLOCK_FREQUENCY = 50000000)(input ClockIn, input Reset, input [1:0] Speed, output [3:0] CounterValue);
	wire EnableDC;
	RateDivider RD(.ClockIn(ClockIn), .Reset(Reset), .Speed(Speed), .Enable(EnableDC));
	DisplayCounter CD(.Clock(ClockIn), .Reset(Reset), .EnableDC(EnableDC), .CounterValue(CounterValue));
endmodule

module DisplayCounter (input Clock,input Reset,input EnableDC,output [3:0] CounterValue);
	 //4bit
	reg [3:0] CounterRegOut;
	
	always @(posedge EnableDC) begin
		if(Reset) CounterRegOut <= 4'b0000;
		else CounterRegOut <= CounterRegOut + 1;
	end
	assign CounterValue = CounterRegOut;
endmodule
module RateDivider #(parameter CLOCK_FREQUENCY = 500) (input ClockIn, input Reset, input [1:0] Speed, output Enable);
    
    reg [($clog2(4*CLOCK_FREQUENCY)-1):0] N; //#of clock cycles per pulse
    reg [($clog2(4*CLOCK_FREQUENCY)-1):0] Nholder;
	 reg [($clog2(4*CLOCK_FREQUENCY)-1):0] Nprev;
    parameter MAXN = (4*CLOCK_FREQUENCY);
    wire [($clog2(4*CLOCK_FREQUENCY)-1):0] tempStorage0,tempStorage1, tempStorage2, tempStorage3;
    assign tempStorage0 = CLOCK_FREQUENCY/CLOCK_FREQUENCY;
    assign tempStorage1 = CLOCK_FREQUENCY/1;
    assign tempStorage2 = CLOCK_FREQUENCY/0.5;
    assign tempStorage3 = CLOCK_FREQUENCY/0.25;
	
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
 always @(posedge ClockIn, negedge Reset) begin
        if(Reset)
            counter <= {{($clog2(MAXN)){1'b1}}}; 
		//all ones, even the leftmost bits that we dont care about
	else if(Nholder == tempStorage0) //enable always high
		counter <= {($clog2(MAXN)+1){1'b0}};
	else if(counter[$clog2(Nholder)] == 0) 
		counter <= {{($clog2(MAXN)+1){1'b1}}}; 
        else
            counter <= counter - 1;

    end

	always @(*) begin
		if(Reset) begin
			Nholder = N;
			Nprev = N;
		end
		else if(~counter[$clog2(Nholder)]) begin
			Nholder <= N;
			Nprev <= N;
		end
		if(counter[$clog2(Nprev)] == 0) 
			counter = {{{($clog2(MAXN)+1){1'b1}}}};
	end
		
    assign Enable = (counter[$clog2(Nholder)] == 0)?ClockIn:0;  
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
