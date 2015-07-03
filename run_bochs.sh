#########################################################################
# File Name: run_bochs.sh
# Author: 
# mail: 
# Created Time: 2015年06月30日 星期二 17时58分14秒
#########################################################################
#!/bin/bash

# floppy img
nasm -f bin ./os/os.asm  -o boot.bin
echo ""

dd if=boot.bin of=a.img bs=512 count=4 conv=notrunc
echo ""


# disk c img
nasm -f bin ./os/disk_sys_c.asm  -o c.bin
echo ""

dd if=c.bin of=c.img bs=512 count=4 conv=notrunc
echo ""

bochs 

