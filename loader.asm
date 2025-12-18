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

; Load Kernel Similar to Load Loader
; Where in the Memory we want to load the Kernel
loadKernel: 
    mov si, ReadPacket
    mov word[si],0x10
    mov word[si+2],100 ; About 100 sector = 51200 bytes = 50 KB (Enough for Kernel)
    mov word[si+4],0  
    mov word[si+6],0x1000 
    mov dword[si+8],6 
    mov dword[si+0xc],0
    mov dl, [DriveId]
    mov ah, 0x42 
    int 0x13 ; Interrupt 0x13 - BIOS Disk Services
    jc ReadError ; If carry flag is set, jump to Read error (Kernel load error)

GetMemInfoStart:
    ; Get Memory Information using E820
    mov eax, 0xe820
    mov edx, 0x534d4150 ; 'SMAP'
    mov ecx, 20 ; Size of buffer
    mov edi, 0x9000 ; Buffer to store memory map
    xor ebx, ebx ; Continuation value
    int 0x15
    jc NotSupport ; If carry flag is set, jump to Read error 

GetMemInfo:
    add edi, 20 ; Move to next entry
    mov eax, 0xe820
    mov edx, 0x534d4150
    mov ecx, 20 
    int 0x15
    jnc GetMemDone ; If no carry, continue getting memory map

    test ebx, ebx
    ; If Zero flag is not set
    jnz GetMemInfo ; If EBX != 0, continue getting memory map 

GetMemDone:    ; Print Success Message
    ; mov ah,0x13
    ; mov al,1
    ; mov bx,0xa
    ; xor dx,dx
    ; mov bp,Message
    ; mov cx,MessageLen 
    ; int 0x10

TestA20: 
    mov ax, 0xffff
    mov es, ax
    mov word[ds:0x7c00], 0xa200 ; 0:0x7c00 = 0x16+0x7c00 = 0x7c00
    cmp word[es:0x7c10], 0xa200
    jne SetA20LineDone ; If not equal, A20 line is already enabled
    mov word[0x7c00], 0xb200
    cmp word[es:0x7c10], 0xb200
    je End ; If equal, A20 line is not enabled

SetA20LineDone:
    xor ax,ax
    mov es,ax
    
    mov ah,0x13
    mov al,1
    mov bx,0xa
    xor dx,dx
    mov bp,Message
    mov cx,MessageLen 
    int 0x10

; Use Infinite Loop to halt the CPU
ReadError:
NotSupport: ; Memory Info Error Part of Kernel Load Process
NoLongMode:
End:
    hlt
    jmp End 



; Define Variables
DriveId: db 0
Message: db "Long Mode Supported. O.O !!",  0x0D, 0x0A, \
            "Loader Starts :D !! ", 0x0D, 0x0A, \
            "Kernel is Loaded :D !! ", 0x0D, 0x0A, \
            "Get Memory Info Done ^_^ !! " , 0x0D, 0x0A, \
            "A20 Test s_s !! " ,  0x0D, 0x0A, \
            "End of Loader ._. !!", 0x0D, 0x0A,
MessageLen: equ $-Message
; Define Read Packet Structure for BIOS Extended Read
ReadPacket: times 16 db 0 ; 16 Byte