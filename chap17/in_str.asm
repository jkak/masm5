; 17.3  input and show string
; max length of string is 80!!!

assume cs:code, ds:data

data segment
	db 81 dup(0)    ; length is 80(0-79), last byte(80) for NULL
data ends

code segment
start:
	mov ax, data
	mov ds, ax
	mov si, 0	    ; for string stack
	mov dh, 4
	mov dl, 0
    mov byte ptr ds:[80], 0h     ; write NULL to string
	call get_str

	mov ax, 4c00h
	int 21h

; #############################################
; func: get_str
; paramters:
;	ds:si for str stack

get_str:
	push ax
get_char:
	mov ah, 0           ; for read from keyboard
	int 16h
	cmp al, 20h
	jb not_char	        ; al ascii < 20h
	mov ah, 0
	call char_stack	    ; push char in stack
	mov ah, 2
	call char_stack	    ; show stack
	jmp get_char

not_char:
	cmp ah, 0eh	        ; scan code is backspace
	je char_backspace
	cmp ah, 1ch	        ; scan code is enter
	je char_enter
	jmp get_char

char_backspace:
	mov ah, 1
	call char_stack	    ; pop out stack
	mov ah, 2
	call char_stack	    ; show stack
	jmp get_char

char_enter:
	mov al, 0
	mov ah, 0
	call char_stack	    ; push 0 in stack
	mov ah, 2
	call char_stack	    ; show stack
	
	pop ax
	ret





; #################################
; func: char_stack 
; parameter
;	ah: func no. 
;		0: in  stack, al= in char
;		1: out stack, al=return char
;		2: show. dh=row, dl=col.
;	ds:si string stack

char_stack:
	jmp short char_start

table dw char_push, char_pop, char_show
top	  dw 0	    ; top is the stack top pointer ready to push

char_start:
	push bx
	push dx
	push di
	push es

	cmp ah, 2
	ja char_ret
	mov bl, ah
	mov bh, 0
	add bx, bx
	jmp word ptr table[bx]

char_push:
	mov bx, top		; top is stack location
    cmp bx, 80      ; max len of stack
    jnb last_byte   ; equ or above 80
	mov [si][bx], al
	inc top
	jmp char_ret
last_byte:
; the last byte ds:[80] is init to NULL. so it's no use to write NULL again
; if write non-NULL, this is WRONG. return only. no return error.
    jmp char_ret
    

char_pop:
	cmp top, 0	    ; stack top is blank?
	je char_ret         ; top is blank, so ret 
	dec top
	mov bx, top
	mov al, [si][bx]
	jmp char_ret

char_show:
	mov bx, 0b800h
	mov es, bx
	mov al, 160
	mov ah, 0
	mul dh		    ; dh:dl for row:col
	mov di, ax
	add dl, dl
	mov dh, 0
	add di, dx      ; show start at di

	mov bx, 0
char_show_each:		; ds:si for str stack
	cmp bx, top		; bx from 0 to top
	jne noempty
	mov byte ptr es:[di], ' '
	jmp char_ret
noempty:
	mov al, [si][bx]
	mov es:[di], al
	mov byte ptr es:[di+2], ' '	; prepare for backspace.
	inc bx
	add di, 2
	jmp char_show_each

char_ret:
	pop es
	pop di
	pop dx
	pop bx
	ret

code ends
end start

