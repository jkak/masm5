; design a OS!
; author : jungle85gopy
; date   : 2015.06.30

;##############################################
; Sector 1 (CHS=001)

org	07c00h		; mbr will be load to 0:7c00h

start:
    call sectors2mem    ; copy floppy sectors to mem

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
; func: show_init_str
;   string begin at ds:si, end with NULL

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



;##################################
; func: sectors2mem.  
;   copy floppy sectors to mem 8200h
; parameter:
;   ah : sub func no, 0 for read, 1 for write.
;   dx : logic sector
;   es:bx : memory segment and offset.
sectors2mem:
    mov ax, 820h
    mov es, ax
    mov bx, 0       ; es:bx mem addr for copy floppy sector
    mov ah, 0       ; read sector
    mov al, 0       ; read floppy

    mov cx, 3       ; sectors num
    mov dx, 1       ; start from logic sector 1.(0 is mbr)
rd_sec_lp: 
    call sec2mem    ; copy logic sector to mem
    inc dx
    add bx, 512
    loop rd_sec_lp
sectors_end:
    ret
;#### func end ####








; #############################################
; func: sec2mem
;   copy a floppy sector to mem 8200h
; parameter:
;   ah : sub func no, 0 for read, 1 for write.
;   al : driver id. 0 for floppy, 80 for C:
;   dx : logic sector
;   es:bx : memory segment and offset.

sec2mem:
    cmp ah, 1	    ; if ah > 1, ret
    ja ah_ret

    push ax
    push cx
    push dx
    push es
    push si
    push bx
    mov si, ax      ; backup ax 

    ; compute CHS, Formula:
    ; logicSector = (Header*80  + Cylinder) * 18 + Sector - 1
    ;             = Header*1440 + Cylinder  * 18 + Sector -1
    ;   Header =      int(logicSector/1440)
    ; Cylinder = int( rem(LogicSector/1440) / 18 )
    ; Sector   = rem( rem(LogicSector/1440) / 18 ) + 1

    ; compute CHS
    mov ax, dx      
    mov dx, 0h      ; dx:ax is logicSector
    mov bx, 1440
    div bx          ; dx is  remainder, ax is quotient
    mov bx, dx      ; backup remainder
    mov dh, al      ; ### dh: Header   (0,1)
    
    mov ax, bx      ; rem(logicSector/1440)
    mov dl, 18
    div dl          ; ah is remainder, al is quotient
    mov ch, al      ; ### ch: Cylinder (0,79)
    mov al, ah
    inc al          
    mov cl, al      ; ### cl: Sector   (1,18)

    mov ax, si      ; ah: 0/1 means read/write for int7ch
    mov dl, al      ; ### dl: driver of Floppy A

    add ah, 2       ; ah: 2/3 means read/write for int13h
    mov al, 1h      ; ### al: operate only 1 Sector each time.

    pop bx          ; es:bx for mem addr
    int 13h         ; read/write a logic sector.

    pop si
    pop es
    pop dx
    pop cx
    pop ax
ah_ret:
    ret
;#### func end ####


boot_msg:
    db 0ah, "Hello, OS world!", 0

    times 510-($-$$) db 0   ; fill with 0 to 01fdh(510) byte
    dw 	0xaa55				; end flag of MBR


; Sector 1 (CHS=001) end
;##############################################



; 200h sector1
    db "12345678"
    times 1022-($-$$) db 0   ; fill with 0 to logic sector 1
    db "ok"

; 400h sector2
    db "ABCDEFGH"
    times 1534-($-$$) db 0   ; fill with 0 to logic sector 2
    db "ok"

; 600h sector3
    db "abcdefgh"
    times 2046-($-$$) db 0   ; fill with 0 to logic sector 3
    db "ok"

