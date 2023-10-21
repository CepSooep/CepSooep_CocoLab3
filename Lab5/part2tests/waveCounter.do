# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in part2.v to working dir
# could also have multiple verilog files
vlog part2.v

#load simulation using 7404 as the top level simulation module
vsim DisplayCounter

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

force Clock 0 0, 1 1ms -repeat 2ms

force Reset 1
force EnableDC 1
run 1.5ms

force Reset 0
force EnableDC 1
run 8ms

force EnableDC 0
run 4ms

force EnableDC 1
run 30ms
 
force Reset 1
run 3ms