vlib work       


vlog  ./src/*.v
vlog  ./sim/*.v

vsim -t ns -novopt +notimingchecks  work.uart_rx_tb

radix hex

add wave -position insertpoint *

run -all