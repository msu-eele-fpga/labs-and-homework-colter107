#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
//#include <sys/mman.h> //for map
#include <fcntl.h> //for file open flags
//#include <unistd.h> //for getting the page size

void usage()
{
    fprintf(stderr, "devmem ADDRESS [VALUE]\n");
    fprintf(stderr, "devmem can be used to read/write to physical memory viea the /dev/mem device.\n");
    fprintf(stderr, "devmem will only read/write 32-bit values \n\n");
    fprintf(stderr, "Arguments:\n");
    fprintf(stderr, "   ADDRESS The address to read/write to/from\n");
    fprintf(stderr, "   VALUE The optional value to write to ADDRESS; if not given, a read will be performed\n");
}

int main(int argc, char **argv)
{   
    int option;
    bool verbose;
    bool patternMode;
    bool fileMode;

    while((option = getopt(argc,argv,"hvpf")) != 1){
        switch(option){
            case 'h':
                usage();
                break;
            case 'v':
                printf("Verbose\n");
                verbose = true;
                break;
            case 'p':
                printf("Pattern\n");
                patternMode = true;
                break;
            case 'f':
                printf("File\n");
                fileMode = true;
                printf("File Given: %s\n", optarg);
                break;
            case '?':
                printf("Unknown argument %c\n", optopt);
                break;
        }
    }
    
    
    
    /*//size of a page of memory in the system (typically 4096 bytes)
    const size_t PAGE_SIZE = sysconf(_SC_PAGE_SIZE);
    if (argc == 1)
    {
        //No arguments were given, so just print usage text and exit
        //NOTE: first argument is just the program name, so argv[1] is 
        //the first *real* argument
        usage();
        return 1;
    }

    //If the VALUE argument was given, we'll perform a write operation
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