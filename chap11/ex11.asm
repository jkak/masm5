; ex 11 
; capital all the letters. end with NULL

assume cs:code_seg, ds:data_seg, ss:stack_seg

stack_seg segment stack
	db 32 dup(0)	 
stack_seg ends

data_seg segment
	db "Beginner's All-purpose Symbolic Instruction Code. v587!", 0
data_seg ends


code_seg segment

start:
	mov ax, stack_seg   ; stack
	mov ss, ax
	mov sp, 20h
	mov ax, data_seg    ; data
	mov ds, ax
	mov ax, 0B800H	    ; video entrance.
	mov es, ax

	mov si, 0       ; src index of str
	mov cl, 04h	    ; red
	mov dx, 200h    ; row: 2, col: 0 
	call show_str   ; show origin string

	call letter_upper
	
	mov cl, 02h	    ; green
	mov dx, 300h    ; row: 3, col: 0 
	call show_str   ; show capitalized string

	mov ax, 4c00h
	int 21h



; ## letter_upper #################################
; paramters: 
;	DS:SI : str pointer, end with 0,

letter_upper:
	push ax
	push bx
	push cx
	push si
	mov ch, 0h

each_loop:
	mov cl, ds:[si]
	jcxz chk_done

	cmp cl, 61h
	jb chk_next
	cmp cl, 7ah
	ja chk_next
	
	sub cl, 20h		; process
	mov ds:[si], cl	; write back
chk_next:	
	inc si
	jmp each_loop

chk_done:
	pop si
	pop cx
	pop bx
	pop ax
	ret


; #############################################
; sub func: show_str. refer ex10.asm
; paramters: 
;	DS:SI : str_pointer, 
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
	mov al, 0A0H    ; 160 byte each line.
	mov bl, dh      ; row
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

