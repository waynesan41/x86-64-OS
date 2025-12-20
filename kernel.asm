[BITS 64]
[ORG 0x200000]

start: 
    lgdt [Gdt64Ptr] ; Load the GDT
    
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

    mov byte [0xb800C], '!'
    mov byte [0xb800D], 0x07



End:
    hlt
    jmp End

Gdt64:
    dq 0
    dq 0x0020980000000000

Gdt64Len: equ $-Gdt64

Gdt64Ptr: dw Gdt64Len-1
          dq Gdt64
