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

void printBinary(int toBinary){
    char* toPrint = malloc(8 * sizeof(char));
    for(int i = 6; i>=0; i--){
        if(toBinary % 2 == 0){
           toPrint[i] = '0';
        } else {
            toPrint[i] = '1';
        }
        toBinary >>= 1;
    }
    toPrint[7] = '\0';
    printf("%s", toPrint);
    free (toPrint);
}

static volatile bool loopPatterns = true;

void intHandler(int dummy){
    loopPatterns = false;
}
    

int main(int argc, char **argv)
{   
    int option;
    bool verbose;
    bool patternMode = false;
    bool fileMode = false;
    int patternStartIndex = 2;

    if (argc == 1)
    {
        //No arguments were given, so just print usage text and exit
        //NOTE: first argument is just the program name, so argv[1] is 
        //the first *real* argument
        usage();
        return 1;
    }

    option = getopt(argc,argv,"hvpf:");
    while(option != -1){
        switch(option){
            case 'h':
                usage();
                patternStartIndex++;
                break;
            case 'v':
                verbose = true;
                patternStartIndex++;
                break;
            case 'p':
                patternMode = true;
                break;
            case 'f':
                fileMode = true;
                printf("FILEAAAA");
                break;
            case '?':
                printf("Unknown argument %c\n", optopt);
                printf("Exiting program... \n");
                return 1;
        }
        

        if(fileMode && patternMode){
            printf("ERROR: both file mode and pattern mode given\n");
            printf("Exiting program... \n");
            return 1;
        }

        option = getopt(argc,argv,"hvpf");
    }

    if(patternMode){
        
        devmem_write(0,0x1);
        if((argc - patternStartIndex) % 2 != 0){
            printf("Error: Each pattern was not given a matching time value\n");
            printf("Exiting program... \n");
            return 1;
        } 

        signal(SIGINT, intHandler);
        while(loopPatterns == true){
            for(int i = patternStartIndex; i < argc; i++){
                uint32_t patternToWrite = strtoul(argv[i], NULL, 0);
                if(verbose){
                    printf("LED Pattern = ");
                    printBinary(patternToWrite);
                }
                devmem_write(2, patternToWrite);
                i++;
                int sleepTimeS = strtoul(argv[i], NULL, 0);
                float toSleep = (float)sleepTimeS/1000;
                if(verbose){
                    printf(" Time: %d ms\n",sleepTimeS);
                }
                sleep(toSleep);
            }
        }
    }
}
