something useful

- http://csapp.cs.cmu.edu/3e/bomblab-release.html      release Note
- http://csapp.cs.cmu.edu/3e/bomblab.pdf   writeup
- http://csapp.cs.cmu.edu/3e/README-bomblab readme


- 4.21 started the bomb lab



### phase 1

由源代码可以看出六个阶段的函数位phase_x(),首先进入phase_1()

输入 ```disas phase_1()```

![image-20210421210423246](https://gitee.com/20162180090/piccgo/raw/master/image-20210421210423246.png)

其中esi为```$0x402400```地址所指向的值，而rdi为phase_1的参数，即我们输入的值。其中rdi和esi(rsi)分别对应第一，第二个参数，将这两个参数传输strings_not_equal中，返回结果 ```%eax```(test指令为 a&a )如果结果为1，则爆炸，为0则跳到phase_2阶段。

所以输入 ``` x/s 0x402400```可以得到地址```0x402400```所对应的内容。```"Border relations with Canada have never been better."```

### phase 2

首先反汇编两个主要函数，```phase_2```和```read_six_numbers```

```assembly
(gdb) disas read_six_numbers
Dump of assembler code for function read_six_numbers:
   0x000000000040145c <+0>:     sub    $0x18,%rsp
   0x0000000000401460 <+4>:     mov    %rsi,%rdx
   0x0000000000401463 <+7>:     lea    0x4(%rsi),%rcx
   0x0000000000401467 <+11>:    lea    0x14(%rsi),%rax
   0x000000000040146b <+15>:    mov    %rax,0x8(%rsp)
   0x0000000000401470 <+20>:    lea    0x10(%rsi),%rax
   0x0000000000401474 <+24>:    mov    %rax,(%rsp)
   0x0000000000401478 <+28>:    lea    0xc(%rsi),%r9
   0x000000000040147c <+32>:    lea    0x8(%rsi),%r8
   0x0000000000401480 <+36>:    mov    $0x4025c3,%esi
   0x0000000000401485 <+41>:    mov    $0x0,%eax
   0x000000000040148a <+46>:    callq  0x400bf0 <__isoc99_sscanf@plt>
   0x000000000040148f <+51>:    cmp    $0x5,%eax
   0x0000000000401492 <+54>:    jg     0x401499 <read_six_numbers+61>
   0x0000000000401494 <+56>:    callq  0x40143a <explode_bomb>
   0x0000000000401499 <+61>:    add    $0x18,%rsp
   0x000000000040149d <+65>:    retq
End of assembler dump.
(gdb) disas phase_2
Dump of assembler code for function phase_2:
   0x0000000000400efc <+0>:     push   %rbp
   0x0000000000400efd <+1>:     push   %rbx
   0x0000000000400efe <+2>:     sub    $0x28,%rsp
=> 0x0000000000400f02 <+6>:     mov    %rsp,%rsi
   0x0000000000400f05 <+9>:     callq  0x40145c <read_six_numbers>
   0x0000000000400f0a <+14>:    cmpl   $0x1,(%rsp)
   0x0000000000400f0e <+18>:    je     0x400f30 <phase_2+52>
   0x0000000000400f10 <+20>:    callq  0x40143a <explode_bomb>
   0x0000000000400f15 <+25>:    jmp    0x400f30 <phase_2+52>
   0x0000000000400f17 <+27>:    mov    -0x4(%rbx),%eax
   0x0000000000400f1a <+30>:    add    %eax,%eax
   0x0000000000400f1c <+32>:    cmp    %eax,(%rbx)
   0x0000000000400f1e <+34>:    je     0x400f25 <phase_2+41>
   0x0000000000400f20 <+36>:    callq  0x40143a <explode_bomb>
   0x0000000000400f25 <+41>:    add    $0x4,%rbx
   0x0000000000400f29 <+45>:    cmp    %rbp,%rbx
   0x0000000000400f2c <+48>:    jne    0x400f17 <phase_2+27>
   0x0000000000400f2e <+50>:    jmp    0x400f3c <phase_2+64>
   0x0000000000400f30 <+52>:    lea    0x4(%rsp),%rbx
   0x0000000000400f35 <+57>:    lea    0x18(%rsp),%rbp
   0x0000000000400f3a <+62>:    jmp    0x400f17 <phase_2+27>
   0x0000000000400f3c <+64>:    add    $0x28,%rsp
   0x0000000000400f40 <+68>:    pop    %rbx
   0x0000000000400f41 <+69>:    pop    %rbp
   0x0000000000400f42 <+70>:    retq
End of assembler dump.
```

猜测```read_six_numbers```是一个读取六个数字的函数，其中

```assembly
   0x0000000000401460 <+4>:     mov    %rsi,%rdx
   0x0000000000401463 <+7>:     lea    0x4(%rsi),%rcx
   0x0000000000401467 <+11>:    lea    0x14(%rsi),%rax
   0x000000000040146b <+15>:    mov    %rax,0x8(%rsp)
   0x0000000000401470 <+20>:    lea    0x10(%rsi),%rax
   0x0000000000401474 <+24>:    mov    %rax,(%rsp)
   0x0000000000401478 <+28>:    lea    0xc(%rsi),%r9
   0x000000000040147c <+32>:    lea    0x8(%rsi),%r8
```

由书本可知，第一个参数为%rsi,一个整形占4个字节，由这几条语句可得，六个数字分别被赋值到 ``` %rdx,%rcx,%r8,%r9,%rsp,0x8(%rsp)```

通过

```assembly
(gdb) x/s 0x4025c3
0x4025c3:       "%d %d %d %d %d %d"
```

可知```__isoc99_sscanf@plt```就是读取六个整形用的。

```0x000000000040148f <+51>:    cmp    $0x5,%eax``` 返回scanf的长度，为5 （0开始的），长度大于等于5则返回true(1）

接下来看

```assembly
   0x0000000000400f0a <+14>:    cmpl   $0x1,(%rsp)
   0x0000000000400f0e <+18>:    je     0x400f30 <phase_2+52>
   0x0000000000400f10 <+20>:    callq  0x40143a <explode_bomb>
   0x0000000000400f15 <+25>:    jmp    0x400f30 <phase_2+52>
   0x0000000000400f17 <+27>:    mov    -0x4(%rbx),%eax    #%rbx = %rsp+4,所以-4后为%rsp,即为1
   0x0000000000400f1a <+30>:    add    %eax,%eax          # *2
   0x0000000000400f1c <+32>:    cmp    %eax,(%rbx)        
   0x0000000000400f1e <+34>:    je     0x400f25 <phase_2+41>
   0x0000000000400f20 <+36>:    callq  0x40143a <explode_bomb>
   0x0000000000400f25 <+41>:    add    $0x4,%rbx    #i++
   0x0000000000400f29 <+45>:    cmp    %rbp,%rbx    #是否达到边界 到的话 就跳到+50去了
   0x0000000000400f2c <+48>:    jne    0x400f17 <phase_2+27>
   0x0000000000400f2e <+50>:    jmp    0x400f3c <phase_2+64>
   0x0000000000400f30 <+52>:    lea    0x4(%rsp),%rbx    #初始条件 为%rsp+4
   0x0000000000400f35 <+57>:    lea    0x18(%rsp),%rbp   #边界条件   0x18-0x4 = 20 = 4 * 5 ,五个整形+第一个1 = 6个整形 
   0x0000000000400f3a <+62>:    jmp    0x400f17 <phase_2+27>
   0x0000000000400f3c <+64>:    add    $0x28,%rsp
   0x0000000000400f40 <+68>:    pop    %rbx
   0x0000000000400f41 <+69>:    pop    %rbp
   0x0000000000400f42 <+70>:    retq
```

其中```%esp```为1（返回结果），所以答案为 1 2 4 8 16 32 (后面可以加数字，不会错。)

![image-20210427131110786](https://gitee.com/20162180090/piccgo/raw/master/image-20210427131110786.png)

### phase 3

首先还是查看phase_3的汇编代码

```assembly
(gdb) disas phase_3
Dump of assembler code for function phase_3:
   0x0000000000400f43 <+0>:     sub    $0x18,%rsp
   0x0000000000400f47 <+4>:     lea    0xc(%rsp),%rcx
   0x0000000000400f4c <+9>:     lea    0x8(%rsp),%rdx
   0x0000000000400f51 <+14>:    mov    $0x4025cf,%esi  # %d %d 
   0x0000000000400f56 <+19>:    mov    $0x0,%eax
   0x0000000000400f5b <+24>:    callq  0x400bf0 <__isoc99_sscanf@plt>  
   0x0000000000400f60 <+29>:    cmp    $0x1,%eax 
   0x0000000000400f63 <+32>:    jg     0x400f6a <phase_3+39> #长度大于1，就不爆炸
   0x0000000000400f65 <+34>:    callq  0x40143a <explode_bomb>
   0x0000000000400f6a <+39>:    cmpl   $0x7,0x8(%rsp)  #比较7和第一个字符 ，大则爆炸，所以第一个小于等于7
   0x0000000000400f6f <+44>:    ja     0x400fad <phase_3+106>  #无符号数之间的大小关系
   0x0000000000400f71 <+46>:    mov    0x8(%rsp),%eax # %eax = 第一个字符
   0x0000000000400f75 <+50>:    jmpq   *0x402470(,%rax,8) 
   # *0x402470 =  4198276   ;*0x402470(,%rax,8)  = %(0x402470+8*%rax)
   # 随后和对应的进行比较 p/x %(0x402470+8*%rax)
   # 其中 
   #     0 --- > 0x400f7c -- >  $0xcf  -- >  207
   #     1 --- > 0x400fb9 -- >  $0x137 -- >  311
   #     2 --- > 0x400f83 -- >  $0x2c3 -- >  707
   #     3 --- > 0x400f8a -- >  $0x100 -- >  256
   #     4 --- > 0x400f91 -- >  $0x185 -- >  389
   #     5 --- > 0x400f98 -- >  $0xce  -- >  206
   #     6 --- > 0x400f9f -- >  $0x2aa -- >  682
   #     7 --- > 0x400fa6 -- >  $0x147 -- >  327
   0x0000000000400f7c <+57>:    mov    $0xcf,%eax  
   0x0000000000400f81 <+62>:    jmp    0x400fbe <phase_3+123>
   0x0000000000400f83 <+64>:    mov    $0x2c3,%eax
   0x0000000000400f88 <+69>:    jmp    0x400fbe <phase_3+123>
   0x0000000000400f8a <+71>:    mov    $0x100,%eax
   0x0000000000400f8f <+76>:    jmp    0x400fbe <phase_3+123>
   0x0000000000400f91 <+78>:    mov    $0x185,%eax
   0x0000000000400f96 <+83>:    jmp    0x400fbe <phase_3+123>
   0x0000000000400f98 <+85>:    mov    $0xce,%eax
   0x0000000000400f9d <+90>:    jmp    0x400fbe <phase_3+123>
   0x0000000000400f9f <+92>:    mov    $0x2aa,%eax
   0x0000000000400fa4 <+97>:    jmp    0x400fbe <phase_3+123>
   0x0000000000400fa6 <+99>:    mov    $0x147,%eax
   0x0000000000400fab <+104>:   jmp    0x400fbe <phase_3+123>
   0x0000000000400fad <+106>:   callq  0x40143a <explode_bomb>
   0x0000000000400fb2 <+111>:   mov    $0x0,%eax
   0x0000000000400fb7 <+116>:   jmp    0x400fbe <phase_3+123>
   0x0000000000400fb9 <+118>:   mov    $0x137,%eax
   0x0000000000400fbe <+123>:   cmp    0xc(%rsp),%eax  ## 判断第二个参数是否与对应的值相同
   0x0000000000400fc2 <+127>:   je     0x400fc9 <phase_3+134>
   0x0000000000400fc4 <+129>:   callq  0x40143a <explode_bomb>
   0x0000000000400fc9 <+134>:   add    $0x18,%rsp
   0x0000000000400fcd <+138>:   retq
```

首先输入```x/s %0x4025cf```得到scanf的第二个参数format，也就是```"%d %d"```

详细可以看看注释，应该有六组答案 

```shell
0 207
1 311
2 707
3 256
4 389
5 206
6 682
7 327
```

### phase_4

照例打印出汇编代码

```assembly
(gdb) disas phase_4
Dump of assembler code for function phase_4:
   0x000000000040100c <+0>:     sub    $0x18,%rsp
   0x0000000000401010 <+4>:     lea    0xc(%rsp),%rcx
   0x0000000000401015 <+9>:     lea    0x8(%rsp),%rdx
   0x000000000040101a <+14>:    mov    $0x4025cf,%esi #  "%d %d"
   0x000000000040101f <+19>:    mov    $0x0,%eax
   0x0000000000401024 <+24>:    callq  0x400bf0 <__isoc99_sscanf@plt>
   0x0000000000401029 <+29>:    cmp    $0x2,%eax #长度只能为2
   0x000000000040102c <+32>:    jne    0x401035 <phase_4+41>
   0x000000000040102e <+34>:    cmpl   $0xe,0x8(%rsp)  # 
   0x0000000000401033 <+39>:    jbe    0x40103a <phase_4+46>  ##第一个数要小于或等于14
   0x0000000000401035 <+41>:    callq  0x40143a <explode_bomb>
   0x000000000040103a <+46>:    mov    $0xe,%edx  #  %edx = 14 fun4的第三个参数？
   0x000000000040103f <+51>:    mov    $0x0,%esi  #  %esi = 0  fun4的第二个参数
   0x0000000000401044 <+56>:    mov    0x8(%rsp),%edi  # %edi = 第一个数 ，fun4的第一个参数
   0x0000000000401048 <+60>:    callq  0x400fce <func4>
   0x000000000040104d <+65>:    test   %eax,%eax #返回值为0
   0x000000000040104f <+67>:    jne    0x401058 <phase_4+76>
   0x0000000000401051 <+69>:    cmpl   $0x0,0xc(%rsp)  #第二个数得是0
   0x0000000000401056 <+74>:    je     0x40105d <phase_4+81>
   0x0000000000401058 <+76>:    callq  0x40143a <explode_bomb>
   0x000000000040105d <+81>:    add    $0x18,%rsp
   0x0000000000401061 <+85>:    retq
End of assembler dump.
(gdb) disas func4
Dump of assembler code for function func4:
   0x0000000000400fce <+0>:     sub    $0x8,%rsp  
   # %edi = a;   %esi = b = 0; %edx = c = 14
   0x0000000000400fd2 <+4>:     mov    %edx,%eax  # eax = c
   0x0000000000400fd4 <+6>:     sub    %esi,%eax  # eax = c - b
   0x0000000000400fd6 <+8>:     mov    %eax,%ecx  # ecx = c - b
   0x0000000000400fd8 <+10>:    shr    $0x1f,%ecx # ecx = (c - b) >> 31
   0x0000000000400fdb <+13>:    add    %ecx,%eax  # eax = (c - b)>>31 + (c - b)
   0x0000000000400fdd <+15>:    sar    %eax       # eax = ((c - b)>>31 + (c - b)) >> 1
   0x0000000000400fdf <+17>:    lea    (%rax,%rsi,1),%ecx  
   #ecx = ((c - b)>>31 + (c - b)) >> 1 + b
   0x0000000000400fe2 <+20>:    cmp    %edi,%ecx  # 比较ecx 和 edi(a)
   0x0000000000400fe4 <+22>:    jle    0x400ff2 <func4+36>  #如果ecx大于edi就去0x400ff2
   0x0000000000400fe6 <+24>:    lea    -0x1(%rcx),%edx #大于的话 edx = rcx - 1
   0x0000000000400fe9 <+27>:    callq  0x400fce <func4> 重新计入该函数
   0x0000000000400fee <+32>:    add    %eax,%eax  返回值*2
   0x0000000000400ff0 <+34>:    jmp    0x401007 <func4+57> # 跳到+57
   0x0000000000400ff2 <+36>:    mov    $0x0,%eax  #eax = 0 
   0x0000000000400ff7 <+41>:    cmp    %edi,%ecx  #比较a和ecx
   0x0000000000400ff9 <+43>:    jge    0x401007 <func4+57> #JGE大于等于
   0x0000000000400ffb <+45>:    lea    0x1(%rcx),%esi # 小于+1
   0x0000000000400ffe <+48>:    callq  0x400fce <func4> #再次进入
   0x0000000000401003 <+53>:    lea    0x1(%rax,%rax,1),%eax #返回值*2 +1
   0x0000000000401007 <+57>:    add    $0x8,%rsp #返回
   0x000000000040100b <+61>:    retq
End of assembler dump.
```

聚焦到```   0x000000000040101a <+14>:    mov    $0x4025cf,%esi```，输入```(gdb) x/s 0x4025cf```

得到```0x4025cf:       "%d %d"```，所以这题也是两个整数。且由+29知道，只能是两个整数

```0x000000000040102e <+34>:    cmpl   $0xe,0x8(%rsp)   ```第一个数要小于等于14

```   0x0000000000401051 <+69>:    cmpl   $0x0,0xc(%rsp)  ``` 得到第二数得为0

这题其实不太会，看了博客发现这是一个递归函数，所以自己还原了一下C代码

```c
int func4(int a, int b, int c) {
    int temp = ((((c - b) >> 31) + (c - b)) >> 1) + b;
    if (temp <= a) {
        if (temp == a) {
            return 0;
        } else {
            return 2 * func4(a, temp + 1, c) + 1;
        }
    } else {
        return 2 * func4(a, b, temp - 1);
    }
}

int main() {
    int a;
    int b = 0;
    int c = 14;
    for (a = 0; a <= 14; ++a) {
        int res = func4(a, b, c);
        if (res == 0) {
            cout << a << " " << b << " " << c << endl;
        }
    }
}
//0 0 14
//1 0 14
//3 0 14
//7 0 14
```

所以答案为 

```
0 0
1 0
3 0
7 0
```

### phase_5

```assembly
(gdb) disas phase_5
Dump of assembler code for function phase_5:
   0x0000000000401062 <+0>:     push   %rbx
   0x0000000000401063 <+1>:     sub    $0x20,%rsp
   0x0000000000401067 <+5>:     mov    %rdi,%rbx # rbx = x
   0x000000000040106a <+8>:     mov    %fs:0x28,%rax
   0x0000000000401073 <+17>:    mov    %rax,0x18(%rsp)
   0x0000000000401078 <+22>:    xor    %eax,%eax  #eax = 0
   0x000000000040107a <+24>:    callq  0x40131b <string_length>
   0x000000000040107f <+29>:    cmp    $0x6,%eax  
   0x0000000000401082 <+32>:    je     0x4010d2 <phase_5+112>
   0x0000000000401084 <+34>:    callq  0x40143a <explode_bomb>
   0x0000000000401089 <+39>:    jmp    0x4010d2 <phase_5+112>
   ##长度得为6,不然就爆炸，为0的话跳到112，把eax设置为0

   
   0x000000000040108b <+41>:    movzbl (%rbx,%rax,1),%ecx  # 取下标为rax的字符
   0x000000000040108f <+45>:    mov    %cl,(%rsp)          # ecx的最后一个字节
   0x0000000000401092 <+48>:    mov    (%rsp),%rdx         # 就是把对应的字符放到rdx
   0x0000000000401096 <+52>:    and    $0xf,%edx           # 字符的低四位与上0xf
   0x0000000000401099 <+55>:    movzbl 0x4024b0(%rdx),%edx # 
   # (gdb) x 0x4024b0
   # 0x4024b0 <array.3449>:  "maduiersnfotvbylSo you think you can stop the bomb with ctrl-c, do you?"
   # 比较的字符串是从里面获取的，下标是输入的字符串的每个字符的后四位
   
   0x00000000004010a0 <+62>:    mov    %dl,0x10(%rsp,%rax,1) #rsp结果数组
   0x00000000004010a4 <+66>:    add    $0x1,%rax  
   0x00000000004010a8 <+70>:    cmp    $0x6,%rax  #rax是不是第六个了
   0x00000000004010ac <+74>:    jne    0x40108b <phase_5+41> #不是的话继续走
   0x00000000004010ae <+76>:    movb   $0x0,0x16(%rsp)   ## 
   0x00000000004010b3 <+81>:    mov    $0x40245e,%esi
   # (gdb) x 0x40245e
   # 0x40245e:       "flyers"  (不是答案)
   # 对应上面的话，下标分别是 9 15 14 5 6 7
   # 转为二进制为  1001 1111 1110 0101 0110 0111
   # 对应的字符有很多，看看哪些字符对应的ascii码的后四位和上面一样就好了
   # 例如 )/.%&'  可以参照 http://ascii.911cha.com/
   0x00000000004010b8 <+86>:    lea    0x10(%rsp),%rdi
   0x00000000004010bd <+91>:    callq  0x401338 <strings_not_equal>
   0x00000000004010c2 <+96>:    test   %eax,%eax
   0x00000000004010c4 <+98>:    je     0x4010d9 <phase_5+119>
   0x00000000004010c6 <+100>:   callq  0x40143a <explode_bomb>
   0x00000000004010cb <+105>:   nopl   0x0(%rax,%rax,1)
   0x00000000004010d0 <+110>:   jmp    0x4010d9 <phase_5+119>
   0x00000000004010d2 <+112>:   mov    $0x0,%eax # eax = 0
   0x00000000004010d7 <+117>:   jmp    0x40108b <phase_5+41>
   0x00000000004010d9 <+119>:   mov    0x18(%rsp),%rax
   0x00000000004010de <+124>:   xor    %fs:0x28,%rax
   0x00000000004010e7 <+133>:   je     0x4010ee <phase_5+140>
   0x00000000004010e9 <+135>:   callq  0x400b30 <__stack_chk_fail@plt> ## 应该是防止缓存区攻击的，检察canny是否正确
   0x00000000004010ee <+140>:   add    $0x20,%rsp
   0x00000000004010f2 <+144>:   pop    %rbx
```

### phase_6

第六个阶段的代码很长

```assembly
(gdb) disas phase_6
Dump of assembler code for function phase_6:
   0x00000000004010f4 <+0>:     push   %r14
   0x00000000004010f6 <+2>:     push   %r13
   0x00000000004010f8 <+4>:     push   %r12
   0x00000000004010fa <+6>:     push   %rbp
   0x00000000004010fb <+7>:     push   %rbx
   0x00000000004010fc <+8>:     sub    $0x50,%rsp
   0x0000000000401100 <+12>:    mov    %rsp,%r13 #r13 = rsp
   0x0000000000401103 <+15>:    mov    %rsp,%rsi
   0x0000000000401106 <+18>:    callq  0x40145c <read_six_numbers>
   
   0x000000000040110b <+23>:    mov    %rsp,%r14   # r14 = rsp
   0x000000000040110e <+26>:    mov    $0x0,%r12d  # r12d = 0
   0x0000000000401114 <+32>:    mov    %r13,%rbp   # rbp = 该元素
   0x0000000000401117 <+35>:    mov    0x0(%r13),%eax # eax = 该元素
   0x000000000040111b <+39>:    sub    $0x1,%eax  
   # 其中%rsp~%rsp+0x14存放着六个数字
   0x000000000040111e <+42>:    cmp    $0x5,%eax             
   0x0000000000401121 <+45>:    jbe    0x401128 <phase_6+52> # 所有元素要范围要在1-6，配合<+89>看
   0x0000000000401123 <+47>:    callq  0x40143a <explode_bomb> #否则就爆炸
   
   0x0000000000401128 <+52>:    add    $0x1,%r12d  
   0x000000000040112c <+56>:    cmp    $0x6,%r12d  
   0x0000000000401130 <+60>:    je     0x401153 <phase_6+95> ## while(r12<=6){}
   0x0000000000401132 <+62>:    mov    %r12d,%ebx  #ebx = count
   0x0000000000401135 <+65>:    movslq %ebx,%rax   # rax = count 
   0x0000000000401138 <+68>:    mov    (%rsp,%rax,4),%eax  #eax = rsp[rax]
   0x000000000040113b <+71>:    cmp    %eax,0x0(%rbp)      #互不相同，不然就爆炸
   0x000000000040113e <+74>:    jne    0x401145 <phase_6+81> #相同就爆炸
   0x0000000000401140 <+76>:    callq  0x40143a <explode_bomb>
   0x0000000000401145 <+81>:    add    $0x1,%ebx  #ebx++
   0x0000000000401148 <+84>:    cmp    $0x5,%ebx  
   0x000000000040114b <+87>:    jle    0x401135 <phase_6+65>  #ebx<=5? 看起来是两重循环呀？这个应该是do{}while()
   0x000000000040114d <+89>:    add    $0x4,%r13
   0x0000000000401151 <+93>:    jmp    0x401114 <phase_6+32>
   ## 到一步，有6个数字，分别是1-6，且互不相同(顺序未知)
   
   
   0x0000000000401153 <+95>:    lea    0x18(%rsp),%rsi # 
   0x0000000000401158 <+100>:   mov    %r14,%rax # rax = 第一个元素
   0x000000000040115b <+103>:   mov    $0x7,%ecx # exc = 7
   0x0000000000401160 <+108>:   mov    %ecx,%edx # dex = 7
   0x0000000000401162 <+110>:   sub    (%rax),%edx # edx = b 
   0x0000000000401164 <+112>:   mov    %edx,(%rax)
   0x0000000000401166 <+114>:   add    $0x4,%rax
   0x000000000040116a <+118>:   cmp    %rsi,%rax
   0x000000000040116d <+121>:   jne    0x401160 <phase_6+108>
   0x000000000040116f <+123>:   mov    $0x0,%esi
   0x0000000000401174 <+128>:   jmp    0x401197 <phase_6+163>
   0x0000000000401176 <+130>:   mov    0x8(%rdx),%rdx
   0x000000000040117a <+134>:   add    $0x1,%eax
   0x000000000040117d <+137>:   cmp    %ecx,%eax
   0x000000000040117f <+139>:   jne    0x401176 <phase_6+130>
   0x0000000000401181 <+141>:   jmp    0x401188 <phase_6+148>
   0x0000000000401183 <+143>:   mov    $0x6032d0,%edx
   0x0000000000401188 <+148>:   mov    %rdx,0x20(%rsp,%rsi,2)
   0x000000000040118d <+153>:   add    $0x4,%rsi
   0x0000000000401191 <+157>:   cmp    $0x18,%rsi
   0x0000000000401195 <+161>:   je     0x4011ab <phase_6+183>
   0x0000000000401197 <+163>:   mov    (%rsp,%rsi,1),%ecx
   0x000000000040119a <+166>:   cmp    $0x1,%ecx
   0x000000000040119d <+169>:   jle    0x401183 <phase_6+143>
   0x000000000040119f <+171>:   mov    $0x1,%eax
   0x00000000004011a4 <+176>:   mov    $0x6032d0,%edx
   0x00000000004011a9 <+181>:   jmp    0x401176 <phase_6+130>
   0x00000000004011ab <+183>:   mov    0x20(%rsp),%rbx
   0x00000000004011b0 <+188>:   lea    0x28(%rsp),%rax
   0x00000000004011b5 <+193>:   lea    0x50(%rsp),%rsi
   0x00000000004011ba <+198>:   mov    %rbx,%rcx
   0x00000000004011bd <+201>:   mov    (%rax),%rdx
   0x00000000004011c0 <+204>:   mov    %rdx,0x8(%rcx)
   0x00000000004011c4 <+208>:   add    $0x8,%rax
   0x00000000004011c8 <+212>:   cmp    %rsi,%rax
   0x00000000004011cb <+215>:   je     0x4011d2 <phase_6+222>
   0x00000000004011cd <+217>:   mov    %rdx,%rcx
   0x00000000004011d0 <+220>:   jmp    0x4011bd <phase_6+201>
   0x00000000004011d2 <+222>:   movq   $0x0,0x8(%rdx)
   0x00000000004011da <+230>:   mov    $0x5,%ebp
   0x00000000004011df <+235>:   mov    0x8(%rbx),%rax
   0x00000000004011e3 <+239>:   mov    (%rax),%eax
   0x00000000004011e5 <+241>:   cmp    %eax,(%rbx)
   0x00000000004011e7 <+243>:   jge    0x4011ee <phase_6+250>
   0x00000000004011e9 <+245>:   callq  0x40143a <explode_bomb>
   0x00000000004011ee <+250>:   mov    0x8(%rbx),%rbx
   0x00000000004011f2 <+254>:   sub    $0x1,%ebp
   0x00000000004011f5 <+257>:   jne    0x4011df <phase_6+235>
   
   #以下栈恢复，可忽略
   0x00000000004011f7 <+259>:   add    $0x50,%rsp
   0x00000000004011fb <+263>:   pop    %rbx
   0x00000000004011fc <+264>:   pop    %rbp
   0x00000000004011fd <+265>:   pop    %r12
   0x00000000004011ff <+267>:   pop    %r13
   0x0000000000401201 <+269>:   pop    %r14
   0x0000000000401203 <+271>:   retq
End of assembler dump.
```



### 小记

![image-20210421230209743](https://gitee.com/20162180090/piccgo/raw/master/image-20210421230209743.png)

![image-20210421230236364](https://gitee.com/20162180090/piccgo/raw/master/image-20210421230236364.png)

![image-20210421230257117](https://gitee.com/20162180090/piccgo/raw/master/image-20210421230257117.png)



