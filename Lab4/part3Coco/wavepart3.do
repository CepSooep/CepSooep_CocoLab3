# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in part2.v to working dir
# could also have multiple verilog files
vlog part3.v

#load simulation using 7404 as the top level simulation module
vsim part3

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

#pre-testing
force clock 0 0, 1 6ns -repeat 12ns
force reset 1
force ParallelLoadn 0
force RotateRight 0
force ASRight 0
force Data_IN 4'b0111
run 5ns

########################## setting ###########
force ParallelLoadn 0
force RotateRight 1
force ASRight 0
force Data_IN 4'b0111
run 10ns

force reset 0
force ParallelLoadn 0
force RotateRight 0
force ASRight 1
force Data_IN 4'b1001
run 10ns 

################### testing ParallelLoadn = 1, RotateRight = 1, ASRIGht = 1 ###########

force ParallelLoadn 1
force RotateRight 1
force ASRight 1
force Data_IN 4'b0000
run 10ns

force ParallelLoadn 1
force RotateRight 1
force ASRight 1
force Data_IN 4'b1111
run 10ns

force ParallelLoadn 1
force RotateRight 1
force ASRight 1
force Data_IN 4'b0011
run 10ns

force ParallelLoadn 1
force RotateRight 1
force ASRight 1
force Data_IN 4'b0000
run 10ns

force reset 1
run 10ns
force reset 0

force ParallelLoadn 0
force RotateRight 1
force ASRight 1
force Data_IN 4'b0101
run 10ns

force ParallelLoadn 1
force RotateRight 1
force ASRight 1
force Data_IN 4'b0000
run 10ns

force ParallelLoadn 1
force RotateRight 1
force ASRight 1
force Data_IN 4'b0000
run 10ns

force ParallelLoadn 1
force RotateRight 1
force ASRight 1
force Data_IN 4'b0000
run 10ns

##################################  testing ParallelLoadn = 0 #######################
force ParallelLoadn 0
force RotateRight 1
force ASRight 0
force Data_IN 4'b0111
run 10ns

force ParallelLoadn 0
force RotateRight 0
force ASRight 1
force Data_IN 4'b0001
run 10ns 

force ParallelLoadn 0
force RotateRight 1
force ASRight 1
force Data_IN 4'b0000
run 10ns

force ParallelLoadn 0
force RotateRight 0
force ASRight 0
force Data_IN 4'b1011
run 10ns

################### testing ParallelLoadn = 1 RotateRight = 1 ASRIGht = 0 ###########
force ParallelLoadn 1
force RotateRight 1
force ASRight 0
force Data_IN 4'b0000
run 10ns

force ParallelLoadn 1
force RotateRight 1
force ASRight 0
force Data_IN 4'b1111
run 10ns

force ParallelLoadn 1
force RotateRight 1
force ASRight 0
force Data_IN 4'b0011
run 10ns

force ParallelLoadn 1
force RotateRight 1
force ASRight 0
force Data_IN 4'b0000
run 60ns


################### testing ParallelLoadn = 1, RotateRight = 0 ###########
force ParallelLoadn 1
force RotateRight 0
force ASRight 0
force Data_IN 4'b0000
run 10ns

force ParallelLoadn 1
force RotateRight 0
force ASRight 0
force Data_IN 4'b1111
run 10ns

force ParallelLoadn 1
force RotateRight 0
force ASRight 1
force Data_IN 4'b0011
run 10ns

force ParallelLoadn 1
force RotateRight 0
force ASRight 1
force Data_IN 4'b0000
run 20ns

force ParallelLoadn 1
force RotateRight 0
force ASRight 0
force Data_IN 4'b0001
run 20ns
