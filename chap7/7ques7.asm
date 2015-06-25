; question 7.7 use [bx+si]
; to capitalize the Header char of each line in data_seg 

assume cs:code_seg, ds:data_seg, ss:stack_seg

data_seg    segment
    db 'ibm             '   ;16 char each line
    db 'dec             '
    db 'dos             '
    db 'vax             '
data_seg    ends

stack_seg	segment
	dw 0,0,0,0,0,0,0,0	; 8 WORD
stack_seg	ends

code_seg    segment
code_start:
	mov ax, stack_seg	; stack seg
	mov ss, ax
	mov sp, 10h

    mov ax, data_seg	; data seg
    mov ds, ax
    mov bx, 0h

	mov cx, 4h
tag_out:
	push cx
	mov cx, 3h
	mov si, 0h
	
	tag_inside:
		mov al, [bx+si]
	    and al, 0DFh
		mov [bx+si], al
	    inc si
		loop tag_inside

	pop cx
	add bx, 10h
	loop tag_out

	mov ax, 4c00h
	int 21h

code_seg    ends

end code_start

