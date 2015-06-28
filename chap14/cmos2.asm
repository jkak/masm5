; ex 14 access date/time in cmos ram 

assume cs:code_seg, ds:data_seg

data_seg segment
time	db 'yy/mm/dd hh:mm:ss$'
table	db 9, 8, 7, 4, 2, 0
;          y  m  d  h  m  second
; offset of date in cmos:
data_seg ends

code_seg segment
start:
	mov ax, data_seg
	mov ds, ax
	mov si, offset table
	mov di, offset time
	mov cx, 6h
    call read_cmos


    ; #########################################
    ; show time use int 21h
	mov ah, 0	; 0 sub program. set cursor
	mov bh, 0
	int 10h

	mov dx, offset time
	mov ah, 9	; 9 sub program. show string
	int 21h

	mov ax, 4c00h
	int 21h



; #############################################
; func: read_cmos
; parameter:
;	cx: loop times
;	si: src index of cmos
;	di: write index
read_cmos:
	push ax
	push cx
	push si
    push di
read_each:
	mov al, ds:[si]
	out 70h, al 
	in  al, 71h     ; read port

	; compute data
	push cx
	mov ah, al
	mov cl, 4
	shr ah, cl      ; high
	and al, 0fh     ;  low
	add ah, 30h	    ; high to ascii
	add al, 30h     ;  low to ascii
	
	mov ds:[di], ah
	mov ds:[di+1], al
	inc si
    add di, 3       ; except '/' or ':'
	pop cx
	loop read_each

    pop di
    pop si
    pop cx
    pop ax
    ret


code_seg ends
end start

