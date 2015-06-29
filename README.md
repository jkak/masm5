
# 项目说明

本项目是学习王爽的《汇编语言》第二版所做的代码方面的笔记。王爽这本书很经典，正因为如此，本人才重点将代码整理出来。至于内容方面的笔记，此处不做为重点，对于书上的问答或检测点，此处也不会一一给出答案。文库上有现成的答案。本项目是用于整理和记录重要代码能跑通，方便代码复用。

另外，有代码的地方，在github上显示的不太好，可以将readme.md文件的内容复制到一个显示丰富的markdown编辑器中查看。我目前主要使用:

[Cmd Markdown编译器](https://www.zybuluo.com/mdeditor)


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



