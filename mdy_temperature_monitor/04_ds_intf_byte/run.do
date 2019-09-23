vlib work       


vlog  ./src/*.v
vlog  ./sim/*.v

vsim -t ns -novopt +notimingchecks  work.ds_intf_byte_tb

radix hex

add wave -position insertpoint *

run -all