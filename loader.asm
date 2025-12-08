[BITS 16]
[ORG 0x7e00] ; Directive org indicates that the code is supposed to be running at memory address 7c00


; Start of the loader
start:
    mov ah,0x13
    mov al,1
    mov bx,0xa
    xor dx,dx
    mov bp,Message
    mov cx,MessageLen 
    int 0x10

; Use Infinite Loop to halt the CPU
End:
    hlt
    jmp End 


; Define Variables
Message: db "Loader Starts :D !!"
MessageLen: equ $-Message