# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in part2.v to working dir
# could also have multiple verilog files
vlog KarthikRateDividertesting.v

#load simulation using 7404 as the top level simulation module
vsim RateDivider

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


force ClockIn 0 0, 1 1ms -repeat 2ms
force Speed 2'b01

force Reset 1
run 1.5ms

force Reset 0
run 3005ms

force Speed 2'b10
run 2500ms




 