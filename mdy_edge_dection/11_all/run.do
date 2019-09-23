vlib work       


vlog  ./src/*.v
vlog  ./sim/*.v
vlog  ./ip/*.v

vsim -t ns -novopt +notimingchecks work.sobel_edge_dection_tb

radix hex

add wave -position insertpoint *

run -all