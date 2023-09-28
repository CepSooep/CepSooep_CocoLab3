# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in part2.v to working dir
# could also have multiple verilog files
vlog part1.v

#load simulation using 7404 as the top level simulation module
vsim part1

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


# c:0 s:0111
force {a} 4'b0100
force {b} 4'b0011
force {c_in} 0
#run simulation for a few ns
run 40ns

# c:0 s:1010
force {a} 4'b1000
force {b} 4'b0010
force {c_in} 0
#run simulation for a few ns
run 40ns

#c:1 s:0010
force {a} 4'b1111
force {b} 4'b0011
force {c_in} 0
#run simulation for a few ns
run 40ns

#c:1 s:1001
force {a} 4'b1101
force {b} 4'b1100
force {c_in} 0
#run simulation for a few ns
run 40ns

#c:0 s:0111
force {a} 4'b0111
force {b} 4'b0000
force {c_in} 0
#run simulation for a few ns
run 40ns
