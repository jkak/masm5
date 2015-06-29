

## 寻址方式
注意汇编中的寻址方式与Ｃ语言中的对应关系。比如[bx+idata]方式时，C数组a[i], 汇编的寻址5[bx]。
对于更复杂的[bx+si+idata]，与结构体的关系。

大小写转换方法：
* 转小写　or 00100000b
* 转大写 and 11011111b

### question 7.6
* code: 7ques6.asm。use [bx+idata]
* 处理每行中的某列。

### question 7.7, 7.8
* code: 7ques7.asm。use [bx+si] and stack
* 处理每行中的从0开始的连续多列

### question 7.9 and ex6
* code: ex5.asm。use [bx+si+idata]
* 处理每行中非0开始的连续多列。

以上注意在debug时注意使用 d ds:0观察


