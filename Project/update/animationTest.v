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

  
  output reg [7:0] oX,
  output reg [6:0] oY,
  output reg [8:0] oColour,
  output ldXY, //eraseCoin_en
  output reg oPlot,
  output [5:0] current_state,
  output [7:0] RX,
  output [6:0] RY,
  output [2:0] Rdir

);

  
  wire [5:0] next_state;
  wire [19:0] FDcounter;
  wire [1:0] mapSelect;
  wire drawScreenDone, drawCoinDone, drawCarDone, eraseCarDone, eraseCoinDone;
  wire frameDelay_en, drawScreenEnable, drawCoinEnable,drawCarEnable;
  wire eraseCarEnable;
  wire [1:0] ScreenSelect;

  wire [31:0] QoutMAP1; 
  wire [31:0] QoutMAP2;
  wire [31:0] QoutSTART;

  wire [7:0] oXDCar, oXDCoin, oXEntireScreen, oXECar, oXEcoin;
  wire [6:0] oYDCar, oYDCoin, oYEntireScreen, oYECar, oYEcoin;
  wire [8:0] oColourDCar, oColourDCoin, oColourEntireScreen, oColourECar, oColourEcoin;
  wire oPlotDCar, oPlotDCoin, oPlotEntireScreen, oPlotECar, oPlotEcoin;

  wire [14:0] addressMapMEMDCoin, 
  addressMapMEMEntireScreen,addressMapMEMECar, addressMapMEMECoin,addressMapMEMDCar;
  reg [14:0] addressMapMEM;//main out? or jsut the main one

