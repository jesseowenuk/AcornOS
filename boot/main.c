asm(
    ".section .entry\n\t"
    "xor dh, dh\n\t"
    "push edx\n\t"
    "call main\n\t"
);

void main(int boot_drive)
{
    // TODO
    
    for(;;);
}