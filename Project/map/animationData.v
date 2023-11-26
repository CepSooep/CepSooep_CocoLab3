module animationData(
  input [5:0]current_state,
  input button1, button2,
  output reg MapSelect
  );

    
    //Mapselect
    always @(*) begin
      MapSelect = (button1) ? ((!button2)?1'b0 : 1'b0) : ((button2)? 1'b1: 1'b0); //if both pressed, map1, if none pressed map1
    end
endmodule
