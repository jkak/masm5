assume cs:code_seg, ds:data_seg, es:table_seg, ss:stack_seg

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
data_seg ends

stack_seg segment
	dw 16 dup(0)
stack_seg ends

table_seg segment
	db 21 dup('Year Summ NU ?? ')
	; 21 lines.
table_seg ends



code_seg segment

start:
	mov ax, data_seg
	mov ds, ax
	
	mov ax, stack_seg
	mov ss, ax
	mov sp, 10h

	mov ax, table_seg
	mov es, ax
	mov di, 0	; table

	mov cx, 21	; loop times
	mov si, 0	; src index for year and income
	mov di, 0	; des index for write table
	mov bx, 0	; src index for member

year_lp:
	mov ax, ds:[si+0]	; year
	mov es:[di+0], ax
	mov ax, ds:[si+2]
	mov es:[di+2], ax

	mov ax, ds:[si+60h]	; income lower
	mov es:[di+5], ax
	mov dx, ds:[si+62h]	; income higher
	mov es:[di+7], dx   ; DX:AX for income

	push cx
	mov cx, ds:[bx+0c0h] ; member, use cx
	mov es:[di+10], cx	 ; cx also for div

	; div
	div cx
	mov es:[di+13], ax	; save quotient number

	pop cx
	add si, 4	; for year and income.
	add bx, 2	; for member
	add di, 10h	; for des line.
	loop year_lp

	mov ax, 4c00h
	int 21h

code_seg ends

end start

