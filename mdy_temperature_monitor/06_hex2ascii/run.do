vlib work       


vlog  ./src/*.v
vlog  ./sim/*.v

vsim -t ns -novopt +notimingchecks  work.hex2asscii_tb

radix hex

add wave -position insertpoint *

run -all