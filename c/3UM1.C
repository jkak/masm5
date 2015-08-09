main()
{    *(char *)0x2000 = 'a';
	 *(int  *)0x2000 = 0xf;
	 *(char far *)0x20001000='a';

	 _AX=0x2000;
	 *(char *)_AX='b';
	 _BX=0x1000;
	 *(char *)(_BX+_BX)='a';
	 *(char far *)(0x20001000+_BX) = *(char *)_AX;
}