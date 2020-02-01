[org 0x7c00]
%include "kern_info.asm"
start:
    call clear_screen
    mov bx, boot_string
    call print_unformatted_string
    mov bp, 0x8000 
    mov sp, bp
    call load_kernel
    mov edx, prot_mode_init 
    jmp enter_prot_mode                  
    jmp halt    
[bits 16]
load_kernel:
    pusha
    push ds
    push es
    push 0
    pop ds
    push 0
    pop es
    mov edi, KERN_LOAD_ADDR
    xor eax, eax
    mov edx, 1
.read_loop:
    mov esi, da_packet
    call disk_read
    mov eax, [da_packet.blknum]
    inc eax
    mov [da_packet.blknum], eax
    mov esi, 0x20000    
    mov ecx, 512     
    o32 a32 rep movsb
    inc edx
    cmp edx, KERN_SECTOR_COUNT
    jb .read_loop
    pop es
    pop ds
    popa
    ret
%include "util/print/print.asm"
%include "util/err/error.asm"
%include "util/disk.asm"
%include "util/pm/protmode.asm"
%include "util/a20/a20.asm"
boot_string:
    db 'Booting', NEW_LINE, 0
kernel_load_string:
    db 'Loading kernel...', NEW_LINE, 0
newline:
    db NEW_LINE, 0
BOOT_DRIVE db 0x80
[bits 32]
prot_mode_init:
    jmp KERN_LOAD_ADDR 
    jmp halt
times 510-($-$$) db 0
dw 0xaa55