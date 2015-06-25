; ex5-2:

assume cs: code_seg, ds:data_seg, ss:stack_seg

data_seg    segment
    dw 0123h, 0456h
data_seg    ends

stack_seg   segment
    dw 0,0
stack_seg   ends

code_seg    segment
start:  
    mov ax, stack_seg
    mov ss, ax
    mov sp, 10h
    mov ax, data_seg
    mov ds, ax

    push ds:[0]
    push ds:[2]
    pop ds:[2]
    pop ds:[0]

    mov ax, 4c00h
    int 21h
code_seg    ends

end start
