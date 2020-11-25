
# 项目说明

本项目是学习王爽的《汇编语言》第二版所做的代码方面的笔记。王爽这本书很经典，正因为如此，本人才重点将代码整理出来。至于内容方面的笔记，此处不做为重点，对于书上的问答或检测点，此处也不会一一给出答案。文库上有现成的答案。本项目是用于整理和记录重要代码能跑通，方便代码复用。

另外，有代码的地方，在github上显示的不太好，可以将readme.md文件的内容复制到一个显示丰富的markdown编辑器中查看。我目前主要使用:

[Cmd Markdown编译器](https://www.zybuluo.com/mdeditor)


# 进阶介绍

学习完本书后，我建议你学习如下两本书，
* 李忠的《X86汇编语言 从实模式到保护模式》，笔记参考：https://github.com/jkak/orangeS
* 于渊的《orange'S 一个操作系统的实现》，笔记参考：https://github.com/jkak/x86asm

这两本书，我都花大力气整理了笔记，跑通了相关代码，特别是对CPU的相关寄存器变化、处理流程等知识点，画了很多详图进行说明。希望对你有所帮助。
 


# 运行环境

由于本人主要使用Linux。故所有代码在linux下编辑和调试。
> * 系统：　debian
> * 运行环境：　dosbox 0.74
   + 汇编器：masm 5.0
   + 连接器：Overlay Linker 3.60
   + 调试器：debug.exe

书中的代码都是基本在windows环境的。当然在windows下也可以完全使用上述的dosbox, masm, linker, debug等工具。这方面的环境书上或者网上都可以找到，此处从略。 

# 其他说明

因为是在dosbox下运行，故文件命名方面，需要注意ms-dos的8.3原则。名字最好在８个字符以内。也因此增加各章的章目录，以免文件名重复。


## 文件命名基本规则
* 如果是实验，则命名类似chap5/ex4_1.asm
* 如果不是实验，只是某章中的程序，如程序5-9，则命名为chap5/9.asm
* 每章目录下设置readme.md文件作为本章相关程序的说明。


必要的话，会在文件名后加上功能说明。


2015年６月25日


## 代码与章节对应关系
新版本，使用版本。并注意基本功能。

|        file name       |    functions                 |   chapter         |
| :-------------------   | :-------------               | :------           |
| ./chap4/ex3.asm        | NULL                         |  实验3            |
| ./chap5/6loop.asm      | loop功能                     |  程序5.5, 5.6     |
| ./chap5/ex4_1.asm      | loop传数据                   |  实验4.1          |
| ./chap5/ex4_2.asm      | loop传数据                   |  实验4.2          |
| ./chap5/ex4_3.asm      | loop传数据                   |  实验4.3          |
| ./chap6/ex5_1.asm      | debug segment                |  实验5.1          |
| ./chap6/ex5_2.asm      | debug segment                |  实验5.2          |
| ./chap6/ex5_3.asm      | debug segment                |  实验5.3          |
| ./chap6/ex5_5.asm      | add segment                  |  实验5.5          |
| ./chap7/7ques6.asm     | [bx+idata] addessing         |  问题6            |
| ./chap7/7ques7.asm     | [bx+si] addessing            |  问题7            |
| ./chap7/ex6.asm        | [bx+si+idata] addessing      |  实验6            |
| ./chap8/6dec.asm       | compute data                 |  程序6 dec corp   |
| ./chap8/ex7.asm        | compute and show data        |  实验7 dec corp   |
| ./chap9/check1.asm     | study jmp                    |  检查点9.1        |
| ./chap9/check2.asm     | study jmp                    |  检查点9.2        |
| ./chap9/ex8.asm        | analyse jmp short            |  实验8            |
| ./chap9/ex9.asm        | show string on screen        |  实验9            |
| ./chap10/check5.asm    | call and ret                 |  检查点5          |
| ./chap10/ex10.asm      | show_str, div_dw, d2char     |  实验10           |
| ./chap10/design1.asm   | show ex7                     |  课程设计1        |
| ./chap11/ex11.asm      | capital letter and show      |  实验11           |
| ./chap12/ex12.asm      | int 0h show str              |  实验12           |
| ./chap13/int_7ch.asm   | study int 7ch                |  13.2之问题2      |
| ./chap13/int_loop.asm  | int, stack and loop          |  13.3             |
| ./chap13/int_jmp.asm   | int, stack and jmp           |  检测点13.1 -2    |
| ./chap13/ex13_1.asm    | int7ch show str              |  实验13.1         |
| ./chap13/ex13_2.asm    | ln -s to int_loop.asm        |  实验13.2,        |
| ./chap14/cmos.asm      | read cmos date/time          |  实验14，实现1    |
| ./chap14/cmos2.asm     | style 2                      |  实验14，实现2    |
| ./chap15/a2z_esc.asm   | ESC change char color        |  15.4             |
| ./chap15/front_F1.asm  | F1 screen color              |  15.5             |
| ./chap15/ex15_A.asm    | full A on screen             |  实验15           |
| ./chap16/show_hex.asm  | addressing table show hex    |  16.3             |
| ./chap16/ex16_ins.asm  | screen func:                 |  实验16 install   |
| ./chap16/ex16_run.asm  | clear/setcolor/set/back/roll |  实现16 test      |
| ./chap17/rgb_7ch.asm   | input rgb change color       |  17.2             |
| ./chap17/in_str.asm    | input string                 |  17.3             |
| ./chap17/read_mbr.asm  | read mbr sector              |  17.4             |
| ./chap17/ex17.asm      | read logic sector            |  实验17           |




## 旧版对应关系

### 第四章
* ./chap4/ex3.asm   实验3
* ./chap4/readme.md

### 第五章
* ./chap5/6loop.asm   程序5.5, 5.6
* ./chap5/ex4_1.asm   实验4.1
* ./chap5/ex4_2.asm   实验4.2
* ./chap5/ex4_3.asm   实验4.3
* ./chap5/readme.md

### 第六章
* ./chap6/ex5_1.asm   实验5.1
* ./chap6/ex5_2.asm   实验5.2
* ./chap6/ex5_3.asm   实验5.3
* ./chap6/ex5_5.asm   实验5.5
* ./chap6/readme.md

### 第七章
* ./chap7/7ques6.asm  问题6
* ./chap7/7ques7.asm  问题7
* ./chap7/ex6.asm     实验6
* ./chap7/readme.md

### 第八章
* ./chap8/6dec.asm    程序6 dec公司数据
* ./chap8/ex7.asm     实验7

### 第九章
* ./chap9/check1.asm  检查点9.1
* ./chap9/check2.asm  检查点9.2
* ./chap9/ex8.asm     实验8
* ./chap9/ex9.asm     实验9
* ./chap9/readme.md

### 第十章
* ./chap10/check5.asm   检查点5
* ./chap10/ex10.asm     实验10
* ./chap10/design1.asm  课程设计1
* ./chap10/readme.md

### 第十一章
* ./chap11/ex11.asm     实验11

### 第十二章
* ./chap12/ex12.asm     实验12
* ./chap12/readme.md


### 第十三章
* ./chap13/int_7ch.asm     13.2之问题2
* ./chap13/int_loop.asm    13.3用int 实现loop功能
* ./chap13/int_jmp.asm     检测点13.1 第2点 用int实现jmp功能
* ./chap13/ex13_1.asm     实验13.1
* ./chap13/ex13_2.asm     实验13.2, 软链到int_loop.asm
* ./chap13/readme.md


### 第十四章
* ./chap14/cmos.asm      实验14，实现1
* ./chap14/cmos2.asm     实验14，实现2
* ./chap14/readme.md


### 第十五章
* ./chap15/a2z_esc.asm   15.4
* ./chap15/front_F1.asm  15.5
* ./chap15/ex15_A.asm    实验15
* ./chap15/readme.md



### 第十六章
* ./chap16/show_hex.asm   16.3
* ./chap16/ex16_ins.asm   实现16 中断安装程序
* ./chap16/ex16_run.asm   实现16 中断测试程序
* ./chap16/readme.md



### 第十七章
* ./chap17/rgb_7ch.asm    17.2
* ./chap17/in_str.asm     17.3
* ./chap17/read_mbr.asm   17.4
* ./chap17/ex17.asm       实验17
* ./chap17/readme.md



