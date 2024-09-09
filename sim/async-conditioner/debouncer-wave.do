onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label clk_tb /debouncer_tb/clk_tb
add wave -noupdate -label rst_tb /debouncer_tb/rst_tb
add wave -noupdate -divider input
add wave -noupdate -color Salmon -label bouncer_tb /debouncer_tb/bouncer_tb
add wave -noupdate -divider output
add wave -noupdate -color Yellow -label {actual: 1000 ns} /debouncer_tb/debounced_tb(0)
add wave -noupdate -color Yellow -label {actual: 10 us} /debouncer_tb/debounced_tb(1)
add wave -noupdate -color Gold -label expected /debouncer_tb/response_checker/debounced_expected
add wave -noupdate -divider DUT
TreeUpdate [SetDefaultTree]
