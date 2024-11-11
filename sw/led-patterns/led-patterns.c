#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/mman.h> //for map
#include <fcntl.h> //for file open flags
#include <getopt.h>
#include <unistd.h> //for getting the page size
#include <math.h>
#include <string.h>
#include <signal.h>

/**
 * usage() - Prints usage info for led-patterns.c
 */
void usage()
{
    fprintf(stderr, "usage: led-patterns [-h] [-v] [-p pattern1, time1, pattern2, time2 ...] [-f filename]\n");
    fprintf(stderr, "led-patterns can be used to write patterns to the DE-10 Nano's LEDs using software.\n\n");
    fprintf(stderr, "Options:\n");
    fprintf(stderr, "-h                                     show this help message and exit \n");
    fprintf(stderr, "-v                                     verbose: print LED pattern displayed as a\n");
    fprintf(stderr, "                                       binary string, as well as how long each \n");
    fprintf(stderr, "                                       pattern is displayed\n");
    fprintf(stderr, "                                       IE: LED pattern = 11110000\n");
    fprintf(stderr, "                                       Time = 500ms\n");
    fprintf(stderr, "-f [filename]                          file mode: reads from text file of given \n");
    fprintf(stderr, "                                       filename and writes the corresponding patterns.\n");
    fprintf(stderr, "                                       Patterns and time will be given as shown:\n");
    fprintf(stderr, "                                           <pattern1> <time1> \n");
    fprintf(stderr, "                                           <pattern2> <time2>\n");
    fprintf(stderr, "                                       where pattern is a hexadecimal value and\n");
    fprintf(stderr, "                                       time is an unsigned int in ms. \n");
    fprintf(stderr, "-p [pattern1, time1, pattern2 ...]     pattern mode: display each pattern for\n");
    fprintf(stderr, "                                       its respective time, where pattern is a\n");
    fprintf(stderr, "                                       hexadecimal value and time is an");
    fprintf(stderr, "                                       unsigned int in ms. \n");
    fprintf(stderr, "                                       loop until exit command Ctrl-C is entered. \n");
    fprintf(stderr, "                                       if odd number of arguments, print error message\n");
    fprintf(stderr, "                                       and exit.MUST be enetered as last argument.\n");
    fprintf(stderr, "\n");
}

/**
 * devmem_read(char reg) - reads a register using /dev/mem
 * @reg: Register to read from
 * 
 * This method is used to automatically add the appropriate offset and calculate the virtual address for devmem read. This was done
 * so read operations can be simplified only passing in the register to read.
 * This is based on devmem.c. Original comments from that file have been left for clarity when debugging.
 * 
 * Return: uint32_t VALUE
 * This is the value that was read from the register
 */
int devmem_read(char reg){
    const size_t PAGE_SIZE = sysconf(_SC_PAGE_SIZE);
    uint32_t reg_offset = 4*reg;
    const uint32_t ADDRESS = 0xff200000 + reg_offset;

    //Open the /dev/mem file, which is an image of the main system memory.
    //Using synchronous write operations (O_SYNC) to ensure that the value
    //is fully written to the underlying hardware before the write call returns
    int fd = open("../../dev/mem", O_RDWR | O_SYNC);
    if (fd == -1)
    {
        fprintf(stderr, "failed to open /dev/mem. \n");
        return 1;
    }
    
    //mmap needs to map memory at page boundaries (address we're mapping must be aligned to a page).
    //~(PAGE_SIZE -1) bitmask returns the closest page-alligned address that contains ADDRESS in the page.
    //For 4096 byte page, (PAGE_SIZE -1 ) = 0xFFF; after flipping and converting to 32-bit we have a mask of -xFFFF_F000.
    //AND'ing with this mask will make the 3 least significant nibbles of ADDRESS 0.
    //This ensures the returned address is a multple of page size. Because 4096 - 0x1000, anything with three zeros for
    //the least significant nibbles must be a multiple.

    uint32_t page_aligned_addr = ADDRESS & ~(PAGE_SIZE - 1);

    // Map a page of physical memory into virtual memory. 
    // mor infos at mmap man page: https://www.man7.org/linux/man-pages/man2/mmap.2.html
    uint32_t *page_virtual_addr = (uint32_t *)mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, page_aligned_addr);
    if(page_virtual_addr == MAP_FAILED)
    {
        fprintf(stderr, "failed to map memory. \n");
        return 1;
    }

    //The address we want to access is probably not page-aligned, so we need to find how far away from the page boundary it is.
    //Using this offset, we can compute the virtual addres corresponding to the physical targed address (ADDRESS)
    uint32_t offset_in_page =  ADDRESS & (PAGE_SIZE -1);

    //Compute virtual address corrsponding to ADDRESS.
    //Because virtual addresses are both uint32_t (integer) pointers, the pointer addition multiplies the address by the number
    //of bytes needed to store a uint32_t. This is not what we want. So, we divide by this size (4 bytes) to make it return the
    //right address. 

    //We use volatile because the target virtual address could change outside the program.
    //Volatile tells the compiler to not optimize accesses to this address.
    volatile uint32_t *target_virtual_addr = page_virtual_addr + offset_in_page/sizeof(uint32_t*);

    return(*target_virtual_addr);
}   

