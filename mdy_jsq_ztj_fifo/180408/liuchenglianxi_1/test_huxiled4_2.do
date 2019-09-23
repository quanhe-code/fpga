vlib work       


vlog  ./src/*.v
vlog  ./sim/*.v

vsim -t ns -novopt +notimingchecks  work.test_huxiled4_2

radix hex

add wave -position insertpoint *

run -all