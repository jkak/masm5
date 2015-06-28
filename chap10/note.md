

# 第十章

## 检查点10.5
分析代码执行完成后AX的值。

```asm
assume cs:code_seg ss:stack_seg

stack_seg segment
    dw 8 dup(0) 
    ; 16 byte all zero
    ; addr from 0h to 0eh, 0fh.
stack_seg ends

code_seg segment
start:
    mov ax, stack_seg
    mov ss, ax
    mov sp, 10h
    mov ds, ax  ; ds point to stack.
    mov ax, 0
    call word ptr ds:[0EH]
    inc ax
    inc ax
    inc ax
    mov ax, 4c00h
    int 21h
code_seg ends
end start
```

执行call调用会涉及如下步骤:

* 先取出指令
* IP指向了第一条inc指令，假设其地址为add_inc，
* 执行call指令：
　* SP = SP -2 = 0EH
　* MOV WORD SP, add_inc，此即压栈原IP
　* IP = ds:[0EH]，即相当于又从刚写入的单元读取add_inc地址。

至此call指令执行完成。整个call指令想法于两条空指令。程序继续执行至结束。

下一点的功能与本例近似，只不过使用的近跳转，需要同时修改CS:IP。


## 实验10 实验三个子程序

1, show_str
    这个已经比较简单。直接参考代码。需要注意的是，凡是在子程序中需要修改的register，都统一先压栈保留现场，以备返回前恢复现场。
    
2, div_dw
    本次实现时，直接使用了DX:AX/CX方式来实现除法。
    关键是要使用书上给定的公式。先用高位做除法，并将商先保留，这是最终结果的商的高位。这样操作后，DX中是刚才高位除法的余数，再次做DX:AX/CX时就不会有溢出的可能性。
    
3, d2char
    将数字转换成对应的ASCII码。通过将原数据不断的除10除余来完成转换。
    转换中，需要先判定高位是否除尽。然后再判定低位是否除尽。每步转换的余数都压栈，最后弹出到目标地址。


    
## 课程设计1
    显示相关的程序，主要调用实验10的几个子程序。原始数据的计算，参考实验七的程序。本处主要增加几个子程序：

* 初始化要显示的显存空间　init_shown_screen
* 计算原始数据后显示原始数据 show_corp_data



