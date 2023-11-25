module animationControl(
    input clk,
    input resetn,

    input button1,
    input button2,
    input [19:0] FDcounter, //0.2s
    input coinErase_en,
    input won,
    input timesUp,
    input MapSelect, // 0 is MAP1

    output reg drawScreenDone, drawCoinDone, drawCarDone, eraseCarDone,
    output reg frameDelay_en,
    output reg drawScreenEnable, drawCoinEnable, drawCarEnable, eraseCarEnable,
    output reg [1:0] ScreenSelect,
    output reg [5:0] current_state

    );
  reg [5:0] next_state;
  
  localparam  
              stepS     = 6'd9, //button pessed
              step1       = 6'd1, //draw map    
              step1wait   =6'd10, //wait for drawscrene done to go down        
              step2       = 6'd2, //draw coins
              step3       = 6'd3, //draw car
              step4       = 6'd4, //framedelay
              step5       = 6'd5, //erase car?
              stepE       = 6'd7, //erase car
              stepGG      = 6'd8; //endgame

    // Next state logic aka our state table
  always@(*)
  begin: state_table
    case (current_state)
      //stepS1: next_state = (button1 | button2)? stepS2: stepS1;
      stepS: next_state = (drawScreenDone)? step1: stepS;
      step1 : next_state = (!drawScreenDone)? step1wait: step1;
      step1wait: next_state = (drawScreenDone)? step2 : step1wait;
      step2 : next_state = (drawCoinDone)? step3 : step2;
      step3 : next_state = (drawCarDone)? step4: step3;
      step4 : next_state = (won | timesUp) ? stepGG : ((FDcounter == {20{1'b1}})? step5 : step4);
      step5 : next_state = (eraseCarDone)? ((coinErase_en)? stepE:step4): step5;
      stepGG : next_state = (button1 | button2)? stepS: stepGG;
                
      default:     next_state = stepS;
        endcase
    end // state_table

 //for draw screen
 localparam   MAP1 = 2'd0,
              MAP2 = 2'd1,
              START = 2'd2,
              GG = 2'd3;

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
    case (current_state)
      stepS: begin
        ScreenSelect = START;
        drawScreenEnable = 1'b1;
      end
      step1: begin
        ScreenSelect = MapSelect;
        drawScreenEnable = 1'b1;
      end
      step1wait :begin
      end
      step2 : begin
        drawCoinEnable = 1'b1;
      end
      step3 : begin
        drawCarEnable = 1'b1;
      end
      step4: begin
        frameDelay_en = 1'b1;
      end
      step5: begin
        eraseCarEnable = 1'b1;
      end
      stepE: begin
      end
      stepGG: begin
        ScreenSelect = GG;
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




  
