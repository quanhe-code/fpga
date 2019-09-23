vlib work       


vlog  ./src/*.v
vlog  ./sim/*.v

vsim -t ns -novopt +notimingchecks  work.smg_tb2

radix hex

add wave -position insertpoint *

run -all