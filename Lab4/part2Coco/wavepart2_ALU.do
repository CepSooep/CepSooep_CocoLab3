# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in part2.v to working dir
# could also have multiple verilog files
vlog part2.v

#load simulation using 7404 as the top level simulation module
vsim ALU

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

force f 2'b10

force A 3'b0000
force B 3'b0001
run 10ns

force B 3'b1111
run 10ns

force A 3'b1111
run 10ns

force A 3'b1000
run 10ns

force A 3'b0010
run 10ns

force A 3'b0001
run 10ns





