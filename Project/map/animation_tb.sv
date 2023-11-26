`timescale 1ns / 1ps
module animation_tb();

logic clock;
logic resetn;
logic [7:0] nextX;
logic [6:0] nextY;
logic [2:0] dir;
logic coinErase_en;
logic [15:0] memQoutPC; //from pointcounter
logic won;
logic timesUp;
logic forward;
logic backward;
logic [31:0] QoutMAP1;
logic [31:0] QoutMAP2;
logic [31:0] QoutSTART;
logic ldXY;
logic [7:0] oX;
logic [6:0] oY;
logic [8:0] oColour;
logic oPlot;
//integer in;

//As promised, this simulates a 50 MHz clock.
always #1 clock <= ~clock;

animation U1( 
    .clock(clock),
    .resetn(resetn),
    .nextX(nextX),
    .nextY(nextY),
    .dir(dir),
    .coinErase_en(coinErase_en),
    .memQoutPC(memQoutPC), //from pointcounter
    .won(won),
    .timesUp(timesUp),
    .button1(forward), 
    .button2(backward),
    .QoutMAP1(QoutMAP1), 
    .QoutMAP2(QoutMAP2), 
    .QoutSTART(QoutSTART),
    .ldXY(ldXY),

    .oX(oX),
    .oY(oY),
    .oColour(oColour),
    .oPlot(oPlot)
  );

initial begin 
	clock = 1;
	nextX = 2;
	nextY = 2;
	dir = 0;
	coinErase_en = 0;
	memQoutPC = 88;
	won = 0;
	timesUp = 0;
	forward = 1;
	backward = 0;
	ldXY =1;
	memQoutPC=0;
	QoutMAP1 = 0;
	for(int i = 0; i < 4; i = i+1) begin
		#2
		ldXY=0;
		nextX = nextX + 1;
		nextY = nextY + 1;
		QoutMAP1 = QoutMAP1 + 81;
		#2
		ldXY=1;
	end
end
	
endmodule
