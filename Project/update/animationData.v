module animationData(
  input [5:0]current_state,
  input button1, button2,
  output reg [1:0] MapSelect //0 is map1, 1 is map 2
  );
   localparam   MAP1 = 2'b00,
              MAP2 = 2'b01,
              START = 2'b10,
              GG = 2'b11;

    //Mapselect
    always @(*) begin
    if(current_state == 6'd11) //stepSwait
      MapSelect = (button1) ? MAP1 : ((button2)? MAP2: START); //if both pressed, map1, if none pressed map1

    end
endmodule
