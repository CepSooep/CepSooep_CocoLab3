# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in part2.v to working dir
# could also have multiple verilog files
vlog part2.v

#load simulation using 7404 as the top level simulation module
vsim part2test

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


force {SW} 8'b00011000
force {KEY} 2'b00
#run simulation for a few ns
run 40ns

force {SW} 8'b00011000
force {KEY} 2'b01
#run simulation for a few ns
run 40ns


force {SW} 8'b00011000
force {KEY} 2'b10
#run simulation for a few ns
run 40ns

force {SW} 8'b00011000
force {KEY} 2'b11
#run simulation for a few ns
run 40ns
