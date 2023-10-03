# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in part2.v to working dir
# could also have multiple verilog files
vlog part1.v

#load simulation using 7404 as the top level simulation module
vsim part1test

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


# c:0000000000000
force {SW} 10'b0000000000
#run simulation for a few ns
run 40ns

# c:1111111111111
force {SW} 10'b0111111111
#run simulation for a few ns
run 40ns

# c:0000000000001
force {SW} 10'b0000000001
#run simulation for a few ns
run 40ns

