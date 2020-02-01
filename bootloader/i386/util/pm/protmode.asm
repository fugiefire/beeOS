%include "gdt.asm"
%include "util/err/error.asm"
%include "util/err/error_codes.asm"
[bits 16]
enter_prot_mode:
    cli                     
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:prot_mode_early_init
[bits 32]
prot_mode_early_init:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ebp, 0x90000
    mov esp, ebp
    jmp edx