int f(void);

int a,b,ab;

main()
{
	int c;
	c = f();
}

int f(void)
{
	ab = a+b;
	return ab;
}