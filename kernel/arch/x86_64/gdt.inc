%ifndef _kernel_arch_x86_64_gdt_inc
%define _kernel_arch_x86_64_gdt_inc

%include "bootloader/i386/kern_info.asm"

section .rodata
gdt:
.gdt_start:
.gdt_null:
    dq 0

; 64 bit mode kernel
.kernel_code_64:
    dq (1<<43) | (1<<44) | (1<<47) | (1<<53) ; code segment

.kernel_data_64:
    dq (1<<41) | (1<<44) | (1<<47) ; data segment

.seg_real_code_16:
    dw 0xffff       ; length of segment
    dw 0x0          ; segment base
    db 0x0          ; segment base (cont., upper 8 bits, 16-23)
    db 10011010b    ; flags
    db 10000000b    ; flags:4 + seg length upper 4 bits
    db 0x0          ; segment base (another upper 8 bits,24-31)

.seg_real_data_16:
    dw 0xffff       ; length of segment
    dw 0x0          ; segment base
    db 0x0          ; segment base (cont., upper 8 bits, 16-23)
    db 10010010b    ; flags
    db 10000000b    ; flags:4 + seg length upper 4 bits
    db 0x0          ; segment base (another upper 8 bits,24-31)

.tss:
    dq 0
    dq 0

.gdt_end:
.gdt_descriptor:
    dw .gdt_end - .gdt_start - 1  ; size
    dd .gdt_start-kernel_vaddr                ; start addr

KCODE_64 equ gdt.kernel_code_64 - gdt.gdt_start
KDATA_64 equ gdt.kernel_data_64 - gdt.gdt_start

R_M_CODE equ gdt.seg_real_code_16 - gdt.gdt_start
R_M_DATA equ gdt.seg_real_data_16 - gdt.gdt_start

section .text
%endif