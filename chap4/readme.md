

# 实验３

```bash
vim ./chap4/ex3.asm
# input as program ex3
./runDOS.sh

```

以下在dos环境下操作。如果之前先打开了dosbox环境，则刚才新建立的ex3.asm文件在dosbox中看不到。此时可以对dosbox操作使用ctrl+F4来刷新mount，从而可以看到最新的文件。

```dos
asm.bat  chapt4/ex3.asm  ex3
; masm and link assembly
debug ex3.exe
; 通过r命令查看DS, CS刚好相关10H，这个距离正好是psp的内存空间。
; 通过d ds:0 1f　查看PSP段的首两个字节是CD 20
```


