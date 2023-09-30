# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in part2.v to working dir
# could also have multiple verilog files
vlog part3.v

#load simulation using 7404 as the top level simulation module
vsim part3tester

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


force {A} 4'b000000
force {B} 4'b000100
force {KEY} 2'b00
#run simulation for a few ns
run 10ns

force {A} 4'b111110
force {B} 4'b111111
force {KEY} 2'b00
#run simulation for a few ns
run 10ns

force {A} 4'b010011
force {B} 4'b001100
force {KEY} 2'b01
#run simulation for a few ns
run 10ns

force {A} 4'b000000
force {B} 4'b000000
force {KEY} 2'b01
#run simulation for a few ns
run 10ns

force {A} 4'b010101
force {B} 4'b001111
force {KEY} 2'b01
#run simulation for a few ns
run 10ns

force {A} 4'b111111
force {B} 4'b111111
force {KEY} 2'b01
#run simulation for a few ns
run 10ns

force {A} 4'b000000
force {B} 4'b000000
force {KEY} 2'b10
#run simulation for a few ns
run 10ns

force {A} 4'b111111
force {B} 4'b111111
force {KEY} 2'b10
#run simulation for a few ns
run 10ns

force {A} 4'b100011
force {B} 4'b001010
force {KEY} 2'b10
#run simulation for a few ns
run 10ns

force {A} 4'b011111
force {B} 4'b000001
force {KEY} 2'b11
#run simulation for a few ns
run 10ns
