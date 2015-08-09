main()
{
	_AX = 1;
	_BX = 1;
	_CX = 2;
	_AX = _BX + _CX;
	_AH = _BL + _CL;
	_AL = _BH + _CH;
	printf("offset of main: %x\n", main);
}