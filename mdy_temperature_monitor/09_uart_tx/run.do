vlib work       


vlog  ./src/*.v
vlog  ./sim/*.v

vsim -t ns -novopt +notimingchecks  work.uart_tx_tb

radix hex

add wave -position insertpoint *

run -all