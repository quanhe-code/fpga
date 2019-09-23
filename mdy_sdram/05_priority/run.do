
vlib work       


vlog  ./src/*.v
vlog  ./sim/*.v

vsim -t ns -novopt +notimingchecks work.sdram_test

radix hex

add wave -position insertpoint *

run -all