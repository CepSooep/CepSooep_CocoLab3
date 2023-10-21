module RateDivider #(parameter CLOCK_FREQUENCY = 50000000) (input ClockIn, input Reset, input [1:0] Speed, output Enable);
    reg N;
    wire [3:0]tempStorage;
    assign tempStorage[0] = CLOCK_FREQUENCY/CLOCK_FREQUENCY;
    assign tempStorage[1] = CLOCK_FREQUENCY/1;
    assign tempStorage[2] = CLOCK_FREQUENCY/0.5;
    assing tempStorage[3] = CLOCK_FREQUENCY/0.25;

    always @(posedge ClockIn, posedge Reset) begin
        if(Speed == 2'b00)
            N = tempStorage[0]
        else if(Speed == 2'b01)
           N = tempStorage[1]
        else if(Speed == 2'b10)
            N = tempStorage[2];
        else if(Speed == 2'b11)
            N = tempStorage[3];
        
        
        output reg [$clog2(N):0] counter;
        counter

        if(Reset)
            counter <= $clog2(N)'b1;
        else
            counter <= counter - 1;

    end
    assign Enable = (counter[$clog2(N)] == 1'b0)?'1:0;  

    end
    
