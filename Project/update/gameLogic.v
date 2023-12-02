module gameLogic(
  input resetn,
  input clock,
  input [1:0]go,//stop = 00 forward = 11 backwards = 10
  input [2:0]dir,
  input [7:0]currentX,
  input [6:0]currentY,
  input enableGL, //connected to step5(so capture the currentx and y at stepE or step3)
  output reg [7:0] nextx,
  output reg [6:0] nexty,
  output reg changeREGs //to change current to next
  );

  reg [1:0] current_state, next_state;
  localparam step1 = 2'd0,
            stepWait = 2'd1,
            stepChange = 2'd2;

  always @ (*) begin //state table
    case(current_state)
      step1: next_state = (enableGL) ? stepWait : step1; //reset released?
      stepWait: next_state = ~enableGL ? stepChange : stepWait;
      stepChange: next_state = step1;
      default: next_state = step1;
    endcase
  end

  always @ (posedge clock) begin //state FFs
    if(!resetn) current_state <= step1;
    else current_state <= next_state;
  end

  parameter XMAX = 160; // cant be >= 160
  parameter YMAX = 120; //cnat be >= 120
  always@(*) begin//do stuff?
  if(!resetn) begin
    nextx <= 8'd0;
    nexty <= 7'd0;
    changeREGs <= 1'b0;
  end
  else begin
  case(current_state)
    step1: begin
      nextx <= nextx;
      nexty <= nexty;
      changeREGs <= 1'b0;
    end
    stepWait: begin
      nextx <= nextx;
      nexty <= nexty;
      changeREGs <= 1'b0;
    end
    stepChange: begin
      changeREGs <= 1'b1;
      if(go == 2'b00) begin //stop
        nextx <= currentX;
        nexty <= currentY;     
      end

      case(dir) 
        3'd0: begin //horizontal
          if(go == 2'b11) begin
            if(currentX + 1 >= XMAX) nextx <= 8'd0;
            else nextx <= currentX + 1;

            nexty <= currentY;
          end 
          else if(go == 2'b10) begin
            if(currentX - 1 >= XMAX) nextx <= 8'd159; //ie 0 - 1 = 255
            else nextx <= currentX - 1;

            nexty <= currentY;
          end 
        end
        3'd1: begin  
          if(go == 2'b11) begin
            if(currentX + 1 >= XMAX) nextx <= 8'd0;
            else nextx <= currentX + 1;

            if(currentY - 1 >= YMAX) nexty <= 7'd119;
            else nexty <= currentY - 1;
          end 
          else if(go == 2'b10) begin
            if(currentX - 1 >= XMAX) nextx <= 8'd159; //ie 0 - 1 = 255
            else nextx <= currentX - 1;

            if(currentY + 1 >= YMAX) nexty <= 7'd0;
            else nexty <= currentY + 1;
          end 
        end
        3'd2: begin //vertical
          if(go == 2'b11) begin
            nextx <= currentX;

            if(currentY + 1 >= YMAX) nexty <= 7'd0;
            else nexty <= currentY + 1;
          end 
          else if(go == 2'b10) begin
            nextx <= currentX;

            if(currentY - 1 >= YMAX) nexty <= 7'd119;
            else nexty <= currentY - 1;
          end 
        end
        3'd3: begin //diag
          if(go == 2'b11) begin
            if(currentX - 1 >= XMAX) nextx <= 8'd159; //ie 0 - 1 = 255
            else nextx <= currentX - 1;

            if(currentY - 1 >= YMAX) nexty <= 7'd119;
            else nexty <= currentY - 1;
          end 
          else if(go == 2'b10) begin
            if(currentX + 1 >= XMAX) nextx <= 8'd0;
            else nextx <= currentX + 1;

            if(currentY + 1 >= YMAX) nexty <= 7'd0;
            else nexty <= currentY + 1;
          end 
        end
        3'd4: begin //horizontal
            if(go == 2'b11) begin
            if(currentX - 1 >= XMAX) nextx <= 8'd159; //ie 0 - 1 = 255
            else nextx <= currentX - 1;

            nexty <= currentY;
          end 
          else if(go == 2'b10) begin
            if(currentX - 1 >= XMAX) nextx <= 8'd159; //ie 0 - 1 = 255
            else nextx <= currentX - 1;

            nexty <= currentY;
        end
        end
        3'd5: begin
          if(go == 2'b11) begin
            if(currentX - 1 >= XMAX) nextx <= 8'd159; //ie 0 - 1 = 255
            else nextx <= currentX - 1;

            if(currentY + 1 >= YMAX) nexty <= 7'd0;
            else nexty <= currentY + 1;
          end
          else if(go == 2'b10) begin
            if(currentX + 1 >= XMAX) nextx <= 8'd0;
            else nextx <= currentX + 1;

            if(currentY - 1 >= YMAX) nexty <= 7'd119;
            else nexty <= currentY - 1;
          end 
        end
        
        3'd6: begin //vertical
          if(go == 2'b11) begin
            nextx <= currentX;

            if(currentY - 1 >= YMAX) nexty <= 7'd119;
            else nexty <= currentY - 1;
          end
          else if(go == 2'b10) begin
            nextx <= currentX;

            if(currentY + 1 >= YMAX) nexty <= 7'd0;
            else nexty <= currentY + 1;
          end 
        end

        3'd7: begin
        if(go == 2'b11) begin
            if(currentX + 1 >= XMAX) nextx <= 8'd0;
            else nextx <= currentX + 1;

            if(currentY + 1 >= YMAX) nexty <= 7'd0;
            else nexty <= currentY + 1;
        end
        else if(go == 2'b10) begin
            if(currentX - 1 >= XMAX) nextx <= 8'd159; //ie 0 - 1 = 255
            else nextx <= currentX - 1;

            if(currentY - 1 >= YMAX) nexty <= 7'd119;
            else nexty <= currentY - 1;
        end

        end
        default begin
          nextx <= 8'b0;
          nexty <= 7'b0;
        end
      endcase
    end
  
  endcase
  end
  end //always


endmodule

//just a counter
module bigcounter( //2^20 counts
    input wire clock,
    input resetn,
    input frameDelay_en,

    output reg [19:0] frameDelayCounter
);
  always @(posedge clock) begin
    if(!resetn ) begin //smaller clock for testing
      frameDelayCounter <= 20'd0;
    end
    else if ((frameDelayCounter == 20'd10000)) frameDelayCounter <= {20{1'b1}};
    else if (frameDelay_en) begin//dont increase Q
      frameDelayCounter <= frameDelayCounter + 1'b1;
    end
  end
endmodule