vlib work       


vlog  ./src/*.v
vlog  ./sim/*.v

vsim -t ns -novopt +notimingchecks  work.ov7670_config_tb

radix hex

add wave -position insertpoint *

run -all