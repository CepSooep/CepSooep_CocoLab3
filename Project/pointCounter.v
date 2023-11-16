module pointCounter(
  input clock,
  input resetn,
  input nextx,
  input nexty,
  output erasecoinEn,
  output memQout,
  output points);

endmodule

module pointCounterControl(
  input clock,
  input resetn,
  input [3:0] counterTo10,
  input [15:0]memQout,
  output reg wren,
  output reg [4:0] address,
  output reg counterTo10en
  );
  wire exists;
  wire cointestx;
  wire cointesty;
  assign exists = memQout[15];
  assign cointestx = memQout[14:7];
  assign cointesty = memQout[6:0];

  localparam W = 4;
             L = 4;

  reg [1:0] current_state, next_state;

  localparam  step1        = 2'd0,
              step2        = 2'd1,
              step3        = 2'd2,
              step4        = 2'd3,

    // Next state logic aka our state table
  always@(*) begin: state_table
    case (current_state)
      step1: next_state = (counterTo10 == 4'd10) ? step2 : step1; 
      step2: next_state = step3; 
      step3: next_state = (counterTo10 == 4'd10)? step2 : 
                         (((exists)*(nextx<=cointestx)*(cointestx<=(nextx+W))
                         *(nexty<=cointesty)*(cointesty<=(nexty+L)))
                         ? step4 : step3); 
      step4: next_state = step2; 
      default:  next_state = step1;
    endcase
  end // state_table


  // Output logic aka all of our datapath control signals
  always @(*) begin: enable_signals
    // By default make all our signals 0
    counterTo10en <= 1'b1;
    address <= 5'b0;
    wren <= 1'b0;
    counterResetn = 1'b1;
    erasecoinEn = 1'b0;
    case (current_state)
      step1: begin
        address <= counterTo10;
        wren <= 1'b1;
      end
      step2: begin
        counterResetn <= 1'b0; //reset
        counterTo10en <= 1'b1;
        wren <= 1'b0;
      end
      step3: begin
        counterResetn <= 1'b1; //no reset
        address <= counterTo10;
        counterto10en <= 1'b1;
      end 
      step4: begin
        counterResetn <= 1'b0;
        counterTo10en <= 1'b0;
        wren <= 1'b1;
        erasecoinEn <= 1b'1;
      end
            
      default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
    endcase
  end // enable_signals

    // current_state registers
  always@(posedge clk)
  begin: state_FFs
      if(!resetn)
        current_state <= step1;
      else
        current_state <= next_state;
  end // state_FFS
endmodule

module pointCounterData(
  input clock,
  input resetn,
  input erasecoinEn,
  output reg [7:0] datain);

  localparam
    coin0 = 16'b1101001101011111;
    coin1 = 16'b1100101010101010;
    coin2 = 16'b1101111111111111;
    coin3 = 16'b1000000000000001;
    coin4 = 16'b1000000000000011;
    coin5 = 16'b1000000000000111;
    coin6 = 16'b1000000000001001;
    coin7 = 16'b1000000001000001;
    coin8 = 16'b1000000000100001;
    coin9 = 16'b1000100010000001;

// mux for erasing in mem
  always@(*) begin
    if(!resetn) datain <= coin0; //reset to existing coin0
    else begin 
      case(counterTo10)
      //so if erasecoinEn = 1, it would be coin0 & 011111..., which would turn 1st digit 0
        4'b0:datain <= (coin0 & {~erasecoinEn,15{1'b1}});
        4'b1:datain <= (coin1 & {~erasecoinEn,15{1'b1}});
        4'b2:datain <= (coin2 & {~erasecoinEn,15{1'b1}});
        4'b3:datain <= (coin3 & {~erasecoinEn,15{1'b1}});
        4'b4:datain <= (coin4 & {~erasecoinEn,15{1'b1}});
        4'b5:datain <= (coin5 & {~erasecoinEn,15{1'b1}});
        4'b6:datain <= (coin6 & {~erasecoinEn,15{1'b1}});
        4'b7:datain <= (coin7 & {~erasecoinEn,15{1'b1}});
        4'b8:datain <= (coin8 & {~erasecoinEn,15{1'b1}});
        4'b9:datain <= (coin9 & {~erasecoinEn,15{1'b1}});
        default: datain <= (coin0 & {~erasecoinEn,15{1'b1}});//i actually dont care otherwise
      endcase
    end
endmodule

module Counter10(
  input clock,
  input resetn,
  input enable,
  output reg [3:0] q);

  always @(posedge clock) begin
    if(!resetn | (q==4'd10))
      q <= 4'd0;
    else
      q <= q+1;
  end 
endmodule
