assume cs:code

data segment
    db  128 dup (0)
data ends

code segment
start:  
    mov ax, data
    mov ds, ax
    mov ss, ax
    mov sp, 128

    call s

    mov ax, 4c00h
    int 21h

s:

code ends
end start

