# Lab 8: Creating Led Patterns Using Software

## Overview
This lab was focused on using the hardware/software configurations defined by labs 6 and 7 to write LED patterns to the DE-10 Nano using a C program. The C program parses arguments from a linux command line. From this point, the program writes patterns defined either in the command line or in a specified file. Options to display usage information and display pattern information in the command line terminal were also implemented.

## Deliverables

[Link to led-patterns README](/sw/led-patterns/README.md)
> How did you calculate the phsyical addresses of your component's registers? 

The base address of my component is 0x0. This is offset by the address of the HPS-to-FPGA lightweight bridge, 0xff200000. Because each register is 4 bytes (32 bits), the registers are spaced 4 addresses apart starting at this offset address. This gives a final equation of:

Pysical Address = 0xff200000 + 0x0 + (4 * register number)