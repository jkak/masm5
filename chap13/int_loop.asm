; 13.3 use int to simulate loop 
; and show 80 '!' on a line
; this asm is part of ex13 (-2)

assume cs:code_seg

code_seg segment
start:
	mov ax, cs	; code of int process as data
	mov ds, ax
	mov si, offset int_routine

	mov ax, 0h	; segment of int vector
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
	mov ax, 0b800h
	mov es, ax
	mov di, 160*12	; 12th row

	; bx is length of loop code, ready for int offset
	mov bx, offset int_lp_start - offset int_lp_end
	mov cx, 50h	    ; 80 times

int_lp_start:
	mov byte ptr es:[di], '!'
	add di, 2
	int 7ch         ; use int to instead of loop
                    ; use bx to modify IP
int_lp_end:
	nop
    ; ###### end test


	mov ax, 4c00h
	int 21h

; #############################################
; sub func: int_routine

int_routine:
	push bp
	mov bp, sp
	dec cx
	jcxz lpret
	add [bp+2], bx	; modify IP in stack
lpret:
	pop bp
	iret

int_end:
	nop

code_seg ends
end start

