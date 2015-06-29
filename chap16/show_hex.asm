; 16.3  addressing table to show byte in Hex

assume cs:code

code segment
start:
    jmp short start_show
	ori_table db '1234 abcd ABCD', 0
start_show:
	; video pointer
	mov ax, 0b800h
	mov es, ax
	mov di, 160*10      ; row=10,col=0 : start point to show

	mov cl, 4h          ; color
    mov bx, 0           ; loop for table
show_each_hex:
	mov al, ori_table[bx]
    cmp al, 0h
    je show_done
	call hex2asc        ; al=2Ah --> AX: 32H, 41H
	mov ch, al	        ; temp backup al
	
	mov al, ah	        ; display high char and attr
	mov ah, cl	        ; cl is color
	mov es:[di], AX		
	mov al, ch	        ; display low  char and attr
	mov es:[di+2], AX	
	inc bx
	adc di, 4
	jmp show_each_hex
show_done:
	mov ax, 4c00h
	int 21h


; #############################################
; func: hex2asc
; parameter:
;	al: a byte to show
; return: AX, ah for high 4bits, al for low 4bits.
;	eg: 2AH -> ah: 32h, al: 41h
hex2asc:
	jmp short h2a
	table db '0123456789ABCDEF'
h2a:
	push bx
	push cx
	mov ah, al
	mov cl, 4           ; high 4bits
	shr ah, cl
	and al, 0fh         ;  low 4bits

	mov bl, ah
	mov bh, 0
	mov ah, table[bx]	; high 4bits
	mov bl, al
	mov al, table[bx]	;  low 4bits

	pop cx
	pop bx
	ret

code ends
end start

