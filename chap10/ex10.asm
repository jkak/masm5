; ex 10: implement 3 sub-program
;   show_str: show string on screen 
;   div_dw: avoid divide overflow
;   d2char: number to char

assume cs:code_seg, ds:data_seg, ss:stack_seg

stack_seg segment stack
	db 32 dup(0)	 
stack_seg ends

data_seg segment
	db 'Welcome to Asm!',0
	db 32 dup(0) 

data_seg ends


code_seg segment

start:
	mov ax, stack_seg	; stack
	mov ss, ax
	mov sp, 20h

	mov ax, data_seg	; data
	mov ds, ax

	mov ax, 0B800H	    ; video entrance.
	mov es, ax


; #############################################
; test of show_str, show string times in CX
	mov cx, 12	; loop lines(0-24)
	mov dh, 1   ; row
	mov dl, 0   ; col

lines:
	mov si, 0
	jcxz line_done
	push cx
	mov cl, 2	; color green	
	call show_str

	inc dh
	inc dl
	pop cx
	loop lines
line_done:
    nop



; #############################################
; test of div_dw    ; result: 11124h
    mov ax, 0EEEEh
    mov dx, 0FFFFh
    mov cx, 0EFEFh
    call div_dw



; #############################################
;   test of d2char. change DX:AX to char
;   DS:SI for write result 
	mov si, 10h
	call d2char     ; 11124h -> 69924

;   now string at ds:[si]
	mov si, 10h
	mov dh, 0fh
	mov dl, 0fh
	mov cl, 4h
	call show_str


	mov ax, 4c00h
	int 21h

; end of main
; #############################################



; #############################################
; sub func: d2char
; parameter:
;	DX:AX is a Dword int
;	DS:SI for write string addr
d2char:
    push ax
	push bx
	push cx
    push dx
	push si

	mov bx, 0	; for counter
div_lp:
	mov cx, 0ah	; for div(divisor) and jcxz
    call div_dw
    add cx, 30h ; rem NUM --> ASCII code
    push cx

	inc bx	    ; counter
	mov cx, dx	; dx is Quo high
    jcxz chk_ax ; DX zero, go check AX
    inc cx      ; except cx=1
	jcxz div_lp
chk_ax:
    mov cx, ax      ; ax is Quo low
    jcxz div_done   ; AX zero, done
    jmp div_lp
div_done:
	mov cx, bx	    ; counter
wr_mem:
	pop ds:[si]
	inc si
	loop wr_mem

    mov word ptr ds:[si], 0h ; write the end flag!!!
    pop si
    pop dx
	pop cx
	pop bx
    pop ax
	ret



; ##############################################
; sub func: show_str
; paramters: 
;	DS:SI : str_pointer, 
;   ES:   : video segment
;	CL	  : color, 
;   DH	  : row(0-24) 0: 0h~9FH, 1: 0A0H~140H
;   DL    : col(0-79)
show_str:
	push ax
	push bx
    push cx
    push si
	push di
	
	; video pointer
	mov al, 0A0H	; 160 byte each line.
	mov bl, dh	    ; row
	mul bl	        ; MAX result is 4000

	mov bh, 0	; ready for add dl
	mov bl, dl
	add ax, bx	; add column char offset
	add ax, bx	; add column attr offset
	mov di, ax	; video header pointer
	mov ah, cl	; now ah is color
	mov cx, 0	; CX for jcxz

show_char:
	mov cl, ds:[si]
	jcxz show_done
		
	; display
	mov al, cl		; char in al, attr in ah
	mov es:[di], AX	; display char and attr

	inc si
	inc di
	inc di
	loop show_char

show_done:
	pop di
    pop si
    pop cx
	pop bx
	pop ax
	ret


; #############################################
; sub func: div_dw 
;   DX:AX: dividend higher:lower
;   CX	 : divisor 
; return 
;   DX:AX quotient
;   cx remainder
; DX:AX/CX = int(DX/CX)*65536 + [rem(DX/CX)*65536+AX]/CX

div_dw:
	push si	; temp Quotient High
	push bx	; for temp
	push ax	; src lower

	mov ax, dx	; high
	mov dx, 0
	div cx	    ; DX/CX: Quo in AX, Rem in DX
	mov si, ax	; for quotient high

	pop ax		; lower
	div cx	    ; dx:ax/cx. Quo in AX, Rem in DX
	mov cx, dx	; rem of result
	mov dx, si	; dx:ax is quotient

	pop bx
	pop si
	ret



code_seg ends

end start

