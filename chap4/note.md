

# 实验３

```bash
vim ./chap4/ex3.asm
# input as program ex3
./runDOS.sh

```

以下在dos环境下操作。

```dos
asm.bat  chapt4/ex3.asm  ex3
; masm and link assembly
debug ex3.exe
; 通过r命令查看DS, CS刚好相关10H，这个距离正好是psp的内存空间。
; 通过d ds:0 1f　查看PSP段的首两个字节是CD 20
```


