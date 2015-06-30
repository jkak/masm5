#########################################################################
# File Name: run_bochs.sh
# Author: 
# mail: 
# Created Time: 2015年06月30日 星期二 17时58分14秒
#########################################################################
#!/bin/bash

nasm -f bin ./os/os.asm  -o boot.bin
echo ""

dd if=boot.bin of=a.img bs=512 count=1 conv=notrunc
echo ""

bochs 

