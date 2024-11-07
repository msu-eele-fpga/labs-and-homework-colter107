#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <sys/mman.h> //for map
#include <fcntl.h> //for file open flags
#include <getopt.h>
#include <unistd.h> //for getting the page size

void usage()
{
    fprintf(stderr, "usage: led-patterns [-h] [-v] [-p pattern1, time1, pattern2, time2 ...] [-f filename]\n");
    fprintf(stderr, "led-patterns can be used to write patterns to the DE-10 Nano's LEDs using software.\n\n");
    fprintf(stderr, "Options:\n");
    fprintf(stderr, "-h                                     show this help message and exit \n");
    fprintf(stderr, "-v                                     verbose: print LED pattern displayed as a\n");
    fprintf(stderr, "                                       binary string, as well as how long each \n");
    fprintf(stderr, "                                       pattern is displayed\n");
    fprintf(stderr, "                                       IE: LED pattern = 11110000 Display time = 500ms\n");
    fprintf(stderr, "-f [filename]                          file mode: reads from text file of given \n");
    fprintf(stderr, "                                       filename and writes the corresponding patterns.\n");
    fprintf(stderr, "                                       Patterns and time will be given as shown:\n");
    fprintf(stderr, "                                           <pattern1> <time1> \n");
    fprintf(stderr, "                                           <pattern2> <time2>\n");
    fprintf(stderr, "                                       where pattern is a hexadecimal value and time is an \n");
    fprintf(stderr, "                                       unsigned int in ms. \n");
    fprintf(stderr, "-p [pattern1, time1, pattern2 ...]     pattern mode: display each pattern for its respective time, \n");
    fprintf(stderr, "                                       where pattern is a hexadecimal value and time is an\n");
    fprintf(stderr, "                                       unsigned int in ms. \n");
    fprintf(stderr, "                                       loop until exit command Ctrl-C is entered. \n");
    fprintf(stderr, "                                       if odd number of arguments, print error message and exit. \n");
    fprintf(stderr, "                                       MUST be enetered as last argument.\n");
    fprintf(stderr, "\n");
}

int devmem_read (int r_to_read) {

    const size_t PAGE_SIZE = sysconf(_SC_PAGE_SIZE);
    const char to_read = 0xff200000 + (4*r_to_read);
    const uint32_t ADDRESS = to_read;

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

    return *target_virtual_addr;  
}
    

int main(int argc, char **argv)
{   
    int option;
    bool verbose;
    bool patternMode;
    bool fileMode;
    int patternStartIndex = 1;

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
                printf("File\n");
                fileMode = true;
                break;
            case '?':
                printf("Unknown argument %c\n", optopt);
                return 1;
        }
        option = getopt(argc,argv,"hvpf");
        if(fileMode && patternMode){
            printf("ERROR: both file mode and pattern mode given\n");
            printf("Exiting program... \n");
            return 1;
        }


    }

    printf("%d\n",devmem_read('0'));
    

    

    /*//If the VALUE argument was given, we'll perform a write operation
    bool is_write = (argc ==3 ) ? true : false;

    const uint32_t ADDRESS = strtoul(argv[1], NULL, 0);

    //Open the /dev/mem file, which is an image of the main system memory.
    //Using synchronous write operations (O_SYNC) to ensure that the value
    //is fully written to the underlying hardware before the write call returns
    int fd = open("/dev/mem", O_RDWR | O_SYNC);
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
    printf("memroy addresses:\n");
    printf("-------------------------------------------------------------\n");
    printf("page aligned address = 0x%x\n", page_aligned_addr);

    // Map a page of physical memory into virtual memory. 
    // mor infos at mmap man page: https://www.man7.org/linux/man-pages/man2/mmap.2.html
    uint32_t *page_virtual_addr = (uint32_t *)mmap(NULL, PAGE_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd, page_aligned_addr);
    if(page_virtual_addr == MAP_FAILED)
    {
        fprintf(stderr, "failed to map memory. \n");
        return 1;
    }
    printf("page_virtual_addr = %p\n", page_virtual_addr);

    //The address we want to access is probably not page-aligned, so we need to find how far away from the page boundary it is.
    //Using this offset, we can compute the virtual addres corresponding to the physical targed address (ADDRESS)
    uint32_t offset_in_page =  ADDRESS & (PAGE_SIZE -1);
    printf("offset in page = 0x%x\n", offset_in_page);

    //Compute virtual address corrsponding to ADDRESS.
    //Because virtual addresses are both uint32_t (integer) pointers, the pointer addition multiplies the address by the number
    //of bytes needed to store a uint32_t. This is not what we want. So, we divide by this size (4 bytes) to make it return the
    //right address. 

    //We use volatile because the target virtual address could change outside the program.
    //Volatile tells the compiler to not optimize accesses to this address.
    volatile uint32_t *target_virtual_addr = page_virtual_addr + offset_in_page/sizeof(uint32_t*);
    printf("target_virtual_addr = %p\n", target_virtual_addr);
    printf("-------------------------------------------------------------\n");

    if(is_write)
    {
        const uint32_t VALUE = strtoul(argv[2], NULL, 0);
        *target_virtual_addr = VALUE;
    }
    else
    {
        printf("\nvalue at 0x%x = 0x%x\n", ADDRESS, *target_virtual_addr);
    }

    return 0;*/

}