assume ds:data_seg, cs:code_seg

data_seg segment
	dd 12345678h
data_seg ends

code_seg segment
start:
	mov ax, data_seg
	mov ds, ax
	mov bx, 0

    mov [bx], bx
    mov [bx+2], cs

    jmp dword ptr ds:[0]

	mov ax, 4c00h
	int 21h

code_seg ends

end start

