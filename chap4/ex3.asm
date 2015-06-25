assume cs:code_seg

code_seg segment
	mov ax, 2000h
	mov ss, ax
	mov sp, 0
	add sp, 10
	
	pop ax
	pop bx

	mov ax, 1234h
	mov bx, 6789h
	push ax
	push bx
	
	mov ax,4c00h
	int 21h
code_seg ends
end
