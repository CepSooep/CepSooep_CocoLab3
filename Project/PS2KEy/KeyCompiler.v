
module TopLevel(
    input CLOCK_50;
    input SW[1],
    input SW[0],

    inout PS2_CLK,
	inout PS2_DAT,

    output [6:0] HEX7
);
wire validKey;
wire [1:0] dir;
assign wire [3:0] hexData {2'b00, dir};


KeyCompiler smth(
    .CLOCK_50(CLOCK_50),
    .KEY(SW[1]),
    .EN(SW[0]),
    .PS2_CLK(PS2_CLK),
    .PS2_DAT(PS2_DAT),
    .validKey(validKey),
    .direction(dir)
);


Hexadecimal_To_Seven_Segment Segment0 #(
	// Inputs
	.hex_number			(hexData[3:0]),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX0)
);

endmodule



module KeyCompiler(
    input CLOCK_50;
    input KEY,
    input EN,

    inout PS2_CLK,
	inout PS2_DAT,

    output validKey,
    output [1:0] direction,





)
wire [7:0] last_data_received,
wire ps2_key_pressed,

PS2_outputget(
    .CLOCK_50(CLOCK_50),
    .KEY(KEY),

    .PS2_CLK(PS2_CLK),
    .PS2_DAT(PS2_DAT),

    .last_data_received(last_data_received),
    .ps2_key_pressed(ps2_key_pressed)
);

localparam DISABLE      = 3'b000;
localparam IDLE         = 3'b001;
localparam VALIDKEY     = 3'b010;
localparam UP           = 3'b011;
localparam DOWN         = 3'b100;
localparam LEFT         = 3'b101;
localparam RIGHT        = 3'b110;
localparam UPVAL        = 8'b01110011;
localparam DOWNVAL      = 8'b01110010; 
localparam LEFTVAL      = 8'b01101001;
localparam RIGHTVAL     = 8'b01111010;
reg [2:0] currentState;
reg [2:0] nextState;


always @(posedge CLOCK_50) begin 
    if (KEY[0] == 1'b0)
    begin
        if(EN == 1'b0)
        currentState <= DISABLE;
        else
        currentState <= IDLE;
    end 
    else begin
    currentState <= nextState;
    end
end

always @(*) begin 
    case (currentState)

    DISABLE: begin
        if(EN)
        nextState <= IDLE;
        else
        nextState <= DISABLE;
    end 

    IDLE: begin
        if(EN)begin 
            if(ps2_key_pressed)begin 
                nextState <= VALIDKEY;
            end
            else begin 
                nextState <= IDLE;
            end
        end
        else begin
            nextState <= DISABLE;
        end
    end

    VALIDKEY: begin
        if(last_data_received == UPVAL)begin 
            nextState <= UP;
        end 
        else if(last_data_received == DOWNVAL)begin 
            nextState <= DOWN;
        end 
        else if(last_data_received == LEFTVAL)begin 
            nextState <= LEFT;
        end 
        else if(last_data_received == RIGHTVAL)begin 
            nextState <= RIGHT;
        end 
        else begin
            nextState <= IDLE;
        end
    end

    UP: begin
        outByte <= 2'b00;
        nextState <= IDLE;
    end

    DOWN: begin
        outByte <= 2'b01;
        nextState <= IDLE;
    end

    LEFT: begin
        outByte <= 2'b10;
        nextState <= IDLE;
    end

    RIGHT: begin
        outByte <= 2'b11;
        nextState <= IDLE;
    end

    endcase
end


endmodule





module PS2_outputget (
	// Inputs
	CLOCK_50,
	KEY,

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	
    // Output
    last_data_received.,
    ps2_key_pressed,
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

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/

// Internal Wires
wire		[7:0]	ps2_key_data;
output wire		    ps2_key_pressed;

// Internal Registers
output reg	[7:0]	last_data_received;

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge CLOCK_50)
begin
	if (KEY[0] == 1'b0)
		last_data_received <= 8'h00;
	else if (ps2_key_pressed == 1'b1)
		last_data_received <= ps2_key_data;
end

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

endmodule


/*****************************************************************************
 *                                                                           *
 * Module:       Altera_UP_PS2                                               *
 * Description:                                                              *
 *      This module communicates with the PS2 core.                          *
 *                                                                           *
 *****************************************************************************/

