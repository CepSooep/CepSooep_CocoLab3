module combined(
	input CLOCK_50,
	input [3:0] KEY, //KEY0 reset KEY1 for endgame
	input [24:24]GPIO_0,
// 	input				AUD_ADCDAT,
// 	inout				AUD_BCLK,
// inout				AUD_ADCLRCK,
// inout				AUD_DACLRCK,
// inout				FPGA_I2C_SDAT,


// output				AUD_XCK,
// output				AUD_DACDAT,
// output				FPGA_I2C_SCLK,
output [24:18]GPIO_1,
  
inout PS2_CLK,
inout PS2_DAT,

output [6:0] HEX0,
// output HEX1;
	output [9:0] VGA_R,
	output [9:0] VGA_G,
	output [9:0] VGA_B,
	output VGA_HS,
	output VGA_VS,
	output VGA_BLANK,
	output VGA_SYNC,
	output VGA_CLK	
)
wire [1:0] accel;  //forward 10 back 01 00 stop
wire forward, backward;
assign forward = accel[1];
assign backward = accel[0];

// DE1_SoC_Audio_Example AUDIO(

// .CLOCK_50(CLOCK_50),
// .KEY(4'b0000),
// .SW(4'b0000),
// .AUD_ADCDAT(AUD_ADCDAT),

// // Bidirectionals
// .AUD_BCLK(AUD_BCLK),
// .AUD_ADCLRCK(AUD_ADCLRCK),
// .AUD_DACLRCK(AUD_DACLRCK),
// .FPGA_I2C_SDAT(FPGA_I2C_SDAT),

// // Outputs
// .AUD_XCK(AUD_XCK),
// .AUD_DACDAT(AUD_DACDAT),
// .FPGA_I2C_SCLK(FPGA_I2C_SCLK),
// );

wire [1:0] turn; //00 no turn, 01 or 10 for some turn
wire [1:0] cocoTurn; //turn left=00, right= 01 straight = 11 
assign cocoTurn = ~turn; //bitwise not i think
tester ACCELEROMETER
(
	2'b11,
   GPIO_0,
	GPIO_1,
	CLOCK_50,
	HEX0,
	turn
)
// put the pins you need for the DE1 Soc

TopLevel Keyboard(
    // Inputs
	CLOCK_50,
	KEY,//for reset
	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	// Outputs
	accel
);

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

 main AnimationStuff(
  .clock(CLOCK_50),
  .resetn(KEY[0]),
	.endGame(KEY[1]),
  .forward(forward),
  .backward(backward),
  .turn(cocoTurn), //turn left=00, right= 01 straight = 11 
  .oX(oX),
  .oY(oY),
  .oColour(oColour),
  .oPlot(oPlot),
  //for testing
  .coinErase_en(1'b0) //0 for now
);

		
endmodule

