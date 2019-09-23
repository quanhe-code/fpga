vlib work       


vlog  ./src/*.v
vlog  ./sim/*.v
vlog  ./ip/*.v

vsim -t ns -novopt +notimingchecks work.vga_test_tb

radix hex

add wave -position insertpoint *

run -all