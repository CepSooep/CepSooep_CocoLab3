module direction(
  input resetn,
  input forward,
  input backward,
  input [1:0]turn, //turn left=00, right= 01 straight = 11 

  input [2:0]currentDir, //car currently facing
  input enableDir, //same as enableGL - a pulse
  output reg [1:0] go, //stop = 00 forward = 11 backwards = 10
  output reg [2:0] dir); //car future direction

  always@(*) begin
    if (!resetn) go <= 2'b00;
      else if(forward * !backward) go <= 2'b11;
      else if(backward * !forward) go <= 2'b10;
      else go <= 2'b00;
   end   
   //else dir <= dir;
  always @(posedge enableDir or negedge resetn) begin //when turn pulses 00 or 01
    if(!resetn) dir = 3'd0;
    else if(turn == 2'b00) dir = currentDir - 1'b1; //turn right
    else if (turn == 2'b01)dir = currentDir + 1'b1; //turn left
  end
      
endmodule
