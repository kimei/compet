onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cru_tb/dut/inst_pll_all/clkfbout_clkfbin
add wave -noupdate /cru_tb/dut/inst_pll_all/clkin1_ibufg
add wave -noupdate /cru_tb/dut/inst_pll_all/clkout0_buf
add wave -noupdate /cru_tb/dut/inst_pll_all/clkout1_buf
add wave -noupdate /cru_tb/fpga_100m_clk
add wave -noupdate /cru_tb/fpga_cpu_reset_b
add wave -noupdate /cru_tb/dut/clk_lock
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {620000 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1024 ns}
