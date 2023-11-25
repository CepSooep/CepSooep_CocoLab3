module drawCar(iResetn,iX,iY,drawCar,dir,iClock,oX,oY,oColour,oDone, oPlot);
  parameter X_SCREEN_PIXELS = 8'd160;
  parameter Y_SCREEN_PIXELS = 7'd120;

  input wire iResetn;
  //input iPlotBox, iLoadX;
  input [7:0] iX;//the next location
  input [6:0] iY;//the next location
  input wire iClock;
  input drawCar;
  input [2:0] dir; //i think 3 bits?????

  output wire [7:0] oX;         // VGA pixel coordinates
  output wire [6:0] oY;
  output wire [8:0] oColour;     // VGA pixel colour (0-7), 3 bits per color {R,G,B}
  output wire oPlot;        //tells VGA to plot
  output wire  oDone;       // goes high when finished drawing frame
   
  wire plot_en, counterto112_en, counterto225_en, drawCarDone ,loadxy;
  wire [6:0] counter112;
  wire [7:0] counter225;



    DrawCarcontrol C(
    .clk(iCLock),
    .resetn(iResetn),
    .counter112(counter112),
    .counter225(counter225),
    .dir(dir),
    .drawCar(drawCar),
    //input clear,
    .plot_en(plot_en), //draw on screen
    .counterto112_en(counterto112_en), 
    .counterto225_en(counterto225_en), 
    .drawCarDone(drawCarDone), //when car is done drawing
    .loadxy(loadxy),//to load RX and RY so that x_in doesnt need to be held
    .oPlot(oPlot)
    );

    DrawCardatapath D(
    .clk(iCLock),
    .resetn(iResetn),
    .counter112(counter112),
    .counter225(counter225),
    .plot_en(plot_en),
    .x_in(iX), //input coord of upper left corner
    .y_in(iY),
    .loadxy(loadxy),
    .dir(dir),
    .x_out(oX),
    .y_out(oY),
    .col_out(oColour)
    );

  counterTo112 C112(iClock, iResetn, counterto112_en, counter112);
  counterTo225 C225(iClock, iResetn, counterto225_en, counter225);
endmodule // part2


