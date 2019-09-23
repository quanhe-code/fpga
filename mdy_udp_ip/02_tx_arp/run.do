
vlib work       


vlog  ./src/*.v
vlog  ./sim/*.v

vsim -t ns -novopt +notimingchecks work.test_tx_arp

radix hex

add wave -position insertpoint *

run -all