/**
 * devmem_write(char reg, uint32_t write_value) - Write to a register using dev/mem.
 * @reg: register to read from
 * @write_value: value to write
 * 
 * This method is used to automatically add the appropriate offset and calculate the virtual address for devmem write. This was done
 * so write operations can be simplified to passing 2 arguments. write_value MUST be a uint32_t, as the device has 32-bit registers.
 * This is based on devmem.c. Original comments from that file have been left for clarity when debugging.
 */
int devmem_write(char reg, uint32_t write_value){
    const size_t PAGE_SIZE = sysconf(_SC_PAGE_SIZE);
    uint32_t reg_offset = 4*reg;
    const uint32_t ADDRESS = 0xff200000 + reg_offset;

    //Open the /dev/mem file, which is an image of the main system memory.
    //Using synchronous write operations (O_SYNC) to ensure that the value
    //is fully written to the underlying hardware before the write call returns
    int fd = open("../../dev/mem", O_RDWR | O_SYNC);
    if (fd == -1)
    {
        fprintf(stderr, "failed to open /dev/mem. \n");
        return 1;
    }
    
    //mmap needs to map memory at page boundaries (address we're mapping must be aligned to a page).
    //~(PAGE_SIZE -1) bitmask returns the closest page-alligned address that contains ADDRESS in the page.
    //For 4096 byte page, (PAGE_SIZE -1 ) = 0xFFF; after flipping and converting to 32-bit we have a mask of -xFFFF_F000.
    //AND'ing with this mask will make the 3 least significant nibbles of ADDRESS 0.
    //This ensures the returned address is a multple of page size. Because 4096 - 0x1000, anything with three zeros for
    //the least significant nibbles must be a multiple.

    uint32_t page_aligned_addr = ADDRESS & ~(PAGE_SIZE - 1);

    // Map a page of physical memory into virtual memory. 
    // mor infos at mmap man page: https://www.man7.org/linux/man-pages/man2/mmap.2.html
    uint32_t *page_virtual_addr = (uint32_t *)mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, page_aligned_addr);
    if(page_virtual_addr == MAP_FAILED)
    {
        fprintf(stderr, "failed to map memory. \n");
        return 1;
    }


    //The address we want to access is probably not page-aligned, so we need to find how far away from the page boundary it is.
    //Using this offset, we can compute the virtual addres corresponding to the physical targed address (ADDRESS)
    uint32_t offset_in_page =  ADDRESS & (PAGE_SIZE -1);


    //Compute virtual address corrsponding to ADDRESS.
    //Because virtual addresses are both uint32_t (integer) pointers, the pointer addition multiplies the address by the number
    //of bytes needed to store a uint32_t. This is not what we want. So, we divide by this size (4 bytes) to make it return the
    //right address. 

    //We use volatile because the target virtual address could change outside the program.
    //Volatile tells the compiler to not optimize accesses to this address.
    volatile uint32_t *target_virtual_addr = page_virtual_addr + offset_in_page/sizeof(uint32_t*);

    const uint32_t VALUE = (uint32_t)write_value;
    *target_virtual_addr = VALUE;
    return 0;
}

/**
 * print_binary(int to_binary) - Prints an int as its binary representation.
 * @to_binary: Int to be converted and printed
 * 
 * Printing to console was chosen instead of returning the string here so that the memory can be allocated and freed in the same
 * function. For the purpose of this program, the result never needs to be stored.
 */
void print_binary(int to_binary){
    char* string_to_print = malloc(8 * sizeof(char));
    for(int i = 6; i>=0; i--){
        if(to_binary % 2 == 0){
           string_to_print[i] = '0';
        } else {
            string_to_print[i] = '1';
        }
        to_binary >>= 1;
    }
    string_to_print[7] = '\0';
    printf("%s", string_to_print);
    free (string_to_print);
}

