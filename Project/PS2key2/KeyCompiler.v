module TopLevel(
    // Inputs
	CLOCK_50,
	KEY[0],

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	
	// Outputs
	HEX0
);

input CLOCK_50;
input KEY[0];

inout PS2_CLK;
inout PS2_DAT;

output HEX0;

wire [7:0] last_data_received;
wire [2:0] dir;
wire [3:0] outDir;

assign outDir = {1'b0, dir};

keyGet keygetter1 (
    .CLOCK_50(CLOCK_50),
    .reset(KEY[0]),
    .PS2_CLK(PS2_CLK),
    .PS2_DAT(PS2_DAT),
    .last_data_received(last_data_received),
    .dir(dir)
);

Hexadecimal_To_Seven_Segment Segment0 (
	// Inputs
	.hex_number			(outDir),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX0)
);



endmodule

module keyGet(
    CLOCK_50,
    reset,
    PS2_CLK,
    PS2_DAT,
    last_data_received,
    dir
);

input               CLOCK_50;
input               reset;

inout               PS2_CLK;
inout               PS2_DAT;

output reg [7:0]    last_data_received;
output reg [2:0]    dir;

wire                ps2_key_data;
wire                ps2_key_pressed;

localparam UPVAL        = 8'b01110011;
localparam DOWNVAL      = 8'b01110010; 
localparam LEFTVAL      = 8'b01101001;
localparam RIGHTVAL     = 8'b01111010;

always @(posedge CLOCK_50)
begin
	if (reset == 1'b0)
		last_data_received <= 8'h00;
        dir <= 3'b000;
	else if (ps2_key_pressed == 1'b1) begin
		last_data_received <= ps2_key_data;
    end 
end

always @(last_data_received)
begin
    if(last_data_received == UPVAL)
    dir <= 3'b001;
    if(last_data_received == DOWNVAL)
    dir <= 3'b010;
    if(last_data_received == LEFTVAL)
    dir <= 3'b011;
    if(last_data_received == RIGHTVAL)
    dir <= 3'b100;
end

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