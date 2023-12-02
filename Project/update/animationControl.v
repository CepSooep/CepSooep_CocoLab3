module animationControl(
    input clk,
    input resetn,

    input button1,
    input button2,
    input [19:0] FDcounter, 
    input coinErase_en,
    input won,
    input timesUp,
    input [1:0] MapSelect, // 0 is MAP1

    input drawScreenDone, drawCoinDone, drawCarDone, eraseCarDone, eraseCoinDone,
    output reg frameDelay_en,
    output reg drawScreenEnable, drawCoinEnable, drawCarEnable, eraseCarEnable,
    output reg [1:0] ScreenSelect,
    output reg [5:0] current_state,
    output reg [5:0] next_state,
    output reg ldXY
    );
  //reg [5:0] next_state;
  
  localparam  
              stepS     = 6'd9, //draw start screen
              stepSwait = 6'd11, //wait for button press
              stepSwait2 = 6'd12, //wait for button release
              step1       = 6'd1, //draw map    
              step1wait   =6'd10, //wait for drawscrene done to go down        
              step2       = 6'd2, //draw coins
              step3       = 6'd3, //draw car
              step4       = 6'd4, //framedelay
              step5       = 6'd5, //erase car?
              stepE       = 6'd7, //erase coin
              stepGG      = 6'd8; //endgame

    // Next state logic aka our state table
  always@(*)
  begin: state_table
    case (current_state)
      stepS: next_state = (drawScreenDone & resetn)? stepSwait : stepS; //reset released
      stepSwait: next_state = (button1|button2)? stepSwait2: stepSwait;
      stepSwait2: next_state = (~button1 & ~button2)? step1: stepSwait2;
      step1 : next_state = (!drawScreenDone)? step1wait: step1;
      step1wait: next_state = (drawScreenDone)? step2 : step1wait;
      step2 : next_state = (drawCoinDone)? step3 : step2;
      step3 : next_state = (won | timesUp) ? stepGG : (drawCarDone)? step4 : step3;
      step4 : next_state = (FDcounter == {20{1'b1}})? step5 : step4;
      step5 : next_state = (eraseCarDone)? ((coinErase_en)? stepE:step3): step5;
      stepE : next_state = (eraseCoinDone)? step3 : stepE;
      stepGG : next_state = (button1 | button2)? stepS: stepGG;
                
      default:     next_state = stepS;
        endcase
    end // state_table

 //for draw screen
 localparam   MAP1 = 2'b00,
              MAP2 = 2'b01,
              START = 2'b10,
              GG = 2'b11;

    // Output logic aka all of our datapath control signals
  always @(*)
  begin: enable_signals
        // By default make all our signals 0
        drawScreenEnable = 1'b0;
        ScreenSelect = START;
        drawCoinEnable = 1'b0;
        drawCarEnable = 1'b0;
        frameDelay_en = 1'b0;
        eraseCarEnable = 1'b0;
        ldXY = 1'b0;
    case (current_state)
      stepS: begin
        ScreenSelect = START;
        if(!resetn) drawScreenEnable = 1'b0;
        else drawScreenEnable = 1'b1;

      end
      //stepSwait is all default?
      //stepSwait2 all default?
      step1: begin
        ScreenSelect = MapSelect;
        drawScreenEnable = 1'b1;
      end
      step1wait :begin
        ScreenSelect = MapSelect;
        drawScreenEnable = 1'b1;
        
      end
      step2 : begin
        ScreenSelect = MapSelect;
        drawCoinEnable = 1'b1;
      end
      step3 : begin
        ldXY = 1'b1;
        drawCarEnable = 1'b1;
        ScreenSelect = MapSelect;
      end
      step4: begin
        frameDelay_en = 1'b1;
        ScreenSelect = MapSelect;
      end
      step5: begin
        eraseCarEnable = 1'b1;
        ScreenSelect = MapSelect;
      end
      stepE: begin
        ScreenSelect = MapSelect;
      end
      stepGG: begin
        ScreenSelect = GG;
        ScreenSelect = MapSelect;
        drawScreenEnable = 1'b1;
      end
    endcase
    end // enable_signals

    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= stepS;
        else
            current_state <= next_state;
    end // state_FFS
endmodule




  
