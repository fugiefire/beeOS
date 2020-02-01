
%ifndef _error_asm
%define _error_asm
%include "util/print/print.asm"
error:
    push ax
    call print_unformatted_string
    mov ax, 0x0e28
    int 0x10
    pop dx
    call print_hex_byte
    mov ax, 0x0e29
    int 0x10
    jmp halt_loop
halt:
    mov bx, halt_str
    call error
halt_loop:
    cli 
    hlt 
halt_str:
    db 'halting', 0
%endif