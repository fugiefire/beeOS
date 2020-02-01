%ifndef _util_print_print_asm
%define _util_print_print_asm
%define LINE_FEED 0x0a
%define CAR_RETURN 0x0d
%define NEW_LINE LINE_FEED, CAR_RETURN
%define PRINT_INT 0x10
print_unformatted_string:
    pusha
print_unformatted_string_loop:
    mov al, [bx]
    cmp al, 0
    je print_unformatted_string_done
    mov ah, 0x0e    
    int PRINT_INT   
    inc bx          
    jmp print_unformatted_string_loop
print_unformatted_string_done:
    popa            
    ret
print_hex_byte:
    pusha           
    xor cx, cx      
print_hex_byte_loop:
    cmp cx, 2       
    je print_hex_byte_done
    mov al, dl      
    and ax, 0x0f    
    add al, 0x30    
    cmp al, 0x39    
    jle print_hex_byte_write_to_output_string
    add al, 0x7     
print_hex_byte_write_to_output_string:
    mov bx, HEX_STR + 3 
    sub bx, cx          
    mov [bx], al        
    ror dl, 4           
    add cx, 1           
    jmp print_hex_byte_loop 
print_hex_byte_done:
    mov bx, HEX_STR     
    call print_unformatted_string
    popa                
    ret
clear_screen:       
    pusha           
    xor bx, bx      
    mov ah, 0x07    
    mov al, 0x00    
    mov bh, 0x07    
    mov cx, 0x00    
    mov dh, 0x18    
    mov dl, 0x4f    
    int PRINT_INT
    popa            
    ret
HEX_STR:
    db '0x00', 0
HEX_WORD_STR:
    db '0x0000', 0
%endif