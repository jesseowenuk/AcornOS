#include <lib/real_mode.h>

__attribute__((naked))
void real_mode_interrupt(
	uint8_t interrupt_number,
	struct real_mode_registers *registers_out,
	struct real_mode_registers *registers_in)
{
	asm(
		// This is self modifying code: results in "int intterupt_number"
		"mov al, byte ptr ss:[esp+4]\n\t"
		"mov byte ptr ds:[3f], al\n\t"

		// Save the out registers
		"mov eax, dword ptr ss:[esp+8]\n\t"
		"mov dword ptr ds:[6f], eax\n\t"

		// Save the in registers
		"mov eax, dword ptr ss:[esp+12]\n\t"
		"mov dword ptr ds:[7f], eax\n\t"

		// Save non-scratch general purpose registers
		"push ebx\n\t"
		"push esi\n\t"
		"push edi\n\t"
		"push ebp\n\t"

		// Jump to real mode
		"jmp 0x08:1f\n\t"
		"1: .code16\n\t"
		"mov ax, 0x10\n\t"
		"mov ds, ax\n\t"
		"mov es, ax\n\t"
		"mov fs, ax\n\t"
		"mov gs, ax\n\t"
		"mov ss, ax\n\t"
		"mov eax, cr0\n\t"
		"and al, 0xfe\n\t"
		"mov cr0, eax\n\t"
		"jmp 0:2f\n\t"
		"2:\n\t"
		"mov ax, 0\n\t"
		"mov ds, ax\n\t"
		"mov es, ax\n\t"
		"mov fs, ax\n\t"
		"mov gs, ax\n\t"
		"mov ss, ax\n\t"

		// Get the arugments from the stack (in registers)
		"mov dword ptr ds:[5f], esp\n\t"
		"mov esp, dword ptr ds:[7f]\n\t"
		"pop ebp\n\t"
		"pop edi\n\t"
		"pop esi\n\t"
		"pop edx\n\t"
		"pop ecx\n\t"
		"pop ebx\n\t"
		"pop eax\n\t"
		"mov esp, dword ptr ds:[5f]\n\t"

		// Indirect interrupt call
		// 0xCD == BIOS int opcode
		// .byte 0 contains the interrupt_number from the argument list
		// Result = int interrupt_number call when we hit label 3
		".byte 0xcd\n\t"
		"3: .byte 0\n\t"

		// Transfer the registers onto the stack so C can see them
		"mov dword ptr ds:[5f], esp\n\t"
		"mov esp, dword ptr ds:[6f]\n\t"
		"add esp, 7*4\n\t"
		"push eax\n\t"
		"push ebx\n\t"
		"push ecx\n\t"
		"push edx\n\t"
		"push esi\n\t"
		"push edi\n\t"
		"push ebp\n\t"
		"mov esp, dword ptr ds:[5f]\n\t"

		// Jump back to protected mode
		"mov eax, cr0\n\t"
		"or al, 1\n\t"
		"mov cr0, eax\n\t"
		"jmp 0x18:4f\n\t"
		"4: .code32\n\t"
		"mov ax, 0x20\n\t"
		"mov ds, ax\n\t"
		"mov es, ax\n\t"
		"mov fs, ax\n\t"
		"mov gs, ax\n\t"
		"mov ss, ax\n\t"

		// Restore the non-scratch general purpose registers
		"pop ebp\n\t"
		"pop edi\n\t"
		"pop esi\n\t"
		"pop ebx\n\t"

		// Let's exit!
		"ret\n\t"

		// Store the ESP here
		"5: .long 0\n\t"

		// Store the out registers here
		"6: .long 0\n\t"

		// Store the in registers here
		"7: .long 0\n\t"

	);
}