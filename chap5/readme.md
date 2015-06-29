
# 程序5.5, 5.6

```bash
vim ./chap5/6loop.asm
# input as program 5.6
./runDOS.sh

```

以下在dos环境下操作。

```dos
asm.bat  chapt4/6loop.asm  6loop
; masm and link assembly
debug 6loop.exe
; 通过t单步调试，观察各register的变化。
```

另外需要注意，不能需要向内存中写数据，需要清楚写入的地址不会影响到系统的执行。目前默认使用0000:200h~0000:2FFh段来保存程序。



# 实验4
## 4-1
基本的编辑及汇编等过程略。debug程序时，运行到结束前，观察d 0:200地址开始的空间是否写入了预期的数据。

## 4-2
功能同4-1，但bx得复用，即做数据源，又是写入地址的offset。

## 4-3
复制代码到0:200h，则数据源在cs，关键是如何确定要复制代码的长度。一个方法是先随机写个数，再编译程序，通过debug里使用u命令观察各条指令的地址。从而可以确定mov ax, 4c00h在17h号地址，入长度为17h。




