
vlib work       


vlog  ./src/*.v
vlog  ./ip/*.v
vlog  ./sim/*.v

vsim -t ns -novopt +notimingchecks work.test_rx_filter

radix hex

add wave -position insertpoint *

run -all