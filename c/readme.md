
## 研究实验1 simple.c

基于之前在linux下使用dosbox环境学习汇编。这部分研究实验也如此。只需要将tc2.0的整个文件复制到当前目录，命名为./tc/即可。这样在./run_dos.sh启动dosbox后，即可以直接使用tc了。

```bash
./run_dos.sh
```
 run tc in dosbox
```bat
c:\>tc\tc.exe
```

在述启动的tc软件中，编写如下simple.c文件，编译后debug。

```c
main()
{
    printf("hello world!\n");
}
```
debug如下：
```bat
c:>tools\debug.exe simple.exe
u  cs:01f0
```

通过u命令，可以观察到，从0x1fah地址开始是如下指令

```asm
push bp
mov bp, sp
mov ax, 0194h
push ax
call 0abbh
pop cx
pop bp
ret
```

其中的call即在调用printf函数，其中的194h应是printf中那个字符串的首地址。只是很奇怪，没有找到那段字符串。


## 研究实验2 register

编写ur1.c

```c
main()
{
    _AX = 1;
    _BX = 1;
    _CX = 2;
    _AX = _BX + _CX;
    _AH = _BL + _CL;
    _AL = _BH + _CH;
    printf("offset of main: %x\n", main);
}
```

通过u命令，可以观察到，从*0x1fah*地址开始是如下指令

```asm
push bp
mov bp, sp
mov ax, 0001
mov bx, 0001
mov cx, 0002
mov ax, bx
add ax, cx
mov ah, bl
add ah, cl
mov al, bh
add al, ch

mov ax, 01fah
push ax
mov ax, 0194h
push ax
call 0ad5h
pop cx
pop cx
pop bp
ret
ret
```

01fah是main函数本身的入口地址。0194h是要打印的串，也就是说，给函数传参数时，是从右向左压栈的。这样函数内出栈参数时，正好是从左向右顺序的。


```c
void f(void)
{
    _AX = _BX + _CX;
}

main()
{
    _AX = 1;
    _BX = 1;
    _CX = 2;
    f();
}
```

编译后debug可以看到，有两个函数程序。主函数中通过call 01fah来调试的f函数。




## 研究实验3 memory
```c
main()
{    *(char *)0x2000 = 'a';
     *(int  *)0x2000 = 0xf;
     *(char far *)0x20001000='a';

     _AX=0x2000;
     *(char *)_AX='b';
     _BX=0x1000;
     *(char *)(_BX+_BX)='a';
     *(char far *)(0x20001000+_BX) = *(char *)_AX;
}
```
汇编
```asm
push bp
mov bp, sp

mov byte ptr [2000], 61
mov word ptr [2000], 000f
mov bx, 2000
mov es, bx
mov bx, 1000
es:
mov byte ptr [bx], 61

# base on ES
mov ax, 2000
mov bx, ax
mov byte ptr [bx], 62

mov bx, 1000
add bx, bx
mov byte ptr [bx], 61

mov bx, ax
mov al, [bx]
xor cx, cx
add bx, 1000
mov cx, 2000
mov es, cx
es:
mov [bx], al
pop bp
ret
ret
```

### 打印字符a
代码
```c
main()
{
    _BX = 160*12+40*2;
    *(char far *)(0xb8000000+_BX+0) = 'a';
    *(char far *)(0xb8000000+_BX+1) = 0x2;
    /*    
    *(int far *)0xb80007d0) = 0x261;      
    */
}

```

汇编

```asm
push bp
mov bp, sp
mov bx, 07d0
xor cx, cx
add bx, 0
adc 0x, b800
mov es, cx
es:
mov byte ptr [bx], 61

xor cx, cx
add bx, 1
adc cx, b800
mov es, cx
es:
mov byte ptr [bx], 02

pop bp
ret
ret
```


### 全局变量
代码
```c
int a1,a2,a3;

void f(void);

main()
{
    int b1,b2,b3;
    a1 = 0xa1; a2 = 0xa2; a3 = 0xa3;
    b1 = 0xb1; b2 = 0xb2; b3 = 0xb3;
}

void f(void)
{
    int c1,c2,c3;
    a1 = 0x0fa1; a2 = 0x0fa2; a3 = 0x0fa3;
    c1 = 0xc1;   c2 = 0xc2;   c3 = 0xc3;
}
```
对应汇编代码
```asm
# main func
push bp
mov bp, sp
sub sp, +06
mov word ptr [01a6], 00a1   ; global var
mov word ptr [01a8], 00a2
mov word ptr [01aa], 00a3
mov word ptr [bp-6], 00b1   ; local var b*
mov word ptr [bp-4], 00b2
mov word ptr [bp-2], 00b3
mov sp, bp
pop bp
ret

# f func 
push bp
mov bp, sp
sub sp, +06
mov word ptr [01a6], 0fa1   ; global var
mov word ptr [01a8], 0fa2
mov word ptr [01aa], 0fa3
mov word ptr [bp-6], 00c1   local var c*
mov word ptr [bp-4], 00c2
mov word ptr [bp-2], 00c3
mov sp, bp
pop bp
ret
ret

```
其中的sub sp, +06，是空出6个栈空间，用来存放局部变量。相当于申请存储空间。栈地址是从高向低方向的。因此sub之后，sp指向的栈顶下面空了6个byte。因为bp的值并没有sub，还是原来的栈顶。其-2即在原栈顶存放b3。定义的顺序是b1, b2, b3，压栈顺序是b3, b2, b1。

