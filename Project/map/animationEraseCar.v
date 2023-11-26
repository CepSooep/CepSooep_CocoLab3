//need to access memory
module animationEraseCar(iResetn,iX,iY,dir,eraseCar,iClock,ScreenSelect,QoutMAP1, QoutMAP2, QoutSTART, eraseCarDone,oAddress, oX,oY,oColour, oPlot);
  parameter X_SCREEN_PIXELS = 8'd160;
  parameter Y_SCREEN_PIXELS = 7'd120;

  input wire iResetn;
  //input iPlotBox, iLoadX;
  input [7:0] iX;//the next location
  input [6:0] iY;//the next location
  input wire iClock;
  input eraseCar;
  input [1:0] ScreenSelect;
  input [31:0] QoutMAP1, QoutMAP2, QoutSTART;
  input [2:0] dir;
  output [14:0] oAddress;
  output wire [7:0] oX;         // VGA pixel coordinates
  output wire [6:0] oY;
  output wire [8:0] oColour;     // VGA pixel colour (0-7), 3 bits per color {R,G,B}
  output wire oPlot;        //tells VGA to plot
  output  eraseCarDone;       // goes high when finished drawing frame
   
  wire plot_en, counterto225_en ,loadxy;
  wire [7:0] counter225;


    EraseCarcontrol C(
    .clk(iCLock),
    .resetn(iResetn),
    .counter225(counter225),
    .dir(dir),
    .eraseCar(eraseCar),
    //input clear,
    .plot_en(plot_en), //draw on screen
    .counterto196_en(counterto196_en), 
    .counterto225_en(counterto225_en), 
    .eraseCarDone(eraseCarDone), //when car is done drawing
    .loadxy(loadxy),//to load RX and RY so that x_in doesnt need to be held
    .oPlot(oPlot)
    );

    EraseCardatapath D(
    .clk(iCLock),
    .resetn(iResetn),
    .counter225(counter225),
    .plot_en(plot_en),
    .x_in(iX), //input coord of upper left corner
    .y_in(iY),
    .QoutMAP1(QoutMAP1),
    .QoutMAP2(QoutMAP2),
    .QoutSTART(QoutSTART),
    .ScreenSelect(ScreenSelect),
    .loadxy(loadxy),
    .dir(dir),
    .x_out(oX),
    .y_out(oY),
    .col_out(oColour),
    .oAddress(oAddress)
    );

  //counterTo196 C196(iClock, iResetn, counterto196_en, counter196);
  counterTo225 C225(iClock, iResetn, counterto225_en, counter225);
endmodule // part2


module EraseCarcontrol(
    input clk,
    input resetn,
    input [2:0]dir,
    input eraseCar,
    //input iplotbox,
    input [7:0] counter225,
 
    //input clear,
    output reg loadxy,
    output reg plot_en, //draw on screen
    output reg counterto196_en, 
    output reg counterto225_en, 
    output reg eraseCarDone, //when car is done drawing
    output reg oPlot
    );

    reg straight;
    always @ (*) begin
        if((dir == 3'd0)|(dir == 3'd2)|(dir == 3'd4)|(dir == 3'd6)) straight = 1;
        else straight = 0;
    end

    reg [1:0] current_state, next_state;
   
    localparam  
     state1 = 2'd0,
     state2 = 2'd1,
     
     state3 = 2'd3;
    
    // Next state logic aka state table
    always@(*)
    begin: state_table
            case (current_state)
                state1: next_state = eraseCar ? state2 : state1;
                state2: next_state = (counter225 == 8'd225) ? state3 : state2;
                state3: next_state = state1;
            default:  next_state = state1;
        endcase
    end // state_table

    // Output logic aka all of our datapath control signals
    reg firstloop;
    always @(*)
    begin
        // By default make all our signals 0
        plot_en = 1'b0;
        counterto225_en = 1'b0;
        eraseCarDone = 1'b0;
        loadxy = 1'b0;
        oPlot = 1'b0;
        case (current_state)
            state1: begin
                loadxy = 1'b1;
                end
            state2: begin
                plot_en = 1'b1;
                oPlot = 1'b1;
                end
            state3: begin
                eraseCarDone = 1'b1;
                end
        endcase
    end

    // current_state registers
    always@(posedge clk)
    begin
        if(!resetn)
            current_state <= state1;
        else
            current_state <= next_state;
    end // state_FFS
endmodule
////////////////////////////////////
module EraseCardatapath(
    input clk,
    input resetn,
    input plot_en, 
    input [7:0] x_in, //input coord of upper left corner
    input [6:0] y_in,
    input [7:0] counter225,
    input [2:0] dir,
    input loadxy,
    input [31:0] QoutMAP1, QoutMAP2, QoutSTART,
    input [1:0] ScreenSelect,

    output reg [7:0] x_out,
    output reg [6:0] y_out,
    output reg [8:0] col_out,
    output reg [14:0] oAddress

    );

    //loading registers 
    reg [7:0] RX;
    reg [6:0] RY;
    always @ (*) begin
        if (!resetn) begin
            RX = 8'b0;
            RY = 7'b0;
        end
        else if(loadxy) begin
            RX = x_in;
            RY = y_in;
        end
    end

    reg [31:0] iMemOut;
    // Output result register
    always@(posedge clk) begin: Output_result_register
        iMemOut = (ScreenSelect == 2'd0)?QoutMAP1:((ScreenSelect == 2'd1)?QoutMAP2:QoutSTART);
        if(!resetn) begin
            x_out = 7'b0;
            y_out = 7'b0;
            col_out = 3'b0;
            oAddress = 15'b0;
        end
        else if(loadxy)
            oAddress = RX + 160*RY;
        else if(plot_en) begin
            x_out = RX + (counter225[6:0] % 15);
            y_out = RY + (counter225[6:0] / 15);
            oAddress = x_out + 160*y_out;

            col_out = iMemOut[16:8]; //idk if this works        
        end
    end //Output_result_register

endmodule

