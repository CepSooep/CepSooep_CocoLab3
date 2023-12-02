module drawEntireScreen(
  input clock, 
  input resetn,
  input [1:0] ScreenSelect, //
  input drawScreenEnable,
  
  input [31:0] QoutMAP1, QoutMAP2, QoutSTART,

  output reg drawScreenDone,
  output reg [7:0] oX,
  output reg [6:0] oY,
  output reg [8:0] oColour,

  output reg [14:0] address,
  output reg oPlot
);
  wire [7:0] Xcounter;
  wire [6:0] Ycounter;
  reg count_en;
  Xcounter X(clock, resetn, count_en, Xcounter);
  Ycounter Y(clock, resetn, count_en, Ycounter);

 localparam   MAP1 = 2'b00,
              MAP2 = 2'b01,
              START = 2'b10,
              GG = 2'b11;

  reg [31:0] Qout;
  always @(*) begin: mux
    case(ScreenSelect) 
      MAP1: Qout = QoutMAP1;
      MAP2: Qout = QoutMAP2;
      START: Qout = QoutSTART;
    endcase
  end //mux
  
  always @(posedge clock) begin
      oX = Xcounter;
      oY = Ycounter;
      oColour = Qout[16:8];
    if(drawScreenEnable * (address<15'd19199)) begin
      count_en = 1'b1;
      address = oX + 160*oY;
      oPlot = 1'b1;
      drawScreenDone = 1'b0;
    end
    else if(drawScreenEnable * (address==15'd19199)) begin
      address = 15'b0;
      drawScreenDone = 1'b1;
      oPlot = 1'b0;
    end
    else begin
      address = 15'b0;
      count_en = 1'b0;
      oPlot = 1'b0; //drawscreenenable off
      drawScreenDone = 1'b0;
    end
  end
endmodule

module Xcounter(
    input wire clock,
    input resetn,
    input counter_en,

    output reg [7:0] Q
);
  always @(posedge clock) begin
    if(!resetn | (Q==8'd159) |!counter_en )
      Q <= 8'd0;
    else if (counter_en)
      Q <= Q + 1'b1;
  end
endmodule

module Ycounter(
    input wire clock,
    input resetn,
    input counter_en,

    output reg [6:0] count_out
);

reg [7:0] counter; //to 159

always @(posedge clock) begin
    if(!resetn | (count_out == 7'd120) |!counter_en) begin
      counter <= 0;
      count_out <= 0;
    end
    else if ((counter == 8'd159)&counter_en) begin
        counter <= 0;
        if (count_out <= 7'd119)
            count_out <= count_out + 1;
    end 
    else if(counter_en) begin
        counter <= counter + 1;
    end
end

endmodule

