%include "util/err/error_codes.asm"
%include "util/err/error.asm"
disk_read:
    pusha
    mov dl, 0x80
    mov cx, [da_packet.blkcnt]
    mov ah, 0x42
    int 0x13
    jc disk_error
    mov dx, [da_packet.blkcnt]
    cmp cx, dx    
    jne sector_error
    popa
    ret
disk_error:
    mov al, ah
    mov ah, 0
    mov bx, disk_error_string
    jmp error
sector_error:
    mov ax, ERROR_DISK_WRONG_SECTOR_CNT
    mov bx, sector_error_string
    jmp error
disk_error_string:
    db 'Disk read err', 0
sector_error_string:
    db 'Sector cnt err', 0
align 2
da_packet:
.size:      db 0x10 
            db 0    
.blkcnt:    dw 1 
.bufoff:    dw 0x0000   
.bufseg:    dw 0x2000   
.blknum:    dd 1    
.blknumhi:  dd 0