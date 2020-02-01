; wow yes undocumented assembly very cool
%include "bootloader/i386/kern_info.asm"
%include "kernel/arch/x86_64/gdt.inc"
global k_start
[bits 32]
[extern kmain]
[extern bss_begin]
[extern bss_end]
section .text
k_start:
    ; Is this a good place for the stack? probably not.
    mov ebp, 0x1F000
    mov esp, ebp
    call null_bss
    lgdt [gdt.gdt_descriptor-kernel_vaddr]
        
    call page_table_init
    jmp 0x8:(goto_kmain-kernel_vaddr)
section .text
null_bss:
    push eax
    push ecx
    push edi
    o16 push es
    mov ax, 0
    mov es, ax
    mov edi, bss_begin-kernel_vaddr
    mov ecx, bss_end-kernel_vaddr
    sub ecx, bss_begin-kernel_vaddr
    xor eax, eax
    rep stosb
    o16 pop es
    pop edi
    pop ecx
    pop eax
    ret
page_table_init:
    mov eax, PDP-kernel_vaddr
    or ax, 0b11
    mov [PML4-kernel_vaddr], eax
    mov eax, KPDP-kernel_vaddr
    or ax, 0b11
    mov [(PML4-kernel_vaddr) + 511*8], eax
    mov eax, PD-kernel_vaddr
    or ax, 0b11
    mov [PDP-kernel_vaddr], eax
    mov [(KPDP-kernel_vaddr) + 511*8], eax
    mov eax, PT-kernel_vaddr
    or ax, 0b11
    mov [PD-kernel_vaddr], eax
    mov eax, 0x03
    mov edi, PT-kernel_vaddr
    mov cx, 512 
  .buildpt:
    mov [edi], eax
    add eax, 0x1000
    add edi, 8
    loop .buildpt
    mov eax, PML4-kernel_vaddr
    mov cr3, eax
    mov eax, cr4
    or eax, (1 << 5) | (1 << 7)
    mov cr4, eax
    mov ecx, 0xc0000080
    rdmsr
    or eax, 1 << 8
    wrmsr
    mov eax, cr0
    or eax, 1 | (1 << 31)
    mov cr0, eax
    ret
[bits 64]
goto_kmain:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov rax, kmain
    call rax
    jmp $
section .bss
align 4096
global PML4
PML4:   resb 4096
global PDP
PDP:    resb 4096
global KPDP
KPDP:   resb 4096
global PD
PD:     resb 4096
global PT
PT:     resb 4096