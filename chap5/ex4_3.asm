; ex 4-3:
; copy code before exit to 0:200

assume cs:code_seg

code_seg segment
    mov ax, cs
    mov ds, ax
    mov ax, 20h
    mov es, ax

    mov bx, 0   ; for offset
    mov cx, 17h ; for loops
trans_lp:
    mov al, ds:[bx]
    mov es:[bx], al
    inc bx
    loop trans_lp

    mov ax, 4c00h
    int 21h

code_seg ends
end
