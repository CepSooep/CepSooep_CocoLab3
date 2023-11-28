module animationBoard(CLOCK_50, SW, KEY,
				VGA_R, VGA_G, VGA_B,
				VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK);
	
	input CLOCK_50;
	input [9:0] SW; //{1'forward,1'backward,3'dir,2'X,2'Y}
	input [1:0] KEY; //KEY0 reset 
	output [9:0] VGA_R;
	output [9:0] VGA_G;
	output [9:0] VGA_B;
	output VGA_HS;
	output VGA_VS;
	output VGA_BLANK;
	output VGA_SYNC;
	output VGA_CLK;				

	vga_adapter VGA(
			.resetn(KEY[0]), //press to reset
			.clock(CLOCK_50),
			.colour(oColour),
			.x(oX),
			.y(oY),
			.plot(oPlot),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK),
			.VGA_SYNC(VGA_SYNC),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 3;
		//defparam VGA.BACKGROUND_IMAGE = "image.colour.mif";

reg [7:0] Xsimple;
reg [6:0] Ysimple;
always @(*) begin //to make switches work
	Xsimple <= (SW[3:2] * 6'd50);
	Ysimple <= (SW[1:0] * 5'd40);
end

wire [7:0] oX, trash8;
wire [6:0] oY, trash7;
wire [8:0] oColour, trash9;
wire trash, oPlot;
wire [5:0] trash6;
wire [14:0] trash15;
 animation dut(
  .clock(CLOCK_50),
  .resetn(KEY[0]),
  .nextX(Xsimple),
  .nextY(Ysimple),
  .dir(SW[6:4]),
  .coinErase_en(1'b0), //not available now
  .memQoutPC({16{1'b0}}), //from pointcounter, not available now
  .won(1'b0),//not available now
  .timesUp(1'b0),//not available now
  .button1(SW[8]), 
	.button2(SW[7]),

  .oX(oX),
  .oY(oY),
  .oColour(oColour),
  .ldXY(trash), //eraseCoin_en
  .oPlot(oPlot),
);
		
endmodule