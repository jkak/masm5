; design a OS!
; author : jungle85gopy
; date   : 2015.06.30


;##############################################
; Sector 1 (CHS=001)

org	07c00h		; mbr will be load to 0:7c00h

start:
    call sectors2mem    ; copy floppy sectors to mem

    mov	ax, 0
    mov ss, ax
    mov sp, 7c00h
    mov	ds, ax
    mov	es, ax

    jmp near main_entrance





;##################################
; func: sectors2mem.  
;   copy floppy sectors to mem 7e00h
; parameter:
;   ah : sub func no, 0 for read, 1 for write.
;   dx : logic sector
;   es:bx : memory segment and offset.
sectors2mem:
    mov ax, 7e0h
    mov es, ax
    mov bx, 0       ; es:bx mem addr for copy floppy sector
    mov ah, 0       ; read sector
    mov al, 0       ; read floppy

    mov cx, 3       ; sectors num
    mov dx, 1       ; start from logic sector 1.(0 is mbr)
rd_sec_lp: 
    call sec2mem    ; copy logic sector to mem
    inc dx
    add bx, 512
    loop rd_sec_lp
sectors_end:
    ret
;#### func end ####




; #############################################
; func: sec2mem
;   copy a floppy sector to mem 7e00h
; parameter:
;   ah : sub func no, 0 for read, 1 for write.
;   al : driver id. 0 for floppy, 80 for C:
;   dx : logic sector
;   es:bx : memory segment and offset.

sec2mem:
    cmp ah, 1	    ; if ah > 1, ret
    ja ah_ret

    push ax
    push cx
    push dx
    push es
    push si
    push bx
    mov si, ax      ; backup ax 

    ; compute CHS, Formula:
    ; logicSector = (Header*80  + Cylinder) * 18 + Sector - 1
    ;             = Header*1440 + Cylinder  * 18 + Sector -1
    ;   Header =      int(logicSector/1440)
    ; Cylinder = int( rem(LogicSector/1440) / 18 )
    ; Sector   = rem( rem(LogicSector/1440) / 18 ) + 1

    ; compute CHS
    mov ax, dx      
    mov dx, 0h      ; dx:ax is logicSector
    mov bx, 1440
    div bx          ; dx is  remainder, ax is quotient
    mov bx, dx      ; backup remainder
    mov dh, al      ; ### dh: Header   (0,1)
    
    mov ax, bx      ; rem(logicSector/1440)
    mov dl, 18
    div dl          ; ah is remainder, al is quotient
    mov ch, al      ; ### ch: Cylinder (0,79)
    mov al, ah
    inc al          
    mov cl, al      ; ### cl: Sector   (1,18)

    mov ax, si      ; ah: 0/1 means read/write for int7ch
    mov dl, al      ; ### dl: driver of Floppy A

    add ah, 2       ; ah: 2/3 means read/write for int13h
    mov al, 1h      ; ### al: operate only 1 Sector each time.

    pop bx          ; es:bx for mem addr
    int 13h         ; read/write a logic sector.

    pop si
    pop es
    pop dx
    pop cx
    pop ax
ah_ret:
    ret
;#### func end ####




    times 510-($-$$) db 0   ; fill with 0 to 01fdh(510) byte
    dw 	0xaa55				; end flag of MBR


; Sector 1 (CHS=001) end
;##############################################




;##############################################
; Sector 2 (CHS=002) start



;###################################
; func: main_entrance.  do all thing here

main_entrance:
    mov si, boot_msg
;    call show_init_str  ; ds:si

;    call delay

    ; clear screen
    mov cx, 0           ; from row:col = 0:0
    mov dx, 184fh       ;   to row:col = 24:79
    call int10h_clear_screen

    ; show select
    mov ax, 105h        ; select 1, 5 lines 
    call show_select_item

    ; input select
    ; call input_select


fin:
    hlt
    jmp	fin 		; loop forever



;#### func end ####



;###################################
; define data:

select_msg:
    ;tbl  dw 0, line_4, line_3, line_2, line_1, line_0
    
    db "Select item to run: (Up|Down)  ", 0
    db "    * reset pc system          ", 0
    db "    * start existed system     ", 0
    db "    * show clock               ", 0
    db "    * set  clock               ", 0
;   db "-------|+++++++|-------|+++++++|"


boot_msg:
    db 0ah, "Hello, OS world!", 0









;##################################
; func: show_init_str
;   string begin at ds:si, end with NULL

show_init_str:
    push ax
    push bx
    push si

    mov	ah, 0eh		; show a char
    mov	bx, 04h		; bh=0 : page no, bl=04h : red color.
show_init_lp:
	mov	al, [si]
    cmp al, 0
    je show_init_ret
	int	10h			; show string
    inc si
    jmp show_init_lp

show_init_ret:
    pop si
    pop bx
    pop ax
    ret
;#### func end ####



;###################################
; func: delay . wait some seconds.
delay:
    push ax
    push dx
    mov dx, 10fh
    mov ax, 0ffffh
delay_s1: 
    sub ax, 1
    sbb dx, 0
    
    cmp ax, 0
    jne delay_s1
    cmp dx, 0
    jne delay_s1
    pop dx
    pop ax
    ret
;#### func end ####




;###################################
; func: int10h_clear_screen to clear screen.
; parameter:
;   cx left-top row:col
;   dx right-bottle row:col

int10h_clear_screen:
    push ax
    push bx
    push cx
    push dx

    mov ah, 6       ; init to clear screen
    mov al, 0       ; blank
    int 10h

    mov ah, 2       ; set cursor to 0:0
    mov bh, 0
    mov dx, cx
    int 10h

    pop dx
    pop cx
    pop bx
    pop ax
    ret

;#### func end ####




;###################################
; func: get_str_len
; ds:si is the addr, end of NULL
; return cx is the length

get_str_len:
    push ax
    push si
    mov cx, 0       ; for counter
get_str_len_lp:
    mov al, [si]
    cmp al, 0
    je show_len_end
    inc cx
    inc si
    jmp short get_str_len_lp
show_len_end:
    pop si
    pop ax
    ret
;#### func end ####



;###################################
; func: 

;#### func end ####



;###################################
; func: show_select_item
;   show msg defined at select_msg. start at row 0.
; paramter: 
;   ah is selected line.
;   al is num of lines

show_select_item:
    push ax
    push bx
    push cx
    push dx
    push bp
    push si
    push di         ; for backup
    mov di,ax       ; backup ax
    
    ; clear item lines
    mov cx, 0       ; start line
    mov dh, al      ; lines
    dec dh          ; end line
    mov dl, 4fh
    call int10h_clear_screen

    mov si, select_msg  ; select msg addr
    mov dh, 0h          ; first row at: 0
    mov dl, 10h         ; first col at: 10h

    mov cx, di
    mov ch, 0           ; cx is lines
    mov bx, 0           ; offset for line msg
show_select_each_line:
    push bx             ; line offset
    push cx             ; lines

    ; check selected line no
    mov ax, di          ; ah is selected line
    mov al, 5h
    sub al, cl          ; al is diff of 5-cx
    cmp ah, al
    je line_equ
    mov bl, 07h         ; black color
    jmp line_cmp_end
line_equ:
    mov bl, 24h         ; red color, green background.
    call set_cursor
line_cmp_end:
    mov di, ax          ; backup again 
    mov bp, si          ; each line base addr for int 10h
    call get_str_len    ; length in cx

    mov ax, 1300h       ; ah:13h for show string
    mov bh, 0           ; page 0
    int	10h		        ; show string

    pop cx
    pop bx

    inc dh              ; next row to show
    add si, 20h         ; next line offset
    loop show_select_each_line

show_select_ret:
    pop di
    pop si
    pop bp
    pop dx
    pop cx
    pop bx
    pop ax
    ret

;#### func end ####



;###################################
; func: set_cursor
; parameter: al selected line

set_cursor:
    push ax
    push bx
    push dx

    mov dh, al
    mov dl, 2fh     ; str begin 10h, len 20h
    mov ah, 2       ; set cursor
    mov bh, 0       ; page 0
    int 10h

    pop dx
    pop bx
    pop ax
    ret

;#### func end ####



;###################################
; func: input_select

;#### func end ####

;###################################
; func: input_select
input_select:


;#### func end ####





;###################################
; func: 

;#### func end ####









; 200h sector1
    db "12345678"
    times 1022-($-$$) db 0   ; fill with 0 to logic sector 1
    db "ok"

; 400h sector2
    db "ABCDEFGH"
    times 1534-($-$$) db 0   ; fill with 0 to logic sector 2
    db "ok"

; 600h sector3
    db "abcdefgh"
    times 2046-($-$$) db 0   ; fill with 0 to logic sector 3
    db "ok"

