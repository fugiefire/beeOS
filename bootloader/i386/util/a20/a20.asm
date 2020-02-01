[bits 16]
enable_a20:
    mov     ax,2403h
    int     15h
    jb      a20_ns
    cmp     ah,0
    jnz     a20_ns
    mov     ax,2402h
    int     15h
    jb      a20_bios_failed
    cmp     ah,0
    jnz     a20_bios_failed
    cmp     al,1
    jz      a20_activated
    mov     ax,2401h
    int     15h
    jb      a20_bios_failed
    cmp     ah,0
    jnz     a20_bios_failed
a20_activated:
    ret
a20_bios_failed:
    in al, 0x92
    test al, 2
    jnz a20_activated
    or al, 2
    and al, 0xfe 
    out 0x92, al
    jmp a20_activated
a20_ns:
    cli
    hlt