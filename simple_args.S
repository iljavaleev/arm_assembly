#include "aoaa.inc"    
    .section .rodata, ""
    .align 4
float3: .double  0.2
pf    =         float3
fptr:   .dword   pf

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
    __init_offset   = 16 // init up fp, lr
    __offset        = __init_offset
    __x             = __offset
    __offset        = __offset + 8
    __y             = __offset
    size            = 64
    
    stp     fp, lr, [sp, #-16]!
    mov     fp, sp
    sub     sp, sp, #((size)+15) & 0xFFFFFFFFFFFFFFF0

    ldr     x1, [fp, #__x]
    ldr     x2, [fp, #__y]

    add     x0, x1, x2

    mov     sp, fp
    ldp     fp, lr, [sp], #16
    ret


#define z d21
#define r d22
// float addFloatProc(float z, float r);
      .pool
float1: .double  1.34
float2: .double  1.561

addFloatProc:
  _addFloatProc:
    __init_offset   = 16 // init up fp, lr
    __offset        = __init_offset
    __z             = __offset
    __offset        = __offset + 8
    __r             = __offset
    size            = 64
    
    stp     fp, lr, [sp, #-16]!
    mov     fp, sp
    sub     sp, sp, #((size)+15) & 0xFFFFFFFFFFFFFFF0

    ldr     d1, [fp, #__z]
    ldr     d2, [fp, #__r]

    fadd    d0, d1, d2

    mov     sp, fp
    ldp     fp, lr, [sp], #16
    ret


#define result x24
// void addFloatProcPtr(float* z, float* r, float* result);
addFloatProcPtr:
  _addFloatProcPtr:
    __init_offset   = 16 // init up fp, lr
    __offset        = __init_offset
    __v             = __offset
    __offset        = __offset + 8
    __w             = __offset
    __offset        = __offset + 8
    __result        = __offset
    size            = 64
    
    stp     fp, lr, [sp, #-16]!
    mov     fp, sp
    sub     sp, sp, #((size)+15) & 0xFFFFFFFFFFFFFFF0

    ldr     x1, [fp, #__v]
    ldr     x2, [fp, #__w]
    ldr     x3, [fp, #__result]

    ldr     d1, [x1]
    ldr     d2, [x2]
    fadd    d0, d1, d2

    str     d0, [x3]

    mov     sp, fp
    ldp     fp, lr, [sp], #16
    ret

    .global _asmMain
    .global asmMain

asmMain:
  _asmMain:
    stp     fp, lr, [sp, #-16]!
    mov     fp, sp
    sub     sp, sp, #((256)+15) & 0xFFFFFFFFFFFFFFF0

    stp     x, y, [fp, #-16]!
    stp     z, r, [fp, #-16]!
    
    ///
    mov     x, 12
    mov     y, 13
    str     x, [sp]
    str     y, [sp, #8]
    bl      addIntProc
    
    mov     x1, x0
    lea     x0, addIntStr
    str     x,  [sp]
    str     y,  [sp, #8]
    str     x1, [sp, #16]
    bl      printf

    /////
    ldr     z, float1
    ldr     r, float2
    str     z, [sp]
    str     r, [sp, #8]
    bl      addFloatProc

    fmov    d1, d0
    lea     x0, addFloatStr
    str     z,  [sp]
    str     r,  [sp, #8]
    str     d1, [sp, #16]
    bl      printf

    //
    lea     x7, float1
    lea     x8, float2
    lea     x,  fptr
    
    str     x7, [sp]
    str     x8, [sp, #8]
    str     x, [sp, #16]
    bl      addFloatProcPtr

    lea     x3, fptr
    ldr     d3, [x3]
    lea     x0, addFloatStr
    str     z,  [sp]
    str     r,  [sp, #8]
    str     d3, [sp, #16]
    bl      printf

    ldp     z, r, [fp], #16
    ldp     x, y, [fp], #16

    mov     sp, fp
    ldp     fp, lr, [sp], #16
    ret