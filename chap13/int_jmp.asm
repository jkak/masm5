; check point 13.1 -(2)
; use int 7ch implement jmp near ptr label

assume cs:code_seg, ds:data_seg

data_seg segment
	db 'conversation a string!', 0
data_seg ends

code_seg segment
start:
	mov ax, cs	    ; code of int process as data
	mov ds, ax
	mov si, offset int_routine

	mov ax, 0h	    ; int vector
	mov es, ax
	mov di, 200h
	; length of int code
	mov cx, offset int_end - offset int_routine
	cld
	rep movsb

	; set int vector
	mov word ptr es:[7ch*4], 200h	; int IP
	mov word ptr es:[7ch*4+2], 0	; int CS


    ; #########################################
    ; test int 7ch
    ; display data string on 12th row of screen.
	mov ax, data_seg
	mov ds, ax
	mov si, 0
	mov ax, 0b800h
	mov es, ax
	mov di, 160*12	; 12th row
    mov ah, 04h     ; red color
sjp_start:
	mov al, [si]
	cmp al, 0
	je sjp_ok
	mov es:[di], ax
	inc si
	add di, 2
	mov bx, offset sjp_start - offset sjp_ok
    ; bx is length of loop code, ready for int 7ch offset
	int 7ch
sjp_ok:
	mov ax, 4c00h
	int 21h


; #############################################
; sub func: int_routine
; run as jmp

int_routine:
	push bp
	mov bp, sp
	add [bp+2], bx	; modify IP in stack
	pop bp
	iret
int_end:
	nop

code_seg ends
end start

