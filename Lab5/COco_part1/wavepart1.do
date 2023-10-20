# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in part2.v to working dir
# could also have multiple verilog files
vlog part1board.v

#load simulation using 7404 as the top level simulation module
vsim part1

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


force Clock 0 0, 1 3ns -repeat 6ns

force Reset 1
run 10ns

force Reset 0
force Enable 1
run 40 ns

force Enable 0
run 15 ns

force Reset 1
run 10ns

force Reset 0
force Enable 1
run 0.2 ms


