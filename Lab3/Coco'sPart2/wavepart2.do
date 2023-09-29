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


force {A} 4'b0000
force {B} 4'b0001
force {Function} 2'b00
#run simulation for a few ns
run 10ns

force {A} 4'b1111
force {B} 4'b1111
force {Function} 2'b00
#run simulation for a few ns
run 10ns

force {A} 4'b1000
force {B} 4'b0001
force {Function} 2'b00
#run simulation for a few ns
run 10ns

force {A} 4'b0100
force {B} 4'b0011
force {Function} 2'b01
#run simulation for a few ns
run 10ns

force {A} 4'b0000
force {B} 4'b0000
force {Function} 2'b01
#run simulation for a few ns
run 10ns

force {A} 4'b0101
force {B} 4'b0011
force {Function} 2'b01
#run simulation for a few ns
run 10ns

force {A} 4'b1111
force {B} 4'b0011
force {Function} 2'b10
#run simulation for a few ns
run 10ns

force {A} 4'b0000
force {B} 4'b0000
force {Function} 2'b10
#run simulation for a few ns
run 10ns

force {A} 4'b1111
force {B} 4'b1111
force {Function} 2'b10
#run simulation for a few ns
run 10ns

force {A} 4'b1000
force {B} 4'b0010
force {Function} 2'b11
#run simulation for a few ns
run 10ns

force {A} 4'b1101
force {B} 4'b1100
force {Function} 2'b11
#run simulation for a few ns
run 10ns

force {A} 4'b0111
force {B} 4'b0000
force {Function} 2'b11
#run simulation for a few ns
run 10ns

