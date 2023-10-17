# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in part2.v to working dir
# could also have multiple verilog files
vlog part2.v

#load simulation using 7404 as the top level simulation module
vsim part2Board

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


force {KEY[0]} 1 0, 0 6ns -repeat 12ns
#######
force {SW[9:8]} 2'b00

force {KEY[1]} 0
force {SW[3:0]} 4'b1111
run 10ns

force {KEY[1]} 1
force {SW[3:0]} 4'b0101
run 15ns

#######
force {SW[9:8]} 2'b01

force {SW[3:0]} 4'b0110
run 10ns

force {SW[3:0]} 4'b0100
run 10ns

force {SW[3:0]} 4'b1111
run 10ns




