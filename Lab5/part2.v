module RateDivider #(parameter CLOCK_FREQUENCY = 50000000) (input ClockIn, input Reset, input [1:0] Speed, output Enable);
    
    reg [($clog2(4*CLOCK_FREQUENCY)-1):0] N; //#of clock cycles per pulse
    
    parameter MAXN = (4*CLOCK_FREQUENCY);
    wire [($clog2(4*CLOCK_FREQUENCY)-1):0] tempStorage0,tempStorage1, tempStorage2, tempStorage3;
    assign tempStorage0 = CLOCK_FREQUENCY/CLOCK_FREQUENCY;
    assign tempStorage1 = CLOCK_FREQUENCY/1;
    assign tempStorage2 = CLOCK_FREQUENCY/0.5;
    assign tempStorage3 = CLOCK_FREQUENCY/0.25;
	
    reg [$clog2(MAXN)-1:0] counter; //reg is max sized right now

    always @(posedge ClockIn, posedge Reset) begin
        if(Speed == 2'b00)
            N = tempStorage0;
        else if(Speed == 2'b01)
           N = tempStorage1;
        else if(Speed == 2'b10)
            N = tempStorage2;
        else if(Speed == 2'b11)
            N = tempStorage3;
        end
        
        
        always @(posedge ClockIn) begin

        if(Reset)
            counter <= {$clog2(MAXN){1'b1}}; 
		//all ones, even the leftmost bits that we dont care about

        else
            counter <= counter - 1;

    end
    assign Enable = (counter == 0)?'1:0;  
endmodule
