/* MyTrueColor.s

19 November 2023

My recreation of the C X11 TrueColor.c program
using 100% aarch64 assembly language with Linux
system calls and no C library

To make release:
as MyTrueColor.s -o MyTrueColor.o
ld MyTrueColor.o -o MyTrueColor -lX11
strip MyTrueColor

To make debug:
as MyTrueColor.s -o MyTrueColor.o
ld MyTrueColor.o -o MyTrueColor -lX11

 */

.include "./includeConstantsARM64.inc"
.equ ClientMessage, 33

.data
szMessErrS:    .asciz "X11 Server not found.\n"
szMessErrC:    .asciz "Error creating X11 window.\n"
szWindowTitle: .asciz "Hello X11 - RDS"
szLibDW:       .asciz "WM_DELETE_WINDOW"      // message close window

.bss
.align 4
qDisplay:        .skip 8           // Display address
qDefScreen:      .skip 8           // Default screen address
identWin:        .skip 8           // window ident
qVisual:		 .skip 8		   // Visual
qDC:             .skip 8           // Device Context
qXImage: 		 .skip 8		   // XImage 
wmDeleteMessage: .skip 16          // ident close message
stEvent:         .skip 400         // provisional size

.text
.align 4

.global CreateTrueColorImage 
.type CreateTrueColorImage, %function

// Stack memory offsets for passed and local variables in CreateTrueColorImage
.equ i, 92                          // 16-bit
.equ j, 88                          // 16-bit
.equ pWorkingImageData, 80
.equ pStartImageData, 72
.equ Display, 56
.equ Visual, 48
//.equ image, 40      
.equ width, 36                      // 32-bit
.equ height, 32                     // 32-bit

