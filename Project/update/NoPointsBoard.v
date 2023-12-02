module NoPointsBoard(CLOCK_50, SW, KEY,
				VGA_R, VGA_G, VGA_B,
				VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK);
	
	input CLOCK_50;
	input [9:0] SW; //{9:forward; 8:backwards; 1:0 :turn}
	input [1:0] KEY; //KEY0 reset 
	output [9:0] VGA_R;
	output [9:0] VGA_G;
	output [9:0] VGA_B;
	output VGA_HS;
	output VGA_VS;
	output VGA_BLANK;
	output VGA_SYNC;
	output VGA_CLK;				

wire [7:0] oX;
wire [6:0] oY;
wire [8:0] oColour;
wire oPlot;
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



 main dut(
  .clock(CLOCK_50),
  .resetn(KEY[0]),
  .forward(SW[9]),
  .backward(SW[8]),
  .turn(SW[1:0]),
  .oX(oX),
  .oY(oY),
  .oColour(oColour),
  .oPlot(oPlot),

  //for testing
  .coinErase_en(1'b0) //0 for now
);
	defparam dut.DirCounterValue = 3; //shorter for modelsim
	defparam dut.GLEnableCounterValue = 4; //shorter for modelsim
		
endmodule