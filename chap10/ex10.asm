; ex 10: implement 3 sub-program
;   show_str: show string on screen 
;   div_dw: avoid divide overflow
;   d2char: number to char

assume cs:code_seg, ds:data_seg, ss:stack_seg

stack_seg segment stack
	db 32 dup(0)	 
stack_seg ends

data_seg segment
	db 'Welcome to Asm!',0
	db 32 dup(0) 

data_seg ends


code_seg segment

start:
	mov ax, stack_seg	; stack
	mov ss, ax
	mov sp, 20h

	mov ax, data_seg	; data
	mov ds, ax

	mov ax, 0B800H	    ; video entrance.
	mov es, ax


; #############################################
; test of show_str, show string times in CX
	mov cx, 12	; loop lines(0-24)
	mov dh, 1   ; row
	mov dl, 0   ; col

lines:
	mov si, 0
	jcxz line_done
	push cx
	mov cl, 2	; color green	
	call show_str

	inc dh
	inc dl
	pop cx
	loop lines
line_done:
    nop


	mov ax, 4c00h
	int 21h



; ##############################################
; sub func: show_str
; paramters: 
;	DS:SI : str_pointer, 
;   ES:   : video segment
;	CL	  : color, 
;   DH	  : row(0-24) 0: 0h~9FH, 1: 0A0H~140H
;   DL    : col(0-79)
show_str:
	push ax
	push bx
    push cx
    push si
	push di
	
	; video pointer
	mov al, 0A0H	; 160 byte each line.
	mov bl, dh	    ; row
	mul bl	        ; MAX result is 4000

	mov bh, 0	; ready for add dl
	mov bl, dl
	add ax, bx	; add column char offset
	add ax, bx	; add column attr offset
	mov di, ax	; video header pointer
	mov ah, cl	; now ah is color
	mov cx, 0	; CX for jcxz

show_char:
	mov cl, ds:[si]
	jcxz show_done
		
	; display
	mov al, cl		; char in al, attr in ah
	mov es:[di], AX	; display char and attr

	inc si
	inc di
	inc di
	loop show_char

show_done:
	pop di
    pop si
    pop cx
	pop bx
	pop ax
	ret



code_seg ends

end start