// image is passed but never used, not messing with it now but needs to be adjusted.  
// It will require stack adjustments if removed.
CreateTrueColorImage:
 	sub	sp, sp, #0x60			    // Reserve 60 bytes on stack
 	stp	x29, x30, [sp, #16]		    // Save Frame and Link registers
 	add	x29, sp, #0x10			    // Adjust Frame pointer
 	str	x0, [sp, Display]		
 	str	x1, [sp, Visual]		
// 	str	x2, [sp, image]			
 	str	w3, [sp, width]			
 	str	w4, [sp, height]		
 	ldr	w1, [sp, width]			
 	ldr	w0, [sp, height]

  	mul	w0, w1, w0				    // width * height * 2
 	lsl	w0, w0, #2
  	sxtw	x0, w0				    // sign extend w0 to x0

// #define __NR3264_mmap 222
// __SC_3264(__NR3264_mmap, sys_mmap2, sys_mmap)    
// You can use mmap to allocate an area of private memory by setting MAP_ANONYMOUS 
// in the flags parameter and setting the file descriptor fd to -1 . 
// This is similar to allocating memory from the heap using malloc , 
// except that the memory is page-aligned and in multiples of pages.
// p = mmap(0, size, PROT_READ|PROT_WRITE, MAP_PRIVATE, -1, 0);
//          x0  x1   x2                    x3           x4  x5

// #define MAP_PRIVATE 0x02
// #define MAP_ANONYMOUS 0x20
// #define PROT_READ  0x01   // Read permission
// #define PROT_WRITE 0x02   // Write permission

// munmap 215
// munmap(*p, size);

	mov x1, x0
	bl mmset  // ToDo: check for error!

	str	x0, [sp, pStartImageData]	// save allocated memory pointer
	str	x0, [sp, pWorkingImageData]	// Working copy of the memory ptr

	str	wzr, [sp, i]			    // for loop i init to zero
branch_8:
	ldr	w1, [sp,i]			        // w1 loaded with value of i
	ldr	w0, [sp, width]			    // w0 loaded with value of width
	cmp	w1, w0
	b.ge branch_1
	str	wzr, [sp, j]

branch_7:
	ldr	w1, [sp, j]
	ldr	w0, [sp, height]
	cmp	w1, w0
	b.ge branch_2
	ldr	w0, [sp, i]
	cmp	w0, #0xff
	b.gt branch_3
	ldr	w0, [sp, j]
	cmp	w0, #0xff
	b.gt branch_3

	bl get_random
	ldr	x2, [sp, pWorkingImageData]
	add	x1, x2, #0x1
	str	x1, [sp, pWorkingImageData]
	strb	w0, [x2]
    
	bl get_random
	ldr	x2, [sp, pWorkingImageData]
	add	x1, x2, #0x1
	str	x1, [sp, pWorkingImageData]
	strb	w0, [x2]

	bl get_random
	ldr	x2, [sp, pWorkingImageData]
	add	x1, x2, #0x1
	str	x1, [sp, pWorkingImageData]
	strb	w0, [x2]
	b branch_4
branch_3:
	ldr	w0, [sp, i]
	ldr	x2, [sp, pWorkingImageData]
	add	x1, x2, #0x1
	str	x1, [sp, pWorkingImageData]
	strb	w0, [x2]

	ldr	w0, [sp, j]
	ldr	x2, [sp, pWorkingImageData]
	add	x1, x2, #0x1
	str	x1, [sp, pWorkingImageData]
	strb	w0, [x2]

	ldr	w0, [sp, i]
	cmp	w0, #0xff
	b.gt branch_5
	ldr	w0, [sp, i]
	ldr	x2, [sp, pWorkingImageData]
	add	x1, x2, #0x1
	str	x1, [sp, pWorkingImageData]
	strb	w0, [x2]
	b branch_4
branch_5:
	ldr	w0, [sp, j]
	cmp	w0, #0xff
	b.gt branch_6
	ldr	w0, [sp, j]
	ldr	x2, [sp, pWorkingImageData]
	add	x1, x2, #0x1
	str	x1, [sp, pWorkingImageData]
	strb	w0, [x2]
	b branch_4
branch_6:
	mov	w1, #0x100                 	
	ldr	w0, [sp, j]
	sub	w0, w1, w0
	ldr	x2, [sp, pWorkingImageData]
	add	x1, x2, #0x1
	str	x1, [sp, pWorkingImageData]
	strb	w0, [x2]
branch_4:
	ldr	x0, [sp, pWorkingImageData]
	add	x0, x0, #0x1
	str	x0, [sp, pWorkingImageData]
	ldr	w0, [sp, j]
	add	w0, w0, #0x1
	str	w0, [sp, j]
	b branch_7
branch_2:
	ldr	w0, [sp, i]
	add	w0, w0, #0x1
	str	w0, [sp, i]
	b branch_8
branch_1:
    str	wzr, [sp, #8]
    mov	w0, #0x20                  	
    str	w0, [sp]
    ldr	w7, [sp, height]
    ldr	w6, [sp, width]
    ldr	x5, [sp, pStartImageData]
    mov	w4, #0x0                   	
    mov	w3, #0x2                   	
    mov	w2, #0x18                  	
    ldr	x1, [sp, Visual]
    ldr	x0, [sp, Display]
    bl	XCreateImage
 	
    ldp	x29, x30, [sp, #16]
	add	sp, sp, #0x60
    ret

// ssize_t getrandom(void *buf, size_t buflen, unsigned int flags=0)
.global get_random
.type get_random, %function
get_random:
	stp x29, x30, [sp, -32]! // allocate buffer space at [sp]
	mov x29, sp

	mov x0, sp				// buffer address
	mov x1, #8				// size_t of buffer
	mov x2, #0
	mov x8, #278 			// #SVC_GETRANDOM
	svc #0
	ldr x0, [sp]

	ldp x29, x30, [sp], 32
	ret

// mmset service call, pass size of memory needed in x1
// returns address of memory in x0

/*
// #define __NR3264_mmap 222
// __SC_3264(__NR3264_mmap, sys_mmap2, sys_mmap)    
// You can use mmap to allocate an area of private memory by setting MAP_ANONYMOUS 
// in the flags parameter and setting the file descriptor fd to -1 . 
// This is similar to allocating memory from the heap using malloc , 
// except that the memory is page-aligned and in multiples of pages.
// p = mmap(0, size, PROT_READ|PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
// #define MAP_PRIVATE 0x02
// #define MAP_ANONYMOUS 0x20
// #define PROT_READ  0x01   // Read permission
// #define PROT_WRITE 0x02   // Write permission
 */
.global mmset
.type mmset, %function
mmset:
	stp x29, x30, [sp,-16]!
	mov x29,sp

	mov x0, #0
	mov x2, #3
	mov x3, #0x22
	mov x4, #-1					// memory not file!
	mov x5, #0
	mov x8, #222				// svc mmap
	svc #0

	ldp	x29, x30, [sp], 16
	ret

.global printmess
.type printmess, %function
printmess:
    stp x0,x1,[sp,-16]!        // save  registers
    stp x2,x8,[sp,-16]!        // save  registers
    mov x2,0                   // size counter
1:                             // loop start
    ldrb w1,[x0,x2]            // load a byte
    cbz w1,2f                  // if zero -> end string
    add x2,x2,#1               // else increment counter
    b 1b                       // and loop
2:                             // x2 =  string size
    mov x1,x0                  // string address
    mov x0,STDOUT              // output Linux standard
    mov x8,WRITE               // code call system "write"
    svc 0                      // call systeme Linux
    ldp x2,x8,[sp],16          // restore  2 registres
    ldp x0,x1,[sp],16          // restoer  2 registres
    ret                        // retturn adresse lr x30

/* Main entry point of program */
// Command Line .....  */
.global _start
_start:
    mov x0,#0                  // open server X
    bl XOpenDisplay
    cmp x0,#0
    beq errS
                               //  Ok return Display address
    ldr x1,qAdrqDisplay
    str x0,[x1]                // store Display address for future use
    mov x28,x0                 // and in register 28

	mov x1,#0
	bl XDefaultVisual
	ldr x1, qAdrVisual
	str x0,[x1]

	mov x0,x28				   // put Display back in x0

                               // load default screen
    ldr x2,[x0,#264]           // at location 264
    ldr x1,qAdrqDefScreen
    str x2,[x1]                //store default_screen
    mov x2,x0
    ldr x0,[x2,#232]           // screen list

                               //screen areas
    ldr x5,[x0,#+88]           // white pixel
    ldr x3,[x0,#+96]           // black pixel
    ldr x4,[x0,#+56]           // bits par pixel
    ldr x1,[x0,#+16]           // root windows
                               // create window x11
    mov x0,x28                 //display
    mov x2,#0                  // position X 
    mov x3,#0                  // position Y
    mov x4,512                 // weight
    mov x5,512                 // height
    mov x6,0                   // bordure ???
    ldr x7,0                   // ?
    ldr x8,qBlanc              // background
    str x8,[sp,-16]!           // argument fot stack
    bl XCreateSimpleWindow
    add sp,sp,16               // for stack alignement
    cmp x0,#0                  // error ?
    beq errC
    //mov x3,sp
    ldr x1,qAdridentWin
    str x0,[x1]                // store window ident for future use
    mov x27,x0                 // and in register 27

                               // Correction of window closing error
    mov x0,x28                 // Display address
    ldr x1,qAdrszLibDW         // atom name address
    mov x2,#1                  // False  create atom if not exist
    bl XInternAtom
    cmp x0,#0
    ble errC
    ldr x1,qAdrwmDeleteMessage // address message
    str x0,[x1]
    mov x2,x1                  // address atom create
    mov x0,x28                 // display address
    mov x1,x27                 // window ident
    mov x3,#1                  // number of protocoles 
    bl XSetWMProtocols
    cmp x0,#0
    ble errC
    
                            // Display window
    mov x1,x27              // ident window
    mov x0,x28              // Display address
    bl XMapWindow
// RDS Start

    mov x0,x28
    ldr x1,qAdrqDefScreen
    ldr x1,[x1]
    bl XDefaultGC
	ldr x1,qAdrDC			// Store DC
	str x0,[x1]

    adr x2,szWindowTitle
    mov x1,x27
    mov x0,x28
    bl XStoreName

    mov x2,#0x8001
    mov x1,x27
    mov x0,x28
    bl XSelectInput

	ldr x1,qAdrqDisplay
	ldr x0,[x1]
	ldr x2,qAdrVisual
	ldr x1,[x2]
	mov x2,#0
	mov x3,#512
	mov x4,#512
	bl CreateTrueColorImage
	ldr x1,qAdrXImage
	str x0,[x1]

1:                          // events loop
    mov x0,x28              // Display address
    ldr x1,qAdrstEvent      // events structure address
    bl XNextEvent
    ldr x0,qAdrstEvent      // events structure address
    ldr w0,[x0]             // type in 4 fist bytes

    cmp w0,0x0c
    bne chkn

    // Expose received draw code here.
// XPutImage(display, window, DefaultGC(display, 0), ximage, 0, 0, 0, 0, width, height);
xp:
	// The width and height are both 512
	mov x0,#512
	// Because we have more than eight parameters we have to pass
	// parameter 8 & 9 (width and height) on the stack

// This is another method that uses more bytes and cycles
//	sub sp, sp, #16
//	str w0, [sp]
//	str w0, [sp,#8]
// One instruction and done is better!
	stp w0,w0,[sp,16]!

	mov x0, x28				// Display
	mov x1, x27				// Window
	ldr x3, qAdrDC
	ldr x2, [x3]			// DC
	ldr x4, qAdrXImage
	ldr x3, [x4]			// image data
	mov x4, 0
	mov x5, 0
	mov x6, 0
	mov x7, 0
	
	bl XPutImage
	add sp,sp,#16			// readjust the stack

	ldr x1,qAdrDC			// Store DC
	ldr x0,[x1]

    mov x2,x0
    mov x26,x0      		// Save DC in x26
    mov x0,x28
    mov x1,x27
    mov x3,#384
    mov x4,#20
    mov x5,#10
    mov x6,#10
    bl XFillRectangle

    mov x0,x28
    mov x1,x27
    mov x2,x26
    mov x3,#384
    mov x4,#128
    adr x5,szWindowTitle
    mov x6,#15
    bl XDrawString

    b 1b
 chkn:
   
    cmp w0,#ClientMessage      	// message for close window 
    bne 1b                     	// no -> loop

    ldr x0,qAdrstEvent         	// events structure address
    ldr x1,[x0,56]             	// location message code
    ldr x2,qAdrwmDeleteMessage 	// equal ?
    ldr x2,[x2]
    cmp x1,x2
    bne 1b                     	// no loop 

    mov x0,x28
    bl XCloseDisplay

    mov x0,0                   	// end Ok
    b 100f
errC:                       	// error create window
    ldr x0,qAdrszMessErrC
    bl printmess
    mov x0,1
    b 100f
errS:                        	// error no server x11 active
    ldr x0,qAdrszMessErrS
    bl printmess
    mov x0,1
100:                           	// program standard end
    mov x8,EXIT
    svc 0 

qBlanc:              .quad 0xF0F0F0F0
qAdrqDisplay:        .quad qDisplay
qAdrqDefScreen:      .quad qDefScreen
qAdridentWin:        .quad identWin

qAdrVisual:			 .quad qVisual
qAdrDC:				 .quad qDC
qAdrXImage:          .quad qXImage

qAdrstEvent:         .quad stEvent
qAdrszMessErrC:      .quad szMessErrC
qAdrszMessErrS:      .quad szMessErrS
qAdrwmDeleteMessage: .quad wmDeleteMessage
qAdrszLibDW:         .quad szLibDW
