
module tester
(
    input SW[1],
    input SW[0],
    input GPIO_0[24],
    output GPIO_0[22],
    output GPIO_0[20],
    output GPIO_0[18],
    input CLOCK_50,
    output [6:0] HEX0;
// put the pins you need for the DE1 Soc
    
)
wire outByte;
assign
getDeviceID #
(
.switch(SW[1]),
.clk(CLOCK_50),
.reset(SW[0]),
.SPI_mosi(GPIO_0[22]),
.SPI_miso(GPIO_0[24]),
.SPI_clk(GPIO_0[20]),
.SPI_clk(GPIO_0[18]),
.outByte(outByte)
)

hex_decoder(.c(outByte), .display(HEX0))


endmodule

module hex_decoder(c, display);
	input [7:0] c;
	output [6:0] display;

	wire [6:0] inverted; //I messed up, everything is inverted

	assign inverted[0] = (c == 8'b10101101) ? 1'b0 : 1'b1;
	assign inverted[1] = (c == 8'b10101101) ? 1'b0 : 1'b1;
	assign inverted[2] = (c == 8'b10101101) ? 1'b0 : 1'b1;
	assign inverted[3] = (c == 8'b10101101) ? 1'b0 : 1'b1;
	assign inverted[4] = (c == 8'b10101101) ? 1'b0 : 1'b1;
	assign inverted[5] = (c == 8'b10101101) ? 1'b0 : 1'b1;
	assign inverted[6] = 1'b1;
	
	assign display = inverted;

endmodule


module getDeviceID
(
    input               switch,
    input               clk,
    input               reset,
    input               SPI_miso,
    output              SPI_mosi,
    output reg [7:0]    outByte
    output              SPI_clk,
    output              CS);

    wire num_byte_read;
    wire byte_to_read_rdy;
    wire byte_to_read;
    wire SPI_clk;
    wire CS_n;

    assign wire readCmd     = 8'b00001011;
    assign wire DEVID_AD    = 8'b00000000;


    reg byte_to_send;
    reg byte_to_send_rdy;
    reg ready_for_next;

    
    
    
    SPI_Master_With_Single_CS 
        #(.SPI_MODE(0),
        .CLKS_PER_HALF_BIT(250),
        .MAX_BYTES_PER_CS(5),
        .CS_INACTIVE_CLKS(2))
        // set parameters based on experimentation.

        (.i_Rst_L(~reset),
        .i_Clk(clk),

        
        .i_TX_Byte(byte_to_send),
        .i_TX_DV(byte_to_send_rdy),
        .o_TX_Ready(ready_for_next),

        .i_TX_Count(num_byte_read),
        .o_RX_DV(byte_to_read_rdy),
        .o_RX_Byte(byte_to_read),

        .o_SPI_CLK(SPI_clk),
        .i_SPI_MISO(SPI_miso),
        .o_SPI_MOSI(SPI_mosi),
        .o_SPI_CS_n(CS_n)
    );

    localparam IDLE         = 3'b000;
    localparam STGONE       = 3'b001;
    localparam CMDSEND      = 3'b010;
    localparam WTSTATEONE   = 3'b011;
    localparam ADRSEND      = 3'b100;
    localparam WTSTATETWO   = 3'b101;
    localparam READDTA      = 3'b111;
    reg [2:0] currentState;
    reg [2:0] nextState;

    always @(posedge clk or negedge reset)
    begin
        if (~reset) begin
        currentState <= IDLE;
        nextState <= IDLE;
        end
        else begin
        case (currentState)
        IDLE:
            begin
                if(switch)
                nextState <= CMDSEND;
                else
                nextState <= IDLE;
            end
        CMDSEND:
            begin
                num_byte_read       <= 2'b11;
                byte_to_send        <= readCmd;
                byte_to_send_rdy    <= 1'b1;
                nextState           <= WTSTATEONE;
            end
        WTSTATEONE:
            begin 
                byte_to_send_rdy <= 1'b0;
                if(~ready_for_next)
                nextState <= WTSTATEONE;
                else
                nextState <= ADRSEND;
            end
        ADRSEND:
            begin 
                byte_to_send        <= DEVID_AD;
                byte_to_send_rdy    <= 1'b1;
                nextState           <= READDATA;
            end
        READDATA:
            begin 
                byte_to_send_rdy <= 1'b0;
                if(~byte_to_read_rdy)
                nextState <= READDATA;

                else begin
                outByte <= byte_to_read;
                nextState <= WTSTATETWO;
                end
            end
        WTSTATETWO
            begin 
                if(ready_for_next)
                nextState <= IDLE;
                else
                nextState <= WTSTATETWO;
            end 
        endcase
        end
        

        
    end
    always @(posedge clk)begin
        currentState <= nextState;
    end


endmodule







///////////////////////////////////////////////////////////////////////////////
// Description: SPI (Serial Peripheral Interface) Master
//              With single chip-select (AKA Slave Select) capability
//
//              Supports arbitrary length byte transfers.
// 
//              Instantiates a SPI Master and adds single CS.
//              If multiple CS signals are needed, will need to use different
//              module, OR multiplex the CS from this at a higher level.
//
// Note:        i_Clk must be at least 2x faster than i_SPI_Clk
//
// Parameters:  SPI_MODE, can be 0, 1, 2, or 3.  See above.
//              Can be configured in one of 4 modes:
//              Mode | Clock Polarity (CPOL/CKP) | Clock Phase (CPHA)
//               0   |             0             |        0
//               1   |             0             |        1
//               2   |             1             |        0
//               3   |             1             |        1
//
//              CLKS_PER_HALF_BIT - Sets frequency of o_SPI_Clk.  o_SPI_Clk is
//              derived from i_Clk.  Set to integer number of clocks for each
//              half-bit of SPI data.  E.g. 100 MHz i_Clk, CLKS_PER_HALF_BIT = 2
//              would create o_SPI_CLK of 25 MHz.  Must be >= 2
//
//              MAX_BYTES_PER_CS - Set to the maximum number of bytes that
//              will be sent during a single CS-low pulse.
// 
//              CS_INACTIVE_CLKS - Sets the amount of time in clock cycles to
//              hold the state of Chip-Selct high (inactive) before next 
//              command is allowed on the line.  Useful if chip requires some
//              time when CS is high between trasnfers.
///////////////////////////////////////////////////////////////////////////////

module SPI_Master_With_Single_CS
  #(parameter SPI_MODE = 0,
    parameter CLKS_PER_HALF_BIT = 2,
    parameter MAX_BYTES_PER_CS = 2,
    parameter CS_INACTIVE_CLKS = 1)
  (
   // Control/Data Signals,
   input        i_Rst_L,     // FPGA Reset
   input        i_Clk,       // FPGA Clock
   
   // TX (MOSI) Signals
   input [$clog2(MAX_BYTES_PER_CS+1)-1:0] i_TX_Count,  // # bytes per CS low
   input [7:0]  i_TX_Byte,       // Byte to transmit on MOSI
   input        i_TX_DV,         // Data Valid Pulse with i_TX_Byte
   output       o_TX_Ready,      // Transmit Ready for next byte
   
   // RX (MISO) Signals
   output reg [$clog2(MAX_BYTES_PER_CS+1)-1:0] o_RX_Count,  // Index RX byte
   output       o_RX_DV,     // Data Valid pulse (1 clock cycle)
   output [7:0] o_RX_Byte,   // Byte received on MISO

   // SPI Interface
   output o_SPI_Clk,
   input  i_SPI_MISO,
   output o_SPI_MOSI,
   output o_SPI_CS_n
   );

  localparam IDLE        = 2'b00;
  localparam TRANSFER    = 2'b01;
  localparam CS_INACTIVE = 2'b10;

  reg [1:0] r_SM_CS;
  reg r_CS_n;
  reg [$clog2(CS_INACTIVE_CLKS)-1:0] r_CS_Inactive_Count;
  reg [$clog2(MAX_BYTES_PER_CS+1)-1:0] r_TX_Count;
  wire w_Master_Ready;

  // Instantiate Master
  SPI_Master 
    #(.SPI_MODE(SPI_MODE),
      .CLKS_PER_HALF_BIT(CLKS_PER_HALF_BIT)
      ) SPI_Master_Inst
   (
   // Control/Data Signals,
   .i_Rst_L(i_Rst_L),     // FPGA Reset
   .i_Clk(i_Clk),         // FPGA Clock
   
   // TX (MOSI) Signals
   .i_TX_Byte(i_TX_Byte),         // Byte to transmit
   .i_TX_DV(i_TX_DV),             // Data Valid Pulse 
   .o_TX_Ready(w_Master_Ready),   // Transmit Ready for Byte
   
   // RX (MISO) Signals
   .o_RX_DV(o_RX_DV),       // Data Valid pulse (1 clock cycle)
   .o_RX_Byte(o_RX_Byte),   // Byte received on MISO

   // SPI Interface
   .o_SPI_Clk(o_SPI_Clk),
   .i_SPI_MISO(i_SPI_MISO),
   .o_SPI_MOSI(o_SPI_MOSI)
   );


  // Purpose: Control CS line using State Machine
  always @(posedge i_Clk or negedge i_Rst_L)
  begin
    if (~i_Rst_L)
    begin
      r_SM_CS <= IDLE;
      r_CS_n  <= 1'b1;   // Resets to high
      r_TX_Count <= 0;
      r_CS_Inactive_Count <= CS_INACTIVE_CLKS;
    end
    else
    begin

      case (r_SM_CS)      
      IDLE:
        begin
          if (r_CS_n & i_TX_DV) // Start of transmission
          begin
            r_TX_Count <= i_TX_Count - 1'b1; // Register TX Count
            r_CS_n     <= 1'b0;       // Drive CS low
            r_SM_CS    <= TRANSFER;   // Transfer bytes
          end
        end

      TRANSFER:
        begin
          // Wait until SPI is done transferring do next thing
          if (w_Master_Ready)
          begin
            if (r_TX_Count > 0)
            begin
              if (i_TX_DV)
              begin
                r_TX_Count <= r_TX_Count - 1'b1;
              end
            end
            else
            begin
              r_CS_n  <= 1'b1; // we done, so set CS high
              r_CS_Inactive_Count <= CS_INACTIVE_CLKS;
              r_SM_CS             <= CS_INACTIVE;
            end // else: !if(r_TX_Count > 0)
          end // if (w_Master_Ready)
        end // case: TRANSFER

      CS_INACTIVE:
        begin
          if (r_CS_Inactive_Count > 0)
          begin
            r_CS_Inactive_Count <= r_CS_Inactive_Count - 1'b1;
          end
          else
          begin
            r_SM_CS <= IDLE;
          end
        end

      default:
        begin
          r_CS_n  <= 1'b1; // we done, so set CS high
          r_SM_CS <= IDLE;
        end
      endcase // case (r_SM_CS)
    end
  end // always @ (posedge i_Clk or negedge i_Rst_L)


  // Purpose: Keep track of RX_Count
  always @(posedge i_Clk)
  begin
    begin
      if (r_CS_n)
      begin
        o_RX_Count <= 0;
      end
      else if (o_RX_DV)
      begin
        o_RX_Count <= o_RX_Count + 1'b1;
      end
    end
  end

  assign o_SPI_CS_n = r_CS_n;

  assign o_TX_Ready  = ((r_SM_CS == IDLE) | (r_SM_CS == TRANSFER && w_Master_Ready == 1'b1 && r_TX_Count > 0)) & ~i_TX_DV;

endmodule // SPI_Master_With_Single_CS

///////////////////////////////////////////////////////////////////////////////
// Description: SPI (Serial Peripheral Interface) Master
//              Creates master based on input configuration.
//              Sends a byte one bit at a time on MOSI
//              Will also receive byte data one bit at a time on MISO.
//              Any data on input byte will be shipped out on MOSI.
//
//              To kick-off transaction, user must pulse i_TX_DV.
//              This module supports multi-byte transmissions by pulsing
//              i_TX_DV and loading up i_TX_Byte when o_TX_Ready is high.
//
//              This module is only responsible for controlling Clk, MOSI, 
//              and MISO.  If the SPI peripheral requires a chip-select, 
//              this must be done at a higher level.
//
// Note:        i_Clk must be at least 2x faster than i_SPI_Clk
//
// Parameters:  SPI_MODE, can be 0, 1, 2, or 3.  See above.
//              Can be configured in one of 4 modes:
//              Mode | Clock Polarity (CPOL/CKP) | Clock Phase (CPHA)
//               0   |             0             |        0
//               1   |             0             |        1
//               2   |             1             |        0
//               3   |             1             |        1
//              More: https://en.wikipedia.org/wiki/Serial_Peripheral_Interface_Bus#Mode_numbers
//              CLKS_PER_HALF_BIT - Sets frequency of o_SPI_Clk.  o_SPI_Clk is
//              derived from i_Clk.  Set to integer number of clocks for each
//              half-bit of SPI data.  E.g. 100 MHz i_Clk, CLKS_PER_HALF_BIT = 2
//              would create o_SPI_CLK of 25 MHz.  Must be >= 2
//
///////////////////////////////////////////////////////////////////////////////

module SPI_Master
  #(parameter SPI_MODE = 0,
    parameter CLKS_PER_HALF_BIT = 2)
  (
   // Control/Data Signals,
   input        i_Rst_L,     // FPGA Reset
   input        i_Clk,       // FPGA Clock
   
   // TX (MOSI) Signals
   input [7:0]  i_TX_Byte,        // Byte to transmit on MOSI
   input        i_TX_DV,          // Data Valid Pulse with i_TX_Byte
   output reg   o_TX_Ready,       // Transmit Ready for next byte
   
   // RX (MISO) Signals
   output reg       o_RX_DV,     // Data Valid pulse (1 clock cycle)
   output reg [7:0] o_RX_Byte,   // Byte received on MISO

   // SPI Interface
   output reg o_SPI_Clk,
   input      i_SPI_MISO,
   output reg o_SPI_MOSI
   );

  // SPI Interface (All Runs at SPI Clock Domain)
  wire w_CPOL;     // Clock polarity
  wire w_CPHA;     // Clock phase

  reg [$clog2(CLKS_PER_HALF_BIT*2)-1:0] r_SPI_Clk_Count;
  reg r_SPI_Clk;
  reg [4:0] r_SPI_Clk_Edges;
  reg r_Leading_Edge;
  reg r_Trailing_Edge;
  reg       r_TX_DV;
  reg [7:0] r_TX_Byte;

  reg [2:0] r_RX_Bit_Count;
  reg [2:0] r_TX_Bit_Count;

  // CPOL: Clock Polarity
  // CPOL=0 means clock idles at 0, leading edge is rising edge.
  // CPOL=1 means clock idles at 1, leading edge is falling edge.
  assign w_CPOL  = (SPI_MODE == 2) | (SPI_MODE == 3);

  // CPHA: Clock Phase
  // CPHA=0 means the "out" side changes the data on trailing edge of clock
  //              the "in" side captures data on leading edge of clock
  // CPHA=1 means the "out" side changes the data on leading edge of clock
  //              the "in" side captures data on the trailing edge of clock
  assign w_CPHA  = (SPI_MODE == 1) | (SPI_MODE == 3);



  // Purpose: Generate SPI Clock correct number of times when DV pulse comes
  always @(posedge i_Clk or negedge i_Rst_L)
  begin
    if (~i_Rst_L)
    begin
      o_TX_Ready      <= 1'b0;
      r_SPI_Clk_Edges <= 0;
      r_Leading_Edge  <= 1'b0;
      r_Trailing_Edge <= 1'b0;
      r_SPI_Clk       <= w_CPOL; // assign default state to idle state
      r_SPI_Clk_Count <= 0;
    end
    else
    begin

      // Default assignments
      r_Leading_Edge  <= 1'b0;
      r_Trailing_Edge <= 1'b0;
      
      if (i_TX_DV)
      begin
        o_TX_Ready      <= 1'b0;
        r_SPI_Clk_Edges <= 16;  // Total # edges in one byte ALWAYS 16
      end
      else if (r_SPI_Clk_Edges > 0)
      begin
        o_TX_Ready <= 1'b0;
        
        if (r_SPI_Clk_Count == CLKS_PER_HALF_BIT*2-1)
        begin
          r_SPI_Clk_Edges <= r_SPI_Clk_Edges - 1'b1;
          r_Trailing_Edge <= 1'b1;
          r_SPI_Clk_Count <= 0;
          r_SPI_Clk       <= ~r_SPI_Clk;
        end
        else if (r_SPI_Clk_Count == CLKS_PER_HALF_BIT-1)
        begin
          r_SPI_Clk_Edges <= r_SPI_Clk_Edges - 1'b1;
          r_Leading_Edge  <= 1'b1;
          r_SPI_Clk_Count <= r_SPI_Clk_Count + 1'b1;
          r_SPI_Clk       <= ~r_SPI_Clk;
        end
        else
        begin
          r_SPI_Clk_Count <= r_SPI_Clk_Count + 1'b1;
        end
      end  
      else
      begin
        o_TX_Ready <= 1'b1;
      end
      
      
    end // else: !if(~i_Rst_L)
  end // always @ (posedge i_Clk or negedge i_Rst_L)


  // Purpose: Register i_TX_Byte when Data Valid is pulsed.
  // Keeps local storage of byte in case higher level module changes the data
  always @(posedge i_Clk or negedge i_Rst_L)
  begin
    if (~i_Rst_L)
    begin
      r_TX_Byte <= 8'h00;
      r_TX_DV   <= 1'b0;
    end
    else
      begin
        r_TX_DV <= i_TX_DV; // 1 clock cycle delay
        if (i_TX_DV)
        begin
          r_TX_Byte <= i_TX_Byte;
        end
      end // else: !if(~i_Rst_L)
  end // always @ (posedge i_Clk or negedge i_Rst_L)


  // Purpose: Generate MOSI data
  // Works with both CPHA=0 and CPHA=1
  always @(posedge i_Clk or negedge i_Rst_L)
  begin
    if (~i_Rst_L)
    begin
      o_SPI_MOSI     <= 1'b0;
      r_TX_Bit_Count <= 3'b111; // send MSb first
    end
    else
    begin
      // If ready is high, reset bit counts to default
      if (o_TX_Ready)
      begin
        r_TX_Bit_Count <= 3'b111;
      end
      // Catch the case where we start transaction and CPHA = 0
      else if (r_TX_DV & ~w_CPHA)
      begin
        o_SPI_MOSI     <= r_TX_Byte[3'b111];
        r_TX_Bit_Count <= 3'b110;
      end
      else if ((r_Leading_Edge & w_CPHA) | (r_Trailing_Edge & ~w_CPHA))
      begin
        r_TX_Bit_Count <= r_TX_Bit_Count - 1'b1;
        o_SPI_MOSI     <= r_TX_Byte[r_TX_Bit_Count];
      end
    end
  end


  // Purpose: Read in MISO data.
  always @(posedge i_Clk or negedge i_Rst_L)
  begin
    if (~i_Rst_L)
    begin
      o_RX_Byte      <= 8'h00;
      o_RX_DV        <= 1'b0;
      r_RX_Bit_Count <= 3'b111;
    end
    else
    begin

      // Default Assignments
      o_RX_DV   <= 1'b0;

      if (o_TX_Ready) // Check if ready is high, if so reset bit count to default
      begin
        r_RX_Bit_Count <= 3'b111;
      end
      else if ((r_Leading_Edge & ~w_CPHA) | (r_Trailing_Edge & w_CPHA))
      begin
        o_RX_Byte[r_RX_Bit_Count] <= i_SPI_MISO;  // Sample data
        r_RX_Bit_Count            <= r_RX_Bit_Count - 1'b1;
        if (r_RX_Bit_Count == 3'b000)
        begin
          o_RX_DV   <= 1'b1;   // Byte done, pulse Data Valid
        end
      end
    end
  end
  
  
  // Purpose: Add clock delay to signals for alignment.
  always @(posedge i_Clk or negedge i_Rst_L)
  begin
    if (~i_Rst_L)
    begin
      o_SPI_Clk  <= w_CPOL;
    end
    else
      begin
        o_SPI_Clk <= r_SPI_Clk;
      end // else: !if(~i_Rst_L)
  end // always @ (posedge i_Clk or negedge i_Rst_L)
  

endmodule // SPI_Master