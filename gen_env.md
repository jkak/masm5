

# 部署开发环境
　　具体环境如README.md中说明。

## 汇编器调试器等
汇编器使用masm 5.0。可以参考如下[链接](http://blog.fishc.com/602.html)。该链接的5.0版本已经包括了masm.exe, linker.exe。另外需要win7 32位的debug.exe。以上已经都包括在本项目的tools/目录中。
　
增加asm.bat文件。用来一次完成对源文件的汇编和连接，以直接生成可执行文件。文件内容直接查看即可。使用方法，在dosbox中直接运行：

```bat
asm.bat test.asm test
```

在dos下的bat是可以截断字符串的，但在dosbox下却不成功，故上述asm.bat使用了２个参数，分别用于汇编和连接。

　
## dosbox
dosbox是一款优秀的环境模拟器，windows, linux, mac都可以使用。
安装命令如下：

```bash
sudo apt-get install dosbox
```

此时可以直接运行dosbox即可以启动。使用参考网上教程。
    
### 自动mount    

因为dosbox每次启动时都需要手动的mount需要用于编程的目录，如本项目的目录，这样很麻烦。其中一个办法是修改配置文件${HOME}/.dosbox/dosbox-0.74.conf，在其最后部分有提示。加上三行即可：

```bash
mount c ~/masm5/  
c:  
```

另一个办法是写个启动脚本，脚本中配置参数。此处编写runDOS.sh文件。用于启动时自动mount。并增加上述工具所在的tools目录到path变量。假设本项目放在${HOME}/masm5/目录。

```bash
#!/bin/bash
dosbox -c 'mount c: ./'  -c 'c:'  -c  'path %path%;c:\tools\'
```

### dosbox快捷键

重点会用２个即可：
> * CTRL+F4　刷新启动时mount目录。在该目录下新增文件时有用。如不刷新，则masm等工具会报错找不到文件。
> * CTRL+F5 截屏功能。保存在${HOME}/.dosbox/capture/目录。

### vim高亮汇编代码

在~/.vimrc中增加如下配置：
```vim
" for assembly "
autocmd FileType asm set ft=masm
```
再用vim打开*.asm时即可高亮代码。


