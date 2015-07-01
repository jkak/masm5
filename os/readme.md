
#　课程设计2　

## 运行环境
本项目中，之前的代码，除ex17.asm外，都是在dosbox模拟环境下运行测试的。本次课程设计，和之前不同。之前的代码都只是dos下的一个程序而已，而本次设计的代码，是一个简单的操作系统。编写风格及测试环境都有所不同。

本来是可以在VMWare等虚拟机下测试的，但需要来回中转文件。因此本次直接在Linux下使用bochs软件来完成测试。基本的方法就是run_bochs.sh脚本里的三行代码。此时暂时省略环境搭建部分。bochs比较方面之处，是在于其就是个linux下的软件。而dosbox则是模拟dos，界面的记录不能回滚查看。而bochs则有滚动条，只是刚开始要熟悉一下其不同的debug风格。

## 完成过程记录

本文档主要记录完成课程设计２的过程。
1 增加sectors2mem程序，用于从软盘读取多个扇区数据到内存。在程序末端，定义了3个扇区的头内容和尾内容，用于测试观察。6.30.




## 程序调用关系
下面主要列出从start开始的主程序，其内部的调用关系，主程序不会自动退出。目前完成任务后一直在hlt循环中。

入口程序。位于逻辑0号扇区。

* start
> * call sectors2mem  # 读取多个连续的逻辑扇区到内存
     + call sec2mem   # 读取1个逻辑扇区到0x8200地址
> * jmp main_entrance


主程序。开始于逻辑1号扇区。

* main_entrance
> * call show_init_str # show hello string
> * call delay         #
> * call show_select_item        # show selectable item
> * call int10h_clear_screen     # clear screen
> * call show_selector           # show selector items
> * input_select     
     





