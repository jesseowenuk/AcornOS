.section .init
    /* gcc will nicely put the contents of crtend.o's .init section here. */
    popl %ebp

.section .fini
    /* gcc will nicely put the contents of crtend.o's .fini section here. */
    popl %ebp
    ret