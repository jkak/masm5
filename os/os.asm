; design a OS!
; author : jungle85gopy
; date   : 2015.06.30

org	07c00h		; mbr will be load to 0:7c00h

start:
	mov	ax, 0
    mov ss, ax
    mov sp, 7c00h
	mov	ds, ax
	mov	es, ax
    mov si, boot_msg
disp_str:
	mov	al, [si]
    cmp al, 0
    je fin
    
	mov	ah, 0eh		
	mov	bx, 04h		; bh=0 : page no, bl=04h : red color.
	int	10h			; show string
    inc si
    jmp disp_str

fin:
    hlt
	jmp	fin 		; loop forever

boot_msg:
    db 0ah, "Hello, OS world!", 0

    times 510-($-$$) db 0   ; fill with 0 to 01fdh(510) byte
    dw 	0xaa55				; end flag of MBR

