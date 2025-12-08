[BITS 16] 
[ORG 0x7c00] ; Directive org indicates that the code is supposed to be running at memory address 7c00

start:
    xor ax,ax   
    mov ds,ax
    mov es,ax  
    mov ss,ax
    mov sp,0x7c00

; Check Disk Extension Service (Morden computer have this service)
; Need to load Kernal from Disk to Memory f
TestDiskExtension:
    mov [DriveId], dl 
    ; The BIOS places the drive number (e.g., 0x80 for the first HDD, 0x00 for the first floppy) in DL.
    mov ah,0x41
    mov bx,0x55aa
    int 0x13 ; Carry flag set if Service not supported
    jc NotSupport ; If carry flag is set, jump to NotSupport
    cmp bx, 0xaa55 ; If BX != 0xaa55, jump to NotSupport
    jne NotSupport ; Jump if not equal

; Loading Boot Loader into 5
LoadLoader:
    mov si, ReadPacket
    mov word[si],0x10 ; Number of sectors to read
    mov word[si+2],5 ; Offset to load the sectors
    mov word[si+4],0x7e00 ; Segment to load the sectors
    mov word[si+6],0 ; Reserved, must be 0
    mov dword[si+8],1 ; Starting LBA (Logical Block Address) sector number
    mov dword[si+0xc],0 ; Drive number
    mov dl, [DriveId]
    mov ah, 0x42 ; BIOS Extended Read Sectors Function
    int 0x13 ; Interrupt 0x13 - BIOS Disk Services
    jc ReadError ; If carry flag is set, jump to LoadError
    mov dl, [DriveId]
    jmp 0x7e00 ; Jump to the loaded (->loader.asm) bootloader at segment 0x7e00, offset 0x0000


ReadError:
NotSupport:
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
DriveId: db 0
Message: db "We Have an error in boot Process X_X !!",
MessageLen: equ $-Message
ReadPacket: times 16 db 0 ; Boot Sector Signature

times (0x1be-($-$$)) db 0

    db 80h             ; status: 0x80 = bootable (active partition)
    db 0,2,0           ; starting CHS (Cylinder/Head/Sector) (rough CHS values)
    db 0f0h            ; partition type (0xF0, some custom/odd type used here)
    db 0ffh,0ffh,0ffh  ; ending CHS (maxed out/placeholder)
    dd 1               ; starting LBA = 1 (partition starts at sector 1)
    dd (20*16*63-1)    ; number of sectors in the partition
    ; 20 cylinders
    ; 16 heads
    ; 63 sectors per track

    ; There are 4 partition entries in an MBR.
    ; We already defined 1 entry (above).
    ; This line creates 3 more entries, all zeroed out.
    ; 16 * 3 = 48 bytes → 3 empty partition slots.
    times (16*3) db 0


    db 0x55
    db 0xaa

	
