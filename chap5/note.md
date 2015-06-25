
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


