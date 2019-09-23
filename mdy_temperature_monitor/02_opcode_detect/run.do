vlib work       


vlog  ./src/*.v
vlog  ./sim/*.v

vsim -t ns -novopt +notimingchecks  work.opcode_detect_tb

radix hex

add wave -position insertpoint *

run -all