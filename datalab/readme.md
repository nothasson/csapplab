
> https://github.com/myisabella/datalab/blob/master/bits.c
> 
> https://zhuanlan.zhihu.com/p/59534845


## DataLab 


出现 cannot execute binary file: Exec format error
```
sudo apt update
sudo apt install qemu-user-static
sudo update-binfmts --install i386 /usr/bin/qemu-i386-static --magic >'\x7fELF\x01\x01\x01\x03\x00\x00\x00\x00\x00\x00\x00\x00\x03\x00\x03\x00\x01\x00\x00\x00' --mask >'\xff\xff\xff\xff\xff\xff\xff\xfc\xff\xff\xff\xff\xff\xff\xff\xff\xf8\xff\xff\xff\xff\xff\xff\xff'
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install gcc:i386 /*wrong in my wsl but can still run programs correctly*/

```

开始32位架构


## 思想感想：
- 难度比较大，其中很多题并不是我独立思考的，哈哈哈
- 不过做的过程还是挺有乐趣的，第一次写这种作业。 --- 俺都研一了哈哈
- 要继续加油！