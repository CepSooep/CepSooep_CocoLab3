module part3(clock, reset, ParallelLoadn, RotateRight, ASRight, Data_IN, Q);
    input clock, reset, ParallelLoadn, RotateRight, ASRight;
    input [3:0] Data_IN;
    output [3:0] Q;

    wire [3:0] qWire;
    reg [3:0] qReg;
    wire rotateLeft;
    assign rotateLeft = ~RotateRight;
    wire [3:0] choosenQ;

    wire [3:0] givenD;

    always@ (posedge clock or posedge reset) begin
        if(reset)
            qReg <= 0;
        else if (ParallelLoadn)
            qReg <= Data_IN;
        else if(!ASRight)begin
            if (rotateLeft) begin
                qReg[3] <= Q[2];
                qReg[2] <= Q[1];
                qReg[1] <= Q[0];
                qReg[0] <= Q[3];
            end
            else begin
                qReg[3] <= Q[0];
                qReg[2] <= Q[3];
                qReg[1] <= Q[2];
                qReg[0] <= Q[1];
            end
        end
        else if(ASRight) begin
            if(!rotateLeft) begin
                qReg[2] <= Q[3];
                qReg[1] <= Q[2];
                qReg[0] <= Q[1];
            end
        end
    end

    assign Q = qReg;
endmodule

            
                




    
