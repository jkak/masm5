main()
{
	_BX = 160*12+40*2;
	*(char far *)(0xb8000000+_BX+0) = 'a';
	*(char far *)(0xb8000000+_BX+1) = 0x2;
	/*    *(int far *)0xb80007d0) = 0x261;      */
}