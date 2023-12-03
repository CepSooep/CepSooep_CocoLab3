//need to access memory
module animationEraseCar(
  input wire iResetn,
  //input iPlotBox, iLoadX,
  input [7:0] RX,//the next location
  input [6:0] RY,//the next location
  input wire iClock,
  input eraseCar,
  input [1:0] ScreenSelect,
  input [31:0] QoutMAP1, QoutMAP2, QoutSTART,
  input [2:0] Rdir,
  input [1:0] Rgo,
  output [14:0] oAddress,  //for map mem
  output wire [7:0] oX,         // VGA pixel coordinates
  output wire [6:0] oY,
  output wire [8:0] oColour,     // VGA pixel colour (0-7), 3 bits per color {R,G,B}
  output wire oPlot,        //tells VGA to plot
  output  eraseCarDone      // goes high when finished drawing frame
);
  wire plot_en, counterto225_en ,loadxy;
  wire [7:0] counter225;
    wire [2:0] current_state;

    EraseCarcontrol C(
    .clk(iClock),
    .resetn(iResetn),
    .counter225(counter225),
    .dir(Rdir),
    .eraseCar(eraseCar),
    .counterto225_en(counterto225_en), 
    .eraseCarDone(eraseCarDone), //when car is done drawing
    .oPlot(oPlot),
    .current_state(current_state)
    );

    EraseCardatapath D(
    .clk(iClock),
    .resetn(iResetn),
    .counter225(counter225),
    .RX(RX), //input coord of upper left corner
    .RY(RY),
    .QoutMAP1(QoutMAP1),
    .QoutMAP2(QoutMAP2),
    .QoutSTART(QoutSTART),
    .ScreenSelect(ScreenSelect),
    .Rgo(Rgo),
    .Rdir(Rdir),
    .x_out(oX),
    .y_out(oY),
    .col_out(oColour),
    .oAddress(oAddress),
    .current_state(current_state)
    );

  counterTo225 EC225(iClock, iResetn, counterto225_en, counter225);
endmodule // part2


module EraseCarcontrol(
    input clk,
    input resetn,
    input [2:0]dir,
    input eraseCar,
    //input iplotbox,
    input [7:0] counter225,
 
    //input clear,
    output reg counterto225_en, 
    output reg eraseCarDone, //when car is done drawing
    output reg oPlot,
    output reg [2:0] current_state
    );

    reg straight;
    always @ (*) begin
        if((dir == 3'd0)|(dir == 3'd2)|(dir == 3'd4)|(dir == 3'd6)) straight = 1;
        else straight = 0;
    end

    reg [2:0] next_state;
   
    localparam  
     state1 = 3'd0,
     state1wait = 3'd1,
     state2 = 3'd2,
     MEMcolour = 3'd3,
    MEMwait = 3'd4,
     MEMdraw = 3'd5,
     state3 = 3'd6;
    
    // Next state logic aka state table
    always@(*)
    begin: state_table
            case (current_state)
                state1: next_state = (eraseCar)? state1wait : state1;
                state1wait : next_state =state2;
                state2: next_state = (counter225 == 8'd225) ? state3 : MEMcolour;
                MEMcolour: next_state = MEMwait;
                MEMwait : next_state = MEMdraw;
                MEMdraw : next_state = state2;
                state3: next_state = state1;
            default:  next_state = state1;
        endcase
    end // state_table

    // Output logic aka all of our datapath control signals
    //reg firstloop;
    always @(*)
    begin
        // By default make all our signals 0
        counterto225_en = 1'b0;
        eraseCarDone = 1'b0;
        oPlot = 1'b0;
        case (current_state)
            state1: begin
                end
            //state1wait:
            state2: begin

                counterto225_en = 1'b1;
               end
            MEMcolour: begin

                oPlot = 1'b0;
                counterto225_en = 1'b1;
                end
            MEMwait: begin

                oPlot = 1'b1;
                counterto225_en = 1'b1;

                end
            MEMdraw: begin
                oPlot = 1'b1;
                counterto225_en = 1'b1;
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
    input [7:0] RX, //input coord of upper left corner
    input [6:0] RY,
    input [7:0] counter225,
    input [2:0] Rdir,
    input [31:0] QoutMAP1, QoutMAP2, QoutSTART,
    input [1:0] ScreenSelect,
    input [2:0] current_state,
    input [1:0] Rgo, //stop = 00 forward = 11 backwards = 10

    output reg [7:0] x_out,
    output reg [6:0] y_out,
    output reg [8:0] col_out,
    output reg [14:0] oAddress


    );
reg [31:0] imemQout;
always @(*) begin
    case (ScreenSelect)
        2'd0: imemQout = QoutMAP1;
        2'd1: imemQout = QoutMAP2;
        2'd2: imemQout = QoutSTART;
    endcase
end

localparam stop = 2'b00, //for Rgo
 forw = 2'b11 ,
 back = 2'b10;



     always@(posedge clk) begin: Output_result_register
        if (!resetn) begin
            x_out = 8'd0;
            y_out = 7'd0;
            col_out = 3'd0;
            oAddress = 15'd0;
        end
        case(current_state)
        3'd2: begin //state2
            x_out = RX + (counter225[7:0] % 15);//will truncate the fractional part
            y_out = RY + (counter225[7:0] / 15);

        // if((Rdir == 3) & (Rgo == back) | (Rdir == 7) & (Rgo == forw) 
        // | (Rdir == 2) & (Rgo == back) | (Rdir == 6) & (Rgo == forw)
        // | (Rdir == 1) & (Rgo == back) | (Rdir == 5) & (Rgo == forw)) 
        //     oAddress = x_out + 160*(y_out-15); //for some reason, it was redrawing 15 above for these directions
        // else
            oAddress = x_out + 160*y_out;
        end
         
        3'd3: begin //MEMcolour
                    col_out <= imemQout[16:8];
            end
    
    
        3'd4: begin //MEMwait
            col_out <= col_out;
            x_out <= x_out;
            y_out <= y_out;
        end

        endcase
    end //Output_result_register
endmodule
