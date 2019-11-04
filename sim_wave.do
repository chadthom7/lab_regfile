onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /rpncalc/clk
add wave -noupdate /rpncalc/rst
add wave -noupdate /rpncalc/mode
add wave -noupdate /rpncalc/key
add wave -noupdate /rpncalc/val
add wave -noupdate /rpncalc/top
add wave -noupdate /rpncalc/next
add wave -noupdate /rpncalc/counter
add wave -noupdate /rpncalc/pop
add wave -noupdate /rpncalc/push
add wave -noupdate /rpncalc/key_push
add wave -noupdate /rpncalc/op
add wave -noupdate /rpncalc/key_dly
add wave -noupdate /rpncalc/key_dly2
add wave -noupdate /rpncalc/shamt
add wave -noupdate /rpncalc/A
add wave -noupdate /rpncalc/B
add wave -noupdate /rpncalc/Aout
add wave -noupdate /rpncalc/Bout
add wave -noupdate /rpncalc/stack_top
add wave -noupdate /rpncalc/stack_top_minus_one
add wave -noupdate /rpncalc/val2
add wave -noupdate /rpncalc/current_state
add wave -noupdate /rpncalc/next_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {274 ns}
