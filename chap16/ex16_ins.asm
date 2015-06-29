; ex 16 : install int 7ch 
;   function: int 7ch routine to set screen
;     sub 0: clear screen
;     sub 1: set frontground
;     sub 2: set background
;     sub 3: roll up a line
; parameter:
;	ah: sub func no
;	al: color = {0-7}

assume cs:code

code segment

start:
	mov ax, cs	        ; code of int routine as data
	mov ds, ax
	mov si, offset int7ch_setscreen

	mov ax, 0H	        ; int vector
	mov es, ax
	mov di, 200h
	; length of int code
	mov cx, offset int7ch_end - offset int7ch_setscreen
	cld
	rep movsb

	; set int vector
	mov word ptr es:[7ch*4], 200h	; int IP
	mov word ptr es:[7ch*4+2], 0	; int CS

	mov ax, 4c00h
	int 21h


; #############################################
; func: int7ch_routine 

; org is important for offset, this is different from book.
org 200h	
int7ch_setscreen:
	jmp short  set_id
	table dw sub0, sub1, sub2, sub3

set_id:
	push bx
	cmp ah, 3	    ; if ah > 3, iret
	ja sret
	mov bl, ah
	mov bh, 0
	add bx, bx	    ; offset of sub id
	call word ptr table[bx]
sret:
	pop bx
	iret


; ##################################
; func sub0: clear screen 
; set all even video byte as " "
sub0:
	push bx
	push cx
	push es

	mov bx, 0b800h
	mov es, bx
	mov bx, 0
	mov cx, 2000
sub0_lp:
	mov byte ptr es:[bx], ' '
	add bx, 2
	loop sub0_lp
	pop es
	pop cx
	pop bx
	ret


; ##################################
; func sub1: set frontground color 
;   set bits 2-0 of all odd video byte
; parameter: al: color
sub1:
	push bx
	push cx
	push es
	mov bx, 0b800h
	mov es, bx
	mov bx, 1
	mov cx, 2000
sub1_lp:
	and byte ptr es:[bx], 0f8h  ; bits 2-0
	or es:[bx], al	            ; set color
	add bx, 2
	loop sub1_lp
	pop es
	pop cx
	pop bx
	ret
	

; ##################################
; func sub2: set background color 
; set bits 6-4 of all odd video byte
; parameter: al: color

sub2:
    push ax
	push bx
	push cx
	push es
	mov cl, 4
	shl al, cl	    ; align to 6-4 bits
	mov bx, 0b800h
	mov es, bx
	mov bx, 1
	mov cx, 2000
sub2_lp:
	and byte ptr es:[bx], 8fh   ; bits 6-4 
	or es:[bx], al	            ; set color
	add bx, 2
	loop sub2_lp

	pop es
	pop cx
	pop bx
    pop ax
	ret
	

; ##################################
; func sub3: roll up a line 
;       copy n+1 line to n line. 
;       last line(24) set to blank.
sub3:
	push cx
	push si
	push di
	push es
	push ds

	mov si, 0b800h
	mov es, si
	mov ds, si
	mov si, 160		; ds:si for n+1 line
	mov di, 0		; es:di for n   line
	mov cx, 24      ; 24 lines
sub3_lp:
	push cx
	mov cx, 160
	cld
	rep movsb
	pop cx
	loop sub3_lp

	mov cx, 80      ; 80 bytes
	mov si, 0
sub3_last:
	mov byte ptr [160*24+si], ' '
	add si, 2
	loop sub3_last

	pop ds
	pop es
	pop di
	pop si
	pop cx
	ret

int7ch_end:
	nop

code ends
end start

