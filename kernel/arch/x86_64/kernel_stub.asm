[bits 32]
section .kentry
[extern k_start]
_start:
    call k_start
    jmp $