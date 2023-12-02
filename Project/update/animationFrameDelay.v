//just a counter
module frameDelay( //currently a 20bit counter , short for modelsim
    input wire clock,
    input resetn,
    input frameDelay_en,

    output reg [19:0] frameDelayCounter
);
  always @(posedge clock) begin
    if(!resetn )
      frameDelayCounter <= 20'd0;
    else if((frameDelayCounter == {7'd0,{13{1'b1}}}))//skip a few
      frameDelayCounter <= {20{1'b1}};
    else if (frameDelay_en)
      frameDelayCounter <= frameDelayCounter + 1'b1;
  end
endmodule
