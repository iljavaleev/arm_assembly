#include "aoaa.inc" 

/*
struct offsets def

struct node
{
  double value;
  node*  left;
  node*  right;
};
*/
node_base     = 0
__offset      = 0
node_value    = __offset
__offset      = __offset + 8
node_left     = __offset
__offset      = __offset + 8
node_right    = __offset
__offset      = __offset + 8
node_size     = __offset - node_base

    .text
    .align 2
    .extern printf

// ldr     x2, [x1, #node_left]
// ldr     x1, [x2, #node_value]
inorder_walk:
  _inorder_walk:
    __init_offset   = 16
    __offset        = __init_offset
    __node          = __offset
    size            = 64
    
    stp     fp, lr, [sp, #-16]!
    mov     fp, sp
    sub     sp, sp, #((size)+15) & 0xFFFFFFFFFFFFFFF0

    ldr     x1, [fp, #__node]
    lea     x2, sentinel
    cmp     x1, x2
    beq     exit

    ldr     x1, [fp, #__node]
    ldr     x2, [x1, #node_left]
    str     x2, [sp]
    bl      inorder_walk

    ldr     x1, [fp, #__node]
    ldr     x1, [x1, #node_value]
    lea     x0, resultStr
    str     x1,  [sp]
    bl      printf

    ldr     x1, [fp, #__node]
    ldr     x2, [x1, #node_right]
    str     x2, [sp]
    bl      inorder_walk

exit:
    mov     sp, fp
    ldp     fp, lr, [sp], #16
    ret

    .pool
values:         .double 1.23, 1.1, 1.99
resultStr:      .asciz   "%f\n" 
intStr:         .asciz   " %d %d\n"
ptrStr:         .asciz   " %p %p\n"  
sentinel:       .dword  .-.
    
    .global _asmMain
    .global asmMain


asmMain:
  _asmMain:
    __offset    = 0
    __offset    = __offset + node_size
    node_1      = -__offset
    __offset    = __offset + node_size
    node_2      = -__offset
    __offset    = __offset + node_size
    node_3      = -__offset
    locals_size = __offset

    stp     fp, lr, [sp, #-16]!
    mov     fp, sp
    sub     sp, sp, #((locals_size + 64)+15) & 0xFFFFFFFFFFFFFFF0

   
    // init root node
    mov     w9, 0
    adrp    x1, values@PAGE
    add     x1, x1, values@PAGEOFF  
    ldr     d1, [x1, w9, uxtw #3]     

    add     x0, fp, #node_1
    str     d1, [x0, #node_value]

    add     x2, fp, #node_2
    str     x2, [x0, #node_left]

    add     x3, fp, #node_3
    str     x3, [x0, #node_right]

    lea     x0, sentinel

    // init left child
    add     w9, w9, #1
    ldr     d1, [x1, w9, uxtw #3]
    str     d1, [x2, #node_value]

    str     x0, [x2, #node_left]
    str     x0, [x2, #node_right]

    // init right child
    add     w9, w9, #1
    ldr     d1, [x1, w9, uxtw #3]
    str     d1, [x3, #node_value]

    str     x0, [x3, #node_left]
    str     x0, [x3, #node_right]

    add     x0, fp, #node_1
    str     x0, [sp]
    bl      inorder_walk


    mov     sp, fp
    ldp     fp, lr, [sp], #16
    ret