#vlog *.sv
#vlog *.sv
#add log -r /*
restart -f

#restart -f
vlog -novopt *.sv
vsim -novopt work.rpncalc

# add everything
#add wave -r /rpncalc/*

# add specific things
add wave /CSCE611_regfile_testbench/rpncalc/shamt
add wave /CSCE611_regfile_testbench/rpncalc/clk
add wave /CSCE611_regfile_testbench/rpncalc/rst
add wave /CSCE611_regfile_testbench/rpncalc/mode
add wave /CSCE611_regfile_testbench/rpncalc/key
add wave /CSCE611_regfile_testbench/rpncalc/val
add wave /CSCE611_regfile_testbench/rpncalc/val2
add wave /CSCE611_regfile_testbench/rpncalc/top
add wave /CSCE611_regfile_testbench/rpncalc/next
add wave /CSCE611_regfile_testbench/rpncalc/counter
add wave /CSCE611_regfile_testbench/rpncalc/pop
add wave /CSCE611_regfile_testbench/rpncalc/push
add wave /CSCE611_regfile_testbench/rpncalc/key_push
add wave /CSCE611_regfile_testbench/rpncalc/op
add wave /CSCE611_regfile_testbench/rpncalc/key_dly
add wave /CSCE611_regfile_testbench/rpncalc/key_dly2
add wave /CSCE611_regfile_testbench/rpncalc/A
add wave /CSCE611_regfile_testbench/rpncalc/B
add wave /CSCE611_regfile_testbench/rpncalc/Aout
add wave /CSCE611_regfile_testbench/rpncalc/Bout
add wave /CSCE611_regfile_testbench/rpncalc/stack_top
add wave /CSCE611_regfile_testbench/rpncalc/stack_top_minus_one
#add wave /CSCE611_regfile_testbench/rpncalc/idle
#add wave /CSCE611_regfile_testbench/rpncalc/pop1
#add wave /CSCE611_regfile_testbench/rpncalc/pop2
#add wave /CSCE611_regfile_testbench/rpncalc/push1
add wave /CSCE611_regfile_testbench/rpncalc/current_state
add wave /CSCE611_regfile_testbench/rpncalc/next_state
add wave /CSCE611_regfile_testbench/rpncalc/top_captured
add wave /CSCE611_regfile_testbench/rpncalc/next_captured

 

# key3 = 0111 or 7     key2= 1011 or 11 or b    key1 = 1101 or 13 or d     key0 = 1110 or 14 or e
# mode, key, val, as input

force -freeze sim:/rpncalc/clk 1 0, 0 {50 ns} -r 100

run

		# Test Push then Addition
# Push 1st Val
force val 16'h0001
run
force mode 2'b00
run
force key 4'h7
run

# Push 2nd Val
force val 16'h0002
force mode 2'b00
force key 4'h7
run

# Addition:
force mode 2'b00
force key 4'he
run
	# top should be 16'h0003
# ----------------------------------------
		# Test Push then Addition

# Already one val on the stack should be 

# Push 2nd Val
force val 16'h000c
force mode 2'b00
force key 4'h7
run

# Addition:
force mode 2'b00
force key 4'he
run
	# top should be 16'h000f
# ----------------------------------------




run 500
run 300

view transcript
view wave
wave zoom full
