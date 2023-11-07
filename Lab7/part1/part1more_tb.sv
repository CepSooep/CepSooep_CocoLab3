//Coco's Tester
`timescale 1ns / 1ps
module part1more_tb();

logic clock;
logic [4:0] addr;
logic [3:0] data;
logic wren;
logic [3:0] Q_out;
logic [3:0] out_golden;
//integer in;

//Easiest way to generate the clock is in the verilog rather than in the VPI
//As promised, this simulates a 50 MHz clock.
always #1 clock <= ~clock;
//#1: This is a delay specifier, 
//and it means that the block is executed 
//after a delay of 1 time unit (1ns)
part1 U1(.address(addr),
	     .clock(clock),
	     .data(data),
	     .wren(wren),
	     .q(Q_out)
	    );
//assign in = addr * addr + 3 * addr;
//assign data = in[3:0];
//assign out_golden = in[3:0];

initial begin 
	clock = 1;
	addr = 0;
	wren = 1;

	//! Test 1
	//$time is cycle #
	//addr from 0 to 3
	//wren always 1
	$display("At cycle %d, addr = %d, wren = %d, data = %d", $time, addr, wren, data);
	for(int i = 0; i < 4; i = i+1) begin
		data = addr * addr + 3 * addr;
		$display("At cycle %d, addr = %d, wren = %d, data = %d", $time, addr, wren, data);
		#2; //hold for 2ns
		addr = addr + 1;
	end

	//! Test 2
	#2;
	addr = 0;
	wren = 0;
	//addr from 0 to 3
	//wren always 0
	$display("At cycle %d, addr = %d, wren = %d, data = %d", $time, addr, wren, data);
	for(int i = 0; i < 4; i++) begin
		#2;
		data = addr * addr + 2 * addr;
		if(Q_out == out_golden) begin
			$display("At cycle %d, Reading: addr = %d, output = %d, golden_output = %d, PASSED", $time, addr, Q_out, out_golden);
		end else begin
			$display("At cycle %d, Reading: addr = %d, output = %d, golden_output = %d, FAILED", $time, addr, Q_out, out_golden);
		end
		addr = addr + 1;
	end
	
	//! Test 3
	#4;
	addr = 5;
	wren = 1;
	data = 1;
	//addr from 5 to 15
	//wren always 1
	for(int i = 0; i < 11; i++) begin
		#2;
		addr = addr + 1;
	end

	//! Test 4
	#4;
	addr = 15;
	wren = 1;
	data = 0;
	//addr from 15 to 5
	//wren always 1
	for(int i = 0; i < 11; i++) begin
		#2;
		addr = addr - 1;
		data = data + 3;
	end

	//! Test 5
	#4;
	addr = 31;
	wren = 1;
	data = 15;
	//addr from 31 to 27
	//wren always 1
	for(int i = 0; i < 5; i++) begin
		#2;
		addr = addr - 1;
		data = data - 1;
	end

	//! Test 6
	#4;
	addr = 31;
	wren = 0;
	data = 14;
	//addr from 31 to 29
	//wren always 0
	for(int i = 0; i < 3; i++) begin
		#2;
		addr = addr - 1;
	end
	#2;
	wren = 1;
	#4
	$finish;
end

endmodule
