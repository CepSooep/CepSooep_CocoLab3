# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in part2.v to working dir
# could also have multiple verilog files
vlog tester.v

#load simulation using 7404 as the top level simulation module
vsim getDeviceID

#log all signals and add some signals to waveform window
log -r /*
# add wave {/*} would add all items in top level simulation module
add wave {/*}
force clk 0 0, 1 1ms -repeat 2ms

force reset 0
force switch 0
run 20ms

force reset 1
run 5ms

force switch 1
run 50ms

force switch 0 
run 150 ms

force reset 1
run 5ms

force switch 1
run 50ms

force switch 0 
run 150 ms


