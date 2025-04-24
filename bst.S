#include "aoaa.inc" 

.macro  print string, args
    adrp    x0, \string@PAGE
    add     x0, x0, \string@PAGEOFF
    .ifnb   \args
      str     \args, [sp]
    .endif
    bl      printf        
.endm


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

    .data
root:               .dword  .-.
tree_walk_str:      .asciz  "call inordered tree walk:\n"
tree_search_str:    .asciz  "call tree search:\n"
tree_min_str:       .asciz  "call tree min:\n"
tree_max_str:       .asciz  "call tree max:\n"
tree_insert_str:    .asciz  "call tree insert %f\n" 
tree_transplant_str:.asciz  "call tree transplant:\n" 
tree_delete_str:    .asciz  "call tree delete %f\n" 
tree_successor_str: .asciz  "call tree successor:\n" 

    .text
    .align 2
    .extern printf

#define NULL x21
#define ROOT x22

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
    
    __locals_off_in = 0
    __locals_offset = __locals_off_in + 16
    saveX1X2        = -__locals_offset
    __locals_offset = __locals_offset + 16
    saveX3X4        = -__locals_offset
    __locals_offset = __locals_offset + 16
    saveX5X6        = -__locals_offset
    __locals_offset = __locals_offset + 16
    saveX7X8        = -__locals_offset

    size            = __locals_offset - __locals_off_in + 64
    
  
    stp     fp, lr, [sp, #-16]!
    mov     fp, sp
    sub     sp, sp, #((size)+15) & 0xFFFFFFFFFFFFFFF0

    stp     x1, x2, [fp, #saveX1X2]
    stp     x3, x4, [fp, #saveX3X4]
    stp     x5, x6, [fp, #saveX5X6]
    stp     x7, x8, [fp, #saveX7X8]

    ldr     x0, [fp, #__offset] // store root in x0
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
    ldp     x1, x2, [fp, #saveX1X2]
    ldp     x3, x4, [fp, #saveX3X4]
    ldp     x5, x6, [fp, #saveX5X6]
    ldp     x7, x8, [fp, #saveX7X8]
  
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

/*
void tree_insert(node* root, node* node)
{
  tree_root = root;
  node* y = sentinel; // y - parent of new node
  while (root != sentinel)
  {
      y = root;
      if (node->value < root->value)
          root = root->left;
      else
          root = root->right;
  }
  node->parent = y;
  if (y == sentinel)
    tree_root = node;
  else if (node->value < y->value)
    y->left = node;
  else
    y->right = node;
}
*/

tree_insert:
  _tree_insert:
     __init_offset   = 16
    __offset        = __init_offset
    __root          = __offset
    __offset        = __offset + 8
    __node          = __offset
    size            = 64

    stp     fp, lr, [sp, #-16]!
    mov     fp, sp
    sub     sp, sp, #((size)+15) & 0xFFFFFFFFFFFFFFF0

    ldr     x0, [fp, #__root] // root*
    mov     x9, x0 // tree_root*
    ldr     x1, [fp, #__node] // node*
    adrp    x2, sentinel@PAGE 
    add     x2, x2, sentinel@PAGEOFF // sentinel
    
    mov     x3, x2 // y*

    b       tree_insert_while_cond
tree_insert_while:
    mov     x3, x0
    ldr     d0, [x1, #node_value] // node->value
    ldr     d1, [x0, #node_value] // root->value
    fcmp    d0, d1
    bge     insToRight     
    ldr     x0, [x0, #node_left]
    b       tree_insert_while_cond
insToRight:
    ldr     x0, [x0, #node_right]
tree_insert_while_cond:
    cmp     x0, x2
    beq     exit_insert_wl
    b       tree_insert_while
exit_insert_wl:
    str     x3, [x1, #node_parent]
    cmp     x3, x2
    beq     tree_root_assign
    
    ldr     d1, [x3, #node_value]
    fcmp    d0, d1
    blt     YLeft
    
    str     x1, [x3, #node_right]
    b       exit_tree_insert

tree_root_assign:
    str     x1, [x9]
    b       exit_tree_insert
YLeft:
    str     x1, [x3, #node_left]
 

exit_tree_insert:
    mov     sp, fp
    ldp     fp, lr, [sp], #16
    ret     

/*
void transplant(node* root, node* u, node* v)
{
    if (u->parent == sentinel)
      root = v;
    else if (u == u->parent->left)
      u->parent->left = v;
    else 
      u->parent->right = v;

    if (v != sentinel)
      v->parent = u->parent;
}
*/


transplant:
  _transplant:
     __init_offset   = 16
    __offset        = __init_offset
    __root          = __offset
    __offset        = __offset + 8
    __u             = __offset
    __offset        = __offset + 8
    __v             = __offset

    __locals_off_in = 0
    __locals_offset = __locals_off_in + 16
    saveX0X1        = -__locals_offset
    __locals_offset = __locals_offset + 16
    saveX2X3        = -__locals_offset
    __locals_offset = __locals_offset + 16
    saveX4X5        = -__locals_offset
    __locals_offset = __locals_offset + 16
    saveX6X7        = -__locals_offset
    __locals_offset = __locals_offset + 16
    saveNR          = -__locals_offset

    size            = __locals_offset - __locals_off_in + 64

    stp     fp, lr, [sp, #-16]!
    mov     fp, sp
    sub     sp, sp, #((size)+15) & 0xFFFFFFFFFFFFFFF0

    stp     x0, x1, [fp, #saveX0X1]
    stp     x2, x3, [fp, #saveX2X3]
    stp     x4, x5, [fp, #saveX4X5]
    stp     x6, x7, [fp, #saveX6X7]
    stp     NULL, ROOT, [fp, #saveNR]

    ldr     ROOT, [fp, #__root] // root*
    ldr     x1, [fp, #__u] // u*
    ldr     x2, [fp, #__v] // v*

    adrp    NULL, sentinel@PAGE 
    add     NULL, NULL, sentinel@PAGEOFF // sentinel
 
    ldr     x4, [x1, #node_parent] // u->p
    cmp     x4, NULL
    beq     n.p_sent

    mov     x5, x4 // u->p

    ldr     x4, [x5, #node_left] // u->p->l
    cmp     x1, x4
    beq     assign_v_l
    
    ldr     x4, [x5, #node_right] // u->p->r
    b       assign_v_r

n.p_sent:
    adrp    ROOT, root@PAGE
    add     ROOT, ROOT, root@PAGEOFF
    str     x2, [ROOT]
    b       exit_cond

assign_v_l:
    str     x2, [x5, #node_left]
    b       exit_cond

assign_v_r:
    str     x2, [x5, #node_right]

exit_cond:
    cmp     x2, NULL
    beq     exit_transplant
    str     x5, [x2, #node_parent]


exit_transplant:
    ldp     NULL, ROOT, [fp, #saveNR]
    ldp     x0, x1, [fp, #saveX0X1]
    ldp     x2, x3, [fp, #saveX2X3]
    ldp     x4, x5, [fp, #saveX4X5]
    ldp     x6, x7, [fp, #saveX6X7]

    mov     sp, fp
    ldp     fp, lr, [sp], #16
    ret     

/*
void tree_delete(node* root, node* z)
{
    if (z->left == sentinel)
      transplant(root, z, z->right)
    else if (z->right == sentinel)
      transplant(root, z, z->left)
    else
    { 
      node* y = tree_min(z->right);
      if (y != z->right)
      {
        transplant(root, y, y->right);
        y->right = z->right;
        y->right->parent = y;
      }
      transplant(root, z, y);
      y->left = z->left;
      y->left->parent = y;
    }
}
*/

tree_delete:
  _tree_delete:
     __init_offset   = 16
    __offset        = __init_offset
    __root          = __offset
    __offset        = __offset + 8
    __z             = __offset
    size            = 64

    stp     fp, lr, [sp, #-16]!
    mov     fp, sp
    sub     sp, sp, #((size)+15) & 0xFFFFFFFFFFFFFFF0

    stp     NULL, ROOT, [fp, #saveNR]

    ldr     ROOT, [fp, #__root] // root*
    ldr     x1, [fp, #__z] // z*
    adrp    NULL, sentinel@PAGE 
    add     NULL, NULL, sentinel@PAGEOFF // sentinel

    ldr     x3, [x1, #node_left] // z->left
    ldr     x4, [x1, #node_right] // z->right
    
    cmp     x3, NULL
    beq     transplant_right

    cmp     x4, NULL
    beq     transplant_left
    
    str     x4, [sp]
    bl      tree_min // y in x0
    
    cmp     x0, x4
    beq     skip_transplant
    

    str     ROOT, [sp]
    str     x0, [sp, #8]
    ldr     x5, [x0, #node_right] // y->right
    str     x5, [sp, #16]
    bl      transplant
    
    str     x4, [x0, #node_right] //  y->right = z->right
    str     x0, [x4, #node_parent] // y->right->parent = y


skip_transplant:
    str     ROOT, [sp]
    str     x1, [sp, #8]
    str     x0, [sp, #16]
    bl      transplant
     
    str     x3, [x0, #node_left]
    str     x0, [x3, #node_parent] // y->left->parent
    b       exit_delete

transplant_right:
    str     ROOT, [sp]
    str     x1, [sp, #8]
    str     x4, [sp, #16]
    bl      transplant
    b       exit_delete

transplant_left:
    str     ROOT, [sp]
    str     x1, [sp, #8]
    str     x3, [sp, #16]
    bl      transplant

exit_delete: 
    ldp     NULL, ROOT, [fp, #saveNR]
    mov     sp, fp
    ldp     fp, lr, [sp], #16
    ret


    .pool
values:         .double 1.23, 1.11, 1.99, 1.19, 1.85
search_value:   .double 1.11
new_node_value: .double 1.84

resultStr:      .asciz   "%f\n" 
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
    sub     sp, sp, #((locals_size + 256)+15) & 0xFFFFFFFFFFFFFFF0

    stp     NULL, ROOT, [fp, #-16]!

    adrp    x6, sentinel@PAGE
    add     x6, x6, sentinel@PAGEOFF
    mov     NULL, x6

    // init root node_root
    mov     w9, 0
    adrp    x1, values@PAGE
    add     x1, x1, values@PAGEOFF  
    ldr     d1, [x1, w9, uxtw #3]     

    add     x0, fp, #node_root
    str     d1, [x0, #node_value]

    adrp    ROOT, root@PAGE
    add     ROOT, ROOT, root@PAGEOFF
    str     x0, [ROOT]
    ldr     ROOT, [ROOT]

    add     x2, fp, #node_2
    str     x2, [ROOT, #node_left]

    add     x3, fp, #node_3
    str     x3, [ROOT, #node_right]

    str     NULL, [ROOT, #node_parent]

    // init node_2
    add     w9, w9, #1
    ldr     d1, [x1, w9, uxtw #3]
    str     d1, [x2, #node_value]

    str     NULL, [x2, #node_left]
    add     x4, fp, #node_4
    str     x4, [x2, #node_right]

    add     ROOT, fp, #node_root
    str     ROOT, [x2, #node_parent]

    // init node_3
    add     w9, w9, #1
    ldr     d1, [x1, w9, uxtw #3]
    str     d1, [x3, #node_value]

    add     x5, fp, #node_5
    str     x5, [x3, #node_left]
    str     NULL, [x3, #node_right]

    str     ROOT, [x3, #node_parent]

    // init node_4
    add     w9, w9, #1
    ldr     d1, [x1, w9, uxtw #3]
    str     d1, [x4, #node_value]

    str     NULL, [x4, #node_left]
    str     NULL, [x4, #node_right]

    add     x2, fp, #node_2
    str     x2, [x4, #node_parent]

    // init node_5
    add     w9, w9, #1
    ldr     d1, [x1, w9, uxtw #3]
    str     d1, [x5, #node_value]

    str     NULL, [x5, #node_left]
    str     NULL, [x5, #node_right]

    add     x3, fp, #node_3
    str     x3, [x5, #node_parent]

// call inordered tree walk:
    print   tree_walk_str
    str     ROOT, [sp]
    bl      inorder_walk

    
// call tree_search
    print   tree_search_str
    str     ROOT, [sp]
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
    print  tree_min_str
    str     ROOT, [sp]
    bl      tree_min

    ldr     d1, [x0, #node_value]
    adrp    x0, resultStr@PAGE
    add     x0, x0, resultStr@PAGEOFF
    str     d1, [sp]
    bl      printf

// call tree_max
    print   tree_max_str
    str     ROOT, [sp]
    bl      tree_max

    ldr     d1, [x0, #node_value]
    adrp    x0, resultStr@PAGE
    add     x0, x0, resultStr@PAGEOFF
    str     d1, [sp]
    bl      printf


// call tree_successor
    print   tree_successor_str
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


// call tree insert
    
//create new leaf node with value
    __offset    = __offset + node_size
    new_node    = -__offset

    adrp    x1, new_node_value@PAGE
    add     x1, x1, new_node_value@PAGEOFF
    ldr     d1, [x1]
    
    print   tree_insert_str, d1
    adrp    x1, new_node_value@PAGE
    add     x1, x1, new_node_value@PAGEOFF
    
    ldr     d1, [x1]

    add     x0, fp, #new_node

    str     d1, [x0, #node_value]

    adrp    x1, sentinel@PAGE
    add     x1, x1, sentinel@PAGEOFF

    str     x1, [x0, #node_left]
    str     x1, [x0, #node_right]
    
    str     ROOT, [sp]
    str     x0, [sp, #8]

    bl      tree_insert

//  
    print   tree_walk_str
    str     ROOT, [sp]
    bl      inorder_walk

// call tree_delete

    ldr     d1, [ROOT, #node_value]
    print   tree_delete_str, d1

    str     ROOT, [sp]
    str     ROOT, [sp, #8]
    bl      tree_delete


    print   tree_walk_str
    adrp    ROOT, root@PAGE
    add     ROOT, ROOT, root@PAGEOFF
    ldr     ROOT, [ROOT]
    str     ROOT, [sp]
    bl      inorder_walk
    

skip_res:
    ldp     NULL, ROOT, [fp], #16
    mov     sp, fp
    ldp     fp, lr, [sp], #16
    ret