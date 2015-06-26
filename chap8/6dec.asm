; modify a struct of DEC corp

assume cs:code_seg, ds:data_seg

data_seg    segment
    db 'DECKen Oslen PDP'
    dw 137, 40
data_seg    ends

code_seg    segment
code_start:
    mov ax, data_seg	
    mov ds, ax
    mov bx, 0h

	; modiy product
	mov si, 0h
	mov byte ptr [bx].0dh[si], 'V'
	inc si
	mov byte ptr [bx].0dh[si], 'A'
	inc si
	mov byte ptr [bx].0dh[si], 'X'

	; modify ranking 
	mov word ptr [bx].010h, 38

	; modify income
	add word ptr [bx].012h, 70

	mov ax, 4c00h
	int 21h
code_seg    ends

end code_start
