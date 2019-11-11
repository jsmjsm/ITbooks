# Linux程序设计-第二章.md

## 2.2 一点Unix的哲学
`ls -al | more`   
使用 ls 和 more 工具并通过管道实现文件列表的分屏显示

`   man bash | col -b | lpr`  
打印 bash使用手册的参考副本

想让工具执行得更快：现在 shell 中实现原型，再用更快的语言去实现它们。

## 2.3 什么是shell
``A shell is a program that acts as the interface between you and the Linux system, enabling you to enter commands for the operating system to execute.``  
shell 是一个作为用户和 Linux系统间的接口程序。它允许用户向操作系统输入需要执行得命令

`<>` 对输入和输出进行重新定向
` | ` 在同时执行的程序之间实现数据的管道传输
`$(...)` 获取子进程的输出

`/bin/bash --version` 查看bash的版本号

## 2.4 Pipe and Redirection | 管道和重新定向   
### 2.4.1 Redirecting output 重定向输出
文件描述符号： 0 - 标准输入；1 - 标准输出；2 - 标准错误输出

`$ ls -l > lsoutput.txt` 把 ls 命令的输出保存到 lsoutput.txt 这个文件里面
通过 `>` 把标准输出重新定向到一个文件（会覆盖原有内容）
`>>` 将输出内容附加到指定文件的尾部

#### 对标准错误输入进行重新定向：
把想要重新定向的文件描述符号加在`>`前面  
*例子：*  
    **想要丢弃错误信息并且阻止它在屏幕上显示**：用 `2>`  
    假定我要kill一个进程  
    IF 在我kill之前，进程已经结束了，那么执行kill的时候，kill命令将向 standard error   output（标准错误输出） 写一条错误信息  
    S.T. 可以阻止kill命令向屏幕写任何内容  
    `$ kill -HUP 1234 > killout.txt 2>killerr.txt`  // 将标准输出和标准错误输出分别重新定向到两个不同的文件  
    `$ kill -1 1234 >killouterr.txt 2>&1`   //用 `>&` 将两组输出都重新定向到一个文件
    `$ kill -1 1234 >/dev/null 2>&1` // 丢弃所有输出信息到回收站

### 2.4.2 Redirecting Input 重新定向输入
*例子*: `more < killout.txt`






