![bp-stack](https://github.com/jungle85gopy/masm5/blob/master/c/bp-stack.png)

从上可见，函数开始的push bp, mov bp, sp，是用来传递局部变量的。以方便修改栈空间。程序结束时，mov sp, bp，将sp的值改回原值，销毁局部变量。

可以通过在函数中申请不同类型的变量，以观察sub sp时应该减去多少。

### 返回值
代码。
```c
int f(void);
int a,b,ab;
main()
{
    int c;
    c = f();
}
int f(void)
{
    ab = a+b;
    return ab;
}
```

汇编

```asm

push bp
mov bp, sp
sub sp, +02     ; for var c
call 020a       ; main func call f func
mov [bp-02], ax ; return value write to var c
mov sp, bp
pop bp
ret

push bp         ; 020a addr of f func 
mov bp, sp
mov ax, [01a6]
add ax, [01a8]
mov [01aa], ax  ; write result to global var: ab 
mov ax, [01aa]  ; write return value to ax
jmp 021c
pop bp      ; 021c addr
ret
ret         ; for exit from psp
```

如上可见，对于整数型变量，通过ax寄存器传回的参数。另可以将变量改为字符型。可观察到，对于char，是通过al来传送返回值的。

### malloc

c代码。

```c
#define buffer ((char *)*(int far *)0x02000000)

main()
{
    buffer = (char *)malloc(20);
    buffer[10] = 0;
    while (buffer[10] != 8)
    {
         buffer[buffer[10]] = 'a' + buffer[10];
         buffer[10]++;
    }
}
```

汇编。

```asm
PUSH BP
MOV BP,SP
MOV AX,0014     ; parameter of malloc(20)
PUSH AX
CALL 04DD       ; malloc(AX)
POP CX
MOV BX,0200
MOV ES,BX
XOR BX,BX
ES: 
MOV [BX],AX     ; AX: Mem Addr return from malloc 
                ; write to ES:BX(0200h:0)

MOV BX,0200
MOV ES,BX
XOR BX,BX
ES: 
MOV BX,[BX]     ; read MemAddr from buffer[0] to BX
MOV BYTE PTR [BX+0A], 00    ; init buffer[10]

JMP 025B        ; check loops

;;;; addr of 021F.  main of while loops
MOV BX,0200     
MOV ES,BX
XOR BX,BX
ES: 
MOV BX,[BX]     ; head addr of buffer
MOV AL,[BX+0A]  ; al is counter for loops 
ADD AL,61       ; al is char from 'a'
 
MOV BX,0200
MOV ES,BX
XOR BX,BX
ES: 
MOV BX,[BX]
PUSH AX         ; char   
PUSH BX         ; buf pointer
MOV BX,0200
MOV ES,BX
XOR BX,BX
ES: 
MOV BX,[BX]
MOV AL,[BX+0A]  ; al is counter
CBW             ; al byte to word
POP BX
ADD BX,AX       ; buf header  add  counter,
 
POP AX          ; recover counter
MOV [BX],AL     ; write char to buf[counter]
 
MOV BX,0200
MOV ES,BX
XOR BX,BX
ES: 
MOV BX,[BX]
INC BYTE [BX+0A]    ; buf[10] ++
 
;;;;; Addr of 025B. judge expression 
;;;;; of while loops
MOV BX,0200                              
MOV ES,BX
XOR BX,BX
ES: 
MOV BX,[BX]
CMP BYTE PTR [BX+0A], 08
JNZ 021F

POP BP
RET
RET 
```

通过将ip指向新的01fah，执行，调用malloc后，申请的地址空间通过AX返回。

## 不用main函数返回
4f.c代码：
```c
f()
{
    *(char far *)(0xb8000000+160*10+80) = 'a';
    *(char far *)(0xb8000000+160*10+81) = 2;
}
```
汇编代码。在tc只连接时出错。
Linker Error:Undefined symbol ‘_main’in module C0S（未定义的符号_main在模块C0S中）。说明c语言的入口函数main是被C0S.obj调用的。

使用tools\link.exe  4f.obj 生成可执行文件。再debug时，程序并没有像平常有main的函数那样，代码开始于01fah地址。

将上述的代码，f() 改为main()，再编译。主体代码出现在01fah地址了。f()编译后只有541Byte.而main()编译后有4k多。









