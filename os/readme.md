
#　课程设计2　

## 运行环境
本项目中，之前的代码，除ex17.asm外，都是在dosbox模拟环境下运行测试的。本次课程设计，和之前不同。之前的代码都只是dos下的一个程序而已，而本次设计的代码，是一个简单的操作系统。编写风格及测试环境都有所不同。

本来是可以在VMWare等虚拟机下测试的，但需要来回中转文件。因此本次直接在Linux下使用bochs软件来完成测试。基本的方法就是run_bochs.sh脚本里的三行代码。此时暂时省略环境搭建部分。bochs比较方面之处，是在于其就是个linux下的软件。而dosbox则是模拟dos，界面的记录不能回滚查看。而bochs则有滚动条，只是刚开始要熟悉一下其不同的debug风格。



## 如何测试从现有系统中启动

程序的第二个功能是从现有系统中启动，故需要增加一个可以系统来模拟。查看bochs是可以挂多个系统的。通过如下方式来生成。

一、准备系统，直接将os.asm复制为disk_sys_c.asm。将其读取mbr的代号由原来floppy的0改为80h。并修改改选项的显示内容以做区别。

二、增加c.img文件并修改脚本
```bash
# gen c.img
bximage 
# 1  #ENTER for create disk image
# ENTER hd default 
# ENTER flat defalt
# ENTER 10MB defalt
# ENTER c.img defalt

ls -lh c.img

# modify bochsrc, add
# hard disk c
ata0: enabled=1, ioaddr1=0x1f0, ioaddr2=0x3f0, irq=14
ata0-master: type=disk, path="c.img", mode=flat

# modify ./run_bochs.sh
# disk c img
nasm -f bin ./os/disk_sys_c.asm  -o c.bin
echo ""

dd if=c.bin of=c.img bs=512 count=4 conv=notrunc
echo ""

```
通过上述修改，直接运行run_bochs.sh即可开始测试。如果一切正常，系统启动后，即可以从floppy重启，也可以从C盘启动系统。


## 完成过程记录

本文档主要记录完成课程设计2的过程。
1 增加sectors2mem程序，用于从软盘读取多个扇区数据到内存。在程序末端，定义了3个扇区的头内容和尾内容，用于测试观察。6.30.

2 除读取软盘数据的代码放在启动扇区外，其他代码全部启动扇区后面。

3 增加show_select_item以显示可选项，并增加默认选中项，改变显示背景

4 增加input_select实现上下移动选择项。

5 根据选项，启动或重启系统。

6 继续显示时间




## 程序调用关系
下面主要列出从start开始的主程序，其内部的调用关系，主程序不会自动退出。目前完成任务后一直在hlt循环中。

入口程序。位于逻辑0号扇区。



* start

> * call sectors2mem  # 读取多个连续的逻辑扇区到内存
     + call sec2mem   # 读取1个逻辑扇区到0x8200地址
> * jmp main_entrance


主程序。开始于逻辑1号扇区。

* main_entrance

> * call delayL
> * call int10h_clear_screen
> * call delayL
> * call show_select_item        
> * main_select_lp:
    + call show_select_item        
    + call input_select   
    + je main_do_item_0
        - call delay
        - jmp main_select_lp
    + je main_do_item_1
        - call restart_sys
    + je main_do_item_2
        - call restart_sys_c
            + sec2mem
    + je main_do_item_3
        - call show_clock_ctrl
            + call int10h_clear_screen
            + call show_clock
            + clk_read_cmos
            + call delay
    + je main_do_item_4
        - call set_clock_ctrl
            + call clk_read_cmos
            + call show_clock_set
            + call clk_read_kb
            + call clk_write_cmos
        




