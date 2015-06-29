; 15.4 
; show a-z, ESC change color

assume cs:code

stack segment
	db 32 dup (0)
stack ends

data segment
	dw 0, 0
data ends

code segment

start:
	mov ax, stack
	mov ss, ax
	mov sp, 32

	mov ax, data
	mov ds, ax
	mov ax, 0
	mov es, ax

	push es:[9*4]	; save int9 vector to data_seg: ip
	pop ds:[0]
	push es:[9*4+2]	; save int9 vector to data_seg: cs
	pop ds:[2]

	; set new int 7 vector
	cli
	mov word ptr es:[9*4], offset int9_routine
	mov es:[9*4+2], cs
	sti


    ; #########################################
    ; show 'a' to 'z' 
	mov ax, 0b800h
	mov es, ax
	mov ah, 'a'
lp_char:
	mov es:[160*12+40*2], ah
	call delay
	inc ah
	cmp ah, 'z'
	jna lp_char

	mov ax, 0
	mov es, ax
	push ds:[0]	
	pop  es:[9*4]       ; recovery int9 vector: ip
	push ds:[2]
	pop  es:[9*4+2]     ; recovery int9 vector: cs

	mov ax, 4c00h
	int 21h


; #########################################
; func: delay 

delay:
	push ax
	push dx
	mov dx, 6h
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


; #########################################
; func: int9_routine
int9_routine:
	push ax
	push bx
	push es

	in al, 60h
	pushf
	call dword ptr ds:[0]   ; origin int9 routine

	cmp al, 1h      ; ESC's scan code is 1h
	jne int9_ret

	mov ax, 0b800h
	mov es, ax
	inc byte ptr es:[160*12+40*2+1]

int9_ret:
	pop es
	pop bx
	pop ax
	iret

code ends
end start

