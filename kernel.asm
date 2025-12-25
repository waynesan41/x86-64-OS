section .data

Gdt64:
    dq 0
    dq 0x0020980000000000
    dq 0x0020f80000000000 ; f for ring 3
    dq 0x0020f20000000000 ; Data Segment Ring 3 writiable

; Tss Descriptor
TssDesc:
    dw TssLen-1
    dw 0
    db 0
    db 0x89 ; Present, DPL=0, Type=9 (Available 64-bit TSS)
    db 0
    db 0
    dq 0
    
Gdt64Len: equ $-Gdt64

Gdt64Ptr: dw Gdt64Len-1
          dq Gdt64

; Tasks state Segment
Tss:
    dd 0
    dq 0x150000
    times 88 db 0
    dd TssLen

TssLen: equ $-Tss

section .text
extern KMain
global start ; Linker will know the start is Entry of the Kernel

start: 
    lgdt [Gdt64Ptr] ; Load the GDT

SetTss:
    mov rax,Tss
    mov [TssDesc+2],ax
    shr rax,16
    mov [TssDesc+4],al
    shr rax,8
    mov [TssDesc+7],al
    shr rax,8
    mov [TssDesc+8],eax

    ; Load the TSS
    mov ax, 0x20
    ltr ax


InitPIT:
    mov al, (1<<2) | (3<<4)
    out 0x43, al          ; Command port
    
    mov ax, 11931        ; 1.2 MHz / 1200 Hz 1.2 millions per seconds 11931
    out 0x40, al         ; Low byte
    mov al, ah
    out 0x40, al         ; High byte
    
InitPIC:
    mov al, 0x11
    out 0x20, al         ; Start initialization of master PIC
    out 0xa0, al         ; Start initialization of slave PIC
    
    mov al, 32
    out 0x21, al         ; Master PIC vector offset
    mov al, 40
    out 0xa1, al         ; Slave PIC vector offset

    mov al, 4
    out 0x21, al         ; Tell Master PIC that there is a slave PIC at IRQ2
    mov al, 2
    out 0xa1, al         ; Tell Slave PIC its cascade identity

    mov al, 1
    out 0x21, al         ; Set Master PIC to 8086 mode
    out 0xa1, al         ; Set Slave PIC to 8086 mode

    mov al, 11111110b
    out 0x21, al         ; Mask all IRQs on Master PIC except IRQ0
    mov al, 11111111b
    out 0xa1, al         ; Mask all IRQs on Slave PIC

    push 8
    push KernelEntry
    db 0x48
    retf


KernelEntry:
    ; Set up stack pointer
    mov rsp, 0x200000
    call KMain ;Jump to the Main Kernel Entry in C



End:
    hlt
    jmp End



