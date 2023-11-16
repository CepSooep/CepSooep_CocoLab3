module part2(iResetn,iPlotBox,iBlack,iColour,iLoadX,iXY_Coord,iClock,oX,oY,oColour,oPlot,oDone);
   parameter X_SCREEN_PIXELS = 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;


   input wire iResetn, iPlotBox, iBlack, iLoadX;
   input wire [2:0] iColour;
   input wire [6:0] iXY_Coord;
   input wire      iClock;
   output wire [7:0] oX;         // VGA pixel coordinates
   output wire [6:0] oY;


   output wire [2:0] oColour;     // VGA pixel colour (0-7)
   //RGB
   output wire         oPlot;       // Pixel draw enable
   output wire       oDone;       // goes high when finished drawing frame
   
   wire ld_x, ld_y, ld_color, count_en, clearcount_en;
   wire [3:0] counter;
   wire [14:0] counter15;


   control ControlPath(
    .clk(iClock),
    .resetn(iResetn),
    .iloadx(iLoadX),
    .iplotbox(iPlotBox),
    .counter(counter),
    .counter15(counter15),
    .ld_x(ld_x),
    .ld_y(ld_y),
    .ld_color(ld_color),
    .count_en(count_en),
    .clearcount_en(clearcount_en),
    .oDone(oDone),
    .clear(iBlack));


   wire [6:0] oX_7;
   datapath DataFlow(
    .clk(iClock),
    .resetn(iResetn),
    .ld_x(ld_x),
    .ld_y(ld_y),
    .ld_color(ld_color),
    .count_en(count_en),
    .clearcount_en(clearcount_en),
    .counter(counter),
    .counter15(counter15),
    .x_in(iXY_Coord),
    .y_in(iXY_Coord),
    .col_in(iColour),
    .x_out(oX_7),
    .y_out(oY),
    .col_out(oColour),
    .oPlot(oPlot));


  assign oX = {1'b0, oX_7};


  bit4Counter C1(iClock, iResetn, count_en, counter);
  bit15Counter C2(iClock, iResetn, clearcount_en, counter15);
endmodule // part2


module control(
    input clk,
    input resetn,
    input iloadx,
    input iplotbox,
    input [3:0] counter,
    input [14:0] counter15,
    input clear,
    output reg  ld_x, ld_y, ld_color, oDone,
    output reg  count_en, clearcount_en
    );


    reg [3:0] current_state, next_state;
   
    localparam  
     state1 = 4'b0000,
     state2 = 4'b0001,
     state3 = 4'b0010,
     state4 = 4'b0011,
     state5 = 4'b0100,
     state6 = 4'b0101,
     stateC1 = 4'b0110,  
     stateC2 = 4'b0111,
     stateC3 = 4'b1000;      


    // Next state logic aka our state table
    always@(*)
    begin: state_table
            case (current_state)
                state1: next_state = clear ? stateC1 : (iloadx ? state2 : state1);
                state2: next_state = clear ? stateC1 : (iloadx ? state2 : state3);
                state3: next_state = clear ? stateC1 : (iplotbox ? state4 : state3);
                state4: next_state = clear ? stateC1 : (iplotbox ? state4 : state5);
                state5: next_state = (counter != 4'b1111) ? state5 : state6;
                state6: next_state = state1;
                stateC1: next_state = clear ? stateC1 : stateC2;
                stateC2: next_state = counter15 != {8'b01111111,7'b1111111} ? stateC2 : stateC3;
                stateC3: next_state = state1;
            default:     next_state = state1;
        endcase
    end // state_table


    // Output logic aka all of our datapath control signals
    reg firstloop;
    always @(*)
    begin
        // By default make all our signals 0
        ld_x = 1'b0;
        ld_y = 1'b0;
        ld_color = 1'b0;
        count_en = 1'b0;
        clearcount_en = 1'b0;
        oDone = firstloop;


        if(!resetn)
            firstloop = 1'b0;
       
        case (current_state)
            state1: begin
                end
            state2: begin
                ld_x = iloadx ? 1'b1 : 0;
                end
            state3: begin
                end
            state4: begin
                ld_y = iplotbox ? 1'b1 : 0;
                ld_color = iplotbox ? 1'b1 : 0;
                end
            state5: begin
                count_en = 1'b1;
                oDone = 1'b0;
                end
            state6: begin
                firstloop = 1'b1;
                oDone = 1'b0;
                end
            stateC1: begin
                end
            stateC2: begin
                clearcount_en = 1'b1;
                oDone = 1'b0;
                end
            stateC3: begin
                oDone = 1'b0;
                firstloop = 1'b1;
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
module datapath(
    input clk,
    input resetn,
    input ld_x, ld_y, ld_color,
    input count_en, clearcount_en,
    input [3:0] counter,
    input [14:0] counter15,
    input [6:0] x_in,
    input [6:0] y_in,
    input [2:0] col_in,
    output reg [6:0] x_out,
    output reg [6:0] y_out,
    output reg [2:0] col_out,
    output reg oPlot
    );


    // input registers
    reg [6:0] RX;
    reg [6:0] RY;
    reg [2:0] RC;


    // Registers RX, RY, RC with respective input logic
    always@(posedge clk) begin
        if(!resetn) begin
            RX <= 7'b0;
            RY <= 7'b0;
            RC <= 3'b0;
        end
        else begin
            if(ld_x)
                RX <= x_in;
            if(ld_y)
                RY <= y_in;
            if(ld_color)
                RC <= col_in;
        end
    end


    // Output result register
    always@(posedge clk) begin
        if(!resetn) begin
            x_out <= 7'b0;
            y_out <= 7'b0;
            col_out <= 3'b0;
            oPlot = 1'b0;


        end
        else begin
            if(count_en) begin
               x_out <= RX + counter[1:0];
               y_out <= RY + counter[3:2];
               col_out <= RC;
               oPlot = 1'b1;
            end
            else if(clearcount_en) begin
               x_out <= counter15[14:7];
               y_out <= counter15[6:0];
               col_out <= 3'b000;
               oPlot = 1'b1;
            end
            else if(!count_en && !clearcount_en)
               oPlot = 1'b0;
           
        end
    end
endmodule


module bit4Counter(clk, resetn, count_en, Q);
  input clk, resetn, count_en;
  output reg [3:0] Q;


  always @(posedge clk) begin
    if(!resetn)
      Q <= 4'b0000;
    else if (count_en)
      Q <= Q + 1'b1;
  end
endmodule


module bit15Counter(clk, resetn, count_en, Q);
  input clk, resetn, count_en;
  output reg [14:0] Q;


  always @(posedge clk) begin
    if(!resetn | (Q=={8'b01111111,7'b1111111}) )
      Q <= {15{1'b0}};
    else if (count_en)
      Q <= Q + 1'b1;
  end
endmodule