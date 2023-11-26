//just a counter
module frameDelay( //currently a 20bit counter (around 0.2s?)
    input wire clock,
    input resetn,
    input frameDelay_en,

    output reg [19:0] frameDelayCounter
);
  always @(posedge clock) begin
    if(!resetn)
      frameDelayCounter <= 20'd0;
    else if (frameDelay_en)
      frameDelayCounter <= frameDelayCounter + 1'b1;
  end
endmodule
