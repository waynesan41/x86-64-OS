[BITS 64]
[ORG 0x200000]

start: 
   
    mov rdi, Idt
    mov rax, Handler0

    mov [rdi], ax
    shr rax, 16
    mov [rdi+6], ax
    shr rax, 16
    mov [rdi+8], eax

    mov rax, Timer
    add rdi, 32*16 ; Move to the next IDT entry (16 bytes each) 
    mov [rdi], ax
    shr rax, 16
    mov [rdi+6], ax
    shr rax, 16
    mov [rdi+8], eax

    lgdt [Gdt64Ptr] ; Load the GDT
    lidt [IdtPtr] ; Load the IDT

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

    ; xor rbx, rbx
    ; div rbx

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

    ; sti                   ; Set interrupts Flag

    push 0x18|3
    push 0x7c00
    push 0x202
    push 0x10|3
    push UserEntry
    iretq

End:
    hlt
    jmp End

UserEntry:
    mov ax,cs
    and al,11b
    cmp al,3
    jne UEnd

    mov byte[0xb8010],'U'
    mov byte[0xb8011],0xE

UEnd:
    jmp UEnd


Handler0: 
    push rax
    push rbx  
    push rcx
    push rdx  	  
    push rsi
    push rdi
    push rbp
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15

    mov byte [0xb800E], 'D'  ; Indicate interrupt handler was called
    mov byte [0xb800F], 0xc

    jmp End

    pop	r15
    pop	r14
    pop	r13
    pop	r12
    pop	r11
    pop	r10
    pop	r9
    pop	r8
    pop	rbp
    pop	rdi
    pop	rsi  
    pop	rdx
    pop	rcx
    pop	rbx
    pop	rax

    iretq

Timer:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push rbp
    push r8
    push r9
    push r10
    push r11
    push r12
    push r13
    push r14
    push r15

    mov byte[0xb8020],'T' ;Indicate timer interrupt handler was called
    mov byte[0xb8021],0xe
    jmp End

    pop	r15
    pop	r14
    pop	r13
    pop	r12
    pop	r11
    pop	r10
    pop	r9
    pop	r8
    pop	rbp
    pop	rdi
    pop	rsi  
    pop	rdx
    pop	rcx
    pop	rbx
    pop	rax

    iretq

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

; Tasks state Segment
Tss:
    dd 0
    dq 0x150000
    times 88 db 0
    dd TssLen

TssLen: equ $-Tss

