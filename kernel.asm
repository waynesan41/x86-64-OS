[BITS 64]
[ORG 0x200000]

start: 
    mov rdi, Idt
    mov rax, handler0

    mov [rdi], ax
    shr rax, 16
    mov [rdi+6], ax

    shr rax, 16
    mov [rdi+8], eax



    lgdt [Gdt64Ptr] ; Load the GDT
    lidt [IdtPtr] ; Load the IDT



    push 8
    push KernelEntry
    db 0x48
    ; Far Return
    retf



KernelEntry:
   ; Print: K-GDT!!
    mov byte [0xb8000], 'K' ; Write 'K' to the first character position on the screen
    mov byte [0xb8001], 0x1F  ; Set the color of the first character to white (0x1f)

    mov byte [0xb8002], '-'
    mov byte [0xb8003], 0x07     ; light gray on black

    mov byte [0xb8004], 'G'
    mov byte [0xb8005], 0x07

    mov byte [0xb8006], 'D'
    mov byte [0xb8007], 0x07

    mov byte [0xb8008], 'T'
    mov byte [0xb8009], 0x07

    mov byte [0xb800A], '!'
    mov byte [0xb800B], 0x07

    mov byte [0xb800C], '-'
    mov byte [0xb800D], 0x07

    xor rbx, rbx
    div rbx


End:
    hlt
    jmp End

handler0: 
    mov byte [0xb800E], 'D'  ; Indicate interrupt handler was called
    mov byte [0xb800F], 0x07

    jmp End

    iretq

Gdt64:
    dq 0
    dq 0x0020980000000000

Gdt64Len: equ $-Gdt64

Gdt64Ptr: dw Gdt64Len-1
          dq Gdt64

Idt: 
; Repeat 256 times
    %rep 256
    dw 0
    dw 0x8 
    db 0
    db 0x8e ; In binary 1 00 01110
    dw 0
    dd 0
    dd 0
    %endrep

IdtLen: equ $-Idt

IdtPtr: dw IdtLen-1
          dq Idt