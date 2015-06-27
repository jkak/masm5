; ex 12: int0 routine to show "divide error!" string

assume cs:code_seg

code_seg segment
start:
	mov ax, cs	    ; code of int0 routine as data
	mov ds, ax
	mov si, offset int0_routine

	mov ax, 0h	    ; des segment of int vector
	mov es, ax
	mov di, 200h
	; length of int0 routine code
	mov cx, offset int0_end - offset int0_routine
	cld
	rep movsb

	; set int vector
	mov word ptr es:[0*4], 200h	    ; int0 IP
	mov word ptr es:[0*4+2], 0	    ; int0 CS

    ; test divide 0 to call int0
    mov ax, 0ffffh
    mov bx, 0
    div bx

	mov ax, 4c00h
	int 21h



; #############################################
; sub func: int0_routine
; no paramters. function to show "divide error!" on screen

int0_routine:
	jmp int0_start
	db "divide error!"

int0_start:
	mov ax, cs
	mov ds, ax
	mov si, 203h	
		; int start at 200h, jmp has 2 byte and follow a nop inst,
        ; if you don't understand, pls refer page 332 of Appendix 3
	mov ax, 0b800h	; video
	mov es, ax
	mov di, 12*160+4*2	
	mov cx, 0Dh         ; length of str
	mov ah, 04h         ; red color
each_char:
	push cx
	mov al, ds:[si]
	mov es:[di], ax		; write attr and char to video 
	inc si
	add di, 2
	pop cx
	loop each_char

	mov ax, 4c00h
	int 21h

int0_end:
	nop

code_seg ends
end start

