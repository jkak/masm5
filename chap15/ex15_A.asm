; ex 15
; when relax A, the screen full with A
assume cs:code, ss:stack

stack segment
	db 32 dup (0)
stack ends

code segment
start:
	mov ax, stack
	mov ss, ax
	mov sp, 32

	mov ax, cs	    ; ds:si for install int9
	mov ds, ax
	mov si, offset int9_routine

	mov ax, 0
	mov es, ax
	mov di, 204h	; CS:IP start 200h, so new routine start at 204h
	mov cx, offset int9_end - offset int9_routine
	cld
	rep movsb       ; install int9

	push es:[9*4]	; save int9 vector to data_seg: ip
	pop  es:[200h]
	push es:[9*4+2]	; save int9 vector to data_seg: cs
	pop  es:[202h]  ; origin int9 vector save to es:[200-203]

	; set new int9 vector
	cli
	mov word ptr es:[9*4], 204h
	mov word ptr es:[9*4+2], 0h
	sti

	mov ax, 4c00h
	int 21h

; #################################
; func: int9_routine 
int9_routine:
	push ax
	push bx
	push cx
	push es

	in al, 60h
	pushf
	call dword ptr cs:[200h]    ; origin int9 routine

	cmp al, 9eh	    ; 1eh is scan code for 'a'
                    ; 1eh + 80h for relax 'A'
	jne int9_ret
	mov ax, 0b800h  ; show a full with screen
	mov es, ax
	mov bx, 0
	mov cx, 2000
show_a:
	mov byte ptr es:[bx], 'A'
	add bx, 2
	loop show_a

int9_ret:
	pop es
	pop cx
	pop bx
	pop ax
	iret
int9_end:
	nop

code ends
end start

