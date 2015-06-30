; design a OS!
; author : jungle85gopy
; date   : 2015.06.30

;##############################################
; Sector 1 (CHS=001)

org	07c00h		; mbr will be load to 0:7c00h

start:
	mov	ax, 0
    mov ss, ax
    mov sp, 7c00h
	mov	ds, ax
	mov	es, ax
    mov si, boot_msg
    call show_init_str  ; ds:si

fin:
    hlt
	jmp	fin 		; loop forever


;##################################
; func: show str begin at ds:si, end with NULL

show_init_str:
    push ax
    push bx
    push si

	mov	ah, 0eh		
	mov	bx, 04h		; bh=0 : page no, bl=04h : red color.
show_init_lp:
	mov	al, [si]
    cmp al, 0
    je show_init_ret
	int	10h			; show string
    inc si
    jmp show_init_lp

show_init_ret:
    pop si
    pop bx
    pop ax
    ret
;#### func end ####


boot_msg:
    db 0ah, "Hello, OS world!", 0

    times 510-($-$$) db 0   ; fill with 0 to 01fdh(510) byte
    dw 	0xaa55				; end flag of MBR


; Sector 1 (CHS=001) end
;##############################################



