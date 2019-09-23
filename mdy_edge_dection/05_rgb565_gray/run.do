vlib work       


vlog  ./src/*.v
vlog  ./sim/*.v

vsim -t ns -novopt +notimingchecks  work.rgb565_gray_tb

radix hex

add wave -position insertpoint *

run -all