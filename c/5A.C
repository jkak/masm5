void showchar(char a, int b);

main()
{
    showchar('a', 2);
}

void showchar(char a, int b)
{
    *(char far *) (0xb8000000+160*10+80) = a;
    *(char far *) (0xb8000000+160*10+81) = b;
}
