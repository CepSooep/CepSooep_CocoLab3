
module PS2WithBreakPt (
	// Inputs
	CLOCK_50,
	KEY,

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	
	// Outputs
	HEX0,
	accel
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
input				CLOCK_50;
input		[3:0]	KEY;

// Bidirectionals
inout				PS2_CLK;
inout				PS2_DAT;

// Outputs
output		[6:0]	HEX0;
output 	reg [1:0]	accel;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire		[7:0]	ps2_key_data;
wire				ps2_key_pressed;

// Internal Registers
reg			[7:0]	last_data_received;
reg counter;
reg temporary;

// State Machine Registers

localparam FORWARD 		= 8'b01110011;
localparam BACKWARDS 	= 8'b01110010;
localparam BREAK			= 8'b11110000;

reg break;

reg [2:0] state;
/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge CLOCK_50)
begin
	if (KEY[0] == 1'b0) begin
		accel <= 8'h00;
		break <= 1'b0;
	end
	
	
	
	else begin
	
		case (state)
		2'b01: begin
			
		end
		
		2'b10: begin
			if(ps2_key_pressed && break != 1'b1) begin
				if(ps2_key_data == FORWARD)begin
						accel <= 2'b10;
						break <= 1'b0;
				end
				if(ps2_key_data == BACKWARDS) begin
						accel <= 2'b01;
						break <= 1'b0;
				end	
			end
			else if (ps2_key_data == BREAK) begin
				accel <= 2'b00;
				break <= 1'b1;
			end
			state <= 2'b10;
		end
			
	end
end

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/


/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

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
