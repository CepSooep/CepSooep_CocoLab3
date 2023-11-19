module control(
    input clk,
    input resetn,

    input button1,
    input button2,

    output reg timer_en,
    output reg drawStartDone, drawMAP1Done, drawMAP2Done,
    output reg drawStart, drawMAP1, drawMAP2;

    );

  reg [5:0] current_state, next_state;
  
 

  localparam  step1_0         = 6'd0; // at reset
              step1_1         = 6'd1; //wait for startscreen button input             
              step2_0M1       = 6'd2; //draw map1
              step2_0M2       = 6'd4; //draw map2
              step2_0M1       = 6'd3; //finish drawing ,start timer
              step2_0M2       = 6'd5; //finish drawing ,start timer
              step3           = 6'd7; //draw car, start delay


    // Next state logic aka our state table
  always@(*)
  begin: state_table
    case (current_state)
      step1_0: next_state = drawStartDone ? step1_1 : step1_0;
      step1_1: next_state = button1 ? step2_0M1 : (button2 ? step2_0M2 : step1_1);
      
      step2_0M1: next_state = drawMAP1Done ? step2_1M1 : step2_0M1;
      step2_0M2: next_state = drawMAP2Done ? step2_1M2 : step2_0M2;
      step2_1M1: next_state = step3;
      step2_1M2: next_state = step3;

      step3: 

                S_LOAD_A: next_state = go ? S_LOAD_A_WAIT : S_LOAD_A; // Loop in current state until value is input
                S_LOAD_A_WAIT: next_state = go ? S_LOAD_A_WAIT : S_LOAD_B; // Loop in current state until go signal goes low
                S_LOAD_B: next_state = go ? S_LOAD_B_WAIT : S_LOAD_B; // Loop in current state until value is input
                S_LOAD_B_WAIT: next_state = go ? S_LOAD_B_WAIT : S_LOAD_C; // Loop in current state until go signal goes low
                S_LOAD_C: next_state = go ? S_LOAD_C_WAIT : S_LOAD_C; // Loop in current state until value is input
                S_LOAD_C_WAIT: next_state = go ? S_LOAD_C_WAIT : S_LOAD_X; // Loop in current state until go signal goes low
                S_LOAD_X: next_state = go ? S_LOAD_X_WAIT : S_LOAD_X; // Loop in current state until value is input
                S_LOAD_X_WAIT: next_state = go ? S_LOAD_X_WAIT : step2; // Loop in current state until go signal goes low
                step2: next_state = step3;
                step3: next_state = step4;
                step4: next_state = step5;
                step5: next_state = step6;
                step6: next_state = step7;
                step7: next_state = S_LOAD_A;
      default:     next_state = step1_0;
        endcase
    end // state_table


    // Output logic aka all of our datapath control signals
  always @(*)
  begin: enable_signals
        // By default make all our signals 0
    drawStart = 1'b0;
    drawMAP1 = 1'b0;
    drawMAP2 = 1'b0;
    timer_en = 1'b0;
    drawCar = 1'b0;
    delayCounter_en = 1'b0;

        ld_a = 1'b0;
        ld_b = 1'b0;
        ld_c = 1'b0;
        ld_x = 1'b0;
        ld_r = 1'b0;
        alu_select_1 = 2'b0;
        alu_select_2 = 2'b0;
        alu_op       = 1'b0;
        result_valid = 1'b0;

    case (current_state)
      step1_0: begin
        drawStart = 1'b1;
      end
      step1_1: begin //just wait
      end
      step2_0M1: begin
        drawMAP1 = 1'b1;
      end
      step2_0M2: begin
        drawMAP2 = 1'b1;
      end
      step2_1M1: begin
        timer_en = 1'b1;
      end  
      step2_1M2: begin
        timer_en = 1'b1;
      end  
      step3: begin
        drawCar = 1'b1;
        delayCounter_en = 1'b1;
      end
      
            S_LOAD_A: begin
                ld_a = 1'b1;
                end
            S_LOAD_B: begin
                ld_b = 1'b1;
                end
            S_LOAD_C: begin
                ld_c = 1'b1;
                end
            S_LOAD_X: begin
                ld_x = 1'b1;
                end
            step2: begin // Do B*X
                ld_a = 1'b0;
                ld_b = 1'b1;
                ld_c = 1'b0;
                ld_x = 1'b0; 
                ld_r = 1'b0; 
                alu_select_1 = 2'b01;
                alu_select_2 = 2'b11;
                alu_op       = 1'b1;
                ld_alu_out   = 1'b1;
                                
           
            end
            step3: begin
                ld_b = 1'b0;
                ld_x = 1'b1;
                alu_select_1 = 2'b11;
                alu_select_2 = 2'b11;
                alu_op       = 1'b1;
                ld_alu_out   = 1'b1;
                
            end
            step4: begin
                ld_x = 1'b0;
                ld_a = 1'b1;
                alu_select_1 = 2'b00;
                alu_select_2 = 2'b11;
                alu_op       = 1'b1;
                ld_alu_out   = 1'b1;
                

            end
            step5: begin
                ld_a = 1'b1;
                alu_select_1 = 2'b00;
                alu_select_2 = 2'b01;
                alu_op       = 1'b0;
                ld_alu_out   = 1'b1;
                            
            end
            step6: begin
                ld_a = 1'b0;
                ld_r = 1'b1;
                alu_select_1 = 2'b00;
                alu_select_2 = 2'b10;
                alu_op       = 1'b0;
                ld_alu_out   = 1'b1;
                

            end
            step7: begin
                ld_a = 1'b0;
                ld_r = 1'b1;
                alu_select_1 = 2'b00;
                alu_select_2 = 2'b00;
                alu_op       = 1'b0;
                ld_alu_out   = 1'b1;
                result_valid = 1'b1;
            end

            

        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals

    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_LOAD_A;
        else
            current_state <= next_state;
    end // state_FFS
endmodule
