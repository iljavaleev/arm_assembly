#include "aoaa.inc" 

/*
struct offsets def

struct node
{
  double value;
  node*  left;
  node*  right;
  node*  parent;
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
node_parent   = __offset
__offset      = __offset + 8
node_size     = __offset - node_base

    .text
    .align 2
    .extern printf

/*
void inorder_walk(node* root)
{
  if (root != sentinel)
    {
      inorder_walk(root->left);
      printf(root->value);
      inorder_walk(root->right);
    }
}
*/
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
    adrp    x2, sentinel@PAGE
    add     x2, x2, sentinel@PAGEOFF
    cmp     x1, x2
    beq     exit

    ldr     x1, [fp, #__node]
    ldr     x2, [x1, #node_left]
    str     x2, [sp]
    bl      inorder_walk

    ldr     x1, [fp, #__node]
    ldr     x1, [x1, #node_value]
     adrp    x0, resultStr@PAGE
    add     x0, x0, resultStr@PAGEOFF 
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

/*
  node* tree_search(node* root, float key)
  {
    while((root != sentinel) && (key != root->value))
    {
      if (key < root->value)
        root = root->left;
      else
        root = root->right;
    }
    return root;
  }
*/
tree_search:
  _tree_search:
    __init_offset   = 16
    __offset        = __init_offset
    __root          = __offset
    __offset        = __offset + 8
    __key           = __offset
    size            = 64
  
    stp     fp, lr, [sp, #-16]!
    mov     fp, sp
    sub     sp, sp, #((size)+15) & 0xFFFFFFFFFFFFFFF0

    ldr     x0, [fp, #__root] // store root in x0
    adrp    x1, sentinel@PAGE
    add     x1, x1, sentinel@PAGEOFF  // sentinel in x1
    ldr     d1, [fp, #__key]

    b       whileCond    
whileLoop:
    fcmp    d1, d2
    bge     toRight
    ldr     x0, [x0, #node_left]
    b       whileCond
toRight:
    ldr     x0, [x0, #node_right]

whileCond:
    cmp     x0, x1 // root & sentinel
    
    ldr     d2, [x0, #node_value]
    fccmp   d1, d2, #cceq, ne
    beq     exit_loop

    b       whileLoop

exit_loop:
    mov     sp, fp
    ldp     fp, lr, [sp], #16
    ret

/*
node* tree_min(node* root)
{
  while(root->left != sentinel)
    root = root->left;

  return root;
}

*/
tree_min:
  _tree_min:
     __init_offset   = 16
    __offset        = __init_offset
    __root          = __offset
    size            = 64

    stp     fp, lr, [sp, #-16]!
    mov     fp, sp
    sub     sp, sp, #((size)+15) & 0xFFFFFFFFFFFFFFF0

    ldr     x0, [fp, #__root] // store root in x0
    adrp    x1, sentinel@PAGE
    add     x1, x1, sentinel@PAGEOFF  // sentinel in x1

    b       whileTMinCond
whileTMin:
    ldr     x0, [x0, #node_left]
whileTMinCond:
    ldr     x2, [x0, #node_left]
    cmp     x2, x1
    beq     exit_tree_min
    b       whileTMin

exit_tree_min:
    mov     sp, fp
    ldp     fp, lr, [sp], #16
    ret


/*
node* tree_max(node* root)
{
  while(root->right != sentinel)
    root = root->right;

  return root;
}
*/
tree_max:
  _tree_max:
     __init_offset   = 16
    __offset        = __init_offset
    __root          = __offset
    size            = 64

    stp     fp, lr, [sp, #-16]!
    mov     fp, sp
    sub     sp, sp, #((size)+15) & 0xFFFFFFFFFFFFFFF0

    ldr     x0, [fp, #__root] // store root in x0
    adrp    x1, sentinel@PAGE
    add     x1, x1, sentinel@PAGEOFF  // sentinel in x1

    b       whileTMaxCond
whileTMax:
    ldr     x0, [x0, #node_right]
whileTMaxCond:
    ldr     x2, [x0, #node_right]
    cmp     x2, x1
    beq     exit_tree_max
    b       whileTMax

exit_tree_max:
    mov     sp, fp
    ldp     fp, lr, [sp], #16
    ret

/*
node* tree_successor(node* n)
{
  if (n->rigth != sentinel)
    return tree_min(n->rigth)
  
  node* y = n->parent;
  while((y != sentinel) && (n == y->right))
  {
    n = y
    y = y->parent;
  }
  return y;
}
*/

tree_successor:
  _tree_successor:
    __init_offset   = 16
    __offset        = __init_offset
    __node          = __offset
    size            = 64

    stp     fp, lr, [sp, #-16]!
    mov     fp, sp
    sub     sp, sp, #((size)+15) & 0xFFFFFFFFFFFFFFF0

    ldr     x0, [fp, #__node] // n
    adrp    x1, sentinel@PAGE
    add     x1, x1, sentinel@PAGEOFF
    ldr     x2, [x0, #node_right]

    cmp     x2, x1
    beq     tree_successor_else

    str     x2, [sp]
    bl      tree_min
    b       exit_tree_successor

tree_successor_else:
    ldr     x2, [x0, #node_parent] // y

    b       tree_successor_while_cond
tree_successor_while:
    mov     x0, x2
    ldr     x2, [x2, #node_parent]

tree_successor_while_cond:
    cmp     x2, x1
    ldr     x3, [x2, #node_right]
    ccmp    x0, x3, #ccne, ne
    bne     exit_loop_ts
    b       tree_successor_while

exit_loop_ts:
    mov     x0, x2
exit_tree_successor:
    mov     sp, fp
    ldp     fp, lr, [sp], #16
    ret     


    .pool
values:         .double 1.23, 1.11, 1.99, 1.19, 1.85
search_value:   .double 1.11
resultStr:      .asciz   "%f\n" 
intStr:         .asciz   " %d %d\n"
ptrStr:         .asciz   " %p %p\n"  
sentinel:       .dword  .-.
    
    .global _asmMain
    .global asmMain
/*
                s
                |      
                1.23(r)
            /         \
        1.11(2)          1.99(3)
      /     \           /       \
    s     (4)1.19   1.85(5)       s
          /     \   / \
        s       s   s   s
*/

asmMain:
  _asmMain:
    __offset    = 0
    __offset    = __offset + node_size
    node_root   = -__offset
    __offset    = __offset + node_size
    node_2      = -__offset
    __offset    = __offset + node_size
    node_3      = -__offset
    __offset    = __offset + node_size
    node_4      = -__offset
    __offset    = __offset + node_size
    node_5      = -__offset
    locals_size = __offset

    stp     fp, lr, [sp, #-16]!
    mov     fp, sp
    sub     sp, sp, #((locals_size + 64)+15) & 0xFFFFFFFFFFFFFFF0

    adrp    x6, sentinel@PAGE
    add     x6, x6, sentinel@PAGEOFF

    // init root node_root
    mov     w9, 0
    adrp    x1, values@PAGE
    add     x1, x1, values@PAGEOFF  
    ldr     d1, [x1, w9, uxtw #3]     

    add     x0, fp, #node_root
    str     d1, [x0, #node_value]

    add     x2, fp, #node_2
    str     x2, [x0, #node_left]

    add     x3, fp, #node_3
    str     x3, [x0, #node_right]

    str     x6, [x0, #node_parent]

    // init node_2
    add     w9, w9, #1
    ldr     d1, [x1, w9, uxtw #3]
    str     d1, [x2, #node_value]

    str     x6, [x2, #node_left]
    add     x4, fp, #node_4
    str     x4, [x2, #node_right]

    add     x0, fp, #node_root
    str     x0, [x2, #node_parent]

    // init node_3
    add     w9, w9, #1
    ldr     d1, [x1, w9, uxtw #3]
    str     d1, [x3, #node_value]

    add     x5, fp, #node_5
    str     x5, [x3, #node_left]
    str     x6, [x3, #node_right]

    add     x0, fp, #node_root
    str     x0, [x3, #node_parent]

    // init node_4
    add     w9, w9, #1
    ldr     d1, [x1, w9, uxtw #3]
    str     d1, [x4, #node_value]

    str     x6, [x4, #node_left]
    str     x6, [x4, #node_right]

    add     x2, fp, #node_2
    str     x2, [x4, #node_parent]

    // init node_5
    add     w9, w9, #1
    ldr     d1, [x1, w9, uxtw #3]
    str     d1, [x5, #node_value]

    str     x6, [x5, #node_left]
    str     x6, [x5, #node_right]

    add     x3, fp, #node_3
    str     x3, [x5, #node_parent]


// call inordered tree walk

    add     x0, fp, #node_root
    str     x0, [sp]
    bl      inorder_walk

// call tree_search
    add     x0, fp, #node_root
    str     x0, [sp]
    adrp    x1, search_value@PAGE
    add     x1, x1, search_value@PAGEOFF
    ldr     d1, [x1]
    str     d1, [sp, #8]
    bl      tree_search

    adrp    x1, sentinel@PAGE
    add     x1, x1, sentinel@PAGEOFF
    cmp     x1, x0

    beq     skip_res

    ldr     d1, [x0, #node_value]
    adrp    x0, resultStr@PAGE
    add     x0, x0, resultStr@PAGEOFF
    str     d1, [sp]
    bl      printf

// call tree_min
    add     x0, fp, #node_root
    ldr     x0, [x0, #node_right]
    str     x0, [sp]
    bl      tree_min

    ldr     d1, [x0, #node_value]
    adrp    x0, resultStr@PAGE
    add     x0, x0, resultStr@PAGEOFF
    str     d1, [sp]
    bl      printf
// call tree_max
    add     x0, fp, #node_root
    ldr     x0, [x0, #node_left]
    str     x0, [sp]
    bl      tree_max

    ldr     d1, [x0, #node_value]
    adrp    x0, resultStr@PAGE
    add     x0, x0, resultStr@PAGEOFF
    str     d1, [sp]
    bl      printf

// call tree_successor
    add     x0, fp, #node_4
    str     x0, [sp]
    bl      tree_successor

    adrp    x1, sentinel@PAGE
    add     x1, x1, sentinel@PAGEOFF
    cmp     x1, x0

    beq     skip_res

    ldr     d1, [x0, #node_value]
    adrp    x0, resultStr@PAGE
    add     x0, x0, resultStr@PAGEOFF
    str     d1, [sp]
    bl      printf

skip_res:
    mov     sp, fp
    ldp     fp, lr, [sp], #16
    ret