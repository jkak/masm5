; question2 of 13.2
; capitalize a string

assume cs:code_seg, ds:data_seg

data_seg segment
    db 'conversation', 0
data_seg ends

code_seg segment
start:
	mov ax, cs	    ; code of int7c routine as data
	mov ds, ax
	mov si, offset int_routine

	mov ax, 0h      ; int vector
	mov es, ax
	mov di, 200h
	; length of int routine code
	mov cx, offset int_end - offset int_routine
	cld
	rep movsb

	; set int vector
	mov word ptr es:[7ch*4], 200h	; int IP
	mov word ptr es:[7ch*4+2], 0	; int CS


    ; ##### run capitalize
    mov ax, data_seg
    mov ds, ax
    mov si, 0
    int 7ch
    

	mov ax, 4c00h
	int 21h



; #############################################
; sub func : int_routine
; paramters: ds:si pointer string 
; function : to capitalize a string
int_routine:
    push ax
    push bx
	push cx
    push es
    push si
    push di

    mov di, si  ; backup si
    mov bx, 0   ; counter
    mov ch, 0
capitalize:
    mov cl, [si]
	jcxz cp_ok
    and byte ptr [si], 0dfh
    inc si
    inc bx
    jmp short capitalize

cp_ok:
	mov si, di      ; recovery si
    ; show string
    mov cx, 0b800h
    mov es, cx
    mov di, 12*160
    mov ah, 04h
    mov cx, bx      ; length of str

    show_char:
        mov al, ds:[si]
        mov es:[di], ax
        inc si
        add di, 2
        loop show_char

    pop di
    pop si
    pop es
    pop cx
    pop bx
    pop ax
	iret
int_end:
	nop

code_seg ends
end start

