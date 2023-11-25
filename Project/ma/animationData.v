module animationData(
  input current_state,
  input button1, button2,
  output reg MapSelect
  );

    
    //Mapselect
    always @(*) begin
      MapSelect = (button1) ? ((!button2)?1'b0 : 1'b0) : ((button2)? 1'b1: 1'b0); //if both pressed, map1, if none pressed map1
    end
endmodule
// //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//     // input registers
//     reg [6:0] RX;
//     reg [6:0] RY;
//     reg [2:0] RC;




//     // Registers RX, RY, RC with respective input logic
//     always@(posedge clk) begin
//         if(!resetn) begin
//             RX <= 7'b0;
//             RY <= 7'b0;
//             RC <= 3'b0;
//         end
//         else begin
//             if(ld_x)
//                 RX <= x_in;
//             if(ld_y)
//                 RY <= y_in;
//             if(ld_color)
//                 RC <= col_in;
//         end
//     end




//     // Output result register
//     always@(posedge clk) begin
//         if(!resetn) begin
//             x_out <= 7'b0;
//             y_out <= 7'b0;
//             col_out <= 3'b0;
//             oPlot = 1'b0;




//         end
//         else begin
//             if(count_en) begin
//                x_out <= RX + counter[1:0];
//                y_out <= RY + counter[3:2];
//                col_out <= RC;
//                oPlot = 1'b1;
//             end
//             else if(clearcount_en) begin
//                x_out <= counter15[7:0];
//                y_out <= counter15[14:8];
//                col_out <= 3'b000;
//                oPlot = 1'b1;
//             end
//             else if(!count_en && !clearcount_en)
//                oPlot = 1'b0;
           
//         end
//     end
// endmodule














//     // input registers
//     reg [7:0] a, b, c, x;

//     // output of the alu
//     reg [7:0] alu_out;
//     // alu input muxes
//     reg [7:0] alu_a, alu_b;

//     // Registers a, b, c, x with respective input logic
//     always@(posedge clk) begin
//         if(!resetn) begin
//             a <= 8'b0;
//             b <= 8'b0;
//             c <= 8'b0;
//             x <= 8'b0;
//         end
//         else begin
//             if(ld_a)
//                 a <= ld_alu_out ? alu_out : data_in; // load alu_out if load_alu_out signal is high, otherwise load from data_in
//             if(ld_b)
//                 b <= ld_alu_out ? alu_out : data_in; // load alu_out if load_alu_out signal is high, otherwise load from data_in
//             if(ld_x)
//                 x <= ld_alu_out ? alu_out : data_in; // load alu_out onto register x when high otherwise load from data_in
//             if(ld_c)
//                 c <= ld_alu_out ? alu_out : data_in; 
//         end
//     end

//     // Output result register
//     always@(posedge clk) begin
//         if(!resetn) begin
//             data_result <= 8'b0;
//         end
//         else
//             if(ld_r)
//                 data_result <= alu_out;
//     end

//     // The ALU input multiplexers
//     always @(*)
//     begin
//         case (alu_select_1)
//             2'd0:
//                 alu_a = a;
//             2'd1:
//                 alu_a = b;
//             2'd2:
//                 alu_a = c;
//             2'd3:
//                 alu_a = x;
//             default: alu_a = 8'b0;
//         endcase

//         case (alu_select_2)
//             2'd0:
//                 alu_b = a;
//             2'd1:
//                 alu_b = b;
//             2'd2:
//                 alu_b = c;
//             2'd3:
//                 alu_b = x;
//             default: alu_b = 8'b0;
//         endcase
//     end

//     // The ALU
//     always @(*)
//     begin : ALU
//         // alu
//         case (alu_op)
//             0: begin
//                    alu_out = alu_a + alu_b; //performs addition
//                end
//             1: begin
//                    alu_out = alu_a * alu_b; //performs multiplication
//                end
//             default: alu_out = 8'b0;
//         endcase
//     end

// endmodule
