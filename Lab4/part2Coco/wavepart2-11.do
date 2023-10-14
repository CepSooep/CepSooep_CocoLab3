# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in part2.v to working dir
# could also have multiple verilog files
vlog part2.v

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

force Reset_b 0
force {Data} 4'b0101
run 15ns

#######
force {Function} 2'b11

force {Data} 4'b0010
run 10ns

force {Data} 4'b0011
run 10ns

force {Data} 4'b0100
run 10ns

#####
force {Function} 2'b00

force {Data} 4'b1100
run 10ns

###########
force {Function} 2'b11

force {Data} 4'b0000
run 10ns

force {Data} 4'b0001
run 10ns

force {Data} 4'b1000
run 10ns



force Reset_b 1
run 15ns

force Reset_b 0

force {Data} 4'b1111
run 10ns

force {Data} 4'b1111
run 10ns



force {Data} 4'b1111
run 10ns


