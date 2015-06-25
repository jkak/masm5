; practice 7-9

assume cs:code_seg, ds:data_seg, ss:stack_seg

data_seg    segment
    db '1. display      '   ;16 char each line
    db '2. brows        '
    db '3. replace      '
    db '4. modify       '
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

	mov cx, 4h	; outside loops
tag_out:
	push cx
	mov cx, 4h	; inside loops
	mov si, 0h
	
	tag_inside:
		mov al, [bx+si+3]
	    and al, 0DFh
		mov [bx+si+3], al
	    inc si
		loop tag_inside

	pop cx
	add bx, 10h
	loop tag_out

	mov ax, 4c00h
	int 21h

code_seg    ends

end code_start