static volatile bool loop_patterns = true;

/**
 * int_handler(int dummy) - handler for ctrl+c interrupt
 * @dummy: information from signal handler. Required by the signal, but not used in this function.
 * 
 * Stops the patterns from looping in pattern mode and closes the program
 */
void int_handler(int dummy){
    loop_patterns = false;
    devmem_write(0,0);
}
    
/**
 * main(int argc, char **argv) - main functionality of led-patterns
 * 
 * @argc: command line argument count
 * @argv: command line arguments
 * 
 * Writes patterns to the DE10-Nano's LEDs while it is running the led-patterns .rbf file. 
 * Type "./led-patterns -h" for in-depth usage information.
 * 
 * Return: Exit code. Returns 0 if successful exit, 1 if error
 */
int main(int argc, char **argv)
{   
    //Command line arguments 
    int option;
    bool verbose = false;
    bool pattern_mode = false;
    bool file_mode = false;
    char file_name[100] = "";

    //Start index for led pattern data if -p is used
    int pattern_start_index = 2;

    if (argc == 1)
    {
        //No arguments were given, so just print usage text and exit
        //NOTE: first argument is just the program name, so argv[1] is 
        //the first *real* argument
        usage();
        return 1;
    }

    //Get CLI's to set appropriate mode
    while((option = getopt(argc,argv,"hvp:f:")) != -1)
    {
        switch(option)
        {
            case 'h':
                usage();
                pattern_start_index++;
                break;

            case 'v':
                verbose = true;
                pattern_start_index++;
                break;

            case 'p':
                pattern_mode = true;
                break;

            case 'f':
                file_mode = true;
                if (optarg != NULL) 
                {
                    strcpy(file_name,optarg);
                } 
                else 
                {
                    printf("Missing File Name\n");
                    printf("Exiting program...\n");
                    return 1;
                }

                break;
            case '?':
                printf("Unknown argument %c\n", optopt);
                usage();
                printf("Exiting program... \n");
                return 1;
        }
        

        if(file_mode && pattern_mode)
        {
            printf("ERROR: both file mode and pattern mode given\n");
            printf("Exiting program... \n");
            return 1;
        }
    }
    //Pattern mode functionality
    if(pattern_mode)
    {  
        //Set to hardware control mode
        devmem_write(0,0x1);
        //Handle if odd number of pattern arguments
        if((argc - pattern_start_index) % 2 != 0)
        {
            printf("Error: Each pattern was not given a matching time value\n");
            printf("Exiting program... \n");
            return 1;
        } 
        signal(SIGINT, int_handler);
        //Read and loop patterns until ctrl+c
        while(loop_patterns == true)
        {
            for(int i = pattern_start_index; i < argc; i++)
            {
                uint32_t pattern_to_write = strtoul(argv[i], NULL, 0);
                if(verbose)
                {
                    printf("LED Pattern = ");
                    print_binary(pattern_to_write);
                }
                devmem_write(2, pattern_to_write);
                i++;
                int sleep_time_s = strtoul(argv[i], NULL, 0);
                float sleep_time_ms = (float)sleep_time_s/1000;
                if(verbose)
                {
                    printf(" Time: %d ms\n",sleep_time_s);
                }
                sleep(sleep_time_ms);
            }
        }
    } 
    //File mode functionality
    else if (file_mode)
    {
        //Try to read file
        FILE* fin = fopen(file_name, "r");
        if(fin == NULL)
        {
            printf("ERROR: file \"%s\" not found\n", file_name);
            return 0;
        }
        //If successful, read patterns in file, write to LEDs
        else 
        {
            char line[256];
            while(fgets(line,sizeof(line),fin))
            {
                uint32_t pattern_to_write = strtoul(strtok(line," "), NULL, 0);
                if(verbose)
                {
                    printf("LED Pattern = ");
                    print_binary(pattern_to_write);
                }
                devmem_write(2, pattern_to_write);
                uint32_t sleep_time_s = strtoul(strtok(NULL,"\n"), NULL, 0);
                float sleep_time_ms = (float)sleep_time_s/1000;
                if(verbose)
                {
                    printf(" Time: %d ms\n",sleep_time_s);
                }
                sleep(sleep_time_ms);
            }
            fclose(fin);
        }
    } 
}
