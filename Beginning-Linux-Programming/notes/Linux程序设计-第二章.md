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
    
    //假定我要kill一个进程  
    //IF 在我kill之前，进程已经结束了，那么执行kill的时候，kill命令将向 标准错误输出 写一条错误信息  
    //S.T. 可以阻止kill命令向屏幕写任何内容  
    $ kill -HUP 1234 > killout.txt 2>killerr.txt    //将标准输出和标准错误输出分别重新定向到两个不同的文件  
    $ kill -1 1234 >killouterr.txt 2>&1             //用 `>&` 将两组输出都重新定向到一个文件
    $ kill -1 1234 >/dev/null 2>&1                  //丢弃所有输出信息到回收站

### 2.4.2 Redirecting Input 重新定向输入  
*例子*: `more < killout.txt`  

### 2.4.3 Pipes 管道  
You can connect processes using the pipe operator `|`.  
你可以用管道操作符 `|` 来连接进程。  

In Linux, process connected by pipes can run simultaneously and are automatically resheculed as data flows between them.  
在Linux下通过管道连接的进程可以同时运行，并且随着数据流在他们之间的传递可以自动地进行协调。  

*例子：*  
````
    // 不使用管道:
    $ ps > psout.txt 
    $ sort psout.txt > pssort.out

    // 使用管道
    $ ps | sort > passort.out

    // 继续使用管道连接
    $ ps -xo comm | sort | uniq | grep -vsh | more
    // 1. 按字母排序 排序 ps命令的输出
    // 2. 用 uniq 命令去除名字相同的进程
    // 3. 用 grep -vsh 删除名为sh的进程
    // 4. 将结果分页显示在屏幕上
````

**绝对不要在命令流中重复使用相同的文件名**

## 2.5 The Shell as a Programming Language 作为程序设计语言的Shell
编写shell脚本有两种方式：
1. 输入一系列命令让交互的执行
2. 把命令保存到一个文件中，作为一个程序来调

### 2.5.1 Interactive Programs 交互式程序
*例子：从大量C语言源文件中查找包含字符串POSIX的文件*
````
$ for file in *
> do
> if grep -1 POSIX $file    \\grep 输出他找到的包含 POSIX 字符串的文件
> then                      
> more $file                \\more 命令将文件内容显示在屏幕上
> fi
> done                      \\返回shell提示符
````

shell支持通配符拓展：  
`* 匹配字符串`；`? 匹配单个字符`；`[set] 匹配方括号中任意一个单字符`；`[^set] 取反`；`{str1,str2}匹配字符串`

### 2.5.2 Creating a Script 创建脚本
 *脚本范例：*
 ````
#! /bin/sh

# first
# This file looks through all the files in the current
# directory for the string POSIX, and then prints the names of
# those files to the standard output.

for file in * 
do 
    if grep -q POSIX $file
    then
        echo $file
    fi
done

exit 0
 ````

`#!/bin/sh` 是一种特殊形式的注释：`#!`告诉系统，后面跟着的参数`/bin/sh`是用来执行文件的程序。
注释中用的是绝对路径。

因为脚本程序本质上可以被看作是shell的标准输入，所以它可以包含任何通过你的PATH环境变量引用到Linux的命令。

退出码：0表示成功

脚本文件没有任何的拓展名或者后缀，用`.sh`也可以

### 2.5.3 Making a Script Executable 把脚本设为可执行
#### 调用脚本的两种方法
1. 调用shell，并把脚本文件名作为一个参数：  
例子：
`$ bin/sh first`  
In this way,只要输入脚本的名字就可以调用了
如果运行是报错，需要把当前目录设置成Shell的PATH环境变量要查找执行命令的对象

2. （推荐）在保存脚本的目录输入`./first`：
把脚本程序的完整相对路径告诉shell
**能够保证shell不会意外之行系统中的同名程序**

---
完成后的脚本要移动到哪里？  
- 自己用：在自己的home目录创建一个bin目录，并且将这个目录添加到PATH变量
- 让他人也能用：`/usr/local/bin`或者其他合适的位置

防止其他用户修改脚本程序：  
*去掉脚本程序的写权限:*
````
# cp first /usr/local/bin 
# chown root /usr/local/bin/first 
# chgrp root /usr/local/bin/first 
# chmod 755 /usr/local/bin/first
````


