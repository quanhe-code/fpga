
vlib work       


vlog  ./src/*.v
vlog  ./sim/*.v
vlog  ./ip/*.v

vsim -t ns -novopt +notimingchecks work.test_tx_pack

radix hex

add wave -position insertpoint *

run -all