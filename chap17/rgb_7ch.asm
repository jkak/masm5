; 17.2 
; set frontground color by rgb. quit with q.

assume cs:code

code segment
start:
	mov ah, 0
	int 16h     ; ascii in al

	mov ah, 1   ; defaut frontground color is blue.
	cmp al, 'r'
	je red
	cmp al, 'g'
	je green
	cmp al, 'b'
	je blue

	cmp al, 'q'	; to quit
	je sret
	
red:	        ; red include green, so shl 2
	shl ah, 1
green: 
	shl ah, 1   ; green shl 1
blue:
	mov bx, 0b800h
	mov es, bx
	mov bx, 1
	mov cx, 2000
color_lp:
	and byte ptr es:[bx], 0f8h  ; clear bit 2-0.
	or es:[bx], ah              ; set color
	add bx, 2
	loop color_lp

	jmp short start
sret:
	mov ax, 4c00h
	int 21h

code ends
end start

