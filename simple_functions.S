#include "aoaa.inc"
    .text
    .align 2
    .extern printf

    .pool
addIntStr:      .asciz   "%d + %d = %d\n"
addFloatStr:    .asciz   "%.3f + %.3f = %.4f\n"  

#define x x21
#define y x22
// int addIntProc(int x, int y);
    .align 4
addIntProc:
  _addIntProc:
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

#define z d21
#define r d22
    .pool
float1: .double  1.34
float2: .double  1.561

addFloatProc:
  _addFloatProc:
    __offset    = 0
    __offset    = __offset + 8
    add_z       = -__offset
    __offset    = __offset + 8
    add_r       = -__offset
    size        = __offset

    stp     fp, lr, [sp, #-16]!
    mov     fp, sp
    sub     sp, sp, #(size+15) & 0xFFFFFFFFFFFFFFF0

    str     z,  [fp, #add_z]
    str     r,  [fp, #add_r]

    ldr     d1, [fp, #add_z]
    ldr     d2, [fp, #add_r]

    fadd     d0, d1, d2

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
    stp     z, r, [fp, #-16]!

    mov     x, 12
    mov     y, 13
    bl      addIntProc
    
    mov     x1, x0
    lea     x0, addIntStr
    str     x,  [sp]
    str     y,  [sp, #8]
    str     x1, [sp, #16]
    bl      printf

    ldr     z, float1
    ldr     r, float2
    bl      addFloatProc

    fmov    d1, d0
    lea     x0, addFloatStr
    str     z,  [sp]
    str     r,  [sp, #8]
    str     d1, [sp, #16]
    bl      printf

    ldp     z, r, [fp], #16
    ldp     x, y, [fp], #16

    mov     sp, fp
    ldp     fp, lr, [sp], #16
    ret
///