onerror {abort all} 
do compile.do

vcom -93 -explicit ../st_comb_tb.vhd

quit -sim 
vsim -voptargs=+acc -t 1ps st_comb_tb


view -undock -height 900 -width 1400 -x 0 -y 0 wave

do wave.do
run 100000 ns 
radix hex