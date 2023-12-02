module eraseCoin(
  input clock,
  input resetn,
  input coinErase_en, //active positive, from pointcounter
  //input [31:0] mapMem,//x,y color
  input [1:0] ScreenSelect,
  input [31:0] QoutMAP1, QoutMAP2, QoutSTART,
  input [15:0] memQout, //from pointcounter, {exist, x, y}
  output reg [14:0] address,//from Map mem
  output reg [7:0] oXE,
  output reg [6:0] oYE,
  output reg [8:0] oColourE,
  output reg eraseCoinDone,
  output reg oPlot);

  reg [7:0] X;
  reg [6:0] Y;
  reg [31:0] mapMem;

    localparam MAP1 = 2'd0,
          MAP2 = 2'd1,
          START = 2'd2;

  always @(*) begin: mux
    case(ScreenSelect) 
      MAP1: mapMem = QoutMAP1;
      MAP2: mapMem = QoutMAP2;
      START: mapMem = QoutSTART;
    endcase
  end //mux

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
        address = (15'd19200 + 160*Y + X);
        oColourE = mapMem[16:8];
        eraseCoinDone = 1'b0;
        oPlot = 1'b0;
    if(coinErase_en) begin
    case (current_state)
      step1: begin
        X = memQout[14:7];
        Y = memQout[6:0];
        address = (15'd19200 + 160*Y + X);//i really dont know how to make this 15 bits
      end
      step2: begin
        oXE = X;
        oYE = Y;
        address = (15'd19200 + 160*Y + X+1);//for 2nd pixel
        oColourE = mapMem[16:8]; //the colors for 1st pixel
        oPlot = 1'b1;
      end
      step3: begin
        oXE = X+1;
        oYE = Y;
        address = (15'd19200 + 160*(Y+1) + X);//for 3nd pixel
        oColourE = mapMem[16:8]; //the colors for 1st pixel
        oPlot = 1'b1;
      end
      step4: begin
        oXE = X;
        oYE = Y+1;
        address = (15'd19200 + 160*(Y+1) + X+1);//for 4nd pixel
        oColourE = mapMem[16:8]; //the colors for 1st pixel
        oPlot = 1'b1;
      end
      step5: begin
        oXE = X+1;
        oYE = Y+1;
        oColourE = mapMem[16:8]; //the colors for 1st pixel
        oPlot = 1'b1;
        
      end
      step6:  begin
        eraseCoinDone = 1'b1;
        oPlot = 1'b0;
      end
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

