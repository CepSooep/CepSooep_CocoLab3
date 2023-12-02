module main(
  input clock,
  input resetn,
  input forward,
  input backward,
  input [1:0] turn,
  output [7:0] oX,
  output [6:0] oY,
  output [8:0] oColour,
  output oPlot,

  //for testing
  input coinErase_en
);

  wire [2:0] dir;
  reg [2:0] currentDir;
  wire [1:0] go;
  reg [7:0] currentX; 
  wire [7:0] nextX;
  reg [6:0] currentY;
  wire [6:0] nextY;
  wire ldXY;// only occurs when draw car is called, 
  //so load the new x and y into register
  wire changeREGs;
  reg GLEnable, enableDir;
  wire [7:0] RX;
  wire [6:0] RY;
  wire [2:0] Rdir;
  direction Direction(
    .resetn(resetn),
    .forward(forward),
    .backward(backward),
    .turn(turn), //turn left=00, right= 01 straight = 11
    .currentDir(currentDir), //car currently facing in animation
    .go (go), //stop = 00 forward = 11 backwards = 10
    .dir(dir),//car future direction
    .enableDir(enableDir)); 

  gameLogic GameLogic(
    .resetn(resetn),
    .clock(clock),
    .go(go),
    .dir(dir),
    .currentX(currentX),
    .currentY(currentY),
    .enableGL(GLEnable), 
    .nextx(nextX),//nextX goes to animation only, not to the currentX reg
    .nexty(nextY),
    .changeREGs(changeREGs)
  );


  wire [15:0]memQoutPC;
  wire won, timesUp,cnageREGs;
  wire [31:0] QoutMAP1, QoutMAP2, QoutSTART;
  wire [5:0] animationCurrentState;

  
  //makeshift point counter
  assign memQoutPC = 16'd0;
  assign won = 0;
  assign timesUp = 0;

animation ANIMATION( 
    .clock(clock),
    .resetn(resetn),
    .nextX(nextX),
    .nextY(nextY),
    .dir(dir),
    .coinErase_en(coinErase_en),
    .memQoutPC(memQoutPC), //from pointcounter
    .won(won),
    .timesUp(timesUp),
    .button1(forward), 
    .button2(backward),
    .ldXY(ldXY),
    .oX(oX),
    .oY(oY),
    .oColour(oColour),
    .oPlot(oPlot),
    .current_state(animationCurrentState),
    .RX(RX),
    .RY(RY),
    .Rdir(Rdir)
);

  always@(posedge clock) begin
    
    //GLEnable = 1 at state5, which is erase car
    if(!resetn) begin
      currentX <= 7'd0;
      currentY <= 6'd0; 
      currentDir <= 2'd0;
    end
    else if(changeREGs) begin
      currentX <= nextX;
      currentY <= nextY;
      currentDir <= Rdir;
    end
  end

reg [4:0] GLEnableCounter; //GLEnable is on every few times state is 6'd5
parameter GLEnableCounterValue = 4; //smaller for testing, must be even
  always @ (negedge resetn or posedge(animationCurrentState == 6'd5)) begin
      if(!resetn) begin
      GLEnableCounter = 5'd0;
      GLEnable = 0;
    end
    else if(GLEnableCounter < GLEnableCounterValue) begin 
      GLEnableCounter = GLEnableCounter + 1;
      GLEnable = 0;
    end
    else if(GLEnableCounter == GLEnableCounterValue) begin
      GLEnableCounter = 5'd0;
      GLEnable = 1;
    end
  end


  reg [4:0] internalCounter;
  parameter DirCounterValue = 1; //dummy value
  always @ (negedge resetn or posedge GLEnable) begin
    
    if(!resetn) begin
      internalCounter = 5'd0;
      enableDir = 0;
    end
    else if(internalCounter < DirCounterValue) begin 
      internalCounter = internalCounter + 1;
      enableDir = 0;
    end
    else if(internalCounter == DirCounterValue) begin
      internalCounter = 5'd0;
      enableDir = 1;
    end

  end


endmodule