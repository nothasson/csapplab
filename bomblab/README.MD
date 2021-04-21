something useful

- http://csapp.cs.cmu.edu/3e/bomblab-release.html      release Note
- http://csapp.cs.cmu.edu/3e/bomblab.pdf   writeup
- http://csapp.cs.cmu.edu/3e/README-bomblab readme


- 4.21 started the bomb lab
### phase 1
由源代码可以看出六个阶段的函数位phase_x(),首先进入phase_1()

输入 ```disas phase_1()```

![image-20210421210423246](https://gitee.com/20162180090/piccgo/raw/master/image-20210421210423246.png)

其中esi为$0x402400地址所指向的值，而rdi为phase_1的参数，即我们输入的值。其中rdi和esi(rsi)分别对应第一，第二个参数，将这两个参数传输strings_not_equal中，返回结果 %eax(test指令为 a&a )如果结果为1，则爆炸，为0则跳到phase_2阶段。

所以输入 ``` x/s 0x402400```可以得到地址0x402400所对应的内容。```"Border relations with Canada have never been better."```

### phase 2

