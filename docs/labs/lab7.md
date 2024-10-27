

# Lab 7: Verifying Your Custom Component Using System Console and `/dev/mem`

## Overview
The purpose of this lab was to verify the functionality of the registers created for the HPS in lab 6. This was first done using the System Console, then using busybox devmem. Finally, a devmem c file was written and cross-compiled for the SoC on the FPGA. This wa used one final time to verify the SOC system's registers.

## Deliverables
### Questions 

> What hex value did you write to base_period to have a 0.125 second base period?

0000 0010b = 0x02h

> What hex value did you write to base_period to have a 0.5625 second base period? 

0000 1010b = 0x0Ah

