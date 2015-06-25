; ex5-5:

assume cs:code_seg

a segment
    db 1,2,3,4,5,6,7,8
a ends

b segment
    db 1,2,3,4,5,6,7,8
b ends

cc segment
    db 0,0,0,0,0,0,0,0
cc ends


code_seg    segment
start:  
    mov ax, a
    mov ds, ax

    mov bx, 0
    mov cx, 8
add_lp:
    mov al, ds:[bx]
    add al, ds:[bx+16]
    mov ds:[bx+32], al
    inc bx
    loop add_lp


    mov ax, 4c00h
    int 21h
code_seg    ends

end start
