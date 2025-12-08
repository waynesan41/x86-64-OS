[BITS 16]
[ORG 0x7e00] ; Directive org indicates that the code is supposed to be running at memory address 7c00


; Start of the loader
start:
    mov [DriveId], dl ; Store the drive ID passed from bootloader

    mov eax, 0x80000000 ; Check for Long Mode support
    cpuid ; Special Instruction
    cmp eax, 0x80000001
    ; jb (Jump if below)
    jb NoLongMode

    mov eax, 0x80000001 ; infor about Long Mode will be save in EDX
    cpuid ; Return processor identification and feature information
    test edx,(1<<29) ; Check if Long Mode is supported (bit 29 of EDX)
    ; jz (if Zero flag is set)
    jz NoLongMode ; If not supported, jump to NoLongMode

    ; Check 1GB Page Support
    test edx, (1 << 26) ; Bit 26 indicates 1GB page support
    jz NoLongMode ; If not supported, jump to NoLongMode

    mov ah,0x13
    mov al,1
    mov bx,0xa
    xor dx,dx
    mov bp,Message
    mov cx,MessageLen 
    int 0x10

; Use Infinite Loop to halt the CPU
NoLongMode:
End:
    hlt
    jmp End 



; Define Variables
DriveId: db 0
Message: db "Loader Starts :D !! Long Mode Supported. O.O !!"
MessageLen: equ $-Message