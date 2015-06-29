
#　第十七章
更新版的键盘输入读取流程图。

![keyboard_input](https://github.com/jungle85gopy/masm5/blob/master/chap17/keyboard_in.png)

## 输入rgb改变屏幕颜色 rgb_7ch.asm
通过BIOS的int 16h中断，来读到键盘的输入。

在对rgb的处理上，因为显示属性中，最低三位为显示颜色，分别对应rgb。故先默认默认颜色是blue，当判断输入为red时，跳转到red，顺序执行时会shl两次，则正好对应red，如果是green，则只shl一次。如果是blue，则不需要移位。直接输出即可。

本程序增加了q做为退出命令。


## 输入字符串 in_str.asm

书上提供了完整的程序，但有个缺点，即没有限定输入字符串的长度。

此处限定串长最大为80个字符。定义时使用了81个字节，并在一开始即交最后一个字节初始化为NULL。每当输入字符需要入字符串栈时，需要检测当前栈顶是否到达了结束符。如果到达，则直接丢弃。


## 读取磁盘前首扇区(MBR) read_mbr.asm
这里特别需要注意。使用dosbox在测试时，总是观察不到读入的数据。
原因参考网上说明。因为这不是在实模式下进行的。

[dosbox下int 13h不能读入数据的原因](http://zhidao.baidu.com/link?url=xLO7L0WA6tIpjFDkg2EUltjNbkFHw253XvKcOwLaGsBYYlR5kxW6aBXnol4pD1dTcWiau850n_3rlwmY2AOM_K)

关于此程序的调试，作者在虚拟机下安装dos系统。并将文件映像到光驱下。已经调试可行。具体参考作者上传到文库的文档。

[VMWare下安装dos系统并通过iso格式共享磁盘文件到dos环境](http://wenku.baidu.com/view/be0dc982f78a6529657d5385)


