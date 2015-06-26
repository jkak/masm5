assume ds:data_seg, cs:code_seg

data_seg segment
    db 0, 0, 0
data_seg ends

code_seg segment
start:
	mov ax, data_seg
	mov es, ax
	mov bx, 0
	jmp word ptr es:[bx+1]

code_seg ends

end start