always @(*) begin
    if(!resetn) begin
        oX <= 8'd0;
        oY <= 7'd0;
        oColour <= 9'd0;
        addressMapMEM <= 15'd0;
        oPlot <= 1'd0;
    end
    case (current_state) 
      6'd9: begin //stepS
        oX <= oXEntireScreen;
        oY <= oYEntireScreen;
        oColour <= oColourEntireScreen;
        addressMapMEM <= addressMapMEMEntireScreen ;//cuz the address mem stuff starts at 19200
        oPlot <= oPlotEntireScreen;
      end
      6'd1: begin //step1
        oX <= oXEntireScreen;
        oY <= oYEntireScreen;
        oColour <= oColourEntireScreen;
        addressMapMEM <= addressMapMEMEntireScreen;
        oPlot <= oPlotEntireScreen;
        
      end
      6'd10: begin //step1wait why do i need to do this step?
        oX <= oXEntireScreen;
        oY <= oYEntireScreen;
        oColour <= oColourEntireScreen;
        addressMapMEM <= addressMapMEMEntireScreen;
        oPlot <= oPlotEntireScreen;
      end
      6'd2: begin //step2
        oX <= oXDCoin;
        oY <= oYDCoin;
        oColour <= oColourDCoin;
        oPlot <= oPlotDCoin;
      end
      6'd3: begin //step3 draw car
        oX <= oXDCar;
        oY <= oYDCar;
        oColour <= oColourDCar;
        oPlot <= oPlotDCar;
        addressMapMEM <= addressMapMEMDCar;
      end
      6'd4: begin //step4
        oX <= oXDCar;
        oY <= oYDCar;
        oColour <= oColourDCar;
        oPlot <= oPlotDCar;
      end
      6'd5: begin //step5
        oX <= oXECar;
        oY <= oYECar;
        oColour <= oColourECar;
        addressMapMEM <= addressMapMEMECar;
        oPlot <= oPlotECar;
      end
      6'd7: begin //stepE
        oX <= oXECar;
        oY <= oYECar;
        oColour <= oColourECar;
        addressMapMEM <= addressMapMEMECoin;
        oPlot <= oPlotEcoin;
      end
      6'd8: begin //stepGG
        oX <= oXEntireScreen;
        oY <= oYEntireScreen;
        oColour <= oColourEntireScreen;
        addressMapMEM <= addressMapMEMEntireScreen;
        oPlot <= oPlotEntireScreen;
      end
      default begin
        oX <= oXEntireScreen;
        oY <= oYEntireScreen;
        oColour <= oColourEntireScreen;
        addressMapMEM <= addressMapMEMEntireScreen;
        oPlot <= oPlotEntireScreen;
      end
    endcase
  end

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
    .eraseCoinDone(eraseCoinDone),
    .eraseCarDone(eraseCarDone),
    .frameDelay_en(frameDelay_en), 
    .drawScreenEnable(drawScreenEnable), 
    .drawCoinEnable(drawCoinEnable), 
    .drawCarEnable(drawCarEnable), 
    .eraseCarEnable(eraseCarEnable),
    .ScreenSelect(ScreenSelect),
    .current_state(current_state),
        .next_state(next_state),
    .ldXY(ldXY)
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
    .QoutMAP1(QoutMAP1), 
    .QoutMAP2(QoutMAP2), 
    .QoutSTART(QoutSTART),
    .ScreenSelect(ScreenSelect),
    .oX(oXDCar),
    .oY(oYDCar),
    .oColour(oColourDCar),
    .oDone(drawCarDone), 
    .oPlot(oPlotDCar),
    .addressMapMEM(addressMapMEMDCar),
    .RX(RX),
    .RY(RY),
    .Rdir(Rdir) );
  

  drawCoins DCoin(
    .clock(clock),
    .resetn(resetn),
    .drawCoin_en(drawCoinEnable), //active positive, from pointcounter
    .memQout(memQoutPC), //from pointcomunter, {exist, x, y}
    .map(ScreenSelect),//MAP1 or MAP2
    .address(addressMapMEMDCoin),
    .drawCoinDone(drawCoinDone),
    .oXE(oXDCoin),
    .oYE(oYDCoin),
    .oColour(oColourDCoin),
    .oPlot(oPlotDCoin));
  
  drawEntireScreen DEntireScreen(
    .clock(clock),
    .resetn(resetn),
    .ScreenSelect(ScreenSelect),
    .drawScreenEnable(drawScreenEnable),
    .QoutMAP1(QoutMAP1), 
    .QoutMAP2(QoutMAP2), 
    .QoutSTART(QoutSTART),

    .drawScreenDone(drawScreenDone),
    .oX(oXEntireScreen),
    .oY(oYEntireScreen),
    .oColour(oColourEntireScreen),
    .address(addressMapMEMEntireScreen),
    .oPlot(oPlotEntireScreen)
  );

  animationEraseCar ECar(
    .iResetn(resetn),
    .RX(RX),
    .RY(RY),
    .eraseCar(eraseCarEnable),
    .iClock(clock),
    .ScreenSelect(ScreenSelect),
    .QoutMAP1(QoutMAP1), 
    .QoutMAP2(QoutMAP2), 
    .QoutSTART(QoutSTART),
    .Rdir(Rdir),
    .oAddress(addressMapMEMECar), //of address of map MEM
    .oX(oXECar),
    .oY(oYECar),
    .oColour(oColourECar),
    .eraseCarDone(eraseCarDone), 
    .oPlot(oPlotECar)
    );
  
  
  eraseCoin ECoin(
    .clock(clock),
    .resetn(resetn),
    .coinErase_en(coinErase_en), //active positive, from pointcounter
    .ScreenSelect(ScreenSelect),
    .QoutMAP1(QoutMAP1), 
    .QoutMAP2(QoutMAP2), 
    .QoutSTART(QoutSTART),
    //.memQout(memQoutPC), //from pointcounter, {exist, x, y}
    .memQout(memQoutPC), //for testing
    .address(addressMapMEMECoin),//of map mem
    .oXE(oXEcoin),
    .oYE(oYEcoin),
    .oColourE(oColourEcoin),
    .eraseCoinDone(eraseCoinDone),
    .oPlot(oPlotEcoin));

  frameDelay FD( //currently a 20bit counter (around 0.2s?)
    .clock(clock),
    .resetn(resetn),
    .frameDelay_en(frameDelay_en),

    .frameDelayCounter(FDcounter)
  );


  // coinsMEM coinMEM(
	//   .address(),
	//   .clock(clock),
	//   .data(16'd0), //unused
	//   .wren(1'b0), //never write
	//   .q());

  map1init MAP1(
	  .address(addressMapMEM),
	  .clock(clock),
	  .q(QoutMAP1));

  map2init MAP2(
	  .address(addressMapMEM),
	  .clock(clock),
	  .q(QoutMAP2));

  mapStartinit START(
	  .address(addressMapMEM),
	  .clock(clock),
	  .q(QoutSTART));


endmodule
