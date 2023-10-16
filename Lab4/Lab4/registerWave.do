# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in part2.v to working dir
# could also have multiple verilog files
vlog lab4part2.v

#load simulation using 7404 as the top level simulation module
vsim part2

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


force Clock 1 0, 0 6ns -repeat 12ns
#######
force {Function} 2'b00

force Reset_b 1
force {Data} 4'b1111
run 10ns


force {Function} 2'b00

force {Function} 2'b00

force {Function} 2'b00
