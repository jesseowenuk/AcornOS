#define MULTIBOOT_FRAMEBUFFER_TYPE_INDEXED  0
#define MULTIBOOT_FRAMEBUFFER_TYPE_RGA      1
#define MULTIBOOT_FRAMEBUFFER_TYPE_EGA_TEXT 2

/* The symbol table for a.out */
typedef struct mukltiboot_aout_symbol_table
{
    unsigned int tab_size;
    unsigned int str_size;
    unsigned int address;
    unsigned int reserved;
} multiboot_aout_symbol_table;

/* The section header table for ELF */
typedef struct multiboot_elf_section_header_table
{
    unsigned int num;
    unsigned int size;
    unsigned int address;
    unsigned int shndx;
} multiboot_elf_section_header_table;

typedef struct multiboot_info
{
    /* Multiiboot info version number */
    unsigned int flags;

    /* Available memory from BIOS */
    unsigned int mem_lower;
    unsigned int mem_upper;

    /* "root" partition */
    unsigned int boot_device;

    /* Kernel command line */
    unsigned int kernel_command_line;

    /* Boot-Module list */
    unsigned int mods_count;
    unsigned int mods_address;

    union
    {
        multiboot_aout_symbol_table aout_sym;
        multiboot_elf_section_header_table elf_sec;
    } u;

    /* Memory Mapping Buffer */
    unsigned int memory_map_length;
    unsigned int memory_map_address;

    /* Drive info buffer */
    unsigned int drives_length;
    unsigned int drives_address;

    /* ROM configuration table */
    unsigned int config_table;

    /* Boot Loader Name */
    unsigned int boot_loader_name;

    /* APM Table */
    unsigned int apm_table;

    /* Video */
    unsigned int vbe_control_info;
    unsigned short vbe_mode_info;
    unsigned short vbe_mode;
    unsigned short vbe_interface_segment;
    unsigned short vbe_interface_offset;
    unsigned short vbe_interface_len;

    unsigned long long framebuffer_address;
    unsigned int framebuffer_pitch;
    unsigned int framebuffer_width;
    unsigned int framebuffer_height;
    unsigned int framebuffer_bytes_per_pixel;

    unsigned char framebuffer_type;

    union
    {
        struct
        {
            unsigned int framebuffer_pallette_address;
            unsigned short framebuffer_pallette_num_colours; 
        };
        struct
        {
            unsigned char framebuffer_red_field_position;
            unsigned char framebuffer_red_mask_size;
            unsigned char framebuffer_green_field_position;
            unsigned char framebuffer_green_mask_size;
            unsigned char framebuffer_blue_field_position;
            unsigned char framebuffer_blue_mask_size;
        };
    };
} multiboot_info;