
# Homework 9: PWM controller

## Overview
The purpose of this assignment is to establish a PWM signal generator on the FPGA. This generator takes in an unsigned for period time in milliseconds, and a fractional unsigned value for duty cycle percentage.\
\
The period and duty cycle use data types with a custom number of whole and fractional bits, as defined by the lab definition. Using these values, the HDL produces a PWM signal which is on for the specified portion of the period, then off until the end of the period. Values below zero and above one for the duty cycle are hard limited. \
\
This will be used to control a PWM RGB LED for homework 10 and the final project.

## Deliverables

### Modelsim Waveform
|PWM Controller Number | Period | Duty Cycle
|--------|----------|------|
|1|500us|25%|
|2|62.5us|98.4%|
|3|1ms|100% (Hard limited)|

![Modelsim PWM controller waveform](/docs/assets/HW9_Waveform.png)

### Oscilloscope Meaurements
Period = 500 us, Duty Cycle = 25%

![HW9 Oscilloscope Measurement](/docs/assets/HW9_O_scope.png)





