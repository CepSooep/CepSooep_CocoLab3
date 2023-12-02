module TopLevel (
	// Inputs
	CLOCK_50,
	KEY,

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	
	// Outputs
	HEX0,
	HEX1,
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
output		[6:0]	HEX1;


/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire		[7:0]	ps2_key_data;
wire				ps2_key_pressed;


// Internal Registers
reg			[7:0]	last_data_received;
reg 			[3:0] accel;
reg 			[3:0] turn;

localparam UPVAL        = 8'b01110011;
localparam DOWNVAL      = 8'b01110010; 
localparam LEFTVAL      = 8'b01101001;
localparam RIGHTVAL     = 8'b01111010;

//States

localparam IDLE				= 5'b00000;
localparam STORE				= 5'b00001;
localparam DELETEAR			= 5'b00010;
localparam DELETEREGONE		= 5'b00011;
localparam DELETEREGTWO		= 5'b00100;
localparam WAITAFTREGONE	= 5'b00101;
localparam WAITAFTREGTWO	= 5'b00110;

reg [4:0] currentState;
reg [7:0] keyOne;
reg [7:0] keyTwo;

reg [7:0] keyStore;



// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/
always @(posedge CLOCK_50)
	if(KEY[0] == 1'b1) begin
		currentState <= 5'b00000;
		keyOne <= 8'b00000000;
		keyTwo <= 8'b00000000;
		keyStore <= 8'b00000000;
	end
	else begin
		case(currentState)
			IDLE: begin
				if(ps2_key_pressed) begin
					currentState <= STORE;
				end
				else
					currentState <= IDLE;
			end
			
			STORE: begin
				if(keyOne == 8'b00000000) begin
					keyOne <= ps2_key_data;
				end
				else if (keyTwo == 8'b00000000)begin
					keyTwo <= ps2_key_data;
				end
				
				if(ps2_key_data == 8'b11110000)begin
					currentState <= DELETEAR;
				end
				else begin
					currentState <= STORE;
				end
			
			end
			
			DELETEAR: begin
				if(ps2_key_data == keyOne) begin
					currentState <=  DELETEREGONE;
					keyStore <= ps2_key_data;
				end
				else if (ps2_key_data == keyTwo) begin
					currentState <=  DELETEREGTWO;
					keyStore <= ps2_key_data;
				end
			end
			
			DELETEREGONE: begin
				keyOne <= 8'b00000000;
				currentState <= WAITAFTREGONE;
				
			end
			
			DELETEREGTWO: begin
				keyTwo <= 8'b00000000;
				currentState <= WAITAFTREGTWO;
			end
			
			WAITAFTREGONE: begin
				if(ps2_key_data == keyStore) begin
					currentState <= WAITAFTREGONE;
				end
				else if(ps2_key_data == 8'b11110000) begin
				end
				
			end
			
			WAITAFTREGTWO: begin
			end
		endcase
		
	end
	
	




end

/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/



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

Hexadecimal_To_Seven_Segment Segment1 (
	// Inputs
	.hex_number			(turn),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX1)
);


endmodule
