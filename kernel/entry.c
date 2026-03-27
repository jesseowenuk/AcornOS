//
// entry.c
//
// Our kernel C entry point
//

void test()
{
    char *vga_memory = (char *)0xb8000;

    vga_memory[0] = 'A';
    vga_memory[1] = 0x0a;
}

int main()
{
    test();
    return 0; 
}