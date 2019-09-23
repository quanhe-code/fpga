vlib work       


vlog  ./src/*.v
vlog  ./sim/*.v
vlog  ./ip/*.v

vsim -t ns -novopt +notimingchecks work.testfifo2_6

radix hex

add wave -position insertpoint *

run -all