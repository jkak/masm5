; design a OS!
; author : jungle85gopy
; date   : 2015.06.30


;##############################################
; Sector 1 (CHS=001)
; Sector 1 only has func of sectors2mem, 
;   and then jmp to main_entrance

org	07c00h		; mbr will be load to 0:7c00h

start:
    call sectors2mem    ; copy floppy sectors to mem

    mov	ax, 0
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
    mov ax, 0h
    mov es, ax
    mov bx, 7e00h   ; es:bx mem addr for copy floppy sector

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
    push bx
    push cx
    push dx
    push si
    push di
    mov si, ax      ; backup ax 
    mov di, bx      ; backup bx

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

    mov bx, di      ; es:bx for mem addr
    int 13h         ; read/write a logic sector.

    pop di
    pop si
    pop dx
    pop cx
    pop bx
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
    call delayL

    ; clear screen
    mov cx, 0           ; from row:col = 0:0
    mov dx, 184fh       ;   to row:col = 24:79
    call int10h_clear_screen

    call delayL

    ; show select
    mov ax, 105h        ; select 1, 5 lines 
main_select_lp:
    call show_select_item

    ; input select
    mov dx, 0h          ; when enter, dx= selected line
    call input_select
    cmp dx, 0
    je main_do_item_0   ; only delay
    cmp dx, 1
    je main_do_item_1   ; restart current os
    cmp dx, 2
    je main_do_item_2   ; restart from system on c:
    cmp dx, 3
    je main_do_item_3   ; show clock 
    cmp dx, 4
    je main_do_item_4   ; set  clock 

    jmp main_select_lp

main_do_item_0:
    call delay
    jmp main_select_lp
main_do_item_1:
    call restart_sys

main_do_item_2:
    call restart_sys_c

main_do_item_3:
    call show_clock_ctrl
    jmp main_select_lp

main_do_item_4:
    call set_clock_ctrl


main_select_again:
    ; jmp for all select je 
    jmp main_select_lp


fin:
    hlt
    jmp	fin 		; loop forever



;#### func end ####



;###################################
; define data:

select_msg:
    db "Select item to run: (Up|Down)  ", 0
    db "    * reset pc system          ", 0
    db "    * start existed system     ", 0
    db "    * show clock               ", 0
    db "    * set  clock               ", 0
;   db "-------|+++++++|-------|+++++++|"


boot_msg:
    db "test info: Hello, OS world!", 0

; data about clock
time_style:
    db 'yy/mm/dd hh:mm:ss', 0
time_table:
    db 9, 8, 7, 4, 2, 0
;      y  m  d  h  m  second offset of date in cmos








;##################################
; func: show_init_str
;   string begin at ds:si, end with NULL
;   row:col is 10:20

show_init_str:
    push cx
    push dx
    push ds
    push es
    push si

    mov ax, cs          ; src seg
    mov ds, ax         
    mov si, boot_msg    ; src offset
    mov cx, 0b800h      
    mov es, cx          ; des seg
    mov cl, 07h
    mov dh, 10          ; row 10
    mov dl, 10          ; col 10

    call show_str

    pop si
    pop es
    pop ds
    pop dx
    pop cx
    ret

;#### func end ####



;###################################
; func: delayL . wait some seconds longer.
delayL:
    push cx
    mov cx, 10h
delay_lp:
    call delay
    loop delay_lp

    pop cx
    ret
;#### func end ####



;###################################
; func: delay . wait some seconds.
delay:
    push ax
    push dx
    mov dx, 08h
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
; func: 

;#### func end ####



;###################################
; func: show_select_item
;   show msg defined at select_msg. start at row 0.
; paramter: 
;   ah is selected line.
;   al is num of lines

show_select_item:
    push cx
    push dx
    push ds
    push es
    push si
    push ax
    
    ; clear item lines
    mov cx, 0       ; start line
    mov dh, al      ; lines
    dec dh          ; end line
    mov dl, 4fh
    call int10h_clear_screen

    ;#### parameter of show_str
    mov ax, cs
    mov ds, ax
    mov si, select_msg  ; select msg addr
    mov ax, 0b800h
    mov es, ax
    mov cl, 07h         ; white color for default
    mov dh, 0h          ; first row at: 0
    mov dl, 8h          ; first col at: 8h

    pop ax
show_select_each_line:
    cmp dh, al          ; al is num of lines
    jnb show_select_ret
    cmp dh, ah          ; is selected line?
    je line_equ
    mov cl, 07h         ; white color for default
    jmp call_show_str
line_equ:
    mov cl, 24h         ; red color, green background.
    call show_str
    add dl, ch          ; ch is str len ret frm show_str
    call set_cursor     ; row:col in dh:dl
    sub dl, ch          ; recover dl
    jmp show_add_offset

call_show_str:
    call show_str
show_add_offset:
    add si, 20h
    inc dh
    jmp show_select_each_line

show_select_ret:
    pop si
    pop es
    pop ds
    pop dx
    pop cx
    ret

;#### func end ####



;###################################
; func: set_cursor
; parameter: dh:dl is row:col to set cursor. 

set_cursor:
    push ax
    push bx
    mov ah, 2       ; set cursor
    mov bh, 0       ; page 0
    int 10h
    pop bx
    pop ax
    ret

;#### func end ####




;###################################
; func: read_kb  to read keyboard input
; return:
;   ax: ah: scan code, al ascii. al=0 means no input
read_kb:
    mov ah, 1           ; test input
    int 16h             ; scan code in ah, ascii in al
    je kb_in_ignore     ; ZF=1 means Zero, keyboard buf is blank
    mov ah, 0           ; read input 
    int 16h 
    jmp kb_in_ret

kb_in_ignore:
    mov ax, 0h
kb_in_ret:
    ret

;#### func end ####




;###################################
; func: clk_write_cmos  write time_style to cmos
clk_write_cmos:
    push ax
    push bx
    push cx
    push si
    push di
    push ds

    mov ax, cs
    mov ds, ax
    mov di, time_style      ; offset of write data
    mov si, time_table      ; offset of table for cmos
    mov cx, 6h

clk_write_each:
    mov ax, [ds:di]     ; year 15: al=0x31, ah=0x35 --> 0x15
    mov bl, ah
    mov ah, al
    mov al, bl
    sub ax, 3030h       ; 0x01, 0x05
    
    push cx
    mov cl, 4
    shl ah, cl          ; high, 0x10h
    and al, 00fh        ;  low, 0x05h
    and ah, 0f0h
    add ah, al          ; ah: 0x15h

    mov al, [ds:si]     ; offset in table 
    out 70h, al 
    mov al, ah
    out 71h, al         ; write to cmos

    inc si
    add di, 3           ; except '/' or ':'
    pop cx
    loop clk_write_each

    pop ds
    pop di
    pop si
    pop cx
    pop bx
    pop ax
    ret

;#### func end ####





;###################################
; func: clk_read_kb
; parameters:
;   cl: color,  dh:dl is row:col

clk_read_kb:
    push ax
    push cx
    push dx

clk_init_stack:
    push di
    mov di, clk_top		; clk_top is stack location
    mov byte [ds:di], 0
    pop di

clk_get_char:
    mov ah, 0
    int 16h

    cmp al, 20h
    jb clk_not_char	        ; al ascii < 20h
    mov ah, 0
    call clk_char_stack	    ; push char in stack
    jmp clk_get_char

clk_not_char:
    cmp ah, 0eh	            ; scan code is backspace
    je clk_char_backspace
    cmp ah, 1ch	            ; scan code is enter
    je clk_char_enter
    jmp clk_get_char
clk_char_backspace:
    mov ah, 1
    call clk_char_stack	    ; pop out stack
    jmp clk_get_char
clk_char_enter:
    mov ax, 0
    call clk_char_stack	    ; push 0 in stack

    pop dx
    pop cx
    pop ax
    ret

;#### func end ####



; #################################
; func: clk_char_stack  based on time_style
; parameter
;	ah: func no. 
;     0: in  stack, al= in char
;     1: out stack, al= return char
;   cl: color
;   dh:dl is row:col

clk_char_stack:
	jmp short clk_char_start

clk_table dw clk_char_push, clk_char_pop, clk_char_show
clk_top   db 0  ; clk_top is the stack top pointer ready to push

clk_char_start:
    push bx
    push dx
    push ds
    push si
    push di

    mov bx, cs
    mov ds, bx
    mov si, time_style  ; index of time buf
    mov bx, 0
    mov bl, ah
    add bl, bl
    jmp word [cs:clk_table+bx]

clk_char_push:
    mov di, clk_top		; clk_top is stack location
    mov ah, [ds:di]
    cmp ah, 17          ; max len of stack
    mov bl, ah          ; pointer
    jnb last_byte       ; equ or above 17
    mov [ds:si+bx], al
    inc byte [ds:di]
    jmp clk_char_show
last_byte:
; the last byte ds:[si+17] is init to NULL. 
; so it's no use to write NULL again
; if write non-NULL, this is WRONG. return only. no return error.
    jmp clk_char_show
    
clk_char_pop:
    mov di, clk_top		; clk_top is stack location
    mov ah, [ds:di]
    cmp ah, 0	        ; stack clk_top is blank?
    je clk_char_ret     ; clk_top is blank, so ret 
    mov bl, ah
    dec bl              ; pointer to the top data
    mov al,  [ds:si+bx]
    mov byte [ds:si+bx], " "
    mov byte [ds:di], bl

clk_char_show:
    call show_clock_set
    ; set cursor of next input char for line time_style
    inc dh
    add dl, [ds:di]
    add dl, 4
    call set_cursor     

clk_char_ret:
    pop di
    pop si
    pop ds
    pop dx
    pop bx
    ret

;#### func end ####




;###################################
; func: input_select
; parameter: 
;   ax. ah: selected line. al: lines
;       eg: 105, total 5 lines. selected scope is 1-4
; ret: ax:
;       ah: the new selectd line. 
;       al: never changed here
;       dx: =1, when enter

input_select:
    push bx
    push cx
    mov dx, 0
    mov bx, ax
    mov cl, al      ; lines
    dec cl          ; bottle line. select scope

input_lp:
    mov ah, 0
    int 16h         ; scan code in ah, ascii in al
    
    cmp ah, 1ch     ; ENTER
    je in_enter

    cmp ah, 48h     ; Up   key
    je in_up
    cmp ah, 50h     ; Down key
    je in_down

    jmp input_lp
	
in_up:
    mov ax, bx
    cmp ah, 1       ; top already, roll to bottle
    je in_up_roll
    dec ah
    jmp in_ret
in_up_roll:
    mov ax, bx      ; reovery al: lines
    mov ah, cl      ; roll selected line to bottle
    jmp in_ret
    
in_down:
    mov ax, bx
    cmp ah, cl      ; bottle already, roll to top
    je in_down_roll
    inc ah
    jmp in_ret
in_down_roll:
    mov ax, bx      ; reovery al: lines
    mov ah, 1       ; roll selected line to bottle
    jmp in_ret

in_enter:
    mov ax, bx      ; reovery ax
    mov dl, bh      ; bh is the selected item line for enter
in_ret:
    pop cx
    pop bx
    ret

;#### func end ####




;###################################
; func: restart_sys to restart system 

restart_sys:
    call show_init_str 
    call delayL

    push bp
    mov bp, sp
    mov word [bp+2], 0h      ; modify IP in stack
    mov word [bp+4], 0ffffh  ; modify CS in stack
    pop bp              
    ; now, the top of stack is CS:IP, far return to restart
    retf                

;#### func end ####




;###################################
; func: restart_sys_c to restart system on C:

restart_sys_c:
    call show_init_str
    call delayL

    mov ax, 0h
    mov es, ax
    mov bx, 7c00h   ; es:bx mem addr for copy C: MBR sector
    mov ah, 0       ; read sector
    mov al, 80h     ; read disk C
    mov dx, 0       ; start from logic sector 1.(0 is mbr)
    call sec2mem    ; copy MBR sector to mem

reset_cs_ip:
    push bp
    mov bp, sp
    mov word [bp+2], 7c00h  ; modify IP in stack
    mov word [bp+4], 0h     ; modify CS in stack
    pop bp              
    ; now, the top of stack is CS:IP, far return to restart
    retf                

;#### func end ####




;###################################
; func: show_clock_ctrl  to control of show clock from cmos
show_clock_ctrl:
    push ax
    push cx
    push dx

    ; clear show zone
    mov cx, 0a00h           ; start line
    mov dx, 0b4fh
    call int10h_clear_screen

    mov cl, 04              ; set color
    mov dh, ch              ; set start line
    mov dl, 0ch
clk_ctrl_lp:
    call show_clock
    call delay
    call read_kb
    ; 0: no input, other: input occur.
    cmp ax, 0
    je clk_read_no
    cmp ah, 01h             ; scan code of ESC
    je clk_ctrl_ret
    cmp ah, 3bh             ; scan code of F1
    je clk_read_f1
    jmp clk_read_no

clk_read_f1:
    inc cl                  ; change color
    cmp cl, 8h              
    jne clk_read_no
    mov cl, 1h              ; 111B -> 1000B, roll to 001B

clk_read_no:
    jmp clk_ctrl_lp
    
clk_ctrl_ret:
    ; clear show zone
    mov cx, 0a00h           ; start line
    mov dx, 0b4fh
    call int10h_clear_screen

    pop dx
    pop cx
    pop ax
    ret

;#### func end ####



;###################################
; func: show_clock to show clock from cmos
; parameter:
;   cl: attr of color for clock
;   dx: dh:dx is row:col

show_clock:
    jmp clk_start
time_tips   db 'ESC for exit, F1 to change color:', 0

clk_start:
    push ax
    push cx
    push dx
    push si
    push di
    push ds
    push es

    mov ax, cs
    mov ds, ax
    mov di, time_style      ; write index
    mov si, time_table      ; src index of cmos
    mov ax, cx
    mov cx, 6h
    call clk_read_cmos

    ; show clock string
    mov cx, ax              ; cl is color. dh:dl is row:col
    mov si, time_tips       ; read index of tips
    mov ax, 0b800h
    mov es, ax
    call show_str

    mov si, time_style      ; read index of time
    inc dh
    add dl, 4
    call show_str
    call set_cursor

    pop es
    pop ds
    pop di
    pop si
    pop dx
    pop cx
    pop ax
    ret

;#### func end ####




; #############################################
; func: set_clock_ctrl set new clock
set_clock_ctrl:
    push ax
    push cx
    push dx

    ; clear show zone
    mov cx, 0a00h           ; start line
    mov dx, 0b4fh
    call int10h_clear_screen

    mov dh, ch              ; set color
    mov dl, 0ch             ; set start line
    mov cl, 04h
set_clk_ctrl_lp:
    call show_clock_set
    call delay

    call clk_read_kb        ; paramter: cl, dh:dl
    call clk_write_cmos

set_clk_ctrl_ret:
    ; clear show zone
    mov cx, 0a00h           ; start line
    mov dx, 0b4fh
    call int10h_clear_screen
    pop dx
    pop cx
    pop ax
    ret


;#### func end ####




; #############################################
; func: show_clock_set  to show info for set clock
; parameters:
;   cl: attr of color for clock
;   dx: dh:dx is row:col

show_clock_set:
    jmp set_clk_start
set_time_tips   db 'pls input new date and time as below format:', 0

set_clk_start:
    push ax
    push cx
    push dx
    push si
    push ds
    push es

    ; show clock string
    mov ax, cs
    mov ds, ax
    mov si, set_time_tips   ; read index of tips
    mov ax, 0b800h
    mov es, ax              ; video seg
    call show_str

    mov si, time_style      ; read index of time
    inc dh
    add dl, 4
    call show_str
    call set_cursor


    pop es
    pop ds
    pop si
    pop dx
    pop cx
    pop ax
    ret

;#### func end ####





; #############################################
; func: read_cmos
; parameter:
;   cx: loop times.     ds for segment.
;   si: src index of cmos
;   di: write index
clk_read_cmos:
    push ax
    push cx
    push si
    push di
read_each:
    mov al, [ds:si]     ; from ds
    out 70h, al 
    in  al, 71h         ; read port
    
    ; compute data
    push cx
    mov ah, al
    mov cl, 4
    shr ah, cl          ; high
    and al, 0fh         ;  low
    add ah, 30h	        ; high to ascii
    add al, 30h         ;  low to ascii
    
    mov [ds:di], ah     ; both ds
    mov [ds:di+1], al
    inc si
    add di, 3           ; except '/' or ':'
    pop cx
    loop read_each

    pop di
    pop si
    pop cx
    pop ax
    ret

;#### func end ####




; ##############################################
; sub func: show_str show string end with NULL
; paramters: 
;   DS:SI : str_pointer 
;   ES:   : video segment
;   CL	  : color, 
;   DH	  : row(0-24) 0: 0h~9FH, 1: 0A0H~140H
;   DL    : col(0-79)
; return: 
;   CH    : string length
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
    
    mov bh, 0	    ; ready for add dl
    mov bl, dl
    add ax, bx	    ; add column char offset
    add ax, bx	    ; add column attr offset
    mov di, ax	    ; video header pointer
    mov ah, cl	    ; now ah is color
    mov cx, 0	    ; CX for jcxz
    mov bl, 0       ; as counter of length
show_char:
    mov cl, [ds:si]
    jcxz show_done
    ; display
    mov al, cl		; char in al, attr in ah
    mov [es:di], AX	; display char and attr
    inc si
    inc di
    inc di
    inc bl
    loop show_char
    
show_done:
    pop di
    pop si
    pop cx
    mov ch, bl      ; ret value in ch
    pop bx
    pop ax
    ret
    
;#### func end ####



; ##############################################
; sub func: 


;#### func end ####


; #############################################








; 600h sector3
    db "abcdefgh"
    times 2046-($-$$) db 0   ; fill with 0 to logic sector 3
    db "ok"

