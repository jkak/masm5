; ex 16: test int 7ch:
;	sub 0: clear screen
;	sub 1: set frontground
;	sub 2: set background
;	sub 3: roll up a line
; parameter:
;	ah: sub func no
;	al: color = {0-7}


assume cs:code_seg

code_seg segment
start:
	call delay
	mov ah, 1
	mov al, 4	; red front
	int 7ch

	call delay
	mov ah, 2
	mov al, 1	; blue back
	int 7ch

	call delay
	mov ah, 3	; roll up
	int 7ch

	call delay
	mov ah, 0   ; clear screen
	int 7ch

	mov ax, 4c00h
	int 21h


; #############################################
; func: to delay some seconds.
delay:
	push ax
	push dx
	mov dx, 10h
	mov ax, 0ffffh
s1: sub ax, 1
	sbb dx, 0

	cmp ax, 0
	jne s1
	cmp dx, 0
	jne s1
	pop dx
	pop ax
	ret

code_seg ends
end start

