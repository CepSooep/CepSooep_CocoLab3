module TopLevel(
    // Inputs
	CLOCK_50,
	KEY[0],

	// Bidirectionals
	PS2_CLK,
	PS2_DAT,
	
	// Outputs
	HEX0,
	HEX1
);

input CLOCK_50;
input KEY[0];

inout PS2_CLK;
inout PS2_DAT;

output HEX0;
output HEX1;

wire [7:0] last_data_received;
wire [2:0] dir;
wire [3:0] outDir;
wire [2:0] turn;
wire [3:0] outTurn;


assign outDir = {1'b0, dir};
assign outTurn = {1'b0, turn};

keyGet keygetter1 (
    .CLOCK_50(CLOCK_50),
    .reset(KEY[0]),
    .PS2_CLK(PS2_CLK),
    .PS2_DAT(PS2_DAT),
    .last_data_received(last_data_received),
    .forward(dir)
	.turn(turn)
);

Hexadecimal_To_Seven_Segment Segment0 (
	// Inputs
	.hex_number			(outDir),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX0)
);
Hexadecimal_To_Seven_Segment Segment1 (
	// Inputs
	.hex_number			(outTurn),

	// Bidirectional

	// Outputs
	.seven_seg_display	(HEX1)
);



endmodule

module keyGet(
    CLOCK_50,
    reset,
    PS2_CLK,
    PS2_DAT,
    last_data_received,
    forward,
	turn
);

input               CLOCK_50;
input               reset;

inout               PS2_CLK;
inout               PS2_DAT;

output reg [7:0]    last_data_received;
output reg [2:0]   	accel;
output reg [2:0]   	turn;


wire                ps2_key_data;
wire                ps2_key_pressed;

localparam UPVAL        = 8'b01110011;
localparam DOWNVAL      = 8'b01110010; 
localparam LEFTVAL      = 8'b01101001;
localparam RIGHTVAL     = 8'b01111010;
localparam NOVAL		= 8'h00;

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
	case(last_data_received)
	NOVAL:
	begin
		accel <= accel;
		turn <= 2'b00;
	end
	UPVAL:
	begin
		case(accel)
			2'b00:
			begin
				accel <= 2'b01;
			end
			
			2'b01:
			begin
				accel <= 2'b00;
			end
			2'b10:
			begin
				accel <= 2'b01;
			end
		endcase
	end
	DOWNVAL:
	begin
		case(accel)
		2'b00:
		begin
			accel <= 2'b10;
		end

		2'b10:
		begin
			accel <= 2'b00;
		end

		2'b01:
		begin
			accel <= 2'b10;
		end
	end
	LEFTVAL:
		turn <= 2'b01;
	
	RIGHTVAL:
		turn <= 2'b10;
		
	endcase

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