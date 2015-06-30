
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

补充说明。本次read_mbr.asm设置dl=80h，是从磁盘c盘读的mbr。如果要从A盘读取，则还要麻烦一点。需要在上述文档中虚拟机中，增加软驱的img映像文件。在增加完映像后，对dos系统来说，有C硬盘启动，有光盘D盘，有软驱A盘。默认的启动顺序是从A开始的，因此A盘启动会后进入安装dos的界面。选择否则会退出，并从C盘顺序启动了。

这样进入系统后，即可以在A,C,D三个盘间切换了。



## 实验17　使用逻辑扇区号读写软盘

通过逻辑扇区号，以int 7ch中断方式来读写软盘。7ch的例程将逻辑扇区号转换成真实CHS号。然后调用int 13h。

因为7ch的例程主要的工作就在转换chs，故不再又设置一层函数调试。

安装中断的代码之前已经熟悉了，故整个程序不需要过多说明。而且也已经有很多注释。

关键是需要通过软驱调试。观察程序可以正常工作。

如前面补充说明。本次也需要将ex17.asm的代码编译成ex17.exe后，通过UltraISO保存到iso文件，做为CD的映像文件。另使用安装dos的dos71_1.img源文件，做为软驱的img文件。

如此即可以在dos下通过c:\dos71\debug.exe d:\ex17.exe进行debug。本次比对了ex17.exe读取到的数据，与在linux下使用 hexdump dos71_1.img读到的数据做对比，除了显示时的大小端问题（同样是MBR结束的1feh字地址是0xAA55h，Linux显示AA55，高字节地址在前，dos系统显示顺序为55AA，低字节地址在前）。其他内容完全一样。

完毕。