module DrawCarcontrol(
    input clk,
    input resetn,
    input dir,
    input drawCar,
    //input iplotbox,
    input [6:0] counter112,
    input [7:0] counter225,
 
    //input clear,
    output reg loadxy,
    output reg plot_en, //draw on screen
    output reg counterto112_en, 
    output reg counterto225_en, 
    output reg drawCarDone, //when car is done drawing
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
     state2A = 2'd1,
     state2B = 2'd2,
     state3 = 2'd3;
    
    // Next state logic aka state table
    always@(*)
    begin: state_table
            case (current_state)
                state1: next_state = (drawCar & straight) ? state2A : ((drawCar & ~straight) ? state2B : state1);
                state2A: next_state = (counter112 == 7'd112) ? state3 : state2A;
                state2B: next_state = (counter225 == 8'd225) ? state3 : state2B;
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
        counterto112_en = 1'b0;
        counterto225_en = 1'b0;
        drawCarDone = 1'b0;
        loadxy = 1'b0;
        oPlot = 1'b0;
        case (current_state)
            state1: begin
                loadxy = 1'b1;
                end
            state2A: begin
                plot_en = 1'b1;
                oPlot = 1'b1;
                end
            state2B: begin
                plot_en = 1'b1;
                oPlot = 1'b1;
                end
            state3: begin
                drawCarDone = 1'b1;
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
module DrawCardatapath(
    input clk,
    input resetn,
    input plot_en, 
    input [7:0] x_in, //input coord of upper left corner
    input [6:0] y_in,
    input [6:0] counter112,
    input [7:0] counter225,
    input [2:0] dir,
    input loadxy,

    output reg [6:0] x_out,
    output reg [6:0] y_out,
    output reg [2:0] col_out

    );

  reg [9:0] S[111:0];//straigt 
  reg [9:0] D[224:0]; //diagonal
  parameter R = 10'h300, B = 10'h200, W = 10'h3FF, E={10{1'b0}};
      //colors for the car
  initial begin: car_colors
    //{draw enable, color}
    S[0]=B; S[1]=B; S[2]=E; S[3]=E; S[4]=E; S[5]=E; S[6]=B; S[7]=B;
    S[8]=B; S[9]=B; S[10]=E; S[11]=E; S[12]=E; S[13]=E; S[14]=B; S[15]=B;
    S[16]=B; S[17]=B; S[18]=R; S[19]=R; S[20]=R; S[21]=R; S[22]=B; S[23]=B;
    S[24]=E; S[25]=E; S[26]=R; S[27]=R; S[28]=R; S[29]=R; S[30]=E; S[31]=E;
    S[32]=E; S[33]=R; S[34]=R; S[35]=W; S[36]=W; S[37]=R; S[38]=R; S[39]=E;
    S[40]=E; S[41]=R; S[42]=W; S[43]=R; S[44]=R; S[45]=W; S[46]=R; S[47]=E;
    S[48]=E; S[49]=R; S[50]=R; S[51]=R; S[52]=R; S[53]=R; S[54]=R; S[55]=E;
    
    S[56]=E; S[57]=R; S[58]=R; S[59]=R; S[60]=R; S[61]=R; S[62]=R; S[63]=E;
    S[64]=E; S[65]=R; S[66]=W; S[67]=R; S[68]=R; S[69]=W; S[70]=R; S[71]=E;
    S[72]=E; S[73]=R; S[74]=R; S[75]=W; S[76]=W; S[77]=R; S[78]=R; S[79]=E;
    S[80]=E; S[81]=E; S[82]=R; S[83]=R; S[84]=R; S[85]=R; S[86]=E; S[87]=E;
    S[88]=B; S[89]=B; S[90]=R; S[91]=R; S[92]=R; S[93]=R; S[94]=B; S[85]=B;
    S[96]=B; S[97]=B; S[98]=E; S[99]=E; S[100]=E; S[101]=E; S[102]=B; S[103]=B;
    S[104]=B; S[105]=B; S[106]=E; S[107]=E; S[108]=E; S[109]=E; S[110]=B; S[111]=B;

    D[0]=E; D[1]=E; D[2]=E; D[3]=E; D[4]=E; D[5]=B; D[6]=B; D[7]=E; D[8]=E; D[9]=E; D[10]=E; D[11]=E; D[12]=E; D[13]=E; D[14]=E;
    D[15]=E; D[16]=E; D[17]=E; D[18]=E; D[19]=E; D[20]=B; D[21]=B; D[22]=B; D[23]=E; D[24]=E; D[25]=E; D[26]=E; D[27]=E; D[28]=E; D[29]=E;
    D[30]=E; D[31]=E; D[32]=E; D[33]=E; D[34]=E; D[35]=E; D[36]=E; D[37]=B; D[38]=E; D[39]=E; D[40]=E; D[41]=E; D[42]=E; D[43]=E; D[44]=E;
    D[45]=E; D[46]=E; D[47]=E; D[48]=E; D[49]=E; D[50]=R; D[51]=R; D[52]=E; D[53]=E; D[54]=E; D[55]=E; D[56]=E; D[57]=E; D[58]=E; D[59]=E;
    D[60]=E; D[61]=E; D[62]=E; D[63]=E; D[64]=R; D[65]=R; D[66]=R; D[67]=R; D[68]=E; D[69]=E; D[70]=E; D[71]=E; D[72]=E; D[73]=E; D[74]=E;
    D[75]=B; D[76]=B; D[77]=E; D[78]=R; D[79]=R; D[80]=R; D[81]=W; D[82]=W; D[83]=R; D[84]=R; D[85]=E; D[86]=E; D[87]=E; D[88]=E; D[89]=E;
    D[90]=B; D[91]=B; D[92]=B; D[93]=R; D[94]=R; D[95]=W; D[96]=R; D[97]=R; D[98]=R; D[99]=R; D[100]=E; D[101]=E; D[102]=E; D[103]=E; D[104]=E;
    D[105]=E; D[106]=B; D[107]=B; D[108]=E; D[109]=R; D[110]=W; D[111]=R; D[112]=R; D[113]=R; D[114]=W; D[115]=R; D[116]=E; D[117]=B; D[118]=B; D[119]=E;
    D[120]=E; D[121]=E; D[122]=E; D[123]=E; D[124]=E; D[125]=R; D[126]=R; D[127]=R; D[128]=R; D[129]=W; D[130]=R; D[131]=R; D[132]=B; D[133]=B; D[134]=B;
    D[135]=E; D[136]=E; D[137]=E; D[138]=E; D[139]=E; D[140]=R; D[141]=R; D[142]=W; D[143]=W; D[144]=R; D[145]=R; D[146]=R; D[147]=E; D[148]=B; D[149]=B;
    D[150]=E; D[151]=E; D[152]=E; D[153]=E; D[154]=E; D[155]=E; D[156]=E; D[157]=R; D[158]=R; D[159]=R; D[160]=R; D[161]=E; D[162]=E; D[163]=E; D[164]=E;
    D[165]=E; D[166]=E; D[167]=E; D[168]=E; D[169]=E; D[170]=E; D[171]=E; D[172]=E; D[173]=R; D[174]=R; D[175]=E; D[176]=E; D[177]=E; D[178]=E; D[179]=E;
    D[180]=E; D[181]=E; D[182]=E; D[183]=E; D[184]=E; D[185]=E; D[186]=E; D[187]=B; D[188]=B; D[189]=E; D[190]=E; D[191]=E; D[192]=E; D[193]=E; D[194]=E;
    D[195]=E; D[196]=E; D[197]=E; D[198]=E; D[199]=E; D[200]=E; D[201]=E; D[202]=B; D[203]=B; D[204]=B; D[205]=E; D[206]=E; D[207]=E; D[208]=E; D[209]=E;
    D[210]=E; D[211]=E; D[212]=E; D[213]=E; D[214]=E; D[215]=E; D[216]=E; D[217]=E; D[218]=B; D[219]=B; D[220]=E; D[221]=E; D[222]=E; D[223]=E; D[224]=E;
  end //car_colors
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


    // Output result register
    always@(posedge clk) begin: Output_result_register
        if(!resetn) begin
            x_out <= 7'b0;
            y_out <= 7'b0;
            col_out <= 3'b0;
        end

        else if(plot_en) begin
            if(((dir == 0)|(dir == 4))) begin //horizontal
                //S[counter112[6:0]][9] tells us to color or leave transparent
               x_out <= RX + (counter112[6:0] / 14);//will truncate the fractional part
               y_out <= RY + (counter112[6:0] % 14);
               col_out <= S[counter112[6:0]][8:0]; 
            end
            else if(((dir == 2)|(dir == 6))) begin //vertical
               x_out <= RX + (counter112[6:0] % 8);
               y_out <= RY + (counter112[6:0] / 8);
               col_out <= S[counter112[6:0]][8:0];
            end
            else if(((dir == 1)|(dir == 5)))begin //up+right
               x_out <= RX + (counter225[6:0] % 15);
               y_out <= RY + (counter225[6:0] / 15);
               col_out <= D[counter225[6:0]][8:0]; 
            end
            else if(((dir == 3)|(dir == 7))) begin //down+right
               x_out <= RX + (counter225[6:0] / 15);
               y_out <= RY + (counter225[6:0] % 15);
               col_out <= D[counter225[6:0]][8:0]; 

            end 
        end
    end //Output_result_register

  

endmodule


module counterTo225(clk, resetn, count_en, Q);
  input clk, resetn, count_en;
  output reg [7:0] Q;
  always @(posedge clk) begin
    if(!resetn | (Q==8'd225))
      Q <= 8'd0;
    else if (count_en)
      Q <= Q + 1'd1;
  end
endmodule

module counterTo112(clk, resetn, count_en, Q);
  input clk, resetn, count_en;
  output reg [6:0] Q;
  always @(posedge clk) begin
    if(!resetn | (Q==7'd112) )
      Q <= 7'd0;
    else if (count_en)
      Q <= Q + 1'b1;
  end
endmodule 