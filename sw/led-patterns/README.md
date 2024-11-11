# LED-Patterns Program

## Usage
led-patterns [-h] [-v][-p pattern1, time1, pattern2, time2 ...] [-f filename]

led-patterns can be used to write patterns to the DE-10 Nano's LEDs using software.     

Options:

  **-h** 
  
  show this help message and exit                                    
  
 **-v** 
 
 verbose: print LED pattern displayed as a binary string, as well as how long each pattern is displayed 
 
 IE: LED pattern = 11110000 Time = 500ms
  
  **-f** \[filename] 
  
  file mode: reads from text file of given filename and writes the corresponding patterns. Patterns and time will be given as shown:                                         
  \<pattern1\> \<time1\>                                                 
  \<pattern2\> \<time2\>                                        
  where pattern is a hexadecimal value and time is an unsigned int in ms. MUST be entered as last argument. 
  
  **-p** [pattern1, time1, pattern2 ...]     
  
  pattern mode: display each pattern for its respective time, where pattern is a hexadecimal value and time is an unsigned int in ms. loop until exit command Ctrl-C is entered. If odd number of arguments, print error message and exit. MUST be enetered as last argument.

## Installation Instructions
> [!IMPORTANT]
> Building this code relies on cross-compiling for the 32-bit ARM CPU. Linaro GCC ARM Tools were used for this example.

In order to run, this code must be built, then moved to the proper location on the NFS server (see lab3.md for more info on the server configuration). In order to boot from the server, all configuration slide switches on the FPGA must be in the ON position. Alternatively, the software can be loaded via SD card.

### Linux Command Line Build
```
<linaro_tools_location>-gcc -o led-patterns led-patterns.c
```
### Moving Compiled Program to FPGA

```
cp led-patterns /srv/nfs/de10nano/ubuntu-rootfs/home/soc
```
Files for use in file mode will need to be copied to this same location.

>[!NOTE]
> This depends on the server configuration outlined by lab3.md.
## Hardware Configuration

This system relies on the FPGA being programmed with the led-patterns.rbf file oultlined in lab6.md

