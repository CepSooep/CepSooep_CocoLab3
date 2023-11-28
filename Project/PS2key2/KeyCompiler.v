module TopLevel (
	// Inputs
	CLOCK_50,
	reset,

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	outDir
);

/***************************
 *                           Parameter Declarations                          *
 ***************************/


/***************************
 *                             Port Declarations                             *
 ***************************/

// Inputs
input				CLOCK_50;
input				reset;

// Bidirectionals
inout				PS2_CLK;
inout				PS2_DAT;
output 			[3:0] 	outDir;


/***************************
 *                 Internal Wires and Registers Declarations                 *
 ***************************/

// Internal Wires
wire		[7:0]	ps2_key_data;
wire			ps2_key_pressed;


// Internal Registers
reg			[7:0]	last_data_received;

localparam UPVAL        = 8'b01110011;
localparam DOWNVAL      = 8'b01110010; 
localparam LEFTVAL      = 8'b01101001;
localparam RIGHTVAL     = 8'b01111010;

// State Machine Registers

/***************************
 *                         Finite State Machine(s)                           *
 ***************************/
assign outDir = (last_data_received == UPVAL) ? 3'b001 : (last_data_received == DOWNVAL) ? 3'b010 : (last_data_received == LEFTVAL) ? 3'b011 : (last_data_received == RIGHTVAL) ? 3'b100: 3'b00;

/***************************
 *                             Sequential Logic                              *
 ***************************/

always @(posedge CLOCK_50)
begin
	if (reset == 1'b0)
		last_data_received <= 8'h00;
	else if (ps2_key_pressed == 1'b1)
		last_data_received <= ps2_key_data;
end

/***************************
 *                            Combinational Logic                            *
 ***************************/


/***************************
 *                              Internal Modules                             *
 ***************************/

PS2_Controller PS2 (
	// Inputs
	.CLOCK_50				(CLOCK_50),
	.reset				(~reset),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
);

endmodule
