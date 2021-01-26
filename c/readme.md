


## 研究实验1 simple.c

基于之前在linux下使用dosbox环境学习汇编。这部分研究实验也如此。只需要将windows下的tc2.0的整个文件目录复制到当前目录，命名为./tc/即可。这样在./run_dos.sh启动dosbox后，即可以直接使用tc了。

为了研究tc对编译文件的依赖，我们另建一个干净的目录来测试。
```bash
mkdir c/LIB/ -p
cp tc/TC.EXE  ./c/
./run_dos.sh
```

run tc in dosbox
```bat
c:\>cd c\
c:\>c>tc.exe
```
在上述启动的tc环境中，在菜单项“Options”的“Directories”中，所有的路径都设置为“LIB\”。这个目录即上面建立的c/LIB/目录，目前是空的。再“Save options”保存。
再在c目录下编写如下1simple.c文件。

```c
main()
{
    printf("hello world!\n");
}
```
之后编译到目标文件。Compile --> compile to OBJ。编译成功。 在c目录下可以看到新生成的1simple.obj文件。再使用。Compile --> Link EXE file生成exe文件。编译失败。
此时提示"Unable to open input file 'C0S.OBJ"，
按如下方式拷贝c0s.obj文件后，CTRL+F4刷新dosbox后再编译，提示需要UMU.LIB文件。
重复如下动作，依次需要依赖如下文件：MATHS.LIB, GRAPHICS.LIB, CS.LIB。当如下5个文件都拷贝到miniTc时，编译成功。
```bash
cd masm5/c/LIB/
cp ../tc/LIB/C0S.OBJ ./
cp ../tc/LIB/EMU.LIB ./
cp ../tc/LIB/MATHS.LIB ./
cp ../tc/LIB/GRAPHICS.LIB  ./
cp ../tc/LIB/CS.LIB  ./
```

编译后debug。debug如下：
```bat
c:>tools\debug.exe 1simple.exe
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

### 子函数调用2ur2.c

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

编译后debug可以看到，有两个函数程序。1fah地址处是f函数，之后的203地址处才是主函数。主函数中通过call 01fah来调用的f函数。







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

![bp-stack](https://github.com/jkak/masm5/blob/master/c/bp-stack.png)

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


## 不用main函数编程
4f.c代码：
```c
f()
{
    *(char far *)(0xb8000000+160*10+80) = 'a';
    *(char far *)(0xb8000000+160*10+81) = 2;
}
```
汇编代码。在tc中，commpile时正常，但在Linker时出错。
Linker Error:Undefined symbol ‘_main’in module C0S（未定义的符号_main在模块C0S中）。说明c语言的入口函数main是被C0S.obj调用的。

使用tools\link.exe  4f.obj 生成可执行文件。大小仅为541Byte。再debug时，程序并没有像平常有main的函数那样代码开始于01fah地址。而是直接从0号偏移地址开始即相关代码如下：
```asm
push bp     ; begin at cs:0
mov bp, sp
mov bx, b800
mov es, bx
mov bx, 0690
es:
mov byte ptr [bx], 61
mov bx, b800
mov es, bx
mov bx, 0691
es:
mov byte ptr [bx], 02
pop bp
ret
```

将上述的代码，f() 改为main()，再编译。主体代码出现在01fah地址了。f()编译后只有541Byte.而main()编译后有4k多。
main()编译成4m.exe后，在偏移为11ah处有call 01fa，从而进入主函数。在偏移地址1fah处的代码即4f.exe中的代码。

### 编译c0s.obj
```asm
cd c\
..\tools\link.exe  lib\c0s.obj
..\tools\debug.exe c0s.exe
# 在另一个dosbox窗口中对比观察。
..\tools\debug.exe 4m.exe
```
c0s.exe, 4m.exe两个文件在debug观察时。
第一条指令对dx的赋值不同。前者是078C, 后者是07C3。
后面一大段相同。至008c地址开始，前者使用[0000]内存地址，后者使用[019C]，附近亦有相应变化。
至于到了11A地址，前者直接call 11D，此调用相当于直接继续执行下一个地址的指令。 后者则直接是call 1FA。进入main函数。

经过书上相关分析，开发系统提供了c程序所必须的初始化和程序返回等相关程序，这些程序放在相关.obj文件中，这些程序和用户写的程序编译后的.obj文件进行连接，用户程序才可正确运行。运行时由c0s.obj文件中的程序调用main函数来运行用户程序。

通过这些分析，我们只要重写一个c0s.obj文件即可不用main函数编程。

### 仿造c0s.obj
c0s.asm代码如下。
```asm
assume cs:code

data segment
    db  128 dup (0)
data ends

code segment
start:  
    move ax, data
    mov ds, ax
    mov ss, ax
    mov sp, 128

    call s
    int 21h
