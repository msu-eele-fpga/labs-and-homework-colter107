
# Lab 6: Creating a Custom Component in Platform Designer 

## Overview
This lab was about creting a custom component in platform designer to control the FPGA's LEDs from software. This involves connecting the led_patterns_avalon component to the HPS-to-FPGA lightweight bus, and using this bus to read and write dfrom hardware-defined registers to control the LEDs.

## Deliverables
### System Architecture

The hardware component of the system is set up identically to lab 4. The push buttons on the FPGA are connected to an asynchronous conditioner, consisting of a synchronizer, debouncer, and one-pulse component. From this point, they are used as the push button and reset signals for the LED pattern component's FSM. The FPGA's switches are connected as the switch input for this same FSM. The system's 50 mHz clock is fed into 5 clock generator components, which convert the 50mHz clock to the appropriate clocks for each LED pattern, as specified by the user-inputted base period. The appropriate clock signals are then fed to LED7 in the case of the base period clock, and pattern generator components in the case of the other clock signals. These pattern generator components generate the patterns for the FSM. From this point, the FSM feeds the appropriate pattern to the remaining 6 LEDs on the FPGA, outputting the pattern number specified by the switches on a push button input. 

For the software controlled part of the system, 3 registers were established to store the desired control mode, base period, and the software defined LED state. This is done using the HPS to FPGA lightweight bus. Read signals are sent over this bus to the FPGA to read in the base period, control mode, and software-defined LED pattern. Conversely, write signals are sent over this bus to the HPS to update these registers when in the hardware control mode.

![Lab 6 architecture block diagram](/docs/assets/Lab6_BlockDiagram.jpg)

### Register Map

Three registers were created for this project, each with a width of 32 bits. led_reg[6:0] is written to the system's LEDs when it is controlled by the HPS. The rest of the register is unused. Base_period[7:0] is used to set the base period of the LED patterns when in hardware control mode. Again, the rest of the register is unused. HPS_led_control[0] toggles the device between hardware and software control modes, with a 1 indicating software control and 0 indicating hardware control. These registers are mapped to the addresses shown below:

| Register | Address |
| -------- | ------- |
| led_reg  | 00      |
| base_period | 01 |
| hps_led_control | 10 |

![HPS system registers bitfield diagram](/docs/assets/Lab6_Bitfield.png)



### Platform Designer  

> How did you connect these registers to the ARM CPUs in the HPS?

The registers are defined in the HDL, and use a case statement to handle read/write options. Variables named avs_read and avs_write are used to enable read/write, and the appropriate register is read/written to using a switch/case statement based on the desired address. avs_readdata and avs_writedata are used to allow the system to automatically register these as the HPS read/write data.

In platform designer,the memory-mapped interface is connected to the lightweight HPS bus (h2f_lw_axi_master). This then is connected to the HPS system. The HPS lightweight bus also has an export conduit to export led patterns signals. 


> What is the base address of your component in your Platform Designer system?

0x0


