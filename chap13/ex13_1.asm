; ex 13-1
; use int 7ch to display data string on screen

assume cs:code_seg, ds:data_seg

data_seg segment
	db 'welcome to masm', 0
data_seg ends

code_seg segment
start:
	mov ax, cs	    ; code of int process as data
	mov ds, ax
	mov si, offset int_routine

	mov ax, 0H	    ; int vector
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
    ; test int 7ch to display 
	mov ax, data_seg	;data
	mov ds, ax
	mov si, 0
	mov dh, 0ah     ; row
	mov dl, 0h      ; col
	mov cl, 4h      ; color
	int 7ch

	mov ax, 4c00h
	int 21h


; #############################################
; func: int_routine 
; parameter:
;	dh: row,    cl: color, 
;	dl: col     ds:si: the header pointer of str
int_routine:
    push ax
    push dx
    push si
    push di
    push es

	mov ax, 0B800H	; video entrance.
	mov es, ax

	mov ax, 0A0H	; 160 byte each line.
	mul dh	        ; MAX result is 4000
    mov dh, 0
	add ax, dx      ; add char offset
	add ax, dx      ; add attr offset
	mov di, ax	    ; video header pointer
int_each_char:
	mov ah, 0
	mov al, ds:[si]
	cmp ax, 0h
	je int_ok
	mov ah, cl	    ; color
	mov es:[di], ax

	inc si
	inc di
	inc di
	jmp int_each_char

int_ok:
    pop es
    pop di
    pop si
    pop dx
    pop ax
	iret

int_end:
	nop

code_seg ends
end start