s:
code ends
end start
```

编译：
```dos
c:\c> ..\dos\masm.exe c0s.asm
```

将上述生成的c0s.obj临时代替lib\c0s.obj文件。
此时再在tc.exe 4f.c中编译时，仅提供“No stack”。已经可以生成4f.exe文件了。并且可以执行输出正常结果。debug查看代码如下。

```asm
mov ax, 076c
mov ds, ax
mov ss, ax
mov sp, 0080
call 0012
mov ax, 4c00
int 21
push bp     ; addr of 12h
mov bp, sp
mov bx, b800
mov es, bx
mov bx, 0690
es:
mov byte ptr [bx], 61
mov bx, b800
mov es, bx
mov bx, 0691
es:
mov byte ptr [bx], 02
pop bp
ret
```

恢复LIB/C0S.OBJ文件。




## 接收不定数量参数
编写5a.c代码。

```c
void showchar(char a, int b);

main()
{
    showchar('a', 2);
}

void showchar(char a, int b)
{
    *(char far *) (0xb8000000+160*10+80) = a;
    *(char far *) (0xb8000000+160*10+81) = b;
}
```

通过debug看如何给函数showchar传递参数。

```asm
push bp
mov bp, sp
mov ax, 0002
push ax
mov al 61
push ax
call 020b
pop cx
pop cx
pop bp
ret

push bp
mov bp, sp
mov al, [bp+04]
mov bx, b800
mov es, bx
mov bx, 0690
es:
mov [bx], al

mov al, [bp+06]
mov bx, b800
mov es, bx
mov bx, 0691
es:
mov [bx], al
pop bp
ret
ret
```
从上可以看出，c中调用函数是通过栈传递参数的，调用前将参数依次从右往左入栈。
参数在函数中是局部变量，类似于创建局部变量，等价于在子程序调用前为其创建局部变量。不同之处是子程序里局部变量通过保存和恢复sp寄存器来释放局部变量空间，参数的局部变量必须通过调用完成后多次调用pop操作来释放栈空间。


### 不定长参数
```c
void showchar(int, int, ...);

main()
{
    showchar(8, 2, 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h');
}

void showchar(int n, int color,...)
{
    int a;
    for (a=0; a!= n; a++)
    {
        *(char far *) (0xb8000000+160*10+80+a+a) = *(int *)(_BP+8+a+a);
        *(char far *) (0xb8000000+160*10+81+a+a) = color;
    }
}
```
可见，函数是通过第一个参数来传递变长部份的长度。在函数内部，则根据参数的个数，使用sp＋偏移的方式来访问。

注意for循环的实现方式。
```asm
jmp 027E
# main loops
# ...
# end of main loops 

inc si
cmp si, [bp+04]     #  addr 027E
jnz 0235
# end of for
```
其中实现显存地址（0xb8000000+160*10+80+a+a）加法，汇编如下（其中SI为循环体中的a变量）：
```asm
mov ax, si
cwd
push dx
push ax
mov ax, si
cwd
pop bx      ; bx = ax, 是si（即a）的低位
pop cx      ; cx = dx, 扩展成32位的高16位
add bx, ax  ; 实现a＋a的低位 
adc cx, dx  ; 实现a＋a的高位
add bx, 0690    ；160＊10＋80＝1680＝0x690H
adc cx, b800    ；高位
mov es, cx
```



### 分析printf函数传递参数
观察printf函数的调用。
```C
void main()
{
    printf("some char: %c, %c, %c", 'x', 'y', 'z');
    printf("some int : %d, %d", 63, 127);
}
```
观察主函数的内容如下：
```asm
push 007A   # 'z'
push 0079   # 'y'
push 0078   # 'x'
push 0194   # string 
call 0ADB   # printf

add sp, +08
push 007F   # 127
push 003F   # 63
push 01AA   # string
call 0ADB   # printf
add sp, +06
pop bp
ret

```
通过上面的分析，0194及01AA地址应该都是存在要打印的格式化字符串的首地址。且在DS段中。使用g 1fa来执行进入到main函数。再使用d ds:194, d ds:1aa分别查看两个地址段的内容，确认就是格式串。并且串是以0结束的。
如"some int : %d, %d"对应为：736f 6d65 20 696e 74 203a 20 25 64 2c 25 64 00 00 00 00. 其中2564即对应一个%d。2564的数量即对应了数字的个数。

至于实现简易的printf函数。可以仿照前面的showstr函数，第一个参数用来表示可变参数的个数。函数内部的基本逻辑是：
> * 从格式化字符串开始扫描，如果不是％，则直接输出。
> * 如果是％，则读取下一个字符，确认是c or d
>> * 是c：直接输出对应的变量中的字符
>> * 是d：需要将对应的变量中的数，转换成要输出的每一位数字

代码略。



