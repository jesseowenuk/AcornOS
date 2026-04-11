#define PAGE_SIZE               4096

long user_stack[PAGE_SIZE >> 2];

struct 
{
    long *esp;
    short ss;
} stack_start = {&user_stack[PAGE_SIZE >> 2], 0x10 };
