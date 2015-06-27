assume cs:code_seg ss:stack_seg

stack_seg segment
	dw 8 dup(0)
stack_seg ends

code_seg segment
start:
	mov ax, stack_seg
	mov ss, ax
	mov sp, 10h
	mov ds, ax
	mov ax, 0
	call word ptr ds:[0EH]
	inc ax
	inc ax
	inc ax
	mov ax, 4c00h
	int 21h
code_seg ends
end start
