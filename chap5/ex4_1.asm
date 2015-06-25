; ex 4-1:
; use [bx] and loop to trans data 0-63 to 0:200~0:23Fh.

assume cs:code_seg

code_seg segment
    mov ax, 0h
    mov ds, ax

    mov bx, 200h

    mov al, 0   ; for src  
    mov cx, 64  ; for loops

trans_lp:
    mov ds:[bx], al
    inc al
    inc bx
    loop trans_lp

    mov ax, 4c00h
    int 21h

code_seg ends
end
