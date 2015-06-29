; 17.4 read CHS=001 to 0:200

assume cs:code

code segment
start:
	mov ax, 0
	mov es, ax
    ; write something to 200 for check int13 is ok when debug
	mov bx, 0h	
    mov cx, 512
write_200:
    mov byte ptr es:[bx+200h], 0ffh
    inc bx
    loop write_200

    ; read CHS=001 to 200h
	mov bx, 200h	;ES:BX for write buf.
	mov ah, 2	    ; 2: read sector
	mov al, 1	    ; sector num

	mov ch, 0	    ; Cylinder no
	mov cl, 1	    ; Sector no
	mov dh, 0	    ; Header no
	mov dl, 80h	    ; driver no. 0: floppy A,
				    ; C: 80h, D: 81h.
	int 13h         ; read from sector

    ; print return no in ah
    mov al, ah
    add al, 30h
    mov ah, 9   ; show char
    mov bl, 4   ; color
    mov bh, 0   ; page 0
    mov cx, 1
    int 10h

	mov ax, 4c00h
	int 21h

code ends
end start

