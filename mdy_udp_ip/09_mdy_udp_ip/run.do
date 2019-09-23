
vlib work       


vlog  ./src/*.v
vlog  ./ip/*.v
vlog  ./sim/*.v

vsim -t ns -novopt +notimingchecks work.test_mdy_udp_ip

radix hex

add wave -position insertpoint *

run -all