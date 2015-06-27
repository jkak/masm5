; design one
; show 21 years info data of DEC corp. on screen(80*25)
;
assume cs:code_seg, ds:data_seg, ss:stack_seg

stack_seg segment stack
	db 32 dup(0)	 
stack_seg ends

data_seg segment
	db '1975', '1976', '1977', '1978', '1979', '1980', '1981', '1982'
	db '1983', '1984', '1985', '1986', '1987', '1988', '1989', '1990'
	db '1991', '1992', '1993', '1994', '1995', '    ', '    ', '    '
	; 21 year string. 1B*4*21=84 
	; 24*4B/16B=6line: 00h-5fh, last 3 are null

	dd 16,		22,		382,	1356,	2390,	8000,	16000,	24486
	dd 50065,	97479,	140417,	197514,	345980,	590827,	803530,	1183000
	dd 1843000,	2759000,3753000,4649000,5937000,0,		0,		0
	; dword of income(k$) for 21 year. 4Byte * 21 = 84. (84-167)
	; 24*4/16B=6line: 60h-bfh. last 3 are null

	dw 3,		7,		9,		13,		28,		38,		130,	220
	dw 476,		778,	1001,	1442,	2258,	2793,	4037,	5635
	dw 8226,	11542,	14430,	45257,	17800,	0,		0,		0
	; member number for 21 year. 2Byte * 21 = 42. (168-209)
	; 24*2/16B=3line: 0c0h-0efh. last 3 are null

	; used as transit point for show_str
	db 32 dup(0)	; start as 0f0h

	; table for write data 
	; 17 line above. here begin with 110h 
	db 21 dup('Year Summ NU ?? ')
	; 21 lines.

data_seg ends


code_seg segment

start:
; #############################################
; init segment 
	mov ax, stack_seg	; stack
	mov ss, ax
	mov sp, 20h

	mov ax, data_seg	; data
	mov ds, ax

	mov ax, 0B800H	    ; video entrance.
	mov es, ax

; #############################################
; compute corp data
	mov cx, 15h		; loop times
	mov si, 0		; src index for year and income
	mov di, 110h	; des index for write table
	call compute_corp_data


; #############################################
; init the screen before show data
    mov dh, 1h
	mov cx, 15h	    ; 21 lines
	call init_shown_screen


; #############################################
; show corp data
; dh for start line, cx for lines, si for offset
	mov si, 110h
	call show_corp_data


	mov ax, 4c00h
	int 21h

; end of main
; #############################################




; #############################################
; sub func: init_shown_screen
; parameter:
;	DH for start line 
;	CX for lines

init_shown_screen:
	push ax
	push bx
	push cx
	push di

	mov al, 0a0h
	mul dh	
	mov bx, ax	    ; start addr to show
	mov ax, 720h	; display ' ' with black background
	mov di, 0h	    ; colomn on a line

init_screen:	
	push cx
	mov cx, 50h	    ; 80 byte each line

    init_a_line:
        mov es:[bx+di], ax
        add di, 2
        loop init_a_line
	pop cx
	loop init_screen

	pop di
	pop cx
	pop bx
	pop ax
	ret



; #############################################
; sub func: compute_corp_data
; parameter:
;	cx	loop times
;	ds:[si] :  index of src data
;	ds:[di] :  index of des for write 
compute_corp_data:
	push ax
	push bx
	push cx
	push dx
	push si
	push di

	mov bx, 0	; src index for member
each_year:
	mov ax, ds:[si+0]	; centery of year
	mov ds:[di+0], ax
	mov ax, ds:[si+2]
	mov ds:[di+2], ax

	mov ax, ds:[si+60h]	; income lower
	mov ds:[di+5], ax
	mov dx, ds:[si+62h]	; income higher
	mov ds:[di+7], dx	; now DX:AX are income for div
	push cx
	mov cx, ds:[bx+0c0h]  ; member -> cx, also for div
	mov ds:[di+10], cx
	call div_dw         ; return DX:AX quo, cx rem
	mov ds:[di+13], ax	; save quo in ax, ignore DX
	
	add si, 4	; for year and income
	add bx, 2	; for member
	add di, 10h	; for next des line
	pop cx
	loop each_year

	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret



; #############################################
; sub func: show_corp_data
; to show corp data
; parameters:
;   DH for start line on screen(0-24)
;   CX for lines, 
;   DS:SI for offset of data
;   ES:   for video segment
show_corp_data:
	push ax
	push bx	
	push cx
	push dx
	push si
	push di

	mov di, si		; di for offset of table data, 
	mov si, 0f0h	; si for d2char as transit point
    mov bl, dh      ; bl for row

show_each_year:
; call show_str, parameter:
;   DS:SI : tr_pointer,  CL : color, 
;   DH	  : row(0-24)    DL : col(0-79)
	push cx
	mov cl, 4h	        ; color

	mov ax, ds:[di+0h]	; year
	mov ds:[si+0], ax
	mov ax, ds:[di+2h]
	mov ds:[si+2], ax
    mov dh, bl          ; row
	mov dl, 4h	        ; colomn to show
	call show_str

	mov ax, ds:[di+5h]	; income low
	mov dx, ds:[di+7h]	; income high
	call d2char		    ; DX:AX data to char in DS:SI
	mov dh, bl	        ; row
	mov dl, 10h	        ; colomn  to show
	call show_str

	mov ax, ds:[di+0ah]	; members
	mov dx, 0
	call d2char	
	mov dh, bl	        ; row
	mov dl, 1eh	        ; colomn  to show
	call show_str

	mov ax, ds:[di+0dh]	; avg of income
	mov dx, 0
	call d2char
	mov dh, bl	        ; row
	mov dl, 2ah	        ; colomn  to show
	call show_str

	add di, 10h	        ; for each year.
	inc bx		        ; show lines on screen

	pop cx
	loop show_each_year

	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret


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

