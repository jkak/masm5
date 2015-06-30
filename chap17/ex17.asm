; ex 17:
; func: 1 use int7ch and logic sector(0-2879) to read/write floppy.
;       2 r/w only operate one sector each time.
;       3 call int7ch. inside call int 13h.
;       4 int7ch routine install at 0:200h

assume cs:code, ds:data_seg

data_seg segment
    db 512 dup(0)
    ; for storage data read from floppy
data_seg ends

code segment

start:
	mov ax, cs	        ; code of int routine as data
	mov ds, ax
	mov si, offset int_start

	mov ax, 0h	        ; int vector seg
	mov es, ax
	mov di, 200h
	; length of int code
	mov cx, offset int_end - offset int_start
	cld
	rep movsb

	; set int vector
	mov word ptr es:[7ch*4], 200h	; int IP
	mov word ptr es:[7ch*4+2], 0	; int CS
    
    mov ax, data_seg
    mov es, ax
    mov bx, 0           ; es:bx is data_seg

    mov ah, 0
    ;mov dx, 2879       ; H1:C79:S18. for test
    mov dx, 0           ; logic sector 0 means read MBR
    int 7ch

	mov ax, 4c00h
	int 21h


; #############################################
; func: int_routine 
;   parameter:
;   ah : sub func no, 0 for read, 1 for write.
;   dx : logic sector
;   es:bx : memory segment and offset.

; org is important for offset
org 200h	
int_start:
	cmp ah, 1	    ; if ah > 1, iret
	ja ah_ret

    push ax
    push cx
    push dx
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
    mov dl, 0h      ; ### dl: driver of Floppy A

    mov ax, si      ; ah: 0/1 means read/write for int7ch
    add ah, 2       ; ah: 2/3 means read/write for int13h
    mov al, 1h      ; ### al: operate only 1 Sector each time.

    pop bx          ; es:bx for mem addr
    int 13h         ; read/write a logic sector.

    pop si
	pop dx
    pop cx
    pop ax
ah_ret:
	iret

int_end:
	nop

code ends
end start

