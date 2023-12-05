
module PS2WithBreakPt (
	// Inputs
	CLOCK_50,
	reset,

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	
	// Outputs
	HEX1,
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
input			reset;

// Bidirectionals
inout				PS2_CLK;
inout				PS2_DAT;

// Outputs
output		[6:0]	HEX1;
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

localparam FORWARD 	= 8'b01110011;
localparam BACKWARDS 	= 8'b01110010;
localparam BREAK	= 8'b11110000;

reg breaker;

reg [3:0] state;
/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

	always @(posedge CLOCK_50)
begin
	case(state)
		4'b0000: begin
			if(ps2_key_pressed) begin
				if(ps2_key_data == FORWARD)begin
					accel <= 2'b10;
					state <= 4'b0001
				end
				else if(ps2_key_data == BACKWARDS) begin
					accel <= 2'b01;
					state <= 4'b0001
				end
			end
			else begin 
				state <= 4'b0000;
			end
		end
		4'b0001: begin
			if (ps2_key_data == BREAK) begin
				state <= 4'b0010;
			end	
		end
		4'b0010: begin
			if (ps2_key_pressed) begin
				accel <= 2'b00;
				state <= 4'b0010;
			end
			else begin
				state <= 4'b0000;
			end 
		end
		default: begin
			state <= 4'b0000;
			accel <= 4'b0000;
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
	.reset				(~reset),

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
	.seven_seg_display	(HEX1)
);


endmodule
