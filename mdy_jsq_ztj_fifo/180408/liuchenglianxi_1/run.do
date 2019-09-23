vlib work       


vlog  ./src/*.v
vlog  ./sim/*.v

vsim -t ns -novopt +notimingchecks  work.test_huxiled4_time

radix hex

add wave -position insertpoint *

run -all