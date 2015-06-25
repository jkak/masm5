; program 5.5 and 5.6
; func: sum ffff:0 ~ ffff:b to dx.

assume cs:code_seg

code_seg segment
    mov ax, 0ffffh
    mov ds, ax
    mov bx, 0   ; for loop index

    mov dx, 0   ; for sum
    mov ax, 0   ; transit for read from mem
    mov cx, 12  ; for loop times

add_lp:
    mov al, ds:[bx]
    add dx, ax
    inc bx
    loop add_lp

    mov ax, 4c00h
    int 21h

code_seg ends
end
