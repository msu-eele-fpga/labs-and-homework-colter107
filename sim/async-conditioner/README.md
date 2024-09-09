# Questa simulation files for the async conditioner

## Debouncer
The `debouncer-sim.do` file can be run to launch the simulation with optimizations disabled (so we can see all the signals and variables in the testbench) and with vsim set to stop instead of quit when encountering `std.env.finish`. In the transcript window, run
```
do deboucner-sim.do
```

`debouncer-wave.do` will setup a basic waveform window that shows the debouncer input, both debouncer outputs, and the expected output. Once the simulation is running, run
```
do debouncer-wave.do
```
in the transcript window.
