module drawCoins(
  input clock,
  input resetn,
  input drawCoin_en, //active positive, from pointcounter
  input [31:0] mapMem,//x,y color
  input [15:0] memQout, //from pointcounter, {exist, x, y}
  input map,//MAP1 or MAP2
  output reg [14:0] address,
  output reg drawCoinDone,
  output reg [7:0] oXE,
  output reg [6:0] oYE,
  output reg [8:0] oColour);

  reg [7:0] X;
  reg [6:0] Y;


  reg [2:0] current_state, next_state;
  localparam step1 = 3'b0,
            step2 = 3'd1,
            step3 = 3'd2,
            step4 = 3'd3,
            step5 = 3'd4,
            step6 = 3'd5;
            
  
  always@(*)
  begin: state_table
    case (current_state)
      step1: next_state = step2;
      step2: next_state = step3;
      step3: next_state = step4;
      step4: next_state = step5;
      step5: next_state = step6;
      step6: next_state = step1;

      default next_state = step1;
    endcase
  end


  always @(*)
  begin: do_stuff
        X = {8{1'b0}};
        Y = {7{1'b0}};
        oColour = 9'b100100000;
    if(drawCoin_en) begin
        if(!map)
          address = 5'b0;
        else address = 5'd16; //MAP2's coints
        drawCoinDone = 1'b0;
    case (current_state)
      step1: begin
        X = memQout[14:7];
        Y = memQout[6:0];
        address = address;
      end
      step2: begin
        oXE = X;
        oYE = Y;
        address = address;
      end
      step3: begin
        oXE = X+1;
        oYE = Y;
        address = address;

      end
      step4: begin
        oXE = X;
        oYE = Y+1;
        address = address;

      end
      step5: begin
        oXE = X+1;
        oYE = Y+1;
        if((address == 5'd9 )|(address == 5'd25))begin
      
          if(!map)
            address = 5'b0;
          else address = 5'd16; //MAP2's coints
        end
        else
          address = address+1'b1;
      end
      step6: drawCoinDone = 1'b1;
        
    endcase
    end
  end

  always@(posedge clock)
    begin: state_FFs
        if(!resetn)
            current_state <= step1;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

