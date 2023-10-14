# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in part2.v to working dir
# could also have multiple verilog files
vlog part2.v

#load simulation using 7404 as the top level simulation module
vsim Reg8

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

force clk 0 0, 1 6ns -repeat 12ns

force reset_b 1


force d 8'b10101011
run 20ns


force reset_b 0
force d 8'b00000000
run 20ns


force d 8'b10101011
run 20ns

force d 8'b00011111
run 15ns

force d 8'b11000001
run 10ns