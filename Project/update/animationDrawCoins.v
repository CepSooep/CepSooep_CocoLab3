module drawCoins(
  input clock,
  input resetn,
  input drawCoin_en, //active positive, from pointcounter
  //input [31:0] mapMem,//x,y color
  input [15:0] memQout, //from pointcounter, {exist, x, y}
  input [1:0]map,//MAP1 or MAP2
  output reg [14:0] address,
  output reg drawCoinDone,
  output reg [7:0] oXE,
  output reg [6:0] oYE,
  output reg [8:0] oColour,
  output reg oPlot);

  reg [7:0] X;
  reg [6:0] Y;


  reg [2:0] current_state, next_state;
  localparam step1 = 3'b0, //starting one, never loops
            step2 = 3'd1,
            step3 = 3'd2,
            step4 = 3'd3,
            step5 = 3'd4,
            step6 = 3'd5;
            
  
  always@(*)
  begin: state_table
    case (current_state)

      step1: next_state = (drawCoin_en)?step2:step1;
      step2: next_state = (drawCoin_en)?step3:step1;
      step3: next_state = (drawCoin_en)?step4:step1;
      step4: next_state = (drawCoin_en)?step5:step1;
      step5: next_state = (drawCoin_en)?(((address == 5'd9 )|(address == 5'd25))? step6:step2):step1;
      step6: next_state = step1; //done = 1

      default next_state = step1;
    endcase
  end

 localparam   MAP1 = 2'b00,
              MAP2 = 2'b01,
              START = 2'b10,
              GG = 2'b11;

  always @(*)
  begin: do_stuff
        X = {8{1'b0}};
        Y = {7{1'b0}};
        oColour = 9'b100100000;
        drawCoinDone = 1'b0;
        oPlot = 1'b0;

    if(drawCoin_en) begin
        drawCoinDone = 1'b0;
    case (current_state)
      step1: begin
        X = memQout[14:7];
        Y = memQout[6:0];
        oPlot = 1'b0; //maybe????
        if(!map[0])//MAP1
          address = 5'd9;
        else address = 5'd25; //MAP2's coins
      end
      step2: begin
        if((address == 5'd9 )|(address == 5'd25))begin
          if(!map[0])
            address = 5'b0;
          else address = 5'd16; //MAP2's coints

        end
          else
            address = address+1'b1;
        oXE = X;
        oYE = Y;
        address = address;
        oPlot = 1'b1;
      end
      step3: begin
        oPlot = 1'b1;
        oXE = X+1;
        oYE = Y;
        address = address;

      end
      step4: begin
        oPlot = 1'b1;
        oXE = X;
        oYE = Y+1;
        address = address;

      end
      step5: begin
        oPlot = 1'b1;
        oXE = X+1;
        oYE = Y+1;
        //if((address == 5'd9 )|(address == 5'd25)) drawCoinDone = 1'b1;
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

