.equ STDIN,  0                // Linux input console
.equ STDOUT, 1                // linux output console

// https://github.com/torvalds/linux/blob/v4.17/include/uapi/asm-generic/unistd.h
// Linux system calls 64 bits
.equ OPEN,   56               
.equ CLOSE,  57               
.equ READ,   63               
.equ WRITE,  64               
.equ EXIT,   93               
.equ MMAP,   222
.equ UNMAP,  215
.equ RANDOM, 278

.equ HEAPSIZE,   100000
.equ CHARPOS,       '@'     // position character

.equ MAP_PRIVATE, 0x0002    // MMAP Private memory
.equ PROT_READ,   0x0001    // Memory Read permission
.equ PROT_WRITE,  0x0002    // Memory Write permission

.equ O_RDONLY, 0
.equ O_WRONLY, 0x0001    
.equ O_RDWR,   0x0002       // open for reading and writing

.equ O_CREAT,  0x040        // create if nonexistant
.equ O_TRUNC,  0x0400       // truncate to zero length
.equ O_EXCL,   0x0800       // error if already exists 

.equ AT_FDCWD,    -100
