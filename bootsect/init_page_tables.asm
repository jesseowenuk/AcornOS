;
; init_page_tables.asm
;
; Initialises the page tables
;
; The Page Table has 4 components which will be mapped as follows
;
;   PML4T -> 0x1000 (Page Map Level 4 Table)
;   PDPT -> 0x2000 (Page Directory Pointer Table)
;   PDT -> 0x3000 (Page Directory Table)
;   PT -> 0x4000 (Page Table)
;
; We start by clearing out the memory in those areas then proceed
; to setup the page tables.
;
; Each table has 512 entries - all of them are 8 bytes.
; For now we only map the lowest 2MB of memory - this only requires
; one table so the upper 511 entries in the PML4T, PDPT and PDT will 
; be NULL.
; 

init_page_tables:
    mov edi, 0x1000         ; Set the base address for rep stosd. Our
                            ; page table goes from 0x1000 -> 0x4FFF, so 
                            ; we want to start from 0x1000
    
    mov cr3, edi            ; Save the PML4T start address in cr3. This will save
                            ; us time later because cr3 is what the CPU uses to locate
                            ; the page table entries.

    xor eax, eax            

    mov ecx, 4096           ; repeat 4096 times as each page table is 4096 bytes, and we're
                            ; writing 4 bytes each repetition, this will zero out all 4 page tables.

    rep stosd               ; Now actually zero out the page table entries.

    ; Set EDI back to PML4T
    mov edi, cr3

    ; Set up the first entry of each table
    ; Each page table must be aligned, this means the lower 12 bits of the physical address MUST be 0.
    ; Then, each page table entry can use the lower 12 bits as flags for that entry.

    ; The flags are set to 0x003 - this sets bits 0 and 1 (LSB and the next 1)
    ; Bit 0 -> exists (this is only set if the entry corresponds to another page table (PML4T, PDPT, PDT)
    ; or a page of physical memory in the PT).
    ; Bit 1 -> read/write bit, this allows us to view and modify the given entry, as we want full control we 
    ; set this too

    mov dword[edi], 0x2003              ; Set PML4T[0] to address 0x2000 (PDPT) with flags 0x003
    add edi, 0x1000                     ; Go to PDPT[0]
    mov dword[edi], 0x3003              ; Set PDPT[0] to address 0x3000 (PDT) with flags 0x003
    add edi, 0x1000                     ; Go to PDT[0]
    mov dword[edi], 0x4003              ; Set PDT[0] to address 0x4000 (PT) with flags 0x003

    ; Fill in the final page table

    ; We now want to make an Identity Mapping in our PT. We will stil be keeping our flags as 0x003
    ; but we also want to set PT[0].address to 0x00 and PT[1].address to 0x01 and so on.
    add edi, 0x1000                     ; Go to PT[0]
    mov ebx, 0x00000003                 ; EBX now has address 0x0000 with the flags 0x003
    mov ecx, 512                        ; We're going to do this operation 512 times

    .add_page_entry:
        ; A = address
        ; X = index of page table
        ; Flags = entry flags
        mov dword[edi], ebx             ; Write EBX to PT[x] = a.append(flags)
        add ebx, 0x1000                 ; Increment address EBX (a+1)
        add edi, 8                      ; Increment page table location (entries are 8 bytes long)
        loop .add_page_entry            ; Decrement ECX and loop again

    ; Set up PAE paging. Though we're not going to enable it here.
    mov eax, cr4
    or eax, 1 << 5                      ; Set the PAE-bit, which is the 5th bit
    mov cr4, eax

    popad
    ret