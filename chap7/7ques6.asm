; question 7.6 : use [bx+idata]
; to capitalize the Header char of each line in data_seg 

assume cs:code_seg, ds:data_seg

data_seg    segment
    db '1. file         '   ;16 char each line
    db '2. edit         '
    db '3, search       '
    db '4, view         '
	db '5, options      '
	db '6, help         '
data_seg    ends

code_seg    segment
code_start:
    mov ax, data_seg
    mov ds, ax
    mov bx, 0h
	mov cx, 6

head_lp:
    mov al, [bx+3]
    and al, 0DFh    ; Upper
    mov [bx+3], al
    add bx, 10h
    loop head_lp
	
	mov ax, 4c00h
	int 21h
code_seg    ends

end code_start
