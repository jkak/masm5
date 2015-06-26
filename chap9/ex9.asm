assume cs:code_seg, ds:data_seg, ss:stack_seg

stack_seg segment
	dw 16 dup(0)
stack_seg ends

data_seg segment
	db '   Welcome to Assembly World!!  '	
	; 32 byte 
	db 02h, 24h, 71h	; color attr for 3 line
data_seg ends

code_seg segment
start:
	mov ax, stack_seg	; stack
	mov ss, ax
	mov sp, 10h
	mov ax, data_seg	; source data
	mov ds, ax
	mov ax, 0b800h	    ; for des of video memory
	mov es, ax

	mov ax, 0
	mov cx, 3 	; outside loop times for lines

	mov di, 11*160+30h	; center of 12th line offset
	mov bx, 20h		    ; for color attr offset
line_lp:
	mov si, 0	    ; src index
	mov ah, ds:[bx] ; read attr

    push di         ; prepare for next line add header addr
	push cx
	mov cx, 20h	    ; resue cx as inside loops
    char_lp:
        mov al, ds:[si]	    ; read char
        mov es:[di], ax	    ; write char and attr
        inc si
        add di, 2
        loop char_lp

    inc bx	        ; for next attr read
    pop cx
    pop di
    add di, 0a0h	; for next line char display
    loop line_lp

	mov ax, 4c00h
	int 21h

code_seg ends
end start

