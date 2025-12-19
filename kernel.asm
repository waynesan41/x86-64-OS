[BITS 64]
[ORG 0x200000]

start: 
    mov byte[0xb8000], 'K' ; Write 'K' to the first character position on the screen
    mov byte[0xb8002], 0x1f ; Set the color of the first character to white (0x1f)
    

End:
    hlt
    jmp End