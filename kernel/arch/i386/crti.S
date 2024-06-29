.section .init
.global _init
.type _init, @function
_init:
    push %ebp
    movl %esp, %ebp
    /* gcc will nicely put the contents of crtbegin's .o .init section here. */

.section .fini
.global _fini
.type _fini, @function
_fini:
    push %ebp
    movl %esp, %ebp
    /* gcc will nicely put the contents of crtbegin's .fini section here. */