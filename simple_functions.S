#include "aoaa.inc"
    .text
    .align 2
    .extern printf

    .pool
piStr:  .asciz   "%d + %d = %d\n"


#define x x21
#define y x22
// int addProc(int x, int y);
    .align 4
addProc:
  _addProc:
    __offset    = 0
    __offset    = __offset + 8
    add_x       = -__offset
    __offset    = __offset + 8
    add_y       = -__offset
    size        = __offset

    stp     fp, lr, [sp, #-16]!
    mov     fp, sp
    sub     sp, sp, #(size+15) & 0xFFFFFFFFFFFFFFF0

    str     x,  [fp, #add_x]
    str     y,  [fp, #add_y]

    ldr     x1, [fp, #add_x]
    ldr     x2, [fp, #add_y]

    add     x0, x1, x2

    mov     sp, fp
    ldp     fp, lr, [sp], #16
    ret


    .global _asmMain
    .global asmMain

asmMain:
  _asmMain:
    stp     fp, lr, [sp, #-16]!
    mov     fp, sp
    sub     sp, sp, #(64+15) & 0xFFFFFFFFFFFFFFF0

    stp     x, y, [fp, #-16]!

    mov     x, 12
    mov     y, 13
    bl      addProc

    
    mov     x1, x0
    lea     x0, piStr
    str     x,  [sp]
    str     y,  [sp, #8]
    str     x1, [sp, #16]
    bl      printf

    ldp     x, y, [fp], #16

    mov     sp, fp
    ldp     fp, lr, [sp], #16
    ret
///