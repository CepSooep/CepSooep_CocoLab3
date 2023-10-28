# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in part2.v to working dir
# could also have multiple verilog files
vlog part3.v

#load simulation using 7404 as the top level simulation module
vsim RateDivider

log /RateDivider/*
add wave /RateDivider/ClockIn /RateDivider/Reset /RateDivider/Speed /RateDivider/Enable

force ClockIn 0 0, 1 1ms -repeat 2ms
force Speed 2'b01

force Reset 1
run 10ms

force Reset 0

run 5700ms




