module animation(
  input clock,
  input resetn,
  input [7:0] nextX,
  input [6:0] nextY,
  input [2:0] dir,
  input coinErase_en,
  input [15:0] memQoutPC, //from pointcounter
  input won,
  input timesUp,
  input button1, button2,
  input [31:0] QoutMAP1, QoutMAP2, QoutSTARTl,
  
  output [7:0] oX,
  output [6:0] oY,
  output [8:0] oColour,
  output oPlot
);

  wire [19:0] FDcounter;
  wire mapSelect;
  wire drawScreenDone, drawCoinDone, drawCarDone, eraseCarDone;
  wire frameDelay_en, drawScreenEnable, drawCoinEnable,drawCarEnable;
  wire eraseCarEnable;
  wire [1:0] ScreenSelect;
  wire [5:0] current_state;

  animationControl C(
    .clk(clock),
    .resetn(resetn),
    .button1(button1),
    .button2(button2),
    .FDcounter(FDcounter), //0.2s
    .coinErase_en(coinErase_en),
    .won(won),
    .timesUp(timesUp),
    .MapSelect(mapSelect), // 0 is MAP1

    .drawScreenDone(drawScreenDone), 
    .drawCoinDone(drawCoinDone), 
    .drawCarDone(drawCarDone), 
    .eraseCarDone(eraseCarDone),
    .frameDelay_en(frameDelay_en), 
    .drawScreenEnable(drawScreenEnable), 
    .drawCoinEnable(drawCoinEnable), 
    .drawCarEnable(drawCarEnable), 
    .eraseCarEnable(eraseCarEnable),
    .ScreenSelect(ScreenSelect),
    .current_state(current_state)
  );

  animationData D(
    .current_state(current_state),
    .button1(button1), 
    .button2(button2),
    .MapSelect(mapSelect)
  );

  drawCar DCar(
    .iResetn(resetn),
    .iX(nextX),
    .iY(nextY),
    .drawCar(drawCarEnable),
    .dir(dir),
    .iClock(clock),
    .oX(oX),
    .oY(oY),
    .oColour(oColour),
    .oDone(DrawCarcontrol), 
    .oPlot(oPlot) );
  
  wire [31:0] mapMem;
  wire [14:0] addressMapMEM;
  
  drawCoins DCoin(
    .clock(clock),
    .resetn(resetn),
    .drawCoin_en(drawCoinEnable), //active positive, from pointcounter
    .mapMem(mapMem),//x,y color
    .memQout(memQoutPC), //from pointcomunter, {exist, x, y}
    .map(mapSelect),//MAP1 or MAP2
    .address(addressMapMEM),
    .drawCoinDone(drawCoinDone),
    .oXE(oX),
    .oYE(oY),
    .oColour(oColour));
  
  drawEntireScreen DEntireScreen(
    .resetn(resetn),
    .ScreenSelect(ScreenSelect),
    .drawScreenEnable(drawScreenEnable),
    .QoutMAP1(QoutMAP1), 
    .QoutMAP2(QoutMAP2), 
    .QoutSTART(QoutSTART),

    .drawScreenDone(drawScreenDone),
    .oX(oX),
    .oY(oY),
    .oColour(oColour),
    .address(addressMapMEM)
  );

  animationEraseCar ECar(
    .iResetn(resetn),
    .iX(nextX),
    .iY(nextY),
    .eraseCar(eraseCar),
    .iClock(clock),
    .ScreenSelect(ScreenSelect),
    .QoutMAP1(QoutMAP1), 
    .QoutMAP2(QoutMAP2), 
    .QoutSTART(QoutSTART),
    .oAddress(addressMapMEM), //of address of map MEM
    .oX(oX),
    .oY(oY),
    .oColour(oColour),
    .eraseCarDone(eraseCarDone), 
    .oPlot(oPlot));
  
  
  eraseCoin ECoin(
    .clock(clock),
    .resetn(resetn),
    .drawCoin_en(drawCoinEnable), //active positive, from pointcounter
    .ScreenSelect(ScreenSelect),
    .QoutMAP1(QoutMAP1), 
    .QoutMAP2(QoutMAP2), 
    .QoutSTART(QoutSTART),
    .memQout(memQoutPC), //from pointcounter, {exist, x, y}
    .map(mapSelect),//MAP1 or MAP2
    .address(addressMapMEM),//of map mem
    .drawCoinDone(drawCoinDone),
    .oXE(oX),
    .oYE(oY),
    .oColour(oColour));

  frameDelay FD( //currently a 20bit counter (around 0.2s?)
    .clock(clock),
    .resetn(resetn),
    .frameDelay_en(frameDelay_en),

    .frameDelayCounter(FDcounter)
  );

endmodule
