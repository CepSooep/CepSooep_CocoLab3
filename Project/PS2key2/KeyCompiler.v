module KeyCompiler (
	// Inputs
	CLOCK_50,
	KEY,

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	
	// Outputs
	accel
);

/***************************
 *                           Parameter Declarations                          *
 ***************************/


/***************************
 *                             Port Declarations                             *
 ***************************/

// Inputs
input				CLOCK_50;
input		[3:0]	KEY;

// Bidirectionals
inout				PS2_CLK;
inout				PS2_DAT;

// Outputs
output wire [1:0] accel;

/***************************
 *                 Internal Wires and Registers Declarations                 *
 ***************************/

// Internal Wires
wire		[7:0]	ps2_key_data;
wire				ps2_key_pressed;

// Internal Registers
reg			[7:0]	last_data_received;

// State Machine Registers

/***************************
 *                         Finite State Machine(s)                           *
 ***************************/


/***************************
 *                             Sequential Logic                              *
 ***************************/
assign accel = (last_data_received == 8'b01110011) ? (2'b10) : (last_data_received == 8'b01110010) ? (2'b01) : (2'b00);
 
 
always @(posedge CLOCK_50)
begin
	if (KEY[0] == 1'b0)
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
	.reset				(~KEY[0]),

	// Bidirectionals
	.PS2_CLK			(PS2_CLK),
 	.PS2_DAT			(PS2_DAT),

	// Outputs
	.received_data		(ps2_key_data),
	.received_data_en	(ps2_key_pressed)
);

Hexadecimal_To_Seven_Segment Segment0 (
	// Inputs
	.hex_number			(accel),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX0)
);


endmodule
