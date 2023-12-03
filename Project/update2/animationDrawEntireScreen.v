//need to access memory
module drawEntireScreen(
  input clock, 
  input resetn,
  input [1:0] ScreenSelect, //
  input drawScreenEnable,
  
  input [31:0] QoutMAP1, QoutMAP2, QoutSTART,

  output  drawScreenDone,
  output  [7:0] oX,
  output  [6:0] oY,
  output  [8:0] oColour,

  output  [14:0] address,
  output  oPlot
);
    parameter  
     state1 = 3'd0,
     state1wait = 3'd1,
     state2 = 3'd2,
     MEMcolour = 3'd3,
    MEMwait = 3'd4,
     MEMdraw = 3'd5,
     state3 = 3'd6;
  
  wire counterto19200_en;
  wire [14:0] counter19200;
    wire [2:0] current_state;

// wire drawScreenDoneCont;
// always @(*) begin
//   if(!resetn) drawScreenDone = 1'b0;
//   else if(current_state == state3) drawScreenDone = drawScreenDoneCont;
//   else drawScreenDone = 1'b0;
// end

    EntireScreencontrol C(
    .clk(clock),
    .resetn(resetn),
    .counter19200(counter19200),
    .drawScreenEnable(drawScreenEnable),
    .counterto19200_en(counterto19200_en), 
    .drawScreenDone(drawScreenDone), //when car is done drawing
    .oPlot(oPlot),
    .current_state(current_state)
    );

    EntireScreendatapath D(
    .clk(clock),
    .resetn(resetn),
    .counter19200(counter19200),
    .QoutMAP1(QoutMAP1),
    .QoutMAP2(QoutMAP2),
    .QoutSTART(QoutSTART),
    .ScreenSelect(ScreenSelect),
    .x_out(oX),
    .y_out(oY),
    .col_out(oColour),
    .oAddress(address),
    .current_state(current_state)
    );

  counterTo19200 EC225(clock, resetn, counterto19200_en, counter19200); 
endmodule // part2


module EntireScreencontrol(
    input clk,
    input resetn,
    input drawScreenEnable,
    input [14:0] counter19200,
 
    //input clear,
    output reg counterto19200_en, 
    output reg drawScreenDone, //when car is done drawing
    output reg oPlot,
    output reg [2:0] current_state
    );

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
                state1: next_state = (drawScreenEnable)? state1wait : state1;
                state1wait : next_state =state2;
                state2: next_state = (counter19200 == 15'd19200) ? state3 : MEMcolour;
                MEMcolour: next_state = MEMwait;
                MEMwait : next_state = MEMdraw;
                MEMdraw : next_state = state2;
                state3: next_state = state1;
            default:  next_state = state1;
        endcase
    end // state_table


    always @(*)
    begin
        // By default make all our signals 0
        counterto19200_en = 1'b0;
        drawScreenDone = 1'b0;
        oPlot = 1'b0;
        case (current_state)
            state1: begin
                end
            //state1wait:
            state2: begin

                counterto19200_en = 1'b1;
               end
            MEMcolour: begin

                oPlot = 1'b0;
                counterto19200_en = 1'b1;
                end
            MEMwait: begin

                oPlot = 1'b1;
                counterto19200_en = 1'b1;

                end
            MEMdraw: begin
                oPlot = 1'b1;
                counterto19200_en = 1'b1;
            end
            state3: begin
                drawScreenDone = 1'b1;
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
module EntireScreendatapath(
    input clk,
    input resetn,
    input [14:0] counter19200,
    input [31:0] QoutMAP1, QoutMAP2, QoutSTART,
    input [1:0] ScreenSelect,
    input [2:0] current_state,

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

always@(posedge clk) begin: Output_result_register
  if (!resetn) begin
      x_out = 8'd0;
      y_out = 7'd0;
      col_out = 3'd0;
      oAddress = 15'd0;
  end
  case(current_state)
  3'd2: begin //state2
    x_out = (counter19200[14:0] % 160);//will truncate the fractional part
    y_out = (counter19200[14:0] / 160);
    oAddress = counter19200[14:0];
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

module counterTo19200( //count by 3
  input clk, 
  input resetn, 
  input count_en,

  output reg [14:0] Q); //15bit

  reg [1:0] I; //inner counter
  always @(posedge clk) begin
    if(!resetn | (Q==15'd19200)|!count_en) begin
      Q <= 15'd0;
      I <= 2'b0;
    end
    else if (count_en & (I<2'd3)) begin//dont increase Q
      Q <= Q;
      I <= I + 1'b1;
    end
    else if (count_en & (I==2'd3)) begin
      Q <= Q + 1'd1;
      I <= 2'd0;
    end
  end
endmodule